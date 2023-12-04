/****************************************************************************************************************************************** 
* Class Name : ZTS_US_Attachment_Test
* Description  : Test class for CountAttachments Trigger
* Created By   : Laxmikanth
* Created Date : 10/29/2015
*****************************************************************************************************************************************/
@isTest
public with sharing class ZTS_US_Attachment_Test{
    private static final string testUserFirstName = 'ZTS_US_Attachment_TestUser';
    private static final string mzrIdentifier = 'MZR_Confirmation';
    private static final string biosMvpIdentifier = 'MZR_BIOS_2017_Confirmation';
    private static final string vgpEnrollmentIdentifier1 = '_VGP_SS.PNG';
    private static final string vgpEnrollmentIdentifier2 = 'VGP.PNG';
    private static final string installIdentifier = '   In-Service Checklist';
    private static final string rsaIdentifier = '_RSA_';
    private static final string invalidIdentifier = 'INVALID';
    
    @testSetup
    static void setupTestData(){
        User testUser =  ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        testUser.FirstName = testUserFirstName;
        testUser.zts_eu_market__c = 'United States';

        User intlTestUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlTestUser.zts_eu_market__c = 'Poland';
        insert new List<User> {testUser, intlTestUser};

        List<ZTS_US_Contract_Doc_Id_search_string__c> contractDocIdSearchStrings = new List<ZTS_US_Contract_Doc_Id_search_string__c> {
            ZTS_DataUtilityTest.createContractDocIdSearchString('MZR', mzrIdentifier, 'MZR_Doc_Id__c'),
            ZTS_DataUtilityTest.createContractDocIdSearchString('MZR BIOS', biosMvpIdentifier, 'Bios_MVP_Doc_ID__c'),
            ZTS_DataUtilityTest.createContractDocIdSearchString('VGP', vgpEnrollmentIdentifier1 + ';' +vgpEnrollmentIdentifier2, 'VGP_Enrollment_Doc_ID__c'),
            ZTS_DataUtilityTest.createContractDocIdSearchString('Checklist', installIdentifier, 'DX_Install_Doc_ID__c'),
            ZTS_DataUtilityTest.createContractDocIdSearchString('RSA', rsaIdentifier, 'RSA_Flag_Id__c'),
            // Blank value added for code coverage and to make sure no code errors due to missing values
            ZTS_DataUtilityTest.createContractDocIdSearchString('Blank', null, null)
        };

        insert contractDocIdSearchStrings;

        // These records are always created as a User in the United States Market
        System.runAs(testUser) {
            List<Account> testAccounts = ZTS_DataUtilityTest.createAccountRecord(2);
            insert testAccounts;

            Contact testContact = ZTS_DataUtilityTest.createContactRecord(1)[0];
            testContact.ZTS_EU_Market__c = 'United States';
            insert testContact;
        }

        // This Account is created as an International User
        System.runAs(testUser) {
            List<Account> testAccounts = ZTS_EU_DataUtilityTest.createAccountRecord(2);
            insert testAccounts;
        }

    }
    
    @isTest
    private static void testAttachments()
    {
        Contract cse=new Contract();
        Account testAccount = retrieveTestAccount();
        System.runAs(retrieveUnitTestUser())
        {      
            cse.accountid=testAccount.id;
            insert cse;
            List<Attachment> attcs = new List<Attachment>();
            for(integer i=1;i<=2;i++){
                Attachment attach=new Attachment();    
                attach.Name='Unit Test Attachment+i';
                Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body+i');
                attach.body=bodyBlob;
                attach.parentId=cse.id;
                attcs.add(attach);
            }
            insert attcs;
            
            List<Attachment> attachments=[select id, name from Attachment where parent.id=:cse.id];
            System.assertEquals(2, attachments.size());
            delete attcs;
        }
    }
    
    @isTest
    private static void testSetDocumentFieldOnInsert()
    {
        Account testAccount = retrieveTestAccount();
        System.runAs(retrieveUnitTestUser())
        {
            Attachment testAttachment = ZTS_DataUtilityTest.createAttachment(mzrIdentifier, testAccount.Id);
            
            Test.startTest();
                insert testAttachment;
            Test.stopTest();
            
            testAccount = retrieveTestAccount(testAccount.Id);
            system.assertEquals(testAttachment.Id, testAccount.MZR_Doc_Id__c);
        }
    }

    @isTest
    private static void testSetDocumentFieldOnUpdate()
    {
        Account testAccount = retrieveTestAccount();
        System.runAs(retrieveUnitTestUser())
        {
            Attachment testAttachment = ZTS_DataUtilityTest.createAttachment(invalidIdentifier, testAccount.Id);
            insert testAttachment;

            // Sanity Check: Make sure the MZR Doc Id Field was not set
            testAccount = retrieveTestAccount(testAccount.Id);
            system.assertNotEquals(testAttachment.Id, testAccount.MZR_Doc_Id__c);

            testAttachment.Name = mzrIdentifier;
            Test.startTest();
                update testAttachment;
            Test.stopTest();
            
            testAccount = retrieveTestAccount(testAccount.Id);
            system.assertEquals(testAttachment.Id, testAccount.MZR_Doc_Id__c);
        }
    }

    @isTest
    private static void testSetDocumentFieldOnUndelete()
    {
        Account testAccount = retrieveTestAccount();
        System.runAs(retrieveUnitTestUser())
        {
            // Bypass Attachment trigger on insert so that the MZR Document field is only set on Undelete
            DispatchTriggerHandler.bypass('AttachmentTriggerHandler');
            Attachment testAttachment = ZTS_DataUtilityTest.createAttachment(mzrIdentifier, testAccount.Id);
            insert testAttachment;
            DispatchTriggerHandler.clearBypass('AttachmentTriggerHandler');

            delete testAttachment;

            Test.startTest();
                undelete testAttachment;
            Test.stopTest();
            
            testAccount = retrieveTestAccount(testAccount.Id);
            system.assertEquals(testAttachment.Id, testAccount.MZR_Doc_Id__c);
        }
    }

    @isTest
    private static void testSetDocumentFieldOnInsert_MultipleValueIdentifier()
    {
        Account testAccount = retrieveTestAccount();
        System.runAs(retrieveUnitTestUser())
        {
            Attachment testAttachment = ZTS_DataUtilityTest.createAttachment('Test' + vgpEnrollmentIdentifier1 + 'Test', testAccount.Id);
            
            Test.startTest();
                insert testAttachment;
            Test.stopTest();
            
            testAccount = retrieveTestAccount(testAccount.Id);
            system.assertEquals(testAttachment.Id, testAccount.VGP_Enrollment_Doc_ID__c);
        }
    }

    @isTest
    private static void testSetDocumentFieldOnUpdate_MultipleValueIdentifier()
    {
        Account testAccount = retrieveTestAccount();
        System.runAs(retrieveUnitTestUser())
        {
            Attachment testAttachment = ZTS_DataUtilityTest.createAttachment(invalidIdentifier, testAccount.Id);
            insert testAttachment;

            // Sanity Check: Make sure the VGP Enrollment Doc Id Field was not set
            testAccount = retrieveTestAccount(testAccount.Id);
            system.assertNotEquals(testAttachment.Id, testAccount.VGP_Enrollment_Doc_ID__c);

            testAttachment.Name = vgpEnrollmentIdentifier2.toLowerCase() + ' Test';
            Test.startTest();
                update testAttachment;
            Test.stopTest();
            
            testAccount = retrieveTestAccount(testAccount.Id);
            system.assertEquals(testAttachment.Id, testAccount.VGP_Enrollment_Doc_ID__c);
        }
    }

    @isTest
    private static void testSetDocumentFieldOnUndelete_MultipleValueIdentifier()
    {
        Account testAccount = retrieveTestAccount();
        System.runAs(retrieveUnitTestUser())
        {
            // Bypass Attachment trigger on insert so that the VGP Enrollment Document field is only set on Undelete
            DispatchTriggerHandler.bypass('AttachmentTriggerHandler');
            Attachment testAttachment = ZTS_DataUtilityTest.createAttachment(vgpEnrollmentIdentifier1 + vgpEnrollmentIdentifier2, testAccount.Id);
            insert testAttachment;
            DispatchTriggerHandler.clearBypass('AttachmentTriggerHandler');

            delete testAttachment;

            Test.startTest();
                undelete testAttachment;
            Test.stopTest();
            
            testAccount = retrieveTestAccount(testAccount.Id);
            system.assertEquals(testAttachment.Id, testAccount.VGP_Enrollment_Doc_ID__c);
        }
    }

    @isTest
    private static void testSetDocumentFieldOnInsert_RSAIdentifier()
    {
        Account testAccount = retrieveTestAccount();
        System.runAs(retrieveUnitTestUser())
        {
            Attachment testAttachment = ZTS_DataUtilityTest.createAttachment(rsaIdentifier, testAccount.Id);
            
            Test.startTest();
                insert testAttachment;
            Test.stopTest();
            
            testAccount = retrieveTestAccount(testAccount.Id);
            system.assertEquals(testAttachment.Id, testAccount.RSA_Flag_Id__c);
            system.assertEquals(true, testAccount.RSA_Active__c);
        }
    }

    @isTest
    private static void testSetDocumentFieldOnUpdate_RSAIdentifier()
    {
        Account testAccount = retrieveTestAccount();
        System.runAs(retrieveUnitTestUser())
        {
            Attachment testAttachment = ZTS_DataUtilityTest.createAttachment(invalidIdentifier, testAccount.Id);
            insert testAttachment;

            // Sanity Check: Make sure the RSA fields Field were not set
            testAccount = retrieveTestAccount(testAccount.Id);
            system.assertNotEquals(testAttachment.Id, testAccount.RSA_Flag_Id__c);
            system.assertNotEquals(true, testAccount.RSA_Active__c);

            testAttachment.Name = rsaIdentifier;
            Test.startTest();
                update testAttachment;
            Test.stopTest();
            
            testAccount = retrieveTestAccount(testAccount.Id);
            system.assertEquals(testAttachment.Id, testAccount.RSA_Flag_Id__c);
            system.assertEquals(true, testAccount.RSA_Active__c);
        }
    }

    @isTest
    private static void testSetDocumentFieldOnUndelete_RSAIdentifier()
    {
        Account testAccount = retrieveTestAccount();
        System.runAs(retrieveUnitTestUser())
        {
            // Bypass Attachment trigger on insert so that the RSA fields are only set on Undelete
            DispatchTriggerHandler.bypass('AttachmentTriggerHandler');
            Attachment testAttachment = ZTS_DataUtilityTest.createAttachment(rsaIdentifier, testAccount.Id);
            insert testAttachment;
            DispatchTriggerHandler.clearBypass('AttachmentTriggerHandler');

            delete testAttachment;

            Test.startTest();
                undelete testAttachment;
            Test.stopTest();
            
            testAccount = retrieveTestAccount(testAccount.Id);
            system.assertEquals(testAttachment.Id, testAccount.RSA_Flag_Id__c);
            system.assertEquals(true, testAccount.RSA_Active__c);
        }
    }

    @isTest
    private static void testSetDocumentFieldOnInsert_Multiple() {
        List<Account> testAccounts = retrieveAllUSTestAccounts();
        Contact contact = retrieveTestContact();
        system.runAs(retrieveUnitTestUser()) {
            Id account1Id = testAccounts[0].Id;
            Id account2Id = testAccounts[1].Id;
            Attachment mzrAttachment = ZTS_DataUtilityTest.createAttachment(mzrIdentifier, account1Id);
            Attachment biosMvpAttachment = ZTS_DataUtilityTest.createAttachment(biosMvpIdentifier, account1Id);
            Attachment vgpAttachment = ZTS_DataUtilityTest.createAttachment(vgpEnrollmentIdentifier1, account1Id);
            Attachment installAttachment = ZTS_DataUtilityTest.createAttachment(installIdentifier, account1Id);
            Attachment rsaAttachment = ZTS_DataUtilityTest.createAttachment(rsaIdentifier, account1Id);
            
            Attachment mzrAttachmentAccount2 = ZTS_DataUtilityTest.createAttachment(mzrIdentifier, account2Id);
            Attachment vgpAttachmentAccount2 = ZTS_DataUtilityTest.createAttachment(vgpEnrollmentIdentifier2, account2Id);

            Attachment contactAttachment = ZTS_DataUtilityTest.createAttachment(mzrIdentifier, contact.Id);
            
            List<Attachment> attachments = new List<Attachment>{
                mzrAttachment, biosMvpAttachment, vgpAttachment, installAttachment, rsaAttachment, mzrAttachmentAccount2,
                vgpAttachmentAccount2, contactAttachment
            };

            Test.startTest();
                insert attachments;
            Test.stopTest();

            testAccounts = retrieveAllUSTestAccounts();
            for (Account account : testAccounts) {
                // To be safe in case Accounts are returned in different order, 
                // the ids cached above are used to identify the Account
                if (account.Id == account1Id) {
                    system.assertEquals(mzrAttachment.Id, account.MZR_Doc_Id__c);
                    system.assertEquals(biosMvpAttachment.Id, account.Bios_MVP_Doc_ID__c);
                    system.assertEquals(vgpAttachment.Id, account.VGP_Enrollment_Doc_ID__c);
                    system.assertEquals(installAttachment.Id, account.DX_Install_Doc_ID__c);
                    system.assertEquals(rsaAttachment.Id, account.RSA_Flag_Id__c);
                    system.assertEquals(true, account.RSA_Active__c);
                }
                else if (account.Id == account2Id) {
                    system.assertEquals(mzrAttachmentAccount2.Id, account.MZR_Doc_Id__c);
                    system.assertEquals(vgpAttachmentAccount2.Id, account.VGP_Enrollment_Doc_ID__c);
                }
            }
        }
    }

    @isTest
    private static void testSetDocumentFieldOnInsert_NonUSAccount()
    {
        Account testAccount = retrieveIntlTestAccount();
        System.runAs(retrieveUnitTestUser())
        {
            Attachment testAttachment = ZTS_DataUtilityTest.createAttachment(rsaIdentifier, testAccount.Id);

            Test.startTest();
                insert testAttachment;
            Test.stopTest();
            
            testAccount = retrieveIntlTestAccount();
            system.assertNotEquals(testAttachment.Id, testAccount.RSA_Flag_Id__c);
            system.assertNotEquals(true, testAccount.RSA_Active__c);
        }
    }

    @isTest
    private static void testSetDocumentFieldOnInsert_NonAccount()
    {
        Contact testContact = retrieveTestContact();
        System.runAs(retrieveUnitTestUser()) {
            Attachment testAttachment = ZTS_DataUtilityTest.createAttachment(rsaIdentifier, testContact.Id);

            Test.startTest();
                insert testAttachment;
            Test.stopTest();
            
            // Nothing to assert other than no error occurred
        }
    }

    // Test method retrieves the user created in testSetup so tests can run as a US System Admin User.
    // Results are sorted by CreatedDate to decrease the liklihood of pulling back an existing User
    private static User retrieveUnitTestUser() {
        return [
            SELECT Id 
            FROM User WHERE FirstName =: testUserFirstName 
            AND zts_eu_market__c = 'United States'
            ORDER BY CREATEDDATE DESC
            LIMIT 1];
    }

    // Retrieve all US Accounts created in the Unit Test.
    private static List<Account> retrieveAllUSTestAccounts() {
        return [SELECT Id, MZR_Doc_Id__c, Bios_MVP_Doc_ID__c, VGP_Enrollment_Doc_ID__c, DX_Install_Doc_ID__c, RSA_Flag_Id__c, RSA_Active__c
                FROM Account
                WHERE ZTS_EU_Market__c = 'United States'];
    }

    // Retrieve a US Account created in the Unit Test.
    private static Account retrieveTestAccount() {
        return retrieveAllUSTestAccounts()[0];
    }

    // Retrieve a US Account created in the Unit Test by Id.
    // This is used when a specific Account is needed for verification.
    private static Account retrieveTestAccount(Id accountId) {
        return [SELECT Id, MZR_Doc_Id__c, Bios_MVP_Doc_ID__c, VGP_Enrollment_Doc_ID__c, DX_Install_Doc_ID__c, RSA_Flag_Id__c, RSA_Active__c
                FROM Account
                WHERE Id =: accountId];
    }

    // Retrieve an Intl Account created in the Unit Test.
    private static Account retrieveIntlTestAccount() {
        return [SELECT Id, MZR_Doc_Id__c, Bios_MVP_Doc_ID__c, VGP_Enrollment_Doc_ID__c, DX_Install_Doc_ID__c, RSA_Flag_Id__c, RSA_Active__c
                FROM Account
                WHERE ZTS_EU_Market__c != 'United States'
                LIMIT 1];
    }

    // Retrieve an Intl Contact created in the Unit Test.
    private static Contact retrieveTestContact() {
        return [SELECT Id
                FROM Contact
                LIMIT 1];
    }
}