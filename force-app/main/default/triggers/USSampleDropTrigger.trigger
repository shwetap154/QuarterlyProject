/****************************************************************************************************************************************** 
 * Class Name   : USSampleDropTrigger
 * Description  : This trigger will handle all ZTS_US_Sample_Drop__c Trigger Logic
 * Created By   : Slalom Consulting/Alex Carstairs
 * Created Date : 26th May 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)     05/26/2020          Created
*****************************************************************************************************************************************/
trigger USSampleDropTrigger on ZTS_US_Sample_Drop__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new USSampleDropTriggerHandler(), Bypass_Triggers__mdt.Sample_Drop_Bypass__c);
}