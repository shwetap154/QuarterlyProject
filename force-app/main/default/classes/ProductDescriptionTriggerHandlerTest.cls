/**
* File Name     :  ProductDescriptionTriggerHandlerTest
* @description  :  Tests for ProductDescriptionTriggerHandler class and ProductDescriptionTrigger trigger.
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group.
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0	  2/27/2020     Cesar Sandrigo @ ATG	Created the class. Current Coverage: 100% ProductDescriptionTrigger, 100% ProductDescriptionTriggerHandler
*/
@isTest
public class ProductDescriptionTriggerHandlerTest {

    @testSetup
	public static void setup() { 

		List<SAP_Material__c> materials = new List<SAP_Material__c> {
            CPQ_TestDataFactory.createSAPMaterial('PC', '000000000011111111', 'NORM', 'ZFER', '015000715177010', false),
            CPQ_TestDataFactory.createSAPMaterial('SU', '000000000022222222', 'DIEN', 'DIEN', '015000715184050', false),
            CPQ_TestDataFactory.createSAPMaterial('SU', '000000000033333333', 'DIEN', 'DIEN', '015000715184050', false)
        };
        insert materials;

        insert new List<Product_Description__c> {
            CPQ_TestDataFactory.createProductDescription(materials[0], 'EN', false),
            CPQ_TestDataFactory.createProductDescription(materials[0], 'ES', false),
            CPQ_TestDataFactory.createProductDescription(materials[1], 'EN', false)
        };        
    }

    @isTest
    public static void AfterInsert_NoPreviousExistingRecords() {

        SAP_Material__c prevMaterial = [SELECT Id, SAP_Product_Number__c, Description_Last_Modified_Date__c 
                                            FROM SAP_Material__c 
                                            WHERE SAP_Product_Number__c = '000000000033333333'
                                            LIMIT 1];

        Test.startTest();
        
        // Insert Product Description record
        CPQ_TestDataFactory.createProductDescription(prevMaterial, 'EN', true);

        Test.stopTest();

        SAP_Material__c currMaterial = [SELECT Id, SAP_Product_Number__c, Description_Last_Modified_Date__c 
                                            FROM SAP_Material__c 
                                            WHERE SAP_Product_Number__c = '000000000033333333'
                                            LIMIT 1];

        System.Assert(prevMaterial.Description_Last_Modified_Date__c == null);
        System.Assert(currMaterial.Description_Last_Modified_Date__c != null);
        
        // Check no error logs were inserted.
        AssertNoErrorLogsWereInserted();
    }

    @isTest
    public static void AfterInsert_WithPreviousExistingRecords() {

        SAP_Material__c prevMaterial = [SELECT Id, SAP_Product_Number__c, Description_Last_Modified_Date__c 
                                            FROM SAP_Material__c 
                                            WHERE SAP_Product_Number__c = '000000000011111111'
                                            LIMIT 1];

        Test.startTest();
        
        // Insert Product Description record
        CPQ_TestDataFactory.createProductDescription(prevMaterial, 'PT', true);

        Test.stopTest();

        SAP_Material__c currMaterial = [SELECT Id, SAP_Product_Number__c, Description_Last_Modified_Date__c 
                                            FROM SAP_Material__c 
                                            WHERE SAP_Product_Number__c = '000000000011111111'
                                            LIMIT 1];

        System.Assert(prevMaterial.Description_Last_Modified_Date__c != null);
        System.Assert(currMaterial.Description_Last_Modified_Date__c != null);
        // This should be '<' instead '<=', but timing in tests not easy to test because Datetimes only has hh:mm:ss and ss are the same.
        System.Assert(prevMaterial.Description_Last_Modified_Date__c <= currMaterial.Description_Last_Modified_Date__c);
        
        // Check no error logs were inserted.
        AssertNoErrorLogsWereInserted();
    }

    @isTest
    public static void AfterInsert_NoDescriptionInserted() {

        List<SAP_Material__c> materials = [SELECT Id, SAP_Product_Number__c, Description_Last_Modified_Date__c FROM SAP_Material__c];

        for (SAP_Material__c material : materials) {

            if (material.SAP_Product_Number__c == '000000000033333333') {
                // Check Description_Last_Modified_Date__c is null when no descriptions were inserted.
                System.Assert(material.Description_Last_Modified_Date__c == null);
            }
            else {
                System.Assert(material.Description_Last_Modified_Date__c != null);
            }
        }
        
        // Check no error logs were inserted.
        AssertNoErrorLogsWereInserted();
    }

