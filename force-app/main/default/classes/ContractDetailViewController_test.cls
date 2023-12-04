/**
 * @description       : Test class for ContractDetailViewController
 * @author            : Art Smorodin @ Slalom
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   05-22-2020   Art Smorodin @ Slalom          Initial Version
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc      Fix issues with how Contract was queried for to work at any time
**/
@isTest
public with sharing class ContractDetailViewController_test {
    private static final String TEST_ACCOUNT_NAME = 'TestAcct0';

    @testSetup 
    static void setup() {
        // Create common test records
        /*Account testAcct = new Account(Name = 'TestAcct0',
                                    	ZTS_EU_Market__c = 'United States',
                                    	ZTS_US_NARC_ID__c = 'TestNID',
                                    	Type = 'Vet Practice');*/
        List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(1);
        Account testAcct = testAccts[0];
        testAcct.Name = TEST_ACCOUNT_NAME;
        testAcct.ZTS_EU_Market__c = 'United States';
        testAcct.ZTS_US_NARC_ID__c = 'TestNID';
        testAcct.Type = 'Vet Practice';

        insert  testAcct;

        Contract testContract1  = new Contract( Name = 'TestContr0',
                                                AccountId = testAcct.id, 
                                                Status = 'New',
                                                ZTS_US_BIOs_Field_Proposed_Tier__c	= '15,000'
        );

        insert  testContract1;
            
    }
    
    @isTest static void doLcRedirectTest() {

        Contract contr = [SELECT Id FROM Contract WHERE Account.Name=:TEST_ACCOUNT_NAME LIMIT 1];
        ApexPages.StandardController stdController = new ApexPages.StandardController(contr);
        ContractDetailViewController controller = new ContractDetailViewController(stdController);
        PageReference TestPage = Page.ContractPrepDocumentBtn;
        test.setCurrentPage(TestPage);
        PageReference result = controller.doLcRedirect();
        System.assertNotEquals(null,result);

    }

    @isTest static void submitForApprovalTest() {

        Contract contr = [SELECT Id FROM Contract WHERE Account.Name=:TEST_ACCOUNT_NAME LIMIT 1];
        ApexPages.StandardController stdController = new ApexPages.StandardController(contr);
        ContractDetailViewController controller = new ContractDetailViewController(stdController);
        PageReference TestPage = Page.ContractPrepDocumentBtn;
        test.setCurrentPage(TestPage);
        PageReference result = controller.submitForApproval();
        System.assertNotEquals(null,result);

    }

    @isTest static void doBiosRedirectLcTest() {

        Contract contr = [SELECT Id FROM Contract WHERE Account.Name=:TEST_ACCOUNT_NAME LIMIT 1];
        ApexPages.StandardController stdController = new ApexPages.StandardController(contr);
        ContractDetailViewController controller = new ContractDetailViewController(stdController);
        PageReference TestPage = Page.ContractMzrBiosVF;
        test.setCurrentPage(TestPage);
        PageReference result = controller.doBiosRedirectLc();
        System.assertNotEquals(null,result);

    }

    @isTest static void doParasRedirectLcTest() {

        Contract contr = [SELECT Id FROM Contract WHERE Account.Name=:TEST_ACCOUNT_NAME LIMIT 1];
        ApexPages.StandardController stdController = new ApexPages.StandardController(contr);
        ContractDetailViewController controller = new ContractDetailViewController(stdController);
        PageReference TestPage = Page.ContractMzrParasVF;
        test.setCurrentPage(TestPage);
        PageReference result = controller.doParasRedirectLc();
        System.assertNotEquals(null,result);

    }

    @isTest static void callApprovalClsTest() {

        Contract contr = [SELECT Id FROM Contract WHERE Account.Name=:TEST_ACCOUNT_NAME LIMIT 1];
        ApexPages.StandardController stdController = new ApexPages.StandardController(contr);
        ContractDetailViewController controller = new ContractDetailViewController(stdController);
        PageReference TestPage = Page.ContractPrepDocumentBtn;
        test.setCurrentPage(TestPage);
        PageReference result = controller.callApprovalCls();
        System.assertNotEquals(null,result);

    }
    

    @isTest static void hasAgreementsTest() {

        Contract contr = [SELECT Id FROM Contract WHERE Account.Name=:TEST_ACCOUNT_NAME LIMIT 1];
        Boolean result=ContractDetailViewController.hasAgreements(String.valueOf(contr.Id));
        System.assertEquals(false, result);

    }

    @isTest static void getTemplatesTest() {

        Contract contr = [SELECT Id FROM Contract WHERE Account.Name=:TEST_ACCOUNT_NAME LIMIT 1];
        String result = ContractDetailViewController.getTemplates(String.valueOf(contr.Id));
        System.assertEquals('No Template Found', result);

    }

    @isTest static void getContractInfoTest() {

        Contract contr = [SELECT Id FROM Contract WHERE Account.Name=:TEST_ACCOUNT_NAME LIMIT 1];
        Contract result = ContractDetailViewController.getContractInfo(String.valueOf(contr.Id));
        System.assertNotEquals(null, result);

    }

    @isTest static void updateContractTest() {

        Contract contr = [SELECT Id FROM Contract WHERE Account.Name=:TEST_ACCOUNT_NAME LIMIT 1];
        Contract result = ContractDetailViewController.updateContract(String.valueOf(contr.Id));
        System.assertNotEquals(null, result);

    }

    @isTest static void submitApprovalTest() {

        Contract contr = [SELECT Id FROM Contract WHERE Account.Name=:TEST_ACCOUNT_NAME LIMIT 1];
        String result = ContractDetailViewController.submitApproval(String.valueOf(contr.Id));
        System.assertEquals('No Approval Process found matching the the criteria', result);

    }

    @isTest static void docBiosListTest() {

        List<ContentDocument> result = ContractDetailViewController.docBiosList();
        System.assertEquals(0, result.size());

    }

    @isTest static void docParasListTest() {

        List<ContentDocument> result = ContractDetailViewController.docParasList();
        System.assertEquals(0, result.size());

    }
}