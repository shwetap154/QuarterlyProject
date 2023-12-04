/****************************************************************************************************************************************** 
 * Trigger Name   : ContractTrigger
 * Description  : This is trigger on Contract for all events.
 *      
 * Created By   : Slalom/David Stern 
 * Created Date : 10 February 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Slalom(David)		   02/10/2020		   All logic moved to INTLAttendeeService Class.
*****************************************************************************************************************************************/

trigger ContractTrigger on Contract (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.setRecursionContexts(new ContractTriggerHandler());
	DispatchTriggerHandler.dispatchHandlerToFire(new ContractTriggerHandler(), Bypass_Triggers__mdt.Contract_Bypass__c);
}