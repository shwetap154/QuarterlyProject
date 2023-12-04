/****************************************************************************************************************************************** 
 * Trigger Name : Time_Out_of_TerritoryTriggerHandler
 * Description  : All Dispatch Trigger Logic for Time_Out_of_Territory__c object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 12th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/12/2020          Created 
*****************************************************************************************************************************************/
public with sharing class Time_Out_of_TerritoryTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    private Schema.sObjectField marketField = Time_Out_of_Territory__c.ZTS_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US Time Out Of Territories 
        List<Time_Out_of_Territory__c> UsNewListTotToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL Time Out Of Territories 
        List<Time_Out_of_Territory__c> IntlTotToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlTotToProcess.isEmpty()) INTLTime_Out_of_TerritoryTriggerService.beforeInsert(IntlTotToProcess);
        if (!UsNewListTotToProcess.isEmpty()) USTime_Out_of_TerritoryTriggerService.beforeInsert(UsNewListTotToProcess);   
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US Time Out Of Territories 
        List<Time_Out_of_Territory__c> UsOldListTotToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Time Out Of Territories return Map
        Map<Id,Time_Out_of_Territory__c> UsOldMapTotToProcess = new Map<Id, Time_Out_of_Territory__c>(UsOldListTotToProcess);
        //Filter triggerNew List for US Time Out Of Territories 
        List<Time_Out_of_Territory__c> UsNewListTotToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Time Out Of Territories return Map
        Map<Id,Time_Out_of_Territory__c> UsNewMapTotToProcess = new Map<Id, Time_Out_of_Territory__c>(UsNewListTotToProcess);

        //Filter triggerOld List for INTL Time Out Of Territories 
        List<Time_Out_of_Territory__c> IntlOldListTotToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL Time Out Of Territories return Map
        Map<Id,Time_Out_of_Territory__c> IntlOldMapTotToProcess = new Map<Id, Time_Out_of_Territory__c>(IntlOldListTotToProcess);
        //Filter triggerNew List for INTL Time Out Of Territories 
        List<Time_Out_of_Territory__c> IntlNewListTotToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Time Out Of Territories return Map
        Map<Id,Time_Out_of_Territory__c> IntlNewMapTotToProcess = new Map<Id, Time_Out_of_Territory__c>(IntlNewListTotToProcess);

        if (!IntlOldListTotToProcess.isEmpty() && !IntlOldMapTotToProcess.isEmpty() && !IntlNewListTotToProcess.isEmpty() && !IntlNewMapTotToProcess.isEmpty())
            INTLTime_Out_of_TerritoryTriggerService.beforeUpdate(IntlOldListTotToProcess, IntlOldMapTotToProcess, IntlNewListTotToProcess, IntlNewMapTotToProcess);
        if (!UsOldListTotToProcess.isEmpty() && !UsOldMapTotToProcess.isEmpty() && !UsNewListTotToProcess.isEmpty() && !UsNewMapTotToProcess.isEmpty())
            USTime_Out_of_TerritoryTriggerService.beforeUpdate(UsOldListTotToProcess, UsOldMapTotToProcess, UsNewListTotToProcess, UsNewMapTotToProcess);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US Time Out Of Territories 
        List<Time_Out_of_Territory__c> UsOldListTotToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Time Out Of Territories return Map
        Map<Id,Time_Out_of_Territory__c> UsOldMapTotToProcess = new Map<Id, Time_Out_of_Territory__c>(UsOldListTotToProcess);
        //Filter triggerNew List for INTL Time Out Of Territories 
        List<Time_Out_of_Territory__c> IntlOldListTotToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL Time Out Of Territories return Map
        Map<Id,Time_Out_of_Territory__c> IntlOldMapTotToProcess = new Map<Id, Time_Out_of_Territory__c>(IntlOldListTotToProcess);

        if (!UsOldListTotToProcess.isEmpty() && !UsOldMapTotToProcess.isEmpty()) 
            USTime_Out_of_TerritoryTriggerService.beforeDelete(UsOldListTotToProcess, UsOldMapTotToProcess);

    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerNew List for US Time Out Of Territories 
        List<Time_Out_of_Territory__c> UsNewListTotToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Time Out Of Territories return Map
        Map<Id,Time_Out_of_Territory__c> UsNewMapTotToProcess = new Map<Id, Time_Out_of_Territory__c>(UsNewListTotToProcess);
        //Filter triggerNew List for INTL Time Out Of Territories 
        List<Time_Out_of_Territory__c> IntlNewListTotToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Time Out Of Territories return Map
        Map<Id,Time_Out_of_Territory__c> IntlNewMapTotToProcess = new Map<Id, Time_Out_of_Territory__c>(IntlNewListTotToProcess);

        if (!IntlNewListTotToProcess.isEmpty() && !IntlNewMapTotToProcess.isEmpty())
            INTLTime_Out_of_TerritoryTriggerService.afterInsert(IntlNewListTotToProcess, IntlNewMapTotToProcess);
        if (!UsNewListTotToProcess.isEmpty() && !UsNewMapTotToProcess.isEmpty())
            USTime_Out_of_TerritoryTriggerService.afterInsert(UsNewListTotToProcess, UsNewMapTotToProcess);    
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US Time Out Of Territories 
        List<Time_Out_of_Territory__c> UsOldListTotToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Time Out Of Territories return Map
        Map<Id,Time_Out_of_Territory__c> UsOldMapTotToProcess = new Map<Id, Time_Out_of_Territory__c>(UsOldListTotToProcess);
        //Filter triggerNew List for US Time Out Of Territories 
        List<Time_Out_of_Territory__c> UsNewListTotToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Time Out Of Territories return Map
        Map<Id,Time_Out_of_Territory__c> UsNewMapTotToProcess = new Map<Id, Time_Out_of_Territory__c>(UsNewListTotToProcess);

        //Filter triggerOld List for INTL Time Out Of Territories 
        List<Time_Out_of_Territory__c> IntlOldListTotToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL Time Out Of Territories return Map
        Map<Id,Time_Out_of_Territory__c> IntlOldMapTotToProcess = new Map<Id, Time_Out_of_Territory__c>(IntlOldListTotToProcess);
        //Filter triggerNew List for INTL Time Out Of Territories 
        List<Time_Out_of_Territory__c> IntlNewListTotToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Time Out Of Territories return Map
        Map<Id,Time_Out_of_Territory__c> IntlNewMapTotToProcess = new Map<Id, Time_Out_of_Territory__c>(IntlNewListTotToProcess);
        
        if (!IntlOldListTotToProcess.isEmpty() && !IntlOldMapTotToProcess.isEmpty() && !IntlNewListTotToProcess.isEmpty() && !IntlNewMapTotToProcess.isEmpty())
            INTLTime_Out_of_TerritoryTriggerService.afterUpdate(IntlOldListTotToProcess, IntlOldMapTotToProcess, IntlNewListTotToProcess, IntlNewMapTotToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}