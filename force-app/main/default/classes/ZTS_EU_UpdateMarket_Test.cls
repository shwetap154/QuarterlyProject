@isTest (SeeAlldata = False)
public with sharing class ZTS_EU_UpdateMarket_Test {

static testMethod void ZTS_EU_UpdateMarket(){
	Test.startTest();
	List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(1);
	acclist[0].ZTS_EU_Market__c='United States';
	acclist[0].ZTS_EU_Zip_Postal_Code__c = '12345';
	acclist[0].BillingPostalCode = '12345';
	acclist[0].BillingCity = 'Boca Raton';
	acclist[0].BillingState = 'Florida';
	acclist[0].BillingStreet = 'Elm Lane';
	User usr = new User();
	usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
	usr.FirstName = 'davidsUser';
	usr.zts_eu_market__c = 'United Kingdom';
	insert usr;

	System.runAs(usr){
		insert acclist;
	}
	List<Contact> conlist = ZTS_EU_DataUtilityTest.createContactRecord(2);
	for(Contact con: conlist){
		con.AccountId = acclist[0].Id;
		
	}
	insert conlist;
	
	ZTS_EU_UpdateMarket.Contact_updateMarket(conlist);
	Test.stopTest();		
}


}