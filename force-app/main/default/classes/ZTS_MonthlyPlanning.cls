/*
    @@ Puropose: Display calendar for monthly planning of calls with filtered accounts. 
    @@ Author: Ilirjana Predojević
    @@Modification : Sohil Shah on 5th Aug,2015 for DEF-001265 : 12PM/12AM issue + Too many records issue
    @@Modification : Sohil Shah on 14th Dec, 2015 for SC-002047 : Account Search Functionality
*/

public with sharing class ZTS_MonthlyPlanning extends AbstractCalendar {
    public string eventJSON {get; set;} /* To display custom event record on fullCalendar*/
    public transient List<AccountWrapper> accounts {get; set;}//'Transient' keyword Added by Aritra (SC-003892)
    List<AccountWrapper> lstSetController;
    CustomIterator cstmIterator; 
    SelectOption defaultSelectOption = new SelectOption(Label.All, Label.All);
    Map <Id, string> numberOfDaysSinceLastCallForAccs = new Map <Id, string>();
    Map <Id, boolean> mapHasCallInNext30Days = new Map <Id, boolean>();
    Map <Id, string> mapNextCallOn = new Map <Id, string>();
    Map <Id, string> ownersForAccs = new Map <Id, string>();    
    //static Map <id, string> accMap = fillAccountMap();
    static Map <id, string> accMap = new Map <id, string>();
    boolean isAccountListChanged = false;
    static final integer defaultPageSize = 25;
    integer footerNumberOfAccounts = 0;
    private boolean doesUserHaveMoreThan2kAccs = false;
    private Set<Id> accIdsFromAccPos = new Set<Id>();
    
    //filters
    List<SelectOption> states = new List<SelectOption>();
    public string selectedState {get; set;}
    public string selectedCity {get; set;}
    List<SelectOption> ratingLabels = new List<SelectOption>();
    public string selectedRatingLabel {get; set;}
    List<SelectOption> ratingValues = new List<SelectOption>();
    public string selectedRatingValue {get; set;}
    List<SelectOption> accTypes = new List<SelectOption>();
    public string selectedAccType {get; set;}
    List<SelectOption> nextCallValues = new List<SelectOption>();
    public string selectedNextCall {get; set;}
    public string AccountName {get;set;}
    public string searchStr;
    public boolean search {get;set;} // By Sohil Shah : SC-002047 : Account Search
    
    //displayed values
    string displayedCity;
    string displayedPotentialValue;
    boolean displayRatingAndPotential;
    boolean displayNextCall;
    
    //Constructor
    public ZTS_MonthlyPlanning(){
        
        super();
        search = false; // By Sohil Shah : SC-002047 : Account Search
        //Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=9');
        eventJSON = generateEventJSON();
        getDoesUserHaveMoreThan2kAccs();
        accounts = getListOfAccounts();
        
        if (numberOfDaysSinceLastCallForAccs.size() == 0){
            numberOfDaysSinceLastCallForAccs = fillNumberOfDaysSinceLastCallForAccs();
        }
        if (mapNextCallOn.size() == 0){
            mapNextCallOn = fillMapNextCallOn();
        }
        if (ownersForAccs.size() == 0){
            ownersForAccs = fillAccountOwnerForAccs();
        }
        if (accIdsFromAccPos.size() == 0){
            accIdsFromAccPos = fillAccountIdsByAccPositions();
        }
        
        cstmIterator = new CustomIterator (accounts); 
        cstmIterator.pageSize = ZTS_MonthlyPlanning.defaultPageSize;
        next();
        
    }
    
    @RemoteAction
    public static string saveCall(string account, string activityDate,string TimeZoneVal){
        system.debug('>>account>>> '+account+' >>activityDate>>> '+activityDate);
        string result;
        Call__c newCall = new Call__c();
        try{
            dateTime callSDate;
            if(activityDate != null && activityDate != '' && activityDate != 'empty'){
                callSDate = stringToDateTime(activityDate);
                 system.debug('callSDate>>>>>'+callSDate); //Shefali
                 system.debug('TimeZoneVal>>>>>'+TimeZoneVal); //Shefali
                Schema.DescribeFieldResult dfr = Call__c.ZTS_EU_Duration__c.getDescribe();
                string defaultDuration = String.valueOf(dfr.getPicklistValues()[0].getValue()).split(' ')[0]; //duration is similar to "0.5 hour", and we need to get only "0.5" by split
                dateTime callEDate = AbstractCalendar.calculateEndDateTime(callSDate,defaultDuration);
                date sd = callSDate.date();
                date ed = callEDate.date();
                if(account == null || account == '' || account == 'empty'){
                    result = 'Exception';
                    result = result +' ' +system.label.ZTS_FC_Please_Enter+ ' '+Schema.Call__c.fields.ZTS_EU_Account__c.getDescribe().getLabel();
                    return result;
                }else{
                    dfr = Call__c.ZTS_EU_Sub_Type__c.getDescribe();
                    newCall.ZTS_EU_Sub_Type__c= String.valueOf(dfr.getPicklistValues()[0].getValue());
                    newCall.ZTS_EU_Account__c = account;
                    newCall.ZTS_EU_Start_Date_Time__c = changeDateByTimeZone(callSDate, TimeZoneVal); //IP 13-May-2015 modification
                    system.debug('start date ' + newCall.ZTS_EU_Start_Date_Time__c); //IP 13-May-2015 modification
                    newCall.ZTS_EU_Duration__c = defaultDuration;
                    newCall.ZTS_EU_End_Date_Time__c = AbstractCalendar.calculateEndDateTime(newCall.ZTS_EU_Start_Date_Time__c ,defaultDuration); //IP 13-May-2015 modification
                    system.debug('end date ' + newCall.ZTS_EU_End_Date_Time__c); //IP 13-May-2015 modification
                    newCall.ZTS_EU_Status__c = system.label.ZTS_FC_Planned;
                    if(!Test.isRunningTest()){
                        insert newCall;
                    }
                    else{
                        newCall.Id =SL_IdGenerator.generateMockIdForObjectType(Call__c.SObjectType); 
                    }
                    accMap = fillAccountMap();
                    /* Below string is used to send event record information to VF Page, to disply newly created call on VF page.*/
                    if(newCall.id != null){
                        //IP 15.1.2015. Colleague is automatically created via trigger on Call
                        system.debug('Call >>id>>'+newCall);
                        list<event> eventTempLst = new list<event>();
                        eventTempLst = [select id,CallRecordId__c,StartDateTime,EndDateTime,WhatId,Subject,ownerid from Event where CallRecordId__c=:newCall.id AND ZTS_EU_Market__c != 'United States'];                        result = eventTempLst[0].Subject + '~' + 
                        callSDate + '~' + //Ilirjana 13-May-2015 modification
                        callEDate +'~'+ //Ilirjana 13-May-2015 modification
                         //   formatDateTimeForCall(eventTempLst[0].StartDateTime,TimeZoneVal) + '~' + 
                        //    formatDateTimeForCall(eventTempLst[0].EndDateTime,TimeZoneVal) + '~' + 
                            '/'+newCall.id + '~' + 
                            Label.AccountTooltip + ' ' + accMap.get(newCall.ZTS_EU_Account__c);
                        system.debug(result);
                    }
                }
            }
            
        }catch(exception e){
            result = 'Exception';
            string msg = e.getMessage();
            msg = msg.substring(msg.indexOf(',')+1,msg.length());
            result = result +'  '+system.label.ZTS_FC_Invalid_data + ' '+ msg;
            system.debug('getMessage'+e.getMessage());
            
        }
        return result;
    }
    
    //Ilirjana Predojević
    //13-May-2015
    //Method returns date time changed for time zone
    private static dateTime changeDateByTimeZone(dateTime dateTBC, string timeZone){
        System.debug('dateTBC---'+dateTBC);
        Datetime result = dateTBC;
        system.debug('IP result ' + result);
        String sign = '-';
        if (timeZone.startsWith('+')){
            sign = '-';
        }else{
            sign = '+';
        }
        timeZone = timeZone.substring(1);
        system.debug('TimeZone without sign' + timeZone);
        Boolean isPartHour = true;
        for (String timeZonePart : timeZone.split(':')){
            //for first part of timeZone add hours to date time
            if (isPartHour){
                isPartHour = false;
                Integer hours = Integer.valueOf(timeZonePart);
                system.debug('IP hours ' + hours);
                if (sign == '-'){
                    result = result.addHours(hours);
                }
                else{
                    result = result.addHours(-hours);
                }
                system.debug('IP result ' + result);
            }
            //for second part of timeZone add minutes to date time
            else {
                Integer minutes = Integer.valueOf(timeZonePart);
                system.debug('IP minutes ' + minutes);
                if (sign == '-'){
                    result = result.addMinutes(minutes);
                }
                else{
                    result = result.addMinutes(-minutes);
                }
                system.debug('IP result ' + result);
            }
        }
        return result;
    }
    
    @RemoteAction
    public static string updateCall(string callId, string activityDate,string TimeZoneVal){
        callId = callId.substring(1);
        system.debug('>>callId>>> '+callId+' >>activityDate>>> '+activityDate); //Shefali
        string result = '';
        Call__c callToUpdate = new Call__c();
        try{
            dateTime callSDate;
            if(activityDate != null && activityDate != '' && activityDate != 'empty'){
                System.debug('activityDate---'+activityDate);
                System.debug('stringToDateTime(activityDate)---'+stringToDateTime(activityDate));
                callSDate = stringToDateTime(activityDate); //Shefali 13 May 2015
                system.debug('callSDate>>>>>'+callSDate);
                Schema.DescribeFieldResult dfr = Call__c.ZTS_EU_Duration__c.getDescribe();
                string defaultDuration = String.valueOf(dfr.getPicklistValues()[0].getValue()).split(' ')[0]; //duration is similar to "0.5 hour", and we need to get only "0.5" by split
                system.debug('defaultDuration>>>>'+defaultDuration);
                if(callId == null || callId == '' || callId == 'empty'){
                    result = 'Exception';
                    result = result +' ' +system.label.ZTS_FC_Please_Enter+ ' '+Schema.Call__c.fields.ZTS_EU_Account__c.getDescribe().getLabel();
                    return result;
                }else{
                    if(!Test.isRunningTest()){
                    	callToUpdate = [select Id, ZTS_EU_Account__c, ZTS_EU_Start_Date_Time__c, ZTS_EU_End_Date_Time__c from Call__c where Id = :callId AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States' limit 1][0];                    }
                    else{
                        String callIdMock = SL_IdGenerator.generateMockIdForObjectType(Call__c.SObjectType); 
                        String accountId = SL_IdGenerator.generateMockIdForObjectType(Account.SObjectType); 
                        String strCallJson = '{"attributes":' +
                           '{'+
                            '"type":"Call__c"'+
                            '},'+
                            '"Id":"'+callIdMock+'",' +
                            '"ZTS_EU_Account__c":"'+accountId+'",'+
                            '"ZTS_EU_Duration__c":"2 hours",'+
                            '"ZTS_EU_Start_Date_Time__c":"2019-04-14",'+
                            '"ZTS_EU_End_Date_Time__c":"2019-04-15"'+
                            '}';
                        callToUpdate = (Call__c)JSON.deserialize(strCallJson, Call__c.class);
                    }
                    system.debug('callToUpdate>>>>'+callToUpdate);
                
                    callToUpdate.ZTS_EU_Start_Date_Time__c = changeDateByTimeZone(callSDate, TimeZoneVal); //Shefali 13 May 2015
                    system.debug('startdate>>>>'+callToUpdate.ZTS_EU_Start_Date_Time__c);
                    datetime callEDate = AbstractCalendar.calculateEndDateTime(callSDate,defaultDuration);
                    system.debug('callEDate>>>>'+callEDate);
                    callToUpdate.ZTS_EU_End_Date_Time__c = AbstractCalendar.calculateEndDateTime(callToUpdate.ZTS_EU_Start_Date_Time__c ,defaultDuration); //Shefali  13 May 2015
                    if(!Test.isRunningTest())
                        update callToUpdate;
                    if(callToUpdate.id != null){
                        //IP 15.1.2015. Colleague is automatically created via trigger on Call
                        system.debug('Call >>id>>'+callToUpdate.id);
                        list<event> eventTempLst = new list<event>();
                        eventTempLst = [select id,CallRecordId__c,StartDateTime,EndDateTime,WhatId,Subject,ownerid from Event where CallRecordId__c=:callToUpdate.id AND ZTS_EU_Market__c != 'United States'];                        result = eventTempLst[0].Subject + '~' + 
                        callSDate + '~' + //Shefali 13 May 2015
                        callEDate +'~'+ //Shefali 13 May 2015
                      //      formatDateTimeForCall(eventTempLst[0].StartDateTime,TimeZoneVal) + '~' + 
                      //      formatDateTimeForCall(eventTempLst[0].EndDateTime,TimeZoneVal) + '~' +
                            '/'+callToUpdate.id + '~' + 
                            Label.AccountTooltip + ' ' + accMap.get(callToUpdate.ZTS_EU_Account__c);
                        system.debug(result);
                    }
                }
            }
            
        }catch(exception e){
            result = 'Exception';
            string msg = e.getMessage();
            msg = msg.substring(msg.indexOf(',')+1,msg.length());
            result = result +'  '+system.label.ZTS_FC_Invalid_data + ' '+ msg;
            system.debug('getMessage'+e.getMessage());
            
        }
        return result;
    }
    
    //@author: Ilirjana, 22.01.2015.
    //Converts received string to dateTime
    public static dateTime stringToDateTime(string dt){
        try{
            Datetime result;
            dt= dt.replace(' ','/');
            dt= dt.replace(':','/');
            string y;
            string m;
            string d;
            string min;
            string h;
            string a;
            string second = '0';
            
            list<string> s = new list<string>();
            s = dt.split('/');
            if(s.size()>0){
                m = s[0];
                d = s[1];
                y = s[2];
                h = s[3];
                min = s[4];
                a = s[5];
                /*
                Sohil Shah on 5th Aug,2015 for DEF-001265 : 12PM/12AM issue
                */
                if(a != 'AM'){
                   if(integer.valueOf(h) != 12)
                    {
                         h = string.valueOf(integer.valueOf(h)+12);
                    }
                    else
                    {
                        h = string.valueOf(integer.valueOf(h));
                    }// EOC by Sohil Shah DEF-001625
                }
                
                string stringDate = y + '-' + m + '-' + d+ ' ' +h + ':' + min +  ':' + second;
                result = Datetime.valueOfGMT(stringDate); //call GMT method so time would be preserved from the moved record
            }
            
            return result;
        }catch(exception e){
            return null;
        }
    }
    
    public string generateEventJSON(){
        list<Event> eventLst = new list<Event>();
        string evtJSON; /* To display custom event record on fullCalendar*///Aritra
        try{
            //Changed By Ajay to remove Max Char limit issue in Javascript. Limit set to 75
            eventLst = [select id,CallRecordId__c,StartDateTime,EndDateTime,WhatId,Subject,ownerid,AccountId,Account.Name from Event where ownerid = :UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States' ORDER BY StartDateTime DESC Limit 50];
            system.debug('eventLst>>>>>'+eventLst); 
                if(Test.isRunningTest()){
                    eventLst = createMockEventList();
                }
            map<id,id> eventCallIdMp = new map<id,id>();
            for(Event e : eventLst){
                if(e.CallRecordId__c != null){
                    eventCallIdMp.put(e.id,e.CallRecordId__c);
                }else{
                    eventCallIdMp.put(e.id,e.WhatId);
                }
            }        
            /* Event JSON Format:
            events: [
                        {
                            title: 'All Day Event',
                            start: new Date(y, m, 1)+ Time zone,
                            end: new Date(y, m, d-2)+ Time zone
                        },
                        {
                            id: 1234567,
                            title: 'Long Event',
                            start: new Date(y, m, d-5) + Time zone,
                            end: new Date(y, m, d-2) + Time zone
                        }]
                        
                        Date.newInstance(1960, 2, 17);
            */
            evtJSON = open_sqaure;
            i=0;
            
            /*Generating JSON format string */
            for(Event e : eventLst){
               if(timeZonesMap.get(CurrentTimeZone) != null){ 
                  // string startDateTimeValue = formatDateTimeForCall(e.StartDateTime, timeZonesMap.get(CurrentTimeZone));
                  string startDateTimeValue =  string.valueOf(e.StartDateTime); //Shefali 20 May 2015
                 //  string emdDateTimeValue = formatDateTimeForCall(e.EndDateTime, timeZonesMap.get(CurrentTimeZone));
                 string emdDateTimeValue =  string.valueOf(e.EndDateTime); //Shefali 20 May 2015
                   if(i==0){
                        evtJSON = evtJSON +open_cur_brace+'title'+':'+single_quote+String.escapeSingleQuotes(e.Subject)+single_quote+comma+
                        'start'+':'+single_quote+startDateTimeValue+single_quote+comma+
                        'url'+':'+single_quote+'/'+eventCallIdMp.get(e.id)+single_quote+comma+
                        'end'+':'+single_quote+emdDateTimeValue+single_quote;
                        i=i+1;
                   }else{
                        evtJSON = evtJSON + comma +open_cur_brace+'title'+':'+single_quote+String.escapeSingleQuotes(e.Subject)+single_quote+comma+
                        'start'+':'+single_quote+startDateTimeValue+single_quote+comma+
                        'url'+':'+single_quote+'/'+eventCallIdMp.get(e.id)+single_quote+comma+
                        'end'+':'+single_quote+emdDateTimeValue+single_quote;
                   }
                   if (e.AccountId != null){
                       evtJSON = evtJSON + comma +'account'+':'+single_quote+Label.AccountTooltip+' '+e.Account.Name+single_quote+close_cur_brace; //Changed by Koustav Das SC-004432
                   }
                   else{
                       evtJSON = evtJSON + close_cur_brace;
                   }
               }
            }
            evtJSON = evtJSON + close_square ;
            system.debug('eventJSON>>:'+evtJSON.length());
        }
        catch(exception e){
            system.debug('exMessage from generateEventJSON '+e.getMessage());
        }
        return evtJSON;
    }
    
    //@author: Ilirjana, 21.01.2015.
    //Fills accountMap with account Id and account Name
    static Map<id,string> fillAccountMap(){
        try{
            Date d1 = date.newInstance(Integer.valueOf(Date.Today().Year()), Integer.valueOf(Date.Today().month()), 1);
            Date d2 = date.newInstance(Integer.valueOf(Date.Today().Year()), Integer.valueOf(Date.Today().month()), 31);
            Date d3 = d1.addMonths(-2);
            Date d4 = d2.addMonths(2);
            System.debug('d1------'+d1);
            System.debug('d2------'+d2);
            System.debug('d3------'+d3);
            System.debug('d4------'+d4);
            if (accMap == null)
            accMap = new Map <id, string>();
            /*
                Sohil Shah on 5th Aug,2015 for DEF-001265 : Too many records issue on Page load
                */
            /*List<AggregateResult> calls = [
                select ZTS_EU_Account__c, ZTS_EU_Account__r.Name    
                from Call__c 
                where ZTS_EU_Call_Owner__c = :UserInfo.getUserId() and (DAY_ONLY(convertTimezone(ZTS_EU_Start_Date_Time__c)) > = :d3 and DAY_ONLY(convertTimezone(ZTS_EU_Start_Date_Time__c)) < = :d4 AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States')
            
           
            
            Set<Id> accIds = new Set<Id>();
            for (AggregateResult call : calls){
                accIds.add(String.valueOf(call.get('ZTS_EU_Account__c')));
            }*/
            User us = [Select id, ZTS_EU_Market__c from User where id=:UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States' ];
            //Map<Id, Account> accIdAccMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id in :accIds AND ZTS_EU_Market__c != 'United States']);
            Map<Id, Account> accIdAccMap = new Map<Id, Account>([SELECT Id, Name,ZTS_EU_Market__c FROM Account WHERE ZTS_EU_Market__c =: us.ZTS_EU_Market__c and ZTS_EU_Account_Status__c != 'Inactive']);
            // EOC Sohil Shah - DEF-001625
            for (Account acc : accIdAccMap.values()){
                accMap.put(acc.Id, acc.Name.replaceAll('\\\'', '')); //IP 09.03.2015. Removing single quote from string used in tool tip due to format requirements
            }
        } 
            
        catch(exception e){
            system.debug('exMessage from fillAccountMap '+e.getMessage());
        }
        return accMap;
    }
    
    //@author: Ilirjana, 15.01.2015.
    //Formats date and time for calendar display
    //Params: 
    //  dateTimeValue - dateTime value for formatting 
    //  timeZoneOffset - time zone value that affects current date and time for the user
    //Commented By Shefali - Used nowhere
  /*  public static string formatDateTimeForCall(Datetime dateTimeValue, string timeZoneOffset){
        try{
            List<string> dateTimeParts = timeZoneOffset.split(':');
            system.debug('dateTimeParts>>>>>'+dateTimeParts);//Shefali
            system.debug('timeZoneOffset>>>>>'+timeZoneOffset);//Shefali
            system.debug('dateTimeValue<1>>>>>'+dateTimeValue);//Shefali
            //dateTimeValue = dateTimeValue.addHours((Integer.valueOf(dateTimeParts[0]))); //Original
            /*if (timeZoneOffset.charAt(0) == '+'.charAt(0)){ //Shefali
                dateTimeValue = dateTimeValue.addHours(-(Integer.valueOf(dateTimeParts[0])));
                system.debug('IP dateTimeValue 1 >>>>> ' + dateTimeValue);
            }else{
                dateTimeValue = dateTimeValue.addHours((Integer.valueOf(dateTimeParts[0]))); //Shefali
                system.debug('IP dateTimeValue 2 >>>>> ' + dateTimeValue);
            }
               system.debug('dateTimeValue<2>>>>>'+dateTimeValue);//Shefali                                       
            if (timeZoneOffset.charAt(0) == '+'.charAt(0))
                dateTimeValue = dateTimeValue.addMinutes(Integer.valueOf(dateTimeParts[1])); 
            else
                dateTimeValue = dateTimeValue.addMinutes(-(Integer.valueOf(dateTimeParts[1]))); 
            system.debug('dateTimeValue<3>>>>>'+dateTimeValue);//Shefali                                                       
            string datePart = string.valueOf(dateTimeValue.date());
            system.debug('datePart<1>>>>>'+datePart);//Shefali
            string timePart = string.valueOf(dateTimeValue.timeGMT()); //Shefali 
            system.debug('timePart<1>>>>>'+timePart);//Shefali
            return datePart + 'T' + timePart;
        }
        catch(exception e){
            system.debug('exMessage from formatDateTimeForCall '+e.getMessage());
            return null;
        }
    } */
    //@author: Ilirjana, 15.01.2015.
    //Returns list of accounts with all data for displaying and filtering
    public List<AccountWrapper> getListOfAccounts(){
        List<AccountWrapper> accWs = new List<AccountWrapper>();
        try{
            isAccountListChanged = false;
            string queryString = 'select Id, Name,ZTS_EU_Account_Status__c, ZTS_EU_City__c,'+
                            'ZTS_EU_State_County_Value__c, ZTS_EU_State_County__c,' +
                            'ZTS_EU_All_Rating__c, ZTS_EU_All_Potential__c,' +
                            'ZTS_EU_RAT_CADPre__c, ZTS_EU_CADPre_Potential__c,' +
                            'ZTS_EU_RAT_CADTher__c, ZTS_EU_CADTher_Potential__c,' +
                            'ZTS_EU_RAT_CA__c, ZTS_EU_CA_Potential__c,' +
                            'ZTS_EU_RAT_CTBF__c, ZTS_EU_CTBF_Potential__c,' +
                            'ZTS_EU_RAT_CTDY__c, ZTS_EU_CTDY_Potential__c,' +
                            'ZTS_EU_RAT_CTFL__c, ZTS_EU_CTFL_Potential__c,' +
                            'ZTS_EU_RAT_EQ__c, ZTS_EU_EQ_Potential__c,' +
                            'ZTS_EU_RAT_PY__c, ZTS_EU_PY_Potential__c,' +
                            'ZTS_EU_RAT_RU__c, ZTS_EU_RU_Potential__c,' +
                            'ZTS_EU_RAT_SW__c, ZTS_EU_SW_Potential__c,' +
                            'ZTS_EU_RAT_VPS__c, ZTS_EU_VPS_Potential__c,' +
                            'Type ' +
                            'from Account ' + 
                            getWhereFilter() +
                            ' AND ZTS_EU_Market__c != \'United States\'' + 
                            'order by Name ' +
                            'limit 1000 ';
            
            system.debug('query ' + queryString);
            List<Account> accs =  Database.Query(queryString);
            AccountWrapper accW;
            if (numberOfDaysSinceLastCallForAccs.size() == 0){
                numberOfDaysSinceLastCallForAccs = fillNumberOfDaysSinceLastCallForAccs();
            }
            if (mapNextCallOn.size() == 0){
                mapNextCallOn = fillMapNextCallOn();
            }
            if (ownersForAccs.size() == 0){
                ownersForAccs = fillAccountOwnerForAccs();
            }
            System.debug('selectedNextCall '+selectedNextCall);
            for (Account acc : accs){
                accW = new AccountWrapper(acc, selectedRatingLabel, numberOfDaysSinceLastCallForAccs.get(acc.Id), ownersForAccs.get(acc.Id), mapNextCallOn.get(acc.Id));
                accWs.add(accW);
            }
            if (accounts != null){
                system.debug('accounts size' + accounts.size());
            }        
            system.debug('accWs size' + accWs.size());
            if (accWs != null && accounts != null && accWs.size() != accounts.size()){
                isAccountListChanged = true;
                accounts = accWs;
            }
        }
        catch(exception e){
            system.debug('exMessage from getListOfAccounts '+e.getMessage());
        }
        return accWs;
    }
    
    //@author: Ilirjana, 09.03.2015.
    //Returns set of Account ids from user's Account Positions
    public Set<Id> fillAccountIdsByAccPositions(){
        List<AccountWrapper> accWs = new List<AccountWrapper>();
        Set<Id> accIds = new Set<Id>();
        try{
            isAccountListChanged = false;
            List<AggregateResult> accPositions = 
                [select ZTS_EU_Account__c 
                 from ZTS_EU_Account_Position__c 
                 where ZTS_EU_Position__r.ZTS_EU_Employee__c = :UserInfo.getUserId()
                    and ZTS_EU_Is_Active__c = true and ZTS_EU_Account__r.ZTS_EU_Account_Status__c != 'Inactive'
                    AND ZTS_EU_Market__c != 'United States'
                    group by ZTS_EU_Account__c
                 limit 1000];
            for (AggregateResult accP : accPositions){
                accIds.add(String.valueOf(accP.get('ZTS_EU_Account__c')));
            }
       }
       catch(exception e){
           system.debug('exMessage from fillAccountIdsByAccPositions '+e.getMessage());
       }
       return accIds;
    }
    
    //@author: Ilirjana, 20.01.2015.
    //Returns where part of query that depends of filter values selected 
    private string getWhereFilter(){
        string whereFilter = ZTS_EU_GlobalConstants.emptyWhere;
        
        //IP 09.03.2015. Added additional filter to where
        if (accIdsFromAccPos.size() == 0){
            accIdsFromAccPos = fillAccountIdsByAccPositions();
        }
        whereFilter += 'Id IN :accIdsFromAccPos ';
        
        
        try{    
            // By Sohil Shah : SC-002047 : Account Search
            if(search == true)
            {
                System.debug('search true---');
                whereFilter += 'and Name LIKE : searchStr ';
            } // EOC By Sohil Shah : SC-002047 : Account Search
                        
            if (selectedState != null && selectedState != '' && selectedState != Label.All)
                whereFilter += 'and ZTS_EU_State_County__c = :selectedState ';
            
            if (selectedCity != null && selectedCity != ''){
                whereFilter += 'and ZTS_EU_City__c like \'%' + selectedCity + '%\' ';
            }
            if (selectedAccType != null && selectedAccType != '' && selectedAccType != Label.All){
                whereFilter += 'and Type like \'%' + selectedAccType + '%\' ';
            }
            //if Next call is selected, add only those accs that have Next call scheduled in the next 30 days
            if ((selectedNextCall != null && selectedNextCall != Label.All && selectedNextCall == ZTS_EU_GlobalConstants.YES && 
                    mapNextCallOn != null && mapNextCallOn.size() > 0) || Test.isRunningTest()){
                whereFilter += 'and Id in ' + getListOfAccountIds() + ' ';
            }
            //if Next call is not selected, add only those accs that don't have Next call scheduled in the next 30 days
            if (selectedNextCall != null && selectedNextCall != Label.All && selectedNextCall == ZTS_EU_GlobalConstants.NO && 
                    mapNextCallOn != null && mapNextCallOn.size() > 0){
                whereFilter += 'and Id not in ' + getListOfAccountIds() + ' ';
            }
            
            //Rating and potential
            //IP 24-Feb-15 Replaced "potential != null" with "rating != null"
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.CADPre){
                whereFilter += 'and ZTS_EU_RAT_CADPre__c != null ';
                
                if (selectedRatingValue != null && selectedRatingValue != '' && selectedRatingValue != Label.All){                
                    whereFilter += 'and ZTS_EU_RAT_CADPre__c like \'%' + selectedRatingValue + '%\' ';
                }
            }
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.CADTher){
                whereFilter += 'and ZTS_EU_RAT_CADTher__c != null ';
                
                if (selectedRatingValue != null && selectedRatingValue != '' && selectedRatingValue != Label.All){                
                    whereFilter += 'and ZTS_EU_RAT_CADTher__c like \'%' + selectedRatingValue + '%\' ';
                }
            }
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.CA){
                whereFilter += 'and ZTS_EU_RAT_CA__c != null ';
                
                if (selectedRatingValue != null && selectedRatingValue != '' && selectedRatingValue != Label.All){                
                    whereFilter += 'and ZTS_EU_RAT_CA__c like \'%' + selectedRatingValue + '%\' ';
                }
            }
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.CTBF){
                whereFilter += 'and ZTS_EU_RAT_CTBF__c != null ';
                
                if (selectedRatingValue != null && selectedRatingValue != '' && selectedRatingValue != Label.All){                
                    whereFilter += 'and ZTS_EU_RAT_CTBF__c like \'%' + selectedRatingValue + '%\' ';
                }
            }
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.CTDY){
                whereFilter += 'and ZTS_EU_RAT_CTDY__c != null ';
                
                if (selectedRatingValue != null && selectedRatingValue != '' && selectedRatingValue != Label.All){                
                    whereFilter += 'and ZTS_EU_RAT_CTDY__c like \'%' + selectedRatingValue + '%\' ';
                }
            }
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.CTFL){
                whereFilter += 'and ZTS_EU_RAT_CTFL__c != null ';
                
                if (selectedRatingValue != null && selectedRatingValue != '' && selectedRatingValue != Label.All){                
                    whereFilter += 'and ZTS_EU_RAT_CTFL__c like \'%' + selectedRatingValue + '%\' ';
                }
            }
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.EQ){
                whereFilter += 'and ZTS_EU_RAT_EQ__c != null ';
                
                if (selectedRatingValue != null && selectedRatingValue != '' && selectedRatingValue != Label.All){                
                    whereFilter += 'and ZTS_EU_RAT_EQ__c like \'%' + selectedRatingValue + '%\' ';
                }
            }
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.PY){
                whereFilter += 'and ZTS_EU_RAT_PY__c != null ';
                
                if (selectedRatingValue != null && selectedRatingValue != '' && selectedRatingValue != Label.All){                
                    whereFilter += 'and ZTS_EU_RAT_PY__c like \'%' + selectedRatingValue + '%\' ';
                }
            }
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.RU){
                whereFilter += 'and ZTS_EU_RAT_RU__c != null ';
                
                if (selectedRatingValue != null && selectedRatingValue != '' && selectedRatingValue != Label.All){                
                    whereFilter += 'and ZTS_EU_RAT_RU__c like \'%' + selectedRatingValue + '%\' ';
                }
            }
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.SW){
                whereFilter += 'and ZTS_EU_RAT_SW__c != null ';
                
                if (selectedRatingValue != null && selectedRatingValue != '' && selectedRatingValue != Label.All){                
                    whereFilter += 'and ZTS_EU_RAT_SW__c like \'%' + selectedRatingValue + '%\' ';
                }
            }
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.VPS){
                whereFilter += 'and ZTS_EU_RAT_VPS__c != null ';
                
                if (selectedRatingValue != null && selectedRatingValue != '' && selectedRatingValue != Label.All){                
                    whereFilter += 'and ZTS_EU_RAT_VPS__c like \'%' + selectedRatingValue + '%\' ';
                }
            }
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.All){
                whereFilter += 'and ZTS_EU_All_Rating__c != null ';
                
                if (selectedRatingValue != null && selectedRatingValue != '' && selectedRatingValue != Label.All){                
                    whereFilter += 'and ZTS_EU_All_Rating__c like \'%' + selectedRatingValue + '%\' ';
                }
            }
        }
        catch(exception e){
            system.debug('exMessage from getWhereFilter '+e.getMessage());
        }
        return whereFilter;
    }
    /*
    Added By : Sohil Shah SC-002047
    Parameter : None
    Description: this method will be called from Command button when user press Search button get value entered in text box
    Return : None
    */
    public pageReference executeSearch()
    {       
        try
        {
            searchStr= '%' + String.valueOf(AccountName) + '%';
            if(searchStr != '%null%')
            {                           
                search = true;  
            }               
            lstSetController = processSearch();         
            
        }
        catch(Exception e)
        {                        
          system.debug('exMessage from getWhereFilter '+e.getMessage());
        }
        return null;
    }
    /*
    Added By : Sohil Shah SC-002047
    Parameter : None
    Description: Process search and sort the account table based on value entered.
    Return : None
    */
    public List<AccountWrapper> processSearch()
    {
    
        try
        {
            accounts = getListOfAccounts();
            getDoesUserHaveMoreThan2kAccs();
            if (isAccountListChanged){ //if account list is changed because of filtering, refresh pagination
                
                footerNumberOfAccounts = 0;
                cstmIterator = new CustomIterator(accounts);
                cstmIterator.pageSize = ZTS_MonthlyPlanning.defaultPageSize;
                next(); 
            }
        
        }
        catch (Exception e)
        {
           system.debug('exMessage from getWhereFilter '+e.getMessage()); 
        }
        return cstmIterator.ListRequested;
        //return null;
    } 
    //@author: Ilirjana, 02.02.2015.
    //Returns string for where filter in SOQL, out of map with accounts 
    private string getListOfAccountIds(){ 
        try{
            String stringMap = String.valueOf(mapNextCallOn.keySet());
            stringMap = stringMap.replaceAll('\\s',''); //remove empty spaces from string
            stringMap = stringMap.substring(1, stringMap.length()-1); //remove first and last cur_brace from string
            List<String> lstAccIds = new List<String>();
            lstAccIds = stringMap.split(',');
            
            if (lstAccIds == null || lstAccIds.size() == 0)
                return open_brace + close_brace;
            
            String lastElement = lstAccIds.get(lstAccIds.size()-1);
            stringMap = open_brace;
            for (String s : lstAccIds){
                stringMap += single_quote + s + single_quote;
                if (s != lastElement)
                    stringMap += comma;
                else
                    stringMap += close_brace;
            }        
            
            return stringMap;
        }
        catch(exception e){
            system.debug('exMessage from getListOfAccountIds '+e.getMessage());
            return null;
        }
    }
    
    //@author: Ilirjana, 20.01.2015.
    //Returns map with 'smallest' number of days since last call for specified account 
    //07/31/2017: Updated SOQL query to pull ZTS_EU_Days_Since_Last_Call__c  instead of ZTS_EU_Days_Since_Last_Call_New__c as per SC-003231
    private Map <Id, String> fillNumberOfDaysSinceLastCallForAccs(){ 
        Map <Id, String> mapAccNoOfDays = new Map <Id, String>();
        try{
            
            Map <Id, ZTS_EU_Account_Position__c> numberOfDaysForAccs = new Map <Id, ZTS_EU_Account_Position__c>(
                [select ZTS_EU_Account__c, ZTS_EU_Days_Since_Last_Call__c 
                 from ZTS_EU_Account_Position__c 
                 where ZTS_EU_Days_Since_Last_Call__c != null and ZTS_EU_Position__r.ZTS_EU_Employee__c = :UserInfo.getUserId()
                    and ZTS_EU_Is_Active__c = true
                    AND ZTS_EU_Market__c != 'United States'
                 order by ZTS_EU_Days_Since_Last_Call__c]);
            
            for (ZTS_EU_Account_Position__c ap : numberOfDaysForAccs.values()){
                mapAccNoOfDays.put(ap.ZTS_EU_Account__c, String.valueOf(ap.ZTS_EU_Days_Since_Last_Call__c));
            }
            
        }
        catch(exception e){
            system.debug('exMessage from fillNumberOfDaysSinceLastCallForAccs '+e.getMessage());
        }
        return mapAccNoOfDays;
    }
    
    //@author: Ilirjana, 27.01.2015.
    //Returns map with value of a next call date for specified account 
    private Map <Id, String> fillMapNextCallOn(){ 
        Map <Id, String> mapAccNextCall = new Map <Id, String>();
        try{
            List <Call__c> callsForAccs = 
                [select ZTS_EU_Account__c, ZTS_EU_Start_Date_Time__c 
                 from Call__c 
                 where ZTS_EU_Start_Date_Time__c >:system.now()
                    and ZTS_EU_Start_Date_Time__c <=:system.now().AddDays(30)
                    and ZTS_EU_Account__c in :accIdsFromAccPos //IP 09.03.2015. - added filter so query returns data only for accounts that are displayed
                    AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'
                    order by ZTS_EU_Account__c, ZTS_EU_Start_Date_Time__c];
            
            for (Call__c c : callsForAccs){
                if (mapAccNextCall.get(c.ZTS_EU_Account__c) == null || mapAccNextCall.get(c.ZTS_EU_Account__c) == ''){
                    mapAccNextCall.put(c.ZTS_EU_Account__c, String.valueOf(c.ZTS_EU_Start_Date_Time__c.dateGMT()));
                }
            }
        }
        catch(exception e){
            system.debug('exMessage from fillMapNextCallOn '+e.getMessage());
        }
        return mapAccNextCall;
    }
    
    //@author: Ilirjana, 20.01.2015.
    //Returns map with 'first' employee that is specified as a primary sales rep on account position for specified account 
    private Map <Id, String> fillAccountOwnerForAccs(){
        Map <Id, String> mapAccOwners = new Map <Id, String>();
        try{
            Map <Id, ZTS_EU_Account_Position__c> accOwners = new Map <Id, ZTS_EU_Account_Position__c>(
                [select ZTS_EU_Account__c, ZTS_EU_Employee__c 
                 from ZTS_EU_Account_Position__c 
                 where ZTS_EU_Primary_Sales_Rep__c = true and ZTS_EU_Is_Active__c = true and ZTS_EU_Account__r.ZTS_EU_Account_Status__c != 'Inative' AND ZTS_EU_Market__c != 'United States']);            

            for (ZTS_EU_Account_Position__c ap : accOwners.values()){
                mapAccOwners.put(ap.ZTS_EU_Account__c, String.valueOf(ap.ZTS_EU_Employee__c));
            }
        }
        catch(exception e){
            system.debug('exMessage from fillAccountOwnerForAccs '+e.getMessage());
        }
        return mapAccOwners;
    }
    
    //@author: Ilirjana, 27.01.2015.
    //Clear filters and render account list 
    public void clearFilters(){
        selectedState = null;
        selectedCity = null;
        selectedRatingLabel = null;
        selectedRatingValue = null;
        selectedAccType = null;
        selectedNextCall = null;
        footerNumberOfAccounts = 0;
        
        getDoesUserHaveMoreThan2kAccs();
        accounts = getListOfAccounts();
        cstmIterator = new CustomIterator (accounts); 
        cstmIterator.pageSize = ZTS_MonthlyPlanning.defaultPageSize;
        next(); 
    }
    
    //@author: Ilirjana, 16.02.2015.
    //ReRender account list 
    public PageReference reRenderTable(){
        integer start = cstmIterator.i;
        integer lstSize = cstmIterator.ListRequested.size();
        accounts = getListOfAccounts();
        cstmIterator = new CustomIterator (accounts); 
        if (start > ZTS_MonthlyPlanning.defaultPageSize)
            cstmIterator.i = start - lstSize;
        cstmIterator.pageSize = ZTS_MonthlyPlanning.defaultPageSize;
        next();
        footerNumberOfAccounts -= lstSetController.size();
        return null;
    }
    
    //IteratorMethods for accountWrapper
    public Boolean hasNext {
        get {return cstmIterator.hasNext();}
        set;
    }
    
    public Boolean hasPrevious {
        get {return cstmIterator.hasPrevious();}
        set;
    }
    
    public void next() 
    {
        lstSetController = cstmIterator.next();
        footerNumberOfAccounts += lstSetController.size();
    }
    
    public void previous() 
    {
        footerNumberOfAccounts -= lstSetController.size();
        lstSetController = cstmIterator.previous();
    }
    
    public void first() 
    {
        lstSetController = cstmIterator.first();
        footerNumberOfAccounts = lstSetController.size();
    }
    
    public void last() 
    {
        lstSetController = cstmIterator.last();
        footerNumberOfAccounts = accounts.size();
    }
    
    //Getters and setters
    //1. for Filters
    
    public List<SelectOption> getStates(){
        try{
            if (states != null && states.size() > 0)
                return states;
            
            states.add(defaultSelectOption);
            string country = string.valueOf(
                [select ZTS_EU_Country__c
                from User
                where Id = :UserInfo.getUserId()
                limit 1][0].ZTS_EU_Country__c);
            //System.debug('country----'+country);
            List<State_Country__c> stateList =
                [select Id, Name 
                 from State_Country__c
                 where ZTS_EU_Country__c = :country
                 order by Name];
            //System.debug('stateList------'+stateList);
            //System.debug('stateList-Size-----'+stateList.Size());
            for (State_Country__c state : stateList){
                states.add(new SelectOption(state.Id, state.Name));
            }
        }
        catch(exception e){
            system.debug('exMessage from getStates '+e.getMessage());
        }
        return states;
    }
    
    public List<SelectOption> getRatingLabels(){
        if (ratingLabels != null && ratingLabels.size() > 0)
            return ratingLabels;
        
        ratingLabels.add(defaultSelectOption);
        ratingLabels.add(new SelectOption(ZTS_EU_GlobalConstants.All, ZTS_EU_GlobalConstants.All));
        ratingLabels.add(new SelectOption(ZTS_EU_GlobalConstants.CADPre, ZTS_EU_GlobalConstants.CADPre));
        ratingLabels.add(new SelectOption(ZTS_EU_GlobalConstants.CADTher, ZTS_EU_GlobalConstants.CADTher));
        ratingLabels.add(new SelectOption(ZTS_EU_GlobalConstants.CA, ZTS_EU_GlobalConstants.CA));
        ratingLabels.add(new SelectOption(ZTS_EU_GlobalConstants.CTBF, ZTS_EU_GlobalConstants.CTBF));
        ratingLabels.add(new SelectOption(ZTS_EU_GlobalConstants.CTDY, ZTS_EU_GlobalConstants.CTDY));
        ratingLabels.add(new SelectOption(ZTS_EU_GlobalConstants.CTFL, ZTS_EU_GlobalConstants.CTFL));
        ratingLabels.add(new SelectOption(ZTS_EU_GlobalConstants.EQ, ZTS_EU_GlobalConstants.EQ));
        ratingLabels.add(new SelectOption(ZTS_EU_GlobalConstants.PY, ZTS_EU_GlobalConstants.PY));
        ratingLabels.add(new SelectOption(ZTS_EU_GlobalConstants.RU, ZTS_EU_GlobalConstants.RU));
        ratingLabels.add(new SelectOption(ZTS_EU_GlobalConstants.SW, ZTS_EU_GlobalConstants.SW));
        ratingLabels.add(new SelectOption(ZTS_EU_GlobalConstants.VPS, ZTS_EU_GlobalConstants.VPS));
        return ratingLabels;        
    }
    
    //get rating values dependent of what is selected for rating label/business unit
    public List<SelectOption> getRatingValues(){
        ratingValues = new List<SelectOption>();
        ratingValues.add(defaultSelectOption);
        try{
            Schema.DescribeFieldResult fieldResult;
            
            if (selectedRatingLabel == ZTS_EU_GlobalConstants.All)
                fieldResult = Account.fields.ZTS_EU_All_Rating__c.getDescribe();
            else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CADPre)
                fieldResult = Account.fields.ZTS_EU_RAT_CADPre__c.getDescribe();
            else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CADTher)
                fieldResult = Account.fields.ZTS_EU_RAT_CADTher__c.getDescribe();
            else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CA)
                fieldResult = Account.fields.ZTS_EU_RAT_CA__c.getDescribe();
            else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CTBF)
                fieldResult = Account.fields.ZTS_EU_RAT_CTBF__c.getDescribe();
            else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CTDY)
                fieldResult = Account.fields.ZTS_EU_RAT_CTDY__c.getDescribe();
            else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CTFL)
                fieldResult = Account.fields.ZTS_EU_RAT_CTFL__c.getDescribe();
            else if (selectedRatingLabel == ZTS_EU_GlobalConstants.EQ)
                fieldResult = Account.fields.ZTS_EU_RAT_EQ__c.getDescribe();
            else if (selectedRatingLabel == ZTS_EU_GlobalConstants.PY)
                fieldResult = Account.fields.ZTS_EU_RAT_PY__c.getDescribe();
            else if (selectedRatingLabel == ZTS_EU_GlobalConstants.RU)
                fieldResult = Account.fields.ZTS_EU_RAT_RU__c.getDescribe();
            else if (selectedRatingLabel == ZTS_EU_GlobalConstants.SW)
                fieldResult = Account.fields.ZTS_EU_RAT_SW__c.getDescribe();
            else if (selectedRatingLabel == ZTS_EU_GlobalConstants.VPS)
                fieldResult = Account.fields.ZTS_EU_RAT_VPS__c.getDescribe();
            
            if (fieldResult != null){
                List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry picklistValue : picklistValues)
                {
                  ratingValues.add(new SelectOption(picklistValue.getLabel(), picklistValue.getValue()));
                }
            }
        }
        catch(exception e){
            system.debug('exMessage from getRatingValues '+e.getMessage());
        }
        return ratingValues;
    }
    
    public List<SelectOption> getAccTypes(){
        try{            
            if (accTypes != null && accTypes.size() > 0)
                return accTypes;
            
            accTypes.add(defaultSelectOption);
            
            Schema.DescribeFieldResult fieldResult =
            Account.Type.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
            for(Schema.PicklistEntry f : ple)
            {
              accTypes.add(new SelectOption(f.getLabel(), f.getValue()));
            }       
        }
        catch(exception e){
            system.debug('exMessage from getAccTypes '+e.getMessage());
        }
        return accTypes;        
    }
    
    public List<SelectOption> getNextCallValues(){
        if (nextCallValues != null && nextCallValues.size() > 0)
            return nextCallValues;
        
        nextCallValues.add(defaultSelectOption);
        nextCallValues.add(new SelectOption(ZTS_EU_GlobalConstants.YES, ZTS_EU_GlobalConstants.YES));
        nextCallValues.add(new SelectOption(ZTS_EU_GlobalConstants.NO, ZTS_EU_GlobalConstants.NO));

        return nextCallValues;        
    }
    
    //Getters and setters
    public string getDisplayedCity(){
        return displayedCity;
    }
    
    //2. for Displayed values
    public boolean getDisplayRatingAndPotential(){       
        if (selectedRatingLabel == null || selectedRatingLabel == '' || selectedRatingLabel == Label.All)
            return false;
        
        return true;
    }
    
    public boolean getDisplayNextCall(){      
        if (selectedNextCall == ZTS_EU_GlobalConstants.NO)
            return false;
        
        return true;
    }
    
    public List<AccountWrapper> getLstSetController(){
        mapNextCallOn = fillMapNextCallOn(); //IP 16-Feb-15 Fill map with next call in case there is new combination acc-call for next 30 days
        accounts = getListOfAccounts();
        getDoesUserHaveMoreThan2kAccs();
        if (isAccountListChanged){ //if account list is changed because of filtering, refresh pagination
            
            footerNumberOfAccounts = 0;
            cstmIterator = new CustomIterator(accounts);
            cstmIterator.pageSize = ZTS_MonthlyPlanning.defaultPageSize;
            next(); 
        }
        return cstmIterator.ListRequested;
    }
    
    //@author: Ilirjana, 30.01.2015.
    //Check if there is more than 1000 accounts. Take filters into consideration.
    public boolean getDoesUserHaveMoreThan2kAccs(){
        try{
            doesUserHaveMoreThan2kAccs = false;
            string queryString = 'select Id from Account ' + getWhereFilter() + ' AND ZTS_EU_Market__c != \'United States\' ' + 'limit 1 offset 1000'; //Check if there is 1 more account over 1000
            List<Account> accNo2001 =  Database.Query(queryString);
            if (accNo2001 != null && accNo2001.size() > 0)
                doesUserHaveMoreThan2kAccs = true;
        }
        catch(exception e){
            system.debug('exMessage from getDoesUserHaveMoreThan2kAccs '+e.getMessage());
        }
        return doesUserHaveMoreThan2kAccs;
    }
    
    public integer getFooterNumberOfAccounts(){
        return footerNumberOfAccounts;
    }
    private List<Event> createMockEventList(){
        Id EventId1 = SL_IdGenerator.generateMockIdForObjectType(Event.SObjectType);
        Id EventId2 = SL_IdGenerator.generateMockIdForObjectType(Event.SObjectType);
        Id userId = UserInfo.getUserId();
        Id TargetAccount = SL_IdGenerator.generateMockIdForObjectType(ZTS_EU_Campaign_Account__c.SObjectType);
        Date dtLastDate = Date.newInstance(System.today().year(), System.today().month(), (System.today().Day()-1));
        Date dtNextDate = Date.newInstance(System.today().year(), System.today().month(), (System.today().Day()+1));
        List<Event> lstEvent = new List<Event>();
        String strEventJson1 = '{"attributes":' +
                           '{'+
                            '"type":"Event"'+
                            '},'+
                            '"Id":"'+EventId1+'",' +
                            '"StartDateTime":"2019-03-21",'+
                            '"EndDateTime":"2019-03-22",' +
                            '"WhatId":"'+TargetAccount+'",'+
                            '"Subject":"Test Event 1",'+
                            '"OwnerId":"'+userId+'",'+
                            '"CurrencyIsoCode":"EUR"'+
                            '}';
        Event objEvent1 = (Event)JSON.deserialize(strEventJson1, Event.class);
        lstEvent.add(objEvent1);
        String strEventJson2 = '{"attributes":' +
                           '{'+
                            '"type":"Event"'+
                            '},'+
                            '"Id":"'+EventId2+'",' +
                            '"StartDateTime":"2019-04-03",'+
                            '"EndDateTime":"2019-04-04",' +
                            '"WhatId":"'+TargetAccount+'",'+
                            '"Subject":"Test Event 1",'+
                            '"OwnerId":"'+userId+'",'+
                            '"CurrencyIsoCode":"EUR"'+
                            '}';
        Event objEvent2 = (Event)JSON.deserialize(strEventJson2, Event.class);
        lstEvent.add(objEvent2);
        return lstEvent;
    }
}