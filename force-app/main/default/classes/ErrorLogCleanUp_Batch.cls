/**
 * @description       : Handles deletion of old ZTS_EU_Error_Log__c records
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 03-12-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   02-25-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
global class ErrorLogCleanUp_Batch implements Database.Batchable<sObject>, Database.Stateful {
  private static final String ERROR_LOG_ORIGIN_TYPE = 'ErrorLogCleanUp_Batch - Execute';
  private static final String ERROR_LOG_ORIGIN_TYPE_FIN = 'ErrorLogCleanUp_Batch - Finish';
  private static ErrorLogGlobalSettings__c errorSettings = ErrorLogGlobalSettings__c.getOrgDefaults();
  private static Integer logRetention = Integer.valueOf(errorSettings.Maximum_Log_Retention__c);
  
  @TestVisible
  private static Integer totalLogDays = logRetention == null ? 120 : logRetention;
  private static Integer errorCount = 0;
  private static List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>();
  private static List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
  @TestVisible
  private static Boolean mockDMLError = false;

  global Database.QueryLocator start(Database.BatchableContext BC) {
    String queryStr =
      'SELECT Id FROM ZTS_EU_Error_Log__c WHERE CreatedDate < LAST_N_DAYS:' +
      totalLogDays;
    return Database.getQueryLocator(queryStr);
  }

  global void execute(
    Database.BatchableContext BC,
    List<ZTS_EU_Error_Log__c> scope
  ) {
    List<ZTS_EU_Error_Log__c> errorLogs = new List<ZTS_EU_Error_Log__c>();
    deleteResults = Database.delete(scope, false);
    if (mockDMLError) {
      deleteResults = Database.delete(scope, false);
    }
    // collect any errors during update
    errorLogs.addAll(
      ZTS_EU_Logger.buildLogsByDMLResults(deleteResults, ERROR_LOG_ORIGIN_TYPE)
    );
    if (!errorLogs.isEmpty()) {
      errorCount += errorLogs.size();
      saveResults = Database.insert(errorLogs, false);
    }
  }

  global void finish(Database.BatchableContext BC) {
    if (errorCount > 0) {
      ZTS_EU_Logger.info(
        'Total Errors In Batch: ' + errorCount,
        'count',
        ERROR_LOG_ORIGIN_TYPE_FIN
      );
    }
  }
}