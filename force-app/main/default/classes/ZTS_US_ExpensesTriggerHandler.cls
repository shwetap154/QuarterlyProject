/****************************************************************************************************************************************** 
 * Class Name : ZTS_US_ExpensesTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_US_Expenses object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 14th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           02/14/2020          Created 
*****************************************************************************************************************************************/

public with sharing class ZTS_US_ExpensesTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface {

    private Schema.sObjectField marketField = ZTS_US_Expenses__c.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US expenses 
        List<ZTS_US_Expenses__c> UsOldListExpensesToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US expenses return Map
        Map<Id,ZTS_US_Expenses__c> UsOldMapExpensesToProcess = new Map<Id, ZTS_US_Expenses__c>(UsOldListExpensesToProcess);
        //Filter triggerNew List for INTL expenses 
        List<ZTS_US_Expenses__c> IntlOldListExpensesToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL expenses return Map
        Map<Id,ZTS_US_Expenses__c> IntlOldMapExpensesToProcess = new Map<Id, ZTS_US_Expenses__c>(IntlOldListExpensesToProcess);

        if (!IntlOldListExpensesToProcess.isEmpty() && !IntlOldMapExpensesToProcess.isEmpty()) 
            INTLZTS_US_ExpensesTriggerService.beforeDelete(IntlOldListExpensesToProcess, IntlOldMapExpensesToProcess);
        if (!UsOldListExpensesToProcess.isEmpty() && !UsOldMapExpensesToProcess.isEmpty()) 
            USZTS_US_ExpensesTriggerService.beforeDelete(UsOldListExpensesToProcess, UsOldMapExpensesToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US expenses 
        List<ZTS_US_Expenses__c> UsNewListExpensesToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US expenses return Map
        Map<Id,ZTS_US_Expenses__c> UsNewMapExpensesToProcess = new Map<Id, ZTS_US_Expenses__c>(UsNewListExpensesToProcess);
        //Filter triggerNew List for INTL expenses 
        List<ZTS_US_Expenses__c> IntlNewListExpensesToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL expenses return Map
        Map<Id,ZTS_US_Expenses__c> IntlNewMapExpensesToProcess = new Map<Id, ZTS_US_Expenses__c>(IntlNewListExpensesToProcess);

        if (!IntlNewListExpensesToProcess.isEmpty() && !IntlNewMapExpensesToProcess.isEmpty())
            INTLZTS_US_ExpensesTriggerService.afterInsert(IntlNewListExpensesToProcess, IntlNewMapExpensesToProcess);
        if (!UsNewListExpensesToProcess.isEmpty() && !UsNewMapExpensesToProcess.isEmpty())
            USZTS_US_ExpensesTriggerService.afterInsert(UsNewListExpensesToProcess, UsNewMapExpensesToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerOld List for US expenses 
        List<ZTS_US_Expenses__c> UsOldListExpensesToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US expenses return Map
        Map<Id,ZTS_US_Expenses__c> UsOldMapExpensesToProcess = new Map<Id, ZTS_US_Expenses__c>(UsOldListExpensesToProcess);
        //Filter triggerNew List for US expenses 
        List<ZTS_US_Expenses__c> UsNewListExpensesToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US expenses return Map
        Map<Id,ZTS_US_Expenses__c> UsNewMapExpensesToProcess = new Map<Id, ZTS_US_Expenses__c>(UsNewListExpensesToProcess);

        //Filter triggerOld List for INTL expenses 
        List<ZTS_US_Expenses__c> IntlOldListExpensesToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL expenses return Map
        Map<Id,ZTS_US_Expenses__c> IntlOldMapExpensesToProcess = new Map<Id, ZTS_US_Expenses__c>(IntlOldListExpensesToProcess);
        //Filter triggerNew List for INTL expenses 
        List<ZTS_US_Expenses__c> IntlNewListExpensesToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL expenses return Map
        Map<Id,ZTS_US_Expenses__c> IntlNewMapExpensesToProcess = new Map<Id, ZTS_US_Expenses__c>(IntlNewListExpensesToProcess);
        
        if (!IntlOldListExpensesToProcess.isEmpty() && !IntlOldMapExpensesToProcess.isEmpty() && !IntlNewListExpensesToProcess.isEmpty() && !IntlNewMapExpensesToProcess.isEmpty())
            INTLZTS_US_ExpensesTriggerService.afterUpdate(IntlOldListExpensesToProcess, IntlOldMapExpensesToProcess, IntlNewListExpensesToProcess, IntlNewMapExpensesToProcess);
        if (!UsOldListExpensesToProcess.isEmpty() && !UsOldMapExpensesToProcess.isEmpty() && !UsNewListExpensesToProcess.isEmpty() && !UsNewMapExpensesToProcess.isEmpty())
            USZTS_US_ExpensesTriggerService.afterUpdate(UsOldListExpensesToProcess, UsOldMapExpensesToProcess, UsNewListExpensesToProcess, UsNewMapExpensesToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

}