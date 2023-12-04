@isTest
public with sharing class TargetedAccListControllerTest {

    static void setupData(Boolean isUSRecords, String fieldTargeting){
        
        String market = isUSRecords ? 'United States' : 'United Kingdom';
        String userFirstName = isUSRecords ? 'usUser' : 'intlUser';

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = userFirstName;
        usr.zts_eu_market__c = market;
        insert usr;
        
        System.runAs(usr)
        {
            Campaign testCampaign = ZTS_DataUtilityTest.createCampaignRecord(1)[0];
            testCampaign.Campaign_Name_English__c = 'English';
            testCampaign.ZTS_EU_Market__c = market;
            testCampaign.ZTS_EU_Field_Targeting__c = fieldTargeting;
            insert testCampaign;
    
            Account testAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            testAccount.ZTS_EU_Market__c = market;
            insert testAccount;
            
            ZTS_EU_Campaign_Account__c testCampaignAccount = new ZTS_EU_Campaign_Account__c();
            testCampaignAccount.ZTS_EU_Account__c = testAccount.Id;
            testCampaignAccount.ZTS_EU_Campaign__c = testCampaign.Id;
            insert testCampaignAccount;
        }

    }

    @isTest
    static void TargetedAccAccountListBtnTest_OpenUS() {

        setupData(true,'Open');

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccAccountListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doAccountRedirect();
        Test.stopTest();

        Pagereference expectedPgReference = new Pagereference('/apex/ZTS_US_targetAccount?campId='+campaignAccounts[0].ZTS_EU_Campaign__c);
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
    }

    @isTest
    static void TargetedAccAccountListBtnTest_ClosedUS() {

        setupData(true,null);

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        List<Campaign> testCampaigns = [SELECT Id, ZTS_EU_Field_Targeting__c FROM Campaign];
        // testCampaigns[0].ZTS_EU_Field_Targeting__c = 'Closed';
        // update testCampaigns;

        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccAccountListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doAccountRedirect();
        Test.stopTest();

        Pagereference expectedPgReference = new Pagereference('/lightning/cmp/c__ErrorToastLC?c__campId='+testCampaigns[0].Id+'&c__campTargeting='+testCampaigns[0].ZTS_EU_Field_Targeting__c);
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
    }

    @isTest
    static void TargetedAccAccountListBtnTest_Intl() {

        setupData(false,null);

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        List<Campaign> testCampaigns = [SELECT Id, ZTS_EU_Field_Targeting__c FROM Campaign];
        update testCampaigns;

        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccAccountListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doAccountRedirect();
        Test.stopTest();

        Pagereference expectedPgReference = new Pagereference('/apex/SL_TargetAccount?id='+testCampaigns[0].Id);
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
    }

    @isTest
    static void TargetedAccNarcAccListBtnTest_OpenUS() {

        setupData(true,'Open');

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccNarcAccListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doAccountNARCRedirect();
        Test.stopTest();

        Pagereference expectedPgReference = new Pagereference('/apex/ZTS_US_targetAccountNARC?campId='+campaignAccounts[0].ZTS_EU_Campaign__c);
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
    }

    @isTest
    static void TargetedAccNarcAccListBtnTest_ClosedUS() {

        setupData(true, null);

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        List<Campaign> testCampaigns = [SELECT Id, ZTS_EU_Field_Targeting__c FROM Campaign];

        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccNarcAccListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doAccountNARCRedirect();
        Test.stopTest();

        Pagereference expectedPgReference = new Pagereference('/lightning/cmp/c__ErrorToastLC?c__campId='+testCampaigns[0].Id+'&c__campTargeting='+testCampaigns[0].ZTS_EU_Field_Targeting__c);
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
    }

    @isTest
    static void TargetedAccountTgAccIdListBtnTest_OpenUS() {
        setupData(true,'Open');

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccountTgAccIdListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doAccountAccIdRedirect();
        Test.stopTest();

        Pagereference expectedPgReference = new Pagereference('/apex/ZTS_EU_targetAccountID?campId='+campaignAccounts[0].ZTS_EU_Campaign__c);
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
    }

    @isTest
    static void TargetedAccountTgAccIdListBtnTest_ClosedUS() {
        setupData(true,null);

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        List<Campaign> testCampaigns = [SELECT Id, ZTS_EU_Field_Targeting__c FROM Campaign];

        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccountTgAccIdListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doAccountAccIdRedirect();
        Test.stopTest();

        Pagereference expectedPgReference = new Pagereference('/lightning/cmp/c__ErrorToastLC?c__campId='+testCampaigns[0].Id+'&c__campTargeting='+testCampaigns[0].ZTS_EU_Field_Targeting__c);
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
    }

    @isTest
    static void TargetedAccRemoveListBtnTest_OpenUS() {
        setupData(true,'Open');

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccRemoveListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doRemoveRedirect();
        Test.stopTest();

        Pagereference expectedPgReference = new Pagereference('/apex/ZTS_US_removeTargetAccnts?records='+campaignAccounts[0].Id+'&campId='+campaignAccounts[0].ZTS_EU_Campaign__c);
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
        // doRemoveRedirect
    }

    @isTest
    static void TargetedAccRemoveListBtnTest_ClosedUS() {
        setupData(true,null);

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        List<Campaign> testCampaigns = [SELECT Id, ZTS_EU_Field_Targeting__c FROM Campaign];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccRemoveListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doRemoveRedirect();
        Test.stopTest();
        
        Pagereference expectedPgReference = new Pagereference('/lightning/cmp/c__ErrorToastLC?c__campId='+testCampaigns[0].Id+'&c__campTargeting='+testCampaigns[0].ZTS_EU_Field_Targeting__c);
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
        // doRemoveRedirect
    }

    @isTest
    static void TargetedAccRemoveListBtnTest_Intl() {
        setupData(false,null);

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccRemoveListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doRemoveRedirect();
        Test.stopTest();

        Pagereference expectedPgReference = new Pagereference('/apex/SL_RemoveAccount?id=' + campaignAccounts[0].ZTS_EU_Campaign__c + '&selectedAccounts=' +campaignAccounts[0].Id);
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
        // doRemoveRedirect
    }

    @isTest
    static void TargetedAccTgAccountsListBtnTest_OpenUS() {
        setupData(true,'Open');

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccTgAccountsListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doTgAccountsRedirect();
        Test.stopTest();
		String campId = String.valueOf(campaignAccounts[0].ZTS_EU_Campaign__c).left(15);
        Pagereference expectedPgReference = new Pagereference('/apex/ZTS_US_Mass_Add_Account_to_Campaign?id='+campId+'&fromCamp=true');
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
        // doTgAccountsRedirect
    }

    @isTest
    static void TargetedAccTgAccountsListBtnTest_ClosedUS() {
        setupData(true,null);

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        List<Campaign> testCampaigns = [SELECT Id, ZTS_EU_Field_Targeting__c FROM Campaign];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccTgAccountsListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doTgAccountsRedirect();
        Test.stopTest();
		String campId = String.valueOf(testCampaigns[0].Id).left(15);
        Pagereference expectedPgReference = new Pagereference('/lightning/cmp/c__ErrorToastLC?c__campId='+campId+'&c__campTargeting='+testCampaigns[0].ZTS_EU_Field_Targeting__c);
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
        // doTgAccountsRedirect
    }

    @isTest
    static void TargetedAccTgAccountsListBtnTest_Intl() {
        setupData(false,null);

        List<ZTS_EU_Campaign_Account__c> campaignAccounts = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c FROM ZTS_EU_Campaign_Account__c];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(campaignAccounts);
        stdSetController.setSelected(campaignAccounts);
        TargetedAccListController targetedAccController = new TargetedAccListController(stdSetController);
        
        PageReference targetAccPage = Page.TargetedAccTgAccountsListBtn;
        Test.setCurrentPage(targetAccPage);
        ApexPages.currentPage().getParameters().put('id', campaignAccounts[0].ZTS_EU_Campaign__c);

        Test.startTest();
            Pagereference actualPgReference = targetedAccController.doTgAccountsRedirect();
        Test.stopTest();
		String campId = String.valueOf(campaignAccounts[0].ZTS_EU_Campaign__c).left(15);
        Pagereference expectedPgReference = new Pagereference('/apex/SL_TargetAccounts?id=' + campId);
        System.assertEquals(expectedPgReference.getUrl(), actualPgReference.getUrl(), 'Page references should match');
        // doTgAccountsRedirect
    }
}