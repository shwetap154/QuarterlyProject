/**
 * @description       : Test class for BatchEmailForCallSubmissionSchedule
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 07-27-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   11-22-2021   Unknown                      Initial Version
 * 1.1   07-27-2022   Ethan Hirsch @ Zoetis Inc    Setup a User to set in testUserId to fix a failing Unit Test.
**/
@isTest
public class BatchEmailForCallSubmissionSchedule_Test {
    public static String ch='0 0 23 * * ?';
    @isTest static void testschedule()
    {
        User testUser = TestDataFactory.createUser(
            [SELECT ID FROM PROFILE WHERE NAME = 'System Administrator' LIMIT 1].Id, 
            false);

        testUser.Territory__c='US-Terr-6921';
        insert testUser;
        
        Test.startTest();
        BatchEmailForCallSubmissionSchedule acc2=new BatchEmailForCallSubmissionSchedule();
        BatchToSendEmailForCallSubmission.testUserId = testUser.Id;
        system.schedule('Test call to rep schedule',ch,acc2);
        test.stoptest();
        
    }

}