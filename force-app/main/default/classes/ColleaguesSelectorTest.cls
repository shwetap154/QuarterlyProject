/**
 * @description       : Test class for ColleaguesSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-07-2022   Ethan Hirsch @ Zoetis Inc   Initial Version
**/
@isTest
private class ColleaguesSelectorTest {
    private static final String intlUserUserNameTemplate = 'testintlUser@zoetis.com.ColleaguesSelectorTest';
    private static final Integer maxRecordCount = 5;
    private static final Integer colleaguePerCall = 2;

    private static final String commonErrorMessage = 'More/Less Colleagues exist than expected';

    @TestSetup
    static void setup(){
        Id adminProfileId = [SELECT Id from Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        List<User> intlUsers = new List<User>();
        for (Integer i = 0; i < maxRecordCount; i++) {
            User testUser = TestDataFactory.createUser(adminProfileId, false);
            testUser.Username = string.format('{0}{1}', new List<Object> {intlUserUserNameTemplate, i});

            intlUsers.add(testUser);
        }

        insert intlUsers;

        Territory2 territory;
        // Create Territory in a separate context to avoid Mixed DML
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Territory2Type territoryType = [
                SELECT Id, DeveloperName
                FROM Territory2Type
                LIMIT 1];

            Territory2Model territoryModel = new Territory2Model();
            territoryModel.DeveloperName = 'TestModel';
            territoryModel.Name = 'TestModel';
            insert territoryModel;

            territory = new Territory2();
            territory.AccountAccessLevel = 'Edit';
            territory.CaseAccessLevel = 'Edit';
            territory.DeveloperName = 'TestTerritory';
            territory.Name = 'TestTerritory';
            territory.OpportunityAccessLevel = 'Edit';
            territory.Territory2ModelId = territoryModel.Id;
            territory.Territory2TypeId = territoryType.Id;
            insert territory;
        }

        ZTS_EU_Territory__c testTerritory = TestDataFactory.createZTSTerritory(
            'TestTerritoryUK',
            territory.Id,
            'United Kingdom',
            false);

        List<ZTS_EU_Position__c> positionList = new List<ZTS_EU_Position__c>();
        for (User userRecord : intlUsers) {
            ZTS_EU_Position__c tempPosition = TestDataFactory.createPosition(
                testTerritory.Name,
                testTerritory.Id,
                testTerritory.ZTS_EU_Market__c,
                userRecord.Id,
                false);

            positionList.add(tempPosition);
        }
        insert positionList;

        State_Country__c stateCountryUK = TestDataFactory.createStateCountry(
            'United Kingdom',
            'County Down',
            false
        );

        insert stateCountryUK;

        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < maxRecordCount; i++) {
            Account acct = TestDataFactory.createAccount_EU(
                string.format('UK Test Account {0}', new List<Object> {i}),
                stateCountryUK.Id,
                false);

            accounts.add(acct);
        }

        // Account Positions will automatically be created for the Account and Users on insert of Account.
        insert accounts;


        List<Call__c> calls = new List<Call__c>();
        for (Account account : accounts) {
            calls.add(TestDataFactory.createCall(account.Id, false));
        }

        // A Colleague record will be automatically created for intlUser[0] on all Calls.
        System.runAs(intlUsers[0]) {
            insert calls;
        }

        List<ZTS_EU_Colleague__c> colleagues = new List<ZTS_EU_Colleague__c>();
        for (Integer i = 1; i < maxRecordCount; i++) {
            colleagues.add(TestDataFactory.createColleague(calls[i].Id, intlUsers[i].Id));
        }

        // Make each Call have 2 Colleagues by adding one more Colleague to the first Call.
        colleagues.add(TestDataFactory.createColleague(calls[0].Id, intlUsers[1].Id));

