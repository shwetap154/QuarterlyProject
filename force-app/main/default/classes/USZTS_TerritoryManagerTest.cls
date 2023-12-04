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
private class USZTS_TerritoryManagerTest {

      static testMethod void testFetchNARCId() {
        ZTS_DataUtilityTest.activateTriggerSettings();
        List < Account > acclist = ZTS_DataUtilityTest.createAccountRecord(1);
        for (Account acc : accList) acc.ZTS_EU_Market__c = 'United States';
        insert acclist;

        Set < Id > accids = new Set < Id > ();
        List < Id > accIdList = new List < Id > ();
        List < String > narcidlist = new List < String > ();

        for (Account acc: acclist) {
            accids.add(acc.id);
            accIdList.add(acc.id);
            narcidlist.add(acc.ZTS_US_NARC_ID__c);
        }


        System.assert(!accids.isEmpty(), 'Failed to create Accounts');
        System.assert(!accIdList.isEmpty(), 'Failed to create Accounts');
        System.assert(!narcidlist.isEmpty(), 'NARCIDs are empty on Account creation');


        Map < String, List < Account >> narAccListMap = USZTS_TerritoryManager.fetch_NARCID_AccountsMap(accids);

        System.assert(!narAccListMap.isEmpty(), 'Account with NARCID not found');

        USZTS_TerritoryManager.fetch_NARCID_Accounts(narAccListMap.keySet());

        narAccListMap = USZTS_TerritoryManager.fetch_NARCID_AccountListMap(narAccListMap.keySet());
        System.assert(!narAccListMap.isEmpty(), 'Account with NARCID not found');

        Map < String, Account > narcAccMap = USZTS_TerritoryManager.getAccountInfo(accIdList);
        System.assert(!narcAccMap.isEmpty(), 'Account with NARCID not found');
        
        


        List < Account > acclistWithNARCIDS = USZTS_TerritoryManager.fetchAccountWithNARCID(narcidlist);
        USZTS_TerritoryManager.getNARCID_AccountMap(acclist);

        System.assert(!acclistWithNARCIDS.isEmpty(), 'Account with NARCID not found');

    }

    static testMethod void testRemoveTerritory() {
        List < ZTS_EU_Territory__c > custTerritoryList = ZTS_DataUtilityTest.createCustomTerritory(7);
        insert custTerritoryList;

        List < String > terrIdList = new List < String > ();
        for (ZTS_EU_Territory__c terr: custTerritoryList) {
            terrIdList.add(terr.id);
        }

        USZTS_TerritoryManager.zoetisTerritoryUpdate(terrIdList);
        USZTS_TerritoryManager.updateCustomTerrAssignedFlag();

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = ZTS_DataUtilityTest.getJobUtilitiesMock();
        Test.setMock(HttpCalloutMock.class, multimock);
        
        USZTS_TerritoryManager.removeTerritories(terrIdList);
        List < UserTerritory2Association > usrterrlist = ZTS_DataUtilityTest.getStdUserTerrRecords();
        List < String > usrterrIds = new List < String > ();
        for (UserTerritory2Association ut: usrterrlist) {
            usrterrIds.add(ut.id);
        }
        System.runAs(new User(id = UserInfo.getUserId())) {
            USZTS_TerritoryManager.removeUserTerritoryAsync(usrterrIds, UserInfo.getSessionId());
        }
        Test.stopTest();
    }
  
    static testMethod void testAccTerr() {
        ZTS_DataUtilityTest.activateTriggerSettings();
        List < Account > acclist = ZTS_DataUtilityTest.createAccountRecord(10);
        for (Account acc : accList) acc.ZTS_EU_Market__c = 'United States';
        insert acclist;

        USZTS_TerritoryManager.SFA terrSFA = new USZTS_TerritoryManager.SFA();

        List < ZTS_EU_Territory__c > customterrList = ZTS_DataUtilityTest.createCustomTerritory(10);
        insert customterrList;

        List < ZTS_AccountTerritory__c > accterr = ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
        for (ZTS_AccountTerritory__c a : accterr) a.ZTS_EU_Market__c = 'United States';
        insert accterr;
        
        Test.startTest();
        
        USZTS_TerritoryManager.populateAccountTSF(accterr,true);
        
        USZTS_TerritoryManager.createAccountTeams(accterr);

        Test.stopTest();
    }
  
