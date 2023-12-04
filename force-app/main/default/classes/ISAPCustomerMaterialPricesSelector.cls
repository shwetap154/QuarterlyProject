/**
 * @description       : Interface for SAPCustomerMaterialPriceSelector
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 03-29-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-14-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   03-29-2022   Ethan Hirsch @ Zoetis Inc      Add methods selectValidByCustomerNumbersWithProduct and selectValidByCustomerNumbersAndProductId

 **/
public interface ISAPCustomerMaterialPricesSelector extends fflib_ISObjectSelector {
  List<SAPCustomerMaterialPrice__c> selectById(Set<Id> idSet);
  List<SAPCustomerMaterialPrice__c> selectBySAPCustomerId(Set<String> sapCustomerIdSet);

  String selectBySAPCustomerIdAsQueryString(
    Set<String> sapCustomerIdSet
  );

  String selectByEmptyProductPortfolioAsQueryString();

  List<SAPCustomerMaterialPrice__c> selectValidByCustomerNumbersWithProduct(Set<String> customerNumbers);
  List<SAPCustomerMaterialPrice__c> selectValidByCustomerNumbersAndProductIds(Set<String> customerNumbers, Set<Id> productIds);
}