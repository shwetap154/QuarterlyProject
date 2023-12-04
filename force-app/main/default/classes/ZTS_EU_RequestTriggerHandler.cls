/****************************************************************************************************************************************** 
 * Class Name   : ZTS_EU_RequestTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Request__c object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 11th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/11/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_EU_RequestTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        INTLZTS_EU_RequestTriggerService.beforeUpdate(triggerOld, (Map<Id, ZTS_EU_Request__c>)triggerOldMap, triggerNew, (Map<Id, ZTS_EU_Request__c>)triggerNewMap);
        // These two methods perform the same action.  Keeping for posterity.
        //USZTS_EU_RequestTriggerService.beforeUpdate(triggerOld, (Map<Id, ZTS_EU_Request__c>)triggerOldMap, triggerNew, (Map<Id, ZTS_EU_Request__c>)triggerNewMap);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}