/******************************************************************************************************************************************
 * Class Name   : ContractDetailViewController
 * Description  : Controller class for Contract buttons with StandardController  
 * Created By   : Slalom/Art Smorodin
 * Created Date : 22 May 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin(Slalom)     05/22/2020          Created.
 *****************************************************************************************************************************************/
public with sharing class ContractDetailViewController {

    //public Account acc;
    private ApexPages.StandardController standardController;
    public String currentRecordId {get;set;}
    public Contract sourceContract;
    public String businessClass;

    public ContractDetailViewController(ApexPages.StandardController standardController) {

        this.standardController = standardController;
        //currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');

        Contract tmpContr = (Contract)standardController.getRecord();
        this.sourceContract = [SELECT id, AccountId FROM Contract WHERE id = :tmpContr.id limit 1];

        Account acc = [SELECT Id, Name, ZTS_US_Business_Class__c FROM Account WHERE Id =: sourceContract.AccountId ];
        businessClass = acc.ZTS_US_Business_Class__c;

    }

    public PageReference doLcRedirect(){
        try {
            String returnUrl = '/lightning/cmp/c__ContractPrepDocumentLc?c__contrId='+sourceContract.Id+'&c__account='+businessClass;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }

    public PageReference submitForApproval(){
        try {
            String returnUrl = '/lightning/cmp/c__ContractForApprovalLc?c__contrId='+sourceContract.Id;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static Boolean hasAgreements(String contractId){
        Boolean result;
        List<echosign_dev1__SIGN_Agreement__c> agreements =  [SELECT Id,echosign_dev1__Status__c,echosign_dev1__Contract__c 
                    FROM echosign_dev1__SIGN_Agreement__c 
                    WHERE echosign_dev1__Contract__c =: contractId AND echosign_dev1__Status__c != 'Signed' ];
        if(agreements != null && agreements.size() > 0) result = true;
        else result = false;
        return result;
        
    }

    @AuraEnabled
    public static String getTemplates(String id){
        String result = Adobe_Send_For_Signature.createAddendum(id);
        return result;
        
    }

    @AuraEnabled
    public static Contract getContractInfo(String contractId){
        
        Contract theContract =  [SELECT Id, 
                                        ZTS_US_Count_Attachments__c,
                                        ZTS_US_Submitter_Comments__c, 
                                        Record_Type_Name__c,
                                        Incremental_Sales_Opportunity__c,
                                        Net_Bios_Sales_Last_12_Mos__c,
                                        Net_Bios_Sales_Next_12_Mos__c,
                                        Net_Paras_Sales_Last_12_Mos__c,
                                        Net_Paras_Sales_Next_12_Mos__c
                    FROM Contract 
                    WHERE Id =: contractId LIMIT 1 ];
        
        return theContract;
    }

    @AuraEnabled
    public static Contract updateContract(String contractId){
        Contract contrRec = [SELECT Id, Status, ZTS_US_Approval_Status__c  
                        FROM Contract  
                        WHERE id=:contractId LIMIT 1];

        if (contrRec.Status != 'Proposal Approved' || contrRec.ZTS_US_Approval_Status__c != 'Approved') {
            contrRec.Status = 'Proposal Approved';
            contrRec.ZTS_US_Approval_Status__c = 'Approved';
        } 

        update contrRec;
        return contrRec;
    }

    @AuraEnabled
    public static String submitApproval(String contractId){
        String result;

        result = ContractApproval.submitContractApprovalRequest(Id.valueOf(contractId));

        return result;
    }

    public PageReference doBiosRedirectLc()
    {   
        String returnUrl = '/lightning/cmp/c__ContractMzrBiosCalcLC?c__contrId='+sourceContract.Id;
        PageReference pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }

    public PageReference doParasRedirectLc()
    {   
        String returnUrl = '/lightning/cmp/c__ContractMzrParasCalcLC?c__contrId='+sourceContract.Id;
        PageReference pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }

    public PageReference callApprovalCls(){
        Contract currentRecord = [SELECT Id FROM Contract WHERE Id =: sourceContract.Id];
        ZTS_US_ContractBaseClass.SingleApproveRenewal(currentRecord);
        PageReference pg = new PageReference('/'+sourceContract.Id);
        pg.setRedirect(true);
        return pg;  
    }

    @AuraEnabled
    public static List<ContentDocument> docBiosList() {
        List<ContentDocument> docBiosList = new List<ContentDocument>();
        docBiosList = [SELECT Id,Title FROM ContentDocument Where Title = 'MZR BIOS Calculator'];
        return docBiosList;
    }

    @AuraEnabled
    public static List<ContentDocument> docParasList() {
        List<ContentDocument> docParasList = new List<ContentDocument>();
        docParasList = [SELECT Id,Title FROM ContentDocument Where Title = 'MZR PARAs Calculator'];
        return docParasList;
    }
        
}