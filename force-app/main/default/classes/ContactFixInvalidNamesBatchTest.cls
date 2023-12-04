@isTest
public class ContactFixInvalidNamesBatchTest {
    public static final String CONTACT_STATUS = 'Pending - Incorrect First or Last Name';
    @testSetup
    static void createTestData() {
        list<Contact> lstContactsToInsert = new list<Contact>();
        //Create couple of contacts with invalid first name or last name combinations.
        Contact con = new Contact(FirstName = 'X', LastName = 'George', Email = 'james.george@testEmail1.com', ZTS_US_Profession__c = 'Academia', ZTS_US_Job_Function__c= 'Clinical Faculty' );
        Contact con1 = new Contact(FirstName = '.', LastName = '*', Email = 'jamesx.george1@testEmail2.com', ZTS_US_Profession__c = 'Academia', ZTS_US_Job_Function__c= 'Clinical Faculty');
        lstContactsToInsert.add(con);
        lstContactsToInsert.add(con1);
        INSERT lstContactsToInsert;
        System.assertEquals(2,lstContactsToInsert.size(), 'Insertion of contacts failed');
    }

    //TEST METHODS

    static testMethod void testBatchForUpdatingContacts(){
        List<Contact> lstContact =  [SELECT Id FROM Contact limit 2];
        Test.startTest();
        ContactFixInvalidNamesBatch batch = new ContactFixInvalidNamesBatch();
        Database.executebatch(batch);        
        Test.stopTest();        
    }
}