    @isTest
    public static void AfterUpdate_SingleDescriptions() {

        SAP_Material__c prevMaterial = [SELECT Id, SAP_Product_Number__c, Description_Last_Modified_Date__c 
                                            FROM SAP_Material__c 
                                            WHERE SAP_Product_Number__c = '000000000022222222'
                                            LIMIT 1];

        Product_Description__c prodDescription = [SELECT Id, Product_Description__c
                                                    FROM Product_Description__c
                                                    WHERE SAP_Material__c = :prevMaterial.Id];

        Test.startTest();

        prodDescription.Product_Description__c = 'This is a text';
        update prodDescription;

        Test.stopTest();

        SAP_Material__c currMaterial = [SELECT Id, SAP_Product_Number__c, Description_Last_Modified_Date__c 
                                            FROM SAP_Material__c 
                                            WHERE SAP_Product_Number__c = '000000000022222222'
                                            LIMIT 1];

        System.Assert(prevMaterial.Description_Last_Modified_Date__c != null);
        System.Assert(currMaterial.Description_Last_Modified_Date__c != null);
        // This should be '<' instead '<=', but timing in tests not easy to test because Datetimes only has hh:mm:ss and ss are the same.
        System.Assert(prevMaterial.Description_Last_Modified_Date__c <= currMaterial.Description_Last_Modified_Date__c);
        
        // Check no error logs were inserted.
        AssertNoErrorLogsWereInserted();
    }

    @isTest
    public static void AfterUpdate_MultipleDescriptionMultipleMaterials() {

        List<SAP_Material__c> prevMaterialList = [SELECT Id, SAP_Product_Number__c, Description_Last_Modified_Date__c FROM SAP_Material__c];
        List<Product_Description__c> prodDescriptionsList = [SELECT Id, Product_Description__c FROM Product_Description__c];

        Test.startTest();

        for (Product_Description__c prodDesc : prodDescriptionsList) {
            prodDesc.Product_Description__c = 'This is a text';
        }

        update prodDescriptionsList;

        Test.stopTest();

        List<SAP_Material__c> currMaterialList = [SELECT Id, SAP_Product_Number__c, Description_Last_Modified_Date__c FROM SAP_Material__c];

        Map<String, SAP_Material__c> prevMaterialMap = getMaterialNumberMaterialMap(prevMaterialList);
        Map<String, SAP_Material__c> currMaterialMap = getMaterialNumberMaterialMap(currMaterialList);

        for (String matNumber : prevMaterialMap.keySet()) {
            
            if (matNumber == '000000000033333333') {
                continue;
            }
            
            System.Assert(prevMaterialMap.get(matNumber).Description_Last_Modified_Date__c != null);
            System.Assert(currMaterialMap.get(matNumber).Description_Last_Modified_Date__c != null);
            // This should be '<' instead '<=', but timing in tests not easy to test because Datetimes only has hh:mm:ss and ss are the same.
            System.Assert(prevMaterialMap.get(matNumber).Description_Last_Modified_Date__c <= currMaterialMap.get(matNumber).Description_Last_Modified_Date__c);
        }
        
        // Check no error logs were inserted.
        AssertNoErrorLogsWereInserted();
    }

    private static Map<String, SAP_Material__c> getMaterialNumberMaterialMap(List<SAP_Material__c> materials) {
        
        Map<String, SAP_Material__c> materialsMap = new Map<String, SAP_Material__c>();

        for (SAP_Material__c mat : materials) {
            materialsMap.put(mat.SAP_Product_Number__c, mat);
        }

        return materialsMap;
    }
    
    private static void AssertNoErrorLogsWereInserted() {
        List<Error_Log__c> errorLogs = [SELECT Id, Message__c, Stack_Trace__c FROM Error_Log__c];
        if (!errorLogs.isEmpty()) {
            System.assert(false, 'Error: ' + errorLogs[0].Message__c + ' - Trace: ' + errorLogs[0].Stack_Trace__c);
        }
    }

}