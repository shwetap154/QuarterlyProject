/**
 * @description       : Main Query Class for Gigya_Market_Setting__mdt
 * doesn't use traditional Selector factory class pattern because Custom Metadata 
 * doesn't support SObjectType, and also because SOQL is not necessary to access 
 * Custom Metadata Records as of API version 51
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : Selectors
 * @last modified on  : 08-12-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
**/
public class GigyaMarketSettingsSelector {
    private static List<Gigya_Market_Setting__mdt> instance = null;
    private static String matchingString = 'Production';

    public static List<Gigya_Market_Setting__mdt> selectAll(){
        if(instance == null){
            instance = Gigya_Market_Setting__mdt.getAll().values();
        }
        return instance;
    }

    public static List<Gigya_Market_Setting__mdt> selectByEnvironmentType(Boolean isSandbox){
        List<Gigya_Market_Setting__mdt> settings = new List<Gigya_Market_Setting__mdt>();
        if(isSandbox){
            matchingString = 'Sandbox';
        }
        for(Gigya_Market_Setting__mdt setting : selectAll()){
            if(matchingString.equalsIgnoreCase(setting.Environment__c)){
                settings.add(setting);
            }
        }
        return settings;
    }
}