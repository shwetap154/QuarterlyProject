/**
* File Name     :  
* @description  :  Helper class that takes gathered data in the auto-bundle process and inserts records to create the CPQ bundle
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/3/2019		Cory Bartholomew @ ATG     Created the Class.
* 1.1     1/XX/2020		Cory Bartholomew @ ATG	   Added Quote template display field logic.  Updated address validation logic to use helper class
* 2.0     2/6/2020		Cory Bartholomew @ ATG     Added descriptions.
* 3.0     02/13/2020    Ramiro Alvarez @ ATG     Add validation to prevent submiting for approval if quote is non primary CPQATG-687
* 4.0	    02/28/2020    Ramiro Alvarez @ ATG     CPQATG-747 Prevent user to submit for approval the quote if price is missing	
* 4.1     07/05/2020    Cesar Sandrigo @ ATG     Default ship to configuration on quote creation.
* 4.2     12/22/2020    Cesar Sandrigo @ ATG     CPQATG-1250: Keep the Distributor and Leasing Agent addresses up to date.
* 4.3     03/11/2020    Ramiro Alvarez @ ATG     Deprecate Distributor and Leasing Agent
* 4.4     08/16/2022    Mila Imas 				 MAT Amounts	
* 4.5	  06/09/2023    Rahul Kumar	@DEL		 Added Opportunity Field in preInstallCheckList Creation.
* 4.6     04/08/2023    Avish Jain	@DEL		 Refactored QuoteTriggerHandler Class
**/

public class QuoteTriggerHandler {
    //Boolean to avoid recursion
    @TestVisible
    private static boolean run = true;
    private static string acntid = '';
    
    /**
* @description Flag that indicates if 'Vistex Price in Sync' should be calculated or not.
*              This is useful for bypassing the trigger when doing changes in the quote related to Vistex price.
*/
    private static boolean disablePriceInSyncCalc = false;
    
    /**
* @description Flag that indicates if ship to configuration record should be updated or not
*              When update is performed from ship To page, needs to bypass this update function
*/
    private static boolean disableShipToConfUpd = false;
    
    // This can be moved into a Custom Setting if needed
    private static List<String> PRICING_DEPENDENT_FIELD_NAMES = new List<String>{
        'SBQQ__StartDate__c', // Quote Start Date (it's used as the pricing date)
            'CurrencyIsoCode', // Currency
            'Sales_Org__c', // Sales Org (all market-dependent values)
            'SAP_Account_ID__c', // Sold-to account
            'Bill_To_Address__c', // Bill-to account
            'Ship_To_Address__c', // Ship-to account
            'Payer_Address__c' // Payer account
            };
                
                public class EligibilityException extends Exception {
                }
    public class AddressException extends Exception {
    }
    
    private List<SBQQ__Quote__c> triggerNew;
    private Map<Id, SBQQ__Quote__c> triggerNewMap;
    
    /**
* @descripiton Map with the previous version of the objects. Provided by the trigger.
*/
    private Map<Id, SBQQ__Quote__c> triggerOldMap { get; set; }
    
    /**
* @description Constructor.
* @param triggerNew List of new version of the Quotes, provided by the trigger.
* @param triggerNewMap Map of the new version of the Quotes, provided by the trigger.
* @param triggerOldMap Map of the old version of the Quotes, provided by the trigger.
*/
    public QuoteTriggerHandler(
        List<SBQQ__Quote__c> triggerNew,
        Map<Id, SBQQ__Quote__c> triggerNewMap,
        Map<Id, SBQQ__Quote__c> triggerOldMap
    ) {
        this.triggerNew = triggerNew;
        this.triggerNewMap = triggerNewMap;
        this.triggerOldMap = triggerOldMap;
    }
    public class matAmounts {
        
        private decimal dxAmt { get; set; }
        private decimal rxAmt  { get; set; } 
        private date    salesDate {get;set;}
    }
    /**
* @description Disables the calculation of the 'Vistex Price in Sync' flag.
*/
    public static void disablePriceInSyncCalculation() {
        disablePriceInSyncCalc = true;
        //System.debug(LoggingLevel.WARN, '[Vistex Price in Sync] - Disabled');
    }
    
    /**
* @description Enables the calculation of the 'Vistex Price in Sync' flag.
*/
    public static void enablePriceInSyncCalculation() {
        disablePriceInSyncCalc = false;
        //System.debug(LoggingLevel.WARN, '[Vistex Price in Sync] - Enabled');
    }
    
    /**
* @description Returns 'true' when the 'Vistex Price in Sync' calculation is disabled.
*/
    public static Boolean isPriceInSyncCalculationDisabled() {
        return disablePriceInSyncCalc;
    }
    
    /**
* @description Disable updates on ShipTo configuration records when is updated from ShipTo page
*/
    public static void disableUpdatesOnShipTo() {
        disableShipToConfUpd = true;
        //System.debug(LoggingLevel.WARN, '[Ship To Configuration Upd] - Disabled');
    }
    
    /**
* @description Disable updates on ShipTo configuration records when is updated from ShipTo page
*/
    public static void enableUpdatesOnShipTo() {
        disableShipToConfUpd = false;
        //System.debug(LoggingLevel.WARN, '[Ship To Configuration Upd] - Enable');
    }
    
    public void beforeInsert() {
        //System.debug(LoggingLevel.WARN, 'SBQQ__Quote__c >> BeforeInsert');
        // getQuoteEligibility(this.triggerNew);
        validateAdressToAccountHierarchy(this.triggerNew);
        // CPQATG-1250: Set the Distributor and Leasing Agent Addresses
        //setDistributorAndLeasingAgentAddress(this.triggerNew);
        
        //System.debug('beforeInsert > Distributor Address:' + this.triggerNew[0].Distributor_Address__c);
    }
    
    public void afterInsert() {
        createDefaultShipToConfiguration(this.triggerNew);
        
        createDefaultPreInstallCheckList(this.triggerNew);
    }
    
