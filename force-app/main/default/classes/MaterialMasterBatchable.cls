/**
* File Name     :  MaterialMasterBatchable
* @description  :  Batchable class that implements the logic to create Product2 records out of SAP Materials.
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group.
* How to Run	:  Run the following lines in Anonymous Apex Windows:
*						MaterialMasterBatchable mmb = new MaterialMasterBatchable();
*						Database.executeBatch(mmb, 200);
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/21/19        Cory Bartholomew @ ATG   Created the Class. Added the initial functionality.
* 1.1	  8/5/19		 Cesar Sandrigo @ ATG		Modified to create just one Product2 record for each Material
* 1.2	  5/28/20		 Ramiro Alvarez @ ATG		Create/Update Localization records after insertion/update of products
*/

global class MaterialMasterBatchable implements Database.Batchable<sObject>, Schedulable {

	static final Integer SCHEDULABLE_BATCH_SIZE = 200;
	
	String productQuery = '(SELECT Id, Name, IsActive, SBQQ__AssetConversion__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__ChargeType__c, ' +
		'SBQQ__Component__c, CPQ_Configured__c, LastModifiedDate, SBQQ__PricingMethod__c, ProductCode, Description, Family, ' +
		'SAP_Base_Unit_of_Measure__c, SAP_Item_Category_Group__c, SAP_Material__c,	SAP_Material_Type__c, SAP_Product_Number__c, ' +
		'SAP_Quantity_for_Base_Unit_of_Measure__c, SAP_Quantity_for_Sales_Unit_of_Measure__c,SAP_Sales_Unit_of_Measure__c, ' + 
		'SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionType__c ' +
		'FROM Products__r ' +
		'), ';
	
	//Chil query from Material
	String productDescriptionQuery = '(SELECT ' +
		'Id, Name, Language_Code__c, Product_Description__c, Product_Name__c, SAP_Material__c, SAP_Product_Number__c ' +
		'FROM Product_Desciptions__r ) ';	// This should have no comma at the end,  it acts like the last field in the query
	
	//Child Query from Material
	String query = 'SELECT Id, Name, CreatedDate, LastModifiedDate, SAP_Base_Unit_of_Measure__c, Last_Batch_Run__c,' +
		'SAP_Item_Category__c, SAP_Item_Category_Group__c, SAP_Material_Type__c, SAP_Product_Hierarchy__c, SAP_Product_Number__c,' +
		'SAP_Quantity_for_Base_Unit_of_Measure__c, SAP_Quantity_for_Sales_Unit_of_Measure__c, SAP_Sales_Unit_of_Measure__c, CPQ_Material_Type__c, ' +
		 productQuery +
		 productDescriptionQuery +		 		
		'FROM SAP_Material__c ' +
		'WHERE Eligible_for_Batch_Run__c = TRUE';
	
	global MaterialMasterBatchable() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(query);
	}

  	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		System.Debug(LoggingLevel.WARN, 'Scope: ' + scope);
		MaterialMasterHelper helper = new MaterialMasterHelper(scope);
		helper.createOrUpdateProducts();		

		//get a set of successes so we can update the materials as ineligible for the next batch run
		Set<Id> successfulProducts = new Set<Id>();		
		
		if(helper.productsToInsert.size() > 0){
			//attemp product inserts.  Loop DB results and grab successes.  Log failures.
			Database.SaveResult[] srProductInsert = Database.insert(helper.productsToInsert,false);
			for(Database.SaveResult sr : srProductInsert) {
				if(sr.isSuccess()) {
					successfulProducts.add(sr.getId());
				}
			}
			ErrorLogUtil.handleSaveResults('Material Master Batch:  Failed to insert Product', srProductInsert);
		}
		//create 0$ pricebook entries for successfully inserted Products
		helper.createPricebookEntries(successfulProducts);
		
		if(helper.pricebookEntries.size() > 0){
			//attemp pricebook entry inserts.  Loop DB results and grab successes.  Log failures.
			Database.SaveResult[] srListInsertPBE = Database.insert(helper.pricebookEntries,false);
			for(Database.SaveResult sr : srListInsertPBE){
				if(sr.isSuccess()){
					System.debug('Successfully inserted pricebookentry');
				}				
			}
			ErrorLogUtil.handleSaveResults('Material Master Batch:  Failed to insert Pricebook Entry', srListInsertPBE);
		}

		// send successfulProducts (Id set) to CPQOrdersCreatedFromSAPSalesOrderHandler class to process any OrderItems that need cloned for Product2Id update
		CPQOrdersCreatedFromSAPSalesOrderHandler.handleNewProducts(successfulProducts);		

		//Update products that are not net new
		if(helper.productsToUpdate.size() > 0){
			//attemp product updates.  Loop DB results and grab successes.  Log failures.
			Database.SaveResult[] srProductUpdate = Database.update(helper.productsToUpdate,false);
			for(Database.SaveResult sr : srProductUpdate){
				if(sr.isSuccess()){
					System.debug('Successfully updated product');
					successfulProducts.add(sr.getId());
				}
			}
			ErrorLogUtil.handleSaveResults('Material Master Batch:  Failed to update Product', srProductUpdate);
		}
		//Find the materials that were successful and update them as ineligible for batch class (until they are changed again).		
		List<Product2> productsForMaterialUpdate = [SELECT Id, SAP_Material__c FROM Product2 WHERE Id IN : successfulProducts];
		//Set<SAP_Material__c> materialsToUpdate = new Set<SAP_Material__c>();
		Map<Id,SAP_Material__c> materialsToUpdate = new Map<Id,SAP_Material__c>();
		materialsToUpdate = helper.getMaterialUpdatesForProducts(productsForMaterialUpdate); 

		if(!materialsToUpdate.values().isEmpty()) {
			//attemp product updates.  Loop DB results and grab successes.  Log failures.
			//Database.SaveResult[] srMatUpdate = Database.update(new List<SAP_Material__c>(materialsToUpdate),false);
			Database.SaveResult[] srMatUpdate = Database.update(materialsToUpdate.values(),false);
			for(Database.SaveResult sr : srMatUpdate){		
				if(sr.isSuccess()) {
					System.debug('Materials were successfuly updated');
				}						
			}
			ErrorLogUtil.handleSaveResults('Material Master Batch:  Failed to update material',srMatUpdate);		
		}

		//RA - CPQATG-846: Create or Update Localization records for products succesfuly inserted/updated
		helper.createOrUpdLocalizationRecords(productsForMaterialUpdate);
		if(helper.localizationToInsert.size() > 0) {			
			Database.SaveResult[] srLocalizationInsert = Database.insert(helper.localizationToInsert,false);
			for(Database.SaveResult sr : srLocalizationInsert) {
				if(sr.isSuccess()) {
					System.debug('Localization record inserted successfuly');
				}
			}
			ErrorLogUtil.handleSaveResults('Material Master Batch: Failed to insert Localization', srLocalizationInsert);
		}
		if(helper.localizationToUpdate.size() > 0) {
			//List<SBQQ__Localization__c> localizationListToUpd = new List<SBQQ__Localization__c>();
			Map<Id,SBQQ__Localization__c> localizationToUpdMap = new Map<Id,SBQQ__Localization__c> ();
			for (SBQQ__Localization__c localization : helper.localizationToUpdate){
				if (!localizationToUpdMap.containsKey(localization.Id)) {
					localizationToUpdMap.put(localization.Id, localization);
				}
			}

			Database.SaveResult[] srLocalizationUpdate = Database.update(localizationToUpdMap.values(),false);
			for(Database.SaveResult sr : srLocalizationUpdate){
				if(sr.isSuccess()) {
					System.debug('Localization record updated successfuly');						
				}
			}
			ErrorLogUtil.handleSaveResults('Material Master Batch:  Failed to update Localization', srLocalizationUpdate);
		}

		// Log the error for the materials that don't have any Product Description records associated to it.
		if (!helper.materialNumberMissingProductDescription.isEmpty()) {
			ErrorLogUtil.log('MaterialMasterBatchable: The following Materials cannot be processed since they don\'t have any Product Description record associated to them: ' + String.join(helper.materialNumberMissingProductDescription, ', '), new List<String>());
		}

		ErrorLogUtil.commitLogs();
	}
	
	global void finish(Database.BatchableContext bc) {
		
	}

	//Only method of Schedulable Interface    
	global void execute(SchedulableContext ctx){
		MaterialMasterBatchable batchObject = new MaterialMasterBatchable();
		Id batchId = Database.executeBatch(batchObject, SCHEDULABLE_BATCH_SIZE);
	}	
}