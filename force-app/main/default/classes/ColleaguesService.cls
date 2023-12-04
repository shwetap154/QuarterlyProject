/**
 * @description       : Service Class for all future Colleague utilities/services
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : ServiceClass
 * @last modified on  : 11-09-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   11-09-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
public with sharing class ColleaguesService {
  /**
   * @description create a map for collegues and their activity dates.
   * Migrated from ZTS_EU_AccountPositionUtility on 11/9/2021
   * @author Shreyas @ CloudSense | 03-13-2015
   * @param List<ZTS_EU_Colleague__c> collegueList
   * @return Map<String, DateTime>
   **/
  public static Map<String, DateTime> getCollegueKeyToCallDateMap(
    List<ZTS_EU_Colleague__c> collegueList
  ) {
    Map<string, datetime> collegueMap = new Map<string, datetime>();
    String key1;
    String key2;
    String key;
    DateTime callDateTime;
    for (ZTS_EU_Colleague__c c : collegueList) {
      key1 = c.ZTS_EU_User__c;
      key2 = c.ZTS_EU_Call__r.ZTS_EU_Account__c;
      key = key1 + key2;
      callDateTime = c.ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c;
      if (callDateTime <= System.Now()) {
        if (collegueMap.containsKey(key)) {
          if (callDateTime > collegueMap.get(key)) {
            collegueMap.put(key, callDateTime);
          }
        } else {
          collegueMap.put(key, callDateTime);
        }
      }
    }
    return collegueMap;
  }
}