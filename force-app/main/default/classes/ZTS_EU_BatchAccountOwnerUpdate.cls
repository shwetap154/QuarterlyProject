/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_BatchAccountOwnerUpdate.cls
   Description: Batch used for updating Account owner to Sue Worden(UK), Douglas Roach(Spain), Simona Rinaldi(Italy), Celina Pietruszyńska(Poland).                    
   Date         Version    Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   09-10-2014   1.0        Srinivas               Initial Version    
   20-10-2015   2.0        Priya Krishnamurthy    Modified version   
------------------------------------------------------------------------------------------------------------------------ */
global class ZTS_EU_BatchAccountOwnerUpdate implements Database.Batchable<sObject> {
     // Variable declaration 
    string accOwner; 
    List<AccountAndContactOwnerId__c> ownerids= AccountAndContactOwnerId__c.getall().values();
    Map<string, string> MarketUserIdMap=new Map<string,string>();
    
    //Query on accounts to get market related account records
      string query= 'SELECT Id,Name,ZTS_EU_Market__c,ZTS_EU_RAT_CA__c,OwnerId'+
                         +' FROM Account'
                         +' WHERE (ZTS_EU_Market__c = \'New Zealand\' OR ZTS_EU_Market__c = \'Australia\')' ;
                        
    
    // Start Method 
    global Database.queryLocator start(Database.BatchableContext BC){
        //system.debug('query========>'+query);
         return Database.getQueryLocator(query);
    }
     global void execute(Database.BatchableContext BC, List<Account> acclst){
         boolean isUpdate = false;
         for(AccountAndContactOwnerId__c customvalues:ownerids){
            MarketUserIdMap.put(customvalues.Market__c,customvalues.OwnerId__c);
            //system.debug('MarketUserIdMap===========>'+MarketUserIdMap);
         }
         for(Account acc:acclst){
             if(!MarketUserIdMap.isEmpty())
             {
                 if(MarketUserIdMap.containsKey(acc.ZTS_EU_Market__c) && acc.OwnerId!=MarketUserIdMap.get(acc.ZTS_EU_Market__c) && MarketUserIdMap.containsKey(acc.OwnerId)!=null)
                 {
                     acc.OwnerId=MarketUserIdMap.get(acc.ZTS_EU_Market__c);
                     acc.IsBatchUpdated__c=true;
                     isUpdate = true;
                 }  
             }
         }
         if(!accLst.isEmpty() && isUpdate){
            update acclst;
         }
    }
         

   global void finish(Database.BatchableContext BC){
       ZTS_EU_BatchContactOwnerUpdate contactBatch=new ZTS_EU_BatchContactOwnerUpdate();
       database.executebatch(contactBatch,2000);       
   }
}