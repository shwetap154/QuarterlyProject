/****************************************************************************************************************************************** 
 * Trigger Name : Sample_DropTriggerHandler
 * Description  : All Dispatch Trigger Logic for Sample_Drop__c object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 18th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/18/2020          Created 
*****************************************************************************************************************************************/
public with sharing class Sample_DropTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    public void beforeInsert(List<SObject> triggerNew) 
    {
        INTLSample_DropTriggerService.beforeInsert(triggerNew);
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        INTLSample_DropTriggerService.beforeUpdate(triggerOld, (Map<Id, Sample_Drop__c>)triggerOldMap, triggerNew, (Map<Id, Sample_Drop__c>)triggerNewMap);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        INTLSample_DropTriggerService.afterInsert(triggerNew, (Map<Id, Sample_Drop__c>)triggerNewMap);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}