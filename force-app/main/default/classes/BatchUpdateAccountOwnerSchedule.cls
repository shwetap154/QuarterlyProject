global class BatchUpdateAccountOwnerSchedule implements Schedulable{
global void execute(SchedulableContext sc) 
    { 
        ZTS_EU_AccountOwner accBatch = new ZTS_EU_AccountOwner(); 
        database.executebatch(accBatch,20); 
  } 
}