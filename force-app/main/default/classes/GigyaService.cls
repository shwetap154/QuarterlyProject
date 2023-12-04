/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-20-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
**/
public with sharing class GigyaService {
  public static String getAPIKey(String market) {
    Map<String, Gigya_Market_Setting__mdt> mapGigyaSettingsByMarket = new Map<String, Gigya_Market_Setting__mdt>();
    for (
      Gigya_Market_Setting__mdt setting : GigyaMarketSettingsSelector.selectByEnvironmentType(
        Org.isSandbox()
      )
    ) {
      mapGigyaSettingsByMarket.put(setting.Market__c, setting);
    }
    Gigya_Market_Setting__mdt gigyaSetting = mapGigyaSettingsByMarket.get(
      market
    );
    if (gigyaSetting != null) {
      return mapGigyaSettingsByMarket.get(market).API_Key__c;
    } else {
      return '';
    }
  }
}