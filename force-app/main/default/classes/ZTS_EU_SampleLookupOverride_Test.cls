/* -----------------------------------------------------------------------------------------------------------------------
Name:        ZTS_EU_SampleLookupOverride_Test.cls
Description: Test Class for ExtensionClass ZTS_EU_SampleLookupOverrideController.cls

Date         Version Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
27-11-2014   1.0     CloudSense(Bimba)   Initial Version          
------------------------------------------------------------------------------------------------------------------------ */
@isTest
public class ZTS_EU_SampleLookupOverride_Test{
    public static String searchText ='Test Drop';
    
    static testMethod void testSampleLookupOverrideCtrlr(){
        PageReference pgRef = Page.ZTS_EU_SampleLookupOverride;
        Test.setCurrentPage(pgRef);
        //Create test data
        //Create Account
        List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr){
            database.insert(accList,false);
        }
        
        //Create Contact
        Contact cont = new Contact();
        cont.AccountId = accList[0].Id;
        cont.FirstName = 'firstname';
        cont.LastName = 'lastName';
        cont.ZTS_EU_Contact_type__c = 'Other';
        cont.ZTS_EU_Species_Specialty__c = 'All Species';
        cont.Is_Government_Official__c = 'No';
        database.insert(cont,false);        
        
        //Create SKU Product Hierarchy record
        String skuRecTypeId = [Select Id from RecordType where DeveloperName = 'SKU'].Id;
        
        ZTS_EU_Species_Product__c skuRec = new ZTS_EU_Species_Product__c();
        skuRec.Name = 'TestSKU';
        skuRec.RecordTypeId = skuRecTypeId;
        skuRec.ZTS_EU_Create_Samples__c = true;
        skuRec.ZTS_EU_Market__c = 'Brazil';
        skuRec.ZTS_EU_Type__c = 'SKU';
        database.insert(skuRec,false);
        
        //Create Sample record
        
        String sampleRecordTypeId = [Select Id from RecordType where DeveloperName='New_SKU_Sample'].Id;
        
        ZTS_EU_Sample__c sampleRec = new ZTS_EU_Sample__c();
        sampleRec.RecordTypeId = sampleRecordTypeId;
        sampleRec.ZTS_EU_Account__c = accList[0].Id;
        sampleRec.ZTS_EU_Contact__c = cont.Id;
        sampleRec.ZTS_EU_Is_Active__c = true;
        sampleRec.ZTS_EU_Product__c = skuRec.Id;
        database.insert(sampleRec,false); 
        
        
        //Create Call instance
        Call__c testCall = new Call__c();
        testCall.ZTS_EU_Account__c = accList[0].Id;
        testCall.Name = 'Test Call';
        testcall.ZTS_EU_Call_Owner__c = usr.Id;
        insert testCall;  
        
        //Create Standard controller instance
        System.currentPageReference().getParameters().put('callId', testCall.Id);
        System.currentPageReference().getParameters().put('lksrch',searchText);
        
        ApexPages.StandardController con = new ApexPages.Standardcontroller(sampleRec);
        //Create the controller
        ZTS_EU_SampleLookupOverrideController sampleController = new ZTS_EU_SampleLookupOverrideController(con);
        
        //create Attendee instance
        Attendee__c testAttendee = new Attendee__c(Name='TestAttendee', ZTS_EU_call__c=testCall.Id,ZTS_EU_Contact__c=cont.Id);
        System.runAs(usr){
            insert testAttendee;
        }
        
