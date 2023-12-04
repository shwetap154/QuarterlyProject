public with sharing class ZTS_GL_ZipToBrickHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  {
    
    public void beforeInsert(List<SObject> triggerNew){

        ZTS_GL_ZipToBrickService.beforeInsert((List<ZTS_GL_ZipToBrick__c>)triggerNew);
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        
        if(!UtilityService.stopUpdateZip)
            ZTS_GL_ZipToBrickService.beforeUpdate((List<ZTS_GL_ZipToBrick__c>)triggerNew, (List<ZTS_GL_ZipToBrick__c>)triggerOld, (Map<Id,ZTS_GL_ZipToBrick__c>)triggerOldMap);
    }

    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
}