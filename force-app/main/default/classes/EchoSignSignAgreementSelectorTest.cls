/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 06-09-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Ver   Date         Author                      Modification
* 1.0   06-22-2023   Padma Nerella @ Zoetis Inc  Add test method for SelectById TPDEV-1070
**/
@isTest
private class EchoSignSignAgreementSelectorTest {
    @TestSetup
    private static void setup(){
        
        List<Lead> leadToInsert = TestDataFactory.createLeadRec(1);
        insert leadToInsert;
        
        List<echosign_dev1__SIGN_Agreement__c> echoSignAgreeList = TestDataFactory.createEchoSignDev1SignAgreement(1);
        echoSignAgreeList[0].Lead__c =leadToInsert[0].Id;
        insert echoSignAgreeList;
        
        
    }
    
    @isTest
    private static void SelectByIdTest(){
        Set<Id> echoSignIdSet = new Set<Id>();
        List<echosign_dev1__SIGN_Agreement__c> echoSignAgreeList1 = [Select Id,Lead__c,Lead__r.NOA_Application_Number__c,Lead__r.Id From echosign_dev1__SIGN_Agreement__c];
        for(echosign_dev1__SIGN_Agreement__c echo:echoSignAgreeList1){
            echoSignIdSet.add(echo.Id);
        }
        Test.startTest();
        List<echosign_dev1__SIGN_Agreement__c> echoSignAgreeList2 = EchoSignSignAgreementSelector.SelectById(echoSignIdSet);
        Test.stopTest();
        Assert.areEqual(1,echoSignAgreeList2.size(), '1 echosign_dev1__SIGN_Agreement__c record retrived');
    }
}