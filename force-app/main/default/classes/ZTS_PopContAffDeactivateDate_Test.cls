/******************************************************************************************************************************************
 * Class Name       : ZTS_PopContAffDeactivateDate_Test
 * Description      : Test Class for ZTS_PopulateContAffDeactivateDate.cls (SC-008471)
 * Created By       : Cognizant
 * Created Date     : 5-April, 2021
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)        5-April-2021          Created  (SC-008471)
 * Morgan Marchese          26-May-2021           Formatting and removal of unnecessary comments
 * Ethan Hirsch             26-Jul-2022           Call ZTS_PopulateContAffDeactivateDate in testAffInsert. (This class may not be used anymore)
 *****************************************************************************************************************************************/
@isTest
public class ZTS_PopContAffDeactivateDate_Test {
  static testMethod void testAffInsert() {
    User usr;
    usr = ZTS_EU_DataUtilityTest.createUserWithProfile(
      'System Administrator',
      false
    );
    usr.FirstName = 'Test';
    usr.LastName = 'uk_User';
    usr.Email = 'temp@temp.com';
    usr.zts_eu_market__c = 'United Kingdom';
    insert usr;

    Primary_Contact_Inactive_Profile_List__c newCustomSetting = new Primary_Contact_Inactive_Profile_List__c();
    newCustomSetting.Name = 'Profile Names';
    newCustomSetting.profile__c = '\'ZTS AUT Business Administrator\';\'ZTS BAL Business Administrator\';\'ZTS BGR Business Administrator\';\'ZTS BNLX Business Administrator\';\'ZTS EGY Business Administrator\';\'ZTS ESP Business Administrator\';\'ZTS FIN Business Administrator\';\'System Administrator\'';
    insert newCustomSetting;

    Primary_Contact_Inactive_Profile_List__c newCustomSetting2 = new Primary_Contact_Inactive_Profile_List__c();
    newCustomSetting2.Name = 'Profile Names 1';
    newCustomSetting2.profile__c = '\'ZTS FRA Business Administrator\';\'ZTS UK Business Administrator\';\'ZTS ITA Business Administrator\',\'Integration Profile\',\'ZTS KOR Business Administrator\',\'ZTS THA Business Administrator\',\'ZTS PHL Business Administrator\',\'ZTS VNM Business Administrator\'';
    insert newCustomSetting2;

    Primary_Contact_Inactive_Profile_List__c newCustomSetting3 = new Primary_Contact_Inactive_Profile_List__c();
    newCustomSetting3.Name = 'Profile Names 2';
    newCustomSetting3.profile__c = '\'ZTS TWN Business Administrator\',\'ZTS IDN Business Administrator\',\'ZTS IND Business Administrator\', \'ZTS CHN Business Administrator\',\'Intll Business Administrator\', \'ZTS CLAR SoLA Business Administrator\'';
    insert newCustomSetting3;

    Account testAccount;
    testAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
    testAccount.ZTS_EU_Market__c = 'United Kingdom';
    testAccount.ZTS_EU_Account_Status__c = 'Active';

    List<Contact> testcontactList;
    testcontactList = ZTS_DataUtilityTest.createContactRecord(3);

    for (Contact c : testcontactList) {
      c.ZTS_EU_Market__c = 'United Kingdom';
      c.ZTS_EU_Contact_Status__c = 'Active';
      c.ZTS_EU_Rep_Contact_Status__c = 'Active';
      c.ZTS_Contact_Affiliation_Deactivated_Date__c = system.now()
        .addHours(-25);
    }

    System.runAs(usr) {
      insert testAccount;
      insert testcontactList;
      list<ZTS_EU_Affiliations__c> testaffList;
      testaffList = ZTS_DataUtilityTest.createAccConAffiliationRecord(3);
      for (Integer i = 0; i < 3; i++) {
        testaffList[i].ZTS_EU_Contact__c = testcontactList[i].id;
        testaffList[i].ZTS_EU_Account__c = testAccount.id;
        testaffList[i].ZTS_EU_Affiliation_Status__c = 'Active';
        testaffList[i].ZTS_EU_Species_Speciality__c = 'Equine';
        testaffList[i].ZTS_EU_Job_Function__c = 'Animal Welfare';
        testaffList[i].ZTS_EU_Profession__c = 'Consultant';
      }
      insert testaffList;

      Test.startTest();
        ZTS_PopulateContAffDeactivateDate a = new ZTS_PopulateContAffDeactivateDate();
        a.updateAffDeactDate(testaffList, null, false, true);
      Test.stopTest();
    }

    List<Id> lstContIds = new List<Id>();
    for (Contact c : testcontactList) {
      lstContIds.add(c.Id);
    }
    

    List<Contact> lstCon = [
      SELECT Id
      FROM Contact
      WHERE
        Id IN :lstContIds
        AND ZTS_Contact_Affiliation_Deactivated_Date__c = NULL
    ];
    system.assertEquals(lstCon.size(), 3, 'Date removed');
  }

