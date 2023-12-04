/**
 * @description       : Test class for CaseProductsService
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             :
 * @last modified on  : 07-29-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-18-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for upsertBatchDetailFromCaseProduct
 * 1.1   07-20-2022   Ethan Hirsch @ Zoetis Inc   Add tests for setPrimaryBatchDetailOnCaseProduct and
 *                                                clearProductDetailsWherePrimaryBatchDetailBlank.
 * 1.2   07-29-2022   Ethan Hirsch @ Zoetis Inc   Set Product Category when creating PVW Products to trigger the
 *                                                Case Product Workflow Rule that sets Agency (Agency is based off Product Category).
 * 1.3   08-01-2022   Ethan Hirsch @ Zoetis Inc   Add data to reevaluteRelatedBatchDetailQualifiers_General_Test to test
 *                                                Serial Number being set when Product changes.
 * 1.4   12-14-2022   Ahmed Elawad @ Slalom       Add test for validateFirstAdministrationStartDate
 **/
@isTest
private class CaseProductsServiceTest {
    private static final String CREATE_BATCH_DETAIL_CASE_SUBJECT = 'TestCase1';
    private static final String PVW_PRODUCT_1_NAME = 'Product1';
    private static final String PVW_PRODUCT_2_NAME = 'Product1';
    private static Id zoetisProductRecordTypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId();

    @testSetup
    private static void setup(){
        Account testAccount = TestDataFactory.createAccount_US('Test Account 1', true);

        List<ZTS_US_PVW_Product__c> pvwProducts = ZTS_DataUtilityTest.createPvwProducts(2);
        pvwProducts[0].Name = PVW_PRODUCT_1_NAME;
        pvwProducts[0].ZTS_US_Product_Category__c  = 'DIAG';
        pvwProducts[1].Name = PVW_PRODUCT_2_NAME;
        pvwProducts[1].ZTS_US_Product_Category__c  = 'DIAG';
        insert pvwProducts;

        Id vmipsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        Case testVmipsCase1 = ZTS_DataUtilityTest.createCases(1, vmipsRecordTypeId)[0];
        testVmipsCase1.Subject = CREATE_BATCH_DETAIL_CASE_SUBJECT;
        testVmipsCase1.Type = 'Animal Complaint';
        testVmipsCase1.AccountId = testAccount.Id;

        insert testVmipsCase1;

        List<ZTS_US_Case_Product__c> caseProducts = ZTS_DataUtilityTest.createCaseProducts(2, zoetisProductRecordTypeId,
            testVmipsCase1.Id, pvwProducts[0].Id);

        caseProducts[0].ZTS_US_Product_Lot__c = '951';
        caseProducts[0].ZTS_US_Serial_Number__c = '321';
        caseProducts[0].ZTS_US_Diluent__c = '831';
        Date today = Date.today();
        // assign the case product start date to one week ago: today -7 days
        caseProducts[0].ZTS_US_Start_Date__c = today.addDays(-7);
        caseProducts.addAll(ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, testVmipsCase1.Id,
            pvwProducts[1].Id));

