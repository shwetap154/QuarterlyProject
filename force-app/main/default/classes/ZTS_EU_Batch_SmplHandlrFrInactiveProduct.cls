/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_Batch_SmplHandlrFrInactiveProduct 
* Description   :  This is a batch class that deactivates all the samples for the De activated SKU's i.e. whose Is_Active is False .                        

* @author       :   CloudSense (Sohil shah)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     17th-April-15   Shreyas             Created the class.

********************************************************************************************************************************************/

global class ZTS_EU_Batch_SmplHandlrFrInactiveProduct implements Database.Batchable<SObject>

{
     global final List<ZTS_EU_Species_Product__c> productListForDeactivatingSamples;  
      string skuType;
     List<String> listOfApplicableMarkets;    
     global ZTS_EU_Batch_SmplHandlrFrInactiveProduct()
     {
         skuType = 'SKU';   
         listOfApplicableMarkets = ZTS_EU_Batch_SampleHandlerController.getListOfApplicableMarkets();       
         productListForDeactivatingSamples = [Select Id, Name, ZTS_EU_Create_Samples__c, ZTS_EU_Is_Active__c, ZTS_EU_Market__c, ZTS_EU_Is_Old__c,Is_Deactivated_Processed__c from ZTS_EU_Species_Product__c 
        where (ZTS_EU_Is_Active__c = False AND Is_Deactivated_Processed__c = false AND ZTS_EU_Market__c IN: listOfApplicableMarkets AND ZTS_EU_Is_Old__c = False AND ZTS_EU_Type__c =: skuType)];
     }
         
   global Database.queryLocator start(Database.BatchableContext bc) { 
       //skuProductList = new List<ZTS_EU_Species_Product__c>();
        System.debug('productListForDeactivatingSamples----------------'+productListForDeactivatingSamples);
        System.debug('productListForDeactivatingSamples--Size--------------'+productListForDeactivatingSamples.Size()); 
             
        String query = ' Select Id, ZTS_EU_Is_Active__c, ZTS_EU_Product__c from ZTS_EU_Sample__c where ZTS_EU_Product__c in: productListForDeactivatingSamples ';  
        return Database.getQueryLocator(query);   
            
    }
        
    
    global void execute(Database.BatchableContext bc, List<ZTS_EU_Sample__c> scope) {
             
        List<ZTS_EU_Sample__c> sampleList = new List<ZTS_EU_Sample__c>();      
         for(ZTS_EU_Sample__c samples: scope)
         {
             sampleList.add(samples);
         }
        System.debug('sampleList--Size--------------'+productListForDeactivatingSamples.Size());    
        ZTS_EU_Batch_SampleHandlerController.processSampleDataForInactivatedProducts(sampleList);
    }
     
    
    global void finish(Database.BatchableContext bc) {
    boolean flag = false;
         List<ZTS_EU_Species_Product__c> productListToUpdate = new List<ZTS_EU_Species_Product__c>();
        for(ZTS_EU_Species_Product__c sku: productListForDeactivatingSamples){
                productListToUpdate.add(sku);
                 if(sku.Is_Deactivated_Processed__c == false)
                {
                    flag = true;
                }
            }
    
        if(productListToUpdate.size() > 0 && flag == true){
            for(ZTS_EU_Species_Product__c sku: productListToUpdate){
                sku.Is_Deactivated_Processed__c = true;
            }
         }
        System.debug('productListToUpdate----------------'+productListToUpdate); 
        update productListToUpdate;
    } 
    /* 
        Modified & Added by Sohil Shah (DEF-000673)
    */

}