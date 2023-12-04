/**
 * @description       : Test class for BatchEmailForCallToManagerSchedule
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 08-08-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-22-2022   Unknown                     Initial Version with single tests
 * 1.1   08-08-2022   Ethan Hirsch @ Zoetis Inc   Setup test data and pass in the new Users to avoid limit exceptions in tests
**/
@isTest
public class BatchEmailForCallToManagerSchedule_Test {
    public static String ch='0 0 23 * * ?';
    @isTest static void testschedule()
    {
        List<Call_Reminder_Territories__mdt> callReminderTerritories = [
            SELECT Id, Territory_Name__c
            FROM Call_Reminder_Territories__mdt
            WHERE Territory_Name__c != null
            LIMIT 3];
            
        Id adminProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1].Id;

        List<User> users = new List<User>();
        for (Call_Reminder_Territories__mdt callReminderTerritory : callReminderTerritories) {
            User testUser = TestDataFactory.createUser(adminProfileId, false);
            testUser.Territory__c = callReminderTerritory.Territory_Name__c;
            testUser.Manager_Call_Reminder_Scheduled_Date__c = System.today();
            testUser.ManagerId = UserInfo.getUserId();

            users.add(testUser);
        }

        insert users;

        Account testAccount = TestDataFactory.createAccount_US('Test Account', true);

        List<Call__c> testCalls = new List<Call__c>();
        for (User user : users) {
            Call__c testCall = TestDataFactory.createCall(testAccount.Id, false);

            testCall.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2015, 9, 1, 12, 30, 2);        
            testCall.ZTS_EU_End_Date_Time__c = datetime.newInstance(2015, 9, 1, 12, 30, 2).addHours(1);
            testCall.ZTS_EU_Submitted_Date__c=datetime.newInstance(2017, 9, 1, 12, 30, 2);
            testCall.ZTS_EU_Status__c='Submitted';
            testCall.ZTS_EU_Sub_Type__c = 'Account Call';   
            testCall.ZTS_EU_Call_Owner__c = user.Id;

            testCalls.add(testCall);
        }

        // Bypass the Call Trigger to save processing time and field overrides
        DispatchTriggerHandler.bypass('CallTriggerHandler');
        insert testCalls;
        DispatchTriggerHandler.clearBypass('CallTriggerHandler');

        Test.startTest();
        BatchEmailForCallToManagerSchedule acc2=new BatchEmailForCallToManagerSchedule();
        BatchToSendEmailForCallToManager.testUsers = users;
        system.schedule('Test call to manager schedule',ch,acc2);
        test.stoptest();
        
        // No assertions are done because asserting User data causes the batch job not to run
    }

}