    private static void createDefaultPreInstallCheckList(List<SBQQ__Quote__c> quotes) {
        List<PreInstallCheckList__c> preInstallCheckList = new List<PreInstallCheckList__c>();
        
        Set<Id> quotesIds = new Set<Id>();
        Set<String> markets = new Set<String> ();
        for (SBQQ__Quote__c quote : quotes) {
            quotesIds.add(quote.Id);
            markets.add(quote.Market__c);
        }
        
        //Only to create records based on new checkbox in the market
        List<Market__c> marketList = [SELECT Id, Name, Is_PreInstallCheckList_Enable__c FROM Market__c WHERE Name IN :markets];        
        
        Map<String,Boolean> marketPreInstallCheckListMap = new Map<String,Boolean>();
        for (Market__c market : marketList) {
            marketPreInstallCheckListMap.put(market.Name, market.Is_PreInstallCheckList_Enable__c);
        }
        
        for (SBQQ__Quote__c quote : quotes) {            
            if (marketPreInstallCheckListMap.containsKey(quote.Market__c) &&
                marketPreInstallCheckListMap.get(quote.Market__c)) {
                    
                    preInstallCheckList.add(
                        new PreInstallCheckList__c(
                            Quote__c = quote.Id,
                            Market__c = quote.Market__c,
                            Status__c = CPQ_CONSTANT_Zoetis.STRING_NOT_STARTED,
                            Clinic_Delivery_Question_9__c = CPQ_CONSTANT_Zoetis.STRING_NO,
                            VETSCAN_IMAGYST_Question_12__c = CPQ_CONSTANT_Zoetis.STRING_NO,
                            VETSCAN_VUE_Question_6__c = CPQ_CONSTANT_Zoetis.STRING_NO,
                            Opportunity__c = quote.SBQQ__Opportunity2__c,
                            Cloud_Internet_Question_3__c = quote.Market__c == 'South Africa' ? 'N/A' : 'Yes'   // added as a part of TPDEV 2418 by Rahul Deloitte
                        ));
                }
        }
        
        if (!preInstallCheckList.isEmpty()) {
            try
            {
                insert preInstallCheckList;
            }
            Catch(Exception ex)
            {
                ErrorLogUtil.log(ex);
                ErrorLogUtil.commitLogs();
            }
        }
        
    }
    
    public void beforeUpdate() {
        //System.debug('1. beforeUpdate > Distributor Address:' + this.triggerNew[0].Distributor_Address__c);
        if (run) {
            run = false;
            
            //System.debug(LoggingLevel.WARN, 'SBQQ__Quote__c >> BeforeUpdate');
            
            updateVistexPricingInSyncFlag();
            
            setQTRebateDisplayField();
            
            // CPQATG-1250: Set the Distributor and Leasing Agent Addresses
            //updateDistributorAndLeasingAgentAddress(this.triggerNew, this.triggerOldMap);
            
            //get only quotes that had an address change to validate addresses in the account hierarchy
            //MAT amounts
            boolean freeflex;
            List<SBQQ__Quote__c> quotesToProcess = new List<SBQQ__Quote__c>();
            List<SBQQ__QuoteLine__c> quotelines = [SELECT Id, SBQQ__Quote__c, Program_Eligibility_Filter__c,SBQQ__Number__c 
                                                   FROM SBQQ__QuoteLine__c
                                                   WHERE  SBQQ__Number__c = 1 and SBQQ__Quote__c = :triggerNew];
            if (quotelines.size() > 0) {
                freeflex = true;
            }
            
            Set<Id> accIdsSet = ApexUtils.pluckIdSet(triggerNew, 'SBQQ__Account__c');
            Map<Id, matAmounts> accIdToMatAmountsMap = setMATAmounts(accIdsSet);
			
            
            
            for (SBQQ__Quote__c quote : triggerNew) {
                
                if (freeflex == true){
                    matAmounts amounts= accIdToMatAmountsMap.get(quote.SBQQ__Account__c);
                    if(amounts != null){
                        quote.MAT_Purchase_Dollars_Dx__c = amounts.dxAmt;
                        quote.MAT_Purchase_Dollars_Rx__c = amounts.rxAmt;
                        quote.MAT_AMT_Date__c = amounts.salesDate;
                    }
                } else {
                    quote.MAT_Purchase_Dollars_Dx__c = 0.00;
                    quote.MAT_Purchase_Dollars_Rx__c = 0.00;
                    quote.MAT_AMT_Date__c = null;
                }
                if (quote.Expiration_Date__c ==  null){
                    quote.Expiration_Date__c = quote.SBQQ__ExpirationDate__c;
                }
                //System.debug('SBQQ__Quote__c >> BeforeUpdate before saving quote test' + quote);
                //System.debug ('value  triggerOldMap' + triggerOldMap);
                if (triggerOldMap.containsKey(quote.Id)) {
                    SBQQ__Quote__c oldQuote = triggerOldMap.get(quote.Id);
                    if (
                        quote.Bill_To_Address__c != oldQuote.Bill_To_Address__c ||
                        quote.Ship_To_Address__c != oldQuote.Ship_To_Address__c ||
                        quote.Payer_Address__c != oldQuote.Payer_Address__c     ||
                        quote.MAT_AMT_Date__c  != oldQuote.MAT_AMT_Date__c
                    ) {
                        quotesToProcess.add(quote);
                    }
                }
            }
            if (quotesToProcess.size() > 0) {
                validateAdressToAccountHierarchy(quotesToProcess);
            }
            //CPQATG-687
            validatePrimaryQuote();
            //CPQATG-747
            validatePriceBookEntry();
        }
    }
    
    public void afterUpdate() {
        // Update default ship-to configuration
        updateDefaultShipToConfiguration(this.triggerNew, this.triggerOldMap);
        
        // Update Pre-Install Checklist Relevant fields
        setRelevantFlagOnPreInstallCheckList(this.triggerNew);
        
    }
    
    /**
* @description CPQATG-1288 Set relevant checkbox fields for elegibility on Pre-Install checklist page
*/
    
