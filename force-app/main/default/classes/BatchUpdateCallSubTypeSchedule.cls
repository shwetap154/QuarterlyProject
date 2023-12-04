/**
 * @description       : Schedulable Job to Call Call Translation Batch Job
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 02-16-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   02-10-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
global class BatchUpdateCallSubTypeSchedule implements Schedulable {
  global void execute(SchedulableContext sc) {
    ZTS_EU_UpdateCallSubType translateBatch = new ZTS_EU_UpdateCallSubType();
    // Higher than 20 causes Too Many DML
    database.executebatch(translateBatch, 20);
  }
}