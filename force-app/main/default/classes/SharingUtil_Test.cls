/**
 * @description       : Test Class for SharingUtil.cls
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 01-25-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   01-21-2021   Morgan Marchese @ Zoetis Inc   Initial Version
**/
@isTest
private class SharingUtil_Test {
    private static final Integer MAX_ACCOUNTS = 5;
    @testSetup
    static void setup(){
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;

        Territory2Type territoryType = [SELECT Id, DeveloperName 
                                        FROM Territory2Type 
                                        LIMIT 1];
        Territory2Model territoryModel = new Territory2Model();
        territoryModel.DeveloperName = 'TestModel';
        territoryModel.Name = 'TestModel';
        insert territoryModel;

        Territory2 territory = new Territory2();
        territory.AccountAccessLevel = 'Edit';
        territory.CaseAccessLevel = 'Edit';
        territory.DeveloperName = 'TestTerritory';
        territory.Name = 'TestTerritory';
        territory.OpportunityAccessLevel = 'Edit';
        territory.Territory2ModelId = territoryModel.Id;
        territory.Territory2TypeId = territoryType.Id;
        insert territory;

        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            List<State_Country__c> stateCountryList = new List<State_Country__c>();
            List<Account> accountList = new List<Account>();    
            TestDataFactory.createVetSaveMarket_UK('United Kingdom',true);
            
            State_Country__c stateCountryUK = TestDataFactory.createStateCountry('United Kingdom','County Down',false);
            stateCountryList.add(stateCountryUK);
            insert stateCountryList;
           
            // Create Test Accounts with different NARC Ids
            for(Integer i = 0;i<MAX_ACCOUNTS;i++){
                Account acct = TestDataFactory.createAccount_EU('UK Test Account ' + i,stateCountryUK.Id,false);
                accountList.add(acct);
            }
            for(Integer i = 0;i<MAX_ACCOUNTS;i++){
                Account acct = TestDataFactory.createAccount_US('US Test Account ' + i,false);
                accountList.add(acct);
            }
            insert accountList;

            List<ObjectTerritory2Association> objAssociations = new List<ObjectTerritory2Association>();
            for(Account record : accountList){
                ObjectTerritory2Association association = new ObjectTerritory2Association();
                association.ObjectId = record.Id;
                association.Territory2Id = territory.Id;
                association.AssociationCause = 'Territory2Manual';
                objAssociations.add(association);
            }
            insert objAssociations;
        }
    }
	@IsTest
    static void createShares_Test(){
        List<AccountShare> acctShareList = new List<AccountShare>();
        List<Account> accounts = [SELECT Id 
                                    FROM Account];
        User contextUser = new User(Id = UserInfo.getUserId());
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        for(Account record : accounts){
            AccountShare share = new AccountShare();
            share.AccountId = record.Id;
            share.UserOrGroupId = contextUser.Id;
            share.AccountAccessLevel = 'Edit';
            share.OpportunityAccessLevel = 'Edit';
            share.CaseAccessLevel = 'Edit';
            share.ContactAccessLevel = 'Edit';
            share.RowCause = 'Manual';
            acctShareList.add(share);
        }
        Test.startTest();
        System.runAs(contextUser){
            saveResults = SharingUtil.create(acctShareList);            
        }
        Test.stopTest();

        for(Database.SaveResult result : saveResults){
            System.assert(result.isSuccess(),'All Share Records Should Be Inserted Successfully');
        }
        System.assertEquals(accounts.size(), saveResults.size(),'Each Account Should Have One Successul Save Result');
        List<AccountShare> accountShares = [SELECT Id 
                                            FROM AccountShare 
                                            WHERE AccountId IN :accounts 
                                            AND UserOrGroupId = :contextUser.Id];
        System.assertEquals(accounts.size(), accountShares.size(),'Each Account Should Have One Successul Save Result');
    }
    @IsTest
    static void createSharesEmptyList_Test(){
        List<AccountShare> shares = new List<AccountShare>();
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        saveResults = SharingUtil.create(shares);
        System.assertEquals(0, saveResults.size(),'An Empty Share List should return an Empty Save List');
    }

    @IsTest
    static void getObjTerritoryAssociations_Test(){
        User contextUser = new User(Id = UserInfo.getUserId());
        Set<Id> objectIds = new Set<Id>();
        Set<Id> territoryIds = new Set<Id>();
        Map<Id,Territory2> territoryMap = new Map<Id,Territory2>([SELECT Id 
                                                                    FROM Territory2]);
        List<ObjectTerritory2Association> associationList;
        Map<Id,Account> accountMap = new Map<Id, Account>([SELECT Id 
                                                            FROM Account]);
        Test.startTest();
        System.runAs(contextUser){
            associationList = SharingUtil.getObjTerritoryAssociations(accountMap.keySet(), territoryMap.keySet());
        }
        Test.stopTest();
        System.assertEquals(accountMap.size(), associationList.size());
    }

    @IsTest
    static void deleteObjTerritoryAssociations_Test(){
        User contextUser = new User(Id = UserInfo.getUserId());
        Set<Id> objectIds = new Set<Id>();
        Set<Id> territoryIds = new Set<Id>();
        Map<Id,Territory2> territoryMap = new Map<Id,Territory2>([SELECT Id 
                                                                    FROM Territory2]);
        List<ObjectTerritory2Association> associationList;
        List<Database.DeleteResult> deleteResults;
        Map<Id,Account> accountMap = new Map<Id, Account>([SELECT Id 
                                                            FROM Account]);
        Test.startTest();
        System.runAs(contextUser){
            associationList = SharingUtil.getObjTerritoryAssociations(accountMap.keySet(), territoryMap.keySet());
            deleteResults = SharingUtil.deleteObjTerritoryAssociations(associationList);
        }
        Test.stopTest();
        associationList = [SELECT Id 
                            FROM ObjectTerritory2Association];
        System.assertEquals(0, associationList.size());
    }
}