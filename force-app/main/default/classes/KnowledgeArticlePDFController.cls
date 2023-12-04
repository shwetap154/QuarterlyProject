/**
Class Name	    : KnowledgeArticlePDFController
Description	    : Controller Class created as part of TPDEV-428 for the KnowledgeArticlePDF page. 
Created By		: Sibin Kuriakose
Created Date	: 04-04-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer			Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Sibin Kuriakose	04-04-2023   Added Methods to Retrive details of current Knowledge record 
*/

public With Sharing class KnowledgeArticlePDFController {

    public Id KnowledgeId {get; private set;}
    public String Title {get; private set;}
    public String Description {get; private set;}
    public String Content {get; private set;}
    
    /**
     * Constructor that pulls back all data needed for the Page
     */
    public KnowledgeArticlePDFController() {
        Id KnowledgeId = Id.valueOf(ApexPages.CurrentPage().getparameters().get('id'));
      
        List<Id> recordId = new List<Id>();
        recordId.add(KnowledgeId);
        List<FAQ__kav> lstKnowdetail = KnowledgeSelector.selectKnowledgeById(recordId); 
        List<ContentDocument> lstFiles = new List<ContentDocument>();
        List<ContentDocumentLink> templstDoc = ContentDocumentLinksSelector.selectContentDocumentById(recordId);
        List<Id> tempRecordId = new List<Id>();
        for(ContentDocumentLink tempDoc : templstDoc){
            tempRecordId.add(tempDoc.ContentDocumentId);
        }
        for(FAQ__kav templst : lstKnowdetail){
            Title = templst.Title;
            Description = templst.Description__c;
            Content = templst.Answer__c;
        }
        }
}