/****************************************************************************************************************************************** 
 * Class Name   : ZTS_AccountTerritoryTrigger
 * Description  : This trigger will handle all Account Trigger Logic
 * Created By   : Slalom Consulting/David Stern
 * Created Date : 26 June 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern(Slalom)     06/26/2020          Created
*****************************************************************************************************************************************/
trigger ZTS_AccountTerritoryTrigger on ZTS_AccountTerritory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_AccountTerritoryTriggerHandler(), Bypass_Triggers__mdt.ZTS_AccountTerritory_Bypass__c);
}