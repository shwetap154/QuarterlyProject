@isTest
public with sharing class AccountEventListController_Test {

    private static testMethod void testAutoRun() {

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        List<String> maktList = new list<String> {'Italy', 'United States', 'Germany', 'United States'};
        //Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<4;i++) {
                                    testAccts.add(new Account(Name = 'TestAcct'+i,
                                    ZTS_EU_Market__c = String.valueOf(maktList[i]),
                                    ZTS_US_NARC_ID__c = 'TestNID'+i,
                                    Type = 'Vet Practice',
                                    ZTS_EU_Zip_Postal_Code__c = '12345',
                                    BillingPostalCode = '12345',
                                    BillingCity = 'Boca Raton',
                                    BillingState = 'Florida',
                                    BillingStreet = 'Elm Lane'));
    }

        System.runAs(usr)
        {
            insert testAccts;
        }
        
        Test.startTest();
        Test.setCurrentPage(Page.AccountAddToEventList);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(testAccts);
        stdSetController.setSelected(testAccts);
        AccountEventListController ext = new AccountEventListController(stdSetController);
        System.assertNotEquals(null,ext.doRedirect());

        Test.stopTest();
    }

    private static testMethod void testNoRecords() {
            
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        

        List<String> maktList = new list<String> {'Italy', 'United States', 'Germany', 'United States'};
        //Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<4;i++) {
                                    testAccts.add(new Account(Name = 'TestAcct'+i,
                                    ZTS_EU_Market__c = String.valueOf(maktList[i]),
                                    ZTS_US_NARC_ID__c = 'TestNID'+i,
                                    Type = 'Vet Practice',
                                    ZTS_EU_Zip_Postal_Code__c = '12345',
                                    BillingPostalCode = '12345',
                                    BillingCity = 'Boca Raton',
                                    BillingState = 'Florida',
                                    BillingStreet = 'Elm Lane'));
        }

        System.runAs(usr)
        {
            insert testAccts;
        }
        
        Test.startTest();
        Test.setCurrentPage(Page.AccountAddToEventList);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(testAccts);
        AccountEventListController ext = new AccountEventListController(stdSetController);
        System.assertEquals(null,ext.doRedirect());

        Test.stopTest();
    }
}