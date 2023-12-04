@isTest
public class USCallTriggerServiceTest {
    
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
    
    static final String MARKET = 'United States';
    static final String DI_SEARCH = 'Testy';
    static final String SAMPLE_SEARCH = 'Testy Sample ';
    static final String PRODUCT_LEVEL = 'Brand';
    static final String US_USER_LN = 'UsUser';
    static final String COLLEAGUE_USER_LN = 'Colleague';
    static final String US_PROFESSION = 'Academia';
    
    static final Integer ON_HAND_BALACE = 30;
    
    
     static void dataSetup() {
        
        AccountTriggerHandler accountHandler = new AccountTriggerHandler();
        accountHandler.disableTrigger = true;
        // ContactTriggerHandler contactHandler = new ContactTriggerHandler();
        // contactHandler.disableTrigger = true;
        // CallTriggerHandler callHandler = new CallTriggerHandler();
        // callHandler.disableTrigger = true;

        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();

        List<Id> searchResultIds = new List<Id>();

        List<Account> testAccounts = new List<Account>();
        testAccounts.addAll(ZTS_DataUtilityTest.createAccountRecord(NUM_ACCOUNTS));
        insert testAccounts;

        List<Contact> testContacts = new List<Contact>();
        testContacts.addAll(ZTS_DataUtilityTest.createContactRecord(NUM_CONTACTS));
        for(Integer i=0; i<NUM_CONTACTS; i++) {
            testContacts[i].AccountId = testAccounts[i].Id;
            testContacts[i].ZTS_EU_Market__c = MARKET;
        }
        insert testContacts;
        User userRecord1 = [SELECT Id FROM User WHERE LastName LIKE :US_USER_LN LIMIT 1];
        
        List<Call__c> testCalls = new List<Call__c>();
        for(Integer i=0; i<NUM_CALLS; i++) {
        
            DateTime startdatetime = DateTime.newInstance(2021, 03, 17, 12, 0, 0);
            DateTime enddatetime = DateTime.newInstance(2021, 03, 17, 12, 30, 0);
            Call__c call = new Call__c();
            call.ZTS_EU_Start_Date_Time__c = startdatetime;
            call.ZTS_EU_Sub_Type__c = 'Account Call'; 
            call.ZTS_EU_Duration__c = '0.5'; 
            call.ZTS_EU_Next_Step__c = 'Test next step ' + i; 
            call.ZTS_EU_Account__c = testAccounts[i].Id;
            call.ZTS_EU_Call_Owner__c = userRecord1.Id;
            call.Opportunity_Type__c = 'CARYSTA';
            call.ZTS_EU_Status__c = 'Submitted';
            call.ZTS_EU_End_Date_Time__c = enddatetime;
            testCalls.add(call);
        }
        insert testCalls;

        List<ZTS_EU_Colleague__c> testColleagues = new List<ZTS_EU_Colleague__c>();
        for(Integer i=0; i<NUM_COLLEAGUES; i++) {
            ZTS_EU_Colleague__c colleagues = new ZTS_EU_Colleague__c();
            colleagues.ZTS_EU_Call__c = testCalls[i].Id;
            testColleagues.add(colleagues);
        }
        insert testColleagues;

        List<Attendee__c> testAttendees = new List<Attendee__c>();
        for(Integer i=0; i<NUM_ATTENDEES; i++) {
            Attendee__c attendee = new Attendee__c();
            attendee.Name = 'Test Attendee' + i; 
            attendee.ZTS_EU_Call__c = testCalls[0].Id;
            attendee.ZTS_EU_Contact__c = testContacts[i].Id;
            testAttendees.add(attendee);
        }
        insert testAttendees;

        List<ZTS_EU_Discussion_Item__c> discussionItems = new List<ZTS_EU_Discussion_Item__c>();
        for(Integer i=0; i<NUM_DISC_ITEMS; i++) {
            ZTS_EU_Discussion_Item__c discItem = new ZTS_EU_Discussion_Item__c();
            discItem.ZTS_EU_Start_Date__c = Date.today() - 5; 
            if(Math.mod(i,2)==0) {
                discItem.ZTS_EU_Discussion_Item_Title__c = 'Discussion Item '+i;
                discItem.ZTS_EU_End_Date__c = Date.today() - 1; 
            }
            else {
                discItem.ZTS_EU_Discussion_Item_Title__c = DI_SEARCH + ' Discussion Item '+i;
            }
            discItem.ZTS_EU_Market__c = MARKET;
            discussionItems.add(discItem);
        }
        insert discussionItems;

        

       

        List<ZTS_EU_Discussion__c> callDiscussions = new List<ZTS_EU_Discussion__c>();
        for(Attendee__c attendee : testAttendees) {
        
            for(ZTS_EU_Discussion_Item__c discItem : discussionItems) {
                searchResultIds.add(discItem.Id);
                ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c();
                disc.ZTS_EU_Call_Attendee__c = attendee.Id; 
                disc.ZTS_EU_Discussion_Items__c = discItem.Id; 
                callDiscussions.add(disc);
            }

            }
        insert callDiscussions; 

        
        
       
    

    }
     @isTest
    static void saveLookupResultsTest_NetNewCall() {

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = US_USER_LN;
        usr.zts_eu_market__c = MARKET;
        insert usr;
                
        System.runAs(usr)
        {

            dataSetup();

            SalesCallWrapper testSalesCallWrapper = new SalesCallWrapper();
            
            Call__c testCall = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Sub_Type__c, ZTS_EU_Duration__c, ZTS_EU_Next_Step__c,ZTS_EU_Start_Date_Time__c,ZTS_EU_End_Date_Time__c,Opportunity_Type__c,ZTS_EU_Status__c,CreatedById FROM Call__c LIMIT 1];
            testSalesCallWrapper.callId = testCall.Id; 
            List<Call__c> lstcall = new List<Call__c>();
            lstcall.add(testCall);
            List<LookupSearchResultWrapper> attendeeWrappers = new List<LookupSearchResultWrapper>();
            List<Attendee__c> testAttendees = [SELECT Id, Name FROM Attendee__c WHERE ZTS_EU_call__c = :testCall.Id];
            for(Attendee__c attendee : testAttendees) {
                attendeeWrappers.add(SalesCallLWCController.buildLookupResultFromSObject(attendee));
            }
            testSalesCallWrapper.attendees = attendeeWrappers; 
            
            List<Id> discussionIds = new List<Id>();
            List<Id> discussionItemIds = new List<Id>();
            List<Id> productIds = new List<Id>();
            List<Id> campaignIds = new List<Id>();
            for(ZTS_EU_Discussion__c disc : [SELECT Id, ZTS_EU_Discussion_Items__c, ZTS_EU_Product__c, ZTS_EU_Campaign__c FROM ZTS_EU_Discussion__c WHERE ZTS_EU_Call_Attendee__c IN :testAttendees]) {
                discussionIds.add(disc.Id);
                if(disc.ZTS_EU_Discussion_Items__c != null) {
                    discussionItemIds.add(disc.ZTS_EU_Discussion_Items__c);
                }
                
                if(disc.ZTS_EU_Product__c != null) {
                    productIds.add(disc.ZTS_EU_Product__c);
                }
                
                if(disc.ZTS_EU_Campaign__c != null) {
                    campaignIds.add(disc.ZTS_EU_Campaign__c);
                }
            }

            
            // Needed to mimic searching for contact to add as attendee
            Contact newTestContact = ZTS_DataUtilityTest.createContactRecord(1)[0];
            newTestContact.LastName = 'Testy';
            newTestContact.LastName = 'McTesterson';
            newTestContact.ZTS_EU_Market__c = MARKET;
            newTestContact.AccountId = testCall.ZTS_EU_Account__c;
            
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true; 
            Database.SaveResult sr = Database.insert(newTestContact, dml); 
            
            testSalesCallWrapper.contacts = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestContact)};
            
            // Needed to mimic searching for discussion item to add as discussion
            ZTS_EU_Discussion_Item__c newTestDiscItem = new ZTS_EU_Discussion_Item__c();
            newTestDiscItem.ZTS_EU_Start_Date__c = Date.today() - 5; 
            newTestDiscItem.ZTS_EU_Discussion_Item_Title__c = DI_SEARCH + ' Discussion Item 999';
            newTestDiscItem.ZTS_EU_Market__c = MARKET;
            insert newTestDiscItem; 
            testSalesCallWrapper.discussionItems = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestDiscItem)};
            
            // Needed to mimic searching for product to add as discussion
            ZTS_EU_Species_Product__c newTestProduct = new ZTS_EU_Species_Product__c();
            newTestProduct.Name = SAMPLE_SEARCH + '999';
            newTestProduct.ZTS_EU_Is_Active__c = true;
            newTestProduct.ZTS_Hierarchy_Level__c = PRODUCT_LEVEL;
            newTestProduct.ZTS_EU_Market__c = MARKET;
            
            Opportunity opp = new Opportunity(ZTS_EU_Market__c = 'United States',Name='Test',CloseDate = system.today(),
                                          Type='CARYSTA HVC',
                                          StageName='Qualified',
                                          AccountId=testCall.ZTS_EU_Account__c);
            
            Test.startTest();
            insert opp;
            
            insert newTestProduct; 
            testSalesCallWrapper.products = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestProduct)};
            
             Map<Id, Call__c> callList = new Map<Id, Call__c>([SELECT Id, ZTS_EU_Call_Owner__c, ZTS_EU_Call_Objectives__c, ZTS_EU_Account__c, ZTS_EU_Status__c,
                                                            ZTS_EU_Submitted_Date__c, ZTS_EU_Start_Date_Time__c,CreatedById,Name,ZTS_EU_End_Date_Time__c
                                                            FROM Call__c]);
       // System.assert(callList.size() > 0);

        CallUtils.createOpportunity(new List<Id>(callList.keySet()));
            // Needed to mimic searching for campaign to add as discussion
            ZTS_US_Sample__c newTestSample = new ZTS_US_Sample__c();
            newTestSample.ZTS_US_Product__c = newTestProduct.Id;
            newTestSample.ZTS_US_Item_Code__c = 'IC-00099';
            newTestSample.ZTS_US_Start_Quantity__c = ON_HAND_BALACE;
            newTestSample.ZTS_EU_Market__c = MARKET;
            insert newTestSample; 
            testSalesCallWrapper.samples = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestSample)};
            ZTS_EU_Discussion_Item__c zts = new ZTS_EU_Discussion_Item__c(ZTS_EU_Market__c=MARKET,ZTS_EU_Active__c=true);
            insert zts;
            // Needed to mimic adding a new follow-up activity to add as discussion
            Task testTask = new Task();
            testTask.Subject = 'Test Subject 999';
            testTask.Status = 'Call';
            testTask.Priority = 'Medium';
            testTask.ActivityDate = Date.today() + 7;
            testTask.WhatId = testCall.Id;
            
            
            FollowUpActivityWrapper testFAW = new FollowUpActivityWrapper(testTask);
            User testUser = new User(
                Id=UserInfo.getUserId()
            );
            LookupSearchResultWrapper userLookup = SalesCallLWCController.buildLookupResultFromSObject(testUser);
            testFAW.owner = new List<LookupSearchResultWrapper>{userLookup};

            testSalesCallWrapper.followUpActivities = new List<FollowUpActivityWrapper>{testFAW};

            // Needed to mimic searching for user to add as colleague
            User newTestUser = new User();
            newTestUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            newTestUser.FirstName = 'Test';
            newTestUser.LastName = COLLEAGUE_USER_LN;
            newTestUser.zts_eu_market__c = MARKET;
            insert newTestUser;
            testSalesCallWrapper.users = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestUser)};

            // Add next call info and query for new call record for assertion
            // Next call fields to create next planned call automatically
            Map<String,String> nextCallFieldMappings = new Map<String,String>();
            
            Date testDate = Date.today();
            String dateTimeString = testDate.year() +'-'+ testDate.month() +'-'+ testDate.day() + 'T12:00:00.000Z';
            nextCallFieldMappings.put('ZTS_EU_Next_Call_Date__c', dateTimeString); 
            nextCallFieldMappings.put('ZTS_EU_Sub_Type__c', testCall.ZTS_EU_Sub_Type__c);
            nextCallFieldMappings.put('ZTS_EU_Next_Step__c', testCall.ZTS_EU_Next_Step__c);
            nextCallFieldMappings.put('ZTS_EU_Duration__c', testCall.ZTS_EU_Duration__c);
            nextCallFieldMappings.put('ZTS_EU_Account__c', testCall.ZTS_EU_Account__c);
            testSalesCallWrapper.nextCallFieldsJson = JSON.serialize(nextCallFieldMappings);
             String testSalesCallWrapperJson = JSON.serialize(testSalesCallWrapper);
            //  Boolean isSuccess = SalesCallLWCController.saveLookupResults(testSalesCallWrapperJson);
            USCallTriggerService.beforeInsert(lstcall);
            USCallTriggerService.afterUpdate(lstcall, callList, lstcall, callList);
            Test.stopTest();
        }

    }
    
    @isTest static void caluclateEndDateTime(){
        
        //Create an US User
        
        Profile p = [SELECT Id FROM Profile WHERE Name='US Livestock Rep'];
        
        User newuser = new User();
        newuser.profileid=p.Id;
        newuser.email='deneme@deneme.com';
        newuser.username= 'z' + string.valueof(math.random())+'@ZUSTEST.com';
        newuser.lastname='deneme';
        newuser.alias='deneme1';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newuser.ZTS_EU_isCoacher__c=TRUE;    
        newuser.ZTS_EU_Market__c='United States';
        newuser.EmailEncodingKey='ISO-8859-1';    
            
       
            
        insert newuser;

        System.runAs(newuser) {
        
               //Create an Account
                
                Account acc = new Account();         
                acc.name = 'Test Account';
                acc.ZTS_EU_Country__c = 'United States';
                acc.BillingCity = 'Test City';
                acc.ZTS_EU_Zip_Postal_Code__c = '12345';
                //acc.ZTS_EU_State_County__c  = 'Ohio';
                acc.BillingStreet = 'Test Street'; 
                acc.BillingPostalCode = '12344';
                acc.BillingState = 'Test State'; 
                acc.ZTS_EU_Market__c = '';
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
                call.ZTS_EU_Status__c = 'Submitted';
                call.ZTS_EU_Duration__c = '0.5 Hour';
                call.ZTS_EU_Call_Owner__c = UserInfo.getUserId();
                insert call;    


                Map<Id, Call__c> mockOldMap = new Map<Id, Call__c>{call.Id => call};
                //This part was added as part of SC-008816  
                call.ZTS_EU_Start_Date_Time__c = startdatetime.addMinutes(30);
            	update call;
                
                DateTime updatedStartTime = [Select ZTS_EU_Start_Date_Time__c from Call__c where id =:call.id][0].ZTS_EU_Start_Date_Time__c;
            	DateTime calEventDateTime = [Select startDateTime from Event where CallRecordID__c =:call.id][0].startDateTime;
            	
                system.assertEquals(updatedStartTime,calEventDateTime);
                //EOC - This part was added as part of SC-008816  

            	Map<Id, Call__c> mockNewMap = new Map<Id, Call__c>{call.Id => call};
                

              //  USCallTriggerService.beforeInsert(new List<Call__c>{call});
                
  
                USCallTriggerService.beforeDelete(mockOldMap.values(), mockOldMap);
               
                    
        }
        
        //Create an US User
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='US Livestock Manager'];
        
        User newuser1 = new User();
        newuser1.profileid=p1.Id;
        newuser1.email='manager@deneme.com';
        newuser1.username= 'z' + string.valueof(math.random())+'@ZUSTEST.com';
        newuser1.lastname='deneme';
        newuser1.alias='deneme211';
        newuser1.languagelocalekey='en_US';
        newuser1.localesidkey='en_US';
        newuser1.timezonesidkey='America/Los_Angeles';
        newuser1.localesidkey='en_US';
        newuser1.ZTS_EU_isCoacher__c=TRUE;    
        newuser1.ZTS_EU_Market__c='United States';
        newuser1.EmailEncodingKey='ISO-8859-1';    
        
    }
    

}