/**
 * @description       : Contains logic to run on a DML action for a Batch Detail record.
 * @author            : Slalom
 * @group             : 
 * @last modified on  : 07-20-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-01-2022   Slalom                      Initial Version
 * 1.1   06-24-2022   Slalom                      Updates
 * 1.2   07-18-2022   Ethan Hirsch @ Zoetis Inc   Change calls to getInformationFromPVWProduct to use BatchDetailsService.setFieldsFromPVWProduct
 * 1.3   07-19-2022   Ethan Hirsch @ Zoetis Inc   Change beforeInsert logic to only set Primary to true when Primary 
 *                                                is not already true and save SOQL queries.
 *                                                Change afterUpdate method to sync Batch Detail fields using 
 *                                                CaseProductsService.syncUpdatedBatchDetailsToCaseProduct. 
 *                                                Remove updateCaseProduct method as its logic was moved to CaseProductsService.
 * 1.4   07-20-2022   Ethan Hirsch @ Zoetis Inc   Move logic for clearing out Product fields on Case in afterDelete
 *                                                method to CaseProductService.clearProductDetailsWherePrimaryBatchDetailBlank.
 */
public with sharing class BatchDetailTriggerHelper {

    static final String  ZOETIS_PRODUCT= Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId();

    @testVisible static final String BATCH_DETAIL_INVESTIGATION_DELETE_ERROR = 'Batch Details cannot be deleted once an investigation is logged';
    @testVisible static final String BATCH_DETAIL_AGENCY_DELETE_ERROR = 'Batch Details cannot be deleted once an agency submission is logged';
    
    public static void afterUpdate(List<Batch_Detail__c> newBatchDetailRecords, Map<Id, Batch_Detail__c> oldBatchDetailsMap)
    {
        CaseProductsService.syncUpdatedBatchDetailsToCaseProduct(newBatchDetailRecords, oldBatchDetailsMap);
    }
    
    
    public static void afterInsert(List<Batch_Detail__c> newBatchDetailRecords)
    {
        CaseProductsService.setPrimaryBatchDetailOnCaseProduct(newBatchDetailRecords);

    }
    
    public static void beforeInsert(List<Batch_Detail__c> newBatchDetailRecords)
    {
        /*Set<Id> caseprodIds = new Set<Id>();
        for(Batch_Detail__c bd:newBatchDetailRecords)
        {
            // Only check if Primary should be true on Batch Details where Primary is not already true
            if (!bd.ZTS_US_Primary__c) {
                caseprodIds.add(bd.ZTS_US_Case_Product__c);
            }
        }

        // If Case Products are empty, they do not need to be queried for and this logic does not need to run
        if (!caseprodIds.isEmpty()) {
            List<Batch_Detail__c> bdList = [select id,ZTS_US_Case_Product__c from Batch_Detail__c where ZTS_US_Case_Product__c =: caseprodIds and ZTS_US_Primary__c = true];
            Map<Id,Batch_Detail__c> bdMap = new Map<Id,Batch_Detail__c>();
            for (Batch_Detail__c bdr : bdList)
            {
                bdMap.put(bdr.ZTS_US_Case_Product__c,bdr);
            }
            for(Batch_Detail__c bdrec:newBatchDetailRecords)
            {
                if(bdMap.get(bdrec.ZTS_US_Case_Product__c) == null)
                {
                    bdrec.ZTS_US_Primary__c =true;
                }
            }
        }*/

        BatchDetailsService.setFieldsFromPVWProduct(newBatchDetailRecords, null);
    }

    public static void beforeDelete(List<Batch_Detail__c> oldBatchDetailRecords)
    {  
        Id[] batchDetailIds = new Id[]{};
        Set<id> caseProductIds = new Set<Id>();
        for(Batch_Detail__c batchDetail:oldBatchDetailRecords){
            batchDetailIds.add(batchDetail.Id);
            if(!caseProductIds.contains(batchDetail.ZTS_US_Case_Product__c)){
                caseProductIds.add(batchDetail.ZTS_US_Case_Product__c);
            }
        }

        Boolean canDeleteProductsWithAgencySubmission = FeatureManagement.checkPermission('PVWCaseProductDeleteWithAgencySub');
        system.debug('canDeleteProductsWithAgencySubmission'+canDeleteProductsWithAgencySubmission);
        Boolean canDeleteProductsWithInvestigation = FeatureManagement.checkPermission('PVWCaseProductDeleteWithInvestigation');
        system.debug('canDeleteProductsWithInvestigation'+canDeleteProductsWithInvestigation);

        ZTS_US_Product_Investigation__c[] productInvestigations = [ SELECT Id,ZTS_US_Batch_Detail__c
                                                                    FROM ZTS_US_Product_Investigation__c
                                                                    WHERE ZTS_US_Batch_Detail__c IN :batchDetailIds];
        ZTS_US_Case_Agency_Submission__c[] agencySubmissions = [ SELECT Id,Case_Product__c
                                                                    FROM ZTS_US_Case_Agency_Submission__c
                                                                    WHERE Case_Product__c IN :caseProductIds];
        Set<Id> batchDetailsWithInvestigation = new Set<Id>();
        Set<Id> caseProductsWithAgencySubmission = new Set<Id>();
        if(productInvestigations!=null){
            for(ZTS_US_Product_Investigation__c productInvestigation : productInvestigations){
                if(!batchDetailsWithInvestigation.contains(productInvestigation.ZTS_US_Batch_Detail__c)){
                    batchDetailsWithInvestigation.add(productInvestigation.ZTS_US_Batch_Detail__c);
                }
            }
        }
        if(agencySubmissions!=null){
            for(ZTS_US_Case_Agency_Submission__c agencySubmission : agencySubmissions){
                if(!caseProductsWithAgencySubmission.contains(agencySubmission.Case_Product__c)){
                    caseProductsWithAgencySubmission.add(agencySubmission.Case_Product__c);
                }
            }
        }
        
        for(Batch_Detail__c batchDetail:oldBatchDetailRecords){
            if(batchDetailsWithInvestigation.contains(batchDetail.Id) && !canDeleteProductsWithInvestigation){
                batchDetail.addError(BATCH_DETAIL_INVESTIGATION_DELETE_ERROR);
            }
            else if(caseProductsWithAgencySubmission.contains(batchDetail.ZTS_US_Case_Product__c) && !canDeleteProductsWithAgencySubmission){
                batchDetail.addError(BATCH_DETAIL_AGENCY_DELETE_ERROR);
            }
        }

    }


    public static void afterDelete(List<Batch_Detail__c> newBatchDetailRecords)
    {
        Set<Id> caseProductIds= new Set<Id>();
        for(Batch_Detail__c batchDetail:newBatchDetailRecords)
        {
            caseProductIds.add(batchDetail.ZTS_US_Case_Product__c);
        }

        CaseProductsService.clearProductDetailsWherePrimaryBatchDetailBlank(caseProductIds);
    }

    public static void beforeUpdate(List<Batch_Detail__c> triggerOld, Map<Id, Batch_Detail__c> triggerOldMap, List<Batch_Detail__c> triggerNew, Map<Id, Batch_Detail__c> triggerNewMap)
    {
        BatchDetailsService.setFieldsFromPVWProduct(triggerNew, triggerOldMap);

    }
}