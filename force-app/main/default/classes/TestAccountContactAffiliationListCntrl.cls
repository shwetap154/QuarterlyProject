/****************************************************************************************************************************************** 
* CLass Name : TestAccountContactAffiliationListCntrl
* Description  : Controller test for new buttons (that used to be JS) on ZTS_EU_Affiliations__c object
* Created By   : Slalom(David Stern) 
* Created Date : 5th May, 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern            06/04/2020          Created 
*****************************************************************************************************************************************/
@isTest
public class TestAccountContactAffiliationListCntrl 
{
    @testSetup
    public static void testSetup()
    {
        Account acct = ZTS_DataUtilityTest.createAccountRecord(1)[0];
        acct.ZTS_EU_Market__c = 'United States';
        insert acct;   
        
        Contact cont = ZTS_DataUtilityTest.createContactRecord(1)[0];
        cont.ZTS_EU_Market__c = 'United States';
        insert cont;
        
        ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Account__c = acct.Id,
                                                                ZTS_EU_Account_influence__c = 'High',
                                                                ZTS_EU_Affiliation_Status__c = 'Active',
                                                                ZTS_EU_Contact__c = cont.Id,
                                                                ZTS_EU_Commitment_Level__c = 'Supporter',
                                                                ZTS_US_Job_Function__c = 'Lead Technician',
                                                                ZTS_US_Profession__c = 'Consultant'
                                                               );
        
        insert aff;
    }
    
    @isTest
    public static void testDoMakePrimaryRedirect()
    {
        ZTS_EU_Affiliations__c aff = [
            SELECT Id
            FROM ZTS_EU_Affiliations__c
            LIMIT 1
        ];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aff);
        PageReference accountContactAffiliationPage = Page.AccountContactAffiliationMakePrimary;
        Test.setCurrentPage(accountContactAffiliationPage);
        
        AccountContactAffiliationListController controller = new AccountContactAffiliationListController(sc);
        controller.doMakePrimaryRedirect();
        
        System.assertEquals([SELECT Id, ZTS_US_Job_Function__c FROM Contact].ZTS_US_Job_Function__c, 'Lead Technician');
    }
    
    @isTest
    public static void testDoAddAccountAffiliation()
    {
        ZTS_EU_Affiliations__c aff = [
            SELECT Id
            FROM ZTS_EU_Affiliations__c
            LIMIT 1
        ];
        
        Id conId = [SELECT Id FROM Contact].Id;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<ZTS_EU_Affiliations__c>{aff});
        PageReference accountContactAffiliationPage = Page.AccountContactAffiliationAddAcctAff;
        Test.setCurrentPage(accountContactAffiliationPage);
        ApexPages.currentPage().getParameters().put('id', conId);
        
        AccountContactAffiliationListController controller = new AccountContactAffiliationListController(sc);
        controller.doAddAccountAffiliation();
        
        PageReference pg = controller.doAddAccountAffiliation();
        System.assertEquals(pg.getUrl(), '/apex/ZTS_US_accountContactAff?conId=' + conId);
    }
    
    @isTest
    public static void testDoAffiliateExistingContact()
    {
        ZTS_EU_Affiliations__c aff = [
            SELECT Id
            FROM ZTS_EU_Affiliations__c
            LIMIT 1
        ];
        
        Id accntId = [SELECT Id FROM Account].Id;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<ZTS_EU_Affiliations__c>{aff});
        PageReference accountContactAffiliationPage = Page.AccountContactAffiliationAffiliateCont;
        Test.setCurrentPage(accountContactAffiliationPage);
        ApexPages.currentPage().getParameters().put('id', accntId);
        
        AccountContactAffiliationListController controller = new AccountContactAffiliationListController(sc);
        
        PageReference pg = controller.doAffiliateExistingContact();
        System.assertEquals(pg.getUrl(), '/apex/ZTS_US_accountContactAff?accntId=' + accntId);
    }
    
    @isTest
    public static void testFailDoAffiliateExistingContact()
    {
        ZTS_EU_Affiliations__c aff = [
            SELECT Id
            FROM ZTS_EU_Affiliations__c
            LIMIT 1
        ];
        
        Id accntId = [SELECT Id FROM Account].Id;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<ZTS_EU_Affiliations__c>{aff});
        PageReference accountContactAffiliationPage = Page.AccountContactAffiliationAffiliateCont;
        Test.setCurrentPage(accountContactAffiliationPage);
        ApexPages.currentPage().getParameters().put('id', accntId);
        
        AccountContactAffiliationListController controller = new AccountContactAffiliationListController(sc);
        controller.failTest = true;
        
        PageReference pg = controller.doAffiliateExistingContact();
        System.assertEquals(pg, null);
    }

    @isTest
    static void testDoRedirectIntl() {
        ZTS_EU_Affiliations__c aff = [
            SELECT Id
            FROM ZTS_EU_Affiliations__c
            LIMIT 1
        ];
        
        Id accntId = [SELECT Id FROM Account].Id;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<ZTS_EU_Affiliations__c>{aff});

        AccountContactAffiliationListController controller = new AccountContactAffiliationListController(sc);
        PageReference pr = controller.doRedirectIntl();
    }
    
     @isTest
    static void isINTLRedirectTest() {
        
        /*Account acct = ZTS_DataUtilityTest.createAccountRecord(1)[0];
        acct.ZTS_EU_Market__c = 'United Kingdom';
        insert acct;   
        
        Contact cont = ZTS_DataUtilityTest.createContactRecord(1)[0];
        cont.ZTS_EU_Market__c = 'United Kingdom';
        insert cont;
        
        ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Account__c = acct.Id,
                                                                ZTS_EU_Account_influence__c = 'High',
                                                                ZTS_EU_Affiliation_Status__c = 'Active',
                                                                ZTS_EU_Contact__c = cont.Id,
                                                                ZTS_EU_Commitment_Level__c = 'Supporter'
                                                               );
        
        insert aff;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<ZTS_EU_Affiliations__c>{aff});

        AccountContactAffiliationListController controller = new AccountContactAffiliationListController(sc);*/
        Boolean result = AccountContactAffiliationListController.isIntlRedirect('United Kingdom');
        
        system.assertEquals(result, true);
    }
    
    public class MyException extends Exception{}
}