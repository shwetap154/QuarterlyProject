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
private class ZTS_US_GlobalConstantsTest {
    
    
    static testMethod void testConstants() {
        Date dateLoad;
        String jobsClose;
        
      Test.startTest();
      ZTS_GlobalConstants globalConst=new ZTS_GlobalConstants();
      ZTS_GlobalConstants.zoetisAppConfig.put('ZTS_CRON_EXP_JOBS_CLOSE__c', '0 5 * * * ?');
      ZTS_GlobalConstants.zoetisAppConfig.put('ZTS_Data_Load_End_Date__c', Date.valueOf('2014-05-06'));
      dateLoad = ZTS_GlobalConstants.DATA_LOAD_END_DATE;
      jobsClose =  ZTS_GLobalConstants.CRON_EXP_JOBS_CLOSE;
      Test.stopTest();
    	
    	 System.assert(ZTS_GlobalConstants.CRON_EXP_JOBS_CLOSE!=null);
    	 System.assert(ZTS_GlobalConstants.CRON_EXP_REMOVE_USERS!=null);
    	 System.assert(ZTS_GlobalConstants.CRON_EXP_ACCTEAM_EXCEPTION_FLAG!=null);
    	 System.assert(ZTS_GlobalConstants.CRON_EXP_JOBS_CLOSE!=null);
         System.assert(ZTS_GlobalConstants.ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS!=null);
         System.assert(ZTS_GlobalConstants.ENABLE_VMIPS_CASE_TASK_NOTIFY!=null);
         System.assert(ZTS_GlobalConstants.CAMPAIGN_OPEN_FIELD_TARGET_STATUS!=null);
         System.assertEquals(ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT,'Insert');
         System.assertEquals(ZTS_GlobalConstants.CHANGE_FLAG_STATUS_DELETE,'Delete');
    	 System.assertEquals(Url.getSalesforceBaseUrl().toExternalForm(),ZTS_GlobalConstants.SERVER_URL);
    	// System.assertEquals(Url.getSalesforceBaseUrl().toExternalForm(),'https://touchpointeca--monthly.sandbox.my.salesforce.com');
         System.debug('SF base url'+ Url.getSalesforceBaseUrl().toExternalForm());
         System.debug('SF server url'+ ZTS_GlobalConstants.SERVER_URL);                     
    	 System.assert(ZTS_GlobalConstants.DATA_LOAD_END_DATE!=null);
         System.assertEquals(false, ZTS_GlobalConstants.ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS, 'Global Constants ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS set incorrectly');
         System.assertEquals('0 5 * * * ?', jobsClose, 'Global Constants ZTS_CRON_EXP_JOBS_CLOSE__c set incorrectly');
         System.assertEquals(Date.valueOf('2014-05-06'), dateLoad, 'Global Constants ZTS_Data_Load_End_Date__c set incorrectly');

         User usr=new User(FirstName=UserInfo.getName(),isActive=true);
         ZTS_GlobalConstants.getString(usr, 'FirstName', 'TestUser');
         ZTS_GlobalConstants.getBoolean(usr, 'isActive', true);
    }
}