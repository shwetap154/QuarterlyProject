/****************************************************************************************************************************************** 
 * Trigger Name : InternalAttendeeTrigger
 * Description  : All Trigger Logic for Zoetis Attendee object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 6th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern           02/06/2020          Created 
*****************************************************************************************************************************************/
trigger InternalAttendeeTrigger on ZTS_US_Internal_Attendee__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	DispatchTriggerHandler.dispatchHandlerToFire(new InternalAttendeeTriggerHandler(), Bypass_Triggers__mdt.Zoetis_Attendee_Bypass__c);
}