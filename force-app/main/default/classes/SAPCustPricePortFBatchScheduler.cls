global class SAPCustPricePortFBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc){         
        SAPCustomerPrice_Portfolio_Batch batchSAPCustPricePortF = new SAPCustomerPrice_Portfolio_Batch();
        Database.executeBatch(batchSAPCustPricePortF);
    }
}