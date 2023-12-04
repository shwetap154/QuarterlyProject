/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
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
 
 * Name          :   ZTS_EU_TerritroyAssignAccountBatchTest .
* Description   :    This is used to test ZTS_EU_TerritroyAssignAccountBatch.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
6/11/2014       Sunil                       Created
 */
 @isTest(seeAllData = false)
public with sharing class ZTS_EU_TerritroyAssignAccountBatchTest {
	public static testMethod void tesAssignAccount(){
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
        List<State_Country__c> scList = new List<State_Country__c>();
            State_Country__c sc = new State_Country__c();         
            sc.name = 'County Down';
            sc.ZTS_EU_Country__c = 'United Kingdom';
            sc.ZTS_EU_uniqueCOUNTY__c = 'County Down';
            scList.add(sc);
        insert scList;
		// Insert Account
		List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(19);
        Account acc = new Account();         
            acc.name = 'Test Account';
            acc.Type = 'Farm';
            acc.ZTS_EU_Sub_Type__c = 'Beef';
            acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc.ZTS_EU_City__c = 'Test City';
            acc.ZTS_EU_Zip_Postal_Code__c = 'LD';  
            acc.ZTS_EU_Potential_Region__c = '1';              
            acc.ZTS_EU_Main_Phone__c='9876789876';
            acc.CurrencyIsoCode='EUR';
            acc.ZTS_EU_Market__c='';
        	acc.ZTS_EU_Country__c='United Kingdom';
            acc.ZTS_EU_State_County__c=scList[0].Id;
            acc.ZTS_EU_Vetsave_ID__c='200';
            acc.ZTS_EU_Vetsave_HO_ID__c='56';
            accList.add(acc);
		List<Account> accountList = new List<Account>();
		for(Account a : acclist){
			//a.ZTS_EU_Excludezipbrickterralignment__c = false;
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
		Test.StartTest();
			ZTS_EU_TerritroyAssignAccountBatch accObj = new ZTS_EU_TerritroyAssignAccountBatch();
			ID batchprocessid = Database.executeBatch(accObj,20);
		Test.StopTest();
	}
}