        insert colleagues;
    }

    @isTest
    static void getRecordListById_Test() {
        Set<Id> colleagueIds = new Map<Id, ZTS_EU_Colleague__c>([SELECT ID FROM ZTS_EU_Colleague__c]).keySet();

        Test.startTest();
            List<ZTS_EU_Colleague__c> colleagues = ColleaguesSelector.newInstance().selectById(colleagueIds);
        Test.stopTest();

        System.assertEquals(maxRecordCount * colleaguePerCall, colleagues.size(), commonErrorMessage);
    }

    @isTest
    static void getRecordListByCallAccountId_Test() {
        Set<Id> accountIds = new Map<Id, Account>([SELECT Id FROM Account LIMIT 2]).keySet();

        System.assertEquals(2, accountIds.size(), 'More/Less Accounts than expected were returned');

        Test.startTest();
            List<ZTS_EU_Colleague__c> colleagues = ColleaguesSelector.newInstance().selectByCallAccountId(accountIds);
        Test.stopTest();

        System.assertEquals(accountIds.size() * colleaguePerCall, colleagues.size(), commonErrorMessage);
    }

    @isTest
    static void getRecordListByCallAccountIdExcludeCallIds_Test() {
        Set<Id> accountIds = new Map<Id, Account>([SELECT Id FROM Account LIMIT: maxRecordCount]).keySet();
        System.assertEquals(maxRecordCount, accountIds.size(), 'More/Less Accounts than expected were returned');

        Set<Id> excludeCallIds = new Map<Id, Call__c>([SELECT Id FROM Call__c LIMIT 2]).keySet();

        System.assertEquals(2, excludeCallIds.size(), 'More/Less Calls than expected were returned.');

        Test.startTest();
            List<ZTS_EU_Colleague__c> colleagues = ColleaguesSelector.newInstance().selectByCallAccountIdExcludeCallIds(
                accountIds, excludeCallIds);
        Test.stopTest();

        System.assertEquals((maxRecordCount - excludeCallIds.size()) * colleaguePerCall,
            colleagues.size(), commonErrorMessage);
    }

    @isTest
    static void getRecordListByCallAccountIdAndUserId_Test() {
        Set<Id> accountIds = new Map<Id, Account>([SELECT Id FROM Account LIMIT: maxRecordCount]).keySet();
        System.assertEquals(maxRecordCount, accountIds.size(), 'More/Less Accounts than expected were returned');

        // The first User returned is added to every Call and will return 1 result per call.
        string userNameFilter = string.format('{0}0', new List<String> {intlUserUserNameTemplate});
        Set<Id> userIds = new Map<Id, User>([SELECT ID FROM USER WHERE Username LIKE:userNameFilter LIMIT 1]).keySet();

        System.assertEquals(1, userIds.size(), 'More/Less Users than expected were returned.');

        Test.startTest();
            List<ZTS_EU_Colleague__c> colleagues = ColleaguesSelector.newInstance().selectByCallAccountIdAndUserId(
                accountIds, userIds);
        Test.stopTest();

        System.assertEquals(maxRecordCount, colleagues.size(), commonErrorMessage);
    }

    @isTest
    static void getRecordListByCallAccountIdAndUserIdAndExcludeColleagueIds() {
        Set<Id> accountIds = new Map<Id, Account>([SELECT Id FROM Account LIMIT: maxRecordCount]).keySet();
        System.assertEquals(maxRecordCount, accountIds.size(), 'More/Less Accounts than expected were returned');

        string userNameFilter = string.format('{0}%', new List<String> {intlUserUserNameTemplate});
        Set<Id> userIds = new Map<Id, User>([SELECT ID FROM USER WHERE Username LIKE:userNameFilter]).keySet();

        System.assertEquals(maxRecordCount, userIds.size(), 'More/Less Users than expected were returned.');

        Set<Id> colleagueIds = new Map<Id, ZTS_EU_Colleague__c>(
            [SELECT ID FROM ZTS_EU_Colleague__c LIMIT 2]).keySet();

        System.assertEquals(2, colleagueIds.size(), 'More/Less Colleagues than expected were returned.');

        Test.startTest();
            List<ZTS_EU_Colleague__c> colleagues = 
                ColleaguesSelector.newInstance().selectByCallAccountIdAndUserIdAndExcludeColleagueIds(
                    accountIds, userIds, colleagueIds);
        Test.stopTest();

        System.assertEquals(maxRecordCount * colleaguePerCall - colleagueIds.size(),
            colleagues.size(), commonErrorMessage);
    }
}