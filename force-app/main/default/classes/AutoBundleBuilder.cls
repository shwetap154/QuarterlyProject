/**
* File Name     :  AutoBundleBuilder
* @description  :  Helper class that takes gathered data in the auto-bundle process and inserts records to create the CPQ bundle
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.  Date        Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0   09/12/2019  Cory Bartholomew @ ATG  Created the Class.
* 2.0   02/05/2020	Cory Bartholomew @ ATG  Added descriptions.
* 2.1   06/06/2020  Cesar Sandrigo @ ATG    Added Product Features, Parent Bundle and Nested bundle translations.
* 2.2   11/06/2020  Ramiro Alvarez @ ATG    CPQATG-881 - Adding logic to upsert product options
* 2.3   03/07/2020  Ramiro Alvarez @ ATG    CPQATG-787 - Move SBQQ__Number__c to 99999 for addlContractConsFeature
* 2.4   08/05/2020  Ramiro Alvarez @ ATG    CPQATG-1006 - Adding validateExistingBundle
* 2.5   08/21/2020  Ramiro Alvarez @ ATG    CPQATG-1008/13 Adding translations
* 2.6   1/26/2021  Ramiro Alvarez @ ATG    CPQATG-1273 Set market on bundle wrapper product2 record
* 2.7   2/19/2021  Ramiro Alvarez @ ATG    CPQATG-1219 conditionally add appropriate cash back/buy out option based on Vistex parameter
*/

