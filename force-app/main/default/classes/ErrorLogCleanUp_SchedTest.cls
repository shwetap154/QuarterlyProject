/**
 * @description       :
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 02-25-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   02-25-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
@isTest
private class ErrorLogCleanUp_SchedTest {
  static testMethod void testScheduler() {
    String cronExpression = '0 00 1 3 * ?';
    String jobId = '';
    ErrorLogCleanUp_Sched schedule = new ErrorLogCleanUp_Sched();
    jobId = System.schedule(
      'Error Log Scheduler Test',
      cronExpression,
      schedule
    );
    System.assert(!String.isBlank(jobId), 'Job should be scheduled');
  }
}