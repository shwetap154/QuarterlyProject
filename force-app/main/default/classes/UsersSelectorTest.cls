/**
 * @description       : Test class for UsersSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 06-29-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-30-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for selectUsersByIdNotExcludedFromIntegrations
 * 2.0   05-05-2023   Sibin Kuriakose             Added  method to test selectUserLangById
 * 3.0   05-29-2023   Sibin Kuriakose             Added  method to test selectUserMarketsById & selectUserDetailByName
 * 4.0   06-22-2023   Padma Nerella @ Zoetis Inc  Added method to test selectByNameTest TPDEV-1070
**/
@isTest
private class UsersSelectorTest {
    private static final String excludeIntegrationUserName = 'ExcludeIntegrations@zoetis.com.UsersSelectorTest';
    private static final String doNotExcludeIntegrationUserName = 'DoNotExcludeIntegrations@zoetis.com.UsersSelectorTest';

    @isTest
    static void selectUsersByIdNotExcludedFromIntegrations_Test(){
        String integrationToExclude = TestDataFactory.retrieveFirstActivePicklistValue('User', 'Exclude_From_Integrations__c');
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User user1 = TestDataFactory.createUser(adminProfileId, false);
        user1.Username = doNotExcludeIntegrationUserName;

        User user2 = TestDataFactory.createUser(adminProfileId, false);
        user2.Username = excludeIntegrationUserName;
        user2.Exclude_From_Integrations__c = integrationToExclude;

        insert new List<User> {user1, user2};

        Test.startTest();
            List<User> retrievedUsers = UsersSelector.newInstance().selectUsersByIdNotExcludedFromIntegrations(
                new Set<Id> {user1.Id, user2.Id},
                new Set<String> {integrationToExclude});
        Test.stopTest();

        System.assertEquals(1, retrievedUsers.size(), 'Only 1 User should have been retrieved.');
        System.assertEquals(user1.Id, retrievedUsers[0].Id,
            'The returned User should have been the User without any integrations excluded');
    }
    
    @isTest
    static void selectUserMarketsLangById_Test(){
       
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User user1 = TestDataFactory.createUser(adminProfileId, false);
        user1.Username = doNotExcludeIntegrationUserName;
        insert user1;

        Id User = [SELECT Id FROM User WHERE Id = :user1.Id].Id;
        
        List<Id> lstId = new List<Id>();
        lstId.add(user);

        Test.startTest();
        List<User> markets = UsersSelector.selectUserMarketsLangById(lstId);
        Test.stopTest();

        System.assertEquals(User, markets[0].Id, 'Only 1 User should have been retrieved.');
    }
    
     @isTest
    static void selectUserDetailByName_Test(){
       
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User user1 = TestDataFactory.createUser(adminProfileId, false);
        user1.Username = doNotExcludeIntegrationUserName+'1';
        user1.Additional_Markets__c = 'ALPHA';
        user1.FirstName = 'iDevelop';
        user1.LastName = 'User';
        user1.Title = 'test';
        user1.ZTS_EU_Market__c = 'Albania';
        insert user1;
        
        User user2 = TestDataFactory.createUser(adminProfileId, false);
        user2.Username = doNotExcludeIntegrationUserName+'2';
        user2.Additional_Markets__c = 'ALPHA';
        user2.FirstName = 'iDevelop';
        user2.LastName = 'User2';
        user2.Title = 'test';
        insert user2;
        
        Id perId = [SELECT Id from PermissionSet WHERE Name = 'iDevelop_Coachee'].Id;
        
        insert new PermissionSetAssignment(AssigneeId = user1.id, PermissionSetId = perId);
        insert new PermissionSetAssignment(AssigneeId = user2.id, PermissionSetId = perId);
        
        String str = 'iDevelop%';
        Set<String> setPermission = new Set<String>();
        String pername = 'iDevelop_Coachee';
        setPermission.add(pername);
        Integer intlimit = 10;

        Test.startTest();
        List<User> results = UsersSelector.selectUserDetailByName(str,setPermission,intlimit);
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Only 1 User should have been retrieved.');
    }
    
    @isTest
    static void selectByNameTest(){
        List<User> userList = [Select Id,Name,echosign_dev1__EchoSign_Allow_Delegated_Sending__c From User where Name ='New Online Account Site Guest User' AND echosign_dev1__EchoSign_Allow_Delegated_Sending__c =true];
        String userName = userList[0].Name;
        Set<String> userNames = new Set<String>{userName};
        Test.startTest();
        List<User> userList1 = UsersSelector.selectByName(userNames);
        Test.stopTest();
        Assert.areEqual(userList.size(), userList1.size(),'Number od user record retrieved: '+userList.size());
    }
    
}