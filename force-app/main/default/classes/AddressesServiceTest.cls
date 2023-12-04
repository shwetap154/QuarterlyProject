/**
 * @description       : Test class for AddressService
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 09-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-11-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for isActiveDirectShipToAddress
 * 1.1   05-25-2022   Ethan Hirsch @ Zoetis Inc   Add tests for mergeRelatedAddressesByAddressTypeAndDetails method. 
 *                                                Update existing tests for handling additional Addresses being created.
 * 1.2   06-28-2022   Ethan Hirsch @ Zoetis Inc   Replace usage of ZTS_US_Source_Account_Number__c with ZTS_EU_Address_ID__c to match updated merge logic.
 *                                                Add a Unit Test to verify the behavior of merging Accounts with varying ZTS_EU_Address_ID__c.
 *                                                Set both Name and ZTS_Address_Line_1__c on Addresses
 * 1.3   07-11-2022   Ethan Hirsch @ Zoetis Inc   Update mergeRelatedAddressesByAddressTypeAndDetails_DuplicateAddressesWithDifferentIds_Test
 *                                                and data setup to test out Address matching with ZTS_US_Source_Account_Number__c
 *                                                Change input to mergeRelatedAddressesByAddressTypeAndDetails method.
 *                                                Add tests for verifying Bypass Permissions is checked on Case on merge of Address
 * 1.4   09-08-2022   Ethan Hirsch @ Zoetis Inc   Update mergeRelatedAddressesByAddressTypeAndDetails tests to verify that the newest 
 *                                                Address is kept instead of the oldest. Disable more Triggers in setup to avoid
 *                                                Apex Execution Timeout Limits.
 * 1.4   09-08-2022   Ethan Hirsch @ Zoetis Inc   Update mergeRelatedAddressesByAddressTypeAndDetails tests to verify Phone is copied properly
 * 1.5   09-15-2022   Ethan Hirsch @ Zoetis Inc   Update test data to make a case-insensitive Address comaprison.
 * 1.5   09-19-2022   Ethan Hirsch @ Zoetis Inc   Update test data and tests for
 *                                                mergeRelatedAddressesByAddressTypeAndDetails to verify Accounts and
 *                                                Contacts are updated.
 **/
@isTest
private class AddressesServiceTest {
    private static final String multiAddressAccountName = 'multiAddressAccount';

    private static final Integer totalCaseCount = 5;
    private static final Integer totalAccountCount = 3;
    
    private static final String mergeAddressAccountNameFormat = 'MergeAddressAccount{0}';

    private static List<String> orderAddressLookupFields = new List<String> {'Bill_To_Address__c',
        'Distributor_Address__c', 'Drop_Ship_Requester_Distr__c', 'Leasing_Agent_Address__c',
        'Payer_Address__c', 'Ship_To_Address__c'};

    private static final String mergeAccount4AddressId1 = 'TEST4_NEW';
    private static final String mergeAccount4AddressId2 = 'TEST4_NEW_2';

