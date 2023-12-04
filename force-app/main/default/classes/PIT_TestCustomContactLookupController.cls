/**
 * @description       : Test class for PIT_TestCustomContactLookupC
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 06-03-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-29-2020   Unknown                     Initial Version
 * 1.1   06-03-2022   Ethan Hirsch @ Zoetis Inc   Fix Test errors due to validation rules
**/
@isTest
private class PIT_TestCustomContactLookupController {

    static testMethod void testController() {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();

        Account acc = new Account();
        acc.Name = 'test account';
        acc.ZTS_EU_Zip_Postal_Code__c = '12345';
        acc.BillingPostalCode = '12345';
        acc.BillingCity = 'Boca Raton';
        acc.BillingState = 'Florida';
        acc.BillingStreet = 'Elm Lane';
        acc.ZTS_EU_Market__c = 'United States';

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;

        System.runAs(usr){
            insert acc;
        }

        Contact ctc = new Contact();
        ctc.LastName = 'testLastName';
        ctc.ZTS_EU_Profession__c = 'Other';
        ctc.ZTS_Job_Function__c = 'Other';
        ctc.AccountId = acc.id;
        ctc.ZTS_EU_Market__c = 'United States';
        ctc.ZTS_US_Profession__c = 'Veterinarian';
        ctc.ZTS_US_Job_Function__c = 'Veterinary Resident';
        System.runAs(usr){
            insert ctc;
        }

        PIT_CustomContactLookupController controller = new PIT_CustomContactLookupController();
        System.runAs(usr) {
            controller.searchString = 'test';
            controller.accId = acc.id;
            controller.search();
        }

        System.assertEquals(1, controller.results.size());
        System.assertEquals(ctc.id, controller.results[0].id);

        controller.getFormTag();
        controller.getTextBox();

    }


}