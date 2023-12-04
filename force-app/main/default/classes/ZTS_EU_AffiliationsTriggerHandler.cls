/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_AffiliationsTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Affiliation object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 07 May 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           05/07/2020          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_EU_AffiliationsTriggerHandler  extends TriggerHandlerExtension implements TriggerHandlerInterface 
{
    //Field used for ZTS_EU_Affiliation segmentation logic
    private Schema.sObjectField marketField = ZTS_EU_Affiliations__c.ZTS_EU_Market_from_Parent__c.getDescribe().getSObjectField();
    
    public void beforeInsert(List<SObject> triggerNew) 
    {
        //Filter triggerNew List for US ZTS_EU_Affiliations 
        List<ZTS_EU_Affiliations__c> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNew List for INTL ZTS_EU_Affiliations 
        List<ZTS_EU_Affiliations__c> IntlAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false); 
        System.debug('beforeInsert');
        if (!UsNewListAccToProcess.isEmpty()) USZTS_EU_AffiliationsTriggerService.beforeInsert(UsNewListAccToProcess);       
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    { 
        //Filter triggerOld List for US ZTS_EU_Affiliations 
        List<ZTS_EU_Affiliations__c> UsOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US ZTS_EU_Affiliations return Map
        Map<Id,ZTS_EU_Affiliations__c> UsOldMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(UsOldListAccToProcess);
        //Filter triggerNew List for US ZTS_EU_Affiliations 
        List<ZTS_EU_Affiliations__c> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US ZTS_EU_Affiliations return Map
        Map<Id,ZTS_EU_Affiliations__c> UsNewMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(UsNewListAccToProcess);

        //Filter triggerOld List for INTL ZTS_EU_Affiliations 
        List<ZTS_EU_Affiliations__c> IntlOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL ZTS_EU_Affiliations return Map
        Map<Id,ZTS_EU_Affiliations__c> IntlOldMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(IntlOldListAccToProcess);
        //Filter triggerNew List for INTL ZTS_EU_Affiliations 
        List<ZTS_EU_Affiliations__c> IntlNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL ZTS_EU_Affiliations return Map
        Map<Id,ZTS_EU_Affiliations__c> IntlNewMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(IntlNewListAccToProcess);
        System.debug('beforeUpdate');
        if (!IntlOldListAccToProcess.isEmpty() && !IntlOldMapAccToProcess.isEmpty() && !IntlNewListAccToProcess.isEmpty() && !IntlNewMapAccToProcess.isEmpty())
            INTLZTS_EU_AffiliationsTriggerService.beforeUpdate(IntlOldListAccToProcess, IntlOldMapAccToProcess, IntlNewListAccToProcess, IntlNewMapAccToProcess);
        if (!UsOldListAccToProcess.isEmpty() && !UsOldMapAccToProcess.isEmpty() && !UsNewListAccToProcess.isEmpty() && !UsNewMapAccToProcess.isEmpty())
            USZTS_EU_AffiliationsTriggerService.beforeUpdate(UsOldListAccToProcess, UsOldMapAccToProcess, UsNewListAccToProcess, UsNewMapAccToProcess);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        //Filter triggerOld List for US ZTS_EU_Affiliations 
        List<ZTS_EU_Affiliations__c> UsOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US ZTS_EU_Affiliations return Map
        Map<Id,ZTS_EU_Affiliations__c> UsOldMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(UsOldListAccToProcess);
        //Filter triggerNew List for INTL ZTS_EU_Affiliations 
        List<ZTS_EU_Affiliations__c> IntlOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL ZTS_EU_Affiliations return Map
        Map<Id,ZTS_EU_Affiliations__c> IntlOldMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(IntlOldListAccToProcess);

        if (!IntlOldListAccToProcess.isEmpty() && !IntlOldMapAccToProcess.isEmpty()) 
            INTLZTS_EU_AffiliationsTriggerService.beforeDelete(IntlOldListAccToProcess, IntlOldMapAccToProcess);
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerNew List for US ZTS_EU_Affiliations 
        List<ZTS_EU_Affiliations__c> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US ZTS_EU_Affiliations return Map
        Map<Id,ZTS_EU_Affiliations__c> UsNewMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(UsNewListAccToProcess);
        //Filter triggerNew List for INTL ZTS_EU_Affiliations 
        List<ZTS_EU_Affiliations__c> IntlNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL ZTS_EU_Affiliations return Map
        Map<Id,ZTS_EU_Affiliations__c> IntlNewMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(IntlNewListAccToProcess);
        System.debug('afterInsert');
        if (!IntlNewListAccToProcess.isEmpty() && !IntlNewMapAccToProcess.isEmpty())
            INTLZTS_EU_AffiliationsTriggerService.afterInsert(IntlNewListAccToProcess, IntlNewMapAccToProcess);
        if (!UsNewListAccToProcess.isEmpty() && !UsNewMapAccToProcess.isEmpty())
            USZTS_EU_AffiliationsTriggerService.afterInsert(UsNewListAccToProcess, UsNewMapAccToProcess);
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        //Filter triggerOld List for US ZTS_EU_Affilitions 
        List<ZTS_EU_Affiliations__c> UsOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US ZTS_EU_Affilitions return Map
        Map<Id,ZTS_EU_Affiliations__c> UsOldMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(UsOldListAccToProcess);
        //Filter triggerNew List for US ZTS_EU_Affilitions 
        List<ZTS_EU_Affiliations__c> UsNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, true);
        //Filter triggerNewMap Map for US ZTS_EU_Affilitions return Map
        Map<Id,ZTS_EU_Affiliations__c> UsNewMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(UsNewListAccToProcess);

        //Filter triggerOld List for INTL ZTS_EU_Affilitions 
        List<ZTS_EU_Affiliations__c> IntlOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerOldMap Map for INTL ZTS_EU_Affilitions return Map
        Map<Id,ZTS_EU_Affiliations__c> IntlOldMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(IntlOldListAccToProcess);
        //Filter triggerNew List for INTL ZTS_EU_Affilitions 
        List<ZTS_EU_Affiliations__c> IntlNewListAccToProcess = TriggerHandlerExtension.filter(triggerNew, marketField, false);
        //Filter triggerNewMap Map for INTL ZTS_EU_Affilitions return Map
        Map<Id,ZTS_EU_Affiliations__c> IntlNewMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(IntlNewListAccToProcess);
        System.debug('afterUpdate');
        if (!UsOldListAccToProcess.isEmpty() && !UsOldMapAccToProcess.isEmpty() && !UsNewListAccToProcess.isEmpty() && !UsNewMapAccToProcess.isEmpty())
            USZTS_EU_AffiliationsTriggerService.afterUpdate(UsOldListAccToProcess, UsOldMapAccToProcess, UsNewListAccToProcess, UsNewMapAccToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        //TPDEV-733 Pooja Added
        //Filter triggerOld List for US ZTS_EU_Affiliations 
        List<ZTS_EU_Affiliations__c> UsOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, true);
        //Filter triggerOldMap Map for US ZTS_EU_Affiliations return Map
        Map<Id,ZTS_EU_Affiliations__c> UsOldMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(UsOldListAccToProcess);
        //Filter triggerNew List for INTL ZTS_EU_Affiliations 
        List<ZTS_EU_Affiliations__c> IntlOldListAccToProcess = TriggerHandlerExtension.filter(triggerOld, marketField, false);
        //Filter triggerNewMap Map for INTL ZTS_EU_Affiliations return Map
        Map<Id,ZTS_EU_Affiliations__c> IntlOldMapAccToProcess = new Map<Id, ZTS_EU_Affiliations__c>(IntlOldListAccToProcess);

        if (!UsOldListAccToProcess.isEmpty() && !UsOldMapAccToProcess.isEmpty()) 
            USZTS_EU_AffiliationsTriggerService.afterDelete(UsOldListAccToProcess, UsOldMapAccToProcess);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}  
}