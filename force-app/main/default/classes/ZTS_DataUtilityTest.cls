/**
 * @description       : Test data utility class
 * @author            : Deloitte consulting
 * @group             : 
 * @last modified on  : 03-09-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-02-2016   Akanksha                    Created the Class.
 * 1.1   07-14-2016   Raghu                       Added/Modified methods 
 * 1.2   07-11-2016   Shiva                       Added createSOCallRecord method
 * 1.3   03-16-2022   Ethan Hirsch                Added createContractDocIdSearchString and createAttachment methods
 * 1.4   03-23-2022   Ethan Hirsch                Added createCases method
 * 1.5   06-07-2022   Ethan Hirsch @ Zoetis Inc   Change Profile names in createPrimaryContactInactiveProfileCustomSetting to 
 *                                                replace & with and as part of changes to Profile names to avoid Copado issues.
 * 1.6   06-20-2022   Ethan Hirsch @ Zoetis Inc   Add createPvwProducts, createCaseProducts, createEventNarratives,
 *                                                createVeddraCodings, and createVeddraEvent methods
 * 1.7   07-19-2022   Ethan Hirsch @ Zoetis Inc   Add createAssessments and createPVWBatchNumber method
 * 1.8   03-29-2023   Padma Nerella @ Zoetis Inc  Added createEUSpeciesProductRec, createEUSpeciesRec and createEUAccountSpeciesPotentialRec
 **/
@isTest
public class ZTS_DataUtilityTest{
   
   
   public static ZTS_EU_Sales_Presets__c createSalesPreset(string salesPresetName, string selectedPrefTime){
        ZTS_EU_Sales_Presets__c salesPresets = new ZTS_EU_Sales_Presets__c ();
        salesPresets.Name = salesPresetName;
        salesPresets.ZTS_EU_Selected_GLR_Type__c = 'Bill-To';
        salesPresets.ZTS_EU_Selected_Preferred_Brands__c = 'Brand1;Brand2';
        salesPresets.ZTS_EU_Selected_Preferred_Species__c = 'Species1;Species2';
        salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c = 'Thera1;Thera2';
        salesPresets.ZTS_EU_Selected_Preferred_Time__c = selectedPrefTime;
        salesPresets.ZTS_EU_User__c = UserInfo.getUserId();
        insert salesPresets;
        return salesPresets;
    }
   
   
   
    /****************************Insert Account(s)**************************************************************************/
    public static List<Account> fv
        (Integer numAcct,Integer uniquenarid) {
        List<Account> accList = new List<Account>();
                
        for(Integer i=0;i<numAcct;i++) {
            Account acc = new Account();         
            acc.name = 'Test Account'+i;
            acc.ZTS_EU_Country__c = 'United States';
            acc.BillingCity = 'Test City'+i;
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';
            //acc.ZTS_EU_State_County__c  = 'Ohio';
            acc.BillingStreet = 'Test Street'+i; 
            acc.BillingPostalCode = '12344';
            acc.BillingState = 'Test State'+i; 
            //acc.ZTS_EU_Zoetis_SFDC_ID__c='NC'+(100*uniquenarid)+i;
            acc.ZTS_EU_Market__c = '';
            accList.add(acc);
        }    
        return accList;  
    }
    
     public static List<Account> createAccountRecord(Integer numAcct) {
        List<Account> accList = new List<Account>();
                
        for(Integer i=0;i<numAcct;i++) {
            Account acc = new Account();         
            acc.name = 'Test Account'+i;
            acc.ZTS_Business_Class__c = 'Breeder';
            acc.ZTS_EU_Country__c = 'x';
            acc.ZTS_EU_Zip_Postal_Code__c = '10003';
            acc.BillingPostalCode = '12345';
            acc.BillingCity = 'Boca Raton';
            acc.BillingState = 'Florida';
            acc.BillingStreet = 'Elm Lane';
            acc.ZTS_EU_Market__c='United States';
            acc.Practice_Management_Software__c = 'Other';
            acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            accList.add(acc);
        }    
        return accList;  
    }
    
    public static List<Account> createAccountRecord(Integer numAcct,Integer uniquenarid) {
        List<Account> accList = new List<Account>();
                
        for(Integer i=0;i<numAcct;i++) {
            Account acc = new Account();         
            acc.name = 'Test Account'+i;
            acc.ZTS_US_Business_Class__c = 'Sub-Class 1';
            acc.ZTS_EU_Country__c = 'United States';
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';
            acc.BillingCity = 'Test City'+i;
            acc.ZTS_US_State_Province__c  = 'Ohio';
            acc.BillingStreet = 'Test Street'+i;  
            acc.BillingPostalCode = '45220';
            acc.BillingState = 'OH';
            acc.ZTS_EU_Market__c = 'United States';
            acc.ZTS_US_NARC_ID__c='NC'+(100*uniquenarid)+i;
            accList.add(acc);
        }    
        return accList;  
    }
    /****************************Insert Contact(s)**************************************************************************/
    public static List<Contact> createContactRecord(Integer numCont) {
    
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<numCont;i++) {
            Contact con = new Contact(); 
            con.firstname='Test First'+i;
            con.lastname = 'Test Contact'+i; 
            con.ZTS_EU_Profession__c='Executive Leadership';
            con.ZTS_US_Profession__c='Executive Leadership';
            con.ZTS_Job_Function__c='CEO/President';
            con.ZTS_US_Job_Function__c='CEO/President';
            con.ZTS_EU_Market__c = 'United Kingdom';
            conList.add(con);
        }        
        return conList;  
           
    }
    
