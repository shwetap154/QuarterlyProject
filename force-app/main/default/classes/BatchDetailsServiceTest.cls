/**
 * @description       : Test class for BatchDetailsService
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-18-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-18-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for setFieldsFromPVWProduct method
 * 1.1   07-20-2022   Ethan Hirsch @ Zoetis Inc   Update assertions to verify Lot/Serial Expiry Date and 
 *                                                Expiry Date Approx are cleared out when Lot/Serial are cleared
 *                                                out or set to Invalid values.
 **/
@isTest
private class BatchDetailsServiceTest {
    private static final String QUALIFIER_CASE_SUBJECT_1 = 'Qualif1';
    private static final String QUALIFIER_CASE_SUBJECT_2 = 'Qualif2';

    // Only Lot 2 and Serial 2 go together
    private static final String TEST_LOT_NUMBER_1 = '1234';
    private static final String TEST_SERIAL_NUMBER_1 = '1234';
    private static final String TEST_LOT_NUMBER_2 = '7896';
    private static final String TEST_SERIAL_NUMBER_2 = '3452';
    private static final String TEST_LOT_NUMBER_3 = '9285';
    private static final String TEST_SERIAL_NUMBER_3 = '7861';
    private static final String TEST_INVALID_NUMBER = 'INVALID';
    // Product 1 has multiple Batch Numbers
    private static final String TEST_PVWPRODUCT_NAME_1 = 'PVW Product Test 1';
    // Product 2 just has 2 Batch Numbers
    private static final String TEST_PVWPRODUCT_NAME_2 = 'PVW Product Test 2';

    private static Date testExpiryDate = Date.today().addDays(-10);