  static testMethod void testAffUpdateInactive() {
    User usr;
    usr = ZTS_EU_DataUtilityTest.createUserWithProfile(
      'System Administrator',
      false
    );
    usr.FirstName = 'Test';
    usr.LastName = 'uk_User';
    usr.Email = 'temp@temp.com';
    usr.zts_eu_market__c = 'United Kingdom';
    insert usr;

    Primary_Contact_Inactive_Profile_List__c newCustomSetting = new Primary_Contact_Inactive_Profile_List__c();
    newCustomSetting.Name = 'Profile Names';
    newCustomSetting.profile__c = '\'ZTS AUT Business Administrator\';\'ZTS BAL Business Administrator\';\'ZTS BGR Business Administrator\';\'ZTS BNLX Business Administrator\';\'ZTS EGY Business Administrator\';\'ZTS ESP Business Administrator\';\'ZTS FIN Business Administrator\';\'System Administrator\'';
    insert newCustomSetting;

    Primary_Contact_Inactive_Profile_List__c newCustomSetting2 = new Primary_Contact_Inactive_Profile_List__c();
    newCustomSetting2.Name = 'Profile Names 1';
    newCustomSetting2.profile__c = '\'ZTS FRA Business Administrator\';\'ZTS UK Business Administrator\';\'ZTS ITA Business Administrator\',\'Integration Profile\',\'ZTS KOR Business Administrator\',\'ZTS THA Business Administrator\',\'ZTS PHL Business Administrator\',\'ZTS VNM Business Administrator\'';
    insert newCustomSetting2;

    Primary_Contact_Inactive_Profile_List__c newCustomSetting3 = new Primary_Contact_Inactive_Profile_List__c();
    newCustomSetting3.Name = 'Profile Names 2';
    newCustomSetting3.profile__c = '\'ZTS TWN Business Administrator\',\'ZTS IDN Business Administrator\',\'ZTS IND Business Administrator\', \'ZTS CHN Business Administrator\',\'Intll Business Administrator\', \'ZTS CLAR SoLA Business Administrator\'';
    insert newCustomSetting3;

    Account testAccount;
    testAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
    testAccount.ZTS_EU_Market__c = 'United Kingdom';
    testAccount.ZTS_EU_Account_Status__c = 'Active';

    List<Contact> testcontactList;
    testcontactList = ZTS_DataUtilityTest.createContactRecord(1);
    testcontactList[0].ZTS_EU_Market__c = 'United Kingdom';
    testcontactList[0].ZTS_EU_Contact_Status__c = 'Active';

    System.runAs(usr) {
      insert testAccount;
      insert testcontactList;
      ZTS_EU_Affiliations__c tstAff = new ZTS_EU_Affiliations__c();
      tstAff.ZTS_EU_Contact__c = testcontactList[0].id;
      tstAff.ZTS_EU_Account__c = testAccount.id;
      tstAff.ZTS_EU_Affiliation_Status__c = 'Active';
      tstAff.ZTS_EU_Species_Speciality__c = 'Equine';
      insert tstAff;
      Map<Id, ZTS_EU_Affiliations__c> mapOldAff = new Map<Id, ZTS_EU_Affiliations__c>(
        [
          SELECT Id, ZTS_EU_Contact__c, ZTS_EU_Affiliation_Status__c
          FROM ZTS_EU_Affiliations__c
          WHERE id = :tstAff.Id
        ]
      );

      system.debug('after insert testaffList' + tstAff);
      tstAff.ZTS_EU_Affiliation_Status__c = 'Inactive';
      update tstAff;

      List<ZTS_EU_Affiliations__c> newListAff = new List<ZTS_EU_Affiliations__c>(
        [
          SELECT Id, ZTS_EU_Contact__c, ZTS_EU_Affiliation_Status__c
          FROM ZTS_EU_Affiliations__c
          WHERE id = :tstAff.Id
        ]
      );

      test.startTest();
      ZTS_PopulateContAffDeactivateDate a = new ZTS_PopulateContAffDeactivateDate();
      a.updateAffDeactDate(newListAff, mapOldAff, true, false);
      test.stopTest();
    }

  }

