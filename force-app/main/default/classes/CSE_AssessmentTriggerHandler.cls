/****************************************************************************************************************************************** 
 * Class Name   : CSE_AssessmentTriggerHandler
 * Description  : This trigger will handle all AssessmentTrigger logic
 * Created By   : Slalom Consulting/Neil Kapoor
 * Created Date : September 14th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                			Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Neil Kapoor(Slalom)     			   09/14/2021          Created
 * Venkat Joginapally(Slalom)		   10/27/2021		   Modified to call handler using Dispatch Trigger Handler
*****************************************************************************************************************************************/

public with sharing class CSE_AssessmentTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    public static final String OBJECT_API_NAME = 'ZTS_US_Assessment__c';
    public static final String CASE_FIELD_API_NAME = 'ZTS_US_Case__c';
    
    public static final String localAssessmentRT = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByName().get('Local Assessment').getRecordTypeId();

    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        validateFieldUpdatesForPVWorks( (List<ZTS_US_Assessment__c>) triggerNew, (Map<Id, ZTS_US_Assessment__c>) triggerOldMap );
        //CaseAgencyAssessmentValidation.getAssessmentRecords((List<ZTS_US_Assessment__c>) triggerNew, (Map<Id, ZTS_US_Assessment__c>) triggerNewMap, (Map<Id, ZTS_US_Assessment__c>) triggerOldMap);           

    }

    @TestVisible
    private static void validateFieldUpdatesForPVWorks( List<ZTS_US_Assessment__c> triggerNew, Map<Id, ZTS_US_Assessment__c> triggerOldMap )
    {
        // lets call the function that handles the validation
        SL_CaseTriggerHandler.validateRelatedRecordsForSendingToPVWorks( triggerNew, triggerOldMap, CASE_FIELD_API_NAME );
    }
    
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerNew, null, OBJECT_API_NAME,CASE_FIELD_API_NAME,null,Trigger.operationType); 
        VmipsCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'ZTS_US_Case__r',triggerNewMap);
        
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        // Added this logic as a part of CSE-49(LongTextArea Field Audit)
        new CSE_LongTextAreaAuditTrailHelper().filterTextAreaChangedRecords(triggerNew, triggerOldMap, 'Long_Text_Area_Fields');
        VmipsCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'ZTS_US_Case__r',triggerNewMap);
        
    }
	public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerOld,triggerOldMap, OBJECT_API_NAME,CASE_FIELD_API_NAME,null,Trigger.operationType);  
        
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeInsert(List<SObject> triggerNew) {
        //sequence only needs to be generated for local assessments.
        Sobject[] recordsForSequence = new Sobject[]{};
        for(Sobject triggerRec : triggerNew){
            if((String)triggerRec.get('RecordTypeId') == localAssessmentRT){
                recordsForSequence.add(triggerRec);
            }
        }
        if(!recordsForSequence.isEmpty()){
            AuditAndSequenceHelper.createSequenceForObject(recordsForSequence,OBJECT_API_NAME, CASE_FIELD_API_NAME);
        }
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){}
}