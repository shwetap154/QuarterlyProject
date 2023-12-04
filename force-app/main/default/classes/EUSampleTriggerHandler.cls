/****************************************************************************************************************************************** 
 * Trigger Name : EUSampleTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Sample__c object.
 * Created By   : Slalom(Allister McKenzie) 
 * Created Date : 25th November, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Allister McKenzie            11/25/2020         Created 
*****************************************************************************************************************************************/
public with sharing class EUSampleTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface {
    public static void beforeInsert(List<SObject> triggerNew) {}

    public static void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

    public static void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}

    public static void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

    public static void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {

        //Filter triggerOld List for INTL accounts 
        List<ZTS_EU_Sample__c> IntlOldListEUSampleProcess = TriggerHandlerExtension.filter(triggerOld, ZTS_EU_Sample__c.Market__c.getDescribe().getSObjectField(), false);
        //Filter triggerOldMap Map for INTL accounts return Map
        Map<Id,ZTS_EU_Sample__c> IntlOldMapEUSampleProcess = new Map<Id, ZTS_EU_Sample__c>(IntlOldListEUSampleProcess);
        //Filter triggerNew List for INTL accounts 
        List<ZTS_EU_Sample__c> IntlNewListEUSampleProcess = TriggerHandlerExtension.filter(triggerNew, ZTS_EU_Sample__c.Market__c.getDescribe().getSObjectField(), false);
        //Filter triggerNewMap Map for INTL accounts return Map
        Map<Id,ZTS_EU_Sample__c> IntlNewMapEUSampleProcess = new Map<Id, ZTS_EU_Sample__c>(IntlNewListEUSampleProcess);
        System.debug('$$$ triggernew.size(): '+triggerNew.size());
        System.debug('$$$ triggernew: '+triggerNew[0]);
        System.debug('$$$ triggernew market: '+triggerNew[0].get('ZTS_EU_Year__c'));
        System.debug('$$$ IntlNewListEUSampleProcess: '+IntlNewListEUSampleProcess.size());
        System.debug('$$$ ---------');
        System.debug('$$$ triggerold.size(): '+triggerOld.size());
        System.debug('$$$ triggerold: '+triggerOld[0]);
        System.debug('$$$ triggerold market: '+triggerOld[0].get('ZTS_EU_Year__c'));
        System.debug('$$$ IntlOldListEUSampleProcess: '+IntlOldListEUSampleProcess.size());
        System.debug('$$$ %%%%%%%%%%%');
        if (!IntlOldListEUSampleProcess.isEmpty() && !IntlOldMapEUSampleProcess.isEmpty() && !IntlNewListEUSampleProcess.isEmpty() && !IntlNewMapEUSampleProcess.isEmpty())
            INTLSampleTriggerService.afterUpdate(IntlOldListEUSampleProcess, IntlOldMapEUSampleProcess, IntlNewListEUSampleProcess, IntlNewMapEUSampleProcess);
    }

    public static void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}

    public static void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

    public override Boolean isDisabled() {
        return super.isDisabled();
    }

    public override Boolean isFirstTime() { 
        return super.isFirstTime(); 
    }

    public override List<String> getTriggerContextsForRecursion() { 
        return super.getTriggerContextsForRecursion(); 
    }

    public static void setBypassField(Schema.SObjectField bypassField) {}
}