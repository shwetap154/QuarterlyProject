global class ZTS_EU_BatchAccountOwnerUpdateSchedule implements Schedulable{
   
    global void execute(SchedulableContext sc) 
    { 
        ZTS_EU_BatchAccountOwnerUpdate accBatch = new ZTS_EU_BatchAccountOwnerUpdate(); 
        database.executebatch(accBatch); 
    } 
}