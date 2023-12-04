/****************************************************************************************************************************************** 
 * Class Name   : CSE_VedDraEventTrigger
 * Description  : This trigger will handle all CSE_VedDraEventTrigger logic
 * Created By   : Slalom Consulting/Jyothsna Jogi
 * Created Date : December 9th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                  		  Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Jyothsna Jogi                    12/09/2021           Created
*****************************************************************************************************************************************/

trigger CSE_VedDraEventTrigger on ZTS_US_VedDRA_Event__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    DispatchTriggerHandler.dispatchHandlerToFire(new CSE_VedDraEventTriggerHandler(),Bypass_Triggers__mdt.VedDra_Event_Bypass__c);

}