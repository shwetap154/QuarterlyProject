public with sharing class ASC_AdministrationTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  {
    
    public void beforeInsert(List<SObject> triggerNew){
        ASC_AdministrationTriggerService.beforeInsert((List<ASC_Administration__c>)triggerNew);
    }
    
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        ASC_AdministrationTriggerService.beforeUpdate((List<ASC_Administration__c>)triggerNew);
    }
    
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}