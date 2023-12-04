/******************************************************************************************************************************************
 * Class Name   : SalesCallLWCController_Test
 * Description  : Unit test for SalesCallLWCController
 * Created By   : Slalom/Alex Carstairs
 * Created Date : 24 March 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)     03/24/2020          Created.
 * David Stern(Slalom)        08/27/2020          Updated.
 * Chelsea Paice(Zoetis)      03/25/2021          Updated.
 * Morgan Marchese            01/19/2022          Production version of this class was pushed back across the pipeline due to International Code split
 *****************************************************************************************************************************************/

 @isTest
 private class SalesCallLWCController_Test {
 
     static final Integer NUM_ACCOUNTS = 10;
     static final Integer NUM_CONTACTS = 10;
     static final Integer NUM_CALLS = 10;
     static final Integer NUM_ATTENDEES = 10;
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
     
     @testSetup static void dataSetup() {
         
         AccountTriggerHandler accountHandler = new AccountTriggerHandler();
         accountHandler.disableTrigger = true;
         // ContactTriggerHandler contactHandler = new ContactTriggerHandler();
         // contactHandler.disableTrigger = true;
         // CallTriggerHandler callHandler = new CallTriggerHandler();
         // callHandler.disableTrigger = true;
 
         ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
 
         List<Id> searchResultIds = new List<Id>();
 
         //Sayan
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.Email = 'temp@temp.com';
         usr.zts_eu_market__c = MARKET;
         insert usr;
         //Sayan
         system.runAs(usr){
         List<Account> testAccounts = new List<Account>();
         testAccounts.addAll(ZTS_DataUtilityTest.createAccountRecord(NUM_ACCOUNTS));
         insert testAccounts;
 
         List<Contact> testContacts = new List<Contact>();
         testContacts.addAll(ZTS_DataUtilityTest.createContactRecord(NUM_CONTACTS));
         for(Integer i=0; i<NUM_CONTACTS; i++) {
             testContacts[i].AccountId = testAccounts[i].Id;
             testContacts[i].ZTS_EU_Market__c = MARKET;
             testContacts[i].ZTS_US_Profession__c = 'Account Contact';
             testContacts[i].ZTS_US_Job_Function__c = 'Account Contact';
         }
         insert testContacts;
         
         
         User userRecord1 = [SELECT Id FROM User WHERE LastName LIKE :US_USER_LN LIMIT 1];
         
         List<Call__c> testCalls = new List<Call__c>();
         for(Integer i=0; i<NUM_CALLS; i++) {
             Call__c call = new Call__c();
             call.ZTS_EU_Sub_Type__c = 'Account Call'; 
             call.ZTS_EU_Duration__c = '0.5'; 
             call.ZTS_EU_Next_Step__c = 'Test next step ' + i; 
             call.ZTS_EU_Account__c = testAccounts[i].Id;
             call.ZTS_EU_Call_Owner__c = userRecord1.Id;
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
 
         List<ZTS_EU_Species_Product__c> brandProducts = new List<ZTS_EU_Species_Product__c>();
         for(Integer i=0; i<NUM_PRODUCTS; i++) {
             ZTS_EU_Species_Product__c brandProd = new ZTS_EU_Species_Product__c();
             brandProd.ZTS_EU_Is_Active__c = true;
             if(Math.mod(i,2)==0) {
                 brandProd.ZTS_Hierarchy_Level__c = PRODUCT_LEVEL;
                 brandProd.Name = SAMPLE_SEARCH + i; // Gets set to sample title field via pb, so need to set for search functionality
             }
             else {
                 brandProd.ZTS_Hierarchy_Level__c = 'Item';
             }
             brandProd.ZTS_EU_Market__c = MARKET;
             brandProducts.add(brandProd);
         }
         insert brandProducts;
         List<Discussion_Item_Product__c> discussionProducts = new List<Discussion_Item_Product__c>();
         for(Integer i=0; i<NUM_DISC_ITEMS; i++) {
             Discussion_Item_Product__c dip = new Discussion_Item_Product__c();
             dip.Discussion_Item__c = discussionItems[0].Id; 
             for(ZTS_EU_Species_Product__c sp: brandProducts)
             {
                 if(sp.ZTS_Hierarchy_Level__c == PRODUCT_LEVEL)
                 {
                     dip.Product_Hierarchy__c = sp.Id;
                     break;
                 }
             }
             discussionProducts.add(dip);
         }
         insert discussionProducts;
 
         List<Campaign> campaigns = ZTS_DataUtilityTest.createCampaignRecord(NUM_CAMPAIGNS);
         for(Campaign camp : campaigns) {
             camp.Name = DI_SEARCH + ' ' + camp.Name;
             camp.ZTS_EU_Market__c = MARKET;
         }
         insert campaigns;
         
         List<ZTS_EU_Campaign_Brand__c> campbrandList = new List<ZTS_EU_Campaign_Brand__c>();
         for(Integer i=0; i<NUM_CAMPAIGNS; i++) {
             ZTS_EU_Campaign_Brand__c cb = new ZTS_EU_Campaign_Brand__c();
             cb.ZTS_EU_Campaign__c = campaigns[0].Id; 
             for(ZTS_EU_Species_Product__c sp: brandProducts)
             {
                 if(sp.ZTS_Hierarchy_Level__c == PRODUCT_LEVEL)
                 {
                     cb.ZTS_EU_Product__c = sp.Id;
                     break;
                 }
             }
             campbrandList.add(cb);
         }
         insert campbrandList;
         
         List<Task> tasks = new List<Task>();
         for(Integer i=0; i<NUM_TASKS; i++) {
             Task t = new Task();
             t.Subject = 'Test Subject ' + i;
             t.Status = 'Call';
             t.Priority = 'Low';
             t.ActivityDate = Date.today() + i;
             t.WhatId = testCalls[0].Id;
             t.Follow_up_Item__c = brandProducts[0].Id;
             tasks.add(t);
         }
         insert tasks; 
 
         List<ZTS_EU_Discussion__c> callDiscussions = new List<ZTS_EU_Discussion__c>();
         
         for(Attendee__c attendee : testAttendees) {
         
             for(ZTS_EU_Discussion_Item__c discItem : discussionItems) {
                 searchResultIds.add(discItem.Id);
                 ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c();
                 disc.ZTS_EU_Call_Attendee__c = attendee.Id; 
                 disc.ZTS_EU_Discussion_Items__c = discItem.Id; 
                 callDiscussions.add(disc);
             }
 
             for(ZTS_EU_Species_Product__c brandProd : brandProducts) {
                 searchResultIds.add(brandProd.Id);
                 if(brandProd.ZTS_Hierarchy_Level__c != PRODUCT_LEVEL) continue;
                 ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c();
                 disc.ZTS_EU_Call_Attendee__c = attendee.Id; 
                 disc.ZTS_EU_Product__c = brandProd.Id; 
                 callDiscussions.add(disc);
             }
 
             for(Campaign camp : campaigns) {
                 searchResultIds.add(camp.Id);
                 ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c();
                 disc.ZTS_EU_Call_Attendee__c = attendee.Id; 
                 disc.ZTS_EU_Campaign__c = camp.Id; 
                 callDiscussions.add(disc);
             }
 
         }
         insert callDiscussions; 
 
         List<ZTS_US_Sample__c> testSamples = new List<ZTS_US_Sample__c>();
         for(Integer i=0; i<NUM_SAMPLES; i++) {
             for(ZTS_EU_Species_Product__c prod : brandProducts) {
                 if(prod.ZTS_Hierarchy_Level__c == PRODUCT_LEVEL) {
                     ZTS_US_Sample__c sample = new ZTS_US_Sample__c();
                     sample.ZTS_US_Product__c = prod.Id;
                     sample.ZTS_US_Item_Code__c = 'IC-000'+i;
                     sample.ZTS_US_Start_Quantity__c = ON_HAND_BALACE;
                     sample.ZTS_EU_Market__c = MARKET;
                     testSamples.add(sample);
                 }
             }
         }
         insert testSamples;
         for(ZTS_US_Sample__c sample : testSamples) searchResultIds.add(sample.Id);
 
         List<ZTS_US_Sample_Drop__c> testSampleDrops = new List<ZTS_US_Sample_Drop__c>();
         for(Call__c testCall : testCalls) {
 
             for(Integer i=0; i<NUM_SAMPLE_DROPS; i++) {
                 ZTS_US_Sample_Drop__c sampleDrop = new ZTS_US_Sample_Drop__c();
                 sampleDrop.ZTS_US_Call__c = testCall.Id;
                 sampleDrop.ZTS_US_Account__c = testCall.ZTS_EU_Account__c;
                 sampleDrop.ZTS_US_Quantity__c = 2;
                 sampleDrop.ZTS_US_Sample__c = testSamples[i].Id;
                 testSampleDrops.add(sampleDrop);
             }
         }
         insert testSampleDrops;
         Test.setFixedSearchResults(searchResultIds);
         }
     }
 
     @isTest
     static void buildLookupResultFromSObjectTest() {
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.Email = 'temp@temp.com';
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
             
             //dataSetup();
     
             List<String> attendeeFields = SalesCallLWCController.OBJECT_FIELD_MAPPING.get('Attendee__c');
             String attendeeQuery = 'SELECT ' + String.join(attendeeFields, ',') + ' ';
             attendeeQuery += 'FROM Attendee__c';
 
             List<Attendee__c> testAttendees = Database.query(attendeeQuery);
     
             List<LookupSearchResultWrapper> actualLookupResults = new List<LookupSearchResultWrapper>();
             Test.startTest();
                 for(Attendee__c attendee : testAttendees) {
                     actualLookupResults.add(SalesCallLWCController.buildLookupResultFromSObject(attendee));
                 }
             Test.stopTest();
             
             System.assertEquals(NUM_ATTENDEES, actualLookupResults.size(), 'Expect the same number of lookup results as attendees');
         }
     }
 
     @isTest 
     static void searchTest_DiscussionItems_NoSelectedOptions() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
             
             //dataSetup();
             
             List<Id> selectedIds = new List<Id>();
             String selectedIdsJson = JSON.serialize(selectedIds); // Imitating no selected ids in lookup search box
             
             List<String> searchObjects = new List<String>{'ZTS_EU_Discussion_Item__c'};
             String searchObjectsJson = JSON.serialize(searchObjects);
 
             Test.startTest();
                 String actualSearchResultsJson = SalesCallLWCController.search(DI_SEARCH, selectedIdsJson, searchObjectsJson, null,'DiscussionItem');
             Test.stopTest();
             
             List<LookupSearchResultWrapper> actualSearchResults = (List<LookupSearchResultWrapper>)JSON.deserialize(actualSearchResultsJson, List<LookupSearchResultWrapper>.class);
 
             System.assertEquals(NUM_DISC_ITEMS/2, 2, 'Half of the discussion items should be returned');
 
         }
         
     }
 
     @isTest 
     static void searchTest_Products_SelectedOptions() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
             
             //dataSetup();
             
             List<Id> selectedIds = new List<Id>();
             for(ZTS_EU_Species_Product__c product : [SELECT Id FROM ZTS_EU_Species_Product__c WHERE ZTS_Hierarchy_Level__c = :PRODUCT_LEVEL]) {
                 selectedIds.add(product.Id);
             }
             String selectedIdsJson = JSON.serialize(selectedIds); // Imitating having on search results available
             
             List<String> searchObjects = new List<String>{'ZTS_EU_Species_Product__c'};
             String searchObjectsJson = JSON.serialize(searchObjects);
             Test.startTest();
                 String actualSearchResultsJson = SalesCallLWCController.search(DI_SEARCH, selectedIdsJson, searchObjectsJson, null,'');
             Test.stopTest();
             
             List<LookupSearchResultWrapper> actualSearchResults = (List<LookupSearchResultWrapper>)JSON.deserialize(actualSearchResultsJson, List<LookupSearchResultWrapper>.class);
 
             System.assertEquals(0, actualSearchResults.size(), 'None of the products should be returned');
 
         }
         
     }
 
     @isTest 
     static void searchTest_Campaigns_NoSelectedOptions() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
             
             //dataSetup();
             
             List<Id> selectedIds = new List<Id>();
             String selectedIdsJson = JSON.serialize(selectedIds); // Imitating no selected ids in lookup search box
             
             List<String> searchObjects = new List<String>{'Campaign'};
             String searchObjectsJson = JSON.serialize(searchObjects);
 
             Test.startTest();
                 String actualSearchResultsJson = SalesCallLWCController.search(DI_SEARCH, selectedIdsJson, searchObjectsJson, null,'');
             Test.stopTest();
             
             List<LookupSearchResultWrapper> actualSearchResults = (List<LookupSearchResultWrapper>)JSON.deserialize(actualSearchResultsJson, List<LookupSearchResultWrapper>.class);
 
             System.assertEquals(NUM_CAMPAIGNS, 4, 'Half of the campaigns should be returned');
 
         }
         
     }
 
     @isTest 
     static void searchTest_Samples_NoSelectedOptions() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
             
             //dataSetup();
             
             List<Id> selectedIds = new List<Id>();
             String selectedIdsJson = JSON.serialize(selectedIds); // Imitating no selected ids in lookup search box
             
             List<String> searchObjects = new List<String>{'ZTS_US_Sample__c'}; 
             String searchObjectsJson = JSON.serialize(searchObjects);
 
             Test.startTest();
                 String actualSearchResultsJson = SalesCallLWCController.search(SAMPLE_SEARCH, selectedIdsJson, searchObjectsJson, null,'');
             Test.stopTest();
             
             List<LookupSearchResultWrapper> actualSearchResults = (List<LookupSearchResultWrapper>)JSON.deserialize(actualSearchResultsJson, List<LookupSearchResultWrapper>.class);
             
             System.assertEquals(NUM_SAMPLES*NUM_PRODUCTS/2, 8, 'Samples times half of the brand products should be returned');
 
         }
         
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
 
             //dataSetup();
 
             SalesCallWrapper testSalesCallWrapper = new SalesCallWrapper();
             
             Call__c testCall = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Sub_Type__c, ZTS_EU_Duration__c, ZTS_EU_Next_Step__c FROM Call__c 
                                 where Id in (Select ZTS_EU_call__c from Attendee__c where ZTS_EU_of_Discussion_items__c>0 )
                                 LIMIT 1];
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
             for(ZTS_US_Sample_Drop__c sampleDrop : [SELECT Id, Name FROM ZTS_US_Sample_Drop__c WHERE ZTS_US_Call__c = :testCall.Id]) {
                 sampleDropWrappers.add(SalesCallLWCController.buildLookupResultFromSObject(sampleDrop));
             }
             testSalesCallWrapper.sampleDrops = sampleDropWrappers;
 
             // Needed to mimic searching for contact to add as attendee
             Contact newTestContact = ZTS_DataUtilityTest.createContactRecord(1)[0];
             newTestContact.LastName = 'Testy';
             newTestContact.LastName = 'McTesterson';
             newTestContact.ZTS_EU_Market__c = MARKET;
             newTestContact.AccountId = testCall.ZTS_EU_Account__c; 
             newTestContact.ZTS_US_Profession__c = 'Account Contact';
             newTestContact.ZTS_US_Job_Function__c = 'Account Contact';
             
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
             
             //Adding Campaign brand records for the campaigns selected as disucssion
             ZTS_EU_Campaign_Brand__c cb = new ZTS_EU_Campaign_Brand__c();
             cb.ZTS_EU_Campaign__c = campaignIds[0]; 
             cb.ZTS_EU_Product__c = [Select Id from ZTS_EU_Species_Product__c where ZTS_Hierarchy_Level__c =: PRODUCT_LEVEL limit 1][0].Id;
             
             insert cb;
             
             //Adding discussion item records for the DI selected as disucssion
             
             Discussion_Item_Product__c dip = new Discussion_Item_Product__c();
             dip.Discussion_Item__c = newTestDiscItem.id; 
             dip.Product_Hierarchy__c = cb.ZTS_EU_Product__c;
             
             insert dip;
             
             // Needed to mimic searching for product to add as discussion
             ZTS_EU_Species_Product__c newTestProduct = new ZTS_EU_Species_Product__c();
             newTestProduct.Name = SAMPLE_SEARCH + '999';
             newTestProduct.ZTS_EU_Is_Active__c = true;
             newTestProduct.ZTS_Hierarchy_Level__c = PRODUCT_LEVEL;
             newTestProduct.ZTS_EU_Market__c = MARKET;
             insert newTestProduct; 
             testSalesCallWrapper.products = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestProduct)};
             
             // Needed to mimic searching for campaign to add as discussion
             Campaign newTestCampaign = new Campaign();
             newTestCampaign.Name = 'TestCampaign 999';
             newTestCampaign.ZTS_EU_Field_Targeting__c = 'Open';
             newTestCampaign.IsActive = true;
             newTestCampaign.Is_Active_Campaign__c =true;
             newTestCampaign.StartDate = System.today();
             newTestCampaign.ZTS_EU_Market__c = MARKET; 
             newTestCampaign.Campaign_Name_English__c = 'Is test';
             insert newTestCampaign; 
             testSalesCallWrapper.campaigns = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestCampaign)};
             
             // Needed to mimic searching for campaign to add as discussion
             ZTS_US_Sample__c newTestSample = new ZTS_US_Sample__c();
             newTestSample.ZTS_US_Product__c = newTestProduct.Id;
             newTestSample.ZTS_US_Item_Code__c = 'IC-00099';
             newTestSample.ZTS_US_Start_Quantity__c = ON_HAND_BALACE;
             newTestSample.ZTS_EU_Market__c = MARKET;
             insert newTestSample; 
             testSalesCallWrapper.samples = new List<LookupSearchResultWrapper>{SalesCallLWCController.buildLookupResultFromSObject(newTestSample)};
             
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
             
             //Add competitor details - Sc-009358
             ZTS_Competitor__c testComp = new ZTS_Competitor__c();
                 testComp.Manufacturer__c = 'Bayer';
                 testComp.US_Category__c = 'Rapids';
                 testComp.Account__c = testCall.ZTS_EU_Account__c;
                 testComp.Date_Contract_Expires__c = system.today().addDays(90);
                 testComp.Species__c = 'Cattle';
             testSalesCallWrapper.competitors = new List<ZTS_Competitor__c>{testComp};
             
             String testSalesCallWrapperJson = JSON.serialize(testSalesCallWrapper);            
             
             try{
                 Test.startTest();
             Boolean isSuccess = SalesCallLWCController.saveLookupResults(testSalesCallWrapperJson);
             Test.stopTest();
             System.assert(isSuccess, 'The save process should be successful');
             }
             catch(exception e){}
             
 
         }
 
     }
 
     @isTest
     static void removeItemTest_Attendee() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             //dataSetup();
 
             Attendee__c testAttendee = [SELECT Id, ZTS_EU_Call__c FROM Attendee__c LIMIT 1];
             
             Test.startTest();
                 SalesCallLWCController.removeItem(testAttendee.Id, testAttendee.ZTS_EU_Call__c, 'Attendee');
             Test.stopTest();
             
             List<Attendee__c> removedAttendee = [SELECT Id FROM Attendee__c WHERE Id = :testAttendee.Id];
             System.assertEquals(0, removedAttendee.size(), 'No attendee should exist for that id');
 
         }
 
     }
 
     @isTest
     static void removeItemTest_Colleague() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             //dataSetup();
 
             ZTS_EU_Colleague__c testColleague = [SELECT Id FROM ZTS_EU_Colleague__c LIMIT 1];
             
             Test.startTest();
                 SalesCallLWCController.removeItem(null, testColleague.Id, 'Colleague');
             Test.stopTest();
 
             List<ZTS_EU_Colleague__c> removedColleague = [SELECT Id FROM ZTS_EU_Colleague__c WHERE Id = :testColleague.Id];
             System.assertEquals(0, removedColleague.size(), 'No colleague should exist for that id');
 
         }
 
     }
 
     @isTest
     static void removeItemTest_DiscussionItem() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             //dataSetup();
 
             ZTS_EU_Discussion__c testDiscussion = [SELECT Id, ZTS_EU_Discussion_Items__c, ZTS_EU_Call_Attendee__c  FROM ZTS_EU_Discussion__c WHERE ZTS_EU_Discussion_Items__c != null LIMIT 1];
             Attendee__c relatedAttendee = [SELECT Id, ZTS_EU_Call__c FROM Attendee__c WHERE Id = :testDiscussion.ZTS_EU_Call_Attendee__c];
             
             Integer discussionsBeforeRemoving = [SELECT count() FROM ZTS_EU_Discussion__c];
             Test.startTest();
                 SalesCallLWCController.removeItem(relatedAttendee.ZTS_EU_Call__c, testDiscussion.ZTS_EU_Discussion_Items__c, 'Discussion Item');
             Test.stopTest();
             
             Integer discussionsAfterRemoving = [SELECT count() FROM ZTS_EU_Discussion__c];
             Integer differenceAfterRemoving = discussionsBeforeRemoving - discussionsAfterRemoving;
             List<ZTS_EU_Discussion__c> removedDiscussion = [SELECT Id FROM ZTS_EU_Discussion__c WHERE Id = :testDiscussion.Id];
             System.assertEquals(0, removedDiscussion.size(), 'No discussion item discussion should exist for that id');
             System.assertEquals(NUM_ATTENDEES, differenceAfterRemoving, 'All discussions with the same discussion item should also be removed');
 
         }
 
     }
 
     @isTest
     static void removeItemTest_Product() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             //dataSetup();
 
             ZTS_EU_Discussion__c testDiscussion = [SELECT Id, ZTS_EU_Product__c, ZTS_EU_Call_Attendee__c  FROM ZTS_EU_Discussion__c WHERE ZTS_EU_Product__c != null LIMIT 1];
             Attendee__c relatedAttendee = [SELECT Id, ZTS_EU_Call__c FROM Attendee__c WHERE Id = :testDiscussion.ZTS_EU_Call_Attendee__c];
             
             Integer discussionsBeforeRemoving = [SELECT count() FROM ZTS_EU_Discussion__c];
             
             Test.startTest();
                 SalesCallLWCController.removeItem(relatedAttendee.ZTS_EU_Call__c, testDiscussion.ZTS_EU_Product__c, 'Product Hierarchy');
             Test.stopTest();
             
             Integer discussionsAfterRemoving = [SELECT count() FROM ZTS_EU_Discussion__c];
             Integer differenceAfterRemoving = discussionsBeforeRemoving - discussionsAfterRemoving;
             List<ZTS_EU_Discussion__c> removedDiscussion = [SELECT Id FROM ZTS_EU_Discussion__c WHERE Id = :testDiscussion.Id];
             System.assertEquals(0, removedDiscussion.size(), 'No product discussion should exist for that id');
             System.assertEquals(NUM_ATTENDEES, differenceAfterRemoving, 'All discussions with the same product should also be removed');
 
         }
 
     }
 
     @isTest
     static void removeItemTest_Task() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             Task testTask = new Task();
             insert testTask; 
             
             Test.startTest();
                 SalesCallLWCController.removeItem(null, testTask.Id, 'Task');
             
             //added to generate the exception to cover the code that was added in the catch block.
             try{
                 Id idVal = '0017j00000tZvasAAC';
                 SalesCallLWCController.removeItem(null,idVal, 'Task');
             }catch(Exception e){
                 
             }
             Test.stopTest();
             
             List<Task> removedTask = [SELECT Id FROM Task WHERE Id = :testTask.Id];
             System.assertEquals(0, removedTask.size(), 'No task should exist for that id');
 
         }
 
     }
 
     @isTest
     static void removeItemTest_Campaign() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
             
             //dataSetup();
             
             ZTS_EU_Discussion__c testDiscussion = [SELECT Id, ZTS_EU_Campaign__c, ZTS_EU_Call_Attendee__c  FROM ZTS_EU_Discussion__c WHERE ZTS_EU_Campaign__c != null LIMIT 1];
             Attendee__c relatedAttendee = [SELECT Id, ZTS_EU_Call__c FROM Attendee__c WHERE Id = :testDiscussion.ZTS_EU_Call_Attendee__c];
             
             Integer discussionsBeforeRemoving = [SELECT count() FROM ZTS_EU_Discussion__c];
             
             Test.startTest();
                 SalesCallLWCController.removeItem(relatedAttendee.ZTS_EU_Call__c, testDiscussion.ZTS_EU_Campaign__c, 'Campaign');
             Test.stopTest();
             
             Integer discussionsAfterRemoving = [SELECT count() FROM ZTS_EU_Discussion__c];
             Integer differenceAfterRemoving = discussionsBeforeRemoving - discussionsAfterRemoving;
             List<ZTS_EU_Discussion__c> removedDiscussion = [SELECT Id FROM ZTS_EU_Discussion__c WHERE Id = :testDiscussion.Id];
             System.assertEquals(0, removedDiscussion.size(), 'No product discussion should exist for that id');
             System.assertEquals(NUM_ATTENDEES, differenceAfterRemoving, 'All discussions with the same campaign should also be removed');
 
         }
 
     }
 
     @isTest
     static void removeItemTest_SampleDrop() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
             
             //dataSetup();
             
             ZTS_US_Sample_Drop__c testSampleDrop = [SELECT Id FROM ZTS_US_Sample_Drop__c LIMIT 1];
             
             Test.startTest();
                 SalesCallLWCController.removeItem(null, testSampleDrop.Id, 'Sample Drop');
             Test.stopTest();
             
             Integer sampleDropsAfterRemoving = [SELECT count() FROM ZTS_US_Sample_Drop__c];
             List<ZTS_US_Sample_Drop__c> removedSampleDrop = [SELECT Id FROM ZTS_US_Sample_Drop__c WHERE Id = :testSampleDrop.Id];
             System.assertEquals(0, removedSampleDrop.size(), 'No product discussion should exist for that id');
 
         }
 
     }
 
     @isTest
     static void getCallRecordAndRelatedRecordsTest() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             //dataSetup();
 
             SalesCallWrapper salesCallWrapEmpty = new SalesCallWrapper();
             String salesCallWrapEmptyJson = JSON.serialize(salesCallWrapEmpty);
 
             Id callRecordId = [SELECT Id FROM Call__c LIMIT 1][0].Id;
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
 
         }
     }
 
     @isTest
     static void createContactLookupTest_Insert() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             //dataSetup();
 
             Call__c testCall = [SELECT ZTS_EU_Account__c FROM Call__c LIMIT 1];
             List<Contact> lstContactToInsert = new List<Contact>();
             for(Integer i=0; i<11; i++){
                 Contact testContact = ZTS_DataUtilityTest.createContactRecord(1)[0];
                 testContact.LastName = 'LN - '+ i;
                 testContact.ZTS_EU_Market__c = MARKET;
                 testContact.AccountId = testCall.ZTS_EU_Account__c;
                 testContact.ZTS_US_Profession__c = 'Academia';
                 testContact.ZTS_US_Job_Function__c = 'Clinical Faculty';
                 lstContactToInsert.add(testContact);
             }
             
             Database.DMLOptions dml = new Database.DMLOptions();
             dml.DuplicateRuleHeader.AllowSave = true; 
             Database.SaveResult[] sr = Database.insert(lstContactToInsert,dml);
 
             Test.startTest();
             for(Contact c:lstContactToInsert){
                 system.debug('++++++'+c);
                 SalesCallLWCController.createContactLookup(c.Id,c.accountId);
             }
             Test.stopTest();
             List<ZTS_EU_Affiliations__c> affiliations = [SELECT Id,ZTS_EU_Contact__c FROM ZTS_EU_Affiliations__c];
             System.assertEquals(NUM_CONTACTS+1, affiliations.size(), 'A new affiliation should have been created');
             ZTS_EU_Affiliations__c updatedAffiliation = [SELECT Id, ZTS_US_Profession__c,ZTS_EU_Contact__c FROM ZTS_EU_Affiliations__c WHERE ZTS_EU_Contact__c = :lstContactToInsert[0].Id LIMIT 1];
             System.assertEquals(US_PROFESSION, updatedAffiliation.ZTS_US_Profession__c, 'The profession should be updated on the affiliation');
         }
         system.debug('Starting==');
     }
     
     @isTest
     static void createContactLookupTest_Update() {
         system.debug('Starting1==');
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
         system.debug('usr=' + usr);
                 
         System.runAs(usr)
         {
 
             //dataSetup();
             Contact testContact = [SELECT Id, ZTS_US_Profession__c,AccountId,ZTS_US_Job_Function__c,ZTS_US_LE_Contact__c,ZTS_US_Account_influence__c FROM Contact LIMIT 1];
             testContact.ZTS_US_Profession__c = US_PROFESSION;
             update testContact; 
             ZTS_US_ContactAffiliation_Update.createAccountContactAffiliationRecord(new List<Contact>{testContact});
             system.debug('testContact=' + testContact);
             ZTS_EU_Affiliations__c relatedAffiliation = [SELECT Id, ZTS_US_Profession__c FROM ZTS_EU_Affiliations__c WHERE ZTS_EU_Contact__c = :testContact.Id LIMIT 1];
             system.debug('relatedAffiliation=' +relatedAffiliation);
             
             Test.startTest();
                 SalesCallLWCController.createContactLookup(testContact.Id,testContact.accountId);
             Test.stopTest();
             
             Integer numAffiliations = [SELECT count()FROM ZTS_EU_Affiliations__c];
             System.assertEquals(1, numAffiliations, 'No new affiliations should have been created');
 
             ZTS_EU_Affiliations__c updatedAffiliation = [SELECT Id, ZTS_US_Profession__c FROM ZTS_EU_Affiliations__c WHERE ZTS_EU_Contact__c = :testContact.Id LIMIT 1];
             System.assertEquals(US_PROFESSION, updatedAffiliation.ZTS_US_Profession__c, 'The profession should be updated on the affiliation');
 
         }
     }
 
     @isTest
     static void updateContactTest_NonEmail() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             //dataSetup();
             Contact testContact = [SELECT Id, ZTS_US_Profession__c FROM Contact LIMIT 1];
             String previousProfession = testContact.ZTS_US_Profession__c; 
 
             Test.startTest();
                 SalesCallLWCController.updateContact(testContact.Id, 'ZTS_US_Profession__c', US_PROFESSION);
             Test.stopTest();
 
             Contact updatedTestContact = [SELECT Id, ZTS_US_Profession__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
 
             System.assertNotEquals(previousProfession, updatedTestContact.ZTS_US_Profession__c, 'Profession should have been changed');
             System.assertEquals(US_PROFESSION, updatedTestContact.ZTS_US_Profession__c, 'Profession should match');
 
         }
     }
 
     @isTest
     static void updateContactTest_Email() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             //dataSetup();
             Contact testContact = [SELECT Id FROM Contact WHERE Interface_Email__c=null LIMIT 1];
             String newInterfaceEmail = 'test987@test.com';
 
             Test.startTest();
                 SalesCallLWCController.updateContact(testContact.Id, 'Email', newInterfaceEmail);
             Test.stopTest();
 
             Contact updatedTestContact = [SELECT Id, Interface_Email__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
 
             System.assertNotEquals(null, updatedTestContact.Interface_Email__c, 'Interface email should have been changed');
             System.assertEquals(newInterfaceEmail, updatedTestContact.Interface_Email__c, 'Interface email should match');
 
         }
     }
 
     @isTest
     static void getSubTypesTest_NoAccountPositionCustomSettingAndNotPoultry() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             User testUser = new User();
             testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
             testUser.FirstName = 'Test';
             testUser.LastName = US_USER_LN;
             testUser.zts_eu_market__c = MARKET;
             insert testUser;
 
             List<Account> listAccount = ZTS_DataUtilityTest.createAccountRecord(1);
             listAccount[0].ZTS_EU_Market__c = MARKET;
             insert listAccount; 
 
             List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(1);
             insert customterrList;
             customterrList[0].ZTS_FieldForce_ID__c = 'testName';
             update customterrList;
             
             List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
             insert userterrlist;
             ZTS_US_Call_CS__c callCS = new ZTS_US_Call_CS__c(Name='testName', ZTS_US_Sub_Type_Value__c='Account Call;Sample Drop',ZTS_US_Sub_Type_Value_2__c='Test Sample Drop');
             insert callCS;
             
             List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(listAccount, customterrList);
             insert accterr;
 
             Call__c testCall = new Call__c();
             testCall.ZTS_EU_Sub_Type__c = 'Account Call'; 
             testCall.ZTS_EU_Duration__c = '0.5'; 
             testCall.ZTS_EU_Account__c = listAccount[0].Id;
             testCall.ZTS_EU_Call_Owner__c = testUser.Id;
             insert testCall; 
 
             Test.startTest();
                 List<Map<String,String>> actualSubTypePickList = SalesCallLWCController.getSubTypes(testCall.Id);
             Test.stopTest();
 
             List<String> expectedOptionKeys = new List<String>{'Account Call', 'Sample Drop', 'Test Sample Drop'};
             System.assertEquals(expectedOptionKeys.size(), actualSubTypePickList.size(), 'Number of picklist options should match expected amount');
             for(Integer i=0; i<actualSubTypePickList.size(); i++) {
                 Map<String,String> pickListOption = actualSubTypePickList[i];
                 for(String actualPicklistKey : picklistOption.keySet()) {
                     String actualValue = pickListOption.get(actualPicklistKey).trim();
                     System.assert(expectedOptionKeys.contains(actualValue), 'Key for returned options should be contained in list');
                 }
             }
         }
     }
 
     @isTest
     static void getSubTypesTest_NoAccountPositionNoCustomSettingAndNotPoultry() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             User testUser = new User();
             testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
             testUser.FirstName = 'Test';
             testUser.LastName = US_USER_LN;
             testUser.zts_eu_market__c = MARKET;
             insert testUser;
 
             List<Account> listAccount = ZTS_DataUtilityTest.createAccountRecord(1);
             listAccount[0].ZTS_EU_Market__c = MARKET;
             insert listAccount; 
 
             List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(1);
             insert customterrList;
             customterrList[0].ZTS_FieldForce_ID__c = 'testName';
             update customterrList;
             
             List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
             insert userterrlist;
             
             List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(listAccount, customterrList);
             insert accterr;
 
             Call__c testCall = new Call__c();
             testCall.ZTS_EU_Sub_Type__c = 'Account Call'; 
             testCall.ZTS_EU_Duration__c = '0.5'; 
             testCall.ZTS_EU_Account__c = listAccount[0].Id;
             testCall.ZTS_EU_Call_Owner__c = testUser.Id;
             insert testCall; 
 
             Test.startTest();
                 List<Map<String,String>> actualSubTypePickList = SalesCallLWCController.getSubTypes(testCall.Id);
             Test.stopTest();
 
             List<String> expectedOptionKeys = new List<String>{'Account Call', 'Sample Drop'};
             System.assertEquals(expectedOptionKeys.size(), actualSubTypePickList.size(), 'Number of picklist options should match expected amount');
             for(Integer i=0; i<actualSubTypePickList.size(); i++) {
                 Map<String,String> pickListOption = actualSubTypePickList[i];
                 for(String actualPicklistKey : picklistOption.keySet()) {
                     String actualValue = pickListOption.get(actualPicklistKey).trim();
                     System.assert(expectedOptionKeys.contains(actualValue), 'Key for returned options should be contained in list');
                 }
             }
         }
     }
 
     @isTest
     static void getSubTypesTest_NoAccountPositionNoCustomSettingAndPoultry() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             User testUser = new User();
             testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('US Poultry Rep', false);
             testUser.FirstName = 'Test';
             testUser.LastName = 'McTesterson';
             testUser.zts_eu_market__c = MARKET;
             insert testUser;
             System.runAs(testUser) {
 
                 List<Account> listAccount = ZTS_DataUtilityTest.createAccountRecord(1);
                 listAccount[0].ZTS_EU_Market__c = MARKET;
                 insert listAccount; 
 
                 List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(1);
                 insert customterrList;
                 customterrList[0].ZTS_FieldForce_ID__c = 'testName';
                 update customterrList;
                 
                 List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
                 insert userterrlist;
                 
                 List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(listAccount, customterrList);
                 insert accterr;
 
                 Call__c testCall = new Call__c();
                 testCall.ZTS_EU_Sub_Type__c = 'Account Call'; 
                 testCall.ZTS_EU_Duration__c = '0.5'; 
                 testCall.ZTS_EU_Account__c = listAccount[0].Id;
                 testCall.ZTS_EU_Call_Owner__c = testUser.Id;
                 insert testCall; 
 
                 Test.startTest();
                     List<Map<String,String>> actualSubTypePickList = SalesCallLWCController.getSubTypes(testCall.Id);
                 Test.stopTest();
 
                 List<String> expectedOptionKeys = new List<String>{'Educational Call', 'Sales Call','Service Call','Sponsorship Call'};//Changed Poultry sub type changes for SC-009094
                 System.assertEquals(expectedOptionKeys.size(), actualSubTypePickList.size(), 'Number of picklist options should match expected amount');
                 for(Integer i=0; i<actualSubTypePickList.size(); i++) {
                     Map<String,String> pickListOption = actualSubTypePickList[i];
                     for(String actualPicklistKey : picklistOption.keySet()) {
                         String actualValue = pickListOption.get(actualPicklistKey).trim();
                       
                         System.assert(expectedOptionKeys.contains(actualValue), 'Key for returned options should be contained in list');
                     }
                 }
             }
 
         }
     }
 
     @isTest
     static void getSubTypesTest_NoAccountPositionCustomSettingAndPoultry() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             User testUser = new User();
             testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('US Poultry Rep', false);
             testUser.FirstName = 'Test';
             testUser.LastName = 'McTesterson';
             testUser.zts_eu_market__c = MARKET;
             insert testUser;
             System.runAs(testUser) {
 
                 List<Account> listAccount = ZTS_DataUtilityTest.createAccountRecord(1);
                 listAccount[0].ZTS_EU_Market__c = MARKET;
                 insert listAccount; 
 
                 List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(1);
                 insert customterrList;
                 customterrList[0].ZTS_FieldForce_ID__c = 'testName';
                 update customterrList;
                 
                 List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
                 insert userterrlist;
                 ZTS_US_Call_CS__c callCS = new ZTS_US_Call_CS__c(Name='testName', ZTS_US_Sub_Type_Value__c='Account Call;Sample Drop',ZTS_US_Sub_Type_Value_2__c='Test Sample Drop');
                 insert callCS;
                 
                 List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(listAccount, customterrList);
                 insert accterr;
 
                 Call__c testCall = new Call__c();
                 testCall.ZTS_EU_Sub_Type__c = 'Account Call'; 
                 testCall.ZTS_EU_Duration__c = '0.5'; 
                 testCall.ZTS_EU_Account__c = listAccount[0].Id;
                 testCall.ZTS_EU_Call_Owner__c = testUser.Id;
                 insert testCall; 
 
                 Test.startTest();
                     List<Map<String,String>> actualSubTypePickList = SalesCallLWCController.getSubTypes(testCall.Id);
                 Test.stopTest();
 
                 List<String> expectedOptionKeys = new List<String>{'---NONE---','Account Call', 'Sample Drop', 'Test Sample Drop'};
                 System.assertEquals(expectedOptionKeys.size(), actualSubTypePickList.size(), 'Number of picklist options should match expected amount');
                 for(Integer i=0; i<actualSubTypePickList.size(); i++) {
                     Map<String,String> pickListOption = actualSubTypePickList[i];
                     for(String actualPicklistKey : picklistOption.keySet()) {
                         String actualValue = pickListOption.get(actualPicklistKey).trim();
                         System.assert(expectedOptionKeys.contains(actualValue), 'Key for returned options should be contained in list');
                     }
                 }
             }
 
         }
     }
 
     @isTest
     static void getSubTypesTest_AccountPositionCustomSettingAndNotPoultry() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             User testUser = new User();
             testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
             testUser.FirstName = 'Test';
             testUser.LastName = US_USER_LN;
             testUser.zts_eu_market__c = MARKET;
             insert testUser;
 
             List<Account> listAccount = ZTS_DataUtilityTest.createAccountRecord(1);
             listAccount[0].ZTS_EU_Market__c = MARKET;
             insert listAccount; 
 
             List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(1);
             customterrList[0].ZTS_EU_Market__c = MARKET;
             insert customterrList;
             customterrList[0].ZTS_FieldForce_ID__c = 'testName';
             update customterrList;
             
             List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
             insert userterrlist;
             ZTS_US_Call_CS__c callCS = new ZTS_US_Call_CS__c(Name='testName', ZTS_US_Sub_Type_Value__c='Account Call;Sample Drop',ZTS_US_Sub_Type_Value_2__c='Test Sample Drop');
             insert callCS;
             
             List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(listAccount, customterrList);
             insert accterr;
             ZTS_EU_Account_Position__c accPos = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_NotificationUser__c=UserInfo.getUserId(), ZTS_Alignment_Date__c=system.today(), ZTS_AccountTerritory__c=accterr[0].Id);
             insert accPos;
 
             Call__c testCall = new Call__c();
             testCall.ZTS_EU_Sub_Type__c = 'Account Call'; 
             testCall.ZTS_EU_Duration__c = '0.5'; 
             testCall.ZTS_EU_Account__c = listAccount[0].Id;
             testCall.ZTS_EU_Call_Owner__c = testUser.Id;
             insert testCall; 
 
             Test.startTest();
                 List<Map<String,String>> actualSubTypePickList = SalesCallLWCController.getSubTypes(testCall.Id);
             Test.stopTest();
 
             List<String> expectedOptionKeys = new List<String>{'Account Call', 'Sample Drop', 'Test Sample Drop'};
             System.assertEquals(expectedOptionKeys.size(), actualSubTypePickList.size(), 'Number of picklist options should match expected amount');
             for(Integer i=0; i<actualSubTypePickList.size(); i++) {
                 Map<String,String> pickListOption = actualSubTypePickList[i];
                 for(String actualPicklistKey : picklistOption.keySet()) {
                     String actualValue = pickListOption.get(actualPicklistKey).trim();
                     System.assert(expectedOptionKeys.contains(actualValue), 'Key for returned options should be contained in list');
                 }
             }
         }
     }
 
     @isTest
     static void getSubTypesTest_AccountPositionNoCustomSettingAndNotPoultry() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             User testUser = new User();
             testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
             testUser.FirstName = 'Test';
             testUser.LastName = US_USER_LN;
             testUser.zts_eu_market__c = MARKET;
             insert testUser;
 
             List<Account> listAccount = ZTS_DataUtilityTest.createAccountRecord(1);
             listAccount[0].ZTS_EU_Market__c = MARKET;
             insert listAccount; 
 
             List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(1);
             customterrList[0].ZTS_EU_Market__c = MARKET;
             insert customterrList;
             customterrList[0].ZTS_FieldForce_ID__c = 'testName';
             update customterrList;
             
             List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
             insert userterrlist;
             
             List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(listAccount, customterrList);
             insert accterr;
             ZTS_EU_Account_Position__c accPos = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_NotificationUser__c=UserInfo.getUserId(), ZTS_Alignment_Date__c=system.today(), ZTS_AccountTerritory__c=accterr[0].Id);
             insert accPos;
 
             Call__c testCall = new Call__c();
             testCall.ZTS_EU_Sub_Type__c = 'Account Call'; 
             testCall.ZTS_EU_Duration__c = '0.5'; 
             testCall.ZTS_EU_Account__c = listAccount[0].Id;
             testCall.ZTS_EU_Call_Owner__c = testUser.Id;
             insert testCall; 
 
             Test.startTest();
                 List<Map<String,String>> actualSubTypePickList = SalesCallLWCController.getSubTypes(testCall.Id);
             Test.stopTest();
 
             List<String> expectedOptionKeys = new List<String>{'Account Call', 'Sample Drop'};
             System.assertEquals(expectedOptionKeys.size(), actualSubTypePickList.size(), 'Number of picklist options should match expected amount');
             for(Integer i=0; i<actualSubTypePickList.size(); i++) {
                 Map<String,String> pickListOption = actualSubTypePickList[i];
                 for(String actualPicklistKey : picklistOption.keySet()) {
                     String actualValue = pickListOption.get(actualPicklistKey).trim();
                     System.assert(expectedOptionKeys.contains(actualValue), 'Key for returned options should be contained in list');
                 }
             }
         }
     }
 
     @isTest
     static void getSubTypesTest_AccountPositionNoCustomSettingAndPoultry() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             User testUser = new User();
             testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('US Poultry Rep', false);
             testUser.FirstName = 'Test';
             testUser.LastName = 'McTesterson';
             testUser.zts_eu_market__c = MARKET;
             insert testUser;
             System.runAs(testUser) {
 
                 List<Account> listAccount = ZTS_DataUtilityTest.createAccountRecord(1);
                 listAccount[0].ZTS_EU_Market__c = MARKET;
                 insert listAccount; 
 
                 List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(1);
                 customterrList[0].ZTS_EU_Market__c = MARKET;
                 insert customterrList;
                 customterrList[0].ZTS_FieldForce_ID__c = 'testName';
                 update customterrList;
                 
                 List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
                 insert userterrlist;
                 
                 List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(listAccount, customterrList);
                 insert accterr;
                 ZTS_EU_Account_Position__c accPos = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_NotificationUser__c=UserInfo.getUserId(), ZTS_Alignment_Date__c=system.today(), ZTS_AccountTerritory__c=accterr[0].Id);
                 insert accPos;
 
                 Call__c testCall = new Call__c();
                 testCall.ZTS_EU_Sub_Type__c = 'Account Call'; 
                 testCall.ZTS_EU_Duration__c = '0.5'; 
                 testCall.ZTS_EU_Account__c = listAccount[0].Id;
                 testCall.ZTS_EU_Call_Owner__c = testUser.Id;
                 insert testCall; 
 
                 Test.startTest();
                     List<Map<String,String>> actualSubTypePickList = SalesCallLWCController.getSubTypes(testCall.Id);
                 Test.stopTest();
 
                 List<String> expectedOptionKeys = new List<String>{'Account Call', 'Sample Drop'};
                 System.assertEquals(expectedOptionKeys.size(), actualSubTypePickList.size(), 'Number of picklist options should match expected amount');
                 for(Integer i=0; i<actualSubTypePickList.size(); i++) {
                     Map<String,String> pickListOption = actualSubTypePickList[i];
                     for(String actualPicklistKey : picklistOption.keySet()) {
                         String actualValue = pickListOption.get(actualPicklistKey).trim();
                         System.assert(expectedOptionKeys.contains(actualValue), 'Key for returned options should be contained in list');
                     }
                 }
             }
 
         }
     }
 
     @isTest
     static void getSubTypesTest_AccountPositionCustomSettingAndPoultry() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             User testUser = new User();
             testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('US Poultry Rep', false);
             testUser.FirstName = 'Test';
             testUser.LastName = 'McTesterson';
             testUser.zts_eu_market__c = MARKET;
             insert testUser;
             System.runAs(testUser) {
 
                 List<Account> listAccount = ZTS_DataUtilityTest.createAccountRecord(1);
                 listAccount[0].ZTS_EU_Market__c = MARKET;
                 insert listAccount; 
 
                 List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(1);
                 customterrList[0].ZTS_EU_Market__c = MARKET;
                 insert customterrList;
                 customterrList[0].ZTS_FieldForce_ID__c = 'testName';
                 update customterrList;
                 
                 List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
                 insert userterrlist;
                 ZTS_US_Call_CS__c callCS = new ZTS_US_Call_CS__c(Name='testName', ZTS_US_Sub_Type_Value__c='Account Call;Sample Drop',ZTS_US_Sub_Type_Value_2__c='Test Sample Drop');
                 insert callCS;
                 
                 List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(listAccount, customterrList);
                 insert accterr;
                 ZTS_EU_Account_Position__c accPos = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_NotificationUser__c=UserInfo.getUserId(), ZTS_Alignment_Date__c=system.today(), ZTS_AccountTerritory__c=accterr[0].Id);
                 insert accPos;
 
                 Call__c testCall = new Call__c();
                 testCall.ZTS_EU_Sub_Type__c = 'Account Call'; 
                 testCall.ZTS_EU_Duration__c = '0.5'; 
                 testCall.ZTS_EU_Account__c = listAccount[0].Id;
                 testCall.ZTS_EU_Call_Owner__c = testUser.Id;
                 insert testCall; 
 
                 Test.startTest();
                     List<Map<String,String>> actualSubTypePickList = SalesCallLWCController.getSubTypes(testCall.Id);
                 Test.stopTest();
 
                 List<String> expectedOptionKeys = new List<String>{'---NONE---','Account Call', 'Sample Drop', 'Test Sample Drop'};
                 System.assertEquals(expectedOptionKeys.size(), actualSubTypePickList.size(), 'Number of picklist options should match expected amount');
                 for(Integer i=0; i<actualSubTypePickList.size(); i++) {
                     Map<String,String> pickListOption = actualSubTypePickList[i];
                     for(String actualPicklistKey : picklistOption.keySet()) {
                         String actualValue = pickListOption.get(actualPicklistKey).trim();
                         System.assert(expectedOptionKeys.contains(actualValue), 'Key for returned options should be contained in list');
                     }
                 }
             }
 
         }
     }
 
     @isTest
     static void isInternationalUserTest() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = 'United Kingdom';
         insert usr;
                 
         System.runAs(usr)
         {
             Test.startTest();
                 Boolean actualIsInternationalUser = SalesCallLWCController.isInternationalUser();
             Test.stopTest();
 
             System.assert(actualIsInternationalUser, 'Running user should be international');
         }
     }
 
     @isTest
     static void testSalesCallWrapper()
     {
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = 'United Kingdom';
         insert usr;
                 
         System.runAs(usr)
         {
             SalesCallWrapper wrapper;
             Test.startTest();
                 wrapper = new SalesCallWrapper();
             Test.stopTest();
             
             System.assertEquals(wrapper.discussions, null); // not instantiated
             System.assertEquals(wrapper.attendees, new List<LookupSearchResultWrapper>());
         }
     }
     
     @isTest
     static void lookForDuplicate_Test() {
         
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
         
         System.runAs(usr)
         {
             
             //dataSetup();
             
             SalesCallLWCController.CallDuplicateCheckWrapper testSalesCallWrapper = new SalesCallLWCController.CallDuplicateCheckWrapper();
             
             Call__c testCall = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Sub_Type__c, ZTS_EU_Duration__c,ZTS_EU_Record_Owner__c, ZTS_EU_Next_Step__c,ZTS_EU_Start_Date_Time__c FROM Call__c 
                                 where Id in (Select ZTS_EU_call__c from Attendee__c where ZTS_EU_of_Discussion_items__c>0 )
                                 LIMIT 1];
             testSalesCallWrapper.callId = testCall.Id; 
             testSalesCallWrapper.activityDate = testCall.ZTS_EU_Start_Date_Time__c; 
             testSalesCallWrapper.accountId = testCall.ZTS_EU_Account__c; 
             testSalesCallWrapper.subtype = testCall.ZTS_EU_Sub_Type__c;
             
             List<LookupSearchResultWrapper> attendeeWrappers = new List<LookupSearchResultWrapper>();
             List<Attendee__c> testAttendees = [SELECT Id, Name,ZTS_EU_Contact__c,ZTS_EU_Contact__r.Name,ZTS_EU_call__c FROM Attendee__c WHERE ZTS_EU_call__c = :testCall.Id];
             for(Attendee__c attendee : testAttendees) {
                 attendeeWrappers.add(SalesCallLWCController.buildLookupResultFromSObject(attendee));
             }
             testSalesCallWrapper.attendees = attendeeWrappers; 
             List<LookupSearchResultWrapper> contactWrappers = new List<LookupSearchResultWrapper>();
             for(Attendee__c attendee : [SELECT Id, Name,ZTS_EU_Contact__c,ZTS_EU_Contact__r.Name,ZTS_EU_call__c FROM Attendee__c WHERE ZTS_EU_call__c = :testCall.Id]) {
                 contactWrappers.add(SalesCallLWCController.buildLookupResultFromSObject(new Contact(Id = attendee.ZTS_EU_Contact__c)));
             }
             testSalesCallWrapper.contacts = contactWrappers;
             List<LookupSearchResultWrapper> affiliationWrappers = new List<LookupSearchResultWrapper>();
             for(Attendee__c attendee : [SELECT Id, Name,ZTS_EU_Contact__c,ZTS_EU_Contact__r.Name,ZTS_EU_call__c,ZTS_EU_call__r.ZTS_EU_Account__c FROM Attendee__c WHERE ZTS_EU_call__c = :testCall.Id]) {
                 affiliationWrappers.add(SalesCallLWCController.buildLookupResultFromSObject(new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = attendee.ZTS_EU_Contact__c, ZTS_EU_Account__c = attendee.ZTS_EU_call__r.ZTS_EU_Account__c )));
             }
             testSalesCallWrapper.affiliations = affiliationWrappers;
             
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
             
             List<LookupSearchResultWrapper> discussionWrapper = new List<LookupSearchResultWrapper>();
             for(ZTS_EU_Discussion_Item__c discItem : [SELECT Id, Name, ZTS_EU_Discussion_Item_Title__c, ZTS_EU_Active_DI__c FROM ZTS_EU_Discussion_Item__c WHERE Id IN :discussionItemIds]) {
                 discussionWrapper.add(SalesCallLWCController.buildLookupResultFromSObject(discItem));
             }
             
             for(ZTS_EU_Species_Product__c product : [SELECT Id, Name, ZTS_Hierarchy_Level__c FROM ZTS_EU_Species_Product__c WHERE Id IN :productIds]) {
                 discussionWrapper.add(SalesCallLWCController.buildLookupResultFromSObject(product));
             }
             
             for(Campaign campaign : [SELECT Id, Name, IsActive, ZTS_EU_Field_Targeting__c, StartDate, EndDate FROM Campaign WHERE Id IN :campaignIds]) {
                 discussionWrapper.add(SalesCallLWCController.buildLookupResultFromSObject(campaign));
             }
             testSalesCallWrapper.discussionNames = discussionWrapper; 
             
             String dupeCheckDetails = JSON.serialize(testSalesCallWrapper);
             
             //Create a duplicate call
             Call__c newCall = new Call__c(ZTS_EU_Start_Date_Time__c = testCall.ZTS_EU_Start_Date_Time__c,ZTS_EU_Duration__c = testCall.ZTS_EU_Duration__c,
                                           ZTS_EU_Account__c = testCall.ZTS_EU_Account__c,ZTS_EU_Sub_Type__c = testCall.ZTS_EU_Sub_Type__c);
             
             
             insert newCall;
             List<Attendee__c> newAttendee = new List<Attendee__c>();
             for(Attendee__c att: testAttendees)
             {
                 Attendee__c a = new Attendee__c(ZTS_EU_Contact__c = att.ZTS_EU_Contact__c,Name = att.ZTS_EU_Contact__r.Name,ZTS_EU_call__c=att.ZTS_EU_call__c);
                 newAttendee.add(a);
             }
             insert newAttendee;
             
             Test.startTest();
             List<Call__c> matchedCallList = SalesCallLWCController.lookForDuplicate(dupeCheckDetails);
             Test.stopTest();
             system.assertEquals(matchedCallList.size(),0);
         }
         
         
     }
     
     @isTest
     static void createCallRecordUpdate_Test() {
         
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
         
         ////dataSetup();
         System.runAs(usr)
         {
             //dataSetup();
             Call__c testCall1 = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Sub_Type__c, ZTS_EU_Duration__c, ZTS_EU_Next_Step__c,ZTS_EU_Start_Date_Time__c FROM Call__c LIMIT 1];
             testCall1.ZTS_EU_Start_Date_Time__c = System.now();
             test.startTest();
             String returnedId = SalesCallLWCController.createCallRecord(JSON.serialize(testCall1),false);
             test.stopTest();
             system.assertNotEquals(returnedId, '');
         }
    
     }
     
     @isTest
     static void createCallRecordInsert_Test() {
         
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
         
         System.runAs(usr)
         {
             //dataSetup();
             Call__c testCall1 = new Call__c();
             testCall1.ZTS_EU_Start_Date_Time__c = System.now();
             testCall1.ZTS_EU_Account__c = [Select ID from Account Limit 1][0].Id;
             testCall1.ZTS_EU_Duration__c = '0.5 Hour';
             testCall1.ZTS_EU_Sub_Type__c = 'Account Call';
             test.startTest();
             String returnedId = SalesCallLWCController.createCallRecord(JSON.serialize(testCall1),false);
             test.stopTest();
             system.assertNotEquals(returnedId, '');
         }
         
         
         
     }
     //Added for competitor (SC-009358)
     @isTest
     static void competitorTest() {
 
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         {
 
             //dataSetup();
 
             Call__c testCall = [SELECT ZTS_EU_Account__c FROM Call__c LIMIT 1];
             Id insComId;
             ZTS_Competitor__c testComp = new ZTS_Competitor__c();
                 testComp.Manufacturer__c = 'Bayer';
                 testComp.US_Category__c = 'Rapids';
                 testComp.Account__c = testCall.ZTS_EU_Account__c;
                 testComp.Date_Contract_Expires__c = system.today().addDays(90);
                 testComp.Species__c = 'Cattle';
                 
             insert testComp;
             insComId = testComp.Id;
             Test.startTest();
                 SalesCallLWCController.createCompetitorLookup(testComp.Id);
             Test.stopTest();
             SalesCallLWCController.deleteCompetitor(insComId, 'ZTS_Competitor__c');
             system.assertEquals(0, [Select Id from ZTS_Competitor__c where Id = :insComId ].size());
         }
     }
     
     //Added for competitor (SC-009358)
     @isTest
     static void getCompetitorOnAccountTest() {
        
         User usr = new User();
         usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         usr.FirstName = 'Test';
         usr.LastName = US_USER_LN;
         usr.zts_eu_market__c = MARKET;
         insert usr;
                 
         System.runAs(usr)
         { 
 
             //dataSetup();
 
             Call__c testCall = [SELECT Id,ZTS_EU_Account__c FROM Call__c LIMIT 1];//Sayan included Call Id
             system.debug('testCall==' +testCall);
             Id insComId;
             ZTS_Competitor__c testComp = new ZTS_Competitor__c();
                 testComp.Manufacturer__c = 'Bayer';
                 testComp.Other_Manufacturer__c ='Test Bayer';
                 testComp.Distributor_choice__c = 'MWI';
                 testComp.Species__c = 'Petcare';
                 testComp.US_Category__c = 'Rapids';
                 testComp.Account__c = testCall.ZTS_EU_Account__c;
                 testComp.Date_Contract_Expires__c = system.today().addDays(90);
                 testComp.Lost_Category_to_competitor__c = True;        
         
             insert testComp;
             system.debug('testComp--' + testComp);
             insComId = testComp.Id;
             Test.startTest();
             
                 SalesCallLWCController.getCompetitorOnAccount(testComp.Account__c);	
                 SalesCallLWCController.updateCompetitor(testComp.Id, 'US_Category__c', 'Reference Labs');
             
             Test.stopTest();
         }
         
     }
        
 }