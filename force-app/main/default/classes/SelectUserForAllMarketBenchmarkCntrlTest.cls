/**
Class Name	    : SelectUserForAllMarketBenchmarkCntrlTest
Description	    : Test Class created as part of TPDEV-158 for the SelectUserForAllMarketBenchmarkCntrl Class. 
Created By		: Sibin Kuriakose
Created Date	: 05-29-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				05-29-2023	 Created methods to Test Methods on SelectUserForAllMarketBenchmarkCntrl
*/
@isTest
public class SelectUserForAllMarketBenchmarkCntrlTest {
	private static final String excludeIntegrationUserName = 'ExcludeIntegrations@zoetis.com.UsersSelectorTest';
    private static final String doNotExcludeIntegrationUserName = 'DoNotExcludeIntegrations@zoetis.com.UsersSelectorTest';
    
    @isTest
    static void search_Test(){
       
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        
        List<User> lstUser = new List<User>();
        
        User user1 = TestDataFactory.createUser(adminProfileId, false);
        user1.Username = doNotExcludeIntegrationUserName+'1';
        user1.Additional_Markets__c = 'ALPHA';
        user1.FirstName = '123uqnTest';
        user1.LastName = 'User';
        user1.Title = 'test';
        user1.ZTS_EU_Market__c = 'Albania';
        //insert user1;
        lstUser.add(user1);
        
        User user2 = TestDataFactory.createUser(adminProfileId, false);
        user2.Username = doNotExcludeIntegrationUserName+'2';
        user2.Additional_Markets__c = 'ALPHA';
        user2.FirstName = '123uqnTest';
        user2.LastName = 'User2';
        user2.Title = 'test';
        lstUser.add(user2);
        
        User user3 = TestDataFactory.createUser(adminProfileId, false);
        user3.Username = doNotExcludeIntegrationUserName+'3';
        user3.FirstName = '123uqnTest';
        user3.LastName = 'User3';
        user3.Title = 'test';
        user3.ZTS_EU_Market__c = 'ALPHA';
        lstUser.add(user3);
        
        User user4 = TestDataFactory.createUser(adminProfileId, false);
        user4.Username = doNotExcludeIntegrationUserName+'4';
        user2.Additional_Markets__c = 'Albania';
        user4.FirstName = '123uqnTest';
        user4.LastName = 'User4';
        user4.Title = 'test';
        lstUser.add(user4);
        
        User user5 = TestDataFactory.createUser(adminProfileId, false);
        user5.Username = doNotExcludeIntegrationUserName+'5';
        user5.Additional_Markets__c = 'ALPHA';
        user5.FirstName = '123uqnTest';
        user5.LastName = 'User';
        user5.Title = 'test';
        user5.ZTS_EU_Market__c = 'Albania';
        lstUser.add(user5);
        
        insert lstUser;
        
        Id perId = [SELECT Id from PermissionSet WHERE Name = 'iDevelop_Coachee'].Id;
        
        List<PermissionSetAssignment> lstpa = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment pa1 = new PermissionSetAssignment(AssigneeId = lstUser[0].id, PermissionSetId = perId);
        PermissionSetAssignment pa2 = new PermissionSetAssignment(AssigneeId = lstUser[1].id, PermissionSetId = perId);
        PermissionSetAssignment pa3 = new PermissionSetAssignment(AssigneeId = lstUser[2].id, PermissionSetId = perId);
        PermissionSetAssignment pa4 = new PermissionSetAssignment(AssigneeId = lstUser[3].id, PermissionSetId = perId);
        PermissionSetAssignment pa5 = new PermissionSetAssignment(AssigneeId = lstUser[4].id, PermissionSetId = perId);
        lstpa.add(pa1);
        lstpa.add(pa2);
        lstpa.add(pa3);
        lstpa.add(pa4);
        lstpa.add(pa5);
        
        insert lstpa;
        
        String str = '123uqnTes%';
        String striDevelop = '';// = 'iCoach_Coachee';
        List<String> lstStr = new List<String>();
        System.runAs(user1){
        Test.startTest();
        List<LookupSearchResult> lookup = SelectUserForAllMarketBenchmarkCntrl.search(str,striDevelop);
        Test.stopTest();
        System.assertEquals(4, lookup.size());
        }
    }
}