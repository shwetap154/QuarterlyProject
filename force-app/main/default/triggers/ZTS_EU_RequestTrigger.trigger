/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_RequestTrigger
 * Description  : This is trigger on ZTS_EU_Request__c for all events.
 *      
 * Created By   : Slalom/David Stern 
 * Created Date : 12 February 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Slalom(David)           02/12/2020          All logic moved to INTLZTS_EU_RequestService Class.
*****************************************************************************************************************************************/
trigger ZTS_EU_RequestTrigger on ZTS_EU_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EU_RequestTriggerHandler(), Bypass_Triggers__mdt.ZTS_EU_Request_Bypass__c);
}