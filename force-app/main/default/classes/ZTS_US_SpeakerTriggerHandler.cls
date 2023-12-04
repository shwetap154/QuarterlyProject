/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_US_SpeakerTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_US_Speaker__c object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 12th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/12/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_US_SpeakerTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{

    private Schema.sObjectField marketField = ZTS_US_Speaker__c.ZTS_EU_Market_from_Parent__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) 
    {
        System.debug('marketField ::: '+marketField);
        //Filter triggerNew List for US speaker 
        List<ZTS_US_Speaker__c> UsNewListSpeakersToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        System.debug('UsNewListSpeakersToProcess ::: '+UsNewListSpeakersToProcess);

        if (!UsNewListSpeakersToProcess.isEmpty())
            USZTS_US_SpeakerTriggerService.beforeInsert( UsNewListSpeakersToProcess );
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US speakers 
        List<ZTS_US_Speaker__c> UsOldListSpeakersToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US speakers return Map
        Map<Id,ZTS_US_Speaker__c> UsOldMapSpeakersToProcess = new Map<Id, ZTS_US_Speaker__c>(UsOldListSpeakersToProcess);
        //Filter triggerNew List for US speakers 
        List<ZTS_US_Speaker__c> UsNewListSpeakersToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US speakers return Map
        Map<Id,ZTS_US_Speaker__c> UsNewMapExpensesToProcess = new Map<Id, ZTS_US_Speaker__c>(UsNewListSpeakersToProcess);

        if (!UsOldListSpeakersToProcess.isEmpty() && !UsOldMapSpeakersToProcess.isEmpty() && !UsNewListSpeakersToProcess.isEmpty() && !UsNewMapExpensesToProcess.isEmpty())
            USZTS_US_SpeakerTriggerService.beforeUpdate(triggerOld, (Map<Id, ZTS_US_Speaker__c>) triggerOldMap, triggerNew, (Map<Id, ZTS_US_Speaker__c>) triggerNewMap);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US speakers 
        List<ZTS_US_Speaker__c> UsOldListSpeakersToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US speakers return Map
        Map<Id,ZTS_US_Speaker__c> UsOldMapSpeakersToProcess = new Map<Id, ZTS_US_Speaker__c>(UsOldListSpeakersToProcess);

        if (!UsOldListSpeakersToProcess.isEmpty() && !UsOldMapSpeakersToProcess.isEmpty())
            USZTS_US_SpeakerTriggerService.beforeDelete(triggerOld, (Map<Id, ZTS_US_Speaker__c>)triggerOldMap);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        //Filter triggerNew List for US speakers 
        List<ZTS_US_Speaker__c> UsNewListSpeakersToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US speakers return Map
        Map<Id,ZTS_US_Speaker__c> UsNewMapExpensesToProcess = new Map<Id, ZTS_US_Speaker__c>(UsNewListSpeakersToProcess);

        if(!UsNewListSpeakersToProcess.isEmpty() && !UsNewMapExpensesToProcess.isEmpty())
    	    USZTS_US_SpeakerTriggerService.afterInsert(triggerNew, (Map<Id, ZTS_US_Speaker__c>)triggerNewMap);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US speakers 
        List<ZTS_US_Speaker__c> UsOldListSpeakersToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US speakers return Map
        Map<Id,ZTS_US_Speaker__c> UsOldMapSpeakersToProcess = new Map<Id, ZTS_US_Speaker__c>(UsOldListSpeakersToProcess);
        //Filter triggerNew List for US speakers 
        List<ZTS_US_Speaker__c> UsNewListSpeakersToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US speakers return Map
        Map<Id,ZTS_US_Speaker__c> UsNewMapExpensesToProcess = new Map<Id, ZTS_US_Speaker__c>(UsNewListSpeakersToProcess);

        if (!UsOldListSpeakersToProcess.isEmpty() && !UsOldMapSpeakersToProcess.isEmpty() && !UsNewListSpeakersToProcess.isEmpty() && !UsNewMapExpensesToProcess.isEmpty())
            USZTS_US_SpeakerTriggerService.afterUpdate(triggerOld, (Map<Id, ZTS_US_Speaker__c>) triggerOldMap, triggerNew, (Map<Id, ZTS_US_Speaker__c>) triggerNewMap);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap)
    {
        //Filter triggerOld List for US speakers 
        List<ZTS_US_Speaker__c> UsOldListSpeakersToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US speakers return Map
        Map<Id,ZTS_US_Speaker__c> UsOldMapSpeakersToProcess = new Map<Id, ZTS_US_Speaker__c>(UsOldListSpeakersToProcess);

        if (!UsOldListSpeakersToProcess.isEmpty() && !UsOldMapSpeakersToProcess.isEmpty())
            USZTS_US_SpeakerTriggerService.afterDelete(triggerOld, (Map<Id, ZTS_US_Speaker__c>)triggerOldMap);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}