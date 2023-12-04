/****************************************************************************************************************************************** 
 * Trigger Name : ContactTriggerHandler
 * Description  : All Dispatch Trigger Logic for Contact object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 10th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/10/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ContactTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    private Schema.sObjectField marketField = Contact.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US contacts 
        List<Contact> UsNewListContactToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL contacts 
        List<Contact> IntlNewListContactToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlNewListContactToProcess.isEmpty()) INTLContactTriggerService.beforeInsert(IntlNewListContactToProcess);
        if (!UsNewListContactToProcess.isEmpty()) USContactTriggerService.beforeInsert(UsNewListContactToProcess); 
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US contacts 
        List<Contact> UsOldListContactToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US contacts return Map
        Map<Id,Contact> UsOldMapContactToProcess = new Map<Id, Contact>(UsOldListContactToProcess);
        //Filter triggerNew List for US contacts 
        List<Contact> UsNewListContactToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US contacts return Map
        Map<Id,Contact> UsNewMapContactToProcess = new Map<Id, Contact>(UsNewListContactToProcess);

        //Filter triggerOld List for INTL contacts 
        List<Contact> IntlOldListContactToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL contacts return Map
        Map<Id,Contact> IntlOldMapContactToProcess = new Map<Id, Contact>(IntlOldListContactToProcess);
        //Filter triggerNew List for INTL contacts 
        List<Contact> IntlNewListContactToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL contacts return Map
        Map<Id,Contact> IntlNewMapContactToProcess = new Map<Id, Contact>(IntlNewListContactToProcess);

        if (!IntlOldListContactToProcess.isEmpty() && !IntlOldMapContactToProcess.isEmpty() && !IntlNewListContactToProcess.isEmpty() && !IntlNewMapContactToProcess.isEmpty())
            INTLContactTriggerService.beforeUpdate(IntlOldListContactToProcess, IntlOldMapContactToProcess, IntlNewListContactToProcess, IntlNewMapContactToProcess);
        if (!UsOldListContactToProcess.isEmpty() && !UsOldMapContactToProcess.isEmpty() && !UsNewListContactToProcess.isEmpty() && !UsNewMapContactToProcess.isEmpty())
            USContactTriggerService.beforeUpdate(UsOldListContactToProcess, UsOldMapContactToProcess, UsNewListContactToProcess, UsNewMapContactToProcess);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US contacts 
        List<Contact> UsOldListContactToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US contacts return Map
        Map<Id,Contact> UsOldMapContactToProcess = new Map<Id, Contact>(UsOldListContactToProcess);
        //Filter triggerNew List for INTL contacts 
        List<Contact> IntlOldListContactToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL contacts return Map
        Map<Id,Contact> IntlOldMapContactToProcess = new Map<Id, Contact>(IntlOldListContactToProcess);

        if (!IntlOldListContactToProcess.isEmpty() && !IntlOldMapContactToProcess.isEmpty()) 
            INTLContactTriggerService.beforeDelete(IntlOldListContactToProcess, IntlOldMapContactToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {

        //Filter triggerNew List for US contacts 
        List<Contact> UsNewListContactToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US contacts return Map
        Map<Id,Contact> UsNewMapContactToProcess = new Map<Id, Contact>(UsNewListContactToProcess);
        //Filter triggerNew List for INTL contacts 
        List<Contact> IntlNewListContactToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL contacts return Map
        Map<Id,Contact> IntlNewMapContactToProcess = new Map<Id, Contact>(IntlNewListContactToProcess);

        if (!IntlNewListContactToProcess.isEmpty() && !IntlNewMapContactToProcess.isEmpty())
            INTLContactTriggerService.afterInsert(IntlNewListContactToProcess, IntlNewMapContactToProcess);
        if (!UsNewListContactToProcess.isEmpty() && !UsNewMapContactToProcess.isEmpty())
            USContactTriggerService.afterInsert(UsNewListContactToProcess, UsNewMapContactToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerOld List for US contacts 
        List<Contact> UsOldListContactToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US contacts return Map
        Map<Id,Contact> UsOldMapContactToProcess = new Map<Id, Contact>(UsOldListContactToProcess);
        //Filter triggerNew List for US contacts 
        List<Contact> UsNewListContactToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US contacts return Map
        Map<Id,Contact> UsNewMapContactToProcess = new Map<Id, Contact>(UsNewListContactToProcess);

        //Filter triggerOld List for INTL contacts 
        List<Contact> IntlOldListContactToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL contacts return Map
        Map<Id,Contact> IntlOldMapContactToProcess = new Map<Id, Contact>(IntlOldListContactToProcess);
        //Filter triggerNew List for INTL contacts 
        List<Contact> IntlNewListContactToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL contacts return Map
        Map<Id,Contact> IntlNewMapContactToProcess = new Map<Id, Contact>(IntlNewListContactToProcess);
        
        if (!IntlOldListContactToProcess.isEmpty() && !IntlOldMapContactToProcess.isEmpty() && !IntlNewListContactToProcess.isEmpty() && !IntlNewMapContactToProcess.isEmpty())
            INTLContactTriggerService.afterUpdate(IntlOldListContactToProcess, IntlOldMapContactToProcess, IntlNewListContactToProcess, IntlNewMapContactToProcess);
        if (!UsOldListContactToProcess.isEmpty() && !UsOldMapContactToProcess.isEmpty() && !UsNewListContactToProcess.isEmpty() && !UsNewMapContactToProcess.isEmpty())
            USContactTriggerService.afterUpdate(UsOldListContactToProcess, UsOldMapContactToProcess, UsNewListContactToProcess, UsNewMapContactToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}