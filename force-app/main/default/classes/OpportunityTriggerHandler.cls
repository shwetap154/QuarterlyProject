/****************************************************************************************************************************************** 
 * Trigger Name : OpportunityTriggerHandler
 * Description  : All Dispatch Trigger Logic for Opportunity object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 26th June, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           06/26/2020          Created 
 * Mila Imas   			 08/17/2021          added afterUpdate update Acnt from Oprt
*****************************************************************************************************************************************/
public with sharing class OpportunityTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for Opportunity segmentation logic
    private Schema.sObjectField marketField = Opportunity.ZTS_EU_Market__c.getDescribe().getSObjectField();
    
    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US opportunities 
        List<Opportunity> UsNewListOppToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL opportunities 
        List<Opportunity> IntlOppToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!UsNewListOppToProcess.isEmpty()) USOpportunityTriggerService.beforeInsert(UsNewListOppToProcess);        
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US opportunities 
        List<Opportunity> UsNewListOppToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US opportunities return Map
        Map<Id,Opportunity> UsNewMapOppToProcess = new Map<Id, Opportunity>(UsNewListOppToProcess);
        //Filter triggerNew List for INTL opportunities 
        List<Opportunity> IntlNewListOppToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL opportunities return Map
        Map<Id,Opportunity> IntlNewMapOppToProcess = new Map<Id, Opportunity>(IntlNewListOppToProcess);

        if (!IntlNewListOppToProcess.isEmpty() && !IntlNewMapOppToProcess.isEmpty())
            INTLOpportunityTriggerService.afterInsert(IntlNewListOppToProcess, IntlNewMapOppToProcess);
        if (!UsNewListOppToProcess.isEmpty() && !UsNewMapOppToProcess.isEmpty())
            USOpportunityTriggerService.afterInsert(UsNewListOppToProcess, UsNewMapOppToProcess);
    }
    //mi
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
    
        List<Opportunity> UsNewListOppToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US opportunities return Map
        Map<Id,Opportunity> UsNewMapOppToProcess = new Map<Id, Opportunity>(UsNewListOppToProcess);
                    system.debug('OpportunityTriggerHandler about to update UsNewListOppToProcess===> ' + UsNewListOppToProcess);
        if (!UsNewListOppToProcess.isEmpty() && !UsNewMapOppToProcess.isEmpty())
            USOpportunityTriggerService.afterUpdate(UsNewListOppToProcess, UsNewMapOppToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}