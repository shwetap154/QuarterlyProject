global class ZTS_EU_ECCUpdateBatchSchedule implements Schedulable{
   
  global void execute(SchedulableContext sc) 
    { 
       ZTS_EU_ECCUpdateBatch batch = new ZTS_EU_ECCUpdateBatch();
         database.executebatch(batch);          
    } 
}