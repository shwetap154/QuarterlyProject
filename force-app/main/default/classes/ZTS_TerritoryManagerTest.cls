/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class ZTS_TerritoryManagerTest 
{
    private static final Date FROM_DATE = Date.newInstance(2018, 8, 27);
    private static final Date TO_DATE = Date.newInstance(2020, 8, 27);
    private static final Id accountId = SL_IdGenerator.generateMockIdForObjectType(Account.SObjectType);
    private static final Id account1Id = SL_IdGenerator.generateMockIdForObjectType(Account.SObjectType);
    private static final Id accountTerritoryId = SL_IdGenerator.generateMockIdForObjectType(ZTS_AccountTerritory__c.SObjectType);
    private static final Id accountTerritoryId2 = SL_IdGenerator.generateMockIdForObjectType(ZTS_AccountTerritory__c.SObjectType);
    private static final Id territoryId = SL_IdGenerator.generateMockIdForObjectType(ZTS_EU_Territory__c.SObjectType);
    private static final Id accountPositionId = SL_IdGenerator.generateMockIdForObjectType(ZTS_EU_Account_Position__c.SObjectType);
    private static final Id userTerritory2AssociationId = SL_IdGenerator.generateMockIdForObjectType(UserTerritory2Association.SObjectType);
    private static final Id parentTerritoryId = SL_IdGenerator.generateMockIdForObjectType(ZTS_EU_Territory__c.SObjectType);
    private static final Id positionId = SL_IdGenerator.generateMockIdForObjectType(ZTS_EU_Position__c.SObjectType); 
    private static final Id stdTerritoryId = SL_IdGenerator.generateMockIdForObjectType(Territory2.SObjectType); 
    private static final Id positionHistoryId = '0172F00004UiTWjQAN'; //SL_IdGenerator.generateMockIdForObjectType(ZTS_EU_Position__c.SObjectType); //SL_IdGenerator.generateMockIdForObjectType(ZTS_EU_Position__History.SObjectType); 
    private static final Id groupId = SL_IdGenerator.generateMockIdForObjectType(Group.SObjectType);

    @isTest
    private static void test_ZTS_TerritoryManager_NoData() 
    {
        ZTS_TerritoryManager objCntl = new ZTS_TerritoryManager();
        
        system.assertEquals(ZTS_TerritoryManager.fetchAccountWithNARCID(new List<String>{'test123'}).size(), 0);
        system.assertEquals(ZTS_TerritoryManager.getNARCID_AccountMap(new List<Account>{}).size(), 0);
        system.assertEquals(ZTS_TerritoryManager.fetch_NARCID_AccountListMap(new Set<String>{'test123'}).size(),0);
        system.assertEquals(ZTS_TerritoryManager.fetch_NARCID_AccountsMap(new Set<Id>{accountId}).size(), 0);
        system.assertEquals(ZTS_TerritoryManager.fetch_NARCID_Accounts(new Set<String>{'NARCId123'}).size(), 0);
        system.assertEquals(ZTS_TerritoryManager.getAccountInfo(new List<Id>{accountId}).size(), 0);
        system.assertEquals(ZTS_TerritoryManager.getNARCIDs(new List<ZTS_AccountTerritory__c>{}).size(), 0);
        
        //ZTS_TerritoryManager.zoetisTerritoryUpdate(new List<String>{territoryId});
        ZTS_TerritoryManager.populateAccountTSF(new List<ZTS_AccountTerritory__c>{}, False);
        
        //ZTS_TerritoryManager.removeTerritories(new List<String>{territoryId});
        ZTS_TerritoryManager.removeTerritory(new List<Id>{});
        system.assertEquals(ZTS_TerritoryManager.getAccountTerritoryRecordsForAccTeam(new List<ZTS_EU_Account_Position__c>{}).size(),0 );

        ZTS_TerritoryManager.getUserTerritoryCSV_ToInsert(new List<ZTS_EU_Position__c>{});
        
        system.assertEquals(ZTS_TerritoryManager.getSFID_ToDelete(new List<SObject>{}), '');
        
        ZTS_TerritoryManager.insertUserTerritoryBatch(new List<ZTS_EU_Position__c>{});
        
        system.assertEquals(ZTS_TerritoryManager.createAccountShares(accountId, territoryId).size(), 1);
        
        ZTS_TerritoryManager.deleteAccountShares(new List<ZTS_AccountTerritory__c>{});
        ZTS_TerritoryManager.deleteAccountTerritoryShares(new List<Id>{accountId});
        
        system.assertEquals(ZTS_TerritoryManager.fetchTerritoryAccTerrMap(new List<ZTS_EU_Position__c>{}).size(), 0);
        
        ZTS_TerritoryManager.createAccountTeams(new List<ZTS_EU_Position__c>{}, new List<ZTS_AccountTerritory__c>{});
        ZTS_TerritoryManager.createAccountTeams(new List<ZTS_AccountTerritory__c>{});
        
        system.assertEquals(ZTS_TerritoryManager.updatedUserTerrHistoryRecords(FROM_DATE, TO_DATE).size(), 0);
        system.assertEquals(ZTS_TerritoryManager.updatedUserTerrUserRecordsToRemove(new List<ZTS_EU_Position__History>{}).size(), 0);
        
        ZTS_TerritoryManager.removeUserTerritory(new List<UserTerritory2Association>{}, 'sessionId123');
        ZTS_TerritoryManager.removeCustomUserTerritory(new List<ZTS_EU_Position__c>{});
    } 
    
    private static Account getMockAccountRecord() 
    {
        String strAccountJson = '{"attributes":' +
                           '{'+
                            '"type":"Account"'+
                            '},'+
                            '"Id":"'+accountId+'",' +
                            '"Name":"Account Test 1",'+
                            //'"ZTS_TSF__c":"AccTerri",' +
                            '"ZTS_EU_Zoetis_SFDC_ID__c":"NARCId123"'+
                            '}';
        Account objAccount = (Account)JSON.deserialize(strAccountJson, Account.class);
        
        return objAccount;
    }
    
     private static Account getMockAccountRecordWithZTSTSF() 
    {
        String strAccountJson = '{"attributes":' +
                           '{'+
                            '"type":"Account"'+
                            '},'+
                            '"Id":"'+account1Id+'",' +
                            '"Name":"Account Test 1",'+
                            '"ZTS_TSF__c":"AccTerri",' +
                            '"ZTS_EU_Zoetis_SFDC_ID__c":"NARCId123"'+
                            '}';
        Account objAccount = (Account)JSON.deserialize(strAccountJson, Account.class);
        
        return objAccount;
    }
    
    private static ZTS_AccountTerritory__c getMockAccountTerritoryRecord()
    {
        ZTS_AccountTerritory__c objATMock = new ZTS_AccountTerritory__c(Id = accountTerritoryId, ZTS_Zoetis_SFDC_ID__c = 'NARCId123',
                                                                        ZTS_EU_Account__c = accountId);
        String strAccountTerritoryJson = '{"attributes":' +
                           '{'+
                            '"type":"ZTS_AccountTerritory__c"'+
                            '},'+
                            '"Id":"'+accountTerritoryId+'",' +
                            '"ZTS_Zoetis_SFDC_ID__c":"NARCId123",'+
                            '"ZTS_TerrName__c":"AccTerri",'+
                            '"ZTS_Territory_SF_ID__c":"'+stdTerritoryId+'",'+
                            '"ZTS_EU_Territory__c":"'+territoryId+'",'+
                            '"ZTS_EU_Account__c":"'+accountId+'"'+
                            '}';
        ZTS_AccountTerritory__c objAT = (ZTS_AccountTerritory__c)JSON.deserialize(strAccountTerritoryJson, ZTS_AccountTerritory__c.class);
        return objAT;
    }
    
    private static ZTS_AccountTerritory__c getMockAccountTerritoryRecord2()
    {
        ZTS_AccountTerritory__c objATMock = new ZTS_AccountTerritory__c(Id = accountTerritoryId2, ZTS_Zoetis_SFDC_ID__c = 'NARCId123',
                                                                        ZTS_EU_Account__c = account1Id);
        String strAccountTerritoryJson = '{"attributes":' +
                           '{'+
                            '"type":"ZTS_AccountTerritory__c"'+
                            '},'+
                            '"Id":"'+accountTerritoryId+'",' +
                            '"ZTS_Zoetis_SFDC_ID__c":"NARCId123",'+
                            '"ZTS_TerrName__c":"AccTerri",'+
                            '"ZTS_Territory_SF_ID__c":"'+stdTerritoryId+'",'+
                            '"ZTS_EU_Territory__c":"'+territoryId+'",'+
                            '"ZTS_EU_Account__c":"'+accountId+'"'+
                            '}';
        ZTS_AccountTerritory__c objAT = (ZTS_AccountTerritory__c)JSON.deserialize(strAccountTerritoryJson, ZTS_AccountTerritory__c.class);
        return objAT;
    }
    
    private static ZTS_EU_Territory__c getMockTerritoryRecord()
    {
        
        String strTerritoryJson = '{"attributes":' +
                           '{'+
                            '"type":"ZTS_EU_Territory__c"'+
                            '},'+
                            '"Id":"'+territoryId+'",' +
                            '"ZTS_EU_Market__c":"India",'+
                            '"Name":"Territory-1",'+ 
                            '"ZTS_EU_Terr_SFID__c":"NARCId123",'+
                            '"ZTS_EU_Parent_Territory__c":"'+parentTerritoryId+'"'+
                            '}';
        ZTS_EU_Territory__c objTerri = (ZTS_EU_Territory__c)JSON.deserialize(strTerritoryJson, ZTS_EU_Territory__c.class);                        
        return objTerri;
    }
    
    private static ZTS_EU_Account_Position__c getMockAccountPositionRecord()
    {
        String strAccountPositionJSON = '{"attributes":' +
                                   '{'+
                                    '"type":"ZTS_EU_Account_Position__c"'+
                                    '},'+
                                    '"Id":"'+accountPositionId+'",' +
                                    '"ZTS_EU_Account__c":"'+accountId+'",'+
                                    '"ZTS_EU_Territory__c":"'+territoryId+'"'+
                                    '}';
        
        ZTS_EU_Account_Position__c objAT = (ZTS_EU_Account_Position__c)JSON.deserialize(strAccountPositionJSON, ZTS_EU_Account_Position__c.class);                                    
        
        return objAT;
    }
    
    private static ZTS_EU_Position__c getMockPositionRecord()
    {
        String strPositionJSON = '{"attributes":' +
                                   '{'+
                                    '"type":"ZTS_EU_Position__c"'+
                                    '},'+
                                    '"Id":"'+positionId+'",' +
                                    //'"ZTS_AccountTerritory__c":"'+accountTerritoryId+'",'+
                                    '"ZTS_ChangeFlag__c":"Delete",'+
                                    '"ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c":"NARCId123",'+
                                    '"ZTS_EU_Territory__c":"'+territoryId+'"'+
                                    '}';
        
        ZTS_EU_Position__c objPosition = (ZTS_EU_Position__c)JSON.deserialize(strPositionJSON, ZTS_EU_Position__c.class);  
        
        return objPosition;
    }
    
    private static UserTerritory2Association getMockUserTerritoryAssocition()
    {
        String strUTAJson = '{"attributes":' +
                                   '{'+
                                    '"type":"UserTerritory2Association"'+
                                    '},'+
                                    '"Id":"'+userTerritory2AssociationId+'",' +
                                    '"ZTS_EU_Territory__c":"'+territoryId+'"'+
                                    '}';
        
        UserTerritory2Association objUTA = (UserTerritory2Association)JSON.deserialize(strUTAJson, UserTerritory2Association.class);
        return objUTA;
    }
    
    private static Territory2 getMockStdTerritoryRecord()
    {
        String strStdTerritoryJSON = '{"attributes":' +
                                   '{'+
                                    '"type":"Territory2"'+
                                    '},'+
                                    '"Id":"'+stdTerritoryId+'",' +
                                    '"ZTS_Terr_SFID__c":"'+stdTerritoryId+'"'+
                                    '}';
        
        Territory2 objStdTerritory = (Territory2)JSON.deserialize(strStdTerritoryJSON, Territory2.class);
        return objStdTerritory;
    }
    
    private static Group getMockGRoupRecord()
    {
        String strGroupJSON = '{"attributes":' +
                                   '{'+
                                    '"type":"Group"'+
                                    '},'+
                                    '"Id":"'+groupId+'",' +
                                    '"RelatedId":"'+territoryId+'",'+
                                    '"Type":"Territory"'+
                                    '}';
        
        Group objGroup = (Group)JSON.deserialize(strGroupJSON, Group.class);
        return objGroup;
    }    
    
    private static ZTS_EU_Position__History getPositionHistoryRecord()
    {
        Id userId = UserInfo.getUserId();
        String strPositionHistoryJson = '{"attributes":' +
                                   '{'+
                                    '"type":"ZTS_EU_Position__History"'+
                                    '},'+
                                    '"Id":"'+positionHistoryId+'",' +
                                    '"parentId":"'+territoryId+'"'+
                                    //'"OldValue":"null",'+
                                    //'"NewValue":"0052F000003LPZzQAO"'+
                                    '}';
        
        ZTS_EU_Position__History objPositionHistory = (ZTS_EU_Position__History)JSON.deserialize(strPositionHistoryJson, ZTS_EU_Position__History.class);
        return objPositionHistory;
    }
    
    @isTest
    private static void test_ZTS_TerritoryManager_WithData() 
    {
        ZTS_TerritoryManager objCntl = new ZTS_TerritoryManager();
        system.assertEquals(ZTS_TerritoryManager.getNARCID_AccountMap(new List<Account>{getMockAccountRecord()}).size(), 1);
        
        ZTS_TerritoryManager.mockAccountList = new List<Account>{getMockAccountRecord()};
        system.assertEquals((ZTS_TerritoryManager.fetch_NARCID_AccountListMap(new Set<String>{'NARCId123'})).keyset(), new Set<String>{'NARCId123'});
        
        system.assertEquals((ZTS_TerritoryManager.fetch_NARCID_AccountsMap(new Set<Id>{accountId})).keyset(), new Set<String>{'NARCId123'});
        
        system.assertEquals((ZTS_TerritoryManager.fetch_NARCID_Accounts(new Set<String>{'NARCId123'})).keyset(), new Set<String>{'NARCId123'});
        
        system.assertEquals((ZTS_TerritoryManager.getAccountInfo(new List<Id>{accountId})).keyset(), new Set<String>{'NARCId123'});
        
        system.assertEquals(ZTS_TerritoryManager.getNARCIDs(new List<ZTS_AccountTerritory__c>{getMockAccountTerritoryRecord()}).size(), 1);
        
        ZTS_TerritoryManager.populateAccountTSF(new List<ZTS_AccountTerritory__c>{getMockAccountTerritoryRecord()}, true);
        ZTS_TerritoryManager.populateAccountTSF(new List<ZTS_AccountTerritory__c>{getMockAccountTerritoryRecord2()},false);
        
        ZTS_TerritoryManager.mockTerritoryList = new List<ZTS_EU_Territory__c>{getMockTerritoryRecord()};
        ZTS_TerritoryManager.zoetisTerritoryUpdate(new List<String>{territoryId});
        ZTS_TerritoryManager.removeTerritories(new List<String>{territoryId});
        
        ZTS_TerritoryManager.mockStdTerritoryList = new List<Territory2>{getMockStdTerritoryRecord()};
        system.assertEquals(ZTS_TerritoryManager.updateCustomTerrAssignedFlag().size(), 0);
        
        system.assertEquals(ZTS_TerritoryManager.getAccountTerritoryRecordsForAccTeam(new List<ZTS_EU_Account_Position__c>{getMockAccountPositionRecord()}).size(), 0);
        
        List<ZTS_AccountTerritory__c> lstAccountTerritory = new List<ZTS_AccountTerritory__c>{getMockAccountTerritoryRecord()};
        ZTS_TerritoryManager.mockAccountPositionList = new List<ZTS_EU_Account_Position__c> {getMockAccountPositionRecord()};
        
        ZTS_TerritoryManager.createAccountTeams(new List<ZTS_EU_Position__c>{getMockPositionRecord()}, lstAccountTerritory); 
        ZTS_TerritoryManager.createAccountTeams(lstAccountTerritory);
        system.assertEquals(ZTS_TerritoryManager.getUserTerritoryCSV_ToInsert(new List<ZTS_EU_Position__c>{getMockPositionRecord()}), '');
        
        ZTS_TerritoryManager.removeCustomUserTerritory(new List<ZTS_EU_Position__c>{getMockPositionRecord()});
        ZTS_TerritoryManager.getSFID_ToDelete(new List<SObject>{getMockUserTerritoryAssocition()});
        ZTS_TerritoryManager.deleteAccountShares(lstAccountTerritory);
       
        ZTS_TerritoryManager.mockAccountTerritoryList = lstAccountTerritory;
        ZTS_TerritoryManager.mockIsDelete = false;
        ZTS_TerritoryManager.deleteAccountTerritory(lstAccountTerritory, false);
        
        ZTS_TerritoryManager.mockIsDelete = true;
        ZTS_TerritoryManager.deleteAccountTerritory(lstAccountTerritory, true);
        
        ZTS_TerritoryManager.mockGroupList = new List<Group>{getMockGRoupRecord()};
        system.assertEquals(ZTS_TerritoryManager.getTerritoryGroupMap(new List<Id>{territoryId}).size(), 1);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('JobInfoResponseMock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
         
        Test.setMock(HttpCalloutMock.class, mock);
	        
        ZTS_TerritoryManager.removeUserTerritoryAsync(new List<String>{getMockUserTerritoryAssocition().Id}, UserInfo.getSessionId());
        ZTS_TerritoryManager.insertUserTerritoryBatch(new List<ZTS_EU_Position__c>{getMockPositionRecord()});
        
        system.assertEquals(ZTS_TerritoryManager.updatedUserTerrUserRecordsToRemove(new List<ZTS_EU_Position__History>{getPositionHistoryRecord()}).size(), 0);
    }
}