/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
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
 
 * Name          :   ZTS_EU_GlobalConstantsTest .
* Description   :    This is used to test ZTS_EU_GlobalConstants.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
6/17/2014       Sunil                       Created
 */
 @isTest(seeAllData = false)
public with sharing class ZTS_EU_GlobalConstantsTest 
{
	public static testMethod void testEUGlobalConstants()
    {
        Boolean feedFollow;
		//Start Test
		Test.startTest();
			ZTS_EU_GlobalConstants globalObj  = new ZTS_EU_GlobalConstants();
        	ZTS_EU_GlobalConstants.zoetisAppConfig.put('ZTS_AccountTeamsAutoFollowChatterFeed__c', false);
        	feedFollow = ZTS_EU_GlobalConstants.ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS;
		Test.stopTest();
		// Stop Test
		System.assertEquals(false, feedFollow, 'Global Constants ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS set incorrectly');
		
	}
    
    public static testMethod void testNonEUGlobalConstants()
    {
        Boolean feedFollow;
        Boolean caseNotify; 
        Date dateLoad;
        String url;
        String jobsClose;
        String removeUsers;
        String accTeamException;
        String kolJobs;
        //Start Test
        Test.startTest();
        ZTS_GlobalConstants globalObj  = new ZTS_GlobalConstants();
        ZTS_GlobalConstants.zoetisAppConfig.put('ZTS_AccountTeamsAutoFollowChatterFeed__c', false);
        ZTS_GlobalConstants.zoetisAppConfig.put('ZTS_CRON_EXP_JOBS_CLOSE__c', '0 5 * * * ?');
        ZTS_GlobalConstants.zoetisAppConfig.put('ZTS_Data_Load_End_Date__c', Date.valueOf('2014-05-06'));
        feedFollow = ZTS_GlobalConstants.ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS;
        caseNotify = ZTS_GlobalConstants.ENABLE_VMIPS_CASE_TASK_NOTIFY;
        dateLoad = ZTS_GlobalConstants.DATA_LOAD_END_DATE;
        url = ZTS_GLobalConstants.SERVER_URL;
        jobsClose =  ZTS_GLobalConstants.CRON_EXP_JOBS_CLOSE;
   		removeUsers = ZTS_GlobalConstants.CRON_EXP_REMOVE_USERS;
        accTeamException = ZTS_GLobalConstants.CRON_EXP_ACCTEAM_EXCEPTION_FLAG;
        kolJobs = ZTS_GLobalConstants.CRON_EXP_KOL_JOBS;
        Test.stopTest();
        // Stop Test
        System.assertEquals(false, feedFollow, 'Global Constants ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS set incorrectly');
        System.assertEquals('0 5 * * * ?', jobsClose, 'Global Constants ZTS_CRON_EXP_JOBS_CLOSE__c set incorrectly');
        System.assertEquals(Date.valueOf('2014-05-06'), dateLoad, 'Global Constants ZTS_Data_Load_End_Date__c set incorrectly');

    }
}