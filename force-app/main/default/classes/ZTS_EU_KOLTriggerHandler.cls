/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_KOLTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_KOL object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 11th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           02/11/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_EU_KOLTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    public void beforeInsert(List<SObject> triggerNew) 
    {
        USZTS_EU_KOLTriggerService.beforeInsert(triggerNew);
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        USZTS_EU_KOLTriggerService.beforeUpdate(triggerOld, (Map<Id, ZTS_EU_KOL__c>)triggerOldMap, triggerNew, (Map<Id, ZTS_EU_KOL__c>)triggerNewMap);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        USZTS_EU_KOLTriggerService.afterInsert(triggerNew, (Map<Id, ZTS_EU_KOL__c>) triggerNewMap);
        INTLZTS_EU_KOLTriggerService.afterInsert(triggerNew, (Map<Id, ZTS_EU_KOL__c>) triggerNewMap);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        USZTS_EU_KOLTriggerService.afterUpdate(triggerOld, (Map<Id, ZTS_EU_KOL__c>) triggerOldMap, triggerNew, (Map<Id, ZTS_EU_KOL__c>) triggerNewMap);
        INTLZTS_EU_KOLTriggerService.afterUpdate(triggerOld, (Map<Id, ZTS_EU_KOL__c>) triggerOldMap, triggerNew, (Map<Id, ZTS_EU_KOL__c>) triggerNewMap);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        USZTS_EU_KOLTriggerService.afterDelete(triggerOld, (Map<Id, ZTS_EU_KOL__c>) triggerOldMap);
        INTLZTS_EU_KOLTriggerService.afterDelete(triggerOld, (Map<Id, ZTS_EU_KOL__c>) triggerOldMap);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        USZTS_EU_KOLTriggerService.afterUndelete(triggerNew, (Map<Id, ZTS_EU_KOL__c>) triggerNewMap);
        INTLZTS_EU_KOLTriggerService.afterUndelete(triggerNew, (Map<Id, ZTS_EU_KOL__c>) triggerNewMap);
    }
}