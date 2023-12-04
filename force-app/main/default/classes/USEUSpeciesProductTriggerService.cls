/****************************************************************************************************************************************** 
* Class Name   : USEUSpeciesProductTriggerService
* Description  : Logic for all ZTS_EU_Species_Product__c triggers housed here.
* Created By   : Slalom/Allister McKenzie 
* Created Date : 02 December 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                     Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Allister McKenzie(Slalom)     12/02/2020         Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public inherited sharing class USEUSpeciesProductTriggerService {

    public static void beforeInsert(List<ZTS_EU_Species_Product__c> triggerNew) {
        //getting custom setting value for the Market to check its Product Potential Level
        for(ZTS_EU_Species_Product__c prodHier : triggerNew) {
            // checks if the record is new and market value is not null or if the record is old and market value is not Null
            if( prodHier.ZTS_EU_Market__c != null || (trigger.isUpdate && trigger.OldMap != null && trigger.OldMap.get(prodHier.id) != null) ) {
                Map<String,MarketGeoMapping__c> market = MarketGeoMapping__c.getAll(); 
                if(market.get(prodHier.ZTS_EU_Market__c) != null) {
                    if(market.get(prodHier.ZTS_EU_Market__c).Product_Potential_Level__c != null){
                        //updating the Product_Potential_Level__c field on Product Hierarchy
                        prodHier.ZTS_EU_Product_Potential_Level__c = market.get(prodHier.ZTS_EU_Market__c).Product_Potential_Level__c;
                        system.debug('&&&&&'+prodHier.ZTS_EU_Product_Potential_Level__c);
                    }
                } 
                
            }
        }
    }

    public static void beforeUpdate(List<ZTS_EU_Species_Product__c> triggerOld, Map<Id, ZTS_EU_Species_Product__c> triggerOldMap, List<ZTS_EU_Species_Product__c> triggerNew, Map<Id, ZTS_EU_Species_Product__c> triggerNewMap) {
        for(ZTS_EU_Species_Product__c prodHier : triggerNew) {
            if( trigger.OldMap != null && trigger.OldMap.get(prodHier.id) != null ) {
                Map<String,MarketGeoMapping__c> market = MarketGeoMapping__c.getAll(); 
                if(market.get(prodHier.ZTS_EU_Market__c) != null) {
                    if(market.get(prodHier.ZTS_EU_Market__c).Product_Potential_Level__c != null) {
                        //updating the Product_Potential_Level__c field on Product Hierarchy
                        prodHier.ZTS_EU_Product_Potential_Level__c = market.get(prodHier.ZTS_EU_Market__c).Product_Potential_Level__c;
                        system.debug('&&&&&'+prodHier.ZTS_EU_Product_Potential_Level__c);
                    }
                } 
                
            }
        }
    }

    public static void beforeDelete(List<ZTS_EU_Species_Product__c> triggerOld, Map<Id, ZTS_EU_Species_Product__c> triggerOldMap) {
       // if( !CustomSettingService.checkIfTriggerIsForBypass('ZTS_EU_Species_Product') ){
         //   return;
        //}
        
        List<ZTS_EU_Product_Gift_Limit__c> relatedGiftLimit = [SELECT Id, ZTS_EU_Product__c FROM ZTS_EU_Product_Gift_Limit__c WHERE ZTS_EU_Product__c IN :triggerOld ];
        Map<String,Boolean>  mapGiftLimitExists = new Map <String,Boolean>();

        for(ZTS_EU_Product_Gift_Limit__c giftLimit : relatedGiftLimit) {
            mapGiftLimitExists.put(giftLimit.ZTS_EU_Product__c,true);
        }

        for(ZTS_EU_Species_Product__c product : triggerOld) {
            if(mapGiftLimitExists != null && mapGiftLimitExists.containskey(product.Id)){
                if(mapGiftLimitExists.get(product.Id)){
                    product.addError('Cannot Delete Product as there are associated Gift Limits');
                }
            
            }
        }
    }

}