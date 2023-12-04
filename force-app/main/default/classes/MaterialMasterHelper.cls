/**
* File Name     :  MaterialMasterHelper
* @description  :  Class that contains helper methods related to Product2 record creation out of SAP Materials
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/17/19         Cory Bartholomew @ ATG   Created the Class. Added the initial logic.
* 1.1	  8/5/19		  Cesar Sandrigo @ ATG		Modified the logic to create just one Product2 (Recurring) record per Material.
* 1.2	  6/4/20		  Ramiro Alvarez @ ATG		Adding createOrUpdLocalizationRecords method
* 1.3	  7/16/20		  Ramiro Alvarez @ ATG		CPQATG-909 Update updateProduct to receive and return List of Products
*/
public with sharing class MaterialMasterHelper {

	private static final Integer OFFSET_MINUTES = 10;

	//private static final List<String> SUPPORTED_CURRENCIES = new List<String>{'USD', 'CAD', 'BRL', 'GBP', 'MXN'};
	private List<Market__c> salesOrgPricebookList { get; set; }
	public List<SAP_Material__c> materials {get; set;}
	public List<Product2> productsToInsert {get; set;}
	public List<Product2> productsToUpdate {get; set;}
	public List<PricebookEntry> pricebookEntries {get; set;}
	public List<SBQQ__Localization__c> localizationToInsert {get; set;}
	public Set<SBQQ__Localization__c> localizationToUpdate {get; set;}

	//CPQATG-1311
	public List<String> materialForPreInstallEmail {get; set;}

	/**
	 * List of Material Numbers that doesn't have Product Description record associated to them.
	 * Since Product Description records contains the Product Name, the Product Record will fail
	 * at the time it's inserted. For that reason we need to track this Materials Numbers
	 * to log a frienly message.
	 */
	public List<String> materialNumberMissingProductDescription { get; private set; }
	

    /* Removing CPQ material type code.  Updated as a formula field based on a conversion identified in ATGCPQ-302
	@TestVisible
	private Map<String, Material_Type__c> materialTypeMap {get; set;}
	*/

	private Map<String, String> constLangMap = new Map<String, String> {		
		'DA' => 'da',
		'DE' => 'de',		
		'EN' => 'en_US',
		'ES' => 'es',
		'FI' => 'fi',
		'FR' => 'fr',		
		'IT' => 'it',
		'JA' => 'ja',
		'KO' => 'ko',
		'NL' => 'nl_NL',
		'NO' => 'no',		
		'PT' => 'pt_BR',
		'RU' => 'ru',
		'TH' => 'th',
		'ZF' => 'zh_TW',
		'ZH' => 'zh_CN'
	};
	
	public MaterialMasterHelper() {
		System.Debug(LoggingLevel.WARN, 'Material Master Helper INIT()');
		initSalesOrgPricebookList();
		
		//CPQATG-1311 Get SAP Product Numbers from custom setting to populate Send_PreInstall_Checklist__c on Product2
        CPQ_PreInstall_Checklist__c param = CPQ_PreInstall_Checklist__c.getInstance();
        this.materialForPreInstallEmail = param.Send_Email_Material_List__c != null ? param.Send_Email_Material_List__c.split(',') : new List<String> ();
	}

	public MaterialMasterHelper(List<SAP_Material__c> materials) {
		System.Debug(LoggingLevel.WARN, 'Material Master Helper INIT()');
		this.materials = materials;	
		this.productsToInsert = new List<Product2>();	
		this.productsToUpdate = new List<Product2>();		
		initSalesOrgPricebookList();
		this.localizationToInsert = new List<SBQQ__Localization__c>();
		this.localizationToUpdate = new Set<SBQQ__Localization__c>();
		this.materialNumberMissingProductDescription = new List<String>();

		//CPQATG-1311 Get SAP Product Numbers from custom setting to populate Send_PreInstall_Checklist__c on Product2
        CPQ_PreInstall_Checklist__c param = CPQ_PreInstall_Checklist__c.getInstance();
        this.materialForPreInstallEmail = param.Send_Email_Material_List__c != null ? param.Send_Email_Material_List__c.split(',') : new List<String> ();
	}

	/**
	 * @description Creates or updates the Product2 records related with the SAP Materials provided in the class constructor.
	 */
	public void createOrUpdateProducts() {

		//Compare existing products in Materials to verify all products have a one-time and recurring material
		for(SAP_Material__c material : this.materials) {
			
			// If there's no related product to the material, we need to create a new product.
			if (material.Products__r == null || material.Products__r.isEmpty()) {

				// Create an instance of a new Product based on the information in the material record.
				Product2 newProduct = createProduct(material);

				// Check if the material has Product Description records associated to it so the Name can be determined.
				if (String.isBlank(newProduct.Name)) {
					// If the Name cannot be determined, add the Material Number to a list so an error message can be logged.
					this.materialNumberMissingProductDescription.add(material.SAP_Product_Number__c);
				} else {
					// All good, the product can be inserted.
					this.productsToInsert.add(newProduct);
				}
			}
			else {
				//update the products under this material to have the correct material supplied fields
				//this.productsToUpdate.add(updateProduct(material.Products__r[0], material));
				this.productsToUpdate.addAll(updateProduct(material.Products__r, material));
			}
		}
	}

	/**
	 * @description Initializes the SalesOrg - Pricebook Id map.
	 */
	private void initSalesOrgPricebookList() {

		// Initialize the Map
		salesOrgPricebookList = [
			SELECT Price_Book__c, Sales_Org__c,
				(SELECT Id, Name, CurrencyIsoCode, Market__c
				FROM Market_Countries__r)
			FROM Market__c
		];		
	}

	/**
	 * @description Creates pricebook entries in the Stantard Pricebook for the products passed as parameter.
	 * @products Set of Product IDs.
	 */
	public void createPricebookEntries(Set<Id> products) {
		System.Debug(LoggingLevel.WARN, 'Material Master Helper CreatePricebookEntries()');
		this.pricebookEntries = createZeroDollarPricebookEntries(products, getStandardPricebook());
		System.Debug(LoggingLevel.WARN, 'PricebookEntries count: ' + this.pricebookEntries.size() + ' >>> ' + this.pricebookEntries );
	}
	
	public Map<Id, SAP_Material__c> getMaterialUpdatesForProducts(List<Product2> products) {
		//Set<SAP_Material__c> materialsToReturn = new Set<SAP_Material__c>();
		Map<Id, SAP_Material__c> materialsToReturnMap = new Map<Id, SAP_Material__c> ();
		for( Product2 product: products) {
			if (!materialsToReturnMap.containsKey(product.SAP_Material__c)) {
				SAP_Material__c material = new SAP_Material__c(Id = product.SAP_Material__c, Last_Batch_Run__c = Datetime.now().addMinutes(OFFSET_MINUTES));
				materialsToReturnMap.put(product.SAP_Material__c, material);
			}
		}
		return materialsToReturnMap;
	}

	/**
	 * @description Creates Localization records for the products passed as parameter.
	 * @products
	 */
	public void createOrUpdLocalizationRecords(List<Product2> products) {
		System.Debug(LoggingLevel.WARN, 'MaterialMasterHelper createLocalizationRecords()');		
		Set<Id> materialIds = new Set<Id> ();
		for (Product2 product : products) {			
			materialIds.add(product.SAP_Material__c);
		}

		Set<Id> productIds = new Set<Id> ();
		for (Product2 product : products) {			
			productIds.add(product.Id);
		}

		List<Product_Description__c> prodDescList = [SELECT Id, Language_Code__c, Product_Description__c, Product_Name__c, SAP_Material__c
										   	  		FROM Product_Description__c
										   	   		WHERE SAP_Material__c IN :materialIds];
		
		Map<Id,List<Product_Description__c>> matProdDescMap = new Map<Id,List<Product_Description__c>> ();
		for (Product_Description__c prodDesc : prodDescList) {
			if (!matProdDescMap.containsKey(prodDesc.SAP_Material__c)) {
				matProdDescMap.put(prodDesc.SAP_Material__c, new List<Product_Description__c> ());
			}
			matProdDescMap.get(prodDesc.SAP_Material__c).add(prodDesc);
		}

		List<SBQQ__Localization__c> localizationList = [SELECT Id, SBQQ__Product__c,SBQQ__Language__c
									   					FROM SBQQ__Localization__c
														WHERE SBQQ__Product__c IN : productIds];
														   
		Map<String,Id> prodLocKeyMap = new Map<String,Id> ();
		for (SBQQ__Localization__c localization : localizationList){
			prodLocKeyMap.put(localization.SBQQ__Product__c + '-' + localization.SBQQ__Language__c,localization.Id);
		}
		
		for (Product2 product : products) {

			Map<String,String> productLangMap = getProductName(matProdDescMap.get(product.SAP_Material__c));			
			System.debug('createLocalizationRecords Map: '+ productLangMap);
			for (String lang : productLangMap.keySet()) {				
				if (constLangMap.containsKey(lang)) {
					if(!prodLocKeyMap.containsKey(product.Id + '-' + constLangMap.get(lang))) {
						System.debug('prodLocKeyMap Map - not contains: '+ prodLocKeyMap);
						SBQQ__Localization__c localization = new SBQQ__Localization__c ();
						localization.SBQQ__Product__c = product.Id;
						localization.SBQQ__Language__c = constLangMap.get(lang); //map to SF lang
						localization.SBQQ__APIName__c = 'Name';
						localization.SBQQ__Text__c = productLangMap.get(lang);
						localizationToInsert.add(localization);
					} else {
						System.debug('prodLocKeyMap Map - contains: '+ prodLocKeyMap);
						SBQQ__Localization__c localization = new SBQQ__Localization__c (Id = prodLocKeyMap.get(product.Id + '-' + constLangMap.get(lang)));
						localization.SBQQ__Text__c = productLangMap.get(lang);						
						localizationToUpdate.add(localization);
					}
				}
			}
		}
	}		
	

	/**
	 * @description Creates a Product2 record out of the SAP Material passed as parameter.
	 * @param material SAP Material
	 * @returns Product2 record that represents the SAP Material
	 */
	@TestVisible
	private Product2 createProduct(SAP_Material__c material) {
		
		Product2 product = new Product2();
		
		//SBQQ Fields
		product.IsActive = true;	
		product.SBQQ__AssetConversion__c = null;
		product.CPQ_Configured__c = true;		
		product.SBQQ__Component__c = true;
		product.SBQQ__ChargeType__c = 'Recurring';

		// CPQATG-276
		product.SBQQ__PricingMethod__c = 'List';
		product.SBQQ__SubscriptionPricing__c = null;
		product.SBQQ__SubscriptionTerm__c = null; 
		product.SBQQ__SubscriptionType__c = null;
		product.SBQQ__SubscriptionPercent__c = null;
		product.SBQQ__AssetConversion__c = null;
		product.SBQQ__AssetAmendmentBehavior__c = null;
		product.SBQQ__BillingFrequency__c = 'Monthly';
		product.SBQQ__BillingType__c = 'Advance';

		//SAP Fields Mapped From Material
		product.SAP_Material__c = material.Id;

        /*/* Removing CPQ material type code.  Updated as a formula field based on a conversion identified in ATGCPQ-302
		if(material != null && material.SAP_Product_Hierarchy__c != null) {
			product.CPQ_Material_Type__c = getMaterialTypeFromHierarchy(material.SAP_Product_Hierarchy__c);
		}*/

		// For product code, use Material Number
		product.ProductCode = material.SAP_Product_Number__c;

		// Get product Name and Description from Material multi-language related records
		//CPQATG-771 - Populate the name according to language
		Map<String,String> productLangMap = getProductName(material.Product_Desciptions__r);
		product.Name = productLangMap.get('EN');
		product.Product_Name_af__c = productLangMap.containsKey('AF') ? productLangMap.get('AF') : '';
		product.Product_Name_ar__c = productLangMap.containsKey('AR') ? productLangMap.get('AR') : '';
		product.Product_Name_cs__c = productLangMap.containsKey('CS') ? productLangMap.get('CS') : '';
		product.Product_Name_da__c = productLangMap.containsKey('DA') ? productLangMap.get('DA') : '';
		product.Product_Name_de__c = productLangMap.containsKey('DE') ? productLangMap.get('DE') : '';
		product.Product_Name_el__c = productLangMap.containsKey('EL') ? productLangMap.get('EL') : '';
		product.Product_Name_es__c = productLangMap.containsKey('ES') ? productLangMap.get('ES') : '';
		product.Product_Name_fr__c = productLangMap.containsKey('FR') ? productLangMap.get('FR') : '';
		product.Product_Name_hu__c = productLangMap.containsKey('HU') ? productLangMap.get('HU') : '';
		product.Product_Name_it__c = productLangMap.containsKey('IT') ? productLangMap.get('IT') : '';
		product.Product_Name_ja__c = productLangMap.containsKey('JA') ? productLangMap.get('JA') : '';
		product.Product_Name_ko__c = productLangMap.containsKey('KO') ? productLangMap.get('KO') : '';
		product.Product_Name_nl__c = productLangMap.containsKey('NL') ? productLangMap.get('NL') : '';
		product.Product_Name_pl__c = productLangMap.containsKey('PL') ? productLangMap.get('PL') : '';
		product.Product_Name_pt__c = productLangMap.containsKey('PT') ? productLangMap.get('PT') : '';
		product.Product_Name_sl__c = productLangMap.containsKey('SL') ? productLangMap.get('SL') : '';
		product.Product_Name_th__c = productLangMap.containsKey('TH') ? productLangMap.get('TH') : '';
		product.Product_Name_tr__c = productLangMap.containsKey('TR') ? productLangMap.get('TR') : '';
		product.Product_Name_zf__c = productLangMap.containsKey('ZF') ? productLangMap.get('ZF') : '';
		product.Product_Name_zh__c = productLangMap.containsKey('ZH') ? productLangMap.get('ZH') : '';

		//product.Name = getProductName(material.Product_Desciptions__r);
		product.Description = getProductDescription(material.Product_Desciptions__r);

		//CPQATG-1311
		product.Send_PreInstall_Checklist__c = this.materialForPreInstallEmail.contains(material.SAP_Product_Number__c) ? true : false;
		
		//CPQATG-1328
		if (material.CPQ_Material_Type__c == 'Ancillary' || material.CPQ_Material_Type__c == 'Consumable') {
			product.SBQQ__Component__c = false;
		}


		return product;
	}

	/**
	 * @description Updates the Product2 record based on the SAP Material passed as parameter.
	 * @param material SAP Material
	 * @returns Updated Product2 record
	 */
	@TestVisible
	private List<Product2> updateProduct(List<Product2> products, SAP_Material__c material) {
			
		// Updates product Name and Description
		//product.Name = getProductName(material.Product_Desciptions__r);
		
		//CPQATG-771 - Populate the name according to language

		Map<String,String> productLangMap = getProductName(material.Product_Desciptions__r);

		for (Product2 product: products) {
			product.Product_Name_af__c = productLangMap.containsKey('AF') ? productLangMap.get('AF') : '';
			product.Product_Name_ar__c = productLangMap.containsKey('AR') ? productLangMap.get('AR') : '';
			product.Product_Name_cs__c = productLangMap.containsKey('CS') ? productLangMap.get('CS') : '';
			product.Product_Name_da__c = productLangMap.containsKey('DA') ? productLangMap.get('DA') : '';
			product.Product_Name_de__c = productLangMap.containsKey('DE') ? productLangMap.get('DE') : '';
			product.Product_Name_el__c = productLangMap.containsKey('EL') ? productLangMap.get('EL') : '';
			product.Product_Name_es__c = productLangMap.containsKey('ES') ? productLangMap.get('ES') : '';
			product.Product_Name_fr__c = productLangMap.containsKey('FR') ? productLangMap.get('FR') : '';
			product.Product_Name_hu__c = productLangMap.containsKey('HU') ? productLangMap.get('HU') : '';
			product.Product_Name_it__c = productLangMap.containsKey('IT') ? productLangMap.get('IT') : '';
			product.Product_Name_ja__c = productLangMap.containsKey('JA') ? productLangMap.get('JA') : '';
			product.Product_Name_ko__c = productLangMap.containsKey('KO') ? productLangMap.get('KO') : '';
			product.Product_Name_nl__c = productLangMap.containsKey('NL') ? productLangMap.get('NL') : '';
			product.Product_Name_pl__c = productLangMap.containsKey('PL') ? productLangMap.get('PL') : '';
			product.Product_Name_pt__c = productLangMap.containsKey('PT') ? productLangMap.get('PT') : '';
			product.Product_Name_sl__c = productLangMap.containsKey('SL') ? productLangMap.get('SL') : '';
			product.Product_Name_th__c = productLangMap.containsKey('TH') ? productLangMap.get('TH') : '';
			product.Product_Name_tr__c = productLangMap.containsKey('TR') ? productLangMap.get('TR') : '';
			product.Product_Name_zf__c = productLangMap.containsKey('ZF') ? productLangMap.get('ZF') : '';
			product.Product_Name_zh__c = productLangMap.containsKey('ZH') ? productLangMap.get('ZH') : '';

			String productDesc = getProductDescription(material.Product_Desciptions__r);
			product.Description = productDesc == null ? product.SBQQ__ChargeType__c : productDesc + ' - ' + product.SBQQ__ChargeType__c;

			// Updates product code - DEPRECATED: Multiple products can be assigned to one single manterial 
			//product.ProductCode = material.SAP_Product_Number__c;

			// CPQATG-276
			product.SBQQ__PricingMethod__c = 'List';
			product.SBQQ__SubscriptionPricing__c = null;
			product.SBQQ__SubscriptionTerm__c = null; 
			product.SBQQ__SubscriptionType__c = null;
			product.SBQQ__SubscriptionPercent__c = null;
			product.SBQQ__AssetConversion__c = null;
			product.SBQQ__AssetAmendmentBehavior__c = null;
			product.SBQQ__BillingFrequency__c = 'Monthly';
			product.SBQQ__BillingType__c = 'Advance';
			
			//CPQATG-1311
			product.Send_PreInstall_Checklist__c = this.materialForPreInstallEmail.contains(material.SAP_Product_Number__c) ? true : false;

			//CPQATG-1328
			if (material.CPQ_Material_Type__c == 'Ancillary' || material.CPQ_Material_Type__c == 'Consumable') {
				product.SBQQ__Component__c = false;
			}
			
			// Sets the Material Type
			/* Removing CPQ material type code.  Updated as a formula field based on a conversion identified in ATGCPQ-302
			if(material != null && material.SAP_Product_Hierarchy__c != null){
				product.CPQ_Material_Type__c = getMaterialTypeFromHierarchy(material.SAP_Product_Hierarchy__c);
			}*/
		}

		return products;
	}

	//Get the default(English) product name from the child product descriptions object on Material.
	public Map<String,String> getProductName(List<Product_Description__c> descriptions){
		//System.Debug(LoggingLevel.WARN, 'Material Master Helper getProductName()');
		Map<String,String> productNameMap = new Map<String,String> ();
		for(Product_Description__c descr : descriptions){
			productNameMap.put(descr.Language_Code__c, descr.Product_Name__c);
		}
		return productNameMap;

		/*String name = null;
		for(Product_Description__c descr : descriptions){
			//Reutrn the english description
			if(descr.Language_Code__c == 'EN'){
				name = descr.Product_Name__c;				
			}			
		}
		return name;		*/
	}
	public String getProductDescription(List<Product_Description__c> descriptions){
		//System.Debug(LoggingLevel.WARN, 'Material Master Helper getProductDescription()');
		String description = null;
		for(Product_Description__c descr : descriptions){
			//Reutrn the english description
			if(descr.Language_Code__c == 'EN'){
				description = descr.Product_Description__c;
			}
		}
		return description;		
	}

	public List<PricebookEntry> createZeroDollarPricebookEntries(Set<Id> products, Pricebook2 standardPB){
		System.Debug(LoggingLevel.WARN, 'Material Master Helper createZeroDollarPBE()');
		Set<String> currencyCodes = new Set<String>();
			//Updates to have active markets drive which currencies we support
			for(Market__c market : this.salesOrgPricebookList){
				for(Market_Country__c country : market.Market_Countries__r){
					currencyCodes.add(country.CurrencyIsoCode);
			}
		}
		//Create PBEs for the determined currencies		
		List<PricebookEntry> entries = new List<PricebookEntry>();	
		for(Id productId : products){
			for(String curr : currencyCodes){
				entries.add(createPricebookEntry(new Product2(Id = productId), curr, 0, standardPB));
			}
		}
		System.debug(LoggingLevel.WARN, '$0 Pricebook Entries ' + entries); 		
		return entries;
	}

	public PricebookEntry createPricebookEntry(Product2 product, String currencyIsoCode, Decimal unitPrice, Pricebook2 pricebook){
		return new PricebookEntry(
			IsActive = TRUE,
			CurrencyIsoCode = currencyIsoCode,
			UnitPrice = unitPrice,
			Pricebook2Id = pricebook.Id,
			Product2Id = product.Id
		);
	}

	public Pricebook2 getStandardPricebook(){
		return [
			SELECT Id
		 	FROM Pricebook2
			WHERE IsStandard = TRUE
			LIMIT 1
		 ];
	}

	public Set<Id> getIdSetFromObject(List<SObject> records){
		Set<Id> returnSet = new Set<Id>();
		for(SObject obj : records){
			returnSet.add(obj.Id);
		}
		return returnSet;
	}	

	public String removeLeadingZeros(String stringVal){
		Boolean execute = true;
		String returnVal = stringVal;
		do {
			if(stringVal.length()>0){
				if (returnVal.left(1) == '0'){
					returnVal = returnval.substring(1,returnVal.length());
					//System.debug(LoggingLevel.WARN, 'StringVal of hierarchy' + returnVal);
				}else{
					execute = false;
				}
			}				
		} while(execute);
		return returnVal;
	}
}