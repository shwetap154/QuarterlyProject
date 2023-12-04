/**
 * @description       : Test Class for AddressesSelector
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 09-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-14-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   03-24-2022   Ethan Hirsch @ Zoetis Inc      Add selectDirectActiveShipToAddressesByAccountId test method. Change tests to use @isTest
 * 1.2   05-25-2022   Ethan Hirsch @ Zoetis Inc      Add tests for selectByAccountIdWithRelatedDatatest
 * 1.3   07-11-2022   Ethan Hirsch @ Zoetis Inc      Update selectByAccountIdWithRelatedDatatest to change input passed to
 *                                                   selectByAccountIdWithRelatedDataTest
 * 1.4   09-19-2022   Ethan Hirsch @ Zoetis Inc      Update selectByAccountIdWithRelatedDataTest to change the output type
 *                                                   of selectByAccountIdWithRelatedData
 **/
@IsTest
private class AddressesSelectorTest {
  @TestSetup
  private static void makeData() {
    Account objAccount = TestDataFactory.createAccount_US('Test Account', true);
    
    List<Address__c> addresses = TestDataFactory.createAddresses(3, objAccount.Id);

    addresses[0].ZTS_EU_Address_Type__c = 'Main';
    addresses[0].ZTS_US_Source_Account_Number__c = '12345';

    addresses[1].ZTS_EU_Address_Type__c = 'Ship To';
    addresses[1].ZTS_US_Source_Account_Number__c = '123456';
    addresses[1].Ship_Indirect__c = 'Y';

    addresses[2].ZTS_EU_Address_Type__c = 'Shipping';
    addresses[2].ZTS_US_Source_Account_Number__c = '123456';
    addresses[2].Is_Active__c = true;
    addresses[2].Ship_Indirect__c = 'N';

    insert addresses;
  }

  @isTest
  private static void selectByIdTest() {
    Map<Id, Address__c> addressMap = new Map<Id, Address__c>(
      [SELECT Id FROM Address__c]
    );
    List<Address__c> addresses = AddressesSelector.newInstance()
      .selectById(addressMap.keySet());
    // 3 + 1 because Address is created on Insert of Account as well
    System.assertEquals(4, addresses.size(), 'Should find all Addresses');
  }

  @isTest
  private static void selectByTypeTest() {
    List<Address__c> addresses = AddressesSelector.newInstance()
      .selectByType(new Set<String>{ 'Main' });
    System.assertEquals(1, addresses.size(), 'Should find Main Address Only');
  }

  @isTest
  private static void selectByAccountIdTest() {
    List<Account> accounts = [SELECT Id FROM Account];
    List<Address__c> addresses = AddressesSelector.newInstance()
      .selectByAccountId(new Set<Id>{ accounts[0].Id });
    // 3 + 1 because an address is created automatically on Account insert
    System.assertEquals(
      4,
      addresses.size(),
      'There should be three addresses related to the Account'
    );
  }

  @isTest
  private static void selectBySourceAccountNumberTest() {
    List<Address__c> addresses = AddressesSelector.newInstance()
      .selectBySourceAccountNumber(new Set<String>{ '12345' });
    System.assertEquals(
      1,
      addresses.size(),
      'Should find the matching Source Account Record'
    );
  }

  @isTest
  private static void selectBySourceAccountNumberAndTypeTest() {
    List<Address__c> addresses = AddressesSelector.newInstance()
      .selectBySourceAccountNumberAndType(
        new Set<String>{ '12345' },
        new Set<String>{ 'Main' }
      );
    System.assertEquals(
      1,
      addresses.size(),
      'Should find the matching Main address for Source Account'
    );
  }

  @isTest
  private static void selectDirectActiveShipToAddressesByAccountIdTest() {
    List<Account> accounts = [SELECT Id FROM Account];
    List<Address__c> addresses = AddressesSelector.newInstance()
      .selectDirectActiveShipToAddressesByAccountId(
        new Set<Id> {accounts[0].Id}
      );
    System.assertEquals(
      1,
      addresses.size(),
      'Should find the matching Active Direct Ship To address for Source Account'
    );
  }

  @isTest
  private static void selectByAccountIdWithRelatedDataTest() {
    List<Account> accounts = [SELECT Id FROM Account];

    List<MergeService.MergeChildRelationship> childRelationships = new List<MergeService.MergeChildRelationship>();
    for (Schema.ChildRelationship childRelationship : Schema.Address__c.sObjectType.getDescribe().getChildRelationships()) {
      if (childRelationship.getRelationshipName() == 'Accounts__r') {
        childRelationships.add(new MergeService.MergeChildRelationship(childRelationship, null));
        break;
      }
    }

    Test.startTest();
      Map<Id, MergeService.RecordAndRelationships> addresses = AddressesSelector.newInstance().selectByAccountIdWithRelatedData(
        new Set<Id> {accounts[0].Id}, childRelationships);
    Test.stopTest();

    System.assertEquals(4, addresses.size(),
      'Should find 4 Addresses for the Account');
  }
}