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
 
 * Name          :   ZTS_EU_UncheckZipTest .
* Description   :    This is used to test ZTS_EU_UncheckZip.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
6/11/2014       Sunil                       Created
 */
 @isTest(seeAllData = false)
public with sharing class ZTS_EU_UncheckZipTest {
	public static testMethod void uncheckZip(){
		// Insert Custom Territory
		List<ZTS_EU_Territory__c> custTerritory = ZTS_EU_DataUtilityTest.createTerritory(1);
		system.debug('custTerritory****************>'+custTerritory);
		insert custTerritory;
		
		//Insert Brick
		List<ZTS_GL_BrickToTerr__c> brickTerritory = ZTS_EU_DataUtilityTest.createBrickTerrRecord(1);
		List<ZTS_GL_BrickToTerr__c> brickList = new List<ZTS_GL_BrickToTerr__c>();
		for(ZTS_GL_BrickToTerr__c b : brickTerritory){
			b.ZTS_EU_Territory__c = custTerritory[0].Id;
			brickList.add(b);
		}
		insert brickList;
		//Insert Zip
		List<ZTS_GL_ZipToBrick__c> zipBrick = ZTS_EU_DataUtilityTest.createZipBrickRecord(19);
		List<ZTS_GL_ZipToBrick__c> zipList = new List<ZTS_GL_ZipToBrick__c>();
		for(ZTS_GL_ZipToBrick__c zip : zipBrick){
			zip.ZTS_EU_BrickCode__c = brickList[0].id;
			zipList.add(zip);
		}
		insert zipList;
		
		// Insert Account
		List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(19);
		List<Account> accountList = new List<Account>();
		for(Account a : acclist){
			a.ZTS_EU_Excludezipbrickterralignment__c = false;
			a.ZTS_EU_Account_Status__c = 'Active';
			a.IsExcludedFromRealign = false;
			a.ZTS_EU_Excludezipbrickterralignment__c = false;
			a.ZTS_EU_Zip_Postal_Code__c = '12345';
			a.BillingPostalCode = '12345';
			a.BillingCity = 'Boca Raton';
			a.BillingState = 'Florida';
			a.BillingStreet = 'Elm Lane';
			a.ZTS_EU_Market__c = 'Italy';
			accountList.add(a);
			
		}

		User usr = new User();
		usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
		usr.FirstName = 'davidsUser';
		usr.zts_eu_market__c = 'United Kingdom';
		insert usr;

		System.runAs(usr){
			insert accountList;
		}
		
		Set<Id> accountID = new Set<ID>();
		Map<id,Account> failAccMap = new  Map<id,Account> ();
		for(Account a : accountList){
			accountID.add(a.id);
		}
		Test.StartTest();
			ZTS_EU_UncheckZip zip = new ZTS_EU_UncheckZip();
			zip.failedAccountId = accountID;
			zip.failedAccMap = failAccMap;
			ID batchprocessid = Database.executeBatch(zip,20);
		Test.StopTest();
		ZTS_GL_ZipToBrick__c zipSync = [select id,ZTS_EU_To_Be_Synced__c from ZTS_GL_ZipToBrick__c where id = :zipList[0].id];
		System.assertEquals(zipSync.ZTS_EU_To_Be_Synced__c,false);
	}
}