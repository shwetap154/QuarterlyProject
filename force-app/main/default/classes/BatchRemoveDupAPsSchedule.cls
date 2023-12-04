// Main Batch Class
global class BatchRemoveDupAPsSchedule implements Schedulable{
global void execute(SchedulableContext sc) 
    { 
        
        ZTS_US_RemoveDuplicateAP appBatch = new ZTS_US_RemoveDuplicateAP(); 
        database.executebatch(appBatch,20); 
  } 
}