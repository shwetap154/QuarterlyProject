/**
* File Name     :  MaterialMasterHelperTest
* @description  :  Test coverage for class that contains helper methods related to Product2 record creation out of SAP Materials
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/1/19         Cory Bartholomew @ ATG   Created the Class. Added the initial logic.
* 1.1     2/6/20         Cory Bartholomew @ ATG   Added descriptions
*/

@isTest
private class MaterialMasterHelperTest {
	
	@testSetup
	public static void setup() { 

		CPQ_PreInstall_Checklist__c settings = new CPQ_PreInstall_Checklist__c(SetupOwnerId=UserInfo.getOrganizationId(), Send_Email_Material_List__c = 'test');
    	insert settings;

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

	}

	@isTest 
	public static void testCreateProduct() {
		List<SAP_Material__c> materials = [
				SELECT Id, Name, SAP_Base_Unit_of_Measure__c, Last_Batch_Run__c,
							SAP_Item_Category__c, SAP_Item_Category_Group__c, SAP_Material_Type__c, SAP_Product_Hierarchy__c, SAP_Product_Number__c,
							SAP_Quantity_for_Base_Unit_of_Measure__c, SAP_Quantity_for_Sales_Unit_of_Measure__c, SAP_Sales_Unit_of_Measure__c,CPQ_Material_Type__c
				FROM SAP_Material__c 
				WHERE SAP_Product_Number__c = '000000000011111111'
				LIMIT 1
			];
		
		System.assertEquals(1, materials.size(), 'The material with SAP Product Number 000000000011111111 was not found from testSetup()');

		MaterialMasterHelper helper = new MaterialMasterHelper();
		//helper.materialTypeMap = helper.getAllMatrialTypes(); ATGCPQ-302
		//run method on recurring product
		System.Debug(LoggingLevel.WARN, ' Test createproduct() Material >> '  + materials[0]);
		Product2 product1 = helper.createProduct(materials[0]);
		System.assertNotEquals(null, product1, 'Failed to create Recurring Product');
		System.assertEquals('List', product1.SBQQ__PricingMethod__c, 'SBQQ__PricingMethod__c is incorrect.');
		System.assertEquals(null, product1.SBQQ__SubscriptionPercent__c, 'SBQQ__SubscriptionPercent__c is incorrect.');
		System.assertEquals(null, product1.SBQQ__SubscriptionPricing__c, 'SBQQ__SubscriptionPricing__c is incorrect.');
		System.assertEquals(null, product1.SBQQ__SubscriptionTerm__c, 'SBQQ__SubscriptionTerm__c is incorrect.');
		System.assertEquals(null, product1.SBQQ__SubscriptionType__c, 'SBQQ__SubscriptionType__c is incorrect.');
		System.assertEquals(null, product1.SBQQ__AssetConversion__c, 'SBQQ__AssetConversion__c is incorrect.');
		System.assertEquals(null, product1.SBQQ__AssetAmendmentBehavior__c, 'SBQQ__AssetAmendmentBehavior__c is incorrect.');
	}
	
	@isTest
	public static void testUpdateProduct() {
		// Implement test code
		List<SAP_Material__c> materials = [
			SELECT Id, Name, SAP_Base_Unit_of_Measure__c, Last_Batch_Run__c,
						SAP_Item_Category__c, SAP_Item_Category_Group__c, SAP_Material_Type__c, SAP_Product_Hierarchy__c, SAP_Product_Number__c,
						SAP_Quantity_for_Base_Unit_of_Measure__c, SAP_Quantity_for_Sales_Unit_of_Measure__c, SAP_Sales_Unit_of_Measure__c, CPQ_Material_Type__c
			FROM SAP_Material__c 
			WHERE SAP_Product_Number__c = '000000000011111111'
			LIMIT 1
		];
		
		System.assertEquals(1, materials.size(), 'The material with SAP Product Number 000000000011111111 was not found from testSetup()');

		List<Product2> productsToUpdate = [
			SELECT Id, Name, Description, ProductCode, SBQQ__Component__c 
			FROM Product2
			LIMIT 1
		];

		System.assertEquals(1, productsToUpdate.size(), 'No product from TestSetup() was returned by this test');

		MaterialMasterHelper helper = new MaterialMasterHelper();
		//helper.materialTypeMap = helper.getAllMatrialTypes();  ATGCPQ-302
		//run class method
		System.Debug(LoggingLevel.WARN, ' Test updateproduct() Material >> '  + materials[0]);
		helper.updateProduct(productsToUpdate, materials[0]);
	
		System.assertEquals(materials[0].SAP_Product_Number__c, productsToUpdate[0].ProductCode, 'The product code is a value other than expected');
		//System.assertEquals(true, productsToUpdate[0].SBQQ__Component__c, 'The updated product was not marked as component');
		System.assertEquals('List', productsToUpdate[0].SBQQ__PricingMethod__c, 'SBQQ__PricingMethod__c is incorrect.');
		System.assertEquals(null, productsToUpdate[0].SBQQ__SubscriptionPercent__c, 'SBQQ__SubscriptionPercent__c is incorrect.');
		System.assertEquals(null, productsToUpdate[0].SBQQ__SubscriptionPricing__c, 'SBQQ__SubscriptionPricing__c is incorrect.');
		System.assertEquals(null, productsToUpdate[0].SBQQ__SubscriptionTerm__c, 'SBQQ__SubscriptionTerm__c is incorrect.');
		System.assertEquals(null, productsToUpdate[0].SBQQ__SubscriptionType__c, 'SBQQ__SubscriptionType__c is incorrect.');
		System.assertEquals(null, productsToUpdate[0].SBQQ__AssetConversion__c, 'SBQQ__AssetConversion__c is incorrect.');
		System.assertEquals(null, productsToUpdate[0].SBQQ__AssetAmendmentBehavior__c, 'SBQQ__AssetAmendmentBehavior__c is incorrect.');
	}

	//Get the default(English) product description from the child product descriptions object on Material.
	@isTest
	public static void testProductDescription() {
		List<Product_Description__c> descriptions = [
			SELECT Id,Name,Product_Description__c,Product_Name__c, Language_Code__c 
			FROM Product_Description__c 
			LIMIT 1
		];

		System.assertEquals(1,descriptions.size(), 'No product description object was found from TestSetup()');
		MaterialMasterHelper helper = new MaterialMasterHelper();
		//run class method
		String description = helper.getProductDescription(descriptions);
		System.assertEquals('Product Description', description, 'The product description is incorrect');
	}

	//Get the default(English) product name from the child product descriptions object on Material.
	@isTest 
	public static void testProductName() {
		List<Product_Description__c> descriptions = [
			SELECT Id,Name,Product_Description__c,Product_Name__c, Language_Code__c 
			FROM Product_Description__c 
			LIMIT 1
		];
		System.assertEquals(1,descriptions.size(), 'No product description object was found from TestSetup()');
		MaterialMasterHelper helper = new MaterialMasterHelper();
		//run class method

		//CPQATG-771 - Populate the name according to language
		Map<String,String> productMap = helper.getProductName(descriptions);
		System.assertEquals('Product Name', productMap.get('EN'), 'The product name is incorrect');

		/*String description = helper.getProductName(descriptions);
		System.assertEquals('Product Name', description, 'The product name is incorrect');*/
	}

	//Expects 2 product for insert and 2 for update based on the testSetup() data
	@isTest
	public static void testCreateOrUpdateProducts() {

		List<SAP_Material__c> materials = [
			SELECT Id, Name, SAP_Base_Unit_of_Measure__c, Last_Batch_Run__c,
						SAP_Item_Category__c, SAP_Item_Category_Group__c, SAP_Material_Type__c, SAP_Product_Hierarchy__c, SAP_Product_Number__c,
						SAP_Quantity_for_Base_Unit_of_Measure__c, SAP_Quantity_for_Sales_Unit_of_Measure__c, SAP_Sales_Unit_of_Measure__c,CPQ_Material_Type__c,
							(SELECT Id, Name, IsActive, SBQQ__AssetConversion__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__ChargeType__c,
											SBQQ__Component__c, CPQ_Configured__c, LastModifiedDate, SBQQ__PricingMethod__c, ProductCode, Description, Family,
											SAP_Base_Unit_of_Measure__c, SAP_Item_Category_Group__c, SAP_Material__c,	SAP_Material_Type__c, SAP_Product_Number__c,
											SAP_Quantity_for_Base_Unit_of_Measure__c, SAP_Quantity_for_Sales_Unit_of_Measure__c,SAP_Sales_Unit_of_Measure__c,
											SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionType__c 
							FROM Products__r),
							(SELECT Id, Name, Language_Code__c, Product_Description__c, Product_Name__c, SAP_Material__c, SAP_Product_Number__c 
								FROM Product_Desciptions__r)
			FROM SAP_Material__c 
		];
		MaterialMasterHelper helper = new MaterialMasterHelper(materials);
		helper.createOrUpdateProducts();
		System.assertEquals(1, helper.productsToInsert.size(), 'Unexpected number of products to insert');
		System.assertEquals(1, helper.productsToUpdate.size(), 'Unexpected number of products to update');
	}

	@isTest
	public static void testGetMaterialsFromProducts() {
		
		List<Product2> products= [
			SELECT Id, SAP_Material__c 
			FROM Product2
		];
		
		MaterialMasterHelper helper = new MaterialMasterHelper();
		Map<Id, SAP_Material__c> materials = helper.getMaterialUpdatesForProducts(products);
		for(SAP_Material__c mat : materials.values()){
			System.assert(mat.Last_Batch_Run__c != null, 'The batch run was not updated with todays date');
		}
	}

	@isTest
	public static void testCreateLocalizationRecords() {

		List<SAP_Material__c> materials = [
			SELECT Id, Name, SAP_Base_Unit_of_Measure__c, Last_Batch_Run__c,
						SAP_Item_Category__c, SAP_Item_Category_Group__c, SAP_Material_Type__c, SAP_Product_Hierarchy__c, SAP_Product_Number__c,
						SAP_Quantity_for_Base_Unit_of_Measure__c, SAP_Quantity_for_Sales_Unit_of_Measure__c, SAP_Sales_Unit_of_Measure__c,CPQ_Material_Type__c,
							(SELECT Id, Name, IsActive, SBQQ__AssetConversion__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__ChargeType__c,
											SBQQ__Component__c, CPQ_Configured__c, LastModifiedDate, SBQQ__PricingMethod__c, ProductCode, Description, Family,
											SAP_Base_Unit_of_Measure__c, SAP_Item_Category_Group__c, SAP_Material__c,	SAP_Material_Type__c, SAP_Product_Number__c,
											SAP_Quantity_for_Base_Unit_of_Measure__c, SAP_Quantity_for_Sales_Unit_of_Measure__c,SAP_Sales_Unit_of_Measure__c,
											SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionType__c 
							FROM Products__r),
							(SELECT Id, Name, Language_Code__c, Product_Description__c, Product_Name__c, SAP_Material__c, SAP_Product_Number__c 
								FROM Product_Desciptions__r)
			FROM SAP_Material__c 
		];
		
		List<Product2> products= [
			SELECT Id, SAP_Material__c 
			FROM Product2
		];
		
		MaterialMasterHelper helper = new MaterialMasterHelper(materials);
		helper.createOrUpdLocalizationRecords(products);
	}

	@isTest
	public static void testCreatePricebookEntry() {
		MaterialMasterHelper helper = new MaterialMasterHelper();		
		PricebookEntry pbe = helper.createPricebookEntry(new Product2(Name='Test'), 'USD', 0, new Pricebook2(Id = Test.getStandardPricebookId()));
		System.assertNotEquals(null, pbe, 'A pricebook entry was not created during this test.');
	}

	@isTest
	public static void testGetIdSetFromObject() {
		List<SAP_Material__c> mats = [SELECT Id FROM SAP_Material__c];
		MaterialMasterHelper helper = new MaterialMasterHelper();
		Set<Id> recordIds = helper.getIdSetFromObject(mats);
		System.assertEquals(2, recordIds.size(), 'The expected number of Ids were not returned');
	}
}