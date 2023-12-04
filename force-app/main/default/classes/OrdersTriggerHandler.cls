public with sharing class OrdersTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for Orders__c segmentation logic
    private Schema.sObjectField marketField = Orders__c.ZTS_EU_Market__c.getDescribe().getSObjectField();
        
    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US Orders 
        List<Orders__c> UsNewListOrderToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL Orders 
        List<Orders__c> IntlOrderToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlOrderToProcess.isEmpty()) INTLOrdersTriggerService.beforeInsert(IntlOrderToProcess);
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US Orders 
        List<Orders__c> UsOldListOrderToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Orders return Map
        Map<Id,Orders__c> UsOldMapOrderToProcess = new Map<Id, Orders__c>(UsOldListOrderToProcess);
        //Filter triggerNew List for INTL Orders 
        List<Orders__c> IntlOldListOrderToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL Orders return Map
        Map<Id,Orders__c> IntlOldMapOrderToProcess = new Map<Id, Orders__c>(IntlOldListOrderToProcess);

        if (!IntlOldListOrderToProcess.isEmpty() && !IntlOldMapOrderToProcess.isEmpty()) 
            INTLOrdersTriggerService.beforeDelete(IntlOldListOrderToProcess, IntlOldMapOrderToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US Orders 
        List<Orders__c> UsNewListOrderToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Orders return Map
        Map<Id,Orders__c> UsNewMapOrderToProcess = new Map<Id, Orders__c>(UsNewListOrderToProcess);
        //Filter triggerNew List for INTL Orders 
        List<Orders__c> IntlNewListOrderToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Orders return Map
        Map<Id,Orders__c> IntlNewMapOrderToProcess = new Map<Id, Orders__c>(IntlNewListOrderToProcess);

        if (!IntlNewListOrderToProcess.isEmpty() && !IntlNewMapOrderToProcess.isEmpty())
            INTLOrdersTriggerService.afterInsert(IntlNewListOrderToProcess, IntlNewMapOrderToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}    

}