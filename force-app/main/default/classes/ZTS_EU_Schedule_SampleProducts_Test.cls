/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_Batch_SampleProducts_Test.cls
   Description: Test Class for Class ZTS_EU_Schedulable_SampleForProducts.cls
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   22-01-2014   1.0     CloudSense(Shefali)   Initial Version          
------------------------------------------------------------------------------------------------------------------------ */

@isTest
public class ZTS_EU_Schedule_SampleProducts_Test{
 
    public static String CRON_EXP = '0 10 * * * ?';

    static testmethod void test() {
        Test.startTest();
        
        String jobId = System.schedule('ZTS_EU_Batch_SampleHandlerForProducts',CRON_EXP,new ZTS_EU_Schedulable_SampleForProducts());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP,ct.CronExpression);
        //System.assertEquals('2015-01-22 00:00:00',String.valueOf(ct.NextFireTime));
        Test.stopTest();
        
    }
}