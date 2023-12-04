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
private class ZTS_US_CreateAccountTeamBatchTest {

    static testMethod void testCreateAccTeam() {
		User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'amandaUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;


		List<Account> acclist=ZTS_DataUtilityTest.createAccountRecord(5);
		System.runAs(usr)
    	{
        	insert acclist;
    	}
    	
		List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(5);
		for ( ZTS_EU_Territory__c territory: customterrList)
		{
			territory.ZTS_EU_Market__c = 'United States';
		}
    	insert customterrList;
    	
    	List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
        for ( ZTS_EU_Position__c userTerr: userterrlist)
		{
			userTerr.Market__c = 'United States';
		}
    	insert userterrlist;
        
        for ( ZTS_EU_Position__c userTerr: userterrlist)
		{
			userTerr.ZTS_Processed__c = False;
		} 
        update userterrlist;
    	List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
    	insert accterr;
    	
        Test.startTest();
        String batchId=ZTS_US_CreateAccountTeamBatch.executeBatch(200);
        System.assert(batchId!=null,'ZTS_US_CreateAccountTeamBatch Apex not executed');
        Test.stopTest();
        String batchIdElse = ZTS_US_CreateAccountTeamBatch.executeBatch(200);
        List<ZTS_EU_Account_Position__c> accteams=[SELECT Id,Name from ZTS_EU_Account_Position__c WHERE ZTS_EU_Market__c = 'United States'];
        System.assert(accteams.size()>0,'No Account Team created');
        Integer ut_process_cnt=[SELECT COUNT() FROM ZTS_EU_Position__c WHERE ZTS_Processed__c=false];
        System.assert(ut_process_cnt==0,'User territory process flag updated failed');
    }
}