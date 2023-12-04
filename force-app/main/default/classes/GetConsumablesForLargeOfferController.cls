/**
* File Name     :  GetConsumablesForLargeOfferController
* @description  :  Controller Class for selectConsumablesForLargeOffer lwc
* @author       :  Ramiro Alvarez @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/24/21         Ramiro Alvarez @ ATG   Created the Class.
*/

public with sharing class GetConsumablesForLargeOfferController {

    public class FlexibleGroupItem {

        @AuraEnabled
        public String Id { get; set; }

        @AuraEnabled
        public String SAPNumber { get; set; }

        @AuraEnabled
        public String ProductNumber { get; set; }

        @AuraEnabled
        public String ProductName { get; set; }
    }

   /**
   * @description Return already selected materials by Flexible Group/Suffix.
   * @param String quoteId.
   */

    @AuraEnabled(cacheable=true)
    public static Map<String, List<FlexibleGroupItem>> getSelectedMaterialsByFlexibleGroup(String quoteId) {

        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, Deal_Line_Group__c, Flexible_Group__c,
                                               Is_a_consumable_for_LargeOffer__c, SBQQ__Quote__c,SAP_Product_Number__c,
                                               SBQQ__ProductName__c
                                               FROM SBQQ__QuoteLine__c
                                               WHERE Is_a_consumable_for_LargeOffer__c = TRUE
                                               AND  SBQQ__Quote__c = :quoteId];

       // Map<String,List<String>> flexibleSAPCodesMap = new Map<String,List<String>> ();
        Map<String, List<FlexibleGroupItem>> materialsByFlexNumber = new Map<String, List<FlexibleGroupItem>>();

        for (SBQQ__QuoteLine__c line : quoteLines) {

            String key = line.Flexible_Group__c + '-' + (line.Deal_Line_Group__c != null ? line.Deal_Line_Group__c : 'noSuffix');
            System.debug('key: ' + key);

            if (!materialsByFlexNumber.containsKey(key)) {
                materialsByFlexNumber.put(key,new List<FlexibleGroupItem> ());
            }

            FlexibleGroupItem fgi = new FlexibleGroupItem();
                fgi.Id = line.SAP_Product_Number__c;
                fgi.SAPNumber = line.SAP_Product_Number__c;
                fgi.ProductNumber = line.SAP_Product_Number__c;
                fgi.ProductName = line.SBQQ__ProductName__c;

                materialsByFlexNumber.get(key).add(fgi);
        }

        System.debug('flexibleSAPCodesMap: ' + materialsByFlexNumber);
        return materialsByFlexNumber;

    }

   /**
   * @description Create Quote Lines based on selected materials per Flexible Group/Suffix.
   * @param String quoteId.
   * @param List<String> keyList
   */

    @AuraEnabled
    public static void createQuoteLines(String quoteId, List<String> keyList) {

        System.debug('We are in the back-end, quoteID: ' + quoteId + 'obj: ' + keyList);

        //Prepare map to have FlexibleGroup-Suffix as a key and the list of Product2 records that need to be added as QL
        Map<String,Set<String>> flexGroupProdMap = new Map<String,Set<String>>();
        Set<String> allProductCodeSet = new Set<String> ();

        for (String key : keyList) {
            
            List<String> flexGroupSAPcodeList = key.split(':'); //results in a list with 2 elements
            String flexGroupSuffixKey = flexGroupSAPcodeList[0]; // FlexibleGroup:Suffix
            String productCodeKey = flexGroupSAPcodeList[1]; //SAP Product Code
            
            if (!flexGroupProdMap.containsKey(flexGroupSuffixKey)) {
                flexGroupProdMap.put(flexGroupSuffixKey, new Set<String> ());
            }
            
            flexGroupProdMap.get(flexGroupSuffixKey).add(productCodeKey);
            allProductCodeSet.add(productCodeKey);
        }

        System.debug('createQuoteLines => flexGroupProdMap ' + flexGroupProdMap);        
        System.debug('createQuoteLines => allProductCodeSet ' + allProductCodeSet);

        //Query Product2 records
        List<Product2> productList = [SELECT Id, IsActive, ProductCode
            FROM Product2
            WHERE ProductCode IN :allProductCodeSet
            AND IsActive = TRUE];

        Map<String,Id> productCodeIdMap = new Map<String,Id>();
        for (Product2 product : productList) {
            productCodeIdMap.put(product.ProductCode, product.Id);
        }

        System.debug('createQuoteLines => productCodeIdMap ' + productCodeIdMap);

        //Query Existing Flexible Group Lines
        List<SBQQ__QuoteLine__c> parentQuoteLines = [SELECT Id, Flexible_Group__c, Deal_Line_Group__c,        	
                                                    SBQQ__ProductOption__r.SBQQ__Feature__c,SBQQ__Product__r.Id,SBQQ__Number__c,Is_a_consumable_for_LargeOffer__c,
                                                    Is_Aggregate_Commitment_Line__c,SAP_Product_Number__c
                                                    FROM SBQQ__QuoteLine__c
                                                    WHERE (Is_Aggregate_Commitment_Line__c = true OR Is_a_consumable_for_LargeOffer__c = true)
                                                    AND Flexible_Group__c != NULL
                                                    AND SBQQ__Quote__c = :quoteId];

        System.debug('createQuoteLines => parentQuoteLines ' + parentQuoteLines);        

        //Prepare map from existing quote lines
        Map<String, SBQQ__QuoteLine__c> existingQuoteLineMap = new Map<String,SBQQ__QuoteLine__c> ();
        List<SBQQ__QuoteLine__c> quoteLinesToBeDeleted = new List<SBQQ__QuoteLine__c> ();
        Set<String> quoteLinesAlreadyInserted = new Set<String>();

        for (SBQQ__QuoteLine__c quoteLine : parentQuoteLines) {
            String key = quoteLine.Flexible_Group__c + '-' + (quoteLine.Deal_Line_Group__c == null ? 'noSuffix' : quoteLine.Deal_Line_Group__c);

            if (quoteLine.Is_Aggregate_Commitment_Line__c) { // This is parent line, never should be deleted
                existingQuoteLineMap.put(key,quoteLine);
            } else {
                if (!flexGroupProdMap.containsKey(key) || !flexGroupProdMap.get(key).contains(quoteLine.SAP_Product_Number__c)) {
                    quoteLinesToBeDeleted.add(quoteLine);
                } else { //Line already exists and persist in list, no need to insert it again
                    quoteLinesAlreadyInserted.add(key + ':' + quoteLine.SAP_Product_Number__c);
                }
            }
        }

        List<SBQQ__QuoteLine__c> quotelinesToIns = new List<SBQQ__QuoteLine__c>();

        for (String flexGroupSuffix : flexGroupProdMap.keySet()) {
            System.debug('flexGroupSuffix loop: ' + flexGroupSuffix);

            for (String productCode : flexGroupProdMap.get(flexGroupSuffix)) {

                if (productCodeIdMap.containsKey(productCode) && existingQuoteLineMap.containsKey(flexGroupSuffix) && !quoteLinesAlreadyInserted.contains(flexGroupSuffix + ':' + productCode ) ) {

                    quotelinesToIns.add(new SBQQ__QuoteLine__c(
                        SBQQ__Quote__c = quoteId,
                        SBQQ__Quantity__c = 1,
                        SBQQ__Product__c = productCodeIdMap.get(productCode),
                        SBQQ__RequiredBy__c = existingQuoteLineMap.get(flexGroupSuffix).Id,
                        SBQQ__BundledQuantity__c = 1,
                        SBQQ__OptionLevel__c = 3,
                        SBQQ__Number__c = existingQuoteLineMap.get(flexGroupSuffix).SBQQ__Number__c, //Set same number as parent for now
                        Flexible_Group__c = existingQuoteLineMap.get(flexGroupSuffix).Flexible_Group__c,
                        Deal_Line_Group__c = existingQuoteLineMap.get(flexGroupSuffix).Deal_Line_Group__c,
                        Is_a_consumable_for_LargeOffer__c = true,
                        Is_Spread_Commitment_Line__c = true
                    ));
                }
            }

        }

        System.debug('Quote Lines to be inserted: ' + quotelinesToIns);
        SBQQ.TriggerControl.disable();
        QuoteTriggerHandler.disablePriceInSyncCalculation();
        QuoteLineTriggerHandler.disableShipToOverrideUpdate();
        try {

        // Remove old lines
        if (!quoteLinesToBeDeleted.isEmpty()) {
            delete quoteLinesToBeDeleted;
        }
        
        insert quotelinesToIns;

        //Need to update Numbers after insert
        List<SBQQ__QuoteLine__c> allQuoteLines = [SELECT Id,SBQQ__Number__c
                                                  FROM SBQQ__QuoteLine__c
                                                  WHERE SBQQ__Quote__c = :quoteId
                                                  ORDER BY SBQQ__Number__c ASC, CreatedDate ASC];
        Integer lineNumber = 1;
        List<SBQQ__QuoteLine__c> quoteLinesToUpd = new List<SBQQ__QuoteLine__c> ();
        for (SBQQ__QuoteLine__c quoteLine : allQuoteLines) {
            quoteLinesToUpd.add(new SBQQ__QuoteLine__c (Id = quoteLine.Id, SBQQ__Number__c = lineNumber));
            lineNumber++;
        }

        update quoteLinesToUpd;

        } catch (Exception ex) {
            ErrorLogUtil.log('Error inserting Quote Lines for Large offers: ' + quoteId, ex);
            AuraHandledException e = new AuraHandledException('Error inserting quote lines for Large Offer: ' + ex.getMessage());
            e.setMessage('Error inserting quote lines for Large Offer ' + ex.getMessage());
            throw e;
        } finally {
            SBQQ.TriggerControl.enable();
            QuoteTriggerHandler.enablePriceInSyncCalculation();
            QuoteLineTriggerHandler.enableShipToOverrideUpdate();
        }
    }

   /**
   * @description Get Items (SAP Materials) for the flexible groups within the quote.
   * @param String quoteId.
   */
 
    @AuraEnabled(cacheable=true)    
    public static Map<String, List<FlexibleGroupItem>> getFlexGroupItems(String quoteId) {

        if (quoteId == null){
            System.debug('getFlexGroupItems -> quoteId is null, return');
            return new Map<String, List<FlexibleGroupItem>>();
        }

        //Query quote to get Sales Org in order to validate pricebook entries
        List<SBQQ__Quote__c> quotes = [SELECT Id, Sales_Org__c, (
                                            SELECT Id, Flexible_Group__c
                                            FROM SBQQ__LineItems__r
                                            WHERE Is_Aggregate_Commitment_Line__c = TRUE AND Flexible_Group__c != NULL)
                                        FROM SBQQ__Quote__c
                                        WHERE Id = :quoteId
                                        LIMIT 1];

        if (quotes.isEmpty()) {
            throw new AuraHandledException('Error: Quote not found.');
        }

        SBQQ__Quote__c quote = quotes[0];

        if (quote.Sales_Org__c == null) {
            throw new AuraHandledException('Error: Sales Org could not be blank to query consumables for large offers.');
        }

        if (quote.SBQQ__LineItems__r == null || quote.SBQQ__LineItems__r.isEmpty()) {
            throw new AuraHandledException('Error: The current Quote does not have any Aggregate Consumable line configured.');
        }

        Set<String> flexGroupNumberSet = new Set<String>();

        for (SBQQ__QuoteLine__c aggregateCommitmentLine : quote.SBQQ__LineItems__r) {
            flexGroupNumberSet.add(aggregateCommitmentLine.Flexible_Group__c);
        }
                
        //Query for Flexible Group Items
        List<Flexible_Group_Item__c> flexGroupItems = [SELECT Id, Flexible_Group_Number__c, SAP_Material_Number__c
                                                       FROM Flexible_Group_Item__c
                                                       WHERE Flexible_Group_Number__c IN :flexGroupNumberSet];
        
        System.debug('flexGroupItems size' + flexGroupItems.size());

        Set<String> allSAPMaterialNumberSet = new Set<String>();
        Map<String, Set<String>> flexGroupMaterialNumbersMap = new Map<String, Set<String>>();

        for (Flexible_Group_Item__c flexItem : flexGroupItems) {
            allSAPMaterialNumberSet.add(flexItem.SAP_Material_Number__c);
            
            if (flexGroupMaterialNumbersMap.containsKey(flexItem.Flexible_Group_Number__c)) {
                flexGroupMaterialNumbersMap.get(flexItem.Flexible_Group_Number__c).add(flexItem.SAP_Material_Number__c);
            }
            else {
                flexGroupMaterialNumbersMap.put(flexItem.Flexible_Group_Number__c, new Set<String>{ flexItem.SAP_Material_Number__c });
            }
        }
        
        //Query for Product2 records that are related to the FGIs. Also checks that product2 is active and has a related active PBE.
        List<Product2> productList = [SELECT Id, IsActive, SAP_Product_Number__c,ProductCode,Name,
                                        (
                                            SELECT IsActive, Pricebook2Id, Pricebook2.SAP_Sales_Org_ID__c
                                            FROM PricebookEntries WHERE Pricebook2.SAP_Sales_Org_ID__c = :quote.Sales_Org__c AND IsActive = TRUE
                                        )
                                    FROM Product2
                                    WHERE IsActive = TRUE
                                    AND SAP_Product_Number__c IN :allSAPMaterialNumberSet
                                    AND CPQ_Material_Type__c = 'Consumable'
                                    ORDER BY Name ASC];

        System.debug('productList size' + productList.size());


        Map<String, List<FlexibleGroupItem>> materialsByFlexNumber = new Map<String, List<FlexibleGroupItem>>();

        for (Product2 prod : productList) {
            
            if (prod.PricebookEntries != null && !prod.PricebookEntries.isEmpty()) {

                FlexibleGroupItem fgi = new FlexibleGroupItem();
                fgi.Id = prod.ProductCode;
                fgi.SAPNumber = prod.SAP_Product_Number__c;
                fgi.ProductNumber = prod.ProductCode;
                fgi.ProductName = prod.Name;

                for (String flexGroupNumber : flexGroupMaterialNumbersMap.keySet()) {

                    if (flexGroupMaterialNumbersMap.get(flexGroupNumber).contains(prod.SAP_Product_Number__c)) {
                        if (materialsByFlexNumber.containsKey(flexGroupNumber)) {
                            materialsByFlexNumber.get(flexGroupNumber).add(fgi);
                        }
                        else {
                            materialsByFlexNumber.put(flexGroupNumber, new List<FlexibleGroupItem>{ fgi });
                        }
                    }
                }
            }
        }
        
        return materialsByFlexNumber;
    }

    /**
   * @description Get Flexible Groups within the quote.
   * @param String quoteId.
   */

    @AuraEnabled (cacheable=true)
    public static List<SBQQ__QuoteLine__c> getFlexibleGroups(String quoteId) {
       
       List<SBQQ__QuoteLine__c> flexibleGroups = [SELECT Id, Flexible_Group__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c, Deal_Line_Group__c, Aggregate_Commitment_Type__c
                                                  FROM SBQQ__QuoteLine__c
                                                  WHERE Is_Aggregate_Commitment_Line__c = true
                                                  AND Flexible_Group__c != NULL
                                                  AND SBQQ__Quote__c = :quoteId];
       return flexibleGroups;
    }

}