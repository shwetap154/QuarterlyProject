global class CarystaOpportunityBatch implements Database.Batchable<SObject>, Schedulable {
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<String> openStages = new List<String>{'Installed','Not Interested','To Be Nurtured for Future'};
        Id carystaRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CARYSTA_HVC').getRecordTypeId();
        return Database.getQueryLocator([Select Id,Name,StageName,LastModifiedDate,CreatedDate,Carysta_Scheduler_Flag__c,Days_Last__c,RecordTypeId 
                                         from Opportunity Where RecordTypeId = :carystaRecTypeId AND StageName NOT IN :openStages
                                         AND Days_Last__c = 30
                                         AND ZTS_EU_Market__c = 'United States']);
        
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> listCarystaOpptys) {
        for(Opportunity opp : listCarystaOpptys){
            opp.Carysta_Scheduler_Flag__c = true;
        }
        if(listCarystaOpptys != null && listCarystaOpptys.size() > 0){
            try{
                Database.update(listCarystaOpptys, false);
                
            }catch(DMLException ex){
                System.debug('Error updating CarystaSchedulerFlag on Opportunities :: ' + listCarystaOpptys);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public void execute (SchedulableContext sc) { 
        Database.executebatch(new CarystaOpportunityBatch());
    }
    
}