/****************************************************************************************************************************************** 
 * Class Name   : CSE_EventNarrativeTriggerHandler
 * Description  : This class will handle all CSE_EventNarrativeTriggerHandler logic
 * Created By   : Slalom Consulting/Neil Kapoor
 * Created Date : September 19th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                  		  Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Neil Kapoor (Slalom)     		09/19/2021            Created
 * Madhu Goriparthi(Slalom) 		09/29/2021			  Modified
 * Venkat Joginapally(Slalom)		10/27/2021			  Updated to use Dispatch Trigger Handler
*****************************************************************************************************************************************/

public with sharing class CSE_EventNarrativeTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    public static final String OBJECT_API_NAME = 'ZTS_US_Event_Narrative__c';
    public static final String CASE_FIELD_API_NAME = 'ZTS_US_Case__c';
    
    @TestVisible private static final String VMIPS_CASE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Animal_Support' ).getRecordTypeId();
    @TestVisible private static final Set<String> REPORTABLE_CASE_TYPES = new Set<String>{ 'Animal Complaint', 'Human Exposure', 'Product Defect' };
    @TestVisible private static final String REQUIRED_FIELD_NULLED = 'The field {0} on {1} cannot be set to null when it\'s related Case has been sent to PV Works already.';

    public static void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        
        VMIPSCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'ZTS_US_Case__r',triggerNewMap);


        // Added this logic as a part of CSE-49(LongTextArea Field Audit)
        new CSE_LongTextAreaAuditTrailHelper().filterTextAreaChangedRecords(triggerNew, triggerOldMap, 'Long_Text_Area_Fields');
        //lookup field on event narrative to case is set via a flow, need this to execute after that lookup is filled in.  allowing trigger recursion for this
        //operation to run after flow update
        /*CSE_EventNarrativeTriggerHandler enHandler = new CSE_EventNarrativeTriggerHandler();
        DispatchTriggerHandler.setRecursionContexts(enHandler);*/
        AuditAndSequenceHelper.checkUpdatedRecords(triggerNew,triggerOldMap, OBJECT_API_NAME,CASE_FIELD_API_NAME,null,Trigger.operationType); 
    }
    
    public static void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        validateFieldUpdatesForPVWorks( (List<ZTS_US_Event_Narrative__c>) triggerNew, (Map<Id, ZTS_US_Event_Narrative__c>) triggerOldMap );
        Set<ZTS_US_Event_Narrative__c> eventNarrativesForTemplateCheck = new Set<ZTS_US_Event_Narrative__c>();
        for(ZTS_US_Event_Narrative__c objEventNarrative : (List<ZTS_US_Event_Narrative__c>) triggerNew){
            ZTS_US_Event_Narrative__c oldEventNarrative = (ZTS_US_Event_Narrative__c)triggerOldMap.get(objEventNarrative.Id);
            if(oldEventNarrative != null && oldEventNarrative.ZTS_US_Event_Narrative_Summary_Field__c != objEventNarrative.ZTS_US_Event_Narrative_Summary_Field__c){
                eventNarrativesForTemplateCheck.add(objEventNarrative);
            }
        }
        if(!eventNarrativesForTemplateCheck.isEmpty()){
            CSE_EventNarrativesController.updateEventNarrative(eventNarrativesForTemplateCheck);
        }
    }

    @TestVisible
    private static void validateFieldUpdatesForPVWorks( List<ZTS_US_Event_Narrative__c> triggerNew, Map<Id, ZTS_US_Event_Narrative__c> triggerOldMap )
    {
        // lets get the related case records - we have query cases where the event narrative ids are in trigger new
        List<Case> queriedCases = [ SELECT Id, 
                                           ZTS_US_Event_Narrative__c,
                                           RecordTypeId, 
                                           Type, 
                                           Sync_Status__c
                                            FROM Case 
                                            WHERE ZTS_US_Event_Narrative__c IN :triggerNew 
                                            AND RecordTypeId = :VMIPS_CASE_RT_ID
                                            AND Type IN :REPORTABLE_CASE_TYPES 
                                            AND Sync_Status__c != :VmipsCaseSyncStatusHandler.SYNC_UNAPPROVED ];

        // lets group the cases by event narrative id 
        Map<Id, List<Case>> narrativeIdToCases = new Map<Id, List<Case>>();
        Set<String> fieldSetFields;
        if(queriedCases!=null && !queriedCases.isEmpty()){
            Map<String, Set<String>> fieldSetFieldsMap = SL_CaseTriggerHelper.retrieveApprovalFieldsFromMetadata( queriedCases[0].Type, null );
            fieldSetFields = fieldSetFieldsMap.get( OBJECT_API_NAME );
            
            for ( Case aCase : queriedCases )
            {
                List<Case> relatedCases = narrativeIdToCases.containsKey( aCase.ZTS_US_Event_Narrative__c ) 
                                                ? narrativeIdToCases.get( aCase.ZTS_US_Event_Narrative__c )
                                                : new List<Case>();

                relatedCases.add( aCase );
                narrativeIdToCases.put( aCase.ZTS_US_Event_Narrative__c, relatedCases );
            }
        }
        
        // now lets iterate over trigger new 
        for ( ZTS_US_Event_Narrative__c aNarrative : triggerNew )
        {
            // lets check to see if we have to check the fields to see if they've been nulled out
            if ( narrativeIdToCases!=null && narrativeIdToCases.containsKey( aNarrative.Id ) && fieldSetFields!=null)
            {
                // lets get the old values
                ZTS_US_Event_Narrative__c oldNarrativeRecord = triggerOldMap.get( aNarrative.Id );

                // lets iterate over the field set
                for ( String fieldAPIName : fieldSetFields )
                {
                    if ( aNarrative.get( fieldAPIName ) != oldNarrativeRecord.get( fieldAPIName ) && aNarrative.get( fieldAPIName ) == null )
                    {
                        aNarrative.addError( String.format( REQUIRED_FIELD_NULLED, new List<String>{ fieldAPIName, aNarrative.Name } ) );
                    }
                }
            }
        }
    }
    
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerNew,null, OBJECT_API_NAME,CASE_FIELD_API_NAME,null,Trigger.operationType);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerOld, triggerOldMap,OBJECT_API_NAME,CASE_FIELD_API_NAME,null,Trigger.operationType);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeInsert(List<SObject> triggerNew) {}
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}

}