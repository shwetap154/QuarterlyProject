/**
 * @description       : Service class for Case Product
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-01-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-18-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with methods to create a Batch Detail from a
 *                                                Case Product.
 * 1.1   07-19-2022   Ethan Hirsch @ Zoetis Inc   Add method syncUpdatedBatchDetailsToCaseProduct to update a
 *                                                Case Product from Batch Detail.
 * 1.2   07-20-2022   Ethan Hirsch @ Zoetis Inc   Add clearProductDetailsWherePrimaryBatchDetailBlank method to clear
 *                                                Product fields.
 *                                                Add reevaluteRelatedBatchDetailQualifiers method to reevaluate
 *                                                qualifiers when Product changes on a Case Product.
 * 1.3   07-29-2022   Ethan Hirsch @ Zoetis Inc   Fix a bug with upsertBatchDetailFromCaseProduct where it checked Primary Batch Detail on Old case Product
 * 1.4   08-01-2022   Ethan Hirsch @ Zoetis Inc   Add forceUpdateCaseProductBatchDetailIds to force a Case Product to be updated from a Batch Detail.
 *                                                This is primarily meant for a situation where Serial Number is cleared on the Case Product,
 *                                                but then repopulated at the Batch Detail.
 * 1.5   12-15-2022	  Ahmed Elawad @ Slalom		 Add validateStartDateForRelatedCaseProducts for CASS-940:INC2745917 implement case-product validation on 
 * 												 insert and update where if there are vedra events on the invent narrative there must always be one case product 
 * 											     where the earliest ZTS_US_Start_Date__c on all case products for the case <= the earliest ZTS_US_Start_Date__c 
 * 												 across veDRA events related to the case 
 **/
