/**
 * @description       : Interface for AddressesSelector
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 09-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-14-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   03-24-2022   Ethan Hirsch @ Zoetis Inc      Add selectDirectActiveShipToAddressesByAccountId method
 * 1.2   05-25-2022   Ethan Hirsch @ Zoetis Inc      Add selectByAccountIdWithRelatedData method
 * 1.3   07-11-2022   Ethan Hirsch @ Zoetis Inc      Change input type of childRelationships in selectByAccountIdWithRelatedData
 * 1.4   09-19-2022   Ethan Hirsch @ Zoetis Inc      Update selectByAccountIdWithRelatedData to change the output type
 *                                                   to handle more than 20 child relationships
 **/
public interface IAddressesSelector extends fflib_ISObjectSelector {
  List<Address__c> selectById(Set<Id> idSet);
  List<Address__c> selectByType(Set<String> typeSet);
  List<Address__c> selectByAccountId(Set<Id> accountIdSet);
  List<Address__c> selectBySourceAccountNumber(
    Set<String> sourceAccountNumbers
  );
  List<Address__c> selectBySourceAccountNumberAndType(
    Set<String> sourceAccountNumbers,
    Set<String> types
  );
  List<Address__c> selectDirectActiveShipToAddressesByAccountId(Set<Id> accountIdSet);
  Map<Id, MergeService.RecordAndRelationships> selectByAccountIdWithRelatedData(Set<Id> accountIdSet, List<MergeService.MergeChildRelationship> childRelationships);
  }