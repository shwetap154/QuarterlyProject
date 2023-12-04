/****************************************************************************************************************************************** 
 * Trigger Name : AccountTriggerHandler
 * Description  : All Dispatch Trigger Logic for Account object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 7th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/07/2020          Created 
*****************************************************************************************************************************************/
public with sharing class AccountTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for Account segmentation logic
    private Schema.sObjectField marketField = Account.ZTS_EU_Market__c.getDescribe().getSObjectField();
    
    public void beforeInsert(List<SObject> triggerNew) 
    {
        System.debug('$$$ I am in before Insert');
        //Filter triggerNew List for US accounts 
        List<Account> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL accounts 
        List<Account> IntlAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlAccToProcess.isEmpty()) INTLAccountTriggerService.beforeInsert(IntlAccToProcess);
        if (!UsNewListAccToProcess.isEmpty()) USAccountTriggerService.beforeInsert(UsNewListAccToProcess);        
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    { 
        //Filter triggerOld List for US accounts 
        List<Account> UsOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US accounts return Map
        Map<Id,Account> UsOldMapAccToProcess = new Map<Id, Account>(UsOldListAccToProcess);
        //Filter triggerNew List for US accounts 
        List<Account> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US accounts return Map
        Map<Id,Account> UsNewMapAccToProcess = new Map<Id, Account>(UsNewListAccToProcess);

        //Filter triggerOld List for INTL accounts 
        List<Account> IntlOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL accounts return Map
        Map<Id,Account> IntlOldMapAccToProcess = new Map<Id, Account>(IntlOldListAccToProcess);
        //Filter triggerNew List for INTL accounts 
        List<Account> IntlNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL accounts return Map
        Map<Id,Account> IntlNewMapAccToProcess = new Map<Id, Account>(IntlNewListAccToProcess);

        if (!IntlOldListAccToProcess.isEmpty() && !IntlOldMapAccToProcess.isEmpty() && !IntlNewListAccToProcess.isEmpty() && !IntlNewMapAccToProcess.isEmpty())
            INTLAccountTriggerService.beforeUpdate(IntlOldListAccToProcess, IntlOldMapAccToProcess, IntlNewListAccToProcess, IntlNewMapAccToProcess);
        if (!UsOldListAccToProcess.isEmpty() && !UsOldMapAccToProcess.isEmpty() && !UsNewListAccToProcess.isEmpty() && !UsNewMapAccToProcess.isEmpty())
            USAccountTriggerService.beforeUpdate(UsOldListAccToProcess, UsOldMapAccToProcess, UsNewListAccToProcess, UsNewMapAccToProcess);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US accounts 
        List<Account> UsOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US accounts return Map
        Map<Id,Account> UsOldMapAccToProcess = new Map<Id, Account>(UsOldListAccToProcess);
        //Filter triggerNew List for INTL accounts 
        List<Account> IntlOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL accounts return Map
        Map<Id,Account> IntlOldMapAccToProcess = new Map<Id, Account>(IntlOldListAccToProcess);

        if (!IntlOldListAccToProcess.isEmpty() && !IntlOldMapAccToProcess.isEmpty()) 
            INTLAccountTriggerService.beforeDelete(IntlOldListAccToProcess, IntlOldMapAccToProcess);
        if (!UsOldListAccToProcess.isEmpty() && !UsOldMapAccToProcess.isEmpty()) 
            USAccountTriggerService.beforeDelete(UsOldListAccToProcess, UsOldMapAccToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        // if (Test.isRunningTest() && UserInfo.getUserId() == '0052C000002PBGxQAO') System.assert(false);
        //Filter triggerNew List for US accounts 
        List<Account> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US accounts return Map
        Map<Id,Account> UsNewMapAccToProcess = new Map<Id, Account>(UsNewListAccToProcess);
        //Filter triggerNew List for INTL accounts 
        List<Account> IntlNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL accounts return Map
        Map<Id,Account> IntlNewMapAccToProcess = new Map<Id, Account>(IntlNewListAccToProcess);

        if (!IntlNewListAccToProcess.isEmpty() && !IntlNewMapAccToProcess.isEmpty())
            INTLAccountTriggerService.afterInsert(IntlNewListAccToProcess, IntlNewMapAccToProcess);
        if (!UsNewListAccToProcess.isEmpty() && !UsNewMapAccToProcess.isEmpty())
            USAccountTriggerService.afterInsert(UsNewListAccToProcess, UsNewMapAccToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US accounts 
        List<Account> UsOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US accounts return Map
        Map<Id,Account> UsOldMapAccToProcess = new Map<Id, Account>(UsOldListAccToProcess);
        //Filter triggerNew List for US accounts 
        List<Account> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US accounts return Map
        Map<Id,Account> UsNewMapAccToProcess = new Map<Id, Account>(UsNewListAccToProcess);

        //Filter triggerOld List for INTL accounts 
        List<Account> IntlOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL accounts return Map
        Map<Id,Account> IntlOldMapAccToProcess = new Map<Id, Account>(IntlOldListAccToProcess);
        //Filter triggerNew List for INTL accounts 
        List<Account> IntlNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL accounts return Map
        Map<Id,Account> IntlNewMapAccToProcess = new Map<Id, Account>(IntlNewListAccToProcess);
        
        if (!IntlOldListAccToProcess.isEmpty() && !IntlOldMapAccToProcess.isEmpty() && !IntlNewListAccToProcess.isEmpty() && !IntlNewMapAccToProcess.isEmpty())
            INTLAccountTriggerService.afterUpdate(IntlOldListAccToProcess, IntlOldMapAccToProcess, IntlNewListAccToProcess, IntlNewMapAccToProcess);
        if (!UsOldListAccToProcess.isEmpty() && !UsOldMapAccToProcess.isEmpty() && !UsNewListAccToProcess.isEmpty() && !UsNewMapAccToProcess.isEmpty())
            USAccountTriggerService.afterUpdate(UsOldListAccToProcess, UsOldMapAccToProcess, UsNewListAccToProcess, UsNewMapAccToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US accounts 
        List<Account> UsOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US accounts return Map
        Map<Id,Account> UsOldMapAccToProcess = new Map<Id, Account>(UsOldListAccToProcess);
        //Filter triggerNew List for INTL accounts 
        List<Account> IntlOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL accounts return Map
        Map<Id,Account> IntlOldMapAccToProcess = new Map<Id, Account>(IntlOldListAccToProcess);
        
        if (!IntlOldListAccToProcess.isEmpty() && !IntlOldMapAccToProcess.isEmpty())
            INTLAccountTriggerService.afterDelete(IntlOldListAccToProcess, IntlOldMapAccToProcess);
        if (!UsOldListAccToProcess.isEmpty() && !UsOldMapAccToProcess.isEmpty())
            USAccountTriggerService.afterDelete(UsOldListAccToProcess, UsOldMapAccToProcess);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}