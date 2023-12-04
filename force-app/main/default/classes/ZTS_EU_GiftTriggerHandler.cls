public with sharing class ZTS_EU_GiftTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  {
    
    public void beforeInsert(List<SObject> triggerNew){
        ZTS_EU_GiftTriggerService.beforeInsert((List<ZTS_EU_Gift__c>)triggerNew);
    }
    
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        ZTS_EU_GiftTriggerService.beforeUpdate((List<ZTS_EU_Gift__c>)triggerNew, (List<ZTS_EU_Gift__c>)triggerOld);
    }
    
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}