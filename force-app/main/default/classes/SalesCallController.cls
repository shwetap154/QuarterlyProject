/*************************************************************************************
* Name          :    SalesCallController.
* Description   :    Controller for a New Call page.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
12/17/2013       Sunil                      Created

01/05/2014      Akanksha                    Modified to incorporate latest call changes.
12/17/2014      Sohil Shah(Cloud Sense)     DEF-001577 for US Poultry Rep Users by default no value is selected in Subtype and force them 
                                            to select at least one
12/25/2014      Sohil Shah(Cloud Sense)     DEF-001585 Restrict User To delete DI and attendee on a Submitted Calls.            
01/16/2015      Sohil Shah(Cloud Sense)     DEF-001208 Fetch Call SubType Value based on Call Creator > USer Territory > Territory > Field  Force ID.     
02/05/2015       SOHIL SHAH(CloudSense)      Modified the query for DEF- DEF-001269 (Product Name Vs Description) 
06/29/2017      Vineet Singh(Cognizant)     For restricting User to change Activity date to Future's date Post Submission of Call                               
**************************************************************************************/
public with sharing class SalesCallController {
    /*****************************************
    VARIABLES
    ******************************************/
    public Call__c call{get;set;}
    public String  address{get; set;}
    public String selectedop{get;set;}
    public string retainSelectedDop = selectedop;
    public String title{get;set;}   
    public Id loggedInUserId {get;set;}
    public List<Attendee__c> attendeeList{get;set;} 
    public List<ZTS_EU_Colleague__c> colleagueList{get;set;}
    public List<attendeerWrapper> attendeeWraList{get;set;} 
    public List<attendeerWrapper> colleagueWraList{get;set;}
    public List<sampleDropWrapper> sDropWrapperList{get;set;}
    public List<AccountContactRole> accConRoleList;
    public String attendeeRemoveId{get;set;}
    public String colleagueRemoveId{get;set;}
    public String discRemoveId{get;set;}
    public String productRemoveId{get;set;}
    public String keyMsgRemoveId{get;set;}
    public String sDropRemoveId{get;set;}
    public List<Product_Metrics__c> productList{get;set;}
    public List<Key_Message_Discussions__c> keyMsgList = new List<Key_Message_Discussions__c>();
    public List<ZTS_US_Sample_Drop__c> sampleDropList{get;set;}
    public List<Key_Message_Discussions__c> kMsgList{get;set;}
    public Map<String,String> attendeeMap = new Map<String,String>();
    public List<Product_Metrics__c> productAddList; 
    public List<Attendee__c> attendeeAddList; 
    public List<ZTS_US_Sample_Drop__c> sDropAddList; 
    public List<Key_Message_Discussions__c> kMsgUpdateList; 
    public Map<Id, List<Key_Message_Discussions__c>> mapKeyMsg = new Map<Id, List<Key_Message_Discussions__c>>(); 
    public boolean shwSubmitError{get;set;}
    public boolean showdiscussion{get;set;}
    public boolean hidediscussion{get;set;}
    public boolean showview{get;set;}
    public boolean flag{get;set;}
    public boolean flag2{get;set;}
    public boolean attendeeRemoveFlag{get;set;}
    public boolean removediscussionItm{get;set;}
    public boolean myFlag;
    public boolean isSubmit{get;set;}
    public String attendeeid{get;set;}
    public String accid{get;set;}
    public map<Id,List<CampaignMemberStatus>> campaignIdCampMemStatusObjListMap = new map<Id,List<CampaignMemberStatus>>();
    public List<CampaignMemberStatus> CampMemStatList = new List<CampaignMemberStatus>();
    public Integer attendeecount;
    public String startDate = '';
    public String startTime = '';
    public String startDateTime = '';
    public final String COMPLETED_STATUS{get;set;}{COMPLETED_STATUS = 'Submitted';}
    public final String NEW_STATUS{get;set;}{NEW_STATUS = 'Planned';}
    public List<Call__c> lstCall = new List<Call__c>();
    public List<CampaignMember> campaignMemberList{get;set;}
    public List<CampaignMember> campaignMemberAddList ;
    public List<Task> followUpActivitiesList{get;set;}
    public String followUpActivityRemoveId{get;set;}
    public Task taskObj{get; set;}{taskObj = new Task();}
    public boolean addFollowUpSection{get;set;}{addFollowUpSection = false;}
    public List<ZTS_EU_Discussion__c> listdiscc{get;set;}
    public List<SelectOption> subtypelist{get;set;}
    public List<ZTS_EU_Account_Position__c> accposlist{get;set;}
    public String forceid{get;set;}
    public String name{get;set;}
    public Date mydate1;
    public String sdate1;
    public Date mydate2;
    public String sdate2;
 /***********
        * Method name  : accountChange
        * Description  : Check if the account on the call is changed
        * Return Type  : Void.
        * Parameters   : None
    ***********/ 
    public Void accountChange()
    {
        address = '';
        if(call.ID == NULL)
        {
            getPreviousCallObjectives();
        }
    }
   
     /***********
        * Method name  : SalesCallController
        * Description  : Get the details of call record.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
    public SalesCallController(ApexPages.StandardController controller) {
        listdiscc=new List<ZTS_EU_Discussion__c>();
        subtypelist = new List<SelectOption>();
        attendeeid='';
        showdiscussion=false;
        hidediscussion=false;
        showview=true;
        flag=false;
        flag2=false;
        attendeeRemoveFlag = false;
        removediscussionItm = false;
        myFlag = false;
        call = (Call__c)controller.getrecord();
        loggedInUserId = UserInfo.getUserId();
        shwSubmitError=false;
        populateSubType();
        System.debug('retURL------'+ApexPages.currentPage().getParameters().get('retURL'));
        if(ApexPages.currentPage().getParameters().get('retURL') !=null && ApexPages.currentPage().getParameters().get('id') !=null)
        {   
            this.selectedop = call.ZTS_EU_Sub_Type__c  ;
            System.debug('selectedop------'+selectedop);
        }
            
       if(ApexPages.currentPage().getParameters().containsKey('evt13')) {
           String startTimeTemp = ApexPages.currentPage().getParameters().get('evt13');
           startTime = EncodingUtil.urlDecode(startTimeTemp,'UTF-8');           
       }
       if(ApexPages.currentPage().getParameters().containsKey('evt4')) {
           String startDateTemp = ApexPages.currentPage().getParameters().get('evt4');
           startDate = EncodingUtil.urlDecode(startDateTemp,'UTF-8');         
       }
       if(startTime != null && startTime != '' && startDate != null && startDate != ''){
           startDateTime = startDate + ' ' + startTime;
           system.debug('startDateTime is: '+startDateTime);
           Datetime callStartDateTime = Datetime.parse(startDateTime);          
       
       call.ZTS_EU_Start_Date_Time__c = callStartDateTime;
       call.ZTS_EU_End_Date_Time__c = callStartDateTime.addHours(1);
       }
       
       if(call.Id != Null){
            showAttendee();
            showSampleDrop();
            showFollowUpActivities();
            if(system.today()<call.ZTS_EU_Start_Date_Time__c.Date())
                shwSubmitError=true;
            
            
       }

        
    }   
    
    public PageReference onLoad() {

        Id userId = UserInfo.getUserId();
        User u = [SELECT ZTS_EU_Market__c FROM User WHERE Id = :userId LIMIT 1];

        Id currentId = (Id)ApexPages.CurrentPage().getparameters().get('id');
        Call__c call = new Call__c(Id=currentId);
        PageReference pr = new ApexPages.StandardController(call).view();
        System.debug('$$$ UserInfo.UITheme(): '+UserInfo.getUITheme());
        System.debug('$$$ UserInfo.UIThemeDisplayed(): '+UserInfo.getUiThemeDisplayed());
        // Theme4d is lightning
        // Theme3 is classic

        if(u.ZTS_EU_Market__c == 'United States') {
            pr.getParameters().put('nooverride', '1');
            pr.getParameters().put('id',currentId);
            pr.setRedirect(true);
            return pr; 
        }
        System.debug('$$$ no US');
        return null;
    }

     /***********
        * Method name  : populateSubType
        * Description  : Method to show the list applicable Sub type values on Call.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
    public void populateSubType(){
        
        subtypelist = new List<SelectOption>();
        List<String> forceidfields= new List<String>();     
        name=Userinfo.getFirstName()+' '+Userinfo.getLastName();
        /* Added by sohil shah DEF-001208 Fetch Call SubType Value based on Call Creator > USer Territory > Territory > Field Force ID. 
        */
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        /* EOC by sohil shah DEF-001208 Fetch Call SubType Value based on Call Creator > USer Territory > Territory > Field Force ID. 
        */  
        accposlist =[SELECT Id,ZTS_EU_Employee__c,ZTS_Field_ForceID__c,ZTS_EU_Account__c from ZTS_EU_Account_Position__c where ZTS_EU_Account__c=:call.ZTS_EU_Account__c and ZTS_EU_Employee__c=:name AND ZTS_EU_Market__c = 'United States']; 
       if(accposlist!=null && accposlist.size()>0)
       {
            for (ZTS_EU_Account_Position__c acpo:accposlist){
                forceidfields.add(acpo.ZTS_Field_ForceID__c);
            }                   
             List<String> listFieldVal2 =new List<String>(); 
             List<String> listFieldVal1=new List<String>(); 
             List<ZTS_US_Call_CS__c> callcs = [Select Name,ZTS_US_Sub_Type_Value__c,ZTS_US_Sub_Type_Value_2__c from ZTS_US_Call_CS__c where Name=:forceidfields];
             
               if(callcs!=null && callcs.size()>0)
               {
                    listFieldVal1 = callcs[0].ZTS_US_Sub_Type_Value__c.split(';');
                    if(callcs[0].ZTS_US_Sub_Type_Value_2__c!= null){
                    listFieldVal2 = callcs[0].ZTS_US_Sub_Type_Value_2__c.split(';');
                    }
                    /* Added by Sohil Shah DEF-0001577 for US Poultry Rep Users by default no value is selected in Subtype and force them to
                        select at least one
                    */  
                                            
                    if(profileName == 'US Poultry Rep')
                    {   
                        subtypelist.add(new SelectOption('---NONE---','---NONE---'));
                    }
                    /* EOC by Sohil Shah DEF-0001577 for US Poultry Rep Users by default no value is selected in Subtype and force them to
                        select at least one
                    */
                    for(String field : listFieldVal1){      
                        subtypelist.add(new SelectOption(field,field));
                    }
                    
                    for(String field : listFieldVal2){  
                    if(listFieldVal2!=null && listFieldVal2.size()>0){
                        subtypelist.add(new SelectOption(field,field));
                        }
                    }
                   
                }
               else
                {
                    subtypelist.add(new SelectOption('Account Call','Account Call'));
                    subtypelist.add(new SelectOption('Sample Drop','Sample Drop'));
                }
        }
        else{
                  /*subtypelist.add(new SelectOption('Account Call','Account Call'));
                  subtypelist.add(new SelectOption('Sample Drop','Sample Drop'));*/
                /*  Added by sohil shah DEF-001208 Fetch Call SubType Value based on Call Creator > USer Territory > Territory > Field Force ID. 
        
                */                  
                List<ZTS_EU_Position__c> userTerritoryLst = new List<ZTS_EU_Position__c>();
                userTerritoryLst = [Select Id, Name,ZTS_EU_Position__c.ZTS_EU_Territory__r.ZTS_FieldForce_ID__c  from ZTS_EU_Position__c where ZTS_EU_Employee__r.name=:name];
               
                for(ZTS_EU_Position__c userTerr : userTerritoryLst)
                {
                    forceidfields.add(userTerr.ZTS_EU_Territory__r.ZTS_FieldForce_ID__c);
                }
                List<String> listFieldVal2 =new List<String>(); 
                 List<String> listFieldVal1=new List<String>(); 
                 List<ZTS_US_Call_CS__c> callcs = [Select Name,ZTS_US_Sub_Type_Value__c,ZTS_US_Sub_Type_Value_2__c from ZTS_US_Call_CS__c where Name=:forceidfields];
                 
                 if(callcs!=null && callcs.size()>0)
                   {
                        listFieldVal1 = callcs[0].ZTS_US_Sub_Type_Value__c.split(';');
                        if(callcs[0].ZTS_US_Sub_Type_Value_2__c!= null){
                        listFieldVal2 = callcs[0].ZTS_US_Sub_Type_Value_2__c.split(';');
                        }
                        //DEF-0001577 for US Poultry Rep Users
                        if(profileName == 'US Poultry Rep')
                        {   
                            subtypelist.add(new SelectOption('---NONE---','---NONE---'));
                        }
                        // EOC DEF-0001577 for US Poultry Rep Users*/
                        for(String field : listFieldVal1){      
                            subtypelist.add(new SelectOption(field,field));
                        }
                        
                        for(String field : listFieldVal2){  
                        if(listFieldVal2!=null && listFieldVal2.size()>0){
                            subtypelist.add(new SelectOption(field,field));
                            }
                        }
                        
                   }
                   else
                    {
                        //DEF-0001577 for US Poultry Rep Users
                        if(profileName == 'US Poultry Rep')
                        {   
                            subtypelist.add(new SelectOption('---NONE---','---NONE---'));
                            subtypelist.add(new SelectOption('Account Call','Account Call'));
                            subtypelist.add(new SelectOption('Sample Drop','Sample Drop'));
                        }
                        /* EOC by Sohil Shah DEF-0001577 for US Poultry Rep Users by default no value is selected in Subtype and force them to
                        select at least one
                        */  
                        else{
                            subtypelist.add(new SelectOption('Account Call','Account Call'));
                            subtypelist.add(new SelectOption('Sample Drop','Sample Drop'));
                        }
                        
                   }
               /* EOC by sohil shah DEF-001208 Fetch Call SubType Value based on Call Creator > USer Territory > Territory > Field Force ID. 
        
                */  
            }
           
    }
    
    
     /***********
        * Method name  : saveCall
        * Description  : Insert or Update a call and redirect to the associated account, if no errors.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    
    public PageReference saveCall() {
        boolean redirectflag=true;
        List<Account> listaccount= [Select Id,name,BillingCountry,BillingCity,BillingState,BillingStreet from Account where Id=:call.ZTS_EU_Account__c AND ZTS_EU_Market__c = 'United States'];
        
        Account acc=new Account();
        if(listaccount!=null && listaccount.size()>0){
            acc=listaccount[0];
        }
        PageReference pg=null;
        calculateEndDateTime(call);
        /*************************Update the Call*************************************************************/
        if(call.id != Null){
            Call__c updateCall = new Call__c(id=call.id);
            updateCall.ZTS_EU_Start_Date_Time__c = call.ZTS_EU_Start_Date_Time__c;
            updateCall.ZTS_EU_End_Date_Time__c = call.ZTS_EU_End_Date_Time__c;
            updateCall.ZTS_EU_Status__c = call.ZTS_EU_Status__c;
            updateCall.ZTS_EU_Call_Objectives__c = call.ZTS_EU_Call_Objectives__c;
            updateCall.ZTS_EU_Additional_Notes__c = call.ZTS_EU_Additional_Notes__c;
            updateCall.ZTS_EU_Next_Step__c = call.ZTS_EU_Next_Step__c;
            updateCall.ZTS_EU_Duration__c = call.ZTS_EU_Duration__c;
            updateCall.ZTS_EU_Next_Call_Date__c=call.ZTS_EU_Next_Call_Date__c;
            updateCall.ZTS_EU_Sub_Type__c = selectedop;
            //updateCall.ZTS_US_Call_Owner__c=loggedInUserId;
            
            //Added by Sohil DEF-0001577 For US Poultry Rep Users by default no value is selected in Subtype and force them to select at least one
            if(selectedop == '---NONE---')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Sub type Value'));
                return null;
            }
            // Added by Vineet Singh SC-002288 For restricting User to change Activity date to Future's date Porst Submission of Call
            DateTime dT = call.ZTS_EU_Start_Date_Time__c;
            myDate1 = date.newinstance(dT.year(), dT.month(), dT.day());
            sdate1 = String.valueOf(myDate1);

            if((call.ZTS_EU_Status__c=='Submitted') && (call.ZTS_EU_Submitted_Date__c != NULL))
            {
            DateTime dT1 = call.ZTS_EU_Submitted_Date__c;
            myDate2 = date.newinstance(dT1.year(), dT1.month(), dT1.day());
            sdate2 = String.valueOf(myDate2);
            
            if(sdate1>sdate2)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Activity Date cannot be greater than Submitted Date'));
                return null;
            }
            }



            // EOC by Sohil DEF-0001577 For US Poultry Rep Users by default no value is selected in Subtype and force them to select at least one
                        
            //integer numberofDays = System.now().daysBetween(call.ZTS_EU_Submitted_Date__c);
            try{
                if(call.ZTS_EU_Status__c!='Submitted'||(Call.ZTS_EU_Status__c == 'Submitted' && System.now().addDays(-10)<=call.ZTS_EU_Submitted_Date__c)){
                    update updateCall;
                }
                else{                   
                    redirectflag=false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot edit a submitted call after 10 days has elapsed.'));
                    return null;
                }
                if(acc.BillingCountry!=null && acc.BillingCity!=null && acc.BillingState!=null && acc.BillingStreet!=null){
                update updateCall;
                }
                else{
                    redirectflag=false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The account on which you are trying to create the call do not have Primary Address information : Country, State, City, Street populated.'));
                }
                
            }
            catch(DmlException e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
            if(redirectflag){   
            pg=new PageReference('/apex/ViewSalesCall');
            pg.getParameters().put('retURL',updateCall.ZTS_EU_Account__c);
            pg.getParameters().put('id',updateCall.Id);
            pg.setRedirect(true);
            return  pg;
            }
        }
        /*************************Insert a Call*************************************************************/
        else{        
            Call__c newCall = new Call__c();
            newCall.ZTS_EU_Account__c = call.ZTS_EU_Account__c;           
            if(title != Null)
            newCall.Name = title;
            newCall.ZTS_EU_Start_Date_Time__c = call.ZTS_EU_Start_Date_Time__c;
            newCall.ZTS_EU_Sub_Type__c = selectedop;
            newCall.ZTS_EU_End_Date_Time__c = call.ZTS_EU_End_Date_Time__c;
            newCall.ZTS_EU_Status__c = NEW_STATUS;
            newCall.ZTS_EU_Call_Objectives__c = call.ZTS_EU_Call_Objectives__c;
            newCall.ZTS_EU_Additional_Notes__c = call.ZTS_EU_Additional_Notes__c;
            newCall.ZTS_EU_Next_Step__c = call.ZTS_EU_Next_Step__c;
            newCall.ZTS_EU_Duration__c = call.ZTS_EU_Duration__c;
            newCall.ZTS_EU_Next_Call_Date__c=call.ZTS_EU_Next_Call_Date__c;
            newCall.ZTS_EU_Call_Owner__c =loggedInUserId;

            if(address!= Null && address!= 'None' && address != ''){
                newCall.ZTS_EU_Address__c = address;
            }
            //Added by Sohil DEF-0001577 For US Poultry Rep Users by default no value is selected in Subtype and force them to select at least one
            if(selectedop == '---NONE---')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Sub type Value'));
                return null;
            }
            // EOC by Sohil DEF-0001577 For US Poultry Rep Users by default no value is selected in Subtype and force them to select at least one
            
            
            try{
            if(acc.BillingCountry!=null && acc.BillingCity!=null && acc.BillingState!=null && acc.BillingStreet!=null){
                insert newCall;
                }
                else{
                redirectflag=false;
               
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The account on which you are trying to create the call do not have Primary Address information : Country, State, City, Street populated.'));
                }
            }
            catch(DmlException e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
            if(redirectflag){
            pg=new PageReference('/apex/ViewSalesCall');
            pg.getParameters().put('retURL',newCall.ZTS_EU_Account__c);
            pg.getParameters().put('id',newCall.Id);
            pg.setRedirect(true);
            return  pg;
            }
        }
        return null;
       
    }
     /***********
        * Method name  : cancelCall
        * Description  : redirect to related account detail page.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public PageReference cancelCall() {
        PageReference pg = new PageReference('/' + call.ZTS_EU_Account__c);
        return pg;       
    }
    /***********
        * Method name  : editCall
        * Description  : redirect to edit detail page if no errors.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public PageReference editCall() {      
      if(call.Id != Null && call.ZTS_EU_Account__c != Null){
          PageReference pg=new PageReference('/apex/SalesCall');
          pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
          pg.getParameters().put('id',call.Id);
          pg.setRedirect(true);
          return  pg;
      }    
      return  Null;      
    }
    /***********
        * Method name  : updateCallDetails
        * Description  : redirect to the related account.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public PageReference updateCallDetails(){ 
     
        PageReference pg = null;
        kMsgUpdateList = new List<Key_Message_Discussions__c>(); 
        productAddList = new List<Product_Metrics__c>();
        attendeeAddList = new List<Attendee__c>();
        campaignMemberAddList = new List<CampaignMember>(); 
        sDropAddList = new List<ZTS_US_Sample_Drop__c>();
        List<String> attendeeName = new List<String>(); 
            if(attendeeWraList != null &&  attendeeWraList.size()>0){
              for(attendeerWrapper aw : attendeeWraList){
                attendeeAddList.add(aw.attendeeObj);                                                
                for(CampaignMember cm : campaignMemberList){
                    if(cm.ContactId == aw.attendeeObj.ZTS_EU_Contact__c && cm.CampaignId == aw.attendeeObj.ZTS_EU_Related_Campaign__c){
                        cm.Status = aw.attendeeObj.ZTS_EU_Campaign_Response__c;
                        campaignMemberAddList.add(cm);
                    }
                }
              }           
            }
            /*
             Added by Sohil Shah(Cloud Sense) DEF-001585 Restrict User To delete DI and attendee on a Submitted Calls.    
            */
            if(call.ZTS_EU_Status__c == 'Submitted')
            {
                if(attendeeAddList != null &&  attendeeAddList.size()>0){
                    for(Attendee__c atten : attendeeAddList){
                        if(atten.Discussions__r==null || atten.Discussions__r.size()==0){
                            flag=true;
                            attendeeName.add(atten.Name+'\n');
                            
                        }   
                    }
                }
                else{
                    flag2=true;                 
                }
            }       
            if(sDropWrapperList.size()>0){
                for(sampleDropWrapper sDWrap : sDropWrapperList){               
                     sDropAddList.add(sDWrap.sDropObj);                
                }
            }
            
        if(!flag && !flag2){  
            try{
                    update productAddList;
                    update kMsgUpdateList;
                    update attendeeAddList;
                    update campaignMemberAddList;
                    update sDropAddList; 
                    pg = new PageReference('/' + call.ZTS_EU_Account__c);
                }
            catch(DmlException e){      
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));         
              
            } 
         }       
        else{
           
               if(flag2){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Each call needs to have at least one attendee. '));
               }
               if(flag){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Each attendee needs to have at least one discussion item for call.'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Attendee'+ attendeeName +' does not have any discussion Item'));
                }
        }   
        return  pg;  
          //EOC Sohil Shah(Cloud Sense)     DEF-001585 Restrict User To delete DI and attendee on a Submitted Calls.     
    }
    
     /***********
        * Method name  : saveAndSubmit
        * Description  : updates the status field on Call record to Completed.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public PageReference saveAndSubmit(){
    
       if(call.id != Null){
            List<Attendee__c> newattenlist=[select id,(Select Id from Discussions__r) from Attendee__c where ZTS_EU_call__c=:call.Id AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States'];          
            if(newattenlist != null && newattenlist.size()>0){
            for(Attendee__c atten:newattenlist){
                    if(atten.Discussions__r==null || atten.Discussions__r.size()==0){
                    flag=true;
                    break;
                    }
            }
            }
            else{
            flag2=true;
            
            }
        
        if(isSubmit!=null && !flag && !flag2 && isSubmit){ 
           updateCallDetails();
          lstCall = [Select name,c.ZTS_EU_Status__c,ZTS_EU_Address__c,ZTS_EU_Duration__c,ZTS_EU_Next_Step__c,ZTS_EU_Additional_Notes__c,ZTS_EU_SelectedAdress__c,c.ZTS_EU_Sub_Type__c,c.ZTS_EU_Next_Call_Date__c,c.Id, c.ZTS_EU_Account__c,c.ZTS_EU_Account__r.Name,c.ZTS_EU_Submitted_Date__c,ZTS_EU_Call_Owner__c From Call__c c where c.Id=:call.Id AND ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States'];
          try{
              if(lstCall != null && lstCall.size()>0){
                  if(lstCall[0].ZTS_EU_Next_Call_Date__c<>null&&lstCall[0].ZTS_EU_Status__c<>COMPLETED_STATUS){
                       Call__c oCall=lstCall[0].clone(false,true);
                       oCall.ZTS_EU_Next_Step__c=null;
                       oCall.ZTS_EU_Next_Call_Date__c=null;
                       oCall.ZTS_EU_Start_Date_Time__c=lstCall[0].ZTS_EU_Next_Call_Date__c;
                       oCall.ZTS_EU_Call_Objectives__c=lstCall[0].ZTS_EU_Next_Step__c;
                       oCall.ZTS_EU_Additional_Notes__c=null;
                       oCall.ZTS_EU_Status__c=NEW_STATUS; 
                       oCall.ZTS_EU_Duration__c=lstCall[0].ZTS_EU_Duration__c;
                       calculateEndDateTime(oCall);
                       insert oCall;
                   }
                   lstCall[0].ZTS_EU_Status__c = COMPLETED_STATUS;
                   lstCall[0].ZTS_EU_Submitted_Date__c = system.now();
               }
               update lstCall;
               PageReference pg=new PageReference('/' + call.ZTS_EU_Account__c);     
               return  pg; 
           }
           catch(DmlException e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
          }
       } 
       else{
      
       if(flag2){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Each call needs to have at least one attendee for it to be submitted '));
       }
       if(flag){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Each attendee needs to have at least one discussion item for call to be submitted '));
       }
       }
       }
       return null;
    }
    
     /***********
        * Method name  : createNextCall
        * Description  : Method to add next call based on Next Call date.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
    /*public void createNextCall(List<Call__c> lstCall){
    for(Call__c newcall:lstCall){
        if(newcall.id!=null){
            if(newcall.ZTS_EU_Next_Call_Date__c<>null&&newcall.ZTS_EU_Status__c==COMPLETED_STATUS){
                       Call__c oCall=newcall.clone(false,true);
                       oCall.ZTS_EU_Next_Step__c=null;
                       oCall.ZTS_EU_Next_Call_Date__c=null;
                       oCall.ZTS_EU_Start_Date_Time__c=newcall.ZTS_EU_Next_Call_Date__c;
                       oCall.ZTS_EU_Call_Objectives__c=newcall.ZTS_EU_Next_Step__c;
                       oCall.ZTS_EU_Additional_Notes__c=null;
                       oCall.ZTS_EU_Status__c=NEW_STATUS; 
                       oCall.ZTS_EU_Duration__c=newcall.ZTS_EU_Duration__c;
                       calculateEndDateTime(oCall);
                       insert oCall;
                    }
                }
            }
        }*/
    
    
     /***********
        * Method name  : showAttendee
        * Description  : Method to show the list of attendees when View Discussions is clicked.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
   
    public Void showAttendee(){
        if(call.Id != Null){
            set<Id> conIdSet = new set<Id>();
            set<Id> campIdSet = new set<Id>();
            map<Id,List<CampaignMember>> mapAttIdLstCampMem = new map<Id,List<CampaignMember>>();
            Map<Attendee__c,boolean> attendeeVsDiscussionSize = new Map<Attendee__c,boolean>();
            List<SelectOption> relCamOption = new List<SelectOption> ();
            set<Id> accIdSet = new set<Id>();
            map<Id,ZTS_EU_Affiliations__c> accContAffMap = new Map<ID,ZTS_EU_Affiliations__c>();
            attendeeWraList = new List<attendeerWrapper>();
            colleagueWraList = new List<attendeerWrapper>();
            attendeeList = [select id,name,ZTS_EU_call__c,ZTS_EU_Contact__r.Account.Name, ZTS_EU_Contact__r.AccountId,ZTS_EU_Contact__c,ZTS_US_Account_On_Attendee__c,ZTS_US_Account_On_Attendee_Id__c,ZTS_US_Contact_Profession__c,ZTS_EU_Related_Campaign__c,ZTS_EU_Campaign_Response__c,ZTS_EU_Employee__c,ZTS_EU_Represents_Account__c,(Select Id from Discussions__r) from Attendee__c where ZTS_EU_call__c=:call.Id AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States'];
            colleagueList =[select id,Name,ZTS_EU_Call__c,ZTS_EU_User__c,ZTS_US_User_PIT_BU__c,ZTS_EU_User_Email__c from ZTS_EU_Colleague__c where ZTS_EU_Call__c=:call.Id AND ZTS_EU_Market__c = 'United States'];
                               
            for(Attendee__c att : attendeeList){
                if(att.ZTS_EU_Contact__c != null){
                    conIdSet.add(att.ZTS_EU_Contact__c);
                }
                if(att.ZTS_US_Account_On_Attendee_Id__c !=null){
                    accIdSet.add(att.ZTS_US_Account_On_Attendee_Id__c);
                }
            }
             
            for(ZTS_EU_Affiliations__c acaff : [Select ZTS_US_Job_Function__c,ZTS_EU_Contact__c,ZTS_US_Email__c,ZTS_EU_Contact__r.ZTS_Invalid_Email__c,ZTS_EU_Contact__r.HasOptedOutOfEmail,ZTS_EU_Account__c from ZTS_EU_Affiliations__c where ZTS_EU_Contact__c in :conIdSet and ZTS_EU_Account__c in:accIdSet AND ZTS_EU_Market_from_Parent__c = 'United States' ORDER BY CreatedDate ASC]){
                if(!accContAffMap.containsKey(acaff.ZTS_EU_Contact__c)){
                    accContAffMap.put(acaff.ZTS_EU_Contact__c, acaff);
                }
            }
        
                campaignMemberList = [Select c.ContactId, c.Campaign.IsActive, c.Campaign.Name, c.Status, c.CampaignId From CampaignMember c 
                                        where c.ContactId in :conIdSet and c.Campaign.IsActive = true AND ZTS_EU_Market__c = 'United States'];
            
            //this is added for dynamic
            
            for(CampaignMember campaignMemberObj : campaignMemberList){
                campIdSet.add(campaignMemberObj.CampaignId);                                        
            }  
            CampMemStatList = [Select Label, IsDefault, Id, HasResponded, CampaignId From CampaignMemberStatus Where CampaignId IN: campIdSet];
            
            for(CampaignMemberStatus cmpgnMemStatusObj : CampMemStatList) {
                List<CampaignMemberStatus> campMemStatusList = campaignIdCampMemStatusObjListMap.get(cmpgnMemStatusObj.CampaignId);
                if(campMemStatusList == null) {
                    campMemStatusList = new List<CampaignMemberStatus>();
                }
                campMemStatusList.add(cmpgnMemStatusObj);
                campaignIdCampMemStatusObjListMap.put(cmpgnMemStatusObj.CampaignId,campMemStatusList);
            }
            for(Attendee__c att : attendeeList){
                mapAttIdLstCampMem.put(att.id,new List<CampaignMember>());
                if(att.ZTS_EU_Contact__c != null){
                    for(CampaignMember cm : campaignMemberList){
                        if(cm.ContactId != null && att.ZTS_EU_Contact__c == cm.ContactId){
                                mapAttIdLstCampMem.get(att.id).add(cm);
                        }
                    }
                }   
            }            
            for(Attendee__c att : attendeeList){   
                /*
                   Added by Sohil Shah(Cloud Sense) DEF-001585 Restrict User To delete DI and attendee on a Submitted Calls.
                */  
                myFlag = false;
                attendeerWrapper attWar = new attendeerWrapper();               
                attWar.attendeeObj = att;                               
                attWar.aConAff = accContAffMap.get(att.ZTS_EU_Contact__c);                
                if(call.ZTS_EU_Status__c == 'Submitted')
                {   
                    if(att.Discussions__r !=null && att.Discussions__r.size()==1){
                        myFlag = true;              
                    }
                }                
                attendeeVsDiscussionSize.put(att,myflag);
                attWar.removeDi = attendeeVsDiscussionSize.get(att);
                
                 /*
                    EOC Sohil Shah(Cloud Sense) DEF-001585 Restrict User To delete DI and attendee on a Submitted Calls.
                */  
                    if(att.ZTS_EU_Contact__r.AccountId != null){
                        attWar.accountRep.add(new selectOption(att.ZTS_EU_Contact__r.AccountId, att.ZTS_EU_Contact__r.Account.Name));
                    }
                    
                    if(att.ZTS_EU_Contact__c != null && mapAttIdLstCampMem.get(att.id) != null){
                        for(CampaignMember cm : mapAttIdLstCampMem.get(att.id)){
                            attWar.relCamOption.add(new selectOption(cm.CampaignId, cm.Campaign.Name));
                        }
                    }           
                attendeeWraList.add(attWar);
                
            }
            for (ZTS_EU_Colleague__c col: colleagueList){
            attendeerWrapper attWar = new attendeerWrapper(); 
            attWar.colleagueobj = col;
            colleagueWraList.add(attWar);
            }
        }
    }
     /***********
        * Method name  : showSampleDrop
        * Description  : Display the SampleDrop list based on the Call.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
  public void showSampleDrop(){
       sDropWrapperList = new List<sampleDropWrapper>();  
        //By sohil   Modified the query for DEF- DEF-001269 (Product Name Vs Description)    
       sampleDropList = [select id,Name,ZTS_US_Account__c,ZTS_US_Call__c,ZTS_EU_Quantity__c,ZTS_US_Sample__c,ZTS_US_Sample_Drop_Type__c,ZTS_US_Sample__r.Name,ZTS_US_Sample__r.ZTS_US_Product__r.Name,ZTS_US_Sample__r.ZTS_US_Product__r.ZTS_Description__c, ZTS_US_Sample__r.ZTS_US_On_Hand_Balance__c,ZTS_US_Signature_Captured__c from ZTS_US_Sample_Drop__c where ZTS_US_Call__c =:call.Id];
       for(ZTS_US_Sample_Drop__c sd : sampleDropList){
            sampleDropWrapper sDrop = new sampleDropWrapper();
            sDrop.sDropObj = sd;
            sDropWrapperList.add(sDrop);
        
       }
    }
    
    /***********
        * Method name  : removeSampleDrop
        * Description  : Remove the SampleDrop from the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
    public PageReference removeSampleDrop(){
        if(sDropRemoveId != null){
            ZTS_US_Sample_Drop__c sDObjDelete = new ZTS_US_Sample_Drop__c(id=sDropRemoveId);
            try{
                delete sDObjDelete;
            }catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
         PageReference pg=new PageReference('/apex/ViewSalesCall');
         pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
         pg.getParameters().put('id',call.Id);
         pg.setRedirect(true);
         return  pg;
    }
 
   
    /***********
        * Method name  : removeAttendee
        * Description  : Remove the attendee from the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
        * Modification : Added by Sohil Shah(CloudSense) logic to restrict deletion of attendee to fix DEF-001585
    ***********/
    public PageReference removeAttendee(){
       
        /*
            Sohil Shah(Cloud Sense) DEF-001585 Restrict User To delete DI and attendee on a Submitted Calls.
        */
         hidediscussion=false;
         showdiscussion = false;
        if(call.id !=null){           
            List<Attendee__c> newattenlist=[select id from Attendee__c where ZTS_EU_call__c=:call.id AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States'];
            
            if(call.ZTS_EU_Status__c == 'Submitted'){
                if(newattenlist != null && newattenlist.size()==1){ 
                      attendeeRemoveFlag=true;
                }
            }   
            if(attendeeRemoveId!=null && !attendeeRemoveFlag){
                 Attendee__c attDelete = new Attendee__c(id=attendeeRemoveId);
                try{
                    delete attDelete; //EOC Sohil Shah(Cloud Sense) DEF-001585 Restrict User To delete DI and attendee on a Submitted Calls.
                    
                }catch(Exception e){
                    system.debug('Exception'+e);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
                }
            }
            else{
                if(attendeeRemoveFlag){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You can not delete an Attendee as each call needs to have at least one attendee for it to be submitted '));
                    return null;
                 }
            }
            
        }
         PageReference pg=new PageReference('/apex/ViewSalesCall');
         pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
         pg.getParameters().put('id',call.Id);
         pg.setRedirect(true);
         return  pg;
        
    }
    
    /***********
        * Method name  : removeColleague
        * Description  : Remove the attendee from the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
    public PageReference removeColleague(){
        if(colleagueRemoveId!= null){
            
            ZTS_EU_Colleague__c colDelete = new ZTS_EU_Colleague__c(id=colleagueRemoveId);
            try{
                
                delete colDelete;
            }catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
         PageReference pg=new PageReference('/apex/ViewSalesCall');
         pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
         pg.getParameters().put('id',call.Id);
         pg.setRedirect(true);
         return  pg;
    
    }
    /***********

        * Method name  : removeDiscussionItem
        * Description  : Remove the DiscussionItem from the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
    public PageReference removeDiscussionItem(){
        showAttendee();
        removediscussionItm = (boolean.valueof(ApexPages.currentPage().getParameters().get('removediscussionItm')));
       
        if(discRemoveId!= null && !removediscussionItm){
            ZTS_EU_Discussion__c discDelete = new ZTS_EU_Discussion__c(id=discRemoveId);
                try{
                    delete discDelete;
                    
                }catch(Exception e){
                    system.debug('Exception'+e);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
                }
        }
        else{
            if(removediscussionItm){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot delete Discussion Item. Each Attendee needs at least one discussion Item '));
                return null;
            }               
        }   
         PageReference pg=new PageReference('/apex/ViewSalesCall');
         pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
         pg.getParameters().put('id',call.Id);
         pg.setRedirect(true);
         return  pg;
    
    }
    
    
    /***********
        * Method name  : removeProduct
        * Description  : Remove the product from the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
    public PageReference removeProduct(){
        
        if(productRemoveId!= null){
            Product_Metrics__c prodDelete = new Product_Metrics__c(id=productRemoveId);
            List<Key_Message_Discussions__c> kMsgUpdateList = [select id,ZTS_EU_Discussion__c from Key_Message_Discussions__c where ZTS_EU_Discussion__c=:productRemoveId];
            try{
                if(kMsgUpdateList.size()>0){
                    delete kMsgUpdateList;
                }
                
                delete prodDelete;
            }catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
         PageReference pg=new PageReference('/apex/ViewSalesCall');
         pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
         pg.getParameters().put('id',call.Id);
         pg.setRedirect(true);
         return  pg;
    
    }
  
    /***********
        * Method name  : deleteCall
        * Description  : Delete the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
    public PageReference deleteCall(){
        String callAccId = '';
        if(call.id != Null && call.ZTS_EU_Account__c != null){
            callAccId = call.ZTS_EU_Account__c;
            Call__c delCall = new Call__c(id= call.id);
            try{
                delete delCall;
            }catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }        
        PageReference pg = new PageReference('/' + call.ZTS_EU_Account__c);
        return pg;
       }
       return null;
    }   
   
     //Teresa
   /***********
        * Method name  : showFollowUpActivities
        * Description  : Display the Activities list based on the Call.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
    public void showFollowUpActivities(){
       followUpActivitiesList = [select id,Subject,Status,Priority,Owner.Name,ActivityDate from Task where WhatId =:call.Id];
       
    }
    
     /***********
        * Method name  : removeFollowUpActivities
        * Description  : Remove the FollowUpActivities from the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
    public PageReference removeFollowUpActivities(){
        if(followUpActivityRemoveId != null){
            Task followUpActObjDelete = new Task(id=followUpActivityRemoveId);
            try{
                delete followUpActObjDelete;
            }catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
        
         PageReference pg=new PageReference('/apex/ViewSalesCall');
         pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
         pg.getParameters().put('id',call.Id);
         pg.setRedirect(true);
         return  pg;
    }
    /***********
        * Method name  : sampleDropWrapper
        * Description  : Wrapper class for Sample Drop
        * Return Type  : None.
        * Parameters   : None.
    ***********/
    public class sampleDropWrapper{
        public ZTS_US_Sample_Drop__c sDropObj{get;set;}
        public sampleDropWrapper(){
            sDropObj = new ZTS_US_Sample_Drop__c();
        }
    }
     /***********
        * Method name  : calculateEndDateTime
        * Description  : Method to calculate End date Time as per entered activity date and Duration values
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
    public void calculateEndDateTime(Call__c newcall)
    {
            system.debug(LoggingLevel.ERROR,'@@ date '+ Date.today());
            //newcall.ZTS_EU_End_Date_Time__c = Datetime.now();
            system.debug(LoggingLevel.ERROR,'#### start date '+ newcall.ZTS_EU_Duration__c);
            String str = '';
            if(newcall.ZTS_EU_Duration__c != NULL )
            {
               str = newcall.ZTS_EU_Duration__c; 
            }
            else
            {
               //str = '0.5 Hours';
            }
            
            List <String> strList = str.split(' ');
            String str1 = strList[0];
            str1 = str1.trim();
            Double minutes = Double.valueOf(str1) * 60; 
            if(newcall.ZTS_EU_Start_Date_Time__c != NULL || newcall.ZTS_EU_Duration__c == '--None--' )
            {
                //Integer minutes = Integer.valueOf(newcall.ZTS_EU_Duration__c);
                newcall.ZTS_EU_End_Date_Time__c = newcall.ZTS_EU_Start_Date_Time__c.addMinutes(Integer.valueOf(minutes));
            }
    }
  /***********
        * Method name  : attendeerWrapper
        * Description  : Wrapper class for Attendees
        * Return Type  : None.
        * Parameters   : None.
    ***********/  

   public class attendeerWrapper{
        public Attendee__c attendeeObj{get;set;}
        public boolean removeDi{get;set;}
        public ZTS_EU_Affiliations__c aConAff{get;set;}
        public ZTS_EU_Colleague__c colleagueobj{get;set;}
        public List<SelectOption> accountRep{get;set;}
        public List<SelectOption> relCamOption{get;set;}
        public List<SelectOption> relCamRespOption {get{
            this.relCamRespOption = new List<SelectOption>();
            List<CampaignMemberStatus> lstStat = [Select Label, IsDefault, Id, HasResponded, CampaignId From CampaignMemberStatus Where CampaignId =: this.attendeeObj.ZTS_EU_Related_Campaign__c];
            this.relCamRespOption.add(new SelectOption('None', 'None'));
            for(CampaignMemberStatus cms : lstStat){
                this.relCamRespOption.add(new SelectOption(cms.label, cms.label));
            }
            
            return this.relCamRespOption; 
        } set;}
        public String selectedAttendee{get;set;} 
        public attendeerWrapper(){
            attendeeObj = new Attendee__c();
            aConAff = new ZTS_EU_Affiliations__c();
            colleagueobj = new ZTS_EU_Colleague__c();
            accountRep = new List<SelectOption>();
            relCamOption = new List<SelectOption>();
            relCamRespOption  = new List<SelectOption>();
        }
    }
    /***********
        * Method name  : getPreviousCallObjectives
        * Description  : Method to get previous call objectives
        * Return Type  : Void.
        * Parameters   : None.
    ***********/  
     public void getPreviousCallObjectives()
    {
        if(call.ZTS_EU_Account__c != null)
        {
           List<Call__c> prevCallList = [Select ID, ZTS_EU_Next_Step__c,ZTS_EU_Call_Owner__c FROM Call__c 
                                WHERE CreatedByID = :UserInfo.getUserId() 
                                    AND ZTS_EU_Account__c = :call.ZTS_EU_Account__c 
                                    AND ZTS_EU_End_Date_Time__c != NULL
                                    AND ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States'
                                    Order by ZTS_EU_End_Date_Time__c DESC LIMIT 1];
            
            if(prevCallList.size() > 0)
            {
                for(Call__c prevCall: prevCallList)
                {
                    call.ZTS_EU_Call_Objectives__c = prevCall.ZTS_EU_Next_Step__c;
                }    
            }
        }        
    }
    /***********
        * Method name  : saveTask
        * Description  : Method to save the task that has been added to the call
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/ 
    public pageReference  saveTask()
   {
        //String accountName = [select id,name from Account where id=:call.ZTS_EU_Account__c AND ZTS_EU_Market__c = 'United States'].name;
        //System.debug('*******AccountName is'+accountName);
        //List<Task> tasks = new List<Task>();
        Task taskObj1;
    if(taskObj.ownerId != null){
       taskObj =  new Task(OwnerId = taskObj.ownerId,
                                       whatId = call.Id, 
                                       Subject = taskObj.subject, 
                                       priority = taskObj.Priority, 
                                       Status = taskObj.Status,
                                       ActivityDate = taskObj.ActivityDate,
                                       CallRecordId__c = call.id
                                      );
                        
    
        
            
       try
       {
            //Database.DMLOptions notifyOptions = new Database.DMLOptions();
            //notifyOptions.EmailHeader.triggerUserEmail = true;
         
           Database.insert(taskObj);
       }
          /* String assignedto = [select id,name from User where id=:taskObj.ownerId AND ZTS_EU_Market__c = \'United States\'].name;
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); // new mail object
                                   
                                  //mail.setSenderDisplayName('Zoetis Admin');
                                  mail.setSaveAsActivity(false);
                                  mail.setWhatId(taskObj.AccountId);
                                  mail.setSubject('Action Required: Account Call Follow Up Has Been Assigned to You');
                                  mail.setTargetObjectId(taskObj.ownerId); //target to receipient
                                  //String Task = URL.getSalesforceBaseUrl().toExternalForm()+'/'+taskObj.id;
                                  String displayDate = taskObj.ActivityDate.format();
                                  mail.setHtmlBody('<b>'+assignedto+'</b>'+
                                                              '</br></br>'+Userinfo.getName()+' has created a follow up action for you after their interaction with '+ accountName+':</br></br>'+
                                                                     taskObj.subject+'</br></br>Priority:'+taskObj.Priority+'</br>Due Date:'+displayDate+'</br></br> Please click on the link below to see this follow up in TouchPoint and be sure to mark this as Complete once you have finished the task.</br></br>'+
                                                              '<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+taskObj.id+'">'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+taskObj.id+'</a>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       }*/
        catch(Exception e)
       {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insert Failes:Contact'));
       }
                                     
           
    } 
           //insert taskObj;
            //taskObj = new Task(Subject='--Enter Subject--',Status = 'Not Started', Priority = 'Normal');
            //tasks.add(taskObj);
            
       else{
        taskObj =  new Task(OwnerId = call.ZTS_EU_Call_Owner__c,
                                       whatId = call.Id, 
                                       Subject = taskObj.subject, 
                                       priority = taskObj.Priority, 
                                       Status = taskObj.Status,
                                       ActivityDate = taskObj.ActivityDate,
                                       CallRecordId__c = call.id
                                      );
          try{
            Database.insert(taskObj);
            }
       catch(Exception e)
       {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insert Failes:Contact'));
       }
        }
            showFollowUpActivities();
               addFollowUpSection = false;
           
        
       
       return null;
       }
    /***********
        * Method name  : addSectionToTask
        * Description  : This method is used to update whether the section for adding task needs to be displayed
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/ 
    
     public PageReference addSectionToTask(){
           if(addFollowUpSection)
                addFollowUpSection = false;
           else{
                taskObj = new Task(Subject='',Status = 'Not Started', Priority = 'Normal');
                addFollowUpSection = true;
           }
           return null;
      }
     /***********
        * Method name  : showDiscussionAF
        * Description  : Action Function called on page to show the list of discussions .
        * Return Type  : Void.
        * Parameters   : None.
    ***********/ 
   public void showDiscussionAF(){
        system.debug('--------AttendeeID-----'+attendeeid);
        listdiscc = [SELECT Id,Name,ZTS_EU_Call_Attendee__c,ZTS_EU_Campaign__c,ZTS_EU_Discussion_Items__c,ZTS_EU_Product__c from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__c =:attendeeid];
        showdiscussion=true;
        hidediscussion=true;
        //showview=false;
        }
    /***********
        * Method name  : hideDiscussionAF
        * Description  : Action Function called on page to hide the list of discussions .
        * Return Type  : Void.
        * Parameters   : None.
    ***********/ 
    public void hideDiscussionAF(){
     hidediscussion=false;
     showdiscussion=false;
     //showview=true;
    }
    }