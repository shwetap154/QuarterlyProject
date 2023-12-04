/****************************************************************************************************************************************** 
 * Trigger Name : UserTrigger
 * Description  : All Trigger Logic for User object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 6th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/06/2020          Created 
*****************************************************************************************************************************************/
trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	DispatchTriggerHandler.dispatchHandlerToFire(new UserTriggerHandler(), Bypass_Triggers__mdt.User_Bypass__c);
}