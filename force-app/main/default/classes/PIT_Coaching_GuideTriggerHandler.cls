/****************************************************************************************************************************************** 
 * Trigger Name : PIT_Coaching_GuideTriggerHandler
 * Description  : All Dispatch Trigger Logic for Coaching Guide object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 10th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/10/2020          Created 
*****************************************************************************************************************************************/
public with sharing class PIT_Coaching_GuideTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    private Schema.sObjectField marketField = PIT_Coaching_Guide__c.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew)
    {
        //Filter triggerNew List for US Time Out Of Territories 
        List<PIT_Coaching_Guide__c> UsNewListGuideToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL Time Out Of Territories 
        List<PIT_Coaching_Guide__c> IntlNewListGuideToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlNewListGuideToProcess.isEmpty()) INTLPIT_Coaching_GuideTriggerService.beforeInsert(IntlNewListGuideToProcess);
        if (!UsNewListGuideToProcess.isEmpty()) USPIT_Coaching_GuideTriggerService.beforeInsert(UsNewListGuideToProcess);
        
        
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        
        //Filter triggerOld List for US Time Out Of Territories 
        List<PIT_Coaching_Guide__c> UsOldListGuideToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Time Out Of Territories return Map
        Map<Id,PIT_Coaching_Guide__c> UsOldMapGuideToProcess = new Map<Id, PIT_Coaching_Guide__c>(UsOldListGuideToProcess);
        //Filter triggerNew List for US Time Out Of Territories 
        List<PIT_Coaching_Guide__c> UsNewListGuideToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Time Out Of Territories return Map
        Map<Id,PIT_Coaching_Guide__c> UsNewMapGuideToProcess = new Map<Id, PIT_Coaching_Guide__c>(UsNewListGuideToProcess);

        //Filter triggerOld List for INTL Time Out Of Territories 
        List<PIT_Coaching_Guide__c> IntlOldListGuideToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL Time Out Of Territories return Map
        Map<Id,PIT_Coaching_Guide__c> IntlOldMapGuideToProcess = new Map<Id, PIT_Coaching_Guide__c>(IntlOldListGuideToProcess);
        //Filter triggerNew List for INTL Time Out Of Territories 
        List<PIT_Coaching_Guide__c> IntlNewListGuideToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Time Out Of Territories return Map
        Map<Id,PIT_Coaching_Guide__c> IntlNewMapGuideToProcess = new Map<Id, PIT_Coaching_Guide__c>(IntlNewListGuideToProcess);

        if (!IntlOldListGuideToProcess.isEmpty() && !IntlOldMapGuideToProcess.isEmpty() && !IntlNewListGuideToProcess.isEmpty() && !IntlNewMapGuideToProcess.isEmpty())
            INTLPIT_Coaching_GuideTriggerService.beforeUpdate(IntlOldListGuideToProcess, IntlOldMapGuideToProcess, IntlNewListGuideToProcess, IntlNewMapGuideToProcess);
        if (!UsOldListGuideToProcess.isEmpty() && !UsOldMapGuideToProcess.isEmpty() && !UsNewListGuideToProcess.isEmpty() && !UsNewMapGuideToProcess.isEmpty())
            USPIT_Coaching_GuideTriggerService.beforeUpdate(UsOldListGuideToProcess, UsOldMapGuideToProcess, UsNewListGuideToProcess, UsNewMapGuideToProcess);
        
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US Time Out Of Territories 
        List<PIT_Coaching_Guide__c> UsOldListGuideToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Time Out Of Territories return Map
        Map<Id,PIT_Coaching_Guide__c> UsOldMapGuideToProcess = new Map<Id, PIT_Coaching_Guide__c>(UsOldListGuideToProcess);
        //Filter triggerNew List for INTL Time Out Of Territories 
        List<PIT_Coaching_Guide__c> IntlOldListGuideToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL Time Out Of Territories return Map
        Map<Id,PIT_Coaching_Guide__c> IntlOldMapGuideToProcess = new Map<Id, PIT_Coaching_Guide__c>(IntlOldListGuideToProcess);

        if (!UsOldListGuideToProcess.isEmpty() && !UsOldMapGuideToProcess.isEmpty()) 
            USPIT_Coaching_GuideTriggerService.beforeDelete(UsOldListGuideToProcess, UsOldMapGuideToProcess);
        if (!IntlOldListGuideToProcess.isEmpty() && !IntlOldMapGuideToProcess.isEmpty()) 
            INTLPIT_Coaching_GuideTriggerService.beforeDelete(IntlOldListGuideToProcess, IntlOldMapGuideToProcess);

    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US Time Out Of Territories 
        List<PIT_Coaching_Guide__c> UsNewListGuideToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Time Out Of Territories return Map
        Map<Id,PIT_Coaching_Guide__c> UsNewMapGuideToProcess = new Map<Id, PIT_Coaching_Guide__c>(UsNewListGuideToProcess);
        //Filter triggerNew List for INTL Time Out Of Territories 
        List<PIT_Coaching_Guide__c> IntlNewListGuideToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Time Out Of Territories return Map
        Map<Id,PIT_Coaching_Guide__c> IntlNewMapGuideToProcess = new Map<Id, PIT_Coaching_Guide__c>(IntlNewListGuideToProcess);

        if (!IntlNewListGuideToProcess.isEmpty() && !IntlNewMapGuideToProcess.isEmpty())
            INTLPIT_Coaching_GuideTriggerService.afterInsert(IntlNewListGuideToProcess, IntlNewMapGuideToProcess);
        if (!UsNewListGuideToProcess.isEmpty() && !UsNewMapGuideToProcess.isEmpty())
            USPIT_Coaching_GuideTriggerService.afterInsert(UsNewListGuideToProcess, UsNewMapGuideToProcess);  

    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap){}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}