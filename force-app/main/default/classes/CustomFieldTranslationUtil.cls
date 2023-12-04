/**
 * @description       : Utility Methods for working with CustomFieldTranslation__mdt
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 02-16-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   02-10-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
public with sharing class CustomFieldTranslationUtil {
  /**
   * @description returns a Map of Translatable Fields and Values by API Name
   * @author Morgan Marchese @ Zoetis Inc | 02-10-2021
   * @param String objectAPIName
   * @return Map<String, Map<String, String>>
   **/
  public static Map<String, Map<String, String>> getTranslationMapByObjectName(
    String objectAPIName
  ) {
    // Return Map Structure: Map<Field_API_Name__c, Map<Translate_From__c, Translate_To__c>>>
    Map<String, Map<String, String>> returnMap = new Map<String, Map<String, String>>();
    Map<String, String> translationMap;
    for (CustomFieldTranslation__mdt record : [
      SELECT
        MasterLabel,
        Object_API_Name__c,
        Field_API_Name__c,
        Translate_From__c,
        Translate_To__c
      FROM CustomFieldTranslation__mdt
      WHERE Object_API_Name__c = :objectAPIName
    ]) {
      translationMap = returnMap.get(record.Field_API_Name__c);
      if (translationMap == null) {
        returnMap.put(
          record.Field_API_Name__c,
          new Map<String, String>{
            record.Translate_From__c => record.Translate_To__c
          }
        );
      } else {
        translationMap.put(record.Translate_From__c, record.Translate_To__c);
      }
    }
    return returnMap;
  }

  /*
    * FUTURE WORK IN PROGRESS - INCOMPLETE CODE
    * This is a rough approximation of what code might look like to get ALL Translation Records
    * This was not completed in the interest of time due to the seriousness of the deployment
    * @author : Morgan Marchese @ Zoetis

    public static Map<String, Map<String, Map<String,String>>> getAllTranslationsMap(){
        // Return Map Structure: Map<Object_API_Name__c, Map<Field_API_Name__c, Map<Translate_From__c, Translate_To__c>>>
        Map<String, Map<String, Map<String, String>>> returnMap = new Map<String, Map<String, Map<String,String>>>();
        Map<String, Map<String,String>> fieldMap;
        Map<String, String> translationMap;
        for (CustomFieldTranslation__mdt record : [
          SELECT
            MasterLabel,
            Object_API_Name__c,
            Field_API_Name__c,
            Translate_From__c,
            Translate_To__c
          FROM CustomFieldTranslation__mdt
        ]) {
           fieldMap = returnMap.get(record.Object_API_Name__c);
           if(fieldMap == null){
               returnMap.put(
                   record.Object_API_Name__c, 
                   new Map<String,Map<String,String>>{
                       record.Field_API_Name__c,
                       new Map<String,String>{
                           record.Translate_From__c => record.Translate_To__c
                          }
                      }
              );
           }else{
              translationMap = fieldMap.get(record.Field_API_Name__c);
              if(translationMap == null){
                  translationMap.put()
              }
           }  
        }
    } */
}