public with sharing class AutoBundleBuilder {
    
    /**
     * @description 'Additional Contract Consideration' Product Feature name
     */
    public static final String ADDL_CONTRACT_CONSIDERATIONS_PRODUCT_NAME = 'Cash Back/Internal/Competitor Buyout';
    
    /**
    * @description 'Cash Back/Buy Out/Internal' product name variables
    */    
    public String CASH_BACK_PRODUCT_NAME;
    public String COMPETITIVE_BUY_OUT_PRODUCT_NAME;
    public String INTERNAL_BUY_OUT_PRODUCT_NAME;
    public String ADDITIONAL_CONSUMABLE_ANC_PRODUCT_NAME;
    public String ADDITIONAL_CONSUMABLE_ANC_FEATURE_NAME;
    public String ITEM_FOR_ZOETIS_DEVICE_RETURN;

    AutoBundleDataWrapper bundleData { get; set; }

    /**
     * @description The translation helper to support all the translations to the objects created.
     */
    private AutoBundleLocalizationHelper translationHelper = new AutoBundleLocalizationHelper();

    private Set<Id> productIdsForCreatePBEs;

    private Boolean stopProcessing = false;

    public AutoBundleBuilder() {
    }

    public AutoBundleBuilder(AutoBundleDataWrapper bundleData) {
        this.bundleData = bundleData;

        CPQBundleUpdates__c autobundlerConfig = CPQBundleUpdates__c.getOrgDefaults();
        this.CASH_BACK_PRODUCT_NAME = autobundlerConfig.Cash_Back_Prod_Name__c != null ? autobundlerConfig.Cash_Back_Prod_Name__c : 'Cash Back';
        this.COMPETITIVE_BUY_OUT_PRODUCT_NAME = autobundlerConfig.Competitive_Buy_Out_Prod_Name__c != null ? autobundlerConfig.Competitive_Buy_Out_Prod_Name__c : 'Competitive Buy Out';
        this.INTERNAL_BUY_OUT_PRODUCT_NAME = autobundlerConfig.Internal_Buy_Out_Prod_Name__c != null ? autobundlerConfig.Internal_Buy_Out_Prod_Name__c : 'Internal Buy Out';
        this.ITEM_FOR_ZOETIS_DEVICE_RETURN = autobundlerConfig.Item_for_Zoetis_Device_Return__c != null ? autobundlerConfig.Item_for_Zoetis_Device_Return__c : 'ITEM FOR ZOETIS DEVICE RETURN';
        this.ADDITIONAL_CONSUMABLE_ANC_PRODUCT_NAME = autobundlerConfig.AdditionalConsumableAncillary_Prod_Name__c != null ? autobundlerConfig.AdditionalConsumableAncillary_Prod_Name__c : 'Additional Consumables/Ancillaries for Initial Shipment';
        this.ADDITIONAL_CONSUMABLE_ANC_FEATURE_NAME = autobundlerConfig.AddConsumableAncillary_Feature_Name__c != null ? autobundlerConfig.AddConsumableAncillary_Feature_Name__c : 'Additional Consumables/Ancillaries for Initial Shipment';
    }

    //Worker method to utilize data gathered from a vistex deal and create a bundle structure to insert
    public void createBundle() {
        //create the parent product
        System.debug('createBundle ' + this.bundleData.bundleParent);
        //if(this.bundleData.bundleParent == null) {

        try {
            // Initialize the Set that contains the Product IDs for creating the PBEs
            productIdsForCreatePBEs = new Set<Id>();

            //CPQATG-1006
            this.validateExistingBundle(this.bundleData);
            if (stopProcessing) {
                System.debug('AutoBundleBuilder > createBundle: There is more than one product related to the Deal');
                ErrorLogUtil.log(
                    'AutoBundleBuilder > createBundle: There is more than one product related to the Deal',
                    new List<String>()
                );
                ErrorLogUtil.commitLogs();
                return;
            }

            //Fix: query market here once and pass it downstream
            Market__c market = [SELECT Id, Name, Price_Book__c, Add_Consumables_Ancillaries_Available__c,
                                Limit_Product_Option_auto_selection__c, Number_for_Selected_Product_Options__c,
                                (SELECT Name, Country__c, CurrencyIsoCode FROM Market_Countries__r)
                                FROM Market__c
                                WHERE Sales_Org__c = :this.bundleData.dealheader.ORGID__c];

            this.bundleData.bundleParent = createBundleHeader(this.bundleData, true, market);
            this.createProductOptions(this.bundleData, market);

            // Commit the registered localizations
            translationHelper.commitLocalizations();

            // Create pricebook entries for all the product2 records created during the process
            createPricebookEntries(productIdsForCreatePBEs, this.bundleData.dealheader.ORGID__c, market);
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'AutoBundleBuilder > createBundle: ERROR on creating bundle. Ex: ' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, 'AutoBundleBuilder > ' + ex.getStackTraceString());

            ErrorLogUtil.log('AutoBundleBuilder > createBundle: ERROR on creating bundle.', ex);
        }
        // }
    }

    //CPQATG-1006 Automatic CPQ Bundle Updates
    private void validateExistingBundle(AutoBundleDataWrapper data) {
        System.debug('validateExistingBundle...');

        // 10012020 - Fix: Do always replace if bundle already exists
        Boolean doReplace = true;

        if (doReplace) {
            List<Product2> existingProduct = [
                SELECT Id, Name, IsActive, ProductCode, Vistex_Deal_Header__c
                FROM Product2
                WHERE ProductCode = :data.dealHeader.DEALNUM__c
            ];

            System.debug('validateExistingBundle, existingProduct ' + existingProduct);

            // product header already exist, need to inactivate
            if (existingProduct.size() == 1) {
                System.debug('validateExistingBundle, size = 1 ');
                String dealId = existingProduct[0].Vistex_Deal_Header__c;

                //Run 'Fix Quotes' functionality
                if (dealId != null) {
                    if (!Test.isRunningTest()) {
                        RemoveDealFromQuoteLinesBatchable batch = new RemoveDealFromQuoteLinesBatchable(dealId);
                        Id batchId = Database.executeBatch(batch);
                    }
                }

                // Update existing bundle to be deprecated
                existingProduct[0].Name = existingProduct[0].Name + '_REPLACED-' + DateTime.now();
                existingProduct[0].IsActive = false;
                existingProduct[0].Vistex_Deal_Header__c = null;
                existingProduct[0].ProductCode = existingProduct[0].ProductCode + '_REPLACED-' + DateTime.now();

                //1st level product options
                List<SBQQ__ProductOption__c> parentOptions = [
                    SELECT Id, SBQQ__ConfiguredSKU__c, SBQQ__ProductCode__c, Unique_Key__c, SBQQ__ConfiguredSKU__r.ProductCode
                    FROM SBQQ__ProductOption__c
                    WHERE SBQQ__ConfiguredSKU__r.ProductCode = :data.dealHeader.DEALNUM__c
                ];

                System.debug('validateExistingBundle, parentOptions' + parentOptions);

                Set<String> childOptionCodes = new Set<String>();
                //Get products code for optional sku (2nd level options)
                for (SBQQ__ProductOption__c parentOption : parentOptions) {
                    childOptionCodes.add(parentOption.SBQQ__ProductCode__c);
                }

                // Need to update product code of Optional Products also
                List<Product2> optionalProducts = [
                    SELECT Id, ProductCode, Name, isActive
                    FROM Product2
                    WHERE
                        ProductCode IN :childOptionCodes
                        AND SAP_Material__c = NULL
                        AND Name != :ADDL_CONTRACT_CONSIDERATIONS_PRODUCT_NAME
                        AND Name != :this.CASH_BACK_PRODUCT_NAME
                        AND Name != :this.INTERNAL_BUY_OUT_PRODUCT_NAME
                        AND Name != :this.COMPETITIVE_BUY_OUT_PRODUCT_NAME
                        AND Name != :this.ITEM_FOR_ZOETIS_DEVICE_RETURN
                        AND Name != :this.ADDITIONAL_CONSUMABLE_ANC_PRODUCT_NAME
                        AND isActive = TRUE
                ];

                List<Product2> childProdToUpd = new List<Product2>();
                for (Product2 childProdct : optionalProducts) {
                    childProdToUpd.add(
                        new Product2(
                            Id = childProdct.Id,
                            ProductCode = childProdct.ProductCode + '_REPLACED-' + DateTime.now(),
                            Name = childProdct.Name + '_REPLACED-' + DateTime.now(),
                            isActive = false
                        )
                    );
                }

                //2nd level product options
                List<SBQQ__ProductOption__c> childOptions = [
                    SELECT Id, SBQQ__ConfiguredSKU__c, SBQQ__ProductCode__c, Unique_Key__c, SBQQ__ConfiguredSKU__r.ProductCode
                    FROM SBQQ__ProductOption__c
                    WHERE SBQQ__ConfiguredSKU__r.ProductCode IN :childOptionCodes
                ];

                System.debug('validateExistingBundle, childOptions' + childOptions);

                // Query for existing product features
                List<SBQQ__ProductFeature__c> productFeatures = [
                    SELECT Id, Name, Unique_Key__c, SBQQ__ConfiguredSKU__r.ProductCode
                    FROM SBQQ__ProductFeature__c
                    WHERE
                        SBQQ__ConfiguredSKU__r.ProductCode = :data.dealHeader.DEALNUM__c
                        AND Name != :AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS
                        AND Name != :this.ADDITIONAL_CONSUMABLE_ANC_FEATURE_NAME
                ];

                System.debug('validateExistingBundle, productFeatures' + productFeatures);

                // Loop into childOptions and update name and unique key
                for (SBQQ__ProductOption__c childOption : childOptions) {
                    if (childOption.Unique_Key__c != null) {
                        if (childOption.Unique_Key__c.contains('_REPLACED-')) {
                            Integer indexKey = childOption.Unique_Key__c.indexOf('_REPLACED-');
                            childOption.Unique_Key__c = childOption.Unique_Key__c.left(indexKey) + '_REPLACED-' + DateTime.now();
                        } else {
                            childOption.Unique_Key__c = childOption.Unique_Key__c + '_REPLACED-' + DateTime.now();
                        }
                        System.debug('validateExistingBundle, childOption.Unique_Key__c ' + childOption.Unique_Key__c);
                    }
                }

                // Loop into parentOptions and update name and unique key
                for (SBQQ__ProductOption__c parentOption : parentOptions) {
                    if (parentOption.Unique_Key__c != null) {
                        if (parentOption.Unique_Key__c.contains('_REPLACED-')) {
                            Integer indexKey = parentOption.Unique_Key__c.indexOf('_REPLACED-');
                            parentOption.Unique_Key__c = parentOption.Unique_Key__c.left(indexKey) + '_REPLACED-' + DateTime.now();
                        } else {
                            parentOption.Unique_Key__c = parentOption.Unique_Key__c + '_REPLACED-' + DateTime.now();
                        }
                        System.debug('validateExistingBundle, parentOption.Unique_Key__c ' + parentOption.Unique_Key__c);
                    }
                }

                // Loop into product featues and update name and unique key
                for (SBQQ__ProductFeature__c parentFeature : productFeatures) {
                    if (parentFeature.Unique_Key__c != null) {
                        if (parentFeature.Unique_Key__c.contains('_REPLACED-')) {
                            Integer indexKey = parentFeature.Unique_Key__c.indexOf('_REPLACED-');
                            parentFeature.Unique_Key__c = parentFeature.Unique_Key__c.left(indexKey) + '_REPLACED-' + DateTime.now();
                        } else {
                            parentFeature.Unique_Key__c = parentFeature.Unique_Key__c + '_REPLACED-' + DateTime.now();
                        }
                        System.debug('validateExistingBundle, parentFeature.Unique_Key__c ' + parentFeature.Unique_Key__c);
                    }
                }

                try {
                    System.debug('validateExistingBundle, try: ' + childOptions);
                    update childOptions;
                    System.debug('validateExistingBundle, parentOptions: ' + parentOptions);
                    update parentOptions;
                    System.debug('validateExistingBundle, productFeatures: ' + productFeatures);
                    update productFeatures;
                    System.debug('validateExistingBundle, existingProduct: ' + existingProduct[0]);
                    update existingProduct[0];
                    System.debug('validateExistingBundle, childProdToUpd: ' + childProdToUpd);
                    update childProdToUpd;
                } catch (Exception e) {
                    System.debug('validateExistingBundle - ERROR: ' + e.getMessage() + 'line: ' + e.getLineNumber());
                    ErrorLogUtil.log(e);
                    return;
                }
            } else if (existingProduct.size() > 1) {
                stopProcessing = true;
            }
        }
    }

    @testVisible
    private Product2 createBundleHeader(AutoBundleDataWrapper data, Boolean doInsert, Market__c market) {

        //CPQATG-1273 RA: Query market to translate sales org into market
        /*List<Market__c> markets = [SELECT Id, Name, Sales_Org__c
                                    FROM Market__c
                                    WHERE Sales_Org__c = :data.dealHeader.ORGID__c];
        */

        //create Parent Product
        Product2 product = new Product2();
        //SBQQ Fields
        product.IsActive = false;
        product.ProductCode = data.dealHeader.DEALNUM__c;
        product.Vistex_Deal_Header__c = data.dealHeader.Id;
        product.Program_Eligibility_Filter__c = data.eligibilityFilter;
        product.SBQQ__ConfigurationType__c = 'Allowed';
        product.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        product.Family = 'Programs'; // CPQATG-612
        product.name = data.bundleName;
        product.CPQ_Configured__c = true;
        product.SBQQ__Component__c = false;
        product.SBQQ__ChargeType__c = 'Recurring';
        product.SBQQ__PricingMethod__c = 'List';
        product.SBQQ__SubscriptionTerm__c = data.dealTerm;
        product.SBQQ__SubscriptionType__c = null;
        product.SBQQ__SubscriptionPercent__c = null;
        product.SBQQ__AssetConversion__c = null;
        product.SBQQ__AssetAmendmentBehavior__c = null;
        product.SBQQ__BillingFrequency__c = 'Monthly';
        product.SBQQ__BillingType__c = 'Advance';
        product.SBQQ__QuantityEditable__c = false;
        product.Vistex_Deal_ID__c = data.dealHeader.DEALNUM__c;
        product.vistex_banner_zprm__c = data.zprmText;
        product.vistex_banner_zter__c = data.zterText;
        product.vistex_banner_zprq__c = data.zprqText;
        product.vistex_banner_zcpq__c = data.zcpqText;
        product.Vistex_Banner_Summary__c = data.promoSummary; //Assignment added by Sourav Mitra @ CTS to show the summary of all banners in product object TPDEV-1637
        product.Lease_Type__c = data.dealHeader.CPQ_Transaction_Type_Text__c;        
        product.Large_Offer__c = data.IsLargeOffer;        
        product.Market__c = market.Id; //CPQATG-1273
        product.Is_Third_Party_Lease_Default__c = data.dealHeader.CPQ_Transaction_Type_Text__c == 'Device Sale/Third Party Lease' ?
            data.dealHeader.Is_Third_Party_Lease_Default__c : false; //CPQATG-1261

        if (doInsert) {
            try {
                insert product;
                productIdsForCreatePBEs.add(product.Id);
            } catch (Exception e) {
                System.debug(Logginglevel.ERROR, 'Error inserting bundle wrapper: ' + e);
                ErrorLogUtil.log(e);
            }
        }

        // Add translation for french, name of the offer will be the same for all languages
        translationHelper.addTranslations(product, data.bundleName, AutoBundleLocalizationHelper.FR_LANG_CODE);
        translationHelper.addTranslations(product, data.bundleName, AutoBundleLocalizationHelper.PT_BR_LANG_CODE);
        translationHelper.addTranslations(product, data.bundleName, AutoBundleLocalizationHelper.ES_LANG_CODE);
        translationHelper.addTranslations(product, data.bundleName, AutoBundleLocalizationHelper.ES_MX_LANG_CODE);
        translationHelper.addTranslations(product, data.bundleName, AutoBundleLocalizationHelper.IT_LANG_CODE);
        translationHelper.addTranslations(product, data.bundleName, AutoBundleLocalizationHelper.DE_LANG_CODE);
        translationHelper.addTranslations(product, data.bundleName, AutoBundleLocalizationHelper.JA_LANG_CODE);

        return product;
    }

    @testVisible
    private void createPricebookEntries(Set<Id> productIds, String salesOrg, Market__c market) {
        /* Market__c market = [
            SELECT Id, Name, Price_Book__c, (SELECT Name, Country__c, CurrencyIsoCode FROM Market_Countries__r)
            FROM Market__c
            WHERE Sales_Org__c = :salesOrg
        ];*/

        List<PricebookEntry> standardPBEs = new List<PricebookEntry>();
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        Set<String> currencyCodes = new Set<String>();
        for (Market_Country__c country : market.Market_Countries__r) {
            currencyCodes.add(country.CurrencyIsoCode);
        }

        Id standardPricebookId = Test.IsRunningTest() ? Test.getStandardPricebookId() : getStandardPricebook().Id;

        for (Id productId : productIds) {
            for (String curr : currencyCodes) {
                standardPBEs.add(createPricebookEntry(productId, curr, standardPricebookId));
                pbes.add(createPricebookEntry(productId, curr, market.Price_Book__c));
            }
        }

        try {
            System.debug('AutoBundleBuilder - createPricebookEntries: creating ' + standardPBEs.size() + ' standard PBEs');
            insert standardPBEs;
            try {
                System.debug('AutoBundleBuilder - createPricebookEntries: creating ' + pbes.size() + ' PBEs for Market ' + salesOrg);
                insert pbes;
            } catch (Exception e) {
                System.debug('An error occured when trying to insert Market Specific pricebook entries for the deal header');
                System.debug(e);
                System.debug(pbes);
                ErrorLogUtil.log(e);
                ErrorLogUtil.commitLogs();
            }
        } catch (Exception e1) {
            System.debug('An error occured when trying to insert Standard pricebook entries for the deal header');
            System.debug(e1);
            System.debug(standardPBEs);
            ErrorLogUtil.log(e1);
            ErrorLogUtil.commitLogs();
        }
    }

    @testVisible
    private PricebookEntry createPricebookEntry(Id productId, String currencyIsoCode, String pricebookId) {
        return new PricebookEntry(
            IsActive = true,
            CurrencyIsoCode = currencyIsoCode,
            UnitPrice = 0,
            Pricebook2Id = pricebookId,
            Product2Id = productId
        );
    }

    public static Pricebook2 getStandardPricebook() {
        return [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
    }

    /**
     * Creates the Product Options and Product Features.
     */
    private void createProductOptions(AutoBundleDataWrapper data, Market__c market) {
        List<AutoBundleDealLineWrapper> genericBundleLines = new List<AutoBundleDealLineWrapper>();
        genericBundleLines.addAll(bundleData.MaterialLines);
        genericBundleLines.addAll(bundleData.FlexibleGroupLines);

        // Create Product Future helper
        AutoBundleProductFeatureHelper featureHelper = new AutoBundleProductFeatureHelper(
            bundleData.bundleParent,
            genericBundleLines,
            bundleData.IsLargeOffer
        );

        // Get the product features
        List<FeatureOptionsGroup> productFeatureOptionGroupList = featureHelper.getProductFeatures();

        System.debug(
            'AutoBundleBuilder.createProductOptions - Nested Bundles: ' +
            featureHelper.SuffixWrapperBundleNameMap.size() +
            ' - Features: ' +
            productFeatureOptionGroupList.size()
        );

        Map<String, Product2> suffixNestedBundleWrapperMap = new Map<String, Product2>();

        /***** NESTED BUNDLE PROCESSING ****/
        if (featureHelper.SuffixWrapperBundleNameMap.size() > 0) {
            // Create nested product record or get it if it's already created
            suffixNestedBundleWrapperMap = createOrGetNestedBundleProducts(
                featureHelper.SuffixWrapperBundleNameMap,
                featureHelper.SuffixWrapperBundleNameTranslationMap
            );

            Map<String, SBQQ__ProductOption__c> suffixProductOptionMap = new Map<String, SBQQ__ProductOption__c>();
            Integer optionNumber = 100;

            // Create one product option for linking nested bundle with ultimate parent bundle
            for (String suffix : suffixNestedBundleWrapperMap.keySet()) {
                String prodOptionUniqueKey =
                    bundleData.bundleParent.ProductCode +
                    '-' +
                    suffixNestedBundleWrapperMap.get(suffix).ProductCode;

                SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c(
                    SBQQ__ConfiguredSKU__c = bundleData.bundleParent.Id,
                    SBQQ__OptionalSKU__c = suffixNestedBundleWrapperMap.get(suffix).Id,
                    SBQQ__Number__c = optionNumber += 100,
                    SBQQ__Quantity__c = 1,
                    SBQQ__QuantityEditable__c = true,
                    SBQQ__Required__c = false,
                    SBQQ__Selected__c = market.Limit_Product_Option_auto_selection__c ? false : true,
                    SBQQ__Type__c = 'Related Product',
                    Unique_Key__c = prodOptionUniqueKey
                );

                System.debug('AutoBundleBuilder.createProductOptions, nested productOption ' + productOption);

                suffixProductOptionMap.put(suffix, productOption);
            }

            // Insert Product Option for building the relationship between Parent Bundle product and Nested Bundle
            //insert suffixProductOptionMap.values();

            //CPQATG-881: Upsert product option for linking nested bundle with ultimate parent bundle
            System.debug('AutoBundleBuilder.createProductOptions, nested productOption' + suffixProductOptionMap);
            upsert suffixProductOptionMap.values() Unique_Key__c;
        }

        Map<String, SBQQ__ProductFeature__c> productFeaturesMap = new Map<String, SBQQ__ProductFeature__c>();

        for (FeatureOptionsGroup featureOptionGroup : productFeatureOptionGroupList) {
            Id parentId = null;
            // CPQATG-881
            String productCodeforKey = bundleData.bundleParent.ProductCode;

            if (suffixNestedBundleWrapperMap.containsKey(featureOptionGroup.Suffix)) {
                parentId = suffixNestedBundleWrapperMap.get(featureOptionGroup.Suffix).Id;
                productCodeforKey = suffixNestedBundleWrapperMap.get(featureOptionGroup.Suffix).ProductCode;
            }

            SBQQ__ProductFeature__c feature = featureOptionGroup.getProductFeature(parentId, productCodeforKey);

            productFeaturesMap.put(featureOptionGroup.Name, feature);

            // Register translations for the Feature
            translationHelper.addTranslations(feature, featureOptionGroup.getTranslations());
        }

        // Only Create a Feature for 'Additional Contract Considerations' if there are no nested bundles.

        if (suffixNestedBundleWrapperMap.isEmpty()) {
            // Create Product Feature for 'Additional Contract Considerations'
            
            /* 
            CPQATG-1241 New feature name: Cash Back Internal/External Buyout
            */
            SBQQ__ProductFeature__c addlContractConsFeature = new SBQQ__ProductFeature__c(
                Name = AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS,
                SBQQ__ConfiguredSKU__c = bundleData.bundleParent.Id,
                SBQQ__MinOptionCount__c = 0,
                SBQQ__Number__c = 99998, //
                Unique_Key__c = bundleData.bundleParent.ProductCode +
                    '-' +
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS
            );

            //CPQATG-1328 Feature name: Defined by custom setting. Default: Additional Consumables/Ancillaries for Initial Shipment
            SBQQ__ProductFeature__c addConsumablesFeature = new SBQQ__ProductFeature__c(
                Name = this.ADDITIONAL_CONSUMABLE_ANC_FEATURE_NAME,
                SBQQ__ConfiguredSKU__c = bundleData.bundleParent.Id,
                SBQQ__MinOptionCount__c = 0,
                SBQQ__Number__c = 99999, // It shoud be the last in the list
                Unique_Key__c = bundleData.bundleParent.ProductCode + '-' + this.ADDITIONAL_CONSUMABLE_ANC_FEATURE_NAME
            );

            // Add Product Feature for 'Additional Contract Considerations' to the map
            productFeaturesMap.put(AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS, addlContractConsFeature);
            
            //CPQATG-1328 Add Product Feature for 'Additional Consumables/Ancillaries for Initial Shipment'
            productFeaturesMap.put(this.ADDITIONAL_CONSUMABLE_ANC_FEATURE_NAME, addConsumablesFeature);

            System.debug('productFeaturesMap: ' + productFeaturesMap);

            // Register translations for the ACC Feature - FR
            translationHelper.addTranslations(
                addlContractConsFeature,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.FR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS
                ),
                AutoBundleLocalizationHelper.FR_LANG_CODE
            );

            // Register translations for the ACC Feature - BR
            translationHelper.addTranslations(
                addlContractConsFeature,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS
                ),
                AutoBundleLocalizationHelper.PT_BR_LANG_CODE
            );

            // Register translations for the ACC Feature - ES
            translationHelper.addTranslations(
                addlContractConsFeature,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS
                ),
                AutoBundleLocalizationHelper.ES_LANG_CODE
            );

            // Register translations for the ACC Feature - ES MX
            translationHelper.addTranslations(
                addlContractConsFeature,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS
                ),
                AutoBundleLocalizationHelper.ES_MX_LANG_CODE
            );

            // Register translations for the ACC Feature - IT
            translationHelper.addTranslations(
                addlContractConsFeature,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.IT_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS
                ),
                AutoBundleLocalizationHelper.IT_LANG_CODE
            );

            // Register translations for the ACC Feature - DE
            translationHelper.addTranslations(
                addlContractConsFeature,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.DE_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS
                ),
                AutoBundleLocalizationHelper.DE_LANG_CODE
            );

            // Register translations for the ACC Feature - JA
            translationHelper.addTranslations(
                addlContractConsFeature,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.JA_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS
                ),
                AutoBundleLocalizationHelper.JA_LANG_CODE
            );
        }        

        //CPQATG-881: Upsert product features
        upsert productFeaturesMap.values() Unique_Key__c;

        List<SBQQ__ProductOption__c> productOptionsToBeCreated = new List<SBQQ__ProductOption__c>();

        for (FeatureOptionsGroup featureOptionGroup : productFeatureOptionGroupList) {
            Product2 nestedBundleParent = null;

            if (suffixNestedBundleWrapperMap.containsKey(featureOptionGroup.Suffix)) {
                nestedBundleParent = suffixNestedBundleWrapperMap.get(featureOptionGroup.Suffix);
            }

            System.debug('Getting Options for Group: ' + featureOptionGroup.Name + ' - Override? ' + (nestedBundleParent != null));

            for (SBQQ__ProductOption__c productOption : featureOptionGroup.getProductOptions(nestedBundleParent)) {
                productOption.SBQQ__Feature__c = productFeaturesMap.get(featureOptionGroup.Name).Id;
                productOptionsToBeCreated.add(productOption);
            }
        }

        // Get the Parent Product record for 'Additional Contract Considerations' bundle.
        List<Product2> addlContractConsProductList = getAdditionalContractConsiderationBundle(data.dealHeader.Add_Cash_Back_Bundle__c,
            data.dealHeader.Add_Competitive_Buy_Out_Bundle__c,
            data.dealHeader.Add_Internal_Buy_Out_Bundle__c,
            data.dealHeader.Add_Consumables_Ancillaries_Available__c,
            market.Add_Consumables_Ancillaries_Available__c);
        
        System.debug('AutoBundleBuilder, addlContractConsProductList: ' + addlContractConsProductList);
        
        if (!addlContractConsProductList.isEmpty()) {
            Integer numberLine = 100000 - addlContractConsProductList.size();

            for (Product2 addlContractConsProduct : addlContractConsProductList) {

                String prodOptionUniqueKey = bundleData.bundleParent.ProductCode + '-' + addlContractConsProduct.ProductCode;
                System.debug('AutoBundleBuilder, prior to upsert addlContractConsProduct,prodOptionUniqueKey ' + prodOptionUniqueKey);

                
                if (addlContractConsProduct.Name != this.ADDITIONAL_CONSUMABLE_ANC_PRODUCT_NAME) { 
                    
                    // Create Product Options for hosting 'Cash Back/Bayout' nested bundle
                    productOptionsToBeCreated.add(
                        new SBQQ__ProductOption__c(
                            SBQQ__ConfiguredSKU__c = bundleData.bundleParent.Id,
                            SBQQ__OptionalSKU__c = addlContractConsProduct.Id,
                            SBQQ__Feature__c = productFeaturesMap.containsKey(AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS)
                                        ? productFeaturesMap.get(AutoBundleLocalizationHelper.FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS).Id : null,
                            SBQQ__Number__c = numberLine++,
                            SBQQ__Quantity__c = 1,
                            SBQQ__QuantityEditable__c = true,
                            SBQQ__Required__c = false,
                            SBQQ__Selected__c = false,
                            SBQQ__Type__c = 'Related Product',
                            Unique_Key__c = prodOptionUniqueKey
                        )
                    );
                    // Create Product Option for dynamic bundle (for additional consumables, andciliares)
                } else {
                    productOptionsToBeCreated.add(
                        new SBQQ__ProductOption__c(
                            SBQQ__ConfiguredSKU__c = bundleData.bundleParent.Id,
                            SBQQ__OptionalSKU__c = addlContractConsProduct.Id,
                            SBQQ__Feature__c = productFeaturesMap.containsKey(this.ADDITIONAL_CONSUMABLE_ANC_FEATURE_NAME)
                                        ? productFeaturesMap.get(this.ADDITIONAL_CONSUMABLE_ANC_FEATURE_NAME).Id : null,
                            SBQQ__Number__c = numberLine++,
                            SBQQ__Quantity__c = 1,
                            SBQQ__QuantityEditable__c = true,
                            SBQQ__Required__c = false,
                            SBQQ__Selected__c = false,
                            SBQQ__Type__c = 'Related Product',
                            Unique_Key__c = prodOptionUniqueKey
                        )
                    );
                }
            }
        }
        //CPQATG-1291: purge Product Options prior to insert it
        productOptionsToBeCreated = purgeProductOptionsForWarranties(data.dealHeader.DEALNUM__c, productOptionsToBeCreated, data.dealTerm);
        //CPQATG-1309: Control Product Option Auto-Selection for Non-Flexible Group Items
        productOptionsToBeCreated = autoSelectionForNonFlexGroupItems(productOptionsToBeCreated, market);

        upsert productOptionsToBeCreated Unique_Key__c;
    }

    /**
     * @description Control Product Option Auto-Selection for Non-Flexible Group Items
     * @return List<SBQQ__ProductOption__c> updated list
     */
    private List<SBQQ__ProductOption__c> autoSelectionForNonFlexGroupItems(List<SBQQ__ProductOption__c> productOptions, Market__c market) {

        /*
        * Count number of PO related to materials (non flexible group items)
        */
        
        Integer countMaterialOptions = 0;
        Map<String,Integer> prodOptionsSuffixCount = new Map<String,Integer>();

        for (SBQQ__ProductOption__c productOption : productOptions) {
            if (productOption.Flexible_Group__c == null && productOption.SBQQ__Selected__c) {
                String optionKey = productOption.Deal_Line_Group__c == null ? 'noSuffix' : productOption.Deal_Line_Group__c;
                if (!prodOptionsSuffixCount.containsKey(optionKey)) {
                    prodOptionsSuffixCount.put(optionKey,0);
                }                
                prodOptionsSuffixCount.put(optionKey,prodOptionsSuffixCount.get(optionKey)+1);
            }
        }

        System.debug('autoSelectionForNonFlexGroupItems, prodOptionsSuffixCount: ' + prodOptionsSuffixCount);
        
        /* If "Limit Product Option auto selection" is active and 
        *  the count of PO related to materials/suffix are greater than the Number for Selected Product Options, then set SBQQ__Selected__c to FALSE        
        */
        Integer marketNumberPOs = market.Number_for_Selected_Product_Options__c == null ? 0 : (Integer) market.Number_for_Selected_Product_Options__c;        
        //if(market.Limit_Product_Option_auto_selection__c && countMaterialOptions > marketNumberPOs) {
        if(market.Limit_Product_Option_auto_selection__c) {
            for (SBQQ__ProductOption__c productOption : productOptions) {                
                if (productOption.Flexible_Group__c == null && productOption.SBQQ__Selected__c) {
                    String optionKey = productOption.Deal_Line_Group__c == null ? 'noSuffix' : productOption.Deal_Line_Group__c;
                    if (prodOptionsSuffixCount.get(optionKey) > marketNumberPOs) {
                        productOption.SBQQ__Selected__c = false;
                    }
                }
            }
        }

        System.debug('autoSelectionForNonFlexGroupItems, productOptions: ' + productOptions);

        return productOptions;
    }

    /**
     * @description Purge product options list based on CPQ_Warranty_Addons__c custom setting
     * @return List<SBQQ__ProductOption__c> purged list
     */
    private List<SBQQ__ProductOption__c> purgeProductOptionsForWarranties(String productCode,List<SBQQ__ProductOption__c> productOptions, Integer dealTerm) {

        System.debug('AutoBundleBuilder, purgeProductOptionsForWarranties, productOptionsToBeCreated prior to purge ' + productOptions);
        System.debug('AutoBundleBuilder, purgeProductOptionsForWarranties productOptionsToBeCreated prior to purge size ' + productOptions.size());
        
        //Query Warranties Addons custom setting
        CPQ_Warranty_Addons__c warrantyConfig = CPQ_Warranty_Addons__c.getOrgDefaults(); 
        List<String> usProgramReagent = warrantyConfig.US_Program_Type_Reagent__c != null ?
            warrantyConfig.US_Program_Type_Reagent__c.split(',') : new List<String> ();
    
        List<String> usProgramCashDeal = warrantyConfig.US_Program_Type_Cash_Deal_Cash_Choice__c != null ?
            warrantyConfig.US_Program_Type_Cash_Deal_Cash_Choice__c.split(',') : new List<String> ();

        List<String> usProgramFinanced = warrantyConfig.US_Program_Type_Choice_Financed__c != null ?
            warrantyConfig.US_Program_Type_Choice_Financed__c.split(',') : new List<String> ();        

        List<String> usExtendedWarrOneYear = warrantyConfig.US_Extended_Warranties_One_Year__c != null ?
            warrantyConfig.US_Extended_Warranties_One_Year__c.split(',') : new List<String> ();        

        List<String> usExtendedWarrTwoYear = warrantyConfig.US_Extended_Warranties_Two_Year__c != null ?
            warrantyConfig.US_Extended_Warranties_Two_Year__c.split(',') : new List<String> ();

        List<String> usExtendedWarrThreeYear = warrantyConfig.US_Extended_Warranties_Three_Year__c != null ?
            warrantyConfig.US_Extended_Warranties_Three_Year__c.split(',') : new List<String> ();

        List<String> usExtendedWarrFourYear = warrantyConfig.US_Extended_Warranties_Four_Year__c != null ?
            warrantyConfig.US_Extended_Warranties_Four_Year__c.split(',') : new List<String> ();

        List<String> usExtendedWarrFiveYear = warrantyConfig.US_Extended_Warranties_Five_Year__c != null ?
            warrantyConfig.US_Extended_Warranties_Five_Year__c.split(',') : new List<String> ();

        
        //Query product1 to populate Map with SAP Product Codes for options
        Set<Id> optionalProdIds = new Set<Id> ();
        Map<Id,String> productSAPNumberMap = new Map<Id,String> ();

        for (SBQQ__ProductOption__c productOption : productOptions) {
            optionalProdIds.add(productOption.SBQQ__OptionalSKU__c);
        }
        
        List<Product2> products = [SELECT Id, SAP_Product_Number__c
                                  FROM Product2
                                  WHERE Id IN :optionalProdIds];

        for (Product2 product : products) {
            productSAPNumberMap.put(product.Id,product.SAP_Product_Number__c);
        }        
        
        /* CPQATG-1291:
        If the offer term is 36 months, do not create product options for deal lines with material numbers that fall into the
            One Year, Three Year, Four Year, and Five Year US Extended Warranties custom setting.
            If the offer term is 72 months, do not create product options for deal lines with material numbers that fall into the
            One Year, Two Year, Three Year, and Four Year US Extended Warranties custom setting.
        If the offer is Type B, Cash Deal/Cash Choice Offer, do not create product options for deal lines with material numbers that fall into the
             One Year, Two Year, Three Year, and Four Year US Extended Warranties custom setting.
        */
        if (usProgramReagent.contains(productCode)) {
            System.debug('AutoBundleBuilder, purgeProductOptionsForWarranties, product code: ' + productCode + ' in custom setting Reagent ' + usProgramReagent);
            System.debug('AutoBundleBuilder, purgeProductOptionsForWarranties, deal term:' + dealTerm);
            for (Integer i = productOptions.size() - 1; i >= 0; i--) {
                if (dealTerm == 36 && ((usExtendedWarrOneYear.contains(productSAPNumberMap.get(productOptions[i].SBQQ__OptionalSKU__c))) ||
                                        (usExtendedWarrThreeYear.contains(productSAPNumberMap.get(productOptions[i].SBQQ__OptionalSKU__c))) ||
                                        (usExtendedWarrFourYear.contains(productSAPNumberMap.get(productOptions[i].SBQQ__OptionalSKU__c))) ||
                                        (usExtendedWarrFiveYear.contains(productSAPNumberMap.get(productOptions[i].SBQQ__OptionalSKU__c))) 
                                    ))
                {
                        productOptions.remove(i);
                }

                System.debug('AutoBundleBuilder, purgeProductOptionsForWarranties, productOption code: ' + productOptions[i].SBQQ__OptionalSKU__c);
                if (dealTerm == 72 && ((usExtendedWarrOneYear.contains(productSAPNumberMap.get(productOptions[i].SBQQ__OptionalSKU__c))) ||
                                        (usExtendedWarrTwoYear.contains(productSAPNumberMap.get(productOptions[i].SBQQ__OptionalSKU__c))) ||
                                        (usExtendedWarrThreeYear.contains(productSAPNumberMap.get(productOptions[i].SBQQ__OptionalSKU__c))) ||
                                        (usExtendedWarrFourYear.contains(productSAPNumberMap.get(productOptions[i].SBQQ__OptionalSKU__c)))
                                    ))
                {
                        productOptions.remove(i);
                }
            }
        }
        if (usProgramCashDeal.contains(productCode)) {
            System.debug('AutoBundleBuilder, purgeProductOptionsForWarranties, product code: ' + productCode + ' in custom setting CashDeal ' + usProgramCashDeal);
            for (Integer i = productOptions.size() - 1; i >= 0; i--) {
                if ((usExtendedWarrOneYear.contains(productSAPNumberMap.get(productOptions[i].SBQQ__OptionalSKU__c))) ||
                    (usExtendedWarrTwoYear.contains(productSAPNumberMap.get(productOptions[i].SBQQ__OptionalSKU__c))) ||
                    (usExtendedWarrThreeYear.contains(productSAPNumberMap.get(productOptions[i].SBQQ__OptionalSKU__c))) ||
                    (usExtendedWarrFourYear.contains(productSAPNumberMap.get(productOptions[i].SBQQ__OptionalSKU__c))))
                {
                        productOptions.remove(i);
                }                
            }
        }

        System.debug('AutoBundleBuilder, purgeProductOptionsForWarranties, productOptionsToBeCreated after purge ' + productOptions);
        System.debug('AutoBundleBuilder, purgeProductOptionsForWarranties productOptionsToBeCreated after purge size ' + productOptions.size());

        return productOptions;

    }

    /**
     * @description Gets the 'Additional Contract Consideration' bundle record.
     * @return Product2 record.
     */
    private List<Product2> getAdditionalContractConsiderationBundle(Boolean cashBack, Boolean competitiveBuyOut, Boolean internalBuyOut, Boolean addConsumbablesAncillaries, Boolean addConsumablesForMarket) {

        List<String> productNamesToBeAdded = new List<String>();
        
        if (cashBack) {
            productNamesToBeAdded.add(this.CASH_BACK_PRODUCT_NAME);
        }
        if (competitiveBuyOut) {
            productNamesToBeAdded.add(this.COMPETITIVE_BUY_OUT_PRODUCT_NAME);
        }
        if (internalBuyOut) {
            productNamesToBeAdded.add(this.INTERNAL_BUY_OUT_PRODUCT_NAME);
        }

        //Always include ITEM FOR ZOETIS DEVICE RETURN as product option
        productNamesToBeAdded.add(this.ITEM_FOR_ZOETIS_DEVICE_RETURN);

        //CPQATG-1328 Include AdditionalConsumableAncillary (dynamic bundle)
        if (addConsumbablesAncillaries && addConsumablesForMarket) {
            productNamesToBeAdded.add(this.ADDITIONAL_CONSUMABLE_ANC_PRODUCT_NAME);
        }

        List<Product2> products = [
            SELECT Id, Name, ProductCode
            FROM Product2
            WHERE Name IN :productNamesToBeAdded AND IsActive = TRUE
        ];

        System.debug('getAdditionalContractConsiderationBundle, products: ' + products);

        if (products.isEmpty()) {
            ErrorLogUtil.log(
                'AutoBundles > There is no active Product2 records with the name ' +
                this.CASH_BACK_PRODUCT_NAME + ' or ' + this.COMPETITIVE_BUY_OUT_PRODUCT_NAME + ' or ' + this.INTERNAL_BUY_OUT_PRODUCT_NAME + ' or ' +
                this.ITEM_FOR_ZOETIS_DEVICE_RETURN + '. Cash Back Internal/External Buyout not be available.',
                new List<String>()
            );
        } else {
            if (products.size() > 5) {
                ErrorLogUtil.log(
                    'AutoBundles > There is more than 5 active Product2 record with the name ' +
                    this.CASH_BACK_PRODUCT_NAME + ' or ' + this.COMPETITIVE_BUY_OUT_PRODUCT_NAME + ' or ' + this.INTERNAL_BUY_OUT_PRODUCT_NAME + ' or ' +
                    this.ITEM_FOR_ZOETIS_DEVICE_RETURN + '. Cash Back Internal/External Buyout not be available.',
                    new List<String>()
                );
                products = new List<Product2> ();
            }
        }

        return products;
    }

    /**
     * @description Gets or creates the nested bundle products.
     */
    @testVisible
    private Map<String, Product2> createOrGetNestedBundleProducts(
        Map<String, String> suffixProductNameMap,
        Map<String, Map<String, String>> suffixProductTranslations
    ) {
        Map<String, String> suffixProductCodes = new Map<String, String>();

        for (String suffix : suffixProductNameMap.keySet()) {
            suffixProductCodes.put(suffix, getNestedBundleProductCode(bundleData.dealNumber, suffix));
        }

        List<Product2> existingProducts = [
            SELECT Id, ProductCode, Name, Lease_Type__c
            FROM Product2
            WHERE ProductCode IN :suffixProductCodes.values()
        ];

        Map<String, Product2> productCodeExistingProductMap = new Map<String, Product2>();
        for (Product2 existingProd : existingProducts) {
            productCodeExistingProductMap.put(existingProd.ProductCode, existingProd);
        }

        Map<String, Product2> suffixProductMap = new Map<String, Product2>();
        Map<String, Product2> suffixProductsToBeCreated = new Map<String, Product2>();

        for (String suffix : suffixProductNameMap.keySet()) {
            String productCode = suffixProductCodes.get(suffix);

            if (productCodeExistingProductMap.containsKey(productCode)) {
                System.debug('AutoBundleBuilder > createOrGetNestedBundleProducts: Existing Nested Bundle - Code: ' + productCode);
                suffixProductMap.put(suffix, productCodeExistingProductMap.get(productCode));
            } else {
                System.debug('AutoBundleBuilder > createOrGetNestedBundleProducts: Creating Nested Bundle - Code: ' + productCode);

                Product2 nestedBundleProd = new Product2(
                    IsActive = true,
                    ProductCode = getNestedBundleProductCode(bundleData.dealNumber, suffix),
                    SBQQ__ConfigurationType__c = 'Required',
                    SBQQ__SubscriptionPricing__c = 'Fixed Price',
                    Name = suffixProductNameMap.get(suffix).abbreviate(100),
                    CPQ_Configured__c = true,
                    SBQQ__Component__c = false,
                    SBQQ__ChargeType__c = 'Recurring',
                    SBQQ__PricingMethod__c = 'List',
                    SBQQ__SubscriptionType__c = null,
                    SBQQ__SubscriptionPercent__c = null,
                    SBQQ__AssetConversion__c = null,
                    SBQQ__AssetAmendmentBehavior__c = null,
                    SBQQ__BillingFrequency__c = 'Monthly',
                    SBQQ__BillingType__c = 'Advance',
                    SBQQ__QuantityEditable__c = false,
                    Lease_Type__c = this.bundleData.bundleParent.Lease_Type__c
                );

                suffixProductsToBeCreated.put(suffix, nestedBundleProd);

                // Register translations for the bundle
                translationHelper.addTranslations(nestedBundleProd, suffixProductTranslations.get(suffix));
                System.debug('AutoBundleBuilder > Adding nestedProd translations: ' + suffixProductTranslations.get(suffix));
            }
        }

        // Create the products
        insert suffixProductsToBeCreated.values();

        // Add the product ids just created to the Set for creating the PBEs
        for (Product2 product : suffixProductsToBeCreated.values()) {
            productIdsForCreatePBEs.add(product.Id);
        }

        suffixProductMap.putAll(suffixProductsToBeCreated);
        return suffixProductMap;
    }

    private static String getNestedBundleProductCode(String dealNumber, String suffix) {
        return String.format('{0}-{1}', new List<String>{ dealNumber, suffix });
    }
}