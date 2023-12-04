/****************************************************************************************************************************************** 
 * Trigger Name : AddressTrigger
 * Description  : All Trigger Logic for Address object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 17th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           02/17/2020          Created 
*****************************************************************************************************************************************/

trigger AddressTrigger on Address__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new AddressTriggerHandler(),Bypass_Triggers__mdt.Address_Bypass__c);
}