/**
 * @description       : Test class for AttendeeService
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-05-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   08-04-2022   Ethan Hirsch @ Zoetis Inc      Initial versions with tests for updateRelatedContacts
 * 1.1   08-05-2022   Ethan Hirsch @ Zoetis Inc      Assert Last Call Created By Fields
 **/
@isTest
private class AttendeesServiceTest {
    private static final String CONTACT_BLANK_CALLERS_LAST_NAME = 'BlankCallers';
    private static final String CONTACT_SINGLE_CALLERS_LAST_NAME = 'SingleCaller';
    private static final String CONTACT_MAX_LENGTH_CALLERS_LAST_NAME = 'maxCaller';
    private static final String PAST_CALLER_USERNAME = 'testcaller@zoetis.com.AttendeesServiceTest';

    @TestSetup
    private static void setup(){
        DispatchTriggerHandler.bypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.bypass('CallTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        Id systemAdminProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1].Id;

        User testUser = TestDataFactory.createUser(systemAdminProfileId, false);
        testUser.Username = PAST_CALLER_USERNAME;
        testUser.ZTS_EU_Market__c = 'United States';
        insert testUser;

        Account testAccount = TestDataFactory.createAccount_US('Test Account', true);

        List<Contact> contacts = TestDataFactory.createContacts(testAccount.Id, 3, false);
        contacts[0].LastName = CONTACT_BLANK_CALLERS_LAST_NAME;

        contacts[1].LastName = CONTACT_SINGLE_CALLERS_LAST_NAME;
        contacts[1].RecentCallers__c = String.format(';{0}', new List<Object> {testUser.Id});
        // Set the fields below to confirm they get overwritten
        contacts[1].Last_Call_Created_by__c = 'Test';
        contacts[1].Last_Call_Created_by_Email__c = 'Test@zoetis.com.fillinemail';

        contacts[2].LastName = CONTACT_MAX_LENGTH_CALLERS_LAST_NAME;
        // Set Recent Callers to 237 characters to prevent more User Ids from being added
        contacts[2].RecentCallers__c = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque';
        
        insert contacts;

        Call__c testCall = TestDataFactory.createCall(testAccount.Id, false);
        insert testCall;
    }

    @isTest
    private static void updateRelatedContacts_NoContact() {
       
        Attendee__c testAttendee = ZTS_EU_DataUtilityTest.createAttendees(new List<Contact>{new Contact()},
            retrieveTestCall())[0];
        
        Test.startTest();
            insert testAttendee;
        Test.stopTest();

        // No error should have occurred, but there is nothing to assert
        DispatchTriggerHandler.clearBypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.clearBypass('CallTriggerHandler');
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
        DispatchTriggerHandler.clearBypass('UserTriggerHandler');
    }

    @isTest
    private static void updateRelatedContacts_ContactBlankRecentCallers() {
        
        Contact testContact = retrieveTestContactByLastName(CONTACT_BLANK_CALLERS_LAST_NAME);

        Call__c testCall = retrieveTestCall();
        Attendee__c testAttendee = ZTS_EU_DataUtilityTest.createAttendees(new List<Contact>{testContact},
            testCall)[0];

        Test.startTest();
            insert testAttendee;
        Test.stopTest();

        testContact = retrieveContactWithCallInformation(testContact.Id);
        System.assertEquals(String.format(';{0}', new List<Object> {UserInfo.getUserId()}), 
            testContact.RecentCallers__c, 'Recent Callers was not set as expected.');

        assertLastCallCreatedByFields(testContact, testCall);
    }

    @isTest
    private static void updateRelatedContacts_ContactPopulatedRecentCallers() {
        
        Contact testContact = retrieveTestContactByLastName(CONTACT_SINGLE_CALLERS_LAST_NAME);
        String originalRecentCallers = testContact.RecentCallers__c;

        Call__c testCall = retrieveTestCall();
        Attendee__c testAttendee = ZTS_EU_DataUtilityTest.createAttendees(new List<Contact>{testContact},
            testCall)[0];

        Test.startTest();
            insert testAttendee;
        Test.stopTest();

        testContact = retrieveContactWithCallInformation(testContact.Id);
        System.assertEquals(String.format('{0};{1}', new List<Object> {originalRecentCallers, UserInfo.getUserId()}),
            testContact.RecentCallers__c, 'Recent Callers was not set as expected.');

        assertLastCallCreatedByFields(testContact, testCall);
    }

    @isTest
    private static void updateRelatedContacts_ContactPopulatedRecentCallersExistingCaller() {
  
        User testUser = [
            SELECT Id
            FROM User
            WHERE Username =: PAST_CALLER_USERNAME
            LIMIT 1];

        Contact testContact = retrieveTestContactByLastName(CONTACT_SINGLE_CALLERS_LAST_NAME);
        String originalRecentCallers = testContact.RecentCallers__c;

        Call__c testCall;
        System.runAs(testUser) {
            testCall = retrieveTestCall();
            Attendee__c testAttendee = ZTS_EU_DataUtilityTest.createAttendees(new List<Contact>{testContact},
                testCall)[0];

            Test.startTest();
                insert testAttendee;
            Test.stopTest();
        }

        testContact = retrieveContactWithCallInformation(testContact.Id);
        System.assertEquals(originalRecentCallers, testContact.RecentCallers__c,
            'Recent Callers changed unexpectedly.');

        assertLastCallCreatedByFields(testContact, testCall);
    }

    @isTest
    private static void updateRelatedContacts_SetRecentCallersMaxLength() {
        
        Contact testContact = retrieveTestContactByLastName(CONTACT_MAX_LENGTH_CALLERS_LAST_NAME);
        String originalRecentCallers = testContact.RecentCallers__c;

        Call__c testCall = retrieveTestCall();
        Attendee__c testAttendee = ZTS_EU_DataUtilityTest.createAttendees(new List<Contact>{testContact},
            testCall)[0];

        Test.startTest();
            insert testAttendee;
        Test.stopTest();

        testContact = retrieveContactWithCallInformation(testContact.Id);
        System.assertEquals(originalRecentCallers, testContact.RecentCallers__c,
            'Recent Callers changed unexpectedly.');

        assertLastCallCreatedByFields(testContact, testCall);
    }

    @isTest
    private static void updateRelatedContacts_SetRecentCallersNoContactEditAccess() {

         
        Id smallAnimalRepProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'US Small Animal Rep'
            LIMIT 1].Id;

        User testUser = TestDataFactory.createUser(smallAnimalRepProfileId, false);
        testUser.ZTS_EU_Market__c = 'United States';
        insert testUser;

        Id accountId = retrieveTestUSAccountId();

        AccountShare testShare = new AccountShare(
            AccountId = accountId,
            AccountAccessLevel = 'Read',
            ContactAccessLevel = 'Read',
            OpportunityAccessLevel = 'Read',
            UserOrGroupId = testUser.Id
        );

        insert testShare;

        Contact testContact = retrieveTestContactByLastName(CONTACT_BLANK_CALLERS_LAST_NAME);
        Call__c testCall = TestDataFactory.createCall(retrieveTestUSAccountId(), false);

        System.runAs(testUser) {
            insert testCall;

            Attendee__c testAttendee = ZTS_EU_DataUtilityTest.createAttendees(new List<Contact>{testContact},
                testCall)[0];

           Test.startTest();
                insert testAttendee;
          Test.stopTest();
        }

        Call__c afterInsertCall = [
            SELECT Id, ZTS_EU_Call_Owner__r.Name, ZTS_EU_Call_Owner__r.Email
            FROM Call__c
            WHERE Id =: testCall.Id];

        testContact = retrieveContactWithCallInformation(testContact.Id);
        System.assertEquals(String.format(';{0}', new List<Object> {testUser.Id}), 
            testContact.RecentCallers__c, 'Recent Callers was not set as expected.');

        assertLastCallCreatedByFields(testContact, afterInsertCall);
          
    }

