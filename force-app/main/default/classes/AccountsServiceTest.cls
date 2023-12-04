/**
 * @description       : Test class for AccountsService
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-04-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-13-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for setPrimaryProgramOwnerOnAccounts
 * 1.0   04-14-2022   Ethan Hirsch @ Zoetis Inc   Cleanup comment
 * 1.1   05-06-2022   Ethan Hirsch @ Zoetis Inc   Add tests for setOnboardingCaseStatus method.
 * 1.2   08-29-2022   Ethan Hirsch @ Zoetis Inc   Add tests for setSendToDMRFlagUpdate method.
 * 1.3   08-30-2022   Ethan Hirsch @ Zoetis Inc   Update setSendToDMRFlagUpdate_DoNotSend_IgnoredUser to set the
 *                                                Exclude Integrations field on the current User.
 * 1.4   08-30-2022   Ethan Hirsch @ Zoetis Inc   Add tests for setSendToDMRFlagCreate.
 * 1.5   08-30-2022   Ethan Hirsch @ Zoetis Inc   Move setSendToDMRFlagCreate and setSendToDMRFlagUpdate tests to 
 *                                                setSendToDMRFlag tests. 
 *                                                Add additional assertions to verify create and update flags are set 
 *                                                properly on insert and update.
 * 1.6   08-31-2022   Ethan Hirsch @ Zoetis Inc   Add tests and assertions for setSendToDMRFlags to make sure flags can
 *                                                be unchecked.
 * 1.7   09-07-2022   Ethan Hirsch @ Zoetis Inc   Add and update tests to make sure DMR Flags can be unchecked manually
 *                                                and the Create flag is only checked when a field changes.
 * 1.8   09-12-2022   Ethan Hirsch @ Zoetis Inc   Add and update tests to make sure DMR Update can be set when DMR Id is blank
 * 1.2   05-26-2022   Ethan Hirsch @ Zoetis Inc   Add tests for mergeRelatedDataInternational method. 
 *                                                These tests look to do more high level testing of the logic. 
 *                                                In depth tests are in individual Service classes for the objects being merged.
 * 1.3   06-22-2022   Ethan Hirsch @ Zoetis Inc   Update test data created for merge test so that the Account Position on a duplicate
 *                                                Account is kept to verify there are no errors updating its unique key.
 * 1.4   06-27-2022   Ethan Hirsch @ Zoetis Inc   Add Assertions to confirm Assigned Territories are not deleted on an Account.
 * 1.5   07-06-2022   Ethan Hirsch @ Zoetis Inc   Comment out assertions around the Account Territory object
 * 1.6   07-15-2022   Ethan Hirsch @ Zoetis Inc   Reenable assertions around the Account Territory object
 * 1.7   08-02-2022   Ethan Hirsch @ Zoetis Inc   Bypass the Account Trigger in setOnboardingCaseStatus tests to avoid limit errors
 **/
@isTest
private class AccountsServiceTest {
    private static final String testUserUSUserNameFormat = 'testusUser{0}@zoetis.com.AccountsServiceTest';
    private static final String firstUSAccountName = 'US Account 0';
    private static final String secondUSAccountName = 'US Account 1';
    private static final String firstMergeAccountName = 'Merge Account 0';
    private static final String secondMergeAccountName = 'Merge Account 1';
    private static final String thirdMergeAccountName = 'Merge Account 2';

    private static final Integer uniqueRecordCountForMergeTest = 3;

    @TestSetup
    private static void setup(){
        // Setup Territory in a separate context so other data can be created safely
        Territory2 primaryTestTerritory;
        List<Territory2> territories = new List<Territory2>();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Territory2Type territoryType = [
                SELECT Id, DeveloperName
                FROM Territory2Type
                LIMIT 1];

            Territory2Model territoryModel = new Territory2Model();
            territoryModel.DeveloperName = 'TestModel';
            territoryModel.Name = 'TestModel';
            insert territoryModel;

            for (integer i = 0; i < uniqueRecordCountForMergeTest; i++) {
                Territory2 testTerritory = new Territory2();
                testTerritory.AccountAccessLevel = 'Edit';
                testTerritory.CaseAccessLevel = 'Edit';
                testTerritory.DeveloperName = String.format('TestTerritory_{0}', new List<Object> {i});
                testTerritory.Name = String.format('TestTerritory_{0}', new List<Object> {i});
                testTerritory.OpportunityAccessLevel = 'Edit';
                testTerritory.Territory2ModelId = territoryModel.Id;
                testTerritory.Territory2TypeId = territoryType.Id;
                territories.add(testTerritory);
            }
            insert territories;

            primaryTestTerritory = territories[0];
        }

