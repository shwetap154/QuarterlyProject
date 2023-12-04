/**
 * Test class for Logger_Extension
 * @author Ethan Hirsch @ Zoetis Inc
 * @since 01-20-2023
 * Ver   Date         Author                      Modification
 * 1.0   01-20-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for buildLogMessageWithRecordIdList and errorLogIfSaveError
 */
@isTest
private class Logger_ExtensionTest {
    private static final String testMessage = 'Test {0}';
    private static final String testMessageValue = 'Test';

    @isTest
    private static void buildLogMessageWithRecordIdList_Test() {
        List<Account> accounts = new List<Account>{
            new Account(Id = '0017h00000ttaR2AAI'),
            new Account(Id = '0017h00000uXgUhAAK'),
            new Account(Id = '0017h00000vdjxuAAA'),
            new Account(Id = '0017h00000w9IIQAA2')
        };

        Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();

        // Both overloads are tested to be safe
        Test.startTest();
            LogMessage logMessageOne = Logger_Extension.buildLogMessageWithRecordIdList(
                'Test Message 1 with Account Ids: {0}', accounts);

            LogMessage logMesageTwo = Logger_Extension.buildLogMessageWithRecordIdList(
                'Test Message 2 with Account Ids: {0}', accountIds);
        Test.stopTest();

        String joinedAccountIds = String.join((Iterable<String>)accountIds, ', ');
        Assert.areEqual(
            String.format('Test Message 1 with Account Ids: {0}',
            new List<String> {joinedAccountIds}),
            logMessageOne.getMessage());

        Assert.areEqual(
            String.format('Test Message 2 with Account Ids: {0}',
            new List<String> {joinedAccountIds}),
            logMesageTwo.getMessage());
    }

    @isTest
    private static void errorLogIfSaveError_CreateLogEntry_Test() {
        List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(5);
        for (Account account : accounts) {
            // Clear name on Account so they fail to insert.
            account.Name = null;
        }

        List<Database.SaveResult> saveResults = Database.insert(accounts, false);
        
        Test.startTest();
            Logger_Extension.errorLogIfSaveError(new LogMessage(testMessage, testMessageValue), accounts, saveResults);
            Logger.saveLog();
        Test.stopTest();
        
        assertSaveErrorLog(true, false);
    }

    @isTest
    private static void errorLogIfSaveError_CreateLogEntryNotifyAdmin_Test() {
        List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(5);
        for (Account account : accounts) {
            // Clear name on Account so they fail to insert.
            account.Name = null;
        }

        List<Database.SaveResult> saveResults = Database.insert(accounts, false);
        
        Test.startTest();
            Logger_Extension.errorLogIfSaveError(new LogMessage(testMessage, testMessageValue), accounts, saveResults,
                true);

            Logger.saveLog();
        Test.stopTest();

        assertSaveErrorLog(true, true);
    }

    @isTest
    private static void errorLogIfSaveError_CreateLogEntry_NoRecords_Test() {
        List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(5);
        for (Account account : accounts) {
            // Clear name on Account so they fail to insert.
            account.Name = null;
        }

        List<Database.SaveResult> saveResults = Database.insert(accounts, false);
        
        Test.startTest();
            Logger_Extension.errorLogIfSaveError(new LogMessage(testMessage, testMessageValue), new List<Account>(),
                saveResults, true);

            Logger.saveLog();
        Test.stopTest();

        assertSaveErrorLog(false, true);
    }

    // If the records list and saveResults are not parallel, a Log should still be created. No error should occur either.
    @isTest
    private static void errorLogIfSaveError_CreateLogEntry_UnevenRecords_Test() {
        List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(5);
        for (Account account : accounts) {
            // Clear name on Account so they fail to insert.
            account.Name = null;
        }

        List<Database.SaveResult> saveResults = Database.insert(accounts, false);
        
        Test.startTest();
            Logger_Extension.errorLogIfSaveError(new LogMessage(testMessage, testMessageValue),
                new List<Account> {accounts[0]}, saveResults);
            Logger.saveLog();
        Test.stopTest();

        assertSaveErrorLog(true, false);
    }

    @isTest
    private static void errorLogIfSaveError_CreateLogEntry_TextMessage_Test() {
        List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(5);
        for (Account account : accounts) {
            // Clear name on Account so they fail to insert.
            account.Name = null;
        }

        List<Database.SaveResult> saveResults = Database.insert(accounts, false);
        
        Test.startTest();
            Logger_Extension.errorLogIfSaveError('Test Test', accounts, saveResults, false);
            Logger.saveLog();
        Test.stopTest();
        
        assertSaveErrorLog(true, false);
    }

    @isTest
    private static void errorLogIfSaveError_DoNotCreateLogEntry_Test() {
        List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(5);

        // Bypass Triggers to speed up performance
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        List<Database.SaveResult> saveResults = Database.insert(accounts, false);
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        Test.startTest();
            Logger_Extension.errorLogIfSaveError(new LogMessage(testMessage, testMessageValue), accounts, saveResults);
            Logger.saveLog();
        Test.stopTest();
        
        List<LogEntry__c> logEntries = [
            SELECT Id
            FROM LogEntry__c
            WHERE Log__r.OwnerId =: UserInfo.getUserId()
        ];

        Assert.isTrue(logEntries.isEmpty(), 'Log Entries were created unexpectedly.');
    }

    private static void assertSaveErrorLog(Boolean expectRecords, Boolean expectTag) {
        List<LogEntry__c> logEntries = [
            SELECT Id, Message__c, HasRecordJson__c, HasRecordId__c, HasDatabaseResult__c,
                (SELECT Id, Tag__r.Name FROM LogEntryTags__r)
            FROM LogEntry__c
            WHERE Log__r.OwnerId =: UserInfo.getUserId()
        ];

        Assert.areEqual(1, logEntries.size(), 'More/Less Log Entries than expected were created.');

        LogEntry__c testEntry = logEntries[0];

        Assert.areEqual('Test Test', testEntry.Message__c, 'Unexpected Error Message');
        
        if (expectRecords) {
            // To avoid needing to recreate the JSON logic, Record JSON is just verified to not be null
            Assert.isTrue(testEntry.HasRecordJson__c, 'Record JSON should be populated.');
        }
        else {
            Assert.isFalse(testEntry.HasRecordJson__c, 'Record JSON should not be populated.');
        }

        Assert.isTrue(testEntry.HasDatabaseResult__c, 'Database Result JSON should be populated.');

        if (expectTag) {
            Assert.areEqual(1, testEntry.LogEntryTags__r.size(),
                'More/Less Log Entry Tags were created than expected.');

            LogEntryTag__c tag = testEntry.LogEntryTags__r[0];

            Assert.areEqual(System.Label.Logger_Notify_Admin_Tag, tag.Tag__r.Name, 'Unexpected Tag Name');
        }
        else {
            Assert.isTrue(testEntry.LogEntryTags__r.isEmpty(), 'Unexpected Log Entries Tags were created.');
        }
    }

}