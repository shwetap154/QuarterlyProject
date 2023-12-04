/**
* File Name     :  OrderItemTriggerHandler
* @description  :  Handler class for the Order Item Trigger
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/19/2019		Cesar Sandrigo @ ATG     Created the Class.
* 1.2     6/19/2023		Mila Imas  Virtual RECALL service Item
* 1.3     7/31/2023     Rahul Kumar(Deloitte)    Used Constant Class and removed hard coded strings
*/
public with sharing class OrderItemTriggerHandler {
    /***
* @description Handles the Before Insert event.
* @param triggerNewList List of new Order Items provided by the Trigger.
*/
    public static void handleBeforeInsert(List<OrderItem> triggerNewList) {
        calculateSAPItemCaterogyAndUsageType(triggerNewList);
    }
    
    // Define constants or enums for SAP item category and usage type values
    enum SapItemCategory {
        // Add SAP item category values here
        Z001, Z003, Z004, Z015, Z018, Z019, Z020, Z021, Z022, Z023, Z031, Z034, Z035, Z036, Z038, Z040, Z042, Z044, Z047, Z3PL, ZAOD, ZAOF, ZBB1, ZCB1
            }
    
    enum SapUsageType {
        // Add SAP usage type values here
        AN,AVC, AQC,AOI, BO, CAV, CAQ, CB, CC, CSQ, CSV, CV, DSD, DS, EW, OLC, OLD, RD3, RVD, SL, SQC, SV, SW, TSF
            } 
    
    /***
* @description Caculates the Item Category and the Usage Type based on the Material Type, the Supplier and some other Quote parameters.
* @param orderItems List of Order Items.
*/
    private static void calculateSAPItemCaterogyAndUsageType(List<OrderItem> orderItems) {
        Set<Id> quoteLineIds = new Set<Id>();
        for (OrderItem oItem : orderItems) {
            quoteLineIds.add(oItem.SBQQ__QuoteLine__c);
        }
        
        Map<Id, SBQQ__QuoteLine__c> relatedQuoteLinesMap = getRelatedQuoteLines(quoteLineIds);
        
        for (OrderItem item : orderItems) {
            SBQQ__QuoteLine__c quoteLine = relatedQuoteLinesMap.get(item.SBQQ__QuoteLine__c);
            
            if (quoteLine.Is_Spread_Commitment_Line__c)  //quoteLine.Exclude_from_SAP__c || quoteLine.Is_Spread_Commitment_Line__c , here removed quoteLine.Exclude_from_SAP__c because it's a formula field and it will be true if Vistex_Automatic_Add_on__c = true
            {
                continue;
            }
            
            if (quoteLine.CPQ_Material_Type__c == null) {
                ErrorLogUtil.log(
                    CPQ_CONSTANT_Zoetis.STRING_ERROR_MSG_NULL_MATERIAL_TYPE,
                    new List<String>{
                        CPQ_CONSTANT_Zoetis.STRING_QUOTE + CPQ_CONSTANT_Zoetis.STRING_COLON + quoteLine.SBQQ__Quote__r.Name, CPQ_CONSTANT_Zoetis.STRING_QUOTE_LINE_NUMBER + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.SBQQ__Number__c, CPQ_CONSTANT_Zoetis.STRING_MATERIAL_NUMBER + CPQ_CONSTANT_Zoetis.STRING_COLON + quoteLine.SBQQ__Product__r.SAP_Product_Number__c,
                            CPQ_CONSTANT_Zoetis.STRING_MATERIAL_TYPE + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.CPQ_Material_Type__c, CPQ_CONSTANT_Zoetis.STRING_MATERIAL_TYPE_GROUPING + CPQ_CONSTANT_Zoetis.STRING_COLON + quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c,
                            CPQ_CONSTANT_Zoetis.STRING_LEASE_TYPE + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.Lease_Type__c, CPQ_CONSTANT_Zoetis.STRING_AGGR_CMT_LINE + CPQ_CONSTANT_Zoetis.STRING_COLON + quoteLine.Is_Aggregate_Commitment_Line__c, CPQ_CONSTANT_Zoetis.STRING_AGGR_SPREAD_LINE + CPQ_CONSTANT_Zoetis.STRING_COLON + quoteLine.Is_Spread_Commitment_Line__c,
                            CPQ_CONSTANT_Zoetis.STRING_SPC_CMT + CPQ_CONSTANT_Zoetis.STRING_COLON + quoteLine.Specific_Commitment__c, CPQ_CONSTANT_Zoetis.STRING_AUTO_SHIP + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.Auto_Ship__c, CPQ_CONSTANT_Zoetis.STRING_NET_PRICE + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.SBQQ__NetPrice__c,
                            CPQ_CONSTANT_Zoetis.STRING_SUPPLIER + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.Supplier__c, CPQ_CONSTANT_Zoetis.STRING_INSTALLMENT + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.SBQQ__Quote__r.Installment_Plan__c
                            }
                );
                continue;
            }
            
            // -- ADDON LINES --
            if (quoteLine.Vistex_Automatic_Add_on__c) {
                // Item category based on the price
                item.SAP_Item_Category__c = quoteLine.SBQQ__NetPrice__c == 0.0 ? SapItemCategory.ZAOF.name() : SapItemCategory.ZAOD.name();               
                // Calculate Usage Type base on if it has multiple ship-tos or not
                item.SAP_Usage_Type__c = isMultipleShipTo(quoteLine) ? SapUsageType.AOI.name() : isConsumableLine(quoteLine) ? SapUsageType.SQC.name(): quoteLine.CPQ_Material_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_ANCILLARY) ? SapUsageType.AN.name() :
                isExtendedWarranty(quoteLine) ? SapUsageType.EW.name(): isStandardWarranty(quoteLine) ? SapUsageType.SW.name() : null; // Set to null if none of the conditions match or provide a default value if needed.                
                continue;
            }
            //* Mi - 
            if (quoteLine.CPQ_Material_Type__c.equals('VR Service Item')){
                item.SAP_Usage_Type__c = 'SV';
                item.SAP_Item_Category__c = 'Z047';
            }
            
            //* Mi - 
            if (quoteLine.CPQ_Material_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_SERVICE_TEAM))
            {
                item.SAP_Usage_Type__c = SapUsageType.SV.name();
                item.SAP_Item_Category__c = SapItemCategory.Z047.name();
            }
            
            // Supplier: Distributor
            if (quoteLine.Supplier__c == CPQ_CONSTANT_Zoetis.STRING_DISTRIBUTOR) 
            {
                item.SAP_Item_Category__c = SapItemCategory.Z001.name();
                item.SAP_Usage_Type__c = SapUsageType.DS.name();
            } 
            else if (quoteLine.Supplier__c == CPQ_CONSTANT_Zoetis.STRING_ZOETIS) 
            {
                // Supplier: Zoetis
                // Suplier: Zoetis - Mat Type: Device (No Service Item w/ Billing plan)
                if (isDeviceLineNoServiceItem(quoteLine)) {
                    // Suplier: Zoetis - Mat Type: Device - Installment: YES
                    if (quoteLine.SBQQ__Quote__r.Installment_Plan__c) 
                    {
                        item.SAP_Item_Category__c = SapItemCategory.Z004.name();
                        item.SAP_Usage_Type__c = SapUsageType.DSD.name();
                    }
                    else if (quoteLine.Lease__c && quoteLine.Lease_Type__c != null) 
                    {
                        // Suplier: Zoetis - Installment: NO - Mat Type: Device - Lease
                        // Suplier: Zoetis - Installment: NO - Mat Type: Device - Device Sale (No lease)
                        if (quoteLine.Lease_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_DEVICE_LEASE)) 
                        {
                            item.SAP_Usage_Type__c = '3PL';
                            item.SAP_Item_Category__c = quoteLine.SBQQ__NetPrice__c == 0.0 ? SapItemCategory.Z022.name() : SapItemCategory.Z021.name();
                        } 
                        else if (quoteLine.Lease_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_SALES_LEASE)) 
                        {
                            // Suplier: Zoetis - Installment: NO - Mat Type: Device - Sales Type Lease
                            item.SAP_Usage_Type__c = SapUsageType.SL.name();
                            item.SAP_Item_Category__c = quoteLine.SBQQ__NetPrice__c == 0.0 ? SapItemCategory.Z038.name() : SapItemCategory.Z021.name();
                        } 
                        else if (quoteLine.Lease_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_OPERATING_LEASE)) 
                        {
                            // Suplier: Zoetis - Installment: NO - Mat Type: Device - Operating Lease (Rental)
                            item.SAP_Usage_Type__c = SapUsageType.OLD.name();
                            item.SAP_Item_Category__c = SapItemCategory.Z044.name();
                        }
                    } 
                    else
                    {
                        // Suplier: Zoetis - Installment: NO - Mat Type: Device - Direct Device Sale
                        item.SAP_Usage_Type__c = SapUsageType.DSD.name();
                        item.SAP_Item_Category__c = quoteLine.SBQQ__NetPrice__c == 0.0 ? SapItemCategory.Z022.name() : SapItemCategory.Z021.name();
                    }
                }
                else if (isServiceItemWithBillingPlan(quoteLine)) {
                    // Suplier: Zoetis - Mat Type: Device (No Service Item w/ Billing plan)
                    item.SAP_Usage_Type__c = SapUsageType.OLC.name();
                    item.SAP_Item_Category__c = quoteLine.SBQQ__NetPrice__c == 0.0 ? SapItemCategory.Z023.name() : SapItemCategory.Z035.name();
                }
                else if (isConsumableLine(quoteLine)) {
                    // Suplier: Zoetis - Installment: NO - Mat Type: Consumable - No Add-on
                    // Suplier: Zoetis - Installment: NO - Mat Type: Consumable - Aggregate Line
                    if (quoteLine.Is_Aggregate_Commitment_Line__c) {
                        if (quoteLine.CPQ_Commitment_Value__c != null && quoteLine.CPQ_Commitment_Value__c > 0) {
                            // VALUE COMMITMENT
                            item.SAP_Item_Category__c = SapItemCategory.Z020.name();
                            item.SAP_Usage_Type__c = SapUsageType.AVC.name();
                        } else {
                            // QUANTITY COMMITMENT
                            item.SAP_Usage_Type__c = SapUsageType.AQC.name();
                            item.SAP_Item_Category__c = quoteLine.CPQ_Commitment_Quantity__c == 0 ? SapItemCategory.Z031.name() : SapItemCategory.Z020.name();
                        }
                    } else if (quoteLine.Specific_Commitment__c) {
                        // Suplier: Zoetis - Installment: NO - Mat Type: Consumable - Specific Commitment
                        // CPQATG-415
                        item.SAP_Usage_Type__c = quoteLine.Auto_Ship__c ? 'AS' : SapUsageType.SQC.name(); // Usage Type based on Auto-ship
                        item.SAP_Item_Category__c = quoteLine.SBQQ__NetPrice__c == 0 ? SapItemCategory.Z003.name() : SapItemCategory.Z034.name(); // Item Category based on Price
                    }
                } else if (quoteLine.CPQ_Material_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_ANCILLARY)) {
                    // Suplier: Zoetis - Installment: NO - Mat Type: Ancillary
                    item.SAP_Usage_Type__c = SapUsageType.AN.name();
                    item.SAP_Item_Category__c = quoteLine.SBQQ__NetPrice__c == 0.0 ? SapItemCategory.Z015.name() : SapItemCategory.Z036.name();
                }
                else if (isProgramChargeLine(quoteLine))
                {
                    // Suplier: Zoetis - Installment: NO - Mat Type: Program
                    // Suplier: Zoetis - Installment: NO - Mat Type: Program - Buy Out
                    if (!String.isBlank(quoteLine.Program_Charge_Type__c) && quoteLine.Program_Charge_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_BUY_OUT)) {
                        item.SAP_Item_Category__c = SapItemCategory.ZCB1.name();
                        item.SAP_Usage_Type__c = SapUsageType.CB.name();
                    } else if (
                        !String.isBlank(quoteLine.Program_Charge_Type__c) && quoteLine.Program_Charge_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_BUY_OUT_EQP_RET)
                    ) {
                        // Suplier: Zoetis - Installment: NO - Mat Type: Program - Buy Out - Equipment Return
                        item.SAP_Item_Category__c = SapItemCategory.ZBB1.name();
                        item.SAP_Usage_Type__c = SapUsageType.BO.name();
                    } else if (!String.isBlank(quoteLine.Program_Charge_Type__c) && quoteLine.Program_Charge_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_CASH_BACK)) {
                        // Suplier: Zoetis - Installment: NO - Mat Type: Program - Cash Back
                        item.SAP_Item_Category__c = SapItemCategory.ZCB1.name();
                        item.SAP_Usage_Type__c = SapUsageType.CB.name();
                    } else if (!String.isBlank(quoteLine.Program_Charge_Type__c) && quoteLine.Program_Charge_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_CONTRACT_CHARGE)) {
                        // Suplier: Zoetis - Installment: NO - Mat Type: Program - Contract Charge
                        item.SAP_Item_Category__c = SapItemCategory.Z018.name();
                        item.SAP_Usage_Type__c = SapUsageType.CC.name();
                    } else if (
                        !String.isBlank(quoteLine.Program_Charge_Type__c) && quoteLine.Program_Charge_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_PT_RES_PARA)
                    ) {
                        // Suplier: Zoetis - Installment: NO - Mat Type: Program - Program Transfer (Residual Parameter)
                        item.SAP_Item_Category__c = SapItemCategory.Z001.name();
                        item.SAP_Usage_Type__c =  SapUsageType.RD3.name();
                    } else if (!String.isBlank(quoteLine.Program_Charge_Type__c) && quoteLine.Program_Charge_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_PT_CONTRACT_CHARGE)) {
                        // Suplier: Zoetis - Installment: NO - Mat Type: Program - Program Transfer (Contract charge)
                        item.SAP_Item_Category__c = SapItemCategory.Z018.name();
                        item.SAP_Usage_Type__c = SapUsageType.RVD.name();
                    } else if (
                        !String.isBlank(quoteLine.Program_Charge_Type__c) &&
                        quoteLine.Program_Charge_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_PT_TRANS_BET_CON)
                    ) {
                        // Suplier: Zoetis - Installment: NO - Mat Type: Program - Program Transfer (Transfer Device Between Contracts)
                        item.SAP_Item_Category__c = SapItemCategory.Z040.name();
                        item.SAP_Usage_Type__c = SapUsageType.TSF.name();
                    } else {
                        ErrorLogUtil.log(
                            CPQ_CONSTANT_Zoetis.STRING_ERROR_MSG_NOT_DETERMINE +  CPQ_CONSTANT_Zoetis.STRING_PRG_CHARGE_MAT_MSG ,
                            new List<String>{
                                CPQ_CONSTANT_Zoetis.STRING_QUOTE + quoteLine.SBQQ__Quote__r.Name,
                                    CPQ_CONSTANT_Zoetis.STRING_MATERIAL_NUMBER + quoteLine.SBQQ__Product__r.SAP_Product_Number__c, CPQ_CONSTANT_Zoetis.STRING_MATERIAL_TYPE + quoteLine.CPQ_Material_Type__c, CPQ_CONSTANT_Zoetis.STRING_MATERIAL_TYPE_GROUPING  + quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c
                                    }
                        );
                    }
                }
                else if (isWarranty(quoteLine)) {
                    // Suplier: Zoetis - Installment: NO - Mat Type: Service (other) / Warranties
                    // Suplier: Zoetis - Installment: NO - Mat Type: Service (other) - Extended Warranty
                    if (isExtendedWarranty(quoteLine)) {
                        item.SAP_Usage_Type__c = SapUsageType.EW.name();
                        item.SAP_Item_Category__c = quoteLine.SBQQ__NetPrice__c == 0.0 ? SapItemCategory.Z023.name() : SapItemCategory.Z019.name();
                    } else if (isStandardWarranty(quoteLine)) {
                        // Suplier: Zoetis - Installment: NO - Mat Type: Service (other) - Standard Warranty
                        item.SAP_Usage_Type__c = SapUsageType.SW.name();
                        item.SAP_Item_Category__c = SapItemCategory.Z042.name();
                    }
                }
            } 
            else if (quoteLine.Supplier__c == CPQ_CONSTANT_Zoetis.STRING_CO_SOURCE) 
            {
                // Supplier = Co-Sourced
                // Supplier = Co-Sourced - Mat Type: Consumable
                if (isConsumableLine(quoteLine)) {
                    // Supplier = Co-Sourced - Mat Type: Consumable - Aggregate Commitment
                    if (quoteLine.Is_Aggregate_Commitment_Line__c)
                    {
                        if (quoteLine.CPQ_Commitment_Value__c != null && quoteLine.CPQ_Commitment_Value__c > 0) 
                        {
                            // VALUE COMMITMENT
                            item.SAP_Item_Category__c = SapItemCategory.Z020.name();
                            item.SAP_Usage_Type__c = SapUsageType.CAV.name();
                        }
                        else
                        {
                            // QUANTITY COMMITMENT
                            item.SAP_Usage_Type__c = SapUsageType.CAQ.name();
                            item.SAP_Item_Category__c = quoteLine.SBQQ__NetPrice__c == 0.0 ? SapItemCategory.Z031.name() : SapItemCategory.Z020.name();
                        }
                    } 
                    else if (quoteLine.Specific_Commitment__c) 
                    {
                        // Supplier = Co-Sourced - Mat Type: Consumable - Specific Commitment
                        if (quoteLine.CPQ_Commitment_Value__c != null && quoteLine.CPQ_Commitment_Value__c > 0) 
                        {
                            // VALUE COMMITMENT
                            item.SAP_Item_Category__c = SapItemCategory.Z034.name();
                            item.SAP_Usage_Type__c = SapUsageType.CSV.name();
                        }
                        else
                        {
                            // QUANTITY COMMITMENT
                            item.SAP_Usage_Type__c = SapUsageType.CSQ.name();
                            item.SAP_Item_Category__c = quoteLine.SBQQ__NetPrice__c == 0.0 ? SapItemCategory.Z003.name() : SapItemCategory.Z034.name();
                        }
                    }
                }
            }
            
            // Check if the SAP Usage Type and the Item Category were set. If not, log an error!
            if (String.isBlank(item.SAP_Usage_Type__c) || String.isBlank(item.SAP_Item_Category__c)) {
                ErrorLogUtil.log(
                    CPQ_CONSTANT_Zoetis.STRING_ERROR_MSG_NULL_MATERIAL_TYPE.substring(0, CPQ_CONSTANT_Zoetis.STRING_ERROR_MSG_NULL_MATERIAL_TYPE.indexOf(':')) + '. ',
                    new List<String>{
                        CPQ_CONSTANT_Zoetis.STRING_QUOTE + CPQ_CONSTANT_Zoetis.STRING_COLON + quoteLine.SBQQ__Quote__r.Name,
                            CPQ_CONSTANT_Zoetis.STRING_QUOTE_LINE_NUMBER + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.SBQQ__Number__c, CPQ_CONSTANT_Zoetis.STRING_MATERIAL_NUMBER + CPQ_CONSTANT_Zoetis.STRING_COLON + quoteLine.SBQQ__Product__r.SAP_Product_Number__c,
                            CPQ_CONSTANT_Zoetis.STRING_MATERIAL_TYPE + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.CPQ_Material_Type__c, CPQ_CONSTANT_Zoetis.STRING_MATERIAL_TYPE_GROUPING + CPQ_CONSTANT_Zoetis.STRING_COLON + quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c,
                            CPQ_CONSTANT_Zoetis.STRING_LEASE_TYPE + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.Lease_Type__c, CPQ_CONSTANT_Zoetis.STRING_AGGR_CMT_LINE + CPQ_CONSTANT_Zoetis.STRING_COLON + quoteLine.Is_Aggregate_Commitment_Line__c,
                            CPQ_CONSTANT_Zoetis.STRING_AGGR_SPREAD_LINE + CPQ_CONSTANT_Zoetis.STRING_COLON + quoteLine.Is_Spread_Commitment_Line__c, CPQ_CONSTANT_Zoetis.STRING_SPC_CMT + CPQ_CONSTANT_Zoetis.STRING_COLON + quoteLine.Specific_Commitment__c,
                            CPQ_CONSTANT_Zoetis.STRING_AUTO_SHIP + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.Auto_Ship__c, CPQ_CONSTANT_Zoetis.STRING_NET_PRICE + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.SBQQ__NetPrice__c,
                            CPQ_CONSTANT_Zoetis.STRING_SUPPLIER + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.Supplier__c, CPQ_CONSTANT_Zoetis.STRING_INSTALLMENT + CPQ_CONSTANT_Zoetis.STRING_COLON+ quoteLine.SBQQ__Quote__r.Installment_Plan__c
                            }
                );
            }
        }
        
        ErrorLogUtil.commitLogs();
    }
    
    private static Boolean isConsumableLine(SBQQ__QuoteLine__c quoteLine) {
        return quoteLine.SBQQ__Product__r.SAP_Material__c != null &&
            quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c.equals(CPQ_CONSTANT_Zoetis.STRING_CONSUMABLE);
    }
    
    private static Boolean isDeviceLine(SBQQ__QuoteLine__c quoteLine) {
        return quoteLine.SBQQ__Product__r.SAP_Material__c != null && quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c.equals(CPQ_CONSTANT_Zoetis.STRING_DEVICE);
    }
    
    private static Boolean isDeviceLineNoServiceItem(SBQQ__QuoteLine__c quoteLine) {
        return quoteLine.SBQQ__Product__r.SAP_Material__c != null &&
            quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c.equals(CPQ_CONSTANT_Zoetis.STRING_DEVICE) &&
            !quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_SER_ITEM_BILL_PLAN);
    }
    
    private static Boolean isServiceItemWithBillingPlan(SBQQ__QuoteLine__c quoteLine) {
        return quoteLine.SBQQ__Product__r.SAP_Material__c != null &&
            quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c.equals(CPQ_CONSTANT_Zoetis.STRING_DEVICE) &&
            quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_SER_ITEM_BILL_PLAN);
    }
    
    private static Boolean isProgramChargeLine(SBQQ__QuoteLine__c quoteLine) {
        return quoteLine.SBQQ__Product__r.SAP_Material__c != null &&
            quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c.equals(CPQ_CONSTANT_Zoetis.STRING_PRG_CHARGE);
    }
    
    private static Boolean isWarranty(SBQQ__QuoteLine__c quoteLine) {
        return quoteLine.SBQQ__Product__r.SAP_Material__c != null &&
            quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c.equals(CPQ_CONSTANT_Zoetis.STRING_WARRANTY);
    }
    
    private static Boolean isStandardWarranty(SBQQ__QuoteLine__c quoteLine) {
        return quoteLine.SBQQ__Product__r.SAP_Material__c != null &&
            quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c.equals(CPQ_CONSTANT_Zoetis.STRING_WARRANTY) &&
            quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_STANDARD_WARRANTY);
    }
    
    private static Boolean isExtendedWarranty(SBQQ__QuoteLine__c quoteLine) {
        return quoteLine.SBQQ__Product__r.SAP_Material__c != null &&
            quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c.equals(CPQ_CONSTANT_Zoetis.STRING_WARRANTY) &&
            (quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_SER_EXTND_WARRANTY) ||
             quoteLine.SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type__c.equals(CPQ_CONSTANT_Zoetis.STRING_EXTND_WARRANTY));
    }
    
    private static Boolean isMultipleShipTo(SBQQ__QuoteLine__c quoteLine) {
        return quoteLine.SBQQ__Quote__c != null && quoteLine.SBQQ__Quote__r.Ship_To__c != null && quoteLine.SBQQ__Quote__r.Ship_To__c > 1;
    }
    
    /***
* @description Gets a Map of the Quotes Lines with all the relevant fields.
* @param quoteLineIds Set of Quote Line Ids.
* @return Map of Quote Lines, with the Quote Line ID as the key.
*/
    private static Map<Id, SBQQ__QuoteLine__c> getRelatedQuoteLines(Set<Id> quoteLineIds) {
        return new Map<Id, SBQQ__QuoteLine__c>(
            [
                SELECT
                Id, Name, Auto_Ship__c, Lease__c, Lease_Type__c, CPQ_Commitment_Quantity__c,
                CPQ_Commitment_Value__c, Specific_Commitment__c, Program_Charge_Type__c,
                SBQQ__NetPrice__c, Supplier__c, CPQ_Material_Type__c, Is_Aggregate_Commitment_Line__c,
                Is_Spread_Commitment_Line__c, SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c,
                SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type__c, SBQQ__Product__r.SAP_Product_Number__c,
                SBQQ__Quote__r.Name, SBQQ__Quote__r.Installment_Plan__c, SBQQ__Number__c,
                Vistex_Automatic_Add_on__c, Vistex_Manual_Add_on__c, Exclude_from_SAP__c,  SBQQ__Quote__r.Ship_To__c
                FROM SBQQ__QuoteLine__c  WHERE Id IN :quoteLineIds
            ]
        );
    }
}