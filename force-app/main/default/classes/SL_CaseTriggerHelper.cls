public with sharing class SL_CaseTriggerHelper 
{
    public static final String EVENT_NARRATIVE_DUPLICATE_ON_CASE = 'Case #{0} references the following event narrative that is used on another Case: {1}';
	public static final String ANIMAL_COMPLAINT = 'Animal Complaint';
    public static final String HUMAN_EXPOSURE = 'Human Exposure';
    public static final String PRODUCT_DEFECT = 'Product Defect';
    public static final String INQUIRY = 'Inquiry';
    public static final String VEDRA_CLASS_A ='A';
    public static final String VEDRA_CLASS_H ='H';
    public static final String VEDRA_CLASS_C ='C';   
	public static Map<String, Set<String>> productTypeMap= new Map<String, Set<String>>{
        ANIMAL_COMPLAINT => new Set<String>{'(Associated) Product Defect',
            								  'Adverse Reaction',
											  'Ecotoxicity',
											  'Lack of Efficacy',
            								  'Residue Violation',
											  INQUIRY	},
         PRODUCT_DEFECT => new Set<String>{'(Associated) Product Defect'},
         HUMAN_EXPOSURE => new Set<String>{'(Associated) Product Defect','Human Exposure - Asymptomatic','Human Exposure - Symptomatic'},
         INQUIRY => new Set<String>{INQUIRY}
    };
    
    /**
     * Helper method to generically retrieve fields for approval
     * @param String approvalType - set of strings storing the sobject names
     * 
     * @return Map<Schema.SObjectType, Set<String>> - return map of sobject name => set of fields from metadata
     */
    public static Map<String, Set<String>> retrieveApprovalFieldsFromMetadata( String approvalType , String recordTypeFilter )
    {  
        Map<String, Set<String>> sObjTypeToValidationFieldsMap = new Map<String, Set<String>>();
        String metaDataIdentifierField;
        String cacheKey;
            
        if(approvalType == 'Animal Complaint'){
            metaDataIdentifierField = 'AC_Validation_Check__c';
            cacheKey = 'ACValidationCheck';
        }else if(approvalType == 'Human Exposure'){
            metaDataIdentifierField = 'HE_Validation_Check__c';
            cacheKey = 'HEValidationCheck';
        }else if(approvalType == 'Product Defect'){
            metaDataIdentifierField = 'PD_Validation_Check__c';
            cacheKey = 'PDValidationCheck';
        }
        else{
            system.debug('SL_CaseTriggerHelper.retrieveApprovalFieldsFromMetadata Case Type does not have validation setup in metadata: '+approvalType);
            return null;
        }
        //see if the cache already has the fields stored so we won't need to query for them
        Map<String, Set<String>> cachedMap = (Map<String, Set<String>>)Cache.Org.get(cacheKey);
        if(cachedMap!=null && !cachedMap.isEmpty()){
            return cachedMap;
        }
        VMIPS_Validation_Helper__mdt[] allValidationMetadata = VMIPS_Validation_Helper__mdt.getAll().values();
        String[] metaDataFieldDurableIds = new String[]{};
        String[] compoundFields = new String[]{};
        //if the fields in the metadata match the case type, add the 'field name' to a list to query.  
        //The value stored in the field name is actually the durable ID of the field(objectId.fieldId)
        //compound metadata field relationships store the string path so we don't need to retrieve those.
        for(VMIPS_Validation_Helper__mdt metaDataRow : allValidationMetadata){
            Boolean fieldIsValid = ((Boolean)metaDataRow.get(metaDataIdentifierField)==true ? true : false);
            Boolean recordTypeIsValid = (recordTypeFilter == null || (metaDataRow.Record_Type_Filter__c == 'Both')  || (recordTypeFilter != null && recordTypeFilter == metaDataRow.Record_Type_Filter__c));
                
            if(fieldIsValid && recordTypeIsValid){
                    if(String.isNotBlank(metaDataRow.Field_Name__c)){
                        metaDataFieldDurableIds.add(metaDataRow.Field_Name__c);
                    }
                    else if(String.isNotBlank(metaDataRow.Compound_Field_Name__c)){
                        compoundFields.add(metaDataRow.Compound_Field_Name__c);
                    }
            }
        }
        //field describe doesn't have a method to get field ID so we have to query the field definition table to match the ID stored in the metadata to a field API name.
        //unfortunately the developer name found in the fieldDefinition query doesn't contain __c and doesn't have a way to know if a field is custom or not.
        //querying to get the field by ID and then have to do a describe to get a name that is usable by code without translation.
        FieldDefinition[] fields = [SELECT  id, DurableId,DataType,NamespacePrefix, DeveloperName,EntityDefinition.QualifiedAPIName 
                                    FROM    FieldDefinition 
                                    WHERE   DurableId in :metaDataFieldDurableIds];
        system.debug('fields=' + fields);
        Map<String,Set<String>> fieldsByObjectName = new Map<String,Set<String>>();
        //for each field returned, build map of object->set of fields.
        for(FieldDefinition fieldDef : fields){
            String objectName = fieldDef.EntityDefinition.QualifiedAPIName;
            String fieldName;
            Set<String> allObjectFields;
            if(!fieldsByObjectName.containsKey(objectName)){
                Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
                allObjectFields = objectType.getDescribe().fields.getMap().keySet();
                //put the list of fields into a map so the describe doesn't get done over and over for every field
                fieldsByObjectName.put(objectName,allObjectFields);
            }
            else{
                allObjectFields = fieldsByObjectName.get(objectName);
            }
            //this will be a problem if there's a custom field and a standard field in the metadata for a given object that have the same name. i.e. Name__c and Name
            //convert developerName to lowercase because field describe stores them that way
            if(allObjectFields!= null && allObjectFields.contains(fieldDef.DeveloperName.toLowerCase()+'__c')){
                fieldName = fieldDef.DeveloperName+'__c';
            }
            else if(allObjectFields!= null && allObjectFields.contains(fieldDef.DeveloperName.toLowerCase())){
                fieldName = fieldDef.DeveloperName;
            }
            
            if(sObjTypeToValidationFieldsMap.containsKey(objectName) && String.isNotBlank(fieldName)){
                Set<String> fieldsForObject = sObjTypeToValidationFieldsMap.get(objectName);
                fieldsForObject.add(fieldName);
                sObjTypeToValidationFieldsMap.put(objectName,fieldsForObject);
            }
            else if(String.isNotBlank(fieldName)){
                sObjTypeToValidationFieldsMap.put(objectName,new Set<String>{fieldName});
            }
            else{
                system.debug('SL_CaseTriggerHelper.retrieveApprovalFieldsFromMetadata unable to validate '+fieldDef.DeveloperName);
            }
            system.debug('sObjTypeToValidationFieldsMap=' + sObjTypeToValidationFieldsMap);
        }
        //example Contact.Name.LastName, Contact.MailingAddress.MailingCountry - strip out the object and compound field api name and add to map
        for(String compoundField : compoundFields){
            String objectName = compoundField.left(compoundField.indexOf('.'));
            String fieldName = compoundField.right((compoundField.length()-1)-compoundField.lastIndexOf('.'));
            if(String.isBlank(objectName) || String.isBlank(fieldName)){
                system.debug('SL_CaseTriggerHelper.retrieveApprovalFieldsFromMetadata cannot parse compound field');
                continue;
            }
            if(sObjTypeToValidationFieldsMap.containsKey(objectName)){
                Set<String> fieldsForObject = sObjTypeToValidationFieldsMap.get(objectName);
                fieldsForObject.add(fieldName);
                sObjTypeToValidationFieldsMap.put(objectName,fieldsForObject);
            }
            else{
                sObjTypeToValidationFieldsMap.put(objectName,new Set<String>{fieldName});
            }
        }
        
        //drop the map into the cache to avoid reprocessing every time a user hits this method since the metadata won't change often. 
        //Don't do this for the assessment because it will change depending on assessment record type and mess up the cache
        if(!Test.isRunningTest() && sObjTypeToValidationFieldsMap != null && !sObjTypeToValidationFieldsMap.isEmpty() && recordTypeFilter == null){
            try{
                Cache.Org.put(cacheKey,sObjTypeToValidationFieldsMap);
            }
            catch(exception e){
                system.debug('SL_CaseTriggerHelper.retrieveApprovalFieldsFromMetadata unable to cache fieldset map');
            }
        }
        return sObjTypeToValidationFieldsMap;
    }

    // Method for getting all relevant fields from all field sets for Case Product.  
    // This would be used in SL_CaseTriggerHandler line ~1088. To replace this line : "Set<String> productFields = fieldSets.get('ZTS_US_Case_Product__c');"
    public static Set<String> getAllRelevantCaseProductFields() {
        Set<String> completeFieldNameSet = new Set<String>();
        Set<String> acZTSFieldNameSet = convertFieldListToStringSet(Schema.SObjectType.ZTS_US_Case_Product__c.fieldSets.AC_ZTS_Validation_Check.getFields());
        Set<String> acNonZTSFieldNameSet = convertFieldListToStringSet(Schema.SObjectType.ZTS_US_Case_Product__c.fieldSets.AC_Non_ZTS_Validation_Check.getFields());
        Set<String> heZTSFieldNameSet = convertFieldListToStringSet(Schema.SObjectType.ZTS_US_Case_Product__c.fieldSets.HE_ZTS_Validation_Check.getFields());
        Set<String> heNonZTSFieldNameSet = convertFieldListToStringSet(Schema.SObjectType.ZTS_US_Case_Product__c.fieldSets.HE_Non_ZTS_Validation_Check.getFields());

        // No duplicates in Sets
        completeFieldNameSet.addAll(acZTSFieldNameSet);
        completeFieldNameSet.addAll(acNonZTSFieldNameSet);
        completeFieldNameSet.addAll(heZTSFieldNameSet);
        completeFieldNameSet.addAll(heNonZTSFieldNameSet);

        return completeFieldNameSet;
    }

    // Method to validate related Case Products based on parent Case.Type, and Case Product record type. Variables for all 4 potential field sets have to be 
    // hardcoded, and that is done inside this method. This method leverages existing functionality of SL_CaseTriggerHandler.validateRelatedRecordsForApproval(),
    // but offers extra funcitonality for Case Products only.
    public static void validateRelatedCaseProductsForApproval(Case aCase, List<ZTS_US_Case_Product__c> caseProdList,Map<Id, List<String>> idToCustomErrorMessages ) { //, Map<String, Set<String>> fieldSetNameToFieldsMap) {
        
        String ZTS_RECORDTYPE = 'Zoetis_Product';
        String NON_ZTS_RECORDTYPE = 'Non_Zoetis_Product';
        
        List<FieldSetMember> acZTSFieldSet = Schema.SObjectType.ZTS_US_Case_Product__c.fieldSets.AC_ZTS_Validation_Check.getFields();
        List<FieldSetMember> acNonZTSFieldSet = Schema.SObjectType.ZTS_US_Case_Product__c.fieldSets.AC_Non_ZTS_Validation_Check.getFields();
        List<FieldSetMember> heZTSFieldSet = Schema.SObjectType.ZTS_US_Case_Product__c.fieldSets.HE_ZTS_Validation_Check.getFields();
        List<FieldSetMember> heNonZTSFieldSet = Schema.SObjectType.ZTS_US_Case_Product__c.fieldSets.HE_Non_ZTS_Validation_Check.getFields();

        if (aCase.Type == 'Animal Complaint') {
            for (ZTS_US_Case_Product__c caseProd : caseProdList){
                if (caseProd.RecordType.DeveloperName == ZTS_RECORDTYPE) {
                    Set<String> fieldNameSet = convertFieldListToStringSet(acZTSFieldSet);
                    // SL_CaseTriggerHandler.validateRelatedRecordsForApproval(aCase, new List<ZTS_US_Case_Product__c>{caseProd}, fieldNameSet);
                    VmipsCaseService.validateRelatedRecordsForApproval(aCase, new List<ZTS_US_Case_Product__c>{caseProd}, fieldNameSet, idToCustomErrorMessages);
                } else if (caseProd.RecordType.DeveloperName == NON_ZTS_RECORDTYPE) {
                    Set<String> fieldNameSet = convertFieldListToStringSet(acNonZTSFieldSet);
                    VmipsCaseService.validateRelatedRecordsForApproval(aCase, new List<ZTS_US_Case_Product__c>{caseProd}, fieldNameSet,idToCustomErrorMessages);
                    // SL_CaseTriggerHandler.validateRelatedRecordsForApproval(aCase, new List<ZTS_US_Case_Product__c>{caseProd}, fieldNameSet);
                }
            }
        } else if (aCase.Type == 'Human Exposure') {
            for (ZTS_US_Case_Product__c caseProd : caseProdList){
                if (caseProd.RecordType.DeveloperName == ZTS_RECORDTYPE) {
                    Set<String> fieldNameSet = convertFieldListToStringSet(heZTSFieldSet);
                    // SL_CaseTriggerHandler.validateRelatedRecordsForApproval(aCase, new List<ZTS_US_Case_Product__c>{caseProd}, fieldNameSet);
                    VmipsCaseService.validateRelatedRecordsForApproval(aCase, new List<ZTS_US_Case_Product__c>{caseProd}, fieldNameSet, idToCustomErrorMessages);
                } else if (caseProd.RecordType.DeveloperName == NON_ZTS_RECORDTYPE) {
                    Set<String> fieldNameSet = convertFieldListToStringSet(heNonZTSFieldSet);
                    VmipsCaseService.validateRelatedRecordsForApproval(aCase, new List<ZTS_US_Case_Product__c>{caseProd}, fieldNameSet, idToCustomErrorMessages);
                    // SL_CaseTriggerHandler.validateRelatedRecordsForApproval(aCase, new List<ZTS_US_Case_Product__c>{caseProd}, fieldNameSet);
                }
            }
        }
        
    }

    public static Set<String> convertFieldListToStringSet(List<FieldSetMember> fieldSetFields) {
        Set<String> fieldNameSet = new Set<String>();
        for (Schema.FieldSetMember field : fieldSetFields) {
            fieldNameSet.add(field.getFieldPath());
        }
        return fieldNameSet;
    }



    public static void preventEventNarrativeReparenting( List<Case> filteredCases )
    {
        // lets break if we don't have any filtered cases
        if ( filteredCases == null || filteredCases.isEmpty() )
        {
            return;
        }

        // lets iterate over filtered cases to pluck out the narrative ids
        Set<Id> eventNarrativeIds = new Set<Id>();
        for ( Case aCase : filteredCases )
        {
            if ( !eventNarrativeIds.contains( aCase.ZTS_US_Event_Narrative__c ) )
            {
                eventNarrativeIds.add( aCase.ZTS_US_Event_Narrative__c );
            }
            else 
            {
                // if we actually see this event narrative id in this set already, we should error that case out
                aCase.addError( String.format( EVENT_NARRATIVE_DUPLICATE_ON_CASE, new List<String>{ aCase.CaseNumber, aCase.ZTS_US_Event_Narrative__c } ) );
            }
        }

        // if we don't have narrative ids, lets break out of this function
        if ( eventNarrativeIds.isEmpty() )
        {
            return;
        }

        // lets query other cases that use these narrative ids
        List<Case> relatedCases = [ SELECT Id, 
                                           ZTS_US_Event_Narrative__c 
                                        FROM Case 
                                        WHERE ZTS_US_Event_Narrative__c IN :eventNarrativeIds 
                                            AND Id NOT IN :filteredCases ];

        // if we didn't find any related cases, we can break out of this
        if ( relatedCases.isEmpty() )
        {
            return;
        }
        
        // lets pluck out the event narrative ids from the queried list
        Set<Id> relatedEventNarrativeIds = new Set<Id>();
        for ( Case relatedCase : relatedCases )
        {
            relatedEventNarrativeIds.add( relatedCase.ZTS_US_Event_Narrative__c );
        }

        // lets iterate over the cases and determine if we need to add an error for a duplicate error
        for ( Case aCase : filteredCases )
        {
            if ( relatedEventNarrativeIds.contains( aCase.ZTS_US_Event_Narrative__c ) )
            {
                aCase.addError( String.format( EVENT_NARRATIVE_DUPLICATE_ON_CASE, new List<String>{ aCase.CaseNumber, aCase.ZTS_US_Event_Narrative__c } ) );
            }
        }

    }

    /**
     * helper method to filter out cases on insert for event narratives
     * 
     * @param List<Case> triggerNew Trigger new list of Cases
     * 
     * @return List<Case> filtered cases that meet criteria and have an event narrative
     */
    public static List<Case> filterNewCasesForEventNarratives( List<Case> triggerNew )
    {
        // lets declare our return list
        List<Case> filteredCases = new List<Case>();

        Id vmipsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Animal_Support' ).getRecordTypeId(); 
        
        for ( Case aCase : triggerNew )
        {
            if ( aCase.RecordTypeId == vmipsCaseRecordTypeId && 
                 aCase.ZTS_US_Event_Narrative__c != null )
            {
                filteredCases.add( aCase );
            }
        }

        return filteredCases;
    }


    /**
     * Helper method to filter out cases that have an event narrative change
     * @param List<Case> triggerNew Trigger new list of cases
     * @param Map<Id, Case> triggerOldMap Trigger old map of cases
     * 
     * @return List<Case> filtered cases that have a changed event narrative (that is not null)
     * 
     */
    public static List<Case> filterCasesForEventNarrativeChanges( List<Case> triggerNew, Map<Id, Case> triggerOldMap )
    {
        // lets declare our return list
        List<Case> filteredCases = new List<Case>();

        Id vmipsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Animal_Support' ).getRecordTypeId(); 
        

        // lets iterate over the cases 
        for ( Case aCase : triggerNew )
        {
            Case oldCase = triggerOldMap.get( aCase.Id );
            if ( aCase.RecordTypeId == vmipsCaseRecordTypeId &&
                 aCase.ZTS_US_Event_Narrative__c != oldCase.ZTS_US_Event_Narrative__c && 
                 aCase.ZTS_US_Event_Narrative__c != null )
            {
                filteredCases.add( aCase );
            }
        }

        return filteredCases;
    }
    
     /* To validate child records on Case type change
     * Created By: Ravikanth Donthula
     * CSEPVW-181 */
    
    
    public static void validateRelatedRecordsOnTypeChange( Set<Id> caseIds, Map<Id, Case> newCases )
    {
        //Loading Related Products
        List<ZTS_US_Case_Product__c> caseProducts = [select ZTS_US_Case__c,ZTS_US_PVW_Product__c,ZTS_US_Product_Role__c,ZTS_US_Start_Date__c,
														ZTS_US_Product_Used_Correctly__c,ZTS_US_Product_problem_type__c,ZTS_US_End_Date__c,
                                              			RecordType.DeveloperName,ZTS_US_Misuse_Types__c from ZTS_US_Case_Product__c where ZTS_US_Case__c =:caseIds];
        List<ZTS_US_VedDRA_Event__c> vedraEvents  = [SELECT ID,ZTS_US_VedDRA_Coding__r.ZTS_US_VEDDRA_Class__c,ZTS_US_Event_Narrative__r.ZTS_US_Case__c FROM ZTS_US_VedDRA_Event__c 
                                                     	WHERE ZTS_US_Event_Narrative__c IN ( 
            											SELECT ID FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Case__c IN : caseIds )];
        List<ZTS_US_Case_Animal__c> casePatients  =	[select id,RecordType.DeveloperName,ZTS_US_Case__c from ZTS_US_Case_Animal__c 
                                                   		where ZTS_US_Case__c =:caseIds];
        
 
        //Case Product Validations CSEPVW-181
        for(ZTS_US_Case_Product__c c :caseProducts){
            
            if(newCases.get(c.ZTS_US_Case__c).Type == ANIMAL_COMPLAINT || newCases.get(c.ZTS_US_Case__c).Type == HUMAN_EXPOSURE || newCases.get(c.ZTS_US_Case__c).Type == PRODUCT_DEFECT){
                
                if((!productTypeMap.get(newCases.get(c.ZTS_US_Case__c).Type).contains(c.ZTS_US_Product_problem_type__c))){
                    newCases.get(c.ZTS_US_Case__c).addError('Invalid Product Problem Type on Case Product');
                }
    
                if(c.RecordType.DeveloperName =='Zoetis_Product' && ( newCases.get(c.ZTS_US_Case__c).Type == ANIMAL_COMPLAINT || newCases.get(c.ZTS_US_Case__c).Type == HUMAN_EXPOSURE)
                && c.ZTS_US_Product_Used_Correctly__c == 'No' && String.isBlank(c.ZTS_US_Misuse_Types__c)){
                    newCases.get(c.ZTS_US_Case__c).addError('Case Product : Product Used Correctly? Must always have a value. If value = No, a misuse type must be populated');
                }
                
                if(c.ZTS_US_Start_Date__c == null && c.ZTS_US_End_Date__c != null && newCases.get(c.ZTS_US_Case__c).Type != PRODUCT_DEFECT){
                    newCases.get(c.ZTS_US_Case__c).addError('Case Product : Please enter the Dose Start Date');
                }
			}
        }     
                
        //Veddra_Check_for_Animal_Complaint && HUMAN_EXPOSURE
        for(ZTS_US_VedDRA_Event__c ve:vedraEvents){
            if(newCases.get(ve.ZTS_US_Event_Narrative__r.ZTS_US_Case__c).Type == ANIMAL_COMPLAINT && 
               (ve.ZTS_US_VedDRA_Coding__r.ZTS_US_VEDDRA_Class__c != VEDRA_CLASS_A && ve.ZTS_US_VedDRA_Coding__r.ZTS_US_VEDDRA_Class__c != VEDRA_CLASS_C)){
                newCases.get(ve.ZTS_US_Event_Narrative__r.ZTS_US_Case__c).addError('Invalid Veddra Code for Animal Complaint Cases');
			}
            if(newCases.get(ve.ZTS_US_Event_Narrative__r.ZTS_US_Case__c).Type == HUMAN_EXPOSURE && (ve.ZTS_US_VedDRA_Coding__r.ZTS_US_VEDDRA_Class__c != VEDRA_CLASS_H && ve.ZTS_US_VedDRA_Coding__r.ZTS_US_VEDDRA_Class__c != VEDRA_CLASS_C)){
                newCases.get(ve.ZTS_US_Event_Narrative__r.ZTS_US_Case__c).addError('Invalid Veddra Code for Human Exposure Cases');
			}
		}
        
    }
    /**
     * Helper method to handle records that have been merged
     * @param List<Case> list of cases from trigger that have merged.
     * 
     * @return null
     * 
     */
    public static void handleManualCaseMerge(Case[] triggerCases)
    {
        system.debug('in manual case merge');
        Id survivingCaseId;
        
        // lets iterate over the cases 
        for (Case triggerCase : triggerCases){
            //cases sent to pv works cannot be a 'losing' merge record
            if(triggerCase.MasterRecordId != null && triggerCase.Sync_Status__c != null && triggerCase.Sync_Status__c != VmipsCaseSyncStatusHandler.SYNC_UNAPPROVED)
            {
                //throw apex exception
                triggerCase.addError('Case '+triggerCase.CaseNumber+' has previously been marked Ready to Send to PV Works.  Cases marked as such cannot be merged into other cases.');
                return;
            }
            //get the parent(surviving) case ID to find related records as well as when the merge happened
            else if(triggerCase.MasterRecordId != null && survivingCaseId == null){
                survivingCaseId = triggerCase.MasterRecordId;
            }
        }
        if(survivingCaseId == null){
            system.debug('SL_CaseTriggerHelper.handleManualCaseMerge no surviving case found, something is not right');
            return;
        }
        //due to a data load issue, some cases have ccpr in which the amount is in USD but the ISO Code is not.  Update the Iso Code to match without changing the value
        ZTS_US_CCPR__c[] ccprs = [  SELECT      Id, Name, ZTS_US_Amount__c, ZTS_US_Currency__c, CurrencyIsoCode, ZTS_US_Case__c,CreatedDate,LastModifiedDate
                                    FROM        ZTS_US_CCPR__c 
                                    WHERE       ZTS_US_Case__c = :survivingCaseId
                                    AND         CurrencyIsoCode != 'USD'
                                    ORDER BY    LastModifiedDate ASC];
        
        
        if(ccprs != null && !ccprs.isEmpty()){
            for(ZTS_US_CCPR__c ccpr : ccprs){
                ccpr.CurrencyIsoCode = 'USD';
                ccpr.ZTS_US_Currency__c = 'US Dollars';
            }
            try{
                update ccprs;
            }
            catch(Exception e){
                ZTS_EU_Logger.error( 'Error updating CCPR: ' + e.getMessage(), null, 'SL_CaseTriggerHelper.handleManualCaseMerge');
            }
        }

        ZTS_US_Event_Narrative__c[] survivingENs =  [   SELECT      Id, ZTS_US_Case__c,ZTS_US_Case__r.ZTS_US_Event_Narrative__c
                                                        FROM        ZTS_US_Event_Narrative__c 
                                                        WHERE       ZTS_US_Case__c = :survivingCaseId];
        //if there are more than one event narratives after the merge we need to delete any that are not the same as the one in the lookup on the case
        if(survivingENs!=null && survivingENs.size() > 1){
            ZTS_US_Event_Narrative__c[] extraENs = new ZTS_US_Event_Narrative__c[]{};
            for(ZTS_US_Event_Narrative__c survivingEN: survivingENs){
                if(survivingEN.ZTS_US_Case__r.ZTS_US_Event_Narrative__c != survivingEN.Id){
                    extraENs.add(survivingEN);
                }
            }
            if(!extraENs.isEmpty()){
                try{
                    delete extraENs;
                }
                catch(Exception e){
                    ZTS_EU_Logger.error( 'Error deleting extra event narratives on merge: ' + e.getMessage(), null, 'SL_CaseTriggerHelper.handleManualCaseMerge');
                }
            }
        }

        AuditAndSequenceHelper.mergeResequenceFuture(survivingCaseId);
        
        Case_Contact__c[] caseContacts = [  SELECT  	Id, Name, ZTS_US_Contact_Role__c, Primary__c, Contact__c,
                                                    	ZTS_US_Primary_Reporter__c,CreatedDate,LastModifiedDate
                                            FROM    	Case_Contact__c
                                            WHERE   	Case__c = :survivingCaseId
                                            AND     	(Primary__c = TRUE OR ZTS_US_Primary_Reporter__c = TRUE)
            								ORDER BY	CreatedDate DESC];
        
        if(caseContacts != null && !caseContacts.isEmpty()){
            Case_Contact__c firstCaseContact = caseContacts.remove(0);
            Set<Id> caseContactIdsToUpdate = new Set<Id>();
            for(Case_Contact__c caseContact : caseContacts){
                caseContactIdsToUpdate.add(caseContact.Id);
            }
            if(!caseContactIdsToUpdate.isEmpty()){
                handleCaseContactMergeFuture(caseContactIdsToUpdate);
            }
        }
    }
    
    /**
     * Future Method to update case contacts since it is called from case before trigger.  Seems that updating case contact tries to update the case so needed
     * to put the update in a future method to avoid recurision errors
     * @param Set<Id> caseContactIds, all case contacts to update
     * 
     * @return null
     * 
     */
    @future
    public static void handleCaseContactMergeFuture(Set<Id> caseContactIds)
    {
        Case_Contact__c[] caseContactsToUpdate = new Case_Contact__c[]{};
        for(Id caseContactId : caseContactIds){
            Case_Contact__c caseContact = new Case_Contact__c
            (
                Id = caseContactId,
                Primary__c = false,
                ZTS_US_Primary_Reporter__c = false
            );
            caseContactsToUpdate.add(caseContact);
        }
        try{
            update caseContactsToUpdate;
        }
        catch(Exception e){ 
            ZTS_EU_Logger.error( 'Error updating case contacts: ' + e.getMessage(), null, 'SL_CaseTriggerHelper.handleCaseContactMergeFuture');
        }
    }
    /**
     * Method to validate cases that can or cannot be 'erred'(Cancelled)
     * @param Case[] triggerCases, all cases from trigger whose status have been set to cancelled
     * 
     * @return null
     * 
     */
    public static void checkCaseErr(Map<Id,Case> triggerCaseMap){
        Boolean hasErrPermission = FeatureManagement.checkPermission('PVWCaseAgencyErrAbility');

        ZTS_US_Case_Agency_Submission__c[] agencySubmissions = [SELECT Id,Case__c FROM ZTS_US_Case_Agency_Submission__c WHERE Case__c in : triggerCaseMap.keySet()];
        Set<Id> caseIdsWithAgencySubmission = new Set<Id>();
        if(agencySubmissions!=null && !agencySubmissions.isEmpty()){
            for(ZTS_US_Case_Agency_Submission__c submission : agencySubmissions){
                if(!caseIdsWithAgencySubmission.contains(submission.Case__c)){
                    caseIdsWithAgencySubmission.add(submission.Case__c);
                }
            }
        }
        for(Case triggerCase : triggerCaseMap.values()){
            if(String.IsNotBlank(triggerCase.ZTS_EU_PV_Works__c) && caseIdsWithAgencySubmission.contains(triggerCase.Id) && ((!Test.isRunningTest() && !hasErrPermission) || Test.isRunningTest())){
                triggerCase.addError('Cases Sent to PVWorks that have agency submissions can only be Erred by an admin.  Please reach out to an administrator for assistance.');
            }
            else{
                triggerCase.ZTS_US_Information_Type__c = 'Erred';
            }
        }
    }
    /**
     * Method to lock audit trails so that sequences aren't reordered in a merge situation.
     * @param Id[] approvedCases, all cases from PVW validation that passed without erroring
     * 
     * @return null
     * 
     */
	public static void setAuditTrailLock(Id[] caseIds){
        ZTS_US_CSE_Audit_Trail__c[] auditTrails = [   SELECT Id FROM ZTS_US_CSE_Audit_Trail__c WHERE Case__c in : caseIds];
        if(auditTrails!=null && !auditTrails.isEmpty()){
            for(ZTS_US_CSE_Audit_Trail__c auditTrail : auditTrails){
                auditTrail.Sequence_Lock__c = true;
            }
            try{
                update auditTrails;
            }
            catch(Exception e){  
                ZTS_EU_Logger.error( 'Error updating Audit Trails: ' + e.getMessage(), null, 'SL_CaseTriggerHelper.setAuditTrailLock');
            }
        }
    }
    /**
     * Method to validate text fields to make sure no pvw breaking special characters are in that field
     * @param String objectName - the object being checked
     * @param Map<String,String> fieldMap - the fields being checked, key is label, value is text stored in that field
     * 
     * @return Boolean - whether or not the field contains the characters
     * 
     */
	public static String checkForSpecialCharactersAndOddQuotes(String objectName,Map<String,String> fieldMap){
        String errorString = '';
        String[] badChars = Label.PVW_Disallowed_Characters.split(',');
        String[] badCharsASCII = Label.PVW_Disallowed_Characters_ASCII.split(',');
        for(String fieldName : fieldMap.keySet()){
            String fieldValue = fieldMap.get(fieldName);
            if(String.IsNotBlank(fieldValue)){
                //take all of the non-ascii characters from the first label, if the string contains any of these chars, throw an error
                for(String badChar : badChars){
                    if(fieldValue.contains(badChar)){
                        errorString = 'The field '+objectName+' - '+fieldName+' cannot contain special characters, tabs or hard-spaces';
                        return errorString;
                    }
                }
                //get ascii values of characters in the string, if ascii values are in the ascii label, throw an error
                Integer[] asciiChars = fieldValue.getChars(); 
                Set<Integer> asciiCharsSet = new Set<Integer>();
                for(Integer asciiChar : asciiChars){
                    if(!asciiCharsSet.contains(asciiChar)){
                        asciiCharsSet.add(asciiChar);
                    }
                }
                for(String badChar:badCharsASCII){
                    Integer badCharInt = Integer.valueOf(badChar);
                    if(asciiCharsSet.contains(badCharInt)){
                        errorString = 'The field '+objectName+' - '+fieldName+' cannot contain special characters, tabs or hard-spaces';
                        return errorString;
                    }
                }
                /*(if(asciiChars.contains(9) || asciiChars.contains(255) || asciiChars.contains(160)){
                    errorString = 'The field '+objectName+' - '+fieldName+' cannot contain tabs or hard spaces';
                }*/
                //validate that the string contains a complete set of open and close double quotes.  odd number of double quotes throws an error
                if(fieldValue.contains('"')){
                    Integer fieldLength = fieldValue.length();
                    Integer fieldLengthSub = fieldValue.replaceAll('"', '').length();
                    Integer remainder = math.mod(fieldLength - fieldLengthSub,2);
                    if(remainder!=0){
                        errorString = 'The field '+objectName+' - '+fieldName+' is missing "';
                    }
                }
            }
        }
        return errorString;
    }
    
  
    
}