/**
 * @description       :
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-25-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 **/
@isTest
private class DistributorJITHandlerTest {
  private static final Id samlSsoProviderId = '0LE000000000000';
  private static final Id communityId = '0DB000000000000';
  private static final Id portalId = '0DB000000000000';
  private static final String federationIdentifier = 'fedId01';
  private static final String assertion = 'assertion';
  private static final String pid = [
    SELECT Id
    FROM Profile
    WHERE Name = 'Distributor Community User'
  ]
  .Id;
  private static final String adminId = [
    SELECT Id
    FROM Profile
    WHERE Name = 'System Administrator'
  ]
  .Id;
  private static final String roleId = [SELECT Id FROM UserRole LIMIT 1].Id;
  private static final Map<String, String> attributes = new Map<String, String>{
    'User.Email' => 'testuser@test.zts.com',
    'User.FirstName' => 'TestUserFirst',
    'User.LastName' => 'TestUserLast',
    'User.Phone' => '5555555555',
    'User.ProfileId' => pid,
    'User.Username' => 'testuser@test.zts.com'
  };

  @TestSetup
  static void makeData() {
    User adminUser = TestDataFactory.createUser(adminId, roleId, null, true);
    System.runAs(adminUser) {
      List<Contact> contacts = new List<Contact>();
      State_Country__c intlStateCountry = TestDataFactory.createStateCountry(
        'Nigeria',
        'County',
        true
      );
      Account objAcc = TestDataFactory.createAccount_EU(
        'ALPHA Test 1',
        intlStateCountry.Id,
        false
      );
      objAcc.ZTS_EU_Market__c = 'ALPHA';
      objAcc.BillingCountry = 'Nigeria';
      objAcc.ShippingCountry = 'Nigeria';
      objAcc.ZTS_EU_Country__c = 'Nigeria';
      insert objAcc;
      objAcc.IsPartner = true;
      update objAcc;

      Contact objContact = TestDataFactory.createContact(objAcc.Id, false);
      objContact.ZTS_EU_Market__c = 'ALPHA';
      Contact objUserContact = TestDataFactory.createContact(objAcc.Id, false);
      objUserContact.FirstName = 'UserContactFirst';
      objUserContact.LastName = 'UserContactLast';
      objUserContact.ZTS_EU_Market__c = 'ALPHA';

      contacts.add(objContact);
      contacts.add(objUserContact);
      insert contacts;

      Id userContactId;
      for (Contact c : contacts) {
        if (c.FirstName == 'UserContactFirst') {
          userContactId = c.Id;
        }
      }

      User objUser = TestDataFactory.createUser(
        pid,
        null,
        userContactId,
        false
      );
      objUser.ZTS_EU_Market__c = 'ALPHA';
      objUser.Country = 'Nigeria';
      objUser.FirstName = 'UserToUpdate';
      insert objUser;
    }
  }

  static testMethod void testCreateUser() {
    List<Contact> contacts = [SELECT Id FROM Contact WHERE FirstName = 'TestFirstName'];
    System.assertEquals(1,contacts.size(),'There should be one matching Contact');
    Map<String, String> attribs = attributes;
    attribs.put('User.Contact',contacts[0].Id);

    Test.startTest();
    DistributorJITHandler handler = new DistributorJITHandler();
    handler.createUser(
      samlSsoProviderId,
      communityId,
      portalId,
      federationIdentifier,
      attributes,
      assertion
    );
    Test.stopTest();

    List<User> users = [
      SELECT Id, FirstName, LastName, Username, FederationIdentifier
      FROM User
      WHERE FederationIdentifier = :federationIdentifier
    ];
    System.assertEquals(
      1,
      users.size(),
      'Only one user should exist with this Federation Id'
    );
    System.assertEquals(
      'TestUserFirst',
      users[0].FirstName,
      'FirstName should match'
    );
    System.assertEquals(
      'TestUserLast',
      users[0].LastName,
      'LastName should match'
    );
    System.assert(
      users[0].Username.containsIgnoreCase('+DST@'),
      'Username should be appended with +DST before @'
    );
  }

  static testMethod void testCreateUserWithFederationId() {
    List<Contact> contacts = [SELECT Id FROM Contact WHERE FirstName = 'TestFirstName'];
    System.assertEquals(1,contacts.size(),'There should be one matching Contact');
    Map<String, String> attribs = attributes;
    attribs.put('User.FederationIdentifier', 'fedId02');
    attribs.put('User.Contact',contacts[0].Id);

    Test.startTest();
    DistributorJITHandler handler = new DistributorJITHandler();
    handler.createUser(
      samlSsoProviderId,
      communityId,
      portalId,
      federationIdentifier,
      attribs,
      assertion
    );
    Test.stopTest();

    List<User> users = [
      SELECT Id, FirstName, LastName, Username, FederationIdentifier
      FROM User
      WHERE FederationIdentifier = 'fedId02'
    ];
    System.assertEquals(
      1,
      users.size(),
      'Only one user should exist with this Federation Id'
    );
    System.assertEquals(
      'TestUserFirst',
      users[0].FirstName,
      'FirstName should match'
    );
    System.assertEquals(
      'TestUserLast',
      users[0].LastName,
      'LastName should match'
    );
    System.assert(
      users[0].Username.containsIgnoreCase('+DST@'),
      'Username should be appended with +DST before @'
    );

    System.assertEquals(
      'fedId02',
      users[0].FederationIdentifier,
      'Federation Id should be set to 02, not 01'
    );
  }

  static testMethod void testUpdateUser() {
    List<User> users = [SELECT Id,FederationIdentifier FROM User WHERE FirstName = 'UserToUpdate'];
    System.assertEquals(1,users.size(),'There should be one matching User');
    Map<String, String> attribs = attributes;
    attribs.put('User.FederationIdentifier', users[0].FederationIdentifier);
    attribs.put('User.FirstName','NameUpdated');

    Test.startTest();
    DistributorJITHandler handler = new DistributorJITHandler();
    handler.updateUser(users[0].Id, samlSsoProviderId, communityId, portalId, federationIdentifier, attribs, assertion);
    Test.stopTest();

    users = [
      SELECT Id, FirstName, LastName, Username, FederationIdentifier
      FROM User
      WHERE FirstName = 'NameUpdated'
    ];
    System.assertEquals(
      1,
      users.size(),
      'Name should have been changed'
    );
  }
}