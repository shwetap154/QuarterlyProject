/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_Account_PositionTrigger
 * Description  : All Trigger Logic for ZTS_EU_Account_Position object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 13th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           02/13/2020          Created 
*****************************************************************************************************************************************/

trigger ZTS_EU_Account_PositionTrigger on ZTS_EU_Account_Position__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EU_Account_PositionTriggerHandler(),Bypass_Triggers__mdt.ZTS_EU_Account_Position_Bypass__c);
}