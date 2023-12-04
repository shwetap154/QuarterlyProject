global class SL_RotorTransactionBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) { 
        SL_BatchToInsertCaseAndRotorTransaction rtBatch = new SL_BatchToInsertCaseAndRotorTransaction(); 
        database.executebatch(rtBatch); 
    }
}