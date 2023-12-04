/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_PositionTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Position__c object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 14th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/12/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_EU_PositionTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    //Field used for ZTS_EU_Position__c segmentation logic
    private Schema.sObjectField marketField = ZTS_EU_Position__c.market__c.getDescribe().getSObjectField();
    
    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerNew List for US ZTS_EU_Positions 
        List<ZTS_EU_Position__c> UsNewListPositionsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US ZTS_EU_Positions return Map
        Map<Id,ZTS_EU_Position__c> UsNewMapPositionsToProcess = new Map<Id, ZTS_EU_Position__c>(UsNewListPositionsToProcess);
        //Filter triggerNew List for INTL ZTS_EU_Positions 
        List<ZTS_EU_Position__c> IntlNewListPositionsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL ZTS_EU_Positions return Map
        Map<Id,ZTS_EU_Position__c> IntlNewMapPositionsToProcess = new Map<Id, ZTS_EU_Position__c>(IntlNewListPositionsToProcess);

        if (!IntlNewListPositionsToProcess.isEmpty() && !IntlNewMapPositionsToProcess.isEmpty())
            INTLZTS_EU_PositionTriggerService.afterInsert(IntlNewListPositionsToProcess, IntlNewMapPositionsToProcess);
        if (!UsNewListPositionsToProcess.isEmpty() && !UsNewMapPositionsToProcess.isEmpty())
            USZTS_EU_PositionTriggerService.afterInsert(UsNewListPositionsToProcess, UsNewMapPositionsToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US ZTS_EU_Positions 
        List<ZTS_EU_Position__c> UsOldListPositionsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US ZTS_EU_Positions return Map
        Map<Id,ZTS_EU_Position__c> UsOldMapPositionsToProcess = new Map<Id, ZTS_EU_Position__c>(UsOldListPositionsToProcess);
        //Filter triggerNew List for US ZTS_EU_Positions 
        List<ZTS_EU_Position__c> UsNewListPositionsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US ZTS_EU_Positions return Map
        Map<Id,ZTS_EU_Position__c> UsNewMapPositionsToProcess = new Map<Id, ZTS_EU_Position__c>(UsNewListPositionsToProcess);

        //Filter triggerOld List for INTL ZTS_EU_Positions 
        List<ZTS_EU_Position__c> IntlOldListPositionsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL ZTS_EU_Positions return Map
        Map<Id,ZTS_EU_Position__c> IntlOldMapPositionsToProcess = new Map<Id, ZTS_EU_Position__c>(IntlOldListPositionsToProcess);
        //Filter triggerNew List for INTL ZTS_EU_Positions 
        List<ZTS_EU_Position__c> IntlNewListPositionsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL ZTS_EU_Positions return Map
        Map<Id,ZTS_EU_Position__c> IntlNewMapPositionsToProcess = new Map<Id, ZTS_EU_Position__c>(IntlNewListPositionsToProcess);
        
        if (!IntlOldListPositionsToProcess.isEmpty() && !IntlOldMapPositionsToProcess.isEmpty() && !IntlNewListPositionsToProcess.isEmpty() && !IntlNewMapPositionsToProcess.isEmpty())
            INTLZTS_EU_PositionTriggerService.afterUpdate(IntlOldListPositionsToProcess, IntlOldMapPositionsToProcess, IntlNewListPositionsToProcess, IntlNewMapPositionsToProcess);
        if (!UsOldListPositionsToProcess.isEmpty() && !UsOldMapPositionsToProcess.isEmpty() && !UsNewListPositionsToProcess.isEmpty() && !UsNewMapPositionsToProcess.isEmpty())
            USZTS_EU_PositionTriggerService.afterUpdate(UsOldListPositionsToProcess, UsOldMapPositionsToProcess, UsNewListPositionsToProcess, UsNewMapPositionsToProcess);


    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}