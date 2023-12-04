/**
* Scheduler Class to schedule Batch apex 
* ZTS_EU_BatchAccountSegmentationUpdate to 
* update the Segmentation ratings for all accounts
* 
* @author Bimba Ravi
*/
global class ZTS_EU_AcctSegBatchScheduler implements Schedulable {
   
   
    global void execute(SchedulableContext sc) {
        ZTS_EU_BatchAccountSegmentationUpdate batchClsObj = new ZTS_EU_BatchAccountSegmentationUpdate();
        database.executebatch(batchClsObj);
    }
}