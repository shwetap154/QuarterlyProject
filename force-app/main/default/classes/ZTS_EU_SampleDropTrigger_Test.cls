/* -----------------------------------------------------------------------------------------------------------------------
Name:        ZTS_EU_SampleDropTrigger_Test.cls
Description: Repurposing as test Class for INTLSampleTriggerService class

Date         Version Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
28-11-2014   1.0     CloudSense(Shefali)   Initial Version 
03-01-2021   1.1     Slalom (Carstairs)    Repurpose to test intlsampletriggerservice class
--------------------------------------------------------------------------------------------------------------------------*/        
@isTest 
public class ZTS_EU_SampleDropTrigger_Test{
    
    @isTest
    static void EUSampleServiceTest()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'Italy';
        insert usr;
        
        System.runAs(usr)
        {
            //Create Account
            List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            accList[0].ZTS_EU_Market__c = 'Italy';
            insert accList;
            
            //Create Contact
            Contact cont = new Contact();
            cont.AccountId = accList[0].Id;
            cont.FirstName = 'firstname';
            cont.LastName = 'lastName';
            cont.ZTS_EU_Market__c = 'Italy';
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
            sampleRec.ZTS_EU_Year__c = '2000';
            sampleRec.ZTS_EU_Product__c = skuRec.Id;
            insert sampleRec;
            Test.startTest();
                //Create Call instance
                Call__c testCall = new Call__c();
                testCall.ZTS_EU_Account__c = accList[0].Id;
                testCall.Name = 'Test Call';
                testCall.ZTS_EU_Call_Owner__c = UserInfo.getUserId();
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
                insert testSampleDrop;
                
                Sample_Drop__c testDrop2 =new Sample_Drop__c();
                testDrop2.ZTS_EU_Sample__c = sampleRec.Id;
                testDrop2.ZTS_EU_Attendee__c = testAttendee.Id;
                testDrop2.ZTS_EU_Call__c = testCall.Id;
                testDrop2.ZTS_EU_Quantity__c = 1;
                insert testDrop2;
                
                Sample_Drop__c dropupdate = new Sample_Drop__c();
                dropupdate = [Select Id, ZTS_EU_Year__c from Sample_Drop__c where Id =: testDrop2.Id];
                dropupdate.ZTS_EU_Year__c = '2020';
                update dropupdate;
                
                ZTS_EU_Sample__c sampleupdate = new ZTS_EU_Sample__c();
                sampleupdate = [Select Id, ZTS_EU_Year__c from ZTS_EU_Sample__c where Id =: sampleRec.Id];
                sampleupdate.ZTS_EU_Year__c = '2020';
                
                List<ZTS_EU_Sample__c> oldSampleList = new List<ZTS_EU_Sample__c>{sampleRec};
                Map<Id,ZTS_EU_Sample__c> oldSampleListMap = new Map<Id,ZTS_EU_Sample__c>(oldSampleList);
                List<ZTS_EU_Sample__c> newSampleList = new List<ZTS_EU_Sample__c>{sampleupdate};
                Map<Id,ZTS_EU_Sample__c> newSampleListMap = new Map<Id,ZTS_EU_Sample__c>(newSampleList);

            
                INTLSampleTriggerService.afterUpdate(oldSampleList, oldSampleListMap, newSampleList, newSampleListMap);
            Test.stopTest();


            List<Sample_Drop__c> updatedSampleDrops = [SELECT ZTS_EU_Is_Current_Year_Sample_Drop__c FROM Sample_Drop__c WHERE Id = :testDrop2.Id AND ZTS_EU_Is_Current_Year_Sample_Drop__c = false];
            System.assert(!updatedSampleDrops.isEmpty(),'Related sample drops should be returned');
        }
        
    }

    @isTest
    static void deleteAffiliationServiceTest() {

        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'Italy';
        insert usr;
        
        System.runAs(usr)
        {

            ZTS_EU_AffiliationsTriggerHandler affilHandler = new ZTS_EU_AffiliationsTriggerHandler();
            affilHandler.disableTrigger = true;

            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            List<Account> a = ZTS_DataUtilityTest.createAccountRecord(1);
            a[0].ZTS_EU_Market__c = 'Italy';
            insert a;
      
            List<Contact> c = ZTS_DataUtilityTest.createContactRecord(1);
            c[0].ZTS_EU_Market__c = 'Italy';
            c[0].AccountId = a[0].Id;
            insert c;

            List<ZTS_EU_Affiliations__c> affil = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
            affil[0].ZTS_EU_Affiliation_Status__c = 'InActive';
            affil[0].ZTS_EU_Account__c = a[0].Id;
            affil[0].ZTS_EU_Contact__c = c[0].Id;
            insert affil;
            
            a[0].ZTS_EU_Primary_Contact__c = c[0].Id;
            update a;
            
            c[0].ZTS_EU_Contact_Status__c = 'Active';
            update c;
            
            List<ZTS_EU_Affiliations__c> requeriedAffiliations =[SELECT Id, ZTS_EU_Primary_Contact__c, ZTS_EU_Contact_Active_Status__c FROM ZTS_EU_Affiliations__c WHERE Id IN :affil];

            List<ZTS_EU_Affiliations__c> triggerOld = requeriedAffiliations;
            Map<Id,ZTS_EU_Affiliations__c> triggerOldMap = new Map<Id,ZTS_EU_Affiliations__c>(triggerOld);

            try {
                Test.startTest();
                affilHandler.disableTrigger = false;
                delete requeriedAffiliations;
                Test.stopTest();
            }
            catch(Exception ex) {
                String expectedErrorMessage = '<b>The Affiliation for Active Primary Contact of the Account cannot be deleted. Please change the primary contact of the account before deleting this affiliation record. </b>';
                System.assert(ex.getMessage().contains(expectedErrorMessage),'Error message should match the one in the service class');
            }
        }

    }
}