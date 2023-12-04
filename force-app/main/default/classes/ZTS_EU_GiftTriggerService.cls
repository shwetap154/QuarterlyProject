public with sharing class ZTS_EU_GiftTriggerService {
   
    public static void beforeInsert(List<ZTS_EU_Gift__c> triggerNew){

        if(triggerNew.isEmpty() && triggerNew == null)
            return;

        List<ZTS_EU_Gift__c> giftList_PopulateYear = new List<ZTS_EU_Gift__c>();
        List<ZTS_EU_Gift__c> giftList_PopulateGiftValue = new List<ZTS_EU_Gift__c>();
        List<ZTS_EU_Gift__c> giftList_CheckLimits = new List<ZTS_EU_Gift__c>();
        
        for(ZTS_EU_Gift__c gft : triggerNew){
            
            if(gft.ZTS_EU_Year__c == null){
                giftList_PopulateYear.add(gft);
            }
            
            if(gft.ZTS_EU_Product_Hierarchy__c != null){
                giftList_PopulateGiftValue.add(gft);
            }
            
            giftList_CheckLimits.add(gft);
        }
            
        if(giftList_PopulateYear.size() > 0){
            ZTS_EU_GiftUtility.populateYear(giftList_PopulateYear);
        }
        
        if(giftList_PopulateGiftValue.size() > 0){
            ZTS_EU_GiftUtility.populateGiftValue(giftList_PopulateGiftValue);
        }
        
        ZTS_EU_GiftUtility.checkLimitsForExpensiveAndCheapGifts(giftList_CheckLimits);
    }

    public static void beforeUpdate(List<ZTS_EU_Gift__c> triggerNew, List<ZTS_EU_Gift__c> triggerOld){

        if(triggerNew.isEmpty() && triggerNew == null)
            return;

        List<ZTS_EU_Gift__c> gftList_YearChanged = new List<ZTS_EU_Gift__c>();
        List<ZTS_EU_Gift__c> gftList_ProductChanged = new List<ZTS_EU_Gift__c>();
            
        for (Integer i = 0; i < triggerNew.size(); i++){ 
            if(triggerNew[i].ZTS_EU_Year__c != triggerOld[i].ZTS_EU_Year__c){
                gftList_YearChanged.add(triggerNew[i]);
            }
            
            if(triggerNew[i].ZTS_EU_Product_Hierarchy__c != triggerOld[i].ZTS_EU_Product_Hierarchy__c){
                gftList_ProductChanged.add(triggerNew[i]);
            }
        }
    
        if(gftList_YearChanged.size() > 0){
            ZTS_EU_GiftUtility.populateCurrentYearCheckbox(gftList_YearChanged);
        }
        
        if(gftList_ProductChanged.size() > 0){
            ZTS_EU_GiftUtility.populateGiftValue(gftList_ProductChanged);
            ZTS_EU_GiftUtility.checkLimitsForExpensiveAndCheapGifts(gftList_ProductChanged);
        }
    }
}