/**
 * @description       :Test class for LeadsSelector Class
 * @author            : Namrata Patane @ Zoetis Inc
 * @group             :
 * @last modified on  : 11-23-2021
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   11-23-2021   Namrata Patane @ Zoetis Inc   Initial Version
 * 1.1   11-23-2021   Morgan Marchese @ Zoetis Inc  Added ZFS Methods, Formatting
 * 1.2   06-22-2023   Padma Nerella @ Zoetis Inc    Added SelectByNOAAppNumberTest TPDEV-1070
 **/
@isTest
private class LeadsSelectorTest {
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
    }

  static testMethod void testSelectNOALeadsById() {
    Set<Id> recordIds = (new Map<Id, SObject>([SELECT Id FROM Lead])).keySet();
    List<lead> resultList = new List<lead>();
    resultList = LeadsSelector.selectNOALeadsById(recordIds);
    System.assertEquals(
      MAX_RECORDS,
      resultList.size(),
      'Should Be ' +
      MAX_RECORDS +
      ' Results'
    );
  }

  static testMethod void testSelectNOALeadsByAppIdAndEmail() {
    List<Lead> recordIds = [
      SELECT Id, NOA_Application_Number__c, Email
      FROM Lead
    ];
    Set<String> appIds = new Set<String>();
    Set<String> emails = new Set<String>();
    for (Lead objLead : recordIds) {
      appIds.add(objLead.NOA_Application_Number__c);
      emails.add(objLead.Email);
    }
    List<lead> resultList = new List<lead>();
    resultList = LeadsSelector.selectNOALeadsByAppIdAndEmail(appIds, emails);
    System.assertEquals(
      MAX_RECORDS,
      resultList.size(),
      'Should Be ' +
      MAX_RECORDS +
      ' Results'
    );
  }

  static testMethod void testSelectNOALeadsBySAPBillToId() {
    List<Lead> recordIds = [SELECT Id, Email, SAP_Bill_To_ID__c FROM Lead];
    Set<String> SAPIds = new Set<String>();
    recordIds[0].Company = 'New Online Account';
    update recordIds;
    for (Lead objLead : recordIds) {
      SAPIds.add(objLead.SAP_Bill_To_ID__c);
    }
    List<lead> resultList = new List<lead>();
    resultList = LeadsSelector.selectNOALeadsBySAPBillToId(SAPIds);
    System.assertEquals(1, resultList.size(), 'Should Be 1 Result');
  }

  static testMethod void testSelectZFSLeadsById() {
    Set<Id> recordIds = (new Map<Id, SObject>([SELECT Id FROM Lead])).keySet();
    List<lead> resultList = new List<lead>();
    resultList = LeadsSelector.selectZFSLeadsById(recordIds);
    System.assertEquals(
      MAX_RECORDS,
      resultList.size(),
      'Should Be ' +
      MAX_RECORDS +
      ' Results'
    );
  }

  static testMethod void testSelectZFSLeadsByAppIdAndEmail() {
    List<Lead> recordIds = [
      SELECT Id, Shelter_Application_Number__c, Email
      FROM Lead
    ];
    Set<String> appIds = new Set<String>();
    Set<String> emails = new Set<String>();
    for (Lead objLead : recordIds) {
      appIds.add(objLead.Shelter_Application_Number__c);
      emails.add(objLead.Email);
    }
    List<lead> resultList = new List<lead>();
    resultList = LeadsSelector.selectZFSLeadsByAppIdAndEmail(appIds, emails);
    System.assertEquals(
      MAX_RECORDS,
      resultList.size(),
      'Should Be ' +
      MAX_RECORDS +
      ' Results'
    );
  }
    
    static testMethod void SelectByNOAAppNumberTest(){
        Set<String> noaAppNum = new Set<String>();
        List<Lead> leadList = [Select Id,Name,Company,NOA_Application_Number__c from Lead Limit 1];
        for(Lead ld:leadList){
            noaAppNum.add(ld.NOA_Application_Number__c);
        }
        Test.startTest();
        List<Lead> noaLeadList = LeadsSelector.SelectByNOAAppNumber(noaAppNum);
        Test.stopTest();
        Assert.areEqual(1, noaLeadList.size(), '1 lead retrived');
    }  
}