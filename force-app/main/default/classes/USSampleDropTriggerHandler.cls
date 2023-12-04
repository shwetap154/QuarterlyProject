/****************************************************************************************************************************************** 
 * Class Name : USSampleDropTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_US_Sample_Drop__c object.
 * Created By   : Slalom(Alex Carstairs) 
 * Created Date : 26th May 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs           05/26/2020          Created 
*****************************************************************************************************************************************/
public with sharing class USSampleDropTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        USSampleDropTriggerService.beforeDelete(triggerOld, (Map<Id, ZTS_US_Sample_Drop__c>)triggerOldMap);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        USSampleDropTriggerService.afterInsert(triggerNew, (Map<Id, ZTS_US_Sample_Drop__c>)triggerNewMap);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}