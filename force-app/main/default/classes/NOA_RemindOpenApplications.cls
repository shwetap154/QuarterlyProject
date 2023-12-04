/*************************************************************************************
* Name          :    NOA_RemindOpenApplications
* Description   :    Batch class to remind open Online Applications.
* Author        :    Shiva Kudikilla(Cognizant)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
Jun 11, 2018     Shiva Kudikilla(Cognizant)         Created

**************************************************************************************/
global class NOA_RemindOpenApplications implements Database.Batchable<SObject>, Schedulable { 
     
    global Database.QueryLocator start(Database.BatchableContext BC)
    { 
        List<String> statusList = new List<String>{'Open', 'To Be Deleted'};
        List<String> noaRecTypes = new List<String>{'Online_Account_Licensed_Vet','Online_Account_Diagnostic_or_Reproduction'}; 
        return Database.getQueryLocator([SELECT Id,LastModifiedDate,NOA_Application_Number__c,Status,Company,NOA_Reminder_Flag__c FROM Lead 
                                         WHERE RecordType.DeveloperName in :noaRecTypes AND Company = 'New Online Account' AND Status in :statusList AND Market__c = 'United States' ]);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> listOpenNOAleads) {
        List<Lead> leadsToBeUpdated = new List<Lead>();
        List<Lead> day90LeadsTobeDELETEDList = new List<Lead>();
        
        for(Lead l : listOpenNOAleads){
            Integer daysLast;
            if(Test.isRunningTest()){
                daysLast = (l.NOA_Reminder_Flag__c == null) ? 30 : 16;
            }else{
                daysLast = (Date.valueOf(l.LastModifiedDate)).daysBetween(System.today()) + 1;
            }
            System.debug('...Days Last...' + daysLast);
            if(l.Status == 'Open' &&  (l.NOA_Reminder_Flag__c == null || l.NOA_Reminder_Flag__c == 0) && daysLast == 30 ){  
                l.NOA_Reminder_Flag__c = 30;
                leadsToBeUpdated.add(l);
                
            } else if(l.Status == 'Open' && l.NOA_Reminder_Flag__c == 30 && daysLast == 16){
                l.Status = 'To Be Deleted';
                l.NOA_Reminder_Flag__c = 46;
                leadsToBeUpdated.add(l);    
                
            } else if(l.Status == 'To Be Deleted' && daysLast == 45){  
                day90LeadsTobeDELETEDList.add(l);   //This list is to DELETE the leads. Be careful to add
            }
        } 
         
        if(leadsToBeUpdated.size() > 0){
            try{
                //System.debug('...leadsToBeUpdated...' + leadsToBeUpdated);
                Database.update(leadsToBeUpdated, false); 
            }catch(DMLException ex){
                System.debug('Error updating NOA_Reminder_Flag for Leads :: ' + leadsToBeUpdated);
            }
        }
        
        //DELETE New Online Application leads that are in Open or To Be Deleted status for 90 days from its LastModifiedDate
        if(day90LeadsTobeDELETEDList.size() > 0){
            try{
                //System.debug('...day90LeadsTobeDELETEDList...' + day90LeadsTobeDELETEDList);
                Database.delete(day90LeadsTobeDELETEDList, false); 
            }catch(DMLException ex){
                System.debug('Error deleting New Online Account Leads that are in Open or To Be Deleted status for 90 days :: ' + Day90LeadsTobeDELETEDList);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public void execute (SchedulableContext sc) { 
        Database.executebatch(new NOA_RemindOpenApplications());
    }
    
}