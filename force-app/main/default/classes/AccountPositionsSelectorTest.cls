/**
 * @description       : Test class for AccountPositionsSelector
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 09-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   01-25-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   04-07-2022   Ethan Hirsch @ Zoetis Inc      Update existing tests to work with the Selector class inheriting fflib_SObjectSelector
 * 1.2   04-13-2022   Ethan Hirsch @ Zoetis Inc      Add Unit Tests for selectByAccountIdsAndEmployeeIdsAndMarket method.
 * 1.3   05-25-2022   Ethan Hirsch @ Zoetis Inc      Add Unit Tests for selectByAccountIdWithRelatedData method.
 * 1.4   07-11-2022   Ethan Hirsch @ Zoetis Inc      Change input within selectByAccountIdWithRelatedData_Test for the selectByAccountIdWithRelatedData method
 * 1.5   09-19-2022   Ethan Hirsch @ Zoetis Inc      Update selectByAccountIdWithRelatedData_Test to change the output 
 *                                                   type of selectByAccountIdWithRelatedData.
 **/
@isTest
private class AccountPositionsSelectorTest {
  private static final Integer MAX_ACCOUNTS = 5;
  private static final String intlUserFirstName = 'IntUser';

  @TestSetup
  static void setup() {
    User intlUsr = new User();
    intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile(
      'System Administrator',
      false
    );
    intlUsr.FirstName = intlUserFirstName;
    intlUsr.ZTS_EU_Market__c = 'United Kingdom';
    insert intlUsr;

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

    System.runAs(intlUsr) {
      // Create Zoetis Global Custom Territories, related to Standard Territories
      ZTS_EU_Territory__c ztsTerritoryUK = TestDataFactory.createZTSTerritory(
        'TestTerritoryUK',
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
        ztsTerritoryUS
      };
      insert ztsTerritoryList;

      // Create Zoetis Global Positions, related to Global Custom Territories
      List<ZTS_EU_Position__c> positionList = new List<ZTS_EU_Position__c>();
      for (ZTS_EU_Territory__c record : ztsTerritoryList) {
        ZTS_EU_Position__c tempPosition = TestDataFactory.createPosition(
          record.Name,
          record.Id,
          record.ZTS_EU_Market__c,
          intlUsr.Id,
          false
        );

        positionList.add(tempPosition);
      }
      insert positionList;

      ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
      List<State_Country__c> stateCountryList = new List<State_Country__c>();
      List<Account> accountList = new List<Account>();
      TestDataFactory.createVetSaveMarket_UK('United Kingdom', true);

      State_Country__c stateCountryUK = TestDataFactory.createStateCountry(
        'United Kingdom',
        'County Down',
        false
      );
      stateCountryList.add(stateCountryUK);
      insert stateCountryList;

      // Create Test Accounts with different Markets
      for (Integer i = 0; i < MAX_ACCOUNTS; i++) {
        Account acct = TestDataFactory.createAccount_EU(
          'UK Test Account ' + i,
          stateCountryUK.Id,
          false
        );
        accountList.add(acct);
      }
      for (Integer i = 0; i < MAX_ACCOUNTS; i++) {
        Account acct = TestDataFactory.createAccount_US(
          'US Test Account ' + i,
          false
        );
        accountList.add(acct);
      }
      // When an Employee Id is specified, an Account Position is created when an Account and Account Territory is inserted
      // This causes duplicate records to be created.
      DispatchTriggerHandler.bypass('AccountTriggerHandler');
      insert accountList;
      DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

      List<ZTS_AccountTerritory__c> accountTerritoryList = new List<ZTS_AccountTerritory__c>();
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
        accountTerritoryList.add(tempTerritory);
      }
      
      insert accountTerritoryList;
      
    }
  }
  @IsTest
  static void getRecordListByAcctTerritoryId_INTL_Test() {
    IAccountPositionsSelector selector = AccountPositionsSelector.newInstance();

    User contextUser = new User(Id = UserInfo.getUserId());
    List<Account> accounts = [
      SELECT Id
      FROM Account
      WHERE ZTS_EU_Market__c != 'United States'
    ];
    System.assertEquals(
      MAX_ACCOUNTS,
      accounts.size(),
      'We should find all of the created accounts from Setup'
    );
    Test.startTest();
    Map<Id, ZTS_AccountTerritory__c> accountTerritoryMap = new Map<Id, ZTS_AccountTerritory__c>(
      [
        SELECT Id, ZTS_EU_Market__c
        FROM ZTS_AccountTerritory__c
        WHERE ZTS_EU_Account__c IN :accounts
      ]
    );
    for (ZTS_AccountTerritory__c record : accountTerritoryMap.values()) {
      System.debug('Record Market: ' + record.ZTS_EU_Market__c);
    }
    System.assertEquals(
      accounts.size(),
      accountTerritoryMap.size(),
      'Each International Account Should Have One Account Territory'
    );
    System.runAs(contextuser) {
      System.debug('territory size: ' + accountTerritoryMap.size());
      List<ZTS_EU_Account_Position__c> recordList = selector.selectByAcctTerritoryId(
        accountTerritoryMap.keySet(),
        true
      );
      for (ZTS_EU_Account_Position__c record : recordList) {
        System.debug('Position: ' + record);
      }
      System.assertEquals(
        accounts.size(),
        recordList.size(),
        'The International Account List Size should match the Account Position List Size'
      );
      recordList = selector.selectByAcctTerritoryId(
        accountTerritoryMap.keySet(),
        false
      );
      System.assertEquals(
        0,
        recordList.size(),
        'The US Record List Should Be Empty'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void getRecordListByAcctTerritoryId_US_Test() {
    IAccountPositionsSelector selector = AccountPositionsSelector.newInstance();

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
      'Each US Account Should Have One Account Territory'
    );
    System.runAs(contextuser) {
      List<ZTS_EU_Account_Position__c> recordList = selector.selectByAcctTerritoryId(
        accountTerritoryMap.keySet(),
        false
      );
      System.assertEquals(
        accounts.size(),
        recordList.size(),
        'The US Account List Size should match the Account Position List Size'
      );
      recordList = selector.selectByAcctTerritoryId(
        accountTerritoryMap.keySet(),
        true
      );
      System.assertEquals(
        0,
        recordList.size(),
        'The International Record List Should Be Empty'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void getRecordListByAccountIds_Test() {
    integer totalAccountsCount = MAX_ACCOUNTS * 2;
    Set<Id> accountIds = new Map<Id, Account>([
      SELECT Id
      FROM Account
      LIMIT :totalAccountsCount
    ]).keySet();
    
    System.assertEquals(totalAccountsCount, accountIds.size(),
      'We should find all of the created accounts from Setup');

    List<ZTS_EU_Account_Position__c> accountPositions =
      AccountPositionsSelector.newInstance().selectByAccountIds(accountIds);

    system.assertEquals(totalAccountsCount, accountPositions.size(), 
      'There should be one Account Position per Account');
  }

  @isTest
  static void getRecordListByAccountIdsAndEmployeeIds_Test() {
    integer totalAccountsCount = MAX_ACCOUNTS * 2;
    Set<Id> accountIds = new Map<Id, Account>([
      SELECT Id
      FROM Account
      LIMIT :totalAccountsCount
    ]).keySet();

    Id employeeId = [
      SELECT Id 
      FROM User
      WHERE FirstName =: intlUserFirstName
      ORDER BY CREATEDDATE DESC
      LIMIT 1].Id;
    
    System.assertEquals(totalAccountsCount, accountIds.size(),
      'We should find all of the created accounts from Setup');

    List<ZTS_EU_Account_Position__c> accountPositions = 
      AccountPositionsSelector.newInstance().selectByAccountIdsAndEmployeeIds(
        accountIds, new Set<Id> {employeeId});

    system.assertEquals(totalAccountsCount, accountPositions.size(), 
      'There should be one Account Position per Account');
  }

  @isTest
  static void selectByAccountIdsAndEmployeeIdsAndMarket_UnitedStates_Test() {
    integer totalAccountsCount = MAX_ACCOUNTS * 2;
    Set<Id> accountIds = new Map<Id, Account>([
      SELECT Id
      FROM Account
      LIMIT :totalAccountsCount
    ]).keySet();

    Id employeeId = [
      SELECT Id 
      FROM User
      WHERE FirstName =: intlUserFirstName
      ORDER BY CREATEDDATE DESC
      LIMIT 1].Id;
    
    System.assertEquals(totalAccountsCount, accountIds.size(),
      'We should find all of the created accounts from Setup');

    Test.startTest();
      List<ZTS_EU_Account_Position__c> accountPositions = 
        AccountPositionsSelector.newInstance().selectByAccountIdsAndEmployeeIdsAndMarket(
          accountIds, new Set<Id> {employeeId}, true);
    Test.stopTest();

    system.assertEquals(totalAccountsCount / 2, accountPositions.size(), 
      'There should be one Account Position per Account per Market');
  }

  @isTest
  static void selectByAccountIdsAndEmployeeIdsAndMarket_INTL_Test() {
    integer totalAccountsCount = MAX_ACCOUNTS * 2;
    Set<Id> accountIds = new Map<Id, Account>([
      SELECT Id
      FROM Account
      LIMIT :totalAccountsCount
    ]).keySet();

    Id employeeId = [
      SELECT Id 
      FROM User
      WHERE FirstName =: intlUserFirstName
      ORDER BY CREATEDDATE DESC
      LIMIT 1].Id;
    
    System.assertEquals(totalAccountsCount, accountIds.size(),
      'We should find all of the created accounts from Setup');

    Test.startTest();
      List<ZTS_EU_Account_Position__c> accountPositions = 
        AccountPositionsSelector.newInstance().selectByAccountIdsAndEmployeeIdsAndMarket(
          accountIds, new Set<Id> {employeeId}, false);
    Test.stopTest();

    system.assertEquals(totalAccountsCount / 2, accountPositions.size(), 
      'There should be one Account Position per Account per Market');
  }

  @isTest
  static void selectByAccountIdWithRelatedData_Test() {
    integer totalAccountsCount = MAX_ACCOUNTS * 2;
    Set<Id> accountIds = new Map<Id, Account>([
      SELECT Id
      FROM Account
      LIMIT :totalAccountsCount
    ]).keySet();

    List<MergeService.MergeChildRelationship> childRelationships = new List<MergeService.MergeChildRelationship>();
    for (Schema.ChildRelationship childRelationship : Schema.ZTS_EU_Account_Position__c.sObjectType.getDescribe().getChildRelationships()) {
      if (childRelationship.getRelationshipName() == 'Employee_Call_Credits__r') {
        childRelationships.add(new MergeService.MergeChildRelationship(childRelationship, null));
        break;
      }
    }

    Test.startTest();
      Map<Id, MergeService.RecordAndRelationships> accountPositions = 
        AccountPositionsSelector.newInstance().selectByAccountIdWithRelatedData(accountIds, childRelationships);
    Test.stopTest();

    system.assertEquals(totalAccountsCount, accountPositions.size(), 'There should be one Account Position per Account.');
  }
}