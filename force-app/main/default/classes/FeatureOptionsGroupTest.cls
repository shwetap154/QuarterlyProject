/**************************************************************************************************
* File Name     :   FeatureOptionsGroupTest 
* Description   :   Class that represents the grouping between the CPQ Product Features and Product
                    Options. This is part of the Automatic Bundle creation framework.
* @author       :   Cesar Sandrigo
* Modification Log
===================================================================================================
* Ver.  Date       Author              Modification
*--------------------------------------------------------------------------------------------------
* 1.0   11/15/19   Cesar Sandrigo      Created the class. Added tests. Coverage: 92%
**************************************************************************************************/
@isTest
public class FeatureOptionsGroupTest {
    private static final String AGGREGATE_COMMITMENT_MATERIAL_NUMBER = '000000000060000555';

    @testSetup
	public static void setup() { 

		// Create SAP materials
		List<SAP_Material__c> materials = new List<SAP_Material__c> {
        	CPQ_TestDataFactory.createSAPMaterial('VL', '000000000060000040', 'Z006', 'ZFER', '', false), // Device
			CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000041', 'NORM', 'DIEN', '', false), // Consumable
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000042', 'NORM', 'DIEN', '', false) // Consumable
		};
		insert materials;

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
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZDEV', '000000000060000040', null, false), // Device Line
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZCON', '000000000060000041', null, false), // Consumable Line
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZCON', '000000000060000042', null, false) // Consumable Line
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
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[2], 48, null, 24, 'EA', '02',false) // Specific Quantity Commitment - Ship by: Distributor
        };
        insert dealLineConditionChilds;
    }


    @istest
    public static void getProductFeature_getProductOption_Test() {
        // Query deal
        Vistex_Deal_Header__c deal = queryDeal();
        
        // Query deal line conditions and child objecs
        Map<Id,Condition_Header_E1KONH__c> dealLineConditionMap = queryDealLineConditions();

        Set<String> materialNumberSet = new Set<String> { '000000000060000040', '000000000060000041', '000000000060000042' };
        // Query products
        Map<String, Product2> relatedProducts = queryProducts(materialNumberSet);

        // Create a generic product for simulate parent bundle
        Product2 parentBundle = CPQ_TestDataFactory.createProduct(true);

        // Build deal lines based on deal lines and conditions
        List<AutoBundleDealLineWrapper> dealLines = new List<AutoBundleDealLineWrapper>();

        for (Vistex_Deal_Line_E1KOMG__c dealLine : deal.Vistex_Deal_Line__r) {
            Condition_Header_E1KONH__c dealLineCondition = dealLineConditionMap.get(dealLine.Id);
            dealLines.add(new AutoBundleMaterialLineWrapper(dealLine, dealLineCondition, relatedProducts.get(dealLine.MATNR__c)));
        }

        Test.startTest();

        // Create AutoBundleProductFeatureHelper instance
        AutoBundleProductFeatureHelper featureHelper = new AutoBundleProductFeatureHelper(parentBundle, dealLines);
        List<FeatureOptionsGroup> featureOptionsGroupList = featureHelper.getProductFeatures();

        Test.stopTest();

        // 2 Features are expected: Devices and Consumables
        System.assertEquals(2, featureOptionsGroupList.size());

        // 'Devices'
        System.assertEquals('Devices', featureOptionsGroupList[0].Name);
        System.assertEquals(false, featureOptionsGroupList[0].isEmpty());
        System.assertEquals(true, featureOptionsGroupList[0].hasLines());
        SBQQ__ProductFeature__c devicesFeature = featureOptionsGroupList[0].getProductFeature(null,'test');
        System.assert(devicesFeature != null);
        System.assertEquals('Devices', devicesFeature.Name);
        System.assertEquals(parentBundle.Id, devicesFeature.SBQQ__ConfiguredSKU__c);
        System.assertEquals(1,  featureOptionsGroupList[0].getProductOptions(null).size());
        System.assertEquals('test-Devices', devicesFeature.Unique_Key__c);
    
        // 'Consumables'
        System.assertEquals('Consumables', featureOptionsGroupList[1].Name);
        System.assertEquals(false, featureOptionsGroupList[1].isEmpty());
        System.assertEquals(true, featureOptionsGroupList[1].hasLines());
        SBQQ__ProductFeature__c consumablesFeature = featureOptionsGroupList[1].getProductFeature(null,'test2');
        System.assert(consumablesFeature != null);
        System.assertEquals('Consumables', consumablesFeature.Name);
        System.assertEquals(parentBundle.Id, consumablesFeature.SBQQ__ConfiguredSKU__c);
        System.assertEquals(2,  featureOptionsGroupList[1].getProductOptions(null).size());
        System.assertEquals('test2-Consumables', consumablesFeature.Unique_Key__c);

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
                                                                    ZCOMMIT_VALUE__c, ZCOMMITQTY_UOM__c,Aggregate_Commitment_Type__c,Commitment_Change_Approval_Required__c
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

        List<Product2> products = [SELECT Id, SAP_Product_Number__c, CPQ_Material_Type__c, CPQ_Material_Type_Group__c, ProductCode
                                   FROM Product2
                                   WHERE SAP_Product_Number__c IN :sapProductNumbers];

        Map<String, Product2> productMap = new Map<String, Product2>();

        for(Product2 prod : products) {
            productMap.put(prod.SAP_Product_Number__c, prod);
        }

        return productMap;
    }
}