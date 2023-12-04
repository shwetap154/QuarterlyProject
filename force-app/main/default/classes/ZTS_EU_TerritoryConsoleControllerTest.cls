/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
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
 
 * Name          :   ZTS_EU_TerritoryConsoleControllerTest .
* Description   :    This is used to test ZTS_EU_TerritoryConsoleController.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
6/14/2014       Sunil                       Created
 */
 @isTest(seeAllData = false)
public with sharing class ZTS_EU_TerritoryConsoleControllerTest {
 
    public static testMethod void testIt() {
        ZTS_EU_TerritoryConsoleController ztc = new ZTS_EU_TerritoryConsoleController ();
    }
 /*
public static testMethod void tesCterrCount(){
        // Insert Custom Territory2      
        List<ZTS_EU_Territory__c> custTerritory = ZTS_EU_DataUtilityTest.createTerritory(1);
        system.debug('custTerritory****************>'+custTerritory);
        insert custTerritory;
       // Test.setMock(HttpCalloutMock.class, new AccountProfileMockHttpResponseGenerator());
        // Start Test
        
         MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(GlobalVariablesService.SERVER_URL+'/services/async/30.0/job' , 'JobInfoResponseMock');
            multimock.setStaticResource(GlobalVariablesService.SERVER_URL+'/services/async/30.0/job/'+'750c0000000FuiEAAS'+'/batch', 'BatchInfoResponseMock');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/xml');
        Test.setMock(HttpCalloutMock.class, multimock);
        ZTS_EU_TerritoryConsoleController terrObj = new ZTS_EU_TerritoryConsoleController();
        List<ZTS_EU_Territory__c> custTerritory1 = ZTS_EU_DataUtilityTest.createTerritory(1);
        List<ZTS_EU_Territory__c> insertcustTerritory = new List<ZTS_EU_Territory__c>();
        for(ZTS_EU_Territory__c terr1 : custTerritory){
            ZTS_EU_Territory__c terr = new ZTS_EU_Territory__c(id = terr1.id);
            terr.ZTS_EU_Is_Assigned__c = false;
            terr.ZTS_EU_Need_syncing__c =  false;
            terr.ZTS_EU_Territory_synced__c = true;
            insertcustTerritory.add(terr);
        }
        //update insertcustTerritory;
        List<User> userList = ZTS_EU_DataUtilityTest.createcoacherUser();
        ZTS_EU_Position__c  pos = new ZTS_EU_Position__c();
        pos.ZTS_EU_Territory__c =   custTerritory[0].id;
        pos.name = 'Test Position';
        pos.Market__c = 'United Kingdom';
        pos.ZTS_EU_Employee__c = userList[0].id;    
        Test.startTest();
            insert pos;
            terrObj.createTerr();
            
          ZTS_EU_TerritoryConsoleController.getUnAssignedUserTerritoryResults();
            //ZTS_EU_TerritoryConsoleController.getStandaradTerritory();
           // ZTS_EU_TerritoryConsoleController.addAssignmentRules();
          //  ZTS_EU_TerritoryConsoleController.addAssignmentRuleItems();
           // ZTS_EU_TerritoryConsoleController.addUserToTerritory();
          //  ZTS_EU_TerritoryConsoleController.getAssignmentTerrRule();
            String jobId = '34661rvvfvf45678';
            //ZTS_EU_TerritoryConsoleController.closeJob(jobId);
            
            
        Test.stopTest(); // Stop test
    }

 
   
    public static testMethod void tesCterrCount2(){
        // Insert Custom Territory2      
        List<ZTS_EU_Territory__c> custTerritory = ZTS_EU_DataUtilityTest.createTerritory(1);
        system.debug('custTerritory****************>'+custTerritory);
        insert custTerritory;
        // Start Test
        ZTS_EU_TerritoryConsoleController terrObj1= new ZTS_EU_TerritoryConsoleController();
        Test.startTest();
            terrObj1.updateStdTerr();
            terrObj1.terrCount();
            pagereference P = terrObj1.createTerr();
            terrObj1.updateUserTerritory();
            //ZTS_EU_TerritoryConsoleController.getStandaradTerritory();
            //ZTS_EU_TerritoryConsoleController.getAssignmentRule();
           // ZTS_EU_TerritoryConsoleController.getAssignmentTerrRule();
            terrObj1.zipAlignment();
            terrObj1.fullReAlignment();
            ZTS_EU_TerritoryConsoleController.getUnAssignedUserTerritoryResults();
           // Map<Id,Territory2>getAssignmentTerrRule= ZTS_EU_TerritoryConsoleController.getAssignmentTerrRule();
           
            pagereference finish = terrObj1.finish();
        Test.stopTest(); // Stop test
    }
    
    
    public static testMethod void tesCterrCount3(){
        // Insert Custom Territory2      
        List<ZTS_EU_Territory__c> custTerritory = ZTS_EU_DataUtilityTest.createTerritory(1);
      //  system.debug('custTerritory****************>'+custTerritory);
       // insert custTerritory;
        MultiStaticResourceCalloutMock multimock = ZTS_EU_TerritoryManagerTest.getJobUtilitiesMock();
        Test.setMock(HttpCalloutMock.class, multimock);
        ZTS_EU_TerritoryConsoleController terrConsoleCtrl = new ZTS_EU_TerritoryConsoleController();
        List<ZTS_EU_Territory__c> insertcustTerritory = new List<ZTS_EU_Territory__c>();
       // List<Territory2> stdTerrist=ZTS_EU_DataUtilityTest.createStdTerritory(1);
       
         List<User> userList =null;
        System.runAs(new User(Id=UserInfo.getUserId())){
         userList = ZTS_EU_DataUtilityTest.createcoacherUser();
        }
        ZTS_EU_Position__c  pos = new ZTS_EU_Position__c();
        pos.ZTS_EU_Territory__c =   custTerritory[0].id;
        pos.name = 'Test Position';
        pos.Market__c = 'United Kingdom';
        pos.ZTS_EU_Employee__c = userList[0].id;    
            insert pos;
        Test.startTest();
            //terrConsoleCtrl.createTerr();
            ZTS_EU_TerritoryConsoleController.addAssignmentRules();
            ZTS_EU_TerritoryConsoleController.addAssignmentRuleItems();
            String jobId='750c0000000FuiEAAS';
            String batchId='751x00000000079AAA';
            ZTS_EU_TerritoryConsoleController.checkStatus(jobId,batchId);
            ZTS_EU_TerritoryConsoleController.closeJob(jobId);
            
        Test.stopTest(); // Stop test
    }
    */
}