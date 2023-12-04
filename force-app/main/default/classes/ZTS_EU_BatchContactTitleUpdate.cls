/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_BatchContactTitleUpdate.cls
   Description: Batch used for updating Contact Salutation value for EUAFME markets.                    
   Date         Version    Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   01-17-2016   1.0        Srinivas               Initial Version       
------------------------------------------------------------------------------------------------------------------------ */

global class ZTS_EU_BatchContactTitleUpdate implements Database.Batchable<sObject>{
    List<Contact> updateContLst = new List<Contact>();
    List<String> marketLst= new List<String>();  
    global Database.queryLocator start(Database.BatchableContext BC){
         for(MarketGeoMapping__c marketValue : MarketGeoMapping__c.getAll().values()){
            if(marketValue.Geo__c!='CLAR'){
                marketLst.add(marketValue.Name);
        }
        system.debug('marketLst'+marketLst);
    }
        
        string query= 'SELECT Id,ZTS_EU_Market__c,Title,Salutation'+
                        +' FROM Contact'
                        +' WHERE ZTS_EU_Market__c in:marketLst ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Contact> contlst){
        
        for(Contact cont: contlst){
            system.debug('cont.Title====>'+cont.Title);
            system.debug('cont.Salutation====>'+cont.Salutation);
            if(cont.Title !='' && (cont.Salutation =='' || cont.Salutation == null)){
                 cont.Salutation = cont.Title;
                updateContLst.add(cont);
            }

        }
        if(!updateContLst.isEmpty()){
            database.update(updateContLst,false);            
        }
        
    }
    global void finish(Database.BatchableContext BC){
   }
}