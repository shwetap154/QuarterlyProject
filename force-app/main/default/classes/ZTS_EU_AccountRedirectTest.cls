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
 
 * Name          :   ZTS_EU_AccountRedirectTest .
* Description   :    This is used to test ZTS_EU_AccountRedirect.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
5/26/2014       Sunil                       Created
 */
@isTest(seeAllData= false)
public with sharing class ZTS_EU_AccountRedirectTest {
	
	public static testMethod void testaccRedirectMethod() {
        ZTS_EU_Field_ID__c countryCustomSettingField = new ZTS_EU_Field_ID__c();
        countryCustomSettingField.Name = 'ZTS_EU_Country__c';
        countryCustomSettingField.ZTS_EU_ID__c = '00NF000000CM80c';
        insert countryCustomSettingField;

        ZTS_EU_Field_ID__c accountMarketCustomSettingField = new ZTS_EU_Field_ID__c();
        accountMarketCustomSettingField.Name = 'ZTS_EU_Account_Market_Field_Id';
        accountMarketCustomSettingField.ZTS_EU_ID__c = '00NF000000CM80n';
        insert accountMarketCustomSettingField;

		List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(1);
		User usr = new User();
		usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
		usr.FirstName = 'davidsUser';
		usr.zts_eu_market__c = 'United Kingdom';
		insert usr;

		System.runAs(usr){
			insert acclist;
		}
		Account acc = new Account(id = acclist[0].id);
		PageReference pageRef = Page.ZTS_EU_AccountNewRedirect;
		Test.setCurrentPage(pageRef);
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
		ApexPages.currentPage().getParameters().put('RecordType',accRecordTypeId);		
		ApexPages.StandardController stdAcc = new ApexPages.StandardController(acc);						
		ZTS_EU_AccountRedirect accObj = new ZTS_EU_AccountRedirect(stdAcc);
		Test.startTest();
		accObj.accRedirect();
		Test.stopTest();
		
	}
}