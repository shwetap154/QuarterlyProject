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
public class ZTS_EU_TerritoryManagerTest {
    
    
    /*public static MultiStaticResourceCalloutMock getJobUtilitiesMock(){
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(GlobalVariablesService.SERVER_URL+'/services/async/30.0/job' , 'JobInfoResponseMock');
        multimock.setStaticResource(GlobalVariablesService.SERVER_URL+'/services/async/30.0/job/'+'750c0000000FuiEAAS'+'/batch', 'BatchInfoResponseMock');
        multimock.setStaticResource(GlobalVariablesService.SERVER_URL+'/services/async/30.0/job/'+'750c0000000FuiEAAS'+'/batch/751x00000000079AAA', 'BatchStatusResponseMock');
        multimock.setStaticResource(GlobalVariablesService.SERVER_URL+'/services/async/30.0/job/'+'750c0000000FuiEAAS', 'CloseBatchResponseMock');
        
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/xml');
        return multimock;
    }

    static testMethod void insertPosition() {
        List<Territory> stdTerrList=ZTS_EU_DataUtilityTest.createStdTerritory(1);
        
        List<ZTS_EU_Territory__c> custTerritory = ZTS_EU_DataUtilityTest.createTerritory(1);
        system.debug('custTerritory****************>'+custTerritory);
        //insert stdTerrList;
        insert custTerritory;
        //custTerritory[0].ZTS_EU_Terr_SFID__c=stdTerrList[0].id;
        List<User> userList = ZTS_EU_DataUtilityTest.createcoacherUser();
        insert userlist;
        ZTS_EU_Position__c  pos = new ZTS_EU_Position__c();
        pos.ZTS_EU_Territory__c =   custTerritory[0].id;
        pos.name = 'Test Position';
        pos.Market__c = 'United Kingdom';
        pos.ZTS_EU_Employee__c = userList[0].id;    
        insert pos;
        
        
      List<ZTS_EU_Position__c> custUsrTerrList=[SELECT Id, ZTS_EU_Employee__c, ZTS_EU_Territory__c,ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c FROM ZTS_EU_Position__c WHERE ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c!='' and ZTS_EU_Employee__c!= null];
        MultiStaticResourceCalloutMock multimock = getJobUtilitiesMock();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimock);
        
        ZTS_EU_TerritoryManager.insertUserTerritoryBatch(custUsrTerrList );
        Test.stopTest();
    }
    
    static testmethod void updatedUserTerrUserRecordsToRemove(){
        
        List<ZTS_EU_Territory__c> custTerritory = ZTS_EU_DataUtilityTest.createTerritory(1);
        system.debug('custTerritory****************>'+custTerritory);
        insert custTerritory;
        List<User> userList = ZTS_EU_DataUtilityTest.createcoacherUser();
        insert userlist;
        ZTS_EU_Position__c  pos = new ZTS_EU_Position__c();
        pos.ZTS_EU_Territory__c =   custTerritory[0].id;
        pos.name = 'Test Position';
        pos.Market__c = 'United Kingdom';
        pos.ZTS_EU_Employee__c = userList[0].id;    
        insert pos;
        
        System.runAs(new User(id=UserInfo.getUserId())){
            
            pos.ZTS_EU_Employee__c=null;
            update pos;
            
            Date toDt=Date.today();
            Date fromDt=toDt.addDays(-1);
            List<ZTS_EU_Position__History> pos_histlist=ZTS_EU_TerritoryManager.updatedUserTerrHistoryRecords(fromDt,toDt);
            System.debug('### pos_histlist : '+pos_histlist);
            ZTS_EU_TerritoryManager.updatedUserTerrUserRecordsToRemove(pos_histlist);           
            
        }
        
    }
    
    public testmethod static void   testremoveUserTerritory(){
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(GlobalVariablesService.SERVER_URL+'/services/async/30.0/job' , 'JobInfoResponseMock');
        multimock.setStaticResource(GlobalVariablesService.SERVER_URL+'/services/async/30.0/job/'+'750c0000000FuiEAAS'+'/batch', 'BatchInfoResponseMock');
        multimock.setStaticResource(GlobalVariablesService.SERVER_URL+'/services/async/30.0/job/'+'750c0000000FuiEAAS'+'/batch/751x00000000079AAA', 'BatchStatusResponseMock');
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/xml');
        Test.setMock(HttpCalloutMock.class, multimock);
        UserTerritory ut=new UserTerritory(Id='04Sc0000000jm0iEAA',UserId='005c0000000uJxZAAU',TerritoryId='04Tc0000000CnSoEAK');
        List<UserTerritory> utlist=new List<UserTerritory>{ut};
        Test.startTest();
        //ZTS_EU_TerritoryManager.removeUserTerritory(userTerrList, UserInfo.getSessionId());
        ZTS_EU_TerritoryManager.removeUserTerritoryAsync(new String[]{'04Sc0000000jm0iEAA'}, UserInfo.getSessionId());
        Test.stopTest();
    }
    
     public testmethod static void   testAssignmentRule(){
        List<Territory> stdTerrList = ZTS_EU_DataUtilityTest.createStdTerritory(1);
        ZTS_EU_TerritoryManager.getAccountAssignmentRuleCSV_ToInsert(stdTerrList);
        MultiStaticResourceCalloutMock multimock = getJobUtilitiesMock();
        Test.setMock(HttpCalloutMock.class, multimock);
        ZTS_EU_TerritoryManager.insertAssignmentRuleBatch(stdTerrList);
        AccountTerritoryAssignmentRule atsr=ZTS_EU_DataUtilityTest.createAccountTerrAssignmentRule(stdTerrList[0].id);
        Map<Id,Territory> terrMap=new Map<Id,Territory>();
        terrMap.put(stdTerrList[0].id,stdTerrList[0]);
        ZTS_EU_TerritoryManager.insertAssignmentRuleItemBatch(new List<AccountTerritoryAssignmentRule>{atsr},terrMap);
     }*/
}