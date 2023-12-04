/**
* File Name     :  GenerateDocumentOneStepController
* @description  :  Controller class for 'Generate Document One Step' lightning component.
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/19/2020     Cesar Sandrigo @ ATG    Created the Class. Added methods to kick document generation, 
*                                               poll document generation status, create an Agreement.
* 1.1	  10/16/2023	Rahul Kumar @Deloitte	Updated DocGenerationStatusResponse method for TPDEV 2121
*/
public class GenerateDocumentOneStepController {
  /**
   * @description Kicks the Document generation process.
   * @param quoteId Id of the Quote.
   * @return An error if there are existing documents. The Job ID if it was enqueued.d
   */
  @AuraEnabled
  public static GenerateDocumentResponse generateDocument(Id quoteId) {
    List<SBQQ__Quote__c> quotes = [SELECT Id, Name, SBQQ__QuoteTemplateId__c FROM SBQQ__Quote__c WHERE Id = :quoteId];

    if (quotes.isEmpty()) {
      return null;
    }

    SBQQ__Quote__c quote = quotes[0];

    if (quote.SBQQ__QuoteTemplateId__c == null) {
      ErrorLogUtil.log(
        'The Quote does not have a Quote Template associated: ' + quoteId,
        new List<String>{ 'GenerateDocumentOneStepController > generateDocument' }
      );
      ErrorLogUtil.commitLogs();
      return null;
    }

    List<SBQQ__QuoteDocument__c> documents = [
      SELECT Id, SBQQ__Quote__c, SBQQ__QuoteTemplate__c
      FROM SBQQ__QuoteDocument__c
      WHERE SBQQ__Quote__c = :quoteId AND SBQQ__QuoteTemplate__c = :quote.SBQQ__QuoteTemplateId__c
    ];

    List<echosign_dev1__SIGN_Agreement__c> agreements = [SELECT Id FROM echosign_dev1__SIGN_Agreement__c WHERE Quote__c = :quoteId];

    if (!documents.isEmpty() || !agreements.isEmpty()) {
      return new GenerateDocumentResponse(documents.size(), agreements.size());
    }

    String documentName = 'Zoetis - ' + quote.Name;
    List<Id> documentIds = new List<id>();

    Id docSavingJobId;

    if (!Test.isRunningTest()) {
      Id docGenerationJobId = SBQQ.QuoteDocumentController.generateDocument(
        'en_US', quote.Id, quote.SBQQ__QuoteTemplateId__c, documentName, 'PDF','Default',documentIds
      );
      documentIds.add(quoteId);
      docSavingJobId = SBQQ.QuoteDocumentController.saveProposal(
        'en_US',quote.Id,quote.SBQQ__QuoteTemplateId__c,documentName,'PDF','Default',documentIds
      );
    }

    return new GenerateDocumentResponse(docSavingJobId);
  }

  /**
   * @description Gets the status of the Document Generation job.
   * @param jobID Id of the Job.
   * @param quoteId Id of the Quote.
   * @return The job status and the document Id when the job ends sucessfully.
   */
  @AuraEnabled
  public static DocGenerationStatusResponse getDocumentGenerationStatus(Id jobId, Id quoteId) {
    List<AsyncApexJob> jobs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :jobId];

    if (jobs.isEmpty()) {
      return new DocGenerationStatusResponse('Not able to find a Job with ID: ' + jobId);
    }

    AsyncApexJob job = jobs[0];

    if (job.Status == 'Completed') {
      // Done

      List<SBQQ__QuoteDocument__c> documents = [
        SELECT Id, SBQQ__AttachmentId__c, SBQQ__Opportunity__r.Purchasing_Contact__c, SBQQ__Quote__r.Authorized_Zoetis_Signature_for_VR__c ,
        SBQQ__Opportunity__r.Doctor_Contact__c,SBQQ__Opportunity__r.Is_it_a_VR__c,Second_Signature_Purchasing_Contact__c,Authorized_Zoetis_Signature_for_VR__c
        FROM SBQQ__QuoteDocument__c
        WHERE SBQQ__Quote__c = :quoteId
        ORDER BY SBQQ__Version__c DESC LIMIT 1
      ];

      if (!documents.isEmpty()) {
        SBQQ__QuoteDocument__c document = documents[0];

        document.Purchasing_Contact__c = document.SBQQ__Opportunity__r.Purchasing_Contact__c;
          
          // changes according to TPDEV 2121
          // If the Market is Germany, update Quote document fields from both the Quote and Opportunity.
        if(document.SBQQ__Opportunity__r.Is_it_a_VR__c)
        {
          document.Authorized_Zoetis_Signature_for_VR__c = document.SBQQ__Quote__r.Authorized_Zoetis_Signature_for_VR__c;
          document.Second_Signature_Purchasing_Contact__c = document.SBQQ__Opportunity__r.Doctor_Contact__c;  
        }
        update document;

        return new DocGenerationStatusResponse(true, document.Id);
      }
    } else if ((new Set<String>{ 'Queued', 'Processing', 'Preparing', 'Holding' }).contains(job.Status)) {
      // Processing
      return new DocGenerationStatusResponse();
    } else if ((new Set<String>{ 'Aborted', 'Failed' }).contains(job.Status)) {
      // Error
      return new DocGenerationStatusResponse('Job Status: ' + job.Status + '. Details: ' + job.ExtendedStatus);
    }

