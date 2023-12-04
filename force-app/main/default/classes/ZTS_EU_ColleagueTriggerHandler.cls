/****************************************************************************************************************************************** 
 * Class Name   : ZTS_EU_ColleagueTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Colleague__c object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 11th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/11/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_EU_ColleagueTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        INTLZTS_EU_ColleagueTriggerService.beforeDelete(triggerOld, (Map<Id, ZTS_EU_Colleague__c>)triggerOldMap);
        USZTS_EU_ColleagueTriggerService.beforeDelete(triggerOld, (Map<Id, ZTS_EU_Colleague__c>)triggerOldMap);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        INTLZTS_EU_ColleagueTriggerService.afterInsert(triggerNew, (Map<Id, ZTS_EU_Colleague__c>)triggerNewMap);
        USZTS_EU_ColleagueTriggerService.afterInsert(triggerNew, (Map<Id, ZTS_EU_Colleague__c>)triggerNewMap);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        INTLZTS_EU_ColleagueTriggerService.afterDelete(triggerOld, (Map<Id, ZTS_EU_Colleague__c>)triggerOldMap);
        USZTS_EU_ColleagueTriggerService.afterDelete(triggerOld, (Map<Id, ZTS_EU_Colleague__c>)triggerOldMap);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}