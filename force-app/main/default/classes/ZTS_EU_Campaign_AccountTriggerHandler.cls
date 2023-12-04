/****************************************************************************************************************************************** 
 * Class Name   : ZTS_EU_Campaign_AccountTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Campaign_Account__c object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 11th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/11/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_EU_Campaign_AccountTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for ZTS_EU_Campaign_Account__c segmentation logicQ
    private Schema.sObjectField marketField = ZTS_EU_Campaign_Account__c.ZTS_EU_Market_from_Parent__c.getDescribe().getSObjectField();

    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US Campaign Accounts 
        List<ZTS_EU_Campaign_Account__c> UsNewListCampaignAccountToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Campaign Accounts return Map
        Map<Id,ZTS_EU_Campaign_Account__c> UsNewMapCampaignAccountToProcess = new Map<Id, ZTS_EU_Campaign_Account__c>(UsNewListCampaignAccountToProcess);
        //Filter triggerNew List for INTL Campaign Accounts 
        List<ZTS_EU_Campaign_Account__c> IntlNewListCampaignAccountToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Campaign Accounts return Map
        Map<Id,ZTS_EU_Campaign_Account__c> IntlNewMapCampaignAccountToProcess = new Map<Id, ZTS_EU_Campaign_Account__c>(IntlNewListCampaignAccountToProcess);

        if (!IntlNewListCampaignAccountToProcess.isEmpty() && !IntlNewMapCampaignAccountToProcess.isEmpty())
            INTLZTS_EU_Campaign_AcctTriggerService.afterInsert(IntlNewListCampaignAccountToProcess, IntlNewMapCampaignAccountToProcess);
        if (!UsNewListCampaignAccountToProcess.isEmpty() && !UsNewMapCampaignAccountToProcess.isEmpty())
            USZTS_EU_Campaign_AccountTriggerService.afterInsert(UsNewListCampaignAccountToProcess, UsNewMapCampaignAccountToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US Campaign Accounts 
        List<ZTS_EU_Campaign_Account__c> UsOldListCampaignAccountToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Campaign Accounts return Map
        Map<Id,ZTS_EU_Campaign_Account__c> UsOldMapCampaignAccountToProcess = new Map<Id, ZTS_EU_Campaign_Account__c>(UsOldListCampaignAccountToProcess);
        //Filter triggerNew List for US Campaign Accounts 
        List<ZTS_EU_Campaign_Account__c> UsNewListCampaignAccountToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US Campaign Accounts return Map
        Map<Id,ZTS_EU_Campaign_Account__c> UsNewMapCampaignAccountToProcess = new Map<Id, ZTS_EU_Campaign_Account__c>(UsNewListCampaignAccountToProcess);

        //Filter triggerOld List for INTL Campaign Accounts 
        List<ZTS_EU_Campaign_Account__c> IntlOldListCampaignAccountToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL Campaign Accounts return Map
        Map<Id,ZTS_EU_Campaign_Account__c> IntlOldMapCampaignAccountToProcess = new Map<Id, ZTS_EU_Campaign_Account__c>(IntlOldListCampaignAccountToProcess);
        //Filter triggerNew List for INTL Campaign Accounts 
        List<ZTS_EU_Campaign_Account__c> IntlNewListCampaignAccountToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL Campaign Accounts return Map
        Map<Id,ZTS_EU_Campaign_Account__c> IntlNewMapCampaignAccountToProcess = new Map<Id, ZTS_EU_Campaign_Account__c>(IntlNewListCampaignAccountToProcess);
        
        if (!IntlOldListCampaignAccountToProcess.isEmpty() && !IntlOldMapCampaignAccountToProcess.isEmpty() && !IntlNewListCampaignAccountToProcess.isEmpty() && !IntlNewMapCampaignAccountToProcess.isEmpty())
            INTLZTS_EU_Campaign_AcctTriggerService.afterUpdate(IntlOldListCampaignAccountToProcess, IntlOldMapCampaignAccountToProcess, IntlNewListCampaignAccountToProcess, IntlNewMapCampaignAccountToProcess);
        if (!UsOldListCampaignAccountToProcess.isEmpty() && !UsOldMapCampaignAccountToProcess.isEmpty() && !UsNewListCampaignAccountToProcess.isEmpty() && !UsNewMapCampaignAccountToProcess.isEmpty())
            USZTS_EU_Campaign_AccountTriggerService.afterUpdate(UsOldListCampaignAccountToProcess, UsOldMapCampaignAccountToProcess, UsNewListCampaignAccountToProcess, UsNewMapCampaignAccountToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US Campaign Accounts 
        List<ZTS_EU_Campaign_Account__c> UsOldListCampaignAccountToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US Campaign Accounts return Map
        Map<Id,ZTS_EU_Campaign_Account__c> UsOldMapCampaignAccountToProcess = new Map<Id, ZTS_EU_Campaign_Account__c>(UsOldListCampaignAccountToProcess);
        //Filter triggerNew List for INTL Campaign Accounts 
        List<ZTS_EU_Campaign_Account__c> IntlOldListCampaignAccountToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL Campaign Accounts return Map
        Map<Id,ZTS_EU_Campaign_Account__c> IntlOldMapCampaignAccountToProcess = new Map<Id, ZTS_EU_Campaign_Account__c>(IntlOldListCampaignAccountToProcess);
        
        if (!UsOldListCampaignAccountToProcess.isEmpty() && !UsOldMapCampaignAccountToProcess.isEmpty())
            USZTS_EU_Campaign_AccountTriggerService.afterDelete(UsOldListCampaignAccountToProcess, UsOldMapCampaignAccountToProcess);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}