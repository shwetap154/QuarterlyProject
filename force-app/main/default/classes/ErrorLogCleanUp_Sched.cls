/**
 * @description       : Schedulable Job to Call Error Log Clean Up Batch Job
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 02-25-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   02-25-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
global class ErrorLogCleanUp_Sched implements Schedulable {
  global void execute(SchedulableContext sc) {
    ErrorLogCleanUp_Batch cleanupBatch = new ErrorLogCleanUp_Batch();
    database.executebatch(cleanupBatch);
  }
}