    @TestSetup
    private static void setup(){
        List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(totalAccountCount);
        accounts[1].Name = multiAddressAccountName;
        // Make one Account INTL as logic should be the same for all Markets.
        accounts[2].ZTS_EU_Market__c = 'United Kingdom';

        List<Account> mergeAddressAccounts = ZTS_DataUtilityTest.createAccountRecord(5);
        for (integer i = 0; i < mergeAddressAccounts.size(); i++) {
            mergeAddressAccounts[i].ZTS_EU_Market__c = 'United Kingdom';
            mergeAddressAccounts[i].Name = String.format(mergeAddressAccountNameFormat, new List<Object> {i});
        }

        List<Account> allAccounts = new List<Account>();
        allAccounts.addAll(accounts);
        allAccounts.addAll(mergeAddressAccounts);
        insert allAccounts;

        Map<String, Schema.RecordTypeInfo> caseRecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        
        List<Case> allCases = ZTS_DataUtilityTest.createCases(totalCaseCount,
            caseRecordTypes.get('Ref_Labs_Onboarding').getRecordTypeId());
        
        for (integer i = 0; i < allCases.size(); i++) {
            allCases[i].Status = 'On Hold';
            if (i < 3) {
                allCases[i].AccountId = accounts[0].Id;
            }
            else if (i == 3) {
                allCases[i].AccountId = accounts[1].Id;
                allCases[i].Has_RefLabs_Multiple_Ship_To__c = true;
            }
            else {
                allCases[i].AccountId = accounts[2].Id;
            }
        }

        // Set one Case's Status to New to confirm it won't change when updated in tests for isActiveDirectShipToAddress
        allCases[1].Status = 'New';

        State_Country__c testStateCountry = TestDataFactory.createStateCountry('United Kingdom', 'United Kingdom', true);

        State_Country__c testCommune = TestDataFactory.createStateCountry('Test Commune', 'Test Commune', false);
        testCommune.ZTS_EU_Parent_State_Country__c = testStateCountry.Id;
        insert testCommune;

        City_State__c testCityState = TestDataFactory.createCityState('Test City/State', testStateCountry.Id, true);

        List<Address__c> allAddresses = new List<Address__c>();
        List<Address__c> validAddresses = new List<Address__c>();
        validAddresses.AddAll(TestDataFactory.createAddresses(1, accounts[0].Id));
        validAddresses.addAll(TestDataFactory.createAddresses(1, accounts[1].Id));
        validAddresses.addAll(TestDataFactory.createAddresses(1, accounts[2].Id));
        validAddresses[2].ZTS_EU_Market_From_Parent__c = 'United Kingdom';

        for (Address__c validAddress : validAddresses) {
            validAddress.ZTS_EU_Address_Type__c = 'Ship To';
            validAddress.Is_Active__c = true;
            validAddress.Ship_Indirect__c = 'N';
            allAddresses.add(validAddress);
        }

        Address__c invalidAddress = TestDataFactory.createAddresses(1, accounts[1].Id)[0];
        invalidAddress.ZTS_EU_Address_Type__c = 'Ship To';
        invalidAddress.Is_Active__c = false;
        invalidAddress.Ship_Indirect__c = 'N';
        allAddresses.add(invalidAddress);

        Address__c uniqueAccountMergeAddress1 = setupAddressWithAllMergeFields(mergeAddressAccounts[1].Id, 'PO Box', testStateCountry.Id,
            testCommune.Id, testCityState.Id);

        // Set a Phone to make sure it doesn't get updated
        uniqueAccountMergeAddress1.ZTS_EU_Phone__c = '9995551234';
        allAddresses.add(uniqueAccountMergeAddress1);

        allAddresses.add(setupAddressWithAllMergeFields(mergeAddressAccounts[1].Id, 'Billing', testStateCountry.Id,
            testCommune.Id, testCityState.Id));

        List<Address__c> addressesSetCreatedDateNewer = new List<Address__c>();
        List<Address__c> addressesSetCreatedDateOlder = new List<Address__c>();
        // Capture these Addresses to setup related records to transfer
        Address__c account2Address1;
        Address__c account2Address3;

        // Setup Addresses for Account 2
        for (integer i = 0; i < 5; i++) {
            String type;
            if (i < 2) {
                type = 'Billing';
            }
            else if (i < 4) {
                type = 'PO Box';
            }
            else {
                type = 'Primary';
            }

            Address__c address = setupAddressWithAllMergeFields(mergeAddressAccounts[2].Id, type, testStateCountry.Id,
                testCommune.Id, testCityState.Id);

            allAddresses.add(address);

            if (i == 0) {
                account2Address1 = address;
                address.ZTS_EU_Phone__c = '999551234';
            }
            else if (i == 1) {
                address.ZTS_EU_Address_ID__c = 'Test1';
                address.ZTS_EU_Phone__c = '999551235';
            }
            else if (i == 2) {
                account2Address3 = address;
                address.ZTS_EU_Phone__c = '999551236';
                addressesSetCreatedDateOlder.add(address);
            }
            else if (i == 3) {
                addressesSetCreatedDateNewer.add(address);
            }
            else {
                address.ZTS_GL_Unique_Primary_Address_Key__c = 'INCORRECT1';
                address.ZTS_US_Primary__c  = true;
            }
        }

        // Setup Addresses for Account 3
        for (integer i = 0; i < 3; i++) {
            String type;
            if (i < 2) {
                type = 'Billing';
            }
            else {
                type = 'PO Box';
            }

            Address__c address = setupAddressWithAllMergeFields(mergeAddressAccounts[3].Id, type, testStateCountry.Id,
                testCommune.Id, testCityState.Id);

            allAddresses.add(address);

            if (i < 2) {
                address.ZTS_US_Source_Account_Number__c = 'TEST3_NEW';
            }
            
            if (i == 0) {
                addressesSetCreatedDateOlder.add(address);
                address.ZTS_EU_Phone__c = '9995558231';
            }
            else if (i == 1) {
                addressesSetCreatedDateNewer.add(address);
            }
        }

        // Setup Addresses for Account 4
        for (integer i = 0; i < 7; i++) {
            String type = 'Billing';

            Address__c address = setupAddressWithAllMergeFields(mergeAddressAccounts[4].Id, type, testStateCountry.Id,
                testCommune.Id, testCityState.Id);

            allAddresses.add(address);

            if (i < 2) {
                address.ZTS_EU_Address_ID__c = mergeAccount4AddressId1;
                address.ZTS_US_Source_Account_Number__c = mergeAccount4AddressId1;

                // Make all text fields on one Address uppercase to confirm a case insensitive comparison
                if (i == 1) {
                    address.ZTS_Address_Line_1__c = address.ZTS_Address_Line_1__c.toUpperCase();
                    address.Name = address.Name.toUpperCase();
                    address.ZTS_EU_Address_Line_2__c = address.ZTS_EU_Address_Line_2__c.toUpperCase();
                    address.ZTS_EU_Address_Line_3__c = address.ZTS_EU_Address_Line_3__c.toUpperCase();
                    address.Address_Line_4__c = address.Address_Line_4__c.toUpperCase();
                    address.ZTS_EU_Country__c = address.ZTS_EU_Country__c.toUpperCase();
                    address.ZTS_EU_District__c = address.ZTS_EU_District__c.toUpperCase();
                    address.ZTS_EU_City__c = address.ZTS_EU_City__c.toUpperCase();
                    address.Zip_Postal_Code__c = address.Zip_Postal_Code__c.toUpperCase();
                }
            }
            else if (i < 4) {
                address.ZTS_EU_Address_ID__c = mergeAccount4AddressId2;
            }
            else if (i < 6) {
                address.ZTS_US_Source_Account_Number__c = mergeAccount4AddressId2;
            }

            if (i == 0 || i == 2 || i == 4) {
                addressesSetCreatedDateOlder.add(address);
            }
            else if (i == 1 || i == 3 || i == 5) {
                addressesSetCreatedDateNewer.add(address);
            }
        }

        insert allAddresses;

        // Set Created Date manually for prioritization of merging records
        for (Address__c address : addressesSetCreatedDateNewer) {
            Test.setCreatedDate(address.Id, System.now().addDays(-8));
        }

        for (Address__c address : addressesSetCreatedDateOlder) {
            Test.setCreatedDate(address.Id, System.today().addDays(-10));
        }

        List<Order> orders = new List<Order>();

        Order order1 = TestDataFactory.createOrder(account2Address1.ZTS_EU_Account__c, false);
        order1.Bill_To_Address__c = account2Address1.Id;
        order1.Distributor_Address__c = account2Address1.Id;
        order1.Drop_Ship_Requester_Distr__c = account2Address1.Id;
        order1.Leasing_Agent_Address__c = account2Address1.Id;
        order1.Payer_Address__c = account2Address1.Id;
        order1.Ship_To_Address__c = account2Address1.Id;
        orders.add(order1);

        Order order2 = TestDataFactory.createOrder(account2Address3.ZTS_EU_Account__c, false);
        order2.Distributor_Address__c = account2Address3.Id;
        orders.add(order2);

        Order order3 = TestDataFactory.createOrder(account2Address3.ZTS_EU_Account__c, false);
        order3.Bill_To_Address__c = account2Address1.Id;
        order3.Distributor_Address__c = account2Address1.Id;
        order3.Drop_Ship_Requester_Distr__c = account2Address3.Id;
        order3.Leasing_Agent_Address__c = account2Address3.Id;
        orders.add(order3);

        // Skip the Order Trigger to save on execution time
        DispatchTriggerHandler.bypass('OrdersTriggerHandler');
        insert orders;
        DispatchTriggerHandler.clearBypass('OrdersTriggerHandler');

        List<Call__c> calls = new List<Call__c>();
        Call__c call1 = TestDataFactory.createCall(account2Address1.ZTS_EU_Account__c, false);
        call1.ZTS_EU_Address__c = account2Address1.Id;
        calls.add(call1);

        // Skip the Call Trigger to save on execution time
        DispatchTriggerHandler.bypass('CallTriggerHandler');
        insert calls;
        DispatchTriggerHandler.clearBypass('CallTriggerHandler');

        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        Case mergeCase = ZTS_DataUtilityTest.createCases(1, caseRecordTypeId)[0];
        mergeCase.AccountId = account2Address1.ZTS_EU_Account__c;
        mergeCase.Address__c = account2Address1.Id;
        allCases.add(mergeCase);

        // Disable Case logic to prevent Status from changing
        string caseTriggerName = 'ZTS_EU_ServiceRequest';
        CustomSettingService.setTriggerBypass(caseTriggerName, true);
        insert allCases;
        CustomSettingService.setTriggerBypass(caseTriggerName, false);

        // Update Account with Triggers turned off to save limits and processing time
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update new Account(Id = account2Address1.ZTS_EU_Account__c, 
            ZTS_EU_Primary_Address__c = account2Address1.Id);
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        List<Contact> contacts = TestDataFactory.createContacts(account2Address1.ZTS_EU_Account__c, 2, false);
        for (Contact contact : contacts) {
            contact.ZTS_EU_Primary_Address__c = account2Address1.Id;
        }

        // Insert Contacts with Triggers turned off to save limits and processing time
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        insert contacts;
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
    }

