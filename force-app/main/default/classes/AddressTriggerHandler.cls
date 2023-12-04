/****************************************************************************************************************************************** 
 * Class Name : AddressTriggerHandler
 * Description  : All Dispatch Trigger Logic for Address object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 17th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           02/17/2020          Created 
*****************************************************************************************************************************************/

public with sharing class AddressTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{

    //Field used for Address segmentation logic
    private Schema.sObjectField marketField = Address__c.ZTS_EU_Market_From_Parent__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US Addresses 
        List<Address__c> UsNewListAddressToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL Addresses 
        List<Address__c> IntlAddressToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlAddressToProcess.isEmpty()) INTLAddressTriggerService.beforeInsert(IntlAddressToProcess);
        if (!UsNewListAddressToProcess.isEmpty()) USAddressTriggerService.beforeInsert(UsNewListAddressToProcess);  
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US Addresses 
        List<Address__c> UsOldListAddressToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Addresses return Map
        Map<Id,Address__c> UsOldMapAddressToProcess = new Map<Id, Address__c>(UsOldListAddressToProcess);
        //Filter triggerNew List for US Addresses 
        List<Address__c> UsNewListAddressToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Addresses return Map
        Map<Id,Address__c> UsNewMapAddressToProcess = new Map<Id, Address__c>(UsNewListAddressToProcess);

        //Filter triggerOld List for INTL Addresses 
        List<Address__c> IntlOldListAddressToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL Addresses return Map
        Map<Id,Address__c> IntlOldMapAddressToProcess = new Map<Id, Address__c>(IntlOldListAddressToProcess);
        //Filter triggerNew List for INTL Addresses 
        List<Address__c> IntlNewListAddressToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Addresses return Map
        Map<Id,Address__c> IntlNewMapAddressToProcess = new Map<Id, Address__c>(IntlNewListAddressToProcess);

        if (!IntlOldListAddressToProcess.isEmpty() && !IntlOldMapAddressToProcess.isEmpty() && !IntlNewListAddressToProcess.isEmpty() && !IntlNewMapAddressToProcess.isEmpty())
            INTLAddressTriggerService.beforeUpdate(IntlOldListAddressToProcess, IntlOldMapAddressToProcess, IntlNewListAddressToProcess, IntlNewMapAddressToProcess);
        if (!UsOldListAddressToProcess.isEmpty() && !UsOldMapAddressToProcess.isEmpty() && !UsNewListAddressToProcess.isEmpty() && !UsNewMapAddressToProcess.isEmpty())
            USAddressTriggerService.beforeUpdate(UsOldListAddressToProcess, UsOldMapAddressToProcess, UsNewListAddressToProcess, UsNewMapAddressToProcess);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US Addresses 
        List<Address__c> UsNewListAddressToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Addresses return Map
        Map<Id,Address__c> UsNewMapAddressToProcess = new Map<Id, Address__c>(UsNewListAddressToProcess);
        //Filter triggerNew List for INTL Addresses 
        List<Address__c> IntlNewListAddressToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Addresses return Map
        Map<Id,Address__c> IntlNewMapAddressToProcess = new Map<Id, Address__c>(IntlNewListAddressToProcess);

        if (!IntlNewListAddressToProcess.isEmpty() && !IntlNewMapAddressToProcess.isEmpty())
            INTLAddressTriggerService.afterInsert(IntlNewListAddressToProcess, IntlNewMapAddressToProcess);
        if (!UsNewListAddressToProcess.isEmpty() && !UsNewMapAddressToProcess.isEmpty())
            USAddressTriggerService.afterInsert(UsNewListAddressToProcess, UsNewMapAddressToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerOld List for US Addresses 
        List<Address__c> UsOldListAddressToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Addresses return Map
        Map<Id,Address__c> UsOldMapAddressToProcess = new Map<Id, Address__c>(UsOldListAddressToProcess);
        //Filter triggerNew List for US Addresses 
        List<Address__c> UsNewListAddressToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Addresses return Map
        Map<Id,Address__c> UsNewMapAddressToProcess = new Map<Id, Address__c>(UsNewListAddressToProcess);

        //Filter triggerOld List for INTL Addresses 
        List<Address__c> IntlOldListAddressToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL Addresses return Map
        Map<Id,Address__c> IntlOldMapAddressToProcess = new Map<Id, Address__c>(IntlOldListAddressToProcess);
        //Filter triggerNew List for INTL Addresses 
        List<Address__c> IntlNewListAddressToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Addresses return Map
        Map<Id,Address__c> IntlNewMapAddressToProcess = new Map<Id, Address__c>(IntlNewListAddressToProcess);
        
        if (!IntlOldListAddressToProcess.isEmpty() && !IntlOldMapAddressToProcess.isEmpty() && !IntlNewListAddressToProcess.isEmpty() && !IntlNewMapAddressToProcess.isEmpty())
            INTLAddressTriggerService.afterUpdate(IntlOldListAddressToProcess, IntlOldMapAddressToProcess, IntlNewListAddressToProcess, IntlNewMapAddressToProcess);
        if (!UsOldListAddressToProcess.isEmpty() && !UsOldMapAddressToProcess.isEmpty() && !UsNewListAddressToProcess.isEmpty() && !UsNewMapAddressToProcess.isEmpty())
            USAddressTriggerService.afterUpdate(UsOldListAddressToProcess, UsOldMapAddressToProcess, UsNewListAddressToProcess, UsNewMapAddressToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}