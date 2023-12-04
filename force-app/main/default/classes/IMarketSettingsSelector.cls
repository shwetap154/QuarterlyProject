/**
 * @description       : Interface for MarketSettingsSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-30-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-30-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with retrieveEnabledMarketsForIntegrations method
**/
public interface IMarketSettingsSelector extends fflib_ISObjectSelector {
    Map<Schema.SObjectField, Set<String>> retrieveEnabledMarketsForIntegrations(Set<Schema.SObjectField> integrationFields);
}