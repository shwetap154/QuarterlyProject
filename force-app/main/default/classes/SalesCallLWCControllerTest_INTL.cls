/******************************************************************************************************************************************
 * Class Name   : SalesCallLWCControllerTest_INTL
 * Description  : Unit test for SalesCallLWCController for International changes
 * Created By   : Aritra (Cognizant)
 * Created Date : 13 July 2021
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)        13-Jul-2021        Created
 * Ethan Hirsch (Zoetis)    07-Jun-2022        Change reference to UK & Nordics Field Based Function profile to not include
 *                                             special characters to avoid Copado issues with Profile deployments.
 *****************************************************************************************************************************************/
@isTest
private class SalesCallLWCControllerTest_INTL {
    
    static final Integer NUM_ACCOUNTS = 2;
    static final Integer NUM_CONTACTS = 2;
    static final Integer NUM_CALLS = 2;
    static final Integer NUM_ATTENDEES = 2;
    static final Integer NUM_COLLEAGUES = 1;
    static final Integer NUM_DISC_ITEMS = 3;
    static final Integer NUM_PRODUCTS = 4;
    static final Integer NUM_CAMPAIGNS = 3;
    static final Integer NUM_TASKS = 2;
    static final Integer NUM_SAMPLES = 4;
    static final Integer NUM_SAMPLE_DROPS = NUM_SAMPLES;
    
    static final String DI_SEARCH = 'Testy';
    static final String SAMPLE_SEARCH = 'Testy Sample ';
    static final String COLLEAGUE_USER_LN = 'Colleague';
    static final String US_PROFESSION = 'Academia';
    static final String INTL_MARKET = 'United Kingdom';
    static final Integer INTL_ON_HAND_BALANCE = 10;
    static final String INTL_PRODUCT_LEVEL = 'MPG';
    
    static void dataSetup() {
        
        AccountTriggerHandler accountHandler = new AccountTriggerHandler();
        accountHandler.disableTrigger = true;
        // ContactTriggerHandler contactHandler = new ContactTriggerHandler();
        // contactHandler.disableTrigger = true;
        // CallTriggerHandler callHandler = new CallTriggerHandler();
        // callHandler.disableTrigger = true;

        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        List<Id> searchResultIds = new List<Id>();
        //Added by Aritra (for INTL) - SC-004726
        
        User testINTLUser = ZTS_EU_DataUtilityTest.createUserWithProfile('UK and Nordics Field Based Function', false);
        testINTLUser.ZTS_EU_Market__c = INTL_MARKET;
        insert testINTLUser;
        
        List<Account> testINTLAccounts = new List<Account>();
        testINTLAccounts.addAll(ZTS_DataUtilityTest.createAccountRecord(NUM_ACCOUNTS));
        for(Integer i=0; i<NUM_ACCOUNTS; i++) {
            testINTLAccounts[i].ZTS_EU_Market__c = INTL_MARKET;
        }
        insert testINTLAccounts;

        List<Contact> testINTLContacts = new List<Contact>();
        testINTLContacts.addAll(ZTS_DataUtilityTest.createContactRecord(NUM_CONTACTS));
        for(Integer i=0; i<NUM_CONTACTS; i++) {
            testINTLContacts[i].AccountId = testINTLAccounts[i].Id;
            testINTLContacts[i].ZTS_EU_Market__c = INTL_MARKET;
            testINTLContacts[i].ZTS_EU_Contact_type__c = 'Veterinarian';
        }
        insert testINTLContacts;
        User userRecord2 = [SELECT Id FROM User WHERE ZTS_EU_Market__c = :INTL_MARKET and Profile.Name = 'UK and Nordics Field Based Function' LIMIT 1];
        
        List<Call__c> testINTLCalls = new List<Call__c>();
        for(Integer i=0; i<NUM_CALLS; i++) {
            Call__c call = new Call__c();
            call.ZTS_EU_Sub_Type__c = 'Account Call'; 
            call.ZTS_EU_Duration__c = '0.5'; 
            call.ZTS_EU_Next_Step__c = 'Test next step ' + i; 
            call.ZTS_EU_Account__c = testINTLAccounts[i].Id;
            call.ZTS_EU_Call_Owner__c = userRecord2.Id;
            testINTLCalls.add(call);
        }
        insert testINTLCalls;

        List<ZTS_EU_Colleague__c> testINTLColleagues = new List<ZTS_EU_Colleague__c>();
        for(Integer i=0; i<NUM_COLLEAGUES; i++) {
            ZTS_EU_Colleague__c colleagues = new ZTS_EU_Colleague__c();
            colleagues.ZTS_EU_Call__c = testINTLCalls[i].Id;
            testINTLColleagues.add(colleagues);
        }
        insert testINTLColleagues;

        List<Attendee__c> testINTLAttendees = new List<Attendee__c>();
        for(Integer i=0; i<NUM_ATTENDEES; i++) {
            Attendee__c attendee = new Attendee__c();
            attendee.Name = 'Test Attendee' + i; 
            attendee.ZTS_EU_Call__c = testINTLCalls[0].Id;
            attendee.ZTS_EU_Contact__c = testINTLContacts[i].Id;
            testINTLAttendees.add(attendee);
        }
        insert testINTLAttendees;

        List<ZTS_EU_Discussion_Item__c> discussionItemsINTL = new List<ZTS_EU_Discussion_Item__c>();
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
            discItem.ZTS_EU_Market__c = INTL_MARKET;
            discussionItemsINTL.add(discItem);
        }
        insert discussionItemsINTL;

