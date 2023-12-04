/**
 * @description       : Test class for CasesSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-11-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-11-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for selectById and 
 *                                                selectyByAccountIdsAndRecordTypeDeveloperNames.
**/
@isTest
private class CasesSelectorTest {
    private static final Integer maxRecords = 12;

    @TestSetup
    static void setup(){
        List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(2);
        insert accounts;

        Map<String, Schema.RecordTypeInfo> caseRecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        
        List<Case> allCases = new List<Case>();
        List<Case> onboardingCases = ZTS_DataUtilityTest.createCases(maxRecords/2,
            caseRecordTypes.get('Ref_Labs_Onboarding').getRecordTypeId());

        List<Case> supportCases = ZTS_DataUtilityTest.createCases(maxRecords/2,
            caseRecordTypes.get('Reference_Labs_Support').getRecordTypeId());
        
        for (integer i = 0; i < maxRecords / 2; i++) {
            // Switch between the two Accounts every iteration.
            // Half of the Cases go to Account 0 and the other half go to Account 1
            Id accountId = Math.mod(i, 2) == 0
                           ? accounts[0].Id
                           : accounts[1].Id;

            onboardingCases[i].AccountId = accountId;
            supportCases[i].AccountId = accountId;

            allCases.add(onboardingCases[i]);
            allCases.add(supportCases[i]);
        }

        insert allCases;
    }

    @isTest
    private static void selectByIdTest() {
        Set<Id> caseIds = new Map<Id, Case>([SELECT ID FROM Case]).keySet();
        
        System.assertEquals(maxRecords, caseIds.size(), 'More/Less Case records existed than expected');

        Test.startTest();
            List<Case> cases = CasesSelector.newInstance().selectById(caseIds);
        Test.stopTest();

        system.assertEquals(maxRecords, cases.size(), 'More/Less Case records existed than expected');

    }

    @isTest
    private static void selectyByAccountIdsAndRecordTypeDeveloperNamesTest() {
        Id accountId = [SELECT ID FROM ACCOUNT LIMIT 1].Id;

        Test.startTest();
            List<Case> cases = CasesSelector.newInstance().selectyByAccountIdsAndRecordTypeDeveloperNames(
                new Set<Id> {accountId}, new Set<String> {'Ref_Labs_Onboarding', 'Reference_Labs_Support'});
        Test.stopTest();

        system.assertEquals (maxRecords / 2, cases.size(), 
            'Half of the Cases created should be returned when searching for one Account and both Record Types');
    }

	@isTest
    private static void getCaseDetailsTest(){
         Case newCase = new Case(Status = 'New',
                                Origin = 'RefLabs Portal',
                                Type = 'Master Data Inquiry',
                                Subject = 'RefLabs Portal Case test',
                                Description = 'Portal Case',
                                SuppliedEmail = 'test11@reflabs.com',
                                ZTS_EU_Market__c = 'Canada'
                               );
        insert newCase;
        
        Test.startTest();
        Case retrievedCase= CasesSelector.getCaseDetail(newCase.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, retrievedCase, 'Retrieved Case should not be null');
    }
}