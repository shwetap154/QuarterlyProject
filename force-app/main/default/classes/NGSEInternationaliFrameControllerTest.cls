/**
* File Name    :  NGSEInternationaliFrameControllerTest
* description  :  Test class for controller extension for NGSEInternationalIFramePage.vfp
* author       :  Padma Nerella
* Modification Log
===================================================================================================
* Ver.  Date        Author                 Modification
---------------------------------------------------------------------------------------------------
* 1.0   04/29/2022  Padma Nerella         Created test class

**/

@isTest
public class NGSEInternationaliFrameControllerTest {
    @testSetup static void testSetup() {
       
        NGSE_International_iFrame_URL__c ngseURL = NGSE_International_iFrame_URL__c.getInstance();
        ngseURL.NGSE_IFrame_URL__c = 'http://test.test/';
        upsert ngseURL;
    }
    
    public static TestMethod void pageLoadTest() {
        PageReference pageRef = Page.NGSEInternationalIFramePage;
        Test.setCurrentPage(pageRef);
        
        String reportURL;
        
        Test.startTest();
        NGSEInternationaliFrameController ngseIFrame = new NGSEInternationaliFrameController();
        reportURL = ngseIFrame.getFrameurl();
        Test.stopTest();
        
        System.assertEquals('http://test.test/',reportURL);
    }
    
}