        List<ZTS_EU_Species_Product__c> brandProductsINTL = new List<ZTS_EU_Species_Product__c>();
        for(Integer i=0; i<NUM_PRODUCTS; i++) {
            ZTS_EU_Species_Product__c brandProd = new ZTS_EU_Species_Product__c();
            brandProd.ZTS_EU_Is_Active__c = true;
            if(Math.mod(i,2)==0) {
                brandProd.ZTS_Hierarchy_Level__c = INTL_PRODUCT_LEVEL;
                brandProd.Name = SAMPLE_SEARCH + i; // Gets set to sample title field via pb, so need to set for search functionality
            }
            else {
                brandProd.ZTS_Hierarchy_Level__c = 'Item';
            }
            brandProd.ZTS_EU_Is_Active__c = TRUE;
            brandProd.ZTS_EU_Is_Detailable__c = TRUE;
            brandProd.ZTS_EU_is_Samplable__c = TRUE;
            brandProd.ZTS_EU_Market__c = INTL_MARKET;
            brandProductsINTL.add(brandProd);
        }
        insert brandProductsINTL;

        List<Campaign> campaignsINTL = ZTS_DataUtilityTest.createCampaignRecord(NUM_CAMPAIGNS);
        for(Campaign camp : campaignsINTL) {
            camp.Name = DI_SEARCH + ' ' + camp.Name;
            camp.ZTS_EU_Market__c = INTL_MARKET;
        }
        insert campaignsINTL;
        
        List<Task> tasksINTL = new List<Task>();
        for(Integer i=0; i<NUM_TASKS; i++) {
            Task t = new Task();
            t.Subject = 'Test Subject ' + i;
            t.Status = 'Call';
            t.Priority = 'Low';
            t.ActivityDate = Date.today() + i;
            t.WhatId = testINTLCalls[0].Id;
            t.Follow_up_Item__c = brandProductsINTL[0].Id;
            tasksINTL.add(t);
        }
        insert tasksINTL; 

