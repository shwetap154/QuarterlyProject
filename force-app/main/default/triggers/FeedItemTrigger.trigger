/****************************************************************************************************************************************** 
 * Class Name   : FeedItemTrigger
 * Description  : This trigger will handle all FeedItem Trigger Logic
 * Created By   : Slalom Consulting/Allister McKenzie
 * Created Date : 19 November 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date                Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Allister McKenzie(Slalom)    11/19/2020          Created
*****************************************************************************************************************************************/
trigger FeedItemTrigger on FeedItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire( new FeedItemTriggerHandler(), Bypass_Triggers__mdt.Feed_Item_ByPass__c );
}