/****************************************************************************************************************************************** 
 * Class Name   : AttachmentTrigger
 * Description  : This trigger will handle all Attachment Trigger Logic
 * Created By   : Slalom Consulting/David Stern
 * Created Date : 17 February 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern(Slalom)     17/02/2020          Created
*****************************************************************************************************************************************/
trigger AttachmentTrigger on Attachment (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new AttachmentTriggerHandler(),Bypass_Triggers__mdt.Attachment_Bypass__c);
}