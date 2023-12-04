/**
 * @description       : Apex REST Service for Sending Adobe Documents for Signature
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-30-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   04-30-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
@RestResource(urlMapping='/Adobe/v1/eSign/*')
global with sharing class AdobeWS_SendForSignature {
  @HttpPut
  global static Result doPut(List<AdobeDocument> documents) {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    Map<String, String> finalMap = new Map<String, String>();
    Result r = new Result();
    String response;
    String batchId;
    List<Id> agreementIds = new List<Id>();
    System.debug('Adobe Documents: ' + documents);
    if (documents.isEmpty()) {
      r.success = false;
      r.response = 'request contained no document Ids';
      return r;
    }

    for (AdobeDocument record : documents) {
      agreementIds.add(record.Id);
    }

    if (!agreementIds.isEmpty()) {
      echosign_dev1.EchoSignActionBatch agreementsBatch = new echosign_dev1.EchoSignActionBatch(
        agreementIds,
        'Send',
        null,
        null
      );
      batchId = Test.isRunningTest() ? 'testBatchId' : Database.executeBatch(agreementsBatch);
    }
    r.success = true;
    r.response = 'Success';
    r.batchId = batchId;
    return r;
  }

  global class AdobeDocument {
    global String Id { get; set; }
  }

  global class Result {
    global Boolean success;
    global String response;
    global String batchId;
  }
}