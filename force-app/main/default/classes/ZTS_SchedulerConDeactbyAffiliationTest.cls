/****************************************************************************************************************************************** 
 * Class Name       : ZTS_SchedulerConDeactbyAffiliationTest
 * Description      : Test Class for ZTS_Scheduler_ConDeactbyAffiliations.cls (SC-008471)                               
 * Created By       : Cognizant
 * Created Date     : 5-April, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)       05-April-2021       Created  (SC-008471)
*****************************************************************************************************************************************/
@istest
public class ZTS_SchedulerConDeactbyAffiliationTest {
    
    public static testMethod void testschedulerjob(){
        test.startTest();
        String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new ZTS_Scheduler_ConDeactbyAffiliations());
        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();
    }
    
}