public with sharing class CaseProductsService {
    // This is primarily meant for setting Serial Number on a Case Product if its cleared and then set again from the Lot # on a Batch Detail
    // It may be used for other scenarios as needed though.
    public static Set<Id> forceUpdateCaseProductBatchDetailIds = new Set<Id>();

    /**
     * @description Create or Update a Batch Detail record for a Case Product when a Case Product is
     *   inserted or updated with Lot, Serial, or Diluent set or changed.
     *   This method only creates or updates Batch Detail. All other logic occurs in the Batch Detail Trigger
     * @param caseProducts
     * @param oldCaseProductsMap
     */
    public static void upsertBatchDetailFromCaseProduct(List<ZTS_US_Case_Product__c> caseProducts,
        Map<Id, ZTS_US_Case_Product__c> oldCaseProductsMap) {

        List<Batch_Detail__c> upsertBatchDetails = new List<Batch_Detail__c>();

        ZTS_US_Case_Product__c[] clonedCaseProducts = new ZTS_US_Case_Product__c[]{};
        for (ZTS_US_Case_Product__c caseProduct : caseProducts) {
            ZTS_US_Case_Product__c oldCaseProduct = oldCaseProductsMap?.get(caseProduct.Id);

            // A Batch Detail will be created in the following situations:
            // On insert of Case Product, if Lot, Serial, or Diluent are not blank.
            // On update of Case Product, if Lot, Serial, or Diluent are not blank,
            // Primary_Batch_Detail__c is blank, and Lot, Serial, or Diluent changed.
            if ((String.isNotBlank(caseProduct.ZTS_US_Product_Lot__c) ||
                String.isNotBlank(caseProduct.ZTS_US_Serial_Number__c) ||
                String.isNotBlank(caseProduct.ZTS_US_Diluent__c)) &&
                (oldCaseProduct == null || (oldCaseProduct != null &&
                caseProduct.Primary_Batch_Detail__c == null &&
                (caseProduct.ZTS_US_Product_Lot__c != oldCaseProduct.ZTS_US_Product_Lot__c ||
                caseProduct.ZTS_US_Serial_Number__c != oldCaseProduct.ZTS_US_Serial_Number__c ||
                caseProduct.ZTS_US_Diluent__c != oldCaseProduct.ZTS_US_Diluent__c)))) {
                upsertBatchDetails.add(setupPrimaryBatchDetailForCaseProduct(caseProduct));
            }
            // If the Case Product was updated and Primary Batch Detail is not null,
            // update the Batch Detail if Lot, Serial, or Diluent changed.
            else if (oldCaseProduct != null && caseProduct.Primary_Batch_Detail__c != null) {
                Boolean batchDetailChanged = false;

                Batch_Detail__c updateBatchDetail = new Batch_Detail__c(
                    Id = caseProduct.Primary_Batch_Detail__c
                );

                if (caseProduct.ZTS_US_Product_Lot__c != oldCaseProduct.ZTS_US_Product_Lot__c) {
                    updateBatchDetail.ZTS_US_Product_Lot__c = caseProduct.ZTS_US_Product_Lot__c;
                    batchDetailChanged = true;
                }

                if (caseProduct.ZTS_US_Serial_Number__c != oldCaseProduct.ZTS_US_Serial_Number__c) {
                    updateBatchDetail.ZTS_US_Serial_Number__c = caseProduct.ZTS_US_Serial_Number__c;
                    batchDetailChanged = true;
                }

                if (caseProduct.ZTS_US_Diluent__c != oldCaseProduct.ZTS_US_Diluent__c) {
                    updateBatchDetail.ZTS_US_Diluent__c = caseProduct.ZTS_US_Diluent__c;
                    batchDetailChanged = true;
                }

                if (batchDetailChanged) {
                    upsertBatchDetails.add(updateBatchDetail);
                }
            }
            if (caseProduct.getCloneSourceId() != null && oldCaseProductsMap == null) {
                clonedCaseProducts.add(caseProduct);
            }
        }
        if(!clonedCaseProducts.isEmpty()){
            upsertBatchDetails = verifyBatchDetailsAfterClone(clonedCaseProducts,upsertBatchDetails);
        }

        // Exit early if there are no Batch Details to process
        if (upsertBatchDetails.isEmpty()) {
            return;
        }

        upsert upsertBatchDetails;
    }

    /**
     * @description set Primary_Batch_Detail__c on a Case Product tied to a related Primary Batch Detail
     * @param batchDetails
     */
    public static void setPrimaryBatchDetailOnCaseProduct(List<Batch_Detail__c> batchDetails) {
        Map<Id, ZTS_US_Case_Product__c> caseProductsToUpdate = new Map<Id, ZTS_US_Case_Product__c>();

        for (Batch_Detail__c batchDetail : batchDetails) {
            // If this is a Primary Batch Detail, set the Primary Batch Detail lookup on the related Case Product.
            // Set all fields synced between Batch Detail and Case Product to accomodate for Batch Details created
            // manually instead of on a Case Product.
            if (batchDetail.ZTS_US_Primary__c) {
                ZTS_US_Case_Product__c caseProduct = updateCaseProductFromBatchDetail(batchDetail);
                caseProduct.Primary_Batch_Detail__c = batchDetail.Id;
                // In case of duplicates, the last Batch Detail will be used as the Primary Batch Detail
                caseProductsToUpdate.put(caseProduct.Id, caseProduct);
            }
        }

        if (!caseProductsToUpdate.isEmpty()) {
            // Bypass the Case Product Trigger Handler to avoid an unecessary loop.
            // Updating a Case Product will update the Batch Detail too.
            DispatchTriggerHandler.bypass('CSE_CaseProductTriggerHandler');
            update caseProductsToUpdate.values();
            DispatchTriggerHandler.clearBypass('CSE_CaseProductTriggerHandler');
        }

    }

    /**
     * @description Set Lot #, Serial #, and Diluent # on Case Product using the Batch Detail record when
     * these fields change.
     * @param batchDetails
     * @param oldBatchDetailMap
     */
    public static void syncUpdatedBatchDetailsToCaseProduct(List<Batch_Detail__c> batchDetails, Map<Id,Batch_Detail__c> oldBatchDetailMap) {
        List<ZTS_US_Case_Product__c> caseProductsToUpdate = new List<ZTS_US_Case_Product__c>();
        Map<Id, Batch_Detail__c> updatedBatchDetailMap = new Map<Id, Batch_Detail__c>();
        Set<Id> caseProductIdsToQuery = new Set<Id>();
        for (Batch_Detail__c batchDetail : batchDetails) {
            Batch_Detail__c oldBatchDetail = oldBatchDetailMap.get(batchDetail.Id);

            // Update the related Case Product if this is the Primary Batch Detail and it was present in the force
            // update set or Lot, Serial, or Diluent changed
            if (batchDetail.ZTS_US_Primary__c &&
                (forceUpdateCaseProductBatchDetailIds.contains(batchDetail.Id) ||
                (batchDetail.ZTS_US_Product_Lot__c != oldBatchDetail.ZTS_US_Product_Lot__c ||
                batchDetail.ZTS_US_Serial_Number__c != oldBatchDetail.ZTS_US_Serial_Number__c ||
                batchDetail.ZTS_US_Diluent__c != oldBatchDetail.ZTS_US_Diluent__c))) {
                updatedBatchDetailMap.put(batchDetail.Id, batchDetail);
                caseProductIdsToQuery.add(batchDetail.ZTS_US_Case_Product__c);
            }
        }

        // Clear this set to prevent a Case Product from being updated in multiple batches
        forceUpdateCaseProductBatchDetailIds.clear();

        if (caseProductIdsToQuery.isEmpty()) {
            return;
        }

        // Make sure the Batch Detail that was updated is the Primary Batch Detail before updating the Case.
        for (ZTS_US_Case_Product__c caseProduct : [
            SELECT Id, Primary_Batch_Detail__c
            FROM ZTS_US_Case_Product__c
            WHERE Id in: caseProductIdsToQuery
            AND Primary_Batch_Detail__c in: updatedBatchDetailMap.keySet()]) {

            Batch_Detail__c primaryBatchDetail = updatedBatchDetailMap.get(caseProduct.Primary_Batch_Detail__c);
            caseProductsToUpdate.add(updateCaseProductFromBatchDetail(primaryBatchDetail));
        }

        if (!caseProductsToUpdate.isEmpty()) {
            // Bypass the Case Product Trigger Handler to avoid an unecessary loop
            // Updating a Case Product will update the Batch Detail too.
            DispatchTriggerHandler.bypass('CSE_CaseProductTriggerHandler');
            update caseProductsToUpdate;
            DispatchTriggerHandler.clearBypass('CSE_CaseProductTriggerHandler');
        }
    }

    /**
     * @description Clear the Product Detail fields on the passed in Case Products when Primary Batch Detail is blank.
     *   This is primarily meant for when the Primary Batch Detail has been deleted.
     * @param caseProductIds
     */
    public static void clearProductDetailsWherePrimaryBatchDetailBlank(Set<Id> caseProductIds) {
        List<ZTS_US_Case_Product__c> caseProductsToUpdate = new List<ZTS_US_Case_Product__c>();
        if (!caseProductIds.isEmpty()) {
            for (ZTS_US_Case_Product__c caseProduct : [
                SELECT Id, Primary_Batch_Detail__c
                FROM ZTS_US_Case_Product__c
                WHERE Id in: caseProductIds]) {
                if (caseProduct.Primary_Batch_Detail__c == null) {
                    caseProductsToUpdate.add(new ZTS_US_Case_Product__c(
                        Id = caseProduct.Id,
                        ZTS_US_Product_Lot__c = null,
                        ZTS_US_Serial_Number__c = null,
                        ZTS_US_Diluent__c = null
                    ));
                }
            }
        }

        if (!caseProductsToUpdate.isEmpty()) {
            // Bypass the Case Product Trigger to save performance time
            DispatchTriggerHandler.bypass('CSE_CaseProductTriggerHandler');
            update caseProductsToUpdate;
            DispatchTriggerHandler.clearBypass('CSE_CaseProductTriggerHandler');
        }
    }

    /**
     * @description Calls BatchDetailsService.validateQualifierFieldsForPVWorks to reevaluate Lot and Serial Qualifier
     *   for all related Batch Details. This is primarily meant for when Product changes on Case Product.
     * @param caseProducts
     */
    /*
    public static void reevaluteRelatedBatchDetailQualifiers(List<ZTS_US_Case_Product__c> caseProducts) {
        List<Batch_Detail__c> relatedBatchDetails = [
            SELECT Id, ZTS_US_Case_Product__c, ZTS_US_Serial_Number__c, ZTS_US_Product_Lot__c, Serial_Qualifier__c,  Lot_Qualifier__c, ZTS_US_Diluent__c
            FROM Batch_Detail__c
            WHERE ZTS_US_Case_Product__c in: caseProducts];

        BatchDetailsService.validateQualifierFieldsForPVWorks(relatedBatchDetails, null,
            new Map<Id, ZTS_US_Case_Product__c>(caseProducts));

        // Update all batch Details to reset Qualifiers. Skip triggers to save processing time.
        if (!relatedBatchDetails.isEmpty()) {
            DispatchTriggerHandler.bypass('BatchDetailTriggerHandler');
            update relatedBatchDetails;
            DispatchTriggerHandler.clearBypass('BatchDetailTriggerHandler');
        }

        // Update Case Products related to Batch Details that were set in forceUpdateCaseProductBatchDetailIds.
        // These Case Products likely need Serial Number updated.
        if (!forceUpdateCaseProductBatchDetailIds.isEmpty()) {
            Map<Id, Batch_Detail__c> batchDetailMap = new Map<Id, Batch_Detail__c>(relatedBatchDetails);
            List<ZTS_US_Case_Product__c> updateCaseProducts = new List<ZTS_US_Case_Product__c>();
            for (Id updateBatchDetailId : forceUpdateCaseProductBatchDetailIds) {
                updateCaseProducts.add(updateCaseProductFromBatchDetail(batchDetailMap.get(updateBatchDetailId)));
            }

            // Prevent the Case Product from being updated again
            forceUpdateCaseProductBatchDetailIds.clear();

            if (!updateCaseProducts.isEmpty()) {
                // Bypass the Case Product Trigger to avoid an unnecessary loop
                DispatchTriggerHandler.bypass('CSE_CaseProductTriggerHandler');
                update updateCaseProducts;
                DispatchTriggerHandler.clearBypass('CSE_CaseProductTriggerHandler');
            }
        }
    }*/

    /**
     * @description Setup a Primary Batch Detail for the passed in Case Product.
     *   This will set Primary to true and sync Lot #, Serial #, and Diluent # from Case Product to Batch Detail
     * @param caseProduct
     * @return Batch_Detail__c
     */
    private static Batch_Detail__c setupPrimaryBatchDetailForCaseProduct(ZTS_US_Case_Product__c caseProduct) {
        return new Batch_Detail__c(
            ZTS_US_Case_Product__c = caseProduct.Id,
            ZTS_US_Product_Lot__c = caseProduct.ZTS_US_Product_Lot__c,
            ZTS_US_Serial_Number__c =caseProduct.ZTS_US_Serial_Number__c,
            ZTS_US_Diluent__c = caseProduct.ZTS_US_Diluent__c,
            ZTS_US_Primary__c = true
        );
    }

    /**
     * @description Update Lot #, Serial #, and Diluent # for the Case Product related to the passed in Batch Detail.
     *   The Batch Detail will be used to update these fields.
     * @param batchDetail
     * @return ZTS_US_Case_Product__c
     */
    private static ZTS_US_Case_Product__c updateCaseProductFromBatchDetail(Batch_Detail__c batchDetail) {
        return new ZTS_US_Case_Product__c(
            Id = batchDetail.ZTS_US_Case_Product__c,
            ZTS_US_Product_Lot__c = batchDetail.ZTS_US_Product_Lot__c,
            ZTS_US_Serial_Number__c =batchDetail.ZTS_US_Serial_Number__c,
            ZTS_US_Diluent__c = batchDetail.ZTS_US_Diluent__c
        );
    }
    /**
     * @description Make sure all non-primary batch details come over to a cloned case product.  Not cloning the primary since on case product clone the user will be
     * saving the lot/dil/ser and that will handle the primary.  If the user changes these values prior to initial clone save, didn't want to clone an invalid primary batch.
     * @param caseProductIds from cloned trigger
     * @return list of batch details to insert
     */
    public static Batch_Detail__c[] verifyBatchDetailsAfterClone(ZTS_US_Case_Product__c[] clonedCaseProducts,Batch_Detail__c[] upsertBatchDetails){
        Set<Id> cloneSourceIds = new Set<Id>();
        for(ZTS_US_Case_Product__c clonedProduct : clonedCaseProducts){
            if(clonedProduct.getCloneSourceId()!=null && !cloneSourceIds.contains(clonedProduct.getCloneSourceId())){
                cloneSourceIds.add(clonedProduct.getCloneSourceId());
            }
        }
        Map<Id,ZTS_US_Case_Product__c> sourceProducts;
        if(!cloneSourceIds.isEmpty()){
            sourceProducts = new Map<Id,ZTS_US_Case_Product__c>([ SELECT Id,
                                                                (SELECT ZTS_US_Product_Lot__c,ZTS_US_Serial_Number__c,ZTS_US_Diluent__c
                                                                 FROM Batch_Details__r WHERE ZTS_US_Primary__c = false)
                                                                FROM ZTS_US_Case_Product__c WHERE Id in:cloneSourceIds]);
        }
        if(sourceProducts!=null && !sourceProducts.isEmpty()){
            for(ZTS_US_Case_Product__c clonedProduct : clonedCaseProducts){
                ZTS_US_Case_Product__c cloneSource = (sourceProducts.get(clonedProduct.getCloneSourceId()));
                if(cloneSource!=null && cloneSource.Batch_Details__r != null && !cloneSource.Batch_Details__r.isEmpty()){
                    for(Batch_Detail__c cloneSourceBatch : cloneSource.Batch_Details__r){
                        upsertBatchDetails.add(new Batch_Detail__c(   ZTS_US_Case_Product__c = clonedProduct.Id,
                                                                        ZTS_US_Product_Lot__c = cloneSourceBatch.ZTS_US_Product_Lot__c,
                                                                        ZTS_US_Serial_Number__c = cloneSourceBatch.ZTS_US_Serial_Number__c,
                                                                        ZTS_US_Diluent__c = cloneSourceBatch.ZTS_US_Diluent__c));
                    }
                }
            }
        }
        return upsertBatchDetails;
    }

    /**
     * @description Validate the the earliest ZTS_US_Start_Date__c on all case products related to the case for the record being updated <=
     * the earliest ZTS_US_Start_Date__c on all vedraEvent records, if any are attached to the event narrative on the case. Can be called from
     * insert or update. trigger context effects data link creation and query for aggragate results.
     * @params: 
     * 	triggerNew - list of new ZTS_US_Case_Product__c, 
     * 	triggerOldMap - map of old case product id to old case product record - is null if called from insert trigger.
     *  isInsert - Boolean - true if called from insert trigger
     * 	isUpdate - Boolean - true if called from update trigger
     * @return void. no return. Adds error to case product records if it's found that the start date would violate the validation
     */
    public static void validateStartDateForRelatedCaseProducts(List<ZTS_US_Case_Product__c> triggerNew, Map<Id, ZTS_US_Case_Product__c> triggerOldMap, Boolean isInsert, Boolean isUpdate) {
        Set<Id> caseIds = new Set<Id>();
        Set<Id> caseProductIds = new Set<Id>();
        Set<Id> evtNarrativeSet = new Set<Id>();

        /*
         * Section to create data links simulating the relationships of the obcts. Will use this later when we need to figure out
         * which case the updated case product relates to. This allows us to process records where triggerNew[0].case = case 1, and  triggerNew[0].case = case 2
         */
        // map of the case ID on the case product being updated to the case product record
        // this simulates the relationship of the case product lookup to case used for matching the veDRA events later
        Map<Id, ZTS_US_Case_Product__c> caseIdToCaseproductsbeingUpdated = new Map<Id, ZTS_US_Case_Product__c>();
        
        // On insert we do not use the case product id. 
        if (isUpdate) createDataLinksForUpdate( triggerNew,  triggerOldMap, caseIds, caseProductIds, caseIdToCaseproductsbeingUpdated);
        else if (isInsert) createDataLinksForInsert( triggerNew, caseIds, caseIdToCaseproductsbeingUpdated);
        
        // if there are no cases to match any of the records against abort
        if (caseIds.isEmpty()) return;
        
        /*
         * Section to create query the date required to do the validation. 
         * Query the case to get the evt narrative id. This can be used to group and match the aggragate vedra results
         * Query the aggragateResult of the min(ZTS_US_Start_Date__c) for case products. Make sure to ignore the current
         * record being updated if we are in an update trigger.
         * Query the aggragateResult of the min(ZTS_US_Start_Date__c) for vedra events. Group by event narrative id
         */
        Map<Id, Case> casesMap = new Map<Id, Case>([SELECT Id, ZTS_US_Event_Narrative__c FROM Case WHERE Id IN: caseIds]);
        for (Case aCase : casesMap.values()) {
            if (aCase.ZTS_US_Event_Narrative__c == null) continue;
            id nrtvId = aCase.ZTS_US_Event_Narrative__c;
            evtNarrativeSet.add(nrtvId);
        }
        
        List<AggregateResult> aggreagateCaseProduct;
        // if isUpdate we need to ignore all the case product ids for the records being updated to avoid stale values
        // Otherwise qeury them all since the inserts wont return in the result 
        if (isUpdate) aggreagateCaseProduct = [SELECT ZTS_US_Case__c, min(ZTS_US_Start_Date__c) startdate FROM ZTS_US_Case_Product__c WHERE (ZTS_US_Case__c IN: caseIds AND (NOT Id IN: caseProductIds) ) group by ZTS_US_Case__c];
        else if (isInsert) aggreagateCaseProduct = [SELECT ZTS_US_Case__c, min(ZTS_US_Start_Date__c) startdate FROM ZTS_US_Case_Product__c WHERE ZTS_US_Case__c IN: caseIds  group by ZTS_US_Case__c];
        
        List<AggregateResult> aggreagateVedraEvtProduct = [SELECT  ZTS_US_Event_Narrative__c, min(ZTS_US_Start_Date__c) startdate FROM ZTS_US_VedDRA_Event__c WHERE ZTS_US_Event_Narrative__c IN: evtNarrativeSet group by ZTS_US_Event_Narrative__c];
        
        // loop to validate that the case product being updated wont violate the rule
        // Iterate over the case records we had to get earlier. Do this so that we can use the evt narrative id to 
        // match against the list of vedra results, and case id to get the case product
        for (Case caseForValidating : casesMap.values()) {
            // get the evt narative for the case
            Id evtNarrativeId = caseForValidating.ZTS_US_Event_Narrative__c;
            ZTS_US_Case_Product__c caseproductBeingUpdatedForCase = caseIdToCaseproductsbeingUpdated.get(caseForValidating.Id);
            AggregateResult resultForProductsOnCase = null;
            AggregateResult resultForVeDRAonCase = null;

            // loop the aggragate result for all vedraEvents related to the cases
            // find the result where the event narrative id is the one for the current case
            // Set that as the result to match for this case and break the loop.
            for (AggregateResult veDRAResult : aggreagateVedraEvtProduct) {
                if (veDRAResult.get('ZTS_US_Event_Narrative__c') == evtNarrativeId) {
                    resultForVeDRAonCase = veDRAResult;
                    break;
                }
            }

            // if the new product start date is before the aggragate vedra start date
            	// we do not have to run anymore validation since the criteria of atleast 1 case product
            	// on the case where the start date is before all vedra events is being set by this record being updated
            	// continue the outer loop to check the next case
            if (resultForVeDRAonCase == null || resultForVeDRAonCase.get('startdate') == null) continue;
            DateTime vedraDateTime = (DateTime)resultForVeDRAonCase.get('startdate');
            Date earliestVeDRAStartDate = vedraDateTime.date();
            if (caseproductBeingUpdatedForCase.ZTS_US_Start_Date__c <= earliestVeDRAStartDate) continue;
            
            // get the min start date for the case products on the case
            for (AggregateResult productResult : aggreagateCaseProduct) {
                if (productResult.get('ZTS_US_Case__c') == caseForValidating.Id) {
                    resultForProductsOnCase = productResult;
                    break;
                }
            }
            
            // at this point if resultForProductsOnCase for this case is null that means there are no other case products for this case to look at
            // and if the current date being set is after the earliest vedra event add an error to the field and continue to look at the next case
            // if  ( (there are no other products or no other products had a start date ) AND (the new date violates the rule or the start date isnt set) )
            if ( (resultForProductsOnCase == null || resultForProductsOnCase.get('startdate') == null) && (caseproductBeingUpdatedForCase.ZTS_US_Start_Date__c > earliestVeDRAStartDate || caseproductBeingUpdatedForCase.ZTS_US_Start_Date__c == null)) {
                caseproductBeingUpdatedForCase.addError('Dose Start Date must be earlier than or equal to the Veddra Event Start Date.');
                continue;
            }
            
            // if the earliest case product was administered after the first vedra event(earliestProductStartDate > earliestVeDRAStartDate)
            // then this update would violate the start date rule. Add an error
            Date earliestProductStartDate = (Date)resultForProductsOnCase.get('startdate');
            if (earliestProductStartDate > earliestVeDRAStartDate) {
                if (caseproductBeingUpdatedForCase != null) caseproductBeingUpdatedForCase.addError('Dose Start Date must be earlier than or equal to the Veddra Event Start Date.');
            }
        }

        return;
    }
    
    private static void createDataLinksForInsert(List<ZTS_US_Case_Product__c> triggerNew, Set<Id> caseIds, Map<Id, ZTS_US_Case_Product__c> caseIdToCaseproductsbeingUpdated) {
        for (ZTS_US_Case_Product__c updatedCaseProduct : triggerNew) {
            caseIds.add(updatedCaseProduct.ZTS_US_Case__c);
            caseIdToCaseproductsbeingUpdated.put(updatedCaseProduct.ZTS_US_Case__c, updatedCaseProduct);
        }
    }
    
    private static void createDataLinksForUpdate(List<ZTS_US_Case_Product__c> triggerNew, Map<Id, ZTS_US_Case_Product__c> triggerOldMap, Set<Id> caseIds, Set<Id> caseProductIds, Map<Id, ZTS_US_Case_Product__c> caseIdToCaseproductsbeingUpdated) {
         for (ZTS_US_Case_Product__c updatedCaseProduct : triggerNew) {
            ZTS_US_Case_Product__c oldCaseProduct = triggerOldMap.get(updatedCaseProduct.Id);

			Date oldDate = oldCaseProduct.ZTS_US_Start_Date__c;
            Date newDate = updatedCaseProduct.ZTS_US_Start_Date__c;
            // date must be populated and changed
            Date oldStartDate = oldDate;
            Date newStartDate = newDate;
            if ( (oldStartDate == newStartDate) || (oldStartDate == null) ) continue;

            caseIds.add(updatedCaseProduct.ZTS_US_Case__c);
            caseProductIds.add(updatedCaseProduct.Id);

            caseIdToCaseproductsbeingUpdated.put(updatedCaseProduct.ZTS_US_Case__c, updatedCaseProduct);
        }
    }
}