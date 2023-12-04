/**
 * @description       : Batch Job for matching AccountProductPortfolio__c Records
 * to SAPCustomerMaterialPrice__c records by looping through SAPCustomerMaterialPrice__c records
 * without an existing AccountProductPortfolio__c relationship, matching them to existing
 * AccountProductPortfolio__c records if found, or creating new ones as needed.
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-25-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-19-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   07-19-2021   Namrata Patane @ Zoetis Inc    Worked on Logic
 * 1.2   07-20-2021   Morgan Marchese @ Zoetis Inc   Moved logic to Service Class
 **/
global class SAPCustomerPrice_Portfolio_Batch implements Database.Batchable<sObject> {
  public SAPCustomerPrice_Portfolio_Batch() {
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      SAPCustomerMaterialPricesSelector.newInstance()
        .selectByEmptyProductPortfolioAsQueryString()
    );
  }

  global void execute(
    Database.BatchableContext BC,
    List<SAPCustomerMaterialPrice__c> scope
  ) {
    SAPCustomerMaterialPricesService.linkToAccountProductPortfolio(scope);
  }

  global void finish(Database.BatchableContext BC) {
  }
}