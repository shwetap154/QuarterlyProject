public with sharing class ZTS_EU_AccountSegmentThresholdHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  {
    
    public void beforeInsert(List<SObject> triggerNew){
        ZTS_EU_AccountSegmentThresholdService.beforeInsert((List<Account_Segmentation_threshold__c> )triggerNew);
    }
    
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        ZTS_EU_AccountSegmentThresholdService.beforeUpdate((List<Account_Segmentation_threshold__c> )triggerNew, (Map<Id, Account_Segmentation_threshold__c>)triggerOldMap);
    }
    
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){
        ZTS_EU_AccountSegmentThresholdService.beforeDelete((List<Account_Segmentation_threshold__c>)triggerOld);
    }

    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}