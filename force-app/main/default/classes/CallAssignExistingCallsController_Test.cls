@isTest
public with sharing class CallAssignExistingCallsController_Test {
    private static testMethod void doRedirectTest() {

        Account testAcct = new Account(Name = 'TestAcct',
                               ZTS_EU_Market__c = 'United States',
                               ZTS_US_NARC_ID__c = 'TestNID',
                               Type = 'Vet Practice',
                               BillingPostalCode = '6789',
                               BillingCity = 'testCity',
                               BillingState = 'testState',
                               BillingStreet = 'testStreet');
        insert  testAcct;

        Call__c testCall = new Call__c( Name = 'test',
                                ZTS_EU_Account__c = testAcct.id);

        Insert testCall;

        Test.startTest();
        List<Call__c> callList = new List<Call__c>();
        callList.add(testCall);
        Test.setCurrentPage(Page.AssignExistingCallsVF);
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(callList);
        standardController.setSelected(callList);
        CallAssignExistingCallsController ext = new CallAssignExistingCallsController(standardController);
        System.assertNotEquals(null,ext.doRedirect());

        Test.stopTest();

    }
}