/*******************************************************************************************************************************************
* File Name     :  APPTriggerInvokeTemporaryBatch
* Description   :  This batch job that would query all account product potential records (app) of a certain market
                   (market of the product hierarchy connected to app is a parameter of the batch constructor). The only thing 
                   the batch would do is update the queried apps

* @author       :   CloudSense (Palam)

********************************************************************************************************************************************/
global class APPTriggerInvokeTemporaryBatch implements Database.Batchable<SObject>

{
    
   global final String market;
    global final list<String> markets;

   global APPTriggerInvokeTemporaryBatch(list<String> m){
        markets = m; 
   }
    
   global Database.queryLocator start(Database.BatchableContext bc) { 
       
       List<ZTS_EU_Account_Product_Potential__c> accProdPot= new List<ZTS_EU_Account_Product_Potential__c>();
       
       String queryaccProdPot = 'Select ZTS_EU_Sum_Of_Product_Account_Potential__c,Id From ZTS_EU_Account_Product_Potential__c where Product_Hierarchy__r.ZTS_EU_Market__c IN:markets'; 
       
       return Database.getQueryLocator(queryaccProdPot);   
    }
        
    
    global void execute(Database.BatchableContext bc, List<ZTS_EU_Account_Product_Potential__c> scope) {
       
        update scope;
        system.debug('scope---------' + scope);
    }
     
    
    global void finish(Database.BatchableContext bc) {
                

    } 
    
   

}