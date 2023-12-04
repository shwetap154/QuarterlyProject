public with sharing class VaccinationRegisterTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface {

    public void beforeInsert(List<SObject> triggerNew){}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}
    
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        VaccinationRegisterTriggerService.afterInsert((List<VaccinationRegister__c>)triggerNew);
    }

    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        VaccinationRegisterTriggerService.afterUpdate((List<VaccinationRegister__c>)triggerNew);
    }
    
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    
}