        insert caseProducts;
		System.debug(caseProducts[0].ZTS_US_Start_Date__c);
        // Skip the Batch Detail Trigger to prevent this Batch Detail from becoming the Primary Batch Detail.
        Batch_Detail__c testBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1, caseProducts[2].Id)[0];
        DispatchTriggerHandler.bypass('BatchDetailTriggerHandler');
        insert testBatchDetail;
        DispatchTriggerHandler.clearBypass('BatchDetailTriggerHandler');
    }

    @isTest
    private static void upsertBatchDetailFromCaseProduct_and_setPrimaryBatchDetailOnCaseProduct_CreateBatchDetailInsert_Test() {
        Case testCase = retrieveTestCase(CREATE_BATCH_DETAIL_CASE_SUBJECT);

        ZTS_US_PVW_Product__c pvwProduct = retrievePvwProduct();

        ZTS_US_Case_Product__c caseProduct = ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId,
            testCase.Id, pvwProduct.Id)[0];

        caseProduct.ZTS_US_Product_Lot__c = '1234';

        Test.startTest();
            insert caseProduct;
        Test.stopTest();

        List<Batch_Detail__c> testBatchDetails = retrieveBatchDetailsForCaseProduct(caseProduct.Id);

        System.assertEquals(1, testBatchDetails.size(), '1 Batch Detail should have been created.');

        System.assert(testBatchDetails[0].ZTS_US_Primary__c, 'The new Batch Detail should have Primary set to true.');
        System.assertEquals(caseProduct.ZTS_US_Product_Lot__c, testBatchDetails[0].ZTS_US_Product_Lot__c,
            'Lot Number should be set from the Case Product on the Batch Detail.');

        caseProduct = retrieveCaseProductWithProductDetails(caseProduct.Id);

        System.assertEquals(testBatchDetails[0].Id, caseProduct.Primary_Batch_Detail__c,
            'Primary Batch Detail was not set on the Case Product.');
    }

    @isTest
    private static void upsertBatchDetailFromCaseProduct_CreateNoBatchDetailInsert_Test() {
        Case testCase = retrieveTestCase(CREATE_BATCH_DETAIL_CASE_SUBJECT);

        ZTS_US_PVW_Product__c pvwProduct = retrievePvwProduct();

        ZTS_US_Case_Product__c caseProduct = ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId,
            testCase.Id, pvwProduct.Id)[0];

        Test.startTest();
            insert caseProduct;
        Test.stopTest();

        List<Batch_Detail__c> testBatchDetails = retrieveBatchDetailsForCaseProduct(caseProduct.Id);

        System.assertEquals(0, testBatchDetails.size(),
            'No Batch Details should have been created as no data was set on the Product.');
    }

    @isTest
    private static void upsertBatchDetailFromCaseProduct_CreateMultipleBatchDetailInsert_Test() {
        Case testCase = retrieveTestCase(CREATE_BATCH_DETAIL_CASE_SUBJECT);

        ZTS_US_PVW_Product__c pvwProduct = retrievePvwProduct();

        List<ZTS_US_Case_Product__c> caseProducts = ZTS_DataUtilityTest.createCaseProducts(5,
            zoetisProductRecordTypeId, testCase.Id, pvwProduct.Id);

        List<ZTS_US_Case_Product__c> caseProductsWithBatchDetails = new List<ZTS_US_Case_Product__c>();
        for (integer i = 0; i < caseProducts.size(); i++) {
            switch on i {
                when 0 {
                    caseProducts[i].ZTS_US_Product_Lot__c = '1234';

                    caseProductsWithBatchDetails.add(caseProducts[i]);
                }
                when 1 {
                    caseProducts[i].ZTS_US_Serial_Number__c = '4567';

                    caseProductsWithBatchDetails.add(caseProducts[i]);
                }
                when 2 {
                    caseProducts[i].ZTS_US_Diluent__c = '8901';

                    caseProductsWithBatchDetails.add(caseProducts[i]);
                }
                when 3 {
                    caseProducts[i].ZTS_US_Product_Lot__c = '1111';
                    caseProducts[i].ZTS_US_Serial_Number__c = '2222';
                    caseProducts[i].ZTS_US_Diluent__c = '3333';

                    caseProductsWithBatchDetails.add(caseProducts[i]);
                }
            }
        }

        Test.startTest();
            insert caseProducts;
        Test.stopTest();

        Map<Id, ZTS_US_Case_Product__c> caseProductIdsWithBatchDetailsMap = new Map<Id, ZTS_US_Case_Product__c>(
            caseProductsWithBatchDetails);

        for (Batch_Detail__c testBatchDetail : [
            SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Diluent__c, ZTS_US_Primary__c,
                   ZTS_US_Case_Product__c
            FROM Batch_Detail__c
            WHERE ZTS_US_Case_Product__c in: caseProducts
        ]) {
            System.assert(caseProductIdsWithBatchDetailsMap.containsKey(testBatchDetail.ZTS_US_Case_Product__c),
                String.format('A Batch Detail was created unexpectedly for Case Product {0}',
                new List<Object> {testBatchDetail.ZTS_US_Case_Product__c}));

            ZTS_US_Case_Product__c testCaseProduct = caseProductIdsWithBatchDetailsMap.get(
                testBatchDetail.ZTS_US_Case_Product__c);

            System.assert(testBatchDetail.ZTS_US_Primary__c, 'The new Batch Detail should have Primary set to true.');

            if (String.isNotBlank(testCaseProduct.ZTS_US_Product_Lot__c)) {
                System.assertEquals(testCaseProduct.ZTS_US_Product_Lot__c, testBatchDetail.ZTS_US_Product_Lot__c,
                    'Lot Number should be set on the Batch Detail using the Case Product.');
            }
            else {
                System.assert(String.isBlank(testBatchDetail.ZTS_US_Product_Lot__c),
                    String.format('Lot Number should be blank on Batch Detail. Actual value: {0}',
                    new List<String> {testBatchDetail.ZTS_US_Product_Lot__c}));
            }

            if (String.isNotBlank(testCaseProduct.ZTS_US_Serial_Number__c)) {
                System.assertEquals(testCaseProduct.ZTS_US_Serial_Number__c, testBatchDetail.ZTS_US_Serial_Number__c,
                    'Serial Number should be set on the Batch Detail using the Case Product.');
            }
            else {
                System.assert(String.isBlank(testBatchDetail.ZTS_US_Serial_Number__c),
                    String.format('Serial Number should be blank on Batch Detail. Actual value: {0}',
                    new List<String> {testBatchDetail.ZTS_US_Serial_Number__c}));
            }

            if (String.isNotBlank(testCaseProduct.ZTS_US_Diluent__c)) {
                System.assertEquals(testCaseProduct.ZTS_US_Diluent__c, testBatchDetail.ZTS_US_Diluent__c,
                    'Diluent Number should be set on the Batch Detail using the Case Product.');
            }
            else {
                System.assert(String.isBlank(testBatchDetail.ZTS_US_Diluent__c),
                    String.format('Diluent Number should be blank on Batch Detail. Actual value: {0}',
                    new List<String> {testBatchDetail.ZTS_US_Diluent__c}));
            }
        }
    }

    @isTest
    private static void upsertBatchDetailFromCaseProduct_CreateBatchDetailUpdate_Test() {
        ZTS_US_Case_Product__c caseProduct = retrieveExistingCaseProductWithoutBatchDetail();
        caseProduct.ZTS_US_Product_Lot__c = '7512';

        List<Batch_Detail__c> existingBatchDetails = retrieveBatchDetailsForCaseProduct(caseProduct.Id);
        System.assertEquals(0, existingBatchDetails.size(), 'Sanity Check Failed: No Batch Details should exist.');

        Test.startTest();
            update caseProduct;
        Test.stopTest();

        List<Batch_Detail__c> updateBatchDetails = retrieveBatchDetailsForCaseProduct(caseProduct.Id);

        System.assertEquals(1, updateBatchDetails.size(), '1 Batch Detail should have been created.');


        System.assert(updateBatchDetails[0].ZTS_US_Primary__c, 'The new Batch Detail should have Primary set to true.');
        System.assertEquals(caseProduct.ZTS_US_Product_Lot__c, updateBatchDetails[0].ZTS_US_Product_Lot__c,
            'Lot Number was not set as expected.');
    }

    @isTest
    private static void upsertBatchDetailFromCaseProduct_UpdateBatchDetailUpdate_Test() {
        ZTS_US_Case_Product__c caseProduct = retrieveExistingCaseProductWithPrimaryBatchDetail();
        List<Batch_Detail__c> existingBatchDetails = retrieveBatchDetailsForCaseProduct(caseProduct.Id);

        System.assertEquals(1, existingBatchDetails.size(), 'Sanity Check Failed: One Batch Detail should exist.');

        caseProduct.ZTS_US_Product_Lot__c = '532';

        Test.startTest();
            update caseProduct;
        Test.stopTest();

        List<Batch_Detail__c> updateBatchDetails = retrieveBatchDetailsForCaseProduct(caseProduct.Id);

        System.assertEquals(caseProduct.ZTS_US_Product_Lot__c, updateBatchDetails[0].ZTS_US_Product_Lot__c,
            'Lot Number was not changed as expected.');
    }

    // This should not delete the Batch Detail, but clear out these fields
    @isTest
    private static void upsertBatchDetailFromCaseProduct_UpdateBatchDetailClear_Test() {
        ZTS_US_Case_Product__c caseProduct = retrieveExistingCaseProductWithPrimaryBatchDetail();
        List<Batch_Detail__c> existingBatchDetails = retrieveBatchDetailsForCaseProduct(caseProduct.Id);

        System.assertEquals(1, existingBatchDetails.size(), 'Sanity Check Failed: One Batch Detail should exist.');

        caseProduct.ZTS_US_Product_Lot__c = null;
        caseProduct.ZTS_US_Serial_Number__c = null;
        caseProduct.ZTS_US_Diluent__c = null;

        Test.startTest();
            update caseProduct;
        Test.stopTest();

        List<Batch_Detail__c> updateBatchDetails = retrieveBatchDetailsForCaseProduct(caseProduct.Id);

        System.assertEquals(caseProduct.ZTS_US_Product_Lot__c, updateBatchDetails[0].ZTS_US_Product_Lot__c,
            'Lot Number was not changed as expected.');

        System.assertEquals(caseProduct.ZTS_US_Serial_Number__c, updateBatchDetails[0].ZTS_US_Serial_Number__c,
            'Serial Number was not changed as expected.');

        System.assertEquals(caseProduct.ZTS_US_Diluent__c, updateBatchDetails[0].ZTS_US_Diluent__c,
            'Diluent Number was not changed as expected.');
    }

    @isTest
    private static void upsertBatchDetailFromCaseProduct_UpdateNoBatchDetailUpdate_Test() {
        ZTS_US_Case_Product__c caseProduct = retrieveExistingCaseProductWithoutBatchDetail();

        List<Batch_Detail__c> existingBatchDetails = retrieveBatchDetailsForCaseProduct(caseProduct.Id);

        System.assertEquals(0, existingBatchDetails.size(), 'Sanity Check Failed: No Batch Details should exist.');

        Test.startTest();
            update caseProduct;
        Test.stopTest();

        List<Batch_Detail__c> updateBatchDetails = retrieveBatchDetailsForCaseProduct(caseProduct.Id);

        System.assertEquals(0, updateBatchDetails.size(), 'No Batch Details should have been created.');
    }

    @isTest
    private static void upsertBatchDetailFromCaseProduct_UpdateMultipleBatchDetailUpsert_Test() {
        List<ZTS_US_Case_Product__c> caseProducts = new List<ZTS_US_Case_Product__c>();

        Batch_Detail__c existingNonPrimaryBatchDetail = retrieveExistingNonPrimaryBatchDetail();

        for (ZTS_US_Case_Product__c caseProduct : [
            SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Diluent__c
            FROM ZTS_US_Case_Product__c
            WHERE ZTS_US_Case__r.Subject =: CREATE_BATCH_DETAIL_CASE_SUBJECT]) {
            // This Case Product doesn't have a Batch Detail yet
            if (String.isBlank(caseProduct.ZTS_US_Product_Lot__c)) {
                caseProduct.ZTS_US_Product_Lot__c = '9138';
                caseProduct.ZTS_US_Serial_Number__c  = '4810';
                caseProduct.ZTS_US_Diluent__c = '1734';
            }
            // This Case Product has a Batch Detail which will be updated
            else {
                caseProduct.ZTS_US_Product_Lot__c = '5389';
                caseProduct.ZTS_US_Serial_Number__c  = '6479';
                caseProduct.ZTS_US_Diluent__c = '5312';
            }

            caseProducts.add(caseProduct);
        }

        Test.startTest();
            update caseProducts;
        Test.stopTest();

        Map<Id, ZTS_US_Case_Product__c> caseProductMap = new Map<Id, ZTS_US_Case_Product__c>(caseProducts);

        for (Batch_Detail__c testBatchDetail : [
            SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Diluent__c, ZTS_US_Primary__c,
                   ZTS_US_Case_Product__c
            FROM Batch_Detail__c
            WHERE ZTS_US_Case_Product__c in: caseProducts
        ]) {
            // This Batch Detail should not have changed and is checked separately.
            if (testBatchDetail.Id == existingNonPrimaryBatchDetail.Id) {
                System.assertEquals(existingNonPrimaryBatchDetail.ZTS_US_Product_Lot__c,
                    testBatchDetail.ZTS_US_Product_Lot__c,
                    'Lot Number should not have changed on the existing Batch Detail.');

                System.assertEquals(existingNonPrimaryBatchDetail.ZTS_US_Serial_Number__c,
                    testBatchDetail.ZTS_US_Serial_Number__c,
                    'Serial Number should not have changed on the existing Batch Detail.');

                System.assertEquals(existingNonPrimaryBatchDetail.ZTS_US_Diluent__c, testBatchDetail.ZTS_US_Diluent__c,
                    'Diluent Number should not have changed on the existing Batch Detail.');

                continue;
            }

            System.assert(caseProductMap.containsKey(testBatchDetail.ZTS_US_Case_Product__c),
                String.format('A Batch Detail was created unexpectedly for Case Product {0}',
                new List<Object> {testBatchDetail.ZTS_US_Case_Product__c}));

            ZTS_US_Case_Product__c testCaseProduct = caseProductMap.get(testBatchDetail.ZTS_US_Case_Product__c);

            // All Case Product should have all fields set.
            System.assert(testBatchDetail.ZTS_US_Primary__c, 'The new Batch Detail should have Primary set to true.');
            System.assertEquals(testCaseProduct.ZTS_US_Product_Lot__c, testBatchDetail.ZTS_US_Product_Lot__c,
                'Lot Number should be set on the Batch Detail using the Case Product.');

            System.assertEquals(testCaseProduct.ZTS_US_Serial_Number__c, testBatchDetail.ZTS_US_Serial_Number__c,
                'Serial Number should be set on the Batch Detail using the Case Product.');

            System.assertEquals(testCaseProduct.ZTS_US_Diluent__c, testBatchDetail.ZTS_US_Diluent__c,
                'Diluent Number should be set on the Batch Detail using the Case Product.');
        }
    }

    @isTest
    private static void syncUpdatedBatchDetailsToCaseProduct_UpdateCaseProductFromBatchDetail_Test() {
        Batch_Detail__c testBatchDetail = retrieveExistingPrimaryBatchDetail();
        testBatchDetail.ZTS_US_Product_Lot__c = '9182';
        testBatchDetail.ZTS_US_Serial_Number__c = '3712';
        testBatchDetail.ZTS_US_Diluent__c = '4813';

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductWithProductDetails(testBatchDetail.ZTS_US_Case_Product__c);

        System.assertEquals(testBatchDetail.ZTS_US_Product_Lot__c, caseProduct.ZTS_US_Product_Lot__c,
            'Lot # should have synced from Batch Detail to Case Product.');

        System.assertEquals(testBatchDetail.ZTS_US_Serial_Number__c, caseProduct.ZTS_US_Serial_Number__c,
            'Serial # should have synced from Batch Detail to Case Product.');

        System.assertEquals(testBatchDetail.ZTS_US_Diluent__c, caseProduct.ZTS_US_Diluent__c,
            'Diluent # should have synced from Batch Detail to Case Product.');
    }

    @isTest
    private static void syncUpdatedBatchDetailsToCaseProduct_UpdateNonPrimaryBatchDetailNoCaseProductUpdate_Test() {
        Batch_Detail__c testBatchDetail = retrieveExistingNonPrimaryBatchDetail();
        testBatchDetail.ZTS_US_Product_Lot__c = '9182';
        testBatchDetail.ZTS_US_Serial_Number__c = '3712';
        testBatchDetail.ZTS_US_Diluent__c = '4813';

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductWithProductDetails(testBatchDetail.ZTS_US_Case_Product__c);

        System.assertNotEquals(testBatchDetail.ZTS_US_Product_Lot__c, caseProduct.ZTS_US_Product_Lot__c,
            'Lot # should not have synced from Batch Detail to Case Product.');

        System.assertNotEquals(testBatchDetail.ZTS_US_Serial_Number__c, caseProduct.ZTS_US_Serial_Number__c,
            'Serial # should not have synced from Batch Detail to Case Product.');

        System.assertNotEquals(testBatchDetail.ZTS_US_Diluent__c, caseProduct.ZTS_US_Diluent__c,
            'Diluent # should not have synced from Batch Detail to Case Product.');
    }

    @isTest
    private static void syncUpdatedBatchDetailsToCaseProduct_UpdatePrimaryBatchDetailNoCaseProductUpdateNoChangedFields_Test() {
        Batch_Detail__c testBatchDetail = retrieveExistingPrimaryBatchDetail();
        testBatchDetail.ZTS_US_Product_Lot__c = '9182';
        testBatchDetail.ZTS_US_Serial_Number__c = '3712';
        testBatchDetail.ZTS_US_Diluent__c = '4813';

        // Bypass the trigger handler so the Batch Detail does not sync to the Case Product
        DispatchTriggerHandler.bypass('BatchDetailTriggerHandler');
        update testBatchDetail;
        DispatchTriggerHandler.clearBypass('BatchDetailTriggerHandler');

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductWithProductDetails(testBatchDetail.ZTS_US_Case_Product__c);

        System.assertNotEquals(testBatchDetail.ZTS_US_Product_Lot__c, caseProduct.ZTS_US_Product_Lot__c,
            'Lot # should not have synced from Batch Detail to Case Product.');

        System.assertNotEquals(testBatchDetail.ZTS_US_Serial_Number__c, caseProduct.ZTS_US_Serial_Number__c,
            'Serial # should not have synced from Batch Detail to Case Product.');

        System.assertNotEquals(testBatchDetail.ZTS_US_Diluent__c, caseProduct.ZTS_US_Diluent__c,
            'Diluent # should not have synced from Batch Detail to Case Product.');
    }

    @isTest
    private static void syncUpdatedBatchDetailsToCaseProduct_UpdateMultipleBatchDetailCaseProductUpdate_Test() {
        ZTS_US_Case_Product__c caseProductWithoutBatchDetail;
        ZTS_US_Case_Product__c caseProductWithPrimaryBatchDetail;
        for (ZTS_US_Case_Product__c caseProduct : [
            SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Diluent__c
            FROM ZTS_US_Case_Product__c
            WHERE ZTS_US_Case__r.Subject =: CREATE_BATCH_DETAIL_CASE_SUBJECT
            AND ZTS_US_PVW_Product__r.Name =: PVW_PRODUCT_1_NAME
            LIMIT 2
        ]) {
            if (String.isNotBlank(caseProduct.ZTS_US_Product_Lot__c)) {
                caseProductWithPrimaryBatchDetail = caseProduct;
            }
            else {
                caseProductWithoutBatchDetail = caseProduct;
            }
        }

        // Setup a Lot # on this Case Product to Trigger the Batch Detail creation.
        caseProductWithoutBatchDetail.ZTS_US_Product_Lot__c = '9182';
        update caseProductWithoutBatchDetail;

        // Create an additional Batch Detail for this Case Product
        Batch_Detail__c additionalBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1,
            caseProductWithPrimaryBatchDetail.Id)[0];

        insert additionalBatchDetail;

        additionalBatchDetail.ZTS_US_Product_Lot__c = '6879';
        additionalBatchDetail.ZTS_US_Serial_Number__c = '5231';
        additionalBatchDetail.ZTS_US_Diluent__c = '5891';

        Set<Id> caseProductIds = new Set<Id>();
        List<Batch_Detail__c> updateBatchDetails = new List<Batch_Detail__c> {additionalBatchDetail};
        for (Batch_Detail__c batchDetail : [
            SELECT Id, ZTS_US_Primary__c, ZTS_US_Case_Product__c, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c,
                   ZTS_US_Diluent__c
            FROM Batch_Detail__c
            WHERE ZTS_US_Case_Product__r.ZTS_US_Case__r.Subject =: CREATE_BATCH_DETAIL_CASE_SUBJECT
            AND Id != : additionalBatchDetail.Id]) {
            if (batchDetail.ZTS_US_Case_Product__c == caseProductWithoutBatchDetail.Id) {
                batchDetail.ZTS_US_Product_Lot__c = '1382';
                batchDetail.ZTS_US_Diluent__c = '9182';
            }
            else if (batchDetail.ZTS_US_Primary__c) {
                batchDetail.ZTS_US_Product_Lot__c = '7643';
                batchDetail.ZTS_US_Serial_Number__c = '1823';
                batchDetail.ZTS_US_Diluent__c = '3213';
            }
            else {
                batchDetail.ZTS_US_Product_Lot__c = '9553';
                batchDetail.ZTS_US_Serial_Number__c = '3234';
                batchDetail.ZTS_US_Diluent__c = '1223';
            }

            updateBatchDetails.add(batchDetail);
            caseProductIds.add(batchDetail.ZTS_US_Case_Product__c);
        }

        Test.startTest();
            update updateBatchDetails;
        Test.stopTest();

        Map<Id, ZTS_US_Case_Product__c> updatedCaseProductsMap = new Map<Id, ZTS_US_Case_Product__c>([
            SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Diluent__c, Primary_Batch_Detail__c
            FROM ZTS_US_Case_Product__c
            WHERE Id in: caseProductIds
        ]);

        for (Batch_Detail__c testBatchDetail : updateBatchDetails) {
            ZTS_US_Case_Product__c parentCaseProduct = updatedCaseProductsMap.get(testBatchDetail.ZTS_US_Case_Product__c);

            if (testBatchDetail.Id == parentCaseProduct.Primary_Batch_Detail__c) {
                System.assertEquals(testBatchDetail.ZTS_US_Product_Lot__c, parentCaseProduct.ZTS_US_Product_Lot__c,
                    'Lot # should have synced from Batch Detail to Case Product.');

                System.assertEquals(testBatchDetail.ZTS_US_Serial_Number__c, parentCaseProduct.ZTS_US_Serial_Number__c,
                    'Serial # should have synced from Batch Detail to Case Product.');

                System.assertEquals(testBatchDetail.ZTS_US_Diluent__c, parentCaseProduct.ZTS_US_Diluent__c,
                    'Diluent # should have synced from Batch Detail to Case Product.');
            }
            else {
                System.assertNotEquals(testBatchDetail.ZTS_US_Product_Lot__c, parentCaseProduct.ZTS_US_Product_Lot__c,
                    'Lot # should not have synced from Batch Detail to Case Product.');

                System.assertNotEquals(testBatchDetail.ZTS_US_Serial_Number__c, parentCaseProduct.ZTS_US_Serial_Number__c,
                    'Serial # should not have synced from Batch Detail to Case Product.');

                System.assertNotEquals(testBatchDetail.ZTS_US_Diluent__c, parentCaseProduct.ZTS_US_Diluent__c,
                    'Diluent # should not have synced from Batch Detail to Case Product.');
            }
        }
    }

    // This is an edge case, but is tested to confirm that only the Primary Batch Detail can update a Case.
    @isTest
    private static void syncUpdatedBatchDetailsToCaseProduct_UpdateMultiplePrimaryBatchDetailCaseProductUpdate_Test() {
        Batch_Detail__c originalPrimaryBatchDetail = retrieveExistingPrimaryBatchDetail();

        Id caseProductId = originalPrimaryBatchDetail.ZTS_US_Case_Product__c;

        Batch_Detail__c additionalPrimaryBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1,caseProductId)[0];
        additionalPrimaryBatchDetail.ZTS_US_Primary__c = true;

        // Turn off the Batch Detail Trigger to avoid changing the Primary Case Product
        DispatchTriggerHandler.bypass('BatchDetailTriggerHandler');
        insert additionalPrimaryBatchDetail;
        DispatchTriggerHandler.clearBypass('BatchDetailTriggerHandler');

        originalPrimaryBatchDetail.ZTS_US_Product_Lot__c = '9553';
        originalPrimaryBatchDetail.ZTS_US_Serial_Number__c = '3234';
        originalPrimaryBatchDetail.ZTS_US_Diluent__c = '1223';

        additionalPrimaryBatchDetail.ZTS_US_Product_Lot__c = '4182';
        additionalPrimaryBatchDetail.ZTS_US_Serial_Number__c = '5612';
        additionalPrimaryBatchDetail.ZTS_US_Diluent__c = '3891';

        Test.startTest();
            update new List<Batch_Detail__c> {originalPrimaryBatchDetail, additionalPrimaryBatchDetail};
        Test.stopTest();

        ZTS_US_Case_Product__c updatedCaseProduct = retrieveCaseProductWithProductDetails(caseProductId);

        System.assertEquals(originalPrimaryBatchDetail.ZTS_US_Product_Lot__c, updatedCaseProduct.ZTS_US_Product_Lot__c,
            String.format(
                'Lot # should have synced from the original Batch Detail to Case Product. Additional Batch Detail {0}',
                new List<String> {additionalPrimaryBatchDetail.ZTS_US_Product_Lot__c}));

        System.assertEquals(originalPrimaryBatchDetail.ZTS_US_Serial_Number__c, updatedCaseProduct.ZTS_US_Serial_Number__c,
            String.format(
                'Serial # should have synced from the original Batch Detail to Case Product. Additional Batch Detail {0}',
                new List<String> {additionalPrimaryBatchDetail.ZTS_US_Serial_Number__c}));

        System.assertEquals(originalPrimaryBatchDetail.ZTS_US_Diluent__c, updatedCaseProduct.ZTS_US_Diluent__c,
            String.format(
                'Diluent # should have synced from the original Batch Detail to Case Product. Additional Batch Detail {0}',
                new List<String> {additionalPrimaryBatchDetail.ZTS_US_Diluent__c}));
    }

    @isTest
    private static void setPrimaryBatchDetailOnCaseProduct_InsertPrimaryBatchDetail_Test() {
        ZTS_US_Case_Product__c caseProduct = retrieveExistingCaseProductWithoutBatchDetail();

        Batch_Detail__c batchDetail = ZTS_DataUtilityTest.createBatchDetails(1, caseProduct.Id)[0];
        batchDetail.ZTS_US_Primary__c = true;
        batchDetail.ZTS_US_Product_Lot__c = '9553';

        Test.startTest();
            insert batchDetail;
        Test.stopTest();

        ZTS_US_Case_Product__c updatedCaseProduct = retrieveCaseProductWithProductDetails(caseProduct.Id);

        System.assertEquals(batchDetail.Id, updatedCaseProduct.Primary_Batch_Detail__c,
            'Primary Batch Detail was not set properly.');

        System.assertEquals(batchDetail.ZTS_US_Product_Lot__c, updatedCaseProduct.ZTS_US_Product_Lot__c,
            'Lot # was not synced from Batch Detail to Case Product.');
    }

    @isTest
    private static void setPrimaryBatchDetailOnCaseProduct_InsertNonPrimaryBatchDetail_Test() {
        ZTS_US_Case_Product__c caseProduct = retrieveExistingCaseProductWithPrimaryBatchDetail();

        Batch_Detail__c batchDetail = ZTS_DataUtilityTest.createBatchDetails(1, caseProduct.Id)[0];
        batchDetail.ZTS_US_Primary__c = false;
        batchDetail.ZTS_US_Product_Lot__c = '9553';

        Test.startTest();
            insert batchDetail;
        Test.stopTest();

        ZTS_US_Case_Product__c updatedCaseProduct = retrieveCaseProductWithProductDetails(caseProduct.Id);

        System.assertNotEquals(updatedCaseProduct.Primary_Batch_Detail__c, batchDetail.Id,
            'Primary Batch Detail should not have been set to the non-Primary Batch Detail.');

        System.assertNotEquals(batchDetail.ZTS_US_Product_Lot__c, updatedCaseProduct.ZTS_US_Product_Lot__c,
            'Lot # should not have synced from the non-Primary Batch Detail to Case Product.');
    }

    @isTest
    private static void setPrimaryBatchDetailOnCaseProduct_InsertMultipleBatchDetails_Test() {
        Case testCase = retrieveTestCase(CREATE_BATCH_DETAIL_CASE_SUBJECT);
        ZTS_US_PVW_Product__c pvwProduct = retrievePvwProduct();

        List<ZTS_US_Case_Product__c> testCaseProducts = ZTS_DataUtilityTest.createCaseProducts(3, zoetisProductRecordTypeId,
            testCase.Id, pvwProduct.Id);

        // Set a Lot # on the Case Product to cause a Batch Detail to be created and the Batch Details below to not be
        // made Primary
        testCaseProducts[2].ZTS_US_Product_Lot__c = '9313';

        insert testCaseProducts;

        List<Batch_Detail__c> newBatchDetails = new List<Batch_Detail__c>();
        Batch_Detail__c caseProduct1PrimaryBatchDetail;
        List<Batch_Detail__c> caseProduct2PrimaryBatchDetails = new List<Batch_Detail__c>();
        List<Batch_Detail__c> caseProduct3NonPrimaryBatchDetails = new List<Batch_Detail__c>();
        for (integer i = 0; i < testCaseProducts.size(); i++) {
            ZTS_US_Case_Product__c testCaseProduct = testCaseProducts[i];
            if (i == 0) {
                // Setup a single Primary Batch Detail
                caseProduct1PrimaryBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1, testCaseProduct.Id)[0];
                caseProduct1PrimaryBatchDetail.ZTS_US_Primary__c = true;
                newBatchDetails.add(caseProduct1PrimaryBatchDetail);
            }
            else if (i == 1) {
                // Setup multiple Primary Batch Details.
                // This is an edge case, but only one should be used.
                caseProduct2PrimaryBatchDetails.addAll(ZTS_DataUtilityTest.createBatchDetails(2, testCaseProduct.Id));

                for (Batch_Detail__c batchDetail : caseProduct2PrimaryBatchDetails) {
                    batchDetail.ZTS_US_Primary__c = true;
                }

                newBatchDetails.addAll(caseProduct2PrimaryBatchDetails);
            }
            else {
                caseProduct3NonPrimaryBatchDetails.addAll(ZTS_DataUtilityTest.createBatchDetails(2, testCaseProduct.Id));
                // Setup only non-primary batch details
                newBatchDetails.addAll(caseProduct3NonPrimaryBatchDetails);
            }
        }

        // Clear First Time Tracker to allow the Batch Detail Trigger to run again
        DispatchTriggerHandler.firstTimeTracker.clear();
        Test.startTest();
            insert newBatchDetails;
        Test.stopTest();

        for (ZTS_US_Case_Product__c caseProduct : [SELECT Id, Primary_Batch_Detail__c
                                                  FROM ZTS_US_Case_Product__c
                                                  WHERE Id in: testCaseProducts]) {
            if (caseProduct.Id == testCaseProducts[0].Id) {
                System.assertEquals(caseProduct1PrimaryBatchDetail.Id, caseProduct.Primary_Batch_Detail__c,
                    'Primary Batch Detail was not set properly on Case Product 1');
            }
            else if (caseProduct.Id == testCaseProducts[1].Id) {
                // The Primary Batch Details should be set to one of the Primary Batch Details
                Set<Id> primaryBatchDetailIds = new Map<Id, Batch_Detail__c>(caseProduct2PrimaryBatchDetails).keySet();
                System.assert(primaryBatchDetailIds.contains(caseProduct.Primary_Batch_Detail__c),
                    String.format('Primary Batch Detail was not set to one of the following values on Case Product 2: {0}. Actual: {1}',
                        new List<object> {primaryBatchDetailIds, caseProduct.Primary_Batch_Detail__c}));
            }
            else {
                Set<Id> nonPrimaryBatchDetailIds = new Map<Id, Batch_Detail__c>(caseProduct3NonPrimaryBatchDetails).keySet();
                System.assert(!nonPrimaryBatchDetailIds.contains(caseProduct.Primary_Batch_Detail__c),
                    String.format('Primary Batch Detail should not be set to one of the non Primary on Case Product 3. Primary Batch Detail: {0} Non Primary Batch Details: {1}',
                        new List<Object> {nonPrimaryBatchDetailIds, caseProduct.Primary_Batch_Detail__c}));
            }
        }
    }

    @isTest
    private static void clearProductDetailsWherePrimaryBatchDetailBlank_DeletePrimaryBatchDetail_Test() {
        Batch_Detail__c primaryBatchDetail = retrieveExistingPrimaryBatchDetail();
        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductWithProductDetails(primaryBatchDetail.ZTS_US_Case_Product__c);

        System.assertEquals(primaryBatchDetail.Id, caseProduct.Primary_Batch_Detail__c,
            'Sanity Check failed. Primary Batch Detail is not set as expected.');

        System.assertEquals(primaryBatchDetail.ZTS_US_Product_Lot__c, caseProduct.ZTS_US_Product_Lot__c,
            'Sanity Check failed. Lot # does not match between Case Product and Batch Detail');

        System.assertEquals(primaryBatchDetail.ZTS_US_Serial_Number__c, caseProduct.ZTS_US_Serial_Number__c,
            'Sanity Check failed. Serial # does not match between Case Product and Batch Detail');

        System.assertEquals(primaryBatchDetail.ZTS_US_Diluent__c, caseProduct.ZTS_US_Diluent__c,
            'Sanity Check failed. Diluent # does not match between Case Product and Batch Detail');

        Test.startTest();
            delete primaryBatchDetail;
        Test.stopTest();

        caseProduct = retrieveCaseProductWithProductDetails(primaryBatchDetail.ZTS_US_Case_Product__c);

        System.assertEquals(null, caseProduct.Primary_Batch_Detail__c,
            'Primary Batch Detail should have been cleared');

        System.assert(String.isBlank(caseProduct.ZTS_US_Product_Lot__c),
            'Lot # was not cleared on Case Product.');

        System.assert(String.isBlank(caseProduct.ZTS_US_Serial_Number__c),
            'Serial # was not cleared on Case Product.');

        System.assert(String.isBlank(caseProduct.ZTS_US_Diluent__c),
            'Diluent # was not cleared on Case Product.');
    }

    @isTest
    private static void clearProductDetailsWherePrimaryBatchDetailBlank_DeleteNonPrimaryBatchDetail_Test() {
        Batch_Detail__c nonprimaryBatchDetail = retrieveExistingNonPrimaryBatchDetail();
        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductWithProductDetails(nonprimaryBatchDetail.ZTS_US_Case_Product__c);

        System.assertNotEquals(nonprimaryBatchDetail.Id, caseProduct.Primary_Batch_Detail__c,
            'Sanity Check failed. Primary Batch Detail is set to the non-Primary Batch Detail.');

        Test.startTest();
            delete nonprimaryBatchDetail;
        Test.stopTest();

        ZTS_US_Case_Product__c postDeletionCaseProduct = retrieveCaseProductWithProductDetails(caseProduct.Id);

        System.assertEquals(caseProduct.Primary_Batch_Detail__c, postDeletionCaseProduct.Primary_Batch_Detail__c,
            'Primary Batch Detail changed unexpectedly.');

        System.assertEquals(caseProduct.ZTS_US_Product_Lot__c, postDeletionCaseProduct.ZTS_US_Product_Lot__c,
            'Lot # changed unexpectedly.');

        System.assertEquals(caseProduct.ZTS_US_Serial_Number__c, postDeletionCaseProduct.ZTS_US_Serial_Number__c,
            'Serial # changed unexpectedly.');

        System.assertEquals(caseProduct.ZTS_US_Diluent__c, postDeletionCaseProduct.ZTS_US_Diluent__c,
            'Diluent # changed unexpectedly');
    }

    @isTest
    private static void clearProductDetailsWherePrimaryBatchDetailBlank_DeleteMultipleBatchDetail_Test() {
        Case testCase = retrieveTestCase(CREATE_BATCH_DETAIL_CASE_SUBJECT);
        ZTS_US_PVW_Product__c pvwProduct = retrievePvwProduct();

        List<ZTS_US_Case_Product__c> testCaseProducts = ZTS_DataUtilityTest.createCaseProducts(3, zoetisProductRecordTypeId,
            testCase.Id, pvwProduct.Id);

        // Setting these fields will automatically create Primary Batch Details
        for (ZTS_US_Case_Product__c caseProduct : testCaseProducts) {
            caseProduct.ZTS_US_Product_Lot__c = '4213';
            caseProduct.ZTS_US_Serial_Number__c = '4713';
            caseProduct.ZTS_US_Diluent__c = '8419';
        }

        insert testCaseProducts;

        // Create Non-Primary Batch Details for each Case Product
        Map<Id, List<Batch_Detail__c>> additionalBatchDetailsByCaseProductId = new Map<Id, List<Batch_Detail__c>>();
        List<Batch_Detail__c> additionalBatchDetails = new List<Batch_Detail__c>();
        for (integer i = 0; i < testCaseProducts.size(); i++) {
            ZTS_US_Case_Product__c testCaseProduct = testCaseProducts[i];
            List<Batch_Detail__c> caseProductBatchDetails = ZTS_DataUtilityTest.createBatchDetails(2, testCaseProduct.Id);

            additionalBatchDetailsByCaseProductId.put(testCaseProduct.Id, caseProductBatchDetails);
            additionalBatchDetails.addAll(caseProductBatchDetails);
        }

        insert additionalBatchDetails;

        // Reretrieve the Case Products to get the Primary Batch Detail
        testCaseProducts = [
            SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Diluent__c, Primary_Batch_Detail__c
            FROM ZTS_US_Case_Product__c
            WHERE Id in: testCaseProducts
        ];

        List<Batch_Detail__c> deleteBatchDetails = new List<Batch_Detail__c>();
        // Delete the Primary Batch Details for Case Product 0 and 1
        deleteBatchDetails.add(new Batch_Detail__c(Id = testCaseProducts[0].Primary_Batch_Detail__c));
        deleteBatchDetails.add(new Batch_Detail__c(Id = testCaseProducts[1].Primary_Batch_Detail__c));

        // Delete non-Primary Batch Details on other Cases
        deleteBatchDetails.add(additionalBatchDetailsByCaseProductId.get(testCaseProducts[0].Id)[0]);
        deleteBatchDetails.addAll(additionalBatchDetailsByCaseProductId.get(testCaseProducts[1].Id));
        deleteBatchDetails.addAll(additionalBatchDetailsByCaseProductId.get(testCaseProducts[2].Id));

        // Clear First Time Tracker to allow the Batch Detail Trigger to run again
        DispatchTriggerHandler.firstTimeTracker.clear();
        Test.startTest();
            delete deleteBatchDetails;
        Test.stopTest();

        for (ZTS_US_Case_Product__c postDeleteCaseProduct : [
            SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Diluent__c, Primary_Batch_Detail__c
            FROM ZTS_US_Case_Product__c
            WHERE Id in: testCaseProducts]) {

            // Primary Batch Detail should be cleared on this Case Product
            if (postDeleteCaseProduct.Id != testCaseProducts[2].Id) {
                System.assertEquals(null, postDeleteCaseProduct.Primary_Batch_Detail__c,
                    'Primary Batch Detail should have been cleared');

                System.assert(String.isBlank(postDeleteCaseProduct.ZTS_US_Product_Lot__c),
                    'Lot # was not cleared on Case Product.');

                System.assert(String.isBlank(postDeleteCaseProduct.ZTS_US_Serial_Number__c),
                    'Serial # was not cleared on Case Product.');

                System.assert(String.isBlank(postDeleteCaseProduct.ZTS_US_Diluent__c),
                    'Diluent # was not cleared on Case Product.');
            }
            else {
                System.assertEquals(testCaseProducts[2].Primary_Batch_Detail__c,
                    postDeleteCaseProduct.Primary_Batch_Detail__c, 'Primary Batch Detail changed unexpectedly.');

                System.assertEquals(testCaseProducts[2].ZTS_US_Product_Lot__c,
                    postDeleteCaseProduct.ZTS_US_Product_Lot__c, 'Lot # changed unexpectedly.');

                System.assertEquals(testCaseProducts[2].ZTS_US_Serial_Number__c,
                    postDeleteCaseProduct.ZTS_US_Serial_Number__c, 'Serial # changed unexpectedly.');

                System.assertEquals(testCaseProducts[2].ZTS_US_Diluent__c, postDeleteCaseProduct.ZTS_US_Diluent__c,
                    'Diluent # changed unexpectedly');
            }
        }
    }

    // This test just verifies that Qualifier is reevaluated properly for a few different Cases
    // More detailed tests can be found in BatchDetailServiceTest
    // As there is just one test, this method creates most of its own data
    // 12.16.22 Commenting out batch test method since batch recaculate functionality is not active in trigger.
    //Commenting the below logic. Currently the system won't allow you to change the pvw product in the existing case product based on the CASS - 451
    /* 
    @isTest
    private static void reevaluteRelatedBatchDetailQualifiers_General_Test() {
        List<ZTS_US_PVW_Product__c> pvwProducts = [
            SELECT Id
            FROM ZTS_US_PVW_Product__c
            WHERE NAME in: new List<String> {PVW_PRODUCT_1_NAME, PVW_PRODUCT_2_NAME}
            LIMIT 2];

        List<ZTS_US_PVW_Batch_Number__c> product1BatchNumbers = new List<ZTS_US_PVW_Batch_Number__c>();
        product1BatchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[0].Id, '9310', 'LOT', 1000));
        product1BatchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[0].Id, '4812', 'SER', 2000));
        product1BatchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[0].Id, '3192', 'LOT', 3000));
        product1BatchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[0].Id, '6512', 'SER', 3000));

        List<ZTS_US_PVW_Batch_Number__c> product2BatchNumbers = new List<ZTS_US_PVW_Batch_Number__c>();
        product2BatchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[1].Id, '9130', 'LOT', 4000));
        product2BatchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[1].Id, '9310', 'LOT', 1000));
        product2BatchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[1].Id, '4812', 'SER', 2000));

        List<ZTS_US_PVW_Batch_Number__c> allBatchNumbers = new List<ZTS_US_PVW_Batch_Number__c>();
        allBatchNumbers.addAll(product1BatchNumbers);
        allBatchNumbers.addAll(product2BatchNumbers);
        insert allBatchNumbers;

        Case testCase = retrieveTestCase(CREATE_BATCH_DETAIL_CASE_SUBJECT);

        List<ZTS_US_Case_Product__c> caseProducts = new List<ZTS_US_Case_Product__c>();
        caseProducts.add(ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, testCase.Id,
            pvwProducts[0].Id)[0]);

        caseProducts.add(ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, testCase.Id,
            pvwProducts[1].Id)[0]);

        // Create a Primary Batch Detail to test logic specific for the Primary record
        caseProducts[1].ZTS_US_Product_Lot__c = product1BatchNumbers[2].ZTS_US_Batch_Number__c;

        insert caseProducts;

        Batch_Detail__c existingPrimaryBatchDetail = [
            SELECT Id
            FROM Batch_Detail__c
            WHERE ZTS_US_Case_Product__c =: caseProducts[1].Id];

        List<Batch_Detail__c> caseProduct1BatchDetails = ZTS_DataUtilityTest.createBatchDetails(4, caseProducts[0].Id);
        caseProduct1BatchDetails[0].ZTS_US_Product_Lot__c = product1BatchNumbers[0].ZTS_US_Batch_Number__c;
        caseProduct1BatchDetails[1].ZTS_US_Serial_Number__c = product1BatchNumbers[1].ZTS_US_Batch_Number__c;
        caseProduct1BatchDetails[2].ZTS_US_Product_Lot__c = product2BatchNumbers[0].ZTS_US_Batch_Number__c;
        caseProduct1BatchDetails[3].ZTS_US_Product_Lot__c = product1BatchNumbers[2].ZTS_US_Batch_Number__c;
        caseProduct1BatchDetails[3].ZTS_US_Serial_Number__c = product1BatchNumbers[3].ZTS_US_Batch_Number__c;

        List<Batch_Detail__c> caseProduct2BatchDetails = ZTS_DataUtilityTest.createBatchDetails(3, caseProducts[1].Id);
        caseProduct2BatchDetails[0].ZTS_US_Serial_Number__c = product2BatchNumbers[2].ZTS_US_Batch_Number__c;
        caseProduct2BatchDetails[1].ZTS_US_Product_Lot__c = product1BatchNumbers[2].ZTS_US_Batch_Number__c;
        caseProduct2BatchDetails[1].ZTS_US_Serial_Number__c = product1BatchNumbers[3].ZTS_US_Batch_Number__c;
        caseProduct2BatchDetails[2].ZTS_US_Product_Lot__c = product2BatchNumbers[0].ZTS_US_Batch_Number__c;

        List<Batch_Detail__c> allBatchDetails = new List<Batch_Detail__c>();
        allBatchDetails.addAll(caseProduct1BatchDetails);
        allBatchDetails.addAll(caseProduct2BatchDetails);
        insert allBatchDetails;

        caseProducts[0].ZTS_US_PVW_Product__c = pvwProducts[1].Id;
        caseProducts[1].ZTS_US_PVW_Product__c = pvwProducts[0].Id;

        // Clear First Time Tracker so the Update Case Product Trigger can run again.
        // A Workflow Rule causes it to run on insert
        DispatchTriggerHandler.firstTimeTracker.clear();
        Test.startTest();
        update caseProducts;
        Test.stopTest();

        for (Batch_Detail__c batchDetail : [
            SELECT Id, Lot_Qualifier__c, Serial_Qualifier__c, ZTS_US_Serial_Number__c, ZTS_US_Case_Product__r.ZTS_US_Serial_Number__c
            FROM Batch_Detail__c
            WHERE ZTS_US_Case_Product__c in: caseProducts]) {
            if (batchDetail.Id == caseProduct1BatchDetails[0].Id) {
                System.assertEquals('Valid', batchDetail.Lot_Qualifier__c,
                    'Lot Qualifier should be valid for the new Product.');
            }
            else if (batchDetail.Id == caseProduct1BatchDetails[1].Id) {
                System.assertEquals('Valid', batchDetail.Serial_Qualifier__c,
                    'Serial Qualifier should be valid for the new Product.');
            }
            else if (batchDetail.Id == caseProduct1BatchDetails[2].Id) {
                System.assertEquals('Valid', batchDetail.Lot_Qualifier__c,
                    'Lot Qualifier should be valid for the new Product.');
            }
            else if (batchDetail.Id == caseProduct1BatchDetails[3].Id) {
                System.assertEquals('Invalid', batchDetail.Lot_Qualifier__c,
                    'Lot Qualifier should be invalid for the new Product.');
                System.assertEquals('Invalid', batchDetail.Serial_Qualifier__c,
                    'Serial Qualifier should be invalid for the new Product.');
            }
            else if (batchDetail.Id == caseProduct2BatchDetails[0].Id) {
                System.assertEquals('Valid', batchDetail.Serial_Qualifier__c,
                    'Serial Qualifier should be valid for the new Product.');
            }
            else if (batchDetail.Id == caseProduct2BatchDetails[1].Id) {
                System.assertEquals('Valid', batchDetail.Lot_Qualifier__c,
                    'Lot Qualifier should be valid for the new Product.');
                System.assertEquals('Valid', batchDetail.Serial_Qualifier__c,
                    'Serial Qualifier should be valid for the new Product.');
            }
            else if (batchDetail.Id == caseProduct2BatchDetails[2].Id) {
                System.assertEquals('Invalid', batchDetail.Lot_Qualifier__c,
                    'Lot Qualifier should be invalid for the new Product.');
            }
            else if (batchDetail.Id == existingPrimaryBatchDetail.Id) {
                System.assertEquals('Valid', batchDetail.Lot_Qualifier__c,
                    'Lot Qualifier should be valid for the new Product.');
                System.assertEquals(product1BatchNumbers[3].ZTS_US_Batch_Number__c,
                    batchDetail.ZTS_US_Serial_Number__c, 'Serial Number was not set as expected on Batch Detail.');
                System.assertEquals(product1BatchNumbers[3].ZTS_US_Batch_Number__c,
                    batchDetail.ZTS_US_Case_Product__r.ZTS_US_Serial_Number__c, 'Serial Number was not set as expected on Case Product.');
                System.assertEquals('Valid', batchDetail.Serial_Qualifier__c,
                    'Serial Qualifier should be valid for the new Product.');
            }
        }
    }*/

    @isTest
    private static void testCaseProductMerge(){
        Case testCase = retrieveTestCase(CREATE_BATCH_DETAIL_CASE_SUBJECT);

        ZTS_US_PVW_Product__c pvwProduct = retrievePvwProduct();

        ZTS_US_Case_Product__c caseProduct = ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId,
            testCase.Id, pvwProduct.Id)[0];

        caseProduct.ZTS_US_Product_Lot__c = '1234';
        insert caseProduct;

        Batch_Detail__c testBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1, caseProduct.Id)[0];
        testBatchDetail.ZTS_US_Product_Lot__c = '5678';
        insert testBatchDetail;

        //this original case product should now have two batch details, one for the insert of a product with lot number, one from manual creation.
        //clone the case product, the clone should have two batch details also.

        // Clear First Time Tracker to allow the Case Product Trigger to run again
        DispatchTriggerHandler.firstTimeTracker.clear();
        Test.startTest();
        ZTS_US_Case_Product__c caseProductClone = caseProduct.clone(false,false,false,false);
        insert caseProductClone;
        Test.stopTest();
        List<Batch_Detail__c> originalBatchDetails = retrieveBatchDetailsForCaseProduct(caseProduct.Id);

        System.assertEquals(2, originalBatchDetails.size(), '2 Batch Detail should have been created.');

        List<Batch_Detail__c> cloneBatchDetails = retrieveBatchDetailsForCaseProduct(caseProductClone.Id);

        System.assertEquals(2, cloneBatchDetails.size(), '2 Batch Detail should have been created.');
    }

    // Tests that there will always be one case product on the case where the start date is before the
    // earliest start date for all vedra events on the same case
    @isTest
    private static void validateFirstAdministrationStartDate_Test() {
        Case testCase = retrieveTestCase(CREATE_BATCH_DETAIL_CASE_SUBJECT);

        // get case product for case
        ZTS_US_Case_Product__c testCaseProduct_1 = retrieveCaseProductForCaseCase(testCase.Id);
		System.debug(testCaseProduct_1);
        
        if (testCase.ZTS_US_Event_Narrative__c == null) {
        	List<ZTS_US_Event_Narrative__c> evtNarratives = ZTS_DataUtilityTest.createEventNarratives(1, testCase.Id);
            insert evtNarratives;
        }

        // createVeddraCodings
        List<ZTS_US_VedDRA_Coding__c> vedraCodes = ZTS_DataUtilityTest.createVeddraCodings(1);
        insert vedraCodes;

        // createVeddraEvent
        ZTS_US_VedDRA_Event__c veDRAEvt = new ZTS_US_VedDRA_Event__c(
            ZTS_US_Event_Narrative__c = testCase.ZTS_US_Event_Narrative__c,
            ZTS_US_VedDRA_Coding__c = vedraCodes[0].Id,
            ZTS_US_Start_Date__c = DateTime.now()
        );
        
        insert veDRAEvt;
		
        if (veDRAEvt.ZTS_US_Event_Narrative__c != testCase.ZTS_US_Event_Narrative__c) system.debug('EVT Narrative ids dont match');
        DispatchTriggerHandler.firstTimeTracker.clear();
        // update case product start date
        Test.startTest();
        // assign date to one day before vedra event
        DateTime veDRADateTime = veDRAEvt.ZTS_US_Start_Date__c;
        DateTime oneDayBeforeVeDRA = veDRADateTime.addDays(-1);
        DateTime daysAfterVedra = veDRADateTime.addDays(41);
        testCaseProduct_1.ZTS_US_Start_Date__c = daysAfterVedra.date();
        //System.debug(testCaseProduct_1)
        //Database.SaveResult dateOneDaybefore_Result = Database.update(testCaseProduct_1);
       // DispatchTriggerHandler.firstTimeTracker.clear();
        // Clear First Time Tracker to allow the Case Product Trigger to run again
        // assign date to same day as vedra event
        //Database.SaveResult dateDayOf_Result = Database.update(testCaseProduct_1);
        // assign date to one day after vedra event
        String errorMsg = '';
        List<string> fieldname;
        DmlException except;
        try {
             update testCaseProduct_1;
        } catch(DmlException ex) {
            errorMsg = ex.getMessage();
            except = ex;
        }
        System.debug('validateFirstAdministrationStartDate_Test::DEBUG: - ' +testCaseProduct_1.Id);
        // insert a second case where the start date is valide
        // insert a third case where the start date is after
        DmlException insert_exception;
        testCaseProduct_1.Id = null;
        try {
            insert testCaseProduct_1;
        System.debug('validateFirstAdministrationStartDate_Test::DEBUG: - ' +testCaseProduct_1.Id);
        }catch(DmlException e) {
            System.debug('Failed');
            insert_exception = e;
        }

        Test.stopTest();
        // verify results:
        System.assertNotEquals(errorMsg,null,  'Failed to stop update to start date on case product');
        System.assertNotEquals(except,null,  'Failed to stop update to start date on case product');
        System.assertEquals(insert_exception,null, 'Failed to allow a new case product with a valid start date');
    }

    private static Case retrieveTestCase(String caseSubject) {
        return [
            SELECT Id, ZTS_US_Event_Narrative__c
            FROM Case
            WHERE Subject =: caseSubject
            LIMIT 1];
    }

    private static ZTS_US_PVW_Product__c retrievePvwProduct() {
        return [
            SELECT Id
            FROM ZTS_US_PVW_Product__c
            WHERE Name =: PVW_PRODUCT_1_NAME
            LIMIT 1];
    }

    private static List<Batch_Detail__c> retrieveBatchDetailsForCaseProduct(Id caseProductId) {
        return [
            SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Diluent__c, ZTS_US_Primary__c
            FROM Batch_Detail__c
            WHERE ZTS_US_Case_Product__c =: caseProductId
        ];
    }

    private static ZTS_US_Case_Product__c retrieveExistingCaseProductWithPrimaryBatchDetail() {
        return [
            SELECT Id
            FROM ZTS_US_Case_Product__c
            WHERE ZTS_US_Product_Lot__c != null
            LIMIT 1
        ];
    }

    private static ZTS_US_Case_Product__c retrieveExistingCaseProductWithNonPrimaryBatchDetail() {
        return [
            SELECT Id
            FROM ZTS_US_Case_Product__c
            WHERE ZTS_US_Product_Lot__c != null
            AND ZTS_US_PVW_Product__r.Name =: PVW_PRODUCT_2_NAME
            LIMIT 1
        ];
    }

    private static ZTS_US_Case_Product__c retrieveExistingCaseProductWithoutBatchDetail() {
        return [
            SELECT Id
            FROM ZTS_US_Case_Product__c
            WHERE ZTS_US_Product_Lot__c = null
            AND ZTS_US_PVW_Product__r.Name =: PVW_PRODUCT_1_NAME
            LIMIT 1
        ];
    }

    private static Batch_Detail__c retrieveExistingPrimaryBatchDetail() {
        return [
            SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Diluent__c, ZTS_US_Primary__c,
                   ZTS_US_Case_Product__c
            FROM Batch_Detail__c
            WHERE ZTS_US_Primary__c = true
            LIMIT 1
        ];
    }

    private static Batch_Detail__c retrieveExistingNonPrimaryBatchDetail() {
        return [
            SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Diluent__c, ZTS_US_Primary__c,
                   ZTS_US_Case_Product__c
            FROM Batch_Detail__c
            WHERE ZTS_US_Primary__c = false
            LIMIT 1
        ];
    }

    private static ZTS_US_Case_Product__c retrieveCaseProductWithProductDetails(Id caseProductId) {
        return [
            SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Diluent__c, Primary_Batch_Detail__c
            FROM ZTS_US_Case_Product__c
            WHERE Id =: caseProductId
            LIMIT 1
        ];
    }

    private static ZTS_US_Case_Product__c retrieveCaseProductForCaseCase(Id caseId) {
        return [
            SELECT Id, ZTS_US_Start_Date__c, ZTS_US_Case__c
            FROM ZTS_US_Case_Product__c
            WHERE ZTS_US_Case__c =: caseId
            LIMIT 1];
    }

}