  static testMethod void testAffUpdateActive() {
    User usr;
    usr = ZTS_EU_DataUtilityTest.createUserWithProfile(
      'System Administrator',
      false
    );
    usr.FirstName = 'Test';
    usr.LastName = 'uk_User';
    usr.Email = 'temp@temp.com';
    usr.zts_eu_market__c = 'United Kingdom';
    insert usr;

    Primary_Contact_Inactive_Profile_List__c newCustomSetting = new Primary_Contact_Inactive_Profile_List__c();
    newCustomSetting.Name = 'Profile Names';
    newCustomSetting.profile__c = '\'ZTS AUT Business Administrator\';\'ZTS BAL Business Administrator\';\'ZTS BGR Business Administrator\';\'ZTS BNLX Business Administrator\';\'ZTS EGY Business Administrator\';\'ZTS ESP Business Administrator\';\'ZTS FIN Business Administrator\';\'System Administrator\'';
    insert newCustomSetting;

    Primary_Contact_Inactive_Profile_List__c newCustomSetting2 = new Primary_Contact_Inactive_Profile_List__c();
    newCustomSetting2.Name = 'Profile Names 1';
    newCustomSetting2.profile__c = '\'ZTS FRA Business Administrator\';\'ZTS UK Business Administrator\';\'ZTS ITA Business Administrator\',\'Integration Profile\',\'ZTS KOR Business Administrator\',\'ZTS THA Business Administrator\',\'ZTS PHL Business Administrator\',\'ZTS VNM Business Administrator\'';
    insert newCustomSetting2;

    Primary_Contact_Inactive_Profile_List__c newCustomSetting3 = new Primary_Contact_Inactive_Profile_List__c();
    newCustomSetting3.Name = 'Profile Names 2';
    newCustomSetting3.profile__c = '\'ZTS TWN Business Administrator\',\'ZTS IDN Business Administrator\',\'ZTS IND Business Administrator\', \'ZTS CHN Business Administrator\',\'Intll Business Administrator\', \'ZTS CLAR SoLA Business Administrator\'';
    insert newCustomSetting3;

    Account testAccount;
    testAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
    testAccount.ZTS_EU_Market__c = 'United Kingdom';
    testAccount.ZTS_EU_Account_Status__c = 'Active';

    List<Contact> testcontactList;
    testcontactList = ZTS_DataUtilityTest.createContactRecord(1);
    testcontactList[0].ZTS_EU_Market__c = 'United Kingdom';
    testcontactList[0].ZTS_EU_Contact_Status__c = 'Active';
    testcontactList[0]
      .ZTS_Contact_Affiliation_Deactivated_Date__c = system.now().addHours(-23);
    System.runAs(usr) {
      insert testAccount;
      insert testcontactList;
      ZTS_EU_Affiliations__c tstAff = new ZTS_EU_Affiliations__c();
      tstAff.ZTS_EU_Contact__c = testcontactList[0].id;
      tstAff.ZTS_EU_Account__c = testAccount.id;
      tstAff.ZTS_EU_Affiliation_Status__c = 'Inctive';
      tstAff.ZTS_EU_Species_Speciality__c = 'Equine';
      insert tstAff;
      Map<Id, ZTS_EU_Affiliations__c> mapOldAff = new Map<Id, ZTS_EU_Affiliations__c>(
        [
          SELECT Id, ZTS_EU_Contact__c, ZTS_EU_Affiliation_Status__c
          FROM ZTS_EU_Affiliations__c
          WHERE id = :tstAff.Id
        ]
      );

      system.debug('after insert testaffList' + tstAff);
      tstAff.ZTS_EU_Affiliation_Status__c = 'Active';
      update tstAff;

      List<ZTS_EU_Affiliations__c> newListAff = new List<ZTS_EU_Affiliations__c>(
        [
          SELECT Id, ZTS_EU_Contact__c, ZTS_EU_Affiliation_Status__c
          FROM ZTS_EU_Affiliations__c
          WHERE id = :tstAff.Id
        ]
      );

      test.startTest();
      ZTS_PopulateContAffDeactivateDate a = new ZTS_PopulateContAffDeactivateDate();
      a.updateAffDeactDate(newListAff, mapOldAff, true, false);
      test.stopTest();
    }
  }
}