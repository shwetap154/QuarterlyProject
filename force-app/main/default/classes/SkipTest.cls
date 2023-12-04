/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 02-23-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   02-23-2021   Morgan Marchese @ Zoetis Inc   Initial Version
**/
@isTest
private class SkipTest {
	@testSetup static void setup(){
	}
	static testMethod void SkipTest_Test(){
        // Intentionally blank
        // Used for deploying no-code deploys via CLI
        System.assert(true);
    }
}