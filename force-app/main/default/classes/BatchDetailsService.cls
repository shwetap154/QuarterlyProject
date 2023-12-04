/**
 * @description       : Service class for Batch Details
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-01-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-18-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with methods to set Qualifier fields
 * 1.1   07-20-2022   Ethan Hirsch @ Zoetis Inc   Clear out Expiry Date and Expiry Approx Date fields when Lot/Serial 
 *                                                are cleared or marked Invalid to keep data accurate.
 * 1.2   08-01-2022   Ethan Hirsch @ Zoetis Inc   Add logic to add the Batch Detail to CaseProductsService.forceUpdateCaseProductBatchDetailIds
 *                                                in setPVWorksQualifierFields so the updated Serial Number is always synced to the Case Product.
 *                                                This is primarily to update the Case Product when Serial Number was cleared manually 
 *                                                and then repopulated from the Lot Number.
 **/
public with sharing class BatchDetailsService {
    private static final String BATCH_TYPE_SERIAL = 'SER';
    private static final String BATCH_TYPE_LOT = 'LOT';
    private static final String ZOETIS_PRODUCT_RT= Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId();

    /**
     * @description First method in a chain of four that sets data based on a matching PVW Product.
     *   This method checks if any of the passed in Batch Details need to be be processed to set the PVW Product fields
     *   and queries for the related Case Product to get the PVW Product.
     *   A Batch Detail is processed if Serial Number or Lot Number are populated and this is insert or this is update
     *   and the fields have changed.
     * @author Ethan Hirsch @ Zoetis Inc | 7-18-2022
     * @param batchDetails 
     * @param oldBatchDetailMap 
     */
    public static void setFieldsFromPVWProduct(List<Batch_Detail__c> batchDetails, Map<Id, Batch_Detail__c> oldBatchDetailMap) {
        List<Batch_Detail__c> processBatchDetails = new List<Batch_Detail__c>();
        Set<Id> caseProductIds = new Set<Id>();

        for(Batch_Detail__c eachBatchDetail: batchDetails)
        {
            Batch_Detail__c oldBatchDetail = null;
            if (oldBatchDetailMap?.containsKey(eachBatchDetail.Id) == true) {
                oldBatchDetail = oldBatchDetailMap.get(eachBatchDetail.Id);
            }

            // Only Process batch details where Case Product is populated and either:
            // 1. This is insert and Serial or Lot are not blank.
            // 2. This is update and Serial or Lot changed
            if (eachBatchDetail.ZTS_US_Case_Product__c != null &&
                ((String.isNotBlank(eachBatchDetail.ZTS_US_Serial_Number__c) || 
                 String.isNotBlank(eachBatchDetail.ZTS_US_Product_Lot__c)) ||
                (oldBatchDetail != null &&
                (eachBatchDetail.ZTS_US_Serial_Number__c != oldBatchDetail.ZTS_US_Serial_Number__c ||
                 eachBatchDetail.ZTS_US_Product_Lot__c != oldBatchDetail.ZTS_US_Product_Lot__c)))) {

                processBatchDetails.add(eachBatchDetail);

                caseProductIds.add(eachBatchDetail.ZTS_US_Case_Product__c);
            }
        }

        // Exit early if there are no records to process
        if (processBatchDetails.isEmpty()) {
            return;
        }

        Map<Id, ZTS_US_Case_Product__c> caseProductMap = new Map<Id, ZTS_US_Case_Product__c>([
            SELECT Id, RecordTypeId, ZTS_US_PVW_Product__c 
            FROM ZTS_US_Case_Product__c 
            WHERE Id IN :caseProductIds]);

        validateQualifierFieldsForPVWorks(processBatchDetails, oldBatchDetailMap,
            caseProductMap);
    }

     /**
     * @description Second method in a chain of four that sets data based on a matching PVW Product.
     *   This method determines if a Qualifier field needs to be evaluated on a record and collects
     *   Serial, Lot Numbers, and PVW Products to query for Batch Numbers.
     *   Only records related to a Zoetis Product Case Product with Product populated and Serial Number or Lot Number 
     *   populated are processed.
     *   On update, one of those fields must have changed to be processed.
     *   This method calls determineBatchNumbersForValidation to continue the chain
     *   Note: This method can also be called from CaseProductService.reevaluteRelatedBatchDetailQualifiers
     * @author Ethan Hirsch @ Zoetis Inc | 7-18-2022
     * @param batchDetails 
     * @param oldRecordsMap
     * @param caseProductMap
     */
    public static void validateQualifierFieldsForPVWorks(List<Batch_Detail__c> batchDetails, 
        Map<Id, Batch_Detail__c> oldBatchDetailsMap, Map<Id, ZTS_US_Case_Product__c> caseProductMap) {
        Set<String> serialNumbers = new Set<String>();
        Set<String> lotNumbers = new Set<String>();
        Set<Id> pvwProducts = new Set<Id>();
        Boolean hasLotOnlyRecords = false;
        List<Batch_Detail__c> processBatchDetails = new List<Batch_Detail__c>();

        for (Batch_Detail__c batchDetail : batchDetails) {          
            // If the record is not a Zoetis Product Record Type do not process it
            ZTS_US_Case_Product__c caseProduct = caseProductMap.get(batchDetail.ZTS_US_Case_Product__c);
            if (caseProduct.RecordTypeId != ZOETIS_PRODUCT_RT) {
                return;
            }

            String oldSerialNumber = null;
            String oldLotNumber = null;
            // On update, skip running this logic if Serial Number or Lot Number have not changed
            if (oldBatchDetailsMap != null && oldBatchDetailsMap.containsKey(batchDetail.Id)) {
                Batch_Detail__c oldBatchDetail = oldBatchDetailsMap.get(batchDetail.Id);
                
                oldSerialNumber = oldBatchDetail.ZTS_US_Serial_Number__c;
                oldLotNumber = oldBatchDetail.ZTS_US_Product_Lot__c;
                
                if (batchDetail.ZTS_US_Serial_Number__c == oldSerialNumber &&
                    batchDetail.ZTS_US_Product_Lot__c == oldLotNumber) {
                    continue;
                }
            }

            Boolean processRecord = false;
            Id pvwProductId = caseProduct.ZTS_US_PVW_Product__c;
            if (pvwProductId != null) {
                pvwProducts.add(pvwProductId);
                processRecord = true;
            }

            String serialNumber = batchDetail.ZTS_US_Serial_Number__c;
            if (String.isNotBlank(serialNumber)) {
                serialNumbers.add(serialNumber);
                processRecord = true;
            }
            else if (String.isNotBlank(oldSerialNumber)) {
                // If Serial Number was cleared out, clear out Serial Qualifier, Expiry Date, and Expiry Approx.
                // This may get reset if Lot Number is still populated
                batchDetail.Serial_Qualifier__c = null;
                batchDetail.ZTS_US_Serial_Expiry_Date__c = null;
                batchDetail.ZTS_US_Serial_Expiry_Date_Approx__c = false;
            }
            
            String lotNumber = batchDetail.ZTS_US_Product_Lot__c;
            if (String.isNotBlank(lotNumber)) {
                lotNumbers.add(lotNumber);
                processRecord = true;

                // When a batchDetail only has a Lot Number present, Serial Number will be looked up by Lot Number
                if (String.isBlank(serialNumber)) {
                    hasLotOnlyRecords = true;
                }
            }
            else if (String.isNotBlank(oldLotNumber)) {
                // Clear out Lot Qualifier, Expiry Date, and Expiry Approx Date if Lot Number was cleared out
                batchDetail.Lot_Qualifier__c = null;
                batchDetail.ZTS_US_Expiry_Date__c = null;
                batchDetail.ZTS_US_Expiry_Date_Approx__c = false;
            }

            if (processRecord) {
                processBatchDetails.add(batchDetail);
            }
        }

        // Exit early if there are no records to query for
        if (serialNumbers.isEmpty() && lotNumbers.isEmpty()) {
            return;
        }

        determineBatchNumbersForValidation(processBatchDetails, serialNumbers, lotNumbers, pvwProducts,
            hasLotOnlyRecords, caseProductMap);
    }

    /**
     * @description Third method in a chain of four that sets data based on a matching PVW Product.
     *   This method queries for Batch Number records using the passes in Serial Numbers, Lot Numbers, and Products.
     *   If hasLotOnlyRecords is true, this method will also query for Serial Number Batch Numbers by Lot Link Number
     *   if there is at least one record with only Lot populated.
     *   This method calls setPVWorksQualifierFields to continue the chain
     * @author Ethan Hirsch @ Zoetis Inc | 7-18-2022
     * @param batchDetails 
     * @param serialNumbers 
     * @param lotNumbers 
     * @param pvwProducts 
     * @param hasLotOnlyRecords 
     * @param caseProductMap
     */
    private static void determineBatchNumbersForValidation(List<Batch_Detail__c> batchDetails,
        Set<String> serialNumbers,Set<String> lotNumbers, Set<Id> pvwProducts, Boolean hasLotOnlyRecords,
        Map<Id, ZTS_US_Case_Product__c> caseProductMap) {
        ProductBatchNumberMap serialBatchNumberMap = new ProductBatchNumberMap();
        ProductBatchNumberMap lotBatchNumberMap = new ProductBatchNumberMap();
        Set<Decimal> lotLinkNumbers = new Set<Decimal>();

        for (ZTS_US_PVW_Batch_Number__c pvwBatchNumberRecord : [
                SELECT ID, ZTS_US_Expiry_Date__c, ZTS_US_PVW_Product__c, ZTS_US_Batch_Type__c,
                       ZTS_US_Batch_Number__c, ZTS_US_Lot_Link_Number__c, ZTS_US_Expiry_Approximate__c
                FROM ZTS_US_PVW_Batch_Number__c 
                WHERE ZTS_US_PVW_Product__c IN: pvwProducts
                AND ((ZTS_US_Batch_Number__c IN: serialNumbers AND ZTS_US_Batch_Type__c =: BATCH_TYPE_SERIAL)
                OR (ZTS_US_Batch_Number__c IN: lotNumbers AND ZTS_US_Batch_Type__c =: BATCH_TYPE_LOT))
                ORDER BY ZTS_US_Batch_Number__c, ZTS_US_Expiry_Date__c NULLS LAST]) {
            if (pvwBatchNumberRecord.ZTS_US_Batch_Type__c == BATCH_TYPE_SERIAL) {
                serialBatchNumberMap.add(pvwBatchNumberRecord, pvwBatchNumberRecord.ZTS_US_Batch_Number__c);
            }
            else if (pvwBatchNumberRecord.ZTS_US_Batch_Type__c == BATCH_TYPE_LOT) {
                lotBatchNumberMap.add(pvwBatchNumberRecord, pvwBatchNumberRecord.ZTS_US_Batch_Number__c);

                // For lot records, collect their Lot Link Number in a set to lookup related Serial Numbers
                lotLinkNumbers.add(pvwBatchNumberRecord.ZTS_US_Lot_Link_Number__c);
            }
        }

        // Query for Serial Numbers to lookup by Lot only when there are records present with only a Lot Link Number.
        ProductBatchNumberMap serialBatchNumbersForLinkedLotMap = new ProductBatchNumberMap();
        if (!lotLinkNumbers.isEmpty() && hasLotOnlyRecords) {
            for (ZTS_US_PVW_Batch_Number__c pvwBatchNumberRecord : [
                SELECT ID, ZTS_US_Expiry_Date__c, ZTS_US_PVW_Product__c, ZTS_US_Batch_Type__c,
                       ZTS_US_Batch_Number__c, ZTS_US_Lot_Link_Number__c, ZTS_US_Expiry_Approximate__c
                FROM ZTS_US_PVW_Batch_Number__c 
                WHERE ZTS_US_PVW_Product__c IN: pvwProducts
                AND ZTS_US_Lot_Link_Number__c IN: lotLinkNumbers 
                AND ZTS_US_Batch_Type__c =: BATCH_TYPE_SERIAL
                ORDER BY ZTS_US_Batch_Number__c, ZTS_US_Expiry_Date__c NULLS LAST]) {
                serialBatchNumbersForLinkedLotMap.add(pvwBatchNumberRecord, 
                    pvwBatchNumberRecord.ZTS_US_Lot_Link_Number__c);
            }
        }

        setPVWorksQualifierFields(batchDetails, serialBatchNumberMap, lotBatchNumberMap,
            serialBatchNumbersForLinkedLotMap, caseProductMap);
    }

    /**
     * @description Fourth and final method in a chain of four that sets data based on a matching PVW Product.
     *   This method sets Qualifier, Expiry Date, and the Expiry Date Approx Flag for Serial or Lot.
     *   If Lot Number and Serial are populated, Batch Numbers for the same Lot Link Number must be found for both
     *   records to set Qualifier to Valid. Otherwise Qualifier is set to Invalid.
     *   If only Lot Number is populated, so long as a Batch Number is found for that Lot Number, Qualifier is set to Valid.
     *   If only Lot Number is populated, a Serial Number will be attempted to be looked up for the Lot Number's Lot Link Number.
     *   If only Serial Number is populated, so long as a Batch Number is found for that Serial Number, Qualifier is set to Valid.
     * @author Ethan Hirsch @ Zoetis Inc | 7-18-2022
     * @param batchDetails 
     * @param serialBatchNumberMap 
     * @param lotBatchNumberMap 
     * @param serialBatchNumbersForLinkedLotMap 
     * @param caseProductMap
     */
    private static void setPVWorksQualifierFields(List<Batch_Detail__c> batchDetails,
        ProductBatchNumberMap serialBatchNumberMap, ProductBatchNumberMap lotBatchNumberMap, 
        ProductBatchNumberMap serialBatchNumbersForLinkedLotMap, Map<Id, ZTS_US_Case_Product__c> caseProductMap) {
        for (Batch_Detail__c batchDetail : batchDetails) {
            ZTS_US_PVW_Batch_Number__c matchingLotPVWBatchNumber = null;
            ZTS_US_PVW_Batch_Number__c matchingSerialPVWBatchNumber = null;

            String lotNumber = batchDetail.ZTS_US_Product_Lot__c;
            String serialNumber = batchDetail.ZTS_US_Serial_Number__c;
            Id pvwProductId = caseProductMap.get(batchDetail.ZTS_US_Case_Product__c).ZTS_US_PVW_Product__c;

            // Lot Number and Serial Number are both populated.
            // A match will only be found if there is a single Batch Number for the Lot Number and Serial Number 
            // with the same Lot Link Number. If there is more than one match these numbers are treated as invalid 
            // per business rules.
            if (String.isNotBlank(lotNumber) && 
                String.isNotBlank(serialNumber)) {
                Boolean matchFound = false;
                
                for (ZTS_US_PVW_Batch_Number__c lotPVWBatchNumber : lotBatchNumberMap.get(pvwProductId, lotNumber)) {
                    Decimal lotLinkNumber = lotPVWBatchNumber.ZTS_US_Lot_Link_Number__c;

                    for (ZTS_US_PVW_Batch_Number__c serialPVWBatchNumber : serialBatchNumberMap.get(pvwProductId,
                        serialNumber)) {
                        if (serialPVWBatchNumber.ZTS_US_Lot_Link_Number__c == lotLinkNumber) {
                            matchingLotPVWBatchNumber = lotPVWBatchNumber;
                            matchingSerialPVWBatchNumber = serialPVWBatchNumber;

                            matchFound = true;
                            break;
                        }
                    }

                    if (matchFound) {
                        // If a match is found stop processing
                        break;
                    }
                }
            }
            // If just Lot Number is populated, take the first matching Batch Number as the record to process
            // Attempt to find a matching Serial Number with the same Lot Link Number to populate Serial Number on the record.
            else if (String.isNotBlank(lotNumber)) {
                List<ZTS_US_PVW_Batch_Number__c> lotPVWBatchNumbers = lotBatchNumberMap.get(
                    pvwProductId, lotNumber);

                // If no Batch Numbers were found this Case Product will be marked invalid
                if (!lotPVWBatchNumbers.isEmpty()) {
                    matchingLotPVWBatchNumber = lotPVWBatchNumbers[0];

                    // If only Lot Number is specified, try to find a matching Serial Number
                    List<ZTS_US_PVW_Batch_Number__c> serialPVWBatchNumbers = serialBatchNumbersForLinkedLotMap.get(
                        pvwProductId, matchingLotPVWBatchNumber.ZTS_US_Lot_Link_Number__c);

                    if (!serialPVWBatchNumbers.isEmpty()) {
                        matchingSerialPVWBatchNumber = serialPVWBatchNumbers[0];
                    }
                }
            }
            // If just Serial Number is populated, take the first matching Batch Number as the record to process
            else if (String.isNotBlank(serialNumber)) {
                List<ZTS_US_PVW_Batch_Number__c> serialPvwBatchNumbers = serialBatchNumberMap.get(pvwProductId,
                    serialNumber);

                if (!serialPvwBatchNumbers.isEmpty()) {
                    matchingSerialPVWBatchNumber = serialPvwBatchNumbers[0];
                }
            }

            // If a matching Lot Batch Number is found, set Expiry Date and Expiry Approx using the Batch Number.
            // Since a match is found, set Qualifier to Valid. 
            if (matchingLotPVWBatchNumber != null) {
                batchDetail.ZTS_US_Expiry_Date__c = matchingLotPVWBatchNumber.ZTS_US_Expiry_Date__c;
                batchDetail.ZTS_US_Expiry_Date_Approx__c = convertExpiryApproximateToBoolean(
                    matchingLotPVWBatchNumber.ZTS_US_Expiry_Approximate__c);

                batchDetail.Lot_Qualifier__c = 'Valid';
            }
            // Only set Lot Qualifier and clear Expiry Date and Expiry Date Approx to Invalid if 
            // Lot Number was populated, no match was found, and Lot Qualifier is not already Invalid.
            else if (matchingLotPVWBatchNumber == null && String.isNotBlank(lotNumber) && 
                batchDetail.Lot_Qualifier__c != 'Invalid') {
                batchDetail.Lot_Qualifier__c = 'Invalid';
                batchDetail.ZTS_US_Expiry_Date__c = null;
                batchDetail.ZTS_US_Expiry_Date_Approx__c = false;
            }
            // If a matching Serial Batch Number is found, set Expiry Date and Expiry Approx using the Batch Number.
            // Since a match is found, set Qualifier to Valid.
            // If Serial Number is blank on the record, use the Batch Number to set Serial Number on the record.
            // The Serial Number would've come from the matching Lot. 
            if (matchingSerialPVWBatchNumber != null) {
                batchDetail.ZTS_US_Serial_Expiry_Date__c = matchingSerialPVWBatchNumber.ZTS_US_Expiry_Date__c;
                batchDetail.ZTS_US_Serial_Expiry_Date_Approx__c = convertExpiryApproximateToBoolean(
                    matchingSerialPVWBatchNumber.ZTS_US_Expiry_Approximate__c);
                    
                batchDetail.Serial_Qualifier__c = 'Valid';

                // If Serial Number is blank, but a match was found, populate Serial Number
                if (String.isBlank(serialNumber)) {
                    batchDetail.ZTS_US_Serial_Number__c = matchingSerialPVWBatchNumber.ZTS_US_Batch_Number__c;

                    // On update, add the Batch Detail to the forceUpdateCaseProductBatchDetailIds so the related 
                    // Case Product is updated with the new Serial Number.
                    // This is to handle situations where Serial Number was cleared out and then repopulated 
                    // by the Lot Number.
                    if (batchDetail.Id != null) {
                        CaseProductsService.forceUpdateCaseProductBatchDetailIds.add(batchDetail.Id);
                    }
                }
            }
            // Only set Serial Qualifier to Invalid and clear out Expiry Date and Expiry Date Approx if Serial Number was populated, 
            // no match was found, and Serial Qualifier is not already invalid.
            else if (matchingSerialPVWBatchNumber == null && String.isNotBlank(serialNumber) && 
                batchDetail.Serial_Qualifier__c != 'Invalid') {
                batchDetail.Serial_Qualifier__c = 'Invalid';
                batchDetail.ZTS_US_Serial_Expiry_Date__c = null;
                batchDetail.ZTS_US_Serial_Expiry_Date_Approx__c = false;
            }
        }
    }

    /**
     * @description converts the Expiry Approximate Text value to a Boolean
     * @author Ethan Hirsch @ Zoetis Inc | 07-14-2022 
     * @param expiryApproximate 
     * @return Boolean
     */
    private static Boolean convertExpiryApproximateToBoolean(String expiryApproximate) {
        return expiryApproximate == 'Y';
    }

    // Helper class for internalizing a more complex map
    private class ProductBatchNumberMap {
        private Map<Id, Map<Object, List<ZTS_US_PVW_Batch_Number__c>>> internalMap;

        public ProductBatchNumberMap() {
            internalMap = new Map<Id, Map<Object, List<ZTS_US_PVW_Batch_Number__c>>>();
        }

        /**
         * @description Add the PVW Batch Number to the map by Product and the passed in grouping value
         * @author Ethan Hirsch @ Zoetis Inc | 7-18-2022 
         * @param pvwBatchNumberRecord 
         * @param groupingValue 
         */
        public void add(ZTS_US_PVW_Batch_Number__c pvwBatchNumberRecord, Object groupingValue) {
            Id pvwProductId = pvwBatchNumberRecord.ZTS_US_PVW_Product__c;
            if (!internalMap.containsKey(pvwProductId)) {
                internalMap.put(pvwProductId, new Map<Object, List<ZTS_US_PVW_Batch_Number__c>>());
            }

            Map<Object, List<ZTS_US_PVW_Batch_Number__c>> batchNumberMap = internalMap.get(pvwProductId);

            if (!batchNumberMap.containsKey(groupingValue)) {
                batchNumberMap.put(groupingValue, new List<ZTS_US_PVW_Batch_Number__c>());
            }

            batchNumberMap.get(groupingValue).add(pvwBatchNumberRecord);
        }

        /**
         * @description Retrieve the PVW Batch Number to the map by Product and the passed in grouping value
         * @author Ethan Hirsch @ Zoetis Inc | 7-18-2022 
         * @param pvwProductId 
         * @param groupingValue 
         * @return List<ZTS_US_PVW_Batch_Number__c>
         */
        public List<ZTS_US_PVW_Batch_Number__c> get(Id pvwProductId, Object groupingValue) {
            if (internalMap.containsKey(pvwProductId) &&
                internalMap.get(pvwProductId).containsKey(groupingValue)) {
                return internalMap.get(pvwProductId).get(groupingValue);
            }

            // If no data is present return an empty list
            return new List<ZTS_US_PVW_Batch_Number__c>();
        }
    }
}