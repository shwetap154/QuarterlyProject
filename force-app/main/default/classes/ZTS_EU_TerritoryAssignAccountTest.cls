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
 
 * Name          :   ZTS_EU_TerritoryAssignAccountTest .
* Description   :    This is used to test ZTS_EU_TerritoryAssignAccount.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
6/14/2014       Sunil                       Created
 */
 @isTest(seeAllData = false)
public with sharing class ZTS_EU_TerritoryAssignAccountTest {
	public static testMethod void testTerritroyAssign(){
		
		// Insert Account
		List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(19);
		List<Account> accountList = new List<Account>();
		List<Account> accclist =  new List<Account>();
		for(Account a : acclist){
			a.ZTS_EU_Excludezipbrickterralignment__c = false;
			a.ZTS_EU_Account_Status__c = 'Active';
			a.IsExcludedFromRealign = false;
			a.ZTS_EU_Excludezipbrickterralignment__c = false;
			a.ZTS_EU_Zip_Postal_Code__c = 'LD1';
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
			
			
			for(Account ac: accountList){
				ac.ZTS_EU_Market__c = 'Brazil';
				ac.ZTS_EU_TSF_PBC__c = 'IS-TER-OPS-ADM-1;IS-TER-CM-1;IS-TER-RU-AM-11;IS-TER-RU-AM-12';
				ac.ZTS_EU_BrickCode__c = 'IS-TER-OPS-ADM-1;IS-TER-CM-1;IS-TER-RU-AM-11;IS-TER-RU-AM-12';
				ac.ZTS_EU_TSF_PBC_1__c = 'IS-TER-OPS-ADM-1;IS-TER-CM-1;IS-TER-RU-AM-11;IS-TER-RU-AM-12';
				ac.ZTS_EU_TSF_PBC__c = 'IS-TER-OPS-ADM-1;IS-TER-CM-1;IS-TER-RU-AM-11;IS-TER-RU-AM-12';
				accclist.add(ac);
			}
			update accclist;
			
			
			// Insert Custom Territory
			List<ZTS_EU_Territory__c> custTerritory = ZTS_EU_DataUtilityTest.createTerritory(2);
			
			for(ZTS_EU_Territory__c terr : custTerritory){
				terr.ZTS_EU_Market__c = accountList[0].ZTS_EU_Market__c;    
			}
			insert custTerritory;
			
			//Insert Brick
			List<ZTS_GL_BrickToTerr__c> brickTerritory = ZTS_EU_DataUtilityTest.createBrickTerrRecord(2);
			List<ZTS_GL_BrickToTerr__c> brickList = new List<ZTS_GL_BrickToTerr__c>();
			for(ZTS_GL_BrickToTerr__c b : brickTerritory){
				b.ZTS_EU_Territory__c = custTerritory[0].Id;
				b.ZTS_EU_Market__c = accountList[0].ZTS_EU_Market__c;
				brickList.add(b);
			}
			insert brickList;
			
			
			//Insert Zip
			List<ZTS_GL_ZipToBrick__c> zipBrick = ZTS_EU_DataUtilityTest.createZipBrickRecord(2);
			
			for(ZTS_GL_ZipToBrick__c zip : zipBrick){
				zip.ZTS_EU_BrickCode__c = brickList[0].id;
				zip.ZTS_EU_Market__c = accountList[0].ZTS_EU_Market__c;
			}
			insert zipBrick;
			
			
			List<ZTS_EU_Position__c> positionList = new List<ZTS_EU_Position__c>();
			for(Integer i = 0; i < 4; i++){
				ZTS_EU_Position__c positionObj = ZTS_EU_DataUtilityTest.createPosition(UserInfo.getUserId(),false);
				positionObj.ZTS_EU_Territory__c = custTerritory[0].Id; 
				positionList.add(positionObj);
			}
			
			insert positionList;
			
			Test.startTest();
			ZTS_EU_TerritoryAssignAccount.assignTerritory(accountList);
			ZTS_EU_TerritoryAssignAccount.pageBreak_TsfPbc(accountList);
			ZTS_EU_TerritoryAssignAccount.assignTerritoriesForMarketsNotFollowingZipToBrick(accountList);
			ZTS_EU_TerritoryAssignAccount.populateTsfPbcFields(accountList);
			Test.stopTest();
		}
	}
	
	public static testMethod void testTerritroyAssign2(){
		
		// Insert Account
		List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(19);
		List<Account> accountList = new List<Account>();
		List<Account> accclist =  new List<Account>();
		for(Account a : acclist){
			a.ZTS_EU_Excludezipbrickterralignment__c = false;
			a.ZTS_EU_Account_Status__c = 'Active';
			a.IsExcludedFromRealign = false;
			a.ZTS_EU_Excludezipbrickterralignment__c = false;
			a.ZTS_EU_Zip_Postal_Code__c = 'LD1';
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

		for(Account ac: accountList){
			ac.ZTS_EU_Market__c = 'Ireland';
			ac.ZTS_EU_TSF_PBC__c = 'IS-TER-OPS-ADM-1;IS-TER-CM-1;IS-TER-RU-AM-11;IS-TER-RU-AM-12';
			ac.ZTS_EU_BrickCode__c = 'IS-TER-OPS-ADM-1;IS-TER-CM-1;IS-TER-RU-AM-11;IS-TER-RU-AM-12';
			ac.ZTS_EU_TSF_PBC_1__c = 'IS-TER-OPS-ADM-1;IS-TER-CM-1;IS-TER-RU-AM-11;IS-TER-RU-AM-12';
			ac.ZTS_EU_TSF_PBC__c = 'IS-TER-OPS-ADM-1;IS-TER-CM-1;IS-TER-RU-AM-11;IS-TER-RU-AM-12';
			
			accclist.add(ac);
		}

		update accclist;
		
		
		// Insert Custom Territory
		List<ZTS_EU_Territory__c> custTerritory = ZTS_EU_DataUtilityTest.createTerritory(1);
		
		for(ZTS_EU_Territory__c terr : custTerritory){
			terr.ZTS_EU_Market__c = accountList[0].ZTS_EU_Market__c;    
		}
		insert custTerritory;
		
		//Insert Brick
		List<ZTS_GL_BrickToTerr__c> brickTerritory = ZTS_EU_DataUtilityTest.createBrickTerrRecord(1);
		List<ZTS_GL_BrickToTerr__c> brickList = new List<ZTS_GL_BrickToTerr__c>();
		for(ZTS_GL_BrickToTerr__c b : brickTerritory){
			b.ZTS_EU_Territory__c = custTerritory[0].Id;
			b.ZTS_EU_Market__c = accountList[0].ZTS_EU_Market__c;
			brickList.add(b);
		}
		insert brickList;
		
		
		//Insert Zip
		List<ZTS_GL_ZipToBrick__c> zipBrick = ZTS_EU_DataUtilityTest.createZipBrickRecord(1);
		
		for(ZTS_GL_ZipToBrick__c zip : zipBrick){
			zip.ZTS_EU_BrickCode__c = brickList[0].id;
			zip.ZTS_EU_Market__c = accountList[0].ZTS_EU_Market__c;
		}
		insert zipBrick;
		
		Test.startTest();
		ZTS_EU_TerritoryAssignAccount.assignTerritory(accountList);
		ZTS_EU_TerritoryAssignAccount.pageBreak_TsfPbc(accountList);
		ZTS_EU_TerritoryAssignAccount.assignTerritoriesForMarketsNotFollowingZipToBrick(accountList);
		ZTS_EU_TerritoryAssignAccount.populateTsfPbcFields(accountList);
		Test.stopTest();
		
	}
	
	public static testMethod void testTerritroyAssign3(){
		
		// Insert Account
		List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(19);
		List<Account> accountList = new List<Account>();
		List<Account> accclist =  new List<Account>();
		for(Account a : acclist){
			a.ZTS_EU_Excludezipbrickterralignment__c = false;
			a.ZTS_EU_Account_Status__c = 'Active';
			a.IsExcludedFromRealign = false;
			a.ZTS_EU_Excludezipbrickterralignment__c = false;
			a.ZTS_EU_Zip_Postal_Code__c = 'LD1';
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
		for(Account ac: accountList){
			ac.ZTS_EU_Market__c = 'United Kingdom';
			ac.ZTS_EU_TSF_PBC__c = 'IS-TER-OPS-ADM-1;IS-TER-CM-1;IS-TER-RU-AM-11;IS-TER-RU-AM-12';
			ac.ZTS_EU_BrickCode__c = 'IS-TER-OPS-ADM-1;IS-TER-CM-1;IS-TER-RU-AM-11;IS-TER-RU-AM-12';
			ac.ZTS_EU_TSF_PBC_1__c = 'IS-TER-OPS-ADM-1;IS-TER-CM-1;IS-TER-RU-AM-11;IS-TER-RU-AM-12';
			ac.ZTS_EU_TSF_PBC__c = 'IS-TER-OPS-ADM-1;IS-TER-CM-1;IS-TER-RU-AM-11;IS-TER-RU-AM-12';
			accclist.add(ac);
		}
		update accclist;
		
		
		// Insert Custom Territory
		List<ZTS_EU_Territory__c> custTerritory = ZTS_EU_DataUtilityTest.createTerritory(1);
		
        for(ZTS_EU_Territory__c terr : custTerritory){
            terr.ZTS_EU_Market__c = accountList[0].ZTS_EU_Market__c;    
        }
		insert custTerritory;
		
		//Insert Brick
		List<ZTS_GL_BrickToTerr__c> brickTerritory = ZTS_EU_DataUtilityTest.createBrickTerrRecord(1);
		List<ZTS_GL_BrickToTerr__c> brickList = new List<ZTS_GL_BrickToTerr__c>();
		for(ZTS_GL_BrickToTerr__c b : brickTerritory){
			b.ZTS_EU_Territory__c = custTerritory[0].Id;
			b.ZTS_EU_Market__c = accountList[0].ZTS_EU_Market__c;
			brickList.add(b);
		}
		insert brickList;
		
		
		//Insert Zip
		List<ZTS_GL_ZipToBrick__c> zipBrick = ZTS_EU_DataUtilityTest.createZipBrickRecord(1);
		
		for(ZTS_GL_ZipToBrick__c zip : zipBrick){
			zip.ZTS_EU_BrickCode__c = brickList[0].id;
			zip.ZTS_EU_Market__c = accountList[0].ZTS_EU_Market__c;
		}
		insert zipBrick;
		
		Test.startTest();
		ZTS_EU_TerritoryAssignAccount.assignTerritory(accountList);
		ZTS_EU_TerritoryAssignAccount.pageBreak_TsfPbc(accountList);
		ZTS_EU_TerritoryAssignAccount.assignTerritoriesForMarketsNotFollowingZipToBrick(accountList);
		ZTS_EU_TerritoryAssignAccount.populateTsfPbcFields(accountList);
		Test.stopTest();
	
	}
}