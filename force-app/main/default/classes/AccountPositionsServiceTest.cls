/**
* @description       : Test class for AccountPositionsService
* @author            : Morgan Marchese @ Zoetis Inc
* @group             :
* @last modified on  : 05-05-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                         Modification
* 1.0   01-25-2021   Morgan Marchese @ Zoetis Inc   Initial Version
* 1.1   04-07-2022   Ethan Hirsch @ Zoetis Inc      Change to @isTest from test method, add tests for code coverage 
*                                                   for Colleague Update and edge case calls for setting ZTS_EU_Days_Since_Last_Call_New__c
* 1.2   04-13-2022   Ethan Hirsch @ Zoetis Inc      Add Unit Tests for setLeProgramOwnerToPrimaryForContractOwner
* 1.3   05-25-2022   Ethan Hirsch @ Zoetis Inc      Add Unit Tests for mergeRelatedAccountPositionsByAccountAndPosition. Update existing tests to handle merge errors
* 1.4   07-11-2022   Ethan Hirsch @ Zoetis Inc      Change input to mergeRelatedAccountPositionsByAccountAndPosition method.
* 1.5   09-08-2022   Ethan Hirsch @ Zoetis Inc      Add additional data and assertions to confirm an Active Account Position is kept over an inactive one.
* 1.6   09-12-2022   Ethan Hirsch @ Zoetis Inc      Add additional data and assertions to confirm an Account Position with a Call Target of 0 is treated as though 
*                                                   Call Target is blank.
* 1.7   11-21-2022   Ethan Hirsch @ Zoetis Inc      Bypass triggers in setup to save on SOQL and DML Limits and avoid errors
* 1.8   05-02-2023   Padma Nerella @ Zoetis Inc     Moved Test.StartTest() method to avoid soql limit errors
**/
@isTest
private class AccountPositionsServiceTest {
    private static final Integer MAX_ACCOUNTS = 5;
    private static final Integer MAX_USUSERS = 5;
    private static final string usUserNameTemplate = 'UsUser{0}@zoetis.com.AccountPositionServiceTest';
    private static final string ukStateCountryName = 'County Down';
    
    private static Id contractNewContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('New_Contract').getRecordTypeId();
    private static Id contractReadOnlyRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Contract_Read_Only').getRecordTypeId();
    private static Id contractActiveRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Active_Contract').getRecordTypeId();
    
    private static final String intlAccountUniqueAccountPositions = 'UK Test Account 0';
    private static final String intlAccountDuplicateAccountPositions = 'Uk Test Account 1';
    private static final String intlAccountAdditionalDuplicateTest = 'Uk Test Account 2';
    private static final String mainIntlUserFirstName = 'IntUser0';
    private static final String intlUser1FirstName = 'IntUser1';
    private static final String intlUser3FirstName = 'IntUser3';
    
    private static DateTime accountPositionNewerCreatedDate = System.now().addDays(-8);
    
    @TestSetup
    static void setup() {
        // Bypass triggers to save on limit usage in setup.
        // Do not bypass The Account Territory Trigger Handler so Account Positions are autocreated.
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_TerritoryTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_PositionTriggerHandler');
        DispatchTriggerHandler.bypass('ContractTrigger');
        // When an Employee Id is specified, an Account Position is created when an Account and Account Territory is inserted
        // This causes duplicate records to be created.
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        // Disable Trigger to prevent keys from being set. This will prevent errors from occuring due to uniqueness constraints
        DispatchTriggerHandler.bypass('ZTS_EU_Account_PositionTriggerHandler');
        Id adminProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1].Id;
        
        List<User> allUsers = new List<User>();
        
        List<User> intlUsers = new List<User>();
        for (Integer i = 0; i < 6; i++) {
            User intlUser = TestDataFactory.createUser(adminProfileId, null, null, false);
            intlUser.FirstName = String.format('IntUser{0}', new List<Object>{i});
            intlUser.ZTS_EU_Market__c = 'United Kingdom';
            intlUsers.add(intlUser);
        }
        
        allUsers.addAll(intlUsers);
        
        User mainIntlUsr = intlUsers[0];
        
        List<User> usUsers = new List<User>();
        for (Integer i = 0; i < MAX_USUSERS; i++) {
            User usUser = TestDataFactory.createUser(adminProfileId, null, null, false);
            usUser.FirstName = 'USUser';
            usUser.Username = String.format(usUserNameTemplate, new List<Object> {i});
            usUser.ZTS_EU_Market__c = 'United States';
            usUsers.add(usUser);
        }
        
        allUsers.addAll(usUsers);
        
        insert allUsers;
        
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
        
