/**
* @description       : Test class for  ContentDocumentLinkService 
* @author            : Suprabha @ Zoetis Inc
* @group             : 
* @last modified on  : 06-27-2023
* @last modified by  : Suprabha @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   06-27-2023   Suprabha      Added afterInsertTest method to insert the knowledge article and content version and content document link
* 1.1   09-27-2023   Sweta Kumari  Added beforeInsertTest method to insert the Order and content version and content document link 
* 1.2   10-06-2023   Pranav Raut   Added beforeInsertConDocOtherThanOrderTest method for creating an attachment for a non-Order object and confirm Visibility is not set to AllUsers
**/

@isTest
public class ContentDocumentLinkTriggerHandler_Test {
    
    @isTest
    private static void afterInsertTest() {
        Map<Id,ContentDocumentLink> contentDocMap = new Map<Id,ContentDocumentLink>();
        Test.startTest();
        List<FAQ__kav> lstKnowledgeArticle = TestDataFactory.createKnowledgeArticle(1,'Test FAQ','Test summary','Test content','TestURL');
        insert lstKnowledgeArticle;
        List<ContentVersion> lstContentVersion = TestDataFactory.createContentVersion(1,'Test Document','TestDocument.pdf','Test content',true);
        insert lstContentVersion;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:lstContentVersion[0].Id].ContentDocumentId;
        List<ContentDocumentLink> lstContentDocumentLink = TestDataFactory.createContentDocumentLink(1,lstKnowledgeArticle[0].Id,conDocId,'I');
        insert lstContentDocumentLink;
        Test.stopTest();
        
        ContentDocumentLink updatedContentDocumentLink = [SELECT Id, ShareType, Visibility FROM ContentDocumentLink WHERE Id = :lstContentDocumentLink[0].Id];
        
        // Assert the results
        System.assertEquals('I', updatedContentDocumentLink.ShareType);
        
        
    }
    
     @isTest
    private static void beforeInsertTest() {
    List<ContentDocumentLink> contentDocMap = new List<ContentDocumentLink>();
    List<State_Country__c> stateCountryList = new List<State_Country__c>();
    State_Country__c stateCountryUK = TestDataFactory.createStateCountry('United Kingdom', 'County Down', false);
    stateCountryList.add(stateCountryUK);
    insert stateCountryList;

    Account lstAccount = TestDataFactory.createAccount_EU('UK Test Account ',stateCountryUK.Id,false);
        
    insert lstAccount;
    Order lstOrder = TestDataFactory.createOrder(lstAccount.Id, false);
    insert lstOrder;
    List<ContentVersion> lstContentVersion = TestDataFactory.createContentVersion(1, 'Test Document', 'TestDocument.pdf', 'Test content', true);
    insert lstContentVersion;
    Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :lstContentVersion[0].Id].ContentDocumentId;
    List<ContentDocumentLink> lstContentDocumentLink = TestDataFactory.createContentDocumentLink(1, lstOrder.Id, conDocId, 'I');
    for (ContentDocumentLink cdl : lstContentDocumentLink) {
        cdl.Id = null;
    }
    Test.startTest();
    insert lstContentDocumentLink;
    Test.stopTest();

    ContentDocumentLink updatedContentDocumentLink = [SELECT Id, ShareType, Visibility FROM ContentDocumentLink WHERE Id = :lstContentDocumentLink[0].Id];
    System.assertEquals('AllUsers', updatedContentDocumentLink.Visibility);
}
    
    // Test method for creating an attachment for a non-Order object and confirm Visibility is not set to AllUsers
    @isTest
    private static void beforeInsertConDocOtherThanOrderTest() {
    List<ContentDocumentLink> contentDocMap = new List<ContentDocumentLink>();
    List<State_Country__c> stateCountryList = new List<State_Country__c>();
    State_Country__c stateCountryUK = TestDataFactory.createStateCountry('United Kingdom', 'County Down', false);
    stateCountryList.add(stateCountryUK);
    insert stateCountryList;

    Account lstAccount = TestDataFactory.createAccount_EU('UK Test Account ',stateCountryUK.Id,false);        
    insert lstAccount;

    List<ContentVersion> lstContentVersion = TestDataFactory.createContentVersion(1, 'Test Document', 'TestDocument.pdf', 'Test content', true);
    insert lstContentVersion;
    Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :lstContentVersion[0].Id].ContentDocumentId;
    List<ContentDocumentLink> lstContentDocumentLink = TestDataFactory.createContentDocumentLink(1, lstAccount.Id, conDocId, 'I');
    for (ContentDocumentLink cdl : lstContentDocumentLink) {
        cdl.Id = null;
    }
    Test.startTest();
    insert lstContentDocumentLink;
    Test.stopTest();
    ContentDocumentLink updatedContentDocumentLink = [SELECT Id, ShareType, Visibility FROM ContentDocumentLink WHERE Id = :lstContentDocumentLink[0].Id];
    System.assertEquals('InternalUsers', updatedContentDocumentLink.Visibility);
}

}