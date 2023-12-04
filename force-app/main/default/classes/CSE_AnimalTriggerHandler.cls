/****************************************************************************************************************************************** 
 * Class Name   : CSE_AnimalTriggerHandler
 * Description  : This class will handle all CSE_AnimalTriggerHandler logic
 * Created By   : Slalom Consulting/ Christian Kildal-Brandt
 * Created Date : September 20th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer               				  Date                Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Christian Kildal-Brandt(Slalom)      09/20/2021              Created
 * Neil Kapoor							10/12/2021				Modified
 * Venkat Joginapally					10/27/2021				Updated to Dispatch Trigger Framework
*****************************************************************************************************************************************/

public with sharing class CSE_AnimalTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    public static final String OBJECT_API_NAME = 'ZTS_US_Animal__c';
    //note: this Case Api name is on the caseAnimal object not the Animal object
    public static final String CASE_FIELD_API_NAME = 'ZTS_US_Case__c';

    @testVisible
    public static void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap){
   	    final Set<String> VMIPS_CASE_TYPES_FOR_PVWORKS = new Set<String>{ 'Animal Complaint', 'Human Exposure', 'Product Defect' };
        String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
        String animalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Set<String> animalIds = new Set<String>(); 
        ZTS_US_Animal__c[] animalsToValidateAge = new ZTS_US_Animal__c[]{};

        List<ZTS_US_Animal__c> animals = (List<ZTS_US_Animal__c>)triggerNew;
        for(ZTS_US_Animal__c animal: animals){
            animalIds.add(animal.Id);
            ZTS_US_Animal__c oldAnimal = (triggerOldMap!=null && triggerOldMap.containsKey(animal.Id) ? (ZTS_US_Animal__c)triggerOldMap.get(animal.Id) : null);
            if(oldAnimal != null && animal.ZTS_US_Date_of_Birth__c!= null 
                && ((animal.ZTS_US_Species__c != 'Human' && oldAnimal.ZTS_US_Age_from__c != animal.ZTS_US_Age_from__c) 
                    || (animal.ZTS_US_Species__c == 'Human' && oldAnimal.ZTS_US_Age_text__c != animal.ZTS_US_Age_text__c))){
                        animalsToValidateAge.add(animal);
            }
        }
        List<ZTS_US_Case_Animal__c> caseAnimals = [SELECT ID, ZTS_US_Case__c, ZTS_US_Animal__c FROM ZTS_US_Case_Animal__c WHERE ZTS_US_Animal__c IN :animalIds];
        Set<String> caseIds = new Set<String>();
        for(ZTS_US_Case_Animal__c caseAnimal: caseAnimals){
            caseIds.add(caseAnimal.ZTS_US_Case__c);
        }
        Map<Id, Case> relatedCases =  new Map<Id, Case>([SELECT Id, Type,Sync_Status__c FROM Case WHERE Id IN :caseIds AND RecordTypeId = :animalRecordTypeId AND Type IN :VMIPS_CASE_TYPES_FOR_PVWORKS AND Sync_Status__c !=:VmipsCaseSyncStatusHandler.SYNC_UNAPPROVED]);
        //Map<Id, Case> animalToCaseMap = new Map<Id, Case>();
        Map<Id, Set<Case>> animalToCaseMap = new Map<Id, Set<Case>>();
        String caseType;
        for(ZTS_US_Case_Animal__c caseAnimal: caseAnimals){
            Id caseId = caseAnimal.ZTS_US_Case__c;
            //animalToCaseMap.put(caseAnimal.ZTS_US_Animal__c, relatedCases.get(caseId));
            if(relatedCases.containsKey(caseId)){
                Case tempCase = relatedCases.get(caseId);
                caseType = tempCase.Type;
                Id tempAnimalId = caseAnimal.ZTS_US_Animal__c;
                Set<Case> tempList = new Set<Case>();
                if(animalToCaseMap.containsKey(tempAnimalId)){
                    tempList = animalToCaseMap.get(tempAnimalId);
                    tempList.add(tempCase);
                } else {
                    tempList.add(tempCase);
                }
                animalToCaseMap.put(tempAnimalId, tempList);
            }
        }
         
        Map<String, Set<String>> approvalMetadataFields = SL_CaseTriggerHelper.retrieveApprovalFieldsFromMetadata(caseType,null);
        if(approvalMetadataFields!=null && !approvalMetadataFields.isEmpty() && !animalToCaseMap.isEmpty()){
            validateFieldUpdatesForPVWorks((List<ZTS_US_Animal__c>) triggerNew, (Map<Id, ZTS_US_Animal__c>) triggerOldMap, animalToCaseMap, approvalMetadataFields.get( OBJECT_API_NAME ));
        }
        if(!animalsToValidateAge.isEmpty()){
            AnimalAgeHelper.validateAnimalAge(animalsToValidateAge);
        }
    }

    @testVisible
    private static void validateFieldUpdatesForPVWorks(List<ZTS_US_Animal__c> triggerNew, Map<Id, ZTS_US_Animal__c> triggerOldMap,  Map<Id, Set<Case>> animalToCaseMap, Set<String> fieldSet){
        final String REQUIRED_FIELD_NULLED = 'The field {0} on {1} cannot be set to null when it\'s related Case is marked as Approved (for PV Works)';
        for ( ZTS_US_Animal__c animal : triggerNew )
        {
            if(animalToCaseMap.get(animal.id) == null)
            {
                continue;
            }
            for ( String fieldAPIName : fieldSet )
            {
                // if they have changed so that the new value is now null we need to add an error
                ZTS_US_Animal__c oldAnimal = triggerOldMap.get( animal.Id );
                if ( animal.get( fieldAPIName ) != oldAnimal.get( fieldAPIName ) && animal.get( fieldAPIName ) == null )
                {
                    animal.addError( String.format( REQUIRED_FIELD_NULLED, new List<String>{ fieldAPIName, animal.getSObjectType().getDescribe().getLabel()  } ) );
                    List<Database.Error> validationErrors = animal.getErrors();
                    system.debug('validation errors' + validationErrors);
                }
            }
        }
    }

    public static void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)    
    {
        try 
        {
            AtlasIntegrationHelper.filterAndCreatePets( triggerNew );
        } 
        catch ( Exception e)  
        {
            System.debug( 'exception thrown calling integration helper: ' + e.getMessage() );
            ZTS_EU_Logger.error( 'Error creating Animals: ' + e.getMessage(), null, 'CSE_AnimalTriggerHandler - create pet Atlas' );

        }
    }
    
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        // Added this logic as a part of CSE-49(LongTextArea Field Audit)
        new CSE_LongTextAreaAuditTrailHelper().filterTextAreaChangedRecords(triggerNew, triggerOldMap, 'Long_Text_Area_Fields');
    }
	public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeInsert(List<SObject> triggerNew) {
    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {}
}