    static testMethod void testRemoveUserTerrRecords() {
        List < ZTS_EU_Territory__c > custTerritoryList = ZTS_DataUtilityTest.createCustomTerritory(7);
        insert custTerritoryList;

        List < ZTS_EU_Position__c > userterrlist = ZTS_DataUtilityTest.createUserTerritory(custTerritoryList);
        insert userterrlist;

        USZTS_TerritoryManager.updateCustomTerrAssignedFlag();
        USZTS_TerritoryManager.fetchTerritoryAccTerrMap(userterrlist);
        MultiStaticResourceCalloutMock mock = ZTS_DataUtilityTest.getJobUtilitiesMock();
        Test.setMock(HttpCalloutMock.class, mock);

        for (ZTS_EU_Position__c ut: userterrlist) {
            ut.ZTS_EU_Employee__c = null;
        }

        update userterrlist;
        
        List < ZTS_EU_Position__History > ut_histList = USZTS_TerritoryManager.updatedUserTerrHistoryRecords(Date.today(), Date.today());
        List < UserTerritory2Association > usrterrlist = ZTS_DataUtilityTest.getStdUserTerrRecords();
        List < String > usrterrIds = new List < String > ();
        List < UserTerritory2Association > stdusrterrlist = ZTS_DataUtilityTest.getStdUserTerrRecords();
        for (UserTerritory2Association ut: stdusrterrlist) {
            usrterrIds.add(ut.id);
        }
        Test.startTest();
          System.runAs(new User(id = UserInfo.getUserId())) {
            USZTS_TerritoryManager.removeUserTerritoryAsync(usrterrIds, UserInfo.getSessionId());
        }
        
        USZTS_TerritoryManager.updatedUserTerrUserRecordsToRemove(ut_histList);
        Test.stopTest();

    }
    
     static testMethod void testDeleteAccountTerritory(){
        
        ZTS_DataUtilityTest.activateTriggerSettings();
        List < Account > acclist = ZTS_DataUtilityTest.createAccountRecord(10);
        for (Account a : acclist) a.ZTS_EU_Market__c = 'United States';
        insert acclist;
         
        List < ZTS_EU_Territory__c > customterrList = ZTS_DataUtilityTest.createCustomTerritory(10);
        for (ZTS_EU_Territory__c terr : customterrList) terr.ZTS_EU_Market__c = 'United States';
        insert customterrList;

        List < ZTS_AccountTerritory__c > accterr = ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
        for (ZTS_AccountTerritory__c a : accterr) a.ZTS_EU_Market__c = 'United States';
        insert accterr;
         
        List<Id> atIds = new List<Id>();
        for(ZTS_AccountTerritory__c at : accterr)
            atIds.add(at.Id);
         
        List<Id> accIds = new List<Id>();
        for(Account at : acclist)
            accIds.add(at.Id);
        
        List < ZTS_EU_Position__c > userterrlist = ZTS_DataUtilityTest.createUserTerritory(customterrList);
        insert userterrlist;
         
        List < String > unassignedTerrIds = new List < String > ();

        for (ZTS_EU_Territory__c cterr: customterrList) {
            unassignedTerrIds.add(cterr.id);
        }

        System.runAs(new User(id = UserInfo.getUserId())) {
            USZTS_TerritoryManager.SFA ztm = new USZTS_TerritoryManager.SFA();
            List < Territory2 > stdTerrrList = ztm.upsertZoetisTerritory(unassignedTerrIds);
            
            USZTS_TerritoryManager.createAccountShares(acclist.get(0).Id, stdTerrrList.get(0).Id);
            USZTS_TerritoryManager.createAccountTeams(userterrlist, accterr);
        }
           
        Integer acctm_cnt=[SELECT COUNT() FROM ZTS_EU_Account_Position__c WHERE CreatedDate=TODAY AND ZTS_EU_Market__c = 'United States'];
        System.assert(acctm_cnt>0,'Failed to create Account Team records');
        
        Test.startTest();
         	USZTS_TerritoryManager.getTerritoryGroupMap(atIds);
         	USZTS_TerritoryManager.insertUserTerritoryBatch(userterrlist);
        	USZTS_TerritoryManager.deleteAccountShares(accterr);
         	USZTS_TerritoryManager.deleteAccountTerritoryShares(accIds);
        Test.stopTest();
        
    }
    
     static testMethod void testremoveCustomUserTerritory(){
         ZTS_DataUtilityTest.activateTriggerSettings();
         List < ZTS_EU_Territory__c > custTerritoryList = ZTS_DataUtilityTest.createCustomTerritory(7);
        insert custTerritoryList;

        List < ZTS_EU_Position__c > userterrlist = ZTS_DataUtilityTest.createUserTerritory(custTerritoryList);
        insert userterrlist;

        USZTS_TerritoryManager.updateCustomTerrAssignedFlag();
        
        Test.startTest();
        for(ZTS_EU_Position__c ut:userterrlist){
            ut.ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_DELETE;
            ut.ZTS_EU_Employee__c=null;
        }
         update userterrlist;
         
         USZTS_TerritoryManager.removeCustomUserTerritory(userterrlist);
         Integer ut_cnt=[SELECT COUNT() FROM ZTS_EU_Position__c];
         System.assert(ut_cnt==0,'Failed to Delete UserTerritory records with changeflag set to Delete');
         Test.stopTest();
        
    }
}