/****************************************************************************************************************************************** 
* Trigger Name : CSE_CaseProductTriggerHandler
* Description  : All Dispatch Trigger Logic for CaseProduct object.
* Created By   : Slalom(Venkat Joginapally) 
* Created Date : 13th September, 2021
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                      Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Venkat Joginapally          09/13/2021             Created 
* Christain Brandt                                   Added code  
* Ethan Hirsch @ Zoetis Inc   07/18/2022             Remove getInformationFromPVWProduct method and helper methods. 
*                                                    This validation and logic will only occur on Batch Detail as 
*                                                    there can be multiple Batch Details for one Case Product.
*                                                    Add logic to call CaseProductsService.upsertBatchDetailFromCaseProduct
*                                                    after insert and after update
* Ethan Hirsch @ Zoetis Inc   07/20/2022             Add logic to call CaseProductsService.reevaluteRelatedBatchDetailQualifiers 
*                                                    when Product changes to reevaluate Batch Detail Qualifiers.
* Shivadarshini Prasidkhanna  13/04/2023			 Added logic to call VmipsCaseSyncStatusHandler.updateCaseSyncStatus from the after delete (TPDEV-726)
*****************************************************************************************************************************************/

public with sharing class CSE_CaseProductTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    @testVisible static final String CASE_PRODUCT_APPROVEDCASE_DELETE_ERROR = System.Label.CSE_CaseProductTriggerHandler_Error_Text;
    @testVisible static final String CASE_PRODUCT_INVESTIGATION_DELETE_ERROR = 'Case Products cannot be deleted once investigations are logged against them.';
    @testVisible static final String CASE_PRODUCT_AGENCY_DELETE_ERROR = 'Case Products cannot be deleted once agency submissions are logged against them.';
    @testVisible static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    public static final String OBJECT_API_NAME = 'ZTS_US_Case_Product__c';
    public static final String CASE_FIELD_API_NAME = 'ZTS_US_Case__c';
    static final String LOCAL_ASSESSMENT_RT = 'ZTS_US_Local_Assessment';
    static final String PRODUCT_ASSESSMENT_RT = 'ZTS_US_Product_Assessment';
    
    
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){
        // getting deleted case products from triggerOld
        List<ZTS_US_Case_Product__c> lstOldCaseProducts = (List<ZTS_US_Case_Product__c>)triggerOld;
        //get all case Ids from CaseProducts into a set
        validateProductDeletion(lstOldCaseProducts);
    }

    @TestVisible
    private void validateProductDeletion(ZTS_US_Case_Product__c[] caseProducts){
        Map<Id,Integer> caseIdToNumProductsDeleted = new Map<Id,Integer>();
        Boolean canDeleteProductsWithAgencySubmission = FeatureManagement.checkPermission('PVWCaseProductDeleteWithAgencySub');
        system.debug('canDeleteProductsWithAgencySubmission'+canDeleteProductsWithAgencySubmission);
        Boolean canDeleteProductsWithInvestigation = FeatureManagement.checkPermission('PVWCaseProductDeleteWithInvestigation');
        system.debug('canDeleteProductsWithInvestigation'+canDeleteProductsWithInvestigation);
        
        for(ZTS_US_Case_Product__c caseProduct:caseProducts){
            if(caseIdToNumProductsDeleted.containsKey(caseProduct.ZTS_US_Case__c)){
                Integer numProductsDeleted = caseIdToNumProductsDeleted.get(caseProduct.ZTS_US_Case__c);
                caseIdToNumProductsDeleted.put(caseProduct.ZTS_US_Case__c,numProductsDeleted+1);
            }
            else{
                caseIdToNumProductsDeleted.put(caseProduct.ZTS_US_Case__c,1);
            }
            system.debug('case product delete map'+caseIdToNumProductsDeleted);
        }
        Map<Id,Case> caseMap =  new Map<Id,Case>([  SELECT Id,Sync_Status__c, 
                                                    (SELECT Id FROM Case_Products__r),
                                                    (SELECT Id,ZTS_US_Case_Product__c FROM Product_Investigations__r), 
                                                    (SELECT Id,Case_Product__c FROM Case_Agency_Submissions__r)
                                                    FROM Case 
                                                    WHERE Id IN: caseIdToNumProductsDeleted.keySet() 
                                                    AND RecordType.DeveloperName =: RECORDTYPE_CASE_ANIMAL_SUPPORT_STR]);
        for(ZTS_US_Case_Product__c caseProduct:caseProducts){
            Case caseForProduct = caseMap.get(caseProduct.ZTS_US_Case__c);
            Integer numProductsDeleted = caseIdToNumProductsDeleted.get(caseProduct.ZTS_US_Case__c);

            //if the product has an investigation, throw an error unless the user has the override permission
            if(caseForProduct!=null && caseForProduct.Product_Investigations__r != null && !caseForProduct.Product_Investigations__r.isEmpty() && !canDeleteProductsWithInvestigation){
                for(ZTS_US_Product_Investigation__c investigation : caseForProduct.Product_Investigations__r){
                    if(investigation.ZTS_US_Case_Product__c  == caseProduct.Id){
                        caseProduct.addError(CASE_PRODUCT_INVESTIGATION_DELETE_ERROR);
                        return;
                    }
                }
            }
            //if the product has an agency submission, throw an error unless the user has the override permission
            if(caseForProduct!=null && caseForProduct.Case_Agency_Submissions__r != null && !caseForProduct.Case_Agency_Submissions__r.isEmpty() && !canDeleteProductsWithAgencySubmission){
                for(ZTS_US_Case_Agency_Submission__c agencySubmission : caseForProduct.Case_Agency_Submissions__r){
                    if(agencySubmission.Case_Product__c  == caseProduct.Id){
                        caseProduct.addError(CASE_PRODUCT_AGENCY_DELETE_ERROR);
                        return;
                    }
                }
            }
            //if all products for an approved case will be deleted in the trigger, throw an error
            if(caseForProduct!= null && caseForProduct.Sync_Status__c != VmipsCaseSyncStatusHandler.SYNC_UNAPPROVED && 
                    numProductsDeleted!=null && caseForProduct.Case_Products__r.size()==numProductsDeleted){
                caseProduct.addError(CASE_PRODUCT_APPROVEDCASE_DELETE_ERROR);
                return;
            }
            
        }
    }
    
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //validateFieldUpdatesForPVWorks( triggerNew, triggerOldMap );
        validateFieldUpdatesForPVWorks((List<ZTS_US_Case_Product__c>)triggerNew, (Map<Id, ZTS_US_Case_Product__c>)triggerOldMap);
        CaseProductsService.validateStartDateForRelatedCaseProducts((List<ZTS_US_Case_Product__c>)triggerNew, (Map<Id, ZTS_US_Case_Product__c>)triggerOldMap, false, true);
    }
    
    @TestVisible
    private static void validateFieldUpdatesForPVWorks( List<ZTS_US_Case_Product__c> triggerNew, Map<Id, ZTS_US_Case_Product__c> triggerOldMap )
    {        
        // lets call the function that handles the validation
        SL_CaseTriggerHandler.validateRelatedRecordsForSendingToPVWorks( triggerNew, triggerOldMap, CASE_FIELD_API_NAME );
    }
    
    
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerOld, triggerOldMap,OBJECT_API_NAME,CASE_FIELD_API_NAME,null,Trigger.operationType); 
        VmipsCaseSyncStatusHandler.updateCaseSyncStatus(triggerOld, triggerOldMap,OBJECT_API_NAME,CASE_FIELD_API_NAME, 'ZTS_US_Case__r', null,Trigger.operationType);//added for TPDEV-726

     
    }
    
    
    public void afterUpdate( List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap )
    {
        // track multiselect and/or long text area fields for audit trail (CSE-49)
        new CSE_LongTextAreaAuditTrailHelper().filterTextAreaChangedRecords( triggerNew, triggerOldMap, 'Long_Text_Area_Fields' );
        CaseProductsService.upsertBatchDetailFromCaseProduct(triggerNew, (Map<Id, ZTS_US_Case_Product__c>)triggerOldMap);
        
        List<ZTS_US_Case_Product__c> caseProductsWithChangedProducts = new List<ZTS_US_Case_Product__c>();
        for (Sobject record : triggerNew) {
            ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c)record;
            ZTS_US_Case_Product__c oldCaseProduct = (ZTS_US_Case_Product__c)triggerOldMap.get(caseProduct.Id);

            if (caseProduct.ZTS_US_PVW_Product__c != oldCaseProduct.ZTS_US_PVW_Product__c) {
                caseProductsWithChangedProducts.add(caseProduct);
            }
        }
        //Commenting the below logic. Currently the system won't allow you to change the pvw product in the existing case product based on the CASS - 451
        /*if (!caseProductsWithChangedProducts.isEmpty()) {
            CaseProductsService.reevaluteRelatedBatchDetailQualifiers(caseProductsWithChangedProducts);
        }*/
        //TPDEV-726 - Added by Shiva
        VmipsCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'ZTS_US_Case__r',triggerNewMap);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerNew, null, OBJECT_API_NAME,CASE_FIELD_API_NAME,null,Trigger.operationType); 
        CaseProductsService.upsertBatchDetailFromCaseProduct(triggerNew, null);
        System.debug('affter insert called..');
        VmipsCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'ZTS_US_Case__r',triggerNewMap);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeInsert(List<SObject> triggerNew) {
        AuditAndSequenceHelper.createSequenceForObject(triggerNew,OBJECT_API_NAME,CASE_FIELD_API_NAME);
        CaseProductsService.validateStartDateForRelatedCaseProducts((List<ZTS_US_Case_Product__c>)triggerNew, new Map<Id, ZTS_US_Case_Product__c>(), true, false);
    }
}