/**
 * @description       : Test class for GigyaMarketSettingsSelector
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-24-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
**/
@isTest
private class GigyaMarketSettingsSelectorTest {
    private static testMethod void testSelectByEnvironmentType_Sandbox(){
        List<Gigya_Market_Setting__mdt> marketSettings;
        Test.startTest();
        marketSettings = GigyaMarketSettingsSelector.selectByEnvironmentType(true);
        Test.stopTest();
        System.assertNotEquals(0, marketSettings.size());
        for(Gigya_Market_Setting__mdt setting : marketSettings){
            System.assertEquals('Sandbox', setting.Environment__c);
        }
    }

    private static testMethod void testSelectByEnvironmentType_Production(){
        List<Gigya_Market_Setting__mdt> marketSettings;
        Test.startTest();
        marketSettings = GigyaMarketSettingsSelector.selectByEnvironmentType(false);
        Test.stopTest();
        System.assertNotEquals(0, marketSettings.size());
        for(Gigya_Market_Setting__mdt setting : marketSettings){
            System.assertEquals('Production', setting.Environment__c);
        }
    }
}