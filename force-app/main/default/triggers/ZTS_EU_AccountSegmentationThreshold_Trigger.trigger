/**
* Trigger on object Account Segmentation Threshold
* used for all DB events on that object.
* Currently used for implementing populating of the
* minimum threshold value for the threshold range.
*
* @author Shefali Vinchurkar
*/

trigger ZTS_EU_AccountSegmentationThreshold_Trigger on Account_Segmentation_threshold__c (before insert, before update,After insert, After update, After delete,Before delete) {
   
    ZTS_EU_AccountSegmentThresholdHandler accountSegmentationThresholdTriggerHandler = new ZTS_EU_AccountSegmentThresholdHandler();
    DispatchTriggerHandler.setRecursionContexts(accountSegmentationThresholdTriggerHandler);
    DispatchTriggerHandler.dispatchHandlerToFire(accountSegmentationThresholdTriggerHandler, Bypass_Triggers__mdt.Account_Segmentation_threshold_Bypass__c);
}