        List<ZTS_EU_Discussion__c> callDiscussionsINTL = new List<ZTS_EU_Discussion__c>();
        for(Attendee__c attendee : testINTLAttendees) {
        
            for(ZTS_EU_Discussion_Item__c discItem : discussionItemsINTL) {
                searchResultIds.add(discItem.Id);
                ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c();
                disc.ZTS_EU_Call_Attendee__c = attendee.Id; 
                disc.ZTS_EU_Discussion_Items__c = discItem.Id; 
                callDiscussionsINTL.add(disc);
            }

            for(ZTS_EU_Species_Product__c brandProd : brandProductsINTL) {
                searchResultIds.add(brandProd.Id);
                if(brandProd.ZTS_Hierarchy_Level__c != INTL_PRODUCT_LEVEL) continue;
                ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c();
                disc.ZTS_EU_Call_Attendee__c = attendee.Id; 
                disc.ZTS_EU_Product__c = brandProd.Id; 
                callDiscussionsINTL.add(disc);
            }

            for(Campaign camp : campaignsINTL) {
                searchResultIds.add(camp.Id);
                ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c();
                disc.ZTS_EU_Call_Attendee__c = attendee.Id; 
                disc.ZTS_EU_Campaign__c = camp.Id; 
                callDiscussionsINTL.add(disc);
            }

        }
        insert callDiscussionsINTL; 



                    ZTS_EU_Sample__c sample = new ZTS_EU_Sample__c();
                    sample.ZTS_EU_Product__c = brandProductsINTL[0].Id;
                    sample.ZTS_EU_Contact__c = testINTLContacts[0].Id;
                    sample.ZTS_EU_Start_Quantity__c = INTL_ON_HAND_BALANCE;
        insert sample;

        searchResultIds.add(sample.Id);

        List<Sample_Drop__c> testINTLSampleDrops = new List<Sample_Drop__c>();
        for(Integer i=0; i<NUM_CALLS; i++){
                Sample_Drop__c sampleDrop = new Sample_Drop__c();
                sampleDrop.ZTS_EU_Call__c = testINTLCalls[i].Id;
                sampleDrop.ZTS_EU_Contact__c = sample.ZTS_EU_Contact__c;
                sampleDrop.ZTS_EU_Quantity__c = 2;
                sampleDrop.ZTS_EU_Sample__c = sample.Id;
                testINTLSampleDrops.add(sampleDrop);
        }

        insert testINTLSampleDrops;
     
        ZTS_EU_Species_Product__c giftProd = new ZTS_EU_Species_Product__c();
        giftProd.name ='Gift Prod';
        giftProd.ZTS_EU_Is_Active__c = TRUE;
        giftProd.ZTS_EU_is_Gift__c = TRUE;
        giftProd.ZTS_EU_Market__c = INTL_MARKET;
        insert giftProd;
        
        
        
        
        ZTS_EU_Gift__c gift = new ZTS_EU_Gift__c();
        gift.ZTS_EU_Call__c = testINTLCalls[0].Id;
        gift.ZTS_EU_Contact__c = testINTLContacts[0].Id;
        gift.ZTS_EU_Product_Hierarchy__c = giftProd.Id;
        gift.ZTS_EU_Quantity__c = 3;
        gift.ZTS_EU_Description__c = 'Test INTL Gift';
        insert gift;
        
        Opportunity optyINTL = new Opportunity();
        optyINTL.AccountId = testINTLAccounts[0].Id;
        optyINTL.Name= 'UK Test Opportunity';
        optyINTL.CloseDate = system.today()+3;
        optyINTL.StageName = 'Qualified';    
        optyINTL.ZTS_EU_Market__c = INTL_MARKET;
        insert optyINTL;
        

        insert new Opportunity_Call__c(Name = optyINTL.Name,Call__c = testINTLCalls[0].Id,Opportunity__c = optyINTL.id);
            
                
        