        Id adminProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1].Id;

        List<User> usUsers = new List<User>();
        List<User> intlUsers = new List<User>();
        for (integer i = 0; i < 4; i++) {
            User testUser = TestDataFactory.createUser(adminProfileId, false);
            testUser.UserName = string.format(testUserUSUserNameFormat, new List<Object> {i});
            testUser.ZTS_EU_Market__c = 'United States';
            usUsers.add(testUser);
        }

        for (integer i = 0; i < uniqueRecordCountForMergeTest; i++) {
            User intlUser = TestDataFactory.createUser(adminProfileId, false);
            intlUser.ZTS_EU_Market__c = 'United Kingdom';
            intlUsers.add(intlUser);
        }

        List<User> testUsers = new List<User>();
        testUsers.addAll(usUsers);
        testUsers.addAll(intlUsers);
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        insert testUsers;
        DispatchTriggerHandler.clearBypass('UserTriggerHandler');
        Account account1 = TestDataFactory.createAccount_US(firstUSAccountName, false);
        Account account2 = TestDataFactory.createAccount_US(secondUSAccountName, false);
        Account mergeAccount1 = TestDataFactory.createAccount_EU(firstMergeAccountName, null, false);
        Account mergeAccount2 = TestDataFactory.createAccount_EU(secondMergeAccountName, null, false);
        Account mergeAccount3 = TestDataFactory.createAccount_EU(thirdMergeAccountName, null, false);
        insert new List<Account> {account1, account2, mergeAccount1, mergeAccount2, mergeAccount3};

        List<Id> mergeAccountIds = new List<Id> {mergeAccount1.Id, mergeAccount2.Id, mergeAccount3.Id};

        ZTS_EU_Territory__c ztsTerritoryUS1 = TestDataFactory.createZTSTerritory(
            'TestTerritoryUS',
            primaryTestTerritory.Id,
            'United States',
            false);

        ZTS_EU_Territory__c ztsTerritoryUS2 = TestDataFactory.createZTSTerritory(
            'TestTerritoryUS2',
            primaryTestTerritory.Id,
            'United States',
            false);

        List<ZTS_EU_Territory__c> ztsIntlTerritories = new List<ZTS_EU_Territory__c>();
        for (integer i = 0; i < uniqueRecordCountForMergeTest; i++) {
            ztsIntlTerritories.add(TestDataFactory.createZTSTerritory(
                String.format('TestTerritoryUK{0}', new List<Object> {i}),
                territories[i].Id,
                'United Kingdom',
                false));
        }

        List<ZTS_EU_Territory__c> allTerritories = new List<ZTS_EU_Territory__c>();
        allTerritories.add(ztsTerritoryUS1);
        allTerritories.add(ztsTerritoryUS2);
        allTerritories.addAll(ztsIntlTerritories);

        insert allTerritories;

        List<ZTS_EU_Position__c> positions = new List<ZTS_EU_Position__c>();
        positions.add(TestDataFactory.createPosition(
            ztsTerritoryUS1.Name,
            ztsTerritoryUS1.Id,
            ztsTerritoryUS1.ZTS_EU_Market__c,
            usUsers[0].Id,
            false));

        for (integer i = 1; i < usUsers.size(); i++) {
            positions.add(TestDataFactory.createPosition(
                ztsTerritoryUS2.Name,
                ztsTerritoryUS2.Id,
                ztsTerritoryUS2.ZTS_EU_Market__c,
                usUsers[i].Id,
                false
            ));
        }

        List<ZTS_EU_Position__c> intlPositions = new List<ZTS_EU_Position__c>();
        for (Integer i = 0; i < uniqueRecordCountForMergeTest; i++) {
            ZTS_EU_Territory__c intlTerritory = ztsIntlTerritories[i];

            intlPositions.add(TestDataFactory.createPosition(
                intlTerritory.Name,
                intlTerritory.Id,
                intlTerritory.ZTS_EU_Market__c,
                intlUsers[i].Id,
                false
            ));
        }

        List<ZTS_EU_Position__c> allPositions = new List<ZTS_EU_Position__c>();
        allPositions.addAll(positions);
        allPositions.addAll(intlPositions);
        insert allPositions;

        // Create an Account Territory will automatically create Account Positions
        List<ZTS_AccountTerritory__c> accountTerritories = new List<ZTS_AccountTerritory__c>();
        accountTerritories.add(TestDataFactory.createAccountTerritory(
            account1.Id,
            ztsTerritoryUS1.Id,
            false));
        
        accountTerritories.add(TestDataFactory.createAccountTerritory(
            account2.Id,
            ztsTerritoryUS2.Id,
            false));

        // The Account Territories created in this block will get merged into a single record
        for (integer i = 0; i < uniqueRecordCountForMergeTest; i++) {
            accountTerritories.add(TestDataFactory.createAccountTerritory(
                mergeAccountIds[i],
                ztsIntlTerritories[0].Id,
                false
            ));

            // Create an additional Account Territory for the first 2 Accounts
            integer additionalTerritoryIndex = i + 1;
            if (additionalTerritoryIndex >= uniqueRecordCountForMergeTest) {
                continue;
            }

            accountTerritories.add(TestDataFactory.createAccountTerritory(
                mergeAccountIds[i],
                ztsIntlTerritories[additionalTerritoryIndex].Id,
                false
            ));

        }

        // Inserting Account Territories will also create Account Positions
        insert accountTerritories;

        List<Address__c> addresses = new List<Address__c>();
        Address__c orderAddress;
        // THe Addresses created in this loop will be merged together
        for (Id mergeAccountId : mergeAccountIds) {
            Address__c duplicateAddresses = TestDataFactory.createAddresses(1, mergeAccountId)[0];
            duplicateAddresses.ZTS_EU_Address_Type__c = 'Billing';
            addresses.add(duplicateAddresses);

            if (mergeAccountId == mergeAccount2.Id) {
                orderAddress = duplicateAddresses;
            }
        }

        // These Addresses will be left on the new Account after a merge.
        Address__c additionalAddress1 = TestDataFactory.createAddresses(1, mergeAccountIds[0])[0];
        additionalAddress1.ZTS_EU_Address_Type__c = 'PO Box';
        addresses.add(additionalAddress1);

        Address__c additionalAddress2 = TestDataFactory.createAddresses(1, mergeAccountIds[1])[0];
        additionalAddress2.ZTS_EU_Address_Type__c = 'Primary';
        // This key will be overwritten and verified as being properly updated on merge
        additionalAddress2.ZTS_GL_Unique_Primary_Address_Key__c = 'INCORRECT1';
        additionalAddress2.ZTS_US_Primary__c  = true;
        addresses.add(additionalAddress2);

        insert addresses;

        
        // This Order will be left on one of the remaining Addresses after a merge
        Order extraOrder = TestDataFactory.createOrder(mergeAccount2.Id, false);
        extraOrder.Bill_To_Address__c = orderAddress.Id;
        extraOrder.Ship_To_Address__c = orderAddress.Id;
        extraOrder.RecordTypeId = OrderHandler.distributorOrderRTId;
        insert extraOrder;
        System.assert(extraOrder.id != null);

        
        // Create an ECC for the duplicate Account Position on Account 2 to confirm it's merged.
        // Set a Call Target on the duplicate Account Position on Account 3 to make it be prioritized
        ZTS_EU_Account_Position__c eccAccountPosition;
        ZTS_EU_Account_Position__c callTargetAccountPosition;
        for (ZTS_EU_Account_Position__c accountPosition : [
                SELECT Id, ZTS_EU_Account__c
                FROM ZTS_EU_Account_Position__c
                WHERE ZTS_EU_Account__c in: new List<Id> {mergeAccount2.Id, mergeAccount3.Id}
                AND ZTS_AccountTerritory__r.ZTS_EU_Territory__c =: ztsIntlTerritories[0].Id
            ]) {
            if (accountPosition.ZTS_EU_Account__c == mergeAccount2.Id) {
                eccAccountPosition = accountPosition;
            }
            else {
                callTargetAccountPosition = accountPosition;
            }
        }

        // This Employee Call Credit will be left on one of the remaining Account Positions after a merge
        ZTS_EU_DataUtilityTest.createEmployeeCallCredit(eccAccountPosition, intlUsers[1].Id, true);

        callTargetAccountPosition.ZTS_EU_Call_Target__c = 2;
        update callTargetAccountPosition;

       
    }

    @isTest
    private static void setPrimaryProgramOwnerOnAccounts_SetVGPOwner_Test() {
        User testUser = retrieveTestUsUser();

        ZTS_EU_Account_Position__c accountPosition = retrieveFirstAccountPositionForUser(testUser.Id);
        
        accountPosition.VGP_Program_Owner__c = 'Primary';

        Test.startTest();
            update accountPosition;
        Test.stopTest();

        Account account = retrieveUpdatedProgramOwnerAccount(accountPosition.ZTS_EU_Account__c);
        System.assertEquals(accountPosition.ZTS_EU_Employee__c, account.VGP_Program_Owner__c, 
            'VGP Program Owner should be set.');
        System.assertEquals(testUser.Email, account.VGP_Program_Owner_email__c, 
            'VGP Program Owner email should be set to the email of the VGP Program Owner User.');

        System.assert(string.isBlank(account.MZR_Program_Owner__c), 
            string.format('MZR Program Owner should be blank {0}', new List<String> {account.MZR_Program_Owner__c}));
        System.assert(string.isBlank(account.MZR_Program_Owner_email__c), 
            string.format('MZR Program Owner Email should be blank {0}', 
                new List<String> {account.MZR_Program_Owner_email__c}));

        System.assert(string.isBlank(account.LE_Program_Owner__c), 
            string.format('LE Program Owner should be blank {0}', new List<String> {account.LE_Program_Owner__c}));
        System.assert(string.isBlank(account.LE_Program_Owner_email__c), 
            string.format('LE Program Owner Email should be blank {0}', 
                new List<String> {account.LE_Program_Owner_email__c}));
        System.assert(string.isBlank(account.LE_Program_Owner_User_Territory__c), 
            string.format('LE Program Owner User Territory should be blank {0}', 
                new List<String> {account.LE_Program_Owner_User_Territory__c}));
    }

    @isTest
    private static void setPrimaryProgramOwnerOnAccounts_SetMZROwner_Test() {
        User testUser = retrieveTestUsUser();

        ZTS_EU_Account_Position__c accountPosition = retrieveFirstAccountPositionForUser(testUser.Id);
        
        accountPosition.MZR_Program_Owner__c = 'Primary';

        Test.startTest();
            update accountPosition;
        Test.stopTest();

        Account account = retrieveUpdatedProgramOwnerAccount(accountPosition.ZTS_EU_Account__c);
        System.assertEquals(accountPosition.ZTS_EU_Employee__c, account.MZR_Program_Owner__c,
            'MZR Program Owner should be set.');
        System.assertEquals(testUser.Email, account.MZR_Program_Owner_email__c, 
            'MZR Program Owner email should be set to the email of the MZR Program Owner User.');

        System.assert(string.isBlank(account.VGP_Program_Owner__c), 
            string.format('VGP Program Owner should be blank {0}', new List<String> {account.VGP_Program_Owner__c}));
        System.assert(string.isBlank(account.VGP_Program_Owner_email__c), 
            string.format('VGP Program Owner Email should be blank {0}', 
                new List<String> {account.VGP_Program_Owner_email__c}));

        System.assert(string.isBlank(account.LE_Program_Owner__c), 
            string.format('LE Program Owner should be blank {0}', new List<String> {account.LE_Program_Owner__c}));
        System.assert(string.isBlank(account.LE_Program_Owner_email__c), 
            string.format('LE Program Owner Email should be blank {0}', 
                new List<String> {account.LE_Program_Owner_email__c}));
        System.assert(string.isBlank(account.LE_Program_Owner_User_Territory__c), 
            string.format('LE Program Owner User Territory should be blank {0}', 
                new List<String> {account.LE_Program_Owner_User_Territory__c}));
    }

    @isTest
    private static void setPrimaryProgramOwnerOnAccounts_SetLEOwner_Test() {
        User testUser = retrieveTestUsUser();

        ZTS_EU_Account_Position__c accountPosition = retrieveFirstAccountPositionForUser(testUser.Id);
        
        accountPosition.LE_Program_Owner__c = 'Primary';

        Test.startTest();
            update accountPosition;
        Test.stopTest();

        Account account = retrieveUpdatedProgramOwnerAccount(accountPosition.ZTS_EU_Account__c);
        System.assertEquals(accountPosition.ZTS_EU_Employee__c, account.LE_Program_Owner__c,
            'LE Program Owner should be set.');
        System.assertEquals(testUser.Email, account.LE_Program_Owner_email__c, 
            'LE Program Owner email should be set to the email of the LE Program Owner User.');
        System.assertEquals(accountPosition.ZTS_EU_Position__c, account.LE_Program_Owner_User_Territory__c,
            'LE Program Owner User Territory should be set to the Position Id of the Account Position');

        System.assert(string.isBlank(account.VGP_Program_Owner__c), 
            string.format('VGP Program Owner should be blank {0}', new List<String> {account.VGP_Program_Owner__c}));
        System.assert(string.isBlank(account.VGP_Program_Owner_email__c), 
            string.format('VGP Program Owner Email should be blank {0}', 
                new List<String> {account.VGP_Program_Owner_email__c}));

        System.assert(string.isBlank(account.MZR_Program_Owner__c), 
            string.format('MZR Program Owner should be blank {0}', new List<String> {account.MZR_Program_Owner__c}));
        System.assert(string.isBlank(account.MZR_Program_Owner_email__c), 
            string.format('MZR Program Owner Email should be blank {0}', 
                new List<String> {account.MZR_Program_Owner_email__c}));

        System.assert(string.isBlank(account.VGP_Program_Owner__c), 
            string.format('VGP Program Owner should be blank {0}', new List<String> {account.VGP_Program_Owner__c}));
        System.assert(string.isBlank(account.VGP_Program_Owner_email__c), 
            string.format('VGP Program Owner Email should be blank {0}', 
                new List<String> {account.VGP_Program_Owner_email__c}));
    }

    @isTest
    private static void setPrimaryProgramOwnerOnAccounts_SetAllOwner_Test() {
        User testUser = retrieveTestUsUser();

        ZTS_EU_Account_Position__c accountPosition = retrieveFirstAccountPositionForUser(testUser.Id);
        
        accountPosition.VGP_Program_Owner__c = 'Primary';
        accountPosition.MZR_Program_Owner__c = 'Primary';
        accountPosition.LE_Program_Owner__c = 'Primary';

        Test.startTest();
            update accountPosition;
        Test.stopTest();

        Account account = retrieveUpdatedProgramOwnerAccount(accountPosition.ZTS_EU_Account__c);
        System.assertEquals(accountPosition.ZTS_EU_Employee__c, account.VGP_Program_Owner__c,
            'VGP Program Owner should be set.');
        System.assertEquals(testUser.Email, account.VGP_Program_Owner_email__c, 
            'VGP Program Owner email should be set to the email of the VGP Program Owner User.');

        System.assertEquals(accountPosition.ZTS_EU_Employee__c, account.MZR_Program_Owner__c,
            'MZR Program Owner should be set.');
        System.assertEquals(testUser.Email, account.MZR_Program_Owner_email__c, 
            'MZR Program Owner email should be set to the email of the MZR Program Owner User.');

        System.assertEquals(accountPosition.ZTS_EU_Employee__c, account.LE_Program_Owner__c, 
            'LE Program Owner should be set.');
        System.assertEquals(testUser.Email, account.LE_Program_Owner_email__c, 
            'LE Program Owner email should be set to the email of the LE Program Owner User.');
        System.assertEquals(accountPosition.ZTS_EU_Position__c, account.LE_Program_Owner_User_Territory__c,
            'LE Program Owner User Territory should be set to the Position Id of the Account Position');
    }

    @isTest
    private static void setPrimaryProgramOwnerOnAccounts_SetNoOwner_Test() {
        User testUser = retrieveTestUsUser();

        ZTS_EU_Account_Position__c accountPosition = retrieveFirstAccountPositionForUser(testUser.Id);
        
        accountPosition.VGP_Program_Owner__c = 'Backup';
        accountPosition.MZR_Program_Owner__c = 'Backup';
        accountPosition.LE_Program_Owner__c = 'Backup';

        Test.startTest();
            update accountPosition;
        Test.stopTest();

        Account account = retrieveUpdatedProgramOwnerAccount(accountPosition.ZTS_EU_Account__c);
        System.assert(string.isBlank(account.VGP_Program_Owner__c), 
            string.format('VGP Program Owner should be blank {0}', new List<String> {account.VGP_Program_Owner__c}));
        System.assert(string.isBlank(account.VGP_Program_Owner_email__c), 
            string.format('VGP Program Owner Email should be blank {0}', 
                new List<String> {account.VGP_Program_Owner_email__c}));

        System.assert(string.isBlank(account.MZR_Program_Owner__c), 
            string.format('MZR Program Owner should be blank {0}', new List<String> {account.MZR_Program_Owner__c}));
        System.assert(string.isBlank(account.MZR_Program_Owner_email__c), 
            string.format('MZR Program Owner Email should be blank {0}', 
                new List<String> {account.MZR_Program_Owner_email__c}));

        System.assert(string.isBlank(account.LE_Program_Owner__c), 
            string.format('LE Program Owner should be blank {0}', new List<String> {account.LE_Program_Owner__c}));
        System.assert(string.isBlank(account.LE_Program_Owner_email__c), 
            string.format('LE Program Owner Email should be blank {0}', 
                new List<String> {account.LE_Program_Owner_email__c}));
        System.assert(string.isBlank(account.LE_Program_Owner_User_Territory__c), 
            string.format('LE Program Owner User Territory should be blank {0}', 
                new List<String> {account.LE_Program_Owner_User_Territory__c}));
    }

    @isTest
    private static void setPrimaryProgramOwnerOnAccounts_Multiple_Test() {
        List<User> testUsers = [SELECT Id, Email
                                FROM User
                                WHERE Username LIKE: string.format(testUserUSUserNameFormat, new List<Object> {'%'}) ];

        Account accountOne = null;
        Account accountTwo = null;
        List<Account> accounts = [
            SELECT Id, Name
            FROM Account
            WHERE Name in: new List<String> {firstUSAccountName, secondUSAccountName}];

        // Update accountOne using a single User
        // update accountTwo using three separate Users
        for (Account account : accounts) {
            if (account.Name == firstUSAccountName) {
                accountOne = account;
            }
            else if (account.Name == secondUSAccountName) {
                accountTwo = account;
            }
        }

        System.assertNotEquals(null, accountOne, 'Sanity Check Failed: Account One Not Found');
        System.assertNotEquals(null, accountTwo, 'Sanity Check Failed: Account Two Not Found');
        
        ZTS_EU_Account_Position__c accountOneAccountPosition = null;
        ZTS_EU_Account_Position__c accountTwoVGPOwner;
        ZTS_EU_Account_Position__c accountTwoMZROwner;
        ZTS_EU_Account_Position__c accountTwoLEOwner;
        integer accountTwoCounter = 0;

        List<ZTS_EU_Account_Position__c> accountPositions =  [
            SELECT Id, ZTS_EU_Account__c, ZTS_EU_Position__c, ZTS_EU_Employee__c, Employee_Email__c
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Position__r.ZTS_EU_Employee__c in: testUsers
            AND ZTS_EU_Account__c in: accounts];

        for (ZTS_EU_Account_Position__c accountPosition : accountPositions) {
            if (accountPosition.ZTS_EU_Account__c == accountOne.Id) {
                accountPosition.VGP_Program_Owner__c = 'Primary';
                accountPosition.MZR_Program_Owner__c = 'Primary';
                accountPosition.LE_Program_Owner__c = 'Primary';
                accountOneAccountPosition = accountPosition;
            }
            else if (accountPosition.ZTS_EU_Account__c == accountTwo.Id) {
                switch on accountTwoCounter++ {
                    when 0 {
                        accountPosition.VGP_Program_Owner__c = 'Primary';
                        accountTwoVGPOwner = accountPosition;
                    }
                    when 1 {
                        accountPosition.MZR_Program_Owner__c = 'Primary';
                        accountTwoMZROwner = accountPosition;
                    }
                    when 2 {
                        accountPosition.LE_Program_Owner__c = 'Primary';
                        accountTwoLEOwner = accountPosition;
                    }
                }
            }
        }

        System.assertNotEquals(null, accountOneAccountPosition,
            'Sanity check failed: An Account Position for Account One was not found.');

        System.assertEquals(3, accountTwoCounter,
            'Sanity check failed: 3 Account Positions should have been found for Account 2.');

        Test.startTest();
            update accountPositions;
        Test.stopTest();

        for (Account account : [SELECT Id, VGP_Program_Owner__c, VGP_Program_Owner_email__c, MZR_Program_Owner__c,
                                       MZR_Program_Owner_email__c, LE_Program_Owner__c, LE_Program_Owner_email__c,
                                       LE_Program_Owner_User_Territory__c
                                FROM Account
                                WHERE Id in: accounts]) {
            if (account.Id == accountOne.Id) {
                System.assertEquals(accountOneAccountPosition.ZTS_EU_Employee__c, account.VGP_Program_Owner__c,
                    'VGP Program Owner should be set.');
                System.assertEquals(accountOneAccountPosition.Employee_Email__c, account.VGP_Program_Owner_email__c, 
                    'VGP Program Owner email should be set to the email of the VGP Program Owner User.');

                System.assertEquals(accountOneAccountPosition.ZTS_EU_Employee__c, account.MZR_Program_Owner__c,
                    'MZR Program Owner should be set.');
                System.assertEquals(accountOneAccountPosition.Employee_Email__c, account.MZR_Program_Owner_email__c, 
                    'MZR Program Owner email should be set to the email of the MZR Program Owner User.');

                System.assertEquals(accountOneAccountPosition.ZTS_EU_Employee__c, account.LE_Program_Owner__c, 
                    'LE Program Owner should be set.');
                System.assertEquals(accountOneAccountPosition.Employee_Email__c, account.LE_Program_Owner_email__c, 
                    'LE Program Owner email should be set to the email of the LE Program Owner User.');
                System.assertEquals(accountOneAccountPosition.ZTS_EU_Position__c, account.LE_Program_Owner_User_Territory__c,
                    'LE Program Owner User Territory should be set to the Position Id of the Account Position');
            }
            else {
                System.assertEquals(accountTwoVGPOwner.ZTS_EU_Employee__c, account.VGP_Program_Owner__c,
                    'VGP Program Owner should be set.');
                System.assertEquals(accountTwoVGPOwner.Employee_Email__c, account.VGP_Program_Owner_email__c, 
                    'VGP Program Owner email should be set to the email of the VGP Program Owner User.');

                System.assertEquals(accountTwoMZROwner.ZTS_EU_Employee__c, account.MZR_Program_Owner__c,
                    'MZR Program Owner should be set.');
                System.assertEquals(accountTwoMZROwner.Employee_Email__c, account.MZR_Program_Owner_email__c, 
                    'MZR Program Owner email should be set to the email of the MZR Program Owner User.');

                System.assertEquals(accountTwoLEOwner.ZTS_EU_Employee__c, account.LE_Program_Owner__c, 
                    'LE Program Owner should be set.');
                System.assertEquals(accountTwoLEOwner.Employee_Email__c, account.LE_Program_Owner_email__c, 
                    'LE Program Owner email should be set to the email of the LE Program Owner User.');
                System.assertEquals(accountTwoLEOwner.ZTS_EU_Position__c, account.LE_Program_Owner_User_Territory__c,
                    'LE Program Owner User Territory should be set to the Position Id of the Account Position');
            }
        }
    }

    @isTest
    private static void setOnboardingCaseStatus_True_Test() {
        List<Account> accounts = new List<Account>();
        for (integer i = 0; i < 5; i++) {
            Account testAccount =TestDataFactory.createAccount_US(
                string.format('Test Onboarding Case Status {0}', new List<Object> {i}),
                false);

            testAccount.Onboarding_Case_Status__c = false;
            accounts.add(testAccount);
        }

        // Bypass the Account Trigger Handler to avoid limit errors
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert accounts;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        Test.startTest();
            AccountsService.setOnboardingCaseStatus(accounts, true);
        Test.stopTest();

        for (Account account : [SELECT Id, Onboarding_Case_Status__c
                                FROM Account
                                WHERE Id in: accounts]) {
            System.assertEquals(true, account.Onboarding_Case_Status__c, 'Onboarding_Case_Status__c should be true');
        }
    }

    @isTest
    private static void setOnboardingCaseStatus_False_Test() {
        List<Account> accounts = new List<Account>();
        for (integer i = 0; i < 5; i++) {
            Account testAccount =TestDataFactory.createAccount_US(
                string.format('Test Onboarding Case Status {0}', new List<Object> {i}),
                false);

            testAccount.Onboarding_Case_Status__c = true;
            accounts.add(testAccount);
        }

        // Bypass the Account Trigger Handler to avoid limit errors
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert accounts;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        Test.startTest();
            AccountsService.setOnboardingCaseStatus(accounts, false);
        Test.stopTest();

        for (Account account : [SELECT Id, Onboarding_Case_Status__c
                                FROM Account
                                WHERE Id in: accounts]) {
            System.assertEquals(false, account.Onboarding_Case_Status__c, 'Onboarding_Case_Status__c should be false');
        }
    }

    @isTest
    private static void setSendToDMRFlag_Insert_DoNotSendCreateUpdate_DMRIdPopulated() {
        Account testAccount = setupAccountForDMR();

        Test.startTest();
            insert testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Create__c, Send_to_DMR_Update__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(!updatedAccount.Send_to_DMR_Create__c,
            'Send to DMR Create should not be true as DMR Id is populated.');

        System.assert(!updatedAccount.Send_to_DMR_Update__c,
            'Send to DMR Update should not be true as this is running on insert.');
    }

    @isTest
    private static void setSendToDMRFlag_Insert_DoNotSendCreate_UnsupportedMarket() {
        Account testAccount = setupAccountForDMR(false);
        testAccount.ZTS_EU_Market__c = 'Ecuador'; 

        Test.startTest();
            insert testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Create__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(!updatedAccount.Send_to_DMR_Create__c, 
            'Send to DMR Create should not be true as the Market is not supported.');
    }

    @isTest
    private static void setSendToDMRFlag_Insert_DoNotSendCreate_Inactive() {
        Account testAccount = setupAccountForDMR(false);
        testAccount.ZTS_EU_Account_Status__c = 'Inactive';

        Test.startTest();
            insert testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Create__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(!updatedAccount.Send_to_DMR_Create__c, 
            'Send to DMR Create should not be true as the Account is inactive.');
    }

    @isTest
    private static void setSendToDMRFlag_Insert_DoNotSendCreate_IgnoredUser() {
        Account testAccount = setupAccountForDMR(false);

        // Exclude the current User from the Account DMR integration
        update new User(Id = UserInfo.getUserId(), Exclude_From_Integrations__c = 'Account DMR');

        Test.startTest();
            insert testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Create__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(!updatedAccount.Send_to_DMR_Create__c, 
            'Send to DMR Create should not be true as this User\'s records should be ignored.');
    }

    @isTest
    private static void setSendToDMRFlag_Insert_SendToDMRCreate() {
        Account testAccount = setupAccountForDMR(false);

        Test.startTest();
            insert testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Create__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(updatedAccount.Send_to_DMR_Create__c, 
            'Send to DMR Create should be true.');
    }

    @isTest
    private static void setSendToDMRFlag_Insert_SendAndDontSendToDMRCreateUpdate_MultipleRecords() {
        List<Account> sendToDMRAccounts = new List<Account> {
            setupAccountForDMR(false),
            setupAccountForDMR(false)
        };

        List<Account> doNotSendToDMRAccounts = new List<Account> {
            setupAccountForDMR(false),
            setupAccountForDMR(false),
            setupAccountForDMR(false),
            setupAccountForDMR(false),
            // This Account will not be sent to DMR as DMR Id is populated
            setupAccountForDMR(true)
        };

        // Set this Account to inactive, to not set the flag
        doNotSendToDMRAccounts[0].ZTS_EU_Account_Status__c = 'Inactive';
        // Set Direct Flag to true to not set the flag
        doNotSendToDMRAccounts[1].ZTS_EU_Direct_Flag__c = true;
        // Clear Country to stop the flag from setting
        doNotSendToDMRAccounts[2].ZTS_EU_Country__c = null;
        // Set Market to Ecuador to stop the flag from setting
        doNotSendToDMRAccounts[3].ZTS_EU_Market__c = 'Ecuador';

        List<Account> allAccounts = new List<Account>();
        allAccounts.addAll(sendToDMRAccounts);
        allAccounts.addAll(doNotSendToDMRAccounts);

        Test.startTest();
            insert allAccounts;
        Test.stopTest();

        Set<Id> sendToDMRAccountIds = new Map<Id, Account>(sendToDMRAccounts).keySet();
        for (Account account : [
            SELECT Id, Send_to_DMR_Create__c, Send_to_DMR_Update__c
            FROM Account
            WHERE Id in: allAccounts]) {
            if (sendToDMRAccountIds.contains(account.Id)) {
                System.assert(account.Send_to_DMR_Create__c, 'Send to DMR Create should be true for this Account.');
            }
            else {
                System.assert(!account.Send_to_DMR_Create__c, 'Send to DMR Create should be false for this Account.');
            }

            System.assert(!account.Send_to_DMR_Update__c,
                'Send to DMR Update should be false for this Account as this Account was only inserted');
        }
    }
    
    @isTest
    private static void setSendToDMRFlag_Update_SendCreateDoNotSendUpdate_DMRIdBlank() {
        Account testAccount = setupAccountForDMR();

        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        testAccount.DMR_ID__c = null;
        // Set Send to DMR Create to true to simulate the insert trigger running
        testAccount.Send_To_DMR_Create__c = true;
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        testAccount.Name = 'Update Account Name';

        Test.startTest();
            update testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_To_DMR_Create__c, Send_to_DMR_Update__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(updatedAccount.Send_To_DMR_Create__c,
            'Send to DMR Create should be true as DMR Id is blank and all other conditions are met.');

        System.assert(!updatedAccount.Send_to_DMR_Update__c,
            'Send to DMR Update should not be true as DMR Id is blank.');
    }

    @isTest
    private static void setSendToDMRFlag_Update_SendCreate_AccountMadeActive() {
        Account testAccount = setupAccountForDMR();

        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        testAccount.DMR_ID__c = null;
        testAccount.ZTS_EU_Account_Status__c = 'Inactive';
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        testAccount.ZTS_EU_Account_Status__c = 'Active';
        // Update Name too to confirm the Update Flag is not checked
        testAccount.Name = 'Updated Account Name';

        Test.startTest();
            update testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_To_DMR_Create__c, Send_to_DMR_Update__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(updatedAccount.Send_To_DMR_Create__c,
            'Send to DMR Create should be true as DMR Id is blank and all other conditions are met.');

        System.assert(!updatedAccount.Send_to_DMR_Update__c,
            'Send to DMR Update should not be true as Send to DMR Create is checked');
    }

    @isTest
    private static void setSendToDMRFlag_Update_SendCreate_AccountMarketChange() {
        Account testAccount = setupAccountForDMR();

        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        testAccount.DMR_ID__c = null;
        testAccount.ZTS_EU_Market__c = 'Ecuador';
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        testAccount.ZTS_EU_Market__c = 'United Kingdom';

        Test.startTest();
            update testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_To_DMR_Create__c, Send_to_DMR_Update__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(updatedAccount.Send_To_DMR_Create__c,
            'Send to DMR Create should be true as DMR Id is blank and all other conditions are met.');

        System.assert(!updatedAccount.Send_to_DMR_Update__c,
            'Send to DMR Update should not be true as DMR Id is blank.');
    }

    @isTest
    private static void setSendToDMRFlag_Update_DoNotSendUpdate_NoFieldsUpdated() {
        Account testAccount = setupAccountForDMR();

        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        Test.startTest();
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Update__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(!updatedAccount.Send_to_DMR_Update__c, 
            'Send to DMR Update should not be true as no fields changed');
    }

    @isTest
    private static void setSendToDMRFlag_Update_DoNotSendUpdate_UnsupportedMarket() {
        Account testAccount = setupAccountForDMR();

        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        testAccount.ZTS_EU_Market__c = 'Ecuador'; 
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        testAccount.Name = 'Update Account Name';
        Test.startTest();
            update testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Update__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(!updatedAccount.Send_to_DMR_Update__c,
            'Send to DMR Update should not be true as the Market is not supported');
    }

    @isTest
    private static void setSendToDMRFlag_Update_DoNotSendUpdate_IgnoredUser() {
        Account testAccount = setupAccountForDMR();

        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        // Exclude the current User from the Account DMR integration
        update new User(Id = UserInfo.getUserId(), Exclude_From_Integrations__c = 'Account DMR');

        testAccount.Name = 'Update Account Name';
        Test.startTest();
            update testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Update__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(!updatedAccount.Send_to_DMR_Update__c,
            'Send to DMR Update should not be true as this User\'s updates should be ignored');
    }

    @isTest
    private static void setSendToDMRFlag_Update_DoNotSendCreateUpdate_BlankDMRAndInactive() {
        Account testAccount = setupAccountForDMR(false);
        testAccount.ZTS_EU_Account_Status__c = 'Inactive';

        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        testAccount.Name = 'Update Account Name';
        Test.startTest();
            update testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Update__c, Send_To_DMR_Create__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(!updatedAccount.Send_to_DMR_Update__c,
            'Send to DMR Update should not be true as the Account is inactive.');

        System.assert(!updatedAccount.Send_To_DMR_Create__c,
            'Send to DMR Create should not be true as the Account is inactive.');
    }

    @isTest
    private static void setSendToDMRFlag_Update_SendToDMR() {
        Account testAccount = setupAccountForDMR();

        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        testAccount.Name = 'Update Account Name';
        Test.startTest();
            update testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Update__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(updatedAccount.Send_to_DMR_Update__c, 'Send to DMR Update should be true.');
    }

    @isTest
    private static void setSendToDMRFlag_Update_SendToDMR_BlankDMRId() {
        Account testAccount = setupAccountForDMR(false);

        // Create Account without running triggers to save on limits and stop the Create flag from being checked.
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        testAccount.Name = 'Update Account Name';
        Test.startTest();
            update testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Update__c, Send_to_DMR_Create__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(updatedAccount.Send_to_DMR_Update__c, 'Send to DMR Update should be true.');
        System.assert(!updatedAccount.Send_to_DMR_Create__c, 'Send to DMR Create should not be true.');
    }

    @isTest
    private static void setSendToDMRFlag_Update_UncheckCreateFlag() {
        Account testAccount = setupAccountForDMR(false);
        testAccount.Send_to_DMR_Create__c = true;
        
        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        // Setting Account Status to inactive will uncheck the Create flag on this Account
        testAccount.ZTS_EU_Account_Status__c = 'Inactive';

        Test.startTest();
            update testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Create__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(!updatedAccount.Send_to_DMR_Create__c, 
            'Send to DMR Create should be false as the Account is inactive.');
    }

    @isTest
    private static void setSendToDMRFlag_Update_UncheckUpdateFlag() {
        Account testAccount = setupAccountForDMR();
        testAccount.Send_to_DMR_Update__c = true;
        
        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        // Setting the Direct Flag to true will uncheck the Update flag on this Account
        testAccount.ZTS_EU_Direct_Flag__c = true;

        Test.startTest();
            update testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Update__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(!updatedAccount.Send_to_DMR_Update__c, 
            'Send to DMR Update should be false as the Account is not indirect.');
    }

    // This test verifies that Send to DMR Create can be unchecked manually and it will not be checked again immmediately
    @isTest
    private static void setSendToDMRFlag_Update_UncheckSendToDMRCreate() {
        Account testAccount = setupAccountForDMR(false);

        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        // Set Send to DMR Create to true to simulate the insert trigger
        testAccount.Send_to_DMR_Create__c = true;
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
         
        // Perform a sanity check to make sure Send to DMR Create is not unchecked automatically
        testAccount = [
            SELECT Id, Send_to_DMR_Create__c
            FROM Account
            WHERE Id =: testAccount.Id
            LIMIT 1];
            
        System.assert(testAccount.Send_to_DMR_Create__c, 
            'Sanity check failed. Send to DMR Create should still be true.');

        testAccount.Send_to_DMR_Create__c = false;

        Test.startTest();
            update testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Create__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(!updatedAccount.Send_to_DMR_Create__c, 
            'Send to DMR Create should be false as it was manually unchecked.');
    }

    // This test verifies that Send to DMR Create can be unchecked manually and it will not be checked again immmediately
    @isTest
    private static void setSendToDMRFlag_Update_UncheckSendToDMRUpdate() {
        Account testAccount = setupAccountForDMR(true);

        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        // Set Send to DMR Create to true to simulate the Account already being flagged for update
        testAccount.Send_to_DMR_Update__c = true;
        insert testAccount;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        // Perform a sanity check to make sure Send to DMR Update is not unchecked automatically
        testAccount = [
            SELECT Id, Send_to_DMR_Update__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(testAccount.Send_to_DMR_Update__c,
            'Sanity check failed, Send to DMR Update was unchecked automatically.');

        testAccount.Send_to_DMR_Update__c = false;
 
        Test.startTest();
            update testAccount;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Id, Send_to_DMR_Update__c
            FROM Account
            WHERE Id =: testAccount.Id];

        System.assert(!updatedAccount.Send_to_DMR_Update__c, 
            'Send to DMR Update should be false as it was manually unchecked.');
    }

    @isTest
    private static void setSendToDMRFlag_Update_SendAndDontSendCreateUpdateToDMR_MultipleRecords() {
        // This Account should still be sent for updates even without a DMR Id
        Account noDMRIdAccountSendUpdate = setupAccountForDMR(false);
        
        List<Account> sendToDMRAccounts = new List<Account> {
            setupAccountForDMR(),
            setupAccountForDMR(),
            noDMRIdAccountSendUpdate
        };

        // Set this Account to inactive, it should still sync
        sendToDMRAccounts[1].ZTS_EU_Account_Status__c = 'Inactive';

        // Set the name of the Account so it's not identical to the other Account without a DMR Id.
        // This will prevent it from getting set to Inactive below.
        sendToDMRAccounts[2].Name = 'No DMR Send Account';

        // DMR Id will not be set on this Account, the Update flag will still be checked
        Account noDMRIdAccount = setupAccountForDMR(false);

        List<Account> doNotSendToDMRAccounts = new List<Account> {
            noDMRIdAccount,
            setupAccountForDMR(),
            setupAccountForDMR(),
            setupAccountForDMR()
        };

        // Set Direct Flag to true to not set the flag
        doNotSendToDMRAccounts[1].ZTS_EU_Direct_Flag__c = true;
        // Clear Country to stop the flag from setting
        doNotSendToDMRAccounts[2].ZTS_EU_Country__c = null;
        // Set Market to Ecuador to stop the flag from setting
        doNotSendToDMRAccounts[3].ZTS_EU_Market__c = 'Ecuador';

        List<Account> allAccounts = new List<Account>();
        allAccounts.addAll(sendToDMRAccounts);
        allAccounts.addAll(doNotSendToDMRAccounts);
        
        for (integer i = 0; i < allAccounts.size(); i++) {
            if (String.isNotBlank(allAccounts[i].DMR_Id__c)) {
                allAccounts[i].DMR_Id__c = String.format('AC_Test{0}', new List<Object> {i});
            }

            // Set The Send TO DMR Flags to true to verify they get unchecked for these Accounts
            if (doNotSendToDMRAccounts.contains(allAccounts[i])) {

                // The Account with DMR Id blank is changed to inactive so that Send_to_DMR_Create__c can be set to 
                // true automatically
                if (String.isNotBlank(allAccounts[i].DMR_Id__c)) {
                    allAccounts[i].Send_to_DMR_Update__c = true;
                    allAccounts[i].Send_to_DMR_Create__c = true;
                }
                else {
                    allAccounts[i].ZTS_EU_Account_Status__c = 'Inactive';
                }
            }
        }

        // Create Account without running triggers to save on limits
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert allAccounts;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        for (Account testAccount : allAccounts) {
            testAccount.Name = 'Update Account Test';
        }

        // Set the new Account to Active to trigger Send to Create setting to true
        noDMRIdAccount.ZTS_EU_Account_Status__c = 'Active';

        Test.startTest();
            update allAccounts;
        Test.stopTest();

        Set<Id> sendToDMRAccountIds = new Map<Id, Account>(sendToDMRAccounts).keySet();
        for (Account account : [
            SELECT Id, Send_to_DMR_Update__c, Send_to_DMR_Create__c, DMR_Id__c
            FROM Account
            WHERE Id in: allAccounts]) {
            if (sendToDMRAccountIds.contains(account.Id)) {
                System.assert(account.Send_To_DMR_Update__c, 'Send to DMR Update should be true for this Account.');
            }
            else {
                System.assert(!account.Send_To_DMR_Update__c, 'Send to DMR Update should be false for this Account.');
            }

            if (String.isNotBlank(account.DMR_Id__c) || account.Id == noDMRIdAccountSendUpdate.Id ) {
                System.assert(!account.Send_To_DMR_Create__c, 'Send to DMR Create should be false for this Account.');
            }
            else {
                System.assert(account.Send_To_DMR_Create__c,
                    'Send to DMR Create should be true for this Account as DMR Id is blank and all other criteria is met.');
            }
        }
    }

    private static void mergeRelatedDataInternational_NoRelatedData_Test() {
        // Setup new Accounts that will not have any related records
        Account noDataAccount1 = TestDataFactory.createAccount_EU('No Data 1', null, false);
        Account noDataAccount2 = TestDataFactory.createAccount_EU('No Data 2', null, false);

        // Disable the Account Trigger to avoid hitting limits and since the logic is not needed
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert new List<Account> {noDataAccount1, noDataAccount2};
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        Exception error = null;
        Test.startTest();
            try {
                merge noDataAccount1 noDataAccount2;
            }
            catch (Exception ex) {
                error = ex;
            }
        Test.stopTest();

        System.assertEquals(null, error, String.format('An unexpected error occurred {0}',
            new List<String> {error?.getMessage()}));

        assertNoMergeErrors();
    }

    @isTest
    private static void mergeRelatedDataInternational_MergeTwoAccounts_Test() {
        Account masterAccount;
        Account mergeAccount;
        Map<Id, Account> accountsMap = new Map<Id, Account>();

        for (Account account : [
            SELECT Id, Name
            FROM Account
            WHERE Name in: new List<String> {firstMergeAccountName, secondMergeAccountName}
        ]) {
            if (account.Name == firstMergeAccountName) {
                masterAccount = account;
            }
            else {
                mergeAccount = account;
            }
            accountsMap.put(account.Id, account);
        }

        preMergeIntlAccountSanityCheck(accountsMap);

        Test.startTest();
            merge masterAccount mergeAccount;
        Test.stopTest();
        
        assertNoMergeErrors();

        assertIntlAccountMerge(accountsMap.keySet(), masterAccount);
    }

    @isTest
    private static void mergeRelatedDataInternational_MergeThreeAccounts_Test() {
        Account masterAccount;
        List<Account> mergeAccounts = new List<Account>();
        Map<Id, Account> accountsMap = new Map<Id, Account>();

        for (Account account : [
            SELECT Id, Name
            FROM Account
            WHERE Name in: new List<String> {firstMergeAccountName, secondMergeAccountName, thirdMergeAccountName}
        ]) {
            if (account.Name == firstMergeAccountName) {
                masterAccount = account;
            }
            else {
                mergeAccounts.add(account);
            }
            accountsMap.put(account.Id, account);
        }

        preMergeIntlAccountSanityCheck(accountsMap);

        Test.startTest();
            Database.merge(masterAccount, mergeAccounts);
        Test.stopTest();
        
        assertNoMergeErrors();

        assertIntlAccountMerge(accountsMap.keySet(), masterAccount);
    }

    // This test forces an error which will roll back the save.
    @isTest
    private static void mergeRelatedDataInternational_MergeTwoAccounts_Rollback_Test() {
        Account masterAccount;
        Account mergeAccount;
        Map<Id, Account> accountsMap = new Map<Id, Account>();
        for (Account account : [
            SELECT Id, Name
            FROM Account
            WHERE Name in: new List<String> {firstMergeAccountName, secondMergeAccountName}
        ]) {
            if (account.Name == firstMergeAccountName) {
                masterAccount = account;
            }
            else {
                mergeAccount = account;
            }
            accountsMap.put(account.Id, account);
        }

        preMergeIntlAccountSanityCheck(accountsMap);

        AccountsService.forceMergeIntlRollbackError = true;
        Test.startTest();
            merge masterAccount mergeAccount;
        Test.stopTest();
        AccountsService.forceMergeIntlRollbackError = false;
        
        List<ZTS_EU_Error_Log__c> errorLogs = [
            SELECT Id, ZTS_EU_Message__c, ZTS_EU_Origin_Type__c
            FROM ZTS_EU_Error_Log__c
            WHERE ZTS_EU_Origin_Type__c =: AccountsService.accountMergeLogType
            LIMIT 1];

        System.assert(!errorLogs.isEmpty(), 'At least one merge error should have occurred');

        Set<Id> accountIds = accountsMap.keySet();

        integer accountPositionCount = 0;
        integer eccCount = 0;
        Set<Id> relatedAccountTerritoryIds = new Set<Id>();
        for (ZTS_EU_Account_Position__c accountPosition : [
            SELECT Id, ZTS_EU_Account__c, ZTS_AccountTerritory__c, ZTS_EU_Position__c,
                (SELECT Id FROM Employee_Call_Credits__r)
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ]) {
            accountPositionCount++;
            
            System.assertEquals(masterAccount.Id, accountPosition.ZTS_EU_Account__c, 
                'Account Position was not transfered as expected');

            eccCount += accountPosition.Employee_Call_Credits__r.size();

            System.assertNotEquals(null, accountPosition.ZTS_AccountTerritory__c, 
                'Account Territory should not be cleared out on the Account Position.');
            
            relatedAccountTerritoryIds.add(accountPosition.ZTS_AccountTerritory__c);
        }

        System.assertEquals(1, eccCount, 'Expected to find 1 ECC after merge.');
        System.assertEquals(4, accountPositionCount, 'Expected to find 4 Account Positions after merge.');

        integer accountTerritoryCount = 0;
        for (ZTS_AccountTerritory__c accountTerritory : [
            SELECT Id, ZTS_EU_Account__c, ZTS_EU_Territory__c
            FROM ZTS_AccountTerritory__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ]) {
            accountTerritoryCount++;
            
            System.assertEquals(masterAccount.Id, accountTerritory.ZTS_EU_Account__c, 
                'Account Territory was not transfered as expected');

            // Remove values from this set to confirm that none remain.
            // This will allow for an assertion that Account Positions were transfered to the correct Account Territory.
            relatedAccountTerritoryIds.remove(accountTerritory.Id);
        }

        System.assert(relatedAccountTerritoryIds.isEmpty(), String.format(
            'Account Positions were related to unexpected Territories: {0}',
            new List<Object> {relatedAccountTerritoryIds}));

        System.assertEquals(4, accountTerritoryCount, 'Expected to find 4 Account Territories after merge.');

        integer addressCount = 0;
        integer orderCount = 0;
        Boolean foundPrimaryKey = false;
        for (Address__c address : [
            SELECT Id, ZTS_EU_Account__c, ZTS_GL_Unique_Primary_Address_Key__c, ZTS_EU_Address_Type__c,
                (SELECT ID FROM Orders1__r)
            FROM Address__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ]) {
            addressCount++;
            
            System.assertEquals(masterAccount.Id, address.ZTS_EU_Account__c, 
                'Address was not transfered as expected');

            orderCount += address.Orders1__r.size();

            if (String.isNotBlank(address.ZTS_GL_Unique_Primary_Address_Key__c)) {
                foundPrimaryKey = true;
                System.assertNotEquals(String.format('{0}True', new List<Object> {address.ZTS_EU_Account__c}),
                    address.ZTS_GL_Unique_Primary_Address_Key__c,
                    'ZTS_GL_Unique_Primary_Address_Key__c was updated unexpectedly.');
            }
        }

        System.assertEquals(1, orderCount, 'Expected to find 1 ECC after merge.');
        // 6 Addresses expected are:
        // 1. The duplicate Address setup in Test Setup. This will not get merged and result in 2 records
        // 2. An address created automatically when creating an Account. This will not get merged and result in 2 records
        // 3. The unique Address setup on Account 1
        // 4. The unique Address setup on Account 2
        System.assertEquals(6, addressCount, 'Expected to find 6 Addresses after merge.');
        System.assert(foundPrimaryKey, 'At least one Address did not have ZTS_GL_Unique_Primary_Address_Key__c populated');
    }

    @isTest
    private static void mergeRelatedDataInternational_MergeTwoAccounts_UpdateError_Test() {
        Account masterAccount;
        Account mergeAccount;
        Map<Id, Account> accountsMap = new Map<Id, Account>();

        for (Account account : [
            SELECT Id, Name
            FROM Account
            WHERE Name in: new List<String> {firstMergeAccountName, secondMergeAccountName}
        ]) {
            if (account.Name == firstMergeAccountName) {
                masterAccount = account;
            }
            else {
                mergeAccount = account;
            }
            accountsMap.put(account.Id, account);
        }

        preMergeIntlAccountSanityCheck(accountsMap);

        // Deletions will occur with this flag, but updates will not.
        AccountsService.forceMergeIntlUpdateError = true;
        Test.startTest();
            merge masterAccount mergeAccount;
        Test.stopTest();
        AccountsService.forceMergeIntlUpdateError = false;
        
        List<ZTS_EU_Error_Log__c> errorLogs = [
            SELECT Id, ZTS_EU_Message__c, ZTS_EU_Origin_Type__c
            FROM ZTS_EU_Error_Log__c
            WHERE ZTS_EU_Origin_Type__c =: AccountsService.accountMergeLogType
            LIMIT 1];

        System.assert(!errorLogs.isEmpty(), 'At least one merge error should have occurred');

        Set<Id> accountIds = accountsMap.keySet();
        // As it'd be a race condition to verify which records are removed, the only update logic checked is on Address
        Set<Id> foundPositionIds = new Set<Id>();
        integer accountPositionCount = 0;
        integer eccCount = 0;
        Set<Id> relatedAccountTerritoryIds = new Set<Id>();
        for (ZTS_EU_Account_Position__c accountPosition : [
            SELECT Id, ZTS_EU_Account__c, ZTS_EU_Position__c
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ]) {
            accountPositionCount++;
            
            System.assertEquals(masterAccount.Id, accountPosition.ZTS_EU_Account__c, 
                'Account Position was not transfered as expected');
            
            Id positionId = accountPosition.ZTS_EU_Position__c;
            System.assert(!foundPositionIds.contains(positionId), 
                String.format('Position {0} was found multiple times after merge.',
                    new List<Object> {positionId}));

            foundPositionIds.add(positionId);
        }

        System.assertEquals(3, accountPositionCount, 'Expected to find 3 Account Positions after merge.');

        Set<Id> foundTerritoryIds = new Set<Id>();
        integer accountTerritoryCount = 0;
        for (ZTS_AccountTerritory__c accountTerritory : [
            SELECT Id, ZTS_EU_Account__c, ZTS_EU_Territory__c
            FROM ZTS_AccountTerritory__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ]) {
            accountTerritoryCount++;
            
            System.assertEquals(masterAccount.Id, accountTerritory.ZTS_EU_Account__c, 
                'Account Territory was not transfered as expected');
            
            Id territoryId = accountTerritory.ZTS_EU_Territory__c;
            System.assert(!foundTerritoryIds.contains(territoryId), 
                String.format('Territory {0} was found multiple times after merge.',
                    new List<Object> {territoryId}));

            foundTerritoryIds.add(territoryId);
        }
        
        System.assertEquals(3, accountTerritoryCount, 'Expected to find 3 Account Territories after merge.');

        Set<String> foundTypes = new Set<String>();
        integer addressCount = 0;
        integer orderCount = 0;
        Boolean foundPrimaryKey = false;
        for (Address__c address : [
            SELECT Id, ZTS_EU_Account__c, ZTS_GL_Unique_Primary_Address_Key__c, ZTS_EU_Address_Type__c
            FROM Address__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ]) {
            addressCount++;
            
            System.assertEquals(masterAccount.Id, address.ZTS_EU_Account__c, 
                'Address was not transfered as expected');
            
            String type = address.ZTS_EU_Address_Type__c;
            System.assert(!foundTypes.contains(type), String.format('Type {0} was found multiple times after merge.',
                new List<Object> {type}));

            foundTypes.add(type);

            if (String.isNotBlank(address.ZTS_GL_Unique_Primary_Address_Key__c)) {
                foundPrimaryKey = true;
                System.assertNotEquals(String.format('{0}True', new List<Object> {address.ZTS_EU_Account__c}),
                address.ZTS_GL_Unique_Primary_Address_Key__c,
                'ZTS_GL_Unique_Primary_Address_Key__c was updated unexpectedly.');
            }
        }
        // 4 Addresses expected are:
        // 1. The duplicate Address setup in Test Seutp that gets merged to a single record
        // 2. An address created automatically when creating an Account. This will get merged
        // 3. The unique Address setup on Account 1
        // 4. The unique Address setup on Account 2
        System.assertEquals(4, addressCount, 'Expected to find 4 Addresses after merge.');
        System.assert(foundPrimaryKey, 'At least one Address did not have ZTS_GL_Unique_Primary_Address_Key__c populated');
    }

    @isTest
    private static void mergeRelatedDataInternational_MergeTwoAccounts_DeleteError_Test() {
        Account masterAccount;
        Account mergeAccount;
        Map<Id, Account> accountsMap = new Map<Id, Account>();

        for (Account account : [
            SELECT Id, Name
            FROM Account
            WHERE Name in: new List<String> {firstMergeAccountName, secondMergeAccountName}
        ]) {
            if (account.Name == firstMergeAccountName) {
                masterAccount = account;
            }
            else {
                mergeAccount = account;
            }
            accountsMap.put(account.Id, account);
        }

        preMergeIntlAccountSanityCheck(accountsMap);

        // Updates will occur with this flag, but delete will not.
        AccountsService.forceMergeIntlDeleteError = true;
        Test.startTest();
            merge masterAccount mergeAccount;
        Test.stopTest();
        AccountsService.forceMergeIntlDeleteError = false;

        Set<Id> accountIds = accountsMap.keySet();
        
        List<ZTS_EU_Error_Log__c> errorLogs = [
            SELECT Id, ZTS_EU_Message__c, ZTS_EU_Origin_Type__c
            FROM ZTS_EU_Error_Log__c
            WHERE ZTS_EU_Origin_Type__c =: AccountsService.accountMergeLogType
            LIMIT 1];

        System.assert(!errorLogs.isEmpty(), 'At least one merge error should have occurred');

        integer accountPositionCount = 0;
        integer eccCount = 0;
        for (ZTS_EU_Account_Position__c accountPosition : [
            SELECT Id, ZTS_EU_Account__c, ZTS_AccountTerritory__c, ZTS_EU_Position__c,
                (SELECT Id FROM Employee_Call_Credits__r)
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ]) {
            accountPositionCount++;
            
            System.assertEquals(masterAccount.Id, accountPosition.ZTS_EU_Account__c, 
                'Account Position was not transfered as expected');

            eccCount += accountPosition.Employee_Call_Credits__r.size();

            System.assertNotEquals(null, accountPosition.ZTS_AccountTerritory__c, 
                'Account Territory should not be cleared out on the Account Position.');
        }

        System.assertEquals(1, eccCount, 'Expected to find 1 ECC after merge.');
        System.assertEquals(4, accountPositionCount, 'Expected to find 4 Account Positions after merge.');

        // Due to not all Account Position being deleted, Account Position's Territory field updates are not tested

        integer accountTerritoryCount = 0;
        for (ZTS_AccountTerritory__c accountTerritory : [
            SELECT Id, ZTS_EU_Account__c, ZTS_EU_Territory__c
            FROM ZTS_AccountTerritory__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ]) {
            accountTerritoryCount++;
            
            System.assertEquals(masterAccount.Id, accountTerritory.ZTS_EU_Account__c, 
                'Account Territory was not transfered as expected');
        }
        
        System.assertEquals(4, accountTerritoryCount, 'Expected to find 4 Account Territories after merge.');

        integer addressCount = 0;
        integer orderCount = 0;
        Boolean foundPrimaryKey = false;
        for (Address__c address : [
            SELECT Id, ZTS_EU_Account__c, ZTS_GL_Unique_Primary_Address_Key__c, ZTS_EU_Address_Type__c,
                (SELECT ID FROM Orders1__r)
            FROM Address__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ]) {
            addressCount++;
            
            System.assertEquals(masterAccount.Id, address.ZTS_EU_Account__c, 
                'Address was not transfered as expected');

            orderCount += address.Orders1__r.size();

            if (String.isNotBlank(address.ZTS_GL_Unique_Primary_Address_Key__c)) {
                foundPrimaryKey = true;
                System.assertEquals(String.format('{0}True', new List<Object> {address.ZTS_EU_Account__c}),
                    address.ZTS_GL_Unique_Primary_Address_Key__c,
                    'ZTS_GL_Unique_Primary_Address_Key__c was not updated.');
            }
        }

        System.assertEquals(1, orderCount, 'Expected to find 1 ECC after merge.');
        // 6 Addresses expected are:
        // 1. The duplicate Address setup in Test Setup. This will not get merged and result in 2 records
        // 2. An address created automatically when creating an Account. This will not get merged and result in 2 records
        // 3. The unique Address setup on Account 1
        // 4. The unique Address setup on Account 2
        System.assertEquals(6, addressCount, 'Expected to find 6 Addresses after merge.');
        System.assert(foundPrimaryKey, 'At least one Address did not have ZTS_GL_Unique_Primary_Address_Key__c populated');
    }

    private static User retrieveTestUsUser() {
        return [
            SELECT Id, Email
            FROM User
            WHERE Username =: string.format(testUserUSUserNameFormat, new List<Object> {0})
            LIMIT 1];
    }

    private static ZTS_EU_Account_Position__c retrieveFirstAccountPositionForUser(Id userId) {
        return [
            SELECT Id, ZTS_EU_Account__c, ZTS_EU_Position__c, ZTS_EU_Employee__c
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Position__r.ZTS_EU_Employee__c =: userId
            AND ZTS_EU_Account__r.Name =: firstUSAccountName
            LIMIT 1];
    }

    private static Account retrieveUpdatedProgramOwnerAccount(Id accountId) {
        return [
            SELECT Id, VGP_Program_Owner__c, VGP_Program_Owner_email__c, MZR_Program_Owner__c,
                  MZR_Program_Owner_email__c, LE_Program_Owner__c, LE_Program_Owner_email__c,
                  LE_Program_Owner_User_Territory__c
            FROM Account
            WHERE Id =: accountId
        ];
    }

    private static Account setupAccountForDMR() {
        return setupAccountForDMR(true);
    }

    private static Account setupAccountForDMR(Boolean setDmrId) {
        Account testAccount = TestDataFactory.createAccount_EU(null, false);
        testAccount.ZTS_EU_Direct_Flag__c = false;
        testAccount.ZTS_EU_Account_Status__c = 'Active';

        if (setDmrId) {
            testAccount.DMR_Id__c = 'ACTest_1';
        }

        return testAccount;
    }
    
    private static Map<Id, List<SObject>> organizeRecordsByAccountId(List<SObject> records, string accountField) {
        Map<Id, List<SObject>> recordsByAccountId = new Map<Id, List<SObject>>();
        for (SObject record : records) {
            Id accountId = (Id)record.get(accountField);
            if (!recordsByAccountId.containsKey(accountId)) {
                recordsByAccountId.put(accountId, new List<SObject>());
            }

            recordsByAccountId.get(accountId).add(record);
        }

        return recordsByAccountId;
    }

    private static void assertNoMergeErrors() {
        List<ZTS_EU_Error_Log__c> errorLogs = [
            SELECT Id, ZTS_EU_Message__c, ZTS_EU_Origin_Type__c
            FROM ZTS_EU_Error_Log__c
            WHERE ZTS_EU_Origin_Type__c =: AccountsService.accountMergeLogType
            LIMIT 1];

        System.assert(errorLogs.isEmpty(), String.format('An unexpected error occurred on merge: {0}',
            new List<Object> {errorLogs}));
    }

    private static final integer maxRecordsPerAccount = 2;
    // Asserts that data exists properly before running a merge of Intl Accounts
    private static void preMergeIntlAccountSanityCheck(Map<Id, Account> accountsMap) {
        Set<Id> accountIds = accountsMap.keySet();

        List<ZTS_EU_Account_Position__c> preMergeAccountPositions = [
            SELECT Id, ZTS_EU_Account__c
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ];

        Map<Id, List<ZTS_EU_Account_Position__c>> accountPositionsByAccount = organizeRecordsByAccountId(
            preMergeAccountPositions, 'ZTS_EU_Account__c');
        
        for (Id accountId : accountIds) {
            assertRecordsByAccountCount(accountsMap, accountPositionsByAccount, 'Account Position');
        }

        List<ZTS_AccountTerritory__c> preMergeAccountTerritories = [
            SELECT Id, ZTS_EU_Account__c
            FROM ZTS_AccountTerritory__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ];

        Map<Id, List<ZTS_AccountTerritory__c>> accountTerritoriesByAccountId = organizeRecordsByAccountId(
            preMergeAccountTerritories, 'ZTS_EU_Account__c');

        for (Id accountId : accountIds) {
            assertRecordsByAccountCount(accountsMap, accountTerritoriesByAccountId, 'Account Territory');
        }

        List<Address__c> preMergeAddresses = [
            SELECT Id, ZTS_EU_Account__c
            FROM Address__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ];

        Map<Id, List<Address__c>> addresssesByAccountId = organizeRecordsByAccountId(preMergeAddresses,
            'ZTS_EU_Account__c');
        
        for (Id accountId : accountIds) {
            assertRecordsByAccountCount(accountsMap, addresssesByAccountId, 'Address', 3);
        }

        List<ObjectTerritory2Association> territoryAssociations = [SELECT Id, Objectid
                                                                   FROM ObjectTerritory2Association 
                                                                   WHERE ObjectId IN: accountIds];

                        
        Map<Id, List<ObjectTerritory2Association>> territoryAssociationsByAccountId = organizeRecordsByAccountId(
            territoryAssociations, 'ObjectId');
        
        for (Id accountId : accountIds) {
            assertRecordsByAccountCount(accountsMap, territoryAssociationsByAccountId, 'Assigned Territory');
        }
    }

    private static void assertRecordsByAccountCount(Map<Id, Account> accountsMap, Map<Id, List<SObject>> recordsByAccountId, String objectName) {
        assertRecordsByAccountCount(accountsMap, recordsByAccountId, objectName, maxRecordsPerAccount);
    }

    private static void assertRecordsByAccountCount(Map<Id, Account> accountsMap, Map<Id, List<SObject>> recordsByAccountId, String objectName, 
        integer expectedRecordsCount) {
        for (Id accountId : accountsMap.keySet()) {
            if (accountsMap.get(accountId).Name == thirdMergeAccountName) {
                // The 3rd Account will have one less record present
                expectedRecordsCount = expectedRecordsCount - 1;
            }

            System.assertEquals(expectedRecordsCount, recordsByAccountId.get(accountId).size(), String.format(
                'Sanity check failed. Each Account should have {0} {1}(s)',
                new List<Object> {expectedRecordsCount, objectName}));
        }
    }

    // The assertion of Intl Account merges is repeated across Unit Tests, so it's kept in a helper method.
    private static void assertIntlAccountMerge(Set<Id> accountIds, Account masterAccount) {
        Set<Id> foundPositionIds = new Set<Id>();
        integer accountPositionCount = 0;
        integer eccCount = 0;
        Set<Id> relatedAccountTerritoryIds = new Set<Id>();

        for (ZTS_EU_Account_Position__c accountPosition : [
            SELECT Id, ZTS_EU_Account__c, ZTS_AccountTerritory__c, ZTS_EU_Position__c,
                (SELECT Id FROM Employee_Call_Credits__r)
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ]) {
            accountPositionCount++;
            
            System.assertEquals(masterAccount.Id, accountPosition.ZTS_EU_Account__c, 
                'Account Position was not transfered as expected');
            
            Id positionId = accountPosition.ZTS_EU_Position__c;
            System.assert(!foundPositionIds.contains(positionId), String.format(
                'Position {0} was found multiple times after merge.',
                    new List<Object> {positionId}));

            foundPositionIds.add(positionId);

            eccCount += accountPosition.Employee_Call_Credits__r.size();

            System.assertNotEquals(null, accountPosition.ZTS_AccountTerritory__c, 
                'Account Territory should not be cleared out on the Account Position.');
            
            relatedAccountTerritoryIds.add(accountPosition.ZTS_AccountTerritory__c);
        }

        System.assertEquals(1, eccCount, 'Expected to find 1 ECC after merge.');
        System.assertEquals(3, accountPositionCount, 'Expected to find 3 Account Positions after merge.');

        Set<Id> foundTerritoryIds = new Set<Id>();
        Set<Id> foundATNativeTerritoryIds = new Set<Id>();
        integer accountTerritoryCount = 0;
        for (ZTS_AccountTerritory__c accountTerritory : [
            SELECT Id, ZTS_EU_Account__c, ZTS_EU_Territory__c, ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c
            FROM ZTS_AccountTerritory__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ]) {
            accountTerritoryCount++;
            
            System.assertEquals(masterAccount.Id, accountTerritory.ZTS_EU_Account__c, 
                'Account Territory was not transfered as expected');
            
            Id territoryId = accountTerritory.ZTS_EU_Territory__c;
            System.assert(!foundTerritoryIds.contains(territoryId), 
                String.format('Territory {0} was found multiple times after merge.',
                    new List<Object> {territoryId}));

            foundTerritoryIds.add(territoryId);
            // Remove values from this set to confirm that none remain.
            // This will allow for an assertion that Account Positions were transfered to the correct Account Territory.
            relatedAccountTerritoryIds.remove(accountTerritory.Id);
            foundATNativeTerritoryIds.add(accountTerritory.ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c);
        }

        System.assert(relatedAccountTerritoryIds.isEmpty(), String.format(
            'Account Positions were related to unexpected Territories: {0}',
            new List<Object> {relatedAccountTerritoryIds}));

        System.assertEquals(3, accountTerritoryCount, 'Expected to find 3 Account Territories after merge.');

        Set<String> foundTypes = new Set<String>();
        integer addressCount = 0;
        integer orderCount = 0;
        Boolean foundPrimaryKey = false;
        for (Address__c address : [
            SELECT Id, ZTS_EU_Account__c, ZTS_GL_Unique_Primary_Address_Key__c, ZTS_EU_Address_Type__c,
                (SELECT ID FROM Orders1__r)
            FROM Address__c
            WHERE ZTS_EU_Account__c IN: accountIds
        ]) {
            addressCount++;
            
            System.assertEquals(masterAccount.Id, address.ZTS_EU_Account__c, 
                'Address was not transfered as expected');
            
            String type = address.ZTS_EU_Address_Type__c;
            System.assert(!foundTypes.contains(type), String.format('Type {0} was found multiple times after merge.',
                new List<Object> {type}));

            foundTypes.add(type);

            orderCount += address.Orders1__r.size();

            if (String.isNotBlank(address.ZTS_GL_Unique_Primary_Address_Key__c)) {
                foundPrimaryKey = true;
                System.assertEquals(String.format('{0}True', new List<Object> {address.ZTS_EU_Account__c}),
                    address.ZTS_GL_Unique_Primary_Address_Key__c,
                    'ZTS_GL_Unique_Primary_Address_Key__c was not updated as expected.');
            }
        }

        System.assertEquals(1, orderCount, 'Expected to find 1 ECC after merge.');
        // 4 Addresses expected are:
        // 1. The duplicate Address setup in Test Seutp that gets merged to a single record
        // 2. An address created automatically when creating an Account. This will get merged
        // 3. The unique Address setup on Account 1
        // 4. The unique Address setup on Account 2
        System.assertEquals(4, addressCount, 'Expected to find 4 Addresses after merge.');
        System.assert(foundPrimaryKey, 'At least one Address did not have ZTS_GL_Unique_Primary_Address_Key__c populated');

        // Verify ObjectTerritory2Associations are not deleted.
        // On merge, Salesforce natively prevents duplicate ObjectTerritory2Association records.
        // For any records related to a Territory not associated to the Master Account, the old record is deleted and
        // a new one is created.
        // This occurs natively, and possibly asynchronously, and the recreated record doesn't appear in the Unit Test.
        // To avoid errors, we just confirm that more than one Account Territory exists.
        // This makes sure that an Account Territory wasn't deleted incorrectly.
        Set<Id> foundAssignedTerritoryIds = new Set<Id>();
        for (ObjectTerritory2Association territoryAssociation : [SELECT Id, ObjectId, Territory2Id
                                                                 FROM ObjectTerritory2Association
                                                                 WHERE ObjectId in: accountIds]) {
            System.assertEquals(masterAccount.Id, territoryAssociation.ObjectId, 
                'Assigned Territory was not updated as expected.');

            foundAssignedTerritoryIds.add(territoryAssociation.Territory2Id);
        }

        System.assert(foundAssignedTerritoryIds.size() > 1, 'Found 1 or less Assigned Territories.');
        for (String territoryId : foundAssignedTerritoryIds) {
            System.assert(foundATNativeTerritoryIds.contains(territoryId),
                String.format('There are Territories assigned to this Account not present in an Account Territory. Assigned Territories: {0}. Account Territories: {1}',
                    new List<Object> {foundAssignedTerritoryIds, foundATNativeTerritoryIds}));
        }
    }
    
     @isTest
    private static void getAccountsWithEmailChangesTest(){

        List<Account> accountList = new List<Account>();
        List<Account> acc1List = ZTS_DataUtilityTest.createAccountRecord(1);
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        Insert acc1List;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Map<Id, Account> oldAccountMap = new Map<Id, Account>(
            [SELECT Id, Name,Email__c,ZTS_US_Email_Opt_Out__c,ZTS_Invalid_Email__c FROM Account WHERE Id IN :acc1List]
        );
        
        for(Account acc : acc1List){
            acc.Email__c = 'Test@zoetis.com';
            acc.ZTS_US_Email_Opt_Out__c = true;
            accountList.add(acc);
            
        }
        Test.StartTest();
        DispatchTriggerHandler.firstTimeTracker.clear();
        update accountList;
        Map<Id, Account> newAccountMap = new Map<Id, Account>(
            [SELECT Id, Name,Email__c,ZTS_US_Email_Opt_Out__c From Account WHERE Id IN :accountList]
        );
        List<Account> getAccountwithchanges=AccountsService.getAccountsWithEmailChanges(newAccountMap,oldAccountMap);
        Test.StopTest();
        
        System.assertEquals(1,getAccountwithchanges.size(),'1 account record is found with email,Email Opt Out and Invalid Email changes');

    }
    
    @isTest
    private static void getAccountsWithEmailChangesBulkTest(){
        
        List<Account> accountList = new List<Account>();
        List<Account> acc1List = ZTS_DataUtilityTest.createAccountRecord(10);
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        Insert acc1List;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Map<Id, Account> oldAccountMap = new Map<Id, Account>(
            [SELECT Id, Name,Email__c,ZTS_EU_Opt_Out_Email__c,ZTS_Invalid_Email__c FROM Account WHERE Id IN :acc1List]
        );
        
        acc1List[0].Email__c = 'test890@zoetis.com';
        acc1List[1].Email__c = 'test890@zoetis.com';
        acc1List[2].Email__c = 'test890@zoetis.com';
        acc1List[3].ZTS_EU_Opt_Out_Email__c = true;
        acc1List[4].ZTS_EU_Opt_Out_Email__c = true;
        acc1List[5].ZTS_EU_Opt_Out_Email__c = true;
        acc1List[6].ZTS_Invalid_Email__c = true;
        acc1List[7].ZTS_Invalid_Email__c = true;

        Test.StartTest();
        DispatchTriggerHandler.firstTimeTracker.clear();
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update acc1List;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        System.debug('acc1List'+acc1List);
        Map<Id, Account> newAccountMap = new Map<Id, Account>(
            [SELECT Id, Name,Email__c,ZTS_EU_Opt_Out_Email__c,ZTS_Invalid_Email__c From Account WHERE Id IN :acc1List]);
        List<Account> getAccountwithEmailchanges=AccountsService.getAccountsWithEmailChanges(newAccountMap,oldAccountMap);
        System.debug('getAccountwithEmailchanges'+getAccountwithEmailchanges);
        List<Account> accountEmailChangeList = [SELECT Id, Name,Email__c From Account WHERE Id IN :acc1List and Email__c = 'test890@zoetis.com'];
        List<Account> accountoptOutEmailChangeList =[SELECT Id, Name,Email__c,ZTS_EU_Opt_Out_Email__c From Account WHERE Id IN :acc1List and ZTS_EU_Opt_Out_Email__c = true];
        List<Account> accountInvalidEmailChangeList = [SELECT Id, Name,Email__c,ZTS_EU_Opt_Out_Email__c ,ZTS_Invalid_Email__c From Account WHERE Id IN :acc1List and ZTS_Invalid_Email__c = true];
        List<Account> accountNoChangeList = [SELECT Id, Name,Email__c,ZTS_EU_Opt_Out_Email__c ,ZTS_Invalid_Email__c From Account WHERE Id IN :acc1List and ZTS_Invalid_Email__c = False AND ZTS_EU_Opt_Out_Email__c = False AND Email__c != 'test890@zoetis.com'];
        Test.StopTest();
        System.assertEquals(3,accountEmailChangeList.size(),'3 account records are found with email changes');
        System.assertEquals(3,accountoptOutEmailChangeList.size(),'3 account records are found with Email Opt Out changes');
        System.assertEquals(2,accountInvalidEmailChangeList.size(),'2 account records are found with Invalid Email changes');
        System.assertEquals(2,accountNoChangeList.size(),'No changes on 2 account records');
        
    }
   
}