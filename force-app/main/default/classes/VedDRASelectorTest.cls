/****************************************************************************************************************************************** 
 * Class Name   : VedDRASelectorTest
 * Description  : This is a test class for VedDRASelector class.
 *Created By    : Deloitte/ Sai Saranya Siruvuri
 * Created Date : 9-14-2023
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer               				  Date                Description 
 * Sai Saranya Siruvuri                 9-14-2023            Created as part of TPDEV-1932
 * ---------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
private class VedDRASelectorTest {

    @isTest static void testGetHighestVersion() {
    // Create test records using the createVeddraCodings method
    List<ZTS_US_VedDRA_Coding__c> veddraCodings = ZTS_DataUtilityTest.createVeddraCodings(2);
	insert veddraCodings;
        
    Decimal highestVersion = VedDRASelector.getHighestVersion();
    Decimal expectedVersion = 2;
    System.assertEquals(expectedVersion, highestVersion, 'Highest version should match the inserted record');

    // Clean up the test records
    delete veddraCodings;
}
    
    @isTest
    static void testGetVedDRACodingMap() {
        // Create test data for ZTS_US_VedDRA_Coding__c records
        List<ZTS_US_VedDRA_Coding__c> testRecords = new List<ZTS_US_VedDRA_Coding__c>();
        testRecords.add(new ZTS_US_VedDRA_Coding__c(Version__c = 1.0, VedDRA_Version__c = 'v5')); // Assuming Version__c is a Decimal field
        testRecords.add(new ZTS_US_VedDRA_Coding__c(Version__c = 2.0, VedDRA_Version__c = 'v5')); // Assuming Version__c is a Decimal field

        insert testRecords;

        Set<Id> veddraCodingIds = new Set<Id>();
        for (ZTS_US_VedDRA_Coding__c record : testRecords) {
            veddraCodingIds.add(record.Id);
        }
        // Call the getVedDRACodingMap method and assert the result
        Map<Id, ZTS_US_VedDRA_Coding__c> veddraCodingMap = VedDRASelector.getVedDRACodingMap(veddraCodingIds);
        System.assertEquals(testRecords.size(), veddraCodingMap.size());
    }
}