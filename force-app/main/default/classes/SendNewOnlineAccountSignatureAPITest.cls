/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 09-07-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   6-23-2023    Padma Nerella @ Zoetis Inc  Added sendForSignatureTest TPDEV-1070
* 1.1   9-07-2023    Padma Nerella @ Zoetis Inc  Modfied query where condition
**/

@isTest
private class SendNewOnlineAccountSignatureAPITest {
    @TestSetup
    static void setup() {
        User user1 = ZTS_EU_DataUtilityTest.createUserWithProfile('New Online Account Profile1',false);
        user1.FirstName='New Online Account';
        user1.LastName='Site Guest User';
        user1.echosign_dev1__EchoSign_Allow_Delegated_Sending__c =true;
        insert user1;
        
        List<Lead> noaLead = TestDataFactory.createLeadRec(4);
        insert noaLead;
        
        Veterinarian_Information__c vetInfoRec = TestDataFactory.createVetInformationRec(noaLead[0].Id);
        vetInfoRec.Veterinarian_Email__c = 'test@Zoetis.com';
        insert vetInfoRec;
        String name = 'NOALeadDM';
        List<echosign_dev1__SIGN_Data_Mapping__c> echoSignList = new List<echosign_dev1__SIGN_Data_Mapping__c>();
        echosign_dev1__SIGN_Data_Mapping__c echoSignDataMapping1 =TestDataFactory.createEchoSigndev1SignDataMapping(name);
        echoSignList.add(echoSignDataMapping1);
        insert echoSignList;
    }
    
    @isTest
    static void sendForSignatureTest(){
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
        SendNewOnlineAccountSignatureAPI.sendForSignature(noaAppNumList);
        string expectedResponseBody = res.responseBody.tostring();
        Map<String, Id> responseMap = (Map<String,Id>)JSON.deserialize(expectedResponseBody, Map<String, Id>.class);
        Test.stopTest();
        Assert.areEqual(201,res.statusCode,'Lead updated successfully,echosign_dev1__SIGN_Agreement and Attachment are created successfully');
        Assert.areNotEqual(expectedResponseBody, actualResquestBody);
        
        List<Lead> updatedLeadList1 = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead where Signature_Status__c ='Out for Signature'];
        Assert.areEqual(4, updatedLeadList1.size(), '4 Lead records are updated');
        List<echosign_dev1__SIGN_Agreement__c> echoSignList = [Select Id, Lead__c,Lead__r.NOA_Application_Number__c from echosign_dev1__SIGN_Agreement__c where Lead__c=:updatedLeadList1];
        Assert.areEqual(4, echoSignList.size(), '4 echosign_dev1__SIGN_Agreement records created');
        for(echosign_dev1__SIGN_Agreement__c echo:echoSignList){
            System.assert(responseMap.containsKey(echo.Lead__r.NOA_Application_Number__c),'expectedResponseBody contains Key:'+echo.Lead__r.NOA_Application_Number__c);
            System.assertEquals(echo.Id, responseMap.get(echo.Lead__r.NOA_Application_Number__c), 'expectedResponseBody contains Value:'+echo.Id);
        }
        List<Attachment> attachmentlist = [Select Id,Name,description,parentId From Attachment where parentId=:echoSignList];
        Assert.areEqual(4,attachmentlist.size(), '4 attachment records got created');
    }
    
    @isTest
    static void sendForSignatureForceExceptionTest(){
        
        List<Lead> leadList = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead];
        List<String> noaAppNumList = new List<String>();
        for(lead ld:leadList){
            noaAppNumList.add(ld.NOA_Application_Number__c);
        }
        String JsonMsg=JSON.serialize(noaAppNumList);
        SendNewOnlineAccountSignatureAPI.forceExceptionToFailAPI=true;
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/NewOnlineAccount/SendForSignature/V1/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        String actualResquestBody = req.requestBody.toString();
        SendNewOnlineAccountSignatureAPI.sendForSignature(noaAppNumList);
        string expectedResponseBody = res.responseBody.tostring();
        Test.stopTest();
        Assert.areEqual(500,res.statusCode,'Exception occurred');
        Assert.areNotEqual(expectedResponseBody, actualResquestBody);
        
        List<Lead> updatedLeadList1 = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead where Signature_Status__c ='Out for Signature'];
        Assert.areEqual(0, updatedLeadList1.size(), 'Lead records did not get updated since Exception occurred');
        Assert.isTrue(String.isNotBlank(expectedresponseBody), 'expected responsebody length is not null');
    }
}