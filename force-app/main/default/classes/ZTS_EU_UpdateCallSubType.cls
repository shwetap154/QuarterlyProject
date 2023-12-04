/**
 * @description       : Handles Translations of values on Call__c records based on Custom Metadata
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 10-20-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   02-10-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   10-20-2021   Morgan Marchese @ Zoetis Inc   Added Bypass Logic for Call Updates
**/
global class ZTS_EU_UpdateCallSubType implements Database.Batchable<sObject>, Database.Stateful {
  private static Map<String, Map<String, String>> translationFieldMap = CustomFieldTranslationUtil.getTranslationMapByObjectName(
    'Call__c'
  );
  private Integer errorCount = 0;
  @testVisible
  private static final String ERROR_LOG_ORIGIN_TYPE = 'ZTS_EU_UpdateCallSubType Batch - execute: translate Sub Types';
  private static final String ERROR_LOG_ORIGIN_TYPE_FIN = 'ZTS_EU_UpdateCallSubType Batch - finish: translate Sub Types';
  @testVisible
  private static Boolean mockDMLError = false;

  global Database.QueryLocator start(Database.BatchableContext BC) {
    List<String> translatableValues = new List<String>();
    // Build List of translatable values
    // Get all of the Map<String, String>{Translated From => Translated To} values
    for (Map<String, String> stringMap : translationFieldMap.values()) {
      // Use each 'Translated From' value to build a List of values to query for
      for (String s : stringMap.keySet()) {
        translatableValues.add(s);
      }
    }

    // Get All Call records that have a translatable value
    return Database.getQueryLocator(
      [
        SELECT Id, ZTS_EU_Sub_Type__c
        FROM Call__c
        WHERE
          ZTS_EU_Sub_Type__c IN :translatableValues
          AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States' 
          ORDER BY ZTS_EU_Account__c // Order by Account to avoid sharing/row lock errors
      ]
    );
  }

  global void execute(Database.BatchableContext BC, List<Call__c> scope) {
    String translateFrom;
    String translateTo;
    Map<String, String> fieldValueTranslationMap;
    Map<String, Schema.SObjectField> callFieldMap = Schema.SObjectType.Call__c.fields.getMap();
    List<Call__c> callsToUpdate = new List<Call__c>();
    List<Database.SaveResult> saveResults;
    List<ZTS_EU_Error_Log__c> errorLogs = new List<ZTS_EU_Error_Log__c>();
  
    // For each record in Scope
    for (Call__c record : scope) {
      // for each Field API Name in the Translation Map
      for (String translatedField : translationFieldMap.keySet()) {
        // Skip Over Bogus Fields in the Translation Map using Field Schema to avoid an error
        if (!callFieldMap.containsKey(translatedField))
          continue;
        // Get the Map<String,String>{Translated From => Translated To}
        fieldValueTranslationMap = translationFieldMap.get(translatedField);
        // Get the current value of the Translatable Field for this Record
        translateFrom = record.get(translatedField).ToString();
        // Check that the Current Value is not Blank before proceeding
        if (!String.isBlank(translateFrom)) {
          // Check that the Current Value has a corresponding Translation Value
          translateTo = fieldValueTranslationMap.get(translateFrom);
          if (!String.isBlank(translateTo)) {
            // Translate
            record.put(translatedField, translateTo);
            if (mockDMLError) {
              record.ZTS_EU_Account__c = null;
            }
            callsToUpdate.add(record);
          }
        }
      }
    }

    if (!callsToUpdate.isEmpty()) {
      // To avoid conflict with other Call code, bypass the CallTriggerHandler when running Translations.
      DispatchTriggerHandler.bypass('CallTriggerHandler');
      saveResults = Database.update(callsToUpdate, false);
      // Clear Trigger Bypass.
      DispatchTriggerHandler.clearBypass('CallTriggerHandler');

      // collect any errors during update
      errorLogs.addAll(
        ZTS_EU_Logger.buildLogsByDMLResults(saveResults, ERROR_LOG_ORIGIN_TYPE)
      );
      if(!errorLogs.isEmpty()){
        errorCount += errorLogs.size();
        saveResults = Database.insert(errorLogs, false);  
      }
    }
  }

  global void finish(Database.BatchableContext BC) {
    if (errorCount > 0) {
      ZTS_EU_Logger.info('Total Errors In Batch: ' + errorCount, 'count', ERROR_LOG_ORIGIN_TYPE_FIN);
    }
  }
}