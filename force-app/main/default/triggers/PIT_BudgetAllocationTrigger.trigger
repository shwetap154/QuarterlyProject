/****************************************************************************************************************************************** 
 * Trigger Name : PIT_BudgetAllocationTrigger
 * Description  : All Trigger Logic for PIT_Budget_Allocation__c object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 24th July, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           07/24/2020          Modified to use Trigger Framework 
*****************************************************************************************************************************************/
trigger PIT_BudgetAllocationTrigger on PIT_Budget_Allocation__c (before insert, before update, before delete, after insert, after update, after delete) 
{
	DispatchTriggerHandler.dispatchHandlerToFire(new PIT_BudgetAllocation_TriggerHandler(), Bypass_Triggers__mdt.PIT_Budget_Allocation_Bypass__c);

}