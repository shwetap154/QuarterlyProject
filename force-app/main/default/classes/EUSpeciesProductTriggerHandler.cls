/****************************************************************************************************************************************** 
 * Trigger Name : EUSpeciesProductTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Species_Product__c object.
 * Created By   : Slalom(Allister McKenzie) 
 * Created Date : 25th November, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Allister McKenzie            11/25/2020         Created 
*****************************************************************************************************************************************/
public with sharing class EUSpeciesProductTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface {
    //Field used for Account segmentation logic
    private Schema.sObjectField marketField = ZTS_EU_Species_Product__c.ZTS_EU_Market__c.getDescribe().getSObjectField();
    
    public void beforeInsert(List<SObject> triggerNew) {
        //Filter triggerNew List for US accounts 
        List<ZTS_EU_Species_Product__c> UsNewListEUSpeciesProductProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL accounts 
        List<ZTS_EU_Species_Product__c> IntlNewListEUSpeciesProductProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);

        if (!IntlNewListEUSpeciesProductProcess.isEmpty()) INTLEUSpeciesProductTriggerService.beforeInsert(IntlNewListEUSpeciesProductProcess);
        if (!UsNewListEUSpeciesProductProcess.isEmpty()) USEUSpeciesProductTriggerService.beforeInsert(UsNewListEUSpeciesProductProcess);  
    }

    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        //Filter triggerOld List for US accounts 
        List<ZTS_EU_Species_Product__c> UsOldListEUSpeciesProductProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US accounts return Map
        Map<Id,ZTS_EU_Species_Product__c> UsOldMapEUSpeciesProductProcess = new Map<Id, ZTS_EU_Species_Product__c>(UsOldListEUSpeciesProductProcess);
        //Filter triggerNew List for US accounts 
        List<ZTS_EU_Species_Product__c> UsNewListEUSpeciesProductProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US accounts return Map
        Map<Id,ZTS_EU_Species_Product__c> UsNewMapEUSpeciesProductProcess = new Map<Id, ZTS_EU_Species_Product__c>(UsNewListEUSpeciesProductProcess);

        //Filter triggerNew List for US accounts 
        List<ZTS_EU_Species_Product__c> IntlOldListEUSpeciesProductProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for US accounts return Map
        Map<Id,ZTS_EU_Species_Product__c> IntlOldMapEUSpeciesProductProcess = new Map<Id, ZTS_EU_Species_Product__c>(IntlOldListEUSpeciesProductProcess);
        //Filter triggerNew List for INTL accounts 
        List<ZTS_EU_Species_Product__c> IntlNewListEUSpeciesProductProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL accounts return Map
        Map<Id,ZTS_EU_Species_Product__c> IntlNewMapEUSpeciesProductProcess = new Map<Id, ZTS_EU_Species_Product__c>(IntlNewListEUSpeciesProductProcess);

        if (!IntlOldListEUSpeciesProductProcess.isEmpty() && !IntlOldMapEUSpeciesProductProcess.isEmpty() && !IntlNewListEUSpeciesProductProcess.isEmpty() && !IntlNewMapEUSpeciesProductProcess.isEmpty())
            INTLEUSpeciesProductTriggerService.beforeUpdate(IntlOldListEUSpeciesProductProcess, IntlOldMapEUSpeciesProductProcess, IntlNewListEUSpeciesProductProcess, IntlNewMapEUSpeciesProductProcess);
        if (!UsOldListEUSpeciesProductProcess.isEmpty() && !UsOldMapEUSpeciesProductProcess.isEmpty() && !UsNewListEUSpeciesProductProcess.isEmpty() && !UsNewMapEUSpeciesProductProcess.isEmpty())
            USEUSpeciesProductTriggerService.beforeUpdate(UsOldListEUSpeciesProductProcess, UsOldMapEUSpeciesProductProcess, UsNewListEUSpeciesProductProcess, UsNewMapEUSpeciesProductProcess);
    }

    public static void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        //Filter triggerOld List for US accounts 
        List<ZTS_EU_Species_Product__c> UsOldListEUSpeciesProductProcess = TriggerHandlerExtension.filter(triggerOld, ZTS_EU_Species_Product__c.ZTS_EU_Market__c.getDescribe().getSObjectField(), true);
        //Filter triggerOldMap Map for US accounts return Map
        Map<Id,ZTS_EU_Species_Product__c> UsOldMapEUSpeciesProductProcess = new Map<Id, ZTS_EU_Species_Product__c>(UsOldListEUSpeciesProductProcess);
        //Filter triggerNew List for US accounts 
        List<ZTS_EU_Species_Product__c> IntlOldListEUSpeciesProductProcess = TriggerHandlerExtension.filter(triggerOld, ZTS_EU_Species_Product__c.ZTS_EU_Market__c.getDescribe().getSObjectField(), false);
        //Filter triggerNewMap Map for US accounts return Map
        Map<Id,ZTS_EU_Species_Product__c> IntlOldMapEUSpeciesProductProcess = new Map<Id, ZTS_EU_Species_Product__c>(IntlOldListEUSpeciesProductProcess);

        if ( !IntlOldListEUSpeciesProductProcess.isEmpty() && !IntlOldMapEUSpeciesProductProcess.isEmpty() ) 
            INTLEUSpeciesProductTriggerService.beforeDelete(IntlOldListEUSpeciesProductProcess, IntlOldMapEUSpeciesProductProcess);
        if ( !UsOldListEUSpeciesProductProcess.isEmpty() && !UsOldMapEUSpeciesProductProcess.isEmpty() ) 
            USEUSpeciesProductTriggerService.beforeDelete(UsOldListEUSpeciesProductProcess, UsOldMapEUSpeciesProductProcess);
    }

    public static void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

    public static void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

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