/****************************************************************************************************************************************** 
* Class Name   : USContentDocumentTriggerServiceTest
* Description  : Test class for USContentDocumentTriggerService class
* Created By   : Aritra
* Created Date : 07/15/2021
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Aritra (Cognizant)      07/15/2021          Added logic from Attachment trigger test class Added logic to populate RSA Active flag on Account for US(SC-005631)
* Ahmed ELawad (Slalom)   05/04/2022          Added addContentDocumentLinkShareForCaseOwnerTest to test sharing a file with a case owner CSEPVW-120
*****************************************************************************************************************************************/
@isTest
public class USContentDocumentTriggerServiceTest {

    static testMethod void testAttachments()
    {
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContractTriggerHandler');
        Contract cse=new Contract();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        List<Account> accList=new List<Account>();
        accList=ZTS_DataUtilityTest.createAccountRecord(1);
        System.runAs(usr)
        {
            insert accList;
            
            
            cse.accountid=acclist[0].id;
            insert cse;

            ContentVersion contentVersion = new ContentVersion(Title = 'a picture',PathOnClient   = 'Pic.jpg',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
            insert contentVersion;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = cse.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            List<ContentDocumentLink> cdlList=[select Id, ContentDocument.Title,ContentDocument.Id,LinkedEntityId from ContentDocumentLink where LinkedEntityId=:cse.id];
            System.assertNotEquals(0, cdlList.size());
            
        }
    }
    
    static testMethod void testMZRdoc()
    {
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContractTriggerHandler');
        List<ZTS_US_Contract_Doc_Id_search_string__c> css = new List <ZTS_US_Contract_Doc_Id_search_string__c>();
        ZTS_US_Contract_Doc_Id_search_string__c cs1= new ZTS_US_Contract_Doc_Id_search_string__c(Name='MZR',Contract_Attachment_Identifier__c='MZR_Confirmation',Contract_Field_Name__c='MZR_Doc_Id__c');
        css.add(cs1);
        insert css;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        List<Account> accList=new List<Account>();
        accList=ZTS_DataUtilityTest.createAccountRecord(1);
        System.runAs(usr)
        {
            insert accList;
            
            
            ContentVersion contentVersion = new ContentVersion(Title = 'MZR_Confirmation',PathOnClient   = 'Pic.jpg',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
            insert contentVersion;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = accList[0].Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            
            
            documents[0].Description = 'Test Description';
            update documents[0]; 
            
            List<ContentDocumentLink> cdlList=[select Id, ContentDocument.Title,ContentDocument.Id,LinkedEntityId from ContentDocumentLink where LinkedEntityId=:accList[0].id];
            System.assertNotEquals(0, cdlList.size());
            
            accList[0].MZR_Doc_Id__c = documents[0].Id;
            update accList[0];
            
            delete documents;
        }
        
    }
    static testMethod void testCADBIOSdoc()
    {
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContractTriggerHandler');
        List<ZTS_US_Contract_Doc_Id_search_string__c> css = new List <ZTS_US_Contract_Doc_Id_search_string__c>();
        ZTS_US_Contract_Doc_Id_search_string__c cs1= new ZTS_US_Contract_Doc_Id_search_string__c(Name='MZR BIOS',Contract_Attachment_Identifier__c='MZR_BIOS_2017_Confirmation',Contract_Field_Name__c='Bios_MVP_Doc_ID__c');
        css.add(cs1);
        insert css;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        List<Account> accList=new List<Account>();
        accList=ZTS_DataUtilityTest.createAccountRecord(1);
        System.runAs(usr)
        {
            insert accList;
            
            ContentVersion contentVersion = new ContentVersion(Title = 'MZR_BIOS_2017_Confirmation_test_account',PathOnClient   = 'Pic.jpg',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
            insert contentVersion;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = accList[0].Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            
            
            documents[0].Description = 'Test Description';
            update documents[0]; 
            
            List<ContentDocumentLink> cdlList=[select Id, ContentDocument.Title,ContentDocument.Id,LinkedEntityId from ContentDocumentLink where LinkedEntityId=:accList[0].id];
            System.assertNotEquals(0, cdlList.size());
            
            accList[0].Bios_MVP_Doc_ID__c = documents[0].Id;
            update accList[0];
            
            delete documents;
            undelete documents; 
        }
    }
    //Added by Aritra on 07/20/2017 as part of SC-002327 
    static testMethod void testVGPdoc()
    {
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContractTriggerHandler');
        
        List<ZTS_US_Contract_Doc_Id_search_string__c> css = new List <ZTS_US_Contract_Doc_Id_search_string__c>();
        ZTS_US_Contract_Doc_Id_search_string__c cs1= new ZTS_US_Contract_Doc_Id_search_string__c(Name='VGP',Contract_Attachment_Identifier__c='_VGP_SS.PNG;_VGP.PNG',Contract_Field_Name__c='VGP_Enrollment_Doc_ID__c');
        css.add(cs1);
        insert css;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        List<Account> accList=new List<Account>();
        accList=ZTS_DataUtilityTest.createAccountRecord(1);
        System.runAs(usr)
        {
            insert accList;
            
            ContentVersion contentVersion = new ContentVersion(Title = 'Test VGP Enrollment Doc_VGP_SS',PathOnClient   = 'Pic.jpg',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
            insert contentVersion;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = accList[0].Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            
            
            documents[0].Description = 'Test Description';
            update documents[0]; 
            
            List<ContentDocumentLink> cdlList=[select Id, ContentDocument.Title,ContentDocument.Id,LinkedEntityId from ContentDocumentLink where LinkedEntityId=:accList[0].id];
            System.assertNotEquals(0, cdlList.size());
            
            accList[0].VGP_Enrollment_Doc_ID__c = documents[0].Id;
            update accList[0];
            
            delete documents;
            undelete documents;             
            
        }
    }
    static testMethod void testDXdoc()
    {
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContractTriggerHandler');

        List<ZTS_US_Contract_Doc_Id_search_string__c> css = new List <ZTS_US_Contract_Doc_Id_search_string__c>();
        ZTS_US_Contract_Doc_Id_search_string__c cs1= new ZTS_US_Contract_Doc_Id_search_string__c(Name='Checklist',Contract_Attachment_Identifier__c='In-Service Checklist',Contract_Field_Name__c='DX_Install_Doc_ID__c');
        css.add(cs1);
        insert css;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        List<Account> accList=new List<Account>();
        accList=ZTS_DataUtilityTest.createAccountRecord(1);
        System.runAs(usr)
        {
            insert accList;
            
            ContentVersion contentVersion = new ContentVersion(Title = 'Test In-Service Checklist',PathOnClient   = 'Pic.jpg',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
            insert contentVersion;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = accList[0].Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            
            
            documents[0].Description = 'Test Description';
            update documents[0]; 
            
            List<ContentDocumentLink> cdlList=[select Id, ContentDocument.Title,ContentDocument.Id,LinkedEntityId from ContentDocumentLink where LinkedEntityId=:accList[0].id];
            System.assertNotEquals(0, cdlList.size());
            
             
            delete documents;
            undelete documents;             
            
        }
    }
    
    static testMethod void testRSAAttachment()
    {
     
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContractTriggerHandler');

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        List<Account> accList=new List<Account>();
        accList=ZTS_DataUtilityTest.createAccountRecord(1);
        System.runAs(usr)
        {
            insert accList;
            
            
            ContentVersion contentVersion = new ContentVersion(Title = 'Test_RSA_Doc',PathOnClient   = 'Pic.jpg',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
            insert contentVersion;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = accList[0].Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            
            
            documents[0].Description = 'Test Description';
            update documents[0]; 
            
            List<ContentDocumentLink> cdlList=[select Id, ContentDocument.Title,ContentDocument.Id,LinkedEntityId from ContentDocumentLink where LinkedEntityId=:accList[0].id];
            System.assertNotEquals(0, cdlList.size());
            
            accList[0].RSA_Flag_Id__c = documents[0].Id;
            accList[0].RSA_Active__c = TRUE;
            update accList[0];
            
            delete documents;
            undelete documents;     
            
            
        }
    }
    
    @isTest
    static void contentDocumentTestWithContracts() 
    {
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContractTriggerHandler');

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
    @isTest
    static void contentDocumentTest() 
    {
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContractTriggerHandler');

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
    
    /* COMMENTING OUT TEST METHODS DUE TO DEFECT INC2570483, ROLLING BACK
    static testMethod void addContentDocumentLinkShareForCaseOwnerTestPositive() {     
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');

        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        List<Account> accList=new List<Account>();
        accList=ZTS_DataUtilityTest.createAccountRecord(1);
        System.runAs(usr)
        {
            // get VMIPS Case record type
            String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId(); 
            
            // create account
            Account acc = TestDataFactory.createAccount_US('CSE_vmipsCaseAttchmentsDPTest', true);
            
            // insert case owner
            Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User caseOwner = new User(
                Alias = 'standt', 
                Email='khasbch@lkzmsck.test', 
                FirstName = 'tester', 
                EmailEncodingKey='UTF-8', 
                LastName='Testing', 
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', 
                ProfileId = profile.Id, 
                TimeZoneSidKey='America/Los_Angeles', 
                Username='khasbch@lkzmsck.test',
                CurrencyIsoCode='EUR', 
                ZTS_EU_Market__c='United States',
                Default_Country__c='United States', 
                Country='United States'
            );
            INSERT caseOwner;

            // insert case with defaulted case owner
            Case testCase = new Case( Status = 'Open',Origin = 'Email',Type = 'Animal Complaint',RecordTypeId = animalRecordtypeId,ownerId = caseOwner.id);
            INSERT testCase;
            
            // ensure case owner is new user
            testCase = [SELECT ID, OwnerId FROM Case WHERE ID=:testCase.Id];
            System.assertEquals(caseOwner.Id, testCase.OwnerId, 'Case owner was setup incorrectly');
            

            // insert email on case with attachment
            EmailMessage email = new EmailMessage();
            email.FromAddress = 'test@abc.org';
            email.Incoming = True;
            email.ToAddress= 'test@xyz.org';
            email.Subject = 'Test email';
            email.HtmlBody = 'Test email body';
            email.ParentId = testCase.Id; 
            insert email;
            
            
            DispatchTriggerHandler.bypass('ContentDocumentTriggerHandler');

            // Create content document and content version linking the file to the email
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = email.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            DispatchTriggerHandler.clearBypass('ContentDocumentTriggerHandler');
            
            // update the document to trigger the contentDocumentTriggerHanldler
            ContentDocument document = [SELECT Id, Title FROM ContentDocument WHERE id = :contentVersion_2.contentdocumentid];
            document.title = 'New Title';
            update document;

            // get all ContentDocumentLink for inserted cdl on email
            List<ContentDocumentLink> allCDLSforEmailFile = [SELECT Id, ContentDocumentId,  LinkedEntityId, shareType  
                                                            FROM ContentDocumentLink 
                                                            WHERE contentdocumentid = :contentVersion_2.contentdocumentid ];

            ContentDocumentLink caseOwnerCDL;
            
            for (ContentDocumentLink insertedCDL : allCDLSforEmailFile) {
                // verify groupId sahred with is case owner id or 
                // email inserter id
                if (insertedCDL.LinkedEntityId == caseOwner.Id) {
                    caseOwnerCDL = insertedCDL;
                    break;
                }
            }

            // verify cdl exists for user, case, and case owner
            System.assertEquals(2, allCDLSforEmailFile.size(), 'Email contiains invalid number of record shares');
            System.assertNotEquals(null, caseOwnerCDL, 'Did not insert a sharing for the case owner');
            System.assertEquals('I', caseOwnerCDL.ShareType, 'Did not provide collaborator access to case owner');
        }
    } 
    
    static testMethod void addContentDocumentLinkShareForCaseOwnerTestNegative() {     
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        List<Account> accList=new List<Account>();
        accList=ZTS_DataUtilityTest.createAccountRecord(1);
        System.runAs(usr)
        {
            // get VMIPS Case record type
            String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId(); 
            
            // insert case with defaulted case owner
            Case testCase = new Case( Status = 'Open',Origin = 'Email',Type = 'Animal Complaint',RecordTypeId = animalRecordtypeId);
            INSERT testCase;

            // insert email on case with attachment
            EmailMessage email = new EmailMessage();
            email.FromAddress = 'test@abc.org';
            email.Incoming = True;
            email.ToAddress= 'test@xyz.org';
            email.Subject = 'Test email';
            email.HtmlBody = 'Test email body';
            email.ParentId = testCase.Id; 
            insert email;
            
            
            DispatchTriggerHandler.bypass('ContentDocumentTriggerHandler');

            // Create content document and content version linking the file to the email
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = email.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            DispatchTriggerHandler.clearBypass('ContentDocumentTriggerHandler');
            
            // update the document to trigger the contentDocumentTriggerHanldler
            ContentDocument document = [SELECT Id, Title FROM ContentDocument WHERE id = :contentVersion_2.contentdocumentid];
            document.title = 'New Title';
            update document;

            // get all ContentDocumentLink for inserted cdl on email
            List<ContentDocumentLink> allCDLSforEmailFile = [SELECT Id, ContentDocumentId,  LinkedEntityId, shareType  
                                                            FROM ContentDocumentLink 
                                                            WHERE contentdocumentid = :contentVersion_2.contentdocumentid ];

            Integer countOfSharesWithCaseOwner = 0;
            testCase = [SELECT ID, OwnerId FROM Case WHERE ID=:testCase.Id];
            
            for (ContentDocumentLink insertedCDL : allCDLSforEmailFile) {
                // verify groupId sahred with is case owner id 
                if (insertedCDL.LinkedEntityId == testCase.OwnerId) countOfSharesWithCaseOwner += 1;
            }

            // verify cdl exists for user, case, and case owner
            System.assertEquals(1, countOfSharesWithCaseOwner, 'File contains too many contentDocumentLinks sharing with case owner');
        }
    } */
}