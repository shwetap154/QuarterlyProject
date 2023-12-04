/**
 * @description       : Test Classes and Assertions for Sub Type Translation Batch
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 02-16-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   02-11-2021   Morgan Marchese @ Zoetis Inc   Initial Version
**/
@isTest
private class ZTS_EU_UpdateCallSubTypeTest {
  private static final Integer MAX_ACCOUNTS = 20;
  private static final String UNTRANSLATABLE = 'Not Translated Value';
  @testSetup
  static void setup() {
      DispatchTriggerHandler.bypass('AccountTriggerHandler');
      DispatchTriggerHandler.bypass('CallTriggerHandler');
    User intlUsr = new User();
    intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile(
      'System Administrator',
      false
    );
    intlUsr.FirstName = 'IntUser';
    intlUsr.ZTS_EU_Market__c = 'United Kingdom';
    insert intlUsr;
    System.runAs(intlUsr) {
      ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
      List<State_Country__c> stateCountryList = new List<State_Country__c>();
      List<Account> accountList = new List<Account>();
      List<Call__c> callList = new List<Call__c>();
      State_Country__c stateCountryUK = TestDataFactory.createStateCountry(
        'United Kingdom',
        'County Down',
        false
      );
      stateCountryList.add(stateCountryUK);
      insert stateCountryList;

      System.debug('State Country UK ID: ' + stateCountryUK.Id);

      // create MAX_ACCOUNTS accounts
      for (Integer i = 0; i < MAX_ACCOUNTS; i++) {
        accountList.add(
          TestDataFactory.createAccount_EU(
            'Account ' + i,
            stateCountryUK.Id,
            false
          )
        );
      }

      insert accountList;

      // create one new call for each Account in accountList
      for (Account record : accountList) {
        callList.add(
          new Call__c(
            name = 'Training',
            ZTS_EU_Call_Objectives__c = 'Training',
            ZTS_EU_SUB_TYPE__C = 'Entrenamiento / Capacitaciones',
            ZTS_EU_Account__c = record.id
          )
        );

        callList.add(
          new Call__c(
            name = 'Account Call',
            ZTS_EU_Call_Objectives__c = 'Account Call',
            ZTS_EU_SUB_TYPE__C = 'Kundenbesuch',
            ZTS_EU_Account__c = record.id
          )
        );

        callList.add(
          new Call__c(
            name = 'Order',
            ZTS_EU_Call_Objectives__c = 'Order',
            ZTS_EU_SUB_TYPE__C = 'Pedido',
            ZTS_EU_Account__c = record.id
          )
        );
        callList.add(
          new Call__c(
            name = 'Phone Call',
            ZTS_EU_Call_Objectives__c = 'Phone Call',
            ZTS_EU_SUB_TYPE__C = 'Telefon',
            ZTS_EU_Account__c = record.id
          )
        );
        callList.add(
          new Call__c(
            name = 'Event Account Call',
            ZTS_EU_Call_Objectives__c = 'Event Account Call',
            ZTS_EU_SUB_TYPE__C = 'Veranstaltung',
            ZTS_EU_Account__c = record.id
          )
        );
        callList.add(
          new Call__c(
            name = 'Advisory / Diagnostic visit',
            ZTS_EU_Call_Objectives__c = 'Advisory / Diagnostic visit',
            ZTS_EU_SUB_TYPE__C = 'Visita Técnica / Diagnóstico',
            ZTS_EU_Account__c = record.id
          )
        );
        callList.add(
          new Call__c(
            name = 'Re-active - Complaint Visit',
            ZTS_EU_Call_Objectives__c = 'Re-active - Complaint Visit',
            ZTS_EU_SUB_TYPE__C = 'クレーム対応',
            ZTS_EU_Account__c = record.id
          )
        );
        callList.add(
          new Call__c(
            name = 'ICP / DMA visit',
            ZTS_EU_Call_Objectives__c = 'ICP / DMA visit',
            ZTS_EU_SUB_TYPE__C = '院内セミナー(CA)',
            ZTS_EU_Account__c = record.id
          )
        );

        callList.add(
          new Call__c(
            name = 'Account Call',
            ZTS_EU_Call_Objectives__c = 'Account Call',
            ZTS_EU_SUB_TYPE__C = UNTRANSLATABLE,
            ZTS_EU_Account__c = record.id
          )
        );
      }
      insert callList;
    }
      DispatchTriggerHandler.clearbypass('AccountTriggerHandler');
      DispatchTriggerHandler.clearbypass('CallTriggerHandler');
  }

