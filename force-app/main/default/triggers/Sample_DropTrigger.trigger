/****************************************************************************************************************************************** 
 * Class Name   : Sample_DropTrigger
 * Description  : This trigger will handle all Sample_Drop__c Trigger Logic
 * Created By   : Slalom Consulting/David Stern
 * Created Date : 18 February 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern(Slalom)     02/18/2020          Created
*****************************************************************************************************************************************/
trigger Sample_DropTrigger on Sample_Drop__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new Sample_DropTriggerHandler(), Bypass_Triggers__mdt.Sample_Drop_Bypass__c);
}