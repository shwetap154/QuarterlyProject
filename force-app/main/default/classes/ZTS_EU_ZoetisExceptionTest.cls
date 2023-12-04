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
 
 * Name          :   ZTS_EU_ZoetisExceptionTest .
* Description   :    This is used to test ZTS_EU_ZoetisException.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
6/14/2014       Sunil                       Created
 */
 @isTest(seeAllData = false)
public class ZTS_EU_ZoetisExceptionTest {
	public static testMethod void tesException(){ 
		//Start test
		Test.startTest();
		try{
			throw new ZTS_EU_ZoetisException('Test error message');
		}
		catch(Exception ex){
			system.assertEquals('Test error message', ex.getMessage());
		}
		Test.stopTest(); // Stop test
	}
}