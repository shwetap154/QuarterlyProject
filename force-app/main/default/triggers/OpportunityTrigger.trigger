/****************************************************************************************************************************************** 
 * Class Name   : OpportunityTrigger
 * Description  : This trigger will handle all Opportunity Trigger Logic
 * Created By   : Slalom Consulting/David Stern
 * Created Date : 26 June 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern(Slalom)     06/26/2020          Created
*****************************************************************************************************************************************/
trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new OpportunityTriggerHandler(), Bypass_Triggers__mdt.Opportunity_Bypass__c);
}