/****************************************************************************************************************************************** 
 * Class Name   : AttendeeTriggerHandler
 * Description  : All Dispatch Trigger Logic for Attendee object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 10th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/10/2020          Created 
*****************************************************************************************************************************************/
public with sharing class AttendeeTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    private Schema.sObjectField marketField = Attendee__c.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US attendees 
        system.debug('before list');
        List<Attendee__c> UsNewListAttendeeToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        system.debug('after list:'+UsNewListAttendeeToProcess);
        //Filter triggerNew List for INTL attendees 
        List<Attendee__c> IntlAttendeeToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!UsNewListAttendeeToProcess.isEmpty()) USAttendeeTriggerService.beforeInsert(UsNewListAttendeeToProcess);
         //Newly added line to populate represent acount for INTL Markets TPDEV-2016	
          if (!IntlAttendeeToProcess.isEmpty()) INTLAttendeeTriggerService.beforeInsert(IntlAttendeeToProcess);
       
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US attendees 
        List<Attendee__c> UsOldListAttendeeToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US attendees return Map
        Map<Id,Attendee__c> UsOldMapAttendeeToProcess = new Map<Id, Attendee__c>(UsOldListAttendeeToProcess);
        //Filter triggerNew List for INTL attendees 
        List<Attendee__c> IntlOldListAttendeeToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL attendees return Map
        Map<Id,Attendee__c> IntlOldMapAttendeeToProcess = new Map<Id, Attendee__c>(IntlOldListAttendeeToProcess);

        if (!IntlOldListAttendeeToProcess.isEmpty() && !IntlOldMapAttendeeToProcess.isEmpty()) 
            INTLAttendeeTriggerService.beforeDelete(IntlOldListAttendeeToProcess, IntlOldMapAttendeeToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US attendees 
        List<Attendee__c> UsNewListAttendeeToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US attendees return Map
        Map<Id,Attendee__c> UsNewMapAttendeeToProcess = new Map<Id, Attendee__c>(UsNewListAttendeeToProcess);
        //Filter triggerNew List for INTL attendees 
        List<Attendee__c> IntlNewListAttendeeToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL attendees return Map
        Map<Id,Attendee__c> IntlNewMapAttendeeToProcess = new Map<Id, Attendee__c>(IntlNewListAttendeeToProcess);

        if (!IntlNewListAttendeeToProcess.isEmpty() && !IntlNewMapAttendeeToProcess.isEmpty())
            INTLAttendeeTriggerService.afterInsert(IntlNewListAttendeeToProcess, IntlNewMapAttendeeToProcess);
        if (!UsNewListAttendeeToProcess.isEmpty() && !UsNewMapAttendeeToProcess.isEmpty())
            USAttendeeTriggerService.afterInsert(UsNewListAttendeeToProcess, UsNewMapAttendeeToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US attendees 
        List<Attendee__c> UsOldListAttendeeToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US attendees return Map
        Map<Id,Attendee__c> UsOldMapAttendeeToProcess = new Map<Id, Attendee__c>(UsOldListAttendeeToProcess);
        //Filter triggerNew List for INTL attendees 
        List<Attendee__c> IntlOldListAttendeeToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL attendees return Map
        Map<Id,Attendee__c> IntlOldMapAttendeeToProcess = new Map<Id, Attendee__c>(IntlOldListAttendeeToProcess);
        
        if (!IntlOldListAttendeeToProcess.isEmpty() && !IntlOldMapAttendeeToProcess.isEmpty())
            INTLAttendeeTriggerService.afterDelete(IntlOldListAttendeeToProcess, IntlOldMapAttendeeToProcess);
        if (!UsOldListAttendeeToProcess.isEmpty() && !UsOldMapAttendeeToProcess.isEmpty())
            USAttendeeTriggerService.afterDelete(UsOldListAttendeeToProcess, UsOldMapAttendeeToProcess);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}