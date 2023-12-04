@isTest
public class ContractListController_test {
    private static testMethod void doNewRecCreateTest() {

        List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(1);
        Account testAcct = testAccts[0];
        testAcct.Name = 'TestAcct';
        testAcct.ZTS_EU_Market__c = 'United States';
        testAcct.ZTS_US_NARC_ID__c = 'TestNID';
        testAcct.Type = 'Vet Practice';

        insert  testAcct;

        Contract testContract1  = new Contract( Name = 'TestContr1',
                                                AccountId = testAcct.id, 
                                                Status = 'New',
                                                ZTS_US_BIOs_Field_Proposed_Tier__c	= '15,000'
        );

        insert  testContract1;

        Test.startTest();
        List<Contract> testContractsList = new List<Contract>();
        testContractsList.add(testContract1);
        Test.setCurrentPage(Page.ContractNewRecordListBtn);
        ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(testContractsList);
        standardSetController.setSelected(testContractsList);
        ContractListController ext = new ContractListController(standardSetController);
        System.assertNotEquals(null,ext.doNewRecCreate());

        Test.stopTest();
    }

    private static testMethod void doMassApproveCalloutTest() {

        List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(1);
        Account testAcct = testAccts[0];
        testAcct.Name = 'TestAcct';
        testAcct.ZTS_EU_Market__c = 'United States';
        testAcct.ZTS_US_NARC_ID__c = 'TestNID';
        testAcct.Type = 'Vet Practice';

        insert  testAcct;

        Contract testContract1  = new Contract( Name = 'TestContr1',
                                                AccountId = testAcct.id, 
                                                Status = 'New',
                                                ZTS_US_BIOs_Field_Proposed_Tier__c	= '15,000'
        );

        insert  testContract1;

        Test.startTest();
        List<Contract> testContractsList = new List<Contract>();
        testContractsList.add(testContract1);
        Test.setCurrentPage(Page.ContractMassApproveListBtn);
        ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(testContractsList);
        standardSetController.setSelected(testContractsList);
        ContractListController ext = new ContractListController(standardSetController);
        System.assertNotEquals(null,ext.doMassApproveCallout());

        Test.stopTest();
    }

    private static testMethod void doRelListCreateTest() {

        
        List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(1);
        Account testAcct = testAccts[0];
        testAcct.Name = 'TestAcct';
        testAcct.ZTS_EU_Market__c = 'United States';
        testAcct.ZTS_US_NARC_ID__c = 'TestNID';
        testAcct.Type = 'Vet Practice';

        insert  testAcct;

        Contract testContract1  = new Contract( Name = 'TestContr1',
                                                AccountId = testAcct.id, 
                                                Status = 'New',
                                                ZTS_US_BIOs_Field_Proposed_Tier__c	= '15,000'
        );

        insert  testContract1;

        Test.startTest();
        List<Contract> testContractsList = new List<Contract>();
        testContractsList.add(testContract1);
        Test.setCurrentPage(Page.NewContractAccRelList);
        ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(testContractsList);
        standardSetController.setSelected(testContractsList);
        ContractListController ext = new ContractListController(standardSetController);
        System.assertNotEquals(null,ext.doRelListCreate());

        Test.stopTest();
    }
}