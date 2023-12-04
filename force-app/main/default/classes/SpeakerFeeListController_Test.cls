/**
 * @description       : Test class for SpeakerFeeListController
 * @author            : Art Smorodin @ Slalom
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-13-2020   Art Smorodin @ Slalom       Initial version
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc   Fix issues with inserting Contacts that caused Unit Test failures
**/
@isTest
public with sharing class SpeakerFeeListController_Test {

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

        Contact testContact  =  ZTS_DataUtilityTest.createContactRecord(1)[0];
        testContact.ZTS_EU_Market__c = 'United States';
        testContact.ZTS_EU_Profession__c = 'Comercial';
        testContact.AccountId = testAcct.id;
        testContact.ZTS_Job_Function__c  = 'Admin Asst/Recep.';
        insert testContact;

        ZTS_US_Speaker_Fee__c testSpeakerFee =new ZTS_US_Speaker_Fee__c(
                                            ZTS_US_Contact__c = testContact.id,
                                            ZTS_EU_Market__c = 'United States'
        );
        insert testSpeakerFee;

        Test.startTest();
        List<ZTS_US_Speaker_Fee__c> speakerList = new List<ZTS_US_Speaker_Fee__c>();
        speakerList.add(testSpeakerFee);
        Test.setCurrentPage(Page.SpeakerFeenewListBtn);
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(speakerList);
        standardController.setSelected(speakerList);
        SpeakerFeeListController ext = new SpeakerFeeListController(standardController);
        System.assertNotEquals(null,ext.doRedirect());

        Test.stopTest();

    }

    private static testmethod void testFetchRecord() {
        Account testAcct = new Account(Name = 'TestAcct',
                                    	ZTS_EU_Market__c = 'United States',
                                    	ZTS_US_NARC_ID__c = 'TestNID',
                                        Type = 'Vet Practice',
                                        BillingPostalCode = '6789',
                                        BillingCity = 'testCity',
                                        BillingState = 'testState',
                                        BillingStreet = 'testStreet');

        insert  testAcct;

        Contact testContact  =  ZTS_DataUtilityTest.createContactRecord(1)[0];
        testContact.ZTS_EU_Market__c = 'United States';
        testContact.ZTS_EU_Profession__c = 'Comercial';
        testContact.AccountId = testAcct.id;
        testContact.ZTS_Job_Function__c  = 'Admin Asst/Recep.';
        insert testContact;
        Contact values = SpeakerFeeListController.getObjects(testContact.id);

        System.assertNotEquals(null, values);
    }
}