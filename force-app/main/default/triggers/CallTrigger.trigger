/****************************************************************************************************************************************** 
 ****************************************************************************************************************************************** 
 * Trigger Name : CallTrigger
 * Description  : All Trigger Logic for Contact object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 17th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/17/2020          Modified to use Trigger Framework 
*****************************************************************************************************************************************/

trigger CallTrigger on Call__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{   
    CallTriggerHandler callTriggerHandler = new CallTriggerHandler();
    DispatchTriggerHandler.setRecursionContexts(callTriggerHandler);
    DispatchTriggerHandler.dispatchHandlerToFire(callTriggerHandler, Bypass_Triggers__mdt.Call_Bypass__c);
}