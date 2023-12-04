/****************************************************************************************************************************************** 
 * Class Name   : Pitcher_ActivityTriggerHandler
 * Description  : All Dispatch Trigger Logic for Pit_Order object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 29 June, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           06/29/2020          Created 
*****************************************************************************************************************************************/
public with sharing class Pitcher_ActivityTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for Pitcher_Activity segmentation logic
    private Schema.sObjectField marketField = Pitcher_Activity__c.ZTS_EU_Market__c.getDescribe().getSObjectField();

    //No Market, object is US only.    	
    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US Pitcher_Activity__c 
        List<Pitcher_Activity__c> UsNewListPitcherActivityToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Pitcher_Activity__c return Map
        Map<Id,Pitcher_Activity__c> UsNewMapPitcherActivityToProcess = new Map<Id, Pitcher_Activity__c>(UsNewListPitcherActivityToProcess);
        //Filter triggerNew List for INTL Pitcher_Activity__c 
        List<Pitcher_Activity__c> IntlNewListPitcherActivityToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Pitcher_Activity__c return Map
        Map<Id,Pitcher_Activity__c> IntlNewMapPitcherActivityToProcess = new Map<Id, Pitcher_Activity__c>(IntlNewListPitcherActivityToProcess);

        if (!UsNewListPitcherActivityToProcess.isEmpty() && !UsNewMapPitcherActivityToProcess.isEmpty())
            USPitcher_ActivityTriggerService.afterInsert(UsNewListPitcherActivityToProcess, UsNewMapPitcherActivityToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US Pitcher_Activity__c 
        List<Pitcher_Activity__c> UsOldListPitcherActivityToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Pitcher_Activity__c return Map
        Map<Id,Pitcher_Activity__c> UsOldMapPitcherActivityToProcess = new Map<Id, Pitcher_Activity__c>(UsOldListPitcherActivityToProcess);
        //Filter triggerNew List for US Pitcher_Activity__c 
        List<Pitcher_Activity__c> UsNewListPitcherActivityToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Pitcher_Activity__c return Map
        Map<Id,Pitcher_Activity__c> UsNewMapPitcherActivityToProcess = new Map<Id, Pitcher_Activity__c>(UsNewListPitcherActivityToProcess);

        //Filter triggerOld List for INTL Pitcher_Activity__c 
        List<Pitcher_Activity__c> IntlOldListPitcherActivityToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL Pitcher_Activity__c return Map
        Map<Id,Pitcher_Activity__c> IntlOldMapPitcherActivityToProcess = new Map<Id, Pitcher_Activity__c>(IntlOldListPitcherActivityToProcess);
        //Filter triggerNew List for INTL Pitcher_Activity__c 
        List<Pitcher_Activity__c> IntlNewListPitcherActivityToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Pitcher_Activity__c return Map
        Map<Id,Pitcher_Activity__c> IntlNewMapPitcherActivityToProcess = new Map<Id, Pitcher_Activity__c>(IntlNewListPitcherActivityToProcess);
        
        if (!UsOldListPitcherActivityToProcess.isEmpty() && !UsOldMapPitcherActivityToProcess.isEmpty() && !UsNewListPitcherActivityToProcess.isEmpty() && !UsNewMapPitcherActivityToProcess.isEmpty())
            USPitcher_ActivityTriggerService.afterUpdate(UsOldListPitcherActivityToProcess, UsOldMapPitcherActivityToProcess, UsNewListPitcherActivityToProcess, UsNewMapPitcherActivityToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}