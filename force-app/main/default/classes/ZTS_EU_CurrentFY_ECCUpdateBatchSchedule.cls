global class ZTS_EU_CurrentFY_ECCUpdateBatchSchedule implements Schedulable{
   
  global void execute(SchedulableContext sc) 
    { 
       ZTS_EU_CurrentFY_ECCUpdateBatch batch = new ZTS_EU_CurrentFY_ECCUpdateBatch();
         database.executebatch(batch);          
    } 
}