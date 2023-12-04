/****************************************************************************************************************************************** 
 * Class Name   : CSE_VedDraEventTriggerHandler
 * Description  : This class will handle all CSE_VedDraEventTrigger logic
 * Created By   : Slalom Consulting/ Jyothsna Jogi
 * Created Date : September 20th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer               				  Date                Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Jyothsna Jogi      12/16/2021              Created
 * Sai Saranya        9/14/2023               updated the beforeInsert and beforeUpdate as part of TPDEV-1932
*****************************************************************************************************************************************/
public with sharing class CSE_VedDraEventTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface {

    public static final String OBJECT_API_NAME = 'ZTS_US_VedDRA_Event__c';
    public static final String CASE_FIELD_API_NAME = 'Case__c';

    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {

        // Added this logic as a part of CSE-49(LongTextArea Field Audit)
        new CSE_LongTextAreaAuditTrailHelper().filterTextAreaChangedRecords(triggerNew, triggerOldMap, 'Long_Text_Area_Fields');
        VMIPSCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'ZTS_US_Event_Narrative__r.ZTS_US_Case__r',triggerNewMap);
    }

    public static void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerNew, null, OBJECT_API_NAME,CASE_FIELD_API_NAME,null,Trigger.operationType);
        
        VMIPSCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'ZTS_US_Event_Narrative__r.ZTS_US_Case__r',triggerNewMap);
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap){
        ValidateVeddraEventBeforeInsert.validateVeddraEvent(triggerNew, triggerOldMap);
    }
	public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerOld, triggerOldMap,OBJECT_API_NAME,CASE_FIELD_API_NAME,null,Trigger.operationType);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeInsert(List<SObject> triggerNew) {
        AuditAndSequenceHelper.createSequenceForObject(triggerNew,OBJECT_API_NAME,CASE_FIELD_API_NAME);
        ValidateVeddraEventBeforeInsert.validateVeddraEvent(triggerNew, null);
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
}