        System.runAs(mainIntlUsr) {
            // Create Zoetis Global Custom Territories, related to Standard Territories
            ZTS_EU_Territory__c ztsTerritoryUK = TestDataFactory.createZTSTerritory(
                'TestTerritoryUK',
                territory.Id,
                'United Kingdom',
                false
            );
            ZTS_EU_Territory__c ztsTerritoryUK2 = TestDataFactory.createZTSTerritory(
                'TestTerritoryUK2',
                territory.Id,
                'United Kingdom',
                false
            );
            ZTS_EU_Territory__c ztsTerritoryUS = TestDataFactory.createZTSTerritory(
                'TestTerritoryUS',
                territory.Id,
                'United States',
                false
            );
            
            List<ZTS_EU_Territory__c> ztsTerritoryList = new List<ZTS_EU_Territory__c>{
                ztsTerritoryUK,
                    ztsTerritoryUK2,
                    ztsTerritoryUS
                    };
                        insert ztsTerritoryList;
            
            // Create Zoetis Global Positions, related to Global Custom Territories
            Map<Id, ZTS_EU_Position__c> positionsByUserId = new Map<Id, ZTS_EU_Position__c>();
            positionsByUserId.put(mainIntlUsr.Id, TestDataFactory.createPosition(
                ztsTerritoryUK.Name,
                ztsTerritoryUK.Id,
                ztsTerritoryUK.ZTS_EU_Market__c,
                mainIntlUsr.Id,
                false
            ));
            
            for (User intlUser : intlUsers) {
                if (intlUser == mainIntlUsr) {
                    continue;
                }
                
                positionsByUserId.put(intlUser.Id, TestDataFactory.createPosition(
                    ztsTerritoryUK2.Name,
                    ztsTerritoryUK2.Id,
                    ztsTerritoryUK2.ZTS_EU_Market__c,
                    intlUser.Id,
                    false));
            }
            
            for (User usUser : usUsers) {
                
                ZTS_EU_Position__c tempPosition = TestDataFactory.createPosition(
                    ztsTerritoryUS.Name,
                    ztsTerritoryUS.Id,
                    ztsTerritoryUS.ZTS_EU_Market__c,
                    usUser.Id,
                    false
                );
                
                positionsByUserId.put(usUser.Id, tempPosition);
            }
            
            insert positionsByUserId.Values();
            
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            List<State_Country__c> stateCountryList = new List<State_Country__c>();
            List<Account> accountList = new List<Account>();
            TestDataFactory.createVetSaveMarket_UK('United Kingdom', true);
            
            State_Country__c stateCountryUK = TestDataFactory.createStateCountry(
                'United Kingdom',
                ukStateCountryName,
                false
            );
            stateCountryList.add(stateCountryUK);
            insert stateCountryList;
            
            List<Account> intlAccounts = new List<Account>();
            // Create Test Accounts with different Markets
            for (Integer i = 0; i < MAX_ACCOUNTS; i++) {
                Account acct = TestDataFactory.createAccount_EU(
                    'UK Test Account ' + i,
                    stateCountryUK.Id,
                    false
                );
                
                intlAccounts.add(acct);
            }
            
            List<Account> usAccounts = new List<Account>();
            for (Integer i = 0; i < MAX_ACCOUNTS; i++) {
                Account acct = TestDataFactory.createAccount_US(
                    'US Test Account ' + i,
                    false
                );
                
                usAccounts.add(acct);
            }
            
            accountList.addAll(usAccounts);
            accountList.addAll(intlAccounts);
            
            insert accountList;
            
            List<Contract> contracts = new List<Contract>();
            for (Integer i = 0; i < MAX_USUSERS; i++) {
                Id recordTypeId = i < 2
                    ? contractNewContractRecordTypeId
                    : contractReadOnlyRecordTypeId;
                
                Contract contract = TestDataFactory.createContracts(1, usAccounts[i].Id, recordTypeId)[0];
                contract.OwnerId = usUsers[i].Id;
                contracts.add(contract);
            }
            
            Contract incorrectRecordTypeContract = TestDataFactory.createContracts(1, usAccounts[0].Id, contractActiveRecordTypeId)[0];
            incorrectRecordTypeContract.OwnerId = usUsers[0].Id;
            contracts.add(incorrectRecordTypeContract);
            
            insert contracts;
            
            Map<Id, ZTS_AccountTerritory__c> accountTerritoryByAccountId = new Map<Id, ZTS_AccountTerritory__c>();
            for (Account record : accountList) {
                ZTS_AccountTerritory__c tempTerritory;
                if (record.ZTS_EU_Market__c == 'United States') {
                    tempTerritory = TestDataFactory.createAccountTerritory(
                        record.Id,
                        ztsTerritoryUS.Id,
                        false
                    );
                } else {
                    tempTerritory = TestDataFactory.createAccountTerritory(
                        record.Id,
                        ztsTerritoryUK.Id,
                        false
                    );
                }
                accountTerritoryByAccountId.put(record.Id,tempTerritory);
            }
            
            insert accountTerritoryByAccountId.Values();
            
            // An Account Position is automatically created for the Main INTL User for each INTL Account
            List<ZTS_EU_Account_Position__c> additionalAccountPositions = new List<ZTS_EU_Account_Position__c>();
            ZTS_EU_Account_Position__c accountPosition1 = TestDataFactory.createAccountPosition(intlAccounts[0].Id,
                                                                                                accountTerritoryByAccountId.get(intlAccounts[0].Id).Id, false);
            
            accountPosition1.ZTS_EU_Position__c = positionsByUserId.get(intlUsers[1].Id).Id;
            additionalAccountPositions.add(accountPosition1);
            
            List<ZTS_EU_Account_Position__c> accountPositionsSetCreatedDateNewer = new List<ZTS_EU_Account_Position__c>();
            List<ZTS_EU_Account_Position__c> accountPositionsSetCreatedDateOlder = new List<ZTS_EU_Account_Position__c>();
            ZTS_EU_Account_Position__c accountPositionSetUniqueKeyIncorrect1;
            // Setup Account Positions for INTL Account 1 to test update logic and delete logic.
            for (integer i = 0; i < 9; i++) {
                ZTS_EU_Account_Position__c extraAccountPosition = TestDataFactory.createAccountPosition(intlAccounts[1].Id,
                                                                                                        accountTerritoryByAccountId.get(intlAccounts[1].Id).Id, false);
                
                Id userId;
                if (i < 2) {
                    userId = intlUsers[1].Id;
                }
                else if (i < 4) {
                    userId = intlUsers[2].Id;
                }
                else if (i < 6) {
                    userId = intlUsers[3].Id;
                }
                else if (i < 8) {
                    userId = intlUsers[4].Id;
                }
                else {
                    userId = intlUsers[5].Id;
                }
                
                if (i == 0) {
                    accountPositionSetUniqueKeyIncorrect1 = extraAccountPosition;
                    extraAccountPosition.ZTS_AccountUserTerrUniqueKey__c = 'INCORRECT';
                }
                else if (i == 1) {
                    // Set the ZTS_AccountUserTerrUniqueKey__c key manually. This would normally be set by a trigger, but
                    // it doesn't run due to recursion prevention.
                    extraAccountPosition.ZTS_AccountUserTerrUniqueKey__c = AccountPositionsService.generateAccountUserTerrUniqueKey(extraAccountPosition);
                }
                else if (i == 2) {
                    accountPositionsSetCreatedDateNewer.add(extraAccountPosition);
                }
                else if (i == 3) {
                    accountPositionsSetCreatedDateOlder.add(extraAccountPosition);
                }
                else if (i == 5) {
                    extraAccountPosition.ZTS_EU_Call_Target__c = 10;
                }
                else if (i == 6) {
                    extraAccountPosition.ZTS_EU_Active__c = false;
                    // Call Target will not change the Account Position that is kept
                    extraAccountPosition.ZTS_EU_Call_Target__c = 15;
                }
                else if (i == 8) {
                    extraAccountPosition.ZTS_AccountUserTerrUniqueKey__c = 'INCORRECT2';
                    extraAccountPosition.Uniqueness_Key__c = 'INCORRECT';
                }
                
                extraAccountPosition.ZTS_EU_Position__c = positionsByUserId.get(userId).Id;
                additionalAccountPositions.add(extraAccountPosition);
            }
            
            // Setup Account Positions for INTL Account 2 to test update and delete logic
            for (integer i = 0; i < 5; i++) {
                ZTS_EU_Account_Position__c extraAccountPosition = TestDataFactory.createAccountPosition(intlAccounts[2].Id,
                                                                                                        accountTerritoryByAccountId.get(intlAccounts[2].Id).Id, false);
                
                Id userId;
                if (i < 2) {
                    userId = intlUsers[1].Id;
                    extraAccountPosition.ZTS_EU_Call_Target__c = 10;
                    // Set the Unique Key to a value that contains the Account Id and the index to avoid uniqueness errors.
                    extraAccountPosition.ZTS_AccountUserTerrUniqueKey__c = String.format('{0}{1}',
                                                                                         new List<Object> {extraAccountPosition.ZTS_EU_Account__c, i});
                    
                    // Make both Account Positions inactive as it should not impact the Test
                    extraAccountPosition.ZTS_EU_Active__c = false;
                }
                else if (i == 2) {
                    userId = intlUsers[2].Id;
                    extraAccountPosition.Uniqueness_Key__c = 'INCORRECT2';
                }
                else {
                    userId = intlUsers[3].Id;
                } 
                
                if (i == 0) {
                    accountPositionsSetCreatedDateNewer.add(extraAccountPosition);
                }
                else if (i == 1) {
                    accountPositionsSetCreatedDateOlder.add(extraAccountPosition);
                }
                else if (i == 3) {
                    extraAccountPosition.ZTS_EU_Call_Target__c = 0;
                }
                else {
                    extraAccountPosition.ZTS_EU_Call_Target__c = 6;
                }
                
                extraAccountPosition.ZTS_EU_Position__c = positionsByUserId.get(userId).Id;
                additionalAccountPositions.add(extraAccountPosition);
            }
            
            insert additionalAccountPositions;
            
            // Set Created Date differently for some Account Positions to test prioritization of deletion
            // when testing merge logic
            for (ZTS_EU_Account_Position__c accountPosition : accountPositionsSetCreatedDateNewer) {
                Test.setCreatedDate(accountPosition.Id, accountPositionNewerCreatedDate);
            }
            
            for (ZTS_EU_Account_Position__c accountPosition : accountPositionsSetCreatedDateOlder) {
                Test.setCreatedDate(accountPosition.Id, System.today().addDays(-10));
            }
            
            ZTS_EU_DataUtilityTest.createEmployeeCallCredit(accountPositionSetUniqueKeyIncorrect1, intlUsers[1].Id, true);
        }
        
