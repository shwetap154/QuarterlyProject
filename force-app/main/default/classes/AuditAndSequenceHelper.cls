/*
    This class will create audit logs attached to the parent case for a given case related record.  For records that have a parent in between,
    the parentLookupField can be filled with a formula field on the object that looks up to the corresponding case id.

    This class will create a sequence based on these permanent audit log records.  Sequencing generally works in increment of 1 based on a given object
    as it relates to the case.  Product investigation also needs a suffix which is relative to the specific investigation type for a given batch detail

*/
public without sharing class AuditAndSequenceHelper {
    public static void checkUpdatedRecords(List<SObject> triggerNew,Map<Id, SObject> triggerOldMap, String sObjectName, String caseLookupField, String parentLookupField, System.TriggerOperation triggerContext){
        SObject[] recordsParentChanged = new SObject[]{};
        
        for(SObject newRec : triggerNew){
            Id recordId = (Id)newRec.get('Id');
            SObject oldRec = triggerOldMap.get(recordId);
            if((Id)newRec.get(caseLookupField)!= (Id)oldRec.get(caseLookupField)){
                recordsParentChanged.add(newRec);
            }
        }
        //if being called from before trigger, record parent changed and the sequence needs to be redone
        if(!recordsParentChanged.isEmpty() && triggerContext == System.TriggerOperation.BEFORE_UPDATE){
            createSequenceForObject(recordsParentChanged,sObjectName,caseLookupField,parentLookupField,false);
        }
        //if being called from after trigger, audit log needs to be created for new parent
        else if(!recordsParentChanged.isEmpty() && triggerContext == System.TriggerOperation.AFTER_UPDATE){
            createAuditLogForCaseRelatedRecords(recordsParentChanged,triggerOldMap, sObjectName,caseLookupField,parentLookupField,triggerContext);
        }
    }

    public static void createAuditLogForCaseRelatedRecords(List<SObject> triggerRecords, Map<Id, SObject> triggerOldMap, String sObjectName, String caseLookupField, String parentLookupField, System.TriggerOperation triggerContext)
    {
        //caseId holds the id of the case 
        Set<Id> caseIds = new Set<Id>();
        //recordId holds the triggered case related records(ex: Case Product/Case Patient  etc) Id
        Set<Id> recordIds = new Set<Id>();

        for(SObject triggerRecord: triggerRecords){
            recordIds.add(triggerRecord.Id);
        }
        
        Schema.DescribeSObjectResult objDescribe = triggerRecords.get(0).getSObjectType().getDescribe();
        String queryStr;
        //need to requery the record to ensure we always can get the case ID to attach the log to.
        if(string.IsNotBlank(caseLookupField)){
            queryStr = 'SELECT Id ,'+caseLookupField;
            if(string.IsNotBlank(parentLookupField)){
                queryStr += ', '+parentLookupField;
            }
            queryStr += ' FROM ' + sObjectName + ' WHERE Id =: recordIds ALL ROWS';

        }
        

        //Query the case Id from the Triggered records
        List<SObject> requeriedTriggerRecords = new List<SObject>();
        Map<Id,Case> caseMap;
        if(string.isNotBlank(queryStr)){
            try{
                requeriedTriggerRecords = Database.query(queryStr);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            if(!requeriedTriggerRecords.isEmpty()){
                for(SObject queryRecord: requeriedTriggerRecords){
                    Id caseId = String.valueOf(queryRecord.get(caseLookupField));
                    caseIds.add(caseId);
                }
            }
            caseMap = new Map<Id,Case>([SELECT Id , ZTS_EU_PV_Works__c 
                                    FROM Case 
                                    WHERE Id in :caseIds]);
        }

        if(caseMap != null && !caseMap.isEmpty())
        {
            ZTS_US_CSE_Audit_Trail__c[] newAuditTrails = new ZTS_US_CSE_Audit_Trail__c[]{};
            //iterate over all trigger records, setting audit log fields based on attributes of the operation
            for(SObject triggerRecord:triggerRecords)
            {
                ZTS_US_CSE_Audit_Trail__c newAuditTrail = new ZTS_US_CSE_Audit_Trail__c();
                Id caseId = (String.valueOf(triggerRecord.get(caseLookupField)));
                Case recordCase = caseMap.get(caseId);
                newAuditTrail.Case__c = caseId;
                newAuditTrail.Record_Id__c = triggerRecord.Id;
                newAuditTrail.Object_Name__c = sObjectName;
                newAuditTrail.Object_Label__c = objDescribe.getLabel();

                //only audit logs with this flag will get picked up by PVW in the importer
                if(String.IsNotBlank(recordCase.ZTS_EU_PV_Works__c)){
                    newAuditTrail.Audit_Flag__c = True;
                }

                Id parentRecordId;
                if(String.isNotBlank(parentLookupField)){
                    parentRecordId = String.valueOf(triggerRecord.get(parentLookupField));
                }
                else{
                    parentRecordId = caseId;
                }
                newAuditTrail.Parent_Record_Id__c = parentRecordId;

                newAuditTrail.Trigger_Operation__c = String.valueOf(triggerContext);
                //new sequences are assigned in the before trigger.  in the after trigger, get the sequence that was assigned
                //copy that to the audit log to store a permanent history of what sequences were already used.
                //that way, even if a record is deleted, the audit log will persist with the sequence, as sequences cannot be reused.
                if(triggerContext == System.TriggerOperation.AFTER_INSERT){
                    newAuditTrail.New_Value__c = 'Record was inserted';
                    try{
                        newAuditTrail.Sequence_Number__c = Integer.valueOf(triggerRecord.get('Sequence__c'));
                    }
                    catch(exception e){
                        system.debug(sObjectName+' does not have a sequence field or a sequence number'+e);
                    }
                    try{
                        newAuditTrail.Suffix__c = (String)triggerRecord.get('Suffix__c');
                    }
                    catch(exception e){
                        system.debug(sObjectName+' does not have a suffix field or a suffix value');
                    }
                    try{
                        newAuditTrail.Investigation_Type__c = (String)triggerRecord.get('ZTS_US_Investigation_Type__c');
                    }
                    catch(exception e){
                        system.debug(sObjectName+' does not have an investigation type field or a suffix value');
                    }
                }
                else if (triggerContext == System.TriggerOperation.AFTER_DELETE){
                    newAuditTrail.New_Value__c = 'Record was deleted';
                }
                //if the record was reparented or the sequence was updated from a merge, note that.  when records are reparented, they are reassigned a sequence
                //in the before update trigger.  make sure the audit log reflects the new sequence assigned.
                else if (triggerContext == System.TriggerOperation.AFTER_UPDATE){
                    Id recordId = (Id)triggerRecord.get('Id');
                    SObject oldRecord = (triggerOldMap!=null?triggerOldMap.get(recordId):null);
                    String parentField = (String.IsNotBlank(parentLookupField) ? parentLookupField : caseLookupField);
                    
                    newAuditTrail.New_Value__c = 'Record Resequenced because of Merge';
                    try{
                        newAuditTrail.Sequence_Number__c = Integer.valueOf(triggerRecord.get('Sequence__c'));
                    }
                    catch(exception e){
                        system.debug(sObjectName+' does not have a sequence field or a sequence value:'+e);
                    }
                    try{
                        newAuditTrail.Suffix__c = (String)triggerRecord.get('Suffix__c');
                    }
                    catch(exception e){
                        system.debug(sObjectName+' does not have a suffix field or a suffix value');
                    }
                    try{
                        newAuditTrail.Investigation_Type__c = (String)triggerRecord.get('ZTS_US_Investigation_Type__c');
                    }
                    catch(exception e){
                        system.debug(sObjectName+' does not have an investigation type field or a suffix value');
                    }
                }
                newAuditTrails.add(newAuditTrail);
            }
            
            insert newAuditTrails;
        }
    }
    //TO DO, change the spots that call these methods, remove the overload
    public static void createSequenceForObject(Sobject[] triggerRecords,String objectName, String caseRelationshipField){
        createSequenceForObject(triggerRecords,objectName,caseRelationshipField,null,false);
    }
    public static void createSequenceForObject(Sobject[] triggerRecords,String objectName, String caseRelationshipField, String parentRelationshipField){
        createSequenceForObject(triggerRecords,objectName,caseRelationshipField,parentRelationshipField,false);
    }
    /**
     * Method to sequence case related records that are not locked.  lock happens when record is approved for send to pv.
     * @param Sobject[] triggerRecords - records that need sequence
     * @param String    objectName - api name of object that needs sequence
     * @param String    caseRelationshipField - object's lookup field to the case, can also be a formula field looking up to case if not a direct child
     * @param String    parentRelationshipField - relationship field for direct parent of the trigger record, only used when not a direct child of case.
     * @param Boolean   updateNeeded - when called from manual case merge, dml will be needed, otherwise, before trigger will allow update
     * 
     * @return null
     * 
     */
    public static void createSequenceForObject(Sobject[] triggerRecords,String objectName, String caseRelationshipField, String parentRelationshipField, Boolean updateNeeded){
        string sObjectType = String.valueOf(triggerRecords[0].getSObjectType());
        Set<Id> caseIds = new Set<Id>();
        for(sObject triggerRecord: triggerRecords){
            if(String.IsNotBlank(caseRelationshipField)){
                Id caseId = (Id)triggerRecord.get(caseRelationshipField);
                if(!caseIds.contains(caseId)){
                    caseIds.add(caseId);
                }
            }
        }
        //the starting sequence and suffix will be incremented later when they are accessed, ending up as 1 and A
        //or the highest existing sequence/suffix + 1
        Map<String,Integer> startingSequenceNumberToParentId = new Map<String,Integer>();
        Integer startingSequenceNumber = 0;
        String startingSuffixLetter = 'Z';
        //keys will be parent record(batch detail)+investigation type to make a unique key per suffix
        Map<String,String> batchTypeToSuffixMap = new Map<String,String>();
        ZTS_US_CSE_Audit_Trail__c[] permanentAuditTrails = [ SELECT ID,Sequence_Number__c,Suffix__c,Parent_Record_Id__c,Investigation_Type__c
                                                            FROM ZTS_US_CSE_Audit_Trail__c
                                                            WHERE Case__c in: caseIds 
                                                            AND Object_Name__c = :sObjectType
                                                            AND Sequence_Number__c != null
                                                            ORDER BY Sequence_Number__c DESC];                                                   
        
        //sequence should always be +1 from the last highest on the case
        if(permanentAuditTrails!=null && !permanentAuditTrails.isEmpty() && permanentAuditTrails[0].Sequence_Number__c != null && parentRelationshipField == null){
            startingSequenceNumber = (Integer)permanentAuditTrails[0].Sequence_Number__c;
        }
        else if(permanentAuditTrails!=null && !permanentAuditTrails.isEmpty() && parentRelationshipField != null){
            for(ZTS_US_CSE_Audit_Trail__c auditRec : permanentAuditTrails){
        //in addition to sequence, need to generate a suffix for product investigation, 
        //format is A1,A2 if multiple investigations on a given lot/serial/diluent.
        //if multiple investigations across multiple lot/serial/diluent, format is A1,B1,C1 where the letter represents the individual lot/serial/diluent
        //investigation type field on audit log will read either lot or serial or diluent.
                if(sObjectType == ProductInvestigationTriggerHandler.OBJECT_API_NAME){
                if(String.isNotBlank(auditRec.Investigation_Type__c) && String.isNotBlank(auditRec.Parent_Record_Id__c)){
                    String mapKey = auditRec.Investigation_Type__c+auditRec.Parent_Record_Id__c;
                    if(!batchTypeToSuffixMap.containsKey(mapKey)){
                        batchTypeToSuffixMap.put(mapKey,auditRec.Suffix__c);
                    }
                }
                    startingSequenceNumber = (Integer)permanentAuditTrails[0].Sequence_Number__c;
                }
                //need to track the highest sequence number per parent to account for non-direct children of the case. 
                //i.e batch detail sequence is per case product, not per case.  investigation is excluded from this rule, it rolls up to case.
                else if(!startingSequenceNumberToParentId.containsKey(auditRec.Parent_Record_Id__c)){
                    startingSequenceNumberToParentId.put(auditRec.Parent_Record_Id__c,(Integer)auditRec.Sequence_Number__c);
                }
            }
        }
        sObject[] recordsToUpdate = new sObject[]{};
        for(sObject triggerRecord: triggerRecords){
            if(parentRelationshipField!=null && (String)triggerRecord.get(parentRelationshipField) != null && !startingSequenceNumberToParentId.isEmpty()){
                String parentRecordId = (String)triggerRecord.get(parentRelationshipField);
                if(startingSequenceNumberToParentId.containsKey(parentRecordId)){
                    startingSequenceNumber = startingSequenceNumberToParentId.get(parentRecordId) + 1;
                    startingSequenceNumberToParentId.put(parentRecordId,startingSequenceNumber);
                }
                else{
                    startingSequenceNumber = startingSequenceNumber+1;
                }
            }
            else{
                startingSequenceNumber = startingSequenceNumber+1;
            }
            system.debug('startingSequenceNumber:'+startingSequenceNumber);

            
            Boolean recordUpdated = false;
            if(triggerRecord.get('Sequence__c') != String.valueOf(startingSequenceNumber) && ((String)triggerRecord.get('Sequence__c') == null || updateNeeded || (String)triggerRecord.getCloneSourceId()!=null)){
                triggerRecord.put('Sequence__c',String.valueOf(startingSequenceNumber));
                system.debug('putting sequence: '+startingSequenceNumber);
                recordUpdated = true;
            }
            //start of suffix increment for product investigation
            if(sObjectType == ProductInvestigationTriggerHandler.OBJECT_API_NAME && ((String)triggerRecord.get('Suffix__c') == null || updateNeeded)){
                String investigationType = (String)triggerRecord.get('ZTS_US_Investigation_Type__c');
                String parentRecordId = (String)triggerRecord.get(parentRelationshipField);
                //mapKey is investigationType(Lot,Serial,Diluent)+parentRecordId
                String mapKey = (String.IsNotBlank(investigationType) && String.IsNotBlank(parentRecordId) ? investigationType + parentRecordId : null);
                String newSuffix;
                //existing investigation for the given key, need to increment the number
                if(mapKey!=null && batchTypeToSuffixMap.containsKey(mapKey)){
                    String existingSuffix = batchTypeToSuffixMap.get(mapKey);
                    startingSuffixLetter = existingSuffix.left(1);
                    Integer numSeq = Integer.valueOf(existingSuffix.substring(1, existingSuffix.length()));
                    newSuffix = startingSuffixLetter+String.valueOf(numSeq+1);
                }
                //no existing investigation for the given key, need to increment the letter
                else if(mapKey!=null && !batchTypeToSuffixMap.containsKey(mapKey)){
                    String newSuffixLetter;
                    //if there are existing investigations, just not a match for the current one,
                    //get the highest existing suffix letter, then take the one that comes next and assign it
                    if(!batchTypeToSuffixMap.isEmpty()){
                        String[] allSuffixes = batchTypeToSuffixMap.values();
                        allsuffixes.sort();
                        Integer lastIndex = allSuffixes.size()-1;
                        String highestSuffix = allsuffixes[lastIndex];
                        String highestSuffixLetter = highestSuffix.left(1);
                        newSuffixLetter = getNextAlphabetChar(highestSuffixLetter);
                    }
                    //if there are no investigations at all and this is the first, take the initial starting letter (Z),
                    //then increment it to A, that is the starting point
                    else{
                        newSuffixLetter = getNextAlphabetChar(startingSuffixLetter);
                    }
                    startingSuffixLetter = newSuffixLetter;
                    newSuffix = newSuffixLetter+'1';
                }
                //once the new suffix has been determined, add it to the record and to the map being used to keep track of what exists already
                if(mapKey!=null && String.isNotBlank(newSuffix) && triggerRecord.get('Suffix__c') !=newSuffix){
                    triggerRecord.put('Suffix__c',newSuffix);
                    batchTypeToSuffixMap.put(mapKey,newSuffix);
                    recordUpdated = true;
                }
            }
            if(updateNeeded && recordUpdated){
                recordsToUpdate.add(triggerRecord);
            }
        }
        if(!recordsToUpdate.isEmpty()){
            try{
                update recordsToUpdate;
            }
            catch(Exception e){
                ZTS_EU_Logger.error( 'Error updating sequence: ' + e.getMessage(), null, 'AuditAndSequenceHelper.createSequenceForObject');
            }
        }
    }
    //A is at the end of this list so that it wraps around from Z->A
    public static String getNextAlphabetChar(String currentChar){
        String key = 'ABCDEFGHIJKLMNOPQRSTUVWXYZA';
        Integer index = key.indexOfChar(currentChar.charAt(0));
        return index == -1? null: key.substring(index+1, index+2);
    }
    /**
     * Method to resquence all case related records that are not locked.  lock happens when record is approved for send to pv.
     * @param Id survivingCaseId - Case ID with all the records that need to be resequenced
     * 
     * @return null
     * 
     */
    @future
    public static void mergeResequenceFuture(Id survivingCaseId){        
        //requery case with all related records that need to be resequenced
        //veddra event and batch detail need to be queried separately, they are not direct children of case
        Case parentCase = [ SELECT  ID,
                            (SELECT Id,Object_Name__c,Record_Id__c FROM CSE_Audit_Trails__r WHERE Sequence_Lock__c = false),
                            (SELECT Id,Case__c,Sequence__c FROM Case_Contacts__r ORDER BY Id ASC),
                            (SELECT Id,ZTS_US_Case__c,Sequence__c FROM Case_Products__r ORDER BY Id ASC),
                            (SELECT Id,ZTS_US_Case__c,Sequence__c FROM Assessments__r WHERE RecordTypeId = :CSE_AssessmentTriggerHandler.localAssessmentRT ORDER BY Id ASC),
                            (SELECT Id,ZTS_US_Case__c,ZTS_US_Batch_Detail__c,ZTS_US_Investigation_Type__c,Sequence__c,Suffix__c FROM Product_Investigations__r ORDER BY Id ASC)
                            FROM    Case
                            WHERE   Id = :survivingCaseId
                            LIMIT   1];

        ZTS_US_VedDRA_Event__c[] veddraEvents = [SELECT Id,Case__c,Sequence__c FROM ZTS_US_VedDRA_Event__c WHERE Case__c = :survivingCaseId ORDER BY Id ASC];
        Batch_Detail__c[] batchDetails = [SELECT Id,Case__c,ZTS_US_Case_Product__c,Sequence__c FROM Batch_Detail__c WHERE Case__c = :survivingCaseId ORDER BY Id ASC];

        //take all the audit logs returned, organize by object name and all the records we'll need to filter out from the subqueries above
        Map<String,Set<Id>> recordIdsToResequenceByObjectName = new Map<String,Set<Id>>();
        for(ZTS_US_CSE_Audit_Trail__c auditTrail : parentCase.CSE_Audit_Trails__r){
            if(!recordIdsToResequenceByObjectName.containsKey(auditTrail.Object_Name__c)){
                recordIdsToResequenceByObjectName.put(auditTrail.Object_Name__c,new Set<Id>{auditTrail.Record_Id__c});
            }
            else{
                Set<Id> idsAlreadyInMap = recordIdsToResequenceByObjectName.get(auditTrail.Object_Name__c);
                idsAlreadyInMap.add(auditTrail.Record_Id__c);
                recordIdsToResequenceByObjectName.put(auditTrail.Object_Name__c,idsAlreadyInMap);
            }
        }
        //it is important to delete these audit trail records to make sure the sequencing will start off from the last record that isn't locked, or 1 if none exist.
        delete parentCase.CSE_Audit_Trails__r;
        //Resequence Case Contacts
        if(parentCase.Case_Contacts__r != null && !parentCase.Case_Contacts__r.isEmpty()){
            sObject[] recordsToResequence = getRecordsToResequence(CSE_CaseContactTriggerHandler.OBJECT_API_NAME,parentCase.Case_Contacts__r,recordIdsToResequenceByObjectName);
            if(!recordsToResequence.isEmpty()){
                createSequenceForObject(recordsToResequence,CSE_CaseContactTriggerHandler.OBJECT_API_NAME, CSE_CaseContactTriggerHandler.CASE_FIELD_API_NAME, null, true);
                createAuditLogForCaseRelatedRecords(recordsToResequence,null, CSE_CaseContactTriggerHandler.OBJECT_API_NAME,CSE_CaseContactTriggerHandler.CASE_FIELD_API_NAME,null,System.TriggerOperation.AFTER_UPDATE); 
            }
        }
        //Resequence Case Products
        if(parentCase.Case_Products__r != null && !parentCase.Case_Products__r.isEmpty()){
            sObject[] recordsToResequence = getRecordsToResequence(CSE_CaseProductTriggerHandler.OBJECT_API_NAME,parentCase.Case_Products__r,recordIdsToResequenceByObjectName);
            if(!recordsToResequence.isEmpty()){
                createSequenceForObject(recordsToResequence,CSE_CaseProductTriggerHandler.OBJECT_API_NAME, CSE_CaseProductTriggerHandler.CASE_FIELD_API_NAME, null, true);
                createAuditLogForCaseRelatedRecords(recordsToResequence,null, CSE_CaseProductTriggerHandler.OBJECT_API_NAME,CSE_CaseProductTriggerHandler.CASE_FIELD_API_NAME,null,System.TriggerOperation.AFTER_UPDATE);
            } 
        }
        //Resequence Local Assessment
        if(parentCase.Assessments__r != null && !parentCase.Assessments__r.isEmpty()){
            sObject[] recordsToResequence = getRecordsToResequence(CSE_AssessmentTriggerHandler.OBJECT_API_NAME,parentCase.Assessments__r,recordIdsToResequenceByObjectName);
            if(!recordsToResequence.isEmpty()){
                createSequenceForObject(recordsToResequence,CSE_AssessmentTriggerHandler.OBJECT_API_NAME, CSE_AssessmentTriggerHandler.CASE_FIELD_API_NAME, null, true);
                createAuditLogForCaseRelatedRecords(recordsToResequence,null, CSE_AssessmentTriggerHandler.OBJECT_API_NAME,CSE_AssessmentTriggerHandler.CASE_FIELD_API_NAME,null,System.TriggerOperation.AFTER_UPDATE);
            } 
        }
        //Resequence Product Investigation
        if(parentCase.Product_Investigations__r != null && !parentCase.Product_Investigations__r.isEmpty()){
            sObject[] recordsToResequence = getRecordsToResequence(ProductInvestigationTriggerHandler.OBJECT_API_NAME,parentCase.Product_Investigations__r,recordIdsToResequenceByObjectName);
            if(!recordsToResequence.isEmpty()){
                createSequenceForObject(recordsToResequence,ProductInvestigationTriggerHandler.OBJECT_API_NAME, ProductInvestigationTriggerHandler.CASE_FIELD_API_NAME, ProductInvestigationTriggerHandler.BATCH_DETAIL_LOOKUP, true);
                createAuditLogForCaseRelatedRecords(recordsToResequence,null, ProductInvestigationTriggerHandler.OBJECT_API_NAME,ProductInvestigationTriggerHandler.CASE_FIELD_API_NAME,ProductInvestigationTriggerHandler.BATCH_DETAIL_LOOKUP,System.TriggerOperation.AFTER_UPDATE);

            } 
        }

        if(veddraEvents != null && !veddraEvents.isEmpty()){
            sObject[] recordsToResequence = getRecordsToResequence(CSE_VedDraEventTriggerHandler.OBJECT_API_NAME,veddraEvents,recordIdsToResequenceByObjectName);
            if(!recordsToResequence.isEmpty()){
                createSequenceForObject(recordsToResequence,CSE_VedDraEventTriggerHandler.OBJECT_API_NAME, CSE_VedDraEventTriggerHandler.CASE_FIELD_API_NAME, null, true);
                createAuditLogForCaseRelatedRecords(recordsToResequence,null, CSE_VedDraEventTriggerHandler.OBJECT_API_NAME,CSE_VedDraEventTriggerHandler.CASE_FIELD_API_NAME,null,System.TriggerOperation.AFTER_UPDATE);

            } 
        }

        if(batchDetails != null && !batchDetails.isEmpty()){
            sObject[] recordsToResequence = getRecordsToResequence(BatchDetailTriggerHandler.OBJECT_API_NAME,batchDetails,recordIdsToResequenceByObjectName);
            if(!recordsToResequence.isEmpty()){
                createSequenceForObject(recordsToResequence,BatchDetailTriggerHandler.OBJECT_API_NAME, BatchDetailTriggerHandler.CASE_LOOKUP_FIELD, null, true);
                createAuditLogForCaseRelatedRecords(recordsToResequence,null, BatchDetailTriggerHandler.OBJECT_API_NAME,BatchDetailTriggerHandler.CASE_LOOKUP_FIELD,BatchDetailTriggerHandler.PARENT_LOOKUP_FIELD,System.TriggerOperation.AFTER_UPDATE);
            } 
        }
    }
    /**
     * Method to get all records from a given object that need to be resequenced
     * @param Id objectName - API name of object being evaluated
     * @param Id recordList - All related records of the object type from the case, these need to be filtered based on what is in the map
     * @param Id recordIdsToResequenceByObjectName - map of objectName to all records that did not have a locked audit record.
     * 
     * @return List of filtered sobjects to be resequenced
     * 
     */
    public static sObject[] getRecordsToResequence(String objectName,sObject[] recordList,Map<String,Set<Id>> recordIdsToResequenceByObjectName){
        Set<Id> recordIdsToResequence = (recordIdsToResequenceByObjectName.containsKey(objectName) 
                                                ? recordIdsToResequenceByObjectName.get(objectName) : null);
        sObject[] recordsToResequence = new sObject[]{};
        if(recordIdsToResequence!=null){
            for(sObject record : recordList){
                if(recordIdsToResequence.contains((String)record.get('Id'))){
                    recordsToResequence.add(record);
                }
            }
        }
        return recordsToResequence;
    }

    /* Per ravi this was scrapped, they are trying to find a solution on the pvw side.  Was asked to save this just in case.
        The idea was that documents needed a unique name AND a sequence custom field on document could not be used.  Generate a similar sequence
        and prepend that to the doc name.
    public static void sequenceDocuments(ContentDocumentLink[] contentDocumentLinks){
        String vmipRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        Set<Id> caseIdsToCheck = new Set<Id>();
        
        String insertType = String.valueOf(System.TriggerOperation.AFTER_INSERT);
        
        for(ContentDocumentLink docLink : contentDocumentLinks){
            if(String.valueOf(docLink.LinkedEntityId).startsWith('005') && !caseIdsToCheck.contains(docLink.LinkedEntityId)){
                caseIdsToCheck.add(docLink.LinkedEntityId);
            }
        }
        Map<Id,Case> vmipCaseMap;
        if(!caseIdsToCheck.isEmpty()){
            vmipCaseMap = new Map<Id,Case>([    SELECT Id,
                                                    (SELECT ID,Sequence__c
                                                    FROM CSE_Audit_Trails__r
                                                    WHERE Trigger_Operation__c = :insertType
                                                    AND Object_Name__c = 'ContentDocument'
                                                    ORDER BY Sequence__c DESC)
                                                FROM Case 
                                                WHERE Id in: caseIdsToCheck AND RecordTypeId = :vmipRecordTypeId]);
        }
        Map<Id,Id> contentDocIdToCaseId = new Map<Id,Id>();
        for(ContentDocumentLink docLink : contentDocumentLinks){
            if(vmipCaseMap.containsKey(docLink.LinkedEntityId) && !contentDocIdToCaseId.containsKey(docLink.LinkedEntityId)){
                Case vmipCase = vmipCaseMap.get(docLink.LinkedEntityId);
                contentDocIdToCaseId.put(docLink.LinkedEntityId,vmipCase.Id);
            }
        }
        ContentVersion[] contentVersForSequence = [ SELECT id,ContentDocumentId,title,Sequence__c 
                                                    FROM ContentVersion
                                                    WHERE ContentDocumentId in: contentDocIdToCaseId.keySet()];
        //TO DO, how do we increment the counter and then write it back?
        Integer startingSequenceNumber = 1;
        Map<id,Integer> sequenceForCaseId = new Map<Id,Integer>();
        if(!contentVersForSequence.isEmpty()){
            for(ContentVersion version : contentVersForSequence){
                Case vmipCase = vmipCaseMap.get(version.ContentDocumentId);
                if(!vmipCase.CSE_Audit_Trails__r.isEmpty() && !sequenceForCaseId.containsKey(vmipCase.Id)){
                    startingSequenceNumber = Integer.valueOf(vmipCase.CSE_Audit_Trails__r[0].Sequence__c);
                    startingSequenceNumber++;
                    sequenceForCaseId.put(vmipCase.Id,startingSequenceNumber);
                }
                else if(!vmipCase.CSE_Audit_Trails__r.isEmpty() && sequenceForCaseId.containsKey(vmipCase.Id)){
                    startingSequenceNumber = sequenceForCaseId.get(vmipCase.Id);
                    startingSequenceNumber++;
                }
                system.debug('sequence for case '+vmipCase.Id+': '+startingSequenceNumber);
                version.Sequence__c = String.valueOf(startingSequenceNumber);
                version.title = String.valueOf(startingSequenceNumber)+'_'+version.title;
            }
            update contentVersForSequence;
        }
        
    }*/
}