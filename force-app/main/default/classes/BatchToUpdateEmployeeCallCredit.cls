/* -----------------------------------------------------------------------------------------------------------------------
   Name:        BatchToUpdateEmployeeCallCredit.cls
   Description: Batch used for updating is calls status completed filed on EmployeeCallCredit object for Belgium market .                    
   Date         Version    Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   02-1-2016  1.0        Srinivas               Initial Version    
------------------------------------------------------------------------------------------------------------------------ */
global class BatchToUpdateEmployeeCallCredit implements Database.Batchable <sObject> {
	/*Start method is used to get the Belgium completed ECC records */ 
    global Database.QueryLocator start (Database.BatchableContext BC) {
        string query = 'SELECT id,ZTS_EU_Account_Position__c , Call_End_Date__c,Is_Call_status_Completed__c FROM ZTS_EU_Employee_Call_Credit__c WHERE  ZTS_EU_Market__c = \'Belgium\' and Is_Call_status_Completed__c = false  and ZTS_EU_Call__r.ZTS_EU_Status__c = \'Completed\'';    
        return Database.getQueryLocator(query);         
    }
  /*execute method is used to update the ECC call status to true */
    global void execute(database.BatchableContext BC , List<ZTS_EU_Employee_Call_Credit__c> eccLst){
        List<ZTS_EU_Employee_Call_Credit__c> eccLStTOUpdate =  new List<ZTS_EU_Employee_Call_Credit__c>();
        
        // Segmented because accList is segmented. David Stern 4/1
        for(AggregateResult arRec : [SELECT id,ZTS_EU_Account_Position__c , MAX(Call_End_Date__c),Is_Call_status_Completed__c callStatus FROM ZTS_EU_Employee_Call_Credit__c WHERE Id in:eccLst GROUP BY ZTS_EU_Account_Position__c,Is_Call_status_Completed__c,id]){
            ZTS_EU_Employee_Call_Credit__c eccRec = new ZTS_EU_Employee_Call_Credit__c();
                eccRec.Id = (id) arRec.get('id');
            	eccRec.Is_Call_status_Completed__c = True;            
                eccLStTOUpdate.add(eccRec);
        }
        try{
        	database.update(eccLStTOUpdate);
        }catch(DMLException e){
           System.debug('The following exception has occurred on Uapdate: ' + e.getMessage());
        }
    }
  /*finish method is used to */
    global void finish(database.BatchableContext BC){
        
    }

}