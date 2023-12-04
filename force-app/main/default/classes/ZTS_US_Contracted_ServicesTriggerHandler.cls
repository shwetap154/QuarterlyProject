public with sharing class ZTS_US_Contracted_ServicesTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  {
    
    public void beforeInsert(List<SObject> triggerNew){}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}

    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        
        ZTS_US_Contracted_ServicesTriggerService.afterInsert((List<ZTS_US_Contracted_Services__c>)triggerNew);
    }

    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}