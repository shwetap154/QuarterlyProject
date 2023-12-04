/**************************************************************************************************
* File Name     :   AutoBundleFlexibleGroupLineWrapperTest 
* Description   :   Test class for AutoBundleFlexibleGroupLineWrapper
* @author       :   Cesar Sandrigo
* Modification Log
===================================================================================================
* Ver.  Date       Author              Modification
*--------------------------------------------------------------------------------------------------
* 1.0   11/11/19   Cesar Sandrigo      Created the class. Added tests. Coverage: 93%
**************************************************************************************************/
@istest
public class AutoBundleFlexibleGroupLineWrapperTest {

    private static final String AGGREGATE_COMMITMENT_MATERIAL_NUMBER = '000000000060000555';

    @testSetup
	public static void setup() { 

		// Create SAP materials
		List<SAP_Material__c> materials = new List<SAP_Material__c> {
        	CPQ_TestDataFactory.createSAPMaterial('VL', '000000000060000040', 'Z006', 'ZFER', '', false), // Device
			CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000041', 'NORM', 'DIEN', '', false), // Consumable
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000042', 'NORM', 'DIEN', '', false), // Consumable
            CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000043', 'NORM', 'DIEN', '', false), // Consumable
            CPQ_TestDataFactory.createSAPMaterial('EA', AGGREGATE_COMMITMENT_MATERIAL_NUMBER, 'Z011', 'DIEN', '', false), // Aggregate Commitment Material
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

        // Create flexible groups
        insert new List<Flexible_Group__c> {
            CPQ_TestDataFactory.createFlexibleGroup('00001111', 'ZFLX', false)
            //TODO: Add more flexible groups: with value commitment, with devices, with rebate
        };

        insert new List<Flexible_Group_Item__c> {
            // Flexible Group: 00001111
            CPQ_TestDataFactory.createFlexibleGroupItem('00001111', '000001', '000000000060000041', false),
            CPQ_TestDataFactory.createFlexibleGroupItem('00001111', '000002', '000000000060000042', false),
            CPQ_TestDataFactory.createFlexibleGroupItem('00001111', '000003', '000000000060000043', false)
        };

        // Create bundle header
        Vistex_Deal_Header__c dealHeader = CPQ_TestDataFactory.createVistexDealHeader('000001234', '1436', true);

        // Create deal lines
        List<Vistex_Deal_Line_E1KOMG__c> dealLines = new List<Vistex_Deal_Line_E1KOMG__c> {
            CPQ_TestDataFactory.createVistexDealLine_FlexibleGroup(dealHeader, 'ZCON', '00001111', false)
        };
        insert dealLines;
        
        // Create deal lines
        List<Condition_Header_E1KONH__c> dealLineConditions = new List<Condition_Header_E1KONH__c> {
            CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLines[0], false)
        };
        insert dealLineConditions;

        // Create deal lines
        List<Vistex_ZO2C_E1KONP_CPQ__c> dealLineConditionChilds = new List<Vistex_ZO2C_E1KONP_CPQ__c> {
            // Quantity Commitment - Qty: 48 EA - Term: 12
            CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(dealLineConditions[0], 48, 0.0, 12, 'EA', '01', false)
        };
        insert dealLineConditionChilds;
    }

    @istest
    public static void flexGroupWithQuantityCommitment() {
        // Query deal
        Vistex_Deal_Header__c deal = queryDeal();
        // Query deal line conditions and child objecs
        Map<Id,Condition_Header_E1KONH__c> dealLineConditionMap = queryDealLineConditions();

        Set<String> flexGroupMaterialNumberSet = new Set<String> { '000000000060000041', '000000000060000042', '000000000060000043' };

        // Query products
        List<Product2> relatedProducts = queryProducts(flexGroupMaterialNumberSet);

        // Create a generic product for simulate parent bundle
        Product2 parentBundle = CPQ_TestDataFactory.createProduct(true);
        

        for (Vistex_Deal_Line_E1KOMG__c dealLine : deal.Vistex_Deal_Line__r) {

            Condition_Header_E1KONH__c dealLineCondition = dealLineConditionMap.get(dealLine.Id);

            AutoBundleFlexibleGroupLineWrapper flexGroupLineWrapper = new AutoBundleFlexibleGroupLineWrapper(dealLine, dealLineCondition, relatedProducts);

            // AutoBundleDealLineWrapper generic properties
            System.assertEquals('ZCON', flexGroupLineWrapper.LineType);
            System.assertEquals(null, flexGroupLineWrapper.Suffix);
            System.assertEquals(48, flexGroupLineWrapper.CommitmentQuantity);
            System.assertEquals('EA', flexGroupLineWrapper.CommitmentQuantityUnitOfMeasure);
            System.assertEquals(0.0, flexGroupLineWrapper.CommitmentValue);
            System.assertEquals('12', flexGroupLineWrapper.CommitmentTerm);
            
            // Specific properties for AutoBundleFlexibleGroupLineWrapper
            System.assertEquals('00001111', flexGroupLineWrapper.FlexibleGroupNumber);
            System.assertEquals(true, flexGroupLineWrapper.IsAggregateCommitment);
            System.assertEquals(false, flexGroupLineWrapper.IsRebate);
            System.assertEquals('Zoetis', flexGroupLineWrapper.Supplier);

            // Get the related product option
            List<SBQQ__ProductOption__c> productOptions = flexGroupLineWrapper.getRelatedProductOptions(parentBundle, 1);

            // 1 PO: Aggregate Commitment - 3 Flex group item
            System.assertEquals(4, productOptions.size());

            Product2 aggregateCommitmentProduct = queryProducts(new Set<String>{ AGGREGATE_COMMITMENT_MATERIAL_NUMBER })[0];

            for (SBQQ__ProductOption__c prodOption : productOptions) {
                System.assertEquals(parentBundle.Id, prodOption.SBQQ__ConfiguredSKU__c);
                //SBQQ__OptionalSKU__c
                System.assertEquals(1, prodOption.SBQQ__Quantity__c);
                System.assertEquals('EA', prodOption.Commitment_UOM__c);
                System.assertEquals(null, prodOption.Deal_Line_Group__c);
                System.assertEquals('00001111', prodOption.Flexible_Group__c);
                System.assertEquals(false, prodOption.Rebate_Consumable__c);
                System.assertEquals('Zoetis', prodOption.Supplier__c);

                if (prodOption.SBQQ__OptionalSKU__c == aggregateCommitmentProduct.Id) { // Aggregate commitment line
                    System.assertEquals(48, prodOption.CPQ_Commitment_Quantity__c);
                    System.assertEquals(null, prodOption.CPQ_Commitment_Value__c);
                }
                else { // Material Lines
                    System.assertEquals(null, prodOption.CPQ_Commitment_Quantity__c);
                    System.assertEquals(null, prodOption.CPQ_Commitment_Value__c);
                }
            }
        }
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
                                                                    ZCOMMIT_VALUE__c, ZCOMMITQTY_UOM__c,Commitment_Change_Approval_Required__c,
                                                                    Aggregate_Commitment_Type__c
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
    private static List<Product2> queryProducts(Set<String> sapProductNumbers) {

        return [SELECT Id, SAP_Product_Number__c, CPQ_Material_Type__c, ProductCode
                                   FROM Product2
                                   WHERE SAP_Product_Number__c IN :sapProductNumbers];
    }
}