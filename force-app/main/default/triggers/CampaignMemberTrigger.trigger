/****************************************************************************************************************************************** 
 * Trigger Name : CampaignMemberTrigger
 * Description  : All Trigger Logic for CampaignMember object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 7th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/07/2020          Created 
*****************************************************************************************************************************************/
trigger CampaignMemberTrigger on CampaignMember (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    DispatchTriggerHandler.dispatchHandlerToFire(new CampaignMemberTriggerHandler(), Bypass_Triggers__mdt.Campaign_Member_Bypass__c);
}