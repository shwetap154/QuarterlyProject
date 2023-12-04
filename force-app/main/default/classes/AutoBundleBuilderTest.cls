/**
* File Name     :  AutoBundleBuilderTest
* @description  :  Test coverage for AutoBundleBuilder
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     1/10/2020		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/5/2020		Cory Bartholomew @ ATG     Added descriptions.
**/

@isTest
public class AutoBundleBuilderTest {
    private static final String AGGREGATE_COMMITMENT_MATERIAL_NUMBER = '000000000060000555';

    @testSetup
	public static void setup() {

        // Create Markets and Market Countries 
        List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
        CPQ_TestDataFactory.createMarketCountrys(markets, true);

        // Get US market
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        usMarket.Price_Book__c = CPQ_TestDataFactory.createPricebook('US Pricebook', '1436', true).Id;
        usMarket.Add_Consumables_Ancillaries_Available__c = true;

        update usMarket;

		// Create SAP materials
		List<SAP_Material__c> materials = new List<SAP_Material__c> {
        	CPQ_TestDataFactory.createSAPMaterial('VL', '000000000060000040', 'Z006', 'ZFER', '', false), // Device
			CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000041', 'NORM', 'DIEN', '', false), // Consumable
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000042', 'NORM', 'DIEN', '', false), // Consumable
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000043', 'NORM', 'DIEN', '', false), // Consumable
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000045', 'ZANC', 'ZHYB', '', false), // Ancillary
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000046', 'ZIEN', 'ZNBW', '', false), // Standard warranty
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000047', 'DIEN', 'ZNBW', '', false),  // Extended warranty
            CPQ_TestDataFactory.createSAPMaterial('VL', '000000000060000050', 'Z006', 'ZFER', '', false), // Device
            CPQ_TestDataFactory.createSAPMaterial('EA', AGGREGATE_COMMITMENT_MATERIAL_NUMBER, 'Z011', 'DIEN', '', false) // Aggregate Commitment Material
		};
		insert materials;

        // Create flexible groups
        insert new List<Flexible_Group__c> {
            CPQ_TestDataFactory.createFlexibleGroup('00001111', 'ZFLX', false),
            CPQ_TestDataFactory.createFlexibleGroup('00002222', 'ZFLX', false)
        };

        insert new List<Flexible_Group_Item__c> {
            // Flexible Group: 00001111
            CPQ_TestDataFactory.createFlexibleGroupItem('00001111', '000001', '000000000060000041', false),
            CPQ_TestDataFactory.createFlexibleGroupItem('00001111', '000002', '000000000060000042', false),
            CPQ_TestDataFactory.createFlexibleGroupItem('00002222', '000003', '000000000060000040', false),
            CPQ_TestDataFactory.createFlexibleGroupItem('00002222', '000004', '000000000060000050', false)
        };

        // Create Products for materials
        List<Product2> products = new List<Product2>();
        for (SAP_Material__c material : materials) {
            products.add(CPQ_TestDataFactory.createProduct(material, false));
        }
        insert products;

        // Create bundle header
        Vistex_Deal_Header__c dealHeader = CPQ_TestDataFactory.createVistexDealHeader('000001234', '1436', true);

        // Create deal lines
        List<Vistex_Deal_Line_E1KOMG__c> dealLines = new List<Vistex_Deal_Line_E1KOMG__c> {

            // Device Group 1 with Consumables and Warranties
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZDEV', '000000000060000040', 'S1', false), // Device Line
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZCON', '000000000060000041', 'S1', false), // Consumable Line
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZCON', '000000000060000042', 'S1', false), // Consumable Line
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZCON', '000000000060000047', 'S1', false), // Consumable Line / Warranty

            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZCON', '000000000060000047', 'S1', false), // Consumable Line / Warranty

            // No group ancillary
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZANC', '000000000060000045', null, false), // Ancillary Line

            // Device group 2 with Consumables
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZDEV', '000000000060000050', 'S2', false), // Device Line
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZCON', '000000000060000043', 'S2', false),  // Consumable Line

            CPQ_TestDataFactory.createVistexDealLine_FlexibleGroup(dealHeader, 'ZCON', '00001111', 'S1', false), // Aggregate commitment
            CPQ_TestDataFactory.createVistexDealLine_FlexibleGroup(dealHeader, 'ZCON', '00001111', 'S2', false), // Rebate consumables
            CPQ_TestDataFactory.createVistexDealLine_FlexibleGroup(dealHeader, 'ZDEV', '00002222', null, false) // Device flexible groups
        };
        insert dealLines;
        
        // Create deal lines condition headers
        List<Condition_Header_E1KONH__c> dealLineConditions = new List<Condition_Header_E1KONH__c>();
        for(Vistex_Deal_Line_E1KOMG__c dealLine : dealLines) {
            dealLineConditions.add(CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLine, false));
        }
        insert dealLineConditions;

