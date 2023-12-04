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
private class ZTS_US_UpdateAccountTerrShareBatchTest {
 /*
    static testMethod void testAccTerrAssignment() {
        //********************* set up territory related data **********************
        ZTS_DataUtilityTest.activateTriggerSettings();
        
        List<Account> acclist=ZTS_DataUtilityTest.createAccountRecord(10);
        insert acclist;
        
         USZTS_TerritoryManager.SFA terrSFA=new USZTS_TerritoryManager.SFA ();
        
        List<ZTS_US_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(10);
        insert customterrList;
        
         List<Id> unassignedTerrIds=new List<Id>();
         
         for(ZTS_US_Territory__c cterr:customterrList){
                unassignedTerrIds.add(cterr.id);
            }
            
            
            System.runAs(new User(id=UserInfo.getUserId())){
             List<Territory> stdTerrrList= terrSFA.upsertZoetisTerritory(unassignedTerrIds);
            }
        USZTS_TerritoryManager.updateCustomTerrAssignedFlag();
        Integer terrcount=[SELECT count()  from Territory WHERE LastModifiedDate=TODAY];
        System.assert(terrcount>0,'No Standard Territory got created');
        
        
        List<ZTS_US_UserTerritory__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
        insert userterrlist;
        
        
        List<ZTS_US_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
        insert accterr;
        
        
        //*************************** execute batch *******************
        Test.startTest();
        String batchid=ZTS_US_UpdateAccountTerritoryShareBatch.executeBatch(200);
        System.assert(batchid!=null,'ZTS_US_UpdateAccountTerritoryShareBatch failed to execute batch');
        Test.stopTest();
        
    }
    */
}