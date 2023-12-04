/****************************************************************************************************************************************** 
 * Trigger Name : CampaignMemberTriggerHandler
 * Description  : All Dispatch Trigger Logic for CampaignMember object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 7th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/07/2020          Created 
 * Aritra(Cognizant)     03/19/2021          Added the befor delete call for INTL (SC-008159)
*****************************************************************************************************************************************/
public with sharing class CampaignMemberTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    //Field used for CampaignMember segmentation logicQ
    private Schema.sObjectField marketField = CampaignMember.ZTS_EU_Market__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US Campaign Members
        List<CampaignMember> UsOldListCampaignMemberToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Campaign Membersreturn Map
        Map<Id,CampaignMember> UsOldMapCampaignMemberToProcess = new Map<Id, CampaignMember>(UsOldListCampaignMemberToProcess);
        //Filter triggerNew List for INTL Campaign Members
        List<CampaignMember> IntlOldListCampaignMemberToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL Campaign Membersreturn Map
        Map<Id,CampaignMember> IntlOldMapCampaignMemberToProcess = new Map<Id, CampaignMember>(IntlOldListCampaignMemberToProcess);
        
        if (!UsOldListCampaignMemberToProcess.isEmpty() && !UsOldMapCampaignMemberToProcess.isEmpty())
        USCampaignMemberTriggerService.beforeDelete(UsOldListCampaignMemberToProcess, UsOldMapCampaignMemberToProcess);
        //Aritra added the below part to run before delete event for INTL campaign member (SC-008159)
        if (!IntlOldListCampaignMemberToProcess.isEmpty() && !IntlOldListCampaignMemberToProcess.isEmpty())
        INTLCampaignMemberTriggerService.beforeDelete(UsOldListCampaignMemberToProcess, UsOldMapCampaignMemberToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US Campaign Members
        List<CampaignMember> UsNewListCampaignMemberToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Campaign Membersreturn Map
        Map<Id,CampaignMember> UsNewMapCampaignMemberToProcess = new Map<Id, CampaignMember>(UsNewListCampaignMemberToProcess);
        //Filter triggerNew List for INTL Campaign Members
        List<CampaignMember> IntlNewListCampaignMemberToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Campaign Membersreturn Map
        Map<Id,CampaignMember> IntlNewMapCampaignMemberToProcess = new Map<Id, CampaignMember>(IntlNewListCampaignMemberToProcess);

        if (!IntlNewListCampaignMemberToProcess.isEmpty() && !IntlNewMapCampaignMemberToProcess.isEmpty())
            INTLCampaignMemberTriggerService.afterInsert(IntlNewListCampaignMemberToProcess, IntlNewMapCampaignMemberToProcess);
        if (!UsNewListCampaignMemberToProcess.isEmpty() && !UsNewMapCampaignMemberToProcess.isEmpty())
            USCampaignMemberTriggerService.afterInsert(UsNewListCampaignMemberToProcess, UsNewMapCampaignMemberToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap){}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}