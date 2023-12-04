/**************************************************************************************************
* File Name     :   AutoBundleMaterialLineWrapperTest 
* Description   :   Test class for AutoBundleMaterialLineWrapper
* @author       :   Cesar Sandrigo
* Modification Log
===================================================================================================
* Ver.  Date       Author              Modification
*--------------------------------------------------------------------------------------------------
* 1.0   01/09/20   Cesar Sandrigo      Created the class. Added tests. Coverage 90%
**************************************************************************************************/
@istest
public class AutoBundleProductFeatureHelperTest {

    private static final String AGGREGATE_COMMITMENT_MATERIAL_NUMBER = '000000000060000555';

    @testSetup
	public static void setup() { 

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


    @istest
    public static void getProductFeatures_ExplicitGrouping_Test() {
        // Query deal
        Vistex_Deal_Header__c deal = queryDeal();
        
        // Query deal line conditions and child objecs
        Map<Id,Condition_Header_E1KONH__c> dealLineConditionMap = queryDealLineConditions();

        Set<String> materialNumberSet = new Set<String> { '000000000060000040', '000000000060000041', '000000000060000042', '000000000060000047', 
                                                            '000000000060000045', '000000000060000050', '000000000060000043' };
        // Query products
        Map<String, Product2> relatedProducts = queryProducts(materialNumberSet);

        Map<String, List<Product2>> flexGroupProducts = new Map<String, List<Product2>>();
        flexGroupProducts.put('00001111', new List<Product2>{ relatedProducts.get('000000000060000041'), relatedProducts.get('000000000060000041')});
        flexGroupProducts.put('00002222', new List<Product2>{ relatedProducts.get('000000000060000040'), relatedProducts.get('000000000060000050')});

        // Create a generic product for simulate parent bundle
        Product2 parentBundle = CPQ_TestDataFactory.createProduct(true);

        // Build deal lines based on deal lines and conditions
        List<AutoBundleDealLineWrapper> dealLines = new List<AutoBundleDealLineWrapper>();

        for (Vistex_Deal_Line_E1KOMG__c dealLine : deal.Vistex_Deal_Line__r) {
            Condition_Header_E1KONH__c dealLineCondition = dealLineConditionMap.get(dealLine.Id);

            if (!String.isBlank(dealLine.MATNR__c)) {
                dealLines.add(new AutoBundleMaterialLineWrapper(dealLine, dealLineCondition, relatedProducts.get(dealLine.MATNR__c)));
            }
            else {
                dealLines.add(new AutoBundleFlexibleGroupLineWrapper(dealLine, dealLineCondition, flexGroupProducts.get(dealLine.LIFNR__c)));
            }
        }

        Test.startTest();

        // Create AutoBundleProductFeatureHelper instance
        AutoBundleProductFeatureHelper featureHelper = new AutoBundleProductFeatureHelper(parentBundle, dealLines);
        List<FeatureOptionsGroup> featureOptionsGroupList = featureHelper.getProductFeatures();

        Test.stopTest();

        // 3 Features are expected: Device Group 1, Device Group 2, Ancillary
        System.assertEquals(6, featureOptionsGroupList.size());
    }


    @istest
    public static void getProductFeatures_NoGrouping_Test() {

        // Clear suffixes in deal lines to similate no explicit grouping
        List<Vistex_Deal_Line_E1KOMG__c> lines = [SELECT Id, EBONU__c FROM Vistex_Deal_Line_E1KOMG__c];
        for (Vistex_Deal_Line_E1KOMG__c line : lines) {
            line.EBONU__c = null;
        }
        update lines;

        // Query deal
        Vistex_Deal_Header__c deal = queryDeal();
        
        // Query deal line conditions and child objecs
        Map<Id,Condition_Header_E1KONH__c> dealLineConditionMap = queryDealLineConditions();

        Set<String> materialNumberSet = new Set<String> { '000000000060000040', '000000000060000041', '000000000060000042', '000000000060000047', 
                                                            '000000000060000045', '000000000060000050', '000000000060000043' };

        // Query products
        Map<String, Product2> relatedProducts = queryProducts(materialNumberSet);

        Map<String, List<Product2>> flexGroupProducts = new Map<String, List<Product2>>();
        flexGroupProducts.put('00001111', new List<Product2>{ relatedProducts.get('000000000060000041'), relatedProducts.get('000000000060000041')});
        flexGroupProducts.put('00002222', new List<Product2>{ relatedProducts.get('000000000060000040'), relatedProducts.get('000000000060000050')});

        // Create a generic product for simulate parent bundle
        Product2 parentBundle = CPQ_TestDataFactory.createProduct(true);

        // Build deal lines based on deal lines and conditions
        List<AutoBundleDealLineWrapper> dealLines = new List<AutoBundleDealLineWrapper>();

        for (Vistex_Deal_Line_E1KOMG__c dealLine : deal.Vistex_Deal_Line__r) {
            Condition_Header_E1KONH__c dealLineCondition = dealLineConditionMap.get(dealLine.Id);

            if (!String.isBlank(dealLine.MATNR__c)) {
                dealLines.add(new AutoBundleMaterialLineWrapper(dealLine, dealLineCondition, relatedProducts.get(dealLine.MATNR__c)));
            }
            else {
                dealLines.add(new AutoBundleFlexibleGroupLineWrapper(dealLine, dealLineCondition, flexGroupProducts.get(dealLine.LIFNR__c)));
            }
        }

        Test.startTest();

        // Create AutoBundleProductFeatureHelper instance
        AutoBundleProductFeatureHelper featureHelper = new AutoBundleProductFeatureHelper(parentBundle, dealLines);
        List<FeatureOptionsGroup> featureOptionsGroupList = featureHelper.getProductFeatures();

        Test.stopTest();

        //4 Features are expected: Devices, Consumables, Warranties and Ancillary
        System.assertEquals(7, featureOptionsGroupList.size());
    }


    private static Vistex_Deal_Header__c queryDeal() {

        return [SELECT Id, Name, BOART_AG__c, 
                    CURRENCY__c, DEALK01_Ext_Id__c, DEALNUM__c, DEALNUM_EXT__c, DEALTXT__c,
                    ORGID__c, QULAF__c, Transaction_Type_CPQ__c, VALID_FROM__c, VALID_TO__c,Is_Third_Party_Lease_Default__c,
                    (SELECT Id, Name, DEALK01_Ext_Id__c, LOEVM_KO__c, E1KOMG_Ext_Id__c, EBONU__c, EKKOA__c, KOTBNR__c, KSCHL__c, LIFNR__c, MATNR__c, VAKEY__c,
                    DEALK01_Ext_Id__r.ORGID__c
                        FROM Vistex_Deal_Line__r)
                FROM Vistex_Deal_Header__c LIMIT 1];
    }

    private static Map<Id,Condition_Header_E1KONH__c> queryDealLineConditions() {

        List<Condition_Header_E1KONH__c> conditionsList = [SELECT Id, DATAB__c, DATBI__c, KNUMA_AG__c, KNUMH__c, E1KOMG_Ext_Id__c,
                                                            (
                                                                SELECT Id, Ship_By__c, ZCOMMIT_QTY__c, ZCOMMIT_TERM__c,
                                                                    ZCOMMIT_VALUE__c, ZCOMMITQTY_UOM__c, Aggregate_Commitment_Type__c,Commitment_Change_Approval_Required__c
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

}