/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_ColleagueTrigger
 * Description  : This is trigger on ZTS_EU_Colleague__c for all events.
 *      
 * Created By   : Slalom/David Stern 
 * Created Date : 11 February 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Slalom(David)		   02/11/2020		   All logic moved to INTLZTS_EU_ColleagueService Class.
*****************************************************************************************************************************************/
trigger ZTS_EU_ColleagueTrigger on ZTS_EU_Colleague__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
	DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EU_ColleagueTriggerHandler(), Bypass_Triggers__mdt.ZTS_EU_Colleague_Bypass__c);
}