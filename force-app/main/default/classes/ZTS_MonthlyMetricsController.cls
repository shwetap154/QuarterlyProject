/*******************************************************************************************************************************************
* File Name     :  ZTS_MonthlyMetricsController
* Description   :  This is the controller class for the vf page: ZTS_MonthlyMetrics

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     31st-Dec-14   Shreyas             Created the class.

********************************************************************************************************************************************/

public class ZTS_MonthlyMetricsController{

    public SelectOption defaultSelectOption = new SelectOption(Label.All, Label.All);
    public List<selectOption> monthList {get; set;}
    public String monthValue {get; set;} 
    public List<SelectOption> ratingLabels {get; set;}
    public string selectedRatingLabel {get; set;}
    public List<SelectOption> ratingValues = new List<SelectOption>();
    public string selectedRatingValue {get; set;}
    public List<monthlyMetricsWrapper> wrapperList {get; set;}
    public string userId;
    public string userMarket;
    public Map<String, String> businessHoursMap;
    public List<Holiday__c> holidaysList;
    public Map<String, Set<Date>> holidayMap;
    public Set<String> accountIdList;
    public string averageCustomerVisitsPerDay = '0.00';
    public string percentageTimeInTheField = '0.00';
    public string reachToAccountBySegment = '0.00';
    public string frequencyToAccountBySegment = '0.00';

