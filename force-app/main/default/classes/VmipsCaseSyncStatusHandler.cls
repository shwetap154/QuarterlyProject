/**
 * @description       : Class will revise the case sync status based on a related record changing
**/
public with sharing class VmipsCaseSyncStatusHandler {
    public static final String SYNC_SUCCESS = 'Synced Successfully with PV Works';
    public static final String SYNC_READY = 'Ready to Sync with PV Works';
    public static final String SYNC_IN_PROGRESS = 'Sync with PV Works in Progress';
    public static final String SYNC_UNAPPROVED = 'Unapproved';
    public static final String SYNC_REAPPROVAL = 'Re-Approval Needed';
    public static final String CASE_NOT_ELIGIBLE_FOR_PVW = 'This case is not eligible to receive updates in service cloud.  Please make any updates to this case directly in PV Works.';
    public static final Set<String> SUPPORTED_OBJECTS = new Set<String>{BatchDetailTriggerHandler.OBJECT_API_NAME,CSE_AssessmentTriggerHandler.OBJECT_API_NAME,
                                                                        CSE_CaseAnimalTriggerHandler.OBJECT_API_NAME,CSE_CaseContactTriggerHandler.OBJECT_API_NAME,
                                                                        CSE_CaseProductTriggerHandler.OBJECT_API_NAME,CSE_EventNarrativeTriggerHandler.OBJECT_API_NAME,
                                                                        CSE_VedDraEventTriggerHandler.OBJECT_API_NAME,ProductInvestigationTriggerHandler.OBJECT_API_NAME};

                                                                            
//This method is for updating the sync status to Re-ApprovalNeeded
//TPDEV-726 - Added by Shiva
public static void updateCaseSyncStatus(List <SObject> triggerRecords, Map <Id, SObject> triggerOldMap, String sObjectName, String caseLookupField, String caseRelationship, String parentLookupField, System.TriggerOperation triggerContext) {
    //caseId holds the id of the case 
    Set <Id> caseIds = new Set <Id> ();
    //recordId holds the triggered case related records(ex: Case Product/Case Patient  etc) Id
    Set <Id> recordIds = new Set <Id> ();
    for (SObject triggerRecord: triggerRecords) {
        recordIds.add(triggerRecord.Id);
    }
    Schema.DescribeSObjectResult objDescribe = triggerRecords.get(0).getSObjectType().getDescribe();
    String queryStr;
    //need to requery the record to ensure we always can get the case ID to attach the log to.

    if (string.IsNotBlank(caseLookupField)) {
        // TPDEV-726 added caseRelationship+.Sync_Status__c in querry 
  
        queryStr = 'SELECT Id ,' + caseLookupField +', '+caseRelationship+'.Sync_Status__c' ;
        if (string.IsNotBlank(parentLookupField)) {
            queryStr += ', ' + parentLookupField;
        }
        queryStr += ' FROM ' + sObjectName + ' WHERE Id =: recordIds ALL ROWS';
    }

    //Query the case Id from the Triggered records
    List <SObject> requeriedTriggerRecords = new List <SObject> ();
    List <Case> caseRecordsUpdateList = new List <Case> ();
    if (string.isNotBlank(queryStr)) {
        requeriedTriggerRecords = Database.query(queryStr);
        if (!requeriedTriggerRecords.isEmpty()) {
            for (SObject queryRecord: requeriedTriggerRecords) {       
                //TPDEV-726
                Case caseRecord = (Case)queryRecord.getSObject(caseRelationship);
               if( caseRecord.Sync_Status__c == SYNC_SUCCESS ||  caseRecord.Sync_Status__c == SYNC_IN_PROGRESS){
                Case cs = new Case();
                cs.Id = String.valueOf(queryRecord.get(caseLookupField));
                cs.Sync_Status__c = SYNC_REAPPROVAL;
                cs.Case_Updated_Date__c = system.now();
                caseRecordsUpdateList.add(cs);
                  
               }
            }
        }
        List <Database.Saveresult> results = new List <Database.Saveresult>();
        if (!caseRecordsUpdateList.isEmpty()) {
            try{
                results = Database.Update(caseRecordsUpdateList, false);
            }catch(DMLException e){
                ZTS_EU_Logger.error(results, 'VmipsCaseSyncStatusHandler-updateCaseSyncStatus');
            }
        }
    }

}
//TPDEV-726 - Code Ends here
                                                                            
    public static void checkCaseSendToPVWStatus(String objectName, String caseRelationship, Map<Id,SObject> triggerNewMap){
        if(!SUPPORTED_OBJECTS.contains(objectName)){
            return;
        }
        String recQuery;
        Set<Id> triggerKeySet = triggerNewMap.keySet();
        if(String.isNotBlank(objectName) && String.isNotBlank(caseRelationship) && triggerNewMap!=null && !triggerNewMap.isEmpty()){
            recQuery = 'SELECT Id, '+caseRelationship+'.Id, '+caseRelationship+'.Sync_Status__c, '+caseRelationship+'.PVW_External_ID__c';
            recQuery += ' FROM '+objectName+' WHERE id in:triggerKeySet AND '+caseRelationship+'.Sync_Status__c !=:SYNC_REAPPROVAL';
            recQuery += ' AND '+caseRelationship+'.Sync_Status__c != :SYNC_UNAPPROVED';
            recQuery += ' AND '+caseRelationship+'.RecordType.DeveloperName = \'Animal_Support\'';
        }
        system.debug('recQuery:'+recQuery);
        Case[] casesToUpdate = new Case[]{};
        if(String.isNotBlank(recQuery)){
            sObject[] recs = Database.query(recQuery);
            if(recs!=null && !recs.isEmpty()){
                Integer relationshipDepth = caseRelationship.countMatches('.');
                String lowestRelationship='';
                String middleRelationship='';
                String highestRelationship='';
                switch on relationshipDepth{
                    when 0{
                        highestRelationship = caseRelationship;
                    }
                    when 1{
                        lowestRelationship = caseRelationship.substringBefore('.');
                        highestRelationship = caseRelationship.substringAfter('.');
                    }
                    //implement this when there are records that are more than grandchildren from case
                    /*when 2{
                        lowestRelationship = caseRelationship.substringBefore('.');
                        highestRelationship = caseRelationship.substringAfterLast('.');
                        middleRelationship = caseRelationship.substringBetween(lowestRelationship+'.','.'+highestRelationship);
                    }*/
                }
                Boolean integrationBlockActive = false;
                Service_Cloud_Settings__mdt[] scs = Service_Cloud_Settings__mdt.getAll().values();
                if(scs[0].Block_VMIP_Integration_Created__c){
                    integrationBlockActive = true;
                }
                for(sObject record : recs){
                    Case caseToUpdate;
                    if(string.isNotBlank(lowestRelationship)){
                        SObject parentObject = record.getSObject(lowestRelationship);
                        caseToUpdate = (Case)parentObject.getSObject(highestRelationship);
                    }
                    else{
                        caseToUpdate = (Case)record.getSObject(highestRelationship);
                    }
                    if(caseToUpdate!=null && String.isNotBlank(caseToUpdate.PVW_External_ID__c)  && (integrationBlockActive || Test.isRunningTest())){
                        triggerNewMap.get(record.Id).addError(CASE_NOT_ELIGIBLE_FOR_PVW);
                    }
                    else if(caseToUpdate!=null){
                    caseToUpdate.Sync_Status__c = SYNC_REAPPROVAL;
                    caseToUpdate.Case_Updated_Date__c = system.now();
                    casesToUpdate.add(caseToUpdate);
                }
                    
                }
            }
        }

        if(!casesToUpdate.isEmpty()){
            try{
                update casesToUpdate;
            }
            catch(Exception e){
                ZTS_EU_Logger.error( 'Error updating case sync status: ' + e.getMessage(), null, 'VmipsCaseSyncStatusHandler.checkCaseSendToPVWStatus');
            }
        }
    }
    
   
    
}