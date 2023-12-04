/**
 * @description       : Selector class for Account Territory
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 09-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-25-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with selectByAccountIdWithRelatedData method
 * 1.1   06-29-2022   Ethan Hirsch @ Zoetis Inc   Add ZTS_EU_Account__r.ZTS_EU_Zoetis_SFDC_ID__c to the fields queried in selectByAccountIdWithRelatedData
 * 1.2   07-11-2022   Ethan Hirsch @ Zoetis Inc   Change input type of childRelationships in selectByAccountIdWithRelatedData
 * 1.3   07-18-2022   Ethan Hirsch @ Zoetis Inc   Add ZTS_Zoetis_SFDC_ID__c field to selectByAccountIdWithRelatedData query
 * 1.4   09-19-2022   Ethan Hirsch @ Zoetis Inc   Update selectByAccountIdWithRelatedData to handle more than 20 child relationships
 *                                                and use a helper class to perform its query for reusability.
 **/
public with sharing class AccountTerritoriesSelector {
    // Once fflib is implemented, this should return an interface similar to other Selector classes.
    public static AccountTerritoriesSelector newInstance() {
        return new AccountTerritoriesSelector();
    }

    public Map<Id, MergeService.RecordAndRelationships> selectByAccountIdWithRelatedData(Set<Id> accountIdSet, List<MergeService.MergeChildRelationship> childRelationships) {
        // Due to needing to use dynamic relationships, this query does not use fflib
        // A List that is joined together with String.join is used instead of String Concatenation for better performance
        List<String> queryBase = new List<String>();
        queryBase.add('SELECT Id, ZTS_EU_Account__c, ZTS_EU_Territory__c, ZTS_AT_External_ID__c, ');
        queryBase.add('ZTS_Ter_External_ID__c, CreatedDate, ZTS_EU_Account__r.ZTS_EU_Zoetis_SFDC_ID__c,');
        queryBase.add('ZTS_Zoetis_SFDC_ID__c');
    
        List<String> querySuffix = new List<String>();
        querySuffix.add(' FROM ZTS_AccountTerritory__c');
        // Due to the use of a helper method, bind parameters are not used
        querySuffix.add(String.format(' WHERE ZTS_EU_Account__c In (\'\'{0}\'\')',
            new List<String>{String.join(new List<Id>(accountIdSet), '\',\'')}));
    
        return MergeService.queryRelatedData(String.join(queryBase, ''), String.join(querySuffix, ''), childRelationships);
      }
}