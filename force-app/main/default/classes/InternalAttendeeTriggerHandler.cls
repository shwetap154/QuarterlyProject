/****************************************************************************************************************************************** 
 * Trigger Name : InternalAttendeeTriggerHandler
 * Description  : All Dispatch Trigger Logic for Zoetis Attendee object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 6th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/06/2020          Created 
*****************************************************************************************************************************************/
public with sharing class InternalAttendeeTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
    	USInternalAttendeeTriggerService.afterInsert(triggerNew, (Map<Id, ZTS_US_Internal_Attendee__c>)triggerNewMap);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap){}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        USInternalAttendeeTriggerService.afterDelete(triggerOld, (Map<Id, ZTS_US_Internal_Attendee__c>)triggerOldMap);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}