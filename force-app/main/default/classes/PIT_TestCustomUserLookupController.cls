@isTest
private class PIT_TestCustomUserLookupController {

    static testMethod void testController() {
        ZTS_EU_Territory__c territory = new ZTS_EU_Territory__c();
        territory.Name = 'testVetTerritory';
        territory.ZTS_FieldForce_ID__c = '813';
        territory.ZTS_EU_Market__c = 'United States';
        insert territory;
        
        ZTS_EU_Position__c userTerritory = new ZTS_EU_Position__c();
        userTerritory.ZTS_EU_Territory__c = territory.id;
        userTerritory.ZTS_EU_Employee__c = UserInfo.getUserId();
        insert userTerritory;
        
        PIT_CustomUserLookupController controller = new PIT_CustomUserLookupController();
        controller.search();
        
        System.assertEquals(1, controller.results.size());
        System.assertEquals(UserInfo.getUserId(), controller.results[0].id);
        
        controller.getFormTag();
        controller.getTextBox();
        
        controller.searchString = 'nonExistingUser';
        controller.search();
        System.assertEquals(0, controller.results.size());
    }
    
}