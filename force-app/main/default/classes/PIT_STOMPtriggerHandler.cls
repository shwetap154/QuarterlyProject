public without sharing class PIT_STOMPtriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface   
{

    public void beforeInsert(List<SObject> triggerNew) 
    {
        PIT_STOMP_TriggerService.setOwnerManager(triggerNew);
    }

    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        PIT_STOMP_TriggerService.setOwnerManager(triggerNew);
    }

    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}
    
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap){}
    
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap){}
    
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}

    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}

}