    return new DocGenerationStatusResponse('Unknown status: ' + job.Status + '. Details: ' + job.ExtendedStatus);
  }

  /**
   * @description Creates the Agreement
   * @param quoteId Id of the Quote.
   * @param quoteDocumentId Id of the Job.
   * @return The URL to navigate to the agreement
   */
  @AuraEnabled
  public static String generateAgreement(Id quoteId, Id quoteDocumentId) {
    List<SBQQ__QuoteDocument__c> documents = [
      SELECT Id, Name, CustomName__c, SBQQ__AttachmentId__c, SBQQ__Quote__r.Agreement_Message__c, SBQQ__Quote__r.Agreement_Language__c
      FROM SBQQ__QuoteDocument__c
      WHERE Id = :quoteDocumentId
    ];

    if (documents.isEmpty()) {
      ErrorLogUtil.log(
        'Quote Document not found: quoteDocumentId',
        new List<String>{
          'Agreement Template Name: ATG Quote Document Agreement Template',
          'Master Object API Name: SBQQ__QuoteDocument__c'
        }
      );
      ErrorLogUtil.commitLogs();
      return null;
    }

    SBQQ__QuoteDocument__c quoteDocument = documents[0];

    Id templateId = fetchAgreementTemplateId('SBQQ__QuoteDocument__c', 'ATG Quote Document Agreement Template');

    if (templateId == null) {
      ErrorLogUtil.log(
        'Agreement Template was not found.',
        new List<String>{ 'Agreement Name: ATG Quote Document Agreement Template', 'Master Object API Name: SBQQ__QuoteDocument__c' }
      );
      ErrorLogUtil.commitLogs();
      return null;
    }

    Map<String, echosign_dev1.AgreementTemplateVariable> templateVariables = new Map<String, echosign_dev1.AgreementTemplateVariable>{
      'MyAttachment' => new echosign_dev1.AgreementTemplateVariable('MyAttachment', quoteDocument.SBQQ__AttachmentId__c)
    };

    Id agreementId = echosign_dev1.AgreementTemplateService.load(templateId, quoteDocumentId, templateVariables);

    update new echosign_dev1__SIGN_Agreement__c(
      Id = agreementId,
      Quote__c = quoteId,
      ASSFCPQ__Quote_Document__c = quoteDocumentId,
      Name = quoteDocument.Name,
      echosign_dev1__Message__c = quoteDocument.SBQQ__Quote__r.Agreement_Message__c,
      echosign_dev1__SignatureOrder__c = 'Recipient signs, then I sign',
      echosign_dev1__AgreementLocale__c = quoteDocument.SBQQ__Quote__r.Agreement_Language__c
    );

    // Update quote document
    quoteDocument.ASSFCPQ__Agreement__c = agreementId;
    quoteDocument.SBQQ__ElectronicSignature__c = true;
    update quoteDocument;

    return '/' + agreementId;
  }

  private static Id fetchAgreementTemplateId(String objectType, String templateName) {
    List<echosign_dev1__Agreement_Template__c> agreementTemplateList = [
      SELECT Id, Name
      FROM echosign_dev1__Agreement_Template__c
      WHERE echosign_dev1__Master_Object_Type__c = :objectType AND Name = :templateName
    ];

    if (!agreementTemplateList.isEmpty()) {
      return agreementTemplateList[0].Id;
    }

    return null;
  }

  public class DocGenerationStatusResponse {
    @AuraEnabled
    public Boolean Done { get; set; }

    @AuraEnabled
    public Boolean Error { get; set; }

    @AuraEnabled
    public String ErrorMessage { get; set; }

    @AuraEnabled
    public Id QuoteDocumentId { get; set; }

    public DocGenerationStatusResponse(Boolean isDone, Boolean isError, String errMessage, Id qdId) {
      this.Done = isDone;
      this.Error = isError;
      this.ErrorMessage = errMessage;
      this.QuoteDocumentId = qdId;
    }

    public DocGenerationStatusResponse(Boolean isDone, String qdId) {
      this(true, false, null, qdId);
    }

    public DocGenerationStatusResponse(String errMessage) {
      this(true, true, errMessage, null);
    }

    public DocGenerationStatusResponse() {
      this(false, false, null, null);
    }
  }

  public class GenerateDocumentResponse {
    @AuraEnabled
    public Integer ExistingDocuments { get; set; }

    @AuraEnabled
    public Integer ExistingAgreements { get; set; }

    @AuraEnabled
    public Id JobId { get; set; }

    public GenerateDocumentResponse(Integer existDocuments, Id jobId) {
      this.ExistingDocuments = existDocuments;
      this.JobId = jobId;
      this.ExistingAgreements = 0;
    }

    public GenerateDocumentResponse(Id jobId) {
      this(0, jobId);
      this.ExistingAgreements = 0;
    }

    public GenerateDocumentResponse(Integer existDocuments, Integer existinAgreements) {
      this.ExistingDocuments = existDocuments;
      this.ExistingAgreements = existinAgreements;
      this.JobId = null;
    }
  }
}