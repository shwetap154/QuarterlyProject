/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_BatchContactOwnerUpdate.cls
   Description: Batch used for updating Contact owner to Sue Worden(UK), Douglas Roach(Spain), Simona Rinaldi(Italy), Celina Pietruszyńska(Poland).                    
   Date         Version    Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   09-10-2014   1.0        Srinivas               Initial Version     
   21-04-2015   2.0        Priya krishnamurthy    Modified Version  
------------------------------------------------------------------------------------------------------------------------ */
global class ZTS_EU_BatchContactOwnerUpdate implements Database.Batchable<sObject> {
     
    string query= 'SELECT Id,ZTS_EU_Market__c,OwnerId'+
                        +' FROM Contact'
                        +' WHERE (ZTS_EU_Market__c = \'New Zealand\' OR ZTS_EU_Market__c = \'Australia\')' ;
   
   
    Map<string, string> MarketUserIdMap=new Map<string,string>();
    List<AccountAndContactOwnerId__c> ownerids= AccountAndContactOwnerId__c.getall().values();
    global Database.queryLocator start(Database.BatchableContext BC){
        System.debug('Query : ' + query);
        return Database.getQueryLocator(query);
        
    }
     global void execute(Database.BatchableContext BC, List<Contact> contlst){
         boolean isUpdate = false;
        for(AccountAndContactOwnerId__c customvalues:ownerids){
            MarketUserIdMap.put(customvalues.Market__c,customvalues.OwnerId__c);
        }
        for(Contact cont:contlst){
             if(!MarketUserIdMap.isEmpty())
             {
                 if(MarketUserIdMap.containsKey(cont.ZTS_EU_Market__c) && cont.OwnerId!=MarketUserIdMap.get(cont.ZTS_EU_Market__c) && MarketUserIdMap.containsKey(cont.OwnerId)!=null)
                 {
                     cont.OwnerId=MarketUserIdMap.get(cont.ZTS_EU_Market__c);
                     cont.IsBatchUpdated__c=true;
                     isUpdate = true;
                 }  
             }
                        
         }
         if(!contlst.isEmpty() && isUpdate){
            update contlst;
         }
    }
         

   global void finish(Database.BatchableContext BC){
   }
}