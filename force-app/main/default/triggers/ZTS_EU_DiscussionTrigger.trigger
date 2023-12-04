/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_DiscussionTrigger
 * Description  : All Trigger Logic for ZTS_EU_Discussion__c object.
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 11th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman           02/11/2020          Created 
*****************************************************************************************************************************************/
trigger ZTS_EU_DiscussionTrigger on ZTS_EU_Discussion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	ZTS_EU_DiscussionTriggerHandler discussionTriggerHandler = new ZTS_EU_DiscussionTriggerHandler();
    DispatchTriggerHandler.setRecursionContexts(discussionTriggerHandler);
    DispatchTriggerHandler.dispatchHandlerToFire(discussionTriggerHandler, Bypass_Triggers__mdt.ZTS_EU_Discussion_Bypass__c);
}