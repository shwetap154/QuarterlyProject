/**
 * @description       : This class contains generic service methods for all custom settings.
 * @author            : Fayas Mansoor @ Deloitte
 * @group             : 
 * @last modified on  : 04-11-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-17-2014   Fayas Mansoor @ Deloitte    Initial Version
 * 1.1   04-11-2022   Ethan Hirsch @ Zoetis Inc   Add setTriggerBypass method
**/
public with sharing class CustomSettingService {
    
    /*
    * Static maps of custom settings.
    * Be careful when refreshing that the map doesn't hold records not inserted into the database.
    */
    public static Map<String, TriggerActivation__c> triggerActivationMap;
    public static ZTS_Settings__c   zoetisAppConfig;
    /*
    * Refresh map of TriggerActivation__c records (trigActMap). 
    * @param 
    * @return
    */
    public static void refreshTriggerActivationMap() {
        triggerActivationMap = TriggerActivation__c.getAll();
    }
    
    /*
    * Check to see if a trigger is active.
    * @param String triggerName
    * @return boolean
    */
    public static boolean checkIfTriggerActive(String triggerName) {
        //If there is no record created for specified trigger, this initialized value is what will be returned.
        Boolean isActive = false;
        
        
        //If trigActMap is empty, populate it.
        if (triggerActivationMap==null||triggerActivationMap.isEmpty()) 
            refreshTriggerActivationMap();
        //Check to see if parameter trigger name has an associated TriggerActivation__c record created for it and is in map.
        if (triggerActivationMap.containsKey(triggerName))
            
            isActive = triggerActivationMap.get(triggerName).isActive__c;
        return isActive;
    }
    
    /*
    * Check to see if a trigger is active.
    * @param String triggerName
    * @return boolean
    */
    public static boolean checkIfTriggerIsForBypass(String triggerName) {
        //If there is no record created for specified trigger, this initialized value is what will be returned.
        Boolean isForBypass = false;
        //If trigActMap is empty, populate it.
        if (triggerActivationMap==null||triggerActivationMap.isEmpty()) 
            refreshTriggerActivationMap();
        //Check to see if parameter trigger name has an associated TriggerActivation__c record created for it and is in map.
        if (triggerActivationMap.containsKey(triggerName))
            isForBypass= triggerActivationMap.get(triggerName).ZTS_EU_Bypass__c;
        return isForBypass;
    }
    /*
    * Zoetis App Configuration Setting.
    * @param String custom setting name
    * @return boolean
    */
    public static ZTS_Settings__c getZoetisAppConfig() {
        if (zoetisAppConfig==null) {
            zoetisAppConfig=Test.isRunningTest()?ZTS_Settings__c.getInstance(UserInfo.getUserId()):ZTS_Settings__c.getOrgDefaults();
        }
        return zoetisAppConfig;
    }


    /**
    * @description Override the default on/off setting for a Trigger in memory only
    * @author Ethan Hirsch @ Zoetis Inc | 04-11-2022 
    * @param triggerName 
    * @param bypass 
    **/
    public static void setTriggerBypass(string triggerName, Boolean bypass) {
        if (triggerActivationMap == null || triggerActivationMap.isEmpty()) {
            refreshTriggerActivationMap();
        }

        if (triggerActivationMap.containsKey(triggerName)) {
            triggerActivationMap.get(triggerName).ZTS_EU_Bypass__c = !bypass;
        }
    }
}