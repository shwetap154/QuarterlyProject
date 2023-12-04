global class BatchEmailForCallToManagerSchedule implements Schedulable{
   
  global void execute(SchedulableContext sc) 
    { 
        BatchToSendEmailForCallToManager callmanBatch = new BatchToSendEmailForCallToManager(); 
        database.executebatch(callmanBatch,20); 
  } 
}