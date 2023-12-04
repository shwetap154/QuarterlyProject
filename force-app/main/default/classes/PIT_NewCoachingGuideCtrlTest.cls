/*
Adding a test class for coverage of class: PIT_NewCoachingGuideOverrideController

*/

@isTest
private class PIT_NewCoachingGuideCtrlTest {

    static testMethod void testMethod1() {
    
        PIT_Coaching_Guide__c cg = new PIT_Coaching_Guide__c();
        cg.PIT_Coach__c = userinfo.getuserId();
        ApexPages.standardController cont =  new ApexPages.StandardController(cg);
        
        PIT_NewCoachingGuideOverrideController testObj = new PIT_NewCoachingGuideOverrideController(cont);
        testObj.redirectUser();
    }
    
    static testMethod void testMethod2() {
        
        
        
        
        PageReference myPage = Page.PIT_NewCoachingGuideOverride;
        test.setCurrentPage(myPage);
        ApexPages.currentPage().getParameters().put('ID','testID');
        
        PIT_Coaching_Guide__c cg = new PIT_Coaching_Guide__c();
        ApexPages.standardController cont =  new ApexPages.StandardController(cg);
        
        PIT_NewCoachingGuideOverrideController testObj = new PIT_NewCoachingGuideOverrideController(cont);
        testObj.redirectUser();
    }
    
    
    
    }