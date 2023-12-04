/****************************************************************************************************************************************** 
 * Trigger Name : CallTriggerHandler
 * Description  : All Dispatch Trigger Logic for Call__c object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 17th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/17/2020          Created 
 * Aritra (Cognizant)        01/19/2021          Updated beforeUpdate method for US market 
*****************************************************************************************************************************************/
public with sharing class CallTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    private Schema.sObjectField marketField = Call__c.ZTS_EU_Market__c.getDescribe().getSObjectField();
    
    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US calls 
        List<Call__c> UsNewListCallToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL calls 
        List<Call__c> IntlCallToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlCallToProcess.isEmpty()) INTLCallTriggerService.beforeInsert(IntlCallToProcess);
        if (!UsNewListCallToProcess.isEmpty())USCallTriggerService.beforeInsert(UsNewListCallToProcess);  
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US calls 
        List<Call__c> UsOldListCallToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US calls return Map
        Map<Id,Call__c> UsOldMapCallToProcess = new Map<Id, Call__c>(UsOldListCallToProcess);
        //Filter triggerNew List for US calls 
        List<Call__c> UsNewListCallToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US calls return Map
        Map<Id,Call__c> UsNewMapCallToProcess = new Map<Id, Call__c>(UsNewListCallToProcess);

        //Filter triggerOld List for INTL calls 
        List<Call__c> IntlOldListCallToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL calls return Map
        Map<Id,Call__c> IntlOldMapCallToProcess = new Map<Id, Call__c>(IntlOldListCallToProcess);
        //Filter triggerNew List for INTL calls 
        List<Call__c> IntlNewListCallToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL calls return Map
        Map<Id,Call__c> IntlNewMapCallToProcess = new Map<Id, Call__c>(IntlNewListCallToProcess);

        if (!IntlOldListCallToProcess.isEmpty() && !IntlOldMapCallToProcess.isEmpty() && !IntlNewListCallToProcess.isEmpty() && !IntlNewMapCallToProcess.isEmpty())
            INTLCallTriggerService.beforeUpdate(IntlOldListCallToProcess, IntlOldMapCallToProcess, IntlNewListCallToProcess, IntlNewMapCallToProcess);
        //Aritra added this section to call beforeUpdate function from USCallTriggerService (SC-008816)
        if (!UsOldListCallToProcess.isEmpty() && !UsOldMapCallToProcess.isEmpty() && !UsNewListCallToProcess.isEmpty() && !UsNewMapCallToProcess.isEmpty())
            USCallTriggerService.beforeUpdate(UsOldListCallToProcess, UsOldMapCallToProcess, UsNewListCallToProcess, UsNewMapCallToProcess);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US calls 
        List<Call__c> UsOldListCallToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US calls return Map
        Map<Id,Call__c> UsOldMapCallToProcess = new Map<Id, Call__c>(UsOldListCallToProcess);
        //Filter triggerNew List for INTL calls 
        List<Call__c> IntlOldListCallToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL calls return Map
        Map<Id,Call__c> IntlOldMapCallToProcess = new Map<Id, Call__c>(IntlOldListCallToProcess);

        if (!IntlOldListCallToProcess.isEmpty() && !IntlOldMapCallToProcess.isEmpty()) 
            INTLCallTriggerService.beforeDelete(IntlOldListCallToProcess, IntlOldMapCallToProcess);
        if (!UsOldListCallToProcess.isEmpty() && !UsOldMapCallToProcess.isEmpty()) 
            USCallTriggerService.beforeDelete(UsOldListCallToProcess, UsOldMapCallToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerNew List for US Call 
        List<Call__c> UsNewListCallToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Call return Map
        Map<Id,Call__c> UsNewMapCallToProcess = new Map<Id, Call__c>(UsNewListCallToProcess);
        //Filter triggerNew List for INTL Call 
        List<Call__c> IntlNewListCallToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Call return Map
        Map<Id,Call__c> IntlNewMapCallToProcess = new Map<Id, Call__c>(IntlNewListCallToProcess);

        if (!IntlNewListCallToProcess.isEmpty() && !IntlNewMapCallToProcess.isEmpty())
            INTLCallTriggerService.afterInsert(IntlNewListCallToProcess, IntlNewMapCallToProcess);
        if (!UsNewListCallToProcess.isEmpty() && !UsNewMapCallToProcess.isEmpty())
            USCallTriggerService.afterInsert(UsNewListCallToProcess, UsNewMapCallToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerOld List for US calls 
        List<Call__c> UsOldListCallToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US calls return Map
        Map<Id,Call__c> UsOldMapCallToProcess = new Map<Id, Call__c>(UsOldListCallToProcess);
        //Filter triggerNew List for US calls 
        List<Call__c> UsNewListCallToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US calls return Map
        Map<Id,Call__c> UsNewMapCallToProcess = new Map<Id, Call__c>(UsNewListCallToProcess);

        //Filter triggerOld List for INTL calls 
        List<Call__c> IntlOldListCallToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL calls return Map
        Map<Id,Call__c> IntlOldMapCallToProcess = new Map<Id, Call__c>(IntlOldListCallToProcess);
        //Filter triggerNew List for INTL calls 
        List<Call__c> IntlNewListCallToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL calls return Map
        Map<Id,Call__c> IntlNewMapCallToProcess = new Map<Id, Call__c>(IntlNewListCallToProcess);
        
        if (!IntlOldListCallToProcess.isEmpty() && !IntlOldMapCallToProcess.isEmpty() && !IntlNewListCallToProcess.isEmpty() && !IntlNewMapCallToProcess.isEmpty())
            INTLCallTriggerService.afterUpdate(IntlOldListCallToProcess, IntlOldMapCallToProcess, IntlNewListCallToProcess, IntlNewMapCallToProcess);
        if (!UsOldListCallToProcess.isEmpty() && !UsOldMapCallToProcess.isEmpty() && !UsNewListCallToProcess.isEmpty() && !UsNewMapCallToProcess.isEmpty())
            USCallTriggerService.afterUpdate(UsOldListCallToProcess, UsOldMapCallToProcess, UsNewListCallToProcess, UsNewMapCallToProcess);

        //ATG - Create a zoetis diagnostic equipment lead for certain call discussions. 
        Callutils.createLeadFromCall((List<Call__c>)triggerNew, (Map<Id, Call__c>) triggerOldMap);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US calls 
        List<Call__c> UsOldListCallToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US calls return Map
        Map<Id,Call__c> UsOldMapCallToProcess = new Map<Id, Call__c>(UsOldListCallToProcess);
        //Filter triggerNew List for INTL calls 
        List<Call__c> IntlOldListCallToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL calls return Map
        Map<Id,Call__c> IntlOldMapCallToProcess = new Map<Id, Call__c>(IntlOldListCallToProcess);
        
        if (!IntlOldListCallToProcess.isEmpty() && !IntlOldMapCallToProcess.isEmpty())
            INTLCallTriggerService.afterDelete(IntlOldListCallToProcess, IntlOldMapCallToProcess);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}