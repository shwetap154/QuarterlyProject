/*******************************************************************************************************************************************
* File Name     :  OrderTrigger
* Description   :  This trigger has actions to be performed on the Order object                        

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     8th-July-2015   Shreyas             Created the trigger.

********************************************************************************************************************************************/

trigger OrdersTrigger on Orders__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{        
    DispatchTriggerHandler.dispatchHandlerToFire(new OrdersTriggerHandler(), Bypass_Triggers__mdt.Order_Bypass__c);
}