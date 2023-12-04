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
private class ZTS_TerritoryConsoleControllerTest {

    public static testMethod void tesCterrCount() {
        // Insert Custom Territory      
        List < ZTS_EU_Territory__c > custTerritoryList = ZTS_DataUtilityTest.createCustomTerritory(7);
        insert custTerritoryList;

        List < ZTS_EU_Position__c > userterrlist = ZTS_DataUtilityTest.createUserTerritory(custTerritoryList);
        insert userterrlist;

        MultiStaticResourceCalloutMock mock = ZTS_DataUtilityTest.getJobUtilitiesMock();
        Test.setMock(HttpCalloutMock.class, mock);
        ZTS_TerritoryConsoleController consoleCtrl = new ZTS_TerritoryConsoleController();

        Integer totalTerr = consoleCtrl.totalTerrCount;
        Integer unassignedTerrCount = consoleCtrl.unAssignedTerrCount;
        Integer totalUseTerrCount = consoleCtrl.totalUsrTerrCount;
        Integer unassignedUserTerr = consoleCtrl.totalUnassignedUsrTerrCount;

        User currentUser = new User(Id = UserInfo.getUserId());
        System.runAs(currentUser) {
            consoleCtrl.createStdTerrFromCustomTerritory();
        }
        consoleCtrl.updateCustomTerrAssignedStatus();
        Test.startTest();
        System.runAs(currentUser) {
            ZTS_TerritoryConsoleController.addUserToTerritory();
        }
        Test.stopTest(); // Stop test
    }

    public static testMethod void testCloseJob() {
        MultiStaticResourceCalloutMock mock = ZTS_DataUtilityTest.getJobUtilitiesMock('750c0000000FusYAAS');
        Test.setMock(HttpCalloutMock.class, mock);
        ZTS_TerritoryConsoleController.checkStatus('750c0000000FusYAAS', '751x00000000079AAA');
        ZTS_TerritoryConsoleController.closeJob('750c0000000FusYAAS');
    }
    
    public static testMethod void testZoetisSettingsControllerExtension() {

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'IntlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr) {
            ZTS_Settings__c ztsSettings = new ZTS_Settings__c();
            insert ztsSettings;
            ZoetisSettingsControllerExtension ext = new ZoetisSettingsControllerExtension();
            
            //List<TriggerActivation__c> triggerActivationList = ext.triggerActivationList;
            
            Test.startTest();
            ext.executeCurrentFYCallCreditUpdateBatch();
            ext.executeExceptionAlignFlagUpdateBatch();
            ext.executeExceptionAlignFlagUpdateScheduler();
            ext.executeRemoveUserTerrScheduler();
            ext.executeRemoveUserTerrBatch();
            ext.userTerrRemoval();
            ext.updateSettings();
            ext.zoetisSettings = ztsSettings;
            ext.updateSettings();
            ext.closeJobs();
            ext.closeJobScheduler();
            ext.status = 'status';
            ext.console = 'console';
            ext.log = 'log';
            ext.comment = 'comment';
            ext.exceptionStr = 'ex';
            ext.log2 = 'log';
            ext.comment2 = 'comment';
            ext.exceptionStr2 = 'ex';
            
            ZTS_TerritoryConsoleController consoleCtrl = new ZTS_TerritoryConsoleController();
            ext = new ZoetisSettingsControllerExtension(consoleCtrl);

            ZTS_US_TerritoryConsoleController usTerrCotr = new  ZTS_US_TerritoryConsoleController();
            ext = new ZoetisSettingsControllerExtension(usTerrCotr);
            
            ZTS_ExcepAlignFlagUpdateScheduleBatch alignBatch = new ZTS_ExcepAlignFlagUpdateScheduleBatch();
            ZTS_ExcepAlignFlagUpdateScheduleBatch.running();
            Database.executeBatch(alignBatch); 
            
            ZTS_CurrentFY_CallCreditUpdateBatch callBatch = new ZTS_CurrentFY_CallCreditUpdateBatch();
            ZTS_CurrentFY_CallCreditUpdateBatch.running();
            Database.executeBatch(callBatch); 
            Test.stopTest();
        }
    }
    
}