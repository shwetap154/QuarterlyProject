/**
* File Name     :  MarketEnableTriggerHandler
* @description  :  Trigger Handler for MarketEnableTrigger (Market__c object)
* @author       :  Priti Kumar @ Deloitte
* Modification Log
---------------------------------------------------------------------------------------------------
* Ver.    Date          Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/13/2023   Priti Kumar @ Deloitte     Created the Class. Added insertRebateAmount method.
*/
public class MarketEnableTriggerHandler {
    
    public static List<Market__c> insertRebateAmount(List<Market__c> mark,Map<Id,Market__c> oldaccMap,Boolean isInsert){
        Boolean isRun = false;
        List<Rebate_Amount__c> rebateAmountToInsert = new  List<Rebate_Amount__c>();
        Set<ID> marketIds = new Set<Id>();
        for(Market__c marketObj : mark){
            marketIds.add(marketObj.id);
            if(isInsert ||(marketObj.Is_Rebate_Calculator_Enabled__c && !oldaccMap.get(marketObj.Id).Is_Rebate_Calculator_Enabled__c))
            {
                isRun = marketObj.Is_Rebate_Calculator_Enabled__c;
                break;
            }
        }
        
        if(isRun== true)
        {
            Map<Id, List<Rebate_Amount__c>> MarketProduct2sMap = new Map<Id, List<Rebate_Amount__c>>();
            List<Rebate_Amount__c> allRebateAmt =  [SELECT Id, Market__c,CurrencyIsoCode,Description__c,Product_SKU__c,ProductCode__c,Rebate_Amount__c FROM Rebate_Amount__c WHERE Market__c IN :marketIds];
            
            
            for (Rebate_Amount__c obj : allRebateAmt)
            {
                if(MarketProduct2sMap.containsKey(obj.Market__c)){
                    MarketProduct2sMap.get(obj.Market__c).add(obj);
                }
                else{
                    MarketProduct2sMap.put(obj.Market__c,new List<Rebate_Amount__c>{obj});
                }
            }
            List<Rebate_Amount__c> rebCheckList =new List<Rebate_Amount__c>();
            List<Rebate_Amount__c> allRebateAmtForUsMarket  =new List<Rebate_Amount__c>();
            allRebateAmtForUsMarket  =  [SELECT Id, Market__c,CurrencyIsoCode,Description__c,Product__c,Product_SKU__c,ProductCode__c,Rebate_Amount__c FROM Rebate_Amount__c WHERE Market__r.name ='United States'];
                    
            for(Market__c markForIds : mark)
            {
                if (MarketProduct2sMap.containsKey(markForIds.Id)) {
                    rebCheckList = MarketProduct2sMap.get(markForIds.Id);
                }
                if(rebCheckList.size()== 0){
                           
                    if(allRebateAmtForUsMarket.size()>0){
                        for (Rebate_Amount__c prod : allRebateAmtForUsMarket) {
                            Rebate_Amount__c rebAmt = new Rebate_Amount__c();
                            rebAmt.Market__c =markForIds.id;
                            rebAmt.Description__c=prod.Description__c;
                            rebAmt.Product__c = prod.Product__c;
                            rebAmt.Product_SKU__c=prod.Product_SKU__c;
                            rebAmt.Rebate_Amount__c=prod.Rebate_Amount__c;
                            rebAmt.ProductCode__c=prod.ProductCode__c;
                            rebAmt.CurrencyIsoCode = markForIds.CurrencyIsoCode;
                            rebateAmountToInsert.add(rebAmt);
                        }
                    } 
                } 
                
            }
            // Insert the custom object records
            if (!rebateAmountToInsert.isEmpty()) {
                try{
                    insert rebateAmountToInsert; 
                }
                catch(Exception e)
                {
                  System.debug('MarketEnabledTrigger Insert Method Failed'); 
                  System.debug('Error :- ' + e.getMessage());   
                }
            }
        }
        return null;
    }   
}