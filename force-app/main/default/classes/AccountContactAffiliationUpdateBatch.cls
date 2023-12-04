/*************************************************************************************************************************
  Class Name     : AccountContactAffiliationUpdateBatch
  Description    : This class is called from trigger on Account 
  Created By     : Prasun
  Created On     : 09/29/2023
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  Prasun Dubey						09/29/2023				Batch to update the affiliation name, called from trigger with there are large number of affiliations
***************************************************************************************************************************/
global class AccountContactAffiliationUpdateBatch implements Database.Batchable<sObject>{
    Set<Id> accountIds = new Set<Id>();
    
    global AccountContactAffiliationUpdateBatch(Set<Id> accountIds){
        this.accountIds = accountIds;
    }
    
    global Database.queryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id,Name, ZTS_EU_Account__r.Name, ZTS_EU_Contact__r.ZTS_EU_Full_Name__c From ZTS_EU_Affiliations__c Where ZTS_EU_Account__c in: this.accountIds]);
    }
    
    global void execute(Database.BatchableContext BC, List<ZTS_EU_Affiliations__c> affiliationList){
        AffiliationsService.setAffiliationNameOnAccountUpdate(affiliationList);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}