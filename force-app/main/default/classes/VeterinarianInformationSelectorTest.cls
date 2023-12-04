/**
 * @description       :Test class for VeterinarianInformationSelectorTest Class
 * @author            : Namrata Patane @ Zoetis Inc
 * @group             :
 * @last modified on  : 11-23-2021
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   11-23-2021   Namrata Patane @ Zoetis Inc   Initial Version
 * 1.1   11-23-2021   Morgan Marchese @ Zoetis Inc  MAX_RECORDS, Formatting
 
 **/
@isTest
private class VeterinarianInformationSelectorTest {
  private static final Integer MAX_RECORDS = 10;
  @TestSetup
  static void setup() {
    User usr = new User();
    usr = ZTS_EU_DataUtilityTest.createUserWithProfile(
      'System Administrator',
      false
    );
    usr.FirstName = 'TestUser';
    usr.zts_eu_market__c = 'US';
    insert usr;

    ID LeadRecTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get('Shelters')
      .getRecordTypeId();
    List<Lead> leadList = new List<Lead>();
    for (Integer i = 1; i <= MAX_RECORDS; i++) {
      Lead l = new Lead(
        LastName = 'Test' + i,
        Company = 'Test' + i,
        SAP_Bill_To_ID__c = '123' + i,
        RecordTypeId = LeadRecTypeID,
        Parent_Corporate_Specialty_Hospital__c = true,
        Email = 'xyz' + i + '@gmail.com'
      );
      leadList.add(l);
    }
    insert leadList;
    List<Veterinarian_Information__c> lstVeterInfo = new List<Veterinarian_Information__c>();
    for (Integer j = 1; j <= MAX_RECORDS/2; j++) {
      Veterinarian_Information__c objVetInfo = new Veterinarian_Information__c(
        Lead__c = leadList[j].id
      );
      lstVeterInfo.add(objVetInfo);
    }
    insert lstVeterInfo;
  }
  static testMethod void testSelectByLeadId() {
    Set<Id> recordIds = (new Map<Id, SObject>([SELECT Id FROM Lead])).keySet();
    List<Veterinarian_Information__c> resultList = new List<Veterinarian_Information__c>();
    resultList = VeterinarianInformationSelector.selectByLeadId(recordIds);
    System.assertEquals(
      MAX_RECORDS/2,
      resultList.size(),
      'Should Be ' +
      MAX_RECORDS/2 +
      ' Results'
    );
  }
}