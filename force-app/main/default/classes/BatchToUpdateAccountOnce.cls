/*
    @@ Puropose: Update all Existing accounts of France with Gross sales values from current year and Previous year 
    @@ Author: Sohil Shah(Cloud Sense) 
    @@ Reference: DEF-001051
    
    Modification LOG:
    
    Date             Author Name            DEFECT NO                    Description
    -------------------------------------------------------------------------------------------------------
   
*/
global class BatchToUpdateAccountOnce implements Database.Batchable<sObject> {        
        
    global Database.queryLocator start(Database.BatchableContext BC)
    {   
        string market = 'France';       
        string query = ' Select Id, Name,ParentId, ZTS_EU_Market__c,Parent.Name, ZTS_EU_Loyalty_Flag__c,Current_Year_Grand_Total__c,Previous_Year_Grand_Total__c,AP_11_CY_TS__c,AP_11_PY_TS__c,AP_12_CY_TS__c,AP_12_PY_TS__c,AP_10_CY_TS__c,AP_10_PY_TS__c,AP_09_CY_TS__c,AP_09_PY_TS__c,AP_08_PY_TS__c,AP_08_CY_TS__c,AP_07_PY_TS__c,AP_07_CY_TS__c,AP_06_CY_TS__c,AP_06_PY_TS__c,AP_05_PY_TS__c,AP_05_CY_TS__c,AP_04_PY_TS__c,AP_04_CY_TS__c,AP_03_CY_TS__c,AP_03_PY_TS__c,AP_02_PY_TS__c,AP_02_CY_TS__c,AP_01_CY_TS__c,AP_01_PY_TS__c,(select id, ZTS_EU_Date__c, CurrencyIsoCode from Sales__r where ZTS_EU_Date__c <> null) from Account where ZTS_EU_Market__c=:market';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> acclst)
    {        
         updateAccountsFromBatch ap = new updateAccountsFromBatch(acclst);
        
    }
     global void finish(Database.BatchableContext BC)
    {
        
    }   
 }