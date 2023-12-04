@isTest
public with sharing class ZTS_EU_UpdateSpeciesSpeciality_Test {

	static testMethod void ZTS_EU_UpdateSpeciesSpeciality () {
		
		List<ZTS_EU_Affiliations__c> newaff = new List<ZTS_EU_Affiliations__c>();

		List<Account>accRecord=ZTS_EU_DataUtilityTest.createAccountRecord(1);
		User usr = new User();
		usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
		usr.FirstName = 'davidsUser';
		usr.zts_eu_market__c = 'United Kingdom';
		insert usr;

		System.runAs(usr){
			insert accRecord;
		}
		List<Contact>conRecord=ZTS_EU_DataUtilityTest.createContactRecord(1);
		List<Contact> conrec = new List<Contact>();
		for(Contact con : conRecord){
		con.ZTS_EU_Species_Specialty__c = 'Equine';
		conrec.add(con);
		}
		insert conrec;

		List<ZTS_EU_Affiliations__c> affrec = ZTS_EU_DataUtilityTest.createAccConAffiliationRecord(1);

		List<ZTS_EU_Affiliations__c> lstafftrec = new List<ZTS_EU_Affiliations__c>();
		for(ZTS_EU_Affiliations__c aff: affrec){
		aff.ZTS_EU_Account__c = accRecord[0].id;
		aff.ZTS_EU_Contact__c = conrec[0].id;
		lstafftrec.add(aff);
		}
		Insert lstafftrec;
		Test.startTest();
		ZTS_EU_UpdateSpeciesSpeciality.UpdateSpeciesSpeciality(lstafftrec);
		Test.stopTest();

	}

}