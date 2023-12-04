global class ZTS_EU_SchedulerCreateMissingEvent implements Schedulable {

   global void execute(SchedulableContext ctx) {
      ZTS_EU_BatchCreateMissingEventForCall p = new ZTS_EU_BatchCreateMissingEventForCall();
        database.executeBatch(p, 40);
   }   
}