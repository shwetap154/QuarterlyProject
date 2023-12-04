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
 
 * Name          :   UtilityServiceTest .
* Description   :    This is used to test UtilityService.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
7/15/2014       Sunil                       Created
 */
@isTest(seeAllData= false)

public class UtilityServiceTest {
	 public static testMethod void Test_UtilityFunction(){
		Test.startTest();
	       Map<string,Schema.RecordTypeInfo> getRecordtypeInfosbyName = UtilityService.getRecordtypeInfosbyName ('Account');	         
	       Map<Id,Schema.RecordTypeInfo> getRecordtypeInfosbyId = UtilityService.getRecordtypeInfosbyId ('Account');
	       Id recordtypeID = getRecordtypeInfosbyName.get('Active_Pending').getRecordTypeId();
	       String recordTypeName = UtilityService.getRecordTypeName('Account', recordtypeID);
	       system.assertEquals(recordTypeName, 'Active/Pending'); // To validate recordtype name. 
	       UtilityService.kolRun = UtilityService.iskolRun();
	       system.assertEquals(UtilityService.kolRun, true); // To validate kolrun boolean is set to true
	       UtilityService.setkolRunFalse();
	       system.assertEquals(UtilityService.kolRun, false); // To validate kolrun boolean is reset 
	    Test.stopTest();  
	   
	 }
}