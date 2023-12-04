/**
 * @description       : Test class for ColleaguesServices
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   11-09-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   04-07-2022   Ethan Hirsch @ Zoetis Inc      Create additional Calls with dates in the past in setup.
 **/
@IsTest
private class ColleaguesServiceTest {
  private static final Integer MAX_ACCOUNTS = 5;

  @TestSetup
  static void setup() {
    User intlUsr = new User();
    intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile(
      'System Administrator',
      false
    );
    intlUsr.FirstName = 'IntUser';
    intlUsr.ZTS_EU_Market__c = 'United Kingdom';
    insert intlUsr;

    State_Country__c stateCountryUK = TestDataFactory.createStateCountry(
      'United Kingdom',
      'County Down',
      true
    );

    System.runAs(intlUsr) {
      List<Account> accountList = new List<Account>();
      // Create Test Accounts with different Markets
      for (Integer i = 0; i < MAX_ACCOUNTS; i++) {
        Account acct = TestDataFactory.createAccount_EU(
          'UK Test Account ' + i,
          stateCountryUK.Id,
          false
        );
        accountList.add(acct);
      }

      insert accountList;
      List<Call__c> callList = new List<Call__c>();
      for (Account acc : accountList) {
        for (Integer i = 0; i < 3; i++) {
          Call__c call = TestDataFactory.createCall(acc.Id, false);

          // This Call should not impact the latest date chosen for the Colleague
          if (i == 2) {
            call.ZTS_EU_Start_Date_Time__c = call.ZTS_EU_Start_Date_Time__c.addDays(-5);
            call.ZTS_EU_End_Date_Time__c = call.ZTS_EU_End_Date_Time__c.addDays(-5);
          }
          callList.add(call);
        }
      }
      insert callList;
    }
  }

  @isTest
  private static void getCollegueKeyToCallDateMap_Test() {
    Map<String, DateTime> colleagueMap;
    // Order by ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c asc so that earlier dates are overwritten by later dates.
    List<ZTS_EU_Colleague__c> colleagueList = [
      SELECT
        Id,
        ZTS_EU_User__c,
        ZTS_EU_Call__r.ZTS_EU_Account__c,
        ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c
      FROM ZTS_EU_Colleague__c
      ORDER BY ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c ASC
    ];

    Test.startTest();
    colleagueMap = ColleaguesService.getCollegueKeyToCallDateMap(colleagueList);
    Test.stopTest();
    for (String s : colleagueMap.keySet()) {
      System.assertEquals(
        System.today(),
        colleagueMap.get(s).date(),
        'Colleague Map Dates should match Todays date'
      );
    }
  }
}