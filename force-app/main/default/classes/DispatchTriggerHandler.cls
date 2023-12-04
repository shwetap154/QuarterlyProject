/************************************************************************
 @author Alex Carstairs
 @date 21 May 2019
 @description This class acts as a dispatcher for trigger handlers. Used
              to take a trigger's handler class and determine the context
              and call the handler's corresponding context method.
 ************************************************************************/

public with sharing class DispatchTriggerHandler {

    @TestVisible
    private static String context;

    
    public static Boolean isTriggerExecuting=false;
    
    @TestVisible
    private static Set<String> firstTimeTracker = new Set<String>();

    @TestVisible
    private static Set<String> triggerContextsForRecursion = new Set<String>();

    private static Set<String> bypassedHandlers = new Set<String>();

    public static void dispatchHandlerToFire(TriggerHandlerInterface handlerToFire, Schema.SObjectField bypassField ) {
        dispatchHandler(handlerToFire, bypassField);
    }

    public static void dispatchHandlerToFire(TriggerHandlerInterface handlerToFire) {
        dispatchHandler(handlerToFire, null);
    }

    static void dispatchHandler(TriggerHandlerInterface handlerToFire, Schema.SObjectField bypassField) {
        //if the trigger is turned off for the running user profile via the Automation Bypass custom setting, skip it.
        //see method for instructions
        if(checkCustomSettingBypass(bypassField)) return;

        handlerToFire.setBypassField(bypassField);
        System.debug('Dispatching: ' + handlerToFire + '====> ' + bypassField+' isDisabled'+handlerToFire.isDisabled());
        if(handlerToFire.isDisabled()) {
            return;
        }

        if(isBypassed(handlerToFire)) {
            System.debug(LoggingLevel.ERROR,getHandlerName(handlerToFire) + ' Is Being Bypassed');
            return;
        }

        setTriggerContext();
        String handlerName = getHandlerName(handlerToFire) + context;     
        if(!allowRecursion(handlerName)) {
            if(firstTimeTracker.contains(handlerName)) {
                return;
            }
            else {
                firstTimeTracker.add(handlerName);
            }
        }

        Boolean suspendLogging = false;
        try {
            // Suspend Saving if it's not current suspended. This trigger will take care of saving the Logs once.
            if (!Logger.isSavingSuspended()) {
                Logger.suspendSaving();
                suspendLogging = true;
            }

            switch on context {
                when 'BEFORE_INSERT' {
                    handlerToFire.beforeInsert(Trigger.new);
                } when 'BEFORE_UPDATE' {
                    handlerToFire.beforeUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
                } when 'BEFORE_DELETE' {
                    handlerToFire.beforeDelete(Trigger.old, Trigger.oldMap);
                } when 'AFTER_INSERT' {
                    handlerToFire.afterInsert(Trigger.new, Trigger.newMap);
                } when 'AFTER_UPDATE' {
                    handlerToFire.afterUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
                } when 'AFTER_DELETE' {
                    handlerToFire.afterDelete(Trigger.old, Trigger.oldMap);
                } when 'AFTER_UNDELETE' {
                    handlerToFire.afterUndelete(Trigger.new, Trigger.newMap);
                }
            }
        }
        finally {
            if (suspendLogging) {
                Logger.resumeSaving();
                // Logs will save using the Save Method specified in Logger Settings.
                // If this starts causing CPU Timeouts, consider adding code to save logs asynchronously
                // if the CPU TImeout limit is about to be reached.
                Logger.saveLog();
            }
        }
    }


    @TestVisible
    private static void setTriggerContext() {
        if(!Trigger.isExecuting) {
            isTriggerExecuting = false;
            return;
        } else {
            isTriggerExecuting = true;
        }
        if(Trigger.isExecuting) {
            context = String.valueOf(Trigger.operationType);
        }
    }

    @TestVisible
    private static Boolean allowRecursion(String handlerName) {
        for(String handler : triggerContextsForRecursion) {
            if((handler + context) == handlerName) {
                return true;
            }
        }
        return false;
    }

    @TestVisible
    private static String getHandlerName(TriggerHandlerInterface handlerName) {
        return String.valueOf(handlerName).split(':')[0];
    }

    /*********************************
    * Trigger Handler Bypass Methods
    *********************************/
    @TestVisible
    private static Boolean isBypassed(TriggerHandlerInterface handlerName) {
        return DispatchTriggerHandler.bypassedHandlers.contains(getHandlerName(handlerName));
    }

    public static void bypass(String handlerName) {
        DispatchTriggerHandler.bypassedHandlers.add(handlerName);
    }

    public static void clearBypass(String handlerName) {
        DispatchTriggerHandler.bypassedHandlers.remove(handlerName);
    }

    public static void clearAllBypasses() {
        DispatchTriggerHandler.bypassedHandlers.clear();
    }

    public static void setRecursionContexts(TriggerHandlerInterface handler) {
        String handlerName = getHandlerName(handler);
        triggerContextsForRecursion.add(handlerName);
    }

    //This method will take the CUSTOM METADATA Bypass_Triggers__mdt bypass fields that are passed into this class via the trigger
    //The method takes the field api name of the metadata field passed in and matches it to the CUSTOM SETTING called Automation_Bypass.
    //The fields in the custom setting should match the fields in the custom metadata, the custom setting is hierarchy based and can provide override for a given user or profile
    //The custom setting can also bypass process builder and flows where implemented.
    //The original custom metadata will bypass the trigger for all users, but only the triggers.
    public static Boolean checkCustomSettingBypass(Schema.SObjectField bypassSettingField){
        
        Automation_Bypass__c customSetting = (Automation_Bypass__c.getInstance(UserInfo.getUserId())!=null
                                                ? Automation_Bypass__c.getInstance(UserInfo.getUserId()) : Automation_Bypass__c.getInstance(UserInfo.getProfileId()));

        Boolean skipTrigger = false;
        //will allow calling this method from dispatchHandler without changing the signature, allowing this method to run without adding it to every trigger.
        //can use the field names from the original custom metadata with the custom setting call so long as they match.
        if(customSetting!=null && bypassSettingField!=null){
            try{
                String bypassField = bypassSettingField.getDescribe().getName();
                skipTrigger = ((Boolean)customSetting.get(bypassField)==true?true:false);
                system.debug('Bypass Field found, skipTrigger:'+skipTrigger);
            }
            catch(exception e){
                system.debug('Bypass Field does not exist on custom setting'+bypassSettingField.getDescribe().getName() +'error: '+e); 
            }
        }
        return skipTrigger;
    }
}