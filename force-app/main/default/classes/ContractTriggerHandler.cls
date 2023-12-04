/****************************************************************************************************************************************** 
 * Class Name   : ContractTriggerHandler
 * Description  : All Dispatch Trigger Logic for Contract object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 10th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/10/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ContractTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for Contract segmentation logic
    private Schema.sObjectField marketField = Contract.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US contracts 
        List<Contract> UsNewListContractsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL contracts 
        List<Contract> IntlContractsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlContractsToProcess.isEmpty()) INTLContractTriggerService.beforeInsert(IntlContractsToProcess);
        if (!UsNewListContractsToProcess.isEmpty()) USContractTriggerService.beforeInsert(UsNewListContractsToProcess);    
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US contracts 
        List<Contract> UsOldListContractsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US contracts return Map
        Map<Id,Contract> UsOldMapContractsToProcess = new Map<Id, Contract>(UsOldListContractsToProcess);
        //Filter triggerNew List for US contracts 
        List<Contract> UsNewListContractsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US contracts return Map
        Map<Id,Contract> UsNewMapContractsToProcess = new Map<Id, Contract>(UsNewListContractsToProcess);

        //Filter triggerOld List for INTL contracts 
        List<Contract> IntlOldListContractsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL contracts return Map
        Map<Id,Contract> IntlOldMapContractsToProcess = new Map<Id, Contract>(IntlOldListContractsToProcess);
        //Filter triggerNew List for INTL contracts 
        List<Contract> IntlNewListContractsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL contracts return Map
        Map<Id,Contract> IntlNewMapContractsToProcess = new Map<Id, Contract>(IntlNewListContractsToProcess);

        if (!UsOldListContractsToProcess.isEmpty() && !UsOldMapContractsToProcess.isEmpty() && !UsNewListContractsToProcess.isEmpty() && !UsNewMapContractsToProcess.isEmpty())
            USContractTriggerService.beforeUpdate(UsOldListContractsToProcess, UsOldMapContractsToProcess, UsNewListContractsToProcess, UsNewMapContractsToProcess);

    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US contracts 
        List<Contract> UsOldListContractsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US contracts return Map
        Map<Id,Contract> UsOldMapContractsToProcess = new Map<Id, Contract>(UsOldListContractsToProcess);
        //Filter triggerNew List for INTL contracts 
        List<Contract> IntlOldListContractsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL contracts return Map
        Map<Id,Contract> IntlOldMapContractsToProcess = new Map<Id, Contract>(IntlOldListContractsToProcess);

        if (!UsOldListContractsToProcess.isEmpty() && !UsOldMapContractsToProcess.isEmpty()) 
            USContractTriggerService.beforeDelete(UsOldListContractsToProcess, UsOldMapContractsToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US contracts 
        List<Contract> UsNewListContractsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US contracts return Map
        Map<Id,Contract> UsNewMapContractsToProcess = new Map<Id, Contract>(UsNewListContractsToProcess);
        //Filter triggerNew List for INTL contracts 
        List<Contract> IntlNewListContractsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL contracts return Map
        Map<Id,Contract> IntlNewMapContractsToProcess = new Map<Id, Contract>(IntlNewListContractsToProcess);

        if (!IntlNewListContractsToProcess.isEmpty() && !IntlNewMapContractsToProcess.isEmpty())
            INTLContractTriggerService.afterInsert(IntlNewListContractsToProcess, IntlNewMapContractsToProcess);
        if (!UsNewListContractsToProcess.isEmpty() && !UsNewMapContractsToProcess.isEmpty())
            USContractTriggerService.afterInsert(UsNewListContractsToProcess, UsNewMapContractsToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US contracts 
        List<Contract> UsOldListContractsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US contracts return Map
        Map<Id,Contract> UsOldMapContractsToProcess = new Map<Id, Contract>(UsOldListContractsToProcess);
        //Filter triggerNew List for US contracts 
        List<Contract> UsNewListContractsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US contracts return Map
        Map<Id,Contract> UsNewMapContractsToProcess = new Map<Id, Contract>(UsNewListContractsToProcess);

        //Filter triggerOld List for INTL contracts 
        List<Contract> IntlOldListContractsToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL contracts return Map
        Map<Id,Contract> IntlOldMapContractsToProcess = new Map<Id, Contract>(IntlOldListContractsToProcess);
        //Filter triggerNew List for INTL contracts 
        List<Contract> IntlNewListContractsToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL contracts return Map
        Map<Id,Contract> IntlNewMapContractsToProcess = new Map<Id, Contract>(IntlNewListContractsToProcess);
        
        if (!IntlOldListContractsToProcess.isEmpty() && !IntlOldMapContractsToProcess.isEmpty() && !IntlNewListContractsToProcess.isEmpty() && !IntlNewMapContractsToProcess.isEmpty())
            INTLContractTriggerService.afterUpdate(IntlOldListContractsToProcess, IntlOldMapContractsToProcess, IntlNewListContractsToProcess, IntlNewMapContractsToProcess);
        if (!UsOldListContractsToProcess.isEmpty() && !UsOldMapContractsToProcess.isEmpty() && !UsNewListContractsToProcess.isEmpty() && !UsNewMapContractsToProcess.isEmpty())
            USContractTriggerService.afterUpdate(UsOldListContractsToProcess, UsOldMapContractsToProcess, UsNewListContractsToProcess, UsNewMapContractsToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}