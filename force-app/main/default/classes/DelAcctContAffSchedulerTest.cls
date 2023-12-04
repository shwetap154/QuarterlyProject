@isTest
private class DelAcctContAffSchedulerTest{

  @TestSetup
  static void makeData() {
    String domain = String.valueOf(System.now().millisecond()) + '.testclass';
    Profile profiles=[Select Id From Profile Where Name='System Administrator' LIMIT 1];
    User newuser = new User();
    newuser.profileid=profiles.Id;
    newuser.email='testem@' + domain;
    newuser.username='testem@' + domain;
    newuser.lastname='testem';
    newuser.alias='testem';
    newuser.languagelocalekey='en_US';
    newuser.localesidkey='en_US';
    newuser.timezonesidkey='America/Los_Angeles';
    newuser.localesidkey='en_US';  
    newuser.EmailEncodingKey='ISO-8859-1'; 
    newuser.ZTS_EU_Market__c='United Status';

    System.runAs(newuser) {
      ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
      List<Account> a = ZTS_DataUtilityTest.createAccountRecord(1);
      a[0].ZTS_EU_Market__c = 'United States';
      insert a;

      List<Contact> c = ZTS_DataUtilityTest.createContactRecord(1);
      c[0].ZTS_EU_Market__c = 'United States';
      insert c;

      List<ZTS_EU_Affiliations__c> affil = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
      affil[0].ZTS_EU_Affiliation_Status__c = 'Inactive';
      affil[0].ZTS_EU_Account__c = a[0].Id;
      affil[0].ZTS_EU_Contact__c = c[0].Id;
      insert affil;
    }
  }

  @IsTest
  static void testschedule(){
    Test.StartTest();
    ZTS_US_DelAcctContAffiliationScheduler sh1 = new ZTS_US_DelAcctContAffiliationScheduler();      
    String sch = '0  00 1 3 * ?';
    system.schedule('Test', sch, sh1);
    Test.stopTest();

    List<ZTS_EU_Affiliations__c> affilList = [SELECT Id, ZTS_EU_Market_from_Parent__c FROM ZTS_EU_Affiliations__c];
    /*
    TODO

    review batch class
    */
    System.assert(!affilList.isEmpty(), 'Affiliations not deleted');
  }

}