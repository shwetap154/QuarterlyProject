@isTest
public with sharing class PIT_TestNewCoachingGuideOverrideCtl {
    
    public testmethod static void test_PIT_redirect_Check(){
    
        PIT_Coaching_Guide__c cg = new PIT_Coaching_Guide__c();
        cg.PIT_Coach__c = Userinfo.getUserId();
        cg.PIT_Coaching_Status__c = 'New';
        cg.PIT_Colleague__c = Userinfo.getUserId();
        cg.PIT_Colleague_Comments__c = 'comments123';
        cg.ZTS_EU_Market__c = 'United Kingdom';
        insert cg;
        
        ApexPages.Standardcontroller stdCtrl = new Apexpages.Standardcontroller(cg);
        
        Test.startTest();
        PIT_NewCoachingGuideOverrideController ctl = new PIT_NewCoachingGuideOverrideController(stdCtrl);   
        ctl.redirectUser();
        
        PageReference pageRef = Page.PIT_NewCoachingGuideOverride;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('ID','testId');            
        
        PIT_NewCoachingGuideOverrideController ctl2 = new PIT_NewCoachingGuideOverrideController(stdCtrl);
        ctl2.redirectUser();
        
        System.assert(ApexPages.currentPage().getParameters().get('ID') == 'testId', 'proper testId should be passed to the new page');
        
    }
}