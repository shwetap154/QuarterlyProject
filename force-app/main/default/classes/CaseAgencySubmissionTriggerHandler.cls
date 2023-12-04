public with sharing class CaseAgencySubmissionTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface
{
    public static final String OBJECT_API_NAME = 'ZTS_US_Case_Agency_Submission__c';
    public static final String CASE_LOOKUP_FIELD = 'Case__c';

    public static void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
    }

    public static void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerNew,null, OBJECT_API_NAME,CASE_LOOKUP_FIELD,null,Trigger.operationType);            
    }

    public static void beforeInsert(List<SObject> triggerNew)
    {
    } 
    
    public static void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerOld,triggerOldMap, OBJECT_API_NAME,CASE_LOOKUP_FIELD,null,Trigger.operationType);            
    }

    public static void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
    }

    public static void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    
    public static void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap)
    {
    }
}