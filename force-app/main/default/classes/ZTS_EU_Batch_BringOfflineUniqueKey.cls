/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_Batch_BringOfflineUniqueKey
* Description   :  Batch class to update the uniqueness key for existing Bring Offline records.                        

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     11th-Dec-14   Shreyas             Created the class.

********************************************************************************************************************************************/
global class ZTS_EU_Batch_BringOfflineUniqueKey implements Database.Batchable<SObject>

{
    
   global Database.queryLocator start(Database.BatchableContext bc) {
   
       string bringOfflineType = 'To be deleted';
       List<String> listOfApplicableMarkets = new  List<String>();
       String query = 'Select Id, ZTS_EU_Uniqueness_Key__c, OwnerId, ZTS_EU_Account__c, ZTS_EU_Type__c, ZTS_EU_Contact__c from ZTS_EU_Bring_Offline__c where ZTS_EU_Type__c !=: bringOfflineType'; 
       return Database.getQueryLocator(query);   
    }
        
    
    global void execute(Database.BatchableContext bc, List<ZTS_EU_Bring_Offline__c> scope) {
        
        List<ZTS_EU_Bring_Offline__c> boListToUpdate = new List<ZTS_EU_Bring_Offline__c>();
           
        for(ZTS_EU_Bring_Offline__c bo: scope){

            string uniqueKey = '';
            string ownerId = bo.OwnerId;
    
            if(bo.ZTS_EU_Type__c == 'Account'){
                uniqueKey = 'U:'+ ownerId + '_' + bo.ZTS_EU_Type__c + ':' + bo.ZTS_EU_Account__c;
                bo.ZTS_EU_Uniqueness_Key__c = uniqueKey;
            }
            else if(bo.ZTS_EU_Type__c == 'Contact'){
                uniqueKey = 'U:'+ ownerId + '_' + bo.ZTS_EU_Type__c + ':' + bo.ZTS_EU_Contact__c;
                bo.ZTS_EU_Uniqueness_Key__c = uniqueKey;
            }
            
            boListToUpdate.add(bo);
        }
        
        update boListToUpdate;       
       
    }
     
    
    global void finish(Database.BatchableContext bc) {
                

    } 


}