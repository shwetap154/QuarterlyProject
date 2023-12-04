/****************************************************************************************************************************************** 
 * Class Name   : ZTS_US_UnsyncTerritoryResultsTest
 * Description  : This test class is written for both US territory and position results in territory console
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Chanbasha NBSK           08/16/2021          Created
*****************************************************************************************************************************************/
@isTest
private class ZTS_US_UnsyncTerritoryConsoleResultsTest {
    
        public static testMethod void unsyncterritotyconsolerResults() {
        // Insert Custom Territory      
        List < ZTS_EU_Territory__c > custTerritoryList = ZTS_DataUtilityTest.createCustomTerritory(7);
        insert custTerritoryList;

        List < ZTS_EU_Position__c > userterrlist = ZTS_DataUtilityTest.createUserTerritory(custTerritoryList);
        insert userterrlist;

        MultiStaticResourceCalloutMock mock = ZTS_DataUtilityTest.getJobUtilitiesMock();
        Test.setMock(HttpCalloutMock.class, mock);
        ZTS_US_UnsyncTerritoryConsoleResults consoleCtrl = new ZTS_US_UnsyncTerritoryConsoleResults();
      
        System.runAs(new User(id = UserInfo.getUserId())) {
            consoleCtrl.createStdTerrFromCustomTerritory();
        }
        consoleCtrl.updateCustomTerrAssignedStatus();
        Test.startTest();
        System.runAs(new User(id = UserInfo.getUserId())) {

            ZTS_US_UnsyncTerritoryConsoleResults.addUserToTerritory();
        }
        Test.stopTest();
    }
}