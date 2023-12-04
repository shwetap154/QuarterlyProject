/**
 * @description       :
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 11-26-2023
 * @last modified by  : kalyan Nayak @ Zoetis Inc
 * 
 * Modification Log
 * Ver   Date         Author                         Modification
 * 1.0	 11-26-2023	  Kalyan Nayak @ Zoetis Inc		 Added testAdditionalMarketMatch method as part for TPDEV-2467
 **/
@IsTest
private class GigyaRegistrationControllerTest {
  private static final Map<String, Profile> mapProfilesByName = Org.getProfileMapByName();
  private static final Id roleId = [SELECT Id FROM UserRole LIMIT 1].Id;
  private static testMethod void testConstructorParams() {
    PageReference thePage = Page.GigyaLogin;
    Test.setCurrentPageReference(thePage);
    thePage.getParameters().put('market', 'ALPHA');
    GigyaRegistrationController controller = new GigyaRegistrationController();

    System.assert(controller.hasAPIKey, 'Has API Key should be True');
  }

  private static testMethod void testConstructorBadParams() {
    // No Params means the page will find null for market and return API false
    PageReference thePage = Page.GigyaLogin;
    Test.setCurrentPageReference(thePage);
    GigyaRegistrationController controller = new GigyaRegistrationController();

    System.assert(!controller.hasAPIKey, 'Has API Key should be False');
  }

  private static testMethod void testConstructorExtension() {
    Account objAccount = TestDataFactory.createAccount_US(
      'Test Account',
      false
    );
    objAccount.ZTS_EU_Market__c = 'ALPHA';
    objAccount.ZTS_EU_Zip_Postal_Code__c = '00000';
    insert objAccount;

    Contact objContact = TestDataFactory.createContact(objAccount.Id, false);
    objContact.Email = 'testUserEmail@test.zts.com';
    objContact.ZTS_EU_Market__c = 'ALPHA';
    insert objContact;

    User alphaUser = TestDataFactory.createUser(
      mapProfilesByName.get('System Administrator').Id,
      roleId,
      null,
      false
    );
    alphaUser.ZTS_EU_Market__c = 'ALPHA';
    alphaUser.Additional_Markets__c = 'Austria;Panama;';
    alphaUser.IsActive = true;
    System.runAs(new User(Id = UserInfo.getUserId())) {
    insert alphaUser;
        
    Id permissionSetId = [SELECT Id,Name FROM PermissionSet WHERE Name = 'Distributor_Portal_Admin'].Id;
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.AssigneeId = alphaUser.Id;
    psa.PermissionSetId = permissionSetId; 
    insert  psa;  
     

    }
      
    User alphaUser1 = TestDataFactory.createUser(
      mapProfilesByName.get('System Administrator').Id,
      roleId,
      null,
      false
    );
    alphaUser1.ZTS_EU_Market__c = 'ALPHA';
    alphaUser1.Additional_Markets__c = 'Austria;Panama';
    System.runAs(new User(Id = UserInfo.getUserId())) {
    insert alphaUser1;     
    }  
      
    System.runAs(alphaUser) {
      PageReference thePage = Page.GigyaRegistration;
      Test.setCurrentPageReference(thePage);
      thePage.getParameters().put('id', objContact.Id);

      ApexPages.StandardController sc = new ApexPages.StandardController(
        objContact
      );
      GigyaRegistrationController controller = new GigyaRegistrationController(
        sc
      );

      System.assert(controller.hasAPIKey, 'Has API Key should be true');
      System.assert(
        controller.isMarketMatch,
        'Current User Market should match Contact Market'
      );
      System.assert(
        controller.isMarketAdmin,
        'Current User should be flagged as Market Admin'
      );
    }
      
  }

  
  private static testMethod void testConstructorGoodParams() {
    Account objAccount = TestDataFactory.createAccount_US(
      'Test Account',
      false
    );
    objAccount.ZTS_EU_Market__c = 'ALPHA';
    objAccount.ZTS_EU_Zip_Postal_Code__c = '00000';
    insert objAccount;

    Contact objContact = TestDataFactory.createContact(objAccount.Id, false);
    objContact.Email = 'testUserEmail@test.zts.com';
    objContact.ZTS_EU_Market__c = '';
    insert objContact;

    User alphaUser = TestDataFactory.createUser(
      mapProfilesByName.get('API Only').Id,
      roleId,
      null,
      false
    );
    alphaUser.ZTS_EU_Market__c = '';
    alphaUser.IsActive = true;
    System.runAs(new User(Id = UserInfo.getUserId())) {
    insert alphaUser;
        
    Id permissionSetId = [SELECT Id,Name FROM PermissionSet WHERE Name != 'Distributor_Portal_Admin' LIMIT 1].Id;
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.AssigneeId = alphaUser.Id;
    psa.PermissionSetId = permissionSetId; 
    insert  psa;  
     

    }
      
    User alphaUser1 = TestDataFactory.createUser(
      mapProfilesByName.get('API Only').Id,
      roleId,
      null,
      false
    );
    alphaUser1.ZTS_EU_Market__c = '';
    System.runAs(new User(Id = UserInfo.getUserId())) {
    insert alphaUser1;     
    }  
      
    System.runAs(alphaUser) {
      PageReference thePage = Page.GigyaRegistration;
      Test.setCurrentPageReference(thePage);
      thePage.getParameters().put('id', objContact.Id);

      ApexPages.StandardController sc = new ApexPages.StandardController(
        objContact
      );
      GigyaRegistrationController controller = new GigyaRegistrationController(
        sc
      );

      System.assert(controller.hasAPIKey, 'Has API Key should be true');
      System.assert(
        !controller.isMarketMatch,
        'Current User Market should match Contact Market'
      );
      System.assert(
        !controller.isMarketAdmin,
        'Current User should be flagged as Market Admin'
      );
    }
      
  }   
  