    @TestSetup
    private static void setup_Test(){
        List<ZTS_US_PVW_Product__c> pvwProducts = ZTS_DataUtilityTest.createPvwProducts(2);
        pvwProducts[0].Name = TEST_PVWPRODUCT_NAME_1;
        pvwProducts[1].Name = TEST_PVWPRODUCT_NAME_2;
        insert pvwProducts;

        List<ZTS_US_PVW_Batch_Number__c> batchNumbers = new List<ZTS_US_PVW_Batch_Number__c>();
        batchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[0].Id, TEST_LOT_NUMBER_1, 'LOT', 1000));
        batchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[0].Id, TEST_SERIAL_NUMBER_1, 'SER', 2000));
        batchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[0].Id, TEST_LOT_NUMBER_2, 'LOT', 3000));
        batchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[0].Id, TEST_SERIAL_NUMBER_2, 'SER', 3000));
        batchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[1].Id, TEST_LOT_NUMBER_3, 'LOT', 4000));
        batchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[1].Id, TEST_SERIAL_NUMBER_3, 'SER', 5000));

        // Set Expiry Date Approx to Y on a few records for testing
        batchNumbers[0].ZTS_US_Expiry_Approximate__c = 'Y';
        batchNumbers[1].ZTS_US_Expiry_Approximate__c = 'Y';

        for (ZTS_US_PVW_Batch_Number__c batchNumber : batchNumbers) {
            batchNumber.ZTS_US_Expiry_Date__c = testExpiryDate;
        }

        // These Batch Numbers should be skipped for validation tests since their Expiry Date is later
        // than their duplicate records
        ZTS_US_PVW_Batch_Number__c additionalLotBatchNumber = ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[0].Id,
            TEST_LOT_NUMBER_1, 'LOT', 1000);

        additionalLotBatchNumber.ZTS_US_Expiry_Date__c = testExpiryDate.addDays(5);
        batchNumbers.add(additionalLotBatchNumber);

        ZTS_US_PVW_Batch_Number__c additionalSerialBatchNumber = ZTS_DataUtilityTest.createPVWBatchNumber(pvwProducts[0].Id,
            TEST_SERIAL_NUMBER_1, 'SER', 2000);

        additionalSerialBatchNumber.ZTS_US_Expiry_Date__c = testExpiryDate.addDays(5); 
        batchNumbers.add(additionalSerialBatchNumber);

        insert batchNumbers;

        Account testAccount = TestDataFactory.createAccount_US('Test Account 1', true);

        Id vmipsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        Case testVmipsCase1 = ZTS_DataUtilityTest.createCases(1, vmipsRecordTypeId)[0];
        testVmipsCase1.Subject = QUALIFIER_CASE_SUBJECT_1;
        testVmipsCase1.Type = 'Animal Complaint';
        testVmipsCase1.AccountId = testAccount.Id;

        Case testVmipsCase2 = ZTS_DataUtilityTest.createCases(1, vmipsRecordTypeId)[0];
        testVmipsCase2.Subject = QUALIFIER_CASE_SUBJECT_2;
        testVmipsCase2.Type = 'Animal Complaint';
        testVmipsCase2.AccountId = testAccount.Id;
        insert new List<Case> {testVmipsCase1, testVmipsCase2};

        Map<String, Schema.RecordTypeInfo> caseProductRecordTypesByDeveloperName = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName();
        Id zoetisProductRecordTypeId = caseProductRecordTypesByDeveloperName.get('Zoetis_Product').getRecordTypeId();
        Id nonZoetisProductRecordTypeId = caseProductRecordTypesByDeveloperName.get('Non_Zoetis_Product').getRecordTypeId();

        List<ZTS_US_Case_Product__c> caseProductsCase1 = new List<ZTS_US_Case_Product__c>();
        caseProductsCase1.add(ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, testVmipsCase1.Id,
            pvwProducts[0].Id)[0]);
        
        caseProductsCase1.add(ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, testVmipsCase1.Id,
            pvwProducts[1].Id)[0]);

        caseProductsCase1.add(ZTS_DataUtilityTest.createCaseProducts(1, nonZoetisProductRecordTypeId, testVmipsCase1.Id,
            null)[0]);
        caseProductsCase1[2].ZTS_US_Product_problem_type__c = null;

        List<ZTS_US_Case_Product__c> caseProductsCase2 = new List<ZTS_US_Case_Product__c>();
        caseProductsCase2.add(ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, testVmipsCase2.Id,
            pvwProducts[0].Id)[0]);
        
        caseProductsCase2.add(ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, testVmipsCase2.Id,
            pvwProducts[1].Id)[0]);

        List<ZTS_US_Case_Product__c> allCaseProducts = new List<ZTS_US_Case_Product__c>();
        allCaseProducts.addAll(caseProductsCase1);
        allCaseProducts.addAll(caseProductsCase2);

        insert allCaseProducts;

        List<Batch_Detail__c> case2Product1BatchDetails = ZTS_DataUtilityTest.createBatchDetails(3, caseProductsCase2[0].Id);
        case2Product1BatchDetails[0].ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_1;
        case2Product1BatchDetails[1].ZTS_US_Serial_Number__c = TEST_SERIAL_NUMBER_1;
        case2Product1BatchDetails[2].ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_2;
        case2Product1BatchDetails[2].ZTS_US_Serial_Number__c = TEST_SERIAL_NUMBER_2;

        List<Batch_Detail__c> case2Product2BatchDetails = ZTS_DataUtilityTest.createBatchDetails(2, caseProductsCase2[0].Id);
        case2Product2BatchDetails[0].ZTS_US_Product_Lot__c = TEST_INVALID_NUMBER;
        case2Product2BatchDetails[1].ZTS_US_Serial_Number__c = TEST_INVALID_NUMBER;

        List<Batch_Detail__c> allBatchDetails = new List<Batch_Detail__c>();
        allBatchDetails.addAll(case2Product1BatchDetails);
        allBatchDetails.addAll(case2Product2BatchDetails);

        insert allBatchDetails;
    }

    @isTest
    private static void setFieldsFromPVWProduct_InsertNonZoetisCaseProduct_Test() {
        ZTS_US_Case_Product__c nonZoetisCaseProduct = [
            SELECT ID 
            FROM ZTS_US_Case_Product__c
            WHERE RecordType.DeveloperName = 'Non_Zoetis_Product'
            AND ZTS_US_Case__r.Subject =: QUALIFIER_CASE_SUBJECT_1
            LIMIT 1
        ];

        Batch_Detail__c testBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1, nonZoetisCaseProduct.Id)[0];
        testBatchDetail.ZTS_US_Serial_Number__c = TEST_SERIAL_NUMBER_2;
        testBatchDetail.ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_2;

        Test.startTest();
            insert testBatchDetail;
        Test.stopTest();

        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        System.assertEquals(null, testBatchDetail.Lot_Qualifier__c, 'Lot Qualifier set unexpectedly');
        System.assertEquals(null, testBatchDetail.ZTS_US_Expiry_Date__c, 'Lot Expiry Date set unexpectedly');
        System.assertEquals(false, testBatchDetail.ZTS_US_Expiry_Date_Approx__c, 'Lot Expiry Date Approx set unexpectedly');
        System.assertEquals(null, testBatchDetail.Serial_Qualifier__c, 'Serial Qualifier set unexpectedly');
        System.assertEquals(null, testBatchDetail.ZTS_US_Serial_Expiry_Date__c, 'Serial Expiry set unexpectedly');
        System.assertEquals(false, testBatchDetail.ZTS_US_Serial_Expiry_Date_Approx__c,
            'Serial Expiry Date Approx set unexpectedly');
    }

    // This test also verifies Serial is not set for this Lot Number
    @isTest
    private static void setFieldsFromPVWProduct_InsertLotNumberValid_Test() {
        ZTS_US_Case_Product__c testCaseProduct = retrieveCaseProductByPVWProductNameAndSubject(TEST_PVWPRODUCT_NAME_1,
            QUALIFIER_CASE_SUBJECT_1);

        Batch_Detail__c testBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1, testCaseProduct.Id)[0];
        testBatchDetail.ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_1;

        ZTS_US_PVW_Batch_Number__c matchingBatchNumber = retrievePVWBatchNumberByNumberTypeAndProductId(
            testBatchDetail.ZTS_US_Product_Lot__c, 'LOT', testCaseProduct.ZTS_US_PVW_Product__c
        );

        Test.startTest();
            insert testBatchDetail;
        Test.stopTest();

        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        assertLotQualifierValid(testBatchDetail, matchingBatchNumber);

        System.assert(String.isBlank(testBatchDetail.ZTS_US_Serial_Number__c), 'Serial Number was set unexpectedly');
        System.assertEquals(null, testBatchDetail.Serial_Qualifier__c, 'Serial Qualifier set unexpectedly');
        System.assertEquals(null, testBatchDetail.ZTS_US_Serial_Expiry_Date__c, 'Serial Expiry set unexpectedly');
        System.assertEquals(false, testBatchDetail.ZTS_US_Serial_Expiry_Date_Approx__c,
            'Serial Expiry Date Approx set unexpectedly');
    }

    @isTest
    private static void setFieldsFromPVWProduct_InsertLotNumberValidFindSerialNumber_Test() {
        ZTS_US_Case_Product__c testCaseProduct = retrieveCaseProductByPVWProductNameAndSubject(TEST_PVWPRODUCT_NAME_1,
            QUALIFIER_CASE_SUBJECT_1);

        Batch_Detail__c testBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1, testCaseProduct.Id)[0];
        testBatchDetail.ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_2;

        ZTS_US_PVW_Batch_Number__c matchingLotBatchNumber;
        ZTS_US_PVW_Batch_Number__c matchingSerialBatchNumber;
        for (ZTS_US_PVW_Batch_Number__c batchNumber : retrievePvwBatchNumbers(
            new List<String> {TEST_LOT_NUMBER_2, TEST_SERIAL_NUMBER_2},
            new List<String> {'LOT', 'SER'},
            new List<Id> {testCaseProduct.ZTS_US_PVW_Product__c})) {

            if (batchNumber.ZTS_US_Batch_Type__c == 'LOT' && batchNumber.ZTS_US_Batch_Number__c == TEST_LOT_NUMBER_2) {
                matchingLotBatchNumber = batchNumber;
            }
            else if (batchNumber.ZTS_US_Batch_Type__c == 'SER' && 
                batchNumber.ZTS_US_Batch_Number__c == TEST_SERIAL_NUMBER_2) {
                matchingSerialBatchNumber = batchNumber;
            }
        }

        Test.startTest();
            insert testBatchDetail;
        Test.stopTest();

        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        assertLotQualifierValid(testBatchDetail, matchingLotBatchNumber);

        System.assertEquals(matchingSerialBatchNumber.ZTS_US_Batch_Number__c, testBatchDetail.ZTS_US_Serial_Number__c,
            'Serial Number was not found as expected.');

        assertSerialQualifierValid(testBatchDetail, matchingSerialBatchNumber);
    }

    @isTest
    private static void setFieldsFromPVWProduct_InsertLotNumberInvalid_Test() {
        ZTS_US_Case_Product__c testCaseProduct = retrieveCaseProductByPVWProductNameAndSubject(TEST_PVWPRODUCT_NAME_1,
            QUALIFIER_CASE_SUBJECT_1);

        Batch_Detail__c testBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1, testCaseProduct.Id)[0];
        testBatchDetail.ZTS_US_Product_Lot__c = '9103934';

        Test.startTest();
            insert testBatchDetail;
        Test.stopTest();

        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        assertLotQualifierInvalid(testBatchDetail);
    }

    @isTest
    private static void setFieldsFromPVWProduct_InsertSerialNumberValid_Test() {
        ZTS_US_Case_Product__c testCaseProduct = retrieveCaseProductByPVWProductNameAndSubject(TEST_PVWPRODUCT_NAME_1,
            QUALIFIER_CASE_SUBJECT_1);

        Batch_Detail__c testBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1, testCaseProduct.Id)[0];
        testBatchDetail.ZTS_US_Serial_Number__c = TEST_SERIAL_NUMBER_1;

        ZTS_US_PVW_Batch_Number__c matchingBatchNumber = retrievePVWBatchNumberByNumberTypeAndProductId(
            testBatchDetail.ZTS_US_Serial_Number__c, 'SER', testCaseProduct.ZTS_US_PVW_Product__c
        );

        Test.startTest();
            insert testBatchDetail;
        Test.stopTest();

        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        assertSerialQualifierValid(testBatchDetail, matchingBatchNumber);
    }

    @isTest
    private static void setFieldsFromPVWProduct_InsertSerialNumberInvalid_Test() {
        ZTS_US_Case_Product__c testCaseProduct = retrieveCaseProductByPVWProductNameAndSubject(TEST_PVWPRODUCT_NAME_1,
            QUALIFIER_CASE_SUBJECT_1);

        Batch_Detail__c testBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1, testCaseProduct.Id)[0];
        testBatchDetail.ZTS_US_Serial_Number__c = '9013815';

        Test.startTest();
            insert testBatchDetail;
        Test.stopTest();

        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        assertSerialQualifierInvalid(testBatchDetail);
    }

    @isTest
    private static void setFieldsFromPVWProduct_InsertLotAndSerialNumberValid_Test() {
        ZTS_US_Case_Product__c testCaseProduct = retrieveCaseProductByPVWProductNameAndSubject(TEST_PVWPRODUCT_NAME_1,
            QUALIFIER_CASE_SUBJECT_1);

        Batch_Detail__c testBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1, testCaseProduct.Id)[0];
        testBatchDetail.ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_2;
        testBatchDetail.ZTS_US_Serial_Number__c = TEST_SERIAL_NUMBER_2;

        ZTS_US_PVW_Batch_Number__c matchingLotBatchNumber;
        ZTS_US_PVW_Batch_Number__c matchingSerialBatchNumber;
        for (ZTS_US_PVW_Batch_Number__c batchNumber : retrievePvwBatchNumbers(
            new List<String> {TEST_LOT_NUMBER_2, TEST_SERIAL_NUMBER_2},
            new List<String> {'LOT', 'SER'},
            new List<Id> {testCaseProduct.ZTS_US_PVW_Product__c})) {

            if (batchNumber.ZTS_US_Batch_Type__c == 'LOT' && batchNumber.ZTS_US_Batch_Number__c == TEST_LOT_NUMBER_2) {
                matchingLotBatchNumber = batchNumber;
            }
            else if (batchNumber.ZTS_US_Batch_Type__c == 'SER' && 
                batchNumber.ZTS_US_Batch_Number__c == TEST_SERIAL_NUMBER_2) {
                matchingSerialBatchNumber = batchNumber;
            }
        }

        Test.startTest();
            insert testBatchDetail;
        Test.stopTest();

        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        assertLotQualifierValid(testBatchDetail, matchingLotBatchNumber);

        assertSerialQualifierValid(testBatchDetail, matchingSerialBatchNumber);
    }

    // The Serial Number and Lot Number used exist on the Product, but are not linked together
    @isTest
    private static void setFieldsFromPVWProduct_InsertLotAndSerialNumberInvalid_Test() {
        ZTS_US_Case_Product__c testCaseProduct = retrieveCaseProductByPVWProductNameAndSubject(TEST_PVWPRODUCT_NAME_1,
            QUALIFIER_CASE_SUBJECT_1);

        // The Lot and Serial Number exist as Batch Numbers on the Product, but are not on the same Link Lot
        Batch_Detail__c testBatchDetail = ZTS_DataUtilityTest.createBatchDetails(1, testCaseProduct.Id)[0];
        testBatchDetail.ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_2;
        testBatchDetail.ZTS_US_Serial_Number__c = TEST_SERIAL_NUMBER_1;

        Test.startTest();
            insert testBatchDetail;
        Test.stopTest();

        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        assertLotQualifierInvalid(testBatchDetail);
        assertSerialQualifierInvalid(testBatchDetail);
    }

    @isTest
    private static void setFieldsFromPVWProduct_InsertMultiple_Test() {
        ZTS_US_Case_Product__c caseProduct1;
        ZTS_US_Case_Product__c caseProduct2;
        for (ZTS_US_Case_Product__c caseProduct : [
            SELECT ID, ZTS_US_PVW_Product__c, ZTS_US_PVW_Product__r.Name
            FROM ZTS_US_Case_Product__c
            WHERE ZTS_US_PVW_Product__r.Name in: new List<String> {TEST_PVWPRODUCT_NAME_1, TEST_PVWPRODUCT_NAME_2}
            AND ZTS_US_Case__r.Subject =: QUALIFIER_CASE_SUBJECT_1 
        ]) {
            if (caseProduct.ZTS_US_PVW_Product__r.Name == TEST_PVWPRODUCT_NAME_1) {
                caseProduct1 = caseProduct;
            }
            else {
                caseProduct2 = caseProduct;
            }
        }

        List<Batch_Detail__c> product1BatchDetails = ZTS_DataUtilityTest.createBatchDetails(3, caseProduct1.Id);
        product1BatchDetails[0].ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_1;
        product1BatchDetails[1].ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_2;
        product1BatchDetails[1].ZTS_US_Serial_Number__c = TEST_SERIAL_NUMBER_2;
        // This lot only exists on a different product and should not be found
        product1BatchDetails[2].ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_3;

        List<Batch_Detail__c> product2BatchDetails = ZTS_DataUtilityTest.createBatchDetails(2, caseProduct2.Id);
        product2BatchDetails[0].ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_3;
        product2BatchDetails[1].ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_3;
        product2BatchDetails[1].ZTS_US_Serial_Number__c = TEST_SERIAL_NUMBER_3;

        List<Batch_Detail__c> allBatchDetails = new List<Batch_Detail__c>();
        allBatchDetails.addAll(product1BatchDetails);
        allBatchDetails.addAll(product2BatchDetails);

        Map<String, ZTS_US_PVW_Batch_Number__c> batchNumbersByKey = new Map<String, ZTS_US_PVW_Batch_Number__c>();
        for (ZTS_US_PVW_Batch_Number__c batchNumber : retrievePvwBatchNumbers(new List<String> {
            TEST_LOT_NUMBER_1, TEST_LOT_NUMBER_2, TEST_LOT_NUMBER_3, TEST_SERIAL_NUMBER_2, TEST_SERIAL_NUMBER_3},
            new List<String> {'LOT', 'SER'},
            new List<Id> {caseProduct1.ZTS_US_PVW_Product__c, caseProduct2.ZTS_US_PVW_Product__c})) {
            String key = String.format('{0}{1}{2}', new List<Object> {batchNumber.ZTS_US_Batch_Number__c,
                batchNumber.ZTS_US_Batch_Type__c, batchNumber.ZTS_US_PVW_Product__c});

            // Only take the first Batch Number as it will have the earlier Expiry Date
            if (!batchNumbersByKey.containsKey(key)) {
                batchNumbersByKey.put(key, batchNumber);
            }
        }

        Test.startTest();
            insert allBatchDetails;
        Test.stopTest();
        
        Map<Id, Batch_Detail__c> updatedBatchDetailsMap = new Map<Id, Batch_Detail__c>(
            retrieveBatchDetailsForQualifierValidation(
                new List<Id>(new Map<Id, Batch_Detail__c>(allBatchDetails).keySet())));

        for (integer i = 0; i < product1BatchDetails.size(); i++) {
            Batch_Detail__c updatedBatchDetail = updatedBatchDetailsMap.get(product1BatchDetails[i].Id);

            if (i == 0) {
                String lotBatchNumberKey = String.format('{0}{1}{2}', new List<Object> {TEST_LOT_NUMBER_1, 'LOT',
                    caseProduct1.ZTS_US_PVW_Product__c});

                ZTS_US_PVW_Batch_Number__c matchingLotBatchNumber = batchNumbersByKey.get(lotBatchNumberKey);
                assertLotQualifierValid(updatedBatchDetail, matchingLotBatchNumber);
                System.assertEquals(null, updatedBatchDetail.ZTS_US_Serial_Number__c, 
                    'Serial Number populated unexpectedly');
            }
            else if (i == 1) {
                String lotBatchNumberKey = String.format('{0}{1}{2}', new List<Object> {TEST_LOT_NUMBER_2, 'LOT',
                    caseProduct1.ZTS_US_PVW_Product__c});

                String serialBatchNumberKey = String.format('{0}{1}{2}', new List<Object> {TEST_SERIAL_NUMBER_2, 'SER',
                    caseProduct1.ZTS_US_PVW_Product__c});

                assertLotQualifierValid(updatedBatchDetail, batchNumbersByKey.get(lotBatchNumberKey));   
                assertSerialQualifierValid(updatedBatchDetail, batchNumbersByKey.get(serialBatchNumberKey));
            }
            else {
                assertLotQualifierInvalid(updatedBatchDetail);
                System.assertEquals(null, updatedBatchDetail.ZTS_US_Serial_Number__c, 
                    'Serial Number populated unexpectedly');
            }
        }

        for (integer i = 0; i < product2BatchDetails.size(); i++) {
            Batch_Detail__c updatedBatchDetail = updatedBatchDetailsMap.get(product2BatchDetails[i].Id);

            if (i == 0) {
                String batchNumberKey = String.format('{0}{1}{2}', new List<Object> {TEST_LOT_NUMBER_3, 'LOT',
                    caseProduct2.ZTS_US_PVW_Product__c});

                assertLotQualifierValid(updatedBatchDetail, batchNumbersByKey.get(batchNumberKey));
            }
            else {
                assertLotQualifierInvalid(updatedBatchDetail);
                assertSerialQualifierInvalid(updatedBatchDetail);
            }
        }
    }

    // The Case Product used has Lot Number only populated
    @isTest
    private static void setFieldsFromPVWProduct_UpdateClearLotNumber_Test() {
        Batch_Detail__c testBatchDetail = retrieveBatchDetailForTest(TEST_LOT_NUMBER_1, null, QUALIFIER_CASE_SUBJECT_2);
        testBatchDetail.ZTS_US_Product_Lot__c = null;

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();
        
        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        System.assert(String.isBlank(testBatchDetail.Lot_Qualifier__c),
            'Lot Qualifier was not cleared as expected.');

        System.assertEquals(null, testBatchDetail.ZTS_US_Expiry_Date__c, 'Lot Expiry Date was not cleared as expected.');
        System.assertEquals(false, testBatchDetail.ZTS_US_Expiry_Date_Approx__c,
            'Lot Expiry Date Approx was not reset as expected.');
    }

    // This Case Product has Serial Number poppulated only
    @isTest
    private static void setFieldsFromPVWProduct_UpdateClearSerialNumber_Test() {
        Batch_Detail__c testBatchDetail = retrieveBatchDetailForTest(null, TEST_SERIAL_NUMBER_1, QUALIFIER_CASE_SUBJECT_2);
        testBatchDetail.ZTS_US_Serial_Number__c = null;

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();
        
        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        System.assert(String.isBlank(testBatchDetail.Serial_Qualifier__c),
            'Serial Qualifier was not cleared as expected.');
        
        System.assertEquals(null, testBatchDetail.ZTS_US_Serial_Expiry_Date__c,
            'Serial Expiry Date was not cleared as expected.');

        System.assertEquals(false, testBatchDetail.ZTS_US_Serial_Expiry_Date_Approx__c,
            'Serial Expiry Date Approx was not reset as expected.');
    }

    // The Case Product used here has Serial Number and Lot populated
    @isTest
    private static void setFieldsFromPVWProduct_UpdateClearSerialNumberNotLotNumber_Test() {
        Batch_Detail__c testBatchDetail = retrieveBatchDetailForTest(TEST_LOT_NUMBER_2, TEST_SERIAL_NUMBER_2,
            QUALIFIER_CASE_SUBJECT_2);
        testBatchDetail.ZTS_US_Serial_Number__c = null;

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();
        
        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        ZTS_US_PVW_Batch_Number__c matchingBatchNumber = retrievePVWBatchNumberByNumberTypeAndProductId(
            TEST_SERIAL_NUMBER_2, 'SER', testBatchDetail.ZTS_US_Case_Product__r.ZTS_US_PVW_Product__c);

        System.assertEquals(TEST_SERIAL_NUMBER_2, testBatchDetail.ZTS_US_Serial_Number__c, 
            'Serial Number was not reset as expected');

        assertSerialQualifierValid(testBatchDetail, matchingBatchNumber);
    }

    @isTest
    private static void setFieldsFromPVWProduct_UpdateClearSerialNumberAndLotNumber_Test() {
        Batch_Detail__c testBatchDetail = retrieveBatchDetailForTest(TEST_LOT_NUMBER_2, TEST_SERIAL_NUMBER_2,
            QUALIFIER_CASE_SUBJECT_2);
        testBatchDetail.ZTS_US_Product_Lot__c = null;
        testBatchDetail.ZTS_US_Serial_Number__c = null;

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();
        
        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        System.assert(String.isBlank(testBatchDetail.Lot_Qualifier__c),
            'Lot Qualifier was not cleared as expected.');

        System.assertEquals(null, testBatchDetail.ZTS_US_Expiry_Date__c, 'Lot Expiry Date was not cleared as expected.');
        System.assertEquals(false, testBatchDetail.ZTS_US_Expiry_Date_Approx__c,
            'Lot Expiry Date Approx was not reset as expected.');

        System.assert(String.isBlank(testBatchDetail.Serial_Qualifier__c),
            'Serial Qualifier was not cleared as expected.');
        
        System.assertEquals(null, testBatchDetail.ZTS_US_Serial_Expiry_Date__c,
            'Serial Expiry Date was not cleared as expected.');

        System.assertEquals(false, testBatchDetail.ZTS_US_Serial_Expiry_Date_Approx__c,
            'Serial Expiry Date Approx was not reset as expected.');
    }

    // The Case Product used has Lot Number populated only
    @isTest
    private static void setFieldsFromPVWProduct_UpdateChangeLotNumberValid_Test() {
        Batch_Detail__c testBatchDetail = retrieveBatchDetailForTest(TEST_INVALID_NUMBER, null,
            QUALIFIER_CASE_SUBJECT_2);
        testBatchDetail.ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_2;

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();

        ZTS_US_PVW_Batch_Number__c matchingBatchNumber = retrievePVWBatchNumberByNumberTypeAndProductId(
            testBatchDetail.ZTS_US_Product_Lot__c, 'LOT', testBatchDetail.ZTS_US_Case_Product__r.ZTS_US_PVW_Product__c);

        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        assertLotQualifierValid(testBatchDetail, matchingBatchNumber);
    }

    // The Case Product User here has Lot Number populated only
    @isTest
    private static void setFieldsFromPVWProduct_UpdateChangeLotNumberInvalid_Test() {
        Batch_Detail__c testBatchDetail = retrieveBatchDetailForTest(TEST_LOT_NUMBER_1, null, QUALIFIER_CASE_SUBJECT_2);
        testBatchDetail.ZTS_US_Product_Lot__c = TEST_INVALID_NUMBER;

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();
        
        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        assertLotQualifierInvalid(testBatchDetail);
    }

     // The Case Product used has Lot Number populated only.
    // This test makes sure that Lot Expiry Date and Lot Expiry Approx Date are not overwritten
    @isTest
    private static void setFieldsFromPVWProduct_UpdateChangeLotNumberKeepInvalid_Test() {
        Batch_Detail__c testBatchDetail = retrieveBatchDetailForTest(TEST_INVALID_NUMBER, null,
            QUALIFIER_CASE_SUBJECT_2);
        testBatchDetail.ZTS_US_Product_Lot__c = 'Invalid2';
        testBatchDetail.ZTS_US_Expiry_Date__c = System.today().addDays(20);
        testBatchDetail.ZTS_US_Expiry_Date_Approx__c = true;

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();

        Batch_Detail__c updatedBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        System.assertEquals('Invalid', testBatchDetail.Lot_Qualifier__c, 'Lot Qualifier not set to invalid as expected');
        System.assertEquals(testBatchDetail.ZTS_US_Expiry_Date__c, updatedBatchDetail.ZTS_US_Expiry_Date__c,
            'Lot Expiry Date was changed unexpectedly.');

        System.assertEquals(testBatchDetail.ZTS_US_Expiry_Date_Approx__c, updatedBatchDetail.ZTS_US_Expiry_Date_Approx__c,
            'Lot Expiry Date Approx was changed unexpectedly.');
    }

    // The Case Product used here has Serial Number populated only
    @isTest
    private static void setFieldsFromPVWProduct_UpdateChangeSerialNumberValid_Test() {
        Batch_Detail__c testBatchDetail = retrieveBatchDetailForTest(null, TEST_INVALID_NUMBER, QUALIFIER_CASE_SUBJECT_2);
        testBatchDetail.ZTS_US_Serial_Number__c = TEST_SERIAL_NUMBER_2;

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();
        
        ZTS_US_PVW_Batch_Number__c matchingBatchNumber = retrievePVWBatchNumberByNumberTypeAndProductId(
            testBatchDetail.ZTS_US_Serial_Number__c, 'SER', testBatchDetail.ZTS_US_Case_Product__r.ZTS_US_PVW_Product__c);

        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        assertSerialQualifierValid(testBatchDetail, matchingBatchNumber);
    }

    // The Case Product has Serial Number populated only
    @isTest
    private static void setFieldsFromPVWProduct_UpdateChangeSerialNumberInvalid_Test() {
        Batch_Detail__c testBatchDetail = retrieveBatchDetailForTest(null, TEST_SERIAL_NUMBER_1, QUALIFIER_CASE_SUBJECT_2);
        testBatchDetail.ZTS_US_Serial_Number__c = TEST_INVALID_NUMBER;

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();
        
        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        assertSerialQualifierInvalid(testBatchDetail);
    }

    // The Case Product used here has Serial Number populated only
    // This test confirms that Expiry Date and Expiry Date Approx are not reset if they are manually set on an invalid record.
    @isTest
    private static void setFieldsFromPVWProduct_UpdateChangeSerialNumberKeepInvalid_Test() {
        Batch_Detail__c testBatchDetail = retrieveBatchDetailForTest(null, TEST_INVALID_NUMBER, QUALIFIER_CASE_SUBJECT_2);
        testBatchDetail.ZTS_US_Serial_Number__c = 'Invalid2';
        testBatchDetail.ZTS_US_Serial_Expiry_Date__c = System.today().addDays(3);
        testBatchDetail.ZTS_US_Serial_Expiry_Date_Approx__c = true;

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();

        Batch_Detail__c updatedBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);
        
        System.assertEquals('Invalid', updatedBatchDetail.Serial_Qualifier__c, 'Serial Qualifier not set to invalid as expected');
        System.assertEquals(testBatchDetail.ZTS_US_Serial_Expiry_Date__c, updatedBatchDetail.ZTS_US_Serial_Expiry_Date__c,
            'Serial Expiry Date was changed unexpectedly.');

        System.assertEquals(testBatchDetail.ZTS_US_Serial_Expiry_Date_Approx__c,
            updatedBatchDetail.ZTS_US_Serial_Expiry_Date_Approx__c,
            'Serial Expiry Date Approx was changed unexpectedly.');
    }

    @isTest
    private static void setFieldsFromPVWProduct_UpdateChangeLotAndSerialNumberInvalid_Test() {
        Batch_Detail__c testBatchDetail = retrieveBatchDetailForTest(TEST_LOT_NUMBER_2, TEST_SERIAL_NUMBER_2,
            QUALIFIER_CASE_SUBJECT_2);

        testBatchDetail.ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_1;
        testBatchDetail.ZTS_US_Serial_Number__c = TEST_SERIAL_NUMBER_1;

        Test.startTest();
            update testBatchDetail;
        Test.stopTest();
        
        testBatchDetail = retrieveBatchDetailForQualifierValidation(testBatchDetail.Id);

        assertLotQualifierInvalid(testBatchDetail);
        assertSerialQualifierInvalid(testBatchDetail);
    }

    @isTest
    private static void setFieldsFromPVWProduct_UpdateMultiple_Test() {
        Map<String, Batch_Detail__c> batchDetailByOriginalNumbers = new Map<String, Batch_Detail__c>();
        List<Id> batchDetailIds = new List<Id>();
        Map<String, Id> pvwProductIdsByName = new Map<String, Id>();
        for (Batch_Detail__c batchDetail : retrieveBatchDetailsForTest(
            new List<String> {TEST_LOT_NUMBER_1, TEST_LOT_NUMBER_2, TEST_INVALID_NUMBER},
            new List<String> {TEST_SERIAL_NUMBER_1, TEST_SERIAL_NUMBER_2, TEST_INVALID_NUMBER},
            new List<String> {QUALIFIER_CASE_SUBJECT_2})) {
            
            batchDetailIds.add(batchDetail.Id);
            pvwProductIdsByName.put(batchDetail.ZTS_US_Case_Product__r.ZTS_US_PVW_Product__r.Name,
                batchDetail.ZTS_US_Case_Product__r.ZTS_US_PVW_Product__c);

            batchDetailByOriginalNumbers.put(String.format('{0}{1}', 
                new List<Object> {batchDetail.ZTS_US_Product_Lot__c, batchDetail.ZTS_US_Serial_Number__c}),
                batchDetail);

            if (batchDetail.ZTS_US_Product_Lot__c == TEST_LOT_NUMBER_1) {
                batchDetail.ZTS_US_Product_Lot__c = TEST_INVALID_NUMBER;
            }
            else if (batchDetail.ZTS_US_Serial_Number__c == TEST_SERIAL_NUMBER_1) {
                batchDetail.ZTS_US_Serial_Number__c = TEST_SERIAL_NUMBER_2;
            }
            else if (batchDetail.ZTS_US_Product_Lot__c == TEST_LOT_NUMBER_2) {
                batchDetail.ZTS_US_Product_Lot__c = null;
                batchDetail.ZTS_US_Serial_Number__c = null;
            }
            else if (batchDetail.ZTS_US_Product_Lot__c == TEST_INVALID_NUMBER) {
                batchDetail.ZTS_US_Product_Lot__c = TEST_LOT_NUMBER_3;
            }
            else if (batchDetail.ZTS_US_Serial_Number__c == TEST_INVALID_NUMBER) {
                batchDetail.ZTS_US_Serial_Number__c = TEST_SERIAL_NUMBER_3;
            }
        }

        Test.startTest();
            update batchDetailByOriginalNumbers.values();
        Test.stopTest();

        Map<String, ZTS_US_PVW_Batch_Number__c> batchNumbersByKey = new Map<String, ZTS_US_PVW_Batch_Number__c>();
        for (ZTS_US_PVW_Batch_Number__c batchNumber : retrievePvwBatchNumbers(new List<String> {
            TEST_SERIAL_NUMBER_2, TEST_LOT_NUMBER_3, TEST_SERIAL_NUMBER_3},
            new List<String> {'LOT', 'SER'},
            pvwProductIdsByName.values())) {
            String key = String.format('{0}{1}{2}', new List<Object> {batchNumber.ZTS_US_Batch_Number__c,
                batchNumber.ZTS_US_Batch_Type__c, batchNumber.ZTS_US_PVW_Product__c});

            batchNumbersByKey.put(key, batchNumber);
        }

        Map<Id, Batch_Detail__c> updatedBatchDetailsMap = new Map<Id, Batch_Detail__c>(
            retrieveBatchDetailsForQualifierValidation(batchDetailIds));

        for (String originalNumber : batchDetailByOriginalNumbers.keySet()) {
            Batch_Detail__c updatedBatchDetail = updatedBatchDetailsMap.get(
                batchDetailByOriginalNumbers.get(originalNumber).Id);

            if (originalNumber.contains(TEST_LOT_NUMBER_1)) {
                assertLotQualifierInvalid(updatedBatchDetail);
            }
            else if (originalNumber.contains(TEST_SERIAL_NUMBER_1)) {
                String serialBatchKey = String.format('{0}{1}{2}', new List<Object> {TEST_SERIAL_NUMBER_2,
                    'SER', pvwProductIdsByName.get(TEST_PVWPRODUCT_NAME_1)});

                ZTS_US_PVW_Batch_Number__c matchingBatchNumber = batchNumbersByKey.get(serialBatchKey);
                assertSerialQualifierValid(updatedBatchDetail, matchingBatchNumber);
            }
            else if (originalNumber.contains(TEST_LOT_NUMBER_2)) {
                System.assert(String.isBlank(updatedBatchDetail.Lot_Qualifier__c),
                    'Lot Qualifier was not cleared as expected.');

                System.assert(String.isBlank(updatedBatchDetail.Serial_Qualifier__c),
                    'Serial Qualifier was not cleared as expected.');
            }
            else if (originalNumber == String.format('{0}null', new List<Object> {TEST_INVALID_NUMBER})) {
                String lotBatchKey = String.format('{0}{1}{2}', new List<Object> {TEST_LOT_NUMBER_3,
                    'LOT', pvwProductIdsByName.get(TEST_PVWPRODUCT_NAME_2)});

                ZTS_US_PVW_Batch_Number__c matchingBatchNumber = batchNumbersByKey.get(lotBatchKey);
                assertLotQualifierValid(updatedBatchDetail, matchingBatchNumber);
            }
            else if (updatedBatchDetail.ZTS_US_Serial_Number__c == String.format('null{0}', new List<Object> {TEST_INVALID_NUMBER})) {
                String serialBatchKey = String.format('{0}{1}{2}', new List<Object> {TEST_SERIAL_NUMBER_3,
                    'SER', pvwProductIdsByName.get(TEST_PVWPRODUCT_NAME_2)});

                ZTS_US_PVW_Batch_Number__c matchingBatchNumber = batchNumbersByKey.get(serialBatchKey);
                assertSerialQualifierValid(updatedBatchDetail, matchingBatchNumber);
            }
        }
    }

    private static void assertLotQualifierValid(Batch_Detail__c testBatchDetail, 
        ZTS_US_PVW_Batch_Number__c matchingBatchNumber) {
        System.assertEquals('Valid', testBatchDetail.Lot_Qualifier__c, 'Lot Qualifier not set to valid as expected');

        System.assertEquals(matchingBatchNumber.ZTS_US_Expiry_Date__c, testBatchDetail.ZTS_US_Expiry_Date__c,
            'Lot Expiry Date not set correctly');

        System.assertEquals(matchingBatchNumber.ZTS_US_Expiry_Approximate__c == 'Y',
            testBatchDetail.ZTS_US_Expiry_Date_Approx__c, 'Lot Expiry Date Approx not set correctly');
    }

    private static void assertLotQualifierInvalid(Batch_Detail__c testBatchDetail) {
        System.assertEquals('Invalid', testBatchDetail.Lot_Qualifier__c, 'Lot Qualifier not set to invalid as expected');
        System.assertEquals(null, testBatchDetail.ZTS_US_Expiry_Date__c, 'Lot Expiry Date was not cleared as expected.');
        System.assertEquals(false, testBatchDetail.ZTS_US_Expiry_Date_Approx__c,
            'Lot Expiry Date Approx was not reset as expected.');
    }

    private static void assertSerialQualifierValid(Batch_Detail__c testBatchDetail, 
        ZTS_US_PVW_Batch_Number__c matchingBatchNumber) {
        System.assertEquals('Valid', testBatchDetail.Serial_Qualifier__c, 'Serial Qualifier not set to valid as expected');

        System.assertEquals(testExpiryDate, testBatchDetail.ZTS_US_Serial_Expiry_Date__c,
            'Serial Expiry Date not set correctly');

        System.assertEquals(matchingBatchNumber.ZTS_US_Expiry_Approximate__c == 'Y',
            testBatchDetail.ZTS_US_Serial_Expiry_Date_Approx__c, 'Serial Expiry Date Approx not set correctly');
    }

    private static void assertSerialQualifierInvalid(Batch_Detail__c testBatchDetail) {
        System.assertEquals('Invalid', testBatchDetail.Serial_Qualifier__c, 'Serial Qualifier not set to invalid as expected');
        System.assertEquals(null, testBatchDetail.ZTS_US_Serial_Expiry_Date__c,
            'Serial Expiry Date was not cleared as expected.');

        System.assertEquals(false, testBatchDetail.ZTS_US_Serial_Expiry_Date_Approx__c,
            'Serial Expiry Date Approx was not reset as expected.');
    }

    private static Batch_Detail__c retrieveBatchDetailForQualifierValidation(Id batchDetailId) {
        return retrieveBatchDetailsForQualifierValidation(new List<Id> {batchDetailId})[0];
    }

    private static List<Batch_Detail__c> retrieveBatchDetailsForQualifierValidation(List<Id> batchDetailIds) {
        return [
            SELECT Id, ZTS_US_Product_Lot__c,ZTS_US_Expiry_Date__c, ZTS_US_Expiry_Date_Approx__c, Lot_Qualifier__c,
                   ZTS_US_Serial_Number__c, ZTS_US_Serial_Expiry_Date__c, ZTS_US_Serial_Expiry_Date_Approx__c, 
                   Serial_Qualifier__c, ZTS_US_Case_Product__r.ZTS_US_PVW_Product__c
            FROM Batch_Detail__c
            WHERE Id in: batchDetailIds];
    }

    private static Batch_Detail__c retrieveBatchDetailForTest(String lotNumber, String serialNumber, String caseSubject) {
        return retrieveBatchDetailsForTest(new List<String> {lotNumber}, new List<String> {serialNumber},
            new List<String> {caseSubject})[0];
    }

    private static List<Batch_Detail__c> retrieveBatchDetailsForTest(List<String> lotNumbers, List<String> serialNumbers,
        List<String> caseSubjects) {
        return [
            SELECT Id, ZTS_US_Product_Lot__c,ZTS_US_Expiry_Date__c, ZTS_US_Expiry_Date_Approx__c, Lot_Qualifier__c,
                   ZTS_US_Serial_Number__c, ZTS_US_Serial_Expiry_Date__c, ZTS_US_Serial_Expiry_Date_Approx__c, 
                   Serial_Qualifier__c, ZTS_US_Case_Product__r.ZTS_US_PVW_Product__c,
                   ZTS_US_Case_Product__r.ZTS_US_PVW_Product__r.Name
            FROM Batch_Detail__c
            WHERE ZTS_US_Product_Lot__c in: lotNumbers
            AND ZTS_US_Serial_Number__c in: serialNumbers
            AND ZTS_US_Case_Product__r.ZTS_US_Case__r.Subject in: caseSubjects];
    }

    private static ZTS_US_Case_Product__c retrieveCaseProductByPVWProductNameAndSubject(String pvwProductName, String caseSubject) {
        return [
            SELECT ID, ZTS_US_PVW_Product__c
            FROM ZTS_US_Case_Product__c
            WHERE ZTS_US_PVW_Product__r.Name =: pvwProductName
            AND ZTS_US_Case__r.Subject =: caseSubject
            LIMIT 1
        ];
    }

    private static ZTS_US_PVW_Batch_Number__c retrievePVWBatchNumberByNumberTypeAndProductId(String batchNumber, String type, Id productId) {
        return retrievePvwBatchNumbers(new List<String> {batchNumber}, new List<String> {type},
            new List<Id> {productId})[0];
    }

    private static List<ZTS_US_PVW_Batch_Number__c> retrievePvwBatchNumbers(List<String> batchNumbers, List<String> types, List<Id> productIds) {
        return [
            SELECT ID, ZTS_US_Expiry_Approximate__c, ZTS_US_Expiry_Date__c, ZTS_US_Batch_Number__c,
                   ZTS_US_Batch_Type__c, ZTS_US_PVW_Product__c
            FROM ZTS_US_PVW_Batch_Number__c
            WHERE ZTS_US_PVW_Product__c in: productIds
            AND ZTS_US_Batch_Number__c in: batchNumbers
            AND ZTS_US_Batch_Type__c =: types
            ORDER BY ZTS_US_Expiry_Date__c ASC
        ];
    }
}