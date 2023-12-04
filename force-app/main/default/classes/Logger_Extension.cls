/**
 * 
 * @author Ethan Hirsch @ Zoetis Inc
 * @since  01-19-2023
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-19-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with methods errorLogIfSaveError for logging an Error only if exceptions occur and
 *                                                buildLogMessageWithRecordIdList to build a LogMessage that contains a comma separated list of Record Ids
 */
public inherited sharing class Logger_Extension {
    /**
     * Creates a LogMessage that contains a comma separated list of record ids
     * @param logMessage 
     * @param records 
     * @return  `LogMessage`
     */
    public static LogMessage buildLogMessageWithRecordIdList(String logMessage, List<SObject> records) {
        return buildLogMessageWithRecordIdList(logMessage, new Map<Id, SObject>(records).keySet());
    }

    /**
     * Creates a LogMessage that contains a comma separated list of record ids
     * @param logMessage 
     * @param recordIds 
     * @return  `LogMessage`
     */
    public static LogMessage buildLogMessageWithRecordIdList(String logMessage, Set<Id> recordIds) {
        return new LogMessage(logMessage, 
            String.join((Iterable<String>)recordIds, ', '));
    }

    /**
     * Create an Error Log Entry if at least one of the saveResults errored
     * @param logMessage 
     * @param records
     * @param saveResults 
     */
    public static void errorLogIfSaveError(LogMessage logMessage, List<SObject> records, List<Database.SaveResult> saveResults) {
        errorLogIfSaveError(logMessage.getMessage(), records, saveResults, false);
    }

    /**
     * Create an Error Log Entry if at least one of the saveResults errored
     * @param logMessage 
     * @param records
     * @param saveResults 
     * @param notifyAdmin 
     */
    public static void errorLogIfSaveError(LogMessage logMessage, List<SObject> records, List<Database.SaveResult> saveResults, 
        Boolean notifyAdmin) {
        errorLogIfSaveError(logMessage.getMessage(), records, saveResults, notifyAdmin);
    }

    /**
     * Create an Error Log Entry if at least one of the saveResults errored
     * @param logMessage 
     * @param records
     * @param saveResults 
     * @param notifyAdmin 
     */
    public static void errorLogIfSaveError(String logMessage, List<SObject> records, List<Database.SaveResult> saveResults,
        Boolean notifyAdmin) {
        List<Database.SaveResult> errorResults = new List<Database.SaveResult>();
        List<SObject> errorRecords = new List<SObject>();

        // The assumption is that the saveResults passed in and records list are parallel lists, so they can be referenced by index
        for (integer i = 0; i < saveResults.size(); i++) {
            Database.SaveResult saveResult = saveResults[i];
            if (!saveResult.isSuccess()) {
                errorResults.add(saveResult);

                // Just in case the lists are not parallel, do a sanity check that the index exists on the records list
                if (records.size() > i) {
                    errorRecords.add(records[i]);
                }
            }
        }

        if (errorResults.isEmpty()) {
            return;
        }

        LogEntryEventBuilder logEvent = Logger.error(logMessage, errorResults);
        
        if (!errorRecords.isEmpty()) {
            logEvent.setRecord(errorRecords);
        }

        if (notifyAdmin) {
            logEvent.addTag(System.Label.Logger_Notify_Admin_Tag);
        }
    }
}