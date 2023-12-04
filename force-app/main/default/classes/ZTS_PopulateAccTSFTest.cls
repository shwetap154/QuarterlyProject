@isTest
private class ZTS_PopulateAccTSFTest {

    @isTest
    private static void testInsertAndDeleteAccTerr() {
    	ZTS_DataUtilityTest.activateTriggerSettings();

        List<Account> acclist = ZTS_DataUtilityTest.createAccountRecord(10);
    	insert acclist;

        List<ZTS_EU_Territory__c> customterrList = ZTS_DataUtilityTest.createCustomTerritory(10);
    	insert customterrList;

    	List<ZTS_EU_Position__c> userterrlist = ZTS_DataUtilityTest.createUserTerritory(customterrList);
    	insert userterrlist;

    	Test.startTest();

    	List<ZTS_AccountTerritory__c> accterr = ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
    	insert accterr;

    	Integer at_count=[SELECT COUNT() from ZTS_EU_Account_Position__c WHERE CreatedDate=TODAY];
    	//System.assert(at_count>0,'No Account Team created');
    	Test.stopTest();

    	//Deactivate accounts
    	for (Account accountToDeactivate : acclist) {
    		accountToDeactivate.ZTS_EU_Account_Status__c='Inactive';
            accountToDeactivate.ZTS_EU_Reason__c = 'Invalid';
    	}

    	update acclist;

    	//delete Account territory
    	delete accterr[0];

    	//set change flag to delete
    	List<ZTS_AccountTerritory__c> accterrUpdateList=new List<ZTS_AccountTerritory__c> ();
    	for(Integer i=1;i<accterr.size();i++){
    		accterr[i].ZTS_ChangeFlag__c=ZTS_GlobalConstants.CHANGE_FLAG_STATUS_DELETE;
    		accterrUpdateList.add(accterr[i]);
    	}
    	update accterrUpdateList;
    }
}