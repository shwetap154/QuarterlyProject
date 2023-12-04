/**
* File Name     :  GetApprovalDataforEmailTemplate
* @description  :  Controller class for 'GetApprovalDataEmailTemplate' VF component.
* @author       :  Ramiro Alvarez @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     2/03/2021     Ramiro Alvarez @ ATG    Created the Class.
*/

global with sharing class GetApprovalDataforEmailTemplate {   
    
    public Id quoteId {get; set;}    
    public class EmailData {
        public Double numberLine {get; set;}                
        public Double qty {get; set;}        
        public String productName {get; set;}        
        public Double contractPrice {get; set;}                
        public Double offerDisc {get; set;}
        public Double addDisc {get; set;}        
        public Double netTotal {get; set;}        
        public Double cashBackBuyAmount {get; set;}                
        public Double initShipQty {get; set;}
        public String initShipOfferedFree {get; set;}        
        public Double offerCommQty {get; set;}
        public Double offerCommValue {get; set;}        
        public Double quoteCommQty {get; set;}        
        public Double quoteCommValue {get; set;}
        public String currencyCode {get; set;}
    }        
    
    public List<EmailData> getEmailData() {
        
        //Query quotelines to prepare EmailData obj
        List <SBQQ__QuoteLine__c> quotelines =  [SELECT Id, Name, SBQQ__AdditionalDiscount__c,
        CPQ_Commitment_Quantity__c, CPQ_Commitment_Value__c, Initial_Quantity__c,
        Initial_Shipment_Free__c, SBQQ__NetTotal__c, Deal_Discount__c, SBQQ__Product__c,
        SBQQ__ProductName__c, QT_Total_Commitment_Quantity__c,
        QT_Total_Commitment_Value__c, SBQQ__Quote__c, Total_Commitment_Value__c,
        Vistex_Item_Contract_Price__c,SBQQ__Number__c, SBQQ__Quantity__c, SAP_Product_Number__c,Amount_Owed__c,Exclude_from_Vistex_Pricing_Call__c,
        Product_Name_Translated__c,SBQQ__RegularTotal__c, SBQQ__Discount__c, CurrencyIsoCode
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId
            ORDER BY SBQQ__Number__c ASC];

        
        //Query custom setting to get SAP codes for Buy Out and Cash Back products
        Program_Charge_Materials__c param = Program_Charge_Materials__c.getInstance();
        String buyOutString = (String) param.Buy_Out__c;
        String cashBackString = (String) param.Cash_Back__c;

        List<String> buyOutSAPMaterialNumber = buyOutString != null ? buyOutString.split(',') : new List<String> ();
        List<String> cashBackSAPMaterialNumber = cashBackString != null ? cashBackString.split(',') : new List<String> ();
        
        List<EmailData> emailDataList = new List<EmailData> ();

        for (SBQQ__QuoteLine__c quoteline : quotelines) {

            EmailData emailDataRow  = new EmailData();
            emailDataRow.numberLine = quoteline.SBQQ__Number__c;
            emailDataRow.qty = quoteline.SBQQ__Quantity__c;
            emailDataRow.productName = quoteline.Product_Name_Translated__c;
            emailDataRow.contractPrice = !quoteline.Exclude_from_Vistex_Pricing_Call__c ? quoteline.Vistex_Item_Contract_Price__c : null;
            emailDataRow.offerDisc = quoteline.Deal_Discount__c != null ? quoteline.Deal_Discount__c : 0;
            emailDataRow.addDisc = quoteline.SBQQ__Discount__c != null ?  quoteline.SBQQ__Discount__c :
                    ((quoteline.SBQQ__AdditionalDiscount__c != null && quoteline.SBQQ__AdditionalDiscount__c != 0 &&
                    quoteline.SBQQ__RegularTotal__c != null && quoteline.SBQQ__RegularTotal__c != 0) ?
                        (quoteline.SBQQ__AdditionalDiscount__c/quoteline.SBQQ__RegularTotal__c)*100 : 0);
            
            emailDataRow.netTotal = !quoteline.Exclude_from_Vistex_Pricing_Call__c ? quoteline.SBQQ__NetTotal__c : null;
            emailDataRow.cashBackBuyAmount = (buyOutSAPMaterialNumber.contains(quoteline.SAP_Product_Number__c) ||
                                cashBackSAPMaterialNumber.contains(quoteline.SAP_Product_Number__c)) ?
                                quoteline.Amount_Owed__c : null;
            emailDataRow.initShipQty = quoteline.Initial_Quantity__c;
            emailDataRow.initShipOfferedFree = quoteline.Initial_Shipment_Free__c ? 'X' : '';
            emailDataRow.offerCommQty = quoteline.CPQ_Commitment_Quantity__c;
            emailDataRow.offerCommValue = quoteline.CPQ_Commitment_Value__c;
            emailDataRow.quoteCommQty = quoteline.QT_Total_Commitment_Quantity__c;
            emailDataRow.quoteCommValue = quoteline.QT_Total_Commitment_Value__c;
            emailDataRow.currencyCode = quoteline.CurrencyIsoCode + ' ';

            emailDataList.add(emailDataRow);        
        }

        return emailDataList;
    }    
}