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
private class ZTS_US_CurrentFY_CallCreditUpdBatchTest {

    static testMethod void testCallCreditExecuteBatch() {
       //activate custom settings
        ZTS_DataUtilityTest.activateTriggerSettings();
       //create accounts
       List<Account> acclist=ZTS_DataUtilityTest.createAccountRecord(5);
       for (Account a : acclist) a.zts_eu_market__c = 'United States';
       insert acclist;
       
       List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(5);
       for (ZTS_EU_Territory__c a : customterrList) a.zts_eu_market__c = 'United States';
        insert customterrList;
        
       
        User u = ZTS_DataUtilityTest.createcoacherUser()[0];
        u.ZTS_EU_Market__c = 'United States';
        insert u;

        List<ZTS_EU_Position__c> userterrlist;
        System.runAs(u)
        {
          userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
          insert userterrlist;
        }
        
        List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
        for (ZTS_AccountTerritory__c accterrs : accterr) accterrs.ZTS_EU_Market__c = 'United States';
        insert accterr;

        /*ZTS_EU_Account_Position__c ap1 = new ZTS_EU_Account_Position__c();
    
        ap1.ZTS_EU_Account__c = acclist[0].Id;
        ap1.ZTS_AccountTerritory__c = accterr[0].Id;
        ap1.ZTS_EU_Position__c = userterrlist[0].Id;
  
        insert ap1;
  
        ZTS_EU_Account_Position__c ap2 = new ZTS_EU_Account_Position__c();
      
        ap2.ZTS_EU_Account__c = acclist[1].Id;
        ap2.ZTS_AccountTerritory__c = accterr[1].Id;
        ap2.ZTS_EU_Position__c = userterrlist[1].Id;
        
        insert ap2;
        */
        Test.startTest();
        List<Call__c> call_List;
       //create account calls
        System.runAs(u)
        {
            call_List=ZTS_DataUtilityTest.createCallRecords(4,acclist);
            for (Call__c call : call_List) call.ZTS_EU_Call_Owner__c = u.Id;
            insert call_List;
        
       for(Call__c call:call_List){
        call.ZTS_EU_Status__c=ZTS_EU_GlobalConstants.CALL_STATUS_COMPLETED;//submit call
       }
       
       update call_list;
    
       //update submitted date of call
       call_list[0].ZTS_EU_Submitted_Date__c=Datetime.now();
       
       update call_list[0];
    }
       /*Test.startTest();*/
       String batchId=ZTS_US_CurrentFY_CallCreditUpdateBatch.executeBatch();
       System.assert(batchId!=null,'ZTS_US_CurrentFY_CallCreditUpdBatch failed to execute');
       Test.stopTest();
       
       //get account teams
       List<ZTS_EU_Account_Position__c> accteam=[SELECT Id FROM ZTS_EU_Account_Position__c WHERE ZTS_EU_Account__c IN :acclist AND ZTS_EU_Market__c = 'United States' ];
       
       Integer ccCount=[SELECT COUNT() FROM ZTS_US_Call_Credit__c WHERE ZTS_EU_Account_Position__c IN :accteam AND ZTS_EU_Counts_towards_Target__c=true];
       System.assert(ccCount>0,'No CallCredit records exists');
    }
}