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
private class ZTS_CreateAccTeamFromUsrTerrBatchTest {

    static testMethod void testCreateAccTeams() {
        
        ZTS_DataUtilityTest.activateTriggerSettings();
        ZTS_DataUtilityTest.insertZoetisSettings();
        
        List<Account> acclist=ZTS_DataUtilityTest.createAccountRecord(10);
        insert acclist;
        
        List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(10);
        insert customterrList;
        
        List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
        insert userterrlist;
        
        
        List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
        insert accterr;
        Test.startTest();
        List<ZTS_EU_Position__c> utlist=[SELECT Id, ZTS_EU_Territory__c, ZTS_User_Territory_Uniq_Key__c, Name, ZTS_Processed__c, ZTS_End_Date__c, 
                                                    ZTS_EU_Employee__c, ZTS_ChangeFlag__c,ZTS_EU_Is_Active__c FROM ZTS_EU_Position__c];
        ZTS_CreateAccountTeamFromUsrTerrBatch actm_usr_batch=new ZTS_CreateAccountTeamFromUsrTerrBatch(utlist);
        String batchid=Database.executeBatch(actm_usr_batch);
        System.assert(batchid!=null,'ZTS_CreateAccTeamFromUsrTerrBatch failed to execute');
        Test.stopTest();
        
        List<ZTS_AccountTerritory__c> accterrlist2=[SELECT Id,ZTS_Zoetis_SFDC_ID__c,ZTS_EU_Account__c from ZTS_AccountTerritory__c WHERE ZTS_EU_Account__c IN :acclist ];
        ZTS_TerritoryManager.getNARCIDs(accterrlist2);
        // Amitabh Added
        //SL_ZTS_AccountTerritoryTriggerHandler.onAfterInsert(accterrlist2);
        // End
      Integer acctmCount=[SELECT COUNT() FROM  ZTS_EU_Account_Position__c WHERE CreatedDate=TODAY AND ZTS_EU_Account__c IN :acclist];
        System.assert(acctmCount>0,'No Account team exists');
        
    }
}