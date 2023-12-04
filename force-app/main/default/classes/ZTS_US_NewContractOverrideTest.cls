@isTest
public class ZTS_US_NewContractOverrideTest {

    static testmethod void testContractOverride(){
        
        List<Account> acc = ZTS_DataUtilityTest.createAccountRecord(1);
        insert acc;
        
        List<Contract> contr = ZTS_DataUtilityTest.createContractRecord(1);
        insert contr;
        
        PageReference p = Page.ZTS_US_NewContractOverride;
        Test.setCurrentPage(p);
        
        ApexPages.currentPage().getParameters().put('accountId',acc[0].Id);
        ApexPages.currentPage().getParameters().put('accountName',acc[0].Name);
        ApexPages.currentPage().getParameters().put('retURL','login.salesforce.com');
        
        ZTS_US_NewContractOverride conOve = new ZTS_US_NewContractOverride(new ApexPages.StandardController(contr[0]));
        conOve.addRedirect();
    }
}