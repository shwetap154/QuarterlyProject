/****************************************************************************************************************************************** 
 * Trigger Name : UserTriggerHandler
 * Description  : All Dispatch Trigger Logic for User object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 6th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/06/2020          Created 
*****************************************************************************************************************************************/
public with sharing class UserTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    private Schema.sObjectField marketField = User.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US accounts 
        List<User> USUserToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL users 
        List<User> IntlUserToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 

        if (!IntlUserToProcess.isEmpty()) INTLUserTriggerService.beforeInsert(IntlUserToProcess);
        if (!USUserToProcess.isEmpty()) USUserTriggerService.beforeInsert(USUserToProcess);        

    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US accounts 
        List<User> UsOldListUserToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US accounts return Map
        Map<Id,User> UsOldMapUserToProcess = new Map<Id, User>(UsOldListUserToProcess);
        //Filter triggerNew List for US accounts 
        List<User> UsNewListUserToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US accounts return Map
        Map<Id,User> UsNewMapUserToProcess = new Map<Id, User>(UsNewListUserToProcess);

        //Filter triggerOld List for INTL users 
        List<User> IntlOldListUserToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL users return Map
        Map<Id,User> IntlOldMapUserToProcess = new Map<Id, User>(IntlOldListUserToProcess);
        //Filter triggerNew List for INTL users 
        List<User> IntlNewListUserToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL users return Map
        Map<Id,User> IntlNewMapUserToProcess = new Map<Id, User>(IntlNewListUserToProcess);

        if (!IntlOldListUserToProcess.isEmpty() && !IntlOldMapUserToProcess.isEmpty() && !IntlNewListUserToProcess.isEmpty() && !IntlNewMapUserToProcess.isEmpty())
            INTLUserTriggerService.beforeUpdate(IntlOldListUserToProcess, IntlOldMapUserToProcess, IntlNewListUserToProcess, IntlNewMapUserToProcess);
        if (!UsOldListUserToProcess.isEmpty() && !UsOldMapUserToProcess.isEmpty() && !UsNewListUserToProcess.isEmpty() && !UsNewMapUserToProcess.isEmpty())
            USUserTriggerService.beforeUpdate(UsOldListUserToProcess, UsOldMapUserToProcess, UsNewListUserToProcess, UsNewMapUserToProcess);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerNew List for US accounts 
        List<User> USUserToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US accounts return Map
        Map<Id,User> UsNewMapUserToProcess = new Map<Id, User>(USUserToProcess);
        //Filter triggerNew List for INTL users 
        List<User> IntlUserToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 
        //Filter triggerNewMap Map for INTL users return Map
        Map<Id,User> IntlNewMapUserToProcess = new Map<Id, User>(IntlUserToProcess);
        
        if (!IntlUserToProcess.isEmpty() && !IntlNewMapUserToProcess.isEmpty()) 
            INTLUserTriggerService.afterInsert(IntlUserToProcess, IntlNewMapUserToProcess);
        if (!USUserToProcess.isEmpty() && !UsNewMapUserToProcess.isEmpty()) 
            USUserTriggerService.afterInsert(USUserToProcess, UsNewMapUserToProcess); 
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerOld List for US accounts 
        List<User> UsOldListUserToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US accounts return Map
        Map<Id,User> UsOldMapUserToProcess = new Map<Id, User>(UsOldListUserToProcess);
        //Filter triggerNew List for US accounts 
        List<User> UsNewListUserToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US accounts return Map
        Map<Id,User> UsNewMapUserToProcess = new Map<Id, User>(UsNewListUserToProcess);

        //Filter triggerOld List for INTL users 
        List<User> IntlOldListUserToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL users return Map
        Map<Id,User> IntlOldMapUserToProcess = new Map<Id, User>(IntlOldListUserToProcess);
        //Filter triggerNew List for INTL users 
        List<User> IntlNewListUserToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL users return Map
        Map<Id,User> IntlNewMapUserToProcess = new Map<Id, User>(IntlNewListUserToProcess);

        if (!IntlOldListUserToProcess.isEmpty() && !IntlOldMapUserToProcess.isEmpty() && !IntlNewListUserToProcess.isEmpty() && !IntlNewMapUserToProcess.isEmpty())
            INTLUserTriggerService.afterUpdate(IntlOldListUserToProcess, IntlOldMapUserToProcess, IntlNewListUserToProcess, IntlNewMapUserToProcess);
        if (!UsOldListUserToProcess.isEmpty() && !UsOldMapUserToProcess.isEmpty() && !UsNewListUserToProcess.isEmpty() && !UsNewMapUserToProcess.isEmpty())
            USUserTriggerService.afterUpdate(UsOldListUserToProcess, UsOldMapUserToProcess, UsNewListUserToProcess, UsNewMapUserToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}