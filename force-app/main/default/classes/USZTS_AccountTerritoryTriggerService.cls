/****************************************************************************************************************************************** 
* Class Name   : USZTS_AccountTerritoryTriggerService
* Description  : Logic for all US ZTS_AccountTerritory__c triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 26 June 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     06/26/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/

public without sharing class USZTS_AccountTerritoryTriggerService 
{
    public static void afterInsert(List<ZTS_AccountTerritory__c> triggerNew, Map<Id, ZTS_AccountTerritory__c> triggerNewMap) 
    {
        SL_ZTS_US_AccountTerritoryTriggerHandler objHandler = new SL_ZTS_US_AccountTerritoryTriggerHandler();
        objHandler.onAfterInsert(triggerNew);
    }
    public static void afterUpdate(List<ZTS_AccountTerritory__c> triggerOld, Map<Id, ZTS_AccountTerritory__c> triggerOldMap, List<ZTS_AccountTerritory__c> triggerNew, Map<Id, ZTS_AccountTerritory__c> triggerNewMap) 
    {
        SL_ZTS_US_AccountTerritoryTriggerHandler objHandler = new SL_ZTS_US_AccountTerritoryTriggerHandler();
        objHandler.onAfterUpdate(triggerNew);
    }
    public static void afterDelete(List<ZTS_AccountTerritory__c> triggerOld, Map<Id, ZTS_AccountTerritory__c> triggerOldMap) 
    {
        SL_ZTS_US_AccountTerritoryTriggerHandler objHandler = new SL_ZTS_US_AccountTerritoryTriggerHandler();
        ZTS_TerritoryManager.deleteAccountTerritory(triggerOld,Trigger.isExecuting);
    }
}