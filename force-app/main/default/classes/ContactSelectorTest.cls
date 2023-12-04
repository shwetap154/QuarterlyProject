/**
* @description       : Test class for ContactSelector
* @author            : Ethan Hirsch @ Zoetis Inc
* @group             : 
* @last modified on  : 04-19-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   05-06-2022   Ethan Hirsch @ Zoetis Inc   Initial Version
* 1.1   04-11-2023   Padma Nerella @ Zoetis Inc  Added selectInternationalContactByIdwithAccConAffTest
**/
@isTest
private class ContactSelectorTest {
    private static final Integer maxContacts = 5;
    
    @TestSetup
    private static void setup(){
        
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        testUser.ZTS_EU_Market__c = 'United Kingdom';
        
        System.runAs(testUser) {
            List<Account> insertAccList = new List<Account>();
            List<Account> acc = ZTS_DataUtilityTest.createAccountRecord(2);
            acc[0].ZTS_EU_Market__c = 'United Kingdom';
            acc[0].ZTS_EU_Account_Status__c='Active';
            insertAccList.addAll(acc);
            
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            insert insertAccList;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            
            List<Contact> contacts = new List<Contact>();
            for (Contact contact : TestDataFactory.createContacts(null, maxContacts, false)) {
                contact.ZTS_US_Profession__c = 'Veterinarian';
                contact.ZTS_US_Job_Function__c = 'Veterinary Resident';
                contacts.add(contact);
            }
            List<Contact> intlContacts = ZTS_DataUtilityTest.createContactRecord(2);
            intlContacts[0].AccountId = insertAccList[0].Id;
            intlContacts[0].ZTS_EU_Contact_Status__c = 'Active';
            intlContacts[0].ZTS_EU_Market__c ='Spain';
            intlContacts[1].AccountId = insertAccList[1].Id;
            intlContacts[1].ZTS_EU_Contact_Status__c = 'Active';
            intlContacts[1].ZTS_EU_Market__c ='United States';
            contacts.addAll(intlContacts);
            insert contacts;
        }
        
    }
    
    @isTest
    private static void selectPetOwnerContactsById_Test() {
        Test.startTest();
        List<Contact> contacts = ContactSelector.newInstance().selectPetOwnerContactsById(
            new List<Id>(retrieveAllContactIds()));
        Test.stopTest();
        
        System.assertEquals(maxContacts, contacts.size(), 'More/Less Contacts were found than expected.');
    }
    
    @isTest
    private static void selectById_Test() {
        Test.startTest();
        List<Contact> contacts = ContactSelector.newInstance().selectById(
            retrieveAllContactIds());
        Test.stopTest();
        
        System.assertEquals(maxContacts, contacts.size(), 'More/Less Contacts were found than expected.');
    }
    
    private static Set<Id> retrieveAllContactIds() {
        return new Map<Id, Contact>([
            SELECT Id
            FROM Contact
            LIMIT :maxContacts
        ]).keySet();
    }
    
    @isTest
    private static void selectContactsToUpdateEmail_Test(){
        List<Account> acc1 = ZTS_DataUtilityTest.createAccountRecord(1);
        acc1[0].name = 'Test AccountT';
        insert acc1;
		 
        List<Contact> conList = new List<Contact>();
        Id rtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Account_Contact').getRecordTypeId(); 
        Contact cont = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
        cont.AccountId = acc1[0].Id;
        cont.ZTS_EU_Contact_Status__c = 'Active';
        cont.ZTS_US_Profession__c = 'Academia';
        cont.ZTS_US_Job_Function__c= 'Clinical Faculty';
        cont.RecordTypeId =rtId;
        conList.add(cont);
        insert conList;
        
        acc1[0].Email__c = 'test@zoetis.com';
        acc1[0].ZTS_US_Email_Opt_Out__c = true;
        acc1[0].ZTS_Invalid_Email__c = true;
        List<Account> accountList = new List<Account>();
        accountList.add(acc1[0]);  
        DispatchTriggerHandler.firstTimeTracker.clear();
        update accountList;
        Test.startTest();
        List<Contact> contacts = ContactSelector.newInstance().selectContactsToUpdateEmail(accountList);
        Test.stopTest();
        List<Contact> contacts1 = [Select Id,Interface_Email__c,AccountId From Contact where AccountId IN:accountList and Id IN: contacts];
        System.assertEquals('test@zoetis.com', contacts1[0].Interface_Email__c);
    }
    
    @isTest
    private static void selectInternationalContactByIdwithAccConAffTest(){
        
        List<Contact> contactList = [Select Id, Name, ZTS_EU_Contact_Status__c,AccountId,ZTS_EU_Rep_Contact_Status__c from Contact];
        Set<Id> conIdSet =  new Set<Id>();
        for(Contact con : contactList){
            conIdSet.add(con.Id);
        }
        
        Test.startTest();
        List<Contact> contactListToUpdate = ContactSelector.newInstance().selectInternationalContactsByIdwithAffiliations(conIdSet);
        Test.stopTest();
        System.assertEquals(6, contactListToUpdate.size(), '6 Contact record found to update contact status from AccountContactAffiliation');
        
    }
    
	@isTest
    private static void getCaseDetailsTest(){
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Case newCase = new Case(Status = 'New',Origin = 'RefLabs Portal',Type = 'Master Data Inquiry',Subject = 'RefLabs Portal Case test',
                                Description = 'Portal Case',SuppliedEmail = 'test11@reflabs.com',ZTS_EU_Market__c = 'Canada',AccountId = testAccount.Id);
        insert newCase;
        
        Contact testContact = new Contact(AccountId = testAccount.Id,LastName = 'Test Contact',ZTS_US_Profession__c = 'Academia',
                                          ZTS_US_Job_Function__c= 'Clinical Faculty');
        insert testContact;
        
        Test.startTest();
        List<Contact> retrievedContacts = ContactSelector.getContactsByCaseId(newCase.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, retrievedContacts, 'Retrieved Contacts list should not be null');
    }
}