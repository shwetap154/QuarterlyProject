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
 */
@isTest
private class testZTS_EU_Gift_Limit {
//SELECT Id, ZTS_EU_Product__c FROM ZTS_EU_Gift__c WHERE ZTS_EU_Product__c IN :Trigger.old 
    static testMethod void ZTS_EU_Gift_Limit() {
    	test.startTest();
    		
    		ZTS_EU_Species_Product__c PH = new ZTS_EU_Species_Product__c();
    		PH.name = 'testPH';
    		PH.ZTS_EU_Market__c = 'Netherlands';
    		PH.ZTS_EU_Type__c = 'Brand';
    		PH.ZTS_EU_Is_Active__c = true;
    		insert PH;
    		
    		ZTS_EU_Product_Gift_Limit__c GL = new ZTS_EU_Product_Gift_Limit__c();
    		GL.ZTS_EU_Product__c = PH.id;
    		insert GL;
    		
    		delete GL;
   		
    	test.stopTest();
    	
        
    }
    static testMethod void ZTS_EU_Gift_Limit_2() {
    	test.startTest();
    		// TriggerActivation__c TA = new TriggerActivation__c();
    		// TA.Name = 'ZTS_EU_Gift_Limit';
    		// TA.ZTS_EU_Bypass__c = true;
    		// insert TA;
    		
    		ZTS_EU_Species_Product__c PH = new ZTS_EU_Species_Product__c();
    		PH.name = 'testPH';
    		PH.ZTS_EU_Market__c = 'Netherlands';
    		PH.ZTS_EU_Type__c = 'Brand';
    		PH.ZTS_EU_Is_Active__c = true;
    		insert PH;
    		
    		ZTS_EU_Product_Gift_Limit__c GL = new ZTS_EU_Product_Gift_Limit__c();
    		GL.ZTS_EU_Product__c = PH.id;
    		insert GL;
    		
    		/*ZTS_EU_Species_Product__c PH = new ZTS_EU_Species_Product__c();
    		PH.name = 'testPH';
    		PH.ZTS_EU_Market__c = 'Netherlands';
    		PH.ZTS_EU_Type__c = 'Brand';
    		PH.ZTS_EU_Is_Active__c = true;
    		PH.ZTS_EU_is_Gift__c = true;
    		PH.ZTS_EU_Gift_Value__c = 100;
    		
    		insert PH;
    		
    		ZTS_EU_Product_Gift_Limit__c GL = new ZTS_EU_Product_Gift_Limit__c();
    		GL.ZTS_EU_Product__c = PH.id;
    		GL.ZTS_EU_Is_Active__c = true;
    		GL.ZTS_EU_Limit_Value__c = 100;
    		//GL.ZTS_EU_Product_Gift_Value__c = 100;
    		insert GL;
    		
    		List<Contact> lstCon = new List<Contact>();
    		ID conid;
    		lstCon = ZTS_EU_DataUtilityTest.createContactRecord(1);
    		insert lstCon;
    		for(Contact con:lstCon){
    			conid = con.id;
    		}
    		system.debug('AAAA' +conid);
    		
    		ZTS_EU_Gift__c gift = new ZTS_EU_Gift__c();
    		gift.ZTS_EU_Product__c = GL.id;
    		gift.ZTS_EU_Contact__c = conid;
    		
    		insert gift;*/
    		
    		delete GL;
   		
    	test.stopTest();
    	
        
    }
    
}