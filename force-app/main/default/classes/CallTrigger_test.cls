/*******************************************************************************************************************************************
* File Name     :  CallTrigger_test
* Description   :  Test class for Call Trigger
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     1/04/16          Priya              Created the Class.

********************************************************************************************************************************************/
@isTest
public class CallTrigger_test {

    @IsTest
    static void Createcall(){
        // TriggerActivation__c triActivation = new TriggerActivation__c(Name = 'CallTrigger', ZTS_EU_Bypass__c = true);
        // insert triActivation;
        list<user> userlst = ZTS_EU_DataUtilityTest1.createchocheUser(1);
        insert userlst;

        List<ZTS_EU_Colleague__c> col;
        Test.startTest();
            list<call__c> calllst= ZTS_EU_DataUtilityTest1.createCallRecord(1);
            insert calllst;
            
            col = [SELECT id FROM ZTS_EU_Colleague__c];

            calllst[0].name = 'test';
            update calllst;
            delete calllst;
        Test.stopTest();

        List<Event> newEvents = [SELECT Id FROM Event];
        System.debug('$$$ new events'+newEvents);
        System.assert(!newEvents.isEmpty());
        System.assert(!col.isEmpty());
    }

    @IsTest
    static void testTrigger() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        Account acc = new Account();
        acc.Name = 'Test123';
        acc.ZTS_EU_Market__c = 'United Kingdom';
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        System.runAs(usr)
        {
            insert acc;
        }

        PIT_Coaching_Guide__c cg = new PIT_Coaching_Guide__c();
        cg.PIT_Coach__c = Userinfo.getUserId();
        cg.PIT_Coaching_Status__c = 'New';
        cg.PIT_Colleague__c = Userinfo.getUserId();
        cg.PIT_Colleague_Comments__c = 'comments123';
        cg.ZTS_EU_Market__c = 'United Kingdom';
        insert cg;

        List<ZTS_EU_Colleague__c> col;
        Test.startTest();
            Call__c c1 = new Call__c();
            c1.ZTS_EU_Status__c = 'Submitted';
            c1.ZTS_EU_Start_Date_Time__c = System.now().addDays(-1);
            c1.ZTS_EU_End_Date_Time__c = System.now();
            c1.PIT_Coaching_Guide__c = cg.Id;
            c1.ZTS_EU_Account__c = acc.Id;
            insert c1;

            col = [SELECT id FROM ZTS_EU_Colleague__c];

            c1.Name = 'tester';
            update c1;

            delete c1;
        Test.stopTest();

        List<Event> newEvents = [SELECT Id FROM Event];
        System.assert(!newEvents.isEmpty());
        System.assert(!col.isEmpty());
    }
}