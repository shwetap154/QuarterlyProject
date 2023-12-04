global class  ZTS_EU_Batch_Owner_Expiration_Notice_Sch implements Schedulable{
   
  global void execute(SchedulableContext sc) 
    { 
        ZTS_EU_Batch_Owner_Expiration_Notice contractBatch = new ZTS_EU_Batch_Owner_Expiration_Notice (); 
        database.executebatch(contractBatch ); 
  } 
}