/*
 * Name          :   BatchRemoveDupAPsScheduleTest
* Description   :    This is used to test BatchUpdateAccountOwnerSchedule
* Author        :    Amitabh
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
01/02/2022       Amitabh                      Created
 */
@isTest
public class BatchRemoveDupAPsScheduleTest {
    public static String exp='0 0 23 * * ?';
    @isTest static void scheduleTest()
    {
        Test.startTest();
        BatchRemoveDupAPsSchedule APTest=new BatchRemoveDupAPsSchedule();
        String jobId= system.schedule('Test Account Position Remove',exp,APTest);
        test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(exp, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    } 
}