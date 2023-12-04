public with sharing class ZTS_US_Education_BackgroundTrigHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  {
    
    public void beforeInsert(List<SObject> triggerNew){
        System.debug('$$$ Inside Handler - trigger New value '+triggerNew);
        ZTS_US_Education_BackgroundTrigService.beforeInsert((List<ZTS_US_Education_Background__c>)triggerNew);
    }
    
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        
    }
    
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){
        ZTS_US_Education_BackgroundTrigService.beforeDelete((List<ZTS_US_Education_Background__c>)triggerOld, (Map<Id,ZTS_US_Education_Background__c>)triggerOldMap);
    }
    
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        ZTS_US_Education_BackgroundTrigService.afterInsert((List<ZTS_US_Education_Background__c>)triggerNew, (Map<Id,ZTS_US_Education_Background__c>) triggerNewMap);
    }

    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        ZTS_US_Education_BackgroundTrigService.afterUpdate((List<ZTS_US_Education_Background__c>)triggerNew, (Map<Id,ZTS_US_Education_Background__c>)triggerNewMap, (Map<Id,ZTS_US_Education_Background__c>)triggerOldMap);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}