/****************************************************************************************************************************************** 
 * Class Name   : Pitcher_ActivityTrigger
 * Description  : This trigger will handle all Pitcher_Activity__c Trigger Logic
 * Created By   : Slalom Consulting/David Stern
 * Created Date : 29 June 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern(Slalom)     06/29/2020          Created
*****************************************************************************************************************************************/
trigger Pitcher_ActivityTrigger on Pitcher_Activity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new Pitcher_ActivityTriggerHandler(), Bypass_Triggers__mdt.Pitcher_Activity_Bypass__c);
}