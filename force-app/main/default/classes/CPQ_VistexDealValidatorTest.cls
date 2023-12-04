/**
* File Name     :  CPQ_VistexDealValidatorTest
* @description  :  Test coverage for the vistex deal validator
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     1/10/2020		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/5/2020		Cory Bartholomew @ ATG     Added descriptions.
* 3.0	  2/15/2023		Sourav Mitra @ CTS		   Added Methods - testPreValidations,testFlexibleGroup
**/

@IsTest
public class CPQ_VistexDealValidatorTest {
   
    @isTest
    static void TestMultipleZel4Lines() {
        Vistex_Deal_Header__c deal = CPQ_TestDataFactory.createVistexDealHeader('4000006474', '1436', true);
        List<Vistex_Deal_Line_E1KOMG__c> dealLines = new List<Vistex_Deal_Line_E1KOMG__c>();
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Elegibility(deal, 'TestBNDL', false));
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Elegibility(deal, 'TestBNDL2', false));
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Elegibility(deal, 'TestBNDL3', false));
        
        List<CPQ_VistexDealValidator.DealValidationResult> results = CPQ_VistexDealValidator.bulkValidateDealLines(dealLines);
        
        System.AssertEquals(1,results.size());
        System.AssertEquals(false,results[0].isValid);
        System.AssertEquals(true,results[0].invalidReason.contains('There is more than one ZEL4 deal line'));
    }

     @isTest
    static void testOperationalLeaseIncludesRentalFee(){
        Vistex_Deal_Header__c deal = CPQ_TestDataFactory.createVistexDealHeader('4000006474', '1436', true); 
        List<SAP_Material__c> materials = new List<SAP_Material__c>();
        materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001280', 'Z012', 'ZFER', '015000715175010', false));
        materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001285', 'LEAS', 'UNBW', '015000715175011', false));
        insert materials;

        List<Vistex_Deal_Line_E1KOMG__c> dealLines = new List<Vistex_Deal_Line_E1KOMG__c>();
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZDEV', materials[0].SAP_Product_Number__c, null, false));
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZDEV', materials[1].SAP_Product_Number__c, null, false));
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZDEV', materials[1].SAP_Product_Number__c, null, false));
        insert dealLines;

        Map<String,SAP_Material__c> matMap = CPQ_VistexDealValidator.getMaterialMap(dealLines);
        
        CPQ_VistexDealValidator.DealValidationResult result = CPQ_VistexDealValidator.operationalLeaseIncludesRentalFee(dealLines,matMap);
        System.AssertEquals(true, result.invalidReason.contains('There is no rental fee material item included for at least one operatonal Lease item in this deal'));

    }

    @isTest
    static void testSpecificOrAggregate(){
        Vistex_Deal_Header__c deal = CPQ_TestDataFactory.createVistexDealHeader('4000006474', '1436', true);         
        SAP_Material__c mat = CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001280', 'Z006', 'ZFER', '015000715175010', true); 
        
        List<Vistex_Deal_Line_E1KOMG__c> dealLines = new List<Vistex_Deal_Line_E1KOMG__c>();
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_FlexibleGroup(deal, 'ZDEV', '000001', false));       
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZCON', mat.SAP_Product_Number__c, null, false)); 
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_FlexibleGroup(deal, 'ZDEV', '000002', false));
        insert dealLines;

        List<Condition_Header_E1KONH__c> conditions = new List<Condition_Header_E1KONH__c>();        
        conditions.add(CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLines[0], false));
        conditions.add(CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLines[1], false));
        conditions.add(CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLines[2], false));
        insert conditions;

        List<Vistex_ZO2C_E1KONP_CPQ__c> conditionChildren = new List<Vistex_ZO2C_E1KONP_CPQ__c>();     
        //Create conditon children with commits for both the Flex group line (agg commit) and the Dev line(specific commit)   
        conditionChildren.add(CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(conditions[0],0,50,null,null,null,false));
        conditionChildren.add(CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(conditions[1],0,50,null,null,null,false));
        conditionChildren.add(CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(conditions[2],0,0,null,null,null,false));
        insert conditionChildren;        
        
        
        List<CPQ_VistexDealValidator.DealValidationResult> results = CPQ_VistexDealValidator.specificOrAggregate(dealLines);
        System.AssertEquals(false, CPQ_VistexDealValidator.isDealValid(results));
        

    }

    @isTest
    static void testConcatResults(){
        
        List<CPQ_VistexDealValidator.DealValidationResult> results = new List<CPQ_VistexDealValidator.DealValidationResult>{};
        results.add(CPQ_VistexDealValidator.createResult('invalid',false,null));
        results.add(CPQ_VistexDealValidator.createResult('invalid2',false,null));
        String reasons = CPQ_VistexDealValidator.concatValidationResults(results);
        System.AssertEquals('invalid\r\ninvalid2\r\n',reasons);
    }

    @isTest
    static void testIsDealValid(){
        CPQ_VistexDealValidator.DealValidationResult result = new CPQ_VistexDealValidator.DealValidationResult();
        result.isValid = false;
        result.invalidReason = 'Invalid';
        List<CPQ_VistexDealValidator.DealValidationResult> results = new List<CPQ_VistexDealValidator.DealValidationResult>{result};

        Boolean isValid = CPQ_VistexDealValidator.isDealValid(results);
        System.AssertEquals(false,isValid);
    }

    @isTest
    static void testGetMaterialMap(){
        Vistex_Deal_Header__c deal = CPQ_TestDataFactory.createVistexDealHeader('4000006474', '1436', true);  
        SAP_Material__c mat = CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001280', 'Z006', 'ZFER', '015000715175010', true); 
        Vistex_Deal_Line_E1KOMG__c line = CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZDEV', mat.SAP_Product_Number__c, null, true);
        Map<String, SAP_MAterial__c> matMap = CPQ_VistexDealValidator.getMaterialMap(new List<Vistex_Deal_Line_E1KOMG__c>{line});

        System.assertEquals(1, matMap.keySet().size());
        System.AssertEquals(true, matMap.keySet().contains('000000000016001280'));
    }
	
    //Code added by Sourav for testing Validate SAP Material with 'NO SAP Material' condition
    @isTest
    static void testMaterialSAP(){
       Vistex_Deal_Header__c deal = CPQ_TestDataFactory.createVistexDealHeader('4000006474', '1436', true); 
       
       List<SAP_Material__c> materials = new List<SAP_Material__c>();
        materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001280', 'Z012', 'ZFER', '015000715175010', false));
        materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001285', 'LEAS', 'UNBW', '015000715175011', false));
        insert materials; 
        
        List<Vistex_Deal_Line_E1KOMG__c> dealLines = new List<Vistex_Deal_Line_E1KOMG__c>();
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZDEV','015000715175010', null, false));
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZDEV','015000715175010', null, false));
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZDEV','015000715175010', null, false));
        insert dealLines;
        
        Map<String,SAP_Material__c> matMap = CPQ_VistexDealValidator.getMaterialMap(dealLines);
        
        List<CPQ_VistexDealValidator.DealValidationResult> results = CPQ_VistexDealValidator.validateSAPMaterial(dealLines, matMap);
		System.assertEquals(false, results.isEmpty());
        
    }
    
    //Code added by Sourav for testing Flexible Groups
    @isTest
    static void testFlexibleGroup(){
        Vistex_Deal_Header__c deal = CPQ_TestDataFactory.createVistexDealHeader('4000006474', '1436', true); 
        
        Flexible_Group__c flxGroup = CPQ_TestDataFactory.createFlexibleGroup('000001', 'ZFLX', true);
        
        List<Vistex_Deal_Line_E1KOMG__c> dealLines = new List<Vistex_Deal_Line_E1KOMG__c>();
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_FlexibleGroup(deal, 'ZDEV', flxGroup.Flexible_Group_Number__c, false));
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_FlexibleGroup(deal, 'ZDEV', flxGroup.Flexible_Group_Number__c, false));
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_FlexibleGroup(deal, 'ZDEV', flxGroup.Flexible_Group_Number__c, false));
        insert dealLines;
        
       List<CPQ_VistexDealValidator.DealValidationResult> results = CPQ_VistexDealValidator.validateFlexibleGroup(dealLines);
        
        System.assertEquals(true, results.isEmpty());
        
    }
    
     /* 
      * Method created by Sourav
	  * This test method is covering the following methods,
		- runPreValidations
		- validateSAPMaterial
		- validateSapPriceEntry
	 */
    @isTest
    static void testPreValidations(){
		Vistex_Deal_Header__c deal = CPQ_TestDataFactory.createVistexDealHeader('4000006474', '1436', true);
        
        List<SAP_Material__c> materials = new List<SAP_Material__c>();
        materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001280', 'Z012', 'ZFER', '015000715175010', false));
        materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001285', 'LEAS', 'UNBW', '015000715175011', false));
        insert materials;
        
        List<Vistex_Deal_Line_E1KOMG__c> dealLines = new List<Vistex_Deal_Line_E1KOMG__c>();
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZDEV', materials[0].SAP_Product_Number__c, null, false));
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZDEV', materials[1].SAP_Product_Number__c, null, false));
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZDEV', materials[1].SAP_Product_Number__c, null, false));
        insert dealLines;
        
        Date today = Date.today();
         List<SAP_Price_Entry__c> sapPriceEntries = new List<SAP_Price_Entry__c> {
            CPQ_TestDataFactory.createSAPPriceEntry('000000000016001290', '1436', 10.1, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000016001285', '1436', 11.2, today.addDays(-10), today.addDays(10), 'USD', 'ST', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000011021425', '1436', 12.3, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000016001280', '1436', 13.4, today.addDays(-10), today.addDays(10), 'USD', 'PK', false)
        };
            
            insert sapPriceEntries;
        
       List<CPQ_VistexDealValidator.DealValidationResult> results = CPQ_VistexDealValidator.runPreValidations(deal,dealLines);
		System.assertEquals(false, results.isEmpty());           
    }
    
    @isTest
    public static void testGetWarrantyAndDeviceLines(){
        Vistex_Deal_Header__c deal = CPQ_TestDataFactory.createVistexDealHeader('4000006474', '1436', true);
        List<SAP_Material__c> materials = new List<SAP_Material__c>();
        materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000060000007', 'ZIEN', 'DIEN', '015000715175010', false)); 
        materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001280', 'Z006', 'ZFER', '015000715175010', false));    
        insert materials;

        List<Vistex_Deal_Line_E1KOMG__c> dealLines = new List<Vistex_Deal_Line_E1KOMG__c>();
        List<Condition_Header_E1KONH__c> conditions = new List<Condition_Header_E1KONH__c>(); 
        List<Vistex_ZO2C_E1KONP_CPQ__c> conditionChildren = new List<Vistex_ZO2C_E1KONP_CPQ__c>();
       
        
        
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZCON', materials[0].SAP_Product_Number__c, null, false));
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZDEV', materials[1].SAP_Product_Number__c, null, false));
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deal, 'ZDEV', materials[1].SAP_Product_Number__c, null, false));
        dealLines[0].EBONU__c = 'S1';
        dealLines[1].EBONU__c = 'S1';
        dealLines[2].EBONU__c = 'S1';
        //Create 2 ZCON flx group items to fail test
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Term(deal, '48', false));
        
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Elegibility(deal, 'TEST', false));
    
        insert dealLines;     
        
        conditions.add(CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLines[0], false));
        conditions.add(CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLines[1], false));
        conditions.add(CPQ_TestDataFactory.createVistexDealLineItemCondition(dealLines[2], false));
        insert conditions;

        conditionChildren.add(CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(conditions[0], 0, null, 0, 'EA', '01', false));        
        conditionChildren.add(CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(conditions[1], 0, null, 0, 'EA', '01', false));  
        conditionChildren.add(CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(conditions[2], 0, null, 0, 'EA', '01', false));     
        insert conditionChildren;
       
        Map<String, SAP_Material__c> matMap = CPQ_VistexDealValidator.getMaterialMap(dealLines);
        List<CPQ_VistexDealValidator.DealValidationResult> results = CPQ_VistexDealValidator.getWarrantyAndDeviceLines(dealLines, matMap);
        System.assertEquals(true, results[0].invalidReason.contains('It is expected that it will have only 1 device linked with warranty line'));


    }
    
}