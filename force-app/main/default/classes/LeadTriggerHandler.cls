/****************************************************************************************************************************************** 
 * Trigger Name : LeadTriggerHandler
 * Description  : All Dispatch Trigger Logic for Lead object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 28th May, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           05/28/2020          Created 
 * Mila Imas 			 08/05/2020			SC-008625,SC-008281
*****************************************************************************************************************************************/
public with sharing class LeadTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for Lead segmentation logic
    private Schema.sObjectField marketField = Lead.Market__c.getDescribe().getSObjectField();
    
    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US Leads 
        List<Lead> UsNewListLeadToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL Leads 
        List<Lead> IntlLeadToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlLeadToProcess.isEmpty()) INTLLeadTriggerService.beforeInsert(IntlLeadToProcess);    
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    { 
        System.debug('beforeUpdate > triggerNew: ' + triggerNew);
        
        //Filter triggerOld List for US Leads 
        List<Lead> UsOldListLeadToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Leads return Map
        Map<Id,Lead> UsOldMapLeadToProcess = new Map<Id, Lead>(UsOldListLeadToProcess);
        //Filter triggerNew List for US Leads 
        List<Lead> UsNewListLeadToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Leads return Map
        Map<Id,Lead> UsNewMapLeadToProcess = new Map<Id, Lead>(UsNewListLeadToProcess);

        //Filter triggerOld List for INTL Leads 
        List<Lead> IntlOldListLeadToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL Leads return Map
        Map<Id,Lead> IntlOldMapLeadToProcess = new Map<Id, Lead>(IntlOldListLeadToProcess);
        //Filter triggerNew List for INTL Leads 
        List<Lead> IntlNewListLeadToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Leads return Map
        Map<Id,Lead> IntlNewMapLeadToProcess = new Map<Id, Lead>(IntlNewListLeadToProcess);

        if (!IntlOldListLeadToProcess.isEmpty() && !IntlOldMapLeadToProcess.isEmpty() && !IntlNewListLeadToProcess.isEmpty() && !IntlNewMapLeadToProcess.isEmpty())
            INTLLeadTriggerService.beforeUpdate(IntlOldListLeadToProcess, IntlOldMapLeadToProcess, IntlNewListLeadToProcess, IntlNewMapLeadToProcess);
        
        // Added by ATG
        LeadOwnerHelper.updateOwnerOnLead((List<Lead>)triggerNew, (Map<Id, Lead>)triggerOldMap);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US Leads 
        List<Lead> UsNewListLeadToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Leads return Map
        Map<Id,Lead> UsNewMapLeadToProcess = new Map<Id, Lead>(UsNewListLeadToProcess);
        //Filter triggerNew List for INTL Leads 
        List<Lead> IntlNewListLeadToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Leads return Map
        Map<Id,Lead> IntlNewMapLeadToProcess = new Map<Id, Lead>(IntlNewListLeadToProcess);

        if (!IntlNewListLeadToProcess.isEmpty() && !IntlNewMapLeadToProcess.isEmpty())
            INTLLeadTriggerService.afterInsert(IntlNewListLeadToProcess, IntlNewMapLeadToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US Leads 
        List<Lead> UsOldListLeadToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Leads return Map
        Map<Id,Lead> UsOldMapLeadToProcess = new Map<Id, Lead>(UsOldListLeadToProcess);
        //Filter triggerNew List for US Leads 
        List<Lead> UsNewListLeadToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Leads return Map
        Map<Id,Lead> UsNewMapLeadToProcess = new Map<Id, Lead>(UsNewListLeadToProcess);
        //mi
        if (!UsOldListLeadToProcess.isEmpty() && !UsOldMapLeadToProcess.isEmpty() && !UsNewListLeadToProcess.isEmpty() && !UsNewMapLeadToProcess.isEmpty()){
            CompetitorUpdateHelper.updateCompetior(UsNewListLeadToProcess,UsOldMapLeadToProcess);
        }

        //Filter triggerOld List for INTL Leads 
        List<Lead> IntlOldListLeadToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL Leads return Map
        Map<Id,Lead> IntlOldMapLeadToProcess = new Map<Id, Lead>(IntlOldListLeadToProcess);
        //Filter triggerNew List for INTL Leads 
        List<Lead> IntlNewListLeadToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Leads return Map
        Map<Id,Lead> IntlNewMapLeadToProcess = new Map<Id, Lead>(IntlNewListLeadToProcess);
	
        if (!IntlOldListLeadToProcess.isEmpty() && !IntlOldMapLeadToProcess.isEmpty() && !IntlNewListLeadToProcess.isEmpty() && !IntlNewMapLeadToProcess.isEmpty())
            INTLLeadTriggerService.afterUpdate(IntlOldListLeadToProcess, IntlOldMapLeadToProcess, IntlNewListLeadToProcess, IntlNewMapLeadToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}