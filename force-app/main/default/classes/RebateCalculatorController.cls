/**
* File Name     :  RebateCalculatorController
* @description  :  Helper class that takes gathered data for RebateCalculator web comp used in CPQ
* @author       :  Mila Imas
* Modification Log
===================================================================================================
* Ver.    Date          Author                  Modification
---------------------------------------------------------------------------------------------------
**/
public with sharing class RebateCalculatorController {
    @TestVisible  
    public class RebateCalculatorRec {
        @AuraEnabled
        public Integer Id { get; set; }	
        @AuraEnabled
        public String Name { get; set; }
        @AuraEnabled
        public String ProductCode { get; set; }
        @AuraEnabled
        public String Description { get; set; }
        @AuraEnabled
        public Integer Qty { get; set; }
        @AuraEnabled
        public Decimal RebateAmt { get; set; }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<RebateCalculatorRec> getRebateProducts ( String marketNameStr) {
        List<Rebate_Amount__c> listRebateProducts = [SELECT Id, ProductCode__c,Product_SKU__c, Product__r.Name, Description__c, convertCurrency(Rebate_Amount__c) FROM Rebate_Amount__c WHERE Rebate_Amount__c > 0 AND Market__r.Name =: marketNameStr ORDER BY Rebate_Amount__c DESC ];
        
        List<RebateCalculatorRec> listRebateRec = new List<RebateCalculatorRec>();
        Integer i = 0;
        
        for (Rebate_Amount__c rebate : listRebateProducts) {
            RebateCalculatorRec rebateRec = new RebateCalculatorRec();
            rebateRec.Qty = 0;
            rebateRec.RebateAmt = rebate.Rebate_Amount__c; 
            rebateRec.ProductCode = rebate.Product_SKU__c; 
            i++;
            rebateRec.Id = i; 
            rebateRec.Description = rebate.Description__c;
            rebateRec.Name = rebate.Product__r.Name;
            listRebateRec.add(rebateRec);
           // system.debug('rebateRec ==>  '+ rebateRec);
        }
        
        return listRebateRec; 
    }
                              
}