        DispatchTriggerHandler.clearBypass('UserTriggerHandler');
        DispatchTriggerHandler.clearBypass('ZTS_EU_TerritoryTriggerHandler');
        DispatchTriggerHandler.clearBypass('ZTS_EU_PositionTriggerHandler');
        DispatchTriggerHandler.clearBypass('ContractTrigger');
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        DispatchTriggerHandler.clearBypass('ZTS_EU_Account_PositionTriggerHandler');
    }
    
    @IsTest
    static void setRecordsInactive_Test() {
        User contextUser = new User(Id = UserInfo.getUserId());
        Test.startTest();
        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE ZTS_EU_Market__c = 'United States'
        ];
        System.assertEquals(
            MAX_ACCOUNTS,
            accounts.size(),
            'We should find all of the created accounts from Setup'
        );
        Map<Id, ZTS_AccountTerritory__c> accountTerritoryMap = new Map<Id, ZTS_AccountTerritory__c>(
            [
                SELECT Id
                FROM ZTS_AccountTerritory__c
                WHERE ZTS_EU_Account__c IN :accounts
            ]
        );
        System.assertEquals(
            accounts.size(),
            accountTerritoryMap.size(),
            'Each Account should have one Account Territory'
        );
        System.runAs(contextuser) {
            List<ZTS_EU_Account_Position__c> recordList = AccountPositionsSelector.newInstance().selectByAcctTerritoryId(
                accountTerritoryMap.keySet(),
                false
            );
            System.assertEquals(
                accounts.size() * 5,
                recordList.size(),
                'Each Account Territory should have five Positions'
            );
            for (ZTS_EU_Account_Position__c record : recordList) {
                System.assertEquals(
                    true,
                    record.ZTS_EU_Active__c,
                    'Positions Should Start as Active'
                );
            }
            recordList = AccountPositionsService.setRecordsInactive(recordList);
            for (ZTS_EU_Account_Position__c record : recordList) {
                System.assertEquals(
                    false,
                    record.ZTS_EU_Active__c,
                    'Positions Should End as Inactive'
                );
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void updateLastCallDateFromCalls_Update_Test() {
        User intlUsr = [
            SELECT Id
            FROM User
            WHERE FirstName =: mainIntlUserFirstName AND ZTS_EU_Market__c = 'United Kingdom'
            LIMIT 1
        ];
        List<Call__c> callsList = new List<Call__c>();
        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        
        System.runAs(intlUsr) {
            Test.startTest();
            for (Account accObj : accounts) {
                Call__c call = TestDataFactory.createCall(accObj.Id, false);
                callsList.add(call);
            }
            // insert calls
            insert callsList;
            
            // loop through each call and change the date
            for (Call__c objCall : callsList) {
                objCall.ZTS_EU_Start_Date_Time__c = System.now().addDays(-5);
            }
            
            // update all calls
            update callsList;
            Test.stopTest();
        }
        // after update, Last Call Date on all Account Positions should be updated to match the new Call Dates
        List<ZTS_EU_Account_Position__c> accountPositions = [
            SELECT Id, ZTS_EU_Days_Since_Last_Call_New__c
            FROM ZTS_EU_Account_Position__c 
            WHERE ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'
            AND ZTS_EU_Position__r.ZTS_EU_Employee__c =: intlUsr.Id
        ];
        for (ZTS_EU_Account_Position__c objPosition : accountPositions) {
            System.assertEquals(
                5,
                objPosition.ZTS_EU_Days_Since_Last_Call_New__c,
                'Days Since Last Call should match Days between Today and Call Start'
            );
        }
    }
    
    @isTest
    static void updateLastCallDateFromCalls_Delete_Test() {
        User intlUsr = [
            SELECT Id
            FROM User
            WHERE FirstName =: mainIntlUserFirstName AND ZTS_EU_Market__c = 'United Kingdom'
            LIMIT 1
        ];
        List<Call__c> callsList = new List<Call__c>();
        List<Call__c> callsToDelete = new List<Call__c>();
        List<Call__c> allCalls = new List<Call__c>();
        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        
        System.runAs(intlUsr) {
            Test.startTest();
            for (Account accObj : accounts) {
                for (Integer i = 0; i < 2; i++) {
                    Call__c call = TestDataFactory.createCall(accObj.Id, false);
                    if (i == 0) {
                        call.ZTS_EU_Start_Date_Time__c = System.today().addDays(-5);
                        callsList.add(call);
                    } else {
                        call.ZTS_EU_Start_Date_Time__c = System.today().addDays(-3);
                        callsToDelete.add(call);
                    }
                    allCalls.add(call);
                }
            }
            // insert calls
            insert allCalls;
            
            // delete calls
            delete callsToDelete;
            Test.stopTest();
        }
        // after update, Last Call Date on all Account Positions should be updated to match the new Call Dates
        List<ZTS_EU_Account_Position__c> accountPositions = [
            SELECT Id, ZTS_EU_Days_Since_Last_Call_New__c
            FROM ZTS_EU_Account_Position__c 
            WHERE ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'
            AND ZTS_EU_Position__r.ZTS_EU_Employee__c =: intlUsr.Id
        ];
        for (ZTS_EU_Account_Position__c objPosition : accountPositions) {
            System.debug('objPos: ' + objPosition);
            System.assertEquals(
                6,
                objPosition.ZTS_EU_Days_Since_Last_Call_New__c,
                'Days Since Last Call should match Days between Today and Call Start'
            );
        }
    }
    
    @isTest
    static void updateLastCallDateFromColleagues_Delete_Test() {
        User intlUsr = [
            SELECT Id
            FROM User
            WHERE FirstName =: mainIntlUserFirstName AND ZTS_EU_Market__c = 'United Kingdom'
            LIMIT 1
        ];
        List<Call__c> callsList = new List<Call__c>();
        List<Call__c> callsToDelete = new List<Call__c>();
        List<Call__c> allCalls = new List<Call__c>();
        
        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        
        System.runAs(intlUsr) {
            Test.startTest();
            for (Account accObj : accounts) {
                for (Integer i = 0; i < 2; i++) {
                    Call__c call = TestDataFactory.createCall(accObj.Id, false);
                    if (i == 0) {
                        call.ZTS_EU_Start_Date_Time__c = System.today().addDays(-5);
                        callsList.add(call);
                    } else {
                        call.ZTS_EU_Start_Date_Time__c = System.today().addDays(-3);
                        callsToDelete.add(call);
                    }
                    allCalls.add(call);
                }
            }
            // insert calls
            insert allCalls;
            
            List<ZTS_EU_Colleague__c> colleagues = [SELECT Id FROM ZTS_EU_Colleague__c WHERE ZTS_EU_Call__c =: callsToDelete];
            // delete calls
            delete colleagues;
            Test.stopTest();
        }
        // after update, Last Call Date on all Account Positions should be updated to match the new Call Dates
        List<ZTS_EU_Account_Position__c> accountPositions = [
            SELECT Id, ZTS_EU_Days_Since_Last_Call_New__c
            FROM ZTS_EU_Account_Position__c 
            WHERE ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'
            AND ZTS_EU_Position__r.ZTS_EU_Employee__c =: intlUsr.Id
        ];
        for (ZTS_EU_Account_Position__c objPosition : accountPositions) {
            System.debug('objPos: ' + objPosition);
            System.assertEquals(
                6,
                objPosition.ZTS_EU_Days_Since_Last_Call_New__c,
                'Days Since Last Call should match Days between Today and Call Start'
            );
        }
    }
    
    @isTest
    static void updateLastCallDateFromColleagues_Insert_Test() {
        User intlUsr = [
            SELECT Id
            FROM User
            WHERE FirstName =: mainIntlUserFirstName AND ZTS_EU_Market__c = 'United Kingdom'
            LIMIT 1
        ];
        List<Call__c> callsList = new List<Call__c>();
        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        
        for (Account accObj : accounts) {
            Call__c call = TestDataFactory.createCall(accObj.Id, false);
            call.ZTS_EU_Start_Date_Time__c = System.now().addDays(-5);
            callsList.add(call);
        }
        
        // insert calls as the current User. Disable Trigger so no Colleagues are created
        DispatchTriggerHandler.bypass('CallTriggerHandler');
        insert callsList;
        DispatchTriggerHandler.clearBypass('CallTriggerHandler');
        
        List<ZTS_EU_Colleague__c> colleagues = new List<ZTS_EU_Colleague__c>();
        for (Call__c call : callsList) {
            colleagues.add(TestDataFactory.createColleague(call.Id, intlUsr.Id));
        }
        
        // insert Colleagues for the Test User
        Test.startTest();
        insert colleagues;
        Test.stopTest();
        
        // after update, Last Call Date on all Account Positions should be updated to match the new Call Dates
        List<ZTS_EU_Account_Position__c> accountPositions = [
            SELECT Id, ZTS_EU_Days_Since_Last_Call_New__c
            FROM ZTS_EU_Account_Position__c 
            WHERE ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'
            AND ZTS_EU_Position__r.ZTS_EU_Employee__c =: intlUsr.Id
        ];
        for (ZTS_EU_Account_Position__c objPosition : accountPositions) {
            System.debug('objPos: ' + objPosition);
            System.assertEquals(
                5,
                objPosition.ZTS_EU_Days_Since_Last_Call_New__c,
                'Days Since Last Call should match Days between Today and Call Start'
            );
        }
    }
    
    @isTest
    static void updateDaysSinceLastCalled_FutureDate_Test() {
        List<ZTS_EU_Account_Position__c> accountPositions = [
            SELECT Id, ZTS_EU_Employee_Id__c, ZTS_EU_Account__c
            FROM ZTS_EU_Account_Position__c 
            WHERE ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'
        ];
        
        Map<String, DateTime> colleagueMap = new Map<String, DateTime>();
        Datetime futureDate = System.now().addDays(1);
        for (ZTS_EU_Account_Position__c accountPosition : accountPositions) {
            colleagueMap.put(buildColleagueMapKey(accountPosition), futureDate);
        }
        
        Test.startTest();
        AccountPositionsService.updateDaysSinceLastCalled(accountPositions, colleagueMap);
        Test.stopTest();
        
        for (ZTS_EU_Account_Position__c accountPosition : accountPositions) {
            System.assertEquals(null, accountPosition.ZTS_EU_Days_Since_Last_Call_New__c,
                                'Days Since Last Call should be null when Latest Call Date is in the future');
        }
    }
    
    @isTest
    static void updateDaysSinceLastCalled_EmptyColleagueMap_Test() {
        List<ZTS_EU_Account_Position__c> accountPositions = [
            SELECT Id, ZTS_EU_Employee_Id__c, ZTS_EU_Account__c
            FROM ZTS_EU_Account_Position__c 
            WHERE ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'
        ];
        
        Map<String, DateTime> colleagueMap = new Map<String, DateTime>();
        
        Test.startTest();
        AccountPositionsService.updateDaysSinceLastCalled(accountPositions, colleagueMap);
        Test.stopTest();
        
        for (ZTS_EU_Account_Position__c accountPosition : accountPositions) {
            System.assertEquals(null, accountPosition.ZTS_EU_Days_Since_Last_Call_New__c,
                                'Days Since Last Call should be null when Colleague Map is empty');
        }
    }
    
    @isTest
    static void updateDaysSinceLastCalled_NoEmployee_Test() {
        List<Account> accounts = [SELECT Id FROM Account WHERE ZTS_EU_Market__c != 'United States'];
        system.assertEquals(MAX_ACCOUNTS, accounts.size(), 'More/Less Accounts returned than expected.');
        
        List<ZTS_EU_Account_Position__c> accountPositions = new List<ZTS_EU_Account_Position__c>();
        for (Account account : accounts) {
            accountPositions.add(TestDataFactory.createAccountPosition(account.Id, null, false));
        }
        
        insert accountPositions;
        
        Map<String, DateTime> colleagueMap = new Map<String, DateTime>();
        
        Test.startTest();
        AccountPositionsService.updateDaysSinceLastCalled(accountPositions, colleagueMap);
        Test.stopTest();
        
        for (ZTS_EU_Account_Position__c accountPosition : accountPositions) {
            System.assertEquals(null, accountPosition.ZTS_EU_Days_Since_Last_Call_New__c,
                                'Days Since Last Call should be null when Employee is null on the Account Position');
        }
    }
    
    @isTest
    static void setLeProgramOwnerToPrimaryForContractOwner_SingleContract_Test() {
        String testUserUsername = String.format(usUserNameTemplate, new List<Object> {0});
        
        Contract contract = [
            SELECT Id, AccountId, OwnerId
            FROM Contract
            WHERE Owner.UserName =: testUserUsername
            AND RecordTypeId =: contractNewContractRecordTypeId
            LIMIT 1];
        
        ZTS_EU_Account_Position__c accountPosition = [
            SELECT Id, LE_Program_Owner__c
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Account__c =: contract.AccountId
            AND ZTS_Employee_ID__c =: contract.OwnerId
            LIMIT 1];
        
        System.assertNotEquals('Primary', accountPosition.LE_Program_Owner__c,
                               'Sanity Check failed. LE Program Owner should not be Primary before Contract is updated');
        
        contract.Status = 'Proposal Approved';
        Test.startTest();
        update contract;
        Test.stopTest();
        
        accountPosition = [
            SELECT Id, LE_Program_Owner__c
            FROM ZTS_EU_Account_Position__c
            WHERE Id =: accountPosition.Id
            LIMIT 1];
        
        System.assertEquals('Primary', accountPosition.LE_Program_Owner__c,
                            'Program Owner should have changed to Primary after Contract was updated.');
    }
    
    @isTest
    static void setLeProgramOwnerToPrimaryForContractOwner_SingleContractIncorrectStatus_Test() {
        String testUserUsername = String.format(usUserNameTemplate, new List<Object> {0});
        
        Contract contract = [
            SELECT Id, AccountId, OwnerId
            FROM Contract
            WHERE Owner.UserName =: testUserUsername
            AND RecordTypeId =: contractNewContractRecordTypeId
            LIMIT 1];
        
        ZTS_EU_Account_Position__c accountPosition = [
            SELECT Id, LE_Program_Owner__c
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Account__c =: contract.AccountId
            AND ZTS_Employee_ID__c =: contract.OwnerId
            LIMIT 1];
        
        System.assertNotEquals('Primary', accountPosition.LE_Program_Owner__c,
                               'Sanity Check failed. LE Program Owner should not be Primary before Contract is updated');
        
        contract.Status = 'Approved';
        Test.startTest();
        update contract;
        Test.stopTest();
        
        accountPosition = [
            SELECT Id, LE_Program_Owner__c
            FROM ZTS_EU_Account_Position__c
            WHERE Id =: accountPosition.Id
            LIMIT 1];
        
        System.assertNotEquals('Primary', accountPosition.LE_Program_Owner__c,
                               'Program Owner should not have changed to Primary after Contract was updated.');
    }
    
    @isTest
    static void setLeProgramOwnerToPrimaryForContractOwner_SingleContractIncorrectRecordType_Test() {
        String testUserUsername = String.format(usUserNameTemplate, new List<Object> {0});
        
        Contract contract = [
            SELECT Id, AccountId, OwnerId
            FROM Contract
            WHERE Owner.UserName =: testUserUsername
            AND RecordTypeId =: contractActiveRecordTypeId
            LIMIT 1];
        
        ZTS_EU_Account_Position__c accountPosition = [
            SELECT Id, LE_Program_Owner__c
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Account__c =: contract.AccountId
            AND ZTS_Employee_ID__c =: contract.OwnerId
            LIMIT 1];
        
        System.assertNotEquals('Primary', accountPosition.LE_Program_Owner__c,
                               'Sanity Check failed. LE Program Owner should not be Primary before Contract is updated');
        
        contract.Status = 'Proposal Approved';
        Test.startTest();
        update contract;
        Test.stopTest();
        
        accountPosition = [
            SELECT Id, LE_Program_Owner__c
            FROM ZTS_EU_Account_Position__c
            WHERE Id =: accountPosition.Id
            LIMIT 1];
        
        System.assertNotEquals('Primary', accountPosition.LE_Program_Owner__c,
                               'Program Owner should not have changed to Primary after Contract was updated.');
    }
    
    @isTest
    static void setLeProgramOwnerToPrimaryForContractOwner_MultipleContracts_Test() {
        String userNameFilter = String.format(usUserNameTemplate, new List<Object> {'%'});
        
        List<Contract> contracts = [
            SELECT Id, AccountId, OwnerId
            FROM Contract
            WHERE Owner.UserName LIKE: userNameFilter
            AND RecordTypeId in: new List<String>{contractNewContractRecordTypeId, contractReadOnlyRecordTypeId}];
        
        System.assertEquals(MAX_USUSERS, contracts.size(), 'There should be one Contract per User');
        
        Set<String> accountIdOwnerCombos = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
        for (Contract contract : contracts) {
            contract.Status = 'Proposal Approved';
            accountIdOwnerCombos.add(String.format('{0}{1}', new List<Object>{contract.AccountId, contract.OwnerId}));
            accountIds.add(contract.AccountId);
            ownerIds.add(contract.OwnerId);
        }
        
        Test.startTest();
        update contracts;
        Test.stopTest();
        
        for (ZTS_EU_Account_Position__c accountPosition : [SELECT Id, LE_Program_Owner__c, ZTS_EU_Account__c, ZTS_Employee_ID__c
                                                           FROM ZTS_EU_Account_Position__c
                                                           WHERE ZTS_EU_Account__c in: accountIds
                                                           AND ZTS_Employee_ID__c in: ownerIds]) {
                                                               string accountIdOwnerCombo = string.format('{0}{1}',
                                                                                                          new List<Object> {accountPosition.ZTS_EU_Account__c, accountPosition.ZTS_Employee_ID__c});
                                                               
                                                               if (accountIdOwnerCombos.contains(accountIdOwnerCombo)) {
                                                                   System.assertEquals('Primary', accountPosition.LE_Program_Owner__c,
                                                                                       'Program Owner should have changed to Primary after Contract was updated.');
                                                               }
                                                               else {
                                                                   System.assertNotEquals('Primary', accountPosition.LE_Program_Owner__c,
                                                                                          'Program Owner should not have changed to Primary after Contract was updated.');
                                                               }
                                                           }
    }
    
    @isTest
    static void mergeRelatedAccountPositionsByAccountAndPosition_NoData_Test() {
        Exception errorOccurred;
        Map<Id, ZTS_EU_Account_Position__c> deletePositionMap;
        Test.startTest();
        try {
            deletePositionMap = runMergeRelatedAccountPositionsByAccountAndPosition(new Set<Id>(),
                                                                                    new MergeService.UpdateRelatedRecordsMap());
        }
        catch (Exception e) {
            errorOccurred = e;
        }
        Test.stopTest();
        
        system.assertEquals(null, errorOccurred, String.format('An unexpected error occurred: {0}',
                                                               new List<String> {errorOccurred?.getMessage()}));
        
        system.assert(deletePositionMap.isEmpty(), String.format('Unexpected Values in Delete Position Map {0}',
                                                                 new List<Object> {deletePositionMap}));
    }
    
    @isTest
    static void mergeRelatedAccountPositionsByAccountAndPosition_NoAccountPositions_Test() {
        State_Country__c stateCountryUk = [
            SELECT ID
            FROM State_Country__c
            WHERE Name =: ukStateCountryName
            LIMIT 1];
        
        Account account = TestDataFactory.createAccount_EU('Test UK no APs 1', stateCountryUk.Id, false);
        insert account;
        
        Exception errorOccurred;
        Map<Id, ZTS_EU_Account_Position__c> deletePositionMap;
        Test.startTest();
        try {
            deletePositionMap = runMergeRelatedAccountPositionsByAccountAndPosition(new Set<Id>{account.Id},
                                                                                    new MergeService.UpdateRelatedRecordsMap());
        }
        catch (Exception e) {
            errorOccurred = e;
        }
        Test.stopTest();
        
        system.assertEquals(null, errorOccurred, String.format('An unexpected error occurred: {0}',
                                                               new List<String> {errorOccurred?.getMessage()}));
        
        system.assert(deletePositionMap.isEmpty(), String.format('Unexpected Values in Delete Position Map {0}',
                                                                 new List<Object> {deletePositionMap}));
    }
    
    // This test uses an Account with unique Account Positions with correct keys. 
    // As a result, no Account Positions should be deleted and no records should be updated.
    @isTest
    static void mergeRelatedAccountPositionsByAccountAndPosition_UniqueAccountPositions_Test() {
        Account testAccount = [
            SELECT Id
            FROM Account
            WHERE Name =: intlAccountUniqueAccountPositions
            LIMIT 1
        ];
        
        Map<Id, ZTS_EU_Account_Position__c> deletePositionMap;
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();
        Test.startTest();
        deletePositionMap = runMergeRelatedAccountPositionsByAccountAndPosition(new Set<Id>{testAccount.Id},
                                                                                updateRelatedRecordsMap);
        Test.stopTest();
        
        system.assert(deletePositionMap.isEmpty(), String.format('Unexpected Values in Delete Position Map {0}',
                                                                 new List<Object> {deletePositionMap}));
        
        system.assert(updateRelatedRecordsMap.updateRecordsMapByName.isEmpty(), String.format(
            'Unexpected values in updateRelatedRecordsMap {0}', new List<Object> {updateRelatedRecordsMap}));
    }
    
    @isTest
    static void mergeRelatedAccountPositionsByAccountAndPosition_MultipleAccountPositions_Test() {
        Account testAccount = [
            SELECT Id
            FROM Account
            WHERE Name =: intlAccountDuplicateAccountPositions
            LIMIT 1
        ];
        
        Map<Id, ZTS_EU_Account_Position__c> updateOrDeletePositionsById = new Map<Id, ZTS_EU_Account_Position__c>();
        ZTS_EU_Account_Position__c keepEccAccountPosition;
        Date compareDate = accountPositionNewerCreatedDate.dateGMT();
        
        for (ZTS_EU_Account_Position__c accountPosition : [
            SELECT Id, ZTS_EU_Account__c, ZTS_AccountUserTerrUniqueKey__c, Uniqueness_Key__c, ZTS_EU_Position__c, CreatedDate,
            ZTS_EU_Position__r.ZTS_EU_Employee__r.FirstName, ZTS_EU_Call_Target__c, ZTS_EU_Active__c
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Account__c =: testAccount.Id]) {
                
                // Accounts with Incorrect Unique keys will either be updated or deleted.
                if (String.isNotBlank(accountPosition.ZTS_AccountUserTerrUniqueKey__c) &&
                    !accountPosition.ZTS_AccountUserTerrUniqueKey__c.contains(accountPosition.ZTS_EU_Account__c)) {
                        updateOrDeletePositionsById.put(accountPosition.Id, accountPosition);
                    }
                // The Account Position with a Created Date of 8 days ago will be deleted.
                // There is an older duplicate Account Position with the same information.
                else if (accountPosition.CreatedDate.dateGMT() == compareDate) {
                    updateOrDeletePositionsById.put(accountPosition.Id, accountPosition);
                }
                // The Account Position for User 1 with a correct Unique Key will have the ECC for its matching record
                // transfered to it.
                else if (accountPosition.ZTS_EU_Position__r.ZTS_EU_Employee__r.FirstName.contains(intlUser1FirstName) &&
                         accountPosition.ZTS_AccountUserTerrUniqueKey__c.contains(accountPosition.ZTS_EU_Account__c)) {
                             keepEccAccountPosition = accountPosition;
                         }
                // The Account Position for User 3 without a Call Target will be deleted. 
                // Its matching Account Position has a Call Target and will be kept.
                else if (accountPosition.ZTS_EU_Position__r.ZTS_EU_Employee__r.FirstName.contains(intlUser3FirstName) && 
                         accountPosition.ZTS_EU_Call_Target__c == null) {
                             updateOrDeletePositionsById.put(accountPosition.Id, accountPosition);
                         }
                // The inactive Account Position will be deleted.
                // It's Call Target will be transfered to the matching Account
                else if (accountPosition.ZTS_EU_Active__c == false) {
                    updateOrDeletePositionsById.put(accountPosition.Id, accountPosition);
                }
            }
        
        Map<Id, ZTS_EU_Account_Position__c> deletePositionMap;
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();
        Test.startTest();
        deletePositionMap = runMergeRelatedAccountPositionsByAccountAndPosition(new Set<Id>{testAccount.Id},
                                                                                updateRelatedRecordsMap);
        Test.stopTest();
        
        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.containsKey('ZTS_EU_Account_Position__c'),
                      'No Account Positions were updated.');
        
        Map<Id, SObject> updatedAccountPositionsById = updateRelatedRecordsMap.updateRecordsMapByName.get('ZTS_EU_Account_Position__c');
        System.assertEquals(1, updatedAccountPositionsById.size(), 'More/less Account Positions were updated than expected.');
        
        ZTS_EU_Account_Position__c updatedAccountPosition = (ZTS_EU_Account_Position__c)updatedAccountPositionsById.Values()[0];
        Id updatedAccountPositionAccountId = updateOrDeletePositionsById.get(updatedAccountPosition.Id).ZTS_EU_Account__c;
        System.assert(updatedAccountPosition.ZTS_AccountUserTerrUniqueKey__c?.contains(updatedAccountPositionAccountId),
                      String.format(
                          'Account Position does not have the current Account specified in ZTS_AccountUserTerrUniqueKey__c: {0}', 
                          new List<Object> {updatedAccountPositionAccountId}));
        
        System.assert(updatedAccountPosition.Uniqueness_Key__c?.contains(updatedAccountPositionAccountId),
                      String.format(
                          'Account Position does not have the current Account specified in Uniqueness_Key__c: {0}', 
                          new List<Object> {updatedAccountPositionAccountId}));
        
        System.assert(updateOrDeletePositionsById.containsKey(updatedAccountPosition.Id), String.format(
            'Account Position {0} was updated unexpectedly. Expected updated/deleted Ids: {1}',
            new List<Object> {updatedAccountPosition.Id, String.join(
                (List<String>)(new List<Id>(updateOrDeletePositionsById.keySet())), ', ')}));
        
        System.assertEquals(4, deletePositionMap.size(), 'More/less Account Positions deleted than expected.');
        
        for (Id deletedAccountPositionId : deletePositionMap.keySet()) {
            System.assert(updateOrDeletePositionsById.containsKey(deletedAccountPositionId), String.format( 
                'Account Position {0} was deleted unexpectedly. Expected deleted Ids: {1}',
                new List<Object> {deletedAccountPositionId, 
                    String.join((List<String>)(new List<Id>(updateOrDeletePositionsById.keySet())), ', ')}));
        }
        
        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.containsKey('ZTS_EU_Employee_Call_Credit__c'),
                      'Employee Call Credit was not updated as my expected.');
        
        Map<Id, SObject> updatedCallCredits = updateRelatedRecordsMap.updateRecordsMapByName.get(
            'ZTS_EU_Employee_Call_Credit__c');
        
        System.assertEquals(1, updatedCallCredits.size(), 
                            'More/Less Employee Call Credits created than expected.');
        
        System.assertEquals(keepEccAccountPosition.Id, 
                            ((ZTS_EU_Employee_Call_Credit__c)updatedCallCredits.values()[0]).ZTS_EU_Account_Position__c,
                            'Unexpected Account Position set on updated Employee Call Credit');
    }
    
    @isTest
    static void mergeRelatedAccountPositionsByAccountAndPosition_MultipleAccounts_Test() {
        Account multipleDuplicatesAccount;
        Account singleDuplicateAccount;
        Set<Id> accountIds = new Set<Id>();
        for (Account account :[
            SELECT Id, Name
            FROM Account
            WHERE Name In: new List<String>{intlAccountDuplicateAccountPositions, intlAccountAdditionalDuplicateTest}
        ]) {
            if (account.Name == intlAccountDuplicateAccountPositions) {
                multipleDuplicatesAccount = account;
            }
            else {
                singleDuplicateAccount = account;
            }
            
            accountIds.add(account.Id);
        }
        
        Map<Id, ZTS_EU_Account_Position__c> updateOrDeletePositionsById = new Map<Id, ZTS_EU_Account_Position__c>();
        ZTS_EU_Account_Position__c keepEccAccountPosition;
        Date compareDate = accountPositionNewerCreatedDate.dateGMT();
        
        for (ZTS_EU_Account_Position__c accountPosition : [
            SELECT Id, ZTS_EU_Account__c, ZTS_AccountUserTerrUniqueKey__c, Uniqueness_Key__c, ZTS_EU_Position__c, CreatedDate,
            ZTS_EU_Position__r.ZTS_EU_Employee__r.FirstName, ZTS_EU_Call_Target__c, ZTS_EU_Active__c
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Account__c in: accountIds]) {      
                
                // Accounts with Incorrect Unique keys will either be updated or deleted.
                Id accountId = accountPosition.ZTS_EU_Account__c;
                if ((String.isNotBlank(accountPosition.ZTS_AccountUserTerrUniqueKey__c) &&
                     !accountPosition.ZTS_AccountUserTerrUniqueKey__c.contains(accountId)) ||
                    (String.isNotBlank(accountPosition.Uniqueness_Key__c) &&
                     !accountPosition.Uniqueness_Key__c.contains(accountId))) {
                         updateOrDeletePositionsById.put(accountPosition.Id, accountPosition);
                     }
                // The Account Position with a Created Date of 8 days ago will be deleted.
                // There is an older duplicate Account Position with the same information.
                else if (accountPosition.CreatedDate.dateGMT() == compareDate) {
                    updateOrDeletePositionsById.put(accountPosition.Id, accountPosition);
                }
                // The Account Position for User 1 with a correct Unique Key will have the ECC for its matching record
                // transfered to it.
                else if (accountId == multipleDuplicatesAccount.Id && 
                         accountPosition.ZTS_EU_Position__r.ZTS_EU_Employee__r.FirstName.contains(intlUser1FirstName) &&
                         accountPosition.ZTS_AccountUserTerrUniqueKey__c.contains(accountId)) {
                             keepEccAccountPosition = accountPosition;
                         }
                // THe inactive Account Position will be deleted as it is a duplicate of another Account Position
                else if (accountId == multipleDuplicatesAccount.Id &&
                         accountPosition.ZTS_EU_Active__c == false) {
                             updateOrDeletePositionsById.put(accountPosition.Id, accountPosition);
                         }
                // The Account Position for User 3 without a Call Target or a Call Target of 0 will be deleted. 
                // Its matching Account Position has a Call Target and will be kept.
                else if (accountPosition.ZTS_EU_Position__r.ZTS_EU_Employee__r.FirstName.contains(intlUser3FirstName) && 
                         (accountPosition.ZTS_EU_Call_Target__c == null || accountPosition.ZTS_EU_Call_Target__c == 0)) {
                             updateOrDeletePositionsById.put(accountPosition.Id, accountPosition);
                         }
            }
        
        Map<Id, ZTS_EU_Account_Position__c> deletePositionMap;
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap = new MergeService.UpdateRelatedRecordsMap();
        Test.startTest();
        deletePositionMap = runMergeRelatedAccountPositionsByAccountAndPosition(accountIds,
                                                                                updateRelatedRecordsMap);
        Test.stopTest();
        
        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.containsKey('ZTS_EU_Account_Position__c'),
                      'No Account Positions were updated.');
        
        Map<Id, SObject> updatedAccountPositionsById = updateRelatedRecordsMap.updateRecordsMapByName.get('ZTS_EU_Account_Position__c');
        System.assertEquals(2, updatedAccountPositionsById.size(), 'More/less Account Positions were updated than expected.');
        
        for (SObject updatedRecord : updatedAccountPositionsById.Values()) {
            ZTS_EU_Account_Position__c updatedAccountPosition = (ZTS_EU_Account_Position__c)updatedRecord;
            Id updatedAccountPositionAccountId = updateOrDeletePositionsById.get(updatedAccountPosition.Id).ZTS_EU_Account__c;
            
            // One of the updated Account Positions will not have ZTS_AccountUserTerrUniqueKey__c specified
            if (String.isNotBlank(updatedAccountPosition.ZTS_AccountUserTerrUniqueKey__c)) {
                System.assert(updatedAccountPosition.ZTS_AccountUserTerrUniqueKey__c?.contains(updatedAccountPositionAccountId),
                              String.format(
                                  'Account Position does not have the current Account specified in ZTS_AccountUserTerrUniqueKey__c: {0}', 
                                  new List<Object> {updatedAccountPositionAccountId}));
            }
            
            System.assert(updatedAccountPosition.Uniqueness_Key__c?.contains(updatedAccountPositionAccountId),
                          String.format(
                              'Account Position does not have the current Account specified in Uniqueness_Key__c: {0}', 
                              new List<Object> {updatedAccountPositionAccountId}));
            
            System.assert(updateOrDeletePositionsById.containsKey(updatedAccountPosition.Id), String.format(
                'Account Position {0} was updated unexpectedly. Expected updated/deleted Ids: {1}',
                new List<Object> {updatedAccountPosition.Id, String.join(
                    (List<String>)(new List<Id>(updateOrDeletePositionsById.keySet())), ', ')}));
        }
        
        System.assertEquals(6, deletePositionMap.size(), 'More/less Account Positions deleted than expected.');
        
        for (Id deletedAccountPositionId : deletePositionMap.keySet()) {
            System.assert(updateOrDeletePositionsById.containsKey(deletedAccountPositionId), String.format( 
                'Account Position {0} was deleted unexpectedly. Expected deleted Ids: {1}',
                new List<Object> {deletedAccountPositionId, 
                    String.join((List<String>)(new List<Id>(updateOrDeletePositionsById.keySet())), ', ')}));
        }
        
        System.assert(updateRelatedRecordsMap.updateRecordsMapByName.containsKey('ZTS_EU_Employee_Call_Credit__c'),
                      'Employee Call Credit was not updated as my expected.');
        
        Map<Id, SObject> updatedCallCredits = updateRelatedRecordsMap.updateRecordsMapByName.get(
            'ZTS_EU_Employee_Call_Credit__c');
        
        System.assertEquals(1, updatedCallCredits.size(), 
                            'More/Less Employee Call Credits created than expected.');
        
        System.assertEquals(keepEccAccountPosition.Id, 
                            ((ZTS_EU_Employee_Call_Credit__c)updatedCallCredits.values()[0]).ZTS_EU_Account_Position__c,
                            'Unexpected Account Position set on updated Employee Call Credit');
    }
    
    private static string buildColleagueMapKey(ZTS_EU_Account_Position__c accountPosition) {
        return string.format('{0}{1}', new List<String> {
            accountPosition.ZTS_EU_Employee_Id__c, accountPosition.ZTS_EU_Account__c
                });
    }
    
    private static Map<Id, ZTS_EU_Account_Position__c> runMergeRelatedAccountPositionsByAccountAndPosition(
        Set<Id> accountIds, MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap) {
            return AccountPositionsService.mergeRelatedAccountPositionsByAccountAndPosition(accountIds, 
                                                                                            new Map<String, MergeRelatedRecordLookupsSelector.ChildObject>{
                                                                                                'ZTS_EU_Employee_Call_Credit__c' => new MergeRelatedRecordLookupsSelector.ChildObject('ZTS_EU_Employee_Call_Credit__c', null)
                                                                                                    }, updateRelatedRecordsMap);
        }
}