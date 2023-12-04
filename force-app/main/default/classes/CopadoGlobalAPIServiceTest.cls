/**
 * @description       : Test class for CopadoGlobalAPIService
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-24-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   03-09-2022   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   06-01-2022   Ethan Hirsch @ Zoetis Inc      Add File Header
 * 1.2   07-01-2022   Ethan Hirsch @ Zoetis Inc      Add tests and assertions to verify Admin Users are treated as 
 *                                                   Active Copado Users and do not have their license revoked
 * 1.3   07-27-2022   Ethan Hirsch @ Zoetis Inc      Add a Unit Test to verify exception handling when assignLicense is called.
 * 1.4   08-24-2022   Ethan Hirsch @ Zoetis Inc      Fix a bug with releaseOverloadedLicense_Test where the Users being
 *                                                   assigned licenses were retrieved when assigning 11 Users Copado licenses.
**/
@IsTest
private class CopadoGlobalAPIServiceTest {

    private static final String TestUser1FirstName = 'GlobalAPITest';
    private static final String TestUser2FirstName = 'GlobalAPITest2';

    @TestSetup
    static void makeData(){
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User usr1 = TestDataFactory.createUser(adminProfileId, false);
        usr1.FirstName = TestUser1FirstName;

        User usr2 = TestDataFactory.createUser(adminProfileId, false);
        usr2.FirstName = TestUser2FirstName;

        insert new List<User> {usr1, usr2};    
    }

    @isTest
    private static void checkLicense_False_Test(){
        Boolean isSuccess;
        User usr = [SELECT Id FROM User WHERE FirstName =: TestUser1FirstName LIMIT 1];
        Test.startTest();
        system.runAs(usr){
            isSuccess = CopadoGlobalAPIService.checkLicense(usr.Id);
        }
        Test.stopTest();

        system.assertEquals(false,isSuccess,'This User Should Not Have a License');
    }

    @isTest
    private static void checkLicense_True_Test(){
        Boolean isSuccess;
        User usr = [SELECT Id FROM User WHERE FirstName =: TestUser1FirstName LIMIT 1];
        Test.startTest();
        system.runAs(usr){
            CopadoGlobalAPIService.assignLicense(usr.Id);
            isSuccess = CopadoGlobalAPIService.checkLicense(usr.Id);
        }
        Test.stopTest();

        system.assertEquals(true,isSuccess,'This User Should Have a License');
    }

    @isTest
    private static void checkLicense_TrueAdmin_Test(){
        Boolean isSuccess;
        User usr = [SELECT Id FROM User WHERE FirstName =: TestUser1FirstName LIMIT 1];

        assignUserAdminLicense(usr.Id);

        Test.startTest();
        system.runAs(usr){
            isSuccess = CopadoGlobalAPIService.checkLicense(usr.Id);
        }
        Test.stopTest();

        system.assertEquals(true,isSuccess,'This User Should Have a License');
    }

    @isTest
    private static void releaseLicense_Test(){
        Boolean isSuccess;
        User usr = [SELECT Id FROM User WHERE FirstName =: TestUser1FirstName LIMIT 1];
        Test.startTest();
        system.runAs(usr){
            isSuccess = CopadoGlobalAPIService.releaseLicense(usr.Id);
        }
        Test.stopTest();

        system.assertEquals(
            true,
            isSuccess,
            'License Release should return true in this scenario because the limit hasn\'t been reached'
        );
    }

    @isTest
    private static void assignLicense_Test(){
        Boolean isSuccess;
        User usr = [SELECT Id FROM User WHERE FirstName =: TestUser1FirstName LIMIT 1];
        Test.startTest();
        system.runAs(usr){
            isSuccess = CopadoGlobalAPIService.assignLicense(usr.Id);
        }
        Test.stopTest();

        system.assertEquals(
            true,
            isSuccess,
            'License should be assigned successfully'
        );
    }

    @isTest
    private static void assignLicense_forceError_Test(){
        Boolean isSuccess;
        User usr = [SELECT Id FROM User WHERE FirstName =: TestUser1FirstName LIMIT 1];
        Test.startTest();
        system.runAs(usr){
            CopadoGlobalAPIService.forceModifyLicenseError = true;
            isSuccess = CopadoGlobalAPIService.assignLicense(usr.Id);
        }
        Test.stopTest();

        system.assertEquals(
            false,
            isSuccess,
            'License should not be assigned successfully since an error was forced'
        );
    }

    @isTest
    private static void releaseOverloadedLicense_Test(){
        Boolean isSuccess;
        User testUsr;
        User testAdminUser;
        List<String> testUserFirstNames = new List<String> {TestUser1FirstName, TestUser2FirstName}; 
        for (User usr : [SELECT Id, FirstName FROM User WHERE FirstName in: testUserFirstNames LIMIT 2]) {
            if (usr.FirstName == TestUser1FirstName) {
                testUsr  = usr;
            }
            else {
                testAdminUser = usr;
            }
        }

        List<User> otherUsers = new List<User>();
        for(User usr : [SELECT Id FROM User WHERE UserType = 'Standard' AND IsActive = true AND Profile.UserLicense.Name = 'Salesforce' and FirstName not in: testUserFirstNames LIMIT 11]){
            isSuccess = CopadoGlobalAPIService.assignLicense(usr.Id);
            otherUsers.add(usr);
        }

        assignUserAdminLicense(testAdminUser.Id);

        // Set Assignment Date to the past to prioritize those for removal
        testAdminUser.Copado_Assignment_DateTime__c = System.now().addDays(-3);
        otherUsers[0].Copado_Assignment_DateTime__c = System.now().addDays(-2);
        otherUsers[1].Copado_Assignment_DateTime__c = System.now().addDays(-1);

        // Prevent this User from having their license removed, despite them being prioritized as first removal
        otherUsers[0].Copado_Persistent_License__c = true;

        update new List<User> {testAdminUser, otherUsers[0], otherUsers[1]};

        Test.startTest();
        system.runAs(testUsr){
            isSuccess = CopadoGlobalAPIService.releaseLicense(testUsr.Id);
        }
        Test.stopTest();

        system.assertEquals(true,isSuccess,'This should be successful, and cover the too many licenses scenario');
        system.assertEquals(true, CopadoGlobalAPIService.checkLicense(testAdminUser.Id), 'The Admin user should still have a license');
        system.assertEquals(true, CopadoGlobalAPIService.checkLicense(otherUsers[0].Id), 'The User with Copado_Persistent_License__c set to true should have a license');
        system.assertEquals(false, CopadoGlobalAPIService.checkLicense(otherUsers[1].Id), 'The User with Copado_Assignment_DateTime__c set to the past should not have a license');
    }

    /**
     * @description Assigns the passed in User an Admin license manually directly in the API Class
     * @author Ethan Hirsch @ Zoetis Inc | 07-01-2022 
     * @param userId 
     */
    private static void assignUserAdminLicense(Id userId) {
        Map<Id, copado.GlobalAPI.UserLicense> userLicenseMap = CopadoGlobalAPIService.getUserIdToLicenseMap();

        copado.GlobalAPI.UserLicense  UL = new copado.GlobalAPI.UserLicense();
        UL.userId = userId;
        UL.isCopadoEnabled = true;

        userLicenseMap.put(userId, UL);
    }
}