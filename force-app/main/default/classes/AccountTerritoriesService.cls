/**
 * @description       : Service Class for Account Territories
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 09-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-25-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with mergeRelatedAccountTerritoriesByAccountIdAndTerritory method for merging duplicate Account Territories on an Account. Primarily for INTL data.
 * 1.1   07-11-2022   Ethan Hirsch @ Zoetis Inc   Update merge logic to pass long additional details for a Child Relationship
 * 1.2   07-21-2022   Ethan Hirsch @ Zoetis Inc   Change merge logic to prioritize keeping the Account Territory with the correct ZTS_Zoetis_SFDC_ID__c.
 *                                                Also add logic to set ZTS_Zoetis_SFDC_ID__c correctly
 * 1.3   09-19-2022   Ethan Hirsch @ Zoetis Inc   Change the logic of mergeRelatedAccountTerritoriesByAccountIdAndTerritory to change how relationships are processed
**/
public with sharing class AccountTerritoriesService {
    @testVisible 
    private static Id overwriteMergeZoetisSFDCIDId;
    
    /**
    * @description Merges duplicate Account Territories on an account together.
    *              Duplicate Account Territory are identified by having the same Account and Territory record.
    *              Child records of the duplicated Account Territory are transfered to the matching Account Territory.
    *                The child records to keep are identified by the childObjectsToMergeMap collection.
    * @author Ethan Hirsch @ Zoetis Inc | 05-25-2022 
    * @param accountIds 
    * @param childObjectsToMergeMap 
    * @param updateRelatedRecordsMap 
    * @return Map<Id, ZTS_AccountTerritory__c> 
    **/
    public static Map<Id, ZTS_AccountTerritory__c> mergeRelatedAccountTerritoriesByAccountIdAndTerritory(Set<Id> accountIds, 
        Map<String, MergeRelatedRecordLookupsSelector.ChildObject> childObjectsToMergeMap,
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap) {
        Map<String, List<ZTS_AccountTerritory__c>> accountTerritoriesByUniqueKey = new Map<String, List<ZTS_AccountTerritory__c>>();
        Map<String, ZTS_AccountTerritory__c> keepAccountTerritoriesByUniqueKey = new Map<String, ZTS_AccountTerritory__c>();
        List<ZTS_AccountTerritory__c> deleteAccountTerritories = new List<ZTS_AccountTerritory__c>();

        List<MergeService.MergeChildRelationship> childRelationships = MergeService.getChildRelationshipsForObjects(
            childObjectsToMergeMap, ZTS_AccountTerritory__c.getSObjectType());

        Map<Id, MergeService.RecordAndRelationships> recordsAndRelationshipsMap = 
            AccountTerritoriesSelector.newInstance().selectByAccountIdWithRelatedData(accountIds, childRelationships);
        
        for (Id accountTerritoryId : recordsAndRelationshipsMap.keySet()) {
            ZTS_AccountTerritory__c accountTerritory  = (ZTS_AccountTerritory__c)recordsAndRelationshipsMap.get(accountTerritoryId).record;
            // The unique Key contains the Account Id to allow duplicate Territories to exists across Accounts
            string uniqueKey = String.format('{0}{1}', new List<Object> {accountTerritory.ZTS_EU_Account__c,
                accountTerritory.ZTS_EU_Territory__c});
                
            if (!accountTerritoriesByUniqueKey.containsKey(uniqueKey)) {
                accountTerritoriesByUniqueKey.put(uniqueKey, new List<ZTS_AccountTerritory__c>());
            }

            accountTerritoriesByUniqueKey.get(uniqueKey).add(accountTerritory);

            // For INTL Data, ZTS Zoetis SFDC Id is set via a Workflow Rule which can't be bypassed in code.
            // To allow for testing logic around this field, overwriteMergeZoetisSFDCIDId can be used to overwrite
            // the ZTS_Zoetis_SFDC_ID__c field.
            if (Test.isRunningTest() && accountTerritory.Id == overwriteMergeZoetisSFDCIDId) {
                accountTerritory.ZTS_Zoetis_SFDC_ID__c = 'INVALID';
            }

            if (!keepAccountTerritoriesByUniqueKey.containsKey(uniqueKey)) {
                keepAccountTerritoriesByUniqueKey.put(uniqueKey, accountTerritory);
                continue;
            }

            ZTS_AccountTerritory__c matchingAccountTerritory = keepAccountTerritoriesByUniqueKey.get(uniqueKey);

            Boolean externalIdIsBlankOrNotBlankOnBothRecords = ((String.isBlank(accountTerritory.ZTS_AT_External_ID__c) && 
                String.isBlank(matchingAccountTerritory.ZTS_AT_External_ID__c)) ||
                (String.isNotBlank(accountTerritory.ZTS_AT_External_ID__c) && 
                String.isNotBlank(matchingAccountTerritory.ZTS_AT_External_ID__c)));

            Boolean zoetisSFDCIDIsPopulatedProperlyOrNotOnBothRecords = ((
                accountTerritory.ZTS_Zoetis_SFDC_ID__c?.contains(accountTerritory.ZTS_EU_Account__r.ZTS_EU_Zoetis_SFDC_ID__c) == true &&
                matchingAccountTerritory.ZTS_Zoetis_SFDC_ID__c?.contains(accountTerritory.ZTS_EU_Account__r.ZTS_EU_Zoetis_SFDC_ID__c) == true) ||
                (accountTerritory.ZTS_Zoetis_SFDC_ID__c?.contains(accountTerritory.ZTS_EU_Account__r.ZTS_EU_Zoetis_SFDC_ID__c) != true &&
                matchingAccountTerritory.ZTS_Zoetis_SFDC_ID__c?.contains(accountTerritory.ZTS_EU_Account__r.ZTS_EU_Zoetis_SFDC_ID__c) != true));

            // Deduplication logic. 
            // First keep the Account Territory with an External Id as this came from SAP and will get recreated.
            // If they both have an External Id or don't have an External Id, keep the Account Territory where ZTS_Zoetis_SFDC_ID__c contains the current Account.
            // Finally, keep the oldest Account Territory if all other conditions cannot be used to prioritize an Account Territory.
            if ((String.isNotBlank(accountTerritory.ZTS_AT_External_ID__c) && 
                String.isBlank(matchingAccountTerritory.ZTS_AT_External_ID__c))) {
                keepAccountTerritoriesByUniqueKey.put(uniqueKey, accountTerritory);
            }
            // Verify both Account Territories either both have an External Id or don't have an External Id
            // before moving to the next prioritization logic. 
            // This avoids deleting an Account Territory with an External Id incorrectly.
            else if (externalIdIsBlankOrNotBlankOnBothRecords &&
                accountTerritory.ZTS_Zoetis_SFDC_ID__c?.contains(accountTerritory.ZTS_EU_Account__r.ZTS_EU_Zoetis_SFDC_ID__c) == true &&
                matchingAccountTerritory.ZTS_Zoetis_SFDC_ID__c?.contains(accountTerritory.ZTS_EU_Account__r.ZTS_EU_Zoetis_SFDC_ID__c) != true) {
                keepAccountTerritoriesByUniqueKey.put(uniqueKey, accountTerritory);
            }
            // Verify both Account Territories either both have the current Account in their Zoetis SF ID or not
            // before moving to the next prioritization logic. 
            // This avoids deleting an Account Territory with Zoetis SF ID populated properly
            else if (externalIdIsBlankOrNotBlankOnBothRecords &&
                zoetisSFDCIDIsPopulatedProperlyOrNotOnBothRecords &&
                accountTerritory.CreatedDate < matchingAccountTerritory.CreatedDate) {
                keepAccountTerritoriesByUniqueKey.put(uniqueKey, accountTerritory);
            }
        }

        string zoetisSFIdFieldName = ZTS_AccountTerritory__c.ZTS_Zoetis_SFDC_ID__c.getDescribe().getName();
        for (String uniqueKey : accountTerritoriesByUniqueKey.keySet()) {
            MergeService.DeleteRecordsAndKeepRecord deleteRecordsAndKeepRecord = MergeService.setLookupFieldsAndDeleteRecords(
                uniqueKey, keepAccountTerritoriesByUniqueKey, accountTerritoriesByUniqueKey, childRelationships, 
                recordsAndRelationshipsMap, updateRelatedRecordsMap);

            ZTS_AccountTerritory__c keepAccountTerritory = (ZTS_AccountTerritory__c)deleteRecordsAndKeepRecord.keepRecord;

            MergeService.setUniqueKeyField(keepAccountTerritory, zoetisSFIdFieldName,
                keepAccountTerritory.ZTS_EU_Account__r.ZTS_EU_Zoetis_SFDC_ID__c,
                keepAccountTerritory.ZTS_EU_Account__r.ZTS_EU_Zoetis_SFDC_ID__c,
                updateRelatedRecordsMap);

            deleteAccountTerritories.addAll((List<ZTS_AccountTerritory__c>)deleteRecordsAndKeepRecord.deleteRecords);
        }

        return new Map<Id, ZTS_AccountTerritory__c>(deleteAccountTerritories);
    }
}