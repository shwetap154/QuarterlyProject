/**
 * @description       : Main Query Class for SAPCustomerMaterialPrice__c
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 03-30-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-14-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   03-29-2022   Ethan Hirsch @ Zoetis Inc      Add methods selectValidByCustomerNumbersWithProduct and selectValidByCustomerNumbersAndProductId.
 *                                                   Specify Inherited Sharing to fix query issues in alphaCreateOrder and alphaDistReadOnlyController
 * 1.2   03-30-2022   Ethan Hirsch @ Zoetis Inc      Add order by CreatedDate ASC to queries in selectValidByCustomerNumbersWithProduct and selectValidByCustomerNumbersAndProductId.
 * 1.3	 10-17-2023	  Kalyan Nayak @ Zoetis Inc		 Added 3 fields under selectFields in selectValidByCustomerNumbersAndProductIds method
 **/

public inherited sharing class SAPCustomerMaterialPricesSelector extends fflib_SObjectSelector implements ISAPCustomerMaterialPricesSelector {
  public static ISAPCustomerMaterialPricesSelector newInstance() {
    return (ISAPCustomerMaterialPricesSelector) Application.Selector.newInstance(
      SAPCustomerMaterialPrice__c.SObjectType
    );
  }

  public static final String CONDITION_NO_PRODUCT_PORTFOLIO = 'Account_Product_Portfolio__c = null';
  public static final String CONDITION_HAS_PRODUCT_ID = 'Product__c != null';

  /**
  * @description Default Field List to return with all Queries
  * @author Morgan Marchese @ Zoetis Inc | 07-19-2021 
  * @return List<Schema.SObjectField> 
  **/
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      SAPCustomerMaterialPrice__c.Name,
      SAPCustomerMaterialPrice__c.Id,
      SAPCustomerMaterialPrice__c.Customer_Number__c,
      SAPCustomerMaterialPrice__c.Material_Number__c,
      SAPCustomerMaterialPrice__c.Price__c,
      SAPCustomerMaterialPrice__c.Market__c,
      SAPCustomerMaterialPrice__c.CurrencyIsoCode,
      SAPCustomerMaterialPrice__c.OwnerId,
      SAPCustomerMaterialPrice__c.Sales_Organization__c,
      SAPCustomerMaterialPrice__c.Valid_From__c,
      SAPCustomerMaterialPrice__c.Valid_To__c,
      SAPCustomerMaterialPrice__c.Account_Product_Portfolio__c,
      SAPCustomerMaterialPrice__c.Product__c
    };
  }


  /**
  * @description Gets the SObject Type from Salesforce
  * @author Morgan Marchese @ Zoetis Inc | 07-19-2021 
  * @return Schema.SObjectType 
  **/
  public Schema.SObjectType getSObjectType() {
    return SAPCustomerMaterialPrice__c.SObjectType;
  }

  /**
  * @description Selects records by Id
  * @author Morgan Marchese @ Zoetis Inc | 07-19-2021 
  * @param Set<Id> idSet 
  * @return List<SAPCustomerMaterialPrice__c> 
  **/
  public List<SAPCustomerMaterialPrice__c> selectById(Set<Id> idSet) {
    return (List<SAPCustomerMaterialPrice__c>) selectSObjectsById(idSet);
  }

  /**
  * @description Selects records by SAP Customer Id
  * @author Morgan Marchese @ Zoetis Inc | 07-19-2021 
  * @param Set<String> sapCustomerIdSet 
  * @return List<SAPCustomerMaterialPrice__c> 
  **/
  public List<SAPCustomerMaterialPrice__c> selectBySAPCustomerId(
    Set<String> sapCustomerIdSet
  ) {
    fflib_QueryFactory recordQueryFactory = newQueryFactory();
    recordQueryFactory.setCondition('Customer_Number__c IN :sapCustomerIdSet');
    return (List<SAPCustomerMaterialPrice__c>) Database.query(
      recordQueryFactory.toSOQL()
    );
  }

  /**
  * @description Selects records by SAP Customer Id. 
  * Returns them as a String for batch jobs/soql loops.
  * @author Morgan Marchese @ Zoetis Inc | 07-19-2021 
  * @param Set<String> sapCustomerIdSet 
  * @return String 
  **/
  public String selectBySAPCustomerIdAsQueryString(
    Set<String> sapCustomerIdSet
  ) {
    fflib_QueryFactory recordQueryFactory = newQueryFactory();
    recordQueryFactory.setCondition('Customer_Number__c IN :sapCustomerIdSet');
    return recordQueryFactory.toSOQL();
  }

  public String selectByEmptyProductPortfolioAsQueryString() {
    fflib_QueryFactory recordQueryFactory = newQueryFactory();
    recordQueryFactory.setCondition('Account_Product_Portfolio__c = null AND Product__c != null');
    return recordQueryFactory.toSOQL();
  }

  public List<SAPCustomerMaterialPrice__c> selectValidByCustomerNumbersWithProduct(Set<String> customerNumbers) {
    fflib_QueryFactory recordQueryFactory = newQueryFactory();
    recordQueryFactory.selectFields(new List<String> {
      'Unit_Of_Measure__c',
      'Product__r.Name',
      'Product__r.SAP_Material__r.SAP_Sales_Unit_of_Measure__c'
    });

    recordQueryFactory.setCondition((
      string.join(new List<String> {
        'Customer_Number__c in :customerNumbers',
        'AND Product__c != NULL',
        'AND Valid_From__c <= TODAY',
        'AND Valid_To__c >= TODAY'
      }, ' ')));

      recordQueryFactory.setOrdering('Product__r.Name', fflib_QueryFactory.SortOrder.Ascending);
      return (List<SAPCustomerMaterialPrice__c>)Database.query(recordQueryFactory.toSOQL());
  }

  public List<SAPCustomerMaterialPrice__c> selectValidByCustomerNumbersAndProductIds(Set<String> customerNumbers, Set<Id> productIds) {
    fflib_QueryFactory recordQueryFactory = newQueryFactory();
    recordQueryFactory.selectFields(new List<String> {
      'Unit_Of_Measure__c',
      'Product__r.Name',
      'Price__c',
      'Product__r.SAP_Material__r.SAP_Sales_Unit_of_Measure__c',
      'Product__r.SAP_Material__r.SAP_Product_Number__c'
    });

    recordQueryFactory.setCondition((
      string.join(new List<String> {
        'Customer_Number__c in :customerNumbers',
        'AND Product__c in :productIds',
        'AND Valid_From__c <= TODAY',
        'AND Valid_To__c >= TODAY'
      }, ' ')));
                          
      recordQueryFactory.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
      
    
      return (List<SAPCustomerMaterialPrice__c>)Database.query(recordQueryFactory.toSOQL());
  }
}