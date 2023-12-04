/**
 * @description       : Test class for cse_caseApexActions
 * @author            : Slalom
 * @group             : 
 * @last modified on  : 07-27-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-23-2022   Slalom                      Initial Version
 * 1.8   07-27-2022   Ethan Hirsch @ Zoetis Inc   Change assertion of numberOfFilesOwned. 
 *                                                This was previously 9 due to the code in 
 *                                                USContentDocumentTriggerService.giveVmipsCaseOwnerAccessToEmailFile
 *                                                changing the Owner of one of the Files
 **/
@isTest
public with sharing class cse_caseApexActionstest {
    
    
    static testMethod void  giveNewvmipsCaseOwnerFileAccess() {
        // skip triggers to avoid cross dependencies when testing
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        System.runAs(usr)
        {
            // get VMIPS Case record type
            String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId(); 
            
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

            List<Case> testCases = new List<Case>(); 
            // insert 10 casses for mass testing
            for (integer i = 0; i < 10; i++) {
                Case testCase = new Case( Status = 'Open',Origin = 'Email',Type = 'Animal Complaint',RecordTypeId = animalRecordtypeId);
                testCases.add(testCase);
            }
            INSERT testCases;

            // insert email on case with attachment
            List<EmailMessage> emails = new List<EmailMessage>();
            Map<id, id> emailTocaseIds = new Map<id, id>();
            for (integer i = 0; i < 10; i++) {
                EmailMessage email = new EmailMessage();
                email.FromAddress = 'test@abc.org';
                email.Incoming = True;
                email.ToAddress= 'test@xyz.org';
                email.Subject = 'Test email';
                email.HtmlBody = 'Test email body';
                email.ParentId = testCases[i].Id;
                emails.add(email);
            } 
            insert emails;
            for (EmailMessage em : emails) {
                emailTocaseIds.put(em.id, em.ParentId);
            }
            
            
            DispatchTriggerHandler.bypass('ContentDocumentTriggerHandler');
            
            // Create content document and content version linking the file to the email
            List<contentVersion> contentVersions = new List<contentVersion>();
            for (integer i = 0; i < 10; i++) {
                Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
                ContentVersion contentVersion_1 = new ContentVersion(
                    Title='SampleTitle', 
                    PathOnClient ='SampleTitle.jpg',
                    VersionData = bodyBlob, 
                    origin = 'H'
                );
                contentVersions.add(contentVersion_1);
            }
            insert contentVersions;
            
            Map<Id, ContentVersion> docIdToVersionrecord = new Map<Id, ContentVersion>();
            list<contentVersion> versions = new List<contentVersion>([SELECT Id, Title, ContentDocumentId  FROM ContentVersion]);
            for (ContentVersion version : versions) {
                docIdToVersionrecord.put(version.ContentDocumentId, version );
            }

            List<ContentDocumentLink> contentlinks = new List<ContentDocumentLink>();
            for (integer i = 0; i < 10; i++) {
                ContentDocumentLink contentlink = new ContentDocumentLink();
                contentlink.LinkedEntityId = emails[0].id;
                contentlink.contentdocumentid = versions[i].contentdocumentid;
                contentlink.ShareType = 'V';
                contentlinks.add(contentlink);
            }
            insert contentlinks;
            DispatchTriggerHandler.clearBypass('ContentDocumentTriggerHandler');

            List<cse_caseApexActions.cse_caseApexActionsRequest> requests = new List<cse_caseApexActions.cse_caseApexActionsRequest>();
            for (integer i = 0; i < 10; i++) {
                cse_caseApexActions.cse_caseApexActionsRequest request = new cse_caseApexActions.cse_caseApexActionsRequest();
                request.oldCase = testCases[i];
                testCases[i].OwnerId = caseOwner.Id;
                request.newCase = testCases[i];
                request.emails = new List<EmailMessage>{emails[i]};
                requests.add(request);
            }

            cse_caseApexActions.giveNewvmipsCaseOwnerFileAccess(requests);

            // get all ContentDocumentLink for inserted cdl on email
            List<ContentDocumentLink> allCDLSforEmailFile = [SELECT Id, ContentDocumentId,  LinkedEntityId, shareType  
                                                            FROM ContentDocumentLink 
                                                            WHERE contentdocumentid = :docIdToVersionrecord.keySet() ];

            Integer numberOfFilesOwned = 0;
            ContentDocumentLink invalidCDLInsertedForOwner; 
            for (ContentDocumentLink insertedCDL : allCDLSforEmailFile) {
                // verify groupId sahred with is case owner id or 
                // email inserter id
                if (insertedCDL.LinkedEntityId == caseOwner.Id) {
                    numberOfFilesOwned += 1;
                    if (insertedCDL.shareType != 'I') {
                        invalidCDLInsertedForOwner = insertedCDL;
                        break;
                    }
                }
            }

            // verify cdl exists for user, case, and case owner
            System.assertEquals(null, invalidCDLInsertedForOwner, 'provided incorrect share type for case owner ' + invalidCDLInsertedForOwner);
            System.assertEquals(20, allCDLSforEmailFile.size(), 'Email contiains invalid number of record shares');
            System.assertEquals(10, numberOfFilesOwned, 'Did not provide ownership to case owner for all files');
        }
        
    }
}