/**
 * @description       :
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 03-12-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   02-25-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
@isTest
private class ErrorLogCleanUp_BatchTest {
  private static final Integer MAX_RECORDS = 200;
  private static final Date createDate = Date.newInstance(
      System.today().year(),
      System.today().month(),
      System.today().day()
    )
    .addDays(-MAX_RECORDS);

  @testSetup
  static void setup() {
    // Create Org Default Custom Settings
    ErrorLogGlobalSettings__c errorSettings = ErrorLogGlobalSettings__c.getOrgDefaults();
    errorSettings.Maximum_Log_Retention__c = 120;
    upsert errorSettings ErrorLogGlobalSettings__c.Id;
    
    List<ZTS_EU_Error_Log__c> errorLogs = new List<ZTS_EU_Error_Log__c>();
    for (Integer i = 0; i < MAX_RECORDS; i++) {
      ZTS_EU_Error_Log__c log = new ZTS_EU_Error_Log__c();
      log.CreatedDate = createDate.addDays(i);
      log.ZTS_EU_Message__c = 'Message';
      log.ZTS_EU_Log_level__c = ZTS_EU_Logger.Level.ERROR.name();
      log.ZTS_EU_Origin_Type__c = 'Test Class';
      log.ZTS_EU_SObject__c = 'None';
      errorLogs.add(log);
    }

    insert errorLogs;
  }
  static testMethod void ErrorLogCleanUp_30Days_SUCCESS() {
    List<ZTS_EU_Error_Log__c> errorLogs = [
      SELECT Id, CreatedDate
      FROM ZTS_EU_Error_Log__c
      ORDER BY CreatedDate
    ];
    System.assertEquals(
      MAX_RECORDS,
      errorLogs.size(),
      'Error Records should match Max Error Count'
    );
    System.assertEquals(
      createDate,
      errorLogs[0].CreatedDate,
      'First Record in List should match first Created Date'
    );
    System.assertEquals(
      createDate.addDays(9),
      errorLogs[9].CreatedDate,
      'Create Dates should be going up +1 for each new record'
    );
    System.assertEquals(
      System.today().addDays(-1),
      errorLogs[errorLogs.size() - 1].CreatedDate,
      'Last Log should be yesterday'
    );
    ErrorLogCleanUp_Batch.totalLogDays = 30;
    Test.startTest();
    ErrorLogCleanUp_Batch cleanUp = new ErrorLogCleanUp_Batch();
    Database.executeBatch(cleanUp);
    Test.stopTest();
    errorLogs = [
      SELECT Id, CreatedDate
      FROM ZTS_EU_Error_Log__c
      ORDER BY CreatedDate
    ];
    System.assertEquals(
      ErrorLogCleanUp_Batch.totalLogDays - 1,
      errorLogs.size(),
      'Only Logs in the last X days should remain'
    );
  }

  static testMethod void ErrorLogCleanUp_60Days_SUCCESS() {
    List<ZTS_EU_Error_Log__c> errorLogs = [
      SELECT Id, CreatedDate
      FROM ZTS_EU_Error_Log__c
      ORDER BY CreatedDate
    ];
    System.assertEquals(
      MAX_RECORDS,
      errorLogs.size(),
      'Error Records should match Max Error Count'
    );
    System.assertEquals(
      createDate,
      errorLogs[0].CreatedDate,
      'First Record in List should match first Created Date'
    );
    System.assertEquals(
      createDate.addDays(9),
      errorLogs[9].CreatedDate,
      'Create Dates should be going up +1 for each new record'
    );
    System.assertEquals(
      System.today().addDays(-1),
      errorLogs[errorLogs.size() - 1].CreatedDate,
      'Last Log should be yesterday'
    );
    ErrorLogCleanUp_Batch.totalLogDays = 60;
    Test.startTest();
    ErrorLogCleanUp_Batch cleanUp = new ErrorLogCleanUp_Batch();
    Database.executeBatch(cleanUp);
    Test.stopTest();
    errorLogs = [
      SELECT Id, CreatedDate
      FROM ZTS_EU_Error_Log__c
      ORDER BY CreatedDate
    ];
    System.assertEquals(
      ErrorLogCleanUp_Batch.totalLogDays - 1,
      errorLogs.size(),
      'Only Logs in the last X days should remain'
    );
  }

  static testMethod void ErrorLogCleanUp_5Days_SUCCESS() {
    List<ZTS_EU_Error_Log__c> errorLogs = [
      SELECT Id, CreatedDate
      FROM ZTS_EU_Error_Log__c
      ORDER BY CreatedDate
    ];
    System.assertEquals(
      MAX_RECORDS,
      errorLogs.size(),
      'Error Records should match Max Error Count'
    );
    System.assertEquals(
      createDate,
      errorLogs[0].CreatedDate,
      'First Record in List should match first Created Date'
    );
    System.assertEquals(
      createDate.addDays(9),
      errorLogs[9].CreatedDate,
      'Create Dates should be going up +1 for each new record'
    );
    System.assertEquals(
      System.today().addDays(-1),
      errorLogs[errorLogs.size() - 1].CreatedDate,
      'Last Log should be yesterday'
    );
    ErrorLogCleanUp_Batch.totalLogDays = 5;
    Test.startTest();
    ErrorLogCleanUp_Batch cleanUp = new ErrorLogCleanUp_Batch();
    Database.executeBatch(cleanUp);
    Test.stopTest();
    errorLogs = [
      SELECT Id, CreatedDate
      FROM ZTS_EU_Error_Log__c
      ORDER BY CreatedDate
    ];
    System.assertEquals(
      ErrorLogCleanUp_Batch.totalLogDays - 1,
      errorLogs.size(),
      'Only Logs in the last X days should remain'
    );
  }

  static testMethod void ErrorLogCleanUp_30Days_MockDMLError() {
    List<ZTS_EU_Error_Log__c> errorLogs = [
      SELECT Id, CreatedDate
      FROM ZTS_EU_Error_Log__c
      ORDER BY CreatedDate
    ];
    System.assertEquals(
      MAX_RECORDS,
      errorLogs.size(),
      'Error Records should match Max Error Count'
    );
    System.assertEquals(
      createDate,
      errorLogs[0].CreatedDate,
      'First Record in List should match first Created Date'
    );
    System.assertEquals(
      createDate.addDays(9),
      errorLogs[9].CreatedDate,
      'Create Dates should be going up +1 for each new record'
    );
    System.assertEquals(
      System.today().addDays(-1),
      errorLogs[errorLogs.size() - 1].CreatedDate,
      'Last Log should be yesterday'
    );
    ErrorLogCleanUp_Batch.totalLogDays = 30;
    ErrorLogCleanUp_Batch.mockDMLError = true;
    Test.startTest();
    ErrorLogCleanUp_Batch cleanUp = new ErrorLogCleanUp_Batch();
    Database.executeBatch(cleanUp);
    Test.stopTest();
    errorLogs = [
      SELECT Id, CreatedDate
      FROM ZTS_EU_Error_Log__c
      WHERE CreatedDate != TODAY
      ORDER BY CreatedDate
    ];
    System.assertEquals(
      ErrorLogCleanUp_Batch.totalLogDays - 1,
      errorLogs.size(),
      'Only Logs in the last X days should remain'
    );
    errorLogs = [SELECT Id FROM ZTS_EU_Error_Log__c WHERE CreatedDate = TODAY];
    System.assertNotEquals(
      0,
      errorLogs.size(),
      'There should be new error logs from today now'
    );
  }
}