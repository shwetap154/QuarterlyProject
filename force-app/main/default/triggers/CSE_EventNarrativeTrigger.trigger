/****************************************************************************************************************************************** 
 * Class Name   : CSE_EventNarrativeTrigger
 * Description  : This trigger will handle all CSE_EventNarrativeTrigger logic
 * Created By   : Slalom Consulting/Neil Kapoor
 * Created Date : September 19th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                  		  Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Neil Kapoor (Slalom)     		09/19/2021            Created
 * Madhu Goriparthi(Slalom) 		09/29/2021			  Modified
 * Venkat Joginapally(Slalom)		10/27/2021			  Updated to use Dispatch Trigger Handler
*****************************************************************************************************************************************/

trigger CSE_EventNarrativeTrigger on ZTS_US_Event_Narrative__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new CSE_EventNarrativeTriggerHandler(), Bypass_Triggers__mdt.EventNarrative_Bypass__c);
}