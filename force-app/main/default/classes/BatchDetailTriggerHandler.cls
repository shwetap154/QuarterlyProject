public with sharing class BatchDetailTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface
{   
    public boolean inFutureContext = false;
    public static final String OBJECT_API_NAME = 'Batch_Detail__c';
    public static final String CASE_LOOKUP_FIELD = 'Case__c';
    public static final String PARENT_LOOKUP_FIELD = 'ZTS_US_Case_Product__c';


    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        BatchDetailTriggerHelper.afterUpdate(triggerNew, (Map<Id, Batch_Detail__c>) triggerOldMap);
        VmipsCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'ZTS_US_Case_Product__r.ZTS_US_Case__r',triggerNewMap);
                 
    }

    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        BatchDetailTriggerHelper.afterInsert(triggerNew);
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerNew,null, OBJECT_API_NAME,CASE_LOOKUP_FIELD,PARENT_LOOKUP_FIELD,Trigger.operationType);
        VmipsCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'ZTS_US_Case_Product__r.ZTS_US_Case__r',triggerNewMap);                        
    }

    public void beforeInsert(List<SObject> triggerNew)
    {
        BatchDetailTriggerHelper.beforeInsert(triggerNew);            
        AuditAndSequenceHelper.createSequenceForObject(triggerNew,OBJECT_API_NAME, CASE_LOOKUP_FIELD,PARENT_LOOKUP_FIELD);
    } 
    
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        BatchDetailTriggerHelper.afterDelete(triggerOld);
        //per ravi 6.24, sequence for batch will be by case as parent, not by product
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerOld,triggerOldMap, OBJECT_API_NAME,CASE_LOOKUP_FIELD,PARENT_LOOKUP_FIELD,Trigger.operationType); 
    }

    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        BatchDetailTriggerHelper.beforeUpdate(triggerOld, (Map<Id, Batch_Detail__c>) triggerOldMap, triggerNew, (Map<Id, Batch_Detail__c>) triggerNewMap);
    }

    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap)
    {
        BatchDetailTriggerHelper.beforeDelete(triggerOld);
    }

}