@isTest
private class AccountListController_Test {
    private static testMethod void testAutoRun() {
        
        List<String> maktList = new list<String> {'Italy', 'United States', 'Germany', 'United States'};
            //Create common test accounts
            List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(4);
        // for(Integer i=0;i<4;i++) {
        //                             testAccts.add(new Account(Name = 'TestAcct'+i,
        //                             ZTS_EU_Market__c = String.valueOf(maktList[i]),
        //                             ZTS_US_NARC_ID__c = 'TestNID'+i,
        //                             Type = 'Vet Practice'));
        // }
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            insert  testAccts;
        }
        Test.startTest();
        Test.setCurrentPage(Page.AccountAddToCampaignList);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(testAccts);
        stdSetController.setSelected(testAccts);
        AccountListController ext = new AccountListController(stdSetController);
        System.assertNotEquals(null,ext.doRedirect());
        
        Test.stopTest();
    }
    
    private static testMethod void testUSRun() 
    {
        
        List<String> maktList = new list<String> {'Italy', 'United States', 'Germany', 'United States'};
        //Create common test accounts
        List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(4);
 		for (Account a : testAccts) a.ZTS_EU_Market__c = 'United States';
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            insert  testAccts;
        }
        Test.startTest();
        Test.setCurrentPage(Page.AccountAddToCampaignList);
        ApexPages.currentPage().getParameters().put('retUrl', 'id='+SObjectType.Campaign.getKeyPrefix()+'1234&=a0s1111111111111111');
        ApexPages.currentPage().getParameters().put('chosenIds', '00155000000zIN9AAM,00155000000zIN9AAS');
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(testAccts);
        stdSetController.setSelected(testAccts);
        AccountListController ext = new AccountListController(stdSetController);
        System.assertNotEquals(null,ext.doRedirect());
        
        Test.stopTest();
    }
    
    private static testMethod void testNoRecordsUS() {
        
        List<String> maktList = new list<String> {'Italy', 'United States', 'Germany', 'United States'};
            //Create common test accounts
            List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(4);
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        ApexPages.StandardSetController stdSetController;
        System.runAs(usr)
        {
            insert  testAccts;
            Test.startTest();
            PageReference pageRef = Page.AccountAddToCampaignList;
            pageRef.getParameters().put('retUrl', 'id=1234');
            Test.setCurrentPage(pageRef);
                        
            stdSetController = new ApexPages.StandardSetController(new List<Account>());        
        	AccountListController ext = new AccountListController(stdSetController);
            
            System.assertEquals(null,ext.doRedirect());
        }
        Test.stopTest();
    }
    
    private static testMethod void testNoRecordsINTL() {
        
        List<String> maktList = new list<String> {'Italy', 'United States', 'Germany', 'United States'};
            //Create common test accounts
            List<Account> testAccts = ZTS_EU_DataUtilityTest.createAccountRecord(4);
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        ApexPages.StandardSetController stdSetController;
        System.runAs(usr)
        {
            insert  testAccts;
            Test.startTest();
            PageReference pageRef = Page.AccountAddToCampaignList;
            pageRef.getParameters().put('retUrl', 'id=1234');
            Test.setCurrentPage(pageRef);
            
            stdSetController = new ApexPages.StandardSetController(testAccts);
            //stdSetController.setSelected(null);
            AccountListController ext = new AccountListController(stdSetController);
            
            System.assertEquals(null, ext.doRedirectINTL());
        }
        Test.stopTest();
    }
    
    private static testMethod void testIntlRun() {
        
        List<String> maktList = new list<String> {'Italy', 'United States', 'Germany', 'United States'};
            //Create common test accounts
            List<Account> testAccts = ZTS_EU_DataUtilityTest.createAccountRecord(4);
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            insert  testAccts;
        }
        
        Test.startTest();
        Test.setCurrentPage(Page.AccountAddToCampaignINTL);
        ApexPages.currentPage().getParameters().put('retUrl', 'id='+SObjectType.Campaign.getKeyPrefix()+'1234&=a0s1111111111111111');
        ApexPages.currentPage().getParameters().put('chosenIds', '70155000000zIN9AAS');
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(testAccts);
        stdSetController.setSelected(testAccts);
        AccountListController ext = new AccountListController(stdSetController);
        System.assertNotEquals(null,ext.doRedirectINTL());
        
        Test.stopTest();
    }
    private static testMethod void testIntlRunWithUSUser() {
        
        List<String> maktList = new list<String> {'Italy', 'United States', 'Germany', 'United States'};
            //Create common test accounts
            List<Account> testAccts = ZTS_EU_DataUtilityTest.createAccountRecord(4);
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            insert  testAccts;
        }
        
        usr.ZTS_EU_Market__c = 'United States';
        update usr;
        
        Test.startTest();
        Test.setCurrentPage(Page.AccountAddToCampaignINTL);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(testAccts);
        stdSetController.setSelected(testAccts);
        AccountListController ext = new AccountListController(stdSetController);
                
        System.runAs(usr)
        {
            System.assertNotEquals(null,ext.doRedirect());
        }
        
        Test.stopTest();
    }
}