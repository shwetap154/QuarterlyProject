@isTest
private class SL_SubmitCoaching_Test 
{
	private static testMethod void test_SL_SubmitCoaching() 
	{
		User intlUsr = new User();
		intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
		intlUsr.FirstName = 'IntUser';
		intlUsr.ZTS_EU_Market__c = 'United Kingdom';
		insert intlUsr;
		System.runAs(intlUsr) {
			ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
			
			ZTS_EU_Coaching__c objCoaching = new ZTS_EU_Coaching__c(ZTS_EU_Status__c = 'Submitted');
			insert objCoaching;
			
			SL_SubmitCoaching.updateCoaching(objCoaching.Id);
		}
		
		system.assertEquals([Select ZTS_EU_Status__c From ZTS_EU_Coaching__c Limit 1].ZTS_EU_Status__c,'Pending Colleague');
	}
	
}