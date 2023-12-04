/**
 * @description       : Service class for Diagnostic Cases (Reference Labs Onboarding and Reference Lab Support)
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 05-16-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   04-23-2022   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   05-06-2022   Ethan Hirsch @ Zoetis Inc      Add returnNonClosedRefLabOnboardingSupportCases method
 * 1.2   07-27-2022   Morgan Marchese @ Zoetis Inc   Migrated Field Force Final Strings to FieldForceSettingsService
**/
public with sharing class DiagnosticCaseService {

    public static final String VACANT_EMPLOYEE = 'Vacant Vacant';
    public static final String TERRITORY_TYPE_TERRITORY = 'Territory';

    @TestVisible
    private static final String REFLABS_OB_RT_DEVNAME = 'Ref_Labs_Onboarding';
    @TestVisible
    private static final String REFLABS_SUPPORT_RT_DEVNAME = 'Reference_Labs_Support';
    @TestVisible
    private static final String REFLABS_ONBOARDING_Q_DEVNAME = 'Ref_Labs_Sales_Consultants_Queue';
    @TestVisible
    private static final String REFLABS_COURIER_TYPE = Label.RefLabs_Courier_Type;
    private static final String REFLABS_CARRIER_UPS = Label.RefLabs_Carrier_UPS;
    

    // TO-DO: Update this later after CaseService goes live so that CaseService has a global GetRecordTypeInfosByDeveloperName Singleton method
    @TestVisible
    private static Map<String, Schema.RecordTypeInfo> refLabsRecordTypesByDevName {
        get{
            if(refLabsRecordTypesByDevName == null){
                refLabsRecordTypesByDevName = new Map<String, Schema.RecordTypeInfo>();
                for(String rtDevName : Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().keySet()){
                    if(rtDevName.equalsIgnoreCase(REFLABS_OB_RT_DEVNAME) || rtDevName.equalsIgnoreCase(REFLABS_SUPPORT_RT_DEVNAME)){
                        refLabsRecordTypesByDevName.put(rtDevName,Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtDevName));
                    }
                }
            }
            return refLabsRecordTypesByDevName;
        }
        private set;
    }

    @TestVisible
    private static String refLabsOnboardingRecordtypeId
    {
        get
        {
            if ( refLabsOnboardingRecordtypeId == null ) refLabsOnboardingRecordtypeId = refLabsRecordTypesByDevName.get(REFLABS_OB_RT_DEVNAME).getRecordTypeId();
            return refLabsOnboardingRecordtypeId;
        }
        private set;
    }

    @TestVisible
    private static String refLabsSupportRecordtypeId
    {
        get
        {
            if ( refLabsSupportRecordtypeId == null ) refLabsSupportRecordtypeId = refLabsRecordTypesByDevName.get(REFLABS_SUPPORT_RT_DEVNAME).getRecordTypeId();
            return refLabsSupportRecordtypeId;
        }
        private set;
    }

    @TestVisible
    private static Map<String, Group> refLabsQueues
    {
        get {
            if(refLabsQueues == null) refLabsQueues = getRefLabsQueues();
            return refLabsQueues;
        }
        private set;
    }

    public static List<Case> returnClosedRefLabOnboardingCases(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        if(newCaseList.isEmpty()){
            return newCaseList;
        }

        List<Case> closedOnboardingCases = new List<Case>();
        Boolean isStatusChanged = false;
        Boolean isClosed = false;
        Case oldCase;

        for(Case objCase : newCaseList){
            oldCase = oldCaseMap.get(objCase.Id);
            isClosed = objCase.Status.equalsIgnoreCase('Closed');
            isStatusChanged = objCase.Status != oldCase.Status;

            if(objCase.RecordTypeId == refLabsOnboardingRecordtypeId){
                if(isStatusChanged && isClosed){
                    // Add to Case List
                    closedOnboardingCases.add(objCase);
                }
            }
        }

        return closedOnboardingCases;
    }

    public static void createRefLabsInServiceCases(List<Case> caseList){
        if(caseList == null || caseList.isEmpty()){
            return;
        }

        Set<Id> accountIds = new Set<Id>();
        Map<Id, Id> accountIdToContactIdMap = new Map<Id, Id>(); // Account Id -> Case Contact Id
        for(Case objCase : caseList){
            accountIds.add(objCase.AccountId);
            accountIdToContactIdMap.put(objCase.AccountId,objCase.ContactId);
        }

        Map<Id, List<ZTS_EU_Account_Position__c>> accountIdToDXAccountPositionsMap = getDiagnosticAPSByAccountIdMap(accountIds);

        List<Case> inServiceCases = new List<Case>();
        for(Id accId : accountIds){
            inServiceCases.add(
                new Case(
                    AccountId = accId, 
                    ContactId = accountIdToContactIdMap.get(accId),
                    recordTypeId = refLabsSupportRecordtypeId,
                    Type = 'In Service',
                    Subject = 'Ref Lab Support - In Service',
                    OwnerId = determineCaseAssignment(accountIdToDXAccountPositionsMap.get(accId))
                )
            );
        }

        if(!inServiceCases.isEmpty()){
            insert inServiceCases;
        }
    }

    public static List<ZTS_EU_Account_Position__c> findTeamMembers(List<ZTS_EU_Account_Position__c> teamMembers, String fieldForceName){
        List<ZTS_EU_Account_Position__c> teamMembersToReturn = new List<ZTS_EU_Account_Position__c>();

        for(ZTS_EU_Account_Position__c member : teamMembers){
            if(member.ZTS_Field_Force_Name__c == fieldForceName){
                teamMembersToReturn.add(member);
            }
        }
        return teamMembersToReturn;
    }

    private static Map<String, Group> getRefLabsQueues(){
        Map<String, Group> queueMap = new Map<String,Group>();
        
        List<Group> queues = [
            SELECT 
                Id, 
                Name, 
                DeveloperName 
            FROM Group 
            WHERE Type = 'Queue' 
            AND DeveloperName LIKE 'Ref_Labs%'
        ];

        for(Group queue : queues){
            if(!queueMap.containsKey(queue.DeveloperName)){
                queueMap.put(queue.DeveloperName, queue);
            }
        }
        return queueMap;
    }

    private static Id determineCaseAssignment(List<ZTS_EU_Account_Position__c> accountPositionList){
        Id ownerId;
        List<ZTS_EU_Account_Position__c> diagnosticsTeamMembers;
        
        // Check for "Diagnostics Tech Services"
        diagnosticsTeamMembers = findTeamMembers(accountPositionList, FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS_TECH);
        //If a single diagnostics team member was found assign them as the lead owner
        if(!diagnosticsTeamMembers.isEmpty() && diagnosticsTeamMembers.size() == 1){
            ownerId = diagnosticsTeamMembers[0].ZTS_Employee_ID__c;
        } else {
            // Check for "Diagnostics Technical Serices" because name may have changed
            diagnosticsTeamMembers = findTeamMembers(accountPositionList, FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS_REGIONAL_TECH);
            //If a single diagnostics team member was found assign them as the lead owner
            if(!diagnosticsTeamMembers.isEmpty() && diagnosticsTeamMembers.size() == 1){
                ownerId = diagnosticsTeamMembers[0].ZTS_Employee_ID__c;
            } else {
                // Check for "Diagnostics Solution Consultant"
                diagnosticsTeamMembers = findTeamMembers(accountPositionList, FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS);
                //If a single diagnostics team member was found assign them as the lead owner
                if(!diagnosticsTeamMembers.isEmpty() && diagnosticsTeamMembers.size() == 1){
                    ownerId = diagnosticsTeamMembers[0].ZTS_Employee_ID__c;
                } else{
                    // Check for "Inside Sales Diagnostics"
                    diagnosticsTeamMembers = findTeamMembers(accountPositionList, FieldForceSettingsService.FIELD_FORCE_INSIDE_SALES_DIAGNOSTICS);
                    //If a single diagnostics team member was found assign them as the lead owner
                    if(!diagnosticsTeamMembers.isEmpty() && diagnosticsTeamMembers.size() == 1){
                        ownerId = diagnosticsTeamMembers[0].ZTS_Employee_ID__c;
                    }else{
                        // Else Assign to Ref Labs Onboarding Case Queue
                        ownerId = refLabsQueues.get(REFLABS_ONBOARDING_Q_DEVNAME).Id;
                    }
                }
            } 
        }
        return ownerId;
    }

    private static Map<Id, List<ZTS_EU_Account_Position__c>> getDiagnosticAPsByAccountIdMap(Set<Id> accountIds){
        if(accountIds == null){
            return new Map<Id, List<ZTS_EU_Account_Position__c>>();
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(
            AccountSelector.newInstance().selectAccountsWithDiagnosticAPs(accountIds)
        );

        Map<Id, List<ZTS_EU_Account_Position__c>> dxAPMap = new Map<Id, List<ZTS_EU_Account_Position__c>>();

        for(Id accId : accountMap.keySet()){
            dxAPMap.put(accId,accountMap.get(accId).Account_Positions__r);
        }

        return dxAPMap;
    }

    /**
    * @description Returns Cases that have a Record Type of Reference Labs Onboarding or Reference Labs Support 
    *              and Status with a value other than closed. THey also must have Account or Contact specified
    * @author Ethan Hirsch @ Zoetis Inc | 05-03-2022 
    * @param newCaseList 
    * @return List<Case> 
    **/
    public static List<Case> returnNonClosedRefLabOnboardingSupportCasesWithAccountOrContact(List<Case> newCaseList) {
        List<Case> nonClosedCases = new List<Case>();
        for (Case newCase : newCaseList) {
            if ((newCase.RecordTypeId == refLabsOnboardingRecordtypeId || newCase.RecordTypeId == refLabsSupportRecordtypeId) &&
                (newCase.AccountId != null || newCase.ContactId != null) &&
                newCase.Status != 'Closed') {
                nonClosedCases.add(newCase);
            }
        }

        return nonClosedCases;
    }

    /**
    * @description Copies fields from Accounts to Case. For Reference Lab Onboarding Cases, 
    *              the Account's Onboarding Case Status will also be set to true.
    * @author Ethan Hirsch @ Zoetis Inc | 05-06-2022 
    * @param diagnosticCases 
    **/
    public static void setReferenceLabFieldsByAccount(List<Case> diagnosticCases) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Id> accountIdContactIdMap = new Map<Id,Id>();
        Map<Id,Account> mapAccountIdToAccount = new Map<Id,Account>();
        for(Case diagonsticCase : diagnosticCases) {
            if(diagonsticCase.ContactId != null) {
                contactIds.add(diagonsticCase.ContactId);
            } 
            else {
                accountIds.add(diagonsticCase.AccountId);
            }
        }

        // AccountId is not populated on a Case on Insert when ContactId is specified.
        // To work around this, Contacts are queried for to retrieve their related Account.
        // Those Accounts are then treated as though they were set directly on the Case.
        if (!contactIds.isEmpty()) {
            for(Contact con : ContactSelector.newInstance().selectById(contactIds)){
                accountIds.add(con.AccountId);
                accountIdContactIdMap.put(con.Id, con.AccountId );
            }
        }

        if (!accountIds.isEmpty()) {
            mapAccountIdToAccount = new Map<Id,Account>(
                AccountSelector.newInstance().selectAccountWithReferenceLabFields(accountIds));
        }

        Map<Id, Account> onboardingCaseAccountMap = new Map<Id, Account>();

        for(Case diagnosticCase: diagnosticCases) {
            Account relatedAccount;
            if(diagnosticCase.AccountId != null){
                relatedAccount = mapAccountIdToAccount.get(diagnosticCase.AccountId);
            }
            else {
                relatedAccount = mapAccountIdToAccount.get(accountIdContactIdMap.get(diagnosticCase.ContactId));
            }

            if (relatedAccount == null) {
                continue;
            }

            if(diagnosticCase.RecordTypeId == refLabsOnboardingRecordtypeId) {
                onboardingCaseAccountMap.put(relatedAccount.Id, relatedAccount);
            }

            setDiagnosticFieldsOnCaseFromAccount(diagnosticCase, relatedAccount);
        }

        if(!onboardingCaseAccountMap.isEmpty()) {
            AccountsService.setOnboardingCaseStatus(onboardingCaseAccountMap.values(), true);
        }
    }

    /**
    * @description Copy fields from Account to Case 
    * @author Ethan Hirsch @ Zoetis Inc | 05-03-2022 
    * @param diagnosticCase 
    * @param relatedAccount 
    **/
    private static void setDiagnosticFieldsOnCaseFromAccount(Case diagnosticCase, Account relatedAccount) {
        if(String.isBlank(diagnosticCase.Primary_Lab_Location__c)) {
            diagnosticCase.Primary_Lab_Location__c = relatedAccount.Primary_Lab_Location__c;
        }

        if (diagnosticCase.Type == REFLABS_COURIER_TYPE) {

            if(String.isBlank(diagnosticCase.Courier_Request_Type__c)) {
                diagnosticCase.Courier_Request_Type__c = relatedAccount.Courier_Request_Type__c;
            }

            if(String.isBlank(diagnosticCase.Send_In_Courier__c)) {
                diagnosticCase.Send_In_Courier__c = relatedAccount.Send_In_Courier__c;
            }

            if(String.isBlank(diagnosticCase.Courier_Service_Provider__c) && 
                diagnosticCase.Primary_Lab_Location__c == relatedAccount.Primary_Lab_Location__c) {
                diagnosticCase.Courier_Service_Provider__c = relatedAccount.Courier_Service_Provider__c;
            }

            if(String.isBlank(diagnosticCase.Days_of_Pickup__c)) {
                diagnosticCase.Days_of_Pickup__c = relatedAccount.Days_of_Pickup__c;
            }

            // Due to Dropbox_Needed__c being a dependent picklist of Send_In_Courier__c,
            // Dropbox_Needed__c is only set if Send_In_Courier__c matches on the Case and Account
            if(String.isBlank(diagnosticCase.Dropbox_Needed__c) &&
                diagnosticCase.Send_In_Courier__c == relatedAccount.Send_In_Courier__c) {
                diagnosticCase.Dropbox_Needed__c = relatedAccount.Dropbox_Needed_if_Courier__c;
            }

            if(diagnosticCase.Pickups_Per_Day__c ==null) {
                diagnosticCase.Pickups_Per_Day__c = relatedAccount.Pick_ups_Per_Day__c;
            }

            if(String.isBlank(diagnosticCase.Preferred_Pickup_Time__c)) {
                diagnosticCase.Preferred_Pickup_Time__c = relatedAccount.Preferred_Pickup_Time__c;
            }

            if(diagnosticCase.Start_Date__c == null) {
                diagnosticCase.Start_Date__c = relatedAccount.Start_Date__c;
            }

            if(String.isBlank(diagnosticCase.UPS_PPP_Customer__c)) {
                diagnosticCase.UPS_PPP_Customer__c = relatedAccount.UPS_PPP_Customer__c;
            }

            if(String.isBlank(diagnosticCase.UPS_PPP_Pickup_Location__c)
                && diagnosticCase.Primary_Lab_Location__c == relatedAccount.Primary_Lab_Location__c
                && diagnosticCase.Send_In_Courier__c == relatedAccount.Send_In_Courier__c
                && relatedAccount.Send_In_Courier__c != REFLABS_CARRIER_UPS
                && diagnosticCase.Dropbox_Needed__c == relatedAccount.Dropbox_Needed_if_Courier__c) {
                diagnosticCase.UPS_PPP_Pickup_Location__c = relatedAccount.UPS_PPP_Pickup_Location__c;
            }

            if(String.isBlank(diagnosticCase.Will_Call_Time__c)) {
                diagnosticCase.Will_Call_Time__c = relatedAccount.Will_Call_Time__c;
            }

            // For support case of type courier, check to trigger email to vendor
            if(diagnosticCase.RecordTypeId == refLabsSupportRecordTypeId && diagnosticCase.type == REFLABS_COURIER_TYPE
                && diagnosticCase.Send_In_Courier__c != relatedAccount.Send_In_Courier__c
                && (relatedAccount.Send_In_Courier__c == REFLABS_CARRIER_UPS || String.isBlank(relatedAccount.Send_In_Courier__c))) {
                diagnosticCase.Send_Courier_Notification__c = true;
            }
        }
    }
}