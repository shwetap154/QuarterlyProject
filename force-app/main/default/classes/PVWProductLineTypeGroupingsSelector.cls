/**
 * @description       : Main Query class for PVW_Product_Line_Type_Grouping__mdt
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-08-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-08-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with selectProductLinesByType method
**/
public inherited sharing class PVWProductLineTypeGroupingsSelector extends fflib_SObjectSelector implements IPVWProductLineTypeGroupingsSelector {
    public static IPVWProductLineTypeGroupingsSelector newInstance() {
        return (IPVWProductLineTypeGroupingsSelector)Application.Selector.newInstance(
            PVW_Product_Line_Type_Grouping__mdt.SObjectType
        );
      }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PVW_Product_Line_Type_Grouping__mdt.Id,
            PVW_Product_Line_Type_Grouping__mdt.Product_Type__c,
            PVW_Product_Line_Type_Grouping__mdt.Product_Line__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return PVW_Product_Line_Type_Grouping__mdt.sObjectType;
    }

    public Map<String, Set<String>> selectProductLinesByType(Set<String> types) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.setCondition('Product_Type__c in: types');

        Map<String, Set<String>> productLinesByType = new Map<String, Set<String>>();
        for (PVW_Product_Line_Type_Grouping__mdt typeGrouping : (List<PVW_Product_Line_Type_Grouping__mdt>)Database.query(queryFactory.toSOQL())) {
            if (!productLinesByType.containsKey(typeGrouping.Product_Type__c)) {
                productLinesByType.put(typeGrouping.Product_Type__c, new Set<String>());
            }   

            productLinesByType.get(typeGrouping.Product_Type__c).add(typeGrouping.Product_Line__c.toLowerCase());
        }

        return productLinesByType;
    }
}