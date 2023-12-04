/**
* File Name     :  QuoteLineTriggerHandler
* @description  :  Trigger Handler for QuoteLineTrigger (SBQQ__QuoteLine__c object)
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/27/2019    Cesar Sandrigo @ ATG     Created the Class. Added updateQuoteVistexPricingInSyncFlag method.
* 1.2     3/13/2020    Cesar Sandrigo @ ATG     Populate the Unit of Measure field based on the Pricebook Entry.
* 1.3     8/11/2022    Mila Imas                logic for mismatch qty updt (device only)
* 1.4	  08/04/2023   Rahul Kumar @Deloitte	Refactor the code
*/
public class QuoteLineTriggerHandler {
    // This can be moved into a Custom Setting if needed
    private static List<String> PRICING_DEPENDENT_FIELD_NAMES = new List<String>{'SBQQ__Quantity__c', 'SBQQ__Product__c'};        
        /**
* @descripiton List with the new version of the objects. Provided by the trigger.
*/
        private List<SBQQ__QuoteLine__c> triggerNew { get; set; }    
    /**
* @descripiton Map with the previous version of the objects. Provided by the trigger.
*/
    private Map<Id, SBQQ__QuoteLine__c> triggerOldMap { get; set; }    
    /**
* @descripiton boolean to prevent recursive actions on update
*/
    private static Boolean run = true;    
    /**
* @description Indicates if the Ship-to Override update should be bypassed
*/
    private static Boolean bypassShipToOverrideUpdate = false;
    
    /**
* @description Class constructor.
* @param newList  Map of the new version of the Quote Lines, provided by the trigger.
* @param oldMap Map of the old version of the Quote Lines, provided by the trigger.
*/
    public QuoteLineTriggerHandler(List<SBQQ__QuoteLine__c> newList, Map<Id, SBQQ__QuoteLine__c> oldMap) {
        this.triggerNew = newList;
        this.triggerOldMap = oldMap;
    }
    
    public void handleBeforeInsert() {
        // Set the unit of measure based on the
        
        setUnitOfMeasure(triggerNew);
        updateQTAnnualPurchaseComValue(true);
    }
    
    public void handleAfterInsert() {
        // After insert
        // Update 'Vistex pricing in sync' flag in the Quote
        setQuoteVistexPricingInSyncFlagOnQuoteLineCreation();
        getTranslatedDealText();
        updateQuoteRebateEligProduct(true);
        //Commented below method because we are not using QuoteLine.Ship_to_location__c - By Rahul Deloitte
        // validateAdressToAccountHierarchy();
    }
    
    public void handleBeforeUpdate() {
        // Set the unit of measure based on the
        setUnitOfMeasure(triggerNew, triggerOldMap);
        updateQTAnnualPurchaseComValue(false);
    }
    
    public void handleAfterUpdate() {
        // After update
        // Update 'Vistex pricing in sync' flag in the Quote
        updateQuoteVistexPricingInSyncFlag();
        //Commented below method because we are not using QuoteLine.Ship_to_location__c - By Rahul Deloitte
        // validateAdressToAccountHierarchy();
        // Update ship-to override records associated to specific commitment lines
        updateShipToOverrideForSpecificCommitment();       
        updateQuoteRebateEligProduct(false);

    }
    
    public void handleBeforeDelete() {
        removeAssociatedQuantityOverrides(triggerOldMap.keySet());
        updateQuoteRebateEligProductDelete();
    }
    
    public void handleAfterDelete() {
        SBQQ.TriggerControl.disable();
        Map<Id, SBQQ__Quote__c> quotesToUpdate = setQuoteVistexPricingInSyncFlagOnQuoteLineDeletion(false);
        removeDealTextFromQuote(quotesToUpdate);
        update quotesToUpdate.values();
        SBQQ.TriggerControl.enable();
    }
    
    /**
* @description Bypasses the ship-to override update after quote line quantity is changed.
*/
    public static void disableShipToOverrideUpdate() {
        bypassShipToOverrideUpdate = true;
    }
    
    /**
* @description Removes the Bypass the ship-to override update after quote line quantity is changed.
*/
    public static void enableShipToOverrideUpdate() {
        bypassShipToOverrideUpdate = false;
    }
    
    /**
* @description Sets Unit of Measure based on the Pricebook Entry.
*/
    private void setUnitOfMeasure(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> oldMap) {
        // Get the quote lines where the PBE has been modified
        List<SBQQ__QuoteLine__c> changedQuoteLines = (List<SBQQ__QuoteLine__c>) ApexUtils.findChangedRecs(
            quoteLines,
            oldMap,
            ApexUtils.getSobjectFieldsByName( CPQ_CONSTANT_Zoetis.STRING_QUOTELINE_API_NAME , new List<String>{ 'SBQQ__PricebookEntryId__c' })
        );
        
        if (changedQuoteLines.isEmpty())
            return;
        
        // Set the Unit of Measure only in the quote lines
        setUnitOfMeasure(changedQuoteLines);
    }
    
    /**
* @description Populates the "SAP Unit of Measure" field in the "SBQQ__QuoteLine__c" records based on the corresponding "PricebookEntry" records.
*/
    private void setUnitOfMeasure(List<SBQQ__QuoteLine__c> quoteLines) {
        // PBE Id -> List of Quote Lines related the PBE. There could be more than one Quote Line with the same PBE
        Map<Id, List<SBQQ__QuoteLine__c>> pbeQuoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
        
        // Populate the PBE Id -> List<Quote Line> Map
        for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
            if (quoteLine.SBQQ__PricebookEntryId__c == null) {
                continue;
            }
            
            if (!pbeQuoteLineMap.containsKey(quoteLine.SBQQ__PricebookEntryId__c))
            {
                pbeQuoteLineMap.put(quoteLine.SBQQ__PricebookEntryId__c, new List<SBQQ__QuoteLine__c>());
            }
            
            pbeQuoteLineMap.get(quoteLine.SBQQ__PricebookEntryId__c).add(quoteLine);
        }
        
        // If no value on the map, do nothing else
        if (pbeQuoteLineMap.isEmpty())
            return;
        
        // Get the pricebook entries
        // List<PricebookEntry> priceBookEntries = [SELECT Id, SAP_Unit_Of_Measure__c FROM PricebookEntry WHERE Id IN :pbeQuoteLineMap.keySet()];
        
        // Populate the Unit of Measure in the Quote Line
        /*  for (PricebookEntry pbe : priceBookEntries) {
for (SBQQ__QuoteLine__c ql : pbeQuoteLineMap.get(pbe.Id)) {
ql.SAP_Unit_Of_Measure__c = pbe.SAP_Unit_Of_Measure__c;
}
}*/
        
        
        /****-------------------Removed nested for loop because O(n^2) >> O(N) --------------------------------****/
        // Create a map to hold the PricebookEntry Id  --> PricebookEntry
        
        
        Map<Id, PricebookEntry> pbeUnitOfMeasureMap = new map<Id, PricebookEntry>([SELECT Id, SAP_Unit_Of_Measure__c FROM PricebookEntry WHERE Id IN :pbeQuoteLineMap.keySet()]);
        
        // Populate the Unit of Measure in the Quote Line using the map
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            if (ql.SBQQ__PricebookEntryId__c != null && pbeUnitOfMeasureMap.containsKey(ql.SBQQ__PricebookEntryId__c)) 
            {
                ql.SAP_Unit_Of_Measure__c = pbeUnitOfMeasureMap.get(ql.SBQQ__PricebookEntryId__c).SAP_Unit_Of_Measure__c;
            }
        }
        
    }
    
    /**
* @description Updates the 'Vistex Pricing in Sync' flag in the related Quote after quote line creation.
*/
    public void setQuoteVistexPricingInSyncFlagOnQuoteLineCreation() {
        // If Vistex Price in Sync Calculation is disabled, get out of here.
        if (QuoteTriggerHandler.isPriceInSyncCalculationDisabled()) {
            return;
        }
        
        Set<Id> priceNotInSyncQuoteIds = new Set<Id>();
        
        for (SBQQ__QuoteLine__c quoteLine : this.triggerNew) {
            // If the quote line is not an automatic addon and is not part of the bundle structure
            if (!quoteLine.Vistex_Automatic_Add_on__c && !quoteLine.Vistex_Manual_Add_on__c && !quoteLine.SBQQ__Bundle__c) {
                priceNotInSyncQuoteIds.add(quoteLine.SBQQ__Quote__c);
            }
        }
        
        // Update the quotes
        if(priceNotInSyncQuoteIds.size() > 0)
        {
            setPriceNotInSyncForQuotes(priceNotInSyncQuoteIds, true); 
        }
        
    }
    
    /**
* @description Updates the 'Vistex Pricing in Sync' flag in the related Quote after quote line deletion.
*/
    public Map<Id, SBQQ__Quote__c> setQuoteVistexPricingInSyncFlagOnQuoteLineDeletion(Boolean doUpdate) {
        // If Vistex Price in Sync Calculation is disabled, get out of here.
        if (QuoteTriggerHandler.isPriceInSyncCalculationDisabled()) {
            return new Map<Id, SBQQ__Quote__c>();
        }
        
        Set<Id> priceNotInSyncQuoteIds = new Set<Id>();
        
        //Store quote Ids in set
        Set<Id> quoteIds = new Set<Id> ();
        Map<Id,String> quoteProductCodeMap = new Map<Id,String> ();
        
        for (SBQQ__QuoteLine__c quoteline : triggerOldMap.values()) {
            quoteIds.add(quoteline.SBQQ__Quote__c);
        }
        
        // Query Custom setting to get US_Program_Type_Choice_Financed__c product codes
        CPQ_Warranty_Addons__c warrantyConfig = CPQ_Warranty_Addons__c.getOrgDefaults();
        List<String> uSProgramTypeChoiceFinancedList = warrantyConfig.US_Program_Type_Choice_Financed__c != null ?
            warrantyConfig.US_Program_Type_Choice_Financed__c.split(',') : new List<String> ();    
        
        // Query parent bundle line to get product code
        List<SBQQ__QuoteLine__c> parentLines = [SELECT Id, SBQQ__ProductCode__c,SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE Vistex_Deal_Header__c != NULL AND SBQQ__Quote__c IN :quoteIds];
        
        for (SBQQ__QuoteLine__c quoteline : parentLines) {
            quoteProductCodeMap.put(quoteline.SBQQ__Quote__c, quoteline.SBQQ__ProductCode__c);
        }
        
        for (SBQQ__QuoteLine__c quoteLine : triggerOldMap.values()) {
            if (!quoteLine.Vistex_Manual_Add_on__c || uSProgramTypeChoiceFinancedList.contains(quoteProductCodeMap.get(quoteline.SBQQ__Quote__c))) {
                priceNotInSyncQuoteIds.add(quoteLine.SBQQ__Quote__c);
            }
        }
        
        // Update the quotes
        return setPriceNotInSyncForQuotes(priceNotInSyncQuoteIds, doUpdate);
    }
    
    /**
* @description Updates the 'Vistex Pricing in Sync' flag in the related Quote if some of the pricing-dependent fields in the Quote changed.
*/
    public void updateQuoteVistexPricingInSyncFlag() {
        // If Vistex Price in Sync Calculation is disabled, get out of here.
        if (QuoteTriggerHandler.isPriceInSyncCalculationDisabled()) {
            return;
        }
        
        // Get the list of SObject fields from the names in the constant value
        List<Schema.SObjectField> pricingDependentQuoteFields = ApexUtils.getSobjectFieldsByName(CPQ_CONSTANT_Zoetis.STRING_QUOTELINE_API_NAME, PRICING_DEPENDENT_FIELD_NAMES);
        
        // Find the records that were changed
        List<SBQQ__QuoteLine__c> changedQuoteLines = ApexUtils.findChangedRecs(triggerNew, triggerOldMap, pricingDependentQuoteFields);
        
        Set<Id> priceNotInSyncQuoteIds = new Set<Id>();
        
        for (SBQQ__QuoteLine__c quoteLine : changedQuoteLines) {
            //CPQ_Material_Type__c ,SBQQ__Quantity__c , SBQQ__UpgradedQuantity__c Is_Quantity_Overridable__c
            if (quoteLine.CPQ_Material_Type__c == 'device' && quoteLine.Contract_Price__c > 0){ 
                continue;
            }
            priceNotInSyncQuoteIds.add(quoteLine.SBQQ__Quote__c);
        }
        
        // Update the quotes
        setPriceNotInSyncForQuotes(priceNotInSyncQuoteIds, true);
    }
    
    /**
* @description Updates the 'Vistex Pricing in Sync' flag in the related Quote if some of the pricing-dependent fields in the Quote changed.
* @param quoteIds Ids of the quotes to mark as 'Price not in sync'.
*/
    private Map<Id, SBQQ__Quote__c> setPriceNotInSyncForQuotes(Set<Id> quoteIds, Boolean doUpdate) {
        // If Vistex Price in Sync Calculation is disabled, get out of here.
        if (QuoteTriggerHandler.isPriceInSyncCalculationDisabled()) {
            return new Map<Id, SBQQ__Quote__c>();
        }
        
        // If there's nothing to process, let's get out of here
        if (quoteIds.size() < 1)
            return new Map<Id, SBQQ__Quote__c>();
        
        // List to store quotes to be updated
        Map<Id, SBQQ__Quote__c> quotesToUpdate = new Map<Id, SBQQ__Quote__c>();
        
        
        for (Id quoteId : quoteIds) {
            // Add to the map
            quotesToUpdate.put(quoteId, new SBQQ__Quote__c(Id = quoteId, Vistex_Price_In_Sync__c = false)); 
            //  System.debug(LoggingLevel.WARN, 'Quote Line MODIFIED >> Vistex Price NOT VALID ANYMORE for Quote: ' + quoteId);
        }
        
        if (doUpdate) {
            SBQQ.TriggerControl.disable();
            
            try {
                update quotesToUpdate.values();
            } catch (Exception ex) {
                throw ex;
            } finally {
                SBQQ.TriggerControl.enable();
            }
        }
        
        return quotesToUpdate;
    }
    
    //Get the data related to quotelines for the vistex deal
    public void getTranslatedDealText() {
        Boolean dealsToProcess = false;
        Set<Id> quoteIds = ApexUtils.pluckIdSet(triggerNew, CPQ_CONSTANT_Zoetis.STRING_QUOTE_API_NAME);
        Map<String, List<Vistex_Banner_E1EDKT1__c>> vistexDealBannerMap = new Map<String, List<Vistex_Banner_E1EDKT1__c>>();
        
        for (SBQQ__QuoteLine__c quoteLine : triggerNew) {
            if (quoteLine.Vistex_Deal_ID__c != null && !vistexDealBannerMap.containsKey(quoteLine.Vistex_Deal_ID__c)) {
                vistexDealBannerMap.put(quoteLine.Vistex_Deal_ID__c, new List<Vistex_Banner_E1EDKT1__c>());
                dealsToProcess = true;
            }
        }
        //We only want to continue if any vistex deals were on a quote line
        if (dealsToProcess) {
            //  System.debug('After Insert >> QuoteLineTrigger.getTranslatedDealText()');
            AutoBundleDataCollector collector = new AutoBundleDataCollector();
            collector.dealBundleData = new AutoBundleDataWrapper();
            //query unique set of language codes
            Map<Id, SBQQ__Quote__c> quoteMap = queryQuotes(quoteIds);
            //  System.debug('Quote Map: ' + quoteMap);
            Set<String> languageCodes = new Set<String>();
            
            for (SBQQ__Quote__c quote : quoteMap.values()) {
                languagecodes.add(quote.Quote_Language_Code__c);
            }
            // System.debug('Language Codes: ' + languageCodes);
            
            List<Vistex_Banner_E1EDKT1__c> banners = collector.queryVistexBannersByDealNum(new List<String>(vistexDealBannerMap.keySet()),languageCodes);
            //  System.debug('Queried Banners: ' + banners);
            for (Vistex_Banner_E1EDKT1__c banner : banners) {
                if (vistexDealBannerMap.containsKey(banner.DEALK01_Ext_Id__r.DEALNUM__c)) {
                    vistexDealBannerMap.get(banner.DEALK01_Ext_Id__r.DEALNUM__c).add(banner);
                    // System.debug('Added Banner to Map: ' + banner);
                }
            }
            
            handleQuoteLineUpdates(collector, vistexDealBannerMap, quoteMap);
        }
    }
    //handle quoteline field values and dml update
    private void handleQuoteLineUpdates(AutoBundleDataCollector collector, Map<String, List<Vistex_Banner_E1EDKT1__c>> vistexDealBannerMap, Map<Id, SBQQ__Quote__c> quoteMap) 
    {
        //Loop quoteLines and find the translated text needed.  Stamp it into fields.
        List<SBQQ__QuoteLine__c> quotelinesToUpdate = new List<SBQQ__QuoteLine__c>();
        Set<SBQQ__Quote__c> quotesToUpdate = new Set<SBQQ__Quote__c>();
        SBQQ__QuoteLine__c newQL ;
        for (SBQQ__QuoteLine__c quoteLine : triggerNew) {
            if (quoteMap.containsKey(quoteLine.SBQQ__Quote__c)) {
                Boolean showQtReabteSection = false;
                SBQQ__Quote__c quote = quoteMap.get(quoteLine.SBQQ__Quote__c);
                if (!String.isBlank(quoteLine.Rebate_Commitment__c)) {
                    // System.debug('Has Rebate Commitment Val');
                    quote.Rebate_Commitment__c = quoteLine.Rebate_Commitment__c;
                    showQtReabteSection = true;
                }
                //CPQATG-530 check the quote Offer Terms box and map value
                //  System.debug('handleQuoteLineUpdates, quoteline.Offer_Terms_and_Conditions__c: ' + quoteLine.Offer_Terms_and_Conditions__c);
                if (!String.isBlank(quoteLine.Offer_Terms_and_Conditions__c))
                {
                    quote.Offer_Terms_and_Conditions__c = quoteLine.Offer_Terms_and_Conditions__c;
                    quote.Has_Offer_Terms_and_Conditions__c = true;
                } 
                else
                {
                    quote.Offer_Terms_and_Conditions__c = null;
                    quote.Has_Offer_Terms_and_Conditions__c = false;
                }
                
                //Assumption that there is only 1 deal per quote. Meaning 1 line per quote will hit this code.
                if (quoteLine.Vistex_Deal_ID__c != null && vistexDealBannerMap.containsKey(quoteLine.Vistex_Deal_ID__c)) 
                {
                    
                    //reset collector values
                    collector.dealBundleData.zprmText = null;
                    collector.dealBundleData.zterText = null;
                    collector.dealBundleData.zprqText = null;
                    collector.dealBundleData.zcpqText = null;
                    //Set collector values for current deal
                    collector.processVistexBanners(quoteLine.Vistex_Deal_ID__c, quote.Quote_Language_Code__c, vistexDealBannerMap.get(quoteLine.Vistex_Deal_ID__c) );
                    /* nested for loop*/
                    newQL = new SBQQ__QuoteLine__c();
                    newQL.Id = quoteLine.Id;
                    newQL.vistex_banner_zprm_translated__c = collector.dealBundleData.zprmText;
                    newQL.vistex_banner_zter_translated__c = collector.dealBundleData.zterText;
                    newQL.vistex_banner_zcpq_translated__c = collector.dealBundleData.zcpqText;
                    newQL.vistex_banner_zprq_translated__c = collector.dealBundleData.zprqText;
                    quotelinesToUpdate.add(newQL);
                    
                    //ATGCPQ 646.  We also need to stamp these values to the quote for output docs.
                    
                    if (collector.dealBundleData.zprmText != null) {
                        quote.vistex_banner_zprm_translated__c = collector.dealBundleData.zprmText;
                        quote.QT_Display_Promo__c = true;
                        showQtReabteSection = true;
                        //System.debug('Has ZPRM');
                    } else {
                        quote.vistex_banner_zprm_translated__c = null;
                        quote.QT_Display_Promo__c = false;
                    }
                    
                    if (collector.dealBundleData.zterText != null) {
                        quote.vistex_banner_zter_translated__c = collector.dealBundleData.zterText;
                        quote.QT_Display_Termination_Clause__c = true;
                        showQtReabteSection = true;
                        //System.debug('Has ZTER');
                    } else {
                        quote.vistex_banner_zter_translated__c = null;
                        quote.QT_Display_Termination_Clause__c = false;
                    }
                    
                    if (collector.dealBundleData.zcpqText != null) {
                        quote.vistex_banner_zcpq_translated__c = collector.dealBundleData.zcpqText;
                        quote.QT_Display_ZPRQ_field__c = true;
                        showQtReabteSection = true;
                        // System.debug('Has ZCPQ');
                    } else {
                        quote.vistex_banner_zcpq_translated__c = null;
                        quote.QT_Display_ZPRQ_field__c = false;
                    }
                    
                    if (collector.dealBundleData.zprqText != null) {
                        quote.vistex_banner_zprq_translated__c = collector.dealBundleData.zprqText;
                        quote.QT_Display_Program_Prerequisite__c = true;
                        showQtReabteSection = true;
                        // System.debug('Has ZPRM');
                    } else {
                        quote.vistex_banner_zprq_translated__c = null;
                        quote.QT_Display_Program_Prerequisite__c = false;
                    }
                    
                    if (showQtReabteSection) {
                        quote.QT_Rebate_Commitment_Display_Logic__c = true;
                    }
                    
                    quotesToUpdate.add(quote);
                    
                }
            }
        }
        SBQQ.TriggerControl.disable();
        if (quotelinesToUpdate.size() > 0) {
            try {
                // System.debug('Updating quote lines: ' + quotelinesToUpdate);
                update quotelinesToUpdate;
            } catch (Exception e) {
                // System.debug('An error occurred while tyring to update quote lines with translated deal text.');
                // System.debug(e);
                ErrorLogUtil.log(e);
                ErrorLogUtil.commitLogs();
            }
        }
        
        if (quotesToUpdate.size() > 0) {
            try {
                // System.debug('Updating quotes: ' + quotesToUpdate);
                List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>(quotesToUpdate);
                update quoteList;
            } catch (Exception e) {
                //System.debug('An error occurred while tyring to update quotes with translated deal text.');
                //System.debug(e);
                ErrorLogUtil.log(e);
                ErrorLogUtil.commitLogs();
            }
        }
        SBQQ.TriggerControl.enable();
    }
    //If a quote line with deal text was deleted, wipe out the quotes text fields as well.
    public void removeDealTextFromQuote(Map<Id, SBQQ__Quote__c> quotesToUpdate) {
        for (SBQQ__QuoteLine__c quoteLine : this.triggerOldMap.values()) {
            //Check that this quoteline had the banner text
            if (
                !String.isBlank(quoteLine.vistex_banner_zprm_translated__c) ||
                !String.isBlank(quoteLine.vistex_banner_zter_translated__c) ||
                !String.isBlank(quoteLine.vistex_banner_zcpq_translated__c) ||
                !String.isBlank(quoteLine.vistex_banner_zprq_translated__c) ||
                !String.isBlank(quoteLine.Offer_Terms_and_Conditions__c)
            ) {
                if (!quotesToUpdate.containsKey(quoteLine.SBQQ__Quote__c)) {
                    quotesToUpdate.put(quoteLine.SBQQ__Quote__c, new SBQQ__Quote__c(id = quoteLine.SBQQ__Quote__c));
                }
                
                SBQQ__Quote__c quote = quotesToUpdate.get(quoteLine.SBQQ__Quote__c);
                quote.vistex_banner_zprm_translated__c = null;
                quote.QT_Display_Promo__c = false;
                quote.vistex_banner_zter_translated__c = null;
                quote.QT_Display_Termination_Clause__c = false;
                quote.vistex_banner_zcpq_translated__c = null;
                quote.QT_Display_Program_Prerequisite__c = false;
                quote.vistex_banner_zprq_translated__c = null;
                quote.QT_Display_ZPRQ_field__c = false;
                quote.Offer_Terms_and_Conditions__c = null;
                quote.Has_Offer_Terms_and_Conditions__c = false;
                //quote.QT_Rebate_Commitment_Display_Logic__c = false;
            }
        }
    }
    
    //query quotes from a set of Ids
    //Add fields to use where necessary
    private Map<Id, SBQQ__Quote__c> queryQuotes(Set<Id> quoteIds) {
        return new Map<Id, SBQQ__Quote__c>(
            [
                SELECT Id, Quote_Language_Code__c, Account_Ultimate_Parent_Name__c, SBQQ__Account__c, Rebate_Commitment__c
                FROM SBQQ__Quote__c
                WHERE Id IN :quoteIds
            ]
        );
    }
    
    //Commented below method because we are not using QuoteLine.Ship_to_location__c - By Rahul Deloitte
    /*
    public void validateAdressToAccountHierarchy() {
        List<SBQQ__QuoteLine__c> linesToValidate = getQuoteLinesForAddressValidation();
        //Query the quotes so we can get accounts in the hierarchy
        if (linesToValidate.size() > 0) {
            Map<Id, SBQQ__Quote__c> quotes = queryQuotes(ApexUtils.pluckIdSet(linesToValidate, CPQ_CONSTANT_Zoetis.STRING_QUOTE_API_NAME));
            Map<String, List<SBQQ__QuoteLine__c>> quoteLineQuoteMap = ApexUtils.groupBy(linesToValidate, CPQ_CONSTANT_Zoetis.STRING_QUOTE_API_NAME);
            Set<Id> accountIds = ApexUtils.pluckIdSet(quotes.values(), 'SBQQ__Account__c');
            List<Account> hierarchyAccounts = CPQ_QuoteAddressUtils.queryAccountHierarchy(accountIds);
            Map<Id, List<Account>> parentAccountMap = CPQ_QuoteAddressUtils.buildParentAccountMap(accountIds, hierarchyAccounts);
            
            //Loop quotes to get addresses based on the ultimate parent and validate against address fields.
            for (SBQQ__Quote__c quote : quotes.values()) {
                Set<Id> addressesInHierarchy = new Set<Id>();
                if (parentAccountMap.containsKey(quote.SBQQ__Account__c)) {
                    for (Account account : parentAccountMap.get(quote.SBQQ__Account__c)) {
                        addressesInHierarchy.addAll(ApexUtils.pluckIdSet(account.Addresses__r, 'Id'));
                    }
                    if (quoteLineQuoteMap.containsKey(quote.Id)) {
                        //get the quotelines from the map
                        list<SBQQ__QuoteLine__c> lines = quoteLineQuoteMap.get(quote.Id);
                        for (SBQQ__QuoteLine__c line : lines) 
                        {                         
                            //We are only validating ship-to address per CPQATG-667
                            if (line.Ship_To_Address__c != null && !addressesInHierarchy.contains(line.Ship_To_Address__c)) 
                            {
                                String errorString = 'Quote Line Number ' + Integer.valueOf(line.SBQQ__Number__c) + ':\r\n' + CPQ_CONSTANT_Zoetis.STRING_ADDRESS_ACC_ERROR;
                                line.addError(errorString);
                            }
                        }
                    }
                }
            }
        }
    }
    
    public List<SBQQ__QuoteLine__c> getQuoteLinesForAddressValidation() {
        //get only quotes that have a shipt to address to validate addresses in the account hierarchy
        List<SBQQ__QuoteLine__c> quotesLinesToProcess = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c line : this.triggerNew) {
            if (line.Ship_To_Address__c != null) {
                quotesLinesToProcess.add(line);
            }
        }
        return quotesLinesToProcess;
    }
    */
    
    private void removeAssociatedQuantityOverrides(Set<Id> quoteLineIdSet) {
        List<Ship_To_Quantity_Override__c> shipToQuantityOverrides = [ SELECT Id FROM Ship_To_Quantity_Override__c WHERE Quote_Line__c IN :quoteLineIdSet ];
        
        // System.debug('QuoteLineTriggerHandler > removeAssociatedQuantityOverrides: ' + shipToQuantityOverrides.size());
        try{
            delete shipToQuantityOverrides; 
        }
        Catch (Exception ex)
        {
            ErrorLogUtil.log(ex);
            ErrorLogUtil.commitLogs();
        }
        
    }
    
    /**
* @description Updates the Quantity Override records related to a quote line when it changes the Quantity.
*              This is to support the scenario when the Specific Quantity commitment is changed in the QLE
*              and that impacts the Quantity in the line. This should only affect non-vistex markets but
*              it's good to keep everything in sync.
*/
    private void updateShipToOverrideForSpecificCommitment() {
        // If it's bypassed, return. Bypass is used in the Ship-to configuration page.
        if (bypassShipToOverrideUpdate) {
            return;
        }
        
        Map<Id, SBQQ__QuoteLine__c> quotesLinesToProcess = new Map<Id, SBQQ__QuoteLine__c>();
        
        // Only process lines that are specific commitments and Quantity has changed.
        for (SBQQ__QuoteLine__c line : this.triggerNew) {
            if (
                line.Specific_Commitment__c &&
                this.triggerOldMap.containsKey(line.Id) &&
                this.triggerOldMap.get(line.Id).SBQQ__Quantity__c != line.SBQQ__Quantity__c
            ) {
                quotesLinesToProcess.put(line.Id, line);
            }
        }
        
        // If there's nothing to process, return
        if (quotesLinesToProcess.isEmpty()) {
            return;
        }
        
        // Get all the Quantity overrides related to the lines
        List<Ship_To_Quantity_Override__c> shipToQuantityOverrides = [ SELECT Id, Quantity__c, Quote_Line__c, Quote_Line__r.CPQ_Commitment_Quantity__c, Ship_to_Configuration__r.Quantity__c FROM Ship_To_Quantity_Override__c WHERE Quote_Line__c IN :quotesLinesToProcess.keySet()];
        
        // If there are no quantity overrides associated, return
        
        /*  Map<Id, List<Ship_To_Quantity_Override__c>> mapQuoteLineIdQtyOverrideList = new Map<Id, List<Ship_To_Quantity_Override__c>>();

// Create a Map with Quote Line Id -> List of Quantity Overrides
if(shipToQuantityOverrides != null && !shipToQuantityOverrides.isEmpty())
{
for (Ship_To_Quantity_Override__c qtyOverride : shipToQuantityOverrides) {
if (mapQuoteLineIdQtyOverrideList.containsKey(qtyOverride.Quote_Line__c)) {
mapQuoteLineIdQtyOverrideList.get(qtyOverride.Quote_Line__c).add(qtyOverride);
} else {
mapQuoteLineIdQtyOverrideList.put(qtyOverride.Quote_Line__c, new List<Ship_To_Quantity_Override__c>{ qtyOverride });
}
}
}



for (SBQQ__QuoteLine__c quoteLine : quotesLinesToProcess.values()) {
if (!mapQuoteLineIdQtyOverrideList.containsKey(quoteLine.Id)) {
continue;
}*/
        if(shipToQuantityOverrides != null && !shipToQuantityOverrides.isEmpty())
        {
            List<Ship_To_Quantity_Override__c> quanitityOverridesToUpdate = new List<Ship_To_Quantity_Override__c>();
            for (Ship_To_Quantity_Override__c qtyOverr : shipToQuantityOverrides)
            {
                qtyOverr.Quantity__c = qtyOverr.Quote_Line__r.CPQ_Commitment_Quantity__c * qtyOverr.Ship_to_Configuration__r.Quantity__c;
                quanitityOverridesToUpdate.add(qtyOverr);
            } 
            
            
            
            
            try {
                update quanitityOverridesToUpdate;
            } catch (Exception ex) {
                //System.debug(LoggingLevel.ERROR, 'ERROR: QuoteLineTriggerHandler > updateShipToOverrideForSpecificCommitment');
                //System.debug(LoggingLevel.ERROR, 'ERROR: ' + ex.getMessage());
                ErrorLogUtil.log(ex);
                ErrorLogUtil.commitLogs();
        }
    }
}    
    
    private void updateQTAnnualPurchaseComValue(Boolean isInsert) {
        List<SBQQ__QuoteLine__c> linesToUpdate = new List<SBQQ__QuoteLine__c>();
        
        for (SBQQ__QuoteLine__c line : this.triggerNew) {
            if(line.CPQ_Material_Type__c == CPQ_CONSTANT_Zoetis.STRING_AGGR_CMNT_SER)
            {
                // Boolean materialTypeCondition = line.CPQ_Material_Type__c == CPQ_CONSTANT_Zoetis.STRING_AGGR_CMNT_SER;
                Boolean recordChanged = !isInsert && 
                    ( this.triggerOldMap.get(line.Id).CPQ_Material_Type__c != line.CPQ_Material_Type__c || 
                     this.triggerOldMap.get(line.Id).CPQ_Commitment_Value__c != line.CPQ_Commitment_Value__c ||
                     this.triggerOldMap.get(line.Id).QT_Subscription_Term__c != line.QT_Subscription_Term__c ||
                     this.triggerOldMap.get(line.Id).Aggregate_Commitment_Type__c != line.Aggregate_Commitment_Type__c );
                
                if (isInsert || recordChanged) {
                    
                    double commitmentValue = line.CPQ_Commitment_Value__c != null ? line.CPQ_Commitment_Value__c : 0;
                    double subscriptionTerm = line.QT_Subscription_Term__c > 0 ? line.QT_Subscription_Term__c : 1;
                    /*double matPurchaseDollar = line.Aggregate_Commitment_Type__c == 'Rx' ?  quoteMap.get(line.SBQQ__Quote__c).MAT_Purchase_Dollars_Rx__c : 
(line.Aggregate_Commitment_Type__c == 'Dx' ?  quoteMap.get(line.SBQQ__Quote__c).MAT_Purchase_Dollars_Dx__c : 0);*/
                    
                    
                    double annualPurchaseValue = Math.round((commitmentValue / subscriptionTerm) * 12) + line.MAT_Purchase_Dollars__c ;
                    
                    if(annualPurchaseValue != line.QT_Annual_Purchase_Com_Value__c)
                    {
                        line.QT_Annual_Purchase_Com_Value__c = annualPurchaseValue;
                    }            
                }
            }
        }
        
    }
    
    private void updateQuoteRebateEligProduct (Boolean isInsert) {
        
        Map<Id, SBQQ__Quote__c> quotesToUpdateMap ;
        Set<Id> quoteIdsToUpdate = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLinesToProcess = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c quoteLine : this.triggerNew) {
            if(quoteLine.SBQQ__ProductFamily__c == CPQ_CONSTANT_Zoetis.STRING_PROGRAMS) {

                Boolean recordChanged = !isInsert && (
                    this.triggerOldMap.get(quoteLine.Id).Is_Rebate_Calculator_Enabled__c != quoteLine.Is_Rebate_Calculator_Enabled__c ||
                    this.triggerOldMap.get(quoteLine.Id).Template_logic__c != quoteLine.Template_logic__c
                );
                
                if (isInsert || recordChanged) {
                    quoteIdsToUpdate.add(quoteLine.SBQQ__Quote__c);
                    quoteLinesToProcess.add(quoteLine);
                }
            }
        }
        
        if (!quoteIdsToUpdate.isEmpty()) {
            quotesToUpdateMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, Product_Template_Logic__c, Rebate_Eligible_Product__c
                                                             FROM SBQQ__Quote__c
                                                             WHERE Id IN :quoteIdsToUpdate]);
            
            for (SBQQ__QuoteLine__c quoteLine : quoteLinesToProcess) 
            {
                SBQQ__Quote__c quoteToUpdate = quotesToUpdateMap.get(quoteLine.SBQQ__Quote__c);
                if (quoteToUpdate != null) {
                    if (!String.isBlank(quoteLine.Template_logic__c)) {
                        quoteToUpdate.Product_Template_Logic__c = quoteLine.Template_logic__c;
                    }
                    quoteToUpdate.Rebate_Eligible_Product__c = quoteLine.Is_Rebate_Calculator_Enabled__c;
                    if (quoteLine.Is_Rebate_Calculator_Enabled__c) {
                        break;
                    }
                }
            }
        }
        
        try {
            SBQQ.TriggerControl.disable();
            if( quotesToUpdateMap != null && !quotesToUpdateMap.isEmpty())
            {
                update quotesToUpdateMap.values();
            }           
            SBQQ.TriggerControl.enable();
        } catch (Exception ex) {
            ErrorLogUtil.log(ex);
            ErrorLogUtil.commitLogs();
        }
        
    }
    
    private void updateQuoteRebateEligProductDelete() {
        
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>() ;
        Set<Id> quoteIdsToUpdate = new Set<Id>();
        Boolean rebateEligible = true;
        
        for (SBQQ__QuoteLine__c quoteLine :  this.triggerOldMap.values()) {
 
            if (quoteLine.SBQQ__ProductFamily__c == CPQ_CONSTANT_Zoetis.STRING_PROGRAMS && (quoteLine.Is_Rebate_Calculator_Enabled__c || quoteLine.Template_logic__c != null)) {
                quoteIdsToUpdate.add(quoteLine.SBQQ__Quote__c);
                if(quoteLine.Is_Rebate_Calculator_Enabled__c && rebateEligible)
                {
                  rebateEligible = False;
                }
                
            }
        }
        
        if (!quoteIdsToUpdate.isEmpty()) 
        {
			for(ID quoteId : quoteIdsToUpdate)
            {
                quotesToUpdate.add(new SBQQ__Quote__c(Id = quoteId, Product_Template_Logic__c = null , Rebate_Eligible_Product__c = rebateEligible));
            }
        }
        
        try {
            SBQQ.TriggerControl.disable();
            if(!quotesToUpdate.isEmpty())
            {
                update quotesToUpdate;
            }           
            SBQQ.TriggerControl.enable();
        } catch (Exception ex) {
            ErrorLogUtil.log(ex);
            ErrorLogUtil.commitLogs();
        }
        
    }
}