/****************************************************************************************************************************************** 
 ****************************************************************************************************************************************** 
 * Trigger Name : FeedCommentTrigger
 * Description  : All Trigger Logic for FeedComment object.
 * Created By   : Allister McKenzie/Slalom 
 * Created Date : 19th November, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                        Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Allister McKenzie(Slalom)        11/19/2020         Modified to use Trigger Framework 
*****************************************************************************************************************************************/
trigger FeedCommentTrigger on FeedComment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new FeedCommentTriggerHandler(), Bypass_Triggers__mdt.Feed_Comment_Bypass__c);
}