/****************************************************************************************************************************************** 
 * Trigger Name : PIT_Coaching_GuideTrigger
 * Description  : All Trigger Logic for Coaching Guide object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 10th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/10/2020          Created 
*****************************************************************************************************************************************/
trigger PIT_Coaching_GuideTrigger on PIT_Coaching_Guide__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    DispatchTriggerHandler.dispatchHandlerToFire(new PIT_Coaching_GuideTriggerHandler(), Bypass_Triggers__mdt.PIT_Coaching_Guide_Bypass__c);
}