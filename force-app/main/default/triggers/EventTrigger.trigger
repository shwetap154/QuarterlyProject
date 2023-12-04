/****************************************************************************************************************************************** 
 * Class Name   : EventTrigger
 * Description  : This trigger will handle all Event Trigger Logic
 * Created By   : Slalom Consulting/David Stern
 * Created Date : 06 February 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern(Slalom)     06/02/2020          Created, existing Trigger logic moved to Service class
*****************************************************************************************************************************************/

trigger EventTrigger on Event (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new EventTriggerHandler(), Bypass_Triggers__mdt.Event_Bypass__c);
}