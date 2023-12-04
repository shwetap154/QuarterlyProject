/**
 * @description       : Test class for AccountTerritoriesService
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-21-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-25-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for mergeRelatedAccountTerritoriesByAccountIdAndTerritory
 * 1.1   07-11-2022   Ethan Hirsch @ Zoetis Inc   Change input to runMergeRelatedAccountTerritoriesByAccountIdAndTerritory method.
 * 1.2   07-21-2022   Ethan Hirsch @ Zoetis Inc   Add additional data and assertions to verify that Zoetis SFDC Id is used properly 
 *                                                in merge logic and is updated properly on merge.
**/
@isTest
private class AccountTerritoriesServiceTest {
    private static final string accountZeroName = 'INTL Test Account 0';
    private static final string accountOneName = 'INTL Test Account 1';
    private static final string accountTwoName = 'INTL Test Account 2';
    private static final string accountThreeName = 'INTL Test Account 3';
    private static final string externalIdForMergeTest = 'TestMerge1';
    private static final string externalIdForFixZoetisSFDCId = 'TestFixId';

    @TestSetup
    private static void setup(){
        Territory2Type territoryType = [
            SELECT Id, DeveloperName
            FROM Territory2Type
            LIMIT 1
        ];
        
        Territory2Model territoryModel = new Territory2Model();
        territoryModel.DeveloperName = 'TestModel';
        territoryModel.Name = 'TestModel';
        insert territoryModel;

        Territory2 territory = new Territory2();
        territory.AccountAccessLevel = 'Edit';
        territory.CaseAccessLevel = 'Edit';
        territory.DeveloperName = 'TestTerritory';
        territory.Name = 'TestTerritory';
        territory.OpportunityAccessLevel = 'Edit';
        territory.Territory2ModelId = territoryModel.Id;
        territory.Territory2TypeId = territoryType.Id;
        insert territory;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<ZTS_EU_Territory__c> ztsTerritories = new List<ZTS_EU_Territory__c>();
            for (integer i = 0; i < 3; i++) {
                ztsTerritories.add(TestDataFactory.createZTSTerritory(
                    String.format('TestTerritoryUK{0}', new List<Object> {i}),
                    territory.Id,
                    'United Kingdom',
                    false
                ));
            }

            insert ztsTerritories;

            State_Country__c stateCountryUK = TestDataFactory.createStateCountry(
                'United Kingdom',
                'Test Country',
                true
            );

            List<Account> accounts = new List<Account>();
            for (integer i = 0; i < 4; i++) {
                accounts.add(TestDataFactory.createAccount_EU(
                    String.format('INTL Test Account {0}', new List<Object>{i}),
                    stateCountryUK.Id,
                    false
                  ));
            }

            insert accounts;

            // Requery the Accounts to get the populated ZTS_EU_Zoetis_SFDC_ID__c field
            accounts = [
                SELECT ID, ZTS_EU_Zoetis_SFDC_ID__c
                FROM Account
                WHERE Id in: accounts];

            List<ZTS_AccountTerritory__c> accountTerritories = new List<ZTS_AccountTerritory__c>();
            accountTerritories.add(TestDataFactory.createAccountTerritory(
                accounts[1].Id,
                ztsTerritories[0].Id,
                false
              ));

            accountTerritories.add(TestDataFactory.createAccountTerritory(
                accounts[1].Id,
                ztsTerritories[1].Id,
                false
              ));

            List<ZTS_AccountTerritory__c> accountTerritoriesSetCreatedDateNewer = new List<ZTS_AccountTerritory__c>();
            List<ZTS_AccountTerritory__c> accountTerritoriesSetCreatedDateOlder = new List<ZTS_AccountTerritory__c>();
            ZTS_AccountTerritory__c accountTerritoryWithPosition;
            // Setup Account Territories for Account 2
            for (integer i = 0; i < 6; i++) {
                Id territorityId;

                if (i < 2) {
                    territorityId = ztsTerritories[0].Id;
                }
                else if (i < 4) {
                    territorityId = ztsTerritories[1].Id;
                }
                else {
                    territorityId = ztsTerritories[2].Id;
                }

                ZTS_AccountTerritory__c accountTerritory = TestDataFactory.createAccountTerritory(
                    accounts[2].Id,
                    territorityId,
                    false
                );

                if (i == 0) {
                    accountTerritoryWithPosition = accountTerritory;
                }
                else if (i == 1) {
                    accountTerritory.ZTS_AT_External_ID__c = 'Test1';
                }
                else if (i == 2) {
                    accountTerritoriesSetCreatedDateNewer.add(accountTerritory);
                }
                else if (i == 3) {
                    accountTerritoriesSetCreatedDateOlder.add(accountTerritory);
                }
                else if (i == 4) {
                    accountTerritory.ZTS_AT_External_ID__c = 'TestExtra';
                    accountTerritoriesSetCreatedDateNewer.add(accountTerritory);
                }
                else if (i == 5) {
                    accountTerritory.ZTS_AT_External_ID__c = externalIdForMergeTest;
                    accountTerritoriesSetCreatedDateOlder.add(accountTerritory);
                }

                accountTerritories.add(accountTerritory);
            }

            // Setup Account Territories for Account 3
            for (integer i = 0; i < 4; i++) {
                Id territorityId;

                if (i < 2) {
                    territorityId = ztsTerritories[0].Id;
                }
                else if (i < 3) {
                    territorityId = ztsTerritories[1].Id;
                }
                else {
                    territorityId = ztsTerritories[2].Id;
                }

                ZTS_AccountTerritory__c accountTerritory = TestDataFactory.createAccountTerritory(
                    accounts[3].Id,
                    territorityId,
                    false
                );

                if (i == 0) {
                    accountTerritory.ZTS_AT_External_ID__c = 'Test2';
                    accountTerritoriesSetCreatedDateNewer.add(accountTerritory);
                }
                else if (i == 1) {
                    accountTerritory.ZTS_AT_External_ID__c = 'Test3';
                    accountTerritoriesSetCreatedDateOlder.add(accountTerritory);
                }
                else if (i == 3) {
                    accountTerritory.ZTS_AT_External_ID__c = externalIdForFixZoetisSFDCId;
                }

                accountTerritories.add(accountTerritory);
            }

            insert accountTerritories;

            // Set Created Date to prioritize deletion of Account Territories while merging
            for (ZTS_AccountTerritory__c accountTerritory : accountTerritoriesSetCreatedDateNewer) {
                Test.setCreatedDate(accountTerritory.Id, System.now().addDays(-8));
            }
    
            for (ZTS_AccountTerritory__c accountTerritory : accountTerritoriesSetCreatedDateOlder) {
                Test.setCreatedDate(accountTerritory.Id, System.today().addDays(-10));
            }

            TestDataFactory.createAccountPosition(accounts[1].Id, accountTerritoryWithPosition.Id, true);
        }
    }

    // This test passes in no data, so no deletes or updates should occur
    @isTest
    private static void mergeRelatedAccountTerritoriesByAccountIdAndTerritory_NoData_Test() {
        Exception error;
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();
        Map<Id, ZTS_AccountTerritory__c> deleteAccountTerritoriesById;

        try {
            Test.startTest();
                deleteAccountTerritoriesById = runMergeRelatedAccountTerritoriesByAccountIdAndTerritory(
                    new Set<Id>(), updateRelatedRecordsMap);
            Test.stopTest();
        }
        catch (Exception ex) {
            error = ex;
        }

        System.assertEquals(null, error, String.format('An unexpected error occurred: {0}', new List<Object> {error}));
        System.assert(deleteAccountTerritoriesById.isEmpty(), String.format(
            'Unexpeted Account Territories were deleted: {0}', new List<Object>{deleteAccountTerritoriesById}));

        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.isEmpty(), String.format(
            'Records were updated unexpectedly: {0}', new List<Object>{updateRelatedRecordsMap}));
    }

    // The Account used in this test has no Account Territories, so no data should be deleted/updated.
    @isTest
    private static void mergeRelatedAccountTerritoriesByAccountIdAndTerritory_NoAccountTerritories_Test() {
        Account testAccount = [
            SELECT Id
            FROM Account
            WHERE Name =: accountZeroName
            LIMIT 1
        ];

        Exception error;
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();
        Map<Id, ZTS_AccountTerritory__c> deleteAccountTerritoriesById;
        try {
            Test.startTest();
                deleteAccountTerritoriesById = runMergeRelatedAccountTerritoriesByAccountIdAndTerritory(
                    new Set<Id> {testAccount.Id}, updateRelatedRecordsMap);
            Test.stopTest();
        }
        catch (Exception ex) {
            error = ex;
        }

        System.assertEquals(null, error, String.format('An unexpected error occurred: {0}', new List<Object> {error}));
        System.assert(deleteAccountTerritoriesById.isEmpty(), String.format(
            'Unexpeted Account Territories were deleted: {0}', new List<Object>{deleteAccountTerritoriesById}));

        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.isEmpty(), String.format(
            'Records were updated unexpectedly: {0}', new List<Object>{updateRelatedRecordsMap}));
    }

    // The Account used here has unique Account Territories, so no data should be deleted or updated
    @isTest
    private static void mergeRelatedAccountTerritoriesByAccountIdAndTerritory_UniqueAccountTerritories_Test() {
        Account testAccount = [
            SELECT Id
            FROM Account
            WHERE Name =: accountOneName
            LIMIT 1
        ];

        Exception error;
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();
        Map<Id, ZTS_AccountTerritory__c> deleteAccountTerritoriesById;
        try {
            Test.startTest();
                deleteAccountTerritoriesById = runMergeRelatedAccountTerritoriesByAccountIdAndTerritory(
                    new Set<Id> {testAccount.Id}, updateRelatedRecordsMap);
            Test.stopTest();
        }
        catch (Exception ex) {
            error = ex;
        }

        System.assertEquals(null, error, String.format('An unexpected error occurred: {0}', new List<Object> {error}));
        System.assert(deleteAccountTerritoriesById.isEmpty(), String.format(
            'Unexpeted Account Territories were deleted: {0}', new List<Object>{deleteAccountTerritoriesById}));

        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.isEmpty(), String.format(
            'Records were updated unexpectedly: {0}', new List<Object>{updateRelatedRecordsMap}));
    }

    @isTest
    private static void mergeRelatedAccountTerritoriesByAccountIdAndTerritory_DuplicateAccountTerritories_Test() {
        Account testAccount = [
            SELECT Id
            FROM Account
            WHERE Name =: accountTwoName
            LIMIT 1
        ];

        Map<Id, ZTS_AccountTerritory__c> accountTerritoryByTerritoryId = new Map<Id, ZTS_AccountTerritory__c>();
        Set<Id> expectedDeleteAccountTerritoryIds = new Set<Id>();
        Id assignAccountPositionTerritoryId;

        for (ZTS_AccountTerritory__c accountTerritory : [
            SELECT Id, ZTS_AT_External_ID__c, ZTS_EU_Territory__c, CreatedDate
            FROM ZTS_AccountTerritory__c
            WHERE ZTS_EU_Account__c =: testAccount.Id
        ]) {
            Id territoryId = accountTerritory.ZTS_EU_Territory__c;
            if (accountTerritoryByTerritoryId.containsKey(territoryId)) {
                ZTS_AccountTerritory__c matchingTerritory = accountTerritoryByTerritoryId.get(territoryId);

                // When the External Id has externalIdForMergeTest populated, set the Matching Territory Id in the
                // overwriteMergeZoetisSFDCIDId variable so that its Zoetis SFDC Id is overwritten and it is 
                // deleted in favor of its matching record.
                if (accountTerritory.ZTS_AT_External_ID__c == externalIdForMergeTest) {
                    expectedDeleteAccountTerritoryIds.add(matchingTerritory.Id);
                    AccountTerritoriesService.overwriteMergeZoetisSFDCIDId = matchingTerritory.Id;
                }
                else if (String.isNotBlank(matchingTerritory.ZTS_AT_External_ID__c) &&
                    String.isBlank(accountTerritory.ZTS_AT_External_ID__c)) {
                    expectedDeleteAccountTerritoryIds.add(accountTerritory.Id);
                    assignAccountPositionTerritoryId = matchingTerritory.Id;
                }
                else if (String.isNotBlank(accountTerritory.ZTS_AT_External_ID__c) &&
                    String.isBlank(matchingTerritory.ZTS_AT_External_ID__c)) {
                    expectedDeleteAccountTerritoryIds.add(matchingTerritory.Id);
                    assignAccountPositionTerritoryId = accountTerritory.Id;
                }
                else if (matchingTerritory.CreatedDate > accountTerritory.CreatedDate) {
                    expectedDeleteAccountTerritoryIds.add(matchingTerritory.Id);
                }
                else {
                    expectedDeleteAccountTerritoryIds.add(accountTerritory.Id);
                }
            }

            accountTerritoryByTerritoryId.put(territoryId, accountTerritory);
        }

        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();
        Test.startTest();
            Map<Id, ZTS_AccountTerritory__c> deleteAccountTerritoriesById = 
                runMergeRelatedAccountTerritoriesByAccountIdAndTerritory(new Set<Id> {testAccount.Id},
                    updateRelatedRecordsMap);
        Test.stopTest();

        System.assertEquals(expectedDeleteAccountTerritoryIds.size(), deleteAccountTerritoriesById.size(), 
            'More/Less Account Territories deleted than expected.');

        for (Id accountTerritoryId : expectedDeleteAccountTerritoryIds) {
            System.assert(deleteAccountTerritoriesById.containsKey(accountTerritoryId),
                String.format('Account Territory {0} was not deleted as expected. Actual deleted: {1}',
                    new List<Object> {accountTerritoryId, String.join(
                        (List<String>)(new List<Id>(deleteAccountTerritoriesById.keySet())), ',')}));
        }

        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.containsKey('ZTS_EU_Account_Position__c'),
        'No ZTS_EU_Account_Position__c records were updated.');

        Map<Id, SObject> updateAccountPositionsById = updateRelatedRecordsMap.updateRecordsMapByName.get('ZTS_EU_Account_Position__c');

        System.assertEquals(1, updateAccountPositionsById.size(),
            'More/Less Account Positions than expected were updated.');

        ZTS_EU_Account_Position__c accountPosition = (ZTS_EU_Account_Position__c)updateAccountPositionsById.values()[0];
        System.assertEquals(assignAccountPositionTerritoryId, accountPosition.ZTS_AccountTerritory__c,
            'ZTS_AccountTerritory__c was not updated to the expected Account Territory');
    }

    @isTest
    private static void mergeRelatedAccountTerritoriesByAccountIdAndTerritory_MultipleAccounts_Test() {
        Set<Id> accountIds = new Set<Id>();
        Id accountTwoId;
        for (Account account: [
            SELECT Id, Name
            FROM Account
            WHERE Name in: new List<String>{accountTwoName, accountThreeName}
            LIMIT 2]) {
            accountIds.add(account.Id);
            if (account.Name == accountTwoName) {
                accountTwoId = account.Id;
            }
        }

        Map<String, ZTS_AccountTerritory__c> accountTerritoryByTerritoryIdAndAccount = new Map<String, ZTS_AccountTerritory__c>();
        Set<Id> expectedDeleteAccountTerritoryIds = new Set<Id>();
        Id assignAccountPositionTerritoryId;
        Id updateZoetisSFDCIDTerritoryId;
        String expectedUpdatedZoetisSFDCId;
        for (ZTS_AccountTerritory__c accountTerritory : [
            SELECT Id, ZTS_EU_Account__c, ZTS_AT_External_ID__c, ZTS_EU_Territory__c, CreatedDate, 
                   ZTS_EU_Account__r.ZTS_EU_Zoetis_SFDC_ID__c
            FROM ZTS_AccountTerritory__c
            WHERE ZTS_EU_Account__c in: accountIds
        ]) {

            // When the External Id of externalIdForFixZoetisSFDCId is found, set that Account Territory to have its
            // Zoetis SFDC Id overwritten to test that the Zoetis SFDC Id field can be updated.
            // Zoetis SFDC Id is set by a Workflow Rule, so this avoids needing to work around it.
            if (accountTerritory.ZTS_AT_External_ID__c == externalIdForFixZoetisSFDCId) {
                AccountTerritoriesService.overwriteMergeZoetisSFDCIDId = accountTerritory.Id;
                updateZoetisSFDCIDTerritoryId = accountTerritory.Id;
                expectedUpdatedZoetisSFDCId = accountTerritory.ZTS_EU_Account__r.ZTS_EU_Zoetis_SFDC_ID__c;
            }

            String key = String.format('{0}{1}', 
                new List<Object>{accountTerritory.ZTS_EU_Territory__c, accountTerritory.ZTS_EU_Account__c});

            if (accountTerritoryByTerritoryIdAndAccount.containsKey(key)) {
                ZTS_AccountTerritory__c matchingTerritory = accountTerritoryByTerritoryIdAndAccount.get(key);

                // Account Three has matching Account Territories that both have External Id specified.
                // Check both Accounts to avoid marking the wrong Account Territory for deletion.
                if (String.isNotBlank(matchingTerritory.ZTS_AT_External_ID__c) && 
                    String.isBlank(accountTerritory.ZTS_AT_External_ID__c)) {
                    expectedDeleteAccountTerritoryIds.add(accountTerritory.Id);
                    
                    if (matchingTerritory.ZTS_EU_Account__c == accountTwoId) {
                        assignAccountPositionTerritoryId = matchingTerritory.Id;
                    }
                }
                else if (String.isNotBlank(accountTerritory.ZTS_AT_External_ID__c) && 
                    String.isBlank(matchingTerritory.ZTS_AT_External_ID__c)) {
                    expectedDeleteAccountTerritoryIds.add(matchingTerritory.Id);

                    if (accountTerritory.ZTS_EU_Account__c == accountTwoId) {
                        assignAccountPositionTerritoryId = accountTerritory.Id;
                    }
                }
                else if (matchingTerritory.CreatedDate > accountTerritory.CreatedDate) {
                    expectedDeleteAccountTerritoryIds.add(matchingTerritory.Id);
                }
                else {
                    expectedDeleteAccountTerritoryIds.add(accountTerritory.Id);
                }
            }

            accountTerritoryByTerritoryIdAndAccount.put(key, accountTerritory);
        }

        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();
        Test.startTest();
            Map<Id, ZTS_AccountTerritory__c> deleteAccountTerritoriesById = 
                runMergeRelatedAccountTerritoriesByAccountIdAndTerritory(accountIds,
                    updateRelatedRecordsMap);
        Test.stopTest();

        System.assertEquals(expectedDeleteAccountTerritoryIds.size(), deleteAccountTerritoriesById.size(), 
            'More/Less Account Territories deleted than expected.');

        for (Id accountTerritoryId : expectedDeleteAccountTerritoryIds) {
            System.assert(deleteAccountTerritoriesById.containsKey(accountTerritoryId),
                String.format('Account Territory {0} was not deleted as expected. Actual deleted: {1}',
                    new List<Object> {accountTerritoryId, String.join(
                        (List<String>)(new List<Id>(deleteAccountTerritoriesById.keySet())), ',')}));
        }

        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.containsKey('ZTS_EU_Account_Position__c'),
            'No ZTS_EU_Account_Position__c records were updated.');

        Map<Id, SObject> updateAccountPositionsById = updateRelatedRecordsMap.updateRecordsMapByName.get('ZTS_EU_Account_Position__c');

        System.assertEquals(1, updateAccountPositionsById.size(),
            'More/Less Account Positions than expected were updated.');

        ZTS_EU_Account_Position__c accountPosition = (ZTS_EU_Account_Position__c)updateAccountPositionsById.values()[0];
        System.assertEquals(assignAccountPositionTerritoryId, accountPosition.ZTS_AccountTerritory__c,
            'ZTS_AccountTerritory__c was not updated to the expected Account Territory');

        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.containsKey('ZTS_AccountTerritory__c'),
            'No ZTS_AccountTerritory__c records were updated.');

        Map<Id, SObject> updatedAccountTerritoriesById = updateRelatedRecordsMap.updateRecordsMapByName.get('ZTS_AccountTerritory__c');
        System.assertEquals(1, updatedAccountTerritoriesById.size(), 
            'More/Less Account Territories than expected were updated.');

        ZTS_AccountTerritory__c updatedAccountTerritory = (ZTS_AccountTerritory__c)updatedAccountTerritoriesById.values()[0];
        System.assertEquals(updateZoetisSFDCIDTerritoryId, updatedAccountTerritory.Id,
            'A different Account Territory was updated than expected.');

        System.assertEquals(expectedUpdatedZoetisSFDCId, updatedAccountTerritory.ZTS_Zoetis_SFDC_ID__c, 
            'Zoetis SFDC Id was not updated as expected.');
    }

    private static Map<Id, ZTS_AccountTerritory__c> runMergeRelatedAccountTerritoriesByAccountIdAndTerritory(Set<Id> accountIds,
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap) {
        return AccountTerritoriesService.mergeRelatedAccountTerritoriesByAccountIdAndTerritory(accountIds,
        new Map<String, MergeRelatedRecordLookupsSelector.ChildObject>{
            'ZTS_EU_Account_Position__c' => new MergeRelatedRecordLookupsSelector.ChildObject('ZTS_EU_Account_Position__c', null)
        }, updateRelatedRecordsMap);
    }
}