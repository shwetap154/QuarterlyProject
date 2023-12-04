/******************************************************************************************************************************************
 * Class Name   : BatchToCreateMissingECCScheduler
 * Description  : Scheduling class for BatchToCreateMissingECC
 * Created By   : Chelsea Paice - Zoetis
 * Created Date : 24 May 2021
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Chelsea Paice(Zoetis)    05/24/2021         Created.
 *****************************************************************************************************************************************/

global class BatchToCreateMissingECCScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        database.executeBatch(new BatchToCreateMissingECC());
     }
}