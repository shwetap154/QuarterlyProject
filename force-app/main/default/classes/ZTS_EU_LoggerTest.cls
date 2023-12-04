/**
 * @description       : Test class for line coverage on ZTS_EU_Logger. Not a good test class, but not a good class either.
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 05-26-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   02-12-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   05-26-2022   Ethan Hirsch @ Zoetis Inc      Added a test for the error method that does not create a log
 **/
@isTest
private class ZTS_EU_LoggerTest {
  @isTest
  static void logger_Test() {
    String message = 'This test was rushed because nobody wrote adequate test coverage for this strange, non-bulkified Logger class';
    String statusCode = 'what?';
    String logType = 'TestClass';

    // Inserts 1 Record
    ZTS_EU_Logger.error(message, statusCode, logType);

    // This method isn't actually Async, it's lying to you
    // Inserts 1 Record
    ZTS_EU_Logger.errorAsync(message, statusCode, logType);

    // Warning, I'm not loving this Logger Class
    // Inserts 1 Record
    ZTS_EU_Logger.warn(message, statusCode, logType);

    // Inserts 1 Record
    ZTS_EU_Logger.info(message, statusCode, logType);

    // Inserts 1 Record
    ZTS_EU_Logger.debug(message, statusCode, logType);

    // Inserts 1 Record
    ZTS_EU_Logger.trace(message, statusCode, logType);

    ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, message);
    ZTS_EU_Error_Log__c log = new ZTS_EU_Error_Log__c(
      ZTS_EU_Log_level__c = 'ERROR',
      ZTS_EU_Message__c = message
    );
    insert log;

    // Returns a String of Log Level + Message
    String msgString = ZTS_EU_Logger.toString(log);
    System.assert(
      !String.isBlank(msgString),
      'String Should Not Be Null/Blank'
    );

    String successString = '';
    List<Call__c> callList = new List<Call__c>{ new Call__c() };
    List<ZTS_EU_Error_Log__c> logs = new List<ZTS_EU_Error_Log__c>();
    List<Database.SaveResult> saveResults = Database.insert(callList, false);
    List<Database.UpsertResult> upsertResults = Database.upsert(
      new List<ZTS_EU_Error_Log__c>{ log },
      false
    );
    List<Database.DeleteResult> deleteResults = Database.delete(
      new List<ZTS_EU_Error_Log__c>{ log },
      false
    );

    // Inserts 1 Record
    ZTS_EU_Logger.error(saveResults, logType);
    // Returns a String
    successString = ZTS_EU_Logger.getDMLSuccessMsg(saveResults);
    // Builds a List of ZTS_EU_Error_Log__c
    logs = ZTS_EU_Logger.buildLogsByDMLResults(saveResults, logType);

    // Inserts 1 Record
    ZTS_EU_Logger.error(upsertResults, logType);
    // Returns a String
    successString = ZTS_EU_Logger.getDMLSuccessMsg(upsertResults);
    logs = ZTS_EU_Logger.buildLogsByDMLResults(upsertResults, logType);

    // Inserts 1 Record
    ZTS_EU_Logger.error(deleteResults, logType);
    // Returns a String
    successString = ZTS_EU_Logger.getDMLSuccessMsg(deleteResults);
    // Builds a List of ZTS_EU_Error_Log__c
    logs = ZTS_EU_Logger.buildLogsByDMLResults(deleteResults, logType);
  }
      /* created by Chanbasha Noorbashasheik on 19-July-2021 */
    @isTest
    static void assignedTerritoryStatustest(){   
        Test.startTest();  
          ZTS_EU_Logger.processAsync();
        Test.stopTest();   
    }
    
    @isTest
    static void testErrorNoInsert() {
      String message = 'message;';
      String statusCode = 'Status';
      String logType = 'TestClass';

      Test.startTest();
        ZTS_EU_Error_Log__c log = ZTS_EU_Logger.error(message, statusCode, logType, false);
      Test.stopTest();

      System.assertEquals(null, log.Id, 'Log was inserted incorrectly');
      System.assertEquals(ZTS_EU_Logger.Level.ERROR.name(), log.ZTS_EU_Log_Level__c, 'Log Level is not error');
      System.assertEquals(message, log.ZTS_EU_Message__c, 'Log Message was not set correctly');
      System.assertEquals(statusCode, log.ZTS_EU_Status_Code__c);
      System.assertEquals(logType, log.ZTS_EU_Origin_Type__c);
    }
}