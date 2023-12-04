/****************************************************************************************************************************************** 
 * Trigger Name : ContactTrigger
 * Description  : All Trigger Logic for Contact object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 10th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/10/2020          Modified to use Trigger Framework 
*****************************************************************************************************************************************/

trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    ContactTriggerHandler contactTriggerHandler = new ContactTriggerHandler();
    DispatchTriggerHandler.dispatchHandlerToFire(contactTriggerHandler, Bypass_Triggers__mdt.Contact_Bypass__c);
}