/**
 * @description       : Test class for MarketSettingsSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-30-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-30-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with test for retrieveEnabledMarketsForIntegrations
**/
@isTest
private class MarketSettingsSelectorTest {
    // To avoid dependencies on Metadata records, this test just executes the method using
    // the Enable DMR Account Integration field for code coverage purposes only.
    @isTest
    private static void retrieveEnabledMarketsForIntegrations_Test() {
        Test.startTest();
            MarketSettingsSelector.newInstance().retrieveEnabledMarketsForIntegrations(
                new Set<Schema.SObjectField> {Market_Setting__mdt.Enable_Account_DMR_Integration__c});
        Test.stopTest();
    }
}