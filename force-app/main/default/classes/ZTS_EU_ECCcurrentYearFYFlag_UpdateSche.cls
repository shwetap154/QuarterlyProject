global class ZTS_EU_ECCcurrentYearFYFlag_UpdateSche   implements Schedulable {

    global void execute(SchedulableContext ctx) {

        ZTS_EU_ECCcurrentYearFYFlag_Update  currentYearFlagUpdate =new ZTS_EU_ECCcurrentYearFYFlag_Update();
        database.executebatch(currentYearFlagUpdate);
        
         // Custom Scheduling Process through Console
         //ZTS_EU_ECCcurrentYearFYFlag_UpdateSche batch = new ZTS_EU_ECCcurrentYearFYFlag_UpdateSche();
        //String sch = '0 1 1 DEC *';
       //String jobIDNew = system.schedule('Batch Scheduled', sch, batch);

    }
}