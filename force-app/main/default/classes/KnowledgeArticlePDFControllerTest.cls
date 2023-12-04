/**
Class Name	    : KnowledgeArticlePDFControllerTest
Description	    : Test Class created as part of TPDEV-428 for the KnowledgeSelector Class. 
Created By		: Sibin Kuriakose
Created Date	: 04-04-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				04-04-2023	 Created methods to Test Methods on KnowledgeArticlePDFController
*/
@isTest
public class KnowledgeArticlePDFControllerTest {
    /**     * @Description This method will setup the Test data      
                * @Author      Sibin Kuriakose @ Zoetis Inc | 04-04-2023 
    */
    @testSetup static void setupData() {
        //Creating Knowledge

        //First Record
        FAQ__kav tempKnow = new FAQ__kav();
        tempKnow.Title = 'Test Know';
        tempKnow.URLName = 'Test-Know';
        tempKnow.Description__c = 'Test-Know Description';
        tempKnow.Answer__c = 'Test-Know Content';
        tempKnow.Review_Article_In__c = '3 Months';
        tempKnow.Data_Category__c = 'All';
        insert tempKnow;

        //Creating Content

        //First Record
        String title = 'test';
        ContentVersion file = new ContentVersion(
            Title = title,
            PathOnClient = title,
            VersionData = Blob.valueOf(title),
            origin = 'H'
        );

        insert file;

        insert new ContentDocumentLink(
            LinkedEntityId = tempKnow.Id,
            ContentDocumentId = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id =: file.Id].ContentDocumentId
        );
    }
    
    /**     * @Description This method will test selectKnowledgeById method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 04-04-2023
    */
	 @isTest 
     public static void  KnowledgeArticlePDFControllerTest(){
         List<FAQ__kav> lstKnow = [SELECT Id FROM FAQ__kav];
         Set<Id> tempKnowId = (new Map<Id,SObject>(lstKnow)).keySet();

         Id lstKnowId;

         for(Id tempknow : tempKnowId){
            lstKnowId = tempknow;
         }
         Test.setCurrentPage(Page.KnowledgeArticlePDF);
         ApexPages.currentPage().getParameters().put('id', lstKnowId);
         Test.startTest();
         KnowledgeArticlePDFController tempobj = new KnowledgeArticlePDFController();
         Test.stopTest();
         System.assertEquals(1,lstKnow.size());
     }
}