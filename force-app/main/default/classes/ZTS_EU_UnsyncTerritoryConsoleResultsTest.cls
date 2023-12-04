/****************************************************************************************************************************************** 
 * Class Name   : ZTS_EU_UnsyncTerritoryConsoleResultsTest
 * Description  : This test class is written for both territory and position results in territory console
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Chanbasha NBSK           08/17/2021          Created
*****************************************************************************************************************************************/
@isTest
private class ZTS_EU_UnsyncTerritoryConsoleResultsTest {

    public static testMethod void unsyncConsoleresultsTest() {
        // Insert Custom Territory      
        List < ZTS_EU_Territory__c > custTerritoryList = ZTS_DataUtilityTest.createCustomTerritory(7);
        insert custTerritoryList;

        List < ZTS_EU_Position__c > userterrlist = ZTS_DataUtilityTest.createUserTerritory(custTerritoryList);
        insert userterrlist;

        MultiStaticResourceCalloutMock mock = ZTS_DataUtilityTest.getJobUtilitiesMock();
        Test.setMock(HttpCalloutMock.class, mock);
        ZTS_EU_UnsyncTerritoryConsoleResults consoleCtrl = new ZTS_EU_UnsyncTerritoryConsoleResults();
  
        User currentUser = new User(Id = UserInfo.getUserId());
        System.runAs(currentUser) {
            consoleCtrl.createStdTerrFromCustomTerritory();
        }
        consoleCtrl.updateCustomTerrAssignedFlag();
        Test.startTest();
        System.runAs(currentUser) {
            ZTS_EU_UnsyncTerritoryConsoleResults.addUserToTerritory();
        }
        Test.stopTest(); 
    }
}