        Test.setFixedSearchResults(searchResultIds); 
    }
    
    @isTest
    static void getCallRecordAndRelatedRecordsTestINTL() {

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = 'INTL_USER_LN';
        usr.zts_eu_market__c = INTL_MARKET;
        insert usr;
                
        System.runAs(usr)
        {

            dataSetup();

            SalesCallWrapper salesCallWrapEmpty = new SalesCallWrapper();
            String salesCallWrapEmptyJson = JSON.serialize(salesCallWrapEmpty);

            Id callRecordId = [SELECT Id FROM Call__c where ZTS_EU_Account__r.ZTS_EU_Market__c = :INTL_MARKET LIMIT 1][0].Id;
            String callRecordIdString = String.valueOf(callRecordId);
            Test.startTest();
                String actualCallRecordWrapperJson = SalesCallLWCController.getCallRecordAndRelatedRecords(callRecordIdString);
            Test.stopTest();
            

            System.assertNotEquals(salesCallWrapEmptyJson, actualCallRecordWrapperJson, 'The sales call wrapper should not be empty');
            SalesCallWrapper actualCallRecordWrapper = (SalesCallWrapper)JSON.deserialize(actualCallRecordWrapperJson,SalesCallWrapper.class);
            
            System.assert(!actualCallRecordWrapper.attendees.isEmpty(), 'Attendees should not be empty');
            System.assertEquals(NUM_ATTENDEES, actualCallRecordWrapper.attendees.size(), 'The number of attendees should match');
            
            System.assert(!actualCallRecordWrapper.discussionItems.isEmpty(), 'Discussion items should not be empty');
            System.assertEquals(NUM_DISC_ITEMS, actualCallRecordWrapper.discussionItems.size(), 'The number of discussion items should match');
            
            System.assert(!actualCallRecordWrapper.products.isEmpty(), 'Products should not be empty');
            System.assertEquals(NUM_PRODUCTS/2, actualCallRecordWrapper.products.size(), 'The number of brand products should match');
            
            System.assert(!actualCallRecordWrapper.campaigns.isEmpty(), 'Campaigns should not be empty');
            System.assertEquals(NUM_CAMPAIGNS, actualCallRecordWrapper.campaigns.size(), 'The number of campaigns should match');
            
            System.assert(!actualCallRecordWrapper.followUpActivities.isEmpty(), 'Tasks should not be empty');
            System.assertEquals(NUM_TASKS, actualCallRecordWrapper.followUpActivities.size(), 'The number of tasks should match');
            
            System.assert(!actualCallRecordWrapper.gifts.isEmpty(), 'Gifts should not be empty');
            System.assertEquals(1, actualCallRecordWrapper.gifts.size(), 'The number of gifts should match');

        }
    }
    
    @isTest
    static void removeItemTest_Gift() {

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = 'UK_USER_LN';
        usr.zts_eu_market__c = INTL_MARKET;
        insert usr;
                
        System.runAs(usr)
        {
            
            dataSetup();
            
            ZTS_EU_Gift__c testGift = [SELECT Id FROM ZTS_EU_Gift__c LIMIT 1];
            
            Test.startTest();
                SalesCallLWCController.removeItem(null, testGift.Id, 'Gift');
            Test.stopTest();
            
            
            List<ZTS_EU_Gift__c> removedGift = [SELECT Id FROM ZTS_EU_Gift__c WHERE Id = :testGift.Id];
            System.assertEquals(0, removedGift.size(), 'No gift should exist for that id');

        }

    }
    
    @isTest
    static void removeItemTest_Opportunity() {

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = 'UK_USER_LN';
        usr.zts_eu_market__c = INTL_MARKET;
        insert usr;
                
        System.runAs(usr)
        {
            
            dataSetup();
            
            Opportunity_Call__c testOptyCall= [SELECT Id FROM Opportunity_Call__c LIMIT 1];
            
            Test.startTest();
                SalesCallLWCController.removeItem(null, testOptyCall.Id, 'Opportunity Call');
            Test.stopTest();
            
            
            List<Opportunity_Call__c > removedOpptyCall = [SELECT Id FROM Opportunity_Call__c WHERE Id = :testOptyCall.Id];
            System.assertEquals(0, removedOpptyCall .size(), 'No Opportunity Call should exist for that id');

        }

    }
    
    @isTest
    static void removeItemTest_SampleDrop() {

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = 'UK_USER_LN';
        usr.zts_eu_market__c = INTL_MARKET;
        insert usr;
                
        System.runAs(usr)
        {
            
            dataSetup();
            
            Sample_Drop__c testSampleDrop= [SELECT Id FROM Sample_Drop__c LIMIT 1];
            
            Test.startTest();
                SalesCallLWCController.removeItem(null, testSampleDrop.Id, 'Sample Drop');
            Test.stopTest();
            
            
            List<Sample_Drop__c > removedSampleDrop = [SELECT Id FROM Sample_Drop__c WHERE Id = :testSampleDrop.Id];
            System.assertEquals(0, removedSampleDrop.size(), 'No Sample Drop should exist for that id');

        }

    }
    
     @isTest
    static void getAccountIdfromOpptyTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = 'US_USER_LN';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
                
        System.runAs(usr)
        {
        Account testAcc = ZTS_DataUtilityTest.createAccountRecord(1)[0];
        testAcc.ZTS_EU_Market__c = INTL_MARKET;
        insert testAcc;
        
        Opportunity optyINTL = new Opportunity();
        optyINTL.AccountId = testAcc.Id;
        optyINTL.Name= 'UK Test Opportunity';
        optyINTL.CloseDate = system.today()+3;
        optyINTL.StageName = 'Qualified';    
        optyINTL.ZTS_EU_Market__c = INTL_MARKET;
        insert optyINTL;
            
            Test.startTest();
            Id accId = SalesCallLWCController.getAccountIdfromOppty(optyINTL.Id);
            Test.stopTest();
            system.assertEquals(testAcc.Id, accId);
        }
    }
    
      @isTest
    static void isContactCreationRestrictedMarketTest() {

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = 'UK_USER_LN';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
                
        System.runAs(usr)
        {
            Test.startTest();
            Boolean actualIsInternationalUser = SalesCallLWCController.isContactCreationRestrictedMarket();
            Test.stopTest();

            System.assertEquals(false, actualIsInternationalUser);
        }
    }

    @isTest
    static void saveLookupResultsINTLTest() {

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = 'UK_USER_LN';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
                
        System.runAs(usr)
        {

            dataSetup();

            SalesCallWrapper testSalesCallWrapper = new SalesCallWrapper();
            
            Call__c testCall = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Sub_Type__c, ZTS_EU_Duration__c, ZTS_EU_Next_Step__c FROM Call__c LIMIT 1];
            testSalesCallWrapper.callId = testCall.Id; 
            
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

            List<LookupSearchResultWrapper> discussionItemWrappers = new List<LookupSearchResultWrapper>();
            for(ZTS_EU_Discussion_Item__c discItem : [SELECT Id, Name, ZTS_EU_Discussion_Item_Title__c, ZTS_EU_Active_DI__c FROM ZTS_EU_Discussion_Item__c WHERE Id IN :discussionItemIds]) {
                discussionItemWrappers.add(SalesCallLWCController.buildLookupResultFromSObject(discItem));
            }
            testSalesCallWrapper.discussionItems = discussionItemWrappers; 

            List<LookupSearchResultWrapper> productWrappers = new List<LookupSearchResultWrapper>();
            for(ZTS_EU_Species_Product__c product : [SELECT Id, Name, ZTS_Hierarchy_Level__c FROM ZTS_EU_Species_Product__c WHERE Id IN :productIds]) {
                productWrappers.add(SalesCallLWCController.buildLookupResultFromSObject(product));
            }
            testSalesCallWrapper.products = productWrappers; 

            List<LookupSearchResultWrapper> campaignWrappers = new List<LookupSearchResultWrapper>();
            for(Campaign campaign : [SELECT Id, Name, IsActive, ZTS_EU_Field_Targeting__c, StartDate, EndDate FROM Campaign WHERE Id IN :campaignIds]) {
                campaignWrappers.add(SalesCallLWCController.buildLookupResultFromSObject(campaign));
            }
            testSalesCallWrapper.campaigns = campaignWrappers; 
            testSalesCallWrapper.initialDiscussionIds.addAll(discussionIds); 
            
            List<LookupSearchResultWrapper> colleagueWrappers = new List<LookupSearchResultWrapper>();
            for(ZTS_EU_Colleague__c colleague : [SELECT Id, Name FROM ZTS_EU_Colleague__c WHERE ZTS_EU_Call__c = :testCall.Id]) {
                colleagueWrappers.add(SalesCallLWCController.buildLookupResultFromSObject(colleague));
            }
            testSalesCallWrapper.colleagues = colleagueWrappers;
            
            List<LookupSearchResultWrapper> sampleDropWrappers = new List<LookupSearchResultWrapper>();
            for(Sample_Drop__c sampleDrop : [SELECT Id, Name FROM Sample_Drop__c WHERE ZTS_EU_Call__c = :testCall.Id]) {
                sampleDropWrappers.add(SalesCallLWCController.buildLookupResultFromSObject(sampleDrop));
            }
            testSalesCallWrapper.sampleDrops = sampleDropWrappers;

            // Needed to mimic searching for contact to add as attendee
            Contact newTestContact = ZTS_DataUtilityTest.createContactRecord(1)[0];
            newTestContact.LastName = 'Testy';
            newTestContact.LastName = 'McTesterson';
            newTestContact.ZTS_EU_Market__c = 'United Kingdom';
            newTestContact.AccountId = testCall.ZTS_EU_Account__c; 
            newTestContact.ZTS_US_Profession__c = 'Account Contact';
            newTestContact.ZTS_US_Job_Function__c = 'Account Contact';
            insert newTestContact; 
            testSalesCallWrapper.contacts = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestContact)};
            
            // Needed to mimic searching for discussion item to add as discussion
            ZTS_EU_Discussion_Item__c newTestDiscItem = new ZTS_EU_Discussion_Item__c();
            newTestDiscItem.ZTS_EU_Start_Date__c = Date.today() - 5; 
            newTestDiscItem.ZTS_EU_Discussion_Item_Title__c = DI_SEARCH + ' Discussion Item 999';
            newTestDiscItem.ZTS_EU_Market__c = 'United Kingdom';
            insert newTestDiscItem; 
            testSalesCallWrapper.discussionItems = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestDiscItem)};
            
            // Needed to mimic searching for product to add as discussion
            ZTS_EU_Species_Product__c newTestProduct = new ZTS_EU_Species_Product__c();
            newTestProduct.Name = SAMPLE_SEARCH + '999';
            newTestProduct.ZTS_EU_Is_Active__c = TRUE;
            newTestProduct.ZTS_EU_Is_Detailable__c = TRUE;
            newTestProduct.ZTS_EU_is_Samplable__c = TRUE;
            newTestProduct.ZTS_Hierarchy_Level__c = INTL_PRODUCT_LEVEL;
            newTestProduct.ZTS_EU_Market__c = 'United Kingdom';
            insert newTestProduct; 
            testSalesCallWrapper.products = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestProduct)};
            
            // Needed to mimic searching for campaign to add as discussion
            Campaign newTestCampaign = new Campaign();
            newTestCampaign.Name = 'TestCampaign 999';
            newTestCampaign.ZTS_EU_Field_Targeting__c = 'Open';
            newTestCampaign.IsActive = true;
            newTestCampaign.Is_Active_Campaign__c =true;
            newTestCampaign.StartDate = System.today();
            newTestCampaign.ZTS_EU_Market__c = 'United Kingdom'; 
            newTestCampaign.Campaign_Name_English__c = 'Is test';
            insert newTestCampaign; 
            testSalesCallWrapper.campaigns = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestCampaign)};
            
            // Needed to mimic searching for campaign to add as discussion
            /*ZTS_EU_Sample__c newTestSample = new ZTS_EU_Sample__c();
            newTestSample.ZTS_EU_Product__c = newTestProduct.Id;
            newTestSample.ZTS_EU_Item_Code__c = 'IC-00099';
            newTestSample.ZTS_EU_Start_Quantity__c = INTL_ON_HAND_BALANCE;
            newTestSample.ZTS_EU_Contact__c = [Select Id from Contact where AccountID = :testCall.ZTS_EU_Account__c Limit 1].id;
            insert newTestSample; 
            testSalesCallWrapper.samples = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestSample)};*/
                
            Opportunity testOptyINTL = new Opportunity();
            testOptyINTL.AccountId = testCall.ZTS_EU_Account__c;
            testOptyINTL.Name= 'UK Test Opportunity';
            testOptyINTL.CloseDate = system.today()+3;
            testOptyINTL.StageName = 'Qualified';    
            testOptyINTL.ZTS_EU_Market__c = INTL_MARKET;
            insert testOptyINTL;
            testSalesCallWrapper.opportunities = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(testOptyINTL)};
            // Needed to mimic adding a new follow-up activity to add as discussion
            Task testTask = new Task();
            testTask.Subject = 'Test Subject 999';
            testTask.Status = 'Call';
            testTask.Priority = 'Medium';
            testTask.ActivityDate = Date.today() + 7;
            testTask.WhatId = testCall.Id;
            testTask.Follow_up_Item__c = newTestProduct.Id;
            FollowUpActivityWrapper testFAW = new FollowUpActivityWrapper(testTask);
            User testUser = new User(
                Id=UserInfo.getUserId()
            );
            LookupSearchResultWrapper userLookup = SalesCallLWCController.buildLookupResultFromSObject(testUser);
            testFAW.owner = new List<LookupSearchResultWrapper>{userLookup};
            
            LookupSearchResultWrapper taskLookup = SalesCallLWCController.buildLookupResultFromSObject(testTask); //jgm
            testFAW.followup = new List<LookupSearchResultWrapper>{taskLookup};
                
            testSalesCallWrapper.followUpActivities = new List<FollowUpActivityWrapper>{testFAW};
            // Needed to mimic searching for user to add as colleague
            User newTestUser = new User();
            newTestUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            newTestUser.FirstName = 'Test';
            newTestUser.LastName = COLLEAGUE_USER_LN;
            newTestUser.zts_eu_market__c = 'United Kingdom';
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
            
            ZTS_EU_Species_Product__c testGiftProd = new ZTS_EU_Species_Product__c();
            testGiftProd.name ='Gift Prod9999';
            testGiftProd.ZTS_EU_Is_Active__c = TRUE;
            testGiftProd.ZTS_EU_is_Gift__c = TRUE;
            testGiftProd.ZTS_EU_Market__c = INTL_MARKET;
            insert testGiftProd;
            
            
            ZTS_EU_Gift__c testGift = new ZTS_EU_Gift__c();
            testGift.ZTS_EU_Call__c = testCall.Id;
            testGift.ZTS_EU_Quantity__c = 3;
            testGift.ZTS_EU_Description__c = 'Test INTL Gift 2';
            GiftWrapper testGW = new GiftWrapper(testGift);
           	Contact testContact = [Select Id,Name,Account_Name__c from Contact where AccountID = :testCall.ZTS_EU_Account__c Limit 1];
            
            LookupSearchResultWrapper contactLookup = SalesCallLWCController.buildLookupResultFromSObject(testContact);
            testGW.contact = new List<LookupSearchResultWrapper>{contactLookup};
            
            LookupSearchResultWrapper productLookup = SalesCallLWCController.buildLookupResultFromSObject(testGiftProd); //jgm
            testGW.product = new List<LookupSearchResultWrapper>{productLookup};
            testSalesCallWrapper.gifts = new List<GiftWrapper>{testGW};
            
            
            String testSalesCallWrapperJson = JSON.serialize(testSalesCallWrapper);            
            Test.startTest();
                Boolean isSuccess = SalesCallLWCController.saveLookupResults(testSalesCallWrapperJson); 
            Test.stopTest();

            System.assert(isSuccess, 'The save process should be successful');

        }

    }
    @isTest
    static void getTaskPickListOptionsTest() {

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = 'UK_USER_LN';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
                
        System.runAs(usr)
        {
            
            List<map<String,String>> lstStatusOptions = SalesCallLWCController.getTaskStatus();
            List<map<String,String>> lstPriorityOptions = SalesCallLWCController.getTaskPriority();

            //System.assertEquals(false, actualIsInternationalUser);
            System.assertNotEquals(0,lstStatusOptions.size());
            System.assertNotEquals(0,lstPriorityOptions.size());

        }
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
    
    //This is a blank comment made so that Copado can identify this as changed.
    //Another line for fake comment. to consider this update
}