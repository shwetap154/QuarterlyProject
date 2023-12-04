/*
    @@ Puropose: (Scheduled batch class) Update all Existing accounts of France with Gross sales values from current year and Previous year 
    @@ Author: Sohil Shah(Cloud Sense) 
    @@ Reference: DEF-001051
    
    Modification LOG:
    
    Date             Author Name            DEFECT NO                    Description
    -------------------------------------------------------------------------------------------------------
   
*/
global class BatchToUpdateAccountDaily implements Database.Batchable<sObject> {        
        
    global Database.queryLocator start(Database.BatchableContext BC)
    {   
        string market = 'France';
      
        DateTime dt = System.Today();
        system.debug('dt---'+dt);
        system.debug('query---'+[Select Id,ZTS_EU_Account__c,CreatedDate from ZTS_EU_Sales__c where  CreatedDate >=: dt and ZTS_EU_Account__r.ZTS_EU_Market__c = : market]);
        string query = 'Select Id,ZTS_EU_Account__c,CreatedDate from ZTS_EU_Sales__c where CreatedDate >=: dt and ZTS_EU_Account__r.ZTS_EU_Market__c = : market';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<ZTS_EU_Sales__c> saleslst)
    {   
         Set<Id> accntIDs = new Set<Id>();
         for(ZTS_EU_Sales__c sales: saleslst)
         {
             accntIDs.add(sales.ZTS_EU_Account__c);
         }
         List<Account> acclst = new List<Account>();
         acclst = [Select Id, Name,ParentId, ZTS_EU_Market__c,Parent.Name, ZTS_EU_Loyalty_Flag__c,AP_11_CY_TS__c,AP_11_PY_TS__c,AP_12_CY_TS__c,AP_12_PY_TS__c,(select id, ZTS_EU_Date__c, CurrencyIsoCode from Sales__r where ZTS_EU_Date__c <> null) from Account where ZTS_EU_Market__c=:'France' and id IN: accntIDs];
         updateAccountsFromBatch ap = new updateAccountsFromBatch(acclst);
        
    }
     global void finish(Database.BatchableContext BC)
    {
        
    }   
 }