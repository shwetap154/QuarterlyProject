/**
 * @description       : Service Class for VMIPS Cases
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-21-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with validateCaseHasLOEProductAndCode method
 * 1.1   07-08-2022   Ethan Hirsch @ Zoetis Inc   Add validateCaseIsSeriousForAnestheticLOEProduct method
 * 1.2   07-11-2022   Ethan Hirsch @ Zoetis Inc   Add check that CaseProducts is not null in validateCaseIsSeriousForAnestheticLOEProduct method.
 * 1.3   07-12-2022   Ethan Hirsch @ Zoetis Inc   Add validateCaseIsSeriousForAnestheticLOEProduct method. 
 *                                                This was previously validateUnclassifiableAdverseEventForApproval in SL_CaseTriggerHandler
 * 1.4   07-19-2022   Ethan Hirsch @ Zoetis Inc   Add validateCaseAndLocalAsessmentSeriousMatch method.
**/
public with sharing class VmipsCaseService {
    @testVisible
    private static final String loeMissingCodeError = ' A LOE-related VEDRA Event must be present on the related Event Narrative when there is a Non-Diagnostics Support Case Product with a Lack of Efficacy Problem Type. ';
    @testVisible
    private static final String loeMissingProductError = ' A Non-Diagnostics Support Case Product with a Problem Type of Lack of Efficacy must be present when there is a LOE-related VEDRA Event. ';
    @testVisible
    private static final String anethesticProductCaseNotSeriousError = ' An Anesthetic Lack of Efficacy Product is present on this Case. Is it Serious? Must be set to Yes on the Case. ';
    @testVisible
    private static final String unclassifableEventMissingError = ' The Unclassifiable Adverse Event (LLT Code 2190) must be added to this Case to send it to PV Works. ';
    @testVisible
    private static final String caseSeriousLocalAsessmentNotSeriousError = ' If a Company Assessment has Is it Serious? as Yes, the Local Assessment Is it Serious? must be Yes. ';
    
    static final  String ZTS_RECORDTYPE = 'Zoetis_Product';

    //public static List<String> customErrorMessages = new List<String>();
    //public static Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
    
    //Helper method for idToCustomErrorMessage
    public static void addErrorToCustomErrors(Id aCase, String errorMessage,Map<Id,List<String>> idToCustomErrorMessages){
        addErrorToCustomErrors(aCase,new List<String>{errorMessage},idToCustomErrorMessages );
    }
    public static void addErrorToCustomErrors(Id aCase, List<String> errorMessages,Map<Id,List<String>> idToCustomErrorMessages) {
     
     if (idToCustomErrorMessages.containsKey(aCase)) {
        idToCustomErrorMessages.get(aCase).addAll(errorMessages);
    } else {
        idToCustomErrorMessages.put(aCase, errorMessages);
    }
}


    // List<String> errorMessages = new List<String>();

    //Error message text constants
    @testVisible static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    @testVisible static final String  CASE_CONTACTS_ERROR = ' Case Contacts ';
    @testVisible static final String  CASE_PRODUCTS_ERROR = ' Case Products ';
    @testVisible static final String  CASE_PRODUCTSROLE_ERROR = ' Case Products Should have Suspect Role ';
    @testVisible static final String  CASE_ANIMALS_ERROR = ' Case Animals ';
    @testVisible static final String  CASE_EVENT_NARRATIVE_ERROR = ' Event Narrative ';
    @testVisible static final String  CASE_MISSING_TEXT = ' Missing: ';
    @testVisible static final String  VEDDRA_RECORD_MISSING = 'VedDra Event ';
    @testVisible static final String  CASE_ERROR_TEXT = ' : Case cannot be sent for approval ';
    @TestVisible private static final String REQUIRED_FIELD_NULLED = 'The field {0} on {1} cannot be set to null when it\'s related Case is marked as Ready to Sync (for PV Works) ';
    @TestVisible private static final String MISSING_REQUIRED_FIELD_ON_RELATED_RECORD = 'A related {0} record is missing data in the {1} field. ';
    @TestVisible private static final String MISSING_REQUIRED_FIELD = 'The related VedDRA Event record {0} is missing data in the {1} field. ';
    @TestVisible private static final String CASE_INFORMATION_TYPE_ASSESSMENT_REPORTABILITY  = 'The Information Type field on Case should be Erred or Reportable. ';
    @TestVisible private static final String CASE_MISSING_REQUIRED_FIELD = 'The Case is missing data in the {0} field. ';
    @TestVisible private static final STring CASE_ASSESSMENT_ERROR = 'Case Assessments are incomplete ';
    @TestVisible private static final STring CASE_ANIMAL_AGE_ERROR = 'Age and Age Units are required on Patient and Case Patient to Send to PV Works';
    @testVisible static final String RECORDTYPE_ASSESMENT_LOCAL = 'ZTS_US_Local_Assessment';
    @testVisible static final String RECORDTYPE_ASSESMENT_PRODUCT = 'ZTS_US_Product_Assessment';
    @TestVisible static final String ROLE_SUSPECT_PRODUCT = 'Suspect Product';
    @TestVisible static final String STR_NO_ERRORS = 'No Errors ';
    @TestVisible static final String CASE_PRODUCT_LOE_ERROR = 'Case Product LOE Reason is missing. ';
    @TestVisible static final String EXTRA_ASSESSMENT_ERROR = 'You have too many related Assessments. ';
	@TestVisible static final String CONTACT_ADDRESS_REGEX_ERROR = 'Contact Mailing Address cannot have special characters.';


    /**
    * @description Validates that if a Case has a Non-Diagnostic Suspect Product with a Problem Type of Lack of Efficacy, it also has a related VedDRA Code for LOE.
    *              The reverse is also validated. A VedDRA Event with a related VedDRA Coding with an HLT Code of 155 is an LOE VedDRA Code
    * @author Ethan Hirsch @ Zoetis Inc | 06-20-2022 
    * @param caseProducts 
    * @param vedraEvents 
    * @return String 
    **/
    public static String validateCaseHasLOEProductAndCode(List<ZTS_US_Case_Product__c> caseProducts, List<ZTS_US_VedDRA_Event__c> veddraEvents) {
        Boolean hasNonDiagnosticLOESuspectProduct = false;
        Boolean hasLoeCode = false;

        if (caseProducts != null) {
            for (ZTS_US_Case_Product__c caseProduct : caseProducts) {
                if (caseProduct.ZTS_US_PVW_Product__r?.ZTS_US_Product_Category__c != 'DIAG' &&
                    caseProduct.ZTS_US_Product_Role__c == 'Suspect Product' &&
                    caseProduct.ZTS_US_Product_problem_type__c?.Contains('Lack of Efficacy') == true) {
                        hasNonDiagnosticLOESuspectProduct = true;
                        break;
                }
            }
        }

        if (veddraEvents != null) {
            for (ZTS_US_VedDRA_Event__c veddraEvent : veddraEvents) {
                if (veddraEvent.ZTS_US_VedDRA_Coding__r?.ZTS_US_HLT_Code__c == 155) {
                    hasLoeCode = true;
                    break;
                }
            }
        }

        if (hasNonDiagnosticLOESuspectProduct && !hasLoeCode) {
            return loeMissingCodeError;
        }
        else if (!hasNonDiagnosticLOESuspectProduct && hasLoeCode) {
            return loeMissingProductError;
        }

        return null;
    }

    /**
     * @description Validates that if a Case has at least one Anesthetic Product with a Problem Type of Lack of Efficacy,
     *   than the Case must be marked Serious
     * @author Ethan Hirsch @ Zoetis Inc | 07-08-2022 
     * @param vmipsCase 
     * @param caseProducts 
     * @param anestheticProductLines 
     * @return String
     */
    public static String validateCaseIsSeriousForAnestheticLOEProduct(Case vmipsCase, List<ZTS_US_Case_Product__c> caseProducts, Set<String> anestheticProductLines) {
        // If the Case is already marked Serious then Case Products don't need to be checked
        if (vmipsCase.ZTS_US_Is_it_serious_CA__c == 'Yes') {
            return null;
        }

        if (caseProducts != null) {
            for (ZTS_US_Case_Product__c caseProduct : caseProducts) {
                if (caseProduct.ZTS_US_Product_problem_type__c?.Contains('Lack of Efficacy') == true &&
                    // anestheticProductLines will contain all lowercase values so a case insensitive compare can be made
                    anestheticProductLines.contains(caseProduct.ZTS_US_PVW_Product__r?.ZTS_US_Product_Line__c?.toLowerCase())) {
                    return anethesticProductCaseNotSeriousError;
                }
            }
        }

        return null;
    } 

    /**
     * @description Validates that if an Animal Complaint Case only has Diagnostic Suspect Products and one of those 
     *   Products has a Problem Type of Lack of Efficacy, validate there is one Vedra Event present for an 
     *   Unclassifiable Adverse Event (LLT Code 2190). If not, add an error to the Case
     *   An error is added directly to match 
     * @param vmipsCase 
     * @param caseProducts 
     * @param veddraEvents 
     */
    public static String validateIfUnclassifiableEventRequired(Case vmipsCase, List<ZTS_US_Case_Product__c> caseProducts, List<ZTS_US_VedDRA_Event__c> veddraEvents) {
        // This Validation only applies to Animal Complaints
        if (vmipsCase.Type != 'Animal Complaint') {
            return null;
        }

        Boolean diagnosticProductsOnly = true;
        Boolean diagnosticLackOfEfficacyProductPresent = false;
        // If there are no Products, this validation will not run as diagnosticLackOfEfficacyProductPresent is false
        if (caseProducts != null) {
            for(ZTS_US_Case_Product__c caseProduct: caseProducts ){
                // Only Suspect Products should impact this validation
                if (caseProduct.ZTS_US_Product_Role__c != 'Suspect Product') {
                    continue;
                }

                // If there is at least one non-Diagnostic Product do not run this validation
                if (caseProduct.ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c != 'DIAG') {
                    diagnosticProductsOnly = false;
                    break;
                }

                if(caseProduct.ZTS_US_Product_problem_type__c?.Contains('Lack of Efficacy') == true){
                    diagnosticLackOfEfficacyProductPresent = true;
                } 
            }
        }
        
        // This Validation should only run if all Suspect Products are Diagnostic Products
        // and there is at least one Product with a Type of Lack of Efficacy
        Boolean unclassifiableEventPresent = false;
        if(diagnosticProductsOnly && diagnosticLackOfEfficacyProductPresent){
            for(ZTS_US_VedDRA_Event__c vedraEvent : veddraEvents){
                // 2190 is the VedDRA Event Code for Unclassifable Adverse Event
                if(vedraEvent.ZTS_US_VedDRA_Coding__r.ZTS_US_LLT_Code__c == 2190){
                    unclassifiableEventPresent = true;
                    break;
                }          
            }
            
            if(!unclassifiableEventPresent){
                return unclassifableEventMissingError;
            }
        }

        return null;
    }

    /**
     * @description Validates that if a Case cannot be marked Serious if a Local Assessment is not Serious
     * @author Ethan Hirsch @ Zoetis Inc | 07-19-2022 
     * @param vmipsCase 
     * @param assessments 
     * @return String
     */
    public static String validateCaseAndLocalAsessmentSeriousMatch(Case vmipsCase, List<ZTS_US_Assessment__c> assessments) {
        if (vmipsCase.ZTS_US_Is_it_serious_CA__c == 'Yes' && assessments != null) {
            for (ZTS_US_Assessment__c assessment : assessments) {
                if (assessment.RecordType.DeveloperName == 'ZTS_US_Local_Assessment' 
                    && assessment.ZTS_US_Is_it_serious__c != 'Yes') {
                    return caseSeriousLocalAsessmentNotSeriousError;
                }
            }
        }

        return null;
    }


    public static void checkPVWSyncStatus( Case[] triggerNew, Map<Id, Case> oldCasesMap )
    {      
        //this is not bulkified because the required fields are assumed based on the type of the first case in the trigger. Entire validation method would need to
        //be rewritten to be bulkified. Users should be using the lwc button on case to initiate so this is likely OK.
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        Id vmipsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        if(triggerNew[0].recordTypeId != vmipsRecordTypeId 
            && triggerNew[0].Type != 'Product Defect' && triggerNew[0].Type != 'Animal Complaint' && triggerNew[0].Type != 'Human Exposure'){
            return;
        }
        // build list to hold cases that meet the criteria for further checks
        List<Case> casesForValidation = new List<Case>( );
        // set field members from field set.
        
        Map<String, Set<String>> metadataFields = SL_CaseTriggerHelper.retrieveApprovalFieldsFromMetadata(triggerNew[0].Type,null);
        system.debug('checkPVWSyncStatus metadataFields'+metadataFields);
        Set<String> caseRequiredFields = (metadataFields!=null ? metadataFields.get('Case') : null);
        Set<String> revalidationFields = new Set<String>();
        for(Schema.FieldSetMember reValidationFieldSetMember : sObjectType.Case.fieldSets.Re_Validation_Fields.getfields()){
            revalidationFields.add(reValidationFieldSetMember.getFieldPath());
        }
        //check case created by user to see if it is from phase 1
        for(Case triggerCase : triggerNew){
            Case oldCase = oldCasesMap.get(triggerCase.id);
            
            Service_Cloud_Settings__mdt[] scs = Service_Cloud_Settings__mdt.getAll().values();

            if((scs[0].Block_VMIP_Integration_Created__c || Test.isRunningTest()) && triggerCase.RecordTypeId == vmipsRecordTypeId 
            && String.isNotBlank(triggerCase.PVW_External_ID__c) && oldCase.PVW_External_ID__c == triggerCase.PVW_External_ID__c
            && (triggerCase.Type == 'Product Defect'|| triggerCase.Type == 'Animal Complaint' || triggerCase.Type == 'Human Exposure'))          
            {
                addErrorToCustomErrors(triggerCase.Id, VmipsCaseSyncStatusHandler.CASE_NOT_ELIGIBLE_FOR_PVW, idToCustomErrorMessages );
            }
        }


        // check to see if cases meet the criteria
        for ( Case triggerCase : triggerNew )
        {
            Case oldCase = oldCasesMap.get(triggerCase.Id);
            //if the sync status changes to a ready state, add it to a list that will run the entire pvw validation
            if ( triggerCase.RecordTypeId == vmipsRecordTypeId 
                    && (triggerCase.Type == 'Product Defect'|| triggerCase.Type == 'Animal Complaint' || triggerCase.Type == 'Human Exposure')
                    && triggerCase.Sync_Status__c == VmipsCaseSyncStatusHandler.SYNC_READY && triggerCase.Sync_Status__c != oldCase.Sync_Status__c){ 
                        casesForValidation.add( triggerCase );
                        //continue to next case records if above checks are satisfied and the Case is added to Validated cases
                        continue;
            }
            //if the sync status is not unapproved or ready and one of its related fields change, check to see what needs to happen to the case 
            else if( triggerCase.RecordTypeId == vmipsRecordTypeId && caseRequiredFields!=null
                        && (triggerCase.Type == 'Product Defect'|| triggerCase.Type == 'Animal Complaint' || triggerCase.Type == 'Human Exposure') 
                        && triggerCase.Sync_Status__c != VmipsCaseSyncStatusHandler.SYNC_UNAPPROVED && triggerCase.Sync_Status__c != VmipsCaseSyncStatusHandler.SYNC_REAPPROVAL){
                // if one of the case pvw required fields gets unset, tell the user they can't do that
                for (String field : caseRequiredFields){
                    if(triggerCase.get(field) != oldCase.get(field) && triggerCase.get(field) == null)
                    {
                        addErrorToCustomErrors(triggerCase.Id, String.format( CASE_MISSING_REQUIRED_FIELD, new List<String>{ (String)Schema.getGlobalDescribe().get(triggerCase.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(field).getDescribe().getLabel(), triggerCase.getSObjectType().getDescribe().getLabel()} ), idToCustomErrorMessages );
                    }
                }
                //if one of the fields for revalidation changes, change the sync status to let the user know to revalidate
                for(String revalidationField : revalidationFields){
                    if(triggerCase.get(revalidationField) != oldCase.get(revalidationField)){
                        triggerCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_REAPPROVAL;
                        triggerCase.Case_Updated_Date__c = system.now();
                        break;
                    }
                }
            }
        }
        // return validated case list
        if(!casesForValidation.isEmpty()){
            sendCaseForApproval(casesForValidation,metadataFields,idToCustomErrorMessages);
        }
        if(!idToCustomErrorMessages.keySet().isEmpty()){
            for ( Case triggerCase : triggerNew ){
                if(idToCustomErrorMessages.containsKey(triggerCase.Id)){
                    String errorToSend = '';
                    Integer counter = 1;
                    for(String error : idToCustomErrorMessages.get(triggerCase.Id)){
                        errorToSend += String.valueOf(counter) + '. ' +error + '\n';
                        counter++;
                    }
                    triggerCase.addError(errorToSend);
                }
            }
        }
    }

    // CSE- 296 Case Error Validation
    @TestVisible
    private static void sendCaseForApproval( List<Case> validatedCases,Map<String, Set<String>> metadataFields, Map<Id,List<String>> idToCustomErrorMessages)
    {   
        System.debug('SL_CaseTriggerHandler.sendCaseForApproval');
        String errorMessage = '';
        // grab the required case fields
        Set<String> caseFields = (metadataFields!=null ? metadataFields.get('Case'):null);
        // query for the related case contact records
        Set<String> contactFields = (metadataFields!=null ? metadataFields.get('Contact'): null);

        String contactFieldsToQuery = '';
        if(contactFields !=null && contactFields.size() > 0){
            contactFieldsToQuery = String.join( new List<String>( contactFields ), ', ' );
            contactFieldsToQuery = contactFieldsToQuery.leftPad((contactFieldsToQuery.length()+1), ',');
        }
        
        Set<String> caseContactFields = (metadataFields!=null ? metadataFields.get('Case_Contact__c'): new Set<String>());
        // Format string to add to SOQL query
        String caseContactFieldsToQuery = String.join( new List<String>( caseContactFields ), ', ' );
        if (!String.isBlank(caseContactFieldsToQuery)) {
            caseContactFieldsToQuery = caseContactFieldsToQuery.leftPad((caseContactFieldsToQuery.length()+1), ',');
        }

        /*List<Case_Contact__c> queriedCaseContacts = [ SELECT Id,
                                                         Case__c,
                                                         Contact__c,
                                                         ZTS_US_Contact_Role__c,
                                                         ZTS_US_Primary_Reporter__c 
                                                    FROM  Case_Contact__c
                                                    WHERE Case__c IN :validatedCases ];*/
        String caseContactQueryString = ' SELECT Id,Case__c, Email__c, Contact__c,ZTS_US_Contact_Role__c,ZTS_US_Primary_Reporter__c ' + caseContactFieldsToQuery + 
        ' FROM Case_Contact__c ' +
        ' WHERE Case__c IN :validatedCases';
        List<Case_Contact__c> queriedCaseContacts = ( List<Case_Contact__c> ) Database.query( caseContactQueryString );
        
        Set<Id> contactId = new Set<Id>();
        for ( Case_Contact__c ca : queriedCaseContacts )
        {
            contactId.add( ca.Contact__c );
        }

        String contactQueryString = ' SELECT Id ' + contactFieldsToQuery + 
                        ' FROM Contact ' +
                        ' WHERE Id IN :contactId';

        Map<Id, Contact> queriedContactsMap = new Map<Id, Contact>( ( List<Contact> ) Database.query( contactQueryString ) );
        // query for the related case contact records
        Set<String> mandatoryProductFields = SL_CaseTriggerHelper.getAllRelevantCaseProductFields(); //fieldSets.get('ZTS_US_Case_Product__c');
        
        // Combine all the fields to query, with no duplicates
        Set<String> productFields = new Set<String>{'RecordType.DeveloperName','ZTS_US_Case__c', 'ZTS_US_Product_Role__c','ZTS_US_Product_Used_Correctly__c',
                                                    'ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c','ZTS_US_PVW_Product__c',
                                                    'ZTS_US_Product_problem_type__c','ZTS_US_Product_Agency__c','ZTS_US_LOE_Reason__c',
                                                    'ZTS_US_Previous_Exposure__c', 'ZTS_US_PVW_Product__r.ZTS_US_Product_Line__c',
                                                    'ZTS_US_Previous_Exposure_Details__c','ZTS_US_Previous_Reaction_Details__c',
                                                    'ZTS_US_Product_Lot__c','ZTS_US_Serial_Number__c','ZTS_US_Diluent__c'};
        if (mandatoryProductFields != null) {
            productFields.addAll(mandatoryProductFields);
        }

        // Format string to add to SOQL query
        String productFieldsToQuery = String.join( new List<String>( productFields ), ', ' );
        if (!String.isBlank(productFieldsToQuery)) {
            productFieldsToQuery = productFieldsToQuery.leftPad((productFieldsToQuery.length()+1), ',');
        }

        Set<String> batchDetailFields = (metadataFields!=null ? metadataFields.get('Batch_Detail__c') : new Set<String>());
        // Format string to add to SOQL query
        String batchFieldsToQuery = String.join( new List<String>( batchDetailFields ), ', ' );
        if (!String.isBlank(batchFieldsToQuery)) {
            batchFieldsToQuery = batchFieldsToQuery.leftPad((batchFieldsToQuery.length()+1), ',');
        }


        // A combination of the dynamically generated (above) mandatory fields, as well as the hardcoded ZTS_US_Case_Product__c fields that are used in this code
        String productQueryString = ' SELECT Id' + productFieldsToQuery + 
        ' ,(SELECT Id,ZTS_US_Product_Lot__c,ZTS_US_Serial_Number__c,ZTS_US_Diluent__c '+ batchFieldsToQuery +' FROM Batch_Details__r)'+
        ' FROM ZTS_US_Case_Product__c ' +
        ' WHERE ZTS_US_Case__c IN :validatedCases';
        
        List<ZTS_US_Case_Product__c> queriedProducts = ( List<ZTS_US_Case_Product__c> ) Database.query( productQueryString );  
        
        Set<Id> validNarrativeIds = new Set<Id>();
        // query for the related event narrative records
        Set<Id> narrativeIds = new Set<Id>();
        for(Case validCase: validatedCases){
            Id narrativeId = validCase.ZTS_US_Event_Narrative__c;
            if(validCase.Type == 'Animal Complaint' || validCase.Type == 'Human Exposure') {// && validCase.ZTS_EU_Sub_Type__c == 'Human Exposure - Symptomatic')){ ** Edited to fix bug CSE-700
                validNarrativeIds.add(narrativeId);
            }
            
                
                narrativeIds.add(narrativeId);
        }
        Set<String> narrativeFields = (metadataFields!=null ? metadataFields.get('ZTS_US_Event_Narrative__c') : null);
        Set<String> allNarrativeFields = new Set<String>{'ZTS_US_Outcome_of_Reaction__c,ZTS_US_Treatment__c,ZTS_US_Abstract_Summary__c'};
        if (narrativeFields != null) {
            allNarrativeFields.addAll(narrativeFields);
        }

        String narrativeFieldsToQuery = String.join( new List<String>( allNarrativeFields ), ', ' );
        
        //Querying the Veddra Events from Event Narrative
        List<ZTS_US_Event_Narrative__c> listEventNarratives = new List<ZTS_US_Event_Narrative__c>([select id,(SELECT Id,ZTS_US_VedDRA_Coding__c,
                                                                                                              ZTS_US_VedDRA_Coding__r.Name from Veddra_Events__r) 
                                                                                                   from ZTS_US_Event_Narrative__c WHERE ID IN : validNarrativeIds]);
       //this Map has Id as the Event narrative id and Integer as the no. of events associated to EN
        Map<Id,Integer> mapEventNarrativeIdToVedra = new Map<Id,Integer>();
        // checking the size of the integer from the map
        for(ZTS_US_Event_Narrative__c eventNarrativeRec : listEventNarratives){
            if(!eventNarrativeRec.Veddra_Events__r.isEmpty())
                mapEventNarrativeIdToVedra.put(eventNarrativeRec.Id, eventNarrativeRec.Veddra_Events__r.size());
            else
                mapEventNarrativeIdToVedra.put(eventNarrativeRec.Id, 0);
        }
        
        
        String narrativeQueryString = ' SELECT Id, ZTS_US_Case__c,' + narrativeFieldsToQuery + 
                        ' FROM ZTS_US_Event_Narrative__c ' +
                        ' WHERE Id IN :narrativeIds';

        Map<Id, ZTS_US_Event_Narrative__c> queriedNarrativesMap = new Map<Id, ZTS_US_Event_Narrative__c>( ( List<ZTS_US_Event_Narrative__c> )Database.query( narrativeQueryString ) );

        // lets deal with getting veddra events
        Set<String> veddraFields = (metadataFields!=null ? metadataFields.get( 'ZTS_US_VedDRA_Event__c' ) : null);

        String veddraFieldsToQuery = '';
        if(veddraFields !=null && veddraFields.size() > 0){
            veddraFieldsToQuery = String.join( new List<String>( veddraFields ), ', ' );
            veddraFieldsToQuery = veddraFieldsToQuery.leftPad((veddraFieldsToQuery.length()+1), ',');
        }

        String veddraQueryString = 'SELECT Id, Name, ZTS_US_Event_Narrative__c, ZTS_US_VedDRA_Coding__r.ZTS_US_HLT_Code__c, ZTS_US_VedDRA_Coding__r.ZTS_US_LLT_Code__c  ' + veddraFieldsToQuery +
                                        ' FROM ZTS_US_VedDRA_Event__c ' + 
                                        ' WHERE ZTS_US_Event_Narrative__c IN :narrativeIds ';
                                        
        List<ZTS_US_VedDRA_Event__c> queriedVeddraEvents = ( List<ZTS_US_VedDRA_Event__c> ) Database.query( veddraQueryString );
        // lets group the veddras by event narrative id 
        Map<Id, List<ZTS_US_VedDRA_Event__c>> narrativeToVeddraEvents = new Map<Id, List<ZTS_US_VedDRA_Event__c>>();

        for ( ZTS_US_VedDRA_Event__c aVeddraEvent : queriedVeddraEvents )
        {
            List<ZTS_US_VedDRA_Event__c> innerList = narrativeToVeddraEvents.containsKey( aVeddraEvent.ZTS_US_Event_Narrative__c )
                                                            ? narrativeToVeddraEvents.get( aVeddraEvent.ZTS_US_Event_Narrative__c )
                                                            : new List<ZTS_US_VedDRA_Event__c>();

            innerList.add( aVeddraEvent );
            narrativeToVeddraEvents.put( aVeddraEvent.ZTS_US_Event_Narrative__c, innerList );
        }

        //handle getting Animals that are related to a given case
        Set<String> animalFields = (metadataFields!=null ? metadataFields.get('ZTS_US_Animal__c'):null);
        Set<String> allAnimalFields = new Set<String>{'ZTS_US_Died__c','ZTS_US_Euthanized__c','ZTS_US_Alive_with_Sequela__c','ZTS_US_Under_Treatment__c',
                                                            'ZTS_US_Unknown__c','ZTS_US_Recovered__c','ZTS_US_Age_from__c','ZTS_US_Age_unit_from__c',
                                                            'ZTS_US_Age_to__c','ZTS_US_Age_unit_to__c','ZTS_US_Age_text__c','Age_units__c','ZTS_US_Weight__c',
                                                            'ZTS_US_Weight_units__c','ZTS_US_Weight_to__c','ZTS_US_Human_Weight__c'};
        if (animalFields != null) {
            allAnimalFields.addAll(animalFields);
        }

        String animalFieldsToQuery = '';
        if(allAnimalFields !=null && allAnimalFields.size() > 0){
            animalFieldsToQuery = String.join( new List<String>( allAnimalFields ), ', ' );
            animalFieldsToQuery = animalFieldsToQuery.leftPad((animalFieldsToQuery.length()+1), ',');
        }
        
        Set<String> caseAnimalFields = (metadataFields!=null ? metadataFields.get('ZTS_US_Case_Animal__c') : null);
        Set<String> allCaseAnimalFields = new Set<String>{'ZTS_US_Died__c','ZTS_US_Euthanized__c','ZTS_US_Alive_with_Sequela__c','ZTS_US_Under_Treatment__c',
                                                            'ZTS_US_Concomitant_medical_conditions__c',
                                                            'ZTS_US_Unknown__c','ZTS_US_Recovered__c','ZTS_US_Age_from__c','ZTS_US_Age_unit_from__c',
                                                            'ZTS_US_Age_to__c','ZTS_US_Age_unit_to__c','ZTS_US_Age_text__c','Age_units__c','ZTS_US_Weight__c',
                                                            'ZTS_US_Weight_units__c','ZTS_US_Weight_to__c','ZTS_US_Human_Weight__c'};
        String caseAnimalFieldsToQuery = '';
        if (caseAnimalFields != null) {
            allCaseAnimalFields.addAll(caseAnimalFields);
        }
        if(allCaseAnimalFields !=null && allCaseAnimalFields.size() > 0){
            caseAnimalFieldsToQuery = String.join( new List<String>( allCaseAnimalFields ), ', ' );
            caseAnimalFieldsToQuery = caseAnimalFieldsToQuery.leftPad((caseAnimalFieldsToQuery.length()+1), ',');
        }
        
        String caseAnimalQueryString =  'SELECT Id,ZTS_US_Case__c,ZTS_US_Animal__c,RecordType.DeveloperName' 
                                        + caseAnimalFieldsToQuery + 
                                        ' FROM ZTS_US_Case_Animal__c' +
                                        ' WHERE ZTS_US_Case__c IN :validatedCases';
        system.debug('SL_CaseTriggerHandler.approval caseAnimalQueryString:'+caseAnimalQueryString);
        List<ZTS_US_Case_Animal__c> queriedCaseAnimals = (List<ZTS_US_Case_Animal__c>)Database.query( caseAnimalQueryString );

        Set<Id> animalId = new Set<Id>();
        for ( ZTS_US_Case_Animal__c ca : queriedCaseAnimals )
        {
            animalId.add( ca.ZTS_US_Animal__c );
        }
        String animalQueryString =  'SELECT Id' + animalFieldsToQuery + 
                                    ' FROM ZTS_US_Animal__c' +
                                    ' WHERE Id IN :animalId';
        Map<Id, ZTS_US_Animal__c> queriedAnimalsMap = new Map<Id, ZTS_US_Animal__c>( ( List<ZTS_US_Animal__c> )Database.query( animalQueryString ) );        
        
        Set<String> anestheticProductLines = PVWProductLineTypeGroupingsSelector.newInstance().selectProductLinesByType(
            new Set<String> {'Anesthetic'}).get('Anesthetic');

        // map the contacts by case id 
        Map<Id, List<Case_Contact__c>> casesToCaseContactsMap = new Map<Id, List<Case_Contact__c>>();
        List<Case_Contact__c> innerContactList = new List<Case_Contact__c>();
        for ( Case_Contact__c aCaseContact : queriedCaseContacts )
        {
            innerContactList = casesToCaseContactsMap.containsKey( aCaseContact.Case__c ) ? innerContactList = casesToCaseContactsMap.get( aCaseContact.Case__c )
                                                                                                                : new List<Case_Contact__c>();

            innerContactList.add( aCaseContact );
            casesToCaseContactsMap.put( aCaseContact.Case__c, innerContactList );
        }
        // map the products by case id
        Map<Id, List<ZTS_US_Case_Product__c>> casesToCaseProductsMap = new Map<Id, List<ZTS_US_Case_Product__c>>();
        List<ZTS_US_Case_Product__c> innerProductList = new List<ZTS_US_Case_Product__c>();
        Batch_Detail__c[] allBatchDetails = new Batch_Detail__c[]{};
        for ( ZTS_US_Case_Product__c aCaseProduct : queriedProducts )
        {
            innerProductList = casesToCaseProductsMap.containsKey( aCaseProduct.ZTS_US_Case__c ) ? innerProductList = casesToCaseProductsMap.get( aCaseProduct.ZTS_US_Case__c )
                                                                                                                    : new List<ZTS_US_Case_Product__c>();

            innerProductList.add( aCaseProduct );
            casesToCaseProductsMap.put( aCaseProduct.ZTS_US_Case__c, innerProductList );

            //TODO add case product fields
            Map<String,String>productFieldsToCheckSpecialChars = new Map<String, String>();
            productFieldsToCheckSpecialChars.put('Previous Exposure Details',(String)aCaseProduct.get('ZTS_US_Previous_Exposure_Details__c'));
            productFieldsToCheckSpecialChars.put('Previous Reaction Details',(String)aCaseProduct.get('ZTS_US_Previous_Reaction_Details__c'));
            productFieldsToCheckSpecialChars.put('Product Lot #',(String)aCaseProduct.get('ZTS_US_Product_Lot__c'));
            productFieldsToCheckSpecialChars.put('Serial Number',(String)aCaseProduct.get('ZTS_US_Serial_Number__c'));
            productFieldsToCheckSpecialChars.put('Diluent',(String)aCaseProduct.get('ZTS_US_Diluent__c'));
            String productErrorMessage = SL_CaseTriggerHelper.checkForSpecialCharactersAndOddQuotes('Case Product',productFieldsToCheckSpecialChars );
            if(String.isNotBlank(productErrorMessage))errorMessage+=productErrorMessage;

            if(aCaseProduct.Batch_Details__r!=null && !aCaseProduct.Batch_Details__r.isEmpty()){
                allBatchDetails.addAll(aCaseProduct.Batch_Details__r);
            }
        }
        for(Batch_Detail__c batch : allBatchDetails){
            Map<String,String>batchFieldsToCheckSpecialChars = new Map<String, String>();
            batchFieldsToCheckSpecialChars.put('Product Lot #',(String)batch.get('ZTS_US_Product_Lot__c'));
            batchFieldsToCheckSpecialChars.put('Serial Number',(String)batch.get('ZTS_US_Serial_Number__c'));
            batchFieldsToCheckSpecialChars.put('Diluent',(String)batch.get('ZTS_US_Diluent__c'));
            String batchErrorMessage = SL_CaseTriggerHelper.checkForSpecialCharactersAndOddQuotes('Batch Detail',batchFieldsToCheckSpecialChars );
            if(String.isNotBlank(batchErrorMessage))errorMessage+=batchErrorMessage;
        }

        // map the animals by case id 
        Map<Id, List<ZTS_US_Case_Animal__c>> casesToCaseAnimalsMap = new Map<Id, List<ZTS_US_Case_Animal__c>>();
        List<ZTS_US_Case_Animal__c> innerAnimalList = new List<ZTS_US_Case_Animal__c>();
        for ( ZTS_US_Case_Animal__c aCaseAnimal : queriedCaseAnimals )
        {
            innerAnimalList = casesToCaseAnimalsMap.containsKey( aCaseAnimal.ZTS_US_Case__c ) ? innerAnimalList = casesToCaseAnimalsMap.get( aCaseAnimal.ZTS_US_Case__c )
                                                                                                                : new List<ZTS_US_Case_Animal__c>();

            innerAnimalList.add( aCaseAnimal );
            casesToCaseAnimalsMap.put( aCaseAnimal.ZTS_US_Case__c, innerAnimalList );
            Map<String,String>caseAnimalFieldsToCheckSpecialChars = new Map<String, String>{'Concomitant Medical Conditions' => (String)aCaseAnimal.get('ZTS_US_Concomitant_medical_conditions__c')};
            String caseAnimalErrorMessage = SL_CaseTriggerHelper.checkForSpecialCharactersAndOddQuotes('Case Patient',caseAnimalFieldsToCheckSpecialChars );
            if(String.isNotBlank(caseAnimalErrorMessage))errorMessage+=caseAnimalErrorMessage;
        }
        //CSE_573 To validate USDA Reportability rules
        String reportabilityErrors = validateAssessmentReportability(validatedCases);
        
        //CSE_569: To Validate the number of Assessments created and the to verify the required fieldset Validation.
        List<ZTS_US_Assessment__c> queriedAssessments = new List<ZTS_US_Assessment__c>();
        List<ZTS_US_Assessment__c> lstCaseAssessment = new List<ZTS_US_Assessment__c>();
        Map<Id, List<ZTS_US_Assessment__c>> mapCaseId_CaseAssessment = new Map<Id, List<ZTS_US_Assessment__c>>();
        queriedAssessments = [SELECT Id,
                                     Name,
                                     RecordType.DeveloperName,
                                     ZTS_US_Assessor__c,
                                     ZTS_US_Case__c,
                                     ZTS_US_Case__r.Type,
                                     ZTS_US_Dechallenge_PA__c,
                                     ZTS_US_Expected__c,
                                     ZTS_US_Local_Assessment__c,
                                     ZTS_US_Reason_for_Assessment_PA__c,
                                     ZTS_US_Expected_PA__c,
                                     ZTS_US_Rechallenge_PA__c,
                                     ZTS_US_Reportability__c,
                                     ZTS_US_Is_it_serious__c,
                                     ZTS_US_Assessment_PA__c, 
                                     (SELECT Id,
                                             ZTS_US_Assessment__c,
                                             ZTS_US_PVW_Product__c
                                         FROM Assessment_Products__r)
                                 FROM ZTS_US_Assessment__c
                                WHERE ZTS_US_Case__c IN :validatedCases];

        for( ZTS_US_Assessment__c objAssessment :queriedAssessments )
        {
            lstCaseAssessment = mapCaseId_CaseAssessment.containsKey( objAssessment.ZTS_US_Case__c ) ? mapCaseId_CaseAssessment.get( objAssessment.ZTS_US_Case__c )
                                                                                                                : new List<ZTS_US_Assessment__c>();

            lstCaseAssessment.add( objAssessment );
            mapCaseId_CaseAssessment.put( objAssessment.ZTS_US_Case__c, lstCaseAssessment );
            Map<String,String>assessmentFieldsToCheckSpecialChars = new Map<String, String>{'Reason for Assessment' => (String)objAssessment.get('ZTS_US_Reason_for_Assessment_PA__c')};
            String assessmentErrorMessage = SL_CaseTriggerHelper.checkForSpecialCharactersAndOddQuotes('Product Assessment',assessmentFieldsToCheckSpecialChars );
            if(String.isNotBlank(assessmentErrorMessage))errorMessage+=assessmentErrorMessage;
        }
        Id[] caseIdsWithoutErrors = new Id[]{};
        // iterate over the validated cases
        for ( Case aCase : validatedCases )       
        {    
            List<String> caseProductErrors = new List<String>();
            
            List<ZTS_US_Event_Narrative__c> listCaseNarrative1 = new List<ZTS_US_Event_Narrative__c>();
            ZTS_US_Event_Narrative__c caseNarrative1 = queriedNarrativesMap.get(aCase.ZTS_US_Event_Narrative__c);
            if(caseNarrative1 != null){
                listCaseNarrative1.add(caseNarrative1);
            }

            Map<String,String>narrativeFieldsToCheckSpecialChars = new Map<String, String>();
            narrativeFieldsToCheckSpecialChars.put('Event Narrative',(String)caseNarrative1?.get('ZTS_US_Event_Narrative_Summary_Field__c'));
            narrativeFieldsToCheckSpecialChars.put('Treatment',(String)caseNarrative1?.get('ZTS_US_Treatment__c'));
            narrativeFieldsToCheckSpecialChars.put('Abstract Summary',(String)caseNarrative1?.get('ZTS_US_Abstract_Summary__c'));
            String narrativeErrorMessage = SL_CaseTriggerHelper.checkForSpecialCharactersAndOddQuotes('Event Narrative',narrativeFieldsToCheckSpecialChars );
            if(String.isNotBlank(narrativeErrorMessage))errorMessage+=narrativeErrorMessage;

            System.debug('Inside aCase loop'+listCaseNarrative1);

            
            ValidateVeddraEventIfOutcomeChanges.validateVeddraCoding(aCase, listCaseNarrative1);

            Map<String,String>caseFieldsToCheckSpecialChars = new Map<String, String>();
            caseFieldsToCheckSpecialChars.put('Study Protocol',(String)aCase.get('ZTS_US_Study_Protocol__c'));
            caseFieldsToCheckSpecialChars.put('RMPDC',(String)aCase.get('ZTS_US_RMPDC__c'));
            String caseErrorMessage = SL_CaseTriggerHelper.checkForSpecialCharactersAndOddQuotes('Case',caseFieldsToCheckSpecialChars );
            if(String.isNotBlank(caseErrorMessage))errorMessage+=caseErrorMessage;

            if(aCase.ZTS_US_Is_it_serious_CA__c == 'Yes' && 
                ((aCase.ZTS_US_Date_Deemed_Serious__c == null) ||
                    (!aCase.ZTS_US_Death_CA__c && !aCase.ZTS_US_Life_Threatning_CA__c && !aCase.ZTS_US_Disabling_CA__c &&
                     !aCase.ZTS_US_Congen_Anom_CA__c && !aCase.ZTS_US_Other_CA__c))
            ){
                errorMessage+='When Company Assessment is marked as Serious, Date Deemed Serious and one of the condition related checkboxes are required.';
            }

            validateCaseFieldsForApproval(aCase, caseFields, idToCustomErrorMessages);
            List<Case_Contact__c> relatedCaseContacts = casesToCaseContactsMap.get( aCase.Id );
            
            
            if ( relatedCaseContacts == null || relatedCaseContacts.isEmpty() )
            {
                errorMessage += CASE_CONTACTS_ERROR; 
            }else{
                validateRelatedRecordsForApproval(aCase, relatedCaseContacts, caseContactFields, idToCustomErrorMessages);
                validateContactRecordsForApproval(aCase, relatedCaseContacts, queriedContactsMap, contactFields, idToCustomErrorMessages);
                //CSE-690 Added Case Role mandatory field on Case Contacts
                if(aCase.Type == 'Product Defect'|| aCase.Type == 'Animal Complaint' || aCase.Type == 'Human Exposure'){
                    Boolean atLeast1PrimRep = false;
                    for(Case_Contact__c caseCon : relatedCaseContacts){
                        if(caseCon.ZTS_US_Contact_Role__c == null || String.isBlank(caseCon.ZTS_US_Contact_Role__c)){
                            errorMessage += 'Case Contact Role is Missing. ';
                        }
                        if (caseCon.ZTS_US_Primary_Reporter__c == true) {
                            atLeast1PrimRep = true;
                        }
                    }
                    if (atLeast1PrimRep == false) {
                        errorMessage += 'Case must have at least 1 Primary Reporter Case Contact ';
                    }
                }
            }
            // Section below is where the bulk of the Case Product validation occurs
            List<ZTS_US_Case_Product__c> relatedCaseProducts = casesToCaseProductsMap.get( aCase.Id );
            
            if ( relatedCaseProducts == null || relatedCaseProducts.isEmpty() )
            { System.debug('inside if case products'+relatedCaseProducts);
                errorMessage += CASE_PRODUCTS_ERROR;

            }else{
                SL_CaseTriggerHelper.validateRelatedCaseProductsForApproval(aCase, relatedCaseProducts, idToCustomErrorMessages); //validateRelatedRecordsForApproval(aCase, relatedCaseProducts, productFields);
                if(allBatchDetails!=null && !allBatchDetails.isEmpty()){
                    validateRelatedRecordsForApproval(aCase, allBatchDetails, batchDetailFields, idToCustomErrorMessages);
                }
                for (ZTS_US_Case_Product__c caseProd : relatedCaseProducts){

                    if(caseProd.RecordType.DeveloperName == ZTS_RECORDTYPE){
                        if(String.isNotBlank(caseProd.ZTS_US_Product_problem_type__c)){
                            List<String> caseProdProblems = caseProd.ZTS_US_Product_problem_type__c.split(';');
                            if (caseProdProblems.contains('Lack of Efficacy')) {
                                if (String.isBlank(caseProd.ZTS_US_LOE_Reason__c)) {
                                    errorMessage += CASE_PRODUCT_LOE_ERROR;
                                }
                            }
                        }
                    }
                }
                
                Boolean roleProductCheck = false;
                for(ZTS_US_Case_Product__c obCaseProduct : relatedCaseProducts){
                    if(obCaseProduct.ZTS_US_Product_Role__c == 'Suspect Product')
                        roleProductCheck = true;
                }
                if(!roleProductCheck)
                    errorMessage += CASE_PRODUCTSROLE_ERROR;
            }
            
            List<ZTS_US_Case_Animal__c> relatedCaseAnimals = casesToCaseAnimalsMap.get( aCase.Id );
            // To validate mandatory fields on Patient records both Animal/Human
            if(aCase.Type != 'Product Defect'){
                if ( relatedCaseAnimals == null || relatedCaseAnimals.isEmpty() )
                {
                    errorMessage += CASE_ANIMALS_ERROR;
                }else{
                    validateAnimalRecordsForApproval(aCase, relatedCaseAnimals, queriedAnimalsMap, animalFields, caseAnimalFields, idToCustomErrorMessages);
                }

            }
            
            if(aCase.ZTS_US_Event_Narrative__c == null){
                errorMessage += CASE_EVENT_NARRATIVE_ERROR;
            }
            else
            {   
                System.debug('Inside the loop');
                List<ZTS_US_Event_Narrative__c> listCaseNarrative = new List<ZTS_US_Event_Narrative__c>();
                ZTS_US_Event_Narrative__c caseNarrative = queriedNarrativesMap.get(aCase.ZTS_US_Event_Narrative__c);
                listCaseNarrative.add(caseNarrative);
                ValidateVeddraEventIfOutcomeChanges.validateVeddraCoding(aCase, listCaseNarrative);
                validateRelatedRecordsForApproval(aCase, listCaseNarrative, narrativeFields, idToCustomErrorMessages);
                //checking case has event narrative and event narrative should have minimum 1 veddra event
                if(mapEventNarrativeIdToVedra.containsKey(aCase.ZTS_US_Event_Narrative__c) &&
                  mapEventNarrativeIdToVedra.get(aCase.ZTS_US_Event_Narrative__c) == 0){
                      errorMessage += VEDDRA_RECORD_MISSING;
                 }
                if ( narrativeToVeddraEvents != null && !narrativeToVeddraEvents.isEmpty() )
                {            
                    validateVeddraRecordsForApproval( aCase, narrativeToVeddraEvents, veddraFields,idToCustomErrorMessages );

                    List<ZTS_US_VedDRA_Event__c> caseVeddraEvents = narrativeToVeddraEvents.get(caseNarrative.Id);
                    String loeError = VmipsCaseService.validateCaseHasLOEProductAndCode(relatedCaseProducts, caseVeddraEvents);
                    if (String.isNotBlank(loeError)) {
                        caseProductErrors.add(loeError);
                    }

                    String unclassifiableError = VmipsCaseService.validateIfUnclassifiableEventRequired(aCase, relatedCaseProducts, caseVeddraEvents);
                    if (String.isNotBlank(unclassifiableError)) {
                        caseProductErrors.add(unclassifiableError);
                    }
                }
            }

            String anestheticError = VmipsCaseService.validateCaseIsSeriousForAnestheticLOEProduct(aCase,
                relatedCaseProducts, anestheticProductLines);

            if (String.isNotBlank(anestheticError)) {
                caseProductErrors.add(anestheticError);
            }

            //CSE_569: To display errors if Assessments are incomplete or missing validation in fieldsets.
            List<ZTS_US_Assessment__c> caseAssessments = mapCaseId_CaseAssessment.get( aCase.Id );
            String strAssesmentErrors = validateAssessmentRecords( aCase, casesToCaseProductsMap.get( aCase.Id ), caseAssessments);
            if( strAssesmentErrors <> STR_NO_ERRORS )
            {
                errorMessage += strAssesmentErrors;
            }

            String seriousValidationErrorMessage = VmipsCaseService.validateCaseAndLocalAsessmentSeriousMatch(aCase, caseAssessments);
            if (String.isNotBlank(seriousValidationErrorMessage)) {
                caseProductErrors.add(seriousValidationErrorMessage);
            }

            if (!String.isBlank(reportabilityErrors) ) 
            {
                errorMessage += reportabilityErrors;
               
            }

            if (!caseProductErrors.isEmpty()) {
                errorMessage += String.join(caseProductErrors, '');
            }
            
            if (String.isNotBlank( errorMessage ) ) 
            {
                addErrorToCustomErrors(aCase.Id,CASE_MISSING_TEXT + errorMessage + CASE_ERROR_TEXT, idToCustomErrorMessages );
            }
            caseIdsWithoutErrors.add(aCase.Id);
        }
        if(!caseIdsWithoutErrors.isEmpty()){
            SL_CaseTriggerHelper.setAuditTrailLock(caseIdsWithoutErrors);
        }
    }

     //CSE-573- To validate USDA Reportabilility rules
   @TestVisible
   private static String validateAssessmentReportability(List<Case> casesToProcess) {
       final String DIAG = 'DIAG';
       final String BIO = 'BIO';
       final String LOCALASSESSMENT_RT= 'ZTS_US_Local_Assessment';
       final String THREEDAY_ALERT = '3-day alert';
       final String FIFTEENDAY_ALERT = '15-day report';
       final String PERIODIC_REPORT = 'Periodic Report';
       final String NON_REPORTABLE = 'Non-Reportable';
       final String USDA = 'USDA';
       final String REQUIRED_FIELD_ERROR = 'USDA Reportability should be';
       final String REPORTABILITY_ERROR = 'Please add USDA Reportability on Assessment';
       Set<String> productProblem1 = new Set<String>{'Adverse Reaction','Human Exposure - Symptomatic','Lack of Efficacy'};
       Set<String> productProblem2 = new Set<String>{'(Associated) Product Defect'};
       Set<String> productProblem3 = new Set<String>{'Extra label Use','Residue Violation','Ecotoxicity','Human Exposure - Asymptomatic'};
       Set<Id> diagOrBioCases = new Set<Id>();
       Boolean diagExist = false;

       String errorMessage = '';
       
        //map to store the prod Id and related group problem numbers(1 and/or 2 and/or 3)
        Map<String, Set<Integer>> prodNameAndProblemNumber = new Map<String, Set<Integer>>();
       
        List<ZTS_US_Case_Product__c > caseProducts =   [SELECT Id, 
                                                       ZTS_US_Product_Agency__c, 
                                                       ZTS_US_PVW_Product__r.Name, 
                                                       ZTS_US_Case__c, 
                                                       ZTS_US_Product_problem_type__c,
                                                       ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c
                                                       FROM ZTS_US_Case_Product__c 
                                                       WHERE ZTS_US_Case__c IN: casesToProcess 
                                                       AND ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c IN ('DIAG', 'BIO') 
                                                       AND ZTS_US_Product_Agency__c =: USDA];

        if (caseProducts != null && !caseProducts.isEmpty()) {
            for(ZTS_US_Case_Product__c caseProd : caseProducts) {
           
                diagOrBioCases.add(caseProd.ZTS_US_Case__c);
                
                if (caseProd.ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c != null && caseProd.ZTS_US_Product_problem_type__c != null) {
                    if(caseProd.ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c == DIAG) {
                        diagExist = true;
                    } else { //Check Product Problem Type for BIO category products
                        List<String> caseProdProblems = caseProd.ZTS_US_Product_problem_type__c.split(';');
                        System.debug('cas prod '+ caseProd);
                        
                        //To identify the Product Problem Type for each Case product
                        for(String prodPrb : caseProdProblems) {
                            Set<Integer> groupPrblmNums = prodNameAndProblemNumber.get(caseProd.ZTS_US_PVW_Product__c);
                            if(groupPrblmNums == null) groupPrblmNums = new Set<Integer>();
                            
                            if(productProblem1.contains(prodPrb)) {
                                groupPrblmNums.add(1);
                            } else if(productProblem2.contains(prodPrb)) {
                                groupPrblmNums.add(2);
                            } else if(productProblem3.contains(prodPrb)) {
                                groupPrblmNums.add(3);
                            } 
                            
                            prodNameAndProblemNumber.put(caseProd.ZTS_US_PVW_Product__c, groupPrblmNums);
                        }
                    }
                }
             }
        }
        
        System.debug('prodNameAndProblemNumber' + prodNameAndProblemNumber);
        List < ZTS_US_Assessment__c > assessments = [SELECT
                                                   ZTS_US_Reportability__c, 
                                                   RecordType.DeveloperName,
                                                   ZTS_US_Local_Assessment__c, 
                                                   ZTS_US_Case__c,
                                                   ZTS_US_Products__c,
                                                   ZTS_US_Assessment_PA__c,
                                                   ZTS_US_Expected_PA__c,
                                                   ZTS_US_Is_it_serious__c,
                                                   (SELECT ZTS_US_PVW_Product__c,
                                                       ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c,
                                                       ZTS_US_PVW_Product__r.Name
                                                   FROM Assessment_Products__r
                                                   WHERE ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c IN('DIAG', 'BIO')
                                                   ) 
                                                   FROM ZTS_US_Assessment__c
                                                   WHERE ZTS_US_Case__c =: diagOrBioCases
                                                   AND ZTS_US_Reportability__c !=: THREEDAY_ALERT
                                                   ORDER BY RecordType.DeveloperName ASC];
          
       Map<String, ZTS_US_Assessment__c> localAssessMap = new Map<String, ZTS_US_Assessment__c>();
       Map<String, List<ZTS_US_Assessment__c>> prodAssessMap = new Map<String, List<ZTS_US_Assessment__c>>();
       Set<String> localRelatedProds = new Set<String>();

       Boolean casualityAssesmentError = false;
       Boolean casualityAssesmentNoError = false;
       Boolean otherCasualityAssesmentErr = false;
       Boolean digaError = false;
       Boolean groupPrblm2Err = false;
       Boolean groupPrblm3Err = false;

       for(ZTS_US_Assessment__c assessment : assessments) {
           //Local assessment record type
           if(assessment.RecordType.DeveloperName == LOCALASSESSMENT_RT){
               //Iterate and hold the related 'Assessments Product ID's' from current 'Local Assessment'
               for(ZTS_US_Assessment_Products__c prodAssess : assessment.Assessment_Products__r){
                   localRelatedProds.add(prodAssess.ZTS_US_PVW_Product__c);
               }

               if(assessment.ZTS_US_Local_Assessment__c == USDA) {
                   if(diagExist && (String.IsBlank(assessment.ZTS_US_Reportability__c) || assessment.ZTS_US_Reportability__c== null)) {
                       digaError = true;
                   }
                   localAssessMap.put(USDA, assessment);
               }
            
           } else { //Product Assessments recordtype
               
               for(ZTS_US_Assessment_Products__c prodAssess : assessment.Assessment_Products__r) {
                   if(prodAssess.ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c == BIO) {
                       String prodId = prodAssess.ZTS_US_PVW_Product__c;
                       //Check the current Product belongs to USDA Local Assessment 
                       if(localRelatedProds.contains(prodId)) {
                           //get the USDA Local Assessment 
                           ZTS_US_Assessment__c localAssess = localAssessMap.get(USDA);
                           //identify the currenct Product Problem group,then get the associated values (1 or 2 or 3)
                           //if the Prodcut does not belongs to any Problem group, then assing 0 (to avoid null values)
                           Set<Integer> productPrblmNums = prodNameAndProblemNumber.get(prodId) != null ? prodNameAndProblemNumber.get(prodId) : new Set<Integer>();
                         
                           //check if current Product problem belongs to problemGroup1 as defined initially
                           if(productPrblmNums.contains(1)) {
                            System.debug('prodId ' +prodId);
                            System.debug('productPrblmNum' +productPrblmNums);
                               if(localAssess.ZTS_US_Is_it_serious__c == 'Yes' && 
                                   (assessment.ZTS_US_Expected_PA__c == 'No'&&
                                   (assessment.ZTS_US_Assessment_PA__c == 'A - Probable/High' || 
                                   assessment.ZTS_US_Assessment_PA__c == 'B - Possible/Medium'))) {
                                       casualityAssesmentNoError = true;
                                       if(localAssess.ZTS_US_Reportability__c != FIFTEENDAY_ALERT) {
                                           casualityAssesmentError = true;
                                       }
                               } else if(localAssess.ZTS_US_Reportability__c != PERIODIC_REPORT){
                                   otherCasualityAssesmentErr = true;
                               }
                           }  else if(productPrblmNums.contains(3)) { //check current product problem belongs to problemGroup3 as defined initially
                               if(localAssess.ZTS_US_Reportability__c != NON_REPORTABLE) {
                                   groupPrblm3Err = true;
                               }
                           } else if(productPrblmNums.contains(2)) {  //check current product problem belongs to problemGroup2 as defined initially
                               if(localAssess.ZTS_US_Reportability__c == null) {
                                   groupPrblm2Err = true;
                               }
                           }
                       }
                   }
               }
               
           }
        }
        
       if(casualityAssesmentError) {
            errorMessage =  REQUIRED_FIELD_ERROR +' '+ FIFTEENDAY_ALERT;
       } else if(!casualityAssesmentError && !casualityAssesmentNoError && otherCasualityAssesmentErr){
            errorMessage =  REQUIRED_FIELD_ERROR +' '+ PERIODIC_REPORT;
       } else if(groupPrblm3Err) {
            errorMessage =  REQUIRED_FIELD_ERROR +' '+ NON_REPORTABLE; 
       } else if(groupPrblm2Err || digaError) {
            errorMessage =  REPORTABILITY_ERROR;
       } 
       return errorMessage;
    }
    @TestVisible
    private static void validateCaseFieldsForApproval( Case aCase, Set<String> fieldSetMembers, Map<Id, List<String>> idToCustomErrorMessages )
    {
        if ( aCase == null || fieldSetMembers == null || fieldSetMembers.isEmpty() )
        {
            return;
        }
        for ( String field : fieldSetMembers )
        {
            if ( aCase.get( field ) == null )
            {
                // aCase.addError( String.format( CASE_MISSING_REQUIRED_FIELD, new List<String>{ (String)Schema.getGlobalDescribe().get(aCase.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(field).getDescribe().getLabel(), aCase.getSObjectType().getDescribe().getLabel() } ) );
                List<String> errorMessages = new List<String>();
                errorMessages.add( String.format( CASE_MISSING_REQUIRED_FIELD, new List<String>{ (String)Schema.getGlobalDescribe().get(aCase.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(field).getDescribe().getLabel(), aCase.getSObjectType().getDescribe().getLabel() } ) );
                
                              
                addErrorToCustomErrors(aCase.Id, errorMessages,  idToCustomErrorMessages);
            }
        }

    }

    /**
     * Helper method to validate that a required field on a related record is populated for the Send to PV Works Approval validation
     * 
     * @param Case aCase - related case that we need to add the error to
     * @param List<SObject> relatedRecords - list of related records we want to iterate over to validate
     * @param Set<String> fieldSetMembers - set of field api names from the field set on the corresponding object
     * 
     * @return void 
     */
    public static void validateRelatedRecordsForApproval( Case aCase, List<SObject> relatedRecords, Set<String> fieldSetMembers, Map<Id, List<String>> idToCustomErrorMessages)
    {
        if ( aCase == null || relatedRecords == null || relatedRecords.isEmpty() || fieldSetMembers == null || fieldSetMembers.isEmpty() )
        {
            System.debug( 'missing required inputs for SL_CaseTriggerHandler::validateRelatedRecordsForApproval' );
            return;
        }
        
        // now lets iterate over each of our records and make sure it has a value for each of the field set fields
        for ( SObject relatedRecord : relatedRecords )
        {
            //Boolean errorThrown = false;
            for ( String aField : fieldSetMembers )
            {
                if ( relatedRecord.get( aField ) == null )
                {
                    System.debug( '****aField 1971' +aField);
                    List<String> errorMessages = new List<String>();
                    errorMessages.add( String.format( MISSING_REQUIRED_FIELD_ON_RELATED_RECORD, new List<String>{ relatedRecord.getSObjectType().getDescribe().getLabel(), (String)Schema.getGlobalDescribe().get(relatedRecord.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(aField).getDescribe().getLabel() } ) );
                    
                 
                    addErrorToCustomErrors(aCase.Id, errorMessages, idToCustomErrorMessages);

                  
                }
            }
        }

    }
     public static final String CONTACT_MAILING_FIELDSET_NAME = 'Regex_Validation'; 
    public static void validateContactRecordsForApproval (Case aCase, List<Case_Contact__c> caseContactRecords, Map<Id, Contact> queriedContactsMap, Set<String> fieldSetMembers,Map<Id, List<String>> idToCustomErrorMessages) {
        // assumption: case has been checked to see if it meets the requirements to be validated (vmips RT, Type in one of the types that should be checked, sync status = ready to sync):394
        // get the case contact records: done in earlier method
        // pluck out the contact ids and put them in a set: done in earlier method
        // query for contact records and put in Map<Id, Contact>: done in earlier method
        // iterate over case contact records


        //calling validateContactMailingCountry method in CSE_ValidateContactMailingCountry
        CSE_ValidateContactMailingCountry.validateContactMailingCountry(caseContactRecords,queriedContactsMap,fieldSetMembers);
        
        if ( aCase == null || caseContactRecords == null || caseContactRecords.isEmpty() || fieldSetMembers == null || fieldSetMembers.isEmpty() )
        {
            System.debug( 'missing required inputs for SL_CaseTriggerHandler::validateContactRecordsForApproval' );
            return;
        }

        //get all contactId related to the case contact
        List<Id> contactIds = new List<Id>();
        
        for ( Case_Contact__c caseContactRecord : caseContactRecords )
        {         
            // get animal record from the queried animal map
            ID contactId = caseContactRecord.Contact__c;
            contactIds.add(contactId);
            Contact contactRecord = queriedContactsMap.get(contactId);
            //TPDEV-1797/TPDEV-996 - Validation to check CaseContact.Email or Case.Do not notify reporter 
            if(caseContactRecord.ZTS_US_Primary_Reporter__c && caseContactRecord.Email__c == null && aCase.ZTS_US_Do_Not_Notify_Reporter__c == false){
            // aCase.addError(System.label.CSE_CaseSendtoPVWorksError);
            List<String> errorMessages = new List<String>();
            errorMessages.add(System.label.CSE_CaseSendtoPVWorksError);
                
                addErrorToCustomErrors(aCase.Id, errorMessages, idToCustomErrorMessages);
           

            }
            
            // run through validation check
            for ( String aField : fieldSetMembers )
            {               
                
                if ( contactRecord.get( aField ) == null )
                {
                    // if failed, add error to the related case 
                    List<String> errorMessages = new List<String>();
                    errorMessages.add(String.format( MISSING_REQUIRED_FIELD_ON_RELATED_RECORD, new List<String>{ contactRecord.getSObjectType().getDescribe().getLabel(), (String)Schema.getGlobalDescribe().get(contactRecord.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(aField).getDescribe().getLabel() } ) );
                  
                    addErrorToCustomErrors(aCase.Id, errorMessages, idToCustomErrorMessages);
                   
                    
                }
                
            }
    
          
        }
        //get all the fields from the Regex Validation fieldset
        Set<String> cntctMailingFields = CSE_RegexUtility.getFieldsApiName('Contact', CONTACT_MAILING_FIELDSET_NAME);

        String contactFieldsToQuery = '';
        if(cntctMailingFields !=null && cntctMailingFields.size() > 0){
            contactFieldsToQuery = String.join( new List<String>( cntctMailingFields ), ', ' );
            contactFieldsToQuery = contactFieldsToQuery.leftPad((contactFieldsToQuery.length()+1), ',');
        } 
        
        String contactRecordQueryString = 'SELECT Id ' + contactFieldsToQuery +
                                          ' FROM Contact ' + 
                                          ' WHERE Id IN :contactIds ';


        
        List<Contact> queriedContactRecord = (List<Contact>) Database.query(contactRecordQueryString);

        //Checking Regex on Mailing address field contains any ASCII character
        // get the contact fields
        // update frist check to check if field is in API list
        for(String aCntctMailingField: cntctMailingFields)
        {
            //Boolean errorThrown = false;
            for(Contact eContact: queriedContactRecord)
            {
                if(cntctMailingFields.contains(aCntctMailingField) && eContact.get( aCntctMailingField ) != null && !CSE_RegexUtility.isRegexValid((String)eContact.get( aCntctMailingField )))
                {
                    List<String> errorMessages = new List<String>();
                    errorMessages.add( String.format( CONTACT_ADDRESS_REGEX_ERROR, new List<String>{ eContact.getSObjectType().getDescribe().getLabel(), (String)Schema.getGlobalDescribe().get(eContact.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(aCntctMailingField).getDescribe().getLabel() } ) );
                    
                  addErrorToCustomErrors(aCase.Id, errorMessages, idToCustomErrorMessages);
                    
                    
                } 

            }
     
        }
    }

    public static void validateAnimalRecordsForApproval (Case aCase, List<ZTS_US_Case_Animal__c> caseAnimalRecords, Map<Id, ZTS_US_Animal__c> queriedAnimalsMap, Set<String> animalFieldSet, Set<String> caseAnimalFieldSet,Map<Id, List<String>> idToCustomErrorMessages) {
    // assumption: case has been checked to see if it meets the requirements to be validated (vmips RT, Type in one of the types that should be checked, sync status = ready to sync):394
    // get the case animal records: done in earlier method
    // pluck out the animal ids and put them in a set: done in earlier method
    // query for animal records and put in Map<Id, Animal>: done in earlier method
    // iterate over case animal records
    if ( aCase == null || caseAnimalRecords == null || caseAnimalRecords.isEmpty() || animalFieldSet == null || animalFieldSet.isEmpty() || caseAnimalFieldSet == null || caseAnimalFieldSet.isEmpty())
    {
        return;
    }
    for ( ZTS_US_Case_Animal__c caseAnimalRecord : caseAnimalRecords )
    {
        //Boolean errorThrown = false;
        // get animal record from the queried animal map
        ID AnimalId = caseAnimalRecord.ZTS_US_Animal__c;
        ZTS_US_Animal__c animalRecord = queriedAnimalsMap.get(AnimalId);
        Set<String> unknownAgeValues = new Set<String>{'Unknown','NA','Not applicable'};
        //if the patient is a human, make sure the corresponding age fields are filled on both the patient and case patient, unless marked as unknown
        if(animalRecord!=null && caseAnimalRecord.RecordType.DeveloperName == 'Human' && 
            (((animalRecord.ZTS_US_Age_text__c == null || animalRecord.Age_units__c == null) && !unknownAgeValues.contains(animalRecord.Age_units__c))
            ||((caseAnimalRecord.ZTS_US_Age_text__c == null || caseAnimalRecord.Age_units__c == null) && !unknownAgeValues.contains(caseAnimalRecord.Age_units__c)))){
                // aCase.addError(CASE_ANIMAL_AGE_ERROR);
                List<String> errorMessages = new List<String>();
                errorMessages.add(CASE_ANIMAL_AGE_ERROR);
                // aCase.addError(new SendToPVWorksValidationException(CASE_ANIMAL_AGE_ERROR));
               addErrorToCustomErrors(aCase.Id, errorMessages, idToCustomErrorMessages);

               
        }
        //if the patient is an animal, make sure the corresponding age fields are filled on both the patient and case patient, unless marked as unknown
        else if(animalRecord!=null && caseAnimalRecord.RecordType.DeveloperName == 'Animal' && 
                (((animalRecord.ZTS_US_Age_from__c == null || animalRecord.ZTS_US_Age_unit_from__c == null) && !unknownAgeValues.contains(animalRecord.ZTS_US_Age_unit_from__c))
                ||((caseAnimalRecord.ZTS_US_Age_from__c == null || caseAnimalRecord.ZTS_US_Age_unit_from__c == null) && !unknownAgeValues.contains(caseAnimalRecord.ZTS_US_Age_unit_from__c)))){
            // aCase.addError(CASE_ANIMAL_AGE_ERROR);
            List<String> errorMessages = new List<String>();
            errorMessages.add(CASE_ANIMAL_AGE_ERROR);
               
            addErrorToCustomErrors(aCase.Id, errorMessages, idToCustomErrorMessages);
            
        }

        // run through field validation check
        for ( String animalField : animalFieldSet )
        {
            if ( animalRecord.get( animalField ) == null )
            {
                // if failed, add error to the related case 
                List<String> errorMessages = new List<String>();
                errorMessages.add(String.format( MISSING_REQUIRED_FIELD_ON_RELATED_RECORD, new List<String>{ animalRecord.getSObjectType().getDescribe().getLabel(), (String)Schema.getGlobalDescribe().get(animalRecord.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(animalField).getDescribe().getLabel() } ) );
                
               
                addErrorToCustomErrors(aCase.Id, errorMessages, idToCustomErrorMessages);

               
            }
        }
         // run through field validation check
         for ( String caseAnimalField : caseAnimalFieldSet )
         {
             if ( caseAnimalRecord.get( caseAnimalField ) == null )
             {
                 // if failed, add error to the related case 
                List<String> errorMessages = new List<String>();
                errorMessages.add( String.format( MISSING_REQUIRED_FIELD_ON_RELATED_RECORD, new List<String>{ caseAnimalRecord.getSObjectType().getDescribe().getLabel(), (String)Schema.getGlobalDescribe().get(caseAnimalRecord.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(caseAnimalField).getDescribe().getLabel()} ) );
               
               
                 addErrorToCustomErrors(aCase.Id, errorMessages, idToCustomErrorMessages);
 
              
             }
         }
    }
    }
    @TestVisible
    private static void validateVeddraRecordsForApproval( Case aCase, Map<Id, List<ZTS_US_VedDRA_Event__c>> narrativeToVeddraEvents, Set<String> fieldSetMembers,Map<Id, List<String>> idToCustomErrorMessages)        
    {
        if ( aCase == null || aCase.ZTS_US_Event_Narrative__c == null || narrativeToVeddraEvents == null || narrativeToVeddraEvents.isEmpty() || fieldSetMembers == null || fieldSetMembers.isEmpty() )
        {
            return;
        }

        List<ZTS_US_VedDRA_Event__c> relatedVeddraEvents = narrativeToVeddraEvents.get( aCase.ZTS_US_Event_Narrative__c );
        for ( ZTS_US_VedDRA_Event__c aVeddraEvent : relatedVeddraEvents )
        {
            for ( String field : fieldSetMembers )
            {
                if ( aVeddraEvent.get( field ) == null )
                {
                    List<String> errorMessages = new List<String>();
                    errorMessages.add( String.format( MISSING_REQUIRED_FIELD, new List<String>{ aVeddraEvent.Name, (String)Schema.getGlobalDescribe().get(aVeddraEvent.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(field).getDescribe().getLabel()} ) );

                    addErrorToCustomErrors(aCase.Id, errorMessages, idToCustomErrorMessages);
                    
                }
            }
        }
    }
     //Story CSE_569: To validate Case Assessments and the required Case Assessment fields before sending it to PV Works
    @TestVisible
    private static String validateAssessmentRecords( Case currentValidatedCase, List<ZTS_US_Case_Product__c> lstQueriedProducts, List<ZTS_US_Assessment__c> lstQueriedAssessments ){
    
        List<FieldSetMember> acLocalFields = Schema.SObjectType.ZTS_US_Assessment__c.fieldSets.AC_Local_Validation_Check.getFields();
        List<FieldSetMember> acProductFields = Schema.SObjectType.ZTS_US_Assessment__c.fieldSets.AC_Product_Validation_Check.getFields();
        List<FieldSetMember> heLocalFields = Schema.SObjectType.ZTS_US_Assessment__c.fieldSets.HE_Local_Validation_Check.getFields();
        List<FieldSetMember> heProductFields = Schema.SObjectType.ZTS_US_Assessment__c.fieldSets.HE_Product_Validation_Check.getFields();
        List<FieldSetMember> pdLocalFields = Schema.SObjectType.ZTS_US_Assessment__c.fieldSets.PD_Local_Validation_Check.getFields();
        List<FieldSetMember> pdProductFields = Schema.SObjectType.ZTS_US_Assessment__c.fieldSets.PD_Product_Validation_Check.getFields();
        // Empty field set variable to store the relevant List<FieldSetMember> later on
        List<FieldSetMember> fieldSetVar = new List<FieldSetMember>();
    
        set<String> setLocalAssessmentProductAgency = new Set<String>();
        set<String> setCaseProductProductAgency = new Set<String>();
        set<Id> setProductAssessmentsPVWProductId = new Set<Id>();
        set<Id> setCaseProductsPVWProductId = new Set<Id>();

        if( lstQueriedProducts <> NULL && !lstQueriedProducts.isEmpty() ){
            for( ZTS_US_Case_Product__c aCaseProduct : lstQueriedProducts )
            {
                if( aCaseProduct.ZTS_US_Product_Role__c == ROLE_SUSPECT_PRODUCT /*&& aCaseProduct.ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c != 'OTHR'*/)
                {
                    //adding the agency represented on the Case Product to a set
                    setCaseProductProductAgency.add( aCaseProduct.ZTS_US_Product_Agency__c );
                    
                    //adding the PVW Product on the Case Product to a set
                    setCaseProductsPVWProductId.add(aCaseProduct.ZTS_US_PVW_Product__c );
                }
            }
        }
        else{
            return CASE_PRODUCTS_ERROR;
        }

		Boolean isValidationErrorlocalAssessment;
        if( lstQueriedAssessments <> NULL && !lstQueriedAssessments.isEmpty())
        {
            for( ZTS_US_Assessment__c objAssessment :lstQueriedAssessments )
            {
                //To validate the Local Assessments created
                if( objAssessment.RecordType.DeveloperName == RECORDTYPE_ASSESMENT_LOCAL  )
                {
                
                    if(objAssessment.ZTS_US_Reportability__c <> 'Non-Reportable' && currentValidatedCase.ZTS_US_Information_Type__c <> 'Erred' && currentValidatedCase.ZTS_US_Information_Type__c <>'Reportable')
                    {
                        return CASE_INFORMATION_TYPE_ASSESSMENT_REPORTABILITY;
                    }
                    
                    
                    //add the agency of that Assessment to a set
                    setLocalAssessmentProductAgency.add( objAssessment.ZTS_US_Local_Assessment__c );
                }
                //To validate the Product Assessments created
                else if( objAssessment.RecordType.DeveloperName == RECORDTYPE_ASSESMENT_PRODUCT )
                {
                    for( ZTS_US_Assessment_Products__c objAssessment_Product :objAssessment.Assessment_Products__r )
                    {   
                        //add the Assessment Products- PVW Product Id to a set
                        setProductAssessmentsPVWProductId.add( objAssessment_Product.ZTS_US_PVW_Product__c );
                    }
                }
            }
            //To verify that each agency represented has atleast one Local Assessment created
            if( !setLocalAssessmentProductAgency.containsAll( setCaseProductProductAgency ) )
            {
                return CASE_ASSESSMENT_ERROR;
            } else if (setLocalAssessmentProductAgency.containsAll(setCaseProductProductAgency)  && setLocalAssessmentProductAgency.size() >  setCaseProductProductAgency.size()) {
                return EXTRA_ASSESSMENT_ERROR;
            }
            //To verify that each Case Product created has atleast one Product Assessment created
            if( !setProductAssessmentsPVWProductId.containsAll( setCaseProductsPVWProductId ) )
            {
                return CASE_ASSESSMENT_ERROR;
            } else if (setProductAssessmentsPVWProductId.containsAll(setCaseProductsPVWProductId) && setProductAssessmentsPVWProductId.size() >  setCaseProductsPVWProductId.size()) {
                return EXTRA_ASSESSMENT_ERROR;
            }

            for( ZTS_US_Assessment__c objAssessment :lstQueriedAssessments )
            {

                //To validate FieldSet Values For Local assessments.
                if( objAssessment.RecordType.DeveloperName == RECORDTYPE_ASSESMENT_LOCAL )
                {
                    if (currentValidatedCase.Type == 'Animal Complaint') {
                        fieldSetVar = acLocalFields;
                    } else if (currentValidatedCase.Type == 'Human Exposure') {
                        fieldSetVar = heLocalFields;
                    } else if (currentValidatedCase.Type == 'Product Defect') {
                        fieldSetVar = pdLocalFields;
                    }

                    for( FieldSetMember objFSMember: fieldSetVar )
                    {
                        String strField = objFSMember.getFieldPath();
                        //If any of the field is NULL return a validation error
                        if( NULL == objAssessment.get( strField ) )
                        {  
                           return String.format( MISSING_REQUIRED_FIELD_ON_RELATED_RECORD, new List<String>{ (objAssessment.getSObjectType().getDescribe().getLabel()+' '+objAssessment.Name), (String)Schema.getGlobalDescribe().get(objAssessment.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(strField).getDescribe().getLabel()} );
                        }
                    }
                }

                //To validate FieldSet Values For Product assessments.
                if( objAssessment.RecordType.DeveloperName == RECORDTYPE_ASSESMENT_PRODUCT )
                {
                    if (currentValidatedCase.Type == 'Animal Complaint') {
                        fieldSetVar = acProductFields;
                    } else if (currentValidatedCase.Type == 'Human Exposure') {
                        fieldSetVar = heProductFields;
                    } else if (currentValidatedCase.Type == 'Product Defect') {
                        fieldSetVar = pdProductFields;
                    }

                    for( FieldSetMember objFSMember: fieldSetVar )
                    {
                        String strField = objFSMember.getFieldPath();
                        //If any of the field is NULL return a validation error
                        if( NULL == objAssessment.get( strField ) )
                        {
                            return String.format( MISSING_REQUIRED_FIELD_ON_RELATED_RECORD, new List<String>{ (objAssessment.getSObjectType().getDescribe().getLabel()+' '+objAssessment.Name), (String)Schema.getGlobalDescribe().get(objAssessment.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(strField).getDescribe().getLabel() } );
                        }
                    }
                    if ( currentValidatedCase.Type == 'Animal Complaint' || currentValidatedCase.Type == 'Human Exposure' )
                    {
                        if(String.isBlank(objAssessment.ZTS_US_Assessment_PA__c))
                        {
                            return String.format( MISSING_REQUIRED_FIELD_ON_RELATED_RECORD, new List<String>{ (objAssessment.getSObjectType().getDescribe().getLabel()+' '+objAssessment.Name), (String)Schema.getGlobalDescribe().get(objAssessment.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get('ZTS_US_Assessment_PA__c').getDescribe().getLabel() });
                            // return String.format( MISSING_REQUIRED_FIELD_ON_RELATED_RECORD, new List<String>{ (objAssessment.getSObjectType().getDescribe().getLabel()+' '+objAssessment.Name), 'ZTS_US_Assessment_PA__c' });
                           
                        }
                    }
                }
            }
        } else {
            // Else, related Assessments are empty, but they should not be
            return CASE_ASSESSMENT_ERROR;
        }
        return STR_NO_ERRORS;
    }//end of validateAssessmentRecords
}