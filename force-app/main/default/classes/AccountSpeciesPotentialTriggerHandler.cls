/****************************************************************************************************************************************** 
 * Trigger Name : AccountSpeciesPotentialTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Account_Species_Potential__c object.
 * Created By   : Slalom(Allister McKenzie) 
 * Created Date : 20th November, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                ```Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Allister McKenzie           11/20/2020          Created 
*****************************************************************************************************************************************/
public with sharing class AccountSpeciesPotentialTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface {

    //Field used for Account segmentation logic
    private static Schema.sObjectField marketField = ZTS_EU_Account_Species_Potential__c.ZTS_EU_Market_from_Parent__c.getDescribe().getSObjectField();
    
    public static void beforeInsert(List<SObject> triggerNew) {}

    public static void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {

        //Filter triggerOld List for INTL accounts 
        List<ZTS_EU_Account_Species_Potential__c> IntlOldListAccSpecPotToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL accounts return Map
        Map<Id,ZTS_EU_Account_Species_Potential__c> IntlOldMapAccSpecPotToProcess = new Map<Id, ZTS_EU_Account_Species_Potential__c>(IntlOldListAccSpecPotToProcess);
        //Filter triggerNew List for INTL accounts 
        List<ZTS_EU_Account_Species_Potential__c> IntlNewListAccSpecPotToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL accounts return Map
        Map<Id,ZTS_EU_Account_Species_Potential__c> IntlNewMapAccSpecPotToProcess = new Map<Id, ZTS_EU_Account_Species_Potential__c>(IntlNewListAccSpecPotToProcess);

        if (!IntlOldListAccSpecPotToProcess.isEmpty() && !IntlOldMapAccSpecPotToProcess.isEmpty() && !IntlNewListAccSpecPotToProcess.isEmpty() && !IntlNewMapAccSpecPotToProcess.isEmpty())
            INTLAcctSpeciesPotentialTriggerService.beforeUpdate(IntlOldListAccSpecPotToProcess, IntlOldMapAccSpecPotToProcess, IntlNewListAccSpecPotToProcess, IntlNewMapAccSpecPotToProcess);
    }

    public static void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        //Filter triggerNew List for INTL accounts 
        List<ZTS_EU_Account_Species_Potential__c> IntlOldListAccSpecPotToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL accounts return Map
        Map<Id,ZTS_EU_Account_Species_Potential__c> IntlOldMapAccSpecPotToProcess = new Map<Id, ZTS_EU_Account_Species_Potential__c>(IntlOldListAccSpecPotToProcess);

        if (!IntlOldListAccSpecPotToProcess.isEmpty() && !IntlOldMapAccSpecPotToProcess.isEmpty()) 
            INTLAcctSpeciesPotentialTriggerService.beforeDelete(IntlOldListAccSpecPotToProcess, IntlOldMapAccSpecPotToProcess);
    }

    public static void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        //Filter triggerNew List for INTL accounts 
        List<ZTS_EU_Account_Species_Potential__c> IntlNewListAccSpecPotToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL accounts return Map
        Map<Id,ZTS_EU_Account_Species_Potential__c> IntlNewMapAccSpecPotToProcess = new Map<Id, ZTS_EU_Account_Species_Potential__c>(IntlNewListAccSpecPotToProcess);

        if (!IntlNewListAccSpecPotToProcess.isEmpty() && !IntlNewMapAccSpecPotToProcess.isEmpty())
            INTLAcctSpeciesPotentialTriggerService.afterInsert(IntlNewListAccSpecPotToProcess, IntlNewMapAccSpecPotToProcess);
    }

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