    @isTest
    private static void updateRelatedContacts_SetRecentCallersMultipleCalls() {
        
        Map<Id, String> originalRecentCallersByContactId = new Map<Id, String>();
        List<Contact> contacts = new List<Contact>();
        for (Contact contact : [
            SELECT Id, RecentCallers__c
            FROM Contact
            WHERE LastName in: new List<String> {CONTACT_BLANK_CALLERS_LAST_NAME, CONTACT_SINGLE_CALLERS_LAST_NAME}]) {
            contacts.add(contact);

            String recentCallers = contact.RecentCallers__c;
            if (String.isBlank(recentCallers)) {
                recentCallers = '';
            }

            originalRecentCallersByContactId.put(contact.Id, recentCallers);
        }

        Call__c testCall = retrieveTestCall();
        List<Attendee__c> attendees = new List<Attendee__c>();
        // Create two Attendees for each Contact to verify the User is only added once to each and no issues occur
        attendees.addAll(ZTS_EU_DataUtilityTest.createAttendees(contacts,
            testCall));

        attendees.addAll(ZTS_EU_DataUtilityTest.createAttendees(contacts,
            testCall));

        Test.startTest();
            insert attendees;
        Test.stopTest();

        for (Contact testContact : [
            SELECT Id, LastName, RecentCallers__c, Last_Call_Created_by__c, Last_Call_Created_by_Email__c
            FROM Contact
            WHERE Id in: contacts]) {
            System.assertEquals(String.format('{0};{1}', new List<Object>{
                originalRecentCallersByContactId.get(testContact.Id), UserInfo.getUserId()}),
                testContact.RecentCallers__c, 'Recent Callers was not set as expected.');

            assertLastCallCreatedByFields(testContact, testCall);
        }
    }

    private static Call__c retrieveTestCall() {
        return [
            SELECT Id, ZTS_EU_Call_Owner__r.Name, ZTS_EU_Call_Owner__r.Email
            FROM Call__c
            LIMIT 1];
    }

    private static Id retrieveTestUSAccountId() {
        return [
            SELECT Id
            FROM Account
            WHERE ZTS_EU_Market__c = 'United States'
            LIMIT 1].Id;
    }

    private static Contact retrieveTestContactByLastName(String lastName) {
        return [
            SELECT Id, RecentCallers__c
            FROM Contact
            WHERE LastName =: lastName
            LIMIT 1];
    }

    private static Contact retrieveContactWithCallInformation(Id contactId) {
        return [
            SELECT RecentCallers__c, Last_Call_Created_by__c, Last_Call_Created_by_Email__c
            FROM Contact
            WHERE Id =: contactId
            LIMIT 1];
    }

    private static void assertLastCallCreatedByFields(Contact updatedContact, Call__c call) {
        System.assertEquals(updatedContact.Last_Call_Created_by__c, call.ZTS_EU_Call_Owner__r.Name,
            'Last Call Created By was not set as expected.');

        System.assertEquals(updatedContact.Last_Call_Created_by_Email__c, call.ZTS_EU_Call_Owner__r.Email,
            'Last Call Created By Email was not set as expected.');
    }
}