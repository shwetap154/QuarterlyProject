/**
	* File Name    :  FASTreportIFrameControllerTest
	* description  :  Test class for controller extension for FASTreportIFrame.vfp
	* author       :  Chelsea Paice
	* Modification Log
	===================================================================================================
	* Ver.  Date        Author                 Modification
	---------------------------------------------------------------------------------------------------
	* 1.0   04/28/2021  Chelsea Paice          Created test class
    * 1.1   09/24/2021  Pranija Nagavelly      Modified test data setup
**/

@isTest
public class FASTreportIFrameControllerTest {

    @testSetup static void testSetup() {
        Account testAccount = TestDataFactory.createAccount_US('US account for FAST report',false);
        testAccount.ZTS_US_NARC_ID__c = '999888777';
        insert testAccount;
        
        FAST_Report_Base_URL__c FASTsettings = FAST_Report_Base_URL__c.getOrgDefaults();
        FASTsettings.URL__c = 'http://test.test/';
        FASTsettings.FASTDx_URL__c = 'http://test.test/';
        upsert FASTsettings;
    }

    public static TestMethod void pageLoadTest() {
        Account testAct = [SELECT Id,ZTS_US_NARC_ID__c FROM Account LIMIT 1];
        PageReference pageRef = Page.FASTreportIFrame;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(testAct);

        String reportURL;

        Test.startTest();
            FASTreportIFrameController fReportCont = new FASTreportIFrameController(sc);
            reportURL = fReportCont.getReportURL();
        Test.stopTest();

        System.assertEquals('http://test.test/999888777',reportURL);
    }

    public static TestMethod void pageLoadTest_NoNARC() {
        Account testAct = [SELECT Id,ZTS_US_NARC_ID__c FROM Account LIMIT 1];
        testAct.ZTS_US_NARC_ID__c = null;
        update testAct;

        PageReference pageRef = Page.FASTreportIFrame;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(testAct);

        String reportURL;

        Test.startTest();
            FASTreportIFrameController fReportCont = new FASTreportIFrameController(sc);
            reportURL = fReportCont.getReportURL();
        Test.stopTest();

        System.assertEquals('http://test.test/',reportURL);
    }
}