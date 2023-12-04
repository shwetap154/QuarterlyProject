/**
	* File Name    :  FASTDXreportIFrameControllerTest
	* description  :  Test class for controller extension for FASTDxreportIFrame.vfp
	* author       :  Pranija Nagavelly
	* Modification Log
	===================================================================================================
	* Ver.  Date        Author                 Modification
	---------------------------------------------------------------------------------------------------
	* 1.0   09/24/2021 Pranija Nagavelly       Created test class
**/

@isTest
public class FASTDXreportIFrameControllerTest {
 @testSetup static void testSetup() {
        Account testAccount = TestDataFactory.createAccount_US('US account for FASTDX report',false);
        testAccount.ZTS_US_NARC_ID__c = '999888777';
        insert testAccount;
        
     	Profile p = [Select Id from Profile where name = 'System Administrator'];
        
        FAST_Report_Base_URL__c FASTsettings = FAST_Report_Base_URL__c.getOrgDefaults();
        FASTsettings.URL__c = 'http://test.test/';
      	FASTsettings.FASTDx_URL__c = 'http://test.test/';
        upsert FASTsettings;
    }

    public static TestMethod void pageLoadTest() {
        Account testAct = [SELECT Id,ZTS_US_NARC_ID__c FROM Account LIMIT 1];
        PageReference pageRef = Page.FASTDxreportIFrame;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(testAct);

        String reportURL;

        Test.startTest();
            FASTDXreportIFrameController fReportCont = new FASTDXreportIFrameController(sc);
            reportURL = fReportCont.getReportURL();
        Test.stopTest();

        System.assertEquals('http://test.test/top_sight_view/999888777',reportURL);
    }

    public static TestMethod void pageLoadTest_NoNARC() {
        Account testAct = [SELECT Id,ZTS_US_NARC_ID__c FROM Account LIMIT 1];
        testAct.ZTS_US_NARC_ID__c = null;
        update testAct;

        PageReference pageRef = Page.FASTDxreportIFrame;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(testAct);

        String reportURL;

        Test.startTest();
            FASTDXreportIFrameController fReportCont = new FASTDXreportIFrameController(sc);
            reportURL = fReportCont.getReportURL();
        Test.stopTest();

        System.assertEquals('http://test.test/',reportURL);
    }
}