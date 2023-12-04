@isTest
private class BatchToCreateMissingECCScheduler_Test {

    static testMethod void TestBatchToCreateMissingECCScheduler() {
        String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new BatchToCreateMissingECCScheduler() );

        Test.startTest();
            CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        Test.stopTest();

        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));
    }
}