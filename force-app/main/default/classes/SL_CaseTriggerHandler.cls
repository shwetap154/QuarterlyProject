/**
 * @description       : Handler class for the ZTS_EU_ServiceRequest trigger.
 * @author            : Akshay Agrawal @ Unknown
 * @group             : 
 * @last modified on  : 11-15-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   10-16-2019   Akshay Agrawal @ Unknown    Initial Version
 * 1.1   Unknown      Poonam Dalvi @ Unknown      Unknown Updates
 * 1.2   03-23-2022   Ethan Hirsch @ Zoetis Inc   Fix a bug in beforeInsertUpdateOnBoardingCaseStatus with updating the same Account multiple times.
 * 1.3   03-24-2022   Ethan Hirsch @ Zoetis Inc   Replace createMDMBeforeInsertOnboarding method with CaseService.determineReferenceLabsShipToAddress and CaseService.createDataRequestChildCasesForRefLabsOnboardingCase
 *                                                Remove variables only used by createMDMBeforeInsertOnboarding or not in use. Pull common variables from CaseService.
 *                                                Move logic for setting Entitlement Id on Diagnostic Cases to CaseService.setDiagnosticEntitlementOnCase
 * 1.4 03-31-2022     Ethan Hirsch @ Zoetis Inc   Whitespace adjustments.
 * 1.5   05-09-2022   Ethan Hirsch @ Zoetis Inc   Remove beforeInsertUpdateOnBoardingCaseStatus method. This has been moved to DiagnosticCaseService
 * 1.6   06-20-2022   Ethan Hirsch @ Zoetis Inc   Add logic to sendCaseForApproval to call validateCaseHasLOEProductAndCode method to validate a 
 *                                                VMIPS Case has correct data for Lack of Efficacy.
 * 1.7   07-08-2022   Ethan Hirsch @ Zoetis Inc   Add logic to sendCaseForApproval to call validateCaseIsSeriousForAnestheticLOEProduct method to validate a 
 *                                                VMIPS Case has correct data for Lack of Efficacy Anesthetic Product.
 * 1.8   07-12-2022   Ethan Hirsch @ Zoetis Inc   Move validateUnclassifiableAdverseEventForApproval method to VmipsCaseService and rename to validateCaseIsSeriousForAnestheticLOEProduct
 *                                                Change how this is called to make sure it only the VedDRA Events on the Case being validated.
 * 1.9   11-03-2022   Ethan Hirsch @ Zoetis Inc   Update beforeInsertRefLabsPortalCases to set Market on Case using the Account so that Market is set on these Cases.
 *                                                This replicates logic in the Case Before Insert/Update Flow that sets Market based on Account.
 * 1.10  11-15-2022   Ethan Hirsch @ Zoetis Inc   Update onBeforeInsert and cloneRelatedList so that VMIPS Cases have field that should not be cloned beforeInsert and the fields are cleared before Event Narrative is checked.
 *                                                Also update cloneRelatedList to clone record type and non Zoetis Product fields are cloned on Case Products.
 * 1.11  10-31-2023   S. Mitra/ MImas             onBeforeInsert & onBeforeUpdate to make sure DX Users hit validation error when selected Primary Consumable Market is not equal to Account Market
**/
public with sharing class SL_CaseTriggerHandler {
    
    static final String REFLABS_ONBOARDING_CASE_NO_CONTACT_ERROR = Label.RefLabs_Onboarding_Case_No_Contact_Error;
    static final String REFLABS_DUPLICATE_ONBOARDING_CASE_ERROR = Label.RefLabs_Duplicate_Onboarding_Case_Error;
    static final  String ZTS_RECORDTYPE = 'Zoetis_Product';    
    //Error message text constants
    @testVisible static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    @TestVisible private static final String REQUIRED_FIELD_NULLED = 'The field {0} on {1} cannot be set to null when it\'s related Case is marked as Ready to Sync (for PV Works) ';
    @testVisible static final String RECORDTYPE_ASSESMENT_LOCAL = 'ZTS_US_Local_Assessment';
   
    static String refLabsSupportRecordTypeId
    {
        get
        {
            if ( refLabsSupportRecordTypeId == null ) refLabsSupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Reference_Labs_Support' ).getRecordTypeId();
            return refLabsSupportRecordTypeId;
        }
        private set;
    }

    static String refLabsOnboardingRecordtypeId
    {
        get
        {
            return CaseService.refLabsOnboardingRecordtypeId;
        }
    }

    //get Recordtype id CSE- 114
    static string animalRecordtypeId
    {
     get{
      animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId(); 
      return animalRecordtypeId;
    }
      private set;
        
    }


    static string localAssesmentRecordTypeId
    {
     get{
        localAssesmentRecordTypeId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_ASSESMENT_LOCAL).getRecordTypeId(); 
      return localAssesmentRecordTypeId;
    }
      private set;
        
    }

    /***********
    * Method name  : onBeforeInsert
    * Description  : This method call on before insert trigger event and process the data.
    * Return Type  : NA
    * Parameters   : lstNewCases.
    ***********/
    public void onBeforeInsert(List<Case> lstNewCases) {
        List<Case> lstDiagnosticsCases = new List<Case>();
        //Variable added for TPDEV - 307
        List<Case> lstDiagnosticsCaseValid = new List<Case>();
        List<Case> clonedDiagnosticCases = new List<Case>();
        Case[] clonedCasesToValidate = new Case[]{};
        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
         System.debug('We are on Before insert ***');
        // Process Cloned data before running any other validation or processing
        // This is primarily done so that SL_CaseTriggerHelper.preventEventNarrativeReparenting does not fire
        for(Case obj: lstNewCases) {
            // check if it is animal record type.
            if(animalRecordtypeId == obj.RecordTypeId && obj.isClone()){
                clonedCasesToValidate.add(obj);
              obj.ZTS_EU_Case_ID__c = ''; 
              obj.Status = 'New';
              obj.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_UNAPPROVED;
              // Clear out fields that were previously cleared in cloneRelatedList from CSE-114
              obj.ZTS_US_Date_First_Valid__c = null;
              obj.ZTS_US_First_Received_Date__c = null;
              obj.ZTS_US_Event_Narrative__c = null;
              obj.ZTS_US_Information_Type__c = null;
            }
            if(obj.RecordTypeId == diagRecordTypeId) {
                lstDiagnosticsCases.add(obj);
                //for validating Case Primary Consumable and Market for @ TPDEV-307
                lstDiagnosticsCaseValid.add(obj);
                // check if cases are cloned cases
                if(obj.isClone()){
                    clonedDiagnosticCases.add(obj);
                }
            }
            
        }

        SL_CaseTriggerHelper.preventEventNarrativeReparenting( SL_CaseTriggerHelper.filterNewCasesForEventNarratives( lstNewCases ) );

        beforeInsertUpdatePrimaryLabLocation(lstNewCases,Null);
        beforeInsertRefLabsPortalCases(lstNewCases);

        //Call to check for RefLabs Onboarding Cases and crete child Data request Cases - SFDCATS-419
        CaseService.determineReferenceLabsShipToAddress(lstNewCases, null);


        if(!clonedCasesToValidate.isEmpty()){
            validateClonedCases(clonedCasesToValidate);
        }
        if(!clonedDiagnosticCases.isEmpty()){
            resetFieldsWhenCloned(clonedDiagnosticCases);
        }
        
        //Section added for calling the method for Market Validation on Case Primary Consumable - TPDEV 307
        if(!lstDiagnosticsCaseValid.isEmpty()){
            checkDiagnosticsCaseValidation(lstDiagnosticsCaseValid);
        }
        
        if(!lstDiagnosticsCases.isEmpty())
        {
            checkLevel1Support( lstDiagnosticsCases );
           CaseService.setDiagnosticEntitlementOnCase(lstDiagnosticsCases);
        }
    }
    public static void validateClonedCases(Case[] clonedCases) {
        Id[] cloneParentIdByCloneChildId = new Id[]{};
        for(Case clonedCase : clonedCases){
            cloneParentIdByCloneChildId.add(clonedCase.getCloneSourceId());
        }
        Map<id,String> badParentCases = new Map<id,String>();
        ZTS_US_Case_Product__c[] badCaseProducts = [SELECT Id,ZTS_US_Case__c,ZTS_US_Case__r.CaseNumber, ZTS_US_Product_problem_type__c,ZTS_US_Product_Role__c,ZTS_US_Product_Used_Correctly__c 
                                                    FROM ZTS_US_Case_Product__c 
                                                    WHERE ZTS_US_Case__c in:cloneParentIdByCloneChildId 
                                                                AND ((ZTS_US_Product_problem_type__c = null AND ZTS_US_Product_Role__c = 'Suspect Product')
                                                                    OR ZTS_US_Product_Role__c = null 
                                                                    OR ZTS_US_Product_Used_Correctly__c = null)];
        if(badCaseProducts!=null && !badCaseProducts.isEmpty()){
            for(ZTS_US_Case_Product__c badCaseProduct : badCaseProducts){
                if(!badParentCases.containsKey(badCaseProduct.ZTS_US_Case__c)){
                    badParentCases.put(badCaseProduct.ZTS_US_Case__c,badCaseProduct.ZTS_US_Case__r.CaseNumber);
                }
            }
            for(Case clonedCase : clonedCases){
                if(badParentCases.containsKey(clonedCase.getCloneSourceId())){
                    String badParentCaseNumber = badParentCases.get(clonedCase.getCloneSourceId());
                    clonedCase.addError('Case Product Role, Problem Type for Suspect Products and Product Used Correctly fields must be entered prior to cloning a Case.  Please return to Case '+badParentCaseNumber+' and verify all Case Products.');
                }
                
            }
        }
    }

    public class CloneException extends Exception {}

    // CSE- 114 Cloning cases and carrying over realted list
    /*
     * cloning the related list of case 
     * attribute 
     * mapSourceCase to New cloned case Id
    */
    public static void cloneRelatedList(Map<Id,Id> mapSourceCaseIdToNewCaseId) {
        //fetching the case list with all case chield record that we are copying.
        List<Case> caseList = [Select Id,Subject,
                               (SELECT Name,ZTS_US_Patients_Associated__c,
                                                  ZTS_US_Administered_By__c,ZTS_US_Attending_Vet_Suspicion_Level__c,
                                                  ZTS_US_Brand__c,ZTS_US_Brand_Description__c,ZTS_US_Case__c,
                                                  ZTS_US_Company_Product__c,CreatedById,CurrencyIsoCode,
                                                  ZTS_US_Diluent__c,ZTS_US_Dose__c,
                                                  ZTS_US_Dose_Unit__c,
                                                  ZTS_US_Duration__c,ZTS_US_Duration_text__c,ZTS_US_Duration_Unit__c,
                                                  ZTS_US_End_Date__c,ZTS_US_End_Date_Approx__c,ZTS_US_Expiry_Date__c,
                                                  ZTS_US_Expiry_Date_Approx__c,ZTS_US_Filling_Packaging__c,//ZTS_US_First_Onset__c,
                                                  ZTS_US_First_Onset_Approx__c,ZTS_US_First_Onset_Unit__c,ZTS_US_Formulation_PV__c,ZTS_US_Frequency__c,
                                                  ZTS_US_Frequency_Unit__c,ZTS_US_Generic__c,ZTS_US_Interval_Unit__c,
                                                  LastModifiedById,//ZTS_US_Last_Onset__c,ZTS_US_Last_Onset_Approx__c,
                                                  ZTS_US_Last_Onset_Unit__c,ZTS_US_LOE_Reason__c,ZTS_US_MAH_Country_of_Registration__c,
                                                  ZTS_US_MAH_Holder__c,ZTS_US_MAH_License_Registration_No__c,ZTS_US_Manufacturer__c,
                                                  ZTS_US_Misuse_Types__c,ZTS_US_Ongoing__c,OwnerId,ZTS_US_Per__c,
                                                  ZTS_US_Previous_Exposure__c,
                                                  ZTS_US_Previous_Exposure_Details__c,ZTS_US_Previous_Reaction__c,ZTS_US_Previous_Reaction_Details__c,
                                                  ZTS_US_Defect_Product__c,ZTS_US_Product_Agency__c,ZTS_US_Product_Investigation_Requested__c,
                                                  ZTS_US_PVW_Product__c,ZTS_US_Product_Lot__c,ZTS_US_Product_problem_type__c,ZTS_US_Product_Role__c,
                                                  ZTS_US_Product_Used_Correctly__c,ZTS_US_Qualifier__c,ZTS_US_Reason_for_use__c,
                                                  ZTS_US_Route__c,ZTS_US_Serial_Number__c,ZTS_US_Defect_Shipping__c,ZTS_US_Start_Date__c,
                                                  ZTS_US_Start_Date_Approx__c,ZTS_US_PVW_Strength__c,ZTS_US_Used_On_Label__c,ZTS_US_Vet_Aware_of_Similar_Reaction__c,
                                                  RecordTypeId,ZTS_US_Non_Zoetis_Product_Brand__c, ZTS_US_Non_Zoetis_Formulation__c, ZTS_US_Non_Zoetis_Product_Manufacturer__c, ZTS_US_Non_Zoetis_Product_Name_Generic__c, ZTS_US_Non_Zoetis_Product_Strength__c
                                                 FROM Case_Products__r),
                               (SELECT ZTS_US_Animal__c,recordtype.name FROM Case_Animals__r), //recordtype name added as part of TPDEV-2062
                               (SELECT Id,Contact__c from Case_Contacts__r)
                               FROM Case where Id IN : mapSourceCaseIdToNewCaseId.keyset()];
        for(Case sourceCase: caseList){
            if(sourceCase.Case_Products__r!=null && !sourceCase.Case_Products__r.isEmpty()){
                for(ZTS_US_Case_Product__c caseProduct:sourceCase.Case_Products__r){
                    if(String.isBlank(caseProduct.ZTS_US_Product_Role__c)){
                        Case triggerCase = new Case(Id=mapSourceCaseIdToNewCaseId.get(sourceCase.Id));
                        triggerCase.addError('Fill out the product role');
                    }
                }
            }
            
        }
        
        List<ContentDocumentLink> listCotentDocLink = new List<ContentDocumentLink>([SELECT Id,ContentDocumentId    
                                                                                     FROM ContentDocumentLink
                                                                                     WHERE LinkedEntityId IN : mapSourceCaseIdToNewCaseId.keyset()]); 
        
        Map<Id,ContentDocumentLink> mapContentNoteIdToContentDocument = new Map<Id,ContentDocumentLink>();
        
        for(ContentDocumentLink objLink : listCotentDocLink){
            mapContentNoteIdToContentDocument.put(objLink.ContentDocumentId, objLink);   
        }
        
        List<ContentNote> listContentNote = new List<ContentNote>([SELECT Id,Title,TextPreview,FileType ,Content 
                                                                   from ContentNote WHERE ID IN :mapContentNoteIdToContentDocument.keyset()]);
        
        set<Id> contenNotesIds = new Set<Id>();
        set<Id> contenVersionIds = new Set<Id>();
        for(ContentNote contentNoteRec : listContentNote){
            contenNotesIds.add(contentNoteRec.Id);
        }
        for(Id ids : mapContentNoteIdToContentDocument.keySet()){
            if(!contenNotesIds.contains(ids)){
                contenVersionIds.add(ids);
            }
        }
        List<ContentNote> listContentNoteNew = new List<ContentNote>();
        for(ContentNote objContentNote : listContentNote){
            ContentNote contentRec = new ContentNote();
            Blob contentBlob = objContentNote.Content;
            contentRec.Title = objContentNote.Title;
            contentRec.content = contentBlob;//Blob.valueOf(contentString.escapeHtml4());
            listContentNoteNew.add(contentRec);
            
        }
        List<ZTS_US_Case_Product__c> userCaseProductList = new List<ZTS_US_Case_Product__c>();
        List<ZTS_US_Case_Animal__c> listCaseAnimal = new List<ZTS_US_Case_Animal__c>();
        list<Case_Contact__c> listCaseContact = new List<Case_Contact__c>();
        list<ContentDocumentLink> listContentDocumentLink = new List<ContentDocumentLink>();
        
        for(Case objCase : caseList){
            Id newCaseRecordId = mapSourceCaseIdToNewCaseId.get(objCase.id);
            for(ZTS_US_Case_Product__c objUsCaseProduct : objCase.Case_Products__r){
                ZTS_US_Case_Product__c caseProductRec = objUsCaseProduct.clone(false, false, false, false);
                caseProductRec.ZTS_US_Case__c = newCaseRecordId;
                userCaseProductList.add(caseProductRec);
            }
            
            for(ZTS_US_Case_Animal__c objCaseAnimal : objCase.Case_Animals__r){
                ZTS_US_Case_Animal__c caseAnimalRec = objCaseAnimal.clone(false, false, false, false);
                caseAnimalRec.ZTS_US_Case__c = newCaseRecordId;
                listCaseAnimal.add(caseAnimalRec);
            }
            
            for(Case_Contact__c objCaseContact : objCase.Case_Contacts__r){
                Case_Contact__c caseContactRec = objCaseContact.clone(false, false, false, false);
                caseContactRec.Case__c = newCaseRecordId;
                caseContactRec.Contact__c = objCaseContact.Contact__c;
                listCaseContact.add(caseContactRec);
            }
            
            
            
        }
        
        try{
            if(!listContentNoteNew.isEmpty())
            insert listContentNoteNew;
            for(Case objCase : caseList){
                Id newCaseRecordId = mapSourceCaseIdToNewCaseId.get(objCase.id);
                for(ContentNote objContentNote : listContentNoteNew){
                    ContentDocumentLink link = new ContentDocumentLink();
                    link.ContentDocumentId   = objContentNote.id;
                    link.LinkedEntityId      = newCaseRecordId;
                    link.ShareType           = 'V';
                    link.Visibility          = 'InternalUsers';
                    listContentDocumentLink.add(link);
                    
                    }
                    for(ContentDocumentLink objcontentDocumentRec : listCotentDocLink){
                        if(contenVersionIds.contains(objcontentDocumentRec.ContentDocumentId)){
                            ContentDocumentLink newclnk = objcontentDocumentRec.clone();
                            newclnk.LinkedEntityId = newCaseRecordId;
                            newclnk.ShareType = 'V';
                            listContentDocumentLink.add(newclnk);
                        }
                }
            }
            if(!listContentDocumentLink.isEmpty()) 
                insert listContentDocumentLink;
            if(!listCaseContact.isEmpty()){
                DispatchTriggerHandler.setRecursionContexts(new CSE_CaseContactTriggerHandler());//Added by Deepshikha for TPDEV-1033
                upsert listCaseContact;
            }
            if(!listCaseAnimal.isEmpty()) 
                upsert listCaseAnimal;
            if(!userCaseProductList.isEmpty()){
                DispatchTriggerHandler.setRecursionContexts(new CSE_CaseProductTriggerHandler());//Added by Deepshikha for TPDEV-1033
                upsert userCaseProductList;
            }
        }catch(Exception e)
        {
            VMIPS_Case_Clone_Error__e errorEvent = new VMIPS_Case_Clone_Error__e(Error_Message__c='Error in creating related records on case clone: ' + e.getMessage());
            EventBus.publish(errorEvent);
            throw new CloneException('There was a problem cloning your case.  Please reach out to an admin for assistance.');
        }
        
    }
    /***********
    * Method name  : beforeInsertUpdatePrimaryLabLocation
    * Description  :Method Update Primary location to LouisVille
    * Return Type  : void
    * Parameters   : List<Case> triggerNew
    ***********/
    public static void beforeInsertUpdatePrimaryLabLocation( List<Case> triggerNew, Map<Id,Case> oldMap ) {

        for ( Case objCase : triggerNew ) {
            if  (( objCase.RecordTypeId == refLabsSupportRecordTypeId || objCase.RecordTypeId == refLabsOnboardingRecordtypeId)
                &&  objCase.Send_In_Courier__c == 'UPS'
                &&  ( oldMap == null ||  objCase.Send_In_Courier__c != oldMap.get( objCase.Id ).Send_In_Courier__c)
                )
            {
                objCase.Primary_Lab_Location__c = 'Louisville, KY';
            }
        }
    }

    /***********
    * Method name  : beforeInsertRefLabsPortalCases
    * Description  :Method to update the Case created from Reference Labs Web Portal -SFDCATS-159
    * Return Type  : void
    * Parameters   : List<Case> triggerNew
    ***********/
    public static void beforeInsertRefLabsPortalCases(List<Case> triggerNew){

        List<Case> refLabsPortalCases = new List<Case>();
        Set<String> lisNumberList = new Set<String>();
        Set<String> refLabsContactEmailList = new Set<String>();
        //filter refLabs portal cases based on case origin
        for ( Case newCase : triggerNew ) {
            if ( newCase.Origin != 'RefLabs Portal' || String.isNotBlank( newCase.ZenDesk_ID__c ) )  continue;

            refLabsPortalCases.add(newCase);

            if( newCase.LIS_Org_Code__c != null ) lisNumberList.add(newCase.LIS_Org_Code__c);

            if( newCase.SuppliedEmail != null ) refLabsContactEmailList.add(newCase.SuppliedEmail);

            if (  caseTypeMetadataMap.containsKey( newCase.Type ) ) {
                newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( caseTypeMetadataMap.get( newCase.Type ).Record_Type_Name__c ).getRecordTypeId();
                newCase.ownerId = caseTypeMetadataMap.get( newCase.Type ).Queue_Id__c;
            }
            else {
                newCase.RecordTypeId = refLabsSupportRecordTypeId;
                newCase.OwnerId = serviceCloudCustomMetadata.Ref_Labs_Customer_Service_Support_Queue__c;
            }
        }

        if ( refLabsPortalCases.isEmpty() )  return;

        //Search and associate account based on LIS or SAP number
        List<Account> relatedAccountList =
        [    SELECT Id, LIS_Org_Code__c, ZTS_EU_Market__c,
                (   SELECT Id, RefLabs_Contact_Email__c
                    FROM Contacts
                    WHERE RefLabs_Contact_Email__c IN :refLabsContactEmailList
                )
            FROM Account
            WHERE LIS_Org_Code__c IN :lisNumberList
        ];

        if ( relatedAccountList.isEmpty() ) return;

        Map<String, Account> lisToAccountMap =  new Map<String, Account>();
        Map<String, Map<String, String>> accountToContactMap = new Map<String, Map<String, String>>();
        for ( Account accountRec : relatedAccountList ){
            lisToAccountMap.put(accountRec.LIS_Org_Code__c, accountRec);

            Map<String, String> emailToContactMap = new Map<String, String>();
            for ( Contact accountContact : accountRec.Contacts ) {
                emailToContactMap.put( accountContact.RefLabs_Contact_Email__c, emailToContactMap.containsKey( accountContact.RefLabs_Contact_Email__c ) ? null : accountContact.Id );
            }
            accountToContactMap.put( accountRec.LIS_Org_Code__c, emailToContactMap );
        }

        //Add the Account and Contact Ids
        for ( Case portalCase : refLabsPortalCases ){
            if ( lisToAccountMap.containsKey( portalCase.LIS_Org_Code__c ) ) {
                Account accountForLISCode = lisToAccountMap.get( portalCase.LIS_Org_Code__c );
                portalCase.AccountId = accountForLISCode.Id;

                if (String.isBlank(portalCase.ZTS_EU_Market__c)) {
                    portalCase.ZTS_EU_Market__c = accountForLISCode.ZTS_EU_Market__c;
                }
            }

            if ( accountToContactMap.containsKey( portalCase.LIS_Org_Code__c ) ) {
                portalCase.ContactId = accountToContactMap.get( portalCase.LIS_Org_Code__c ).get( portalCase.SuppliedEmail );
            }
        }
    }

    private static Map<String, ZRL_Portal_Case_Type_Mapping__mdt> caseTypeMetadataMap
    {
        get
        {
            if ( caseTypeMetadataMap == null ) {
                //create a Map of Case Type -> Case Mapping Metadata
                caseTypeMetadataMap = new Map<String, ZRL_Portal_Case_Type_Mapping__mdt> ();
                for ( ZRL_Portal_Case_Type_Mapping__mdt caseTypeMetadata :
                    [   SELECT  Case_Type__c, Queue_Id__c, Record_Type_Name__c
                        FROM    ZRL_Portal_Case_Type_Mapping__mdt
                    ]
                    )
                {
                    caseTypeMetadataMap.put( caseTypeMetadata.Case_Type__c, caseTypeMetadata);
                }
            }
            return caseTypeMetadataMap;
        }
        private set;
    }

    private static Service_Cloud_Settings__mdt serviceCloudCustomMetadata
    {
        get
        {
            return CaseService.serviceCloudCustomMetadata;
        }
        private set;
    }

    /***********
    * Method name  : onBeforeUpdate
    * Description  : This method call on before update trigger event and process the data.
    * Return Type  : NA
    * Parameters   : Map<Id, Case> newCases, Map<Id, Case> oldCases.
    ***********/
    public void onBeforeUpdate(Map<Id, Case> newCases, Map<Id, Case> oldCases, List<Case> lstNewCases) {
        system.debug('in BeforeUpdate Case Trigger:'+newCases);

        SL_CaseTriggerHelper.preventEventNarrativeReparenting( SL_CaseTriggerHelper.filterCasesForEventNarrativeChanges( lstNewCases, oldCases ) );
        beforeInsertUpdatePrimaryLabLocation(newCases.values(),oldCases);

        //Call to check for RefLabs Onboarding Cases and crete child Data request Cases - SFDCATS-419
        CaseService.determineReferenceLabsShipToAddress(lstNewCases, oldCases);

        //method to check if there exist atleast 1 Reflabs contact before closing the onboarding case
        checkRefLabsContactOnOnboardingCaseClosure ( lstNewCases, oldCases );

        List<Case> lstDiagnosticsCases = new List<Case>();
        //Section added by Sourav Mitra @ CTS for validation on diagnostic cases with wrong primiary consumable - TPDEV 307
        List<Case> lstUpdatedCaseValid = new List<Case>();
        List<Case> lstUpdatedCase = new List<Case>();
        List<Case> lstCaseToUpdateCC = new List<Case>();
        List<Case> lstCaseToDeleteCC = new List<Case>();
        
        Map<Id,Case> mapIdToUpdatedAccountCases = new Map<Id,Case>();
        Map<Id, Id> mapCaseIdToCaseConsumableId = new Map<Id, Id>();

        Set<Id> setCaseConsumableId = new Set<Id>();

        SL_AvoidCaseConsumableRecursion.isCaseUpdate = true;

        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        Id vmipsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Animal_Support' ).getRecordTypeId();

        Map<Id,Case> caseMapToCheckCancellation = new Map<Id,Case>();

        Boolean isCaseMerge = false;

        //handles the validation rule to avoid throwing exception on record.
        for(Case newCase: newCases.values())
        {
            if(newCase.Primary_Consumable__c != null)
                mapCaseIdToCaseConsumableId.put(newCase.Id, newCase.Primary_Consumable__c);
        }

        for(Product2 objProd: [Select Id, CPQ_Material_Type__c 
                               From Product2 
                               Where Id =: mapCaseIdToCaseConsumableId.values() 
                               AND CPQ_Material_Type__c =: 'Consumable'])
        {
            setCaseConsumableId.add(objProd.Id);
        }

        for(Case newCase: newCases.values()) {

            Case oldCaseObj = oldCases.get(newCase.Id);
            if( (oldCaseObj.RecordTypeId != newCase.RecordTypeId || oldCaseObj.AccountId != newCase.AccountId)
                && newCase.RecordTypeId == diagRecordTypeId )
                lstDiagnosticsCases.add(newCase);

            //condition added by Sourav Mitra @ CTS TPDEV-307
            if(newCase.RecordTypeId == diagRecordTypeId){
                lstUpdatedCaseValid.add(newCase);
            }

            if(oldCaseObj.ContactId != newCase.ContactId)
                lstUpdatedCase.add(newCase);

            if(oldCaseObj.AccountId != newCase.AccountId && newCase.RecordTypeId == diagRecordTypeId)
                mapIdToUpdatedAccountCases.put(newCase.Id, newCase);
           
            if(newCase.RecordTypeId == diagRecordTypeId && ((newCase.Primary_Consumable__c != oldCaseObj.Primary_Consumable__c
                                                        || newCase.Primary_Error_Code__c != oldCaseObj.Primary_Error_Code__c
                                                        || newCase.Rotor_Credit__c != oldCaseObj.Rotor_Credit__c
                                                        || newCase.Primary_Lot_Num__c != oldCaseObj.Primary_Lot_Num__c
                                                        || newCase.Primary_Lot_Num_Unknown__c != oldCaseObj.Primary_Lot_Num_Unknown__c)
                                                        && ( ((newCase.Primary_Lot_Num__c != null && newCase.Primary_Lot_Num_Unknown__c == false)  || (newCase.Primary_Lot_Num__c == null && newCase.Primary_Lot_Num_Unknown__c == true)) || ((newCase.isSet('Primary_Lot_Num__c') && newCase.Primary_Lot_Num_Unknown__c == false) ||  (newCase.Primary_Lot_Num__c == null && newCase.Primary_Lot_Num_Unknown__c == true)) )) && (mapCaseIdToCaseConsumableId.containsKey(newCase.Id) && setCaseConsumableId.contains(mapCaseIdToCaseConsumableId.get(newCase.Id))))
                lstCaseToUpdateCC.add(newCase);

            if(newCase.RecordTypeId == diagRecordTypeId && (newCase.Primary_Consumable__c == null
                                                            && newCase.Primary_Error_Code__c == null))
                lstCaseToDeleteCC.add(newCase);
            //if any of the cases in the new trigger now have a MasterRecordId, the cases in the trigger are being merged
            if(newCase.MasterRecordId != null && oldCaseObj.MasterRecordId == null && newCase.recordTypeId == vmipsCaseRecordTypeId){
                isCaseMerge = true;
            }
            
           
            if(newCase.Status != oldCaseObj.Status && newCase.Status == 'Cancelled' && newCase.RecordTypeId == vmipsCaseRecordTypeId){
                caseMapToCheckCancellation.put(newCase.Id,newCase);
            }
        }

        //Condition added by Sourav Mitra @ CTS for validation on primary consumables based on Account Market TPDEV-307
        if(!lstUpdatedCaseValid.isEmpty()){
            checkDiagnosticsCaseValidation(lstUpdatedCaseValid);
        }

        if(SL_CaseConsumableTriggerHandler.isCaseUpdateFromConsumable)
            return;
        if(isCaseMerge){
            SL_CaseTriggerHelper.handleManualCaseMerge(newCases.values());
        }

        if(!caseMapToCheckCancellation.isEmpty()){
            SL_CaseTriggerHelper.checkCaseErr(caseMapToCheckCancellation);
        }

        // added for LIGHTNI-1798
        if(!mapIdToUpdatedAccountCases.isEmpty())
            updateRotorTxnsOnAccountUpdate(mapIdToUpdatedAccountCases);

        if(!lstDiagnosticsCases.isEmpty())
        {
            checkLevel1Support( lstDiagnosticsCases );
            CaseService.setDiagnosticEntitlementOnCase(lstDiagnosticsCases);
        }
        if(!lstUpdatedCase.isEmpty() && !CSE_CaseContactUpdateRecursion.isCaseUpdate)
            updateCaseContact(lstUpdatedCase,oldCases);
       
        if(!lstCaseToUpdateCC.isEmpty()){
            checkForAppliedCredits(lstCaseToUpdateCC,oldCases);
            upsertCaseConsumable(lstCaseToUpdateCC);
        }           
        
        if(!lstCaseToDeleteCC.isEmpty()){
            deleteCaseConsumable(lstCaseToDeleteCC);
        }
        
        checkPVWSyncStatus( lstNewCases, oldCases );
    }
    
    /***********
    * Method name  : onAfterInsert
    * Description  : This method call on after insert trigger event and process the data.
    * Return Type  : NA
    * Parameters   : Map<Id, Case> newCases, Map<Id, Case> oldCases.
    ***********/
    public void onAfterInsert(List<Case> lstNewCases) {
        
                 System.debug('We are on After insert ***');


        //Call to check if there is an exisiting RefLabs Onboarding Case
        checkForExistingOnboardingCase( lstNewCases );

        //Call to check for RefLabs Onboarding Cases and crete child Data request Cases - SFDCATS-419
        CaseService.createDataRequestChildCasesForRefLabsOnboardingCase(lstNewCases);

        List<Case> lstDiagnosticsCases = new List<Case>();
        List<Case> lstCase = new List<Case>();
        List<Id> casesWithAccessionNumber = new List<Id>();
        Map<Id,Id> mapCloneSourceIdToNewCaseId = new Map<Id,Id>();

        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();

        Set<Id> caseIds = new Set<Id>();
        for(Case obj: lstNewCases) 
        {
            if(animalRecordtypeId == obj.RecordTypeId && obj.isClone()){
                caseIds.add(obj.getCloneSourceId());
            }
            if(obj.RecordTypeId == diagRecordTypeId && obj.ContactId != null) 
                lstDiagnosticsCases.add(obj);
            if(obj.RecordTypeId == diagRecordTypeId && (obj.Primary_Consumable__c != null || obj.Primary_Error_Code__c != null && (obj.Primary_Lot_Num__c != null && obj.Primary_Lot_Num_Unknown__c != null)) )
                lstCase.add(obj);
            if ( obj.Accession__c != null ){
                casesWithAccessionNumber.add( obj.Id );
            }
        }

        List<ZTS_US_Case_Product__c> listCaseProduct = new List<ZTS_US_Case_Product__c>([SELECT Id,ZTS_US_Case__c,ZTS_US_Case__r.Status 
                                                                                         FROM ZTS_US_Case_Product__c 
                                                                                         WHERE ZTS_US_Case__c IN : caseIds
                                             ]);
        Set<Id> setCaseWithCaseProductIds = new Set<Id>();
        for(ZTS_US_Case_Product__c casePro : listCaseProduct){
            setCaseWithCaseProductIds.add(casePro.ZTS_US_Case__c);
        }
        for(Case obj: lstNewCases)
        {
            
            if(obj.status!= 'Closed' && animalRecordtypeId == obj.RecordTypeId && obj.isClone() && !setCaseWithCaseProductIds.isEmpty() && setCaseWithCaseProductIds.contains(obj.getCloneSourceId())){
                   
                 mapCloneSourceIdToNewCaseId.put(obj.getCloneSourceId(),obj.Id); 
            } else if(animalRecordtypeId == obj.RecordTypeId && obj.isClone()){
                //obj.addError(System.label.CSE_Case_Handler_Trigger_Clone_Related_List);
            }
        }
        if(mapCloneSourceIdToNewCaseId != null && mapCloneSourceIdToNewCaseId.size()>0){
            
            cloneRelatedList(mapCloneSourceIdToNewCaseId);
        }
        if(!lstDiagnosticsCases.isEmpty()){
            insertCaseContact( lstDiagnosticsCases );
        }
        if(!lstCase.isEmpty()){
            upsertCaseConsumable(lstCase);
        }
        if ( !casesWithAccessionNumber.isEmpty() ){
            autopopulateFromAccessionNumber( casesWithAccessionNumber );
        }
    }

    /***********
    * Method name  : onAfterUpdate
    * Description  : This method call on after update trigger event and process the data.
    * Return Type  : NA
    * Parameters   : Map<Id, Case> newCases, Map<Id, Case> oldCases.
    ***********/
    public void onAfterUpdate(Map<Id, Case> newCases, Map<Id, Case> oldCases) {


        List<Id> casesWithAccessionNumber = new List<Id>();
        Set<Id> casesWithTypeChange = new Set<Id>();
        for(Case newCase: newCases.values())
        {
            Case oldCase = oldCases.get( newCase.Id );
            if ( newCase.Accession__c != null && newCase.Accession__c != oldCase.Accession__c ){
                casesWithAccessionNumber.add( newCase.Id );
            }
            if ( newCase.Type != oldCase.Type ){
                casesWithTypeChange.add( newCase.Id );
            }
                        
        }
        if ( !casesWithAccessionNumber.isEmpty() ){
            autopopulateFromAccessionNumber( casesWithAccessionNumber );
        }
        if ( !casesWithTypeChange.isEmpty() ){
            SL_CaseTriggerHelper.validateRelatedRecordsOnTypeChange( casesWithTypeChange, newCases);
        }

        
        // Added this logic as a part of CSE-49(LongTextArea Field Audit)
        new CSE_LongTextAreaAuditTrailHelper().filterTextAreaChangedRecords(newCases.values(), oldCases, 'Long_Text_Area_Fields');
    }

    /***********
    * Method name  : sendEmail (After Update)
    * Description  : This method runs when Sync Status = Ready to Sync. 
                    The trigger will send an email to a group of Account Positions where "SIB Flag" is true.
    * Return Type  : NA
    * Parameters   : List of New Cases.
    * Created By   : Apurva Verma @Slalom
    * Story        : CSE-333 
    ***********/

    //method to create email body
    public String setEmailBody(Case aCase)
    {
        String body = 'Dear <b>' + aCase.Account.Name + ', ';
        body += '</b></br></br>Zoetis has been contacted by one of the customers ';
        body += 'who reported a suspected adverse event to a Zoetis product. ';
        body += 'The Case details are listed below: ';
        body += '</b></br></br>Case Number: <b>' +aCase.CaseNumber;
        body += '</b></br></br>Case Owner: <b>' +aCase.Owner.Name;
        body += '</b></br></br>Account Name: <b>' +aCase.Account.Name;
        body += '</b></br></br>Account NARC: <b>' +aCase.Account.ZTS_US_NARC_ID__c;
        body += '</b></br></br>Contact Name: <b>' +aCase.Contact.Name;
        body += '</b></br></br>Associated Case Products: <b>' +aCase.ZTS_US_Case_Products_Text__c;
        body += '</b></br></br>Event Narrative: <b>' +aCase.ZTS_US_Event_Narrative__r.ZTS_US_Event_Narrative_Summary_Field__c;
        body += '</b></br></br>Click on the link below to view more details about this case: </br>'; 
        body += + URL.getSalesforceBaseUrl().toExternalForm()+'/'+aCase.Id;
        body += +'</br></br>'+'CONFIDENTIALITY NOTICE - This message may contain privileged and confidential information. Emails regarding VMIPS cases are for INTERNAL use only '
                                                    +'and should only be forwarded to Zoetis colleagues on a need to know basis as a means of communication on the case.'
                                                    +' Emails should not be forwarded to producers or veterinarians.';

        //adding case thread ID
        
        body += '</br></br> ' +aCase.Email_Thread_Id__c;

        return body;
    }


    //method to send email
    // public void sendEmail(List<Case> cases)
    public void sendEmail( List<Case> cases, Map<Id, Case> triggerOldMap )
    {
        // lets get the custom setting value for if this email is allowed to be sent or not
        Allow_VMIPS_SIB_Email_Flag__c emailFlag = Allow_VMIPS_SIB_Email_Flag__c.getInstance();

        if ( !emailFlag.Is_Email_Sending_enabled__c )
        {
            return;
        }


        //Create a set to store Account Id's from Case
        Set<Id> accIds = new Set<Id>();

        //Create a Set of Case Id's
        Set<Id> caseIds = new Set<Id>();

        //Create a Set of Case Types
        Set<String> caseTypes = new Set<String>{'Animal Complaint', 'Product Defect', 'Human Exposure'};

        for(Case vmipsCases : cases)
        {
            Case oldCase = triggerOldMap.get( vmipsCases.Id );

            if(vmipsCases.AccountId != null && vmipsCases.Sync_Status__c != oldCase.Sync_Status__c && vmipsCases.Sync_Status__c == VmipsCaseSyncStatusHandler.SYNC_READY)
            {
                accIds.add(vmipsCases.AccountId);
                caseIds.add(vmipsCases.Id);
            }
        }

        if ( accIds.isEmpty() || caseIds.isEmpty() )
        {
            return;
        }

        //Create a list of Account Positions for all accounts that are in the Set
        List<ZTS_EU_Account_Position__c> accPositionList = [ SELECT ZTS_EU_Account__r.Name , 
                                                                    ZTS_EU_Account__r.ZTS_US_NARC_ID__c,
                                                                    ZTS_SIB_Flag__c, 
                                                                    ZTS_EU_Employee__c,
                                                                    ZTS_EU_Employee_Id__c, 
                                                                    Employee_Email__c, 
                                                                    ZTS_Field_Force_Name__c, 
                                                                    ZTS_EU_Primary_Sales_Rep__c 
                                                                    FROM ZTS_EU_Account_Position__c 
                                                                    WHERE ZTS_SIB_Flag__c = true 
                                                                    AND ZTS_EU_Account__c IN : accIds ];

        // Create a List of all Cases from the Set of Case Id's
        List<Case> allCases = [ SELECT Id, 
                                    Type,
                                    CaseNumber,
                                    Contact.Name,
                                    Account.Name,
                                    Account.ZTS_US_NARC_ID__c,
                                    Owner.Name,
                                    Sync_Status__c,
                                    ZTS_US_Case_Products_Text__c,
                                    ZTS_US_Event_Narrative__r.ZTS_US_Event_Narrative_Summary_Field__c,Email_Thread_Id__c
                                    FROM Case
                                    WHERE Id IN : caseIds 
                                    AND RecordTypeId = : animalRecordtypeId ];
        
        //Create a Map of Account Id to Account Position Email
        Map<Id, Set<String>> mapOfAccIdToEmail = new Map<Id, Set<String>>();

        //Fill in the Map with appropriate Email values
        for( ZTS_EU_Account_Position__c accPos : accPositionList )
        {
            if( mapOfAccIdToEmail.containsKey(accPos.ZTS_EU_Account__c) )
            {
                Set<String> accPosEmail = mapOfAccIdToEmail.get(accPos.ZTS_EU_Account__c);
                if ( String.isNotBlank( accPos.Employee_Email__c ) )
                {
                    accPosEmail.add(accPos.Employee_Email__c);
                }
            }
            else 
            {
                Set<String> newAccPosEmail = new Set<String>();
                if ( String.isNotBlank( accPos.Employee_Email__c ) )
                {
                    newAccPosEmail.add(accPos.Employee_Email__c);
                    mapOfAccIdToEmail.put(accPos.ZTS_EU_Account__c, newAccPosEmail);
                }
            }
        }

        //Create an email list for sending email messages

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        //List<EmailTemplate> tmplist = [SELECT Id From EmailTemplate Where DeveloperName = 'VMIPS_Email_SIB_Case_Template'];
        OrgWideEmailAddress orgWideEmail = [select Id from OrgWideEmailAddress where Address = 'supportus@zoetis.com' LIMIT 1];
        //Looping over cases and sending out emails to appropriate people

        for( Case aCase : allCases )
        {
            //Check to see Case conditions like sync status, Account Id and Case Type
            if( (aCase.Sync_Status__c == VmipsCaseSyncStatusHandler.SYNC_READY) && (aCase.AccountId != null) && ( mapOfAccIdToEmail.containsKey(aCase.AccountId)) && ( caseTypes.contains(aCase.Type) ) )
            {
                //Create a Set of all emails from the Account Positions on Map
                Set<String> emailSet = mapOfAccIdToEmail.get(aCase.AccountId);
                if ( emailSet.isEmpty() )
                {
                    continue;
                }
                
                // New mail object
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 

                mail.setSaveAsActivity(false);

                //create a List of people who should get the email
                List<String> sendTo = new List<String>(emailSet);
                mail.setToAddresses(sendTo);

                //Setting Email contents
                mail.setSubject('Case Notification for '+aCase.Account.Name);

                //calling the message body
                String body = setEmailBody(aCase);

                mail.setHtmlBody(body);
                mail.setOrgWideEmailAddressId(orgWideEmail.Id);
                //Add your email to the master list
                emails.add(mail);
                
            }
        }
        if ( !Test.isRunningTest() && !emails.isEmpty() )
        {
            //Send all emails in the master list
            Messaging.sendEmail(emails);
        }
    }

    @TestVisible
    private void checkPVWSyncStatus( Case[] triggerNew, Map<Id, Case> oldCasesMap )
    {
        VmipsCaseService.checkPVWSyncStatus(triggerNew,oldCasesMap);      
    }


    /***********
    * Method name  : checkLevel1Support
    * Description  : This method check whether the case account market is in the metadata.
    * Return Type  : NA
    * Parameters   : lstNewCases.
    ***********/
    public void checkLevel1Support( List<Case> lstNewCases ) {
        
    /*
        List<String> lstLevel1SupportMarket = new List<String>();
        for( Diagnostics_Level_1_Support_Markets__mdt objmdt : [SELECT MasterLabel FROM Diagnostics_Level_1_Support_Markets__mdt]){
            lstLevel1SupportMarket.add(objmdt.MasterLabel);
        }
        for(Case obj : lstNewCases) {
            if(!lstLevel1SupportMarket.contains(obj.Account_Market_Formula__c)) {
                obj.Skip_L1__c = true;
            }
        }
    */
        List<String> marketsWithoutDiagLevel1 = new List<String>();
        for(Market_Metadata_Record__mdt mmdt : [SELECT MasterLabel FROM Market_Metadata_Record__mdt WHERE Has_Diagnostics_Level_1_Support__c = false]){
            marketsWithoutDiagLevel1.add(mmdt.MasterLabel);
        }
        for(Case c : lstNewCases){
            if(marketsWithoutDiagLevel1.contains(c.Account_Market_Formula__c))
                c.Skip_L1__c = true;
            
        }
        
        
    }
    
     /***********
    * Method name  : checkDiagnosticsCaseValidation
    * Description  : This method checks validates Case Primary Consumable Market with Case Account Market
    * Return Type  : NA
    * Parameters   : lstNewCases.
    * Method added by Sourav for handling validations on Primary Consumable and Account Market-TPDEV_307
    ***********/
    
    public void checkDiagnosticsCaseValidation(List<Case> lstNewCases){
        Set<Id> primaryConsumableSet = new Set<Id>();
        Map<Id,ZTS_EU_Species_Product__c> prodHierarchyMap;
        for(Case c : lstNewCases){
            primaryConsumableSet.add(c.ZTS_US_Primary_Consumable__c);
        }
        
        prodHierarchyMap = new Map<Id, ZTS_EU_Species_Product__c>([Select Id,Name,ZTS_EU_Market__c FROM ZTS_EU_Species_Product__c Where Id IN :primaryConsumableSet]);
        
        for(Case c : lstNewCases){
            if(c.ZTS_US_Primary_Consumable__c != null){
				if(c.Account_Market_Formula__c != prodHierarchyMap.get(c.ZTS_US_Primary_Consumable__c).ZTS_EU_Market__c){  
					c.addError('Please select correct primary consumable associated with Account Market');
				}
           }
        }
    }

    /***********
    * Method name  : insertCaseContact
    * Description  : This method creates the case contact record based on the lookup value of the Contact on the Case record.
    * Return Type  : NA
    * Parameters   : lstNewCases.
    ***********/
    @TestVisible
    private void insertCaseContact( List<Case> lstNewCases ) {

        List<Case_Contact__c> lstCaseContact = new List<Case_Contact__c>();

        for(Case obj : lstNewCases)
            lstCaseContact.add(new Case_Contact__c(Contact__c = obj.ContactId, Case__c = obj.Id, Primary__c = true));

        insert lstCaseContact;
    }

    /***********
    * Method name  : updateCaseContact
    * Description  : This method updates the case contact record based on the updated lookup value of the Contact on the Case record.
    * Return Type  : NA
    * Parameters   : lstNewCases.
    ***********/
    @TestVisible
    private void updateCaseContact( List<Case> lstNewCases,Map<Id,Case> oldCase ) {
        
        List<Case_Contact__c> lstCaseContact = new List<Case_Contact__c>();
        List<Case_Contact__c> lstDeleteCaseContact = new List<Case_Contact__c>();
        Map<Id, Case_Contact__c> mapCaseToCaseContact = new Map<Id, Case_Contact__c>();

        for(Case_Contact__c objCaseContact : [Select Primary__c, Case__c, Contact__c From Case_Contact__c Where Case__c IN: lstNewCases AND Primary__c =: true] )
            mapCaseToCaseContact.put(objCaseContact.Case__c, objCaseContact);
        
        Set<Id> setIds = new Set<Id>();
        
        for(Case obj : lstNewCases)
        {
                setIds.add(obj.id);
        }
        //before Update was referencing it self and same time we were using the Case Id in Upsert.
       //Queried Case record to get new reference of Case record
        list<Case> listCase = [Select Id , ContactId from Case where Id IN :setIds];

        for(Case obj : listCase)
        {
            Case oldCaseRec = oldCase.get(obj.Id);
            if(obj.ContactId != null && mapCaseToCaseContact.get(obj.Id) != null && oldCaseRec.ContactId != obj.ContactId)
                lstCaseContact.add(new Case_Contact__c(Id = mapCaseToCaseContact.get(obj.Id).Id,
                                                       Contact__c = obj.ContactId));
            else if(obj.ContactId != null && mapCaseToCaseContact.get(obj.Id) == null && oldCaseRec.ContactId != obj.ContactId)
                lstCaseContact.add(new Case_Contact__c(Case__c = obj.Id,
                                                       Contact__c = obj.ContactId,
                                                       Primary__c = true));
            else if(mapCaseToCaseContact.containsKey(obj.Id))
                lstDeleteCaseContact.add(mapCaseToCaseContact.get(obj.Id));
        }
        If(!CSE_CaseContactUpdateRecursion.isCaseUpdate){
           if(!lstCaseContact.isEmpty())
            upsert lstCaseContact;  
            CSE_CaseContactUpdateRecursion.isCaseUpdate =true;
        }
        
            
        try 
        {
            If(!lstDeleteCaseContact.isEmpty())
                delete lstDeleteCaseContact;
        }
        catch ( DMLException e )
        {
            System.debug( 'exception deleting case contacts: ' + e.getMessage() );
        }
    }

    /***********
    * Method name  : updateRotorTxnsOnAccountUpdate
    * Description  : This method updates the related rotor transactions records when Case's Account get updated.
    * Return Type  : NA
    * Parameters   : Map<Id, Case> mapCases
    ***********/
    private void updateRotorTxnsOnAccountUpdate(Map<Id, Case> mapCases) {

        List<Rotor_Transaction__c> lstUpdatableTxns = new List<Rotor_Transaction__c>();
        Map<Id, Case_Consumable__c> mapIdToCaseComsumable = new Map<Id, Case_Consumable__c>([SELECT Id, Case__c
                                                                                             FROM Case_Consumable__c
                                                                                             WHERE Case__c IN :mapCases.keySet()]);

        for(Rotor_Transaction__c objTxn : [SELECT Id, Account__c, Case_Consumable__c, Locked__c
                                           FROM Rotor_Transaction__c
                                           WHERE Case_Consumable__c IN :mapIdToCaseComsumable.keySet()]) {
            Case objCase = mapCases.get(mapIdToCaseComsumable.get(objTxn.Case_Consumable__c).Case__c);
            if(objTxn.Locked__c) {
                objCase.addError('The Account cannot be changed once Rotor Transactions have been locked.');
            }else{
                lstUpdatableTxns.add(new Rotor_Transaction__c(Id = objTxn.Id,
                                                              Account__c = objCase.AccountId));

            }
        }
        update lstUpdatableTxns;
    }

    /***********
    * Method name  : upsertCaseConsumable
    * Description  : This method updates the case consumable record based on the fields updated on the Case record.
    * Return Type  : NA
    * Parameters   : lstNewCases.
    ***********/
    private void upsertCaseConsumable( List<Case> lstNewCases ) {

        List<Case_Consumable__c> lstCaseConsumable = new List<Case_Consumable__c>();
        Map<Id, Case_Consumable__c> mapCaseIdToCaseConsumable = new Map<Id, Case_Consumable__c>();

        for(Case_Consumable__c objCC : [Select Id, Primary__c, Case__c, Lot_Num__c, Lot_Num_Unknown__c, Consumable_Product__c, Diagnostics_Error_Code__c
                                        From Case_Consumable__c Where Case__c IN: lstNewCases AND Primary__c =: true ])
        {
            mapCaseIdToCaseConsumable.put(objCC.Case__c, objCC);
        }

        for(Case obj : lstNewCases)
        {
            lstCaseConsumable.add(new Case_Consumable__c(Id = mapCaseIdToCaseConsumable.containsKey(obj.Id) ? mapCaseIdToCaseConsumable.get(obj.Id).Id : null,
                                                         Case__c = obj.Id,
                                                         Primary__c = true,
                                                         Lot_Num__c = obj.Primary_Lot_Num__c,
                                                         Lot_Num_Unknown__c = obj.Primary_Lot_Num_Unknown__c,
                                                         Consumable_Product__c = obj.Primary_Consumable__c,
                                                         Diagnostics_Error_Code__c = obj.Primary_Error_Code__c,
                                                         Rotor_Credit__c = obj.Rotor_Credit__c));
        }


        upsert lstCaseConsumable;
    }

    /***********
    * Method name  : deleteCaseConsumable
    * Description  : This method deletes the case consumable record based on the fields updated on the Case record.
    * Return Type  : NA
    * Parameters   : lstNewCases.
    ***********/
    private void deleteCaseConsumable( List<Case> lstNewCases ) {

        List<Case_Consumable__c> lstCaseConsumable = new List<Case_Consumable__c>();
        Map<Id, Case_Consumable__c> mapCaseIdToCaseConsumable = new Map<Id, Case_Consumable__c>();
        Set<Id> setCaseConsumableId = new Set<Id>();
        
        //Id adminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        /* Always gets Sys Admin regardless of language */ 
        //TPDEV-823
        Id adminId = [ SELECT Id FROM Profile WHERE (UserType = 'Standard' AND PermissionsCustomizeApplication = true) ORDER BY CreatedDate ASC LIMIT 1 ].Id;

        for(Case_Consumable__c objCC : [Select Id, Primary__c, Case__c, Lot_Num__c, Lot_Num_Unknown__c, Consumable_Product__c, Diagnostics_Error_Code__c
                                        From Case_Consumable__c Where Case__c IN: lstNewCases AND Primary__c =: true ])
        {
            mapCaseIdToCaseConsumable.put(objCC.Case__c, objCC);
        }

        for(Rotor_Transaction__c objRC : [Select Id, Locked__c, Case_Consumable__c
                                            From Rotor_Transaction__c
                                           Where Case_Consumable__c IN: mapCaseIdToCaseConsumable.values() AND Locked__c =: true])
        {
            setCaseConsumableId.add(objRC.Case_Consumable__c);
        }

        for(Case objCase : lstNewCases)
        {
            if(mapCaseIdToCaseConsumable.containsKey(objCase.Id))
            {
                if(setCaseConsumableId.contains(mapCaseIdToCaseConsumable.get(objCase.Id).Id))
                    objCase.addError('Case Consumable record is locked and cannot be deleted.');
                else if(mapCaseIdToCaseConsumable.get(objCase.Id).Primary__c && UserInfo.getProfileId() != adminId)
                    objCase.addError('Primary Case Consumable record cannot be deleted.');
                else
                    lstCaseConsumable.add(mapCaseIdToCaseConsumable.get(objCase.Id));
            }
        }
        delete lstCaseConsumable;
    }

    /***
     * Method Name : resetFieldsWhenCloned
     * Description : This method will clear values for fields defined in 'Do Not Clone' field set
     * Paramaters  : lstNewCases
     * Return Type : NA
     *
     */

    void resetFieldsWhenCloned(List<Case> lstNewCases){
        List<Schema.FieldSetMember> doNotCloneFields = SObjectType.Case.fieldSets.Do_Not_Clone.getFields();
        for(Integer i = 0;i<lstNewCases.size();i++){
            Case clonedCase = lstNewCases[i];
            for(Schema.FieldSetMember fieldSetMember : doNotCloneFields){
                String fieldName = fieldSetMember.getFieldPath();
                String fieldType = String.ValueOf(fieldSetMember.getType());
                clonedCase.put(fieldName,fieldType=='BOOLEAN' ? (Object) false : (Object) null);
            }
        }
    }

    /***
     * Method Name : checkForAppliedCredits
     * Description : This method will check if Rotor Credits are applied at Rotor Transactions
                     when Rotor Credit field is updated on Case record.
     * Paramaters  : updatedCases
     * Return Type : NA
     *
     */

    void checkForAppliedCredits(List<Case> updatedCases, Map<Id,Case> oldCases){
        Map<id,case> id_to_caseMap = new Map<Id,Case>();
        Map<id,Id> primaryConsumableId_To_CaseIdMap = new Map<Id,Id>();
        Map<id,id> consumables_To_CaseMap = new Map<Id,Id>();
        for(Integer i = 0; i<updatedCases.size(); i++){
            Case newCase = updatedCases[i];
            Case oldCase = oldCases.get(newCase.Id);
            if(newCase.Rotor_Credit__c != oldCase.Rotor_Credit__c){
                id_to_caseMap.put(newCase.id,newCase);
                primaryConsumableId_To_CaseIdMap.put(newCase.Primary_Consumable__c,newCase.id);
            }
        }
        for(Case_Consumable__c cc : [Select id, Case__c from Case_Consumable__c where Case__c in :id_to_caseMap.keySet() and Consumable_Product__c in :primaryConsumableId_To_CaseIdMap.keySet()]){
            consumables_To_CaseMap.put(cc.Id,cc.Case__c);
        }
        Set<id> creditsAppliedCasesIds = new Set<Id>();
        // query Rotor Transaction records with case consumable ids and primary consumable ids on case where
        // Applied = true
        // consumables in :caseConsumableIDs
        // product in : primaryConsumableIds
        for(Rotor_Transaction__c rt : [Select Id,Rotor_Credit__c ,Case_Consumable__c,Product__c from Rotor_Transaction__c where Locked__c = true and Case_Consumable__c in :consumables_To_CaseMap.keySet()
                                      and Product__c in :primaryConsumableId_To_CaseIdMap.keySet()]){
                                          if(primaryConsumableId_To_CaseIdMap.containsKey(rt.Product__c) && consumables_To_CaseMap.containsKey(rt.Case_Consumable__c) ){
                                              Id productCaseId = primaryConsumableId_To_CaseIdMap.get(rt.Product__c);
                                              Id consumableCaseId = consumables_To_CaseMap.get(rt.Case_Consumable__c);
                                              if(productCaseId==consumableCaseId){
                                                  creditsAppliedCasesIds.add(productCaseId);
                                              }
                                              
                                              
                                              
                                              
                                          }
                                      }
        // Iterate over updating cases where rotor transactions are changing
        for(Id caseId : id_to_caseMap.keySet()){
            //get case record
            Case c = id_to_caseMap.get(caseId);
            //check if id is in creditsAppliedCasesIds
            if(creditsAppliedCasesIds.contains(c.Id)){
                c.addError('Cannot be modified after the related Rotor Transaction has been locked.');
            }
        }
    }

    @future
    public static void autopopulateFromAccessionNumber( List<Id> casesWithAccessionNumber ){

        //  This code violates best practices by doing a SOQL query
        //  inside the loop.  This is necessary because we are querying
        //  an external object.  To filter external objects, we must
        //  use the LIKE operator.  We can't filter using the IN operator.
        //  Therefore, this method can process at most 199 Cases.
        List<Case> casesToUpdate = new List<Case>();
        for ( Case record :
            [   SELECT  Id, Accession__c,
                        Pet_ID__c, Pet_Description__c,
                        Reference_Labs_Order__c,
                        Test_Completed_Date__c, Test_Received_Date__c
                FROM    Case
                WHERE   Id IN :casesWithAccessionNumber
            ]
            )
        {
            String accession = record.Accession__c;
            String accession_pre = accession + '%';
            String accession_post = '%' + accession;
            for ( Reference_Labs_Order__x refLabsOrder :
                [   SELECT  Accession_Number__c, ExternalId, Pet_ID__c,
                            Pet_Descr__c, Test_Completion_Date__c,
                            Test_Receive_Date__c, Test_Received_Location__c
                    FROM    Reference_Labs_Order__x
                    WHERE   (   Accession_Number__c LIKE :accession_pre
                            AND Accession_Number__c LIKE :accession_post
                            )
                    ORDER BY Test_Receive_Date__c DESC NULLS LAST
                    LIMIT 1
                ]
                )
            {
                record.Pet_ID__c = refLabsOrder.Pet_ID__c;
                record.Pet_Description__c = refLabsOrder.Pet_Descr__c;
                record.Reference_Labs_Order__c = refLabsOrder.ExternalId;
                record.Test_Completed_Date__c =
                (   refLabsOrder.Test_Completion_Date__c != null
                ?   refLabsOrder.Test_Completion_Date__c.date()
                :   null
                );
                record.Test_Received_Date__c =
                (   refLabsOrder.Test_Receive_Date__c != null
                ?   refLabsOrder.Test_Receive_Date__c.date()
                :   null
                );
                casesToUpdate.add( record );
                break;
            }
        }
        update casesToUpdate;
    }

     /***********
    * Method name  : checkRefLabsContactOnOnboardingCaseClosure
    * Description  : Method to validate at least 1 RefLabs contact before Onboarding Case Closure
    * Return Type  : void
    * Parameters   : List<Case> triggerNew, Map<Id, Case> triggerOldMap
    ***********/

    void checkRefLabsContactOnOnboardingCaseClosure ( List<Case> triggerNew, Map<Id, Case> triggerOldMap ) {

        Map<String, Case> accountToCaseMap = new Map<String, Case>();

        for ( Case objCase : triggerNew ) {
            if  ( ( objCase.RecordTypeId == refLabsOnboardingRecordtypeId ) && objCase.Status == 'Closed' && triggerOldMap.get(objCase.Id).Status != 'Closed' )
            {
                accountToCaseMap.put( objCase.AccountId, objCase );
            }
        }

        List<Account> lstOnboardingAccounts = 
        [   SELECT  Id,
                    (   SELECT Id, Reference_Lab_Contact__c 
                        FROM Contacts 
                        WHERE Reference_Lab_Contact__c = true
                    ),
                    (
                        SELECT Id, ZTS_EU_Contact__r.Name, ZTS_EU_Contact__r.Reference_Lab_Contact__c 
                        FROM Accounts_and_Contacts__r 
                        WHERE ZTS_EU_Contact__r.Reference_Lab_Contact__c = true
                    )
            FROM    Account
            WHERE   Id IN :accountToCaseMap.keySet()
        ];

        for ( Account accountRec : lstOnboardingAccounts ) {
            if ( accountRec.Contacts.isEmpty() && accountRec.Accounts_and_Contacts__r.isEmpty() ) {
                accountToCaseMap.get( accountRec.Id ).Status.addError( REFLABS_ONBOARDING_CASE_NO_CONTACT_ERROR );
                continue;
            }
        }
    }

    void checkForExistingOnboardingCase ( List<Case> triggerNew ){
        
        Map<Id, Case> onboardingCases = new Map<Id, Case>();
        for ( Case objCase : triggerNew ) {
            if  ( ( objCase.RecordTypeId == refLabsOnboardingRecordtypeId ) ) onboardingCases.put(objCase.Id, objCase);
        }
        
        if(onboardingCases.isEmpty()) return;

        Map<Id, Case> relatedData = new Map<Id, Case>
        (   [   SELECT Id, Account.RefLabs_Existing_Onboarding_Case__c, Account.Reference_Lab_Customer__c 
                FROM Case 
                WHERE Id IN :onboardingCases.keySet()
            ] 
        );
        
        for( Case caseObj : onboardingCases.values() ){
            Case relatedCase = relatedData.get( caseObj.Id );
            if(relatedCase != null){
            if( relatedCase.Account.RefLabs_Existing_Onboarding_Case__c || relatedCase.Account.Reference_Lab_Customer__c ) {
                caseObj.addError ( REFLABS_DUPLICATE_ONBOARDING_CASE_ERROR );
            }
            }
        }
    }
    
    /**
     * Helper method to validate records related to a Case to determine if a field that is required to maintain a Ready to Sync status for Sending to PV Works has been nulled out
     * 
     * @param List<SObject> triggerNew - Trigger.new from the calling trigger 
     * @param Map<Id, SObject> triggerOldMap - Trigger.oldMap from the calling trigger
     * @param Set<String> fieldSetMembers - set of field API names for the Approval Validation check field set
     * @param String caseLookupFieldName - API name of the case lookup field on the related object
     * 
     * @return void - does not need to return anything as it should just set the error on the offending records 
     */
    public static void validateRelatedRecordsForSendingToPVWorks( List<SObject> triggerNew, Map<Id, SObject> triggerOldMap, String caseLookupFieldName )
    {
        // first lets make sure that we have all the required inputs for this method
        if ( ( triggerNew == null || triggerNew.isEmpty() ) ||
             ( triggerOldMap == null || triggerOldMap.isEmpty() ) ||
             String.isBlank( caseLookupFieldName )
        )
        {
            System.debug( 'Missing required inputs for SL_CaseTriggerHandler::' );
            return;
        }


        // next, lets extract the case id values
        Set<String> caseIds = new Set<String>();
        for ( SObject sObj : triggerNew )
        {
            String caseId = ( String ) sObj.get( caseLookupFieldName );
            caseIds.add( caseId );
        }

        // now lets build our case query string
        final Set<String> VMIPS_CASE_TYPES_FOR_PVWORKS = new Set<String>{ 'Animal Complaint', 'Human Exposure', 'Product Defect' };
        final String syncUnapproved = VmipsCaseSyncStatusHandler.SYNC_UNAPPROVED;

        String caseQueryString = ' SELECT Id,Type ' + // only really need id from this query because we're using our query to filter the records out that we don't care about
                                    ' FROM Case ' +
                                    ' WHERE Id IN :caseIds ' + 
                                    ' AND RecordTypeId = :animalRecordTypeId' +
                                    ' AND Type IN :VMIPS_CASE_TYPES_FOR_PVWORKS ' +
                                    ' AND Sync_Status__c != :syncUnapproved';
        

        // lets execute our case query and store the results in a map of case id => case
        Map<Id, Case> relatedCases = new Map<Id, Case>( ( List<Case> ) Database.query( caseQueryString ) );
        String recordTypeFilter;
        if(triggerNew[0].getSObjectType() == ZTS_US_Assessment__c.SObjectType){
            String localRecordtypeId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get('ZTS_US_Local_Assessment').getRecordTypeId(); 
            String productRecordtypeId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get('ZTS_US_Product_Assessment').getRecordTypeId();
            if((String)triggerNew[0].get('RecordTypeId') == localRecordtypeId){
                recordTypeFilter = 'Local';
            }
            if((String)triggerNew[0].get('RecordTypeId') == productRecordtypeId){
                recordTypeFilter = 'Product';
            }
        }
        else if(triggerNew[0].getSObjectType() == ZTS_US_Case_Product__c.SObjectType){
            String ztsRecordtypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId(); 
            String nonZTSRecordtypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Non_Zoetis_Product').getRecordTypeId();
            if((String)triggerNew[0].get('RecordTypeId') == ztsRecordtypeId){
                recordTypeFilter = 'ZTS Product';
            }
            if((String)triggerNew[0].get('RecordTypeId') == nonZTSRecordtypeId){
                recordTypeFilter = 'Non-ZTS Product';
            }
        }
        
        if(relatedCases!=null && !relatedCases.isEmpty()){
            Map<String,Set<String>> metaDataFieldsByObjectName = SL_CaseTriggerHelper.retrieveApprovalFieldsFromMetadata(relatedCases.values()[0].Type,recordTypeFilter);
            for ( SObject sObj : triggerNew )
            {
                string objectName = sObj.getSObjectType().getDescribe().getName();
                Set<String> metaDataFields = (metaDataFieldsByObjectName!=null ? metaDataFieldsByObjectName.get(objectName):null);
                // check to see if our case map contains the related case. if not, we can skip this iteration because its not a record related to a case that matters for our pv works validation
                String relatedCaseId = ( String ) sObj.get( caseLookupFieldName );
                if ( !relatedCases.containsKey( relatedCaseId ) || metadataFields == null )
                {
                    continue;
                }

                // if the case is found, iterate over the field set members and compare the values to see if they have changed
                for ( String fieldAPIName : metaDataFields )
                {
                    // if they have changed, if the value is now null we need to add an error
                    SObject oldSObject = triggerOldMap.get( sObj.Id );
                    if ( sObj.get( fieldAPIName ) != oldSObject.get( fieldAPIName ) && sObj.get( fieldAPIName ) == null )
                    {
                        sObj.addError( String.format( REQUIRED_FIELD_NULLED, new List<String>{ (String)Schema.getGlobalDescribe().get(sObj.getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get(fieldAPIName).getDescribe().getLabel(), sObj.getSObjectType().getDescribe().getLabel()  } ) );
                    }
                }
            }
        }
        
    }
}