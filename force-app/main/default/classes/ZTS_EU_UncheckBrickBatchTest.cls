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
 
 * Name          :   ZTS_EU_UncheckBrickBatchTest .
* Description   :    This is used to test ZTS_EU_UncheckBrickBatch.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
6/11/2014       Sunil                       Created
 */
 @isTest(seeAllData = false)
public with sharing class ZTS_EU_UncheckBrickBatchTest {
	public static testMethod void uncheckBrick(){
		// Insert Custom Territory
		List<ZTS_EU_Territory__c> custTerritory = ZTS_EU_DataUtilityTest.createTerritory(1);
        system.debug('custTerritory----->'+custTerritory);
		insert custTerritory;
		
		//Insert Brick
		List<ZTS_GL_BrickToTerr__c> brickTerritory = ZTS_EU_DataUtilityTest.createBrickTerrRecord(19);
        system.debug('brickTerritory------->'+brickTerritory);
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
		Set<Id> zipID = new Set<Id>();
		Map<ID,ID> zipBrickMap = new Map<ID,ID>();
		for(ZTS_GL_BrickToTerr__c z : brickList){
			zipID.add(z.id);
			zipBrickMap.put(z.id,z.id);
		
		}
		Test.StartTest();
			ZTS_EU_UncheckBrickBatch brickObj = new ZTS_EU_UncheckBrickBatch();
			brickObj.failedZipId = zipID;
			brickObj.updatedZipMap = zipBrickMap;
			ID batchprocessid = Database.executeBatch(brickObj,20);
        System.debug('batchprocessid------->'+batchprocessid);
		Test.StopTest();
		
		 ZTS_GL_BrickToTerr__c brick = [select id,ZTS_EU_To_Be_Synced__c from  ZTS_GL_BrickToTerr__c where id = :brickList[0].id];
        System.debug('brick----->'+brick);
		System.assertEquals(brick.ZTS_EU_To_Be_Synced__c,true);
	}
}