    public void setRelevantFlagOnPreInstallCheckList (List<SBQQ__Quote__c> quotes) {
        
        Set<Id> quoteIds = new Set<Id> ();
        Set<String> markets = new Set<String>();
        for (SBQQ__Quote__c quote : quotes) {
            markets.add(quote.Market__c);
        }        
        
        //Only to create records based on new checkbox in the market
        List<Market__c> marketList = [SELECT Id, Name, Is_PreInstallCheckList_Enable__c
                                      FROM Market__c
                                      WHERE Name IN :markets];        
        
        Map<String,Boolean> marketPreInstallCheckListMap = new Map<String,Boolean>();
        for (Market__c market : marketList) {
            marketPreInstallCheckListMap.put(market.Name, market.Is_PreInstallCheckList_Enable__c);
        }        
        
        // Only process if Line count > 0
        for (SBQQ__Quote__c quote : quotes) {
            //System.debug('setRelevantFlagOnPreInstallCheckList, quote Is_Ordered: ' + quote.Is_Ordered__c);
            if ( quote.SBQQ__LineItemCount__c > 0
                && !quote.Is_Ordered__c
                && marketPreInstallCheckListMap.containsKey(quote.Market__c)
                && marketPreInstallCheckListMap.get(quote.Market__c)) {
                    quoteIds.add(quote.Id);
                }
        }
        if (quoteIds.isEmpty()) {            
            // if no lines, return
            //System.debug('setRelevantFlagOnPreInstallCheckList, no lines, return');
            return;
        }
        
        // Get SAP Product Numbers from custom setting
        CPQ_PreInstall_Checklist__c param = CPQ_PreInstall_Checklist__c.getInstance();
        
        // Clinic Electrical - SAP Materials
        List<String> clinicElecticList = param.Clinic_Electrical_SAP_Materials__c != null ? param.Clinic_Electrical_SAP_Materials__c.split(',') : new List<String> ();
        
        // Clinic Communication - SAP Materials
        List<String> clinicCommunicationList = param.Clinic_Communication_SAP_Materials__c != null ? param.Clinic_Communication_SAP_Materials__c.split(',') : new List<String> ();
        
        // Clinic Delivery - SAP Materials
        List<String> clinicDeliveryList = param.Clinic_Delivery_SAP_Materials__c != null ? param.Clinic_Delivery_SAP_Materials__c.split(',') : new List<String> ();
        
        //Cloud Internet - SAP Materials
        List<String> cloudInternetList = param.Cloud_Internet_SAP_Materials__c != null ? param.Cloud_Internet_SAP_Materials__c.split(',') : new List<String> ();
        
        //iSTAT - SAP Materials
        List<String> iStatList = param.iSTAT_Alinity_SAP_Materials__c != null ? param.iSTAT_Alinity_SAP_Materials__c.split(',') : new List<String> ();
        
        //VETSCAN FUSE - SAP Materials
        List<String> vetscanFuseList = param.VETSCAN_FUSE_SAP_Materials__c != null ? param.VETSCAN_FUSE_SAP_Materials__c.split(',') : new List<String> ();
        
        //VETSCAN HM5 - SAP Materials
        List<String> vetscanHm5List = param.VETSCAN_HM5_SAP_Materials__c != null ? param.VETSCAN_HM5_SAP_Materials__c.split(',') : new List<String> ();
        
        //VETSCAN IMAGYST - SAP Materials
        List<String> vetscanImagystList = param.VETSCAN_IMAGYST_SAP_Materials__c != null ? param.VETSCAN_IMAGYST_SAP_Materials__c.split(',') : new List<String> ();
        
        //VETSCAN SA - SAP Materials
        List<String> vetscanSAList = param.VETSCAN_SA_SAP_Materials__c != null ? param.VETSCAN_SA_SAP_Materials__c.split(',') : new List<String> ();
        
        //VETSCAN VS2 - SAP Materials
        List<String> vetscanVS2List = param.VETSCAN_VS2_SAP_Materials__c != null ? param.VETSCAN_VS2_SAP_Materials__c.split(',') : new List<String> ();
        
        //VETSCAN VS Pro - SAP Materials
        List<String> vetscanVSProList = param.VETSCAN_Vspro_SAP_Materials__c != null ? param.VETSCAN_Vspro_SAP_Materials__c.split(',') : new List<String> ();
        
        //VETSCAN VUE - SAP Materials
        List<String> vetscanVUEList = param.VETSCAN_VUE_SAP_Materials__c != null ? param.VETSCAN_VUE_SAP_Materials__c.split(',') : new List<String> ();
        
        
        // Query quote lines to check SAP Materials on quote
        List<SBQQ__QuoteLine__c> quotelines = [SELECT Id, SBQQ__Quote__c, SAP_Product_Number__c
                                               FROM SBQQ__QuoteLine__c
                                               WHERE SBQQ__Quote__c IN :quoteIds
                                               AND SAP_Product_Number__c != NULL];
        
        Map<Id,List<String>> quoteSAPproductsMap = new Map<Id,List<String>> ();
        for (SBQQ__QuoteLine__c quoteline : quotelines) {
            if (!quoteSAPproductsMap.containsKey(quoteline.SBQQ__Quote__c)){
                quoteSAPproductsMap.put(quoteline.SBQQ__Quote__c, new List<String> ());
            }
            quoteSAPproductsMap.get(quoteline.SBQQ__Quote__c).add(quoteline.SAP_Product_Number__c);
        }
        
        Set<Id> quoteClinicElectricalSet = new Set<Id> ();
        Set<Id> quoteClinicCommunicationSet = new Set<Id> ();
        Set<Id> quoteClinicDeliverySet = new Set<Id> ();
        Set<Id> quoteCloudInternetSet = new Set<Id> ();        
        Set<Id> quoteiSTATSet = new Set<Id> ();
        Set<Id> quoteVETSCANHM5Set = new Set<Id> ();
        Set<Id> quoteVETSCANFUSESet = new Set<Id> ();
        Set<Id> quoteVETSCANIMAGYSTSet = new Set<Id> ();
        Set<Id> quoteVETSCANSASet = new Set<Id> ();
        Set<Id> quoteVETSCANVS2Set = new Set<Id> ();
        Set<Id> quoteVETSCANVsproSet = new Set<Id> ();
        Set<Id> quoteVETSCANVUESet = new Set<Id> ();        
        
        //Loop the map and push quote Ids to proper Set
        for (Id quoteId : quoteSAPproductsMap.keySet()) {
            
            for (String sapProduct : quoteSAPproductsMap.get(quoteId)) {
                
                if (clinicElecticList.contains(sapProduct)) {
                    quoteClinicElectricalSet.add(quoteId);
                }
                if (clinicCommunicationList.contains(sapProduct)) {
                    quoteClinicCommunicationSet.add(quoteId);
                }
                if (clinicDeliveryList.contains(sapProduct)) {
                    quoteClinicDeliverySet.add(quoteId);
                }
                if (cloudInternetList.contains(sapProduct)) {
                    quoteCloudInternetSet.add(quoteId);
                }
                if (iStatList.contains(sapProduct)) {
                    quoteiSTATSet.add(quoteId);
                }
                if (vetscanFuseList.contains(sapProduct)) {
                    quoteVETSCANFUSESet.add(quoteId);
                }
                if (vetscanHm5List.contains(sapProduct)) {
                    quoteVETSCANHM5Set.add(quoteId);
                }
                if (vetscanImagystList.contains(sapProduct)) {
                    quoteVETSCANIMAGYSTSet.add(quoteId);
                }
                if (vetscanSAList.contains(sapProduct)) {
                    quoteVETSCANSASet.add(quoteId);
                }
                if (vetscanVS2List.contains(sapProduct)) {
                    quoteVETSCANVS2Set.add(quoteId);
                }
                if (vetscanVSProList.contains(sapProduct)) {
                    quoteVETSCANVsproSet.add(quoteId);
                }
                if (vetscanVUEList.contains(sapProduct)) {
                    quoteVETSCANVUESet.add(quoteId);
                }
            }
        }
        
        // Query existing records on Pre-Install checklist
        List<PreInstallCheckList__c> preInstallList = [SELECT Id, Quote__c
                                                       FROM PreInstallCheckList__c
                                                       WHERE Quote__c IN :quoteSAPproductsMap.keySet()];
        
        List<PreInstallCheckList__c> preInstallListToUpd = new List<PreInstallCheckList__c> ();
        
        for (PreInstallCheckList__c preInstallChkQuote : preInstallList) {
            
            Boolean quoteClinicElectricalRelevant = false;
            Boolean quoteClinicCommunicationRelevant = false;
            Boolean quoteClinicDeliveryRelevant = false;
            Boolean quoteCloudInternetRelevant = false;        
            Boolean quoteiSTATRelevant = false;
            Boolean quoteVETSCANHM5Relevant = false;
            Boolean quoteVETSCANFUSERelevant = false;
            Boolean quoteVETSCANIMAGYSTRelevant = false;
            Boolean quoteVETSCANSARelevant = false;
            Boolean quoteVETSCANVS2Relevant = false;
            Boolean quoteVETSCANVsproRelevant = false;
            Boolean quoteVETSCANVUERelevant = false;
            
            if (quoteClinicElectricalSet.contains(preInstallChkQuote.Quote__c)) {
                quoteClinicElectricalRelevant = true;
            }
            if (quoteClinicCommunicationSet.contains(preInstallChkQuote.Quote__c)) {
                quoteClinicCommunicationRelevant = true;
            }
            if (quoteClinicDeliverySet.contains(preInstallChkQuote.Quote__c)) {
                quoteClinicDeliveryRelevant = true;
            }
            if (quoteCloudInternetSet.contains(preInstallChkQuote.Quote__c)) {
                quoteCloudInternetRelevant = true;
            }
            if (quoteiSTATSet.contains(preInstallChkQuote.Quote__c)) {
                quoteiSTATRelevant = true;
            }
            if (quoteVETSCANFUSESet.contains(preInstallChkQuote.Quote__c)) {
                quoteVETSCANFUSERelevant = true;
            }
            if (quoteVETSCANHM5Set.contains(preInstallChkQuote.Quote__c)) {
                quoteVETSCANHM5Relevant = true;
            }
            if (quoteVETSCANIMAGYSTSet.contains(preInstallChkQuote.Quote__c)) {
                quoteVETSCANIMAGYSTRelevant = true;
            }
            if (quoteVETSCANSASet.contains(preInstallChkQuote.Quote__c)) {
                quoteVETSCANSARelevant = true;
            }
            if (quoteVETSCANVS2Set.contains(preInstallChkQuote.Quote__c)) {
                quoteVETSCANVS2Relevant = true;
            }
            if (quoteVETSCANVsproSet.contains(preInstallChkQuote.Quote__c)) {
                quoteVETSCANVsproRelevant = true;
            }
            if (quoteVETSCANVUESet.contains(preInstallChkQuote.Quote__c)) {
                quoteVETSCANVUERelevant = true;
            }
            
            if (quoteClinicElectricalRelevant || quoteClinicCommunicationRelevant || quoteClinicDeliveryRelevant ||
                quoteCloudInternetRelevant || quoteiSTATRelevant || quoteVETSCANHM5Relevant || quoteVETSCANFUSERelevant ||
                quoteVETSCANIMAGYSTRelevant || quoteVETSCANSARelevant || quoteVETSCANVS2Relevant || quoteVETSCANVsproRelevant ||
                quoteVETSCANVUERelevant) {
                    
                    preInstallListToUpd.add(new PreInstallCheckList__c (Id = preInstallChkQuote.Id,
                                                                        Is_Clinic_Electical_Relevant_for_Quote__c = quoteClinicElectricalRelevant,    
                                                                        Is_Clinic_Communic_Relevant_for_Quote__c =  quoteClinicCommunicationRelevant,
                                                                        Is_Clinic_Delivery_Relevant_for_Quote__c = quoteClinicDeliveryRelevant,
                                                                        Is_Cloud_Internet_Relevant_for_Quote__c = quoteCloudInternetRelevant,
                                                                        Is_iSTAT_Alinity_Relevant_for_Quote__c =  quoteiSTATRelevant,
                                                                        Is_Is_VETSCAN_HM5_Relevant_for_Quote__c = quoteVETSCANHM5Relevant,
                                                                        Is_VETSCAN_FUSE_Relevant_for_Quote__c = quoteVETSCANFUSERelevant,
                                                                        Is_VETSCAN_IMAGYST_Relevant_for_Quote__c = quoteVETSCANIMAGYSTRelevant,
                                                                        Is_VETSCAN_SA_Relevant_for_Quote__c = quoteVETSCANSARelevant,
                                                                        Is_VETSCAN_VS2_Relevant_for_Quote__c = quoteVETSCANVS2Relevant,
                                                                        Is_VETSCAN_Vspro_Relevant_for_Quote__c = quoteVETSCANVsproRelevant,
                                                                        Is_VETSCAN_VUE_Relevant_for_Quote__c= quoteVETSCANVUERelevant));
                }
        }
        
        // update preInstallCheckList records with to set relevant flags
        //System.debug('setRelevantFlagOnPreInstallCheckList, preInstallListToUpd: ' + preInstallListToUpd);
        if(!preInstallListToUpd.isEmpty()) {
            try{
                update preInstallListToUpd; 
            }
            Catch(Exception ex)
            {
                ErrorLogUtil.log(ex);
                ErrorLogUtil.commitLogs(); 
            }
            
        }
    }
    