    public ZTS_MonthlyMetricsController(){
        
        monthValue = String.valueOf( System.today().month() );
        
        userId = Userinfo.getUserId();
        userMarket = '';
        User u = new User();
        u = [Select Id, ZTS_EU_Market__c from User where Id =: userId AND ZTS_EU_Market__c != 'United States'];
        if(u != null){
            userMarket = u.ZTS_EU_Market__c;
        }
        
        selectedRatingLabel = Label.All;
        selectedRatingValue = Label.All;
        
        getHolidayAndWeekendDetails(); 
        populatePicklists();
        getMetricsDetails();
        
    
    }
    
    
    
    
    /*
        Name: getMetricsDetails
        Purpose: to fetch the call and account records to calculate the metrics for the selected month.  
        arguments: none
        return type: none
    */
    public void getMetricsDetails(){
    
        integer currentYear = System.Today().year();
        string currentYearString = String.valueOf( currentYear );
        integer currentDate = System.Today().day();
        integer currentMonth = integer.valueOf(monthValue);
        Date tempDate = date.newinstance(currentYear, currentMonth, 5);
        date monthStartDate = tempDate.toStartOfMonth();
        datetime monthStartDateTime = datetime.newInstance(monthStartDate.year(), monthStartDate.month(),monthStartDate.day());
        monthStartDateTime = monthStartDateTime.addHours(16);
        integer daysInMonth = date.daysInMonth(currentYear, currentMonth);
        integer numberOfWorkingDaysInMonth = 0;
        
        map<string, decimal> durationMap = new map<string, decimal>();
        durationMap.put('0.5 Hour', 30);
        durationMap.put('1 hour', 60);
        durationMap.put('1.5 hours', 90);
        durationMap.put('2 hours', 120);
        durationMap.put('2.5 hours', 150);
        durationMap.put('3 hours', 180);
        durationMap.put('3.5 hours', 210);
        durationMap.put('4 hours', 240);
        durationMap.put('4.5 hours', 270);
        durationMap.put('5 hours', 300);
        durationMap.put('5.5 hours', 330);
        durationMap.put('6 hours', 360);
        
        for(integer i=0; i<daysInMonth; i++){
            
            //code for checking whether the date is a weekday or not...
            boolean isWeekDay = false;
            if(businessHoursMap.get(userMarket) != null){
                if(BusinessHours.isWithin(businessHoursMap.get(userMarket), monthStartDateTime)){
                    isWeekDay = true;
                }                
            }
            
            //code for checking whether the date is a holiday or not...
            boolean isHoliday = false;
            if(holidayMap.get(userMarket) != null){
                if(holidayMap.get(userMarket).contains(monthStartDate)){
                    isHoliday = true;
                }
            }
            
            if(isWeekDay && !isHoliday){
                numberOfWorkingDaysInMonth = numberOfWorkingDaysInMonth + 1;
            }
            
            monthStartDateTime = monthStartDateTime.addDays(1);
            monthStartDate = monthStartDate.addDays(1); 
        }

        system.debug('numberOfWorkingDaysInMonth-----------: ' + numberOfWorkingDaysInMonth);
        
        decimal numberOfCallsOnWorkingDays = 0;
        decimal numberOfCallsOnNonWorkingDays = 0;
        
        
        // calculation of 'Average number of customer visits per day'
        List<Call__c> callListFetched = new List<Call__c>();
        callListFetched = [Select Id,ZTS_EU_Call_Owner__c, ZTS_EU_Start_Date_Time__c,ZTS_EU_Duration__c, ZTS_EU_Account__c from Call__c 
                           where ZTS_EU_Call_Owner__c =: userId AND ZTS_EU_Call_Month__c =: monthValue AND ZTS_EU_Call_Year__c =: currentYearString
                           AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        integer totalCalls = callListFetched.size();
        decimal totalCallMinutes = 0;
        accountIdList = new Set<String>();
        
        for(Call__c c: callListFetched){
            
            accountIdList.add(c.ZTS_EU_Account__c);
            if(durationMap.get(c.ZTS_EU_Duration__c) != null){
                totalCallMinutes = totalCallMinutes + durationMap.get(c.ZTS_EU_Duration__c);
            }    
            
            datetime callActivityDateTime = c.ZTS_EU_Start_Date_Time__c;
            date callActivityDate = c.ZTS_EU_Start_Date_Time__c.date();
            
            //code for checking whether the date is a weekday or not...
            boolean isWeekDay = false;
            if(businessHoursMap.get(userMarket) != null){
                if(BusinessHours.isWithin(businessHoursMap.get(userMarket), callActivityDateTime)){
                    isWeekDay = true;
                }                
            }
            
            
            
            //code for checking whether the date is a holiday or not...
            boolean isHoliday = false;
            if(holidayMap.get(userMarket) != null){
                if(holidayMap.get(userMarket).contains(callActivityDate)){
                    isHoliday = true;
                }
            }
            
            if(isWeekDay && !isHoliday){
                numberOfCallsOnWorkingDays = numberOfCallsOnWorkingDays + 1;
            }
            
            if(!isWeekDay || isHoliday){
                numberOfCallsOnNonWorkingDays = numberOfCallsOnNonWorkingDays + 1;
            }
        }
        
        system.debug('numberOfCallsOnWorkingDays-----------: ' + numberOfCallsOnWorkingDays);
        
        if(totalCalls > 0 && numberOfWorkingDaysInMonth != 0){
            averageCustomerVisitsPerDay = string.valueOf(numberOfCallsOnWorkingDays.Divide(numberOfWorkingDaysInMonth, 2));
            
        }
        else{
            averageCustomerVisitsPerDay = 'NA';
        }
        
        
        // calculation of '% time in the field'
        List<Time_Out_of_Territory__c> totListFetched = new List<Time_Out_of_Territory__c>();
        totListFetched = [Select Id, OwnerId, ZTS_EU_DurationInMinutes__c,Month_Of_Start_Date__c,Month_of_End_Date__c from Time_Out_of_Territory__c 
                          where OwnerId =: userId AND Month_Of_Start_Date__c =: monthValue AND Month_of_End_Date__c =: monthValue AND ZTS_Market__c != 'United States'];
        
        decimal totMinutesTotal = 0;
        for(Time_Out_of_Territory__c tot: totListFetched){
            totMinutesTotal = totMinutesTotal + integer.valueOf(tot.ZTS_EU_DurationInMinutes__c);
        }
        
        totMinutesTotal = totMinutesTotal.Divide(60, 2);
        totalCallMinutes = totalCallMinutes.Divide(60, 2);
        
        system.debug('totMinutesTotal in hours-----------: ' + totMinutesTotal);
        system.debug('totalCallMinutes in hours-----------: ' + totalCallMinutes);
        
        
        if(totMinutesTotal != 0.00){
            decimal percentage = totalCallMinutes.Divide(totMinutesTotal, 4);
            percentage = percentage*100;
            percentage = percentage.stripTrailingZeros();
            percentageTimeInTheField = string.valueOf(percentage);
            
        }
        else{
            percentageTimeInTheField = 'NA';
        }
        
        //calculation of 'Reach to account by segment' and 'Frequency to account by segment'
        getAccountBySegmentDetails();
        
        
        wrapperList = new List<monthlyMetricsWrapper>();
        wrapperList.add(new monthlyMetricsWrapper(averageCustomerVisitsPerDay, percentageTimeInTheField, reachToAccountBySegment, frequencyToAccountBySegment) );
        
    
    }
    
    /*
        Name: getAccountBySegmentDetails
        Purpose: to fetch the details of Account by Segment for calculation of 'Reach to account by segment' and 'Frequency to account by segment'
        arguments: none
        return type: none
    */
    public pageReference getAccountBySegmentDetails(){
    
        map<string, string> buMap = new map<string, string>();
        buMap.put(ZTS_EU_GlobalConstants.All,'ZTS_EU_All_Rating__c');
        buMap.put(ZTS_EU_GlobalConstants.CADPre,'ZTS_EU_RAT_CADPre__c');
        buMap.put(ZTS_EU_GlobalConstants.CADTher,'ZTS_EU_RAT_CADTher__c');
        buMap.put(ZTS_EU_GlobalConstants.CA,'ZTS_EU_RAT_CA__c');
        buMap.put(ZTS_EU_GlobalConstants.CTBF,'ZTS_EU_RAT_CTBF__c');
        buMap.put(ZTS_EU_GlobalConstants.CTDY,'ZTS_EU_RAT_CTDY__c');
        buMap.put(ZTS_EU_GlobalConstants.CTFL,'ZTS_EU_RAT_CTFL__c');
        buMap.put(ZTS_EU_GlobalConstants.EQ,'ZTS_EU_RAT_EQ__c');
        buMap.put(ZTS_EU_GlobalConstants.PY,'ZTS_EU_RAT_PY__c');
        buMap.put(ZTS_EU_GlobalConstants.RU,'ZTS_EU_RAT_RU__c');
        buMap.put(ZTS_EU_GlobalConstants.SW,'ZTS_EU_RAT_SW__c');
        buMap.put(ZTS_EU_GlobalConstants.VPS,'ZTS_EU_RAT_VPS__c');
        
        system.debug('selectedRatingValue : ' + selectedRatingValue );
        system.debug('selectedRatingLabel : ' + selectedRatingLabel );
        
        if(selectedRatingValue != Label.All || selectedRatingLabel != Label.All){
        
            string accountQuery = '';
            accountQuery = 'Select Id from Account where ZTS_EU_Market__c != \'United States\' AND Id IN: accountIdList ';
            if(buMap.ContainsKey(selectedRatingLabel)){
                accountQuery = accountQuery + ' AND ' + buMap.get(selectedRatingLabel) + ' =: selectedRatingValue';
            }
            
            //calculation of 'Reach to account by segment'          
            List<ZTS_EU_Account_Position__c> accountPositionListFetched = new List<ZTS_EU_Account_Position__c>();
            accountPositionListFetched = [Select Id, ZTS_EU_Account__c, ZTS_EU_Active__c, ZTS_EU_Employee_Id__c from ZTS_EU_Account_Position__c 
                                          where ZTS_EU_Employee_Id__c =: userId AND ZTS_EU_Active__c = True AND ZTS_EU_Market__c != 'United States'];
            
            List<String> accountIdListWithActiveAP = new List<String>();
            for(ZTS_EU_Account_Position__c ap: accountPositionListFetched){
                accountIdListWithActiveAP.add(ap.ZTS_EU_Account__c);
            }
            
            if(accountIdListWithActiveAP != null){
                accountQuery = accountQuery + ' AND Id IN: accountIdListWithActiveAP';
            }
            
            List<Account> accListFetched = new List<Account>();
            accListFetched = Database.query(accountQuery);
            
            decimal numberOfAccountsForCalls = 0;
            if(accListFetched != null){
                numberOfAccountsForCalls = accListFetched.size();
            }
            
            decimal numberOfActiveAccountPositions = 0;
            if(accountPositionListFetched != null){
                numberOfActiveAccountPositions = accountPositionListFetched.size();
            }
            
            system.debug('numberOfAccountsForCalls-----------: ' + numberOfAccountsForCalls);
            system.debug('numberOfActiveAccountPositions-----------: ' + numberOfActiveAccountPositions);
            
            if(numberOfActiveAccountPositions > 0){
                reachToAccountBySegment = string.valueOf(numberOfAccountsForCalls.Divide(numberOfActiveAccountPositions, 2));
            }
            else{
                reachToAccountBySegment = 'NA';
            }
        
            
            // calculation of 'Frequency to account by segment'
            
            string queryForCall = 'Select Id, ZTS_EU_Account__c, ZTS_EU_Account__r.';
            queryForCall = queryForCall + buMap.get(selectedRatingLabel) + ' from Call__c where '; 
            queryForCall = queryForCall + 'ZTS_EU_Call_Owner__c =: userId AND ZTS_EU_Account__r.ZTS_EU_Market__c != \'United States\' AND ZTS_EU_Call_Month__c =: monthValue AND ZTS_EU_Account__r.';
            queryForCall = queryForCall + buMap.get(selectedRatingLabel) + ' =: selectedRatingValue';
            
            List<Call__c> callListFetchedForBuAndRating = new List<Call__c>();
            callListFetchedForBuAndRating = Database.query(queryForCall);
             
            Set<String> uniqueAccountIdList = new Set<String>();
            for(Call__c c: callListFetchedForBuAndRating){
                uniqueAccountIdList.add(c.ZTS_EU_Account__c);
            }
            
            decimal numberOfCallsMade = 0;
            if(callListFetchedForBuAndRating != null){
                numberOfCallsMade = callListFetchedForBuAndRating.size();
            }
            
            decimal numberOfUniqueAccountsForCalls = 0;
            if(uniqueAccountIdList != null){
                numberOfUniqueAccountsForCalls = uniqueAccountIdList.size();
            }
            
            system.debug('numberOfCallsMade-----------: ' + numberOfCallsMade);
            system.debug('numberOfUniqueAccountsForCalls-----------: ' + numberOfUniqueAccountsForCalls);
            
            if(numberOfUniqueAccountsForCalls > 0){
                frequencyToAccountBySegment = string.valueOf(numberOfCallsMade.Divide(numberOfUniqueAccountsForCalls, 2));
            }
            else{
                frequencyToAccountBySegment = 'NA';
            } 
            wrapperList = new List<monthlyMetricsWrapper>();
            wrapperList.add(new monthlyMetricsWrapper(averageCustomerVisitsPerDay, percentageTimeInTheField, reachToAccountBySegment, frequencyToAccountBySegment) );
            
        }                              
                                      
        return null;                              
    
    }
    
    /*
        Name: getHolidayAndWeekendDetails
        Purpose: to fetch the Business Hour and Holiday records to calculate the number of non working days  
        arguments: none
        return type: none
    */
    public void getHolidayAndWeekendDetails(){
    
        // consider the business hours as per the market and timezone to calculate the number of weekends.
        
        businessHoursMap = new Map<String, String>();
        List<BusinessHours> businessHoursList = new List<BusinessHours>();
        businessHoursList = [SELECT Id, Name FROM BusinessHours WHERE Name =: userMarket];
        for(BusinessHours bh: businessHoursList){
            businessHoursMap.put(bh.Name, bh.Id);
        }
        
        holidaysList = new List<Holiday__c>();
        holidaysList = [Select Id, Name, ZTS_EU_Holiday_Date__c, ZTS_EU_Market__c, ZTS_EU_Default_Holiday__c, 
                        ZTS_EU_Country__c, ZTS_EU_State_County__c from Holiday__c where 
                        ZTS_EU_Market__c =: userMarket AND ZTS_EU_Is_Active__c = True];
                        
        holidayMap = new Map<String, Set<Date>>();
        for(Holiday__c h: holidaysList){
        
            if(h.ZTS_EU_Default_Holiday__c){
                string defaultHolidayKey = h.ZTS_EU_Market__c;
                if(holidayMap.containsKey(defaultHolidayKey)){
                    holidayMap.get(defaultHolidayKey).add(h.ZTS_EU_Holiday_Date__c);
                }
                else{
                    holidayMap.put(defaultHolidayKey, new Set<Date>{h.ZTS_EU_Holiday_Date__c});
                }
            }
        } 
    }
    
    
    /*
        Name: populatePicklists
        Purpose: to populate the Month, BU and Rating picklists  
        arguments: none
        return type: none
    */
    public void populatePicklists(){
    
        monthList = new List<selectOption>();
        monthList.add(defaultSelectOption);
        monthList.add(new SelectOption('1',Label.ZTS_EU_JAN));
        monthList.add(new SelectOption('2',Label.ZTS_EU_FEB));
        monthList.add(new SelectOption('3',Label.ZTS_EU_MAR));
        monthList.add(new SelectOption('4',Label.ZTS_EU_APR));
        monthList.add(new SelectOption('5',Label.ZTS_EU_MAY));
        monthList.add(new SelectOption('6',Label.ZTS_EU_JUN));
        monthList.add(new SelectOption('7',Label.ZTS_EU_JUL));
        monthList.add(new SelectOption('8',Label.ZTS_EU_AUG));
        monthList.add(new SelectOption('9',Label.ZTS_EU_SEP));
        monthList.add(new SelectOption('10',Label.ZTS_EU_OCT));
        monthList.add(new SelectOption('11',Label.ZTS_EU_NOV));
        monthList.add(new SelectOption('12',Label.ZTS_EU_DEC));
        
        
        ratingLabels = new List<selectOption>();
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
                  ratingValues.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
                }
            }
        }
        catch(exception e){
            system.debug('exMessage from getRatingValues '+e.getMessage());
        }
        return ratingValues;
    }
    
    
    
    // inner class
    public class monthlyMetricsWrapper{
    
        public string averageCustomerVisitsPerDay {get; set;}
        public string percentageTimeInTheField {get; set;}
        public string reachToAccountBySegment {get; set;}
        public string frequencyToAccountBySegment {get; set;}
        
        public monthlyMetricsWrapper(string averageVisits, string percentageTime, string reachToAccount, string frequencyToAccount) {
              averageCustomerVisitsPerDay = averageVisits;
              percentageTimeInTheField = percentageTime;
              reachToAccountBySegment = reachToAccount;
              frequencyToAccountBySegment = frequencyToAccount;
        }
    
    }









}