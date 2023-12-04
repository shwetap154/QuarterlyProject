/**
 * @description       : Test class for AccountTerritoriesSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 09-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-25-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for selectByAccountIdWithRelatedData
 * 1.1   07-11-2022   Ethan Hirsch @ Zoetis Inc   Change input type for selectByAccountIdWithRelatedData
 * 1.2   09-19-2022   Ethan Hirsch @ Zoetis Inc   Update selectByAccountIdWithRelatedData_Test to change the output 
 *                                                type of selectByAccountIdWithRelatedData.
**/
@isTest
private class AccountTerritoriesSelectorTest {
    private static integer MAX_ACCOUNTS = 5;
    @TestSetup
    private static void setup(){
        List<Account> accounts = ZTS_EU_DataUtilityTest.createAccountRecord(MAX_ACCOUNTS);
        insert accounts;

        Territory2 territory;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Territory2Type territoryType = [
                SELECT Id, DeveloperName
                FROM Territory2Type
                LIMIT 1
            ];

            Territory2Model territoryModel = new Territory2Model();
            territoryModel.DeveloperName = 'TestModel';
            territoryModel.Name = 'TestModel';
            insert territoryModel;

            territory = new Territory2();
            territory.AccountAccessLevel = 'Edit';
            territory.CaseAccessLevel = 'Edit';
            territory.DeveloperName = 'TestTerritory';
            territory.Name = 'TestTerritory';
            territory.OpportunityAccessLevel = 'Edit';
            territory.Territory2ModelId = territoryModel.Id;
            territory.Territory2TypeId = territoryType.Id;
            insert territory;
        }

        ZTS_EU_Territory__c ztsTerritory = TestDataFactory.createZTSTerritory('Test Territory', territory.Id,
            'United Kingdom', false);

        insert ztsTerritory;

        List<ZTS_AccountTerritory__c> accountTerritories = new List<ZTS_AccountTerritory__c>();
        for (Account account : accounts) {
            accountTerritories.add(TestDataFactory.createAccountTerritory(account, ztsTerritory, false, false));
        }

        insert accountTerritories;
    }

    @isTest
    private static void selectByAccountIdWithRelatedData_Test() {
        Set<Id> accountIds = new Map<Id, Account>([
                SELECT Id
                FROM Account
                LIMIT :MAX_ACCOUNTS
            ]).keySet();

        List<MergeService.MergeChildRelationship> childRelationships = new List<MergeService.MergeChildRelationship>();
        for (Schema.ChildRelationship childRelationship : Schema.ZTS_AccountTerritory__c.sObjectType.getDescribe().getChildRelationships()) {
            if (childRelationship.getRelationshipName() == 'Account_Teams__r') {
                childRelationships.add(new MergeService.MergeChildRelationship(childRelationship, null));
                break;
            }
        }

        Test.startTest();
            Map<Id, MergeService.RecordAndRelationships> accountTerritories = 
                AccountTerritoriesSelector.newInstance().selectByAccountIdWithRelatedData(accountIds, childRelationships);
        Test.stopTest();

        system.assertEquals(MAX_ACCOUNTS, accountTerritories.size(),
            'There should be one Account Territory per Account.');
    }
}