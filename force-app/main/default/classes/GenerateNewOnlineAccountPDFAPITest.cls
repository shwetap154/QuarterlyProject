/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 07-06-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   07-06-2023    Padma Nerella @ Zoetis Inc Added generatePDFTest TPDEV-1268
**/

@isTest
private class GenerateNewOnlineAccountPDFAPITest {
    @TestSetup
    static void setup() {
        List<Lead> noaLead = TestDataFactory.createLeadRec(4);
        insert noaLead;
    }
     @isTest
    static void generatePDFTest(){
        List<Lead> leadList = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead];
        List<String> noaAppNumList = new List<String>();
        for(lead ld:leadList){
            noaAppNumList.add(ld.NOA_Application_Number__c);
        }
        String JsonMsg=JSON.serialize(noaAppNumList);
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/NewOnlineAccount/SendForSignature/V1/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        String actualResquestBody = req.requestBody.toString();
        GenerateNewOnlineAccountPDFAPI.generatePDF(noaAppNumList);
        string expectedResponseBody = res.responseBody.tostring();
        Map<String, Blob> responseMap = (Map<String,Blob>)JSON.deserialize(expectedResponseBody, Map<String, Blob>.class);
        Test.stopTest();
        Assert.areEqual(201,res.statusCode,'Lead pdf generated successfully');
        for(Lead ld:leadList){
            System.assert(responseMap.containsKey(ld.NOA_Application_Number__c),'expectedResponseBody contains Key:'+ld.NOA_Application_Number__c);
        }
        
    }
    
     @isTest
    static void generatePDFForceExceptionTest(){
        List<Lead> leadList = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead];
        List<String> noaAppNumList = new List<String>();
        for(lead ld:leadList){
            noaAppNumList.add(ld.NOA_Application_Number__c);
        }
        String JsonMsg=JSON.serialize(noaAppNumList);
        GenerateNewOnlineAccountPDFAPI.forceExceptionToFailAPI = true;
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/NewOnlineAccount/SendForSignature/V1/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        String actualResquestBody = req.requestBody.toString();
        GenerateNewOnlineAccountPDFAPI.generatePDF(noaAppNumList);
        string expectedResponseBody = res.responseBody.tostring();
        Test.stopTest();
        Assert.areEqual(500,res.statusCode,'Lead pdf did not generated');
        Assert.isTrue(String.isNotBlank(expectedresponseBody), 'expected responsebody length is not null');
        
    }
}