/****************************Insert Contract(s)**************************************************************************/
    public static List<Contract> createContractRecord(Integer numContr) {
        List<Account> accountRecord = createAccountRecord(1,3);
        insert accountRecord;
            List<Contract> contrList = new List<Contract>();
            for(Integer i=0;i<numContr;i++) {
                Contract contr = new Contract(); 
                contr.AccountId = accountRecord[0].id;
                contrList.add(contr);
            }        
            return contrList;  
           
    }
    
    /*****************************Inser Change Request*************************************************************************/
    public static List<ZTS_EU_Request__c> createChangeRequestRecord(Integer numCR) {
        List<Account> accountRecord = createAccountRecord(1,4);
        insert accountRecord;
        List<ZTS_EU_Request__c> cRequestList = new List<ZTS_EU_Request__c>();
        for(Integer i=0;i<numCR;i++) {
            ZTS_EU_Request__c reqObj = new ZTS_EU_Request__c(); 
            //reqObj.ZTS_Requested_Change__c = 'Test Request'; Field not pushed      
            reqObj.ZTS_EU_Object_Type__c = 'Account';
            reqObj.ZTS_EU_Status__c = 'New';
            reqObj.ZTS_EU_Account_To_Be_Changed__c = accountRecord[0].id;
            List<User> ownerList = createcoacherUser();
            //reqObj.OwnerId =  ownerList[0].id;           
            cRequestList.add(reqObj);
        }        
        return cRequestList;   
        
    }
    
    /*****************************Inser Education Background*********************************************************************************/
    public static List<ZTS_US_Education_Background__c> createEduBackgroundRecord(Integer numEB) {
        List<ZTS_US_Education_Background__c>  eduBackground = new List<ZTS_US_Education_Background__c>();
        List<Contact> conList = createContactRecord(1);
        insert conList;
        for(Integer i=0;i<numEB;i++){
            ZTS_US_Education_Background__c eb = new ZTS_US_Education_Background__c();
            eb.ZTS_US_Contact__c = conList[0].id;
            eb.ZTS_US_Type__c = 'DVM';
            eb.ZTS_US_Institution__c = 'Auburn University';
            eduBackground.add(eb);          
        }
        return eduBackground;
    }
    
   /****************************Insert AccountContactAffiliation(s)**************************************************************************/
    public static List<ZTS_EU_Affiliations__c> createAccConAffiliationRecord(Integer numConAffli) {
    
        List<ZTS_EU_Affiliations__c> accConAffList = new List<ZTS_EU_Affiliations__c>();
        for(Integer i=0;i<numConAffli;i++) {
            ZTS_EU_Affiliations__c accConAff = new ZTS_EU_Affiliations__c();
               
            accConAffList.add(accConAff);
        }        
        return accConAffList;             
    }
    
     /****************************Insert AccountAffiliation(s)**************************************************************************/
    public static List<ZTS_EU_Account_Affiliations__c> createAccAffiliationRecord(Integer numConAffli) {
    
        List<ZTS_EU_Account_Affiliations__c> accAffList = new List<ZTS_EU_Account_Affiliations__c>();
        for(Integer i=0;i<numConAffli;i++) {
            ZTS_EU_Account_Affiliations__c accAff = new ZTS_EU_Account_Affiliations__c();
            accAff.ZTS_EU_Account_Influence__c = 'High';
            accAff.ZTS_EU_Affiliation_Status__c = 'Active';
               
            accAffList.add(accAff);
        }        
        return accAffList;             
    }
      /****************************Insert Contact Affiliation(s)**************************************************************************/
  /**  public static List<ZTS_Contact_Affiliations__c> createConAffiliationRecord(Integer numConAffli) {
    
        List<ZTS_Contact_Affiliations__c> conAffList = new List<ZTS_Contact_Affiliations__c>();
        for(Integer i=0;i<numConAffli;i++) {
            ZTS_Contact_Affiliations__c conAff = new ZTS_Contact_Affiliations__c();
            conAff.ZTS_Affiliation_Status__c = 'Active';               
            conAffList.add(conAff);
        }        
        return conAffList;             
    }
    **/
    
   
 /**********************************Insert User *************************************************/
 public static List<User> createcoacherUser() { 
 Profile profiles=[Select Id From Profile Where Name='System Administrator'];
        List<User> usersList = new List<User>();
    User newuser=new User();
    newuser.profileid=profiles.Id;
    newuser.email='deneme@deneme.com';
    newuser.username='deneme1@deneme1.com';
    newuser.lastname='deneme';
    newuser.alias='deneme1';
    newuser.languagelocalekey='en_US';
    newuser.localesidkey='en_US';
    newuser.timezonesidkey='America/Los_Angeles';
    newuser.localesidkey='en_US';
    newuser.ZTS_EU_isCoacher__c=TRUE;  
    newuser.EmailEncodingKey='ISO-8859-1';
    usersList.add(newuser);  
        return usersList;
}
public static List<User> createcoacheeUser() { 
 Profile profiles=[Select Id From Profile Where Name='US Super User'];
        List<User> usersList = new List<User>();
 User newuser=new User();
    newuser.profileid=profiles.Id;
    newuser.email='testem@deneme.com';
    newuser.username='testem@deneme1.com';
    newuser.lastname='testem';
    newuser.alias='testem';
    newuser.languagelocalekey='en_US';
    newuser.localesidkey='en_US';
    newuser.timezonesidkey='America/Los_Angeles';
    newuser.localesidkey='en_US';  
    newuser.EmailEncodingKey='ISO-8859-1';
    usersList.add(newuser);  
        return usersList;
}

