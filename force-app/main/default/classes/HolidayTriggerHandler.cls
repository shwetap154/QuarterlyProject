/****************************************************************************************************************************************** 
 * Trigger Name : HolidayTriggerHandler
 * Description  : All Dispatch Trigger Logic for Holiday object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 28th May, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           05/28/2020          Created 
*****************************************************************************************************************************************/
public with sharing class HolidayTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for Holiday segmentation logic
    private Schema.sObjectField marketField = Holiday__c.ZTS_EU_Market__c.getDescribe().getSObjectField();
    
    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US Holidays 
        List<Holiday__c> UsOldListHolidayToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Holidays return Map
        Map<Id,Holiday__c> UsOldMapHolidayToProcess = new Map<Id, Holiday__c>(UsOldListHolidayToProcess);
        //Filter triggerNew List for INTL Holidays 
        List<Holiday__c> IntlOldListHolidayToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL Holidays return Map
        Map<Id,Holiday__c> IntlOldMapHolidayToProcess = new Map<Id, Holiday__c>(IntlOldListHolidayToProcess);

        if (!IntlOldListHolidayToProcess.isEmpty() && !IntlOldMapHolidayToProcess.isEmpty()) 
            INTLHolidayTriggerService.beforeDelete(IntlOldListHolidayToProcess, IntlOldMapHolidayToProcess);
        
        if (!UsOldListHolidayToProcess.isEmpty() && !UsOldMapHolidayToProcess.isEmpty()) 
            USHolidayTriggerService.beforeDelete(UsOldListHolidayToProcess, UsOldMapHolidayToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US Holidays 
        List<Holiday__c> UsNewListHolidayToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Holidays return Map
        Map<Id,Holiday__c> UsNewMapHolidayToProcess = new Map<Id, Holiday__c>(UsNewListHolidayToProcess);
        //Filter triggerNew List for INTL Holidays 
        List<Holiday__c> IntlNewListHolidayToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Holidays return Map
        Map<Id,Holiday__c> IntlNewMapHolidayToProcess = new Map<Id, Holiday__c>(IntlNewListHolidayToProcess);

        if (!IntlNewListHolidayToProcess.isEmpty() && !IntlNewMapHolidayToProcess.isEmpty())
            INTLHolidayTriggerService.afterInsert(IntlNewListHolidayToProcess, IntlNewMapHolidayToProcess);
        
        if (!UsNewListHolidayToProcess.isEmpty() && !UsNewMapHolidayToProcess.isEmpty())
            USHolidayTriggerService.afterInsert(UsNewListHolidayToProcess, UsNewMapHolidayToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US Holidays 
        List<Holiday__c> UsOldListHolidayToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Holidays return Map
        Map<Id,Holiday__c> UsOldMapHolidayToProcess = new Map<Id, Holiday__c>(UsOldListHolidayToProcess);
        //Filter triggerNew List for US Holidays 
        List<Holiday__c> UsNewListHolidayToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Holidays return Map
        Map<Id,Holiday__c> UsNewMapHolidayToProcess = new Map<Id, Holiday__c>(UsNewListHolidayToProcess);

        //Filter triggerOld List for INTL Holidays 
        List<Holiday__c> IntlOldListHolidayToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL Holidays return Map
        Map<Id,Holiday__c> IntlOldMapHolidayToProcess = new Map<Id, Holiday__c>(IntlOldListHolidayToProcess);
        //Filter triggerNew List for INTL Holidays 
        List<Holiday__c> IntlNewListHolidayToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Holidays return Map
        Map<Id,Holiday__c> IntlNewMapHolidayToProcess = new Map<Id, Holiday__c>(IntlNewListHolidayToProcess);
        
        if (!IntlOldListHolidayToProcess.isEmpty() && !IntlOldMapHolidayToProcess.isEmpty() && !IntlNewListHolidayToProcess.isEmpty() && !IntlNewMapHolidayToProcess.isEmpty())
            INTLHolidayTriggerService.afterUpdate(IntlOldListHolidayToProcess, IntlOldMapHolidayToProcess, IntlNewListHolidayToProcess, IntlNewMapHolidayToProcess);
        
          if (!UsOldListHolidayToProcess.isEmpty() && !UsOldMapHolidayToProcess.isEmpty() && !UsNewListHolidayToProcess.isEmpty() && !UsNewMapHolidayToProcess.isEmpty())
            USHolidayTriggerService.afterUpdate(UsOldListHolidayToProcess, UsOldMapHolidayToProcess, UsNewListHolidayToProcess, UsNewMapHolidayToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}