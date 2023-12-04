@isTest
public with sharing class TerritoryListController_Test {
    @testSetup 
    static void setup() {
        // Create common test accounts
        ZTS_EU_Territory__c testTerritory = new ZTS_EU_Territory__c(Name = 'TestTerr0',
                                    	                       ZTS_EU_Market__c = 'Canada');

        insert  testTerritory;

    }

    private static testMethod void doTerrSyncRedirectTest() {

        List<ZTS_EU_Territory__c> territoryList = new List<ZTS_EU_Territory__c>();
        ZTS_EU_Territory__c terr = [SELECT Id FROM ZTS_EU_Territory__c WHERE Name='TestTerr0' LIMIT 1];
        territoryList.add(terr);

        Test.startTest();
        Test.setCurrentPage(Page.TerritorySyncListBtn);
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(territoryList);
        standardController.setSelected(territoryList);
        TerritoryListController ext = new TerritoryListController(standardController);
        System.assertNotEquals(null,ext.doTerrSyncRedirect());

        Test.stopTest();

    }

    private static testMethod void doTerrRemoveRedirectTest() {

        List<ZTS_EU_Territory__c> territoryList = new List<ZTS_EU_Territory__c>();
        ZTS_EU_Territory__c terr = [SELECT Id FROM ZTS_EU_Territory__c WHERE Name='TestTerr0' LIMIT 1];
        territoryList.add(terr);

        Test.startTest();
        Test.setCurrentPage(Page.TerritoryRemoveListBtn);
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(territoryList);
        standardController.setSelected(territoryList);
        TerritoryListController ext = new TerritoryListController(standardController);
        System.assertNotEquals(null,ext.doTerrRemoveRedirect());

        Test.stopTest();

    }

    @isTest
    static void territoryUpdateTest()
    {
        ZTS_EU_Territory__c terr = [SELECT Id FROM ZTS_EU_Territory__c WHERE Name='TestTerr0' LIMIT 1];
        String  listIds = String.valueOf(terr.Id);
        TerritoryListController.territoryUpdate(listIds);
    }

    @isTest
    static void updateAssignedFlagTest()
    {
        TerritoryListController.updateAssignedFlag();
    }
}