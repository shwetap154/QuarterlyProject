/* -----------------------------------------------------------------------------------------------------------------------
Name:        ZTS_EU_SampleLookupOverride_Test.cls
Description: Test Class for ExtensionClass ZTS_EU_SampleLookupOverrideController.cls

Date         Version Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
28-11-2014   1.0     CloudSense(Shefali)   Initial Version          
------------------------------------------------------------------------------------------------------------------------ */


@isTest (SeeAllData = false)
public class ZTS_EU_AddSampleDropsController_Test{
    
    public static String searchText ='Test Drop';
    
    
    //saipraneeth(added testsAddSample1 method for else part of Sample_Drop__c ZTS_EU_Year__c = null)
    static testMethod void testAddSample(){
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'teterson';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Test.startTest();
            
            List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
            TriggerActivation__c tr1 = new TriggerActivation__c(Name = 'ZTS_EU_SampleDropTrigger',ZTS_EU_Bypass__c = true);
            TriggerActivation__c tr2 = new TriggerActivation__c(Name = 'ZTS_EU_SampleTrigger',ZTS_EU_Bypass__c = true);
            triggerActiveList.add(tr1);
            triggerActiveList.add(tr2);
            insert triggerActiveList;
            
            
            
            PageReference pgRef = Page.ZTS_EU_AddSampleDrops;
            Test.setCurrentPage(pgRef);
            //Create test data
            //Create Account
            List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert accList;
            
            //Create Contact
            Contact cont = new Contact();
            cont.AccountId = accList[0].Id;
            cont.ZTS_EU_Market__c = 'Italy';
            cont.FirstName = 'firstname';
            cont.LastName = 'lastName';
            cont.ZTS_EU_Contact_type__c = 'Other';
            cont.ZTS_EU_Species_Specialty__c = 'All Species';
            cont.Is_Government_Official__c = 'No';
            insert cont; 
            
            //Create SKU Product Hierarchy record
            
            String tgTypeId = [Select Id from RecordType where DeveloperName = 'Therapeutic_Group'].Id;
            ZTS_EU_Species_Product__c tgRec = new ZTS_EU_Species_Product__c();
            tgRec.Name = 'TestTG';
            tgRec.RecordTypeId = tgTypeId;
            tgRec.ZTS_EU_Market__c = 'Brazil';
            tgRec.ZTS_EU_Type__c = 'Therapeutic Group';
            tgRec.ZTS_EU_Is_Active__c = true;
            tgRec.ZTS_EU_Is_Old__c = true;
            insert tgRec;
            
            String brandTypeId = [Select Id from RecordType where DeveloperName = 'Brand'].Id;
            ZTS_EU_Species_Product__c brandRec = new ZTS_EU_Species_Product__c();
            brandRec.Name = 'Testbrand';
            brandRec.RecordTypeId = brandTypeId;
            brandRec.ZTS_EU_Market__c = 'Brazil';
            brandRec.ZTS_EU_Type__c = 'Brand';
            brandRec.ZTS_EU_Is_Active__c = true;
            brandRec.ZTS_EU_Parent_Species_Product__c = tgRec.Id;
            insert brandRec;
            
            String MPGTypeId = [Select Id from RecordType where DeveloperName = 'MPG'].Id;
            ZTS_EU_Species_Product__c mpgRec = new ZTS_EU_Species_Product__c();
            mpgRec.Name = 'TestMPG';
            mpgRec.RecordTypeId = MPGTypeId;
            mpgRec.ZTS_EU_Market__c = 'Brazil';
            mpgRec.ZTS_EU_Type__c = 'MPG';
            mpgRec.ZTS_EU_Is_Active__c = true;
            mpgRec.ZTS_EU_Parent_Species_Product__c = brandRec.Id;
            insert mpgRec;
            
            String skuRecTypeId = [Select Id from RecordType where DeveloperName = 'SKU'].Id;
            ZTS_EU_Species_Product__c skuRec = new ZTS_EU_Species_Product__c();
            skuRec.Name = 'TestSKU';
            skuRec.RecordTypeId = skuRecTypeId;
            skuRec.ZTS_EU_Create_Samples__c = true;
            skuRec.ZTS_EU_Market__c = 'Brazil';
            skuRec.ZTS_EU_Type__c = 'SKU';
            skuRec.ZTS_EU_Is_Old__c = true;
            skuRec.ZTS_EU_Is_Active__c = true;
            skuRec.ZTS_EU_Parent_Species_Product__c = mpgRec.Id;
            skuRec.ZTS_EU_is_Samplable__c = true;
            insert skuRec;
            
            
            
            //Create Sample record
            
            String sampleRecordTypeId = [Select Id from RecordType where DeveloperName='New_SKU_Sample'].Id;
            Integer lastYear = System.today().year()-365;
            String lastYearString = String.valueOf(lastYear);
            ZTS_EU_Sample__c sampleRec = new ZTS_EU_Sample__c();
            sampleRec.RecordTypeId = sampleRecordTypeId;
            sampleRec.ZTS_EU_Account__c = accList[0].Id;
            sampleRec.ZTS_EU_Contact__c = cont.Id;
            sampleRec.ZTS_EU_Is_Active__c = true;
            sampleRec.ZTS_EU_Is_used_for_old_SKUs__c = true;
            sampleRec.ZTS_EU_Year__c = lastYearString;
            insert sampleRec;
            
            // new code added 06 oct-17
            
            Profile p = [select id from profile where name='System Administrator' limit 1];
            User userRecord =  new User(FirstName = 'aaaaa', LastName = 'usa123', Email = 'usa123@test.com', Username = 'usa123@test.com', ProfileId = p.Id,Country = 'usa123',
                                        Alias = 'usa123'.substring(0,5), CommunityNickname = 'usa123'.substring(0,5), ZTS_EU_Market__c='Central America',
                                        TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='UTF-8',languagelocalekey='en_US');
            insert userRecord;
            
            // End code
            Test.stopTest();
            //Create Call instance
            Call__c testCall = new Call__c();
            testCall.ZTS_EU_Account__c = accList[0].Id;
            testCall.Name = 'Test Call';
            testCall.ZTS_EU_Call_Owner__c = userRecord.Id; // new added on 06 oct-17
            insert testCall;
            
            
            //create Attendee instance
            Attendee__c testAttendee = new Attendee__c(Name='TestAttendee', ZTS_EU_call__c=testCall.Id,ZTS_EU_Contact__c=cont.Id);
            insert testAttendee;
            
            //Create Sample Drop
            Sample_Drop__c testSampleDrop =new Sample_Drop__c();
            testSampleDrop.ZTS_EU_Sample__c = sampleRec.Id;
            testSampleDrop.ZTS_EU_Sample_Drop_Type__c = 'Sample Drop';
            testSampleDrop.ZTS_EU_Quantity__c = 5;
            testSampleDrop.ZTS_EU_Call__c = testCall.Id;
            testSampleDrop.ZTS_EU_Product__c = skuRec.Id;
            testSampleDrop.ZTS_EU_Species_Product_New_SKU__c = skuRec.Id;
            
            insert testSampleDrop;
            
            Sample_Drop__c testSampleDrop2 =new Sample_Drop__c();
            testSampleDrop2.ZTS_EU_Sample__c = sampleRec.Id;
            testSampleDrop2.ZTS_EU_Sample_Drop_Type__c = 'Sample Drop';
            testSampleDrop2.ZTS_EU_Quantity__c = 5;
            testSampleDrop2.ZTS_EU_Call__c = testCall.Id;
            testSampleDrop2.ZTS_EU_Product__c = skuRec.Id;
            testSampleDrop2.ZTS_EU_Contact__c = cont.Id;
            
            insert testSampleDrop2;
            
            Sample_Drop__c dropupdate = new Sample_Drop__c();
            dropupdate = [Select Id, ZTS_EU_Year__c from Sample_Drop__c where Id =: testSampleDrop.Id];
            dropupdate.ZTS_EU_Year__c = null;
            update dropupdate;
            
            
            ZTS_EU_Sample__c sampleupdate = new ZTS_EU_Sample__c();
            sampleupdate = [Select Id, ZTS_EU_Year__c, Market__c from ZTS_EU_Sample__c where Id =: sampleRec.Id];
            System.debug('$$$ b4 sampleupdate.ZTS_EU_Year__c: '+sampleupdate.ZTS_EU_Year__c);
            Integer thisYear = System.today().year();
            String thisYearString = String.valueOf(thisYear);
            sampleupdate.ZTS_EU_Year__c = thisYearString;
            System.debug('$$$ sampleupdate: '+sampleupdate);
            System.debug('$$$ sampleupdate.Market__c: '+sampleupdate.Market__c);
            System.debug('$$$ sampleupdate.ZTS_EU_Year__c: '+sampleupdate.ZTS_EU_Year__c);
            update sampleupdate;
            
            
            System.currentPageReference().getParameters().put('callId', testCall.Id);
            System.currentPageReference().getParameters().put('sampleDropId', testSampleDrop.Id);
            
            
            //Create the controller
            try{
                ZTS_EU_AddSampleDropsController sampleController = new ZTS_EU_AddSampleDropsController();
                sampleController.oldYear = '1996';
                Sample_Drop__c testDrop3 = new Sample_Drop__c();
                sampleController.newSampleDrop = testDrop3;
                testDrop3.ZTS_EU_Sample__c = sampleRec.Id;
                sampleController.cancelNewSampleDrop();
                sampleController.showNewSampleDrop();
                sampleController.sampleDropId =testSampleDrop.Id;
                sampleController.selectedSampleId =sampleRec.Id;
                sampleController.determineOldSkuSample();
                sampleController.deleteSampleDrop();
                sampleController.newSampleDrop.ZTS_EU_Product__c = tgRec.Id;
                sampleController.newSampleDrop.ZTS_EU_Quantity__c = 2;
                PageReference pegRef2 = sampleController.saveNewSampleDrop();
                
                
            }
            catch(exception e){
                system.debug(e.getMessage());
            }
        }   
    }  
    
    static testMethod void testAddSampleQuantityException(){
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
            TriggerActivation__c tr1 = new TriggerActivation__c(Name = 'ZTS_EU_SampleDropTrigger',ZTS_EU_Bypass__c = true);
            TriggerActivation__c tr2 = new TriggerActivation__c(Name = 'ZTS_EU_SampleTrigger',ZTS_EU_Bypass__c = true);
            triggerActiveList.add(tr1);
            triggerActiveList.add(tr2);
            insert triggerActiveList;
            
            
            
            PageReference pgRef = Page.ZTS_EU_AddSampleDrops;
            Test.setCurrentPage(pgRef);
            //Create test data
            //Create Account
            List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert accList;
            
            //Create Contact
            Contact cont = new Contact();
            cont.AccountId = accList[0].Id;
            cont.ZTS_EU_Market__c = 'United Kingdom';
            cont.FirstName = 'firstname';
            cont.LastName = 'lastName';
            cont.ZTS_EU_Contact_type__c = 'Other';
            cont.ZTS_EU_Species_Specialty__c = 'All Species';
            cont.Is_Government_Official__c = 'No';
            insert cont; 
            
            //Create SKU Product Hierarchy record
            
            String tgTypeId = [Select Id from RecordType where DeveloperName = 'Therapeutic_Group'].Id;
            ZTS_EU_Species_Product__c tgRec = new ZTS_EU_Species_Product__c();
            tgRec.Name = 'TestTG';
            tgRec.RecordTypeId = tgTypeId;
            tgRec.ZTS_EU_Market__c = 'Brazil';
            tgRec.ZTS_EU_Type__c = 'Therapeutic Group';
            tgRec.ZTS_EU_Is_Active__c = true;
            tgRec.ZTS_EU_Is_Old__c = true;
            insert tgRec;
            
            String brandTypeId = [Select Id from RecordType where DeveloperName = 'Brand'].Id;
            ZTS_EU_Species_Product__c brandRec = new ZTS_EU_Species_Product__c();
            brandRec.Name = 'Testbrand';
            brandRec.RecordTypeId = brandTypeId;
            brandRec.ZTS_EU_Market__c = 'Brazil';
            brandRec.ZTS_EU_Type__c = 'Brand';
            brandRec.ZTS_EU_Is_Active__c = true;
            brandRec.ZTS_EU_Parent_Species_Product__c = tgRec.Id;
            insert brandRec;
            
            String MPGTypeId = [Select Id from RecordType where DeveloperName = 'MPG'].Id;
            ZTS_EU_Species_Product__c mpgRec = new ZTS_EU_Species_Product__c();
            mpgRec.Name = 'TestMPG';
            mpgRec.RecordTypeId = MPGTypeId;
            mpgRec.ZTS_EU_Market__c = 'Brazil';
            mpgRec.ZTS_EU_Type__c = 'MPG';
            mpgRec.ZTS_EU_Is_Active__c = true;
            mpgRec.ZTS_EU_Parent_Species_Product__c = brandRec.Id;
            insert mpgRec;
            
            String skuRecTypeId = [Select Id from RecordType where DeveloperName = 'SKU'].Id;
            ZTS_EU_Species_Product__c skuRec = new ZTS_EU_Species_Product__c();
            skuRec.Name = 'TestSKU';
            skuRec.RecordTypeId = skuRecTypeId;
            skuRec.ZTS_EU_Create_Samples__c = true;
            skuRec.ZTS_EU_Market__c = 'Brazil';
            skuRec.ZTS_EU_Type__c = 'SKU';
            skuRec.ZTS_EU_Is_Old__c = true;
            skuRec.ZTS_EU_Is_Active__c = true;
            skuRec.ZTS_EU_Parent_Species_Product__c = mpgRec.Id;
            skuRec.ZTS_EU_is_Samplable__c = true;
            insert skuRec;
            
            
            
            //Create Sample record
            
            String sampleRecordTypeId = [Select Id from RecordType where DeveloperName='New_SKU_Sample'].Id;
            
            ZTS_EU_Sample__c sampleRec = new ZTS_EU_Sample__c();
            sampleRec.RecordTypeId = sampleRecordTypeId;
            sampleRec.ZTS_EU_Account__c = accList[0].Id;
            sampleRec.ZTS_EU_Contact__c = cont.Id;
            sampleRec.ZTS_EU_Is_Active__c = true;
            sampleRec.ZTS_EU_Is_used_for_old_SKUs__c = true;
            insert sampleRec;
            
            // Code added on 6th oct-17
            Profile p = [select id from profile where name='System Administrator' limit 1];
            User userRecord =  new User(LastName = 'usa123', Email = 'usa123@test.com', Username = 'usa123@test.com', ProfileId = p.Id,Country = 'usa123',
                                        Alias = 'usa123'.substring(0,5), CommunityNickname = 'usa123'.substring(0,5), ZTS_EU_Market__c='Central America',
                                        TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='UTF-8',languagelocalekey='en_US');
            insert userRecord;
            
            //End code
            Test.stopTest();
            //Create Call instance
            Call__c testCall = new Call__c();
            testCall.ZTS_EU_Account__c = accList[0].Id;
            testCall.Name = 'Test Call';
            testCall.ZTS_EU_Call_Owner__c = userRecord.Id;
            insert testCall;
            
            //create Attendee instance
            Attendee__c testAttendee = new Attendee__c(Name='TestAttendee', ZTS_EU_call__c=testCall.Id,ZTS_EU_Contact__c=cont.Id);
            insert testAttendee;
            
            //Create Sample Drop
            Sample_Drop__c testSampleDrop =new Sample_Drop__c();
            testSampleDrop.ZTS_EU_Sample__c = sampleRec.Id;
            testSampleDrop.ZTS_EU_Sample_Drop_Type__c = 'Sample Drop';
            testSampleDrop.ZTS_EU_Quantity__c = 5;
            testSampleDrop.ZTS_EU_Call__c = testCall.Id;
            testSampleDrop.ZTS_EU_Product__c = skuRec.Id;
            testSampleDrop.ZTS_EU_Species_Product_New_SKU__c = skuRec.Id;
            
            insert testSampleDrop;
            
            Sample_Drop__c testSampleDrop2 =new Sample_Drop__c();
            testSampleDrop2.ZTS_EU_Sample__c = sampleRec.Id;
            testSampleDrop2.ZTS_EU_Sample_Drop_Type__c = 'Sample Drop';
            testSampleDrop2.ZTS_EU_Quantity__c = 5;
            testSampleDrop2.ZTS_EU_Call__c = testCall.Id;
            testSampleDrop2.ZTS_EU_Product__c = skuRec.Id;
            testSampleDrop2.ZTS_EU_Contact__c = cont.Id;
            
            insert testSampleDrop2;
            
            Sample_Drop__c dropupdate = new Sample_Drop__c();
            dropupdate = [Select Id, ZTS_EU_Year__c from Sample_Drop__c where Id =: testSampleDrop.Id];
            dropupdate.ZTS_EU_Year__c = null;
            update dropupdate;
            
            
            ZTS_EU_Sample__c sampleupdate = new ZTS_EU_Sample__c();
            sampleupdate = [Select Id, ZTS_EU_Year__c from ZTS_EU_Sample__c where Id =: sampleRec.Id];
            sampleupdate.ZTS_EU_Year__c = '2020';
            update sampleupdate;
            
            
            System.currentPageReference().getParameters().put('callId', testCall.Id);
            System.currentPageReference().getParameters().put('sampleDropId', testSampleDrop.Id);
            
            
            //Create the controller
            try{
                ZTS_EU_AddSampleDropsController sampleController = new ZTS_EU_AddSampleDropsController();
                sampleController.oldYear = '1996';
                Sample_Drop__c testDrop3 = new Sample_Drop__c();
                sampleController.newSampleDrop = testDrop3;
                testDrop3.ZTS_EU_Sample__c = sampleRec.Id;
                sampleController.cancelNewSampleDrop();
                sampleController.showNewSampleDrop();
                sampleController.sampleDropId =testSampleDrop.Id;
                sampleController.selectedSampleId =sampleRec.Id;
                sampleController.determineOldSkuSample();
                sampleController.deleteSampleDrop();
                sampleController.newSampleDrop.ZTS_EU_Product__c = tgRec.Id;
                sampleController.newSampleDrop.ZTS_EU_Quantity__c = 10;
                PageReference pegRef2 = sampleController.saveNewSampleDrop();
                
                
            }
            catch(exception e){
                system.debug(e.getMessage());
            }
        }
    }
    
    static testMethod void testAddSample2(){
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'teterson';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
            TriggerActivation__c tr1 = new TriggerActivation__c(Name = 'ZTS_EU_SampleDropTrigger',ZTS_EU_Bypass__c = true);
            TriggerActivation__c tr2 = new TriggerActivation__c(Name = 'ZTS_EU_SampleTrigger',ZTS_EU_Bypass__c = true);
            triggerActiveList.add(tr1);
            triggerActiveList.add(tr2);
            insert triggerActiveList;
            
            
            
            PageReference pgRef = Page.ZTS_EU_AddSampleDrops;
            Test.setCurrentPage(pgRef);
            //Create test data
            //Create Account
            List<Account> accList1 = ZTS_EU_DataUtilityTest.createAccountRecord(2);
            insert accList1;
            
            //Create Contact
            Contact cont1 = new Contact();
            cont1.AccountId = accList1[1].Id;
            cont1.ZTS_EU_Market__c = 'United Kingdom';
            cont1.FirstName = 'firstname2';
            cont1.LastName = 'lastName2';
            cont1.ZTS_EU_Contact_type__c = 'Other';
            cont1.ZTS_EU_Species_Specialty__c = 'All Species';
            cont1.Is_Government_Official__c = 'No';
            insert cont1; 
            
            //Create SKU Product Hierarchy record
            
            String tgTypeId = [Select Id from RecordType where DeveloperName = 'Therapeutic_Group'].Id;
            ZTS_EU_Species_Product__c tgRec1 = new ZTS_EU_Species_Product__c();
            tgRec1.Name = 'TestTG';
            tgRec1.RecordTypeId = tgTypeId;
            tgRec1.ZTS_EU_Market__c = 'Brazil';
            tgRec1.ZTS_EU_Type__c = 'Therapeutic Group';
            tgRec1.ZTS_EU_Is_Active__c = true;
            tgRec1.ZTS_EU_Is_Old__c = false;
            insert tgRec1;
            
            String brandTypeId = [Select Id from RecordType where DeveloperName = 'Brand'].Id;
            ZTS_EU_Species_Product__c brandRec1 = new ZTS_EU_Species_Product__c();
            brandRec1.Name = 'Testbrand';
            brandRec1.RecordTypeId = brandTypeId;
            brandRec1.ZTS_EU_Market__c = 'Brazil';
            brandRec1.ZTS_EU_Type__c = 'Brand';
            brandRec1.ZTS_EU_Is_Active__c = true;
            brandRec1.ZTS_EU_Parent_Species_Product__c = tgRec1.Id;
            insert brandRec1;
            
            String MPGTypeId = [Select Id from RecordType where DeveloperName = 'MPG'].Id;
            ZTS_EU_Species_Product__c mpgRec1 = new ZTS_EU_Species_Product__c();
            mpgRec1.Name = 'TestMPG';
            mpgRec1.RecordTypeId = MPGTypeId;
            mpgRec1.ZTS_EU_Market__c = 'Brazil';
            mpgRec1.ZTS_EU_Type__c = 'MPG';
            mpgRec1.ZTS_EU_Is_Active__c = true;
            mpgRec1.ZTS_EU_Parent_Species_Product__c = brandRec1.Id;
            insert mpgRec1;
            
            String skuRecTypeId = [Select Id from RecordType where DeveloperName = 'SKU'].Id;
            ZTS_EU_Species_Product__c skuRec1 = new ZTS_EU_Species_Product__c();
            skuRec1.Name = 'TestSKU1';
            skuRec1.RecordTypeId = skuRecTypeId;
            skuRec1.ZTS_EU_Create_Samples__c = true;
            skuRec1.ZTS_EU_Market__c = 'Brazil';
            skuRec1.ZTS_EU_Type__c = 'SKU';
            skuRec1.ZTS_EU_Is_Old__c = false;
            skuRec1.ZTS_EU_Is_Active__c = true;
            skuRec1.ZTS_EU_Parent_Species_Product__c = mpgRec1.Id;
            skuRec1.ZTS_EU_is_Samplable__c = true;
            insert skuRec1;
            
            
            
            //Create Sample record
            
            String sampleRecordTypeId = [Select Id from RecordType where DeveloperName='New_SKU_Sample'].Id;
            
            ZTS_EU_Sample__c sampleRec1 = new ZTS_EU_Sample__c();
            sampleRec1.RecordTypeId = sampleRecordTypeId;
            sampleRec1.ZTS_EU_Account__c = accList1[0].Id;
            sampleRec1.ZTS_EU_Contact__c = cont1.Id;
            sampleRec1.ZTS_EU_Is_Active__c = true;
            sampleRec1.ZTS_EU_Product__c = skuRec1.Id;
            insert sampleRec1;
            
            // Added code on 6th Oct-17
            Profile p = [select id from profile where name='System Administrator' limit 1];
            User userRecord1 =  new User(LastName = 'usa123', Email = 'usa123@test.com', Username = 'usa123@test.com', ProfileId = p.Id,Country = 'usa123',
                                         Alias = 'usa123'.substring(0,5), CommunityNickname = 'usa123'.substring(0,5), ZTS_EU_Market__c='Central America',
                                         TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='UTF-8',languagelocalekey='en_US');
            insert userRecord1;
            
            // end code
            Test.stopTest();
            //Create Call instance
            Call__c testCall1 = new Call__c();
            testCall1.ZTS_EU_Account__c = accList1[0].Id;
            testCall1.Name = 'Test Call';
            testCall1.ZTS_EU_Call_Owner__c = userRecord1.Id; // Code added on 6th Oct-17
            insert testCall1;
            
            //create Attendee instance
            Attendee__c testAttendee1 = new Attendee__c(Name='TestAttendee', ZTS_EU_call__c=testCall1.Id,ZTS_EU_Contact__c=cont1.Id);
            insert testAttendee1;
            
            //Create Sample Drop
            Sample_Drop__c testSampleDrop1 =new Sample_Drop__c();
            testSampleDrop1.ZTS_EU_Sample__c = sampleRec1.Id;
            testSampleDrop1.ZTS_EU_Sample_Drop_Type__c = 'Sample Drop1';
            testSampleDrop1.ZTS_EU_Quantity__c = 5;
            testSampleDrop1.ZTS_EU_Call__c = testCall1.Id;
            testSampleDrop1.ZTS_EU_Species_Product_New_SKU__c = skuRec1.Id;
            testSampleDrop1.ZTS_EU_Contact__c = cont1.Id;
            
            insert testSampleDrop1;
            
            System.currentPageReference().getParameters().put('callId', testCall1.Id);
            System.currentPageReference().getParameters().put('sampleDropId', testSampleDrop1.Id);
            
            
            //Create the controller
            try{
                ZTS_EU_AddSampleDropsController sampleController = new ZTS_EU_AddSampleDropsController();
                sampleController.oldYear = '1996';
                Sample_Drop__c testDrop4 = new Sample_Drop__c();
                sampleController.newSampleDrop = testDrop4;
                testDrop4.ZTS_EU_Sample__c = sampleRec1.Id;
                sampleController.cancelNewSampleDrop();
                sampleController.showNewSampleDrop();
                sampleController.sampleDropId =testSampleDrop1.Id;
                sampleController.selectedSampleId =sampleRec1.Id;
                sampleController.determineOldSkuSample();
                sampleController.newSampleDrop.ZTS_EU_Product__c = tgRec1.Id;
                sampleController.newSampleDrop.ZTS_EU_Quantity__c = 2;
                PageReference pegRef2 = sampleController.saveNewSampleDrop();
                
                
            }
            catch(exception e){
                system.debug(e.getMessage());
            }
        }
    }
    
    static testMethod void testAddSample2QuantityExceptionElse(){
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'teterson';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Test.startTest();
            List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
            TriggerActivation__c tr1 = new TriggerActivation__c(Name = 'ZTS_EU_SampleDropTrigger',ZTS_EU_Bypass__c = true);
            TriggerActivation__c tr2 = new TriggerActivation__c(Name = 'ZTS_EU_SampleTrigger',ZTS_EU_Bypass__c = true);
            triggerActiveList.add(tr1);
            triggerActiveList.add(tr2);
            insert triggerActiveList;
            
            
            
            PageReference pgRef = Page.ZTS_EU_AddSampleDrops;
            Test.setCurrentPage(pgRef);
            //Create test data
            //Create Account
            List<Account> accList1 = ZTS_EU_DataUtilityTest.createAccountRecord(2);
            insert accList1;
            
            //Create Contact
            Contact cont1 = new Contact();
            cont1.AccountId = accList1[1].Id;
            cont1.ZTS_EU_Market__c = 'United Kingdom';
            cont1.FirstName = 'firstname2';
            cont1.LastName = 'lastName2';
            cont1.ZTS_EU_Contact_type__c = 'Other';
            cont1.ZTS_EU_Species_Specialty__c = 'All Species';
            cont1.Is_Government_Official__c = 'No';
            insert cont1; 
            
            //Create SKU Product Hierarchy record
            
            String tgTypeId = [Select Id from RecordType where DeveloperName = 'Therapeutic_Group'].Id;
            ZTS_EU_Species_Product__c tgRec1 = new ZTS_EU_Species_Product__c();
            tgRec1.Name = 'TestTG';
            tgRec1.RecordTypeId = tgTypeId;
            tgRec1.ZTS_EU_Market__c = 'Brazil';
            tgRec1.ZTS_EU_Type__c = 'Therapeutic Group';
            tgRec1.ZTS_EU_Is_Active__c = true;
            tgRec1.ZTS_EU_Is_Old__c = false;
            insert tgRec1;
            
            String brandTypeId = [Select Id from RecordType where DeveloperName = 'Brand'].Id;
            ZTS_EU_Species_Product__c brandRec1 = new ZTS_EU_Species_Product__c();
            brandRec1.Name = 'Testbrand';
            brandRec1.RecordTypeId = brandTypeId;
            brandRec1.ZTS_EU_Market__c = 'Brazil';
            brandRec1.ZTS_EU_Type__c = 'Brand';
            brandRec1.ZTS_EU_Is_Active__c = true;
            brandRec1.ZTS_EU_Parent_Species_Product__c = tgRec1.Id;
            insert brandRec1;
            
            String MPGTypeId = [Select Id from RecordType where DeveloperName = 'MPG'].Id;
            ZTS_EU_Species_Product__c mpgRec1 = new ZTS_EU_Species_Product__c();
            mpgRec1.Name = 'TestMPG';
            mpgRec1.RecordTypeId = MPGTypeId;
            mpgRec1.ZTS_EU_Market__c = 'Brazil';
            mpgRec1.ZTS_EU_Type__c = 'MPG';
            mpgRec1.ZTS_EU_Is_Active__c = true;
            mpgRec1.ZTS_EU_Parent_Species_Product__c = brandRec1.Id;
            insert mpgRec1;
            
            String skuRecTypeId = [Select Id from RecordType where DeveloperName = 'SKU'].Id;
            ZTS_EU_Species_Product__c skuRec1 = new ZTS_EU_Species_Product__c();
            skuRec1.Name = 'TestSKU1';
            skuRec1.RecordTypeId = skuRecTypeId;
            skuRec1.ZTS_EU_Create_Samples__c = true;
            skuRec1.ZTS_EU_Market__c = 'Brazil';
            skuRec1.ZTS_EU_Type__c = 'SKU';
            skuRec1.ZTS_EU_Is_Old__c = false;
            skuRec1.ZTS_EU_Is_Active__c = true;
            skuRec1.ZTS_EU_Parent_Species_Product__c = mpgRec1.Id;
            skuRec1.ZTS_EU_is_Samplable__c = true;
            insert skuRec1;
            
            
            
            //Create Sample record
            
            String sampleRecordTypeId = [Select Id from RecordType where DeveloperName='New_SKU_Sample'].Id;
            
            ZTS_EU_Sample__c sampleRec1 = new ZTS_EU_Sample__c();
            sampleRec1.RecordTypeId = sampleRecordTypeId;
            sampleRec1.ZTS_EU_Account__c = accList1[0].Id;
            sampleRec1.ZTS_EU_Contact__c = cont1.Id;
            sampleRec1.ZTS_EU_Is_Active__c = true;
            sampleRec1.ZTS_EU_Product__c = skuRec1.Id;
            insert sampleRec1;
            
            // Code added on 6th oct-17
            Profile p = [select id from profile where name='System Administrator' limit 1];
            User userRecord =  new User(LastName = 'usa123', Email = 'usa123@test.com', Username = 'usa123@test.com', ProfileId = p.Id,Country = 'usa123',
                                        Alias = 'usa123'.substring(0,5), CommunityNickname = 'usa123'.substring(0,5), ZTS_EU_Market__c='Central America',
                                        TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='UTF-8',languagelocalekey='en_US');
            insert userRecord;
            
            //End code
            Test.stopTest();
            //Create Call instance
            Call__c testCall1 = new Call__c();
            testCall1.ZTS_EU_Account__c = accList1[0].Id;
            testCall1.Name = 'Test Call';
            testCall1.ZTS_EU_Call_Owner__c = userRecord.Id;
            insert testCall1;
            
            //create Attendee instance
            Attendee__c testAttendee1 = new Attendee__c(Name='TestAttendee', ZTS_EU_call__c=testCall1.Id,ZTS_EU_Contact__c=cont1.Id);
            insert testAttendee1;
            
            //Create Sample Drop
            Sample_Drop__c testSampleDrop1 =new Sample_Drop__c();
            testSampleDrop1.ZTS_EU_Sample__c = sampleRec1.Id;
            testSampleDrop1.ZTS_EU_Sample_Drop_Type__c = 'Sample Drop1';
            testSampleDrop1.ZTS_EU_Quantity__c = 5;
            testSampleDrop1.ZTS_EU_Call__c = testCall1.Id;
            testSampleDrop1.ZTS_EU_Species_Product_New_SKU__c = skuRec1.Id;
            testSampleDrop1.ZTS_EU_Contact__c = cont1.Id;
            
            insert testSampleDrop1;
            
            System.currentPageReference().getParameters().put('callId', testCall1.Id);
            System.currentPageReference().getParameters().put('sampleDropId', testSampleDrop1.Id);
            
            
            //Create the controller
            try{
                ZTS_EU_AddSampleDropsController sampleController = new ZTS_EU_AddSampleDropsController();
                sampleController.oldYear = '1996';
                Sample_Drop__c testDrop4 = new Sample_Drop__c();
                sampleController.newSampleDrop = testDrop4;
                testDrop4.ZTS_EU_Sample__c = sampleRec1.Id;
                sampleController.cancelNewSampleDrop();
                sampleController.showNewSampleDrop();
                sampleController.sampleDropId =testSampleDrop1.Id;
                sampleController.selectedSampleId =sampleRec1.Id;
                sampleController.determineOldSkuSample();
                sampleController.newSampleDrop.ZTS_EU_Product__c = tgRec1.Id;
                sampleController.newSampleDrop.ZTS_EU_Quantity__c = 10;
                PageReference pegRef2 = sampleController.saveNewSampleDrop();
                
                
            }
            catch(exception e){
                system.debug(e.getMessage());
            }
        }
    }
}