/**
 * @description       : Test class for RelatedListController
 * @author            : Alex Carstairs @ Slalom
 * @group             : 
 * @last modified on  : 06-08-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-22-2020   Alex Carstairs @ Slalom     Initial Version
 * 1.1   06-08-2022   Ethan Hirsch @ Zoetis Inc   Add header
**/
@isTest
public with sharing class RelatedListController_Test {

    static final Integer NUM_ACCS = 2;
    static final Integer NUM_CONS = 202;

    @isTest static void getData_Positive() {

        AccountTriggerHandler accHandler = new AccountTriggerHandler();
        accHandler.disableTrigger = true;
        ContactTriggerHandler conHandler = new ContactTriggerHandler();
        conHandler.disableTrigger = true;

        List<Account> testAccounts = new List<Account>();
        for(Integer i=0; i<NUM_ACCS; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account'+(i+1);
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';
            acc.BillingPostalCode = '12345';
            acc.BillingCity = 'Boca Raton';
            acc.BillingState = 'Florida';
            acc.BillingStreet = 'Elm Lane';
            testAccounts.add(acc);
        }
        insert testAccounts;

        List<Contact> testContacts = ZTS_EU_DataUtilityTest.createContactRecord(NUM_CONS);
        for(Integer i=0; i<NUM_CONS; i++) {
            Contact con = testContacts[i];
            con.AccountId = testAccounts[Math.mod(i,2)].Id;
        }
        insert testContacts;

        String objectApi = 'Contact';
        String fieldSetName = 'New_Contact';
        String filterField = 'AccountId';
        String filterId = String.valueOf(testAccounts[0].Id);
        
        Test.startTest();
            String actualRelatedContactsJson = RelatedListController.getData(objectApi, fieldSetName, filterId, filterField);
        Test.stopTest();

        System.assert(actualRelatedContactsJson!=null,'Json should not be null');

        List<Contact> actualRelatedContacts = (List<Contact>)JSON.deserialize(actualRelatedContactsJson,List<Contact>.class);
        System.assertEquals(NUM_CONS/2, actualRelatedContacts.size(), 'Half of the contacts should be returned' );

    }
}