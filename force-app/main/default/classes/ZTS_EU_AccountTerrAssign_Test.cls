@isTest
public with sharing class ZTS_EU_AccountTerrAssign_Test {

static testMethod void validate_ZTS_EU_AccountTerrAssign() {
	
	User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
	List<Account>acAccountRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
    System.runAs(usr)
    {
        insert acAccountRecord;
    }
	
}

}