    /**
* @description CPQATG-687 Prevent sending a document to a customer for a non-primary quote
*/
    public void validatePrimaryQuote() {
        for (SBQQ__Quote__c newQuote : triggerNewMap.values()) {
            SBQQ__Quote__c oldQuote = triggerOldMap.get(newQuote.Id);
            if (oldQuote.ApprovalStatus__c != 'Approved' && newQuote.ApprovalStatus__c == 'Approved') {
                if (!newQuote.SBQQ__Primary__c) {
                    newQuote.addError(CPQ_CONSTANT_Zoetis.STRING_PRIMARY_QUOTE_APPROVAL_ERROR);
                }
            }
            if (oldQuote.ApprovalStatus__c != 'Pending' && newQuote.ApprovalStatus__c == 'Pending') {
                if (!newQuote.SBQQ__Primary__c) {
                    newQuote.addError(CPQ_CONSTANT_Zoetis.STRING_PRIMARY_QUOTE_APPROVAL_ERROR);
                }
            }
        }
    }
    
    /**
* @description CPQATG-747 Prevent user to submit for approval the quote if price is missing
*/
    public void validatePriceBookEntry() {
        //System.debug('Entering validatePriceBookEntry...');
        
        Boolean validPricebook = true;
        
        Set<Id> quoteIds = new Set<Id>();
        
        for (SBQQ__Quote__c quote : triggerNewMap.values()) {
            quoteIds.add(quote.Id);
        }
        
        List<SBQQ__QuoteLine__c> quotelines = [
            SELECT
            Id,
            SBQQ__Product__c,
            SBQQ__Quote__c,
            SBQQ__Quote__r.CurrencyIsoCode,
            SBQQ__Quote__r.SBQQ__PriceBook__c,
            Vistex_Automatic_Add_on__c,
            Vistex_Manual_Add_on__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c IN :quoteIds
        ];
        
        Set<Id> productIds = new Set<Id>();
        for (SBQQ__QuoteLine__c quoteline : quotelines) {
            productIds.add(quoteline.SBQQ__Product__c);
        }
        
        List<PricebookEntry> pricebookEntrys = [
            SELECT Id, Pricebook2Id, Product2Id, CurrencyIsoCode
            FROM PricebookEntry
            WHERE Product2Id IN :productIds
        ];
        
        for (SBQQ__Quote__c newQuote : triggerNewMap.values()) {
            SBQQ__Quote__c oldQuote = triggerOldMap.get(newQuote.Id);
            
            if (
                oldQuote.ApprovalStatus__c != 'Approved' &&
                (newQuote.ApprovalStatus__c == 'Approved' ||
                 newQuote.ApprovalStatus__c == 'Pending')
            ) {
                ////System.debug('Validation on PricebookEntry, is now Approved: ' + newQuote.ApprovalStatus__c);
                
                for (SBQQ__QuoteLine__c quoteline : quotelines) {
                    ////System.debug('Validation on PricebookEntry, enetering for loop for quotelines: ' + quoteline);
                    if (
                        quoteline.SBQQ__Quote__c == newQuote.Id &&
                        (quoteline.Vistex_Automatic_Add_on__c || quoteline.Vistex_Manual_Add_on__c)
                    ) {
                        validPricebook = false;
                        for (PricebookEntry pricebookEntry : pricebookEntrys) {
                            if (
                                quoteline.SBQQ__Product__c == pricebookEntry.Product2Id &&
                                quoteline.SBQQ__Quote__r.CurrencyIsoCode == pricebookEntry.CurrencyIsoCode &&
                                quoteline.SBQQ__Quote__r.SBQQ__PriceBook__c == pricebookEntry.Pricebook2Id
                            ) {
                                validPricebook = true;
                                break;
                            }
                        }
                        ////System.debug('Validation on PricebookEntry: ' + validPricebook);
                        if (!validPricebook) {
                            newQuote.addError(CPQ_CONSTANT_Zoetis.STRING_PRICEBOOK_ERROR);
                        }
                    }
                    
                }
            }
        }
        //System.debug('Exit validatePriceBookEntry...');
    }
    
