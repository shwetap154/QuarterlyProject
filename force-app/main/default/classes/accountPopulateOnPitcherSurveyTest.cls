/**
 * @description       : Test class to test the Account is populating On Pitcher Survey Record.
 * @author            : Sohil Shah(CloudSense) 
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-28-2015   Sohil Shah(CloudSense)      Initial Version
 * 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc   Fix failing Unit Tests due to inactive users.
**/
@isTest
public class accountPopulateOnPitcherSurveyTest
{
    private final static string testAdminUser = 'testAdminUser@zoetis.com.testuser';

    @TestSetup
    static void testDataSetup(){
        
        ZTS_DataUtilityTest.activateTriggerSettings();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'USER';
        usr.zts_eu_market__c = 'United States';
        usr.Username = testAdminUser;
        insert usr;
        
        System.runAs(usr){
            
            List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(2);
            testAccts[0].Name='Test Account1';
            testAccts[0].ZTS_US_Business_Class__c = 'Breeder';
            testAccts[1].Name='Test Account2';
            testAccts[1].ZTS_US_Business_Class__c = 'Breeder';
            
            insert testAccts;
            
            Call__c call = new Call__c(Name = 'Test call 1', ZTS_EU_Account__c = testAccts[0].id, ZTS_EU_Start_Date_Time__c=System.Now(), ZTS_EU_Duration__c ='0.5 Hour' );
            insert call;

            Call__c call2 = new Call__c(Name = 'Test call 3', ZTS_EU_Account__c = testAccts[1].id, ZTS_EU_Start_Date_Time__c=System.Now(), ZTS_EU_Duration__c ='0.7 Hour' );
            insert call2;

        }

    }

    @isTest
    static void accountPopulateOnPitcherSurveyMethod1()
    {
        User systemAdminUser = [SELECT Id FROM User WHERE Username =: testAdminUser AND FirstName = 'USER' AND zts_eu_market__c = 'United States' LIMIT 1];
        
        System.runAs(systemAdminUser){
            
            List<Account> accounts = [SELECT Id FROM Account];
            List<Call__c> calls = [SELECT Id, ZTS_EU_Account__c  FROM Call__c];

            Pitcher_Activity__c pitcherActivity = new Pitcher_Activity__c(Name = 'Test1',Call__c = calls[0].id,ZTS_EU_Market__c = 'United States');
            List<Pitcher_Activity__c> pitcherActivityList = new List<Pitcher_Activity__c>();
            pitcherActivityList.add(pitcherActivity);
            Test.startTest();
            insert pitcherActivityList;
            accountPopulateOnPitcherSurvey accntPopulate = new accountPopulateOnPitcherSurvey();
            accntPopulate.populateAccount(pitcherActivityList);
            Test.stopTest();
            List<Pitcher_Activity__c> pitcherActivityListUpdated = [Select Id, Account__c from Pitcher_Activity__c where id=:pitcherActivityList[0].id ];
            System.assertEquals(accounts[0].id,pitcherActivityListUpdated[0].Account__c);   
        }
    }

    @isTest
    static void accountPopulateOnPitcherSurveyMethod2()
    {
        User systemAdminUser = [SELECT Id FROM User WHERE Username =: testAdminUser AND FirstName = 'USER' AND zts_eu_market__c = 'United States' LIMIT 1];
        
        System.runAs(systemAdminUser){

            List<Account> accounts = [SELECT Id FROM Account];
            List<Call__c> calls = [SELECT Id, ZTS_EU_Account__c  FROM Call__c];

            Pitcher_Activity__c pitcherActivity = new Pitcher_Activity__c(Name = 'Test1',Call__c = calls[0].id,ZTS_EU_Market__c = 'United States');
            List<Pitcher_Activity__c> pitcherActivityList2 = new List<Pitcher_Activity__c>();
            pitcherActivityList2.add(pitcherActivity);
            insert pitcherActivityList2;

            pitcherActivityList2[0].call__c = calls[1].id;
            update pitcherActivityList2;

            List<Pitcher_Activity__c> updatedPitcherList = [SELECT Id, Account__c, Call__r.ZTS_EU_Account__c FROM Pitcher_Activity__c];
            
            Test.startTest();
            accountPopulateOnPitcherSurvey.flag = false;
            accountPopulateOnPitcherSurvey.pitcherActivityListToUpdate = new List<Pitcher_Activity__c>();
            accountPopulateOnPitcherSurvey accntPopulate = new accountPopulateOnPitcherSurvey();
            accntPopulate.populateAccount(updatedPitcherList);
            Test.stopTest();  
            
            List<Pitcher_Activity__c> updatedPitchers = [SELECT Id, Account__c, Call__r.ZTS_EU_Account__c FROM Pitcher_Activity__c];
            System.assertEquals(calls[1].ZTS_EU_Account__c, updatedPitchers[0].Account__c , 'The expected Account Id associated with the Picture Activity is equal to the Call__r.ZTS_EU_Account__c');
        }
    }
}