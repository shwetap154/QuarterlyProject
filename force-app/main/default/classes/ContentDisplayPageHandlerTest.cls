/**
 * @description       : 
 * @author            : Wesley Wu @ Cognizant
 * @group             : 
 * @last modified on  : 09-16-2021
 * @last modified by  : Wesley Wu @ Cognizant
**/
@isTest
private class ContentDisplayPageHandlerTest {

    @isTest
    static void retrieveContentRecords_ContentDisplayTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        //usr.UserType = 'POWER_PARTNER_USER';
        insert usr;

        System.runAs(usr)
        {
          
            createContentVersions();
            List<ContentVersion> contentVersionList = new List<ContentVersion>();  
            //Run Aura Component
            contentVersionList = ContentDisplayPageHandler.retrieveContentRecords('Communities_ContentDisplay');    
            //System.assert(contentVersionList.size() == 10, '# of filtered Content Versions = ' + contentVersionList.size() + '. Was expecting 10');
        }
    }
    
    @isTest
    static void retrieveContentRecords_ContentDisplayTest1() {
        Id p = [select id from profile where name='Distributor Community User'].id;
       
        Account acc = new Account() ;
        acc.name='test acc';
        acc.ZTS_EU_Market__c = 'ALPHA';
        acc.ZTS_EU_Country__c='Albania';
        acc.Applicable_Product_Lines__c='Advocin';
        acc.Applicable_Countries__c = 'TZA';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        acc.BillingStreet = '123 Street';
        acc.BillingCity = 'Parsippany';
        acc.BillingState = 'New Jersey';
        acc.BillingPostalCode = '07054';
        acc.BillingCountry = 'United States';
        insert acc;
        //insert ac; 
       
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id);
        con.ZTS_EU_Market__c = 'ALPHA';
        insert con;  
                  
        User user = new User(alias = 'test123', email='cvtest123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United Kingdom',IsActive =true,
                ContactId = con.Id,Applicable_Countries__c='TZA',
                timezonesidkey='America/Los_Angeles', username='cvbntester@noemail.com', ZTS_EU_Market__c = 'ALPHA');
       
        insert user;
        system.runAs(user) {
            ContentDisplayPageHandler.retrieveContentRecords('Communities_ContentDisplay');
        }

    }

    @isTest
    static void retrieveContentRecords_NewsFeedTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
          
            createContentVersions();
            List<String> speciesList = new List<String>{'Equine', 'Ruminants', 'Companion Animals', 'Swine'}; //Does not include Poultry
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            
            //Run Aura Component
            contentVersionList = ContentDisplayPageHandler.retrieveContentRecords('Communities_ContentNewsFeed');
            //System.assert(contentVersionList.size() == 4, '# of filtered Content Versions = ' + contentVersionList.size() + '. Was expecting 4');
        
            List<ContentVersion> allContentVersions = [SELECT Id FROM ContentVersion];
            System.assert(allContentVersions.size() == 10, '# of all Content Versions = ' + allContentVersions.size() + '. Was expecting 10');
        }

    }
    
    @IsTest
    static void getBaseURLTest() {
       
        String returnString = ContentDisplayPageHandler.getBaseURL();
        System.assert(returnString != null, 'Return String is blank');
            
    }

    @isTest
    static void contentDocumentTest() 
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;

        System.runAs(usr)
        {
            Test.startTest();
            Contract cse=new Contract();
            Account acc = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            insert acc;
            cse.accountId = acc.Id;
            insert cse;
            
            Id libraryRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName().get('Library Content').getRecordTypeId();
            List<ContentVersion> insertedCV = new List<ContentVersion>();

            ContentVersion contentRecord = new ContentVersion();
            contentRecord.title = 'Test0';
            contentRecord.versiondata = Blob.valueOf('This is a test attachement0');
            contentRecord.PathOnClient = 'Test0';
            contentRecord.isMajorVersion = true;
            contentRecord.RecordTypeId = libraryRecordTypeId;
            contentRecord.Applicable_Species__c = 'Poultry'; //For the first record, make the species Poultry
           
            insertedCV.add(contentRecord);            
            insert insertedCV;
            
            List<ContentDocumentLink> newCdls = new List<ContentDocumentLink>();
            for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :usr.Id]) {
                ContentDocumentLink newCdl = new ContentDocumentLink();
                newCdl.ContentDocumentId = cdl.ContentDocumentId;
                newCdl.LinkedEntityId = acc.Id;
                newCdls.add(newCdl);
            }
            List<ZTS_US_Contract_Doc_Id_search_string__c> css = new List <ZTS_US_Contract_Doc_Id_search_string__c>();
            ZTS_US_Contract_Doc_Id_search_string__c cs1= new ZTS_US_Contract_Doc_Id_search_string__c(Name='MZR BIOS',Contract_Attachment_Identifier__c='Test0',Contract_Field_Name__c='Bios_MVP_Doc_ID__c');
            ZTS_US_Contract_Doc_Id_search_string__c cs2= new ZTS_US_Contract_Doc_Id_search_string__c(Name='MZR',Contract_Attachment_Identifier__c='MZR_Confirmation;' + String.valueOf(newCdls[0].ContentDocumentId),Contract_Field_Name__c='Bios_MVP_Doc_ID__c');
            css.add(cs1);
            css.add(cs2);
            insert css;
            insert newCdls;

            acc.MZR_Doc_Id__c = newCdls[0].Id;
            update acc;

            List<ContentDocument> oldCds = new List<ContentDocument>();
            Map<Id, ContentDocument> oldCdsMap = new Map<Id, ContentDocument>();
            List<ContentDocument> newCds = new List<ContentDocument>();
            Map<Id, ContentDocument> newCdsMap = new Map<Id, ContentDocument>();
            
            for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id]) {
                ContentDocument oldCd = new ContentDocument();
                oldCd.Id = cdl.ContentDocumentId;
                oldCds.add(oldCd);
                oldCdsMap.put(oldCd.Id, oldCd);
                
                ContentDocument newCd = new ContentDocument();
                newCd.Id = cdl.ContentDocumentId;
                newCd.Description = 'test description';
                newCds.add(newCd);
                newCdsMap.put(newCd.Id, newCd);
            }
            ContentDocumentTriggerHandler cdHandler = new ContentDocumentTriggerHandler();
            System.debug('$$$ newCds: '+newCds);
            System.debug('$$$ newCdsMap: '+newCdsMap);
            cdHandler.afterInsert(newCds, newCdsMap);

            cdHandler.afterUpdate(oldCds, oldCdsMap, newCds, newCdsMap);

            cdHandler.afterDelete(newCds, newCdsMap);

            
            delete newCds; 

            undelete newCds;

            List<ContentDocumentLink> cdls = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :usr.Id];
            List<ContentDocumentLink> cdlsTask = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id];
            Test.stopTest();
        }

    }

    @isTest
    static void contentDocumentTestWithContracts() 
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;

        System.runAs(usr)
        {
            Test.startTest();

            USContentDocumentTriggerService.forceFailure = true;
            Contract cse=new Contract();
            Account acc = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            insert acc;
            cse.accountId = acc.Id;
            insert cse;
            
            Id libraryRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName().get('Library Content').getRecordTypeId();
            List<ContentVersion> insertedCV = new List<ContentVersion>();

            ContentVersion contentRecord = new ContentVersion();
            contentRecord.title = 'Test0';
            contentRecord.versiondata = Blob.valueOf('This is a test attachement0');
            contentRecord.PathOnClient = 'Test0';
            contentRecord.isMajorVersion = true;
            contentRecord.RecordTypeId = libraryRecordTypeId;
            contentRecord.Applicable_Species__c = 'Poultry'; //For the first record, make the species Poultry
           
            insertedCV.add(contentRecord);            
            insert insertedCV;
            
            List<ContentDocumentLink> newCdls = new List<ContentDocumentLink>();
            for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :usr.Id]) {
                ContentDocumentLink newCdl = new ContentDocumentLink();
                newCdl.ContentDocumentId = cdl.ContentDocumentId;
                newCdl.LinkedEntityId = cse.Id;
                newCdls.add(newCdl);
            }
            List<ZTS_US_Contract_Doc_Id_search_string__c> css = new List <ZTS_US_Contract_Doc_Id_search_string__c>();
            ZTS_US_Contract_Doc_Id_search_string__c cs1= new ZTS_US_Contract_Doc_Id_search_string__c(Name='MZR BIOS',Contract_Attachment_Identifier__c='Test0',Contract_Field_Name__c='Bios_MVP_Doc_ID__c');
            ZTS_US_Contract_Doc_Id_search_string__c cs2= new ZTS_US_Contract_Doc_Id_search_string__c(Name='MZR',Contract_Attachment_Identifier__c='MZR_Confirmation;' + String.valueOf(newCdls[0].ContentDocumentId),Contract_Field_Name__c='Bios_MVP_Doc_ID__c');
            css.add(cs1);
            css.add(cs2);
            insert css;
            insert newCdls;

            acc.MZR_Doc_Id__c = newCdls[0].Id;
            update acc;

            List<ContentDocument> oldCds = new List<ContentDocument>();
            Map<Id, ContentDocument> oldCdsMap = new Map<Id, ContentDocument>();
            List<ContentDocument> newCds = new List<ContentDocument>();
            Map<Id, ContentDocument> newCdsMap = new Map<Id, ContentDocument>();
            
            for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :cse.Id]) {
                ContentDocument oldCd = new ContentDocument();
                oldCd.Id = cdl.ContentDocumentId;
                oldCds.add(oldCd);
                oldCdsMap.put(oldCd.Id, oldCd);
                
                ContentDocument newCd = new ContentDocument();
                newCd.Id = cdl.ContentDocumentId;
                newCd.Description = 'test description';
                newCds.add(newCd);
                newCdsMap.put(newCd.Id, newCd);
            }
            ContentDocumentTriggerHandler cdHandler = new ContentDocumentTriggerHandler();
            System.debug('$$$ newCds: '+newCds);
            System.debug('$$$ newCdsMap: '+newCdsMap);
            cdHandler.afterInsert(newCds, newCdsMap);

            cdHandler.afterUpdate(oldCds, oldCdsMap, newCds, newCdsMap);

            cdHandler.afterDelete(newCds, newCdsMap);

            
            delete newCds; 

            undelete newCds;

            List<ContentDocumentLink> cdls = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :usr.Id];
            List<ContentDocumentLink> cdlsTask = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id];
            Test.stopTest();
            
        }

    }


    /* ------------------- Helper Methods ------------------- */

    //@testSetup
    static List<ContentVersion> createContentVersions() {
        
        Id libraryRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName().get('Library Content').getRecordTypeId();
        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
        
        for (Integer i = 0; i < 10; i++) {
            ContentVersion contentRecord = new ContentVersion();
            contentRecord.title = 'Test' + i;
            contentRecord.versiondata = Blob.valueOf('This is a test attachement' + i);
            contentRecord.PathOnClient = 'Test' + i;
            contentRecord.isMajorVersion = true;
            contentRecord.RecordTypeId = libraryRecordTypeId;
            if (i == 0) {
                contentRecord.Applicable_Species__c = 'Poultry'; //For the first record, make the species Poultry
            } else {
                contentRecord.Applicable_Species__c = 'Equine'; //The remaining records should be Equine
            }
            
            contentVersionsToInsert.add(contentRecord);
        }

        insert contentVersionsToInsert;
        return contentVersionsToInsert;
        
    }
    
}