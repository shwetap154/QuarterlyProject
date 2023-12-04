/**
 * @description       : Used for creating Logs in ZTS_EU_Error_Log__c
 * @author            : Deloitte Constulting/Raghu
 * @group             : 
 * @last modified on  : 05-26-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   03/12/2014   Deloitte Constulting/Raghu    Initial Version
 * 1.1   02/10/2021   Morgan Marchese @ Zoetis      Added Methods to support DML at Scale (logger still needs a rework)
 * 1.2   05/26/2022   Ethan Hirsch @ Zoetis         Added a method to be able to generate an error log without inserting
 *                                                  it to allow for creative error messages and limit handling
**/
public class ZTS_EU_Logger {
  public enum Level {
    TRACE,
    DEBUG,
    INFO,
    WARN,
    ERROR,
    FATAL
  }

  public static boolean notify { get; set; }

  private static void log(
    String message,
    Level level,
    String statusCode,
    String logtype
  ) {
    log(message, level, statusCode, logtype, true);
  }

  private static ZTS_EU_Error_Log__c log(
    String message,
    Level level,
    String statusCode,
    String logtype,
    Boolean insertLog
  ) {
    boolean notifyAdmin = false;
    if (notify != null && notify) {
      notifyAdmin = true;
    }
    Integer MSG_LIMIT_SIZE = 32768;
    //CHECK FOR MSG SIZE LIMIT
    if (message.length() >= MSG_LIMIT_SIZE) {
      message = message.substring(0, MSG_LIMIT_SIZE - 1);
    }
    
    ZTS_EU_Error_Log__c log = buildLog(message, level, statusCode, logtype, notifyAdmin);
    if (insertLog) {
      Database.insert(
        log,
        false
      );
    }

    return log;
  }

  public static List<ZTS_EU_Error_Log__c> buildLogsByDMLResults(
    List<Object> dmlResults,
    String logType
  ) {
    List<ZTS_EU_Error_Log__c> errorLogs = new List<ZTS_EU_Error_Log__c>();
    Database.Error errorRecord;
    String msg = '';
    String statusCode = '';
    if (dmlResults != null && !dmlResults.isEmpty()) {
      Object dmlResult = dmlResults[0];
      boolean isError = false;
      if (dmlResult instanceof Database.SaveResult) {
        //create error msg details for failed records
        for (Database.SaveResult res : (List<Database.SaveResult>) dmlResults) {
          if (!res.isSuccess()) {
            isError = true;
            errorRecord = res.getErrors()[0];
            msg = String.valueOf(errorRecord.getMessage());
            statusCode = String.valueOf(errorRecord.getStatusCode())
              .substring(0, 9);
            errorLogs.add(
              buildLog(msg, Level.ERROR, statusCode, logType, true)
            );
          }
        }
      } else if (dmlResult instanceof Database.Upsertresult) {
        //create error msg details for failed records
        for (
          Database.Upsertresult res : (List<Database.Upsertresult>) dmlResults
        ) {
          if (!res.isSuccess()) {
            isError = true;
            errorRecord = res.getErrors()[0];
            msg = String.valueOf(errorRecord.getMessage());
            statusCode = String.valueOf(errorRecord.getStatusCode())
              .substring(0, 9);
            errorLogs.add(
              buildLog(msg, Level.ERROR, statusCode, logType, true)
            );
          }
        }
      } else if (dmlResult instanceof Database.DeleteResult) {
        //create error msg details for failed records
        for (
          Database.DeleteResult res : (List<Database.DeleteResult>) dmlResults
        ) {
          if (!res.isSuccess()) {
            isError = true;
            errorRecord = res.getErrors()[0];
            msg = String.valueOf(errorRecord.getMessage());
            statusCode = String.valueOf(errorRecord.getStatusCode())
              .substring(0, 9);
            errorLogs.add(
              buildLog(msg, Level.ERROR, statusCode, logType, true)
            );
          }
        }
      }
    }
    return errorLogs;
  }

  private static ZTS_EU_Error_Log__c buildLog(
    String message,
    Level level,
    String statusCode,
    String logtype,
    Boolean notifyAdmin
  ) {
    ZTS_EU_Error_Log__c record = new ZTS_EU_Error_Log__c(
      ZTS_EU_Message__c = message,
      ZTS_EU_Log_Level__c = level.name(),
      ZTS_EU_Origin_Type__c = logtype,
      ZTS_EU_Notify_Admin__c = notifyAdmin
    );
    record.ZTS_EU_Status_Code__c = statusCode == null ? '' : statusCode;
    return record;
  }

  public static void error(String message, String statusCode, String logtype) {
    log(message, Level.ERROR, statusCode, logtype);
  }

