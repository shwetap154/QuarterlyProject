public with sharing class ProductInvestigationTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface{  
       
    public static final String OBJECT_API_NAME = 'ZTS_US_Product_Investigation__c';
    public static final String CASE_FIELD_API_NAME = 'ZTS_US_Case__c';
    public static final String BATCH_DETAIL_LOOKUP = 'ZTS_US_Batch_Detail__c';

    public static void beforeInsert(List<SObject> triggerNew) 
    {
        AuditAndSequenceHelper.createSequenceForObject(triggerNew,OBJECT_API_NAME, CASE_FIELD_API_NAME,BATCH_DETAIL_LOOKUP);
    }
    public static void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public static void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public static void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerNew, null, OBJECT_API_NAME,CASE_FIELD_API_NAME,BATCH_DETAIL_LOOKUP,Trigger.operationType);
    }
    public static void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        Map<Id,SObject> recsToCheckCaseStatus = new Map<Id,SObject>();
        for(ZTS_US_Product_Investigation__c newRec : (List<ZTS_US_Product_Investigation__c>) triggerNew){
            ZTS_US_Product_Investigation__c oldRec = (ZTS_US_Product_Investigation__c)triggerOldMap.get(newRec.Id);
            //PVW is only going to pick up investigations where this flag is set.  Don't tell the user to initiate PVW validation until they mark the investigation
            //as ready for PVW
            if(newRec.Send_to_PV_Works__c && !oldRec.Send_to_PV_Works__c){
                recsToCheckCaseStatus.put(newRec.Id,newRec);
            }
        }
        if(!recsToCheckCaseStatus.isEmpty()){
            VMIPSCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'ZTS_US_Case__r',recsToCheckCaseStatus);
        }
    }
    public static void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerOld, triggerOldMap, OBJECT_API_NAME,CASE_FIELD_API_NAME,BATCH_DETAIL_LOOKUP,Trigger.operationType); 
    }
    public static void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}    


}