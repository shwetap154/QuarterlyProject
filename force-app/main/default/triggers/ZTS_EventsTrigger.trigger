/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EventsTrigger
 * Description  : All Trigger Logic for ZTS_Events object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 12th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           02/12/2020          Created 
*****************************************************************************************************************************************/
trigger ZTS_EventsTrigger on ZTS_Events__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EventsTriggerHandler(), Bypass_Triggers__mdt.ZTS_Events_Bypass__c);
}