  //This method will test if Contact Market match Current users Additional Market instead of Market field
  private static testMethod void testAdditionalMarketMatch() {
      Account objAccount = TestDataFactory.createAccount_US(
          'Test Account',
          false
      );
      objAccount.ZTS_EU_Market__c = 'Panama';
      objAccount.ZTS_EU_Zip_Postal_Code__c = '00000';
      insert objAccount;
      
      Contact objContact = TestDataFactory.createContact(objAccount.Id, false);
      objContact.Email = 'testUserEmail@test.zts.com';
      objContact.ZTS_EU_Market__c = 'Panama';
      insert objContact;
      
      User alphaUser = TestDataFactory.createUser(
          mapProfilesByName.get('System Administrator').Id,
          roleId,
          null,
          false
      );
      alphaUser.ZTS_EU_Market__c = 'ALPHA';
      alphaUser.Additional_Markets__c = 'Austria;Panama;';
      alphaUser.IsActive = true;
      System.runAs(new User(Id = UserInfo.getUserId())) {
          insert alphaUser;
          
          Id permissionSetId = [SELECT Id,Name FROM PermissionSet WHERE Name = 'Distributor_Portal_Admin'].Id;
          PermissionSetAssignment psa = new PermissionSetAssignment();
          psa.AssigneeId = alphaUser.Id;
          psa.PermissionSetId = permissionSetId; 
          insert  psa;
      } 
      
      System.runAs(alphaUser) {
          PageReference thePage = Page.GigyaRegistration;
          Test.setCurrentPageReference(thePage);
          thePage.getParameters().put('id', objContact.Id);
          
          ApexPages.StandardController sc = new ApexPages.StandardController(
              objContact
          );
          GigyaRegistrationController controller = new GigyaRegistrationController(
              sc
          );
          
          System.assert(controller.hasAPIKey, 'Has API Key should be true');
          System.assert(
              controller.isMarketMatch,
              'Current User Market should match Contact Market'
          );
          System.assert(
              controller.isMarketAdmin,
              'Current User should be flagged as Market Admin'
          );
      }
  }
}