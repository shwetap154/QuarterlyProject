global class BatchToUpdateAccountOnceSchedule implements Schedulable{
   
  global void execute(SchedulableContext sc) 
    { 
        BatchToUpdateAccountOnce accBatch = new BatchToUpdateAccountOnce(); 
        database.executebatch(accBatch,1); 
  } 
}