        Test.StartTest();
        //sampleController.getSampleRecords();
        //System.currentPageReference().getParameters().put('callId', testCall.Id);
        //System.currentPageReference().getParameters().put('lksrch',searchText);
        sampleController.getSampleRecords();
        PageReference pf = sampleController.searchSample();
        Test.stopTest();
    }   
    
    static testMethod void testSampleLookupOverrideCtrlrforItalyMarketForOlderSample(){
        PageReference pgRef = Page.ZTS_EU_SampleLookupOverride;
        Test.setCurrentPage(pgRef);
        //Create Account
        List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
        accList[0].ZTS_EU_Market__c = 'Italy';
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'Italy';
        insert usr;
        System.runAs(usr){
            database.insert(accList,false);
        }
        
        //Create Contact
        List<Contact> contList = ZTS_EU_DataUtilityTest.createContactRecord(1);
        contList[0].AccountId = accList[0].Id;
        contList[0].ZTS_EU_Market__c = 'Italy';
        database.insert(contList[0],false);        
        
        //Create SKU Product Hierarchy record
        String skuRecTypeId = [Select Id from RecordType where DeveloperName = 'SKU'].Id;
        ZTS_EU_Species_Product__c skuRec = new ZTS_EU_Species_Product__c();
        skuRec.Name = 'TestSKU';
        skuRec.RecordTypeId = skuRecTypeId;
        skuRec.ZTS_EU_Create_Samples__c = true;
        skuRec.ZTS_EU_Market__c = 'Italy';
        skuRec.ZTS_EU_Type__c = 'SKU';
        database.insert(skuRec,false);
      
        String OlderYear = String.valueOf(Date.Today().Year()-5);
        //Create Sample records
        String sampleRecordTypeId = [Select Id from RecordType where DeveloperName='New_SKU_Sample'].Id;
        List<ZTS_EU_Sample__c> sampleRecList = ZTS_EU_DataUtilityTest.createSampleRecords(1);
        sampleRecList[0].RecordTypeId = sampleRecordTypeId;
        sampleRecList[0].ZTS_EU_Account__c = accList[0].Id;
        sampleRecList[0].ZTS_EU_Contact__c = contList[0].Id;
        sampleRecList[0].ZTS_EU_Product__c = skuRec.Id;
        sampleRecList[0].ZTS_EU_Year__c = OlderYear;
        database.insert(sampleRecList,false); 
        
        //Create Call instance       
        Call__c testCall = new Call__c();
        testCall.ZTS_EU_Account__c = accList[0].Id;
        testCall.Name = 'Test Call';
        testcall.ZTS_EU_Call_Owner__c = usr.Id;
        insert testCall;
        
        //create Attendee instance
        Attendee__c testAttendee = new Attendee__c(Name='TestAttendee', ZTS_EU_call__c=testCall.Id,ZTS_EU_Contact__c=contList[0].Id);
        System.runAs(usr){
            insert testAttendee;
        }
        
        //Create Standard controller instance
        System.currentPageReference().getParameters().put('callId', testCall.Id);
        System.currentPageReference().getParameters().put('lksrch','TestSKU');
        
        ApexPages.StandardController con = new ApexPages.Standardcontroller(sampleRecList[0]); //searching with older year sample
        //Create the controller
        ZTS_EU_SampleLookupOverrideController sampleController = new ZTS_EU_SampleLookupOverrideController(con);
        
        Test.StartTest();
        sampleController.getSampleRecords();
        //assert statements
        System.assertEquals(0, sampleController.sampleList.size());
        System.assertEquals(false, sampleController.showSamples);
        PageReference pf = sampleController.searchSample();
        Test.stopTest();
    }
    static testMethod void testSampleLookupOverrideCtrlrforItalyMarketCurrentYearSample(){
        PageReference pgRef = Page.ZTS_EU_SampleLookupOverride;
        Test.setCurrentPage(pgRef);
        //Create Account
        List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
        accList[0].ZTS_EU_Market__c = 'Italy';
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'Italy';
        insert usr;
        System.runAs(usr){
            database.insert(accList,false);
        }
        
        //Create Contact
        List<Contact> contList = ZTS_EU_DataUtilityTest.createContactRecord(1);
        contList[0].AccountId = accList[0].Id;
        contList[0].ZTS_EU_Market__c = 'Italy';
        database.insert(contList[0],false);        
        
        //Create SKU Product Hierarchy record
        String skuRecTypeId = [Select Id from RecordType where DeveloperName = 'SKU'].Id;
        ZTS_EU_Species_Product__c skuRec = new ZTS_EU_Species_Product__c();
        skuRec.Name = 'TestSKU';
        skuRec.RecordTypeId = skuRecTypeId;
        skuRec.ZTS_EU_Create_Samples__c = true;
        skuRec.ZTS_EU_Market__c = 'Italy';
        skuRec.ZTS_EU_Type__c = 'SKU';
        database.insert(skuRec,false);
        
        String CurrentYear = String.valueOf(Date.Today().Year());
        String OlderYear = String.valueOf(Date.Today().Year()-5);
        //Create Sample records
        String sampleRecordTypeId = [Select Id from RecordType where DeveloperName='New_SKU_Sample'].Id;
        List<ZTS_EU_Sample__c> sampleRecList = ZTS_EU_DataUtilityTest.createSampleRecords(1);
        sampleRecList[0].RecordTypeId = sampleRecordTypeId;
        sampleRecList[0].ZTS_EU_Account__c = accList[0].Id;
        sampleRecList[0].ZTS_EU_Contact__c = contList[0].Id;
        sampleRecList[0].ZTS_EU_Product__c = skuRec.Id;
        sampleRecList[0].ZTS_EU_Year__c = CurrentYear;
        database.insert(sampleRecList,false); 
        
        //Create Call instance
        Profile p = [select id from profile where name='System Administrator' limit 1];
        User userRecord =  new User(LastName = 'lastname', Email = 'italy123@test.com', Username = 'italy123@test.com', ProfileId = p.Id,Country = 'Italy',
                                    Alias = 'italy123'.substring(0,5), CommunityNickname = 'italy123'.substring(0,5), ZTS_EU_Market__c='Italy',
                                    TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='UTF-8',languagelocalekey='en_US');
        insert userRecord;
        
        Call__c testCall = new Call__c();
        testCall.ZTS_EU_Account__c = accList[0].Id;
        testCall.Name = 'Test Call';
        testcall.ZTS_EU_Call_Owner__c = userRecord.Id;
        insert testCall;
        
        //create Attendee instance
        Attendee__c testAttendee = new Attendee__c(Name='TestAttendee', ZTS_EU_call__c=testCall.Id,ZTS_EU_Contact__c=contList[0].Id);
        System.runAs(usr){
            insert testAttendee;
        }
        
        //Create Standard controller instance
        System.currentPageReference().getParameters().put('callId', testCall.Id);
        System.currentPageReference().getParameters().put('lksrch','TestSKU');
        
        ApexPages.StandardController con = new ApexPages.Standardcontroller(sampleRecList[0]); //searching with current year sample
        //Create the controller
        ZTS_EU_SampleLookupOverrideController sampleController = new ZTS_EU_SampleLookupOverrideController(con);
        
        Test.StartTest();
        sampleController.getSampleRecords();
        //assert statements
        System.assertEquals(1, sampleController.sampleList.size());
        System.assertEquals(true, sampleController.showSamples);
        PageReference pf = sampleController.searchSample();
        Test.stopTest();
    }
}