    @isTest
    private static void isActiveDirectShipToAddress_ReturnTrue_Test() {
        Address__c address = [
            SELECT Id, ZTS_EU_Address_Type__c, Is_Active__c, Ship_Indirect__c
            FROM Address__c
            WHERE Is_Active__c = true
            AND ZTS_EU_Address_Type__c = 'Ship To'
            LIMIT 1];
        
        Test.startTest();
            Boolean isActiveDirectShipTo = AddressesService.isActiveDirectShipToAddress(address);
        Test.stopTest();

        system.assertEquals(true, isActiveDirectShipTo, 'Address should be an Active, Direct, Ship To Address');
    }

    @isTest
    private static void isActiveDirectShipToAddress_ReturnFalse_Test() {
        Address__c address = [
            SELECT Id, ZTS_EU_Address_Type__c, Is_Active__c, Ship_Indirect__c
            FROM Address__c
            WHERE Is_Active__c = false
            AND ZTS_EU_Address_Type__c = 'Ship To'
            LIMIT 1];
        
        Test.startTest();
            Boolean isActiveDirectShipTo = AddressesService.isActiveDirectShipToAddress(address);
        Test.stopTest();

        system.assertEquals(false, isActiveDirectShipTo, 'Address should not be an Active, Direct, Ship To Address');
    }

    @isTest
    private static void unblockRelatedRefLabOnboardingCases_ActiveAddress_Test() {
        Address__c address = [
            SELECT ID 
            FROM Address__c 
            WHERE ZTS_EU_Account__r.Name =: multiAddressAccountName
            AND Is_Active__c = true
            AND ZTS_EU_Address_Type__c = 'Ship To'
            LIMIT 1];

        address.Reference_Labs_Ship_to__c = true;
        Test.startTest();
            update address;
        Test.stopTest();

        for (Case accountCase : [SELECT Id, Status, Has_RefLabs_Multiple_Ship_To__c
                                 FROM Case
                                 WHERE Account.Name =: multiAddressAccountName]) {
            System.assertEquals('In Progress', accountCase.Status,
                'The Status of the Case should have changed.');

            System.assertEquals(false, accountCase.Has_RefLabs_Multiple_Ship_To__c, 
                'The Has_RefLabs_Multiple_Ship_To__c field should have changed to false');
        }
    }

    @isTest
    private static void unblockRelatedRefLabOnboardingCases_InactiveAddress_Test() {
        Address__c address = [
            SELECT ID 
            FROM Address__c 
            WHERE ZTS_EU_Account__r.Name =: multiAddressAccountName
            AND Is_Active__c = false
            AND ZTS_EU_Address_Type__c = 'Ship To'
            LIMIT 1];

        address.Reference_Labs_Ship_to__c = true;
        Test.startTest();
            update address;
        Test.stopTest();

        for (Case accountCase : [SELECT Id, Status, Has_RefLabs_Multiple_Ship_To__c
                                 FROM Case
                                 WHERE Account.Name =: multiAddressAccountName]) {
            System.assertEquals('On Hold', accountCase.Status,
                'The Status of the Case should not have changed as the Address updated was inactive.');

            System.assertEquals(true, accountCase.Has_RefLabs_Multiple_Ship_To__c, 
                'The Has_RefLabs_Multiple_Ship_To__c field should not have changed to false');
        }
    }

    @isTest
    private static void unblockRelatedRefLabOnboardingCases_MultipleActiveAddresses_Test() {
        List<Address__c> addresses = [
            SELECT ID 
            FROM Address__c 
            WHERE Is_Active__c = true
            AND ZTS_EU_Address_Type__c = 'Ship To'];

        List<Case> accountCases = [
            SELECT Id, Status
            FROM Case
            WHERE RecordType.DeveloperName =: 'Ref_Labs_Onboarding'];
        
        system.assertEquals(totalCaseCount, accountCases.size(),
            'More/Less Cases were created than expected.');

        // The Case with a Status of New should not change after the Address is updated.
        Id newStatusCaseId;
        for (Case accountCase : accountCases) {
            if (accountCase.Status == 'New') {
                newStatusCaseId = accountCase.Id;
                break;
            }
        }
        
        for (Address__c address : addresses) {
            address.Reference_Labs_Ship_to__c = true;
        }

        Test.startTest();
            update addresses;
        Test.stopTest();

        for (Case accountCase : [SELECT Id, Status
                                 FROM Case
                                 WHERE Id in: accountCases]) {
            if (accountCase.Id == newStatusCaseId) {
                System.assertEquals('New', accountCase.Status,
                    'The Status of the Case with a Status of New should not have change');
            }
            else {
                System.assertEquals('In Progress', accountCase.Status,
                    'The Status of the Case should be In Progress');
            }
        }
    }

    @isTest
    private static void unblockRelatedRefLabOnboardingCases_NewAddresses_Test() {
        List<Account> accounts = [
            SELECT Id, ZTS_EU_Market__c 
            FROM Account
            WHERE (NOT Name LIKE: String.format(mergeAddressAccountNameFormat, new List<String> {'%'}))];

        system.assertEquals(totalAccountCount, accounts.size(), 'More/Less Accounts exist than expected.');

        List<Case> accountCases = [
            SELECT Id, Status
            FROM Case
            WHERE RecordType.DeveloperName =: 'Ref_Labs_Onboarding'];
        
        system.assertEquals(totalCaseCount, accountCases.size(),
            'More/Less Cases were created than expected.');

        // The Case with a Status of New should not change after the Address is updated.
        Id newStatusCaseId;
        for (Case accountCase : accountCases) {
            if (accountCase.Status == 'New') {
                newStatusCaseId = accountCase.Id;
                break;
            }
        }

        List<Address__c> addresses = new List<Address__c>();
        for (Account account : accounts) {
            Address__c validAddress = TestDataFactory.createAddresses(1, account.Id)[0];
            validAddress.ZTS_EU_Address_Type__c = 'Ship To';
            validAddress.Is_Active__c = true;
            validAddress.Ship_Indirect__c = 'N';
            validAddress.Reference_Labs_Ship_to__c = true;
            validAddress.ZTS_EU_Market_From_Parent__c = account.ZTS_EU_Market__c;
            addresses.add(validAddress);
        }

        Test.startTest();
            insert addresses;
        Test.stopTest();

        for (Case accountCase : [SELECT Id, Status, Has_RefLabs_Multiple_Ship_To__c
                                 FROM Case
                                 WHERE Id in: accountCases]) {
            if (accountCase.Id == newStatusCaseId) {
                System.assertEquals('New', accountCase.Status,
                    'The Status of the Case with a Status of New should not have change');
            }
            else {
                System.assertEquals('In Progress', accountCase.Status,
                    'The Status of the Case should be In Progress');
            }
        }
    }

