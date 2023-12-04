@isTest
private class PIT_TestSTOMPAccountSelectController {
    
    static testMethod void testController() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr){
            PIT_STOMPAccountSelectController controller = new PIT_STOMPAccountSelectController(new ApexPages.StandardController(new PIT_STOMP__c()));
            System.assertEquals(null, controller.nextButtonAction());
            System.assertEquals(null, controller.autoRedirectAction());
            
            Account acc = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            acc.Name = 'testAcc';        
            insert acc;
            
            controller = new PIT_STOMPAccountSelectController(new ApexPages.StandardController(new PIT_STOMP__c()));
            PageReference pageRef = Page.PIT_STOMPAccountSelect;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('accId', acc.id);
            controller.autoRedirectAction();
            System.assertEquals(acc.id, controller.stomp.PIT_Account__c);
        }            
    }
    
}