  static testMethod void executeBatch_Test() {
    List<Account> accounts = [SELECT Id FROM Account];
    System.assertEquals(
      MAX_ACCOUNTS,
      accounts.size(),
      'We should have a total # of accounts equal to MAX_ACCOUNTS'
    );
    List<Call__c> calls = [
      SELECT Id, Name, ZTS_EU_Sub_Type__c, ZTS_EU_Call_Objectives__c
      FROM Call__c
    ];
    System.assertEquals(
      MAX_ACCOUNTS * 9,
      calls.size(),
      'We should have a total # of accounts equal to MAX_ACCOUNTS * total calls created per account'
    );
    for (Call__c record : calls) {
      System.assertNotEquals(
        record.ZTS_EU_Call_Objectives__c,
        record.ZTS_EU_Sub_Type__c,
        'Before Translation, the Values should be different'
      );
    }
    Test.startTest();
    ZTS_EU_UpdateCallSubType uca = new ZTS_EU_UpdateCallSubType();
    Id batchId = Database.executeBatch(uca);
    Test.stopTest();
    calls = [
      SELECT Id, Name, ZTS_EU_Sub_Type__c, ZTS_EU_Call_Objectives__c
      FROM Call__c
    ];
    for (Call__c record : calls) {
      if (record.ZTS_EU_Sub_Type__c == 'Not Translated Value') {
        System.assertNotEquals(
          record.ZTS_EU_Call_Objectives__c,
          record.ZTS_EU_Sub_Type__c,
          'After Translation, this value should not change because its not in the translation map'
        );
      } else {
        System.assertEquals(
          record.ZTS_EU_Call_Objectives__c,
          record.ZTS_EU_Sub_Type__c,
          'After Translation, the values should be changed from local language to US language versions'
        );
      }
    }
  }

  static testMethod void errorHandling_Test() {
    List<Account> accounts = [SELECT Id FROM Account];
    System.assertEquals(
      MAX_ACCOUNTS,
      accounts.size(),
      'We should have a total # of accounts equal to MAX_ACCOUNTS'
    );
    List<Call__c> calls = [
      SELECT Id, Name, ZTS_EU_Sub_Type__c, ZTS_EU_Call_Objectives__c
      FROM Call__c
    ];
    System.assertEquals(
      MAX_ACCOUNTS * 9,
      calls.size(),
      'We should have a total # of accounts equal to MAX_ACCOUNTS * total calls created per account'
    );
    for (Call__c record : calls) {
      System.assertNotEquals(
        record.ZTS_EU_Call_Objectives__c,
        record.ZTS_EU_Sub_Type__c,
        'Before Translation, the Values should be different'
      );
    }
    Test.startTest();
    ZTS_EU_UpdateCallSubType.mockDMLError = true;
    ZTS_EU_UpdateCallSubType uca = new ZTS_EU_UpdateCallSubType();
    Id batchId = Database.executeBatch(uca);
    Test.stopTest();
    List<ZTS_EU_Error_Log__c> errorLogs = [SELECT Id FROM ZTS_EU_Error_Log__c];
    
    // Get List of all Calls that should have been Translated
    calls = [SELECT Id FROM Call__c WHERE ZTS_EU_Sub_Type__c != :UNTRANSLATABLE];
    // Assert that each record failed DML but was caught/logged. (Call Size + 1 because the Finish Method outputs a log too)
     System.assertEquals(calls.size()+1, errorLogs.size(),'All Calls should have failed DML and been caught with Error Records');
  }
}