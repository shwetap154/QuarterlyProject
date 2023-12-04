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
 
 * Name          :   ZTS_EU_checkSyncBrickTest .
* Description   :    This is used to test ZTS_EU_checkSyncBrick.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
6/14/2014       Sunil                       Created
 */
@isTest(seeAllData = false)
public with sharing class ZTS_EU_checkSyncBrickTest {
	public static testMethod void testcheckSyncBrickTest(){
		// Insert Custom Territory
		List<ZTS_EU_Territory__c> custTerritory = ZTS_EU_DataUtilityTest.createTerritory(1);
		insert custTerritory;
		
		//Insert Brick
		List<ZTS_GL_BrickToTerr__c> brickTerritory = ZTS_EU_DataUtilityTest.createBrickTerrRecord(2);
		List<ZTS_GL_BrickToTerr__c> brickList = new List<ZTS_GL_BrickToTerr__c>();
		for(ZTS_GL_BrickToTerr__c b : brickTerritory){
			b.ZTS_EU_Territory__c = custTerritory[0].Id;
			brickList.add(b);
		}
		insert brickList;
		//Insert Zip
		List<ZTS_GL_ZipToBrick__c> zipBrick = ZTS_EU_DataUtilityTest.createZipBrickRecord(1);
		List<ZTS_GL_ZipToBrick__c> zipList = new List<ZTS_GL_ZipToBrick__c>();
		for(ZTS_GL_ZipToBrick__c zip : zipBrick){
			zip.ZTS_EU_To_Be_Synced__c = false;
			zip.ZTS_EU_BrickCode__c = brickList[0].id;
			zipList.add(zip);
		}
		insert zipList;		
		
		//Start test
		Test.startTest();
			ZTS_EU_checkSyncBrick.checkSyncChildZip(brickList);
		Test.stopTest(); // Stop test
		// TO validate zip is ready for sync when brick needs to be sync
		ZTS_GL_ZipToBrick__c zipcode = [select id,ZTS_EU_BrickCode__c,ZTS_EU_To_Be_Synced__c,ZTS_EU_ZipCode__c from ZTS_GL_ZipToBrick__c where ZTS_EU_BrickCode__c = :brickList[0].id];
		System.assertEquals(zipcode.ZTS_EU_To_Be_Synced__c , true );
		
	}

}