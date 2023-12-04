/****************************************************************************************************************************************** 
 * Class Name       : TaskDueDateBreachEmailtoDirector_Test
 * Description      : Test Class for BatchToNotifyTaskDueDateBreachToDirector.cls (SC-009405)                               
 * Created By       : Aritra(Cognizant)
 * Created Date     : 24-March-2022
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)       24-March-2022       Created  (SC-009405)
*****************************************************************************************************************************************/
@istest
public class TaskDueDateBreachEmailtoDirector_Test {
    
    @TestSetup
    static void setupData(){
        Account acc = new Account();         
        acc.name = 'Test Account';
        acc.Type = 'Farm';
        acc.ZTS_EU_Account_Official_Name__c = 'test';
        acc.ZTS_EU_Sub_Type__c = 'Beef';
        acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
        acc.BillingCity = 'Test City';
        acc.BillingPostalCode = '12345';
        acc.BillingState = 'Test';
        acc.BillingStreet = 'test street';
        acc.ZTS_EU_Main_Phone__c='9876789876';
        acc.ZTS_EU_Market__c= 'United States';
        
        
        Profile profiles=[Select Id From Profile Where Name='US Small Animal Manager'];
        
        User director = new user();
        director.FirstName = 'Director';    
        director.LastName = 'Brown';
        director.ZTS_EU_Market__c = 'United States';
        director.profileid=profiles.Id;
        director.Default_Country__c = 'United States';
        director.Country = 'United States';
        director.email='denem2e@deneme.com';
        director.username='deneme2@deneme1.com';
        director.alias='dene2';
        director.languagelocalekey='en_US';
        director.localesidkey='en_US';
        director.timezonesidkey='America/Los_Angeles';
        director.localesidkey='en_US';
        director.EmailEncodingKey= 'ISO-8859-1';
        insert director;
        
        User manager = new user();
        manager.FirstName='Manager';   
        manager.LastName = 'Mike';
        manager.ZTS_EU_Market__c = 'United States';
        manager.profileid=profiles.Id;
        manager.Default_Country__c = 'United States';
        manager.Country = 'United States';
        manager.email='denem1e@deneme.com';
        manager.username='deneme1@deneme1.com';
        manager.alias='dene1';
        manager.languagelocalekey='en_US';
        manager.localesidkey='en_US';
        manager.timezonesidkey='America/Los_Angeles';
        manager.localesidkey='en_US';
        manager.EmailEncodingKey= 'ISO-8859-1';
        manager.ManagerId=director.Id;
        insert manager;
        
        Profile profile2=[Select Id From Profile Where Name='US Small Animal Rep'];
        user rep = new user();
        rep.FirstName='Rep2';   
        rep.LastName = 'ket';
        rep.ZTS_EU_Market__c = 'United States';
        rep.profileid=profile2.Id;
        rep.Default_Country__c = 'United States';
        rep.Country = 'United States';
        rep.Territory__c='US-Terr-6921';
        rep.email='denem3e@deneme.com';
        rep.username='deneme3@deneme1.com';
        rep.alias='dene3';
        rep.languagelocalekey='en_US';
        rep.localesidkey='en_US';
        rep.timezonesidkey='America/Los_Angeles';
        rep.localesidkey='en_US';
        rep.EmailEncodingKey= 'ISO-8859-1';
        rep.ManagerId=manager.Id;
        insert rep;
        
       
        Task tsk = new Task();
        
        System.runAs(rep){
            
            insert acc;
                     
            tsk.activityDate = date.today().addDays(-8);   
            tsk.WhatId = acc.Id;
            tsk.Status='Not Started';
            tsk.Subject = 'Test Task';   
            tsk.OwnerId = rep.Id;
            tsk.DueDateBreachNotifiedtoDirector__c = false;
            insert tsk;
        }
        
        Task t = [Select DirectorUserId__c,DueDateBreachNotifiedtoDirector__c,activityDate,Status,ZTS_EU_Market__c from Task where id = :tsk.Id limit 1];
        system.debug('task ->'+ t);
        
        
    }
    
    public static testMethod void testschedulerjob(){
        
        Profile profiles=[Select Id From Profile Where Name='System Administrator'];
        
        User runninguser = new user();
        runninguser.FirstName = 'sys Admin';    
        runninguser.LastName = 'Brown';
        runninguser.ZTS_EU_Market__c = 'United States';
        runninguser.profileid=profiles.Id;
        runninguser.Default_Country__c = 'United States';
        runninguser.Country = 'United States';
        runninguser.email='denem344e@deneme.com';
        runninguser.username='deneme344e@deneme1.com';
        runninguser.alias='dene344';
        runninguser.languagelocalekey='en_US';
        runninguser.localesidkey='en_US';
        runninguser.timezonesidkey='America/Los_Angeles';
        runninguser.localesidkey='en_US';
        runninguser.EmailEncodingKey= 'ISO-8859-1';
        insert runninguser;
        
        system.runAs(runninguser)
        {
            test.startTest();
        String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new SchedulerTaskDueDateBreachNotifyDirector());
        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();
        }
    }
    
}