/**
 * @description       : Main Query class for Market Setting Custom Metadata Type
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-30-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-30-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with retrieveEnabledMarketsForIntegrations method
**/
public inherited sharing class MarketSettingsSelector extends fflib_SObjectSelector implements IMarketSettingsSelector {
    public static IMarketSettingsSelector newInstance() {
        return (IMarketSettingsSelector)Application.Selector.newInstance(
            Market_Setting__mdt.SObjectType
        );
      }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Market_Setting__mdt.Id,
            Market_Setting__mdt.DeveloperName,
            Market_Setting__mdt.Market__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Market_Setting__mdt.sObjectType;
    }

    public Map<Schema.SObjectField, Set<String>> retrieveEnabledMarketsForIntegrations(Set<Schema.SObjectField> integrationFields) {
        fflib_QueryFactory queryFactory = newQueryFactory();

        queryFactory.selectFields(integrationFields);

        // Create or conditions based on the passed in integration fields
        List<String> integrationConditions = new List<String>();
        for (Schema.SObjectField integrationField : integrationFields) {
            integrationConditions.add(String.format('{0} = true', 
                new List<String> {integrationField.getDescribe().getName()}));
        }

        queryFactory.setCondition(String.join(integrationConditions, ' OR '));

        Map<Schema.SObjectField, Set<String>> marketsByIntegrationField = new Map<Schema.SObjectField, Set<String>>();
        for (Market_Setting__mdt marketSetting : Database.query(queryFactory.toSOQL())) {
            for (Schema.SObjectField integrationField: integrationFields) {
                if ((Boolean)marketSetting.get(integrationField)) {

                    if (!marketsByIntegrationField.containsKey(integrationField)) {
                        marketsByIntegrationField.put(integrationField, new Set<String>());
                    }
        
                    marketsByIntegrationField.get(integrationField).add(marketSetting.Market__c);
                }
            }
        }

        return marketsByIntegrationField;
    }
}