/**
 * @description       : Test Class for AdobeWS_SendForSignature
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-30-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   05-10-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
@IsTest
public with sharing class AdobeWS_SendForSignature_Test {
  @TestSetup
  static void makeData() {
    Lead ld = new Lead();
    ld.Company = 'Test Lead Co';
    ld.FirstName = 'Test';
    ld.LastName = 'Lead';
    insert ld;

    echosign_dev1__SIGN_Agreement__c agmt = new echosign_dev1__SIGN_Agreement__c();
    agmt.Name = 'Zoetis For Shelters Application - ' + ld.Name;
    agmt.Lead__c = ld.Id;
    agmt.echosign_dev1__Signature_Flow__c = 'Any Order';
    agmt.echosign_dev1__Recipient_Addresses__c = 'nam1994212@mailinator.com';
    //agmt.echosign_dev1__Process_Template__c = [
    //    SELECT Id, Name
    //    FROM echosign_dev1__SIGN_Data_Mapping__c
    //    WHERE Name = 'NOALeadDM'
    //  ][0]
    //  .Id;  
    agmt.echosign_dev1__Message__c = 'If you have questions about your application, please email us at shelterteam@zoetis.com';
    insert agmt;
  }

  @IsTest
  static void doPut_Test() {
    List<echosign_dev1__SIGN_Agreement__c> agreements = [
      SELECT Id
      FROM echosign_dev1__SIGN_Agreement__c
    ];
    List<AdobeWS_SendForSignature.AdobeDocument> documents = new List<AdobeWS_SendForSignature.AdobeDocument>();
    AdobeWS_SendForSignature.Result results;
    String resultsJSON;

    Test.startTest();
    for (echosign_dev1__SIGN_Agreement__c record : agreements) {
      AdobeWS_SendForSignature.AdobeDocument doc = new AdobeWS_SendForSignature.AdobeDocument();
      doc.Id = record.Id;
      documents.add(doc);
    }
    results = AdobeWS_SendForSignature.doPut(documents);
    resultsJSON = JSON.serialize(results);
    Test.stopTest();

    System.assert(resultsJSON.containsIgnoreCase('testBatchId'));
    System.assert(resultsJSON.containsIgnoreCase('success'));
  }

  @IsTest
  static void doPut_Failure_Test() {
    List<AdobeWS_SendForSignature.AdobeDocument> documents = new List<AdobeWS_SendForSignature.AdobeDocument>();
    AdobeWS_SendForSignature.Result results;
    String resultsJSON;

    Test.startTest();
    results = AdobeWS_SendForSignature.doPut(documents);
    resultsJSON = JSON.serialize(results);
    Test.stopTest();

    System.assert(resultsJSON.containsIgnoreCase('false'));
    System.assert(resultsJSON.containsIgnoreCase('no document Ids'));
  }
}