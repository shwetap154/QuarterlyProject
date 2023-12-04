/**
 * @description       : Test class for SAPCustomerMaterialPricesSelector
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 03-29-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Ver   Date         Author                         Modification
 * 1.0   09-01-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   03-29-2022   Ethan Hirsch @ Zoetis Inc      Add tests for selectValidByCustomerNumbersWithProduct and selectValidByCustomerNumbersAndProductId.
 *                                                   Change usage of testMethod to isTest
 **/
@IsTest
private class SAPCustomerMaterialPricesSelectorTest {
  private static Pricebook2 standardPricebook = new Pricebook2(
    Id = Test.getStandardPricebookId(),
    IsActive = true
  );

  private static final string testCustomerNumber = '1234567890';

  @TestSetup
  static void makeData() {
    update standardPricebook;
    Product2 prod = new Product2(Name = 'Laptop X200Test', Family = 'Hardware');
    insert prod;
    List<SAPCustomerMaterialPrice__c> pricesToInsert = new List<SAPCustomerMaterialPrice__c>();
    for (Integer i = 0; i < 7; i++) {
      SAPCustomerMaterialPrice__c priceRecord = new SAPCustomerMaterialPrice__c();
      priceRecord.Price__c = 123;
      priceRecord.CurrencyIsoCode = 'USD';
      priceRecord.Customer_Number__c = testCustomerNumber;
      priceRecord.Material_Number__c = '10000111';
      priceRecord.Sales_Organization__c = '2941';
      priceRecord.Market__c = 'Belgium';
      if (i < 5) {
        priceRecord.Valid_From__c = System.today().addMonths(-12);
        priceRecord.Valid_To__c = System.today().addMonths(12);
      }
      else if (i == 5) {
        priceRecord.Valid_From__c = System.today().addMonths(-12);
        priceRecord.Valid_To__c = System.today().addDays(-1);
      }
      else {
        priceRecord.Valid_From__c = System.today().addDays(1);
        priceRecord.Valid_To__c = System.today().addMonths(12);
      }
      priceRecord.Unit_of_Measure__c = 'CT';
      priceRecord.External_Id__c = 'externalIdTest' + i;
      priceRecord.Product__c = prod.Id;
      pricesToInsert.add(priceRecord);
    }
    insert pricesToInsert;
  }
  @isTest
  public static void selectByIdTest() {
    Map<Id, SAPCustomerMaterialPrice__c> materialPriceMap = new Map<Id, SAPCustomerMaterialPrice__c>(
      [SELECT Id FROM SAPCustomerMaterialPrice__c]
    );

    List<SAPCustomerMaterialPrice__c> prices = new List<SAPCustomerMaterialPrice__c>();
    Test.startTest();
    prices = SAPCustomerMaterialPricesSelector.newInstance()
      .selectById(materialPriceMap.keySet());
    Test.stopTest();

    System.assertEquals(7, prices.size(), 'Query should return all 7 results');
  }

  @isTest
  public static void selectBySAPCustomerIdTest() {
    Set<String> customerIds = new Set<String>();
    for (SAPCustomerMaterialPrice__c p : [
      SELECT Customer_Number__c
      FROM SAPCustomerMaterialPrice__c
    ]) {
      customerIds.add(p.Customer_Number__c);
    }

    List<SAPCustomerMaterialPrice__c> prices = new List<SAPCustomerMaterialPrice__c>();
    Test.startTest();
    prices = SAPCustomerMaterialPricesSelector.newInstance()
      .selectBySAPCustomerId(customerIds);
    Test.stopTest();

    System.assertEquals(7, prices.size(), 'Query should return all 7 results');
  }

  @isTest
  public static void selectBySAPCustomerIdAsQueryStringTest() {
    Set<String> customerIds = new Set<String>();
    for (SAPCustomerMaterialPrice__c p : [
      SELECT Customer_Number__c
      FROM SAPCustomerMaterialPrice__c
    ]) {
      customerIds.add(p.Customer_Number__c);
    }

    String queryString;
    Test.startTest();
    queryString = SAPCustomerMaterialPricesSelector.newInstance()
      .selectBySAPCustomerIdAsQueryString(customerIds);
    Test.stopTest();

    System.assert(
      !String.isBlank(queryString),
      'Query string should not be empty'
    );
  }

  @isTest
  public static void selectByEmptyProductPortfolioAsQueryStringTest() {
    String queryString;
    Test.startTest();
    queryString = SAPCustomerMaterialPricesSelector.newInstance()
      .selectByEmptyProductPortfolioAsQueryString();
    Test.stopTest();

    System.assert(
      !String.isBlank(queryString),
      'Query string should not be empty'
    );
  }

  @isTest
  public static void selectValidByCustomerNumbersWithProductTest() {
    List<SAPCustomerMaterialPrice__c> customerMaterialPrices = new List<SAPCustomerMaterialPrice__c>();
    Test.startTest();
      customerMaterialPrices = SAPCustomerMaterialPricesSelector.newInstance()
        .selectValidByCustomerNumbersWithProduct(new Set<String> {testCustomerNumber});
    Test.stopTest();

    System.assertEquals(5, customerMaterialPrices.size(),
      'Expected 5 records to be returned. Products that are outside the valid range may have been returned');
  }

  @isTest
  public static void selectValidByCustomerNumbersAndProductIdsTest() {
    Id productId = [SELECT ID FROM PRODUCT2 LIMIT 1].Id;
    List<SAPCustomerMaterialPrice__c> customerMaterialPrices = new List<SAPCustomerMaterialPrice__c>();
    Test.startTest();
      customerMaterialPrices = SAPCustomerMaterialPricesSelector.newInstance()
        .selectValidByCustomerNumbersAndProductIds(new Set<String> {testCustomerNumber}, new Set<Id> {productId});
    Test.stopTest();

    System.assertEquals(5, customerMaterialPrices.size(),
      'Expected 5 records to be returned. Products that are outside the valid range may have been returned');
  }
}