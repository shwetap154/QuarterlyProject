/****************************************************************************************************************************************** 
 * Trigger Name   : AttendeeTrigger
 * Description  : This is trigger on Attendee__c for all events.
 *      
 * Created By   : Deloitte Consulting/Fayas Mansoor 
 * Created Date : 17 January 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Fayas Mansoor           01/17/2014          Created 
 * CloudSense(Bimba)       03/12/2014          Updated : added the check to bypass trigger+
 * CloudSense(Sohil)       04/06/2015          update call on Attendee Insert DEF-001251
 * Slalom(David)		   02/10/2020		   All logic moved to INTLAttendeeService Class.
*****************************************************************************************************************************************/

trigger AttendeeTrigger on Attendee__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
	DispatchTriggerHandler.dispatchHandlerToFire(new AttendeeTriggerHandler(), Bypass_Triggers__mdt.Attendee_Bypass__c);
}