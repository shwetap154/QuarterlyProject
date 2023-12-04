/**************************************************************************************************
* File Name     :   AutoBundleMaterialLineWrapperTest 
* Description   :   Test class for AutoBundleMaterialLineWrapper
* @author       :   Cesar Sandrigo
* Modification Log
===================================================================================================
* Ver.  Date       Author              Modification
*--------------------------------------------------------------------------------------------------
* 1.0   11/11/19   Cesar Sandrigo      Created the class. Added tests. Coverage: 100%
**************************************************************************************************/
@istest
public class AutoBundleMaterialLineWrapperTest {
    
    @testSetup
	public static void setup() { 

		// Create SAP materials
		List<SAP_Material__c> materials = new List<SAP_Material__c> {
        	CPQ_TestDataFactory.createSAPMaterial('VL', '000000000060000040', 'Z006', 'ZFER', '', false), // Device
			CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000041', 'NORM', 'DIEN', '', false), // Consumable
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000042', 'NORM', 'DIEN', '', false), // Consumable
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000043', 'NORM', 'DIEN', '', false), // Consumable
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000555', 'Z011', 'DIEN', '', false), // Aggregate Commitment Material
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000045', 'ZANC', 'ZHYB', '', false), // Ancillary
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000046', 'ZIEN', 'ZNBW', '', false), // Standard warranty
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000047', 'DIEN', 'ZNBW', '', false)  // Extended warranty
		};
		insert materials;

        // Create Products for materials
        List<Product2> products = new List<Product2>();
        for (SAP_Material__c material : materials) {
            products.add(CPQ_TestDataFactory.createProduct(material, false));
        }
        insert products;

        // Create FR localization record for the Device Product
        CPQ_TestDataFactory.createProductNameLocalization(products[0], 'fr', 'French Name', true);

        // Create bundle header
        Vistex_Deal_Header__c dealHeader = CPQ_TestDataFactory.createVistexDealHeader('000001234', '1436', true);

        // Create deal lines
        List<Vistex_Deal_Line_E1KOMG__c> dealLines = new List<Vistex_Deal_Line_E1KOMG__c> {
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZDEV', '000000000060000040', 'S1', false), // Device Line
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZCON', '000000000060000041', 'S1', false), // Consumable Line
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZCON', '000000000060000042', 'S1', false), // Consumable Line
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZCON', '000000000060000047', 'S1', false), // Consumable Line / Warranty
            CPQ_TestDataFactory.createVistexDealLine_Material(dealHeader, 'ZANC', '000000000060000045', 'S1', false) // Ancillary Line
        };
        insert dealLines;
        
        // Create deal lines condition headers
        List<Condition_Header_E1KONH__c> dealLineConditions = new List<Condition_Header_E1KONH__c> {
            CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLines[0], false),
            CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLines[1], false),
            CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLines[2], false),
            CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLines[3], false),
            CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLines[4], false)
        };
        insert dealLineConditions;

        // Create deal lines child conditions
        List<Vistex_ZO2C_E1KONP_CPQ__c> dealLineConditionChilds = new List<Vistex_ZO2C_E1KONP_CPQ__c> {
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[0], null, null, null, null, null, false),
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[1], null, 1200, 12, null, '03', false), // Specific Value Commitment - Ship by: Co-Sourced
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[2], 48, null, 24, 'EA', '02',false), // Specific Quantity Commitment - Ship by: Distributor
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[3], null, null, null, null, null, false),
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[4], null, null, null, null, '01',false) // Ship by: Zoetis
        };
        insert dealLineConditionChilds;
    }

    @istest
    public static void testProperties_and_methods() {
        // Query deal
        Vistex_Deal_Header__c deal = queryDeal();
        
        // Query deal line conditions and child objecs
        Map<Id,Condition_Header_E1KONH__c> dealLineConditionMap = queryDealLineConditions();

        Set<String> materialNumberSet = new Set<String> { '000000000060000040', '000000000060000041', '000000000060000042', '000000000060000047', '000000000060000045' };

        // Query products
        Map<String, Product2> relatedProducts = queryProducts(materialNumberSet);

        // Create a generic product for simulate parent bundle
        Product2 parentBundle = CPQ_TestDataFactory.createProduct(true);
        
        for (Vistex_Deal_Line_E1KOMG__c dealLine : deal.Vistex_Deal_Line__r) {

            Condition_Header_E1KONH__c dealLineCondition = dealLineConditionMap.get(dealLine.Id);

            AutoBundleMaterialLineWrapper materialLineWrapper = new AutoBundleMaterialLineWrapper(dealLine, dealLineCondition, relatedProducts.get(dealLine.MATNR__c));

            // AutoBundleDealLineWrapper generic properties
            System.assertEquals(dealLine.KSCHL__c, materialLineWrapper.LineType);
            System.assertEquals('S1', materialLineWrapper.Suffix);

            // Quantity Specific commitment
            if (!dealLineCondition.Vistex_ZO2C_E1KONP_CPQ__r.isEmpty() && dealLineCondition.Vistex_ZO2C_E1KONP_CPQ__r[0].ZCOMMIT_QTY__c  != null) {
                System.assertEquals(48, materialLineWrapper.CommitmentQuantity);
                System.assertEquals('EA', materialLineWrapper.CommitmentQuantityUnitOfMeasure);
                System.assertEquals(null, materialLineWrapper.CommitmentValue);
                System.assertEquals('24', materialLineWrapper.CommitmentTerm);

                System.assertEquals(true, materialLineWrapper.IsSpecificCommitment);
                System.assertEquals(false, materialLineWrapper.IsSpecificValueCommitment);
                System.assertEquals(true, materialLineWrapper.IsSpecificQuantityCommitment);

                System.assertEquals('Consumable', materialLineWrapper.MaterialType);
                System.assertEquals('Distributor', materialLineWrapper.Supplier);
            }
            // Value Specific Commitment
            else if (!dealLineCondition.Vistex_ZO2C_E1KONP_CPQ__r.isEmpty() && dealLineCondition.Vistex_ZO2C_E1KONP_CPQ__r[0].ZCOMMIT_VALUE__c  != null) {
                System.assertEquals(null, materialLineWrapper.CommitmentQuantity);
                System.assertEquals(null, materialLineWrapper.CommitmentQuantityUnitOfMeasure);
                System.assertEquals(1200, materialLineWrapper.CommitmentValue);
                System.assertEquals('12', materialLineWrapper.CommitmentTerm);

                System.assertEquals(true, materialLineWrapper.IsSpecificCommitment);
                System.assertEquals(true, materialLineWrapper.IsSpecificValueCommitment);
                System.assertEquals(false, materialLineWrapper.IsSpecificQuantityCommitment);

                System.assertEquals('Consumable', materialLineWrapper.MaterialType);
                System.assertEquals('Co-Sourced', materialLineWrapper.Supplier);
            }
            // No commitment
            else {
                System.assertEquals(false, materialLineWrapper.IsSpecificCommitment);
                System.assertEquals(false, materialLineWrapper.IsSpecificValueCommitment);
                System.assertEquals(false, materialLineWrapper.IsSpecificQuantityCommitment);
                System.assertEquals('Zoetis', materialLineWrapper.Supplier);
            }

            // Check product translations
            if (materialLineWrapper.MaterialNumber == '000000000060000040') {
                System.assertEquals(1, materialLineWrapper.TranslatedProductName.size()); // Expecting to have the french translations here
                System.assert(materialLineWrapper.TranslatedProductName.containsKey('fr'));
                System.assertEquals('French Name', materialLineWrapper.TranslatedProductName.get('fr'));
            }
            else {
                System.assertEquals(0, materialLineWrapper.TranslatedProductName.size());
            }
            
            // Get the related product option
            List<SBQQ__ProductOption__c> productOptions = materialLineWrapper.getRelatedProductOptions(parentBundle, 1);
            System.assertEquals(1, productOptions.size());

            SBQQ__ProductOption__c prodOption = productOptions[0];
            
            // Generic options
            System.assertEquals(parentBundle.Id, prodOption.SBQQ__ConfiguredSKU__c);
            System.assertEquals(1, prodOption.SBQQ__Quantity__c);
            System.assertEquals('S1', prodOption.Deal_Line_Group__c);
            System.assertEquals(null, prodOption.Flexible_Group__c);
            System.assertEquals(false, prodOption.Rebate_Consumable__c);

            if (materialLineWrapper.MaterialNumber == '000000000060000041') {  // Specific Value Commitment
                System.assertEquals(null, prodOption.CPQ_Commitment_Quantity__c);
                System.assertEquals(1200, prodOption.CPQ_Commitment_Value__c);
                System.assertEquals(true, prodOption.Specific_Commitment__c);
                System.assertEquals(null, prodOption.Commitment_UOM__c);
                System.assertEquals(null, prodOption.Lease_Type__c);
                System.assertEquals('Co-Sourced', prodOption.Supplier__c);
            }
            else if (materialLineWrapper.MaterialNumber == '000000000060000042') { // Specific Quantity Commitment
                System.assertEquals(48, prodOption.CPQ_Commitment_Quantity__c);
                System.assertEquals(null, prodOption.CPQ_Commitment_Value__c);
                System.assertEquals(true, prodOption.Specific_Commitment__c);
                System.assertEquals('EA', prodOption.Commitment_UOM__c);
                System.assertEquals(null, prodOption.Lease_Type__c);
                System.assertEquals('Distributor', prodOption.Supplier__c);
            }
            else {
                System.assertEquals(null, prodOption.CPQ_Commitment_Quantity__c);
                System.assertEquals(null, prodOption.CPQ_Commitment_Value__c);
                System.assertEquals(false, prodOption.Specific_Commitment__c);
                System.assertEquals(null, prodOption.Commitment_UOM__c);
                System.assertEquals(null, prodOption.Lease_Type__c);
                System.assertEquals('Zoetis', prodOption.Supplier__c);
            }
        }
    }

    @istest
    public static void testConstructorValidations() {

        // Query deal
        Vistex_Deal_Header__c deal = queryDeal();
        
        // Query deal line conditions and child objecs
        Map<Id,Condition_Header_E1KONH__c> dealLineConditionMap = queryDealLineConditions();

        Set<String> materialNumberSet = new Set<String> { '000000000060000040', '000000000060000041', '000000000060000042', '000000000060000047', '000000000060000045' };

        // Query products
        Map<String, Product2> relatedProducts = queryProducts(materialNumberSet);

        // Create a generic product for simulate parent bundle
        Product2 parentBundle = CPQ_TestDataFactory.createProduct(true);
        
        // Get the first deal line
        Vistex_Deal_Line_E1KOMG__c dealLine = deal.Vistex_Deal_Line__r[0];

        // Get the deal line condition
        Condition_Header_E1KONH__c dealLineCondition = dealLineConditionMap.get(dealLine.Id);

        AutoBundleMaterialLineWrapper materialLineWrapper;
        
        // Check no error is logged when everything is OK
        materialLineWrapper = new AutoBundleMaterialLineWrapper(dealLine, dealLineCondition, relatedProducts.get(dealLine.MATNR__c));
        System.assert(materialLineWrapper.validationResults.isEmpty());

        materialLineWrapper = new AutoBundleMaterialLineWrapper(null, dealLineCondition, relatedProducts.get(dealLine.MATNR__c));
        System.assert(!materialLineWrapper.validationResults.isEmpty());

        materialLineWrapper = new AutoBundleMaterialLineWrapper(dealLine, null, relatedProducts.get(dealLine.MATNR__c));
        System.assert(!materialLineWrapper.validationResults.isEmpty());

        materialLineWrapper = new AutoBundleMaterialLineWrapper(dealLine, dealLineCondition, null);
        System.assert(!materialLineWrapper.validationResults.isEmpty());
    }

    private static Vistex_Deal_Header__c queryDeal() {

        return [SELECT Id, Name, BOART_AG__c, 
                    CURRENCY__c, DEALK01_Ext_Id__c, DEALNUM__c, DEALNUM_EXT__c, DEALTXT__c,
                    ORGID__c, QULAF__c, Transaction_Type_CPQ__c, VALID_FROM__c, VALID_TO__c,Is_Third_Party_Lease_Default__c,
                    (SELECT Id, Name, DEALK01_Ext_Id__c, LOEVM_KO__c, E1KOMG_Ext_Id__c, EBONU__c, EKKOA__c, KOTBNR__c, KSCHL__c, LIFNR__c, MATNR__c, VAKEY__c,DEALK01_Ext_Id__r.ORGID__c
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

        List<Product2> products = [SELECT Id, SAP_Product_Number__c, CPQ_Material_Type__c, ProductCode, 
                                    (
                                        SELECT SBQQ__APIName__c, SBQQ__Language__c, SBQQ__Text__c
                                        FROM SBQQ__Localizations__r
                                        WHERE SBQQ__APIName__c = 'Name'
                                    )      
                                   FROM Product2
                                   WHERE SAP_Product_Number__c IN :sapProductNumbers];

        Map<String, Product2> productMap = new Map<String, Product2>();

        for(Product2 prod : products) {
            productMap.put(prod.SAP_Product_Number__c, prod);
        }

        return productMap;
    }
}