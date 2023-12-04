@isTest
private class SL_Test_cmp_DynamicLookupController {

    @isTest 
    private static void testMultipleMethods() {
		User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;	
        System.runAs(usr)
        {
          SL_cmp_DynamicLookupController.test_QueryLookupFields();
          List<Account> lstFetchAccount = [SELECT Id, Name FROM Account];
          System.assert(lstFetchAccount[0].Id != Null);
          
          // Finding an account, which is present in DB..
          
          List<SL_cmp_DynamicLookupController.Result>  lstResults =  SL_cmp_DynamicLookupController.lookup('Test New', 'Account');
          System.assert(lstResults.size() > 0);
          System.assertEquals(lstResults[0].SObjectLabel, 'Test New Acc-001');
          
          // Finding and value which is not present in DB..
          lstResults =  SL_cmp_DynamicLookupController.lookup('###12112XXXX1211', 'User');
          System.assert(lstResults.isEmpty());
        }
	}
}