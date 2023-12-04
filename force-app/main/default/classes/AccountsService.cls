/**
 * @description       : Service class for Accounts
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 05-10-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-13-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with setPrimaryProgramOwnerOnAccounts method
 * 1.1   04-14-2022   Ethan Hirsch @ Zoetis Inc   Add an additional comment
 * 1.2   05-06-2022   Ethan Hirsch @ Zoetis Inc   Add setOnboardingCaseStatus method
 * 1.3   08-29-2022   Ethan Hirsch @ Zoetis Inc   Add setSendToDMRFlagUpdate method for flagging Accounts to send to DMR
 * 1.4   08-30-2022   Ethan Hirsch @ Zoetis Inc   Update setSendToDMRFlagUpdate to pull Markets from Metadata and
 *                                                ignored Users via a field.
 * 1.5   08-30-2022   Ethan Hirsch @ Zoetis Inc   Add setSendToDMRFlagCreate method for flagging Accounts to send to DMR
 * 1.6   08-30-2022   Ethan Hirsch @ Zoetis Inc   Combine setSendToDMRFlagCreate and setSendToDMRFlagUpdate into a 
 *                                                single method setSendToDMRFlag to support more use cases.
 * 1.6   08-31-2022   Ethan Hirsch @ Zoetis Inc   Add logic setSendToDMRFlag to uncheck DMR Flags
 * 1.7   09-07-2022   Ethan Hirsch @ Zoetis Inc   Only set the DMR Create flag if something has changed to make the 
 *                                                Account valid for create. This was done to allow the integration
 *                                                to set Send to DMR Create to false before setting a DMR Id.
 * 1.8   09-12-2022   Ethan Hirsch @ Zoetis Inc   Update the logic so that the DMR Update flag can be set to true when DMR Id is blank 
 * 1.3   05-25-2022   Ethan Hirsch @ Zoetis Inc   Add mergeRelatedDataInternational for handling merging duplicate child records on merge of Account
 * 1.4   05-26-2022   Ethan Hirsch @ Zoetis Inc   Update mergeRelatedDataInternational to change error handling to give more helpful error messages
 * 1.5   06-22-2022   Ethan Hirsch @ Zoetis Inc   Update the order of operation records are updated and deleted in mergeRelatedDataInternational 
 *                                                to avoid unique key errors.
 * 1.6   06-23-2022   Ethan Hirsch @ Zoetis Inc   Update update and delete for INTL Merge logic to run without sharing to avoid security errors on merge.
 *                                                The existing updateRecords method was left in place to avoid needing to regression test existing functionality.
 * 1.7   06-28-2022   Ethan Hirsch @ Zoetis Inc   Disable the Account Territory Trigger from running when deleting Account Territories on merge to avoid deletion
 *                                                of Assigned Territories.
 *                                                Also disable CPQ to avoid a callout exception 
 * 1.8   07-06-2022   Ethan Hirsch @ Zoetis Inc   Disable the Account Territory merge logic as requirements are reconfirmed. This will be added back in the near future.
 * 1.9   07-06-2022   Ethan Hirsch @ Zoetis Inc   Change the response of the return type from selectChildObjectsByParentObjectAndMarket
 * 1.10  07-15-2022   Ethan Hirsch @ Zoetis Inc   Reenable Account Territory Merge
 * 1.11  07-21-2022   Ethan Hirsch @ Zoetis Inc   Disable the Account Territory Trigger Handler when testing update errors to avoid duplicate Account Positions.
 * 1.12  01-24-2023   Padma Nerella @ Zoetis Inc  Added getAccountsWithEmailChanges method to get accountlist to update the contact TPDev-103
 * 1.13  03-28-2023   Padma Nerella @ Zoetis Inc  Added updateAccountCertificationStatus to update account certification status TPDev-89
 * 1.14  05-03-2023   Padma Nerella @ Zoetis Inc  Added updateZTSEUCorporateFlagFromINTLParentAcc and updateZTSEUCorporateFlagFromINTLParentAccHelperMethod to update corporate flag from parent account TPDev-109
**/
public with sharing class AccountsService {
    @testVisible
    private static final String accountMergeLogType = 'Account Merge';
    
    private static final String mergeUpdateErrorMessageFormat = 'Failed to update record {0} on merge of Accounts {1}. Please fix the error, verify the record was not deleted, and its unique key(s) are updated. Error: {2}';
    private static final String mergeDeleteErrorMessageFormat = 'Failed to delete record {0} on merge of Accounts {1}. Please fix the error and manually delete the record. Error: {2}';

    /**
    * @description Sets MZR Program Owner, VGP Program Owner, and/or LE Program Owner for an Account using
    *              the related Account Position that has been marked as the Primary Program Owner for that Program.
    * @author Ethan Hirsch @ Zoetis Inc | 04-13-2022 
    * @param accountPositions 
    **/
    public static void setPrimaryProgramOwnerOnAccounts(List<ZTS_EU_Account_Position__c> accountPositions) {
        Set<Id> accountIds = new Set<Id>();
        List<ZTS_EU_Account_Position__c> primaryAccountPositions = new List<ZTS_EU_Account_Position__c>();
        
        // Process Account Positions where one Program Owner field is Primary and there's a related Account and Employee
        for (ZTS_EU_Account_Position__c accountPosition : accountPositions) {
            if (accountPosition.ZTS_EU_Position__c != null && accountPosition.ZTS_EU_Account__c != null &&
                (accountPosition.VGP_Program_Owner__c == 'Primary' || accountPosition.MZR_Program_Owner__c == 'Primary' || 
                accountPosition.LE_Program_Owner__c == 'Primary')) {
                accountIds.add(accountPosition.ZTS_EU_Account__c);
            }
        }
    
        // Exit early if there are no Accounts to retrieve
        if (accountIds.isEmpty()) {
            return;
        }
    
        Map<Id, Account> accountsMap = new Map<Id, Account>(AccountSelector.newInstance().selectByIdAndMarket(
            new List<Id>(accountIds), true));
    
        Map<Id, Account> updateAccountsMap = new Map<Id, Account>();
        for (ZTS_EU_Account_Position__c accountPosition : accountPositions) {
            Account account = accountsMap.get(accountPosition.ZTS_EU_Account__c);
            Boolean updateAccount = false;

            // If Program Owner is Primary and the Employee on the Position does not match the Program Owner field on the Account
            // Update the Program Owner field with the Employee of the Position and set the appropriate Email field to that User's Email.
            if(accountPosition.VGP_Program_Owner__c == 'Primary' && 
                account.VGP_Program_Owner__c != accountPosition.ZTS_EU_Employee__c) {
                account.VGP_Program_Owner__c = accountPosition.ZTS_EU_Employee__c;
                account.VGP_Program_Owner_email__c = accountPosition.Employee_Email__c;
                updateAccount = true;
            }

            if(accountPosition.MZR_Program_Owner__c == 'Primary' && 
                account.MZR_Program_Owner__c != accountPosition.ZTS_EU_Employee__c) {
                account.MZR_Program_Owner__c = accountPosition.ZTS_EU_Employee__c;
                account.MZR_Program_Owner_email__c = accountPosition.Employee_Email__c;
                updateAccount = true;
            }
            
            if(accountPosition.LE_Program_Owner__c == 'Primary' && 
                account.LE_Program_Owner__c != accountPosition.ZTS_EU_Employee__c) {
                account.LE_Program_Owner__c = accountPosition.ZTS_EU_Employee__c;
                account.LE_Program_Owner_email__c = accountPosition.Employee_Email__c;
                account.LE_Program_Owner_User_Territory__c = accountPosition.ZTS_EU_Position__c;
                updateAccount = true;
            }

            if(updateAccount) {
                updateAccountsMap.put(account.Id, account);
            }
        }

        // This update will kick off the Account Trigger which will keep track of the previous value for all 3 Owner fields.
        if (!updateAccountsMap.isEmpty()) {
            new WithoutSharing().updateRecords(updateAccountsMap.values());
        }
    }

    /**
    * @description Sets Onboarding_Case_Status__c to the value passed into this method.
    *              This runs without sharing to avoid security issues
    * @author Ethan Hirsch @ Zoetis Inc | 05-09-2022 
    * @param accounts 
    * @param value 
    **/
    public static void setOnboardingCaseStatus(List<Account> accounts, boolean value) {
        for (Account account : accounts) {
            account.Onboarding_Case_Status__c = value;
        }

        // No logic currently runs on Onboarding_Case_Status__c, so triggers are bypassed.
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        new WithoutSharing().updateRecords(accounts);
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
    }

    /**
    * @description Sets Send_to_DMR_Update__c to true on an Account when it meets the criteria to be picked up by DMR,
    *              DMR Id is set, and one of the fields picked up by DMR changes.
    *              Sets Send_to_DMR_Create__c to true on an Account when it meets the criteria to be picked up by DMR
    *              and DMR Id is blank.
    *              Unchecks both fields if conditions are no longer met to send the Account to DMR.
    * @author Ethan Hirsch @ Zoetis Inc | 08-30-2022 
    * @param accounts
    * @param oldAccountsMap
    **/
    public static void setSendToDMRFlag(List<Account> accounts, Map<Id, Account> oldAccountsMap) {
        Schema.SObjectField dmrAccountIntegrationField = Market_Setting__mdt.Enable_Account_DMR_Integration__c;
        
        Set<String> dmrMarkets =  MarketSettingsSelector.newInstance().retrieveEnabledMarketsForIntegrations(
            new Set<Schema.SObjectField> {dmrAccountIntegrationField}).get(dmrAccountIntegrationField);
        
        FieldSet dmrIntegrationFields =  Schema.SObjectType.Account.fieldsets.DMR_Integration_Fields;

        List<Account> accountsToSendUpdate = new List<Account>();
        List<Account> accountsToSendCreate = new List<Account>();
        for (Account account : accounts) {
            Boolean uncheckSendToDMRFlags = false;
            // First, verify conditions that apply to insert and update
            // Market is supported for DMR, Country is specified, and Direct Flag is set to false
            if (dmrMarkets.contains(account.ZTS_EU_Market__c) &&
                String.isNotBlank(account.ZTS_EU_Country__c) &&
                account.ZTS_EU_Direct_Flag__c == false) {
                // Next check if this is should be a Create or Update in DMR
                // For a Create, Send to DMR Create should not already be true, DMR Id must be blank,
                // and Account Status should be active.
                // Zoetis SFDC Id is not checked on insert of a Salesforce Account as it is an autonumber that will be 
                // populated later.
                Boolean validForCreate = String.isBlank(account.DMR_Id__c) &&
                    account.ZTS_EU_Account_Status__c == 'Active';

                // For an Update, Send to DMR Update should not already be true, 
                // DMR Id should not be blank or Send to DMR Create should not be checked,
                // Zoetis SFDC Id should be populated, and Status can be Active or Inactive if DMR Id is populated.
                // Updates can only be sent on the Update event of an Account which is identified by verifying 
                // oldAccountsMap is populated
                Boolean validForUpdate =
                    (String.isNotBlank(account.DMR_Id__c) || !account.Send_to_DMR_Create__c) && 
                    String.isNotBlank(account.ZTS_EU_Zoetis_SFDC_ID__c) &&
                    (account.ZTS_EU_Account_Status__c == 'Active' || 
                    (account.ZTS_EU_Account_Status__c == 'Inactive' && String.isNotBlank(account.DMR_Id__c)));

                Account oldAccount = null;

                if (oldAccountsMap != null) {
                    oldAccount = oldAccountsMap.get(account.Id);
                }
                
                // On Create, make sure that a field changed in a way to make this Account valid for create for the
                // first time. This is primarily to allow the DMR Integration to uncheck Send to DMR Create before setting a DMR Id
                if (!account.Send_to_DMR_Create__c && validForCreate && (oldAccount == null ||
                    !dmrMarkets.contains(oldAccount.ZTS_EU_Market__c) ||
                    String.isBlank(oldAccount.ZTS_EU_Country__c) ||
                    oldAccount.ZTS_EU_Direct_Flag__c ||
                    oldAccount.ZTS_EU_Account_Status__c != 'Active' ||
                    String.isNotBlank(oldAccount.DMR_Id__c)
                )) {
                    accountsToSendCreate.add(account);
                }
                else if (oldAccountsMap != null && !account.Send_to_DMR_Update__c &&
                    validForUpdate) {

                    // Next for Update verify that one of the DMR Integrated fields changed
                    
                    for (FieldSetMember integrationField : dmrIntegrationFields.getFields()) {
                        Schema.SObjectField fieldToCheck = integrationField.getSObjectField();
                        if (account.get(fieldToCheck) != oldAccount.get(fieldToCheck)) {
                            accountsToSendUpdate.add(account);
                            // Stop the loop once the Account has been identified as needing to be updated
                            break;
                        }
                    }
                }
                // If an Account is not valid for create or update, uncheck any Send to DMR Flags
                else if (!validForCreate && !validForUpdate) {
                    uncheckSendToDMRFlags = true;
                }
            }
            // If an Account is not valid for create or update, uncheck any Send to DMR Flags
            else {
                uncheckSendToDMRFlags = true;
            }

            if (uncheckSendToDMRFlags){
                account.Send_to_DMR_Create__c = false;
                account.Send_to_DMR_Update__c = false;
            }
        }

        // Exit early if no Accounts need to be sent to DMR
        if (accountsToSendUpdate.isEmpty() && accountsToSendCreate.isEmpty()) {
            return;
        }

        // Check if the current User's updates should be ignored due to being excluded from the Account DMR Integration
        string dmrAccountIntegration = 'Account DMR';
        List<User> validUsers = UsersSelector.newInstance().selectUsersByIdNotExcludedFromIntegrations(
            new Set<Id> {UserInfo.getUserId()}, new Set<String> {dmrAccountIntegration});

        // If the User is not returned, exit early without updating the Account
        if (validUsers.isEmpty()) {
            return;
        }
        
        for (Account account : accountsToSendUpdate) {
            account.Send_to_DMR_Update__c = true;
        }

        for (Account account : accountsToSendCreate) {
            account.Send_to_DMR_Create__c = true;
        }
    }

    @testVisible private static Boolean forceMergeIntlRollbackError = false;
    @testVisible private static Boolean forceMergeIntlUpdateError = false;
    @testVisible private static Boolean forceMergeIntlDeleteError = false;
    /**
    * @description For INTL Accounts, merges duplicate Account Positions, Addresses, and Account Territories on an Account.
    *              This method will also update unique keys that do not get updated on merge.
    *              Child records for the records being deleted are also transfered to their matching record.
    *              This method is meant to be called after an Account is merged. 
    *              It should be called async to avoid performance issues
    * @author Ethan Hirsch @ Zoetis Inc | 05-12-2022 
    * @param accountIds 
    **/
    public static void mergeRelatedDataInternational(Set<Id> accountIds) {
        SavePoint savePoint = Database.setSavepoint();
        // Disable CPQ Triggers before performing merge logic to avoid a callout exception when updaitng Quotes.
        // No CPQ logic should need to run on Merge.
        SBQQ.TriggerControl.disable();
        try {
            Map<String, Map<String, MergeRelatedRecordLookupsSelector.ChildObject>> childObjectsByParentObject = 
                MergeRelatedRecordLookupsSelector.selectChildObjectsByParentObjectAndMarket(
                    new Set<String> {'Address__c', 'ZTS_EU_Account_Position__c', 'ZTS_AccountTerritory__c'},
                    'International');

            MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();
            // Retrieve Addresses with Calls, Cases, and Orders
            // Identify Duplicates
            // Transfer related Calls, Cases, and Orders to kept Address
            // Update ZTS_GL_Unique_Primary_Address_Key__c if populated
            Map<Id, Address__c> deleteAddressMap = AddressesService.mergeRelatedAddressesByAddressTypeAndDetails(
                accountIds, childObjectsByParentObject.get('Address__c'), updateRelatedRecordsMap);

            // Retrieve Account Positions with ECCs
            // Identify Duplicates
            // Transfer related ECCs
            // Update both Uniqueness Key and AccountUserTerrUniqueKey if populated
            Map<Id, ZTS_EU_Account_Position__c> deleteAccountPositionMap = 
                AccountPositionsService.mergeRelatedAccountPositionsByAccountAndPosition(accountIds,
                    childObjectsByParentObject.get('ZTS_EU_Account_Position__c'), updateRelatedRecordsMap);

            // Retrieve Account Territories with Account Positions
            // Identify Duplicates
            // Transfer related Account Positions
            Map<Id, ZTS_AccountTerritory__c> deleteAccountTerritoriesMap = 
                AccountTerritoriesService.mergeRelatedAccountTerritoriesByAccountIdAndTerritory(accountIds,
                    childObjectsByParentObject.get('ZTS_AccountTerritory__c'), updateRelatedRecordsMap);

            // This save runs with failures allowed so that failures can be logged.
            // The order of operations for merge is as follows
            // 1. Update all records but Address and Account Position
            // 2. Delete Address and Account Position
            // 3. Update Address and Account Position
            // 4. Delete Account Territories
            // This order prevents errors from occuring due to updating an Address or Account Position's Unique Key
            // before a record with the same key has been deleted and any related data from being deleted
            List<SObject> updateRecordsBatch1= new List<SObject>();
            List<SObject> updateRecordsBatch2 = new List<SObject>();
            Map<Id, SObject> updateAllRecordsMap = new Map<Id, SObject>();
            for (String objectName : updateRelatedRecordsMap.updateRecordsMapByName.keySet()) {
                Map<Id, SObject> updateRecordsMap = updateRelatedRecordsMap.updateRecordsMapByName.get(objectName);

                // Remove any Account Positions being deleted to avoid duplicate key errors
                if (objectName == 'ZTS_EU_Account_Position__c') {
                    for (Id deleteAccountPositionId : deleteAccountPositionMap.keySet()) {
                        updateRecordsMap.remove(deleteAccountPositionId);
                    }

                    updateRecordsBatch2.addAll(updateRecordsMap.values());
                    continue;
                }
                else if (objectName == 'Address__c') {
                    updateRecordsBatch2.addAll(updateRecordsMap.values());
                    continue;
                }
                
                updateRecordsBatch1.addAll(updateRecordsMap.values());
                updateAllRecordsMap.putAll(updateRecordsMap);
            }

            List<Id> deleteRecordIdsBatch1 = new List<Id>();
            // Delete Account Positions before Account Territories to avoid issues with Account Positions being deleted
            // automaticaly when Account Territories are deleted.
            deleteRecordIdsBatch1.addAll(deleteAddressMap.keySet());
            deleteRecordIdsBatch1.addAll(deleteAccountPositionMap.keySet());

            List<Database.SaveResult> updateResults = new List<Database.SaveResult>();
            List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>();

            // When Employee Call Credits are transfered, the Employee Call Credit rollup field is updated and
            // causes the Account Position's Unique Keys to be updated which causes a uniqueness error to be thrown.
            // To avoid this, the Account Position Trigger is disabled
            DispatchTriggerHandler.bypass('ZTS_EU_Account_PositionTriggerHandler');
            updateResults.addAll(updateRecordsOnMerge(updateRecordsBatch1));
            DispatchTriggerHandler.clearBypass('ZTS_EU_Account_PositionTriggerHandler');
            
            deleteResults.addAll(deleteRecordsOnMerge(deleteRecordIdsBatch1));
            updateResults.addAll(updateRecordsOnMerge(updateRecordsBatch2));

            // When deleting Account Territories, bypass the Account Territory Trigger. 
            //This will stop Assigned Territories from being deleted incorrectly
            DispatchTriggerHandler.bypass('ZTS_AccountTerritoryTriggerHandler');
            deleteResults.addAll(deleteRecordsOnMerge(new List<Id>(deleteAccountTerritoriesMap.keySet())));
            DispatchTriggerHandler.clearBypass('ZTS_AccountTerritoryTriggerHandler');

            List<ZTS_EU_Error_Log__c> errorLogs = new List<ZTS_EU_Error_Log__c>();

            if (updateResults != null && !updateResults.isEmpty()) 
            for (Database.SaveResult updateResult : updateResults) {
                if (!updateResult.isSuccess()) {
                    errorLogs.add(processMergeErrors(updateResult.getErrors()[0], mergeUpdateErrorMessageFormat,
                        updateResult.getId(), accountIds));
                }
            }

            if (deleteResults != null && !deleteResults.isEmpty()) {
                for (Database.DeleteResult deleteResult : deleteResults) {
                    if (!deleteResult.isSuccess()) {
                        errorLogs.add(processMergeErrors(deleteResult.getErrors()[0], mergeDeleteErrorMessageFormat,
                            deleteResult.getId(), accountIds));
                    }
                }
            }
            
            if (errorLogs.size() > 0) {
                // If an error log fails to insert the entire operation will be rolled back.
                // This it to avoid partial completions without error logs.
                insert errorLogs;
            }

            // Force a rollback error for code coverage.
            if (Test.isRunningTest() && forceMergeIntlRollbackError) {
                integer y = 1 / 0;
            }
        }
        catch (Exception e) {
            Database.rollback(savePoint);
            ZTS_EU_Logger.error(String.format(
                'An unexpected error occurred on merge of the following Accounts: {0}. Please resolve the issue(s) and manually rerun the merge or manually merge. Error: {1}', new List<String> {
                    String.join((List<String>)(new List<Id>(accountIds)), ', '), e.getMessage()}), null,
                    accountMergeLogType);
        }
        finally {
            // Reenable CPQ Triggers before existing this method
            SBQQ.TriggerControl.enable();
        }
    }

    /**
    * @description Run an update for records on merge. Allow Unit Tests to cause an error.
    * @author Ethan Hirsch @ Zoetis Inc | 06-22-2022 
    * @param updateRecords 
    * @return List<Database.SaveResult> 
    **/
    private static List<Database.SaveResult> updateRecordsOnMerge(List<SObject> updateRecords) {
        List<Database.SaveResult> updateResults = new List<Database.SaveResult>();
        if (!updateRecords.isEmpty()) {
            if (Test.isRunningTest() && forceMergeIntlUpdateError) {
                // To allow an error to occur in a Unit Test, delete the records being updated so the update fails
                // Account Territory Trigger Handler is bypassed to prevent duplicate Account Positions from being created.
                DispatchTriggerHandler.bypass('ZTS_AccountTerritoryTriggerHandler');
                Database.delete(updateRecords, false);
            }

            updateResults = new WithoutSharing().updateRecords(updateRecords, false);

            if (Test.isRunningTest() && forceMergeIntlUpdateError) {
                // If records were deleted, undelete them so they can be verified as not being updated in the Unit Test
                Database.undelete(updateRecords, false);
                DispatchTriggerHandler.clearBypass('ZTS_AccountTerritoryTriggerHandler');
            }
        }

        return updateResults;
    }

    /**
    * @description Run an update for records on merge. Allow Unit Tests to cause an error.
    * @author Ethan Hirsch @ Zoetis Inc | 06-22-2022 
    * @param deleteRecordIds 
    * @return List<Database.DeleteResult> 
    **/
    private static List<Database.DeleteResult> deleteRecordsOnMerge(List<Id> deleteRecordIds) {
        List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>();
        if (!deleteRecordIds.isEmpty()) {
            if (Test.isRunningTest() && forceMergeIntlDeleteError) {
                // To allow an error to occur in a Unit Test, delete the records being deleted so the delete fails
                Database.delete(deleteRecordIds, false);
            }

            deleteResults = new WithoutSharing().deleteRecord(deleteRecordIds, false);

            if (Test.isRunningTest() && forceMergeIntlDeleteError) {
                // If records were deleted, undelete them so they can be verified as not being deleted in the Unit Test
                Database.undelete(deleteRecordIds, false);
            }
        }

        return deleteResults;
    }

    private static ZTS_EU_Error_Log__c processMergeErrors(Database.Error errorRecord, string errorFormat, Id recordId, Set<Id> accountIds) {
        String logMessage = String.format(errorFormat, new List<Object> {recordId, 
            String.join((List<String>)(new List<Id>(accountIds)), ', '),
            errorRecord.getMessage()});

        String statusCode = String.valueOf(errorRecord.getStatusCode()).substring(0, 9);

        return ZTS_EU_Logger.error(logMessage, statusCode, accountMergeLogType, false);
    }

    private without sharing class WithoutSharing {
        private void updateRecords(List<SObject> records) {
            update records;
        }

        private List<Database.SaveResult> updateRecords(List<SObject> records, Boolean allOrNothing) {
            return Database.update(records, allOrNothing);
        }

        private List<Database.DeleteResult> deleteRecord(List<Id> recordIds, Boolean allOrNothing) {
            return Database.delete(recordIds, allOrNothing);
        }
    }

    public static List<Account> getAccountsWithEmailChanges(Map<Id, Account> mapAccountNew,Map<Id, Account> mapAccountOld) {
        List<Account> accountsList = new List<Account>();
        for(Id acc: mapAccountNew.keySet())
        {
          if(mapAccountOld.get(acc).Email__c != mapAccountNew.get(acc).Email__c || 
             mapAccountOld.get(acc).ZTS_EU_Opt_Out_Email__c != mapAccountNew.get(acc).ZTS_EU_Opt_Out_Email__c ||
             mapAccountOld.get(acc).ZTS_Invalid_Email__c != mapAccountNew.get(acc).ZTS_Invalid_Email__c ){
                accountsList.add(mapAccountNew.get(acc));  
             }            
             
        }
        return accountsList;
    }

    /**
    * @description Update account certification status from the contact.
    * @author Padma Nerella @ Zoetis Inc | 03-28-2023 
    * @param accIds 
    **/
    public static void updateAccountCertificationStatus(Set<Id> accIds){
        
        List<Account> acclist = new List<Account>();
        List<Account> acclisttoUpdate = new List<Account>();
        acclist = AccountSelector.newInstance().selectInternationalAccountByIdWithContacts(accIds);
        for(Account a :acclist){
            boolean accCertStatusFlag = false;
            for(Contact contact: a.contacts){
                if(contact.Certification_Status__c != null && contact.Certification_Status__c){
                    accCertStatusFlag = true;
                    break;
                }
            }
            if(a.certification_status__c != accCertStatusFlag){
                a.certification_status__c = accCertStatusFlag;
                acclisttoUpdate.add(a);
            }
        }
        if(acclisttoUpdate.size() > 0){
            //Bypass the Account Trigger when updating Accounts (TPDEV-80) 
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update acclist;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }

    @testVisible private static Boolean forcerunBatchToUpdateCorporateFlag = false;
    /**
    * @description This method will update all the Accounts corporate flag field with grand parents corporate flag value
    * @author Padma Nerella @ Zoetis Inc | 05-10-2023 
    * @param newAccountMap
    * @param oldAccountMap 
    **/
    public static set<Id> AccIdsUpdated= new Set<Id>();
    public static void updateZTSEUCorporateFlagFromINTLParentAcc(Map<Id,Account> newMap,Map<id,account> oldMap){
        Set<Id> parentAccIdSet = new Set<Id>();
        for(Account acc : newMap.values()){
            if(!AccIdsUpdated.contains(acc.ZTS_EU_Parent_Id__c)){
                if(acc.ZTS_EU_Corporate_Flag__c != oldMap.get(acc.id).ZTS_EU_Corporate_Flag__c)
                    parentAccIdSet.add(acc.ZTS_EU_Parent_Id__c);
            }
        }
        
        if(parentAccIdSet.size()>0){
            Map<Id,Account> parentAccMap =new Map<id,account>(AccountSelector.newInstance().selectInternationalParentAccountsById(parentAccIdSet,201));
            if((parentAccMap.size()<=200)&&(!Test.isRunningTest() || forcerunBatchToUpdateCorporateFlag)){
                List<Account> childAccList = setZTSEUCorporateFlagFromINTLParentAcc(parentAccMap);
                DispatchTriggerHandler.bypass('AccountTriggerHandler');
                update childAccList;
                DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            } else {
                UpdateAccountCorporateFlagBatch updateBatchjob = new UpdateAccountCorporateFlagBatch();
                updateBatchjob.parentAccIds = parentAccIdSet;
                database.executeBatch(updateBatchjob,200);
            }
        }
        
    }
    
    /**
    * @description This method will update all the Accounts corporate flag field with grand parents corporate flag value
    * @author Padma Nerella @ Zoetis Inc | 05-10-2023 
    * @param parentAccMap
    **/
    public static List<Account> setZTSEUCorporateFlagFromINTLParentAcc(Map<Id,Account> parentAccMap){
        List<Account> lstToUpdate = new List<Account>();
        for(Account accs :parentAccMap.values()){
            Account accObj = new Account(Id=accs.Id);  
                accObj.ZTS_EU_Corporate_Flag__c = parentAccMap.get(accs.ZTS_EU_Parent_Id__c).ZTS_EU_Corporate_Flag__c; 
                AccIdsUpdated.add(accObj.Id);
                lstToUpdate.add(accObj);
            }
        return lstToUpdate;
    }
    
}