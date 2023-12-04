/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_TerritoryTrigger
 * Description  : This is trigger on ZTS_EU_Territory__c for all events.
 *      
 * Created By   : Slalom/David Stern 
 * Created Date : 12 February 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Slalom(David)		   02/12/2020		   All logic moved to INTLZTS_EU_TerritoryService Class.
*****************************************************************************************************************************************/
trigger ZTS_EU_TerritoryTrigger on ZTS_EU_Territory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
	DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EU_TerritoryTriggerHandler(), Bypass_Triggers__mdt.ZTS_EU_Territory_Bypass__c);
}