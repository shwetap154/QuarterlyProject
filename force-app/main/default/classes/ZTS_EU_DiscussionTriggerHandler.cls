/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_DiscussionTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Discussion__c object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 11th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/11/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_EU_DiscussionTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    private Schema.sObjectField marketField = ZTS_EU_Discussion__c.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US discussions 
        List<ZTS_EU_Discussion__c> UsOldListDiscussionToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US discussions return Map
        Map<Id,ZTS_EU_Discussion__c> UsOldMapDiscussionToProcess = new Map<Id, ZTS_EU_Discussion__c>(UsOldListDiscussionToProcess);
        //Filter triggerNew List for INTL discussions 
        List<ZTS_EU_Discussion__c> IntlOldListDiscussionToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL discussions return Map
        Map<Id,ZTS_EU_Discussion__c> IntlOldMapDiscussionToProcess = new Map<Id, ZTS_EU_Discussion__c>(IntlOldListDiscussionToProcess);

        if (!IntlOldListDiscussionToProcess.isEmpty() && !IntlOldMapDiscussionToProcess.isEmpty()) 
            INTLZTS_EU_DiscussionTriggerService.beforeDelete(IntlOldListDiscussionToProcess, IntlOldMapDiscussionToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {

        //Filter triggerNew List for US discussions 
        List<ZTS_EU_Discussion__c> UsNewListDiscussionToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US discussions return Map
        Map<Id,ZTS_EU_Discussion__c> UsNewMapDiscussionToProcess = new Map<Id, ZTS_EU_Discussion__c>(UsNewListDiscussionToProcess);
        //Filter triggerNew List for INTL discussions 
        List<ZTS_EU_Discussion__c> IntlNewListDiscussionToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL discussions return Map
        Map<Id,ZTS_EU_Discussion__c> IntlNewMapDiscussionToProcess = new Map<Id, ZTS_EU_Discussion__c>(IntlNewListDiscussionToProcess);

        if (!IntlNewListDiscussionToProcess.isEmpty() && !IntlNewMapDiscussionToProcess.isEmpty())
            INTLZTS_EU_DiscussionTriggerService.afterInsert(IntlNewListDiscussionToProcess, IntlNewMapDiscussionToProcess);
        if (!UsNewListDiscussionToProcess.isEmpty() && !UsNewMapDiscussionToProcess.isEmpty())
            USZTS_EU_DiscussionTriggerService.afterInsert(UsNewListDiscussionToProcess, UsNewMapDiscussionToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}