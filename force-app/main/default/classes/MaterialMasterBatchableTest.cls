/**
* File Name     :  MaterialMasterBatchableTest
* @description  : Test coverage for  Batchable class that implements the logic to create Product2 records out of SAP Materials.
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group.
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/1/19        Cory Bartholomew @ ATG   Created the Class. Added the initial functionality.
* 1.1	  2/6/20		Cory Bartholomew @ ATG   Added descriptions
*/

@isTest
private class MaterialMasterBatchableTest {
	
	@testSetup
	public static void setup() { 

		//Create materials
		List<SAP_Material__c> materials = new List<SAP_Material__c>();
		//Create material with no products assocaited.
		materials.add(CPQ_TestDataFactory.createSAPMaterial('PC', '000000000011111111', 'NORM', 'ZFER', '015000715177010', false)); 
		//Create material with product assocaited.
		materials.add(CPQ_TestDataFactory.createSAPMaterial('SU', '000000000022222222', 'DIEN', 'DIEN', '015000715184050', false));
		insert materials;

		List<Product_Description__c> descriptions = new List<Product_Description__c>();
		descriptions.add(CPQ_TestDataFactory.createProductDescription(materials[0], 'EN', false));
		descriptions.add(CPQ_TestDataFactory.createProductDescription(materials[1], 'EN', false));				
		insert descriptions;
		//Create one-time and reccuring product for one of the materials above
		List<Product2> products	= new List<Product2>();		
		//Recurring
		Product2 recurringProduct = new Product2();
		recurringProduct.Name = '1';
		recurringProduct.IsActive = true;
		recurringProduct.SBQQ__AssetAmendmentBehavior__c = 'Default';
		recurringProduct.SBQQ__BillingFrequency__c = 'Monthly';
		recurringProduct.SBQQ__BillingType__c = 'Advance';
		recurringProduct.SBQQ__ChargeType__c = 'Recurring';
		recurringProduct.SBQQ__Component__c = true;
		recurringProduct.CPQ_Configured__c = true;
		//recurringProduct.CPQ_Material_Type__c = 'Consumable';  ATGCPQ-302
		recurringProduct.SBQQ__DefaultQuantity__c = 1;
		recurringProduct.SBQQ__SubscriptionBase__c = 'List';
		recurringProduct.SBQQ__PricingMethod__c = 'List';
		recurringProduct.ProductCode =  materials[0].SAP_Product_Number__c;
		recurringProduct.SAP_Material__c = materials[0].Id;
		recurringProduct.SBQQ__SubscriptionPricing__c = 'Fixed Price';
		recurringProduct.SBQQ__SubscriptionTerm__c = 12;
		recurringProduct.SBQQ__SubscriptionType__c = 'Renewable';
		recurringProduct.SBQQ__AssetConversion__c = 'One per unit';
		recurringProduct.CPQ_Configured__c = true;
		recurringProduct.SBQQ__SubscriptionTerm__c = 12;
		recurringProduct.SBQQ__Component__c = true;
		products.add(recurringProduct);
		
		insert products;

		//Deprecated
		//List<Material_Type__c> matTypes = new List<Material_Type__c>();
		//matTypes.add(CPQ_TestDataFactory.createMaterialType('Consumables - Coagulant', '5', 'Consumable', '15000715177010', '77', false));
		//matTypes.add(CPQ_TestDataFactory.createMaterialType('DX - Connectivity', '5', 'Service', '15000715184050', '84', false));
		//insert matTypes;

		//Workaround to enable standard pricebook to be queryable by the batch helper class since we cant use Test.getStandardPricebook() during the query.
		// Instantiate the Pricebook2 record first, setting the Id
		Pricebook2 standardPricebook = new Pricebook2(
			Id = Test.getStandardPricebookId(),
			IsActive = true
		);
		// Run an update DML on the Pricebook2 record
		// This is the weird workaround that enables IsStandard to become true
		// on the PricebookEntry record
		update standardPricebook;

	}

	@isTest
	public static void testMaterialMasterBatchable() {
		
		Test.startTest();
		MaterialMasterBatchable mmb  = new MaterialMasterBatchable();
		Database.executeBatch(mmb,200);
		Test.stopTest();

		//query products to validate #.  Without being able to see all data only the 2 records we inserted should come through.
		List<Product2> products = [SELECT Id, SBQQ__Component__c, SBQQ__PricingMethod__c, SBQQ__SubscriptionPercent__c, SBQQ__SubscriptionPricing__c,
										SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionType__c, SBQQ__AssetConversion__c, SBQQ__AssetAmendmentBehavior__c
									FROM Product2];

		System.assertEquals(2,products.size(),'The expected number of products were not returned' + products);
		//query against materials to validate all were updated to "Last batch run" of today()
		List<SAP_Material__c> materials = [SELECT Id, Last_Batch_Run__c FROM SAP_Material__c];
		System.assertEquals(2,materials.size(),'The expected number of materials were not returned');
		for(SAP_Material__c mat : materials){
			System.assert(mat.Last_Batch_Run__c != null,'Material was not updated in batch run sucessfully.  The last batch run is ' + mat.Last_Batch_Run__c);
		}

		//System.assertEquals(true, products[0].SBQQ__Component__c, 'The updated product was not marked as component');
		System.assertEquals('List', products[0].SBQQ__PricingMethod__c, 'SBQQ__PricingMethod__c is incorrect.');
		System.assertEquals(null, products[0].SBQQ__SubscriptionPercent__c, 'SBQQ__SubscriptionPercent__c is incorrect.');
		System.assertEquals(null, products[0].SBQQ__SubscriptionPricing__c, 'SBQQ__SubscriptionPricing__c is incorrect.');
		System.assertEquals(null, products[0].SBQQ__SubscriptionTerm__c, 'SBQQ__SubscriptionTerm__c is incorrect.');
		System.assertEquals(null, products[0].SBQQ__SubscriptionType__c, 'SBQQ__SubscriptionType__c is incorrect.');
		System.assertEquals(null, products[0].SBQQ__AssetConversion__c, 'SBQQ__AssetConversion__c is incorrect.');
		System.assertEquals(null, products[0].SBQQ__AssetAmendmentBehavior__c, 'SBQQ__AssetAmendmentBehavior__c is incorrect.');

		System.assertEquals(true, products[1].SBQQ__Component__c, 'The updated product was not marked as component');
		System.assertEquals('List', products[1].SBQQ__PricingMethod__c, 'SBQQ__PricingMethod__c is incorrect.');
		System.assertEquals(null, products[1].SBQQ__SubscriptionPercent__c, 'SBQQ__SubscriptionPercent__c is incorrect.');
		System.assertEquals(null, products[1].SBQQ__SubscriptionPricing__c, 'SBQQ__SubscriptionPricing__c is incorrect.');
		System.assertEquals(null, products[1].SBQQ__SubscriptionTerm__c, 'SBQQ__SubscriptionTerm__c is incorrect.');
		System.assertEquals(null, products[1].SBQQ__SubscriptionType__c, 'SBQQ__SubscriptionType__c is incorrect.');
		System.assertEquals(null, products[1].SBQQ__AssetConversion__c, 'SBQQ__AssetConversion__c is incorrect.');
		System.assertEquals(null, products[1].SBQQ__AssetAmendmentBehavior__c, 'SBQQ__AssetAmendmentBehavior__c is incorrect.');
	}
	
	@isTest
	public static void testSchedulable() {		
		Test.startTest();
		MaterialMasterBatchable mmb  = new MaterialMasterBatchable();
		String sch = '0 0 0 * * ?';
		Id jobId = System.schedule('Renew Orders Batch', sch, mmb);
		Test.stopTest();
		//Lookup the job based on the Job ID
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		//Assertions
		System.assert(ct != null, 'Cron Trigger is null');
	}
	
}