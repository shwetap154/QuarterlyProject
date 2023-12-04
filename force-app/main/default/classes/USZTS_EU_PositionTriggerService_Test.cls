/**
 * @description       : 
 * @author            : Prasun Dubey
 * @group             : 
 * @last modified on  : 03-09-2021
 * @last modified by  : Prasun Dubey
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   03-09-2021   Prasun Dubey   				Initial Version
**/
@isTest
private class USZTS_EU_PositionTriggerService_Test {
    private static final Integer MAX_ACCOUNTS = 5;

    @TestSetup
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
            // Create Zoetis Global Custom Territories, related to Standard Territories
            ZTS_EU_Territory__c ztsTerritoryUK = TestDataFactory.createZTSTerritory('TestTerritoryUK', territory.Id, 'United Kingdom', false);
            ZTS_EU_Territory__c ztsTerritoryUS = TestDataFactory.createZTSTerritory('TestTerritoryUS', territory.Id, 'United States', false);
            List<ZTS_EU_Territory__c> ztsTerritoryList = new List<ZTS_EU_Territory__c>{ztsTerritoryUK,ztsTerritoryUS};
            insert ztsTerritoryList;

            // Create Zoetis Global Positions, related to Global Custom Territories
            List<ZTS_EU_Position__c> positionList = new List<ZTS_EU_Position__c>();
            for(ZTS_EU_Territory__c record : ztsTerritoryList){
                ZTS_EU_Position__c tempPosition = TestDataFactory.createPosition(record.Name, record.Id, record.ZTS_EU_Market__c, false);  
                positionList.add(tempPosition);  
            }
            insert positionList;
            
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            List<State_Country__c> stateCountryList = new List<State_Country__c>();
            List<Account> accountList = new List<Account>();    
            TestDataFactory.createVetSaveMarket_UK('United Kingdom',true);
            
            State_Country__c stateCountryUK = TestDataFactory.createStateCountry('United Kingdom','County Down',false);
            stateCountryList.add(stateCountryUK);
            insert stateCountryList;
           
            // Create Test Accounts with different Markets
            for(Integer i = 0;i<MAX_ACCOUNTS;i++){
                Account acct = TestDataFactory.createAccount_EU('UK Test Account ' + i,stateCountryUK.Id,false);
                accountList.add(acct);
            }
            for(Integer i = 0;i<MAX_ACCOUNTS;i++){
                Account acct = TestDataFactory.createAccount_US('US Test Account ' + i,false);
                accountList.add(acct);
            }
            insert accountList;


            List<ZTS_AccountTerritory__c> accountTerritoryList = new List<ZTS_AccountTerritory__c>();
            for(Account record : accountList){
                ZTS_AccountTerritory__c tempTerritory;
                if(record.ZTS_EU_Market__c == 'United States'){
                    tempTerritory = TestDataFactory.createAccountTerritory(record.Id, ztsTerritoryUS.Id, false);
                }else{
                    tempTerritory = TestDataFactory.createAccountTerritory(record.Id, ztsTerritoryUK.Id, false);
                }
                accountTerritoryList.add(tempTerritory);
            }
            insert accountTerritoryList;
        }
    }
    @IsTest
    static void updatePositionRecord(){
        
        List<Account> accounts = [SELECT Id 
                                FROM Account 
                                WHERE ZTS_EU_Market__c != 'United States'];
        System.assertEquals(MAX_ACCOUNTS,accounts.size());
        Test.startTest();
        Map<Id,ZTS_AccountTerritory__c> accountTerritoryMap = new Map<Id,ZTS_AccountTerritory__c>([SELECT Id,ZTS_EU_Market__c 
                                                                                                   FROM ZTS_AccountTerritory__c 
                                                                                                   WHERE ZTS_EU_Account__c IN :accounts]);
        for(ZTS_AccountTerritory__c record : accountTerritoryMap.values()){
            System.debug('Record Market: ' + record.ZTS_EU_Market__c);
        }
        
        ZTS_EU_Position__c positonRecord = [Select Id From ZTS_EU_Position__c Where Market__c = 'United States' limit 1];
        update positonRecord;
        
        System.assertEquals(accounts.size(),accountTerritoryMap.size());
        
        Test.stopTest();
    }
}