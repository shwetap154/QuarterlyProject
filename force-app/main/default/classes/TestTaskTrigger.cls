/**
 * @description       : Test class for TaskTrigger
 * @author            : David Stern @ Slalom
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   02-06-2020   David Stern @ Slalom          Initial Version
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc     Change Usernames to be more unique
**/
@IsTest
private class TestTaskTrigger{
     static testmethod void afteInsertTest (){    
     Test.starttest();
     ZTS_DataUtilityTest.activateTriggerSettings();
           Profile pf = [Select Id from Profile where Name = 'US Small Animal Rep'];
             User u = new User();
                //u.FirstName = 'Test';
                u.LastName = 'Nicomatic2';
                u.Email = 'test@gmail.com.sandbox';
                u.CompanyName = 'test.com';
                u.Title = 'Test User';
                u.Username = 'nicomatic@zoetis.com.testtasktriggerUser';
                u.Alias = 'ni';
                u.CommunityNickname = 'ni';
                u.TimeZoneSidKey = 'America/Mexico_City';
                u.LocaleSidKey = 'en_US';
                u.EmailEncodingKey = 'ISO-8859-1';
                u.ProfileId = pf.Id;
                u.LanguageLocaleKey = 'en_US';    
                u.ZTS_EU_Market__c = 'United States';  
                insert u;

           User u1 = new User();
                //u.FirstName = 'Test';
                u1.LastName = 'Nicomatic22';
                u1.Email = 'test143@gmail.com.sandbox';
                u1.CompanyName = 'tes1t.com';
                u1.Title = 'Test User1';
                u1.Username = 'nicomatic22@zoetis.com.testtasktriggerUser';
                u1.Alias = 'ni1';
                u1.CommunityNickname = 'ni1';
                u1.TimeZoneSidKey = 'America/Mexico_City';
                u1.LocaleSidKey = 'en_US';
                u1.EmailEncodingKey = 'ISO-8859-1';
                u1.ProfileId = pf.Id;
                u1.LanguageLocaleKey = 'en_US';      
                u1.ZTS_EU_Market__c = 'United States';   
                insert u1;

            
          List<Call__c> calls = ZTS_DataUtilityTest.createCallRecord(2);
           Insert Calls;
           Task t1 = New Task(Subject='test',Priority='Normal',Status='Not started',whatid=calls[0].id,ownerid=u1.id,activitydate=System.today());
               insert t1;
              //system.assertequals(t1.status,'Need identified')  ;  
               
                test.stoptest();  
          
     }
}