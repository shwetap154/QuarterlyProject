/****************************************************************************************************************************************** 
 * Trigger Name : TaskTrigger
 * Description  : All Trigger Logic for Task object.
 * Created By   : Slalom(David Stern) 
 * Created Date : 6th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/06/2020          Created 
*****************************************************************************************************************************************/
trigger TaskTrigger on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	DispatchTriggerHandler.dispatchHandlerToFire(new TaskTriggerHandler(), Bypass_Triggers__mdt.Task_Bypass__c);
}