  public static ZTS_EU_Error_Log__c error(String message, String statusCode, String logtype, Boolean insertRecord) {
    return log(message, Level.ERROR, statusCode, logtype, insertRecord);
  }

  public static void errorAsync(
    String message,
    String statusCode,
    String logtype
  ) {
    log(message, Level.ERROR, statusCode, logtype);
  }

  public static void warn(String message, String statusCode, String logtype) {
    log(message, Level.WARN, statusCode, logtype);
  }

  public static void info(String message, String statusCode, String logtype) {
    log(message, Level.INFO, statusCode, logtype);
  }

  public static void debug(String message, String statusCode, String logtype) {
    log(message, Level.DEBUG, statusCode, logtype);
  }

  public static void trace(String message, String statusCode, String logtype) {
    log(message, Level.TRACE, statusCode, logtype);
  }

  public static void addPageMessage(ApexPages.Message msg) {
    ApexPages.addMessage(msg);
  }

  public static void addPageMessage(ApexPages.Severity severity, String msg) {
    ApexPages.Severity serv_level = severity == null
      ? ApexPages.Severity.INFO
      : severity;
    ApexPages.Message pgMsg = new ApexPages.Message(serv_level, msg);
    addPageMessage(pgMsg);
  }

  public static String toString(ZTS_EU_Error_Log__c log) {
    String msg = log.ZTS_EU_Log_Level__c + ' : ' + log.ZTS_EU_Message__c;
    System.debug(LoggingLevel.Error, '## ZOETIS ERROR LOG : ' + msg);
    return msg;
  }

  public static void error(List<Object> dmlResults, String origin) {
    //implement for merge results - others
    String msg = getDMLErrorMsg(dmlResults);
    if (!String.isBlank(msg)) {
      ZTS_EU_Logger.error(msg, null, origin);
    }
  }

  public static String getDMLErrorMsg(List<Object> dmlResults) {
    String msg = '';

    if (dmlResults != null && !dmlResults.isEmpty()) {
      Object dmlResult = dmlResults[0];
      boolean isError = false;
      if (dmlResult instanceof Database.Saveresult) {
        //create error msg details for failed records
        for (Database.Saveresult res : (List<Database.Saveresult>) dmlResults) {
          if (!res.isSuccess()) {
            isError = true;
            msg += res.getErrors()[0];
          }
        }
      } else if (dmlResult instanceof Database.Upsertresult) {
        //create error msg details for failed records
        for (
          Database.Upsertresult res : (List<Database.Upsertresult>) dmlResults
        ) {
          if (!res.isSuccess()) {
            isError = true;

            msg += res.getErrors()[0];
          }
        }
      } else if (dmlResult instanceof Database.DeleteResult) {
        //create error msg details for failed records
        for (
          Database.DeleteResult res : (List<Database.DeleteResult>) dmlResults
        ) {
          if (!res.isSuccess()) {
            isError = true;

            msg += res.getErrors()[0];
          }
        }
      }

      //implement for merge results - others
    }

    return msg;
  }

  public static String getDMLSuccessMsg(List<Object> dmlResults) {
    String msg = '';
    Integer rec_count = 0;
    if (dmlResults != null && !dmlResults.isEmpty()) {
      Object dmlResult = dmlResults[0];
      boolean isError = false;
      if (dmlResult instanceof Database.Saveresult) {
        //create error msg details for failed records
        for (Database.Saveresult res : (List<Database.Saveresult>) dmlResults) {
          if (res.isSuccess()) {
            msg += res.getId() + ',';
            rec_count++;
          }
        }
      } else if (dmlResult instanceof Database.Upsertresult) {
        //create error msg details for failed records
        for (
          Database.Upsertresult res : (List<Database.Upsertresult>) dmlResults
        ) {
          if (res.isSuccess()) {
            msg += res.getId() + ',';
            rec_count++;
          }
        }
      } else if (dmlResult instanceof Database.DeleteResult) {
        //create error msg details for failed records
        for (
          Database.DeleteResult res : (List<Database.DeleteResult>) dmlResults
        ) {
          if (res.isSuccess()) {
            msg += res.getId() + ',';
            rec_count++;
          }
        }
      }

      //implement for merge results - others
    }

    return msg + '\n Total records success : ' + rec_count;
  }

  @future
  public static void errorAsync(String msg, String origin) {
    ZTS_EU_Logger.error(msg, null, origin);
  }
    //Created by chanbasha Noorbashsheik on 19-July-2021
    //This method is for to update the Assigned territory status field after std territory created
    @future(callout = true)
    public static void processAsync() {
    
         ZTS_EU_UnsyncTerritoryConsoleResults zc = new ZTS_EU_UnsyncTerritoryConsoleResults();
         zc.updateCustomTerrAssignedFlag();    
    }    
}