    // No Accounts are passed in, so no data is updated or deleted.
    @isTest
    private static void mergeRelatedAddressesByAddressTypeAndDetails_NoData_Test() {
        Exception errorOccurred;
        Map<Id, Address__c> deleteAddressMap;
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();

        Test.startTest();
            try {
                deleteAddressMap = runMergeRelatedAddressesByAddressTypeAndDetails(new Set<Id>(),
                    updateRelatedRecordsMap);
            }
            catch (Exception e) {
                errorOccurred = e;
            }
        Test.stopTest();

        system.assertEquals(null, errorOccurred, String.format('An unexpected error occurred: {0}',
            new List<String> {errorOccurred?.getMessage()}));

        system.assert(deleteAddressMap.isEmpty(), String.format('Unexpected Values in Delete Position Map {0}',
            new List<Object> {deleteAddressMap}));

        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.isEmpty(), String.format(
            'Records were updated unexpectdly: {0}', new List<Object>{updateRelatedRecordsMap}));
    }

    // Pass in an Account with no Addresses, so no data will be updated or deleted.
    @isTest
    private static void mergeRelatedAddressesByAddressTypeAndDetails_NoAddresses_Test() {
        Account testAccount = [
            SELECT Id
            FROM Account
            WHERE Name =: String.format(mergeAddressAccountNameFormat, new List<Object>{0})
            LIMIT 1
        ];

        Exception errorOccurred;
        Map<Id, Address__c> deleteAddressMap;
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();

        Test.startTest();
            try {
                deleteAddressMap = runMergeRelatedAddressesByAddressTypeAndDetails(new Set<Id>{testAccount.Id},
                    updateRelatedRecordsMap);
            }
            catch (Exception e) {
                errorOccurred = e;
            }
        Test.stopTest();

        system.assertEquals(null, errorOccurred, String.format('An unexpected error occurred: {0}',
            new List<String> {errorOccurred?.getMessage()}));

        system.assert(deleteAddressMap.isEmpty(), String.format('Unexpected Values in Delete Position Map {0}',
            new List<Object> {deleteAddressMap}));

        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.isEmpty(), String.format(
            'Records were updated unexpectedly: {0}', new List<Object>{updateRelatedRecordsMap}));
    }

    // The Account in this Unit Test has unique Addresses, so no data should be deleted or updated.
    @isTest
    private static void mergeRelatedAddressesByAddressTypeAndDetails_UniqueAddresses_Test() {
        Account testAccount = [
            SELECT Id
            FROM Account
            WHERE Name =: String.format(mergeAddressAccountNameFormat, new List<Object>{1})
            LIMIT 1
        ];

        Exception errorOccurred;
        Map<Id, Address__c> deleteAddressMap;
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();

        Test.startTest();
            try {
                deleteAddressMap = runMergeRelatedAddressesByAddressTypeAndDetails(new Set<Id>{testAccount.Id},
                    updateRelatedRecordsMap);
            }
            catch (Exception e) {
                errorOccurred = e;
            }
        Test.stopTest();

        system.assertEquals(null, errorOccurred, String.format('An unexpected error occurred: {0}',
            new List<String> {errorOccurred?.getMessage()}));

        system.assert(deleteAddressMap.isEmpty(), String.format('Unexpected Values in Delete Position Map {0}',
            new List<Object> {deleteAddressMap}));

        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.isEmpty(), String.format(
            'Records were updated unexpectedly: {0}', new List<Object>{updateRelatedRecordsMap}));
    }

    @isTest
    private static void mergeRelatedAddressesByAddressTypeAndDetails_DuplicateAddresses_Test() {
        Account testAccount = [
            SELECT Id
            FROM Account
            WHERE Name =: String.format(mergeAddressAccountNameFormat, new List<Object>{2})
            LIMIT 1
        ];

        Map<String, Address__c> addressByType = new Map<String, Address__c>();
        Map<Id, Id> replacementAddressIdByDuplicateId = new Map<Id, Id>();
        Address__c updateAddressKeyAddress;

        Map<Id, String> expectedPhoneNumberByAddressId = new Map<Id, String>();
        for (Address__c address : [
            SELECT Id, ZTS_EU_Address_Type__c, CreatedDate, ZTS_EU_Address_ID__c, 
                   ZTS_GL_Unique_Primary_Address_Key__c, ZTS_EU_Account__c, ZTS_EU_Phone__c
            FROM Address__c
            WHERE ZTS_EU_Account__c =: testAccount.Id]) {
            String type = address.ZTS_EU_Address_Type__c;
            if (addressByType.containsKey(type)) {
                Address__c matchingAddress = addressByType.get(type);

                // Only one Address will have ZTS_EU_Address_ID__c populated, so only one Address is checked
                if (String.isNotBlank(address.ZTS_EU_Address_ID__c)) {
                    replacementAddressIdByDuplicateId.put(matchingAddress.Id, address.Id);

                    addExpectedPhoneNumberToMap(address, matchingAddress, expectedPhoneNumberByAddressId);
                }
                else if (String.isNotBlank(matchingAddress.ZTS_EU_Address_ID__c)) {
                    replacementAddressIdByDuplicateId.put(address.Id, matchingAddress.Id);

                    addExpectedPhoneNumberToMap(matchingAddress, address, expectedPhoneNumberByAddressId);
                }
                else if (matchingAddress.CreatedDate < address.CreatedDate) {
                    replacementAddressIdByDuplicateId.put(matchingAddress.Id, address.Id);

                    addExpectedPhoneNumberToMap(address, matchingAddress, expectedPhoneNumberByAddressId);
                }
                else {
                    replacementAddressIdByDuplicateId.put(address.Id, matchingAddress.Id);

                    addExpectedPhoneNumberToMap(matchingAddress, address, expectedPhoneNumberByAddressId);
                }
            }
            else {
                addressByType.put(type, address);
            }

            if (String.isNotBlank(address.ZTS_GL_Unique_Primary_Address_Key__c)) {
                updateAddressKeyAddress = address;
                // ZTS_GL_Unique_Primary_Address_Key__c will be set in a Workflow Rule and can't be overwritten in a Unit Test
                // Setting this flag will cause special test logic to run which will set ZTS_GL_Unique_Primary_Address_Key__c
                // to a value that will get overwritten
                AddressesService.overwriteMergePrimaryAddressKeyId = address.Id;
            }
        }
        
        Map<Id, Order> ordersById = new Map<Id, Order>([
            SELECT Id, Bill_To_Address__c, Distributor_Address__c, Drop_Ship_Requester_Distr__c, 
                   Leasing_Agent_Address__c, Payer_Address__c, Ship_To_Address__c
            FROM Order
            WHERE Distributor_Address__c in: replacementAddressIdByDuplicateId.keySet()
        ]);
        
        Map<Id, Call__c> callsById = new Map<Id, Call__c>([
            SELECT Id, ZTS_EU_Address__c
            FROM Call__c
            WHERE ZTS_EU_Address__c in: replacementAddressIdByDuplicateId.keySet()
        ]);

        Map<Id, Case> casesById = new Map<Id, Case>([
            SELECT Id, Address__c
            FROM Case
            WHERE Address__c in: replacementAddressIdByDuplicateId.keySet()
        ]);

        Map<Id, Account> accountsById = new Map<Id, Account>([
            SELECT Id, ZTS_EU_Primary_Address__c
            FROM Account
            WHERE ZTS_EU_Primary_Address__c in: replacementAddressIdByDuplicateId.keySet()
        ]);

        Map<Id, Contact> contactsById = new Map<Id, Contact>([
            SELECT Id, ZTS_EU_Primary_Address__c
            FROM Contact
            WHERE ZTS_EU_Primary_Address__c in: replacementAddressIdByDuplicateId.keySet()
        ]);

        Map<Id, Address__c> deleteAddressMap;
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();

        Test.startTest();
            deleteAddressMap = runMergeRelatedAddressesByAddressTypeAndDetails(new Set<Id>{testAccount.Id},
                updateRelatedRecordsMap);
        Test.stopTest();

        System.assertEquals(replacementAddressIdByDuplicateId.size(), deleteAddressMap.size(),
            'More/Less Addresses updated than expected');

        for (Id addressId : replacementAddressIdByDuplicateId.keySet()) {
            System.assert(deleteAddressMap.containsKey(addressId), String.format(
                'Address {0} was not deleted as expected. Actual deleted Addresses to delete: {1}', new List<Object> {
                        addressId, String.join(
                            (List<String>)(new List<Id>(deleteAddressMap.keySet())), ',')
                    }));
        }
        
        Map<String, Map<Id, SObject>> updateRecordsMapByName = updateRelatedRecordsMap.updateRecordsMapByName;

        System.assert(updateRecordsMapByName.containsKey('Order'), 'Orders were not updated as expected');

        Map<Id, SObject> updatedOrdersMap = updateRecordsMapByName.get('Order');
        System.assertEquals(ordersById.size(), updatedOrdersMap.size(), 'More/Less Orders updated than expected');

        for (SObject updatedRecord : updatedOrdersMap.values()) {
            Order updatedOrder = (Order)updatedRecord;
            System.assert(ordersById.containsKey(updatedOrder.Id), String.format('Unexpected Order Updated: {0}',
                new List<Object> {updatedOrder.Id}));

            Order originalOrder = ordersById.get(updatedOrder.Id);

            for (String lookupField : orderAddressLookupFields) {
                if (originalOrder.get(lookupField) != null) {
                    Id expectedAddressId = replacementAddressIdByDuplicateId.get((Id)originalOrder.get(lookupField));
                    System.assertEquals(expectedAddressId, updatedOrder.get(lookupField),
                        String.format('Field {0} was not updated as expected', new List<String>{lookupField}));
                }
                else {
                    System.assertEquals(null, updatedOrder.get(lookupField),
                        String.format('Field {0} was updated incorrectly', new List<String>{lookupField}));
                }
            }
        }

        System.assert(updateRecordsMapByName.containsKey('Call__c'), 'Calls were not updated as expected');

        Map<Id, SObject> updatedCallMap = updateRecordsMapByName.get('Call__c');
        System.assertEquals(callsById.size(), updatedCallMap.size(), 'More/Less Calls updated than expected');

        for (SObject updatedRecord : updatedCallMap.values()) {
            Call__c updatedCall = (Call__c)updatedRecord;
            System.assert(callsById.containsKey(updatedCall.Id), String.format('Unexpected Call Updated: {0}',
                new List<Object> {updatedCall.Id}));

            Call__c originalCall = callsById.get(updatedCall.Id);
            Id expectedAddressId = replacementAddressIdByDuplicateId.get(originalCall.ZTS_EU_Address__c);
            System.assertEquals(expectedAddressId, updatedCall.ZTS_EU_Address__c, 
                'ZTS_EU_Address__c was not updated as expected.');
        }

        System.assert(updateRecordsMapByName.containsKey('Case'), 'Cases were not updated as expected');

        Map<Id, SObject> updateCaseMap = updateRecordsMapByName.get('Case');
        System.assertEquals(casesById.size(), updateCaseMap.size(), 'More/Less Cases updated than expected');
        for (SObject updateRecord : updateCaseMap.values()) {
            Case updatedCase = (Case)updateRecord;

            System.assert(casesById.containsKey(updatedCase.Id), String.format('Unexpected Case Updated: {0}',
                new List<Object> {updatedCase.Id}));
            
            Case originalCase = casesById.get(updatedCase.Id);
            Id expectedAddressId = replacementAddressIdByDuplicateId.get(originalCase.Address__c);
            System.assertEquals(expectedAddressId, updatedCase.Address__c, 
                'ZTS_EU_Address__c was not updated as expected.');

            System.assert(updatedCase.Bypass_Validation_Rules__c, 'Bypass_Validation_Rules__c not set to true');
        }

        System.assert(updateRecordsMapByName.containsKey('Account'), 'Accounts were not updated as expected');

        Map<Id, SObject> updateAccountMap = updateRecordsMapByName.get('Account');
        System.assertEquals(accountsById.size(), updateAccountMap.size(), 'More/Less Accounts updated than expected');
        for (SObject updateRecord : updateAccountMap.values()) {
            Account updatedAccount = (Account)updateRecord;

            System.assert(accountsById.containsKey(updatedAccount.Id), String.format('Unexpected Account Updated: {0}',
                new List<Object> {updatedAccount.Id}));
            
            Account originalAccount = accountsById.get(updatedAccount.Id);
            Id expectedAddressId = replacementAddressIdByDuplicateId.get(originalAccount.ZTS_EU_Primary_Address__c);
            System.assertEquals(expectedAddressId, updatedAccount.ZTS_EU_Primary_Address__c, 
                'ZTS_EU_Primary_Address__c was not updated as expected.');
        }

        System.assert(updateRecordsMapByName.containsKey('Contact'), 'Contacts were not updated as expected');

        Map<Id, SObject> updateContactMap = updateRecordsMapByName.get('Contact');
        System.assertEquals(contactsById.size(), updateContactMap.size(), 'More/Less Contacts updated than expected');
        for (SObject updateRecord : updateContactMap.values()) {
            Contact updatedContact = (Contact)updateRecord;

            System.assert(contactsById.containsKey(updatedContact.Id), String.format('Unexpected Contact Updated: {0}',
                new List<Object> {updatedContact.Id}));
            
            Contact originalContact = contactsById.get(updatedContact.Id);
            Id expectedAddressId = replacementAddressIdByDuplicateId.get(originalContact.ZTS_EU_Primary_Address__c);
            System.assertEquals(expectedAddressId, updatedContact.ZTS_EU_Primary_Address__c, 
                'ZTS_EU_Primary_Address__c was not updated as expected.');
        }

        System.assert(updateRecordsMapByName.containsKey('Address__c'), 'Addresses were not updated as expected');

        Map<Id, SObject> updateAddressMap = updateRecordsMapByName.get('Address__c');

        // One Address should have its Key updated. Another Address should have its Phone Number updated
        System.assertEquals(2, updateAddressMap.size(), 'More/Less Addresses updated than expected.');
        
        System.assert(updateAddressMap.containsKey(updateAddressKeyAddress.Id), String.format(
            'Address {0} was not updated as expected. Actual: {1}', 
            new List<Object>{updateAddressKeyAddress.Id, updateAddressMap.keySet()}));

        for (Address__c updatedAddress : (List<Address__c>)updateAddressMap.values()) {
            if (updatedAddress.Id == updateAddressKeyAddress.Id) {
                System.assertEquals(String.format('{0}True', new List<Object> {updateAddressKeyAddress.ZTS_EU_Account__c}), 
                updatedAddress.ZTS_GL_Unique_Primary_Address_Key__c,
                'ZTS_GL_Unique_Primary_Address_Key__c was not updated as expected.');
            }
            else {
                System.assertEquals(expectedPhoneNumberByAddressId.get(updatedAddress.Id), updatedAddress.ZTS_EU_Phone__c,
                    'Phone was not updated as expected.');
            }
        }
    }

    @isTest
    private static void mergeRelatedAddressesByAddressTypeAndDetails_DuplicateAddressesWithDifferentIds_Test() {
        Account testAccount = [
            SELECT Id
            FROM Account
            WHERE Name =: String.format(mergeAddressAccountNameFormat, new List<Object>{4})
            LIMIT 1
        ];

        // Sanity check to confirm there are 4 Keys and 7 Addresses
        Map<String, List<Address__c>> addressesByIntegrationId = new Map<String, List<Address__c>>();
        Map<String, Integer> expectedCountByIntegrationId = new Map<String, Integer> {
            buildUnitTestAddressMergeIntegrationId(null, null) => 1,
            buildUnitTestAddressMergeIntegrationId(mergeAccount4AddressId1, mergeAccount4AddressId1) => 2,
            buildUnitTestAddressMergeIntegrationId(mergeAccount4AddressId2, null) => 2,
            buildUnitTestAddressMergeIntegrationId(null, mergeAccount4AddressId2) => 2
        };

        // Only retrieve Addresses setup in testSetup with a Billing Type to ignore autocreated Addresses
        for (Address__c address : [
            SELECT Id, ZTS_EU_Address_ID__c, ZTS_US_Source_Account_Number__c
            FROM Address__c
            WHERE ZTS_EU_Account__c =: testAccount.Id
            AND ZTS_EU_Address_Type__c = 'Billing']) {
            String integrationId = buildUnitTestAddressMergeIntegrationId(address.ZTS_EU_Address_Id__c,
                address.ZTS_US_Source_Account_Number__c);

            if (!addressesByIntegrationId.containsKey(integrationId)) {
                addressesByIntegrationId.put(integrationId, new List<Address__c>());
            }

            addressesByIntegrationId.get(integrationId).add(address);
        }

        System.assertEquals(expectedCountByIntegrationId.size(), addressesByIntegrationId.size(), 'Sanity check failed. More/Less Address Ids than expected');
        
        for (String integrationId : expectedCountByIntegrationId.keySet()) {
            System.assert(addressesByIntegrationId.containsKey(integrationId), String.format(
                'Sanity Check failed. Key {0} was not present on any Addresses.', new List<String> {integrationId}));

            System.assertEquals(expectedCountByIntegrationId.get(integrationId), addressesByIntegrationId.get(integrationId).size(),
                String.format('Sanity Check failed. More/Less Addresses than expected for Address Id {0}.', new List<String> {integrationId}));
        }
        
        Map<Id, Address__c> deleteAddressMap;
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();

        Test.startTest();
            deleteAddressMap = runMergeRelatedAddressesByAddressTypeAndDetails(new Set<Id>{testAccount.Id},
                updateRelatedRecordsMap);
        Test.stopTest();

        System.assertEquals(4, deleteAddressMap.size(),
            'Expected 4 deletions. One for each Id and one for the blank Address Id');

        for (Address__c address : deleteAddressMap.values()) {
            String integrationId = buildUnitTestAddressMergeIntegrationId(address.ZTS_EU_Address_Id__c,
                address.ZTS_US_Source_Account_Number__c);

            List<Address__c> addressesWithSameId = addressesByIntegrationId.get(integrationId);
            
            // Pull out the same Address from the list above so it can be removed by memory reference
            Address__c matchingAddress = new Map<Id, Address__c>(addressesWithSameId).get(address.Id);
            addressesWithSameId.remove(addressesWithSameId.indexOf(matchingAddress));

            if (addressesWithSameId.isEmpty()) {
                addressesByIntegrationId.remove(integrationId);
            }
        }

        System.assertEquals(3, addressesByIntegrationId.size(), '3 Address Ids should be left after merge.');

        String blankIntegrationId = buildUnitTestAddressMergeIntegrationId(null, null);
        for (String addressIntegrationId : expectedCountByIntegrationId.keySet()) {
            if (addressIntegrationId != blankIntegrationId) {
                System.assert(addressesByIntegrationId.containsKey(addressIntegrationId),
                    String.format('All Addresses for Address Id {0} were deleted unexpectedly.',
                        new List<String> {addressIntegrationId}));

                System.assertEquals(1, addressesByIntegrationId.get(addressIntegrationId).size(),
                    String.format('There are more/less than 1 record with an Id of {0}', new List<String> {addressIntegrationId}));
            }
        }
    }


    @isTest
    private static void mergeRelatedAddressesByAddressTypeAndDetails_MultipleAccounts_Test() {
        Set<Id> accountIds = new Map<Id, Account>([
            SELECT Id
            FROM Account
            WHERE Name LIKE: String.format(mergeAddressAccountNameFormat, new List<Object>{'%'})
            // Due to unpredictiveness of which Address will be kept, 
            // the fourth Account which tests merging Addresses with varying ZTS_EU_Address_ID__c is not used
            AND Name !=: String.format(mergeAddressAccountNameFormat, new List<Object> {4})
        ]).keySet();

        Map<String, Address__c> addressByUniqueKey = new Map<String, Address__c>();
        Map<Id, Id> replacementAddressIdByDuplicateId = new Map<Id, Id>();
        Address__c updateAddressKeyAddress;

        Map<Id, String> expectedPhoneNumberByAddressId = new Map<Id, String>();
        for (Address__c address : [
            SELECT Id, ZTS_EU_Address_Type__c, CreatedDate, ZTS_EU_Address_ID__c, 
                   ZTS_GL_Unique_Primary_Address_Key__c, ZTS_EU_Account__c,
                   ZTS_US_Source_Account_Number__c, ZTS_EU_Phone__c
            FROM Address__c
            WHERE ZTS_EU_Account__c in: accountIds]) {
            String uniqueKey = String.format('{0}{1}', 
                new List<Object>{address.ZTS_EU_Account__c, address.ZTS_EU_Address_Type__c});

            if (addressByUniqueKey.containsKey(uniqueKey)) {
                Address__c matchingAddress = addressByUniqueKey.get(uniqueKey);

                // One Address will have ZTS_EU_Address_ID__c populated on both Accounts, 
                // so both Addresses are checked
                if (String.isNotBlank(address.ZTS_EU_Address_ID__c) && 
                    String.isBlank(matchingAddress.ZTS_EU_Address_ID__c)) {
                    replacementAddressIdByDuplicateId.put(matchingAddress.Id, address.Id);

                    addExpectedPhoneNumberToMap(address, matchingAddress, expectedPhoneNumberByAddressId);
                }
                else if (String.isNotBlank(matchingAddress.ZTS_EU_Address_ID__c) && 
                    String.isBlank(address.ZTS_EU_Address_ID__c)) {
                    replacementAddressIdByDuplicateId.put(address.Id, matchingAddress.Id);

                    addExpectedPhoneNumberToMap(matchingAddress, address, expectedPhoneNumberByAddressId);
                }
                else if (String.isNotBlank(address.ZTS_US_Source_Account_Number__c) && 
                    String.isBlank(matchingAddress.ZTS_US_Source_Account_Number__c)) {
                    replacementAddressIdByDuplicateId.put(matchingAddress.Id, address.Id);

                    addExpectedPhoneNumberToMap(address, matchingAddress, expectedPhoneNumberByAddressId);
                }
                else if (String.isNotBlank(matchingAddress.ZTS_US_Source_Account_Number__c) && 
                    String.isBlank(address.ZTS_US_Source_Account_Number__c)) {
                    replacementAddressIdByDuplicateId.put(address.Id, matchingAddress.Id);

                    addExpectedPhoneNumberToMap(matchingAddress, address, expectedPhoneNumberByAddressId);
                }
                else if (matchingAddress.CreatedDate < address.CreatedDate) {
                    replacementAddressIdByDuplicateId.put(matchingAddress.Id, address.Id);

                    addExpectedPhoneNumberToMap(address, matchingAddress, expectedPhoneNumberByAddressId);
                }
                else {
                    replacementAddressIdByDuplicateId.put(address.Id, matchingAddress.Id);

                    addExpectedPhoneNumberToMap(matchingAddress, address, expectedPhoneNumberByAddressId);
                }
            }
            else {
                addressByUniqueKey.put(uniqueKey, address);
            }

            if (String.isNotBlank(address.ZTS_GL_Unique_Primary_Address_Key__c)) {
                updateAddressKeyAddress = address;
                AddressesService.overwriteMergePrimaryAddressKeyId = address.Id;
            }
        }
        
        Map<Id, Order> ordersById = new Map<Id, Order>([
            SELECT Id, Bill_To_Address__c, Distributor_Address__c, Drop_Ship_Requester_Distr__c, 
                   Leasing_Agent_Address__c, Payer_Address__c, Ship_To_Address__c
            FROM Order
            WHERE Distributor_Address__c in: replacementAddressIdByDuplicateId.keySet()
        ]);
        
        Map<Id, Call__c> callsById = new Map<Id, Call__c>([
            SELECT Id, ZTS_EU_Address__c
            FROM Call__c
            WHERE ZTS_EU_Address__c in: replacementAddressIdByDuplicateId.keySet()
        ]);

        Map<Id, Case> casesById = new Map<Id, Case>([
            SELECT Id, Address__c
            FROM Case
            WHERE Address__c in: replacementAddressIdByDuplicateId.keySet()
        ]);

        Map<Id, Account> accountsById = new Map<Id, Account>([
            SELECT Id, ZTS_EU_Primary_Address__c
            FROM Account
            WHERE ZTS_EU_Primary_Address__c in: replacementAddressIdByDuplicateId.keySet()
        ]);

        Map<Id, Contact> contactsById = new Map<Id, Contact>([
            SELECT Id, ZTS_EU_Primary_Address__c
            FROM Contact
            WHERE ZTS_EU_Primary_Address__c in: replacementAddressIdByDuplicateId.keySet()
        ]);

        Map<Id, Address__c> deleteAddressMap;
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();

        Test.startTest();
            deleteAddressMap = runMergeRelatedAddressesByAddressTypeAndDetails(accountIds,
                updateRelatedRecordsMap);
        Test.stopTest();

        System.assertEquals(replacementAddressIdByDuplicateId.size(), deleteAddressMap.size(),
            'More/Less Addresses updated than expected');

        for (Id addressId : replacementAddressIdByDuplicateId.keySet()) {
            System.assert(deleteAddressMap.containsKey(addressId), String.format(
                'Address {0} was not deleted as expected. Actual deleted Addresses to delete: {1}', new List<Object> {
                        addressId, String.join(
                            (List<String>)(new List<Id>(deleteAddressMap.keySet())), ',')
                    }));
        }
        
        Map<String, Map<Id, SObject>> updateRecordsMapByName = updateRelatedRecordsMap.updateRecordsMapByName;

        System.assert(updateRecordsMapByName.containsKey('Order'), 'Orders were not updated as expected');

        Map<Id, SObject> updatedOrdersMap = updateRecordsMapByName.get('Order');
        System.assertEquals(ordersById.size(), updatedOrdersMap.size(), 'More/Less Orders updated than expected');
        
        for (SObject updatedRecord : updatedOrdersMap.values()) {
            Order updatedOrder = (Order)updatedRecord;
            System.assert(ordersById.containsKey(updatedOrder.Id), String.format('Unexpected Order Updated: {0}',
                new List<Object> {updatedOrder.Id}));

            Order originalOrder = ordersById.get(updatedOrder.Id);

            for (String lookupField : orderAddressLookupFields) {
                if (originalOrder.get(lookupField) != null) {
                    Id expectedAddressId = replacementAddressIdByDuplicateId.get((Id)originalOrder.get(lookupField));
                    System.assertEquals(expectedAddressId, updatedOrder.get(lookupField),
                        String.format('Field {0} was not updated as expected', new List<String>{lookupField}));
                }
                else {
                    System.assertEquals(null, updatedOrder.get(lookupField),
                        String.format('Field {0} was updated incorrectly', new List<String>{lookupField}));
                }
            }
        }

        System.assert(updateRecordsMapByName.containsKey('Call__c'), 'Calls were not updated as expected');

        Map<Id, SObject> updatedCallMap = updateRecordsMapByName.get('Call__c');
        System.assertEquals(callsById.size(), updatedCallMap.size(), 'More/Less Calls updated than expected');
        for (SObject updatedRecord : updatedCallMap.values()) {
            Call__c updatedCall = (Call__c)updatedRecord;
            System.assert(callsById.containsKey(updatedCall.Id), String.format('Unexpected Call Updated: {0}',
                new List<Object> {updatedCall.Id}));

            Call__c originalCall = callsById.get(updatedCall.Id);
            Id expectedAddressId = replacementAddressIdByDuplicateId.get(originalCall.ZTS_EU_Address__c);
            System.assertEquals(expectedAddressId, updatedCall.ZTS_EU_Address__c, 
                'ZTS_EU_Address__c was not updated as expected.');
        }

        System.assert(updateRecordsMapByName.containsKey('Case'), 'Cases were not updated as expected');

        Map<Id, SObject> updateCaseMap = updateRecordsMapByName.get('Case');
        System.assertEquals(casesById.size(), updateCaseMap.size(), 'More/Less Cases updated than expected');
        for (SObject updateRecord : updateCaseMap.values()) {
            Case updatedCase = (Case)updateRecord;

            System.assert(casesById.containsKey(updatedCase.Id), String.format('Unexpected Case Updated: {0}',
                new List<Object> {updatedCase.Id}));
            
            Case originalCase = casesById.get(updatedCase.Id);
            Id expectedAddressId = replacementAddressIdByDuplicateId.get(originalCase.Address__c);
            System.assertEquals(expectedAddressId, updatedCase.Address__c, 
                'ZTS_EU_Address__c was not updated as expected.');

            System.assert(updatedCase.Bypass_Validation_Rules__c, 'Bypass_Validation_Rules__c not set to true');
        }

        System.assert(updateRecordsMapByName.containsKey('Account'), 'Accounts were not updated as expected');

        Map<Id, SObject> updateAccountMap = updateRecordsMapByName.get('Account');
        System.assertEquals(accountsById.size(), updateAccountMap.size(), 'More/Less Accounts updated than expected');
        for (SObject updateRecord : updateAccountMap.values()) {
            Account updatedAccount = (Account)updateRecord;

            System.assert(accountsById.containsKey(updatedAccount.Id), String.format('Unexpected Account Updated: {0}',
                new List<Object> {updatedAccount.Id}));
            
            Account originalAccount = accountsById.get(updatedAccount.Id);
            Id expectedAddressId = replacementAddressIdByDuplicateId.get(originalAccount.ZTS_EU_Primary_Address__c);
            System.assertEquals(expectedAddressId, updatedAccount.ZTS_EU_Primary_Address__c, 
                'ZTS_EU_Primary_Address__c was not updated as expected.');
        }

        System.assert(updateRecordsMapByName.containsKey('Contact'), 'Contacts were not updated as expected');

        Map<Id, SObject> updateContactMap = updateRecordsMapByName.get('Contact');
        System.assertEquals(contactsById.size(), updateContactMap.size(), 'More/Less Contacts updated than expected');
        for (SObject updateRecord : updateContactMap.values()) {
            Contact updatedContact = (Contact)updateRecord;

            System.assert(contactsById.containsKey(updatedContact.Id), String.format('Unexpected Contact Updated: {0}',
                new List<Object> {updatedContact.Id}));
            
            Contact originalContact = contactsById.get(updatedContact.Id);
            Id expectedAddressId = replacementAddressIdByDuplicateId.get(originalContact.ZTS_EU_Primary_Address__c);
            System.assertEquals(expectedAddressId, updatedContact.ZTS_EU_Primary_Address__c, 
                'ZTS_EU_Primary_Address__c was not updated as expected.');
        }

        System.assert(updateRecordsMapByName.containsKey('Address__c'), 'Addresses were not updated as expected');

        Map<Id, SObject> updateAddressMap = updateRecordsMapByName.get('Address__c');

        // One Address should have its Key updated. Two Addresses should have their Phone Number updated
        System.assertEquals(3, updateAddressMap.size(), 'More/Less Addresses updated than expected.');
        
        System.assert(updateAddressMap.containsKey(updateAddressKeyAddress.Id), String.format(
            'Address {0} was not updated as expected. Actual: {1}', 
            new List<Object>{updateAddressKeyAddress.Id, updateAddressMap.keySet()}));

        for (Address__c updatedAddress : (List<Address__c>)updateAddressMap.values()) {
            if (updatedAddress.Id == updateAddressKeyAddress.Id) {
                System.assertEquals(String.format('{0}True', new List<Object> {updateAddressKeyAddress.ZTS_EU_Account__c}), 
                updatedAddress.ZTS_GL_Unique_Primary_Address_Key__c,
                'ZTS_GL_Unique_Primary_Address_Key__c was not updated as expected.');
            }
            else {
                System.assertEquals(expectedPhoneNumberByAddressId.get(updatedAddress.Id), updatedAddress.ZTS_EU_Phone__c,
                    'Phone was not updated as expected.');
            }
        }
    }

    private static Map<Id, Address__c> runMergeRelatedAddressesByAddressTypeAndDetails(Set<Id> accountIds,
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap) {
        return AddressesService.mergeRelatedAddressesByAddressTypeAndDetails(accountIds, 
            new Map<String, MergeRelatedRecordLookupsSelector.ChildObject>{
                'Order' => new MergeRelatedRecordLookupsSelector.ChildObject('Order', null),
                'Call__c' => new MergeRelatedRecordLookupsSelector.ChildObject('Call__c', null),
                'Case' => new MergeRelatedRecordLookupsSelector.ChildObject('Case', 'Bypass_Validation_Rules__c'),
                'Account' => new MergeRelatedRecordLookupsSelector.ChildObject('Account', null),
                'Contact' => new MergeRelatedRecordLookupsSelector.ChildObject('Contact', null)},
            updateRelatedRecordsMap);
    }

    private static Address__c setupAddressWithAllMergeFields(Id accountId, string type, Id stateCountryId,
        Id communeId, Id cityStateId) {
        Address__c address = TestDataFactory.createAddresses(1, accountId)[0];
        address.ZTS_Address_Line_1__c = 'Line 1';
        address.Name = 'Line 1';
        address.ZTS_EU_Address_Line_2__c = 'Line 2';
        address.ZTS_EU_Address_Line_3__c = 'Line 3';
        address.Address_Line_4__c = 'Line 4';
        address.ZTS_EU_Country__c = 'United Kingdom';
        address.ZTS_EU_State_County__c = stateCountryId;
        address.ZTS_EU_Commune_Lookup__c = communeId;
        address.ZTS_EU_District__c = 'District';
        address.ZTS_EU_City__c = 'City';
        address.ZTS_EU_City_Country__c = cityStateId;
        address.Zip_Postal_Code__c = '90909';
        address.ZTS_EU_Address_Type__c = type;

        return address;
    }

    // Build a concaenated Integration Id for Address Merging
    private static String buildUnitTestAddressMergeIntegrationId(String addressId, String accountNumber) {
        return String.format('Address Id:{0} Account Number:{1}', 
                new List<String>{addressId, accountNumber});
    }

    private static void addExpectedPhoneNumberToMap(Address__c keepAddress, Address__c duplicateAddress,
        Map<Id, String> expectedPhoneNumberByAddressId) {
        if (String.isBlank(keepAddress.ZTS_EU_Phone__c) && String.isNotBlank(duplicateAddress.ZTS_EU_Phone__c)) {
            expectedPhoneNumberByAddressId.put(keepAddress.Id, duplicateAddress.ZTS_EU_Phone__c);
        }
        else {
            expectedPhoneNumberByAddressId.put(keepAddress.Id, keepAddress.ZTS_EU_Phone__c);
        }
    }
}