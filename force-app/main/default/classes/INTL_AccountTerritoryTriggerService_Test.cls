/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 01-28-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   01-26-2021   Morgan Marchese @ Zoetis Inc   Initial Version
**/
@isTest
private class INTL_AccountTerritoryTriggerService_Test {
    private static final Integer MAX_ACCOUNTS = 5;

    @testSetup static void setup(){
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        // TPDEV-2054 Test start here
        User intlUsr2 = new User();
        intlUsr2 = ZTS_EU_DataUtilityTest.createUserWithProfile('UK and Nordics Business Administrator', false);
        intlUsr2.FirstName = 'IntUser2';
        intlUsr2.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr2;

        PermissionSet ps = new PermissionSet();
        ps.Label= 'Test permission Terrtory access';
        ps.Name= 'Test_permission_Terrtory_access';
        ps.Description= 'Test Permission set for Territory access';
        Insert ps;
        List<ObjectPermissions> ObjectPermissionsList = new List<ObjectPermissions>();      
        ObjectPermissions obj1 = new ObjectPermissions();
        obj1.ParentId= ps.Id;
        obj1.SobjectType='ZTS_AccountTerritory__c';
        obj1.PermissionsRead = true;
        obj1.PermissionsDelete= true;
        obj1.PermissionsEdit = true;
        obj1.PermissionsViewAllRecords = true;
        obj1.PermissionsModifyAllRecords = true;
        ObjectPermissionsList.add(obj1);
        
        ObjectPermissions obj2 = new ObjectPermissions();
        obj2.ParentId= ps.Id;
        obj2.SobjectType= 'ZTS_EU_Territory__c';
        obj2.PermissionsRead = true;
        obj2.PermissionsViewAllRecords= true;
        ObjectPermissionsList.add(obj2);
        
        Insert ObjectPermissionsList;
        
        PermissionSetAssignment assignpermission = new PermissionSetAssignment();
        assignpermission.PermissionSetId =ps.Id;
        assignpermission.assigneeId=intlUsr2.Id;
        insert assignpermission;
        //TPDEV-2054 Test ends here
		
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
                Account acct =  TestDataFactory.createAccount_EU('UK Test Account ' + i,stateCountryUK.Id,false);
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
    static void afterInsert_Test(){
        User contextUser = new User(Id = UserInfo.getUserId());
        Map<String, ZTS_EU_Territory__c> marketToTerritoryMap = new Map<String, ZTS_EU_Territory__c>();
        List<ZTS_EU_Territory__c> territoryList = [SELECT Id,ZTS_EU_Market__c 
                                                    FROM ZTS_EU_Territory__c];
        for(ZTS_EU_Territory__c territory : territoryList){
            marketToTerritoryMap.put(territory.ZTS_EU_Market__c,territory);
        }
        List<Account> accountList = [SELECT Id,ZTS_EU_Market__c,
                                    ZTS_EU_Zoetis_SFDC_ID__c 
                                    FROM Account];
        List<ZTS_AccountTerritory__c> preTerritories = [SELECT Id FROM ZTS_AccountTerritory__c];
        System.assertEquals(accountList.size(), preTerritories.size(),'Account Territories created in Setup should be found');
        delete preTerritories;
        List<ZTS_EU_Account_Position__c> prePositions = [SELECT Id FROM ZTS_EU_Account_Position__c];
        System.assertEquals(accountList.size(), prePositions.size(),'Account Positions created in Setup should be found');
        delete prePositions;
        Test.startTest();
        System.runAs(contextuser){
            List<ZTS_AccountTerritory__c> accountTerritoryList = new List<ZTS_AccountTerritory__c>();
            for(Account record : accountList){
                ZTS_AccountTerritory__c tempTerritory;
                tempTerritory = TestDataFactory.createAccountTerritory(record.Id, marketToTerritoryMap.get(record.ZTS_EU_Market__c).Id, false);
                accountTerritoryList.add(tempTerritory);
            }
                
            insert accountTerritoryList;
        }
        Test.stopTest();
        List<ZTS_EU_Account_Position__c> accountPositionList = [SELECT Id,ZTS_EU_Active__c 
                                                            FROM ZTS_EU_Account_Position__c];
        
        System.assertEquals(accountList.size(),accountPositionList.size(),'Account Positions Should Be Created Automatically');
        for(ZTS_EU_Account_Position__c record : accountPositionList){
            System.assertEquals(true, record.ZTS_EU_Active__c,'Account Positions should start as active');
        }
    }

    @IsTest
    static void afterUpdate_Test(){
        User contextUser = new User(Id = UserInfo.getUserId());
        List<ZTS_AccountTerritory__c> acctTerritories;
        Test.startTest();
        System.runAs(contextuser){
            acctTerritories = [SELECT Id 
                                FROM ZTS_AccountTerritory__c 
                                WHERE ZTS_EU_Market__c != 'United States'];
            System.assertEquals(MAX_ACCOUNTS, acctTerritories.size());
            for(ZTS_AccountTerritory__c record : acctTerritories){
                record.ZTS_ChangeFlag__c = ZTS_GlobalConstants.CHANGE_FLAG_STATUS_DELETE;
            }
            update acctTerritories;   
        }
        Test.stopTest();

        acctTerritories = [SELECT Id 
                                FROM ZTS_AccountTerritory__c 
                                WHERE ZTS_EU_Market__c != 'United States'];
        System.assertEquals(0, acctTerritories.size());
    }

    @IsTest
    static void afterUpdate2_Test(){
        User contextUser = new User(Id = UserInfo.getUserId());
        List<ZTS_AccountTerritory__c> acctTerritories;
        List<Account> newAccounts = new List<Account>();
        State_Country__c stateCountryUK = [SELECT Id FROM State_Country__c LIMIT 1];
        for(Integer i = 0;i<MAX_ACCOUNTS;i++){
            Account acct = TestDataFactory.createAccount_EU('UK Test Account ' + i,stateCountryUK.Id,false);
            newAccounts.add(acct);
        }
        insert newAccounts;
        Test.startTest();
        System.runAs(contextuser){
            acctTerritories = [SELECT Id 
                                FROM ZTS_AccountTerritory__c 
                                WHERE ZTS_EU_Market__c != 'United States'];
            System.assertEquals(MAX_ACCOUNTS, acctTerritories.size());
            Integer recordCount = 0;
            for(ZTS_AccountTerritory__c record : acctTerritories){
                record.ZTS_EU_Account__c = newAccounts[recordCount].Id;
                recordCount++;
            }
            update acctTerritories;   
        }
        Test.stopTest();

        Set<Id> territoryIds = new Set<Id>();
        acctTerritories = [SELECT Id,ZTS_EU_Account__c,
                                ZTS_Territory_SF_ID__c 
                                FROM ZTS_AccountTerritory__c 
                                WHERE ZTS_EU_Market__c != 'United States'];
        for(ZTS_AccountTerritory__c territory : acctTerritories){
            territoryIds.add(territory.ZTS_Territory_SF_ID__c);
            Boolean match = false;
            for(Account acct : newAccounts){
                if(acct.Id == territory.ZTS_EU_Account__c){
                    match = true;
                }
            }
            System.assertEquals(true, match);
        }
        List<ObjectTerritory2Association> objectTerritoryAssociation = [SELECT Id 
                                                                        FROM ObjectTerritory2Association 
                                                                        WHERE ObjectId IN :newAccounts 
                                                                        AND Territory2Id IN :territoryIds];
        System.assertEquals(MAX_ACCOUNTS, objectTerritoryAssociation.size());
    }

    @IsTest
    static void beforeDelete_Test(){
        User contextUser= [SELECT Id FROM User WHERE FirstName = 'IntUser2'];//TPDEV-2054
        Map<Id,ZTS_AccountTerritory__c> territoryByAccountId = new Map<Id,ZTS_AccountTerritory__c>();
        Test.startTest();
        System.runAs(contextuser){
            List<ZTS_EU_Territory__c> territories = [SELECT Id 
                                                    FROM ZTS_EU_Territory__c 
                                                    WHERE ZTS_EU_Market__c = 'United Kingdom'];
            System.assertEquals(1,territories.size());
            List<ZTS_AccountTerritory__c> acctTerritories = [SELECT Id,ZTS_EU_Account__c FROM ZTS_AccountTerritory__c WHERE ZTS_EU_Territory__c = :territories[0].Id];
            System.assertEquals(MAX_ACCOUNTS, acctTerritories.size(),'Should Be Two Territories for each Account');
            Integer halfRecords = acctTerritories.size() / 2;
            Integer count=1;
            for(ZTS_AccountTerritory__c territory : acctTerritories){
                // since we only need some records to test, we will only collect  
                // and delete half of them
                if(count < halfRecords){
                    territoryByAccountId.put(territory.ZTS_EU_Account__c,territory);
                    count++;    
                }
            }
            // delete territory to check that unrelated 
            // account positions are not inactivated unintentionally
            delete territoryByAccountId.values();    
        }
        
        Test.stopTest();
        List<ZTS_EU_Account_Position__c> positionList = [SELECT Id, ZTS_EU_Market__c,
                                                        ZTS_EU_Active__c,ZTS_AccountTerritory__c,
                                                        ZTS_EU_Account__c 
                                                        FROM ZTS_EU_Account_Position__c];
        System.assertEquals(10,positionList.size(),'There should be one position for each account');
        for(ZTS_EU_Account_Position__c position : positionList){
            if(position.ZTS_EU_Market__c == 'United States'){
                System.assertEquals(true,position.ZTS_EU_Active__c,'Since this is an EU trigger, all US positions should stay active');
            }else{
                if(territoryByAccountId.containsKey(position.ZTS_EU_Account__c)){
                    System.assertEquals(false,position.ZTS_EU_Active__c,'If we deleted the Territory, the position should be inactive');
                }
                else{
                    System.assertEquals(true, position.ZTS_EU_Active__c,'If we didn\'t delete the Territory, the position should stay');
                }
            }
        }
    }

    @IsTest
    static void afterDelete_Test(){
        User contextUser = new User(Id = UserInfo.getUserId());
        Test.startTest();
        System.runAs(contextuser){
            
        }
        Test.stopTest();
    }

    @IsTest
    static void afterUndelete_Test(){
        User contextUser = new User(Id = UserInfo.getUserId());
        List<ZTS_EU_Territory__c> territories = [SELECT Id 
                                                    FROM ZTS_EU_Territory__c 
                                                    WHERE ZTS_EU_Market__c != 'United States'];
        System.assertEquals(1,territories.size());
        List<ZTS_AccountTerritory__c> acctTerritories = [SELECT Id,Name,ZTS_EU_Account__c 
                                                        FROM ZTS_AccountTerritory__c 
                                                        WHERE ZTS_EU_Territory__c = :territories[0].Id];
        System.assertEquals(MAX_ACCOUNTS, acctTerritories.size(),'Should Be A Territory for each Account');
        Set<String> recordNames = new Set<String>();
        for(ZTS_AccountTerritory__c territory : acctTerritories){
            recordNames.add(territory.Name);
        }
        delete acctTerritories;   
        
        Test.startTest();
        System.runAs(contextuser){
            List<ZTS_EU_Account_Position__c> accountPositions = [SELECT Id,ZTS_AccountTerritory__c,
                                                                ZTS_EU_Active__c
                                                                FROM ZTS_EU_Account_Position__c 
                                                                WHERE ZTS_EU_Market__c != 'United States'];
            for(ZTS_EU_Account_Position__c position : accountPositions){
                System.assertEquals(null,position.ZTS_AccountTerritory__c);
                System.assertEquals(false, position.ZTS_EU_Active__c);
            }
            List<ZTS_AccountTerritory__c> deletedTerritories = [SELECT Id,IsDeleted 
                                                                FROM ZTS_AccountTerritory__c 
                                                                WHERE Name IN : recordNames
                                                                AND IsDeleted = TRUE 
                                                                ALL ROWS];
            System.assertEquals(MAX_ACCOUNTS,deletedTerritories.size());
            undelete deletedTerritories;
        }
        Test.stopTest();
        List<ZTS_EU_Account_Position__c> accountPositionsAfter = [SELECT Id,ZTS_AccountTerritory__c,
                                                                ZTS_EU_Active__c
                                                                FROM ZTS_EU_Account_Position__c 
                                                                WHERE ZTS_EU_Market__c != 'United States'];
        System.assertEquals(MAX_ACCOUNTS,accountPositionsAfter.size(),'There should be one position for each account');
        for(ZTS_EU_Account_Position__c position : accountPositionsAfter){
            System.assertNotEquals(null,position.ZTS_AccountTerritory__c);
            System.assertEquals(true, position.ZTS_EU_Active__c);
        }
    }
}