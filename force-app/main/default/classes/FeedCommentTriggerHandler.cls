/****************************************************************************************************************************************** 
 * Trigger Name : FeedCommentTriggerHandler
 * Description  : All Dispatch Trigger Logic for FeedComment object.
 * Created By   : Slalom(Allister McKenzie) 
 * Created Date : 19th November, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Allister McKenzie        11/19/2020         Created 
*****************************************************************************************************************************************/
public with sharing class FeedCommentTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface {

    public void beforeInsert(List<SObject> triggerNew) {
        INTLFeedCommentTriggerService.beforeInsert(triggerNew);
    }

    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
    }

    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
    }

    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
    }

    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
    }

    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
    }

    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
    }
}