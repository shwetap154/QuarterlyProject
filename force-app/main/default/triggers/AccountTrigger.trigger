/****************************************************************************************************************************************** 
 * Class Name   : AccountTrigger
 * Description  : This trigger will handle all Account Trigger Logic
 * Created By   : Slalom Consulting/David Stern
 * Created Date : 07 February 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern(Slalom)     07/02/2020          Created
*****************************************************************************************************************************************/
trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new AccountTriggerHandler(), Bypass_Triggers__mdt.Account_Bypass__c);
}