/*-------------insert Attendee__c objects---------------*/
    public static List<Attendee__c> createAttendee(Integer counter){ 
        List<Attendee__c> listAttendee = new List<Attendee__c>();
        List<Contact> contactList = createContactRecord(counter);
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        System.runAs(usr){
            insert contactList; 
        }
        List<Account> accountRecord = createAccountRecord(1,4);
        insert accountRecord;
         Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = accountRecord[0].Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2015, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2015, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';      
            insert call;
            
        for(Integer i=0; i< counter; i++){
            Attendee__c attendee = new Attendee__c();
            attendee.ZTS_EU_Contact__c = contactList[i].Id;
            attendee.ZTS_EU_call__c = call.Id;
            listAttendee.add(attendee);
        }
        return listAttendee;
    }
    
    /*-------------insert Colleague objects---------------*/
    public static List<ZTS_EU_Colleague__c> createColleague(Integer counter){ // 6/14
        List<ZTS_EU_Colleague__c> listColleague = new List<ZTS_EU_Colleague__c>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standtus', Email='standarduser1212@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1212@testorg.com.uat');
        u.ZTS_EU_Market__c = 'United States';
        insert u; 
        List<Account> accountRecord = createAccountRecord(1,5);
        insert accountRecord;
         Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = accountRecord[0].Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';      
            insert call;
            
        for(Integer i=0; i< counter; i++){
            ZTS_EU_Colleague__c colleague = new ZTS_EU_Colleague__c();
            colleague.ZTS_EU_User__c = u.Id;
            colleague.ZTS_EU_Call__c = call.Id;
            listColleague.add(colleague);
        }
        return listColleague;
    }
    
    /****************************Insert Call**************************************************************************/
    public static List<Call__c> createCallRecord(Integer counter) {
       List<Account> accountRecord = createAccountRecord(1,6);
        insert accountRecord;
        List<Call__c> callList = new List<Call__c>();
        for(Integer i=0;i<counter;i++) {
            Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = accountRecord[0].Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';   
            call.ZTS_EU_Duration__c='0.5 Hours';
            callList.add(call);
        }        
        return callList;  
           
    }
     /****************************Insert US Call**************************************************************************/

     public static List<Account> createUsAccountRecord(Integer numAcct,Integer uniquenarid) {
        List<Account> accList = new List<Account>();
                
        for(Integer i=0;i<numAcct;i++) {
            Account acc = new Account();         
            acc.name = 'US Test Account'+i;
            acc.ZTS_EU_Country__c = 'United States';
            acc.BillingCity = 'US Test City'+i;
            acc.BillingStreet = 'US Test Street'+i;  
            acc.ZTS_EU_Market__c = 'United States';
            accList.add(acc);
        }    
        return accList;  
    }
     public static List<Call__c> createUsCallRecord(Integer counter) {
        List<Account> accountRecord = createUsAccountRecord(1,6);
         insert accountRecord;
         List<Call__c> callList = new List<Call__c>();
         for(Integer i=0;i<counter;i++) {
             Call__c call = new Call__c();         
             call.ZTS_EU_Account__c = accountRecord[0].Id;
             call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2);        
             call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2).addHours(1);
             call.ZTS_EU_Sub_Type__c = 'US Account Call';   
             call.ZTS_EU_Duration__c='0.5 Hours';
             callList.add(call);
         }        
         return callList;  
            
     }
    
     /****************************Insert Call**************************************************************************/
    public static List<Call__c> createCallRecords(Integer counter,List<Account> acclist) {
       List<Account> accountRecord = createAccountRecord(1,6);
        insert accountRecord;
        List<Call__c> callList = new List<Call__c>();
        for(Account acc:acclist){
        for(Integer i=0;i<counter;i++) {
            Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = acc.Id;
            call.ZTS_EU_Start_Date_Time__c = Datetime.now().addHours(-24);        
            call.ZTS_EU_End_Date_Time__c = Datetime.now();
            call.ZTS_EU_Sub_Type__c = 'Account Call';   
            call.ZTS_EU_Duration__c='0.5 Hours';
            callList.add(call);
         }  
        }      
        return callList;  
           
    }
    
    
    /****************************Insert Discussion items*************************************************************************/
    public static List<ZTS_EU_Discussion_Item__c> createDiscussionItemsRecord(Integer counter) {
        
        List<ZTS_EU_Discussion_Item__c> discussionItemList = new List<ZTS_EU_Discussion_Item__c>();
        
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Discussion_Item__c discItem = new ZTS_EU_Discussion_Item__c();
            discItem.ZTS_EU_Start_Date__c=date.newInstance(2000, 9, 1);     
            discItem.ZTS_EU_Description__c = 'Description Text'+i;
            discItem.ZTS_EU_Discussion_Item_Title__c = 'Description Text title';
            discussionItemList.add(discItem);
        }        
        return discussionItemList;  
        
    }
    
    /****************************Insert Campaign**************************************************************************/
   public static List<Campaign> createCampaignRecord(Integer counter) {
        List<Campaign> campaignList = new List<Campaign>();
        for(Integer i=0;i<counter;i++) {
            Campaign campaign = new Campaign();         
            campaign.Name = 'TestCampaign'+i;
            campaign.ZTS_EU_Field_Targeting__c = 'Open';
            campaign.IsActive = true;
            campaign.Is_Active_Campaign__c =true;
            campaign.StartDate = System.today();
            campaign.ZTS_EU_Market__c = '';
            campaign.Campaign_Name_English__c = 'Is test';
            campaignList.add(campaign);
        }        
        return campaignList;  
           
    }
    
    /****************************Insert Campaign Account**************************************************************************/
   public static List<ZTS_EU_Campaign_Account__c> createCampaignAccountRecord(Integer counter) {
        List<ZTS_EU_Campaign_Account__c> campaignAcntList = new List<ZTS_EU_Campaign_Account__c>();
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Campaign_Account__c campaignacnt = new ZTS_EU_Campaign_Account__c();         
            campaignacnt.ZTS_EU_Member_Status__c = 'Added';
            campaignAcntList.add(campaignacnt);
        }        
        return campaignAcntList;  
           
    }
    
    /*-------------insert ZTS_Events__c objects---------------*/
   public static List<ZTS_Events__c> createEvents(Integer counter){
        List<ZTS_Events__c> listEvents1 = new List<ZTS_Events__c>();
        for(Integer i=0; i< counter; i++){
            ZTS_Events__c event = new ZTS_Events__c();
            event.ZTS_US_Will_Firearms_be_Present__c = true;
            event.ZTS_US_Type__c = 'Cattle General';
            event.ZTS_US_Status__c = 'New';
            event.ZTS_US_Start_Date__c = system.today().addDays(1);
            event.ZTS_US_Is_Event_Private__c = false;
            event.ZTS_US_Name__c = 'Test Event'+i;
            event.ZTS_US_End_Date__c = system.today().addDays(i+1);
            event.ZTS_US_Compliance_Status__c = 'Acceptable';
            event.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
            event.ZTS_US_Number_of_Attendees__c = i+2;
           // event.ZTS_US_Purpose_Agenda__c = 'Test purpose';
            event.Purpose_Agenda__c = 'Test purpose';
            event.ZTS_EU_Market__c = 'United States';
            event.ZTS_US_Event_Category__c = 'Business Review Meet';
            listEvents1.add(event);
        }
        return listEvents1;
    }
    
        /***************************** Mock Response for callouts ********************************/
        public static MultiStaticResourceCalloutMock getJobUtilitiesMock(String jobId)
        {
            /* 
            * No webservice / GetContent() calls are allowed from test methods.  This jobId is the same value as
            * found in JobInfoResponseMock, under the tag <id>.
            * 
            * EX: <id>750c0000000FuiEAAS</id>
            */    
            MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
            multimock.setStaticResource(ZTS_GlobalConstants.SERVER_URL+'/services/async/30.0/job' , 'JobInfoResponseMock');
            multimock.setStaticResource(ZTS_GlobalConstants.SERVER_URL+'/services/async/30.0/job/' + jobId + '/batch', 'BatchInfoResponseMock');
            multimock.setStaticResource(ZTS_GlobalConstants.SERVER_URL+'/services/async/30.0/job/' + jobId + '/batch/751x00000000079AAA', 'BatchStatusResponseMock');
            multimock.setStaticResource(ZTS_GlobalConstants.SERVER_URL+'/services/async/30.0/job/' + jobId, 'CloseBatchResponseMock');
            
            multimock.setStatusCode(200);
            multimock.setHeader('Content-Type', 'application/xml');
            return multimock;
        }
    
     /***************************** Mock Response for callouts ********************************/
    public static MultiStaticResourceCalloutMock getJobUtilitiesMock()
    {
        /* 
         * No webservice / GetContent() calls are allowed from test methods.  This jobId is the same value as
         * found in JobInfoResponseMock, under the tag <id>.
         * 
         * EX: <id>750c0000000FuiEAAS</id>
         */
        String jobId = '750c0000000FuiEAAS';

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(ZTS_GlobalConstants.SERVER_URL+'/services/async/30.0/job' , 'JobInfoResponseMock');
        multimock.setStaticResource(ZTS_GlobalConstants.SERVER_URL+'/services/async/30.0/job/' + jobId + '/batch', 'BatchInfoResponseMock');
        multimock.setStaticResource(ZTS_GlobalConstants.SERVER_URL+'/services/async/30.0/job/' + jobId + '/batch/751x00000000079AAA', 'BatchStatusResponseMock');
        multimock.setStaticResource(ZTS_GlobalConstants.SERVER_URL+'/services/async/30.0/job/' + jobId, 'CloseBatchResponseMock');
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/xml');
        return multimock;
    }
    
    /*************************** create VMIPS Cases *******************************************/
   public static List<ZTS_US_VMIPS_Case__c> createVMIPSCases(Integer counter,List<Account> acclist,List<Contact> conlist){
        List<ZTS_US_VMIPS_Case__c> vcases = new List<ZTS_US_VMIPS_Case__c>();
        for(Account acc:acclist){
            for(Contact con:conlist){
                for(Integer i=0; i< counter; i++){
                    ZTS_US_VMIPS_Case__c vcase = new ZTS_US_VMIPS_Case__c();
                    vcase.ZTS_US_Vmips_Account__c = acclist[0].id;
                    //vcase.ZTS_Case_Role__c = 'TestRole';
                    vcase.ZTS_US_Case_Type__c = 'Animal Complaint';
                    vcase.ZTS_US_Sub_Type__c = 'On-Label';
                    vcase.ZTS_US_Comments__c = 'Test Comments';
                    vcase.ZTS_US_Priority__c = true;
                    vcase.ZTS_US_Description__c = 'Test Description';
                    //vcase.ZTS_Contact__c = con.id;
                    vcases.add(vcase);
                  }
         }
        }
        return vcases;
    }
   
    /*************************** create VMIPS Case Acounts *******************************************/
  public static List<ZTS_US_VMIPS_Case_Account__c> createVMIPSCaseAccount(Integer counter,List<Account> acclist,List<ZTS_US_VMIPS_Case__c> vmipscaselist){
        List<ZTS_US_VMIPS_Case_Account__c> vcases = new List<ZTS_US_VMIPS_Case_Account__c>();
        for(Account acc:acclist){
            for(ZTS_US_VMIPS_Case__c vmcase:vmipscaselist){
                for(Integer i=0; i< counter; i++){
                    ZTS_US_VMIPS_Case_Account__c vcase = new ZTS_US_VMIPS_Case_Account__c();
                    vcase.ZTS_US_Account__c = acc.id;
                    vcase.ZTS_US_Case_Role__c = 'TestRole';
                    vcase.ZTS_US_Clinic__c = 'Test Clinic';
                    vcase.ZTS_US_Contact__c = 'Test Contact';
                    vcase.ZTS_US_VMIPS_Case_Number__c=vmcase.Id;
                    vcases.add(vcase);
                  }
                }
        }
        return vcases;
    }
    

     /*************************** Active Trigger Settings *******************************************/
     public static void  activateTriggerSettings(){
        List<TriggerActivation__c> taList=new List<TriggerActivation__c>();
        List<String> names=new List<String>{'PopulateAccountTSFTrigger',
                                    'ZTS_Update_Expense_Record',
                                    'AddressCreateAccountTrigger',
                                    'AccountAddressUpdateAddressTrigger',
                                    'ZTS_Account_Affi_InsertDupliRec',
                                    'ZTS_RecordCreationOnAccount',
                                    'ZTS_Populate_ProdTerritoryTrigger',
                                    'ZTS_AccountUpdatefromEducation',
                                    'ZTS_UserTerritoryTrigger',
                                    'AccountTerrAssignTrigger',
                                    'ZTS_Account',
                                    'ZTS_Contact_Affi_InsertDupliRec',
                                    'ZTS_AllContractTrigger',
                                    'ZTS_KOL',
                                    'ZTS_Account_PositionTrigger',
                                    'ZTS_Contact_Trigger',
                                    'ZTS_EduCreationAndUpdatefromContact',
                                    'ZTS_GL_ChangeRequest',
                                    'AttendeeTrigger',
                                    'ZTS_Trigger_Create_Expense_Record',
                                    'EventTrigger',
                                    'CallTrigger',
                                    'ZTS_AddressUpdateOnAccount',
                                    'ZTS_TerritoryTrigger',
                                    'ZTS_PopulateCampaignMemberTrigger',
                                    'ZTS_PopulateAccTSF',
                                    'ZTS_GL_AllCustomEventsTrigger',
                                    'ZTS_GL_AllTOTTrigger',
                                    'ZTS_AccountContactAffiliation',
                                    'ZTS_CustomTerritoryTrigger',
                                    'ZTS_VMIPSCaseTrigger',
                                    'CampaignMemberTrigger',
                                    'ZTS_Colleague',
                                    'Vmips_Case_Trigger',
                                    'TaskTrigger',
                                    'PIT_Coaching_Guide',
                                    'SampleDropTrigger',
                                    'CampaignTrigger',
                                    'DiscussionCheck',
                                    'populateAccount',
                                    'ZTS_US_VMIPSCaseAccountTrigger',
                                    'ZTS_Opportunity',
                                    'ZTS_Contracted_Services'};
        for(String name:names)  {
            TriggerActivation__c ta=new TriggerActivation__c(name=name,isActive__c=true);
            taList.add(ta);
        }   
        
        upsert talist;                  
     }
     
    
   
     /*************************** Create Custom Territory  *******************************************/
     public static List<ZTS_EU_Territory__c>  createCustomTerritory(Integer size){
        List<ZTS_EU_Territory__c> terrList=new List<ZTS_EU_Territory__c>();
         for(Integer i=0; i< size; i++){
            ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c
                (Name='Terr'+i,ZTS_EU_Market__c = 'India', ZTS_Field_Force_Name__c='FieldForceName-'+i,ZTS_EU_Description__c='Terr Desc-'+i,ZTS_EU_Type__c='Territory');
            terrList.add(cterr);
         }
         return terrList;
     }
     
         /*************************** Create Custom Territory1  *******************************************/
     public static List<ZTS_EU_Territory__c>  createCustomTerritory1(Integer size){
        List<ZTS_EU_Territory__c> terrList=new List<ZTS_EU_Territory__c>();
         for(Integer i=0; i< size; i++){
            ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c
                (Name='Terr'+i,ZTS_EU_Market__c = 'India', ZTS_Field_Force_Name__c='FieldForceName-'+i,ZTS_EU_Description__c='Terr Desc-'+i,ZTS_EU_Type__c='Territory', ZTS_Species__c ='Small Animal');
            terrList.add(cterr);
         }
         return terrList;
     }

   
      /*************************** Create User Territory  *******************************************/
      public static List<ZTS_EU_Position__c>  createUserTerritory(List<ZTS_EU_Territory__c> custTerrList){
        List<ZTS_EU_Position__c> userterrList=new List<ZTS_EU_Position__c>();
         for(ZTS_EU_Territory__c cterr:custTerrList){
            ZTS_EU_Position__c usrTerr=new ZTS_EU_Position__c(ZTS_EU_Employee__c=UserInfo.getUserId(),ZTS_EU_Territory__c=cterr.id,ZTS_ChangeFlag__c=ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
            userterrList.add(usrTerr);
         }
         return userterrList;
     }
     
     /*************************** Create Account Territory  *******************************************/
       public static List<ZTS_AccountTerritory__c>  createAccountTerritory(List<Account> acclist,List<ZTS_EU_Territory__c> custTerrList){
            List<ZTS_AccountTerritory__c> accterrList=new List<ZTS_AccountTerritory__c>();
         for(Account acc:acclist){
            for(ZTS_EU_Territory__c cterr:custTerrList){
                //Art Smorodin: Slalom Adding ZTS_EU_Market__c
            ZTS_AccountTerritory__c accterr=new ZTS_AccountTerritory__c(ZTS_EU_Account__c=acc.id,
                                                                        ZTS_EU_Territory__c=cterr.id,
                                                                        ZTS_Zoetis_SFDC_ID__c=acc.ZTS_EU_Zoetis_SFDC_ID__c,
                                                                        ZTS_ChangeFlag__c=ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT,
                                                                        ZTS_NARC_ID__c='test',
                                                                        ZTS_EU_Market__c = 'United States');
            accterrList.add(accterr);
            }
         }
         return accterrList;
     }
     
     
     // DAVID STERN, 3/23: PRETTY SURE THIS CODE IS BROKEN.  FOR LIST OF 2 ACCOUNTS AND 2 USERTERRS, SHOULD PROBABLY MAKE TWO RECORD
     // BUT IT MAKES 4, WITH EVERY POSSIBLE COMIBNATION.
     /*************************** Create AccountTeam  *******************************************/ 
     public static List<ZTS_EU_Account_Position__c> createAccountTeam(List<Account> acclist,List<ZTS_EU_Position__c> userTerrList){
        List<ZTS_EU_Account_Position__c> accteamlist=new List<ZTS_EU_Account_Position__c>();
        for(Account acc:acclist)
        {
            system.debug('...test 1...' + acc.Id);
            for(ZTS_AccountTerritory__c accterr:acc.Accounts_Territory__r)
            {
                System.debug('....test 2...' + accterr.Id);
                ZTS_EU_Account_Position__c acctm=new ZTS_EU_Account_Position__c(ZTS_EU_Account__c=acc.id, ZTS_AccountTerritory__c=accterr.id);
                accteamlist.add(acctm);
            }
        
        }
        return accteamlist;
        
     }
    /*************************** Create Poultry Demographic *******************************************/ 
    /*** public static List<ZTS_Poultry_Demographics__c> createPoultryDemographicRecord(List<Account> acclist){
        List<ZTS_Poultry_Demographics__c> poudemolist=new List<ZTS_Poultry_Demographics__c>();
         for(Account acc:acclist){
        ZTS_Poultry_Demographics__c poudemo=new ZTS_Poultry_Demographics__c();
        poudemo.ZTS_No_of_Birds__c = 20;
        poudemo.ZTS_EU_Account__c = acc.id;
        poudemolist.add(poudemo);
         }
        return poudemolist;
     }
     ***/
     /*************************** Create Animal Count & FTEs *******************************************/ 
     
     
     public static List<ZTS_Animal_Count_Potential__c> createAnimalCount(List<Account> acclist){
        List<ZTS_Animal_Count_Potential__c> animalcountlist=new List<ZTS_Animal_Count_Potential__c>();
         for(Account acc:acclist){
        ZTS_Animal_Count_Potential__c animalcount=new ZTS_Animal_Count_Potential__c();
        animalcount.ZTS_No_of_Horses__c = 20;
        animalcount.ZTS_EU_Account__c = acc.id;
        animalcountlist.add(animalcount);
         }
        return animalcountlist;
     }
     
     /*************************** Create Address *******************************************/ 
     public static List<Address__c> createAddressrec(List<Account> acclist){
        List<Address__c> addresslist=new List<Address__c>();
         for(Account acc:acclist){
        Address__c addresrec=new Address__c();
        addresrec.ZTS_Address_Line_1__c = 'Test City';
        addresrec.ZTS_EU_City__c = 'Test City';
        addresrec.Zip_Postal_Code__c = 'LD1';                
        addresrec.ZTS_EU_Account__c = acc.id;
        addresslist.add(addresrec);
         }
        return addresslist;
     }
     
     /*************************** Create KOL *******************************************/ 
    /**** public static List<ZTS_GL_KOL__c> createKOLRecord(List<Contact> conlist){
        List<ZTS_GL_KOL__c> kollist=new List<ZTS_GL_KOL__c>();
         for(Contact con:conlist){
        ZTS_GL_KOL__c kol=new ZTS_GL_KOL__c();
        kol.ZTS_Contact__c = con.id;
        kol.ZTS_Role__c = 'Speaker';
        kol.ZTS_Species__c = 'Cattle - Beef';
        kol.ZTS_Geographical_influence__c = '';
        kol.ZTS_Start_Date__c = Date.newInstance(2014,03,07);
        kollist.add(kol);
         }
        return kollist;
     }
     
     ***/
     
    /*************************** Create Account PoultryDemographic RecordType *******************************************/ 
   /***  public static List<ZTS_Acc_PD_RecTypeMap__c> createAccPoultryDemoCustSetingdata(){
        Map<String, String> poultrydemomap = new Map<String, String>();
        poultrydemomap.put('Breeder', 'Primary Breeder');
        poultrydemomap.put('Broiler', 'Broiler');
        poultrydemomap.put('Layer', 'Eggs/Layers');
        poultrydemomap.put('Turkey','Turkey');
        List<ZTS_Acc_PD_RecTypeMap__c> AccPoultryDemolst = new List<ZTS_Acc_PD_RecTypeMap__c>();

        for(String accPDkey : poultrydemomap.keyset()){
        ZTS_Acc_PD_RecTypeMap__c AccPoultryDemo = new ZTS_Acc_PD_RecTypeMap__c();
        AccPoultryDemo.name = accPDkey;
        AccPoultryDemo.ZTS_PD_RecordType__c = poultrydemomap.get(accPDkey);
        AccPoultryDemolst.add(AccPoultryDemo);
        }
        return AccPoultryDemolst;
     }
     ***/
     public static void insertZoetisSettings(){
        ZTS_Settings__c zset=new ZTS_Settings__c();
        zset.ZTS_CRON_EXP_JOBS_CLOSE__c='0 15 * * * ?';
        zset.ZTS_AccountTeamsAutoFollowChatterFeed__c=true;
        zset.ZTS_Mass_Alignment_Email_Notification__c=true;
        zset.ZTS_VMIPS_Case_Task_Notification__c=true;
        zset.ZTS_CRON_EXP_EXCEPTION_FLAG__c='0 0 13 * * ?';
        zset.ZTS_CRON_EXP_REMOVE_USERS__c='0 5 * * * ?';
        zset.setUpOwnerId=UserInfo.getUserId();
        insert zset;
        
     }
     
     public static List<UserTerritory2Association> getStdUserTerrRecords(){
        //used only for test not org dependent 
        String[] usr_ids=new String[]{'0R0f0000000xUexEAE','0R0f0000000xUexEAE','0R0f0000000xUexEAE','0R0f0000000xUexEAE','0R0f0000000xUexEAE'};
        List<UserTerritory2Association> utlist=new List<UserTerritory2Association>();
        for(String uid:usr_ids){
            UserTerritory2Association ut=new UserTerritory2Association(id=uid,UserId=UserInfo.getUserId());
            utlist.add(ut);
        }
        return utlist;
     }

    public static List<Call__c> createSOCallRecord(Integer counter) {
       List<Account> accountRecord = createAccountRecord(1,6);
          insert accountRecord;
        Account acc = accountRecord[0];
        
        List<ZTS_EU_Territory__c> custTerrList = (ZTS_DataUtilityTest.createCustomTerritory(1)); 
         ZTS_EU_Territory__c cterr = custTerrList[0];
         cterr.Name = '8181-0';
        insert cterr;
         
         ZTS_EU_Position__c ust =new ZTS_EU_Position__c(ZTS_EU_Employee__c=UserInfo.getUserId(),ZTS_EU_Territory__c=cterr.id,ZTS_ChangeFlag__c=ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        insert ust ;
       // List<ZTS_EU_Position__c> usts = ZTS_DataUtilityTest.createUserTerritory(custTerrList); 
        //insert usts;
      //  ZTS_EU_Position__c ust = usts[0];
        List<ZTS_AccountTerritory__c> accTerritories = ZTS_DataUtilityTest.createAccountTerritory(accountRecord, custTerrList);         
        insert accTerritories;
         ZTS_AccountTerritory__c act = accTerritories[0];
          
        //ZTS_EU_Account_Position__c accTeam = ZTS_DataUtilityTest.createAccountTeam(accountRecord, usts)[0];
        ZTS_EU_Account_Position__c accTeam = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c=acc.id,ZTS_AccountTerritory__c=act.id,ZTS_EU_Position__r=ust);
        insert accTeam;
          
        //accTeam.ZTS_EU_Position__c = UserInfo.getUserId();
        //insert accTeam;
        List<Call__c> callList = new List<Call__c>();
        for(Integer i=0;i<counter;i++) {
            Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = accountRecord[0].Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2015, 1, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2017, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';   
            call.ZTS_EU_Duration__c='0.5 Hours';
            callList.add(call);
        }        
        return callList;  
           
    }

    public static void createPrimaryContactInactiveProfileCustomSetting() {
        Primary_Contact_Inactive_Profile_List__c contSetting = new Primary_Contact_Inactive_Profile_List__c();
        Primary_Contact_Inactive_Profile_List__c contSetting1 = new Primary_Contact_Inactive_Profile_List__c();
        Primary_Contact_Inactive_Profile_List__c contSetting2 = new Primary_Contact_Inactive_Profile_List__c();



        contSetting.Name = 'Profile Names';
        contSetting1.Name = 'Profile Names 1';
        contSetting2.Name = 'Profile Names 2';
        contSetting.Profile__c = '\'GER and CE Euro Business Administrator\';\'BNLX Business Administrator\';\'Spain and SE Business Administrator\';\'UK and Nordics Business Administrator\';\'System Administrator\'';
        contSetting1.Profile__c = '\'FRA Business Administrator\';\'UK and Nordics Business Administrator\';\'Spain and SE Business Administrator\',\'Integration Profile\',\'JPN and North Asia Business Administrator\',\'South East Asia Business Administrator\'';
        contSetting2.Profile__c = '\'South East Asia Business Administrator\', \'CHN Business Administrator\',\'Intll Business Administrator\', \'ZTS CLAR SoLA Business Administrator\'';

        insert new List<Primary_Contact_Inactive_Profile_List__c>{contSetting, contSetting1, contSetting2};
    }

    public static ZTS_US_Contract_Doc_Id_search_string__c createContractDocIdSearchString(string name, string contractAttachmentIdentifier, string contractFieldName) {
        return new ZTS_US_Contract_Doc_Id_search_string__c(
            Name=name,
            Contract_Attachment_Identifier__c=contractAttachmentIdentifier,
            Contract_Field_Name__c=contractFieldName);
    }

    public static Attachment createAttachment(string name, Id parentId) {
        return new Attachment(
            Name = name,
            Body = Blob.valueOf('Unit Test Attachment Body'),
            ParentId = parentId
        );
    }

    public static List<ZTS_US_Breed__c> createBreeds(integer numBreeds, string species) {
        List<ZTS_US_Breed__c> breeds = new List<ZTS_US_Breed__c>();

        for (integer i = 0; i < numBreeds; i++) {
            breeds.add(new ZTS_US_Breed__c(
                Name = string.format('Test Breed {0}', new List<Object>{i}),
                ZTS_US_Species__c = species
            ));
        }

        return breeds;
    }

    public static List<ZTS_US_Animal__c> createAnimals(integer numAnimals, Date dateOfBirth) {
        List<ZTS_US_Animal__c> animals = new List<ZTS_US_Animal__c>();

        for (integer i = 0; i < numAnimals; i++) {
            animals.add(new ZTS_US_Animal__c(
                Name = string.format('Test Pet {0}', new List<Object>{i}),
                ZTS_US_Date_of_Birth__c = dateOfBirth
            ));
        }

        return animals;
    }
     
    public static List<echosign_dev1__SIGN_Agreement__c> createAgreements(integer numAgreements) {
        List<echosign_dev1__SIGN_Agreement__c> agreemnts = new List<echosign_dev1__SIGN_Agreement__c>();

        for (integer i = 0; i < numAgreements; i++) {
            agreemnts.add(new echosign_dev1__SIGN_Agreement__c(
                Name = string.format('Test Agreement {0}', new List<Object>{i})
            ));
        }

        return agreemnts;
    }

    public static List<Case> createCases(integer numCases, Id recordTypeId) {
        List<Case> cases = new List<Case>();
        
        for (integer i = 0; i < numCases; i++) {
            cases.add(new Case(
                Subject = string.format('Test Case {0}', new List<Object> {i}),
                RecordTypeId = recordTypeId
            ));
        }

        return cases;
    }

    public static Entitlement createEntitlement(string name, Id accountId) {
        return new Entitlement(Name = name, AccountId = accountId);
    }

    public static List<ZTS_US_PVW_Product__c> createPvwProducts(integer numProducts) {
        List<ZTS_US_PVW_Product__c> pvwProducts = new List<ZTS_US_PVW_Product__c>();

        for (integer i = 0; i < numProducts; i++) {
            pvwProducts.add(new ZTS_US_PVW_Product__c(
                Name = String.format('Test PVW Product {0}', new List<Object> {i}),
                CurrencyIsoCode = 'USD',
                ZTS_US_MAH_Country__c = 'US',
                ZTS_US_Active_Product__c = 'Yes',
                ZTS_US_Brand__c = 'Test Brand'
            ));
        }

        return pvwProducts;
    }

    public static List<ZTS_US_Case_Product__c> createCaseProducts(integer numCaseProducts, Id recordTypeId, Id caseId, Id productId) {
        List<ZTS_US_Case_Product__c> caseProducts = new List<ZTS_US_Case_Product__c>();
        
        for (integer i = 0; i < numCaseProducts; i++) {
            caseProducts.add(new ZTS_US_Case_Product__c(
                RecordTypeId = recordTypeId,
                ZTS_US_Case__c = caseId,
                ZTS_US_Product_problem_type__c = 'Ecotoxicity',
                ZTS_US_PVW_Product__c = productId,
                ZTS_US_Product_Used_Correctly__c = 'Yes'
            ));
        }

        return caseProducts;
    }

    public static List<ZTS_US_Event_Narrative__c> createEventNarratives(integer numEventNarratives, Id caseId) {
        List<ZTS_US_Event_Narrative__c> eventNarratives = new List<ZTS_US_Event_Narrative__c>();
        
        for (integer i = 0; i < numEventNarratives; i++) {
            eventNarratives.add(new ZTS_US_Event_Narrative__c(
                ZTS_US_Case__c = caseId
            ));
        }

        return eventNarratives;
    }

    public static List<ZTS_US_VedDRA_Coding__c> createVeddraCodings(integer numVedraCodings) {
        List<ZTS_US_VedDRA_Coding__c> vedraCodings = new List<ZTS_US_VedDRA_Coding__c>();

        for (integer i = 0; i < numVedraCodings; i++) {
             String veddraVersion = 'VEddra v' + (i + 1); // Create a VEddra version
             Integer versionNumber = i + 1; // Create a version number
            vedraCodings.add(new ZTS_US_VedDRA_Coding__c(
                Name = String.format('Test Coding {0}', new List<Object> {i}),
                ZTS_US_VEDDRA_Class__c = 'C',
                ZTS_US_VEDDRA_Status__c = 'Official',
                ZTS_US_Veddra_Display__c = 'Y',
                VedDRA_Version__c = veddraVersion, // Set VEddra version
                Version__c = versionNumber // Set version number
                
            ));
            
        }

        return vedraCodings;
    }

    public static ZTS_US_VedDRA_Event__c createVeddraEvent(Id eventNarrativeId, Id vedraCodingId) {
        return new ZTS_US_VedDRA_Event__c(
            ZTS_US_Event_Narrative__c = eventNarrativeId,
            ZTS_US_VedDRA_Coding__c = vedraCodingId
        );
    }

    public static List<ZTS_US_Assessment__c> createAssessments(integer numAssessments, Id caseId, Id recordTypeId) {
        List<ZTS_US_Assessment__c> assessments = new List<ZTS_US_Assessment__c>();
        for (integer i = 0; i < numAssessments; i++) {
            assessments.add(new ZTS_US_Assessment__c(
                ZTS_US_Case__c = caseId,
                RecordTypeId = recordTypeId
            ));
        }

        return assessments;
    }

    public static ZTS_US_PVW_Batch_Number__c createPVWBatchNumber(Id pvwProductId, String batchNumber, String batchType, Decimal linkLotNumber) {
        return new ZTS_US_PVW_Batch_Number__c(
            ZTS_US_PVW_Product__c = pvwProductId,
            ZTS_US_Batch_Number__c = batchNumber,
            ZTS_US_Batch_Type__c = batchType,
            ZTS_US_Lot_Link_Number__c = linkLotNumber
        );
    }

    public static List<Batch_Detail__c> createBatchDetails(Integer numBatchDetails, Id caseProductId) {
        List<Batch_Detail__c> batchDetails = new List<Batch_Detail__c>();
        for (integer i = 0; i < numBatchDetails; i++) {
            batchDetails.add(new Batch_Detail__c(
                ZTS_US_Case_Product__c = caseProductId
            ));
        }

        return batchDetails;
    }
    
    
    public static List<ZTS_EU_Species_Product__c> createEUSpeciesProductRec(Integer count) {
       List<ZTS_EU_Species_Product__c> speciesProductList =  new List<ZTS_EU_Species_Product__c>();
        for (integer i = 0; i < count; i++) {
            speciesProductList.add(new ZTS_EU_Species_Product__c(
                Name='Product'+i,
                ZTS_EU_Type__c='Business Unit',
                ZTS_EU_Market__c='Spain',
                ZTS_EU_Business_Unit_Abbr__c='RU'
            ));
        }
        return speciesProductList;
    }
    
    public static List<ZTS_EU_Species__c> createEUSpeciesRec(Integer count, Id euSpeciesProductRecId) {
        List<ZTS_EU_Species__c> speciesList = new List<ZTS_EU_Species__c>();
        for (integer i = 0; i < count; i++) {
            speciesList.add(new ZTS_EU_Species__c(
                    Name='species'+i,
                    ZTS_EU_Business_Unit__c=euSpeciesProductRecId,
                    ZTS_EU_Species__c='species'+i,
                    ZTS_EU_Market__c='Spain'
                ));
        }
  
        return speciesList;
    }
    
    
    
     public static ZTS_EU_Account_Species_Potential__c createEUAccountSpeciesPotentialRec(Id euSpeciesRecId,Id accountId) {
         
        return new ZTS_EU_Account_Species_Potential__c(
                         ZTS_EU_Uniqueness_Key__c=accountId+'_'+euSpeciesRecId,
                         Account__c=accountId,
                         ZTS_EU_Species_Potential__c=euSpeciesRecId,
                         ZTS_EU_Animals_Consultations_actual__c=5.00
                     );
    }

    public static List<echosign_dev1__Agreement_Template__c> createEchoSignDev1AgreementTemplateRec(Integer count) {
        List<echosign_dev1__Agreement_Template__c> echoSignList =  new List<echosign_dev1__Agreement_Template__c>();
        for (integer i = 0; i < count; i++) {
            echoSignList.add(new echosign_dev1__Agreement_Template__c(
                Name = 'Improvac Certificate for LW',
                echosign_dev1__Name__c = 'Improvac Certificate for LW'
            ));
        }
        return echoSignList;
    }
}