    /**
* @description Updates the 'Vistex Pricing in Sync' flag if some of the pricing-dependent fields in the Quote changed.
*/
    public void updateVistexPricingInSyncFlag() {
        if (disablePriceInSyncCalc) {
            //System.debug(LoggingLevel.WARN, '[Vistex Price in Sync] - Is disabled');
            return;
        }
        
        // Get the list of SObject fields from the names in the constant value
        List<Schema.SObjectField> pricingDependentQuoteFields = ApexUtils.getSobjectFieldsByName(
            'SBQQ__Quote__c',
            PRICING_DEPENDENT_FIELD_NAMES
        );
        
        // Find the records that were changed
        List<SBQQ__Quote__c> changedQuotes = ApexUtils.findChangedRecs(triggerNew, triggerOldMap, pricingDependentQuoteFields);
        
        for (SBQQ__Quote__c quote : changedQuotes) {
            // If the Vistex Price was synced, it's not anymore
            if (quote.Vistex_Price_In_Sync__c) {
                //System.debug(LoggingLevel.WARN, '[Vistex Price in Sync] - FALSE: ' + quote.Id);
                quote.Vistex_Price_In_Sync__c = false;
            }
        }
    }
    //map quote tempalte visibility fields
    public void setQTRebateDisplayField() {
        for (SBQQ__Quote__c quote : triggerNew) {
            if (
                quote.QT_Display_Promo__c == false &&
                quote.QT_Display_Termination_Clause__c == false &&
                quote.QT_Display_Program_Prerequisite__c == false &&
                quote.QT_Display_ZPRQ_field__c == false &&
                String.isBlank(quote.Rebate_Commitment__c)
            ) {
                quote.QT_Rebate_Commitment_Display_Logic__c = false;
            }
            if (!String.isBlank(quote.Rebate_Commitment__c)) {
                quote.QT_Rebate_Commitment_Display_Logic__c = true;
            }
        }
    }
    
