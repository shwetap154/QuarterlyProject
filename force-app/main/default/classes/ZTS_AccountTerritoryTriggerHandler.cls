/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_AccountTerritoryTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_AccountTerritoryTriggerHandler object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 7th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/07/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_AccountTerritoryTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for ZTS_AccountTerritory__c segmentation logic
    private Schema.sObjectField marketField = ZTS_AccountTerritory__c.ZTS_EU_Market__c.getDescribe().getSObjectField();
    
    public void beforeInsert(List<SObject> triggerNew) {
        //Filter triggerNew List for International List
        List<ZTS_AccountTerritory__c> IntlNewListToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 
        if (!IntlNewListToProcess.isEmpty())INTLZTS_AccountTerritoryTriggerService.beforeInsert(IntlNewListToProcess);
    
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        //Filter triggerOld List for US List
        List<ZTS_AccountTerritory__c> USOldListToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Map
        Map<Id,ZTS_AccountTerritory__c> USOldMapToProcess = new Map<Id, ZTS_AccountTerritory__c>(UsOldListToProcess);
        //Filter triggerNew List for INTL List 
        List<ZTS_AccountTerritory__c> IntlOldListToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL Map
        Map<Id,ZTS_AccountTerritory__c> IntlOldMapToProcess = new Map<Id, ZTS_AccountTerritory__c>(IntlOldListToProcess);

        if (!IntlOldListToProcess.isEmpty() && !IntlOldMapToProcess.isEmpty()) 
            INTLZTS_AccountTerritoryTriggerService.beforeDelete(IntlOldListToProcess, IntlOldMapToProcess);
        if (!USOldListToProcess.isEmpty() && !USOldMapToProcess.isEmpty()) 
            INTLZTS_AccountTerritoryTriggerService.beforeDelete(USOldListToProcess, USOldMapToProcess);    
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US ZTS_AccountTerritory__c territories 
        List<ZTS_AccountTerritory__c> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US ZTS_AccountTerritory__c territories return Map
        Map<Id,ZTS_AccountTerritory__c> UsNewMapAccToProcess = new Map<Id, ZTS_AccountTerritory__c>(UsNewListAccToProcess);
        //Filter triggerNew List for INTL ZTS_AccountTerritory__c territories 
        List<ZTS_AccountTerritory__c> IntlNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL ZTS_AccountTerritory__c territories return Map
        Map<Id,ZTS_AccountTerritory__c> IntlNewMapAccToProcess = new Map<Id, ZTS_AccountTerritory__c>(IntlNewListAccToProcess);
        if (!IntlNewListAccToProcess.isEmpty() && !IntlNewMapAccToProcess.isEmpty())
            INTLZTS_AccountTerritoryTriggerService.afterInsert(IntlNewListAccToProcess, IntlNewMapAccToProcess);
        if (!UsNewListAccToProcess.isEmpty() && !UsNewMapAccToProcess.isEmpty())
            USZTS_AccountTerritoryTriggerService.afterInsert(UsNewListAccToProcess, UsNewMapAccToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US ZTS_AccountTerritory__c territories 
        List<ZTS_AccountTerritory__c> UsOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US ZTS_AccountTerritory__c territories return Map
        Map<Id,ZTS_AccountTerritory__c> UsOldMapAccToProcess = new Map<Id, ZTS_AccountTerritory__c>(UsOldListAccToProcess);
        //Filter triggerNew List for US ZTS_AccountTerritory__c territories 
        List<ZTS_AccountTerritory__c> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US ZTS_AccountTerritory__c territories return Map
        Map<Id,ZTS_AccountTerritory__c> UsNewMapAccToProcess = new Map<Id, ZTS_AccountTerritory__c>(UsNewListAccToProcess);

        //Filter triggerOld List for INTL ZTS_AccountTerritory__c territories 
        List<ZTS_AccountTerritory__c> IntlOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL ZTS_AccountTerritory__c territories return Map
        Map<Id,ZTS_AccountTerritory__c> IntlOldMapAccToProcess = new Map<Id, ZTS_AccountTerritory__c>(IntlOldListAccToProcess);
        //Filter triggerNew List for INTL ZTS_AccountTerritory__c territories 
        List<ZTS_AccountTerritory__c> IntlNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL ZTS_AccountTerritory__c territories return Map
        Map<Id,ZTS_AccountTerritory__c> IntlNewMapAccToProcess = new Map<Id, ZTS_AccountTerritory__c>(IntlNewListAccToProcess);
        
        if (!IntlOldListAccToProcess.isEmpty() && !IntlOldMapAccToProcess.isEmpty() && !IntlNewListAccToProcess.isEmpty() && !IntlNewMapAccToProcess.isEmpty())
            INTLZTS_AccountTerritoryTriggerService.afterUpdate(IntlOldListAccToProcess, IntlOldMapAccToProcess, IntlNewListAccToProcess, IntlNewMapAccToProcess);
        if (!UsOldListAccToProcess.isEmpty() && !UsOldMapAccToProcess.isEmpty() && !UsNewListAccToProcess.isEmpty() && !UsNewMapAccToProcess.isEmpty())
            USZTS_AccountTerritoryTriggerService.afterUpdate(UsOldListAccToProcess, UsOldMapAccToProcess, UsNewListAccToProcess, UsNewMapAccToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US ZTS_AccountTerritory__c territories 
        List<ZTS_AccountTerritory__c> UsOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US ZTS_AccountTerritory__c territories return Map
        Map<Id,ZTS_AccountTerritory__c> UsOldMapAccToProcess = new Map<Id, ZTS_AccountTerritory__c>(UsOldListAccToProcess);
        //Filter triggerNew List for INTL ZTS_AccountTerritory__c territories 
        List<ZTS_AccountTerritory__c> IntlOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL ZTS_AccountTerritory__c territories return Map
        Map<Id,ZTS_AccountTerritory__c> IntlOldMapAccToProcess = new Map<Id, ZTS_AccountTerritory__c>(IntlOldListAccToProcess);
        
        if (!IntlOldListAccToProcess.isEmpty() && !IntlOldMapAccToProcess.isEmpty())
            INTLZTS_AccountTerritoryTriggerService.afterDelete(IntlOldListAccToProcess, IntlOldMapAccToProcess);
        if (!UsOldListAccToProcess.isEmpty() && !UsOldMapAccToProcess.isEmpty())
            USZTS_AccountTerritoryTriggerService.afterDelete(UsOldListAccToProcess, UsOldMapAccToProcess);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US ZTS_AccountTerritory__c territories 
        List<ZTS_AccountTerritory__c> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US ZTS_AccountTerritory__c territories return Map
        Map<Id,ZTS_AccountTerritory__c> UsNewMapAccToProcess = new Map<Id, ZTS_AccountTerritory__c>(UsNewListAccToProcess);
        //Filter triggerNew List for INTL ZTS_AccountTerritory__c territories 
        List<ZTS_AccountTerritory__c> IntlNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL ZTS_AccountTerritory__c territories return Map
        Map<Id,ZTS_AccountTerritory__c> IntlNewMapAccToProcess = new Map<Id, ZTS_AccountTerritory__c>(IntlNewListAccToProcess);

        if (!IntlNewListAccToProcess.isEmpty() && !IntlNewMapAccToProcess.isEmpty())
            INTLZTS_AccountTerritoryTriggerService.afterUndelete(IntlNewListAccToProcess, IntlNewMapAccToProcess);
        if (!UsNewListAccToProcess.isEmpty() && !UsNewMapAccToProcess.isEmpty())
            USZTS_AccountTerritoryTriggerService.afterInsert(UsNewListAccToProcess, UsNewMapAccToProcess);
    }
}