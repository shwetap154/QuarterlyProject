/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EventsTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_Events object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 12th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           02/12/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_EventsTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    private Schema.sObjectField marketField = ZTS_Events__c.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US events 
        List<ZTS_Events__c> UsNewListEventsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL events 
        List<ZTS_Events__c> IntlEventsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!UsNewListEventsToProcess.isEmpty()) USZTS_EventsTriggerService.beforeInsert(UsNewListEventsToProcess);
        //Pooja TPDEV-885 change to throw error if user try to insert image in rich text field
        for( ZTS_Events__c eventObj :  (List<ZTS_Events__c>)triggerNew  ){
            if(eventObj.Purpose_Agenda__c != null && eventObj.Purpose_Agenda__c.contains('<img'))
            eventObj.addError('You cannot add image  in the Purpose/Agenda field');
        }   //Pooja TPDEV-885 change to throw error if user try to insert image in rich text field
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US events 
        List<ZTS_Events__c> UsOldListEventsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US events return Map
        Map<Id,ZTS_Events__c> UsOldMapEventsToProcess = new Map<Id, ZTS_Events__c>(UsOldListEventsToProcess);
        //Filter triggerNew List for US events 
        List<ZTS_Events__c> UsNewListEventsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US events return Map
        Map<Id,ZTS_Events__c> UsNewMapEventsToProcess = new Map<Id, ZTS_Events__c>(UsNewListEventsToProcess);

        //Filter triggerOld List for INTL events 
        List<ZTS_Events__c> IntlOldListEventsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL events return Map
        Map<Id,ZTS_Events__c> IntlOldMapEventsToProcess = new Map<Id, ZTS_Events__c>(IntlOldListEventsToProcess);
        //Filter triggerNew List for INTL events 
        List<ZTS_Events__c> IntlNewListEventsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL events return Map
        Map<Id,ZTS_Events__c> IntlNewMapEventsToProcess = new Map<Id, ZTS_Events__c>(IntlNewListEventsToProcess);
        //Pooja TPDEV-885 change to throw error if user try to insert image in rich text field
        for( ZTS_Events__c eventObj :  (List<ZTS_Events__c>)triggerNew  ){
             if(eventObj.Purpose_Agenda__c != null && eventObj.Purpose_Agenda__c.contains('<img'))
            eventObj.addError('You cannot add image  in the Purpose/Agenda field');
        }   //Pooja TPDEV-885 change to throw error if user try to insert image in rich text field

        if (!UsOldListEventsToProcess.isEmpty() && !UsOldMapEventsToProcess.isEmpty() && !UsNewListEventsToProcess.isEmpty() && !UsNewMapEventsToProcess.isEmpty())
            USZTS_EventsTriggerService.beforeUpdate(UsOldListEventsToProcess, UsOldMapEventsToProcess, UsNewListEventsToProcess, UsNewMapEventsToProcess);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US events 
        List<ZTS_Events__c> UsOldListEventsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US events return Map
        Map<Id,ZTS_Events__c> UsOldMapEventsToProcess = new Map<Id, ZTS_Events__c>(UsOldListEventsToProcess);
        //Filter triggerNew List for INTL events 
        List<ZTS_Events__c> IntlOldListEventsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL events return Map
        Map<Id,ZTS_Events__c> IntlOldMapEventsToProcess = new Map<Id, ZTS_Events__c>(IntlOldListEventsToProcess);

        if (!UsOldListEventsToProcess.isEmpty() && !UsOldMapEventsToProcess.isEmpty()) 
            USZTS_EventsTriggerService.beforeDelete(UsOldListEventsToProcess, UsOldMapEventsToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US events 
        List<ZTS_Events__c> UsNewListEventsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US events return Map
        Map<Id,ZTS_Events__c> UsNewMapEventsToProcess = new Map<Id, ZTS_Events__c>(UsNewListEventsToProcess);
        //Filter triggerNew List for INTL events 
        List<ZTS_Events__c> IntlNewListEventsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL events return Map
        Map<Id,ZTS_Events__c> IntlNewMapEventsToProcess = new Map<Id, ZTS_Events__c>(IntlNewListEventsToProcess);

        if (!IntlNewListEventsToProcess.isEmpty() && !IntlNewMapEventsToProcess.isEmpty())
            INTLZTS_EventsTriggerService.afterInsert(IntlNewListEventsToProcess, IntlNewMapEventsToProcess);
        if (!UsNewListEventsToProcess.isEmpty() && !UsNewMapEventsToProcess.isEmpty())
            USZTS_EventsTriggerService.afterInsert(UsNewListEventsToProcess, UsNewMapEventsToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerOld List for US events 
        List<ZTS_Events__c> UsOldListEventsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US events return Map
        Map<Id,ZTS_Events__c> UsOldMapEventsToProcess = new Map<Id, ZTS_Events__c>(UsOldListEventsToProcess);
        //Filter triggerNew List for US events 
        List<ZTS_Events__c> UsNewListEventsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US events return Map
        Map<Id,ZTS_Events__c> UsNewMapEventsToProcess = new Map<Id, ZTS_Events__c>(UsNewListEventsToProcess);

        //Filter triggerOld List for INTL events 
        List<ZTS_Events__c> IntlOldListEventsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL events return Map
        Map<Id,ZTS_Events__c> IntlOldMapEventsToProcess = new Map<Id, ZTS_Events__c>(IntlOldListEventsToProcess);
        //Filter triggerNew List for INTL events 
        List<ZTS_Events__c> IntlNewListEventsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL events return Map
        Map<Id,ZTS_Events__c> IntlNewMapEventsToProcess = new Map<Id, ZTS_Events__c>(IntlNewListEventsToProcess);
        
        if (!IntlOldListEventsToProcess.isEmpty() && !IntlOldMapEventsToProcess.isEmpty() && !IntlNewListEventsToProcess.isEmpty() && !IntlNewMapEventsToProcess.isEmpty())
            INTLZTS_EventsTriggerService.afterUpdate(IntlOldListEventsToProcess, IntlOldMapEventsToProcess, IntlNewListEventsToProcess, IntlNewMapEventsToProcess);
        if (!UsOldListEventsToProcess.isEmpty() && !UsOldMapEventsToProcess.isEmpty() && !UsNewListEventsToProcess.isEmpty() && !UsNewMapEventsToProcess.isEmpty())
            USZTS_EventsTriggerService.afterUpdate(UsOldListEventsToProcess, UsOldMapEventsToProcess, UsNewListEventsToProcess, UsNewMapEventsToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}