        // Create deal lines child conditions
        List<Vistex_ZO2C_E1KONP_CPQ__c> dealLineConditionChilds = new List<Vistex_ZO2C_E1KONP_CPQ__c> {
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[0], null, null, null, null, null, false),
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[1], null, 1200, 12, null, '03', false), // Specific Value Commitment - Ship by: Co-Sourced
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[2], 48, null, 24, 'EA', '02',false), // Specific Quantity Commitment - Ship by: Distributor
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[3], null, null, null, null, null, false),
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[4], null, null, null, null, '01',false), // Ship by: Zoetis

            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[5], null, null, null, null, null, false),
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[6], null, null, null, null, null, false),
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[7], null, null, null, null, null, false),

            // Quantity Commitment - Qty: 48 EA - Term: 12
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[8], 48, null, 12, 'EA', '01', false), // Aggregate commitment
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[9], null, null, null, null, '01', false), // Rebate
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[10], null, null, null, null, '01', false) // Devices
        };
        insert dealLineConditionChilds;
    }

    private static Vistex_Deal_Header__c queryDeal() {

        return [SELECT Id, Name, BOART_AG__c, Commitment_Indicator__c,
                    CURRENCY__c, DEALK01_Ext_Id__c, DEALNUM__c, DEALNUM_EXT__c, DEALTXT__c,
                    ORGID__c, QULAF__c, Transaction_Type_CPQ__c, VALID_FROM__c, VALID_TO__c, CPQ_Transaction_Type_Text__c, Is_Third_Party_Lease_Default__c,Add_Cash_Back_Bundle__c,Add_Competitive_Buy_Out_Bundle__c,Add_Internal_Buy_Out_Bundle__c,Add_Consumables_Ancillaries_Available__c,
                    (SELECT Id, Name, DEALK01_Ext_Id__c, LOEVM_KO__c, E1KOMG_Ext_Id__c, EBONU__c, EKKOA__c, KOTBNR__c, KSCHL__c, LIFNR__c, MATNR__c, VAKEY__c,DEALK01_Ext_Id__r.ORGID__c
                        FROM Vistex_Deal_Line__r),
                    (SELECT Id FROM BundleWrapperProducts__r )
                FROM Vistex_Deal_Header__c LIMIT 1];
    }

    private static Map<Id,Condition_Header_E1KONH__c> queryDealLineConditions() {

        List<Condition_Header_E1KONH__c> conditionsList = [SELECT Id, DATAB__c, DATBI__c, KNUMA_AG__c, KNUMH__c, E1KOMG_Ext_Id__c,
                                                            (
                                                                SELECT Id, Ship_By__c, ZCOMMIT_QTY__c, ZCOMMIT_TERM__c,
                                                                    ZCOMMIT_VALUE__c, ZCOMMITQTY_UOM__c,Commitment_Change_Approval_Required__c,Aggregate_Commitment_Type__c
                                                                FROM Vistex_ZO2C_E1KONP_CPQ__r
                                                            )
                                                            FROM Condition_Header_E1KONH__c];

        Map<Id, Condition_Header_E1KONH__c> dealLineConditionsMap = new Map<Id, Condition_Header_E1KONH__c>();

        for (Condition_Header_E1KONH__c cond : conditionsList) {
            dealLineConditionsMap.put(cond.E1KOMG_Ext_Id__c, cond);
        }

        return dealLineConditionsMap;
    }

    /**
     * @description Method to query products with matching SAP Material Numbers
     */
    private static Map<String, Product2> queryProducts(Set<String> sapProductNumbers) {

        List<Product2> products = [SELECT Id, Name, SAP_Product_Number__c, CPQ_Material_Type__c, CPQ_Material_Type_Group__c
                                   FROM Product2
                                   WHERE SAP_Product_Number__c IN :sapProductNumbers];

        Map<String, Product2> productMap = new Map<String, Product2>();

        for(Product2 prod : products) {
            productMap.put(prod.SAP_Product_Number__c, prod);
        }

        return productMap;
    }


    @istest
    public static void getProductFeatures_ExplicitGrouping_Test() {
        // Query deal
        Vistex_Deal_Header__c deal = queryDeal();

        AutoBundleDataCollector collector = new AutoBundleDataCollector(deal);
        AutoBundleDataWrapper dataWrapper = collector.collectDealBundleData();

        AutoBundleBuilder builder = new AutoBundleBuilder(dataWrapper);

        Test.startTest();
        builder.createBundle();
        Test.stopTest();

        // Query bundle structure products (not realted to SAP Materials)
        List<Product2> bundleProducts = [SELECT Id FROM Product2 WHERE SAP_Material__c = NULL];

        // We're expecting 4: 1 parent bundle, and 3 nested bundles.
        System.assertEquals(4, bundleProducts.size());
    }

    @isTest static void testAutobundleBatchableExistingBundle(){
        
       // CPQBundleUpdates__c setting = new CPQBundleUpdates__c();
       // setting.isEnableBundleUpdate__c = true;        
      //  insert setting;      

        Product2 existingProduct = CPQ_TestDataFactory.createProduct(null, false);
        existingProduct.ProductCode = '000001234';
        insert existingProduct;

        Vistex_Deal_Header__c deal = queryDeal();

        AutoBundleDataCollector collector = new AutoBundleDataCollector(deal);
        AutoBundleDataWrapper dataWrapper = collector.collectDealBundleData();

        SBQQ__ProductFeature__c productFeature = 
        new SBQQ__ProductFeature__c(
            Name = 'test',
            SBQQ__ConfiguredSKU__c = existingProduct.Id,
            SBQQ__MinOptionCount__c = 0,
            SBQQ__Number__c = 99999, // It shoud be the last in the list
            Unique_Key__c = 'test'
        );
        insert productFeature;

        Product2 childProd = [SELECT Id, ProductCode FROM Product2 WHERE SAP_Material__c != NULL LIMIT 1];

        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c (
                    SBQQ__ConfiguredSKU__c = existingProduct.Id,
                    SBQQ__OptionalSKU__c = childProd.Id,
                    SBQQ__Number__c = 100,
                    SBQQ__Quantity__c = 1,
                    SBQQ__QuantityEditable__c = true,
                    SBQQ__Required__c = false,
                    SBQQ__Selected__c = true,
                    SBQQ__Type__c = 'Related Product',
                    Unique_Key__c = existingProduct.ProductCode + '-' + childProd.ProductCode
                );
        insert productOption;

        AutoBundleBuilder builder = new AutoBundleBuilder(dataWrapper);

        Test.startTest();
        builder.createBundle();
        Test.stopTest();        
  
    }

    @istest
    public static void testNonNestedBundle() {
        
        List<Vistex_Deal_Line_E1KOMG__c> dealLinesToDelete = [SELECT Id FROM Vistex_Deal_Line_E1KOMG__c WHERE EBONU__c != 'S1'];
        delete dealLinesToDelete;
        
        // Query deal
        Vistex_Deal_Header__c deal = queryDeal();

        AutoBundleDataCollector collector = new AutoBundleDataCollector(deal);
        AutoBundleDataWrapper dataWrapper = collector.collectDealBundleData();

        AutoBundleBuilder builder = new AutoBundleBuilder(dataWrapper);

        Test.startTest();
        builder.createBundle();
        Test.stopTest();
        
    }

    @istest
    public static void testAddingAdditionalBundles() {
        
        List<Vistex_Deal_Line_E1KOMG__c> dealLinesToDelete = [SELECT Id FROM Vistex_Deal_Line_E1KOMG__c WHERE EBONU__c != 'S1'];
        delete dealLinesToDelete;
        
        // Query deal
        Vistex_Deal_Header__c deal = queryDeal();
        deal.Add_Cash_Back_Bundle__c = true;
        deal.Add_Consumables_Ancillaries_Available__c = true;

        update deal;

        Product2 cashBack = CPQ_TestDataFactory.createProduct(null, false);
        cashBack.Name = 'Cash Back';
        insert cashBack;

        Product2 additionalProd = CPQ_TestDataFactory.createProduct(null, false);
        additionalProd.Name = 'Additional Consumables/Ancillaries for Initial Shipment';
        insert additionalProd;
        


        AutoBundleDataCollector collector = new AutoBundleDataCollector(deal);
        AutoBundleDataWrapper dataWrapper = collector.collectDealBundleData();

        AutoBundleBuilder builder = new AutoBundleBuilder(dataWrapper);

        Test.startTest();
        builder.createBundle();
        Test.stopTest();
        
    }

}