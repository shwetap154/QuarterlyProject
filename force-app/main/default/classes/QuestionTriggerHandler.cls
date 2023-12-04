public with sharing class QuestionTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  {
    
    public void beforeInsert(List<SObject> triggerNew){}
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        QuestionTriggerService.afterUpdate((List<Question>)triggerOld, (Map<Id, Question>)triggerOldMap, (List<Question>)triggerNew, (Map<Id, Question>) triggerNewMap);
    }
    
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}