/**
* Scheduler Class to schedule Batch apex 
* ZTS_EU_BatchAccountRatPotClear to 
* clear the ratings and Potential for all Accounts
* Author - Mayukh Deb
*/

global class ZTS_EU_AcctRatPotClearScheduler implements Schedulable {
   
   
    global void execute(SchedulableContext sc) {
        ZTS_EU_BatchAccountRatPotClear batchClsObj = new ZTS_EU_BatchAccountRatPotClear();
        database.executebatch(batchClsObj);
    }
}