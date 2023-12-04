/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 06-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   05-13-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   04-07-2022   Ethan Hirsch @ Zoetis Inc      change testmethod to isTest
 * 1.2   06-07-2022   Ethan Hirsch @ Zoetis Inc      Change Profile name of UK & Nordics Field Based Function to 
 *                                                   UK and Nordics Field Based Function to avoid Copado errors with 
 *                                                   Profile deployments.
**/
@isTest
public class INTLCallTriggerServiceTest{
    
    static final Integer NUM_ACCOUNTS = 1;
    static final Integer NUM_CONTACTS = 1;
    static final Integer NUM_CALLS = 1;
    static final Integer NUM_ATTENDEES = 1;
    static final Integer NUM_COLLEAGUES = 1;
    static final Integer NUM_DISC_ITEMS = 4;
    static final Integer NUM_PRODUCTS = 4;
    static final Integer NUM_CAMPAIGNS = 4;
    static final Integer NUM_TASKS = 4;
    static final Integer NUM_SAMPLES = 4;
    static final Integer NUM_SAMPLE_DROPS = NUM_SAMPLES;
    
    static final String MARKET = 'Russia';
    static final String DI_SEARCH = 'Testy';
    static final String SAMPLE_SEARCH = 'Testy Sample ';
    static final String PRODUCT_LEVEL = 'Brand';
    static final String INTL_USER_LN = 'INTLUser';
    static final String COLLEAGUE_USER_LN = 'Colleague';
    static final String US_PROFESSION = 'Academia';
     static final String INTL_MARKET = 'United Kingdom';
    static final Integer ON_HAND_BALACE = 30;
    
    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User newuser = new User();
        newuser.profileid=p.Id;
        newuser.email='deneme@deneme.com';
        newuser.username= 'z' + string.valueof(math.random())+'@ZEUAFMETEST.com';
        newuser.lastname='deneme';
        newuser.alias='sysAdm1';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newuser.ZTS_EU_isCoacher__c=TRUE;    
        newuser.ZTS_EU_Market__c='United Kingdom';
        newuser.EmailEncodingKey='ISO-8859-1';    
        insert newuser;
    }

    @isTest static void caluclateEndDateTime(){
        
        //Create an INTL User
        
        Profile p = [SELECT Id FROM Profile WHERE Name='UK and Nordics Field Based Function'];
        
        User newuser = new User();
        newuser.profileid=p.Id;
        newuser.email='deneme@deneme.com';
        newuser.username= 'z' + string.valueof(math.random())+'@ZEUAFMETEST.com';
        newuser.lastname='deneme';
        newuser.alias='deneme1';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newuser.ZTS_EU_isCoacher__c=TRUE;    
        newuser.ZTS_EU_Market__c='United Kingdom';
        newuser.EmailEncodingKey='ISO-8859-1';    
            
       
        insert newuser;

        System.runAs(newuser) {
        
               //Create an Account
                
                Account acc = new Account();         
                acc.name = 'Test Account';
                acc.ZTS_EU_Country__c = 'Nigeria';
                acc.BillingCity = 'Test City';
                acc.ZTS_EU_Zip_Postal_Code__c = '12345';
                //acc.ZTS_EU_State_County__c  = 'Ohio';
                acc.BillingStreet = 'Test Street'; 
                acc.BillingPostalCode = '12344';
                acc.BillingState = 'Test State'; 
                acc.ZTS_EU_Market__c = 'ALPHA';
                insert acc;
                                         
                //Create one Call
            
                Call__c call = new Call__c();
                call.ZTS_EU_Account__c = acc.Id;
                call.Name = 'Test Call';                
                DateTime startdatetime = DateTime.newInstance(2021, 03, 17, 12, 0, 0);
                DateTime enddatetime = DateTime.newInstance(2021, 03, 17, 12, 30, 0);
                call.ZTS_EU_Sub_Type__c = 'Account Call';
                call.ZTS_EU_Start_Date_Time__c = startdatetime;
                call.ZTS_EU_End_Date_Time__c = enddatetime;
                call.ZTS_EU_Status__c = 'Completed';
                call.ZTS_EU_Duration__c = '0.5 Hour';
                call.ZTS_EU_Call_Owner__c = UserInfo.getUserId();
                insert call;    

                Call__c call1 = new Call__c();
                call1.ZTS_EU_Account__c = acc.Id;
                call1.Name = 'Test Call';                
                DateTime startdatetime1 = DateTime.newInstance(2021, 03, 17, 12, 0, 0);
                DateTime enddatetime1 = DateTime.newInstance(2021, 03, 17, 12, 30, 0);
                call1.ZTS_EU_Sub_Type__c = 'Account Call';
                call1.ZTS_EU_Start_Date_Time__c = startdatetime1;
                call1.ZTS_EU_End_Date_Time__c = enddatetime1;
                call1.ZTS_EU_Status__c = 'Planned';
                call1.ZTS_EU_Duration__c = '0.5 Hour';
                call1.ZTS_EU_Call_Owner__c = UserInfo.getUserId();
                insert call1; 
            
                call1.ZTS_EU_Start_Date_Time__c = startdatetime1.addDays(1);
                call1.ZTS_EU_End_Date_Time__c = enddatetime1.addDays(1);
            
                update call1;
            
                INTLCallTriggerService.beforeInsert(new List<Call__c>{call1});  
                INTLCallTriggerService.beforeInsert(new List<Call__c>{call});  
                Map<Id, Call__c> mockOldMap = new Map<Id, Call__c>{call.Id => call};
                Map<Id, Call__c> mockOldMap1 = new Map<Id, Call__c>{call1.Id => call1}; 
    
                INTLCallTriggerService.beforeDelete(mockOldMap.values(), mockOldMap);   

                INTLCallTriggerService.afterDelete(mockOldMap.values(), mockOldMap); 
            
                
            
        }   
    }

    @isTest
    public static void attendeeDeleteOnChange_Test(){
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Call__c> callList = new List<Call__c>();
        List<Attendee__c> attendeeList = new List<Attendee__c>();
        User usr = [SELECT Id FROM User WHERE Alias = 'sysAdm1' LIMIT 1];
        Id accId1;
        Id accId2;
        State_Country__c sc = TestDataFactory.createStateCountry('United Kingdom', 'United Kingdom', true);
        accountList.add(TestDataFactory.createAccount_EU('Test Account 1', sc.Id, false));
        accountList.add(TestDataFactory.createAccount_EU('Test Account 2', sc.Id, false));
        insert accountList;

        for(Account a : accountList){
            if(accId1 == null){
                accId1 = a.Id;
            }else if(accId2 == null){
                accId2 = a.Id;
            }
            contactList.add(TestDataFactory.createContact(a.Id, false));
            callList.add(TestDataFactory.createCall(a.Id, false));
        }
        insert contactList;

        System.runAs(usr){
        insert callList;

        for(Call__c call : callList){
            for(Contact c : contactList){
                if(c.AccountId == call.ZTS_EU_Account__c){
                    Attendee__c attendee = new Attendee__c();
                    attendee.ZTS_EU_call__c = call.Id;
                    attendee.ZTS_EU_Contact__c = c.Id;
                    attendeeList.add(attendee);
                }
            }
        }
        insert attendeeList;

        Test.startTest();
        for(Call__c call : callList){
            if(call.ZTS_EU_Account__c == accId1){
                call.ZTS_EU_Account__c = accId2;
            }else if(call.ZTS_EU_Account__c == accId2){
                call.ZTS_EU_Account__c = accId1;
            }
        }
        update callList;
    }
        Test.stopTest();
        List<Attendee__c> attendees = [SELECT Id FROM Attendee__c];
        System.assertEquals(0, attendees.size());
    }
    
    public testmethod static void test_PIT_MassAssignCallsController(){
        
        /*Select 
        z.ZTS_US_User_Territory_Uniq_Key__c, 
        z.ZTS_US_Territory__c, 
        z.ZTS_US_Territory_Name__c, 
        z.ZTS_US_Start_Date__c, 
        z.ZTS_US_Processed__c, 
        z.ZTS_US_End_Date__c, 
        z.ZTS_US_Employee__c, 
        z.ZTS_US_ChangeFlag__c, 
        z.Name 
        From ZTS_US_UserTerritory__c z
        */
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        Account acc = new Account();
        acc.Name = 'Test123';
        acc.ZTS_EU_Market__c = 'United Kingdom';
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        System.runAs(usr)
        {
            insert acc;
        }
        
        PIT_Coaching_Guide__c cg = new PIT_Coaching_Guide__c();
        cg.PIT_Coach__c = Userinfo.getUserId();
        cg.PIT_Coaching_Status__c = 'New';
        cg.PIT_Colleague__c = Userinfo.getUserId();
        cg.PIT_Colleague_Comments__c = 'comments123';
        cg.ZTS_EU_Market__c = 'United kingdom';
        //cg.PIT_Colleague_Territory__c = '';
        //cg.PIT_Colleagues_Director__c = '';
        //cg.PIT_Colleagues_Manager__c = '';
        //cg.PIT_Copy_Comments__c = '';
        //cg.PIT_Date_of_Visit__c = '';
        //cg.PIT_Day_Summary__c = '';
        //cg.PIT_Last_Session__c = '';
        //cg.PIT_No_of_Account_Calls__c = '';
        //cg.PIT_No_of_Days_in_Field__c = '';
        //cg.PIT_Notification_Extra_Email__c = '';
        //cg.PIT_Users_Match__c = '';
        //cg.PIT_Check_Current_User_Coach__c = '';
        //cg.PTI_Check_Current_User_Colleague__c = '';
        //cg.PTI_Check_Current_User_Manager__c = '';
        
        insert cg;
        
        Call__c c1 = new Call__c();
        c1.ZTS_EU_Status__c = 'Submitted';
        c1.ZTS_EU_Start_Date_Time__c = System.now().addDays(-1);
        c1.ZTS_EU_End_Date_Time__c = System.now();
        c1.PIT_Coaching_Guide__c = null;
        c1.ZTS_EU_Account__c = acc.Id;
        insert c1;
        
        Test.startTest();
    
        PageReference pageRef = Page.PIT_MassAssignCalls;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',cg.id);            
        
        Call__c[] chck = [select Id from Call__c where PIT_Coaching_Guide__c = :cg.Id];
        System.assert(chck.size() == 0, 'At this stage no related calls should be found');
        
        PIT_MassAssignCallsController ctl = new PIT_MassAssignCallsController();
        System.assert(ctl.foundEls.size() == 1, 'Single call should be potentially found and availale in the app');
        
        ctl.foundEls[0].selected = true;
        ctl.assignCalls();
        
        chck = [select Id from Call__c where PIT_Coaching_Guide__c = :cg.Id];
        System.assert(chck.size() == 1, 'Now record should be assign for contextual coaching guide');
        
        Map<Id, Integer> mIdCoachingGuide2Change = new Map<Id, Integer>();
        Integer i = 3;
        mIdCoachingGuide2Change.put(cg.Id, i);
        Integer j = 2;
        PIT_MassAssignCallsController.addEntryToMap(mIdCoachingGuide2Change, cg.Id, j);
        
        System.assert(mIdCoachingGuide2Change.get(cg.Id) == i + j, 'Method should assign sum of prev. value and new one.');
        
        mIdCoachingGuide2Change = new Map<Id, Integer>();
        PIT_MassAssignCallsController.addEntryToMap(mIdCoachingGuide2Change, cg.Id, j);
        System.assert(mIdCoachingGuide2Change.get(cg.Id) == j, 'In case of not found element, passed value should be used.');
        
        
        Call__c c2 = new Call__c();
        c2.ZTS_EU_Status__c = 'Submitted';
        c2.ZTS_EU_Start_Date_Time__c = System.now().addDays(-1);
        c2.ZTS_EU_End_Date_Time__c = System.now();
        c2.PIT_Coaching_Guide__c = cg.Id;
        c2.ZTS_EU_Account__c = acc.Id;
        insert c2;
        
        delete chck;
             
    }
   
    static testmethod void testDelSubmittedCall() { 
        list<call__c> calllst= ZTS_EU_DataUtilityTest1.createCallRecord(1);
        insert calllst;
        calllst[0].ZTS_EU_Status__c = 'Submitted';
        update calllst;
        CallService.delSubmittedCall(calllst);
        CallService.delSampleDrop(calllst);
        System.assertNotEquals(null,[Select Id From Call__c where ZTS_EU_Status__c = 'Submitted']); 
    }
    
    //Below test method is used to cover method 'updateCallOwner' in class "CallService" 
    @isTest
    static void updateCallOwnerTest() {
        
        
        User testINTLUser = ZTS_EU_DataUtilityTest.createUserWithProfile('UK and Nordics Field Based Function', false);
        testINTLUser.ZTS_EU_Market__c = INTL_MARKET;
        insert testINTLUser;
        
        List<Account> testINTLAccounts = new List<Account>();
        testINTLAccounts.addAll(ZTS_DataUtilityTest.createAccountRecord(1));
        testINTLAccounts[0].ZTS_EU_Market__c = INTL_MARKET;
        insert testINTLAccounts;
        
        User userRecord2 = [SELECT Id FROM User WHERE ZTS_EU_Market__c = :INTL_MARKET and Profile.Name = 'UK and Nordics Field Based Function' LIMIT 1];
        
        List<Call__c> testINTLCalls = new List<Call__c>();
        for(Integer i=0; i<NUM_CALLS; i++) {
            Call__c call = new Call__c();
            call.ZTS_EU_Sub_Type__c = 'Account Call'; 
            call.ZTS_EU_Duration__c = '0.5'; 
            call.ZTS_EU_Next_Step__c = 'Test next step ' + i; 
            call.ZTS_EU_Account__c = testINTLAccounts[0].Id;
            testINTLCalls.add(call);
        }
        insert testINTLCalls;
        
        List<ZTS_EU_Colleague__c> testINTLColleagues = new List<ZTS_EU_Colleague__c>();
        for(Integer i=0; i<NUM_COLLEAGUES; i++) {
            ZTS_EU_Colleague__c colleagues = new ZTS_EU_Colleague__c();
            colleagues.ZTS_EU_Call__c = testINTLCalls[i].Id;
            colleagues.ZTS_EU_User__c = userRecord2.Id;
            testINTLColleagues.add(colleagues);
        }
        insert testINTLColleagues;
        
        test.startTest();
        CallService.updateCallOwner(testINTLColleagues);
        test.stopTest();
        
        Call__c cl = [Select ZTS_EU_Call_Owner__c from Call__c where Id =: testINTLCalls[0].id];
        system.assertNotEquals(null, userRecord2.Id);

    }
    @isTest
    static void beforeinsertTest(){
        User userRecord1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        userRecord1.FirstName = 'David';
        userRecord1.LastName = 'Seliman';
        userRecord1.Email = 'temp@temp.com';
        insert userRecord1;
        List<Account> testINTLAccounts = new List<Account>();
        testINTLAccounts.addAll(ZTS_DataUtilityTest.createAccountRecord(1));
        testINTLAccounts[0].ZTS_EU_Market__c = INTL_MARKET;
        insert testINTLAccounts;
        //Insert Territory
        ZTS_EU_Territory__c ItalIntlTerr = new ZTS_EU_Territory__c(
            Name = 'ItalTestTerr',
            ZTS_EU_Market__c = 'Italy'
        );
        insert ItalIntlTerr;
        //Insert Position 
         ZTS_EU_Position__c testPosition = new ZTS_EU_Position__c(
            ZTS_EU_Territory__c = ItalIntlTerr.id,
            ZTS_EU_Employee__c = userRecord1.Id,
            ZTS_EU_Type__c = 'Field Force Rep',
            ZTS_EU_Is_Active__c = true
        );
        Insert testPosition;
        system.runAs(userRecord1){
            call__c call = new call__c();
            call.ZTS_EU_Sub_Type__c = 'Account Call';
            call.ZTS_EU_Duration__c = '0.5';
            call.ZTS_EU_Next_Step__c = 'Test next step';
            call.ZTS_EU_Account__c = testINTLAccounts[0].Id;
            call.ZTS_EU_Call_Owner__c=null;
            insert call;
            Call__c insertedCall = [SELECT ZTS_EU_Call_Owner__c FROM Call__c WHERE CreatedById = :userRecord1.Id];
            System.assertEquals(insertedCall.ZTS_EU_Call_Owner__c,userRecord1.Id);
        }
        User  userRecord3= [SELECT Id FROM User WHERE Name = 'NGSE Connect INTL' LIMIT 1];
        Test.startTest();
        system.runAs(userRecord3){

            Call__c insertedCall = [SELECT ZTS_EU_Call_Owner__c,Type__c,CreatedById,LastModifiedById FROM Call__c WHERE CreatedById = :userRecord1.Id];
            insertedCall.ZTS_EU_Duration__c='0.6';
            update insertedCall;
            System.assertEquals(insertedCall.ZTS_EU_Call_Owner__c,userRecord1.Id);
            ZTS_EU_Position__c pos = [SELECT Id,ZTS_EU_Type__c FROM ZTS_EU_Position__c where ZTS_EU_Employee__c = :insertedCall.ZTS_EU_Call_Owner__c AND ZTS_EU_Is_Active__c = true];
            System.assertEquals(insertedCall.Type__c,pos.ZTS_EU_Type__c);
        }
        test.stopTest();

    }
    @isTest
    static void afterinsert_col(){
        User testINTLUser = ZTS_EU_DataUtilityTest.createUserWithProfile('UK and Nordics Field Based Function', false);
        testINTLUser.ZTS_EU_Market__c = INTL_MARKET;
        insert testINTLUser;
         List<Account> testINTLAccounts = new List<Account>();
        testINTLAccounts.addAll(ZTS_DataUtilityTest.createAccountRecord(1));
        testINTLAccounts[0].ZTS_EU_Market__c = INTL_MARKET;
        insert testINTLAccounts;
         User userRecord1 = [SELECT Id FROM User WHERE ZTS_EU_Market__c = :INTL_MARKET and Profile.Name = 'UK and Nordics Field Based Function' LIMIT 1];
         User  userRecord2= [SELECT Id FROM User WHERE Name = 'NGSE Connect INTL' LIMIT 1];
        Test.startTest();
        system.runAs(userRecord2){
             call__c call = new call__c();
            call.ZTS_EU_Sub_Type__c = 'Account Call';
            call.Name='Test call';
            call.ZTS_EU_Duration__c = '0.5';
            call.ZTS_EU_Next_Step__c = 'Test next step';
            call.ZTS_EU_Account__c = testINTLAccounts[0].Id;
            call.ZTS_EU_Call_Owner__c=userRecord1.Id;
            call.CreatedById = userRecord2.Id;
            call.LastModifiedById = userRecord2.Id;
            
            insert call;
            ZTS_EU_Colleague__c colleague=[SELECT ZTS_EU_User__c FROM ZTS_EU_Colleague__c where ZTS_EU_Call__c =: call.Id LIMIT 1];
             System.assertEquals(call.ZTS_EU_Call_Owner__c, colleague.ZTS_EU_User__c);

        }
        Test.stopTest();
    }
   
}