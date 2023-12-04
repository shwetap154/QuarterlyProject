/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_Account_AffiliatTriggerHandler
 * Description  : All Dispatch Trigger Logic for ZTS_EU_Account_Affiliations object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 13th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           02/13/2020          Created 
*****************************************************************************************************************************************/



public with sharing class ZTS_EU_Account_AffiliatTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface {

    public void beforeInsert(List<SObject> triggerNew) 
    {}

    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        INTLZTS_EU_Account_AffiliaTriggerService.beforeUpdate(triggerOld, (Map<Id, ZTS_EU_Account_Affiliations__c>) triggerOldMap, triggerNew, (Map<Id, ZTS_EU_Account_Affiliations__c>) triggerNewMap);
    }

    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        INTLZTS_EU_Account_AffiliaTriggerService.beforeDelete(triggerOld,(Map<Id, ZTS_EU_Account_Affiliations__c>) triggerOldMap);
    }

    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        USZTS_EU_Account_AffiliatTriggerService.afterInsert(triggerNew, (Map<Id, ZTS_EU_Account_Affiliations__c>) triggerNewMap);
        INTLZTS_EU_Account_AffiliaTriggerService.afterInsert(triggerNew, (Map<Id, ZTS_EU_Account_Affiliations__c>) triggerNewMap);
    }

    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        USZTS_EU_Account_AffiliatTriggerService.afterUpdate(triggerOld, (Map<Id, ZTS_EU_Account_Affiliations__c>) triggerOldMap, triggerNew, (Map<Id, ZTS_EU_Account_Affiliations__c>) triggerNewMap);
		INTLZTS_EU_Account_AffiliaTriggerService.afterUpdate(triggerOld, (Map<Id, ZTS_EU_Account_Affiliations__c>) triggerOldMap, triggerNew, (Map<Id, ZTS_EU_Account_Affiliations__c>) triggerNewMap);
    }

    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        USZTS_EU_Account_AffiliatTriggerService.afterDelete(triggerOld, (Map<Id, ZTS_EU_Account_Affiliations__c>) triggerOldMap);
        INTLZTS_EU_Account_AffiliaTriggerService.afterDelete(triggerOld, (Map<Id, ZTS_EU_Account_Affiliations__c>) triggerOldMap);
    }

    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        USZTS_EU_Account_AffiliatTriggerService.afterUndelete(triggerNew, (Map<Id, ZTS_EU_Account_Affiliations__c>) triggerNewMap);
        INTLZTS_EU_Account_AffiliaTriggerService.afterUndelete(triggerNew, (Map<Id, ZTS_EU_Account_Affiliations__c>) triggerNewMap);
    }

}