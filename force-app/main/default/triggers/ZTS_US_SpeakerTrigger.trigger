/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_US_SpeakerTrigger
 * Description  : All Trigger Logic for ZTS_US_Speaker__c object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 12th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/12/2020          Created 
*****************************************************************************************************************************************/
trigger ZTS_US_SpeakerTrigger on ZTS_US_Speaker__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_US_SpeakerTriggerHandler(), Bypass_Triggers__mdt.ZTS_US_Speaker_Bypass__c);
}