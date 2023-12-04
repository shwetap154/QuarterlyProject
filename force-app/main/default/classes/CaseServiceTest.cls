/**
 * @description       : Test class for CaseService
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-12-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-11-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for unblockRelatedRefLabOnboardingCases
 * 1.1   04-12-2022   Ethan Hirsch @ Zoetis Inc   Add logic for creating the Case Trigger Custom Setting.
**/
@isTest
private class CaseServiceTest {
    private static final Integer totalCaseCount = 4;
    private static final String singleCaseAccountName = 'singleCaseAccount';
    private static final String caseTriggerName = 'ZTS_EU_ServiceRequest';

    @TestSetup
    private static void setup(){
        // Setup the Case Trigger Setting and refresh the Trigger Activation Map so the Case Trigger can be disabled.
        TriggerActivation__c triggerActivation = new TriggerActivation__c(Name = caseTriggerName, ZTS_EU_Bypass__c = true);
        insert triggerActivation;

        CustomSettingService.refreshTriggerActivationMap();

        List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(2);
        accounts[1].Name = singleCaseAccountName;
        insert accounts;

        Map<String, Schema.RecordTypeInfo> caseRecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        
        List<Case> allCases = ZTS_DataUtilityTest.createCases(totalCaseCount,
            caseRecordTypes.get('Ref_Labs_Onboarding').getRecordTypeId());

        for (integer i = 0; i < allCases.size(); i++) {
            allCases[i].Status = 'On Hold';
            allCases[i].Has_RefLabs_Multiple_Ship_To__c = true;
            if (i < 3) {
                allCases[i].AccountId = accounts[0].Id;
            }
            else {
                allCases[i].AccountId = accounts[1].Id;
            }
        }

        // Set one Case's Status to New to confirm it won't change when testing unblockRelatedRefLabOnboardingCases
        allCases[1].Status = 'New';

        // Disable Case logic to prevent Status from changing
        
        CustomSettingService.setTriggerBypass(caseTriggerName, true);
        insert allCases;
        CustomSettingService.setTriggerBypass(caseTriggerName, false);
    }

    @isTest
    private static void unblockRelatedRefLabOnboardingCases_SingleCase_Test() {
        Id accountId = [
            SELECT Id 
            FROM Account
            WHERE Name =: singleCaseAccountName
            LIMIT 1].Id;

        Test.startTest();
            CaseService.unblockRelatedRefLabOnboardingCases(new Set<Id> {accountId});
        Test.stopTest();

        List<Case> accountCases = [
            SELECT Id, Status, Has_RefLabs_Multiple_Ship_To__c
            FROM Case
            WHERE AccountId =: accountId];
        
        for (Case accountCase : accountCases) {
            system.assertEquals('In Progress', accountCase.Status, 'Case Status should be In Progress');
            system.assertEquals(false, accountCase.Has_RefLabs_Multiple_Ship_To__c, 
                'Has_RefLabs_Multiple_Ship_To__c Should have changed to false');
        }
    }

    @isTest
    private static void unblockRelatedRefLabOnboardingCases_MultipleCases_Test() {
        Set<Id> accountIds = new Map<Id, Account>([SELECT Id FROM Account]).keySet();
        
        List<Case> accountCases = [
            SELECT Id, Status
            FROM Case
            WHERE AccountId in: accountIds];
        
        system.assertEquals(totalCaseCount, accountCases.size(),
            'More/Less Cases were created than expected.');

        // The Case with a Status of New should not change after running unblockRelatedRefLabOnboardingCases
        Id newStatusCaseId;
        for (Case accountCase : accountCases) {
            if (accountCase.Status == 'New') {
                newStatusCaseId = accountCase.Id;
                break;
            }
        }

        Test.startTest();
            CaseService.unblockRelatedRefLabOnboardingCases(accountIds);
        Test.stopTest();

        accountCases = [
            SELECT Id, Status, Has_RefLabs_Multiple_Ship_To__c
            FROM Case
            WHERE Id in: accountCases];

        for (Case accountCase : accountCases) {
            if (accountCase.Id == newStatusCaseId) {
                System.assertEquals('New', accountCase.Status,
                    'The Status of the Case with a Status of New should not have change');
            }
            else {
                System.assertEquals('In Progress', accountCase.Status,
                    'The Status of the Case should be In Progress');
            }

            system.assertEquals(false, accountCase.Has_RefLabs_Multiple_Ship_To__c, 
                'Has_RefLabs_Multiple_Ship_To__c Should have changed to false');
        }
    }
}