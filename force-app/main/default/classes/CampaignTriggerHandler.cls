/****************************************************************************************************************************************** 
 * Trigger Name : CampaignTriggerHandler
 * Description  : All Dispatch Trigger Logic for Campaign object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 29 June 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern(Slalom)     06/29/2020          Created
*****************************************************************************************************************************************/
public with sharing class CampaignTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for Campaign segmentation logic
    private Schema.sObjectField marketField = Campaign.ZTS_EU_Market__c.getDescribe().getSObjectField();
    
    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US campaigns 
        List<Campaign> UsOldListCampaignToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US campaigns return Map
        Map<Id,Campaign> UsOldMapCampaignToProcess = new Map<Id, Campaign>(UsOldListCampaignToProcess);
        //Filter triggerNew List for US campaigns 
        List<Campaign> UsNewListCampaignToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US campaigns return Map
        Map<Id,Campaign> UsNewMapCampaignToProcess = new Map<Id, Campaign>(UsNewListCampaignToProcess);

        //Filter triggerOld List for INTL campaigns 
        List<Campaign> IntlOldListCampaignToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL campaigns return Map
        Map<Id,Campaign> IntlOldMapCampaignToProcess = new Map<Id, Campaign>(IntlOldListCampaignToProcess);
        //Filter triggerNew List for INTL campaigns 
        List<Campaign> IntlNewListCampaignToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL campaigns return Map
        Map<Id,Campaign> IntlNewMapCampaignToProcess = new Map<Id, Campaign>(IntlNewListCampaignToProcess);

        if (!UsOldListCampaignToProcess.isEmpty() && !UsOldMapCampaignToProcess.isEmpty() && !UsNewListCampaignToProcess.isEmpty() && !UsNewMapCampaignToProcess.isEmpty())
            USCampaignTriggerService.afterUpdate(UsOldListCampaignToProcess, UsOldMapCampaignToProcess, UsNewListCampaignToProcess, UsNewMapCampaignToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}