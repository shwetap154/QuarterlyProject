global class BatchEmailForCallSubmissionSchedule implements Schedulable{
   
  global void execute(SchedulableContext sc) 
    { 
        BatchToSendEmailForCallSubmission callBatch = new BatchToSendEmailForCallSubmission(); 
        database.executebatch(callBatch,20); 
  } 
}