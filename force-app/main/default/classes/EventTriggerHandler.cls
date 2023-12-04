/****************************************************************************************************************************************** 
 * Trigger Name : EventTriggerHandler
 * Description  : All Dispatch Trigger Logic for Event object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 6th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/06/2020          Created 
*****************************************************************************************************************************************/
public with sharing class EventTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    private Schema.sObjectField marketField = Event.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap)
    {
        //Filter triggerOld List for US Event 
        List<Event> UsOldListEventToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Event return Map
        Map<Id,Event> UsOldMapEventToProcess = new Map<Id, Event>(UsOldListEventToProcess);
        //Filter triggerNew List for INTL Event 
        List<Event> IntlOldListEventToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL Event return Map
        Map<Id,Event> IntlOldMapEventToProcess = new Map<Id, Event>(IntlOldListEventToProcess);

        if (!IntlOldListEventToProcess.isEmpty() && !IntlOldMapEventToProcess.isEmpty()) 
            INTLEventTriggerService.beforeDelete(IntlOldListEventToProcess, IntlOldMapEventToProcess);
        if (!UsOldListEventToProcess.isEmpty() && !UsOldMapEventToProcess.isEmpty()) 
            USEventTriggerService.beforeDelete(UsOldListEventToProcess, UsOldMapEventToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerNew List for US Event 
        List<Event> UsNewListEventToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Event return Map
        Map<Id,Event> UsNewMapEventToProcess = new Map<Id, Event>(UsNewListEventToProcess);
        //Filter triggerNew List for INTL Event 
        List<Event> IntlNewListEventToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Event return Map
        Map<Id,Event> IntlNewMapEventToProcess = new Map<Id, Event>(IntlNewListEventToProcess);

        if (!IntlNewListEventToProcess.isEmpty() && !IntlNewMapEventToProcess.isEmpty())
            INTLEventTriggerService.afterInsert(IntlNewListEventToProcess, IntlNewMapEventToProcess);
        if (!UsNewListEventToProcess.isEmpty() && !UsNewMapEventToProcess.isEmpty())
            USEventTriggerService.afterInsert(UsNewListEventToProcess, UsNewMapEventToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerOld List for US Event 
        List<Event> UsOldListEventToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Event return Map
        Map<Id,Event> UsOldMapEventToProcess = new Map<Id, Event>(UsOldListEventToProcess);
        //Filter triggerNew List for US Event 
        List<Event> UsNewListEventToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Event return Map
        Map<Id,Event> UsNewMapEventToProcess = new Map<Id, Event>(UsNewListEventToProcess);

        //Filter triggerOld List for INTL Event 
        List<Event> IntlOldListEventToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL Event return Map
        Map<Id,Event> IntlOldMapEventToProcess = new Map<Id, Event>(IntlOldListEventToProcess);
        //Filter triggerNew List for INTL Event 
        List<Event> IntlNewListEventToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Event return Map
        Map<Id,Event> IntlNewMapEventToProcess = new Map<Id, Event>(IntlNewListEventToProcess);

        if (!IntlOldListEventToProcess.isEmpty() && !IntlOldMapEventToProcess.isEmpty() && !IntlNewListEventToProcess.isEmpty() && !IntlNewMapEventToProcess.isEmpty())
            INTLEventTriggerService.afterUpdate(IntlOldListEventToProcess, IntlOldMapEventToProcess, IntlNewListEventToProcess, IntlNewMapEventToProcess);
        if (!UsOldListEventToProcess.isEmpty() && !UsOldMapEventToProcess.isEmpty() && !UsNewListEventToProcess.isEmpty() && !UsNewMapEventToProcess.isEmpty())
            USEventTriggerService.afterUpdate(UsOldListEventToProcess, UsOldMapEventToProcess, UsNewListEventToProcess, UsNewMapEventToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap)
    {
        //Filter triggerOld List for US Event 
        List<Event> UsOldListEventToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Event return Map
        Map<Id,Event> UsOldMapEventToProcess = new Map<Id, Event>(UsOldListEventToProcess);
        //Filter triggerNew List for INTL Event 
        List<Event> IntlOldListEventToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL Event return Map
        Map<Id,Event> IntlOldMapEventToProcess = new Map<Id, Event>(IntlOldListEventToProcess);
        
        if (!IntlOldListEventToProcess.isEmpty() && !IntlOldMapEventToProcess.isEmpty())
            INTLEventTriggerService.afterDelete(IntlOldListEventToProcess, IntlOldMapEventToProcess);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}