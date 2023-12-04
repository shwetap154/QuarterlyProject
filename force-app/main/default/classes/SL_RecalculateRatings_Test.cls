/**
* @ClassName    : SL_RecalculateRatings_Test 
* @JIRATicket   : LIGTHTNI-48
* @CreatedOn    : 3rd April, 2019.
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Test Class for the SL_RecalculateRatings class.
*/
@isTest
private class SL_RecalculateRatings_Test {
	@isTest
	private static void test_SL_RecalculateRatings() {
		User intlUsr = new User();
		intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
		intlUsr.FirstName = 'IntUser';
		intlUsr.ZTS_EU_Market__c = 'United Kingdom';
		insert intlUsr;
		ApexPages.StandardSetController setCon;
		SL_RecalculateRatings objCntl;
		System.runAs(intlUsr) {
			// ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
			Account_Segmentation_threshold__c objAS = new Account_Segmentation_threshold__c(ZTS_EU_Market__c = 'India', ZTS_EU_Segmentation_Rating__c = '2',
			BU_Abbrv__c = 'CA');
			insert objAS;

			setCon = new ApexPages.StandardSetController(new List<Account_Segmentation_threshold__c>{objAS});
			objCntl = new SL_RecalculateRatings(setCon);
			
			objCntl.onAction();
			system.assertNotEquals(objCntl.listView(), null);
		}
	}
}