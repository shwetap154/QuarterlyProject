/**
* File Name     :  PriceEntryBatchable
* @description  :  Batchable class that implements the logic to create Price Book Entries out of SAP Price Entries.
				   This job works in junction with MaterialMasterBatchable which is creating a Product2 record for
				   each SAP Material as well as the pricebook entry in the Standard pricebook for all the supported
				   currencies.
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group.
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/02/2019    Cory Bartholomew @ ATG   Created the Class.
* 1.1	  7/08/2019	   Cesar Sandrigo @ ATG		Added the all logic.
* 1.2	  4/13/2020	   Cesar Sandrigo @ ATG		Added insertion of Price Book Entries for Standard Pricebook when needed.
* 1.3	  7/24/2020	   Ramiro Alvarez @ ATG		CPQATG-910 - multiples products tied to one single material
*/
global class PriceEntryBatchable implements Database.Batchable<sObject>, Schedulable {

	private static final Integer SCHEDULABLE_BATCH_SIZE = 200;

	private static String query = 
		'SELECT Id, Name, CurrencyIsoCode, Last_Batch_Run__c, List_Price__c, ' +
			'Price_Book__c, product__c, SAP_Per__c, SAP_Product_Number__c, ' +
			'SAP_Sales_Org_Id__c, SAP_Unit_of_Measure__c, SAP_Valid_From__c, ' +
			'SAP_Valid_To__c, Date_Range_Valid__c ' +
		'FROM SAP_Price_Entry__c ' +
		'WHERE ' + 
		 	'Eligible_for_Batch_Run__c = TRUE ' + // TODO: Explain what this formula field does
			'AND Exclude_From_Batch_Run__c = FALSE ' + 
		// Applying ordering to process overlapping records together
		'ORDER BY SAP_Product_Number__c ASC, SAP_Sales_Org_Id__c ASC, CurrencyIsoCode ASC, CreatedDate DESC'; 
	
	/**
	 * @description Class constructor.
	 */
	global PriceEntryBatchable() {
	}
	
	/**
	 * @description Start method for the Batchable interface. Executes the query.
	 * @param BC The BatchableContext.
	 * @return The QueryLocator
	 */
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	/**
	 * @description Finish method for the Batchable interface.
	 * @param BC The BatchableContext.
	 * @param scope The batchable scope (records to be processed).
	 */
   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

		// Initialize the helper
		PriceEntryBatchHelper helper = new PriceEntryBatchHelper(scope);

		try {
			// Process the entries
			helper.process();

			// If there are entries to insert in the standard pricebook
			if(!helper.standardPriceBookEntriesToInserted.isEmpty()) {

				// Attempt to insert the entries
				Database.SaveResult[] insertSaveResults = Database.insert(helper.standardPriceBookEntriesToInserted, false);

				// Log any errors
				ErrorLogUtil.handleSaveResults('PriceEntryBatch: Failed to insert one or more Entries in the Standard Price Book', insertSaveResults);
			}

			// If there are entries to insert
			System.debug('helper.priceBookEntriesToInserted, ' + helper.priceBookEntriesToInserted);
			if(!helper.priceBookEntriesToInserted.isEmpty()) {

				// Attempt to insert the entries
				Database.SaveResult[] insertSaveResults = Database.insert(helper.priceBookEntriesToInserted, false);

				// Log any errors
				ErrorLogUtil.handleSaveResults('PriceEntryBatch: Failed to insert one or more Entries', insertSaveResults);
			}

			// Update the existing entries
			System.debug('helper.priceBookEntriesToUpdate, ' + helper.priceBookEntriesToUpdate);			
			if (!helper.priceBookEntriesToUpdate.isEmpty()) {

				// Attempt to insert the entries
				Database.SaveResult[] updateSaveResults = Database.update(helper.priceBookEntriesToUpdate, false);

				// Log any errors
				ErrorLogUtil.handleSaveResults('PriceEntryBatch: Failed to update one or more Entries', updateSaveResults);
			}

			System.debug('helper.sapPriceEntries, ' + helper.sapPriceEntries);
			// Update the SAP entries (mainly to set the 'Last Batch Run' field)
			if (!helper.sapPriceEntries.isEmpty()) {

				// Attempt to insert the entries
				Database.SaveResult[] updateSaveResults = Database.update(helper.sapPriceEntries, false);

				// Log any errors
				ErrorLogUtil.handleSaveResults('PriceEntryBatch: Failed to update one or more SAP Price Entry records.', updateSaveResults);
			}			
		}
		catch(Exception ex) {
			// Log any errors
			System.Debug(LoggingLevel.ERROR, 'PriceEntryBatch >> Exception: ' + ex.getMessage() + ' - Stack: ' + ex.getStackTraceString());
			ErrorLogUtil.log('PriceEntryBatch: There was an exception during the process.', ex);
		}

		ErrorLogUtil.commitLogs();
	}
	
	/**
	 * @description Finish method for the Batchable interface.
	 * @param BC The BatchableContext.
	 */
	global void finish(Database.BatchableContext BC) {
	}

	/**
	 * @description Execute method for the Schedulable interface.
	 * @param ctx the SchedulableContext.
	 */
	global void execute(SchedulableContext ctx){
		PriceEntryBatchable batchObject = new PriceEntryBatchable();
		Id batchId = Database.executeBatch(batchObject, SCHEDULABLE_BATCH_SIZE);
	}	
	
}