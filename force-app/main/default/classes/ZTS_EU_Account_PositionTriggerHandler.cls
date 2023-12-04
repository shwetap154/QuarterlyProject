/****************************************************************************************************************************************** 
 * CLass Name : ZTS_EU_Account_PositionTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Account_Position object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 13th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           02/13/2020          Created 
*****************************************************************************************************************************************/

public with sharing class ZTS_EU_Account_PositionTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    private Schema.sObjectField marketField = ZTS_EU_Account_Position__c.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew)
    {
        System.debug('marketField  ::::::::: BI :::::::: ' +  marketField);
        //Filter triggerNew List for US positions 
        List<ZTS_EU_Account_Position__c> UsNewListPositionToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL positions 
        List<ZTS_EU_Account_Position__c> IntlPositionToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlPositionToProcess.isEmpty()) INTLZTS_EU_Account_PositionTrigerService.beforeInsert(IntlPositionToProcess);
        if (!UsNewListPositionToProcess.isEmpty()) USZTS_EU_Account_PositionTriggerService.beforeInsert(UsNewListPositionToProcess);       
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerOld List for US positions 
        List<ZTS_EU_Account_Position__c> UsOldListPositionToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US positions return Map
        Map<Id,ZTS_EU_Account_Position__c> UsOldMapPositionToProcess = new Map<Id, ZTS_EU_Account_Position__c>(UsOldListPositionToProcess);
        //Filter triggerNew List for US positions 
        List<ZTS_EU_Account_Position__c> UsNewListPositionToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US positions return Map
        Map<Id,ZTS_EU_Account_Position__c> UsNewMapPositionToProcess = new Map<Id, ZTS_EU_Account_Position__c>(UsNewListPositionToProcess);

        //Filter triggerOld List for INTL positions 
        List<ZTS_EU_Account_Position__c> IntlOldListPositionToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL positions return Map
        Map<Id,ZTS_EU_Account_Position__c> IntlOldMapPositionToProcess = new Map<Id, ZTS_EU_Account_Position__c>(IntlOldListPositionToProcess);
        //Filter triggerNew List for INTL positions 
        List<ZTS_EU_Account_Position__c> IntlNewListPositionToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL positions return Map
        Map<Id,ZTS_EU_Account_Position__c> IntlNewMapPositionToProcess = new Map<Id, ZTS_EU_Account_Position__c>(IntlNewListPositionToProcess);

        if (!IntlOldListPositionToProcess.isEmpty() && !IntlOldMapPositionToProcess.isEmpty() && !IntlNewListPositionToProcess.isEmpty() && !IntlNewMapPositionToProcess.isEmpty())
            INTLZTS_EU_Account_PositionTrigerService.beforeUpdate(IntlOldListPositionToProcess, IntlOldMapPositionToProcess, IntlNewListPositionToProcess, IntlNewMapPositionToProcess);
        if (!UsOldListPositionToProcess.isEmpty() && !UsOldMapPositionToProcess.isEmpty() && !UsNewListPositionToProcess.isEmpty() && !UsNewMapPositionToProcess.isEmpty())
            USZTS_EU_Account_PositionTriggerService.beforeUpdate(UsOldListPositionToProcess, UsOldMapPositionToProcess, UsNewListPositionToProcess, UsNewMapPositionToProcess);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        System.debug('marketField  ::::::::: AI :::::::: ' +  marketField);
        //Filter triggerNew List for US positions 
        List<ZTS_EU_Account_Position__c> UsNewListPositionToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US positions return Map
        Map<Id,ZTS_EU_Account_Position__c> UsNewMapPositionToProcess = new Map<Id, ZTS_EU_Account_Position__c>(UsNewListPositionToProcess);
        //Filter triggerNew List for INTL positions 
        List<ZTS_EU_Account_Position__c> IntlNewListPositionToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL positions return Map
        Map<Id,ZTS_EU_Account_Position__c> IntlNewMapPositionToProcess = new Map<Id, ZTS_EU_Account_Position__c>(IntlNewListPositionToProcess);

        if (!IntlNewListPositionToProcess.isEmpty() && !IntlNewMapPositionToProcess.isEmpty())
            INTLZTS_EU_Account_PositionTrigerService.afterInsert(IntlNewListPositionToProcess, IntlNewMapPositionToProcess);
        if (!UsNewListPositionToProcess.isEmpty() && !UsNewMapPositionToProcess.isEmpty())
            USZTS_EU_Account_PositionTriggerService.afterInsert(UsNewListPositionToProcess, UsNewMapPositionToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerOld List for US positions 
        List<ZTS_EU_Account_Position__c> UsOldListPositionToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US positions return Map
        Map<Id,ZTS_EU_Account_Position__c> UsOldMapPositionToProcess = new Map<Id, ZTS_EU_Account_Position__c>(UsOldListPositionToProcess);
        //Filter triggerNew List for US positions 
        List<ZTS_EU_Account_Position__c> UsNewListPositionToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US positions return Map
        Map<Id,ZTS_EU_Account_Position__c> UsNewMapPositionToProcess = new Map<Id, ZTS_EU_Account_Position__c>(UsNewListPositionToProcess);

        //Filter triggerOld List for INTL positions 
        List<ZTS_EU_Account_Position__c> IntlOldListPositionToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL positions return Map
        Map<Id,ZTS_EU_Account_Position__c> IntlOldMapPositionToProcess = new Map<Id, ZTS_EU_Account_Position__c>(IntlOldListPositionToProcess);
        //Filter triggerNew List for INTL positions 
        List<ZTS_EU_Account_Position__c> IntlNewListPositionToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL positions return Map
        Map<Id,ZTS_EU_Account_Position__c> IntlNewMapPositionToProcess = new Map<Id, ZTS_EU_Account_Position__c>(IntlNewListPositionToProcess);
        
        if (!IntlOldListPositionToProcess.isEmpty() && !IntlOldMapPositionToProcess.isEmpty() && !IntlNewListPositionToProcess.isEmpty() && !IntlNewMapPositionToProcess.isEmpty())
            INTLZTS_EU_Account_PositionTrigerService.afterUpdate(IntlOldListPositionToProcess, IntlOldMapPositionToProcess, IntlNewListPositionToProcess, IntlNewMapPositionToProcess);
        if (!UsOldListPositionToProcess.isEmpty() && !UsOldMapPositionToProcess.isEmpty() && !UsNewListPositionToProcess.isEmpty() && !UsNewMapPositionToProcess.isEmpty())
            USZTS_EU_Account_PositionTriggerService.afterUpdate(UsOldListPositionToProcess, UsOldMapPositionToProcess, UsNewListPositionToProcess, UsNewMapPositionToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerNew List for US positions 
        List<ZTS_EU_Account_Position__c> UsNewListPositionToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US positions return Map
        Map<Id,ZTS_EU_Account_Position__c> UsNewMapPositionToProcess = new Map<Id, ZTS_EU_Account_Position__c>(UsNewListPositionToProcess);
        //Filter triggerNew List for INTL positions 
        List<ZTS_EU_Account_Position__c> IntlNewListPositionToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL positions return Map
        Map<Id,ZTS_EU_Account_Position__c> IntlNewMapPositionToProcess = new Map<Id, ZTS_EU_Account_Position__c>(IntlNewListPositionToProcess);

        if (!IntlNewListPositionToProcess.isEmpty() && !IntlNewMapPositionToProcess.isEmpty())
            INTLZTS_EU_Account_PositionTrigerService.afterUndelete(IntlNewListPositionToProcess, IntlNewMapPositionToProcess);
    }

}