/****************************************************************************************************************************************** 
 * Trigger Name : CSE_CaseAnimalTriggerHandler
 * Description  : All Dispatch Trigger Logic for CaseAnimal object.
 * Created By   : Slalom(Venkat Joginapally) 
 * Created Date : 13th September, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                      Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Venkat Joginapally          09/13/2021             Created 
 * Christain Brandt                                   Added code  
*****************************************************************************************************************************************/

public with sharing class CSE_CaseAnimalTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    @testVisible static final String CASE_ANIMAL_APPROVEDCASE_DELETE_ERROR = System.Label.CSE_CaseAnimalTriggerHandler_ErrorText;
    @testVisible static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    public static final String CASE_LOOKUP_FIELD = 'ZTS_US_Case__c';
    public static final String OBJECT_API_NAME = 'ZTS_US_Case_Animal__c';

    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){      
    	List<ZTS_US_Case_Animal__c> lstOldCaseAnimals = (List<ZTS_US_Case_Animal__c>)triggerOld;     
        //get all case Ids from CaseAnimals into a set
        Map<Id, List<ZTS_US_Case_Animal__c>> caseIdToCaseAnimalsMap = new Map<Id, List<ZTS_US_Case_Animal__c>>();
        //Create a map with all the caseIds as key and related tobedeleted CaseAnimals List as value
        for(ZTS_US_Case_Animal__c caseAnimal: lstOldCaseAnimals){
            List<ZTS_US_Case_Animal__c> caseAnimalList = new List<ZTS_US_Case_Animal__c>();
            //if Case Id already exists in the Map, add the case animal record to the List in the map, filter out approved status case ID's
            if(caseIdToCaseAnimalsMap.containsKey(caseAnimal.ZTS_US_Case__c)){
                //get the existing case animal list from the map for that case Id
                caseAnimalList = caseIdToCaseAnimalsMap.get(caseAnimal.ZTS_US_Case__c);
                //add the current caseAnimal record to the above list
                caseAnimalList.add(caseAnimal);
                //Put the case Id and related case animal list into the map which replaces the existing entry for that caseId
                caseIdToCaseAnimalsMap.put(caseAnimal.ZTS_US_Case__c,  caseAnimalList);
            } else {
                // if case Id does not exist in the map, put new entry for the case Id and the List with the current case animal record 
                caseIdToCaseAnimalsMap.put(caseAnimal.ZTS_US_Case__c, new List<ZTS_US_Case_Animal__c>{caseAnimal});
            }
        }     

        //map of case ids with number of ids of case animals which are not in delete, these case ids are only approved ones from above map.
        //iterate through case animals, add error.

        //SOQL to get all the Cases with Approved = true and with list of related Case Animals 
        List<Case> casesWithCaseAnimals = getCasesWithCaseAnimals(caseIdToCaseAnimalsMap.keySet());

        //loop through each Case and check the size of the related case Animals list, if size is =1, give error that Case Animal record cannot be deleted
        for(Case caseWithCaseAnimal: casesWithCaseAnimals){
            List<ZTS_US_Case_Animal__c> relatedToDeleteCaseAnimals =  caseIdToCaseAnimalsMap.get(caseWithCaseAnimal.Id);
            //checking if total list of case animals on the case is equal to list of tobedeleted case animals size
            if(caseWithCaseAnimal.Case_Animals__r.size() == relatedToDeleteCaseAnimals.size()){
                //if the size is same, add error to the case animal records so that they will not be deleted
                for(ZTS_US_Case_Animal__c relatedToDeleteCaseAnimal: relatedToDeleteCaseAnimals){
                    relatedToDeleteCaseAnimal.addError(CASE_ANIMAL_APPROVEDCASE_DELETE_ERROR);
                }
            }
        }
    }

    private List<Case> getCasesWithCaseAnimals(Set<Id> caseIds){
        //get cases and related case animal records, get only cases that are approved = true
        List<Case> caseList =  [SELECT Id, (SELECT Id FROM Case_Animals__r) FROM Case WHERE Id IN: caseIds AND Sync_Status__c != :VmipsCaseSyncStatusHandler.SYNC_UNAPPROVED AND RecordType.DeveloperName =: RECORDTYPE_CASE_ANIMAL_SUPPORT_STR];
        return caseList;
    }
    
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerNew,null, OBJECT_API_NAME,CASE_LOOKUP_FIELD,null,Trigger.operationType);
        VmipsCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'ZTS_US_Case__r',triggerNewMap);
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        List<ZTS_US_Case_Animal__c> triggerCaseAnimals = (List<ZTS_US_Case_Animal__c>)triggerNew;
        ZTS_US_Case_Animal__c[] caseAnimalsWithNewPatients = new ZTS_US_Case_Animal__c[]{};
        
        ZTS_US_Case_Animal__c[] caseAnimalsToValidateAge = new ZTS_US_Case_Animal__c[]{};
        system.debug('in beforeUpdate');
        for(ZTS_US_Case_Animal__c caseAnimal : triggerCaseAnimals){
            ZTS_US_Case_Animal__c oldCaseAnimal = (triggerOldMap!=null && triggerOldMap.containsKey(caseAnimal.Id) 
                                                    ? (ZTS_US_Case_Animal__c)triggerOldMap.get(caseAnimal.Id) : null);
            if(oldCaseAnimal!= null && oldCaseAnimal.ZTS_US_Animal__c == null && caseAnimal.ZTS_US_Animal__c != null){
                system.debug('case patient with new patient');
                caseAnimalsWithNewPatients.add(caseAnimal);
            }
            if(oldCaseAnimal != null && String.isNotBlank(caseAnimal.ZTS_US_Animal__c) &&
                (oldCaseAnimal.ZTS_US_Age_from__c != caseAnimal.ZTS_US_Age_from__c  || oldCaseAnimal.ZTS_US_Age_text__c != caseAnimal.ZTS_US_Age_text__c)){
                caseAnimalsToValidateAge.add(caseAnimal);
            }
        }
        if(!caseAnimalsWithNewPatients.isEmpty()){
            checkPatientHouseHold(caseAnimalsWithNewPatients);
            syncFieldsFromAnimal(caseAnimalsWithNewPatients);
        }
        if(!caseAnimalsToValidateAge.isEmpty()){
            AnimalAgeHelper.validateCaseAnimalAge(caseAnimalsToValidateAge);
        }
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        List<ZTS_US_Case_Animal__c> triggerCaseAnimals = (List<ZTS_US_Case_Animal__c>)triggerNew;
        syncFieldsToAnimal(triggerCaseAnimals,triggerOldMap);
        VmipsCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'ZTS_US_Case__r',triggerNewMap);
    }
    public void syncFieldsToAnimal(ZTS_US_Case_Animal__c[] triggerCaseAnimals,Map<Id, SObject> triggerOldMap){
        Map<Id,Set<String>> animalWithChangedFieldMap = new Map<Id,Set<String>>();
        Set<String> fieldsToSync = getSyncFieldSet();
        for(ZTS_US_Case_Animal__c caseAnimal: triggerCaseAnimals){
            ZTS_US_Case_Animal__c oldCaseAnimal = (triggerOldMap!=null && triggerOldMap.containsKey(caseAnimal.Id) 
                                                        ? (ZTS_US_Case_Animal__c)triggerOldMap.get(caseAnimal.Id) 
                                                        : null);
            //see if any of the fields that we care about syncing changed
            if(caseAnimal.ZTS_US_Animal__c!=null && oldCaseAnimal!=null){
                for(String checkField : fieldsToSync){
                    if(caseAnimal.get(checkField) != oldCaseAnimal.get(checkField)){
                        system.debug('CSE_CaseAnimalTriggerHandler.syncFieldsToAnimal field changed: '+checkField);
                        if(animalWithChangedFieldMap.containsKey(caseAnimal.ZTS_US_Animal__c)){
                            Set<String> animalChangedFields = animalWithChangedFieldMap.get(caseAnimal.ZTS_US_Animal__c);
                            animalChangedFields.add(checkField);
                            animalWithChangedFieldMap.put(caseAnimal.ZTS_US_Animal__c,animalChangedFields);
                        }
                        else{
                            animalWithChangedFieldMap.put(caseAnimal.ZTS_US_Animal__c,new Set<String>{checkField});
                        }
                    }
                }
            }
        }
        
        //get list of fields to query and sync between records
        
        String animalFieldsToQuery;
        if(fieldsToSync!=null){
            animalFieldsToQuery = String.join( new List<String>( fieldsToSync ), ', ' );
            animalFieldsToQuery = animalFieldsToQuery.leftPad((animalFieldsToQuery.length()+1), ',');
        }

        Map<Id,ZTS_US_Animal__c> animalMap;
        if(!animalWithChangedFieldMap.isEmpty() && animalFieldsToQuery!=null && String.isNotBlank(animalFieldsToQuery)){
            Id[] animalIds = new Id[]{};
            animalIds.addAll(animalWithChangedFieldMap.keySet());
            String animalQueryString =  ' SELECT Id' + animalFieldsToQuery + 
                                        ' FROM ZTS_US_Animal__c ' +
                                        ' WHERE Id IN :animalIds';
                                        
            system.debug('CSE_CaseAnimalTriggerHandler.syncFieldsToAnimal query: '+animalQueryString);                            
            animalMap = new Map<Id,ZTS_US_Animal__c>((ZTS_US_Animal__c[])Database.query(animalQueryString));
        }
        ZTS_US_Animal__c[] animalsToUpdate = new ZTS_US_Animal__c[]{};
        //for all the animals that link to the case animal, loop through the fields that changed from the case animal and see if the animal
        //needs to be updated to match
        if(animalMap == null || !animalMap.isEmpty()){
            String[] ageFields = new String[]{'ZTS_US_Age_text__c','ZTS_US_Age_to__c','ZTS_US_Age_from__c','Age_units__c','ZTS_US_Age_Approx__c',
                                                'ZTS_US_Age_Group__c','ZTS_US_Age_unit_from__c','ZTS_US_Age_unit_to__c'};
            String[] ageNumberFields = new String[]{'ZTS_US_Age_text__c','ZTS_US_Age_from__c','ZTS_US_Age_to__c'};
            for(ZTS_US_Case_Animal__c caseAnimal: triggerCaseAnimals){
                if(caseAnimal.ZTS_US_Animal__c!=null && animalWithChangedFieldMap.containsKey(caseAnimal.ZTS_US_Animal__c)){
                    ZTS_US_Animal__c animal = animalMap.get(caseAnimal.ZTS_US_Animal__c);
                    Set<String> caseAnimalFieldsThatChanged = animalWithChangedFieldMap.get(animal.Id);
                    
                    Boolean avoidAgeSync = false;
                    for(String ageNumberField : ageNumberFields){
                        String ageUnitField;
                        switch on ageNumberField{
                            when 'ZTS_US_Age_text__c'{
                                ageUnitField = 'Age_units__c';
                            }
                            when 'ZTS_US_Age_from__c'{
                                ageUnitField = 'ZTS_US_Age_unit_from__c';
                            }
                            when 'ZTS_US_Age_to__c'{
                                ageUnitField = 'ZTS_US_Age_unit_to__c';
                            }
                        }
                        Decimal ageNumberCaseAnimal = (Decimal)caseAnimal.get(ageNumberField);
                        String ageUnitsCaseAnimal = (String)caseAnimal.get(ageUnitField);
                        Decimal ageNumberAnimal = (Decimal)animal.get(ageNumberField);
                        String ageUnitsAnimal = (String)Animal.get(ageUnitField);
                        //do not sync age if the age on the case animal is younger than the age on the animal, unless the units change
                        if(ageNumberCaseAnimal!= null && ageNumberAnimal!= null && String.isNotBlank(ageUnitsCaseAnimal) && String.isNotBlank(ageUnitsAnimal)
                            && ageNumberCaseAnimal < ageNumberAnimal && ageUnitsCaseAnimal == ageUnitsAnimal){
                            avoidAgeSync = true;
                        }
                    }
                    Boolean animalNeedsUpdating = false;
                    for(String fieldToSync:caseAnimalFieldsThatChanged){
                        if(caseAnimal.get(fieldToSync) != animal.get(fieldToSync)){
                            //do not sync any of the age related fields if the age numbers above don't follow the rules
                            if(ageFields.contains(fieldToSync) && avoidAgeSync){
                                continue;
                            }
                            animal.put(fieldToSync,caseAnimal.get(fieldToSync));
                            animalNeedsUpdating = true;
                        }
                    }
                    if(animalNeedsUpdating){
                        animalsToUpdate.add(animal);
                    }
                }
            }
            if(!animalsToUpdate.isEmpty()){
                try{
                    update animalsToUpdate;
                }
                catch(Exception e){
                    system.debug('CSE_CaseAnimalTriggerHandler.syncFieldsToAnimal:'+e.getMessage());
                    ZTS_EU_Logger.error( 'Error updating patients: ' + e.getMessage(), null, 'CSE_CaseAnimalTriggerHandler.syncFieldsToAnimal');
                }
            }
        }
    }//syncFieldsToAnimal
	public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerOld,triggerOldMap, OBJECT_API_NAME,CASE_LOOKUP_FIELD,null,Trigger.operationType);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeInsert(List<SObject> triggerNew) {
        List<ZTS_US_Case_Animal__c> triggerCaseAnimals = (List<ZTS_US_Case_Animal__c>)triggerNew;
        ZTS_US_Case_Animal__c[] caseAnimalsToCheckHousehold = new ZTS_US_Case_Animal__c[]{};
        ZTS_US_Case_Animal__c[] caseAnimalsToValidateAge = new ZTS_US_Case_Animal__c[]{};
        for(ZTS_US_Case_Animal__c caseAnimal: triggerCaseAnimals){
            if(caseAnimal.ZTS_US_Animal__c!=null){
                caseAnimalsToCheckHousehold.add(caseAnimal);
            }
            if(String.isNotBlank(caseAnimal.ZTS_US_Animal__c) &&
                caseAnimal.ZTS_US_Age_from__c!=null || caseAnimal.ZTS_US_Age_text__c != null){
                caseAnimalsToValidateAge.add(caseAnimal);
            }
        }
        if(!caseAnimalsToCheckHousehold.isEmpty()){
            checkPatientHouseHold(caseAnimalsToCheckHousehold);
        }
        if(!caseAnimalsToValidateAge.isEmpty()){
            AnimalAgeHelper.validateCaseAnimalAge(caseAnimalsToValidateAge);
        }
        
        syncFieldsFromAnimal(triggerCaseAnimals);
    }
    public static void syncFieldsFromAnimal(ZTS_US_Case_Animal__c[] triggerCaseAnimals){
        Id[] animalIds = new Id[]{};
        for(ZTS_US_Case_Animal__c caseAnimal: triggerCaseAnimals){
            if(caseAnimal.ZTS_US_Animal__c!=null){
                animalIds.add(caseAnimal.ZTS_US_Animal__c);
            }
        }
        
        //get list of fields to query and sync between records
        Set<String> fieldsToSync = getSyncFieldSet();
        String animalFieldsToQuery;
        if(fieldsToSync!=null){
            animalFieldsToQuery = String.join( new List<String>( fieldsToSync ), ', ' );
            animalFieldsToQuery = animalFieldsToQuery.leftPad((animalFieldsToQuery.length()+1), ',');
        }

        Map<Id,ZTS_US_Animal__c> animalMap;
        if(!animalIds.isEmpty() && animalFieldsToQuery!=null && String.isNotBlank(animalFieldsToQuery)){
            String animalQueryString =  ' SELECT Id' + animalFieldsToQuery + 
                                        ' FROM ZTS_US_Animal__c ' +
                                        ' WHERE Id IN :animalIds';
            animalMap = new Map<Id,ZTS_US_Animal__c>((ZTS_US_Animal__c[])Database.query(animalQueryString));
        }
        if(animalMap != null && !animalMap.isEmpty()){
            for(ZTS_US_Case_Animal__c caseAnimal: triggerCaseAnimals){
                ZTS_US_Animal__c animal = animalMap.get(caseAnimal.ZTS_US_Animal__c);
                for(String fieldToSync:fieldsToSync){
                    if(animal!=null && animal.get(fieldToSync)!=null && caseAnimal.get(fieldToSync) != animal.get(fieldToSync)){
                        caseAnimal.put(fieldToSync,animal.get(fieldToSync));
                    }
                }
            }
        }
    }//syncFieldsFromAnimal
    public static Set<String> getSyncFieldSet(){
        Schema.FieldSet animalFieldSet = Schema.SObjectType.ZTS_US_Animal__c.fieldSets.getMap().get('Patient_Sync_Fields');
        Set<String> fieldsToSync = new Set<String>();
        for ( Schema.FieldSetMember animalField : animalFieldSet.getFields() )
        {
            fieldsToSync.add( animalField.getFieldPath() );
        }
        if(fieldsToSync.isEmpty()){
            system.debug('CSE_CaseAnimalTriggerHandler.syncFieldsFromAnimal cannot find field set for query');
            return null;
        }
        else{
            return fieldsToSync;
        }
    }
    public static void checkPatientHouseHold(ZTS_US_Case_Animal__c[] caseAnimalsToCheckHousehold){
        //only fire for vmips cases
        String animalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        system.debug('checkPatientHouseHold in method');
        String houseHoldError = 'Before adding this Case Patient, please ensure there is a pet owner from the patient\'s household listed as a Case Contact on this Case.';
        Id[] animalIds = new Id[]{};
        Id[] caseIds = new Id[]{};
        for(ZTS_US_Case_Animal__c caseAnimal : caseAnimalsToCheckHousehold){
            animalIds.add(caseAnimal.ZTS_US_Animal__c);
            caseIds.add(caseAnimal.ZTS_US_Case__c);
        }
        Map<Id,Case> caseMap = new Map<Id,Case>([   SELECT  Id,RecordTypeId
                                                    FROM    Case
                                                    WHERE   Id in: caseIds]);
        system.debug('checkPatientHouseHold animalIds:'+animalIds.size()+' caseIds:'+caseIds.size());
        Map<Id,ZTS_US_Animal__c> animalMap = new Map<Id,ZTS_US_Animal__c>([ SELECT  Id,ZTS_US_Pet_Owner__c,ZTS_US_Pet_Owner__r.AccountId
                                                                            FROM    ZTS_US_Animal__c
                                                                            WHERE   Id in: animalIds]);
        Case_Contact__c[] caseContacts = [  SELECT  Id,Contact__c,Contact__r.AccountId,Case__c
                                            FROM    Case_Contact__c
                                            WHERE   Case__c in: caseIds];
        Map<Id,Set<Id>> caseHouseHoldIdMap = new Map<Id,Set<Id>>();
        for(Case_Contact__c caseContact : caseContacts){
            if(caseHouseHoldIdMap.containsKey(caseContact.Case__c)){
                Set<id> houseHoldIds = caseHouseHoldIdMap.get(caseContact.Case__c);
                if(!houseHoldIds.contains(caseContact.Contact__r.AccountId)){
                    houseHoldIds.add(caseContact.Contact__r.AccountId);
                    caseHouseHoldIdMap.put(caseContact.Case__c,houseHoldIds);
                }
            }
            else{
                caseHouseHoldIdMap.put(caseContact.Case__c,new Set<Id>{caseContact.Contact__r.AccountId});
            }
        }
        system.debug('checkPatientHouseHold caseHouseHoldIdMap:'+caseHouseHoldIdMap);
        //if the case has no case contacts, error out.  
        //If the case has no case contacts whose accountIds match the patient's pet owner's accountId, error out. 
        for(ZTS_US_Case_Animal__c caseAnimal : caseAnimalsToCheckHousehold){
            
            ZTS_US_Animal__c animal = animalMap.get(caseAnimal.ZTS_US_Animal__c);
            Case caseForCaseAnimal = caseMap.get(caseAnimal.ZTS_US_Case__c);
            //if there's no case or if the case is not vmips or the patient does not have a pet owner, skip the rule
            if(caseForCaseAnimal==null || caseForCaseAnimal.RecordTypeId != animalRecordTypeId  || (animal!= null && String.IsBlank(animal.ZTS_US_Pet_Owner__c))){
                continue;
            }
            if(!caseHouseHoldIdMap.containsKey(caseAnimal.ZTS_US_Case__c)){
                caseAnimal.addError(houseHoldError);
            }
            else if (caseHouseHoldIdMap.containsKey(caseAnimal.ZTS_US_Case__c) && 
                !caseHouseHoldIdMap.get(caseAnimal.ZTS_US_Case__c).contains(animal.ZTS_US_Pet_Owner__r.AccountId)){
                    caseAnimal.addError(houseHoldError);
                /*Set<Id> caseHouseholds = caseHouseHoldIdMap.get(caseAnimal.ZTS_US_Case__c);
                if(!caseHouseholds.contains(animal.ZTS_US_Pet_Owner__r.AccountId)){
                    caseAnimal.addError(houseHoldError);
                }*/
            }
        }
        
    }
}