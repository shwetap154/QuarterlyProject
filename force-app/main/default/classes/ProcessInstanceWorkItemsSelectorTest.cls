/**
 * @description       :Test class for ProcessInstanceWorkItemsSelector Class
 * @author            : Namrata Patane @ Zoetis Inc
 * @group             :
 * @last modified on  : 11-17-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   11-16-2021   Namrata Patane @ Zoetis Inc   Initial Version
 **/
@isTest
public class ProcessInstanceWorkItemsSelectorTest {
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

    ZTS_EU_Defects__c objEUDefect = new ZTS_EU_Defects__c();
    objEUDefect.Comments__c = 'Test Class';
    objEUDefect.ZTS_EU_Problem_Summary__c = 'testing';
    objEUDefect.ZTS_EU_Status__c = 'Pending Initial Approval';
    objEUDefect.ZTS_EU_Reported_By__c = usr.Id;
    objEUDefect.ZTS_EU_Problem_Summary__c = 'Summary';
    objEUDefect.ZTS_EU_Problem_Description__c = 'test data';
    objEUDefect.Business_Justification_Value__c = 'Give users selecting an address to associate to a case the full information about that address.';
    objEUDefect.Region__c = 'US';
    insert objEUDefect;
  }
  static testMethod void testDefectInsert() {
    List<ZTS_EU_Defects__c> defects = [SELECT Id FROM ZTS_EU_Defects__c];
    Test.startTest();
    Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
    app.setObjectId(defects[0].Id);
    Approval.ProcessResult result = Approval.process(app);
    Test.stopTest();
    list<ProcessInstance> existingApprovals = [
      SELECT Id, TargetObjectId
      FROM ProcessInstance
      WHERE TargetObjectId IN :defects AND Status = 'Pending'
    ];
    System.assertEquals(true, existingApprovals.size() > 0);
  }
}