/****************************************************************************************************************************************** 
 * Trigger Name : Time_Out_of_TerritoryTrigger
 * Description  : All Trigger Logic for Time_Out_of_Territory__c object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 12th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/12/2020          Created 
*****************************************************************************************************************************************/
trigger Time_Out_of_TerritoryTrigger on Time_Out_of_Territory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	DispatchTriggerHandler.dispatchHandlerToFire(new Time_Out_of_TerritoryTriggerHandler(), Bypass_Triggers__mdt.Time_Out_of_Territory_Bypass__c);
}