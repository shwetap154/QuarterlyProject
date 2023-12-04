/****************************************************************************************************************************************** 
 * Class Name   : TasksTranlsateTriggerTest
 * Description  : This is test class for task trigger and classes DEF-001251.     
 * Created By   : CloudSense(Sohil Shah) 
 * Created Date : 4th June, 2015
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sohil Shah           06/04/2015          Created 
*****************************************************************************************************************************************/
@isTest
public class TasksTranlsateTriggerTest
{
     static testmethod void TestTasksTranlsateTrigger()
    {
        

            Recordtype recordType = [select Id, Name from Recordtype where Name = 'Activated Account'];
        	User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'eltonUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;
            Account acc = new Account(recordTypeId = recordType.id, Name='Test',Type='Analyst', ZTS_EU_Market__c = 'United Kingdom', Practice_Management_Software__c = 'Other', Other_Practice_Management_Software__c = 'Sample Practice Management Software');
            System.runAs(usr)
            {
            	insert acc;    
            }	
        	
            Call__c call = new Call__c(ZTS_EU_Account__c = acc.id,ZTS_EU_Sub_Type__c = 'Account Call',ZTS_EU_Start_Date_Time__c=datetime.newInstance(2014, 9, 15, 12, 30, 0));
            insert call;
            
        
            List<Task> tsList = new List<Task>();   
            Task ts = new Task(Sub_Type__c = 'Account Call with Speaker',WhatId = call.id);
            tsList.add(ts);
            Task ts1 = new Task(Sub_Type__c = 'Advisory / Diagnostic visit',WhatId = call.id);
            tsList.add(ts1);
            Task ts2 = new Task(Sub_Type__c = 'Clinical - Seedings initial',WhatId = call.id);
            tsList.add(ts2);
            Task ts3 = new Task(Sub_Type__c = 'Demonstration / PPE',WhatId = call.id);
            tsList.add(ts3);
            Task ts4 = new Task(Sub_Type__c = 'ICP / DMA visit',WhatId = call.id);
            tsList.add(ts4);
            Task ts5 = new Task(Sub_Type__c = 'Loyalty / VAS visit',WhatId = call.id);
            tsList.add(ts5);
            Task ts6 = new Task(Sub_Type__c = 'PBC Call',WhatId = call.id);
            tsList.add(ts6);
            Task ts7 = new Task(Sub_Type__c = 'Practice Discussion Group', CallRecordId__c = call.id,WhatId = call.id);
            tsList.add(ts7);
            insert tsList;
            
            String query = 'Select Id, Sub_Type__c,WhatId from Task where id IN:tsList';
            Test.startTest();    
            TaskUpdateOnInsert.updatTaskOnInsert(tsList);
            taskUpdate.updateTaskOnInsert(tsList);
            Test.stopTest();
        }   
    }