    public void validateAdressToAccountHierarchy(List<SBQQ__Quote__c> quotes) {
        
        //set of account ids On quote
        Set<Id> shipToAddrIdsSet = ApexUtils.pluckIdSet(quotes, 'Ship_To_Address__c');
        // Map of id to addresses upto 5 level of Account Heirarchy
        Map<Id, Address__c> idToAddrsMap = new Map<Id, Address__c>([SELECT Id, Name, ZTS_EU_Account__r.Id, ZTS_EU_Account__r.Parent.Id, ZTS_EU_Account__r.Parent.Parent.Id, ZTS_EU_Account__r.Parent.Parent.Parent.Id, ZTS_EU_Account__r.Parent.Parent.Parent.Parent.Id FROM Address__c WHERE Id IN :shipToAddrIdsSet]);
        
        // check if ship to address on quote is related to direct Account or any account which is in Heirarchy
        for (SBQQ__Quote__c quote : quotes) {
            if(quote.Ship_To_Address__c != null && idToAddrsMap != null && 
               quote.SBQQ__Account__c != idToAddrsMap.get(quote.Ship_To_Address__c).ZTS_EU_Account__r.Id &&
               quote.SBQQ__Account__c != idToAddrsMap.get(quote.Ship_To_Address__c).ZTS_EU_Account__r.Parent.Id && 
               quote.SBQQ__Account__c != idToAddrsMap.get(quote.Ship_To_Address__c).ZTS_EU_Account__r.Parent.Parent.Id && 
               quote.SBQQ__Account__c != idToAddrsMap.get(quote.Ship_To_Address__c).ZTS_EU_Account__r.Parent.Parent.Parent.Id && 
               quote.SBQQ__Account__c != idToAddrsMap.get(quote.Ship_To_Address__c).ZTS_EU_Account__r.Parent.Parent.Parent.Parent.Id ){
                   
                   // add error on quote if address is not n account heirarchy
                   quote.addError(CPQ_CONSTANT_Zoetis.STRING_ADDRESS_ACC_ERROR);
                   
               }
        }
        
        
    }
    
    /**
*
*/
    private static void createDefaultShipToConfiguration(List<SBQQ__Quote__c> quotes) {
        List<Ship_to_Configuration__c> shipToConfigToInsert = new List<Ship_to_Configuration__c>();
        
        Set<Id> quotesIds = new Set<Id>();
        for (SBQQ__Quote__c quote : quotes) {
            quotesIds.add(quote.Id);
        }
        
        // Query for existing default Ship To confirguration
        List<Ship_to_Configuration__c> existingShipTo = [
            SELECT Id, Quote__c, Ship_to_Address__c
            FROM Ship_to_Configuration__c
            WHERE Quote__c IN :quotesIds AND Default_Ship_To_Location__c = TRUE
        ];
        
        Map<Id, Ship_to_Configuration__c> quoteExistingShipToMap = new Map<Id, Ship_to_Configuration__c>();
        for (Ship_to_Configuration__c shipTo : existingShipTo) {
            quoteExistingShipToMap.put(shipTo.Quote__c, shipTo);
        }
        
        for (SBQQ__Quote__c quote : quotes) {
            // If default ShipTo already exist - do nothing
            if (!quoteExistingShipToMap.containsKey(quote.Id)) {
                Id addrressId = quote.Ship_To_Address__c != null ? quote.Ship_To_Address__c : quote.Address__c;
                
                if (addrressId == null) {
                    continue;
                }
                
                shipToConfigToInsert.add(
                    new Ship_to_Configuration__c(
                        Quote__c = quote.Id,
                        Ship_to_Address__c = addrressId,
                        Default_Ship_To_Location__c = true,
                        Quantity__c = 1
                    )
                );
            }
        }
        
        if (!shipToConfigToInsert.isEmpty()) {
            insert shipToConfigToInsert;
        }
    }
    
    private static void updateDefaultShipToConfiguration(List<SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> oldQuotesMap) {
        if (disableShipToConfUpd) {
            //System.debug(LoggingLevel.WARN, '[Update Default Ship To Conf] - Is disabled, return');
            return;
        }
        
        //System.debug('updateDefaultShipToConfiguration...');
        
        List<Ship_to_Configuration__c> shipToConfigToInsert = new List<Ship_to_Configuration__c>();
        List<Ship_to_Configuration__c> shipToConfigToUpdate = new List<Ship_to_Configuration__c>();
        
        Map<Id, SBQQ__Quote__c> quoteToBeProc = new Map<Id, SBQQ__Quote__c>();
        
        for (SBQQ__Quote__c quote : quotes) {
            if (quote.Ship_To_Address__c != oldQuotesMap.get(quote.Id).Ship_To_Address__c) {
                quoteToBeProc.put(quote.Id, quote);
            }
        }
        
        if (quoteToBeProc.isEmpty()) {
            //System.debug('updateDefaultShipToConfiguration, no changes on Ship_To_Address__c - return');
            return;
        }
        // Query for existing default Ship To confirguration
        List<Ship_to_Configuration__c> existingShipTo = [
            SELECT Id, Quote__c, Ship_to_Address__c
            FROM Ship_to_Configuration__c
            WHERE Quote__c IN :quoteToBeProc.keySet() AND Default_Ship_To_Location__c = TRUE
        ];
        
        Map<Id, Ship_to_Configuration__c> quoteExistingShipToMap = new Map<Id, Ship_to_Configuration__c>();
        for (Ship_to_Configuration__c shipTo : existingShipTo) {
            quoteExistingShipToMap.put(shipTo.Quote__c, shipTo);
        }
        
        for (SBQQ__Quote__c quote : quoteToBeProc.values()) {
            if (quote.Ship_To_Address__c == null) {
                continue;
            }
            // If default ShipTo already exist - do nothing
            if (!quoteExistingShipToMap.containsKey(quote.Id)) {
                Ship_to_Configuration__c newShipTo = new Ship_to_Configuration__c(
                    Quote__c = quote.Id,
                    Ship_to_Address__c = quote.Ship_To_Address__c,
                    Default_Ship_To_Location__c = true,
                    Quantity__c = 1
                );
                shipToConfigToInsert.add(newShipTo);
                quoteExistingShipToMap.put(quote.Id, newShipTo);
            } else {
                // If Ship To already exists - update current Ship To record
                shipToConfigToUpdate.add(
                    new Ship_to_Configuration__c(
                        Id = quoteExistingShipToMap.get(quote.Id).Id,
                        Ship_to_Address__c = quote.Ship_To_Address__c
                    )
                );
            }
        }
        
        if (!shipToConfigToInsert.isEmpty()) {
            //System.debug('updateDefaultShipToConfiguration, insert: ' + shipToConfigToInsert);
            insert shipToConfigToInsert;
        }
        if (!shipToConfigToUpdate.isEmpty()) {
            //System.debug('updateDefaultShipToConfiguration, update: ' + shipToConfigToUpdate);
            update shipToConfigToUpdate;
        }
    }
    private static Map<Id, matAmounts> setMATAmounts(Set<Id> accIdsSet) {
        //System.debug('setMATAmounts > setMATAmounts for accountId ==> '+ accountID);
        
        /*List<CPQ_Sales_MAT_Amount__c > salesLines = new List<CPQ_Sales_MAT_Amount__c >();
        salesLines = [
            SELECT Id, Account_Id__c,Product_Grouping_Type__c,Sales_By_Date__c,source_account_number__c, Total_MAT_Current_Sales__c
            FROM CPQ_Sales_MAT_Amount__c where 
            Account_Id__c = :accountID
        ];*/
        /*for (CPQ_Sales_MAT_Amount__c salesRec : salesLines) {
            matAmounts amounts = new matAmounts();
            if (salesRec.Product_Grouping_Type__c=='Dx' && salesRec.Total_MAT_Current_Sales__c > 0)
            {
                amounts.dxAmt  = salesRec.Total_MAT_Current_Sales__c;
                
            }
            if (salesRec.Product_Grouping_Type__c=='Rx' && salesRec.Total_MAT_Current_Sales__c > 0)
            {
                amounts.rxAmt =salesRec.Total_MAT_Current_Sales__c;
            }
            amounts.salesDate = salesRec.Sales_By_Date__c;
            //System.debug('accountId == '+accountId + '  salesRecord  ==> '+salesRec);    
        }*/
        Map<Id, matAmounts> accIdToMatAmountsMap = new Map<Id, matAmounts>();
        for (CPQ_Sales_MAT_Amount__c salesRec : [SELECT Id, Account_Id__c,Product_Grouping_Type__c,Sales_By_Date__c,source_account_number__c, Total_MAT_Current_Sales__c
                FROM CPQ_Sales_MAT_Amount__c WHERE Account_Id__c = :accIdsSet]) {
                    
                    matAmounts amount = new matAmounts();
                    if(accIdToMatAmountsMap != null && accIdToMatAmountsMap.containsKey(salesRec.Account_Id__c)){
                        amount = accIdToMatAmountsMap.get(salesRec.Account_Id__c);
                    }
                    
                    if (salesRec.Product_Grouping_Type__c=='Dx' && salesRec.Total_MAT_Current_Sales__c > 0){
                        amount.dxAmt  = salesRec.Total_MAT_Current_Sales__c;
                    }
                    if (salesRec.Product_Grouping_Type__c=='Rx' && salesRec.Total_MAT_Current_Sales__c > 0){
                        amount.rxAmt =salesRec.Total_MAT_Current_Sales__c;
                    }
                    amount.salesDate = salesRec.Sales_By_Date__c;
                    
                    accIdToMatAmountsMap.put(salesRec.Account_Id__c, amount);
                    
                    
                    
                    
                //System.debug('accountId == '+accountId + '  salesRecord  ==> '+salesRec);    
            }
        //System.debug(' amount return ==> '+amounts);
        
        return accIdToMatAmountsMap;
    }
    
    //CPQATG-1299 Deprecate Set Distributor and Leasing Agent
    
    /**
* CPQATG-1250: Sets the Distributor and Leasing Agent Addresses based
* on the Distributor and Leasing Agent record associated to the Quote when the quote is being created.
* Distributor and Leasing Agent addresses are needed for downstream SAP Contract integration.
* @param triggerNew List of new version of the Quotes, provided by the trigger.
*/
    /*private void setDistributorAndLeasingAgentAddress(List<SBQQ__Quote__c> triggerNew) {
//System.debug('QuoteTriggerHandler > setDistributorAndLeasingAgentAddress');

// Sets to store the Distributor and Leasing Agents Ids to be queried
Set<Id> distributorIds = new Set<Id>();
Set<Id> leasingAgentIds = new Set<Id>();

// Collect all the Distributor and Leasing agents IDs that needs to be queried
for (SBQQ__Quote__c quote : triggerNew) {
if (quote.Distributor_Add__c != null) {
distributorIds.add(quote.Distributor_Add__c);
}
if (quote.Leasing_Agent_Add__c != null) {
leasingAgentIds.add(quote.Leasing_Agent_Add__c);
}
}

// If there are no Distributors or Leasing Agents to query, there is nothing else to do here.
if (distributorIds.isEmpty() && leasingAgentIds.isEmpty()) {
return;
}

Map<Id, Distributor__c> distributorsMap;
Map<Id, Leasing_Agent__c> leasingAgentsMap;

// If there are Distributors to query, create a map with the result for using it later
if (!distributorIds.isEmpty()) {
distributorsMap = new Map<Id, Distributor__c>([SELECT Id, Address__c FROM Distributor__c WHERE Id IN :distributorIds]);
} else {
distributorsMap = new Map<Id, Distributor__c>();
}

// If there are Leasing Agents to query, create a map with the result for using it later
if (!leasingAgentIds.isEmpty()) {
leasingAgentsMap = new Map<Id, Leasing_Agent__c>([SELECT Id, Address__c FROM Leasing_Agent__c WHERE Id IN :leasingAgentIds]);
} else {
leasingAgentsMap = new Map<Id, Leasing_Agent__c>();
}

// Set the Distributors and Leasing Agent Addressess based on the Maps built below
for (SBQQ__Quote__c quote : triggerNew) {
if (quote.Distributor_Add__c != null && distributorsMap.containsKey(quote.Distributor_Add__c)) {
//System.debug('Setting Distributor Address to:' + distributorsMap.get(quote.Distributor_Add__c).Address__c);
quote.Distributor_Address__c = distributorsMap.get(quote.Distributor_Add__c).Address__c;
}

if (quote.Leasing_Agent_Add__c != null && leasingAgentsMap.containsKey(quote.Leasing_Agent_Add__c)) {
quote.Leasing_Agent_Address__c = leasingAgentsMap.get(quote.Leasing_Agent_Add__c).Address__c;
}
}
}*/
    
    /**
* CPQATG-1250: Updates the Distributor and Leasing Agent Addresses based
* on the Distributor and Leasing Agent record associated to the Quote.
* Distributor and Leasing Agent addresses are needed for downstream SAP Contract integration.
* @param triggerNew List of new version of the Quotes, provided by the trigger.
* @param triggerOldMap Map of the old version of the Quotes, provided by the trigger. This is going to be null on Quote creation.
*/
    /* private void updateDistributorAndLeasingAgentAddress(List<SBQQ__Quote__c> triggerNew, Map<Id, SBQQ__Quote__c> triggerOldMap) {
// Set to store the Quotes to be updated
Set<Id> quotesIdToUpdateDistAddress = new Set<Id>();
Set<Id> quotesIdToUpdateLeasAgtAddress = new Set<Id>();

// Sets to store the Distributor and Leasing Agents Ids to be queried
Set<Id> distributorIds = new Set<Id>();
Set<Id> leasingAgentIds = new Set<Id>();

for (SBQQ__Quote__c quote : triggerNew) {
// If the Distributor changed from the previous version of the quote
if (quote.Distributor_Add__c != triggerOldMap.get(quote.Id).Distributor_Add__c) {
// If it was set to null, set the distributor addess also to null
if (quote.Distributor_Add__c == null) {
quote.Distributor_Address__c = null;
} else {
// If it was set to another Distributor, add the quote and the distibutor Ids to the sets.
distributorIds.add(quote.Distributor_Add__c);
quotesIdToUpdateDistAddress.add(quote.Id);
}
}

// If the Leasing Agents changed from the previous version of the quote
if (quote.Leasing_Agent_Add__c != triggerOldMap.get(quote.Id).Leasing_Agent_Add__c) {
// If it was set to null, set the Leasing Agent addess also to null
if (quote.Leasing_Agent_Add__c == null) {
quote.Leasing_Agent_Address__c = null;
} else {
// If it was set to another Leasing Agent, add the quote and the Leasing Agent Ids to the sets.
leasingAgentIds.add(quote.Leasing_Agent_Add__c);
quotesIdToUpdateLeasAgtAddress.add(quote.Id);
}
}
}

// If there are not Quotes to update, there's nothing else to do
if (quotesIdToUpdateDistAddress.isEmpty() && quotesIdToUpdateLeasAgtAddress.isEmpty()) {
return;
}

Map<Id, Distributor__c> distributorsMap;
Map<Id, Leasing_Agent__c> leasingAgentsMap;

// If there are Distributors to query, create a map with the result for using it later
if (!distributorIds.isEmpty()) {
distributorsMap = new Map<Id, Distributor__c>([SELECT Id, Address__c FROM Distributor__c WHERE Id IN :distributorIds]);
} else {
distributorsMap = new Map<Id, Distributor__c>();
}

// If there are Leasing Agents to query, create a map with the result for using it later
if (!leasingAgentIds.isEmpty()) {
leasingAgentsMap = new Map<Id, Leasing_Agent__c>([SELECT Id, Address__c FROM Leasing_Agent__c WHERE Id IN :leasingAgentIds]);
} else {
leasingAgentsMap = new Map<Id, Leasing_Agent__c>();
}

// Update the quotes addresses based on the values stored in the Distributor and Leasing Agent maps
for (SBQQ__Quote__c quote : triggerNew) {
if (
quotesIdToUpdateDistAddress.contains(quote.Id) &&
quote.Distributor_Add__c != null &&
distributorsMap.containsKey(quote.Distributor_Add__c)
) {
quote.Distributor_Address__c = distributorsMap.get(quote.Distributor_Add__c).Address__c;
}

if (
quotesIdToUpdateLeasAgtAddress.contains(quote.Id) &&
quote.Leasing_Agent_Add__c != null &&
leasingAgentsMap.containsKey(quote.Leasing_Agent_Add__c)
) {
quote.Leasing_Agent_Address__c = leasingAgentsMap.get(quote.Leasing_Agent_Add__c).Address__c;
}
}
}*/
}