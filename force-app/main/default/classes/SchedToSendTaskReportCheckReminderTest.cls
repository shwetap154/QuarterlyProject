/****************************************************************************************************************************************** 
 * Class Name       : SchedToSendTaskReportCheckReminderTest
 * Description      : Test Class for SchedulerToSendTaskReportCheckReminder.cls (SC-009405)                               
 * Created By       : Aritra(Cognizant)
 * Created Date     : 1-April-2022
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)       1-April-2022       Created  (SC-009405)
*****************************************************************************************************************************************/
@istest
public class SchedToSendTaskReportCheckReminderTest {
    
    public static testMethod void testEmailSchedulerJob(){
        
        Profile profiles=[Select Id From Profile Where Name='US Inside Sales Manager'];
        
        User IDSM = new user();
        IDSM.FirstName = 'Inside Sales';    
        IDSM.LastName = 'Brown';
        IDSM.ZTS_EU_Market__c = 'United States';
        IDSM.profileid=profiles.Id;
        IDSM.Default_Country__c = 'United States';
        IDSM.Country = 'United States';
        IDSM.email='denem16777@deneme.com';
        IDSM.username='denem16777@deneme1.com';
        IDSM.alias='denem16';
        IDSM.languagelocalekey='en_US';
        IDSM.localesidkey='en_US';
        IDSM.timezonesidkey='America/Los_Angeles';
        IDSM.localesidkey='en_US';
        IDSM.EmailEncodingKey= 'ISO-8859-1';
        insert IDSM;
        
        
        test.startTest();
        String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new SchedulerToSendTaskReportCheckReminder());
        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();
    }
    
}