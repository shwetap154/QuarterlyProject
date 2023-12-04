/**
* File Name     :  PriceEntryBatchHelper
* @description  :  Class that contains helper methods related to Price Book Entries creation out of SAP Price entries
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/02         Cory Bartholomew @ ATG   Created the Class.
* 1.1	  7/11		   Cesar Sandrigo @ ATG		Added all the logic.
* 1.2	  4/13		   Cesar Sandrigo @ ATG		Added insertion of Price Book Entries for Standard Pricebook when needed.
* 1.3	  7/24/2020	   Ramiro Alvarez @ ATG		CPQATG-910 - multiples products tied to one single material
*
*/
public with sharing class PriceEntryBatchHelper {

	private static final Integer OFFSET_MINUTES = 10;

	/**
	 * @description Map that holds the Sales-Org -> Pricebook ID relation
	 */
	private Map<String, Id> salesOrgPricebookIdMap { get; set; }

	/**
	 * @description Map that holds the SAP Material Number -> Product2 Id
	 */	
	 
	//CPQATG-910 - Adjust map value to have Set<Id>
	private Map<String, Set<Id>> sapMaterialProductIdMap { get; set; }
	private Map<String, Id> sapMaterialIdMap { get; set; }
	private Set<Id> productsIds { get; set; }

	/**
	 * @description Map with PricebookId-ProductId as key, and the PricebookEntry Id as the value.
	 * This is useful to quickly get pricebook entries.
	 */
	private Map<String, Id> priceBookEntryMap { get; set; }

	/**
	 * @description List of price entries loaded from SAP.
	 */
	public List<SAP_Price_Entry__c> sapPriceEntries { get; private set; }

	/**
	 * @description Process Output: List of pricebook entries to be Updated
	 */
	public List<PricebookEntry> priceBookEntriesToUpdate { get; private set; }

	/**
	 * @description Process Output: List of pricebook entries to be Inserted
	 */
	public List<PricebookEntry> priceBookEntriesToInserted { get; private set; }

	/**
	 * @description Process Output: List of pricebook entries to be Inserted in the Standard Pricebook
	 */
	public List<PricebookEntry> standardPriceBookEntriesToInserted { get; private set; }

	/**
	 * @description Process Output: List of products that need to be updated with SAP Price Entry reference
	 */	
	public Map<Id,Product2>  prodListToUpd { get; private set; }

	
	/**
	 * @description Class constructor.
	 * @param entries Price Entries coming from SAP.
	 */
	public PriceEntryBatchHelper(List<SAP_Price_Entry__c> entries) {

		// Init the output lists
		priceBookEntriesToUpdate = new List<PricebookEntry>();
		priceBookEntriesToInserted = new List<PricebookEntry>();
		standardPriceBookEntriesToInserted = new List<PricebookEntry>();

		// Init the price entries
		sapPriceEntries = entries;
	}

	public void process() {

		// If there is nothing to process, get out of here
		if (sapPriceEntries.isEmpty()) {
			System.Debug(LoggingLevel.WARN, 'PriceEntryBatchHelper >> No entries to process.');
			return;
		}

		System.Debug(LoggingLevel.WARN, 'PriceEntryBatchHelper >> Entries to be processed: ' + sapPriceEntries.size());

		// Init SalesOrg -> Pricebook Id Map
		initSalesOrgPricebookIdMap();

		// Init SAP Material -> Product2 ID Map
		initSAPMaterialProductIdMap();

		// Propulate the map with the existing pricebook entries
		initPriceBookEntryMap();

		// Get the standard pricebook id
		Id standardPriceBookId = getStandardPricebookId();

		// Initialize temporary maps
		Map<String, PricebookEntry> pbeToUpdate = new Map<String, PricebookEntry>();
		Map<String, PricebookEntry> pbeToInsert = new Map<String, PricebookEntry>();
		
		// Map of pricebook entries to be inserted in the Standard Pricebook
		Map<String, PricebookEntry> standardPbeToInsert = new Map<String, PricebookEntry>();

		List<String> errors = new List<String>();

		//init product to update SAP Price lookup field
		prodListToUpd = new Map<Id, Product2> ();

		// Process the entries
		for (SAP_Price_Entry__c sapPriceEntry : sapPriceEntries) {

			// Check if the price entry has the Unit of Measure field populated
			if (String.isBlank(sapPriceEntry.SAP_Unit_of_Measure__c)) {

				// Add and string to the error list so they can logged together.
				errors.Add('The SAP Unit of Measure field is NOT populated - Entry: ' + sapPriceEntry.Name);

				// Log also in the console
				System.Debug(LoggingLevel.ERROR, 'PriceEntryBatchHelper >> The SAP Unit of Measure field is NOT populated: ' + sapPriceEntry.Name);
				continue;
			}
			
			// Check if there is pricebook for the Sales Org
			if (!salesOrgPricebookIdMap.containsKey(sapPriceEntry.SAP_Sales_Org_Id__c)) {
				// Add and string to the error list so they can logged together.
				errors.Add('No Price Book found for Sales Org: ' + sapPriceEntry.SAP_Sales_Org_Id__c + ' - Entry: ' + sapPriceEntry.Name);

				// Log also in the console
				System.Debug(LoggingLevel.ERROR, 'PriceEntryBatchHelper >> No Price Book found for Sales Org: ' + sapPriceEntry.SAP_Sales_Org_Id__c);
				continue;
			}

			// Check if there is at least a product with the given SAP Product Number
			if (!sapMaterialProductIdMap.containsKey(sapPriceEntry.SAP_Product_Number__c)) {
				// Add and string to the error list so they can logged together.
				errors.Add('No Product2 records found for SAP Material ' + sapPriceEntry.SAP_Product_Number__c + ' - Entry: ' + sapPriceEntry.Name);

				// Log also in the console
				System.Debug(LoggingLevel.ERROR, 'PriceEntryBatchHelper >> No Product2 records found for: ' + sapPriceEntry.SAP_Product_Number__c);
				continue;
			}
			
			// Get the pricebook id for the SalesOrg
			Id pricebookId = salesOrgPricebookIdMap.get(sapPriceEntry.SAP_Sales_Org_Id__c);
			
			for (Id productId : sapMaterialProductIdMap.get(sapPriceEntry.SAP_Product_Number__c)) {

				System.debug('product to be proceeded: '+ productId);

				// Get the product id related to the Material Number
				//Id productId = sapMaterialProductIdMap.get(sapPriceEntry.SAP_Product_Number__c);				

				// Build the key based on the Product Id, the Pricebook Id and the Currency ISO code
				String key = getKey(pricebookId, productId, sapPriceEntry.CurrencyIsoCode);

				System.debug('product to be proceeded, get key '+ key);

				// If the pricebookentry already exists and it was retrieved in the query means it needs to be updated.
				if (priceBookEntryMap.containsKey(key)) {
					// Existing PbE, update it.
					PricebookEntry pbe = new PricebookEntry();
					pbe.Id = priceBookEntryMap.get(key);
					pbe.UnitPrice = sapPriceEntry.List_Price__c;
					pbe.SAP_Price_Entry__c = sapPriceEntry.Id;

					System.debug('product to be proceeded, pbe: '+ pbe);

					if (pbeToUpdate.containsKey(key)) {
						// TODO: Manage overlapping price entries on update
					}
					else {
						pbeToUpdate.put(key, pbe);
					}
				}
				else {
					// No existing PBE, create a new one
					if (pbeToInsert.containsKey(key)) {
						// TODO: Manage overlapping price entries on insert
					}
					else {
						// The pricebook doesn't exist, so I need to create one
						pbeToInsert.put(key, createPricebookEntry(pricebookId, productId, sapPriceEntry.List_Price__c, sapPriceEntry.CurrencyIsoCode, sapPriceEntry.Id));

						/* Since this is new pricebook entry, I need to check if there is already a PBE with the same
						* combination of Product and Currency in the Standard pricebook, if not, I need to create it. */

						// Standard Pricebook Entry Key
						String standardPbeKey = getKey(standardPriceBookId, productId, sapPriceEntry.CurrencyIsoCode);

						// If the PBE doesn't exists in the Standard Pricebook and it was not added yet, a new one needs to be created
						if (!priceBookEntryMap.containsKey(standardPbeKey) && !standardPbeToInsert.containsKey(standardPbeKey)) {
							System.debug('Standard Pricebook Entry missing - MAT: ' + sapPriceEntry.SAP_Product_Number__c + ' CURR: ' + sapPriceEntry.CurrencyIsoCode);
							standardPbeToInsert.put(standardPbeKey, createPricebookEntry(standardPriceBookId, productId, 0, sapPriceEntry.CurrencyIsoCode, null));
						}
					}
				}

				// Update the SAP Price entry
				sapPriceEntry.Last_Batch_Run__c = Datetime.now().addMinutes(OFFSET_MINUTES);
				sapPriceEntry.Price_Book__c = pricebookId;
				sapPriceEntry.SAP_Material__c = sapMaterialIdMap.get(sapPriceEntry.SAP_Product_Number__c);
				//sapPriceEntry.Product__c = productId; **DEPRECATED**
			}
			
		}

		/* As the result of the process, update the public properties with the 
		 * list that are goin to be used to update and insert the PBEs */
		priceBookEntriesToUpdate = pbeToUpdate.values();
		priceBookEntriesToInserted = pbeToInsert.values();
		standardPriceBookEntriesToInserted = standardPbeToInsert.values();

		System.debug('product to be proceeded, priceBookEntriesToUpdate' + priceBookEntriesToUpdate);
		System.debug('product to be proceeded, priceBookEntriesToInserted' + priceBookEntriesToInserted);
		System.debug('product to be proceeded, standardPriceBookEntriesToInserted' + standardPriceBookEntriesToInserted);

		// If there were errors, log them.
		if(!errors.isEmpty()) {
			ErrorLogUtil.log('PriceEntryBatch: There were some errors processing the SAP Prices Entries.', errors);
		}
	}

	/**
	 * @description Creates a PricebookEntry object with the information passed as parameter.
	 * @param pricebookId The Pricebook ID
	 * @param productId The product ID
	 * @param unitPrice The unit price
	 * @param currencyCode The currency ISO code
	 * @return A PricebookEntry.
	 */
	private PricebookEntry createPricebookEntry(Id pricebookId, Id productId, Decimal unitPrice, String currencyCode, String SAPpriceEntryId) {

		return new PricebookEntry(
			IsActive = true,
			CurrencyIsoCode = currencyCode,
			UnitPrice = unitPrice,
			Pricebook2Id = pricebookId,
			Product2Id = productId,
			SAP_Price_Entry__c = SAPpriceEntryId 
		);
	}

	/**
	 * @description Initializes the SalesOrg - Pricebook Id map.
	 */
	private void initSalesOrgPricebookIdMap() {

		// Initialize the Map
		salesOrgPricebookIdMap = new Map<String, Id>();

		// Retrieve the list of Markets
		List<Market__c> marketList = [SELECT Price_Book__c, Sales_Org__c FROM Market__c];

		// Interate thru the markets list and create the map entries
		for (Market__c market : marketList) {
			salesOrgPricebookIdMap.put(market.Sales_Org__c, market.Price_Book__c);
		}
	}

	/**
	 * @description Initializes the SAP Material Number -> Product2 Id Map
	 */
	private void initSAPMaterialProductIdMap() {

		Set<String> materialNumberSet = new Set<String>();

		// Build a set with all the material numbers 
		for (SAP_Price_Entry__c priceEntry : sapPriceEntries) {

			if (String.isNotBlank(priceEntry.SAP_Product_Number__c)) {
				materialNumberSet.add(priceEntry.SAP_Product_Number__c);	
			}
		}

		// Retrieve only the products associated with Materials
		List<Product2> products = [SELECT Id, SAP_Product_Number__c FROM Product2 WHERE SAP_Material__c != NULL AND SAP_Product_Number__c IN :materialNumberSet];

		// Initialize the Map
		sapMaterialProductIdMap = new Map<String, Set<Id>>();
		productsIds = new Set<Id>();		

		// Iterate thru the Product2 records and create the map entries
		System.debug('initSAPMaterialProductIdMap, products: ' + products);
		for (Product2 product : products) {
			if (!sapMaterialProductIdMap.containsKey(product.SAP_Product_Number__c)) {				
				//sapMaterialProductIdMap.put(product.SAP_Product_Number__c, product.Id);
				
				//CPQATG-910 - allow one matareial tied to many products
				sapMaterialProductIdMap.put(product.SAP_Product_Number__c, new Set<Id> ());
			}
			sapMaterialProductIdMap.get(product.SAP_Product_Number__c).add(product.Id);
			productsIds.add(product.Id);			
		}

		// Initialize the Map
		sapMaterialIdMap = new Map<String,Id>();
		// Retrieve Materials to populate new lookup field on SAP Price Entry (CPQATG-910)
		List<SAP_Material__c> materials = [SELECT Id, SAP_Product_Number__c FROM SAP_Material__c WHERE SAP_Product_Number__c IN :materialNumberSet];
		for (SAP_Material__c material : materials) {
			sapMaterialIdMap.put(material.SAP_Product_Number__c, material.Id);		
		}


	}

	/**
	 * @description Initializes a map with PricebookId-ProductId as key, and the PricebookEntryId as the value.
	 */
	private void initPriceBookEntryMap() {

		priceBookEntryMap = new Map<String, Id>();
		
		
		// Get the PBEs related to the products we're going to insert
		List<PricebookEntry> pricebookEntryList = 
			[SELECT Id, IsActive, CurrencyIsoCode, UnitPrice, Pricebook2Id, Product2Id 
			 FROM PricebookEntry
			 WHERE IsDeleted = FALSE AND Product2Id IN :productsIds];

		// Populate the map
		for (PricebookEntry pbe : pricebookEntryList) {
			// Build the key
			String key = getKey(pbe.Pricebook2Id, pbe.Product2Id, pbe.CurrencyIsoCode);
			System.debug('initPriceBookEntryMap, key: ' + key);

			// Insert the entry
			priceBookEntryMap.put(key, pbe.Id);
		}
	}

	/**
	 * @description Builds the unique key to identify a price book entry
	 */
	private static String getKey(Id pricebookId, Id productId, String currIsoCode) {
		return string.format('{0}-{1}-{2}', new List<Object> { pricebookId, productId, currIsoCode });
	}

	private static Id getStandardPricebookId() {

		if (Test.isRunningTest()) {
			return Test.getStandardPricebookId();
		}

		Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
		return pb.Id;
	}
}