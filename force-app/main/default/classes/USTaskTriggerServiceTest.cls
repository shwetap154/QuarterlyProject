@isTest
public with sharing class USTaskTriggerServiceTest {

    static final Id CASE_RT_ID = [SELECT Id FROM RecordType WHERE DeveloperName = 'ZTS_US_SER_Genetics_I_Want_a_Rep' AND SObjectType = 'Case'][0].Id;
    static final String US_USER_FN = 'usUser';
    static final String TASK_OWNER_FN = 'taskOwner';

    @TestSetup
    static void dataSetup(){
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = US_USER_FN;
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {

            User taskOwner = new User();
            taskOwner = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            taskOwner.FirstName = TASK_OWNER_FN;
            taskOwner.zts_eu_market__c = 'United States';
            insert taskOwner;

            List<Account> testAccount = ZTS_DataUtilityTest.createAccountRecord(1, 1);
            testAccount[0].ZTS_EU_Market__c = 'United States';
            insert testAccount;

            Call__c testCall = new Call__c(ZTS_EU_Account__c=testAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
            insert testCall;

            Case testCase = new Case(Subject='Test Controller Acct Case', Status = 'Open', RecordTypeId = CASE_RT_ID);
            insert testCase;
            

        }
    }
    
    @isTest
    static void afterInsertTest_Call() {

        User usUser = [SELECT Id FROM User WHERE FirstName = :US_USER_FN][0];
        User taskOwnerUser = [SELECT Id FROM User WHERE FirstName = :TASK_OWNER_FN][0];
        Call__c testCall = [SELECT Id FROM Call__c ][0];
        Task testTask = new Task(OwnerId = taskOwnerUser.Id,
            WhatId = testCall.Id, 
            Subject = 'Test Subject', 
            priority = 'Low', 
            Status = 'Call',
            ActivityDate = Date.today() + 7
        );

        System.runas(usUser) {
            Integer emailsBefore = Limits.getEmailInvocations();
            Test.startTest();
                insert testTask;
                Integer emailsAfter = Limits.getEmailInvocations();
            Test.stopTest();
    
            //System.assertEquals(2, emailsAfter-emailsBefore, 'An email should have been sent');
        }
    }
    
    @isTest
    static void afterInsertTest_Case() {

        User usUser = [SELECT Id FROM User WHERE FirstName = :US_USER_FN][0];
        User taskOwnerUser = [SELECT Id FROM User WHERE FirstName = :TASK_OWNER_FN][0];
        Case testCase = [SELECT Id FROM Case ][0];
        Task testTask = new Task(OwnerId = taskOwnerUser.Id,
            WhatId = testCase.Id, 
            Subject = 'Test Subject', 
            priority = 'Low', 
            Status = 'Call',
            ActivityDate = Date.today() + 7
        );

        System.runas(usUser) {
            Integer emailsBefore = Limits.getEmailInvocations();
            Test.startTest();
                insert testTask;
                Integer emailsAfter = Limits.getEmailInvocations();
            Test.stopTest();
    
           // System.assertEquals(2, emailsAfter-emailsBefore, 'An email should have been sent');
        }
    }

    @isTest
    static void beforeUpdateTest_Call() {

        User usUser = [SELECT Id FROM User WHERE FirstName = :US_USER_FN][0];
        User taskOwnerUser = [SELECT Id FROM User WHERE FirstName = :TASK_OWNER_FN][0];
        Call__c testCall = [SELECT Id FROM Call__c ][0];
        System.runas(usUser) {

            Task testTask = new Task(OwnerId = taskOwnerUser.Id,
                WhatId = testCall.Id, 
                Subject = 'Test Subject', 
                priority = 'Low', 
                Status = 'Waiting on Customer',
                ActivityDate = Date.today() + 7
            );
            insert testTask;

            Task requeriedTask = [SELECT Id, Status FROM Task WHERE Id = :testTask.Id];
            Date myDate = Date.newInstance(2000, 11, 18);
            Time myTime = Time.newInstance(3, 3, 3, 0);
            DateTime startDate = DateTime.newInstance(2021, 1, 4, 8, 0, 0);
            DateTime endDate = startDate.addMinutes(6);
            requeriedTask.ZTS_US_TASK_Waiting_Start_Time__c =  startDate;
            requeriedTask.ZTS_US_TASK_Waiting_End_Time__c = endDate;
            //requeriedTask.ZTS_US_TASK_Waiting_Start_Time__c =  System.now();
            //requeriedTask.ZTS_US_TASK_Waiting_End_Time__c = System.now().addMinutes(6);
            requeriedTask.Status = 'Call';

            Test.startTest();
                DispatchTriggerHandler.firstTimeTracker = new Set<String>();
                update requeriedTask;
            Test.stopTest();
            
            Task actualTask = [SELECT Id, Total__c FROM Task WHERE Id = :testTask.Id];

            System.assertEquals(0.1, actualTask.Total__c, 'Total should be updated');
        }
    }
    
    @isTest
    static void afterUpdateTest_Case() {

        User usUser = [SELECT Id FROM User WHERE FirstName = :US_USER_FN][0];
        User taskOwnerUser = [SELECT Id FROM User WHERE FirstName = :TASK_OWNER_FN][0];
        Case testCase = [SELECT Id FROM Case ][0];
        System.runas(usUser) {

            ZTS_US_SER_AutoCaseClosureOnTaskClosure__c csRecord = new ZTS_US_SER_AutoCaseClosureOnTaskClosure__c();
            csRecord.Name = 'Open Service Request';
            insert csRecord;

            Task testTask = new Task(OwnerId = taskOwnerUser.Id,
                WhatId = testCase.Id, 
                Subject = 'Test Subject', 
                priority = 'Low', 
                Status = 'Call',
                ActivityDate = Date.today() + 7
            );
            insert testTask;

            Task requeriedTask = [SELECT Id, Status FROM Task WHERE Id = :testTask.Id];
            Date myDate = Date.newInstance(2000, 11, 18);
            Time myTime = Time.newInstance(3, 3, 3, 0);
            DateTime startDate = DateTime.newInstance(2021, 1, 4, 8, 0, 0);
            DateTime endDate = startDate.addMinutes(6);
            requeriedTask.ZTS_US_TASK_Waiting_Start_Time__c =  startDate;
            requeriedTask.ZTS_US_TASK_Waiting_End_Time__c = endDate;
            // requeriedTask.ZTS_US_TASK_Waiting_Start_Time__c = System.now();
            // requeriedTask.ZTS_US_TASK_Waiting_End_Time__c = System.now().addMinutes(6);
            requeriedTask.Status = 'Completed';

            Test.startTest();
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            update requeriedTask;
            Test.stopTest();
            
            Case actualCase = [SELECT Id, Status, ZTS_US_Customer_Reaction_on_Case_Closure__c, ZTS_US_SER_Open_Tasks__c FROM Case WHERE Id = :testCase.Id];
            
            System.assertEquals('Closed',actualCase.Status, 'Case status should be updated to closed');
            System.assertEquals('Neutral',actualCase.ZTS_US_Customer_Reaction_on_Case_Closure__c, 'Case ZTS_US_Customer_Reaction_on_Case_Closure__c should be updated to neutral');
            System.assertEquals(false,actualCase.ZTS_US_SER_Open_Tasks__c, 'Case ZTS_US_SER_Open_Tasks__c should be updated to false');

        }

    }
}