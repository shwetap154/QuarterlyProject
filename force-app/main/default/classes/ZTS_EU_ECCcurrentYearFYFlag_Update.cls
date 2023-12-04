/* -----------------------------------------------------------------------------------------------------------------------
Name:        ZTS_EU_ECCcurrentYearFYFlag_Update.cls
Description: Batch used for updating the "Is_Call_Completed_In_Current_FY__c" flag (run once on 1st day of every FY)                   
Date         Version    Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
8-Dec-2020   1.0        Aritra               Initial Version    
------------------------------------------------------------------------------------------------------------------------*/
global class ZTS_EU_ECCcurrentYearFYFlag_Update implements Database.Batchable<sObject>  {
    global Database.queryLocator start(Database.BatchableContext BC){

        string query = 'Select id,Is_Call_Completed_In_Current_FY__c,ZTS_EU_Call__r.ZTS_EU_Submitted_Date__c from ZTS_EU_Employee_Call_Credit__c where ZTS_EU_Market__c !=\'United States\' and ZTS_EU_FY_EndDate__c < TODAY'+
            ' and Is_Call_Completed_In_Current_FY__c = true';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<ZTS_EU_Employee_Call_Credit__c> eccList){
        List<ZTS_EU_Employee_Call_Credit__c> toUpdateLst = new List<ZTS_EU_Employee_Call_Credit__c>();
 
        for(ZTS_EU_Employee_Call_Credit__c ecc:eccList){
            ecc.Is_Call_Completed_In_Current_FY__c=false;
            toUpdateLst.add(ecc);
        }
        
        List <Database.Saveresult> SaveResultList = Database.update(toUpdateLst,false);
        ErrorLogUtil.handleSaveResults('ZTS_EU_ECCcurrentYearFYFlag_Update: Failed to flip CurrentYear flag for one or more ECC', SaveResultList);
       
    }
     global void finish(Database.BatchableContext BC){    
    }
}