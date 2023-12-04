/****************************************************************************************************************************************** 
 * Trigger Name : TaskTriggerHandler
 * Description  : All Dispatch Trigger Logic for Task object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 6th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/06/2020          Created 
*****************************************************************************************************************************************/
public with sharing class TaskTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        USTaskTriggerService.beforeUpdate( triggerOld, (Map<Id, Task>)triggerOldMap, triggerNew, (Map<Id, Task>)triggerNewMap );
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
    	INTLTaskTriggerService.afterInsert(triggerNew, (Map<Id, Task>)triggerNewMap);
        USTaskTriggerService.afterInsert( triggerNew, (Map<Id, Task>) triggerNewMap );
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
    	INTLTaskTriggerService.afterUpdate(triggerOld, (Map<Id, Task>)triggerOldMap, triggerNew, (Map<Id, Task>)triggerNewMap);
        USTaskTriggerService.afterUpdate(triggerOld, (Map<Id, Task>)triggerOldMap, triggerNew, (Map<Id, Task>)triggerNewMap);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}