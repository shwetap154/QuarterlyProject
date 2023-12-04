/**
 * @description       : Main Service class for Cases
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-14-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-24-2022   Ethan Hirsch @ Zoetis Inc   Initial Version
 * 1.1   04-11-2022   Ethan Hirsch @ Zoetis Inc   Add unblockRelatedRefLabOnboardingCases method
 * 1.2   04-12-2022   Ethan Hirsch @ Zoetis Inc   Update unblockRelatedRefLabOnboardingCases method to also uncheck Has_RefLabs_Multiple_Ship_To__c
 * 1.3   04-14-2022   Ethan Hirsch @ Zoetis Inc   Fix a bug where the Case Trigger Bypass wasn't cleared after Cases were updated.

**/
public with sharing class CaseService {
    @testVisible private static final String REFLABS_ONBOARDING_CASE_ON_HOLD_ERROR = Label.RefLabs_Onboarding_Case_On_Hold_Error;
    @testVisible private static final String MDM_CHILD_CASE_MULTIPLE_SHIP_TO = Label.Reflabs_MDM_Child_Case_Subject;
    @testVisible private static final String REFLABS_TYPE_MASTER_DATA = Label.Reflabs_Type_Master_Data;
    @testVisible private static final String REFLABS_SUBTYPE_TYPE_ACCOUNT_CHANGE = Label.Reflabs_Subtype_Account_Change;
    @testVisible private static final String INSERT_REFLABS_DATAREQUEST_EXCEPTION = 'CaseService - createDataRequestChildCasesForRefLabsOnboardingCase - insert new Data Request Cases()';
    @testVisible private static final String UPDATE_REFLABSADDRESS_EXCEPTION = 'CaseService - determineReferenceLabsShipToAddress - update Address';
    @testVisible private static final String DIAGNOSTICS_ENTITLEMENT_NAME = 'Diagnostics';
    @testVisible private static final String DIAGNOSTICS_ACCOUNT_NAME = 'DIAGNOSTICS ENTITLEMENT ACCOUNT - DO NOT MODIFY';

    // The following variables are marked Public as they are also used in SL_CaseTriggerHandler. Ideally they should be marked private
    public static String refLabsOnboardingRecordtypeId
    {
        get
        {
            if ( refLabsOnboardingRecordtypeId == null ) refLabsOnboardingRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Ref_Labs_Onboarding' ).getRecordTypeId();
            return refLabsOnboardingRecordtypeId;
        }
        private set;
    }

    public static Service_Cloud_Settings__mdt serviceCloudCustomMetadata
    {
        get
        {
            if ( serviceCloudCustomMetadata == null ) {
                serviceCloudCustomMetadata = Service_Cloud_Settings__mdt.getInstance('DEFAULT');
            }
            return serviceCloudCustomMetadata;
        }
        private set;
    }

    private static String dataRequestRecordTypeId
    {
        get
        {
            if ( dataRequestRecordTypeId == null ) dataRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Data_Request' ).getRecordTypeId();
            return dataRequestRecordTypeId;
        }
        private set;
    }

    /**
    * @description Determines the Reference Lab Ship To Address of a Reference Onboarding Case's Account.
    *     If an Account has multiple addresses, the Case is given a Status of On Hold and Has_RefLabs_Multiple_Ship_To__c is set to true.
    *     If an On Hold Case is updated and it still has multiple addresses, an error is returned.
    *     If an On Hold Case is updated and it either no longer has multiple addresses or one address was set as the Reference Lab Ship TO Address, 
    *     the Case's Status is reset to New.
    *     This method runs before insert/update and updates related Addresses. Addresses are updated here for a few reasons:
    *     1. Since they need to be queried for to update the Case.
    *     2. To save a SOQL query querying them again after Insert/Update
    *     3. To avoid having to pass context between Before and After logic.
    * @author Ethan Hirsch @ Zoetis Inc | 03-24-2022 
    * @param newCases 
    * @param oldCasesMap 
    **/
    public static void determineReferenceLabsShipToAddress(List<Case> newCases, Map<Id, Case> oldCasesMap) {
        List<Case> refLabsOnboardingCases = new List<Case>();
        Set<Id> caseAccountIds = new Set<Id>();
 
        for (Case newCase : newCases) {
            if(newCase.RecordTypeId == refLabsOnboardingRecordtypeId){
                refLabsOnboardingCases.add(newCase);
                if (newCase.AccountId != null) {
                    caseAccountIds.add(newCase.AccountId);
                }
            }
        }
 
        if(refLabsOnboardingCases.isEmpty()){
            return;
        }
         
        Map<Id, List<Address__c>> addressesByAccountId = new Map<Id, List<Address__c>>();
        Map<Id, Boolean> accountHasReferenceLabShipToAddress = new Map<Id, Boolean>();
        for (Address__c address : AddressesSelector.newInstance().selectDirectActiveShipToAddressesByAccountId(caseAccountIds)) {
            if (addressesByAccountId.containsKey(address.ZTS_EU_Account__c) == false) {
                addressesByAccountId.put(address.ZTS_EU_Account__c, new List<Address__c>());
            }

            addressesByAccountId.get(address.ZTS_EU_Account__c).add(address);

            // If an Account has an Address where Reference_Labs_Ship_to__c is true, treat the Account has only having one Ship To Address.
            // The Status for the Onboarding Case can change in this situation.
            if (address.Reference_Labs_Ship_to__c) {
                accountHasReferenceLabShipToAddress.put(address.ZTS_EU_Account__c, true);
            }
        }

        Map<Id, Address__c> addressesToUpdateMap = new Map<Id, Address__c>();
        for (Case onboardingCase : refLabsOnboardingCases) {
            Id caseAccountId = onboardingCase.AccountId;

            // If a Case's Account does not have a Reference Lab Ship To Address and either has 0 addresses 
            // or more than one Address, it should be placed On Hold.
            if (accountHasReferenceLabShipToAddress.containsKey(caseAccountId) == false && 
                (addressesByAccountId.containsKey(caseAccountId) == false || 
                addressesByAccountId.get(caseAccountId).size() > 1)) {
                // If Status of this Case was previously On Hold and Status was attempted to be changed, 
                // throw an error preventing the user from changing the Status.
                if (oldCasesMap != null && oldCasesMap.get(onboardingCase.Id).Status == 'On Hold'
                    && onboardingCase.Status != 'On Hold') {
                    onboardingCase.Status.addError( REFLABS_ONBOARDING_CASE_ON_HOLD_ERROR );
                    continue;
                }
                else if (addressesByAccountId.containsKey(caseAccountId) 
                    && addressesByAccountId.get(caseAccountId).size() > 1) {
                    onboardingCase.Has_RefLabs_Multiple_Ship_To__c = true;
                }

                onboardingCase.Status = 'On Hold';
            }
            else {
                // Reset the Case's Status and Has_RefLabs_Multiple_Ship_To__c field if it only has a single Address
                // Or one Address has had Reference_Labs_Ship_to__c set to true 
                onboardingCase.Has_RefLabs_Multiple_Ship_To__c = false;
                if(onboardingCase.Status == 'On Hold') {
                    onboardingCase.Status = 'New';
                }

                // Set Reference_Labs_Ship_to__c = true on the Account's Address if it's not already set
                if (accountHasReferenceLabShipToAddress.containsKey(caseAccountId) == false) {
                    Address__c firstAddress = addressesByAccountId.get(caseAccountId)[0];
                    firstAddress.Reference_Labs_Ship_to__c = true;

                    // The Address is always added to the Map to update as this is the only update that can occur to the Address.
                    // Overrides to the record added to the map will not change any behavior.
                    addressesToUpdateMap.put(firstAddress.Id, firstAddress);
                }
            }
        }

        try {
            if (!addressesToUpdateMap.isEmpty()) {
                DispatchTriggerHandler.bypass('AddressTriggerHandler');
                new WithoutSharing().updateRecords(addressesToUpdateMap.values());
                DispatchTriggerHandler.clearBypass('AddressTriggerHandler');
            }
        }
        catch (DmlException dex) {
            logDmlException(dex, UPDATE_REFLABSADDRESS_EXCEPTION);
        }
    }

    /**
    * @description On insert of new Refs Labs Onboarding Cases, create Data Request Child Cases if 
    *   Case.Has_RefLabs_Multiple_Ship_To__c is set to true.
    *   This method works in tandem with determineReferenceLabsShipToAddress which 
    *   sets Has_RefLabs_Multiple_Ship_To__c to true
    * @author Ethan Hirsch @ Zoetis Inc | 03-24-2022 
    * @param newCases
    **/
    public static void createDataRequestChildCasesForRefLabsOnboardingCase(List<Case> newCases) {
        List<Case> dataRequestCaseList = new List<Case>();
 
        for (Case newCase : newCases) {
            // Create a Data Request Child Case if the following conditions are met:
            // 1. Case Record Type is Refs Labs Onboarding
            // 2. Has_RefLabs_Multiple_Ship_To__c is set to true on the Case.
            // This method works in tandem with determineReferenceLabsShipToAddress 
            // which sets Has_RefLabs_Multiple_Ship_To__c to true
            if(newCase.RecordTypeId == refLabsOnboardingRecordtypeId && newCase.Has_RefLabs_Multiple_Ship_To__c ){
                dataRequestCaseList.add(createChildDataRequestCase(newCase, 
                    serviceCloudCustomMetadata.Master_Data_Queue_ID__c) );
            }
        }

        try {
            if(!dataRequestCaseList.isEmpty()) {
                insert dataRequestCaseList;
            }
        }
        catch (DmlException dex) {
            logDmlException(dex, INSERT_REFLABS_DATAREQUEST_EXCEPTION);
        }
    }

    /**
    * @description Sets Entitlement on the Case to the Diagnostic Entitlement record
    * @author Ethan Hirsch @ Zoetis Inc | 03-24-2022 
    * @param diagnosticCases 
    **/
    public static void setDiagnosticEntitlementOnCase( List<Case> diagnosticCases ) {
        List<Entitlement> diagnosticEntitlements = [
            SELECT Id 
            FROM Entitlement
            WHERE Name =: DIAGNOSTICS_ENTITLEMENT_NAME
            AND SlaProcess.Name =: DIAGNOSTICS_ENTITLEMENT_NAME
            AND Account.Name =: DIAGNOSTICS_ACCOUNT_NAME
            LIMIT 1];
        
        if (diagnosticEntitlements.size() == 0) {
            return;
        }

        Id diagnosticEntitlementId = diagnosticEntitlements[0].Id;
        for(Case diagnosticCase : diagnosticCases) {
            diagnosticCase.EntitlementId = diagnosticEntitlementId;
        }
    }

    /**
    * @description Changes the Status of Reference Labs Onboarding Cases for the passed in Accounts to
    *              In Progress if they were previously On Hold. Also uncheck Has_RefLabs_Multiple_Ship_To__c if checked
    * @author Ethan Hirsch @ Zoetis Inc | 04-11-2022 
    * @param accountIds 
    **/
    public static void unblockRelatedRefLabOnboardingCases(Set<Id> accountIds) {
        List<Case> casesToUpdate = new List<Case>();
        for (Case accountCase : CasesSelector.newInstance().selectyByAccountIdsAndRecordTypeDeveloperNames(
                                    accountIds, new Set<String> {'Ref_Labs_Onboarding' })) {
            Boolean updateCase = false;
            if (accountCase.Status == 'On Hold') {
                accountCase.Status = 'In Progress';
                updateCase = true;
            }

            if (accountCase.Has_RefLabs_Multiple_Ship_To__c) {
                accountCase.Has_RefLabs_Multiple_Ship_To__c = false;
                updateCase = true;
            }

            if (updateCase) {
                casesToUpdate.add(accountCase);
            }
        }

        if (casesToUpdate.size() > 0) {
            // Case uses a Trigger bypass that is configured in a Custom Setting
            string caseTriggerName = 'ZTS_EU_ServiceRequest';
            CustomSettingService.setTriggerBypass(caseTriggerName, true);
            update casesToUpdate;
            CustomSettingService.setTriggerBypass(caseTriggerName, false);
        }
    }

    private static Case createChildDataRequestCase(Case parentCase, String masterDataQueue){
		
        return new Case(ParentId = parentCase.Id
        ,   Subject = MDM_CHILD_CASE_MULTIPLE_SHIP_TO
        ,   Description = MDM_CHILD_CASE_MULTIPLE_SHIP_TO
        ,   RecordTypeId = dataRequestRecordTypeId
        ,   OwnerId = masterDataQueue
        ,   Type = REFLABS_TYPE_MASTER_DATA
        ,   Sub_Type_2__c = REFLABS_SUBTYPE_TYPE_ACCOUNT_CHANGE
        ,   AccountId = parentCase.AccountId
        ,   ContactId = parentCase.ContactId
        ,   Origin = parentCase.Origin
        );

    }

    private static void logDmlException(DmlException dex, string errorMessage) {
        String errorMessages = '';
        for ( Integer i = 0; i < dex.getNumDml(); i++ ) {
            errorMessages += dex.getDmlMessage( i ) + '\n';
        }
        errorMessages.removeEnd( '\n' );
        ZTS_EU_Logger.notify = true;
        ZTS_EU_Logger.error( errorMessages,null, errorMessage );
    }

    private without sharing class WithoutSharing {
        public void updateRecords(List<SObject> records) {
            update records;
        }
    }
}