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
private class ZTS_US_TerritoryConsoleControllerTest {

    public static testMethod void tesCterrCount() {
        // Insert Custom Territory      
        List < ZTS_EU_Territory__c > custTerritoryList = ZTS_DataUtilityTest.createCustomTerritory(7);
        insert custTerritoryList;

        List < ZTS_EU_Position__c > userterrlist = ZTS_DataUtilityTest.createUserTerritory(custTerritoryList);
        insert userterrlist;

        MultiStaticResourceCalloutMock mock = ZTS_DataUtilityTest.getJobUtilitiesMock();
        Test.setMock(HttpCalloutMock.class, mock);
        ZTS_US_TerritoryConsoleController consoleCtrl = new ZTS_US_TerritoryConsoleController();

        Integer totalTerr = consoleCtrl.totalTerrCount;
        Integer unassignedTerrCount = consoleCtrl.unAssignedTerrCount;
        Integer totalUseTerrCount = consoleCtrl.totalUsrTerrCount;
        Integer unassignedUserTerr = consoleCtrl.totalUnassignedUsrTerrCount;

        System.runAs(new User(id = UserInfo.getUserId())) {
            consoleCtrl.createStdTerrFromCustomTerritory();
        }
        consoleCtrl.updateCustomTerrAssignedStatus();
        Test.startTest();
        System.runAs(new User(id = UserInfo.getUserId())) {

            ZTS_US_TerritoryConsoleController.addUserToTerritory();
        }
        Test.stopTest(); // Stop test
    }

    public static testMethod void testCloseJob() {
        MultiStaticResourceCalloutMock mock = ZTS_DataUtilityTest.getJobUtilitiesMock('750c0000000FusYAAS');
        Test.setMock(HttpCalloutMock.class, mock);
        ZTS_US_TerritoryConsoleController.checkStatus('750c0000000FusYAAS', '751x00000000079AAA');
        ZTS_US_TerritoryConsoleController.closeJob('750c0000000FusYAAS');
    }
    
}