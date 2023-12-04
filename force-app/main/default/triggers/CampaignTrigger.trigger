/****************************************************************************************************************************************** 
 * Class Name   : CampaignTrigger
 * Description  : This trigger will handle all Account Trigger Logic
 * Created By   : Slalom Consulting/David Stern
 * Created Date : 29 June 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern(Slalom)     06/29/2020          Created
*****************************************************************************************************************************************/
trigger CampaignTrigger on Campaign (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new CampaignTriggerHandler(), Bypass_Triggers__mdt.Campaign_Bypass__c);
}