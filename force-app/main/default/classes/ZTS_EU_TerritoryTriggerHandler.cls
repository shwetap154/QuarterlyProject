/****************************************************************************************************************************************** 
 * Class Name   : ZTS_EU_TerritoryTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Territory__c object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 12th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/12/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_EU_TerritoryTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    private Schema.sObjectField marketField = ZTS_EU_Territory__c.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US territories 
        List<ZTS_EU_Territory__c> UsOldListTerritoryToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US territories return Map
        Map<Id,ZTS_EU_Territory__c> UsOldMapTerritoryToProcess = new Map<Id, ZTS_EU_Territory__c>(UsOldListTerritoryToProcess);
        //Filter triggerNew List for INTL territories 
        List<ZTS_EU_Territory__c> IntlOldListTerritoryToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL territories return Map
        Map<Id,ZTS_EU_Territory__c> IntlOldMapTerritoryToProcess = new Map<Id, ZTS_EU_Territory__c>(IntlOldListTerritoryToProcess);

        if (!IntlOldListTerritoryToProcess.isEmpty() && !IntlOldMapTerritoryToProcess.isEmpty()) 
            INTLZTS_EU_TerritoryTriggerService.beforeDelete(IntlOldListTerritoryToProcess, IntlOldMapTerritoryToProcess);
        if (!UsOldListTerritoryToProcess.isEmpty() && !UsOldMapTerritoryToProcess.isEmpty()) 
            USZTS_EU_TerritoryTriggerService.beforeDelete(UsOldListTerritoryToProcess, UsOldMapTerritoryToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}