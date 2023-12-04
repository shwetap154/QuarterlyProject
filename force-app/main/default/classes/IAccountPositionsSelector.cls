/**
 * @description       : Interface for AccountPositionsSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 09-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-07-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with selectByAcctTerritoryId, selectByAccounts, and selectByAccountIdsAndEmployeeIds
 * 1.1   04-13-2022   Ethan Hirsch @ Zoetis Inc   Add selectByAccountIdsAndEmployeeIdsAndMarket
 * 1.1   05-25-2022   Ethan Hirsch @ Zoetis Inc   Add selectByAccountIdWithRelatedData
 * 1.3   07-11-2022   Ethan Hirsch @ Zoetis Inc   Change input type of childRelationships in selectByAccountIdWithRelatedData
 * 1.4   09-19-2022   Ethan Hirsch @ Zoetis Inc   Update selectByAccountIdWithRelatedData to change the output type to
 *                                                process more than 20 child relationships.
**/
public interface IAccountPositionsSelector extends fflib_ISObjectSelector {
    List<ZTS_EU_Account_Position__c> selectByAcctTerritoryId(Set<Id> accountTerritoryIds, Boolean international);
    List<ZTS_EU_Account_Position__c> selectByAccountIds(Set<Id> accountIds);
    List<ZTS_EU_Account_Position__c> selectByAccountIdsAndEmployeeIds(Set<Id> accountIds, set<Id> employeeIds);
    List<ZTS_EU_Account_Position__c> selectByAccountIdsAndEmployeeIdsAndMarket(Set<Id> accountIds, set<Id> employeeIds, Boolean isUnitedStates);
    Map<Id, MergeService.RecordAndRelationships> selectByAccountIdWithRelatedData(Set<Id> accountIdSet, List<MergeService.MergeChildRelationship> childRelationships);
}