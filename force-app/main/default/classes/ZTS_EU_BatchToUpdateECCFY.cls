/* -----------------------------------------------------------------------------------------------------------------------
Name:        ZTS_EU_BatchToUpdateECCFY.cls
Description: Batch used for updating Number of Completed Calls In FY field                     
Date         Version    Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
07-06-2016   1.0        Srinivas               Initial Version    
------------------------------------------------------------------------------------------------------------------------*/
global class ZTS_EU_BatchToUpdateECCFY implements Database.Batchable<sObject>  {
    global Database.queryLocator start(Database.BatchableContext BC){
        string query = 'SELECT id, ZTS_EU_Submitted_Date__c,ZTS_EU_Status__c ' + 
        +' FROM Call__c'
        +' WHERE ZTS_EU_Submitted_Date__c = THIS_FISCAL_YEAR AND ZTS_EU_Market__c != \'United States\'';

        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Call__c> callList){
        List<ZTS_EU_Employee_Call_Credit__c> toUpdateLst = new List<ZTS_EU_Employee_Call_Credit__c>();
        List<ZTS_EU_Employee_Call_Credit__c> ECCLst=[select id, Is_Call_Completed_In_Current_FY__c from ZTS_EU_Employee_Call_Credit__c where ZTS_EU_Call__c in :callList AND ZTS_EU_Market__c != 'United States'];
 
        for(ZTS_EU_Employee_Call_Credit__c ecc:ECCLst){
            ecc.Is_Call_Completed_In_Current_FY__c=true;
            toUpdateLst.add(ecc);
        }
        
        database.update(toUpdateLst);
       
    }
     global void finish(Database.BatchableContext BC){    
    }
}