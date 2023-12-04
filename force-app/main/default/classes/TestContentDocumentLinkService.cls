/**
* @description       : Test class for  ContentDocumentLinkService 
* @author            : Suprabha @ Zoetis Inc
* @group             : 
* @last modified on  : 06-23-2023
* @last modified by  : Suprabha @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   06-23-2023   Suprabha     Added testUpdateContentDocumentShareType method to insert the knowledge article and content version and content document link
**/

@isTest
public class TestContentDocumentLinkService {
    
   static testMethod void testUpdateContentDocumentShareType() {
       
        Map<Id,ContentDocumentLink> contentDocMap = new Map<Id,ContentDocumentLink>();
        
        List<FAQ__kav> lstKnowledgeArticle = TestDataFactory.createKnowledgeArticle(1,'Test FAQ','Test summary','Test content','TestURL');
        insert lstKnowledgeArticle;
        List<ContentVersion> lstContentVersion = TestDataFactory.createContentVersion(1,'Test Document','TestDocument.pdf','Test content',true);
        insert lstContentVersion;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:lstContentVersion[0].Id].ContentDocumentId;
        List<ContentDocumentLink> lstContentDocumentLink = TestDataFactory.createContentDocumentLink(1,lstKnowledgeArticle[0].Id,conDocId,'I');
        insert lstContentDocumentLink;
        
        contentDocMap.put(lstContentDocumentLink[0].id,lstContentDocumentLink[0]);
        Test.startTest();
        ContentDocumentLinkService.updateContentDocumentShareType(contentDocMap);
        Test.stopTest();

        // Retrieve the updated record for assertions
        ContentDocumentLink updatedContentDocumentLink = [SELECT Id, ShareType, Visibility FROM ContentDocumentLink WHERE Id = :lstContentDocumentLink[0].Id];

        // Assert the results
        System.assertEquals('I', updatedContentDocumentLink.ShareType);
    }
    
}