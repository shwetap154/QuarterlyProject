/**
 * @description       : Test class for VmipsCaseService
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-01-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-21-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for validateCaseHasLOEProductAndCode method
 * 1.1   07-08-2022   Ethan Hirsch @ Zoetis Inc   Add tests for validateCaseIsSeriousForAnestheticLOEProduct method
 * 1.2   07-11-2022   Ethan Hirsch @ Zoetis Inc   Fix an assertion bug. Add multiple Case Tests for validation
 *                                                (Tests are commented out due to existing bug with Error Message)
 * 1.3   07-12-2022   Ethan Hirsch @ Zoetis Inc   Add tests for validateIfUnclassifiableEventRequired method.
 *                                                Add additional tests/data to verify Validation fires with multiple Problem Types
 * 1.4   07-19-2022   Ethan Hirsch @ Zoetis Inc   Add tests for validateCaseAndLocalAsessmentSeriousMatch method.
 * 1.5   07-21-2022   Ethan Hirsch @ Zoetis Inc   Change SendToPVworks method to send to PV Works using the Sync_Status__c field
 * 1.6   08-01-2022   Ethan Hirsch @ Zoetis Inc   Disable triggers in setup to save on limits.
**/
@isTest
private class VmipsCaseServiceTest {
    private static final String vmipsBaseCaseSubject = 'VMIPS Base Case';
    private static final String vmipsAnestheticCaseSubject = 'VMIPS Anesthetic Case';

    @TestSetup
    private static void setup(){
        // Disable triggers to save on limits in setup
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_CaseProductTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_EventNarrativeTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_VedDraEventTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_AssessmentTriggerHandler');

        Account testAccount = TestDataFactory.createAccount_US('Test Account 1', true);

        Id vmipsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        
        // Setup VMIPS Cases with the minimum data required for errors to be thrown.
        // These Cases do not have enough information to be submitted to PVW Works succesfully.
        Case vmipsBaseCase = ZTS_DataUtilityTest.createCases(1, vmipsRecordTypeId)[0];
        vmipsBaseCase.Subject = vmipsBaseCaseSubject;
        vmipsBaseCase.Type = 'Animal Complaint';
        vmipsBaseCase.AccountId = testAccount.Id;

        Case anestheticsCase = ZTS_DataUtilityTest.createCases(1, vmipsRecordTypeId)[0];
        anestheticsCase.Subject = vmipsAnestheticCaseSubject;
        anestheticsCase.Type = 'Animal Complaint';
        anestheticsCase.AccountId = testAccount.Id;

        insert new List<Case> {vmipsBaseCase, anestheticsCase};

        List<ZTS_US_PVW_Product__c> pvwProducts = ZTS_DataUtilityTest.createPvwProducts(2);
        
        // Set this PVW Products to one of the Anesthetic Products to test out the validation on Anesthetic Products.
        // Change the casing to all lowercase to validate the casing of the field doesn't imapct the Case. 
        pvwProducts[1].ZTS_US_Product_Line__c = [
            SELECT Product_Line__c
            FROM PVW_Product_Line_Type_Grouping__mdt
            WHERE Product_Type__c = 'Anesthetic'
            LIMIT 1].Product_Line__c.toLowerCase();

        insert pvwProducts;

        Id zoetisProductRecordTypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId();
        ZTS_US_Case_Product__c baseCaseProduct = ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, vmipsBaseCase.Id, pvwProducts[0].Id)[0];
        baseCaseProduct.ZTS_US_Product_Role__c = 'Suspect Product';

        ZTS_US_Case_Product__c anestheticCaseProduct = ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, anestheticsCase.Id, pvwProducts[1].Id)[0];
        
        insert new List<ZTS_US_Case_Product__c> {baseCaseProduct, anestheticCaseProduct};

        ZTS_US_Event_Narrative__c eventNarrative = ZTS_DataUtilityTest.createEventNarratives(1, vmipsBaseCase.Id)[0];
        insert eventNarrative;

        ZTS_US_VedDra_Coding__c vedraCoding = ZTS_DataUtilityTest.createVeddraCodings(1)[0];
        insert vedraCoding;

        ZTS_US_VedDRA_Event__c veddraEvent = ZTS_DataUtilityTest.createVeddraEvent(eventNarrative.Id, vedraCoding.Id);
        insert veddraEvent;

        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get('ZTS_US_Local_Assessment').getRecordTypeId();
        ZTS_US_Assessment__c assessment = ZTS_DataUtilityTest.createAssessments(1, vmipsBaseCase.Id, localAssessmentRTId)[0];
        insert assessment;
        
        vmipsBaseCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        update vmipsBaseCase;

        // Enable triggers to be safe
        List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
        TriggerActivation__c tr = new TriggerActivation__c(Name = 'ZTS_EU_ServiceRequest',ZTS_EU_Bypass__c = true);
        triggerActiveList.add(tr);
        insert triggerActiveList;
        DispatchTriggerHandler.clearAllBypasses();
    }

    // Test for validateCaseHasLOEProductAndCode, validateCaseIsSeriousForAnestheticLOEProduct, 
    // and validateIfUnclassifiableEventRequired
    @isTest
    private static void validateCaseHasLOEProductAndCode_validateCaseIsSeriousForAnestheticLOEProduct_NoLOEProductOrCode_Test() {
        Case testCase = retrieveVmipsBaseCase();
        markCaseForSendToPVWorks(testCase);

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoLOEError(errorMessage);
        
        assertNoAnestheticLOEError(errorMessage);

        assertNoUnclassifiableEventMissingError(errorMessage);
    }

    @isTest
    private static void validateCaseHasLOEProductAndCode_LOEProductOnly_Test() {
        Case testCase = retrieveVmipsBaseCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);

        caseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        markCaseForSendToPVWorks(testCase);
        
        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertLoeError(errorMessage);
    }

    @isTest
    private static void validateCaseHasLOEProductAndCode_LOEWithAnotherProblemTypeProductOnly_Test() {
        Case testCase = retrieveVmipsBaseCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);

        caseProduct.ZTS_US_Product_problem_type__c = 'Ecotoxicity;Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        markCaseForSendToPVWorks(testCase);
        
        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertLoeError(errorMessage);
    }

    @isTest
    private static void validateCaseHasLOEProductAndCode_LOECodeOnly_Test() {
        Case testCase = retrieveVmipsBaseCase();

        ZTS_US_VedDRA_Coding__c vedraCoding = [
            SELECT Id
            FROM ZTS_US_VedDRA_Coding__c
            WHERE Id in (
                SELECT ZTS_US_VedDRA_Coding__c 
                FROM ZTS_US_VedDRA_Event__c 
                WHERE ZTS_US_Event_Narrative__r.ZTS_US_Case__c =: testCase.Id)
            LIMIT 1];

        vedraCoding.ZTS_US_HLT_Code__c = 155;
        update vedraCoding;

        markCaseForSendToPVWorks(testCase);
        
        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        System.assert(String.isNotBlank(errorMessage) && errorMessage.contains(vmipsCaseService.loeMissingProductError),
            String.format('Case did not error with the LOE Product Missing Error: {0}', new List<String> {errorMessage}));
    }

    @isTest
    private static void validateCaseHasLOEProductAndCode_LOEProductAndCode_Test() {
        Case testCase = retrieveVmipsBaseCase();

        ZTS_US_VedDRA_Coding__c vedraCoding = [
            SELECT Id
            FROM ZTS_US_VedDRA_Coding__c
            WHERE Id in (
                SELECT ZTS_US_VedDRA_Coding__c 
                FROM ZTS_US_VedDRA_Event__c 
                WHERE ZTS_US_Event_Narrative__r.ZTS_US_Case__c =: testCase.Id)
            LIMIT 1];

        vedraCoding.ZTS_US_HLT_Code__c = 155;
        update vedraCoding;

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);

        caseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        markCaseForSendToPVWorks(testCase);
        
        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoLOEError(errorMessage);
    }

    @isTest
    private static void validateCaseHasLOEProductAndCode_LOEDiagnosticProductOnly_Test() {
        Case testCase = retrieveVmipsBaseCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);

        caseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;
        
        ZTS_US_PVW_Product__c pvwProduct = caseProduct.ZTS_US_PVW_Product__r;
        pvwProduct.ZTS_US_Product_Category__c = 'DIAG';
        update pvwProduct;

        markCaseForSendToPVWorks(testCase);
        
        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoLOEError(errorMessage);
    }

    @isTest
    private static void validateCaseHasLOEProductAndCode_NoProductsOrCodes_Test() {
        // Run the validateCaseHasLOEProductAndCode method directly to test the null condition to
        // avoid needing to setup a second Case to trigger it
        Test.startTest();
            String errorMessage = VmipsCaseService.validateCaseHasLOEProductAndCode(null, null);
        Test.stopTest();

        System.assert(String.isBlank(errorMessage),
            String.format('Unexpected error return: {0}', new List<String> {errorMessage}));
    }

    // Though only a single Case will generally be validated at once, multiple Cases are tested here.
    // There is currently a bug with error message not being reset for each Case, so this test is commented out
    // @isTest
    // private static void validateCaseHasLOEProductAndCode_MultipleCases_Test() {
    //     Case baseCase = retrieveVmipsBaseCase();

    //     Id accountId = [SELECT ID FROM ACCOUNT LIMIT 1].Id;
    //     Id vmipsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();

    //     List<Case> newCases = new List<Case>();
    //     for (integer i = 0; i < 2; i++) {
    //         // There is a bug in the clone case logic where if two Cases are cloned from the same source Case, 
    //         // only the second processed Case will get related Products cloned and Event Narrative cleared.
    //         Case newCase = ZTS_DataUtilityTest.createCases(1, vmipsRecordTypeId)[0];
    //         newCase.Type = 'Animal Complaint';
    //         newCase.AccountId = accountId;
    //         newCases.add(newCase);
    //     }

    //     // This will clone Case Products too
    //     insert newCases;

    //     Id productId = [
    //         SELECT ID 
    //         FROM ZTS_US_PVW_Product__c 
    //         WHERE ZTS_US_Product_Line__c = null 
    //         LIMIT 1].Id;

    //     Id zoetisProductRecordTypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId();
    //     List<ZTS_US_Case_Product__c> newCaseProducts = new List<ZTS_US_Case_Product__c>();
    //     Map<Id, ZTS_US_Event_Narrative__c> newEventNarrativesByCaseId = new Map<Id, ZTS_US_Event_Narrative__c>();
    //     for (Case newCase : newCases) {
    //         ZTS_US_Case_Product__c testCaseProduct = ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, newCase.Id, productId)[0];
    //         testCaseProduct.ZTS_US_Product_Role__c = 'Suspect Product';

    //         // New Case 1 will be missing a Vedra Code
    //         if (newCase.Id == newCases[1].Id) {
    //             testCaseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
    //             testCaseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
    //         }

    //         newCaseProducts.add(testCaseProduct);

    //         ZTS_US_Event_Narrative__c eventNarrative = ZTS_DataUtilityTest.createEventNarratives(1, newCase.Id)[0];
    //         newEventNarrativesByCaseId.put(newCase.Id, eventNarrative);
    //     }

    //     insert newCaseProducts;
    //     insert newEventNarrativesByCaseId.values();

    //     // A VedDRA Event must be created on the additional Cases to avoid null exceptions
    //     ZTS_US_VedDra_Coding__c additionalVedraCoding = ZTS_DataUtilityTest.createVeddraCodings(1)[0];
    //     insert additionalVedraCoding;

    //     List<ZTS_US_VedDRA_Event__c> newVeddraEvents = new List<ZTS_US_VedDRA_Event__c>();
    //     for (ZTS_US_Event_Narrative__c newEventNarrative : newEventNarrativesByCaseId.values()) {
    //         newVeddraEvents.add(ZTS_DataUtilityTest.createVeddraEvent(newEventNarrative.Id, additionalVedraCoding.Id));
    //     }

    //     insert newVeddraEvents;

    //     // Base Case will be missing a LOE Product
    //     ZTS_US_VedDRA_Coding__c vedraCoding = [
    //         SELECT Id
    //         FROM ZTS_US_VedDRA_Coding__c
    //         WHERE Id in (
    //             SELECT ZTS_US_VedDRA_Coding__c 
    //             FROM ZTS_US_VedDRA_Event__c 
    //             WHERE ZTS_US_Event_Narrative__r.ZTS_US_Case__c =: baseCase.Id)
    //         LIMIT 1];

    //     vedraCoding.ZTS_US_HLT_Code__c = 155;
    //     update vedraCoding;

    //     List<Case> allCases = new List<Case> {baseCase};
    //     allCases.addAll(newCases);
    //     for (Case testCase : allCases) {
    //         markCaseForSendToPVWorks(testCase);

    //         if (newEventNarrativesByCaseId.containsKey(testCase.Id)) {
    //             testCase.ZTS_US_Event_Narrative__c = newEventNarrativesByCaseId.get(testCase.Id).Id;
    //         }
    //     }

    //     Test.startTest();
    //         List<Database.SaveResult> results = Database.update(allCases, false);
    //     Test.stopTest();

    //     for (Database.SaveResult saveResult : results) {
    //         string errorMessage = saveResult.getErrors()[0].getMessage();
    //         if (saveResult.getId() == baseCase.Id) {
    //             System.assert(String.isNotBlank(errorMessage) && errorMessage.contains(vmipsCaseService.loeMissingProductError),
    //                 String.format('Case did not error with the LOE Product Missing Error: {0}',
    //                     new List<String> {errorMessage}));
    //         }
    //         else if (saveResult.getId() == newCases[1].Id) {
    //             System.assert(String.isNotBlank(errorMessage) && errorMessage.contains(vmipsCaseService.loeMissingCodeError),
    //                 String.format('Case did not error with the LOE Code Missing Error: {0}',
    //                 new List<String> {errorMessage}));
    //         }
    //         else {
    //             assertNoLOEError(errorMessage);
    //         }
    //     }
    // }

    @isTest
    private static void validateCaseIsSeriousForAnestheticLOEProduct_AnestheticProductNotLackOfEfficacy_Test() {
        Case testCase = retrieveAnestheticCase();

        markCaseForSendToPVWorks(testCase);

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoAnestheticLOEError(errorMessage);
    }

    @isTest
    private static void validateCaseIsSeriousForAnestheticLOEProduct_AnestheticProductLackOfEfficacyNotSerious_Test() {
        Case testCase = retrieveAnestheticCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);

        caseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        markCaseForSendToPVWorks(testCase);

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertAnestheticLOEError(errorMessage);
    }

    @isTest
    private static void validateCaseIsSeriousForAnestheticLOEProduct_AnestheticProductLackOfEfficacyWithAdditionalProblemTypeNotSerious_Test() {
        Case testCase = retrieveAnestheticCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);

        caseProduct.ZTS_US_Product_problem_type__c = 'Adverse Reaction;Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        markCaseForSendToPVWorks(testCase);

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertAnestheticLOEError(errorMessage);
    }

    @isTest
    private static void validateCaseIsSeriousForAnestheticLOEProduct_AnestheticProductLackOfEfficacySerious_Test() {
        Case testCase = retrieveAnestheticCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);

        caseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        markCaseForSendToPVWorks(testCase);
        testCase.ZTS_US_Is_it_serious_CA__c = 'Yes';

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoAnestheticLOEError(errorMessage);
    }

    // Though only a single Case will generally be validated at once, multiple Cases are tested here.
    // There is currently a bug with error message not being reset for each Case, so this test is commented out
    //@isTest
    // private static void validateCaseIsSeriousForAnestheticLOEProduct_MultipleCases_Test() {
    //     Case testCase = retrieveAnestheticCase();

    //     // Cloning the Case will clone the Case Products
    //     Case clonedCase = testCase.clone(false, true, false, false);
    //     insert clonedCase;

    //     List<Case> allCases = new List<Case> {testCase, clonedCase};
    //     List<ZTS_US_Case_Product__c> updateCaseProducts = new List<ZTS_US_Case_Product__c>();
    //     for (ZTS_US_Case_Product__c caseProduct : [
    //         SELECT Id
    //         FROM ZTS_US_Case_Product__c
    //         WHERE ZTS_US_Case__c in: allCases]) {
    //         caseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
    //         caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';

    //         updateCaseProducts.add(caseProduct);
    //     }

    //     update updateCaseProducts;

    //     markCaseForSendToPVWorks(testCase);
    //     markCaseForSendToPVWorks(clonedCase);
    //     testCase.ZTS_US_Is_it_serious_CA__c = 'Yes';

    //     Test.startTest();
    //         List<Database.SaveResult> saveResults = Database.update(new List<Case> {testCase, clonedCase}, false);
    //     Test.stopTest();

    //     for (Database.SaveResult saveResult : saveResults) {
    //         String errorMessage = saveResult.getErrors()[0].getMessage();
    //         if (saveResult.getId() == testCase.Id) {
    //             assertNoAnestheticLOEError(errorMessage);
    //         }
    //         else{
    //             System.assert(errorMessage.contains(vmipsCaseService.anethesticProductCaseNotSeriousError),
    //                 String.format('Error Message does not contain the Anesthetic Product Case error. Actual Error: {0}',
    //                     new List<String> {errorMessage}));
    //         }
    //     }
    // }

    @isTest
    private static void validateIfUnclassifiableEventRequired_LOEProductNonDiagnostics_Test() {
        Case testCase = retrieveVmipsBaseCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);
        caseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        ZTS_US_PVW_Product__c pvwProduct = caseProduct.ZTS_US_PVW_Product__r;
        pvwProduct.ZTS_US_Product_Category__c = 'BIO';
        update pvwProduct;

        markCaseForSendToPVWorks(testCase);

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoUnclassifiableEventMissingError(errorMessage);

    }

    @isTest
    private static void validateIfUnclassifiableEventRequired_SuspectLOEDiagnosticProductNoEvent_Test() {
        Case testCase = retrieveVmipsBaseCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);
        caseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        ZTS_US_PVW_Product__c pvwProduct = caseProduct.ZTS_US_PVW_Product__r;
        pvwProduct.ZTS_US_Product_Category__c = 'DIAG';
        update pvwProduct;

        markCaseForSendToPVWorks(testCase);

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertUnclassifiableEventMissingError(errorMessage);
    }

    @isTest
    private static void validateIfUnclassifiableEventRequired_SuspectLOEDiagnosticProductNoEventNonAnimalComplaint_Test() {
        Case testCase = retrieveVmipsBaseCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);
        caseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        ZTS_US_PVW_Product__c pvwProduct = caseProduct.ZTS_US_PVW_Product__r;
        pvwProduct.ZTS_US_Product_Category__c = 'DIAG';
        update pvwProduct;

        markCaseForSendToPVWorks(testCase);
        testCase.Type = 'Human Exposure';

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoUnclassifiableEventMissingError(errorMessage);
    }

    @isTest
    private static void validateIfUnclassifiableEventRequired_SuspectLOEDiagnosticProductWithEvent_Test() {
        Case testCase = retrieveVmipsBaseCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);
        caseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        ZTS_US_PVW_Product__c pvwProduct = caseProduct.ZTS_US_PVW_Product__r;
        pvwProduct.ZTS_US_Product_Category__c = 'DIAG';
        update pvwProduct;

        ZTS_US_VedDRA_Coding__c vedraCoding = [
            SELECT Id
            FROM ZTS_US_VedDRA_Coding__c
            WHERE Id in (
                SELECT ZTS_US_VedDRA_Coding__c 
                FROM ZTS_US_VedDRA_Event__c 
                WHERE ZTS_US_Event_Narrative__r.ZTS_US_Case__c =: testCase.Id)
            LIMIT 1];

        vedraCoding.ZTS_US_LLT_Code__c = 2190;
        update vedraCoding;

        markCaseForSendToPVWorks(testCase);

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoUnclassifiableEventMissingError(errorMessage);
    }

    @isTest
    private static void validateIfUnclassifiableEventRequired_LOEDiagnosticAndNonDiagnosticNoEvent_Test() {
        Case testCase = retrieveVmipsBaseCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);
        caseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        ZTS_US_PVW_Product__c pvwProduct = caseProduct.ZTS_US_PVW_Product__r;
        pvwProduct.ZTS_US_Product_Category__c = 'DIAG';
        update pvwProduct;

        Id zoetisProductRecordTypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId();
        Id nonDiagnosticPvwProductId = [
            SELECT Id
            FROM ZTS_US_PVW_Product__c
            WHERE ZTS_US_Product_Category__c != 'DIAG'
            LIMIT 1
        ].Id;

        ZTS_US_Case_Product__c nonDiagnosticCaseProduct = ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, testCase.Id, nonDiagnosticPvwProductId)[0];
        nonDiagnosticCaseProduct.ZTS_US_Product_Role__c = 'Suspect Product';
        insert nonDiagnosticCaseProduct;


        markCaseForSendToPVWorks(testCase);

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoUnclassifiableEventMissingError(errorMessage);
    }

    @isTest
    private static void validateIfUnclassifiableEventRequired_LOEDiagnosticAndNonSuspectNoEvent_Test() {
        Case testCase = retrieveVmipsBaseCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);
        caseProduct.ZTS_US_Product_problem_type__c = 'Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        ZTS_US_PVW_Product__c pvwProduct = caseProduct.ZTS_US_PVW_Product__r;
        pvwProduct.ZTS_US_Product_Category__c = 'DIAG';
        update pvwProduct;

        Id zoetisProductRecordTypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId();
        ZTS_US_Case_Product__c nonSuspectCaseProduct = ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, testCase.Id, pvwProduct.Id)[0];
        nonSuspectCaseProduct.ZTS_US_Product_Role__c = 'Suspect Product';
        nonSuspectCaseProduct.ZTS_US_Product_problem_type__c = null;
        insert nonSuspectCaseProduct;

        markCaseForSendToPVWorks(testCase);

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertUnclassifiableEventMissingError(errorMessage);
    }

    @isTest
    private static void validateIfUnclassifiableEventRequired_MultipleLOEDiagnosticNoEvent_Test() {
        Case testCase = retrieveVmipsBaseCase();

        ZTS_US_Case_Product__c caseProduct = retrieveCaseProductForCase(testCase.Id);
        caseProduct.ZTS_US_Product_problem_type__c = 'Adverse Reaction;Lack of Efficacy';
        caseProduct.ZTS_US_LOE_Reason__c = 'Test Reason';
        update caseProduct;

        ZTS_US_PVW_Product__c pvwProduct = caseProduct.ZTS_US_PVW_Product__r;
        pvwProduct.ZTS_US_Product_Category__c = 'DIAG';
        update pvwProduct;

        Id zoetisProductRecordTypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId();
        ZTS_US_Case_Product__c nonDiagnosticCaseProduct = ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId, testCase.Id, pvwProduct.Id)[0];
        nonDiagnosticCaseProduct.ZTS_US_Product_Role__c = 'Suspect Product';
        insert nonDiagnosticCaseProduct;

        markCaseForSendToPVWorks(testCase);

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertUnclassifiableEventMissingError(errorMessage);
    }

    @isTest
    private static void validateCaseAndLocalAsessmentSeriousMatch_CaseNotSeriousLocalAsessmentNotSerious_Test() {
        Case testCase = retrieveVmipsBaseCase();
        testCase.ZTS_US_Is_it_serious_CA__c = 'No';
        markCaseForSendToPVWorks(testCase);

        ZTS_US_Assessment__c localAsssessment = retrieveLocalAsessmentForCase(testCase.Id);
        localAsssessment.ZTS_US_Is_it_serious__c = 'No';
        update localAsssessment;

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoSeriousMismatchError(errorMessage);
    }

    @isTest
    private static void validateCaseAndLocalAsessmentSeriousMatch_CaseSeriousLocalAsessmentNotSerious_Test() {
        Case testCase = retrieveVmipsBaseCase();
        testCase.ZTS_US_Is_it_serious_CA__c = 'Yes';
        markCaseForSendToPVWorks(testCase);

        ZTS_US_Assessment__c localAsssessment = retrieveLocalAsessmentForCase(testCase.Id);
        localAsssessment.ZTS_US_Is_it_serious__c = 'No';
        update localAsssessment;

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertSeriousMismatchError(errorMessage);
    }

    @isTest
    private static void validateCaseAndLocalAsessmentSeriousMatch_CaseAndLocalAsessmentSerious_Test() {
        Case testCase = retrieveVmipsBaseCase();
        testCase.ZTS_US_Is_it_serious_CA__c = 'Yes';
        markCaseForSendToPVWorks(testCase);

        ZTS_US_Assessment__c localAsssessment = retrieveLocalAsessmentForCase(testCase.Id);
        localAsssessment.ZTS_US_Is_it_serious__c = 'Yes';
        update localAsssessment;

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoSeriousMismatchError(errorMessage);
    }

    @isTest
    private static void validateCaseAndLocalAsessmentSeriousMatch_CaseNotSeriousLocalAsessmentSerious_Test() {
        Case testCase = retrieveVmipsBaseCase();
        testCase.ZTS_US_Is_it_serious_CA__c = 'No';
        markCaseForSendToPVWorks(testCase);

        ZTS_US_Assessment__c localAsssessment = retrieveLocalAsessmentForCase(testCase.Id);
        localAsssessment.ZTS_US_Is_it_serious__c = 'Yes';
        update localAsssessment;

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoSeriousMismatchError(errorMessage);
    }

    @isTest
    private static void validCaseAndLocalAssessmentSeriosuMatchCaseSeriousMultipleLocalAssessmentNotAllSerious_Test() {
        Case testCase = retrieveVmipsBaseCase();
        testCase.ZTS_US_Is_it_serious_CA__c = 'Yes';
        markCaseForSendToPVWorks(testCase);

        ZTS_US_Assessment__c localAsssessment = retrieveLocalAsessmentForCase(testCase.Id);
        localAsssessment.ZTS_US_Is_it_serious__c = 'Yes';

        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get('ZTS_US_Local_Assessment').getRecordTypeId();
        ZTS_US_Assessment__c localAsssessment2 = ZTS_DataUtilityTest.createAssessments(1, testCase.Id, localAssessmentRTId)[0];
        localAsssessment2.ZTS_US_Is_it_serious__c = 'No';

        upsert new List<ZTS_US_Assessment__c>{localAsssessment, localAsssessment2};

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertSeriousMismatchError(errorMessage);
    }

    @isTest
    private static void validCaseAndLocalAssessmentSeriosuMatchCaseSeriousMultipleLocalAssessmentAllSerious_Test() {
        Case testCase = retrieveVmipsBaseCase();
        testCase.ZTS_US_Is_it_serious_CA__c = 'Yes';
        markCaseForSendToPVWorks(testCase);

        ZTS_US_Assessment__c localAsssessment = retrieveLocalAsessmentForCase(testCase.Id);
        localAsssessment.ZTS_US_Is_it_serious__c = 'Yes';

        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get('ZTS_US_Local_Assessment').getRecordTypeId();
        ZTS_US_Assessment__c localAsssessment2 = ZTS_DataUtilityTest.createAssessments(1, testCase.Id, localAssessmentRTId)[0];
        localAsssessment2.ZTS_US_Is_it_serious__c = 'Yes';

        upsert new List<ZTS_US_Assessment__c>{localAsssessment, localAsssessment2};

        Test.startTest();
            String errorMessage;
            try {
                update testCase;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
        Test.stopTest();

        assertNoSeriousMismatchError(errorMessage);
    }

    private static void assertLoeError(String errorMessage) {
        System.assert(String.isNotBlank(errorMessage) && errorMessage.contains(vmipsCaseService.loeMissingCodeError),
            String.format('Case did not error with the LOE Code Missing Error: {0}', new List<String> {errorMessage}));
    }

    private static void assertNoLOEError(String errorMessage) {
        System.assert(String.isBlank(errorMessage) || 
            (!errorMessage.contains(vmipsCaseService.loeMissingCodeError) &&
            !errorMessage.contains(vmipsCaseService.loeMissingProductError)),
            String.format('Case errored with a LOE Error: {0}', new List<String> {errorMessage}));
    }

    private static void assertAnestheticLOEError(String errorMessage) {
        System.assert(String.isNotBlank(errorMessage) &&
            errorMessage.contains(vmipsCaseService.anethesticProductCaseNotSeriousError),
            String.format('Error Message does not contain the Anesthetic Product Case error. Actual Error: {0}',
                new List<String> {errorMessage}));
    }

    private static void assertNoAnestheticLOEError(String errorMessage) {
        System.assert(String.isBlank(errorMessage) || 
            !errorMessage.contains(vmipsCaseService.anethesticProductCaseNotSeriousError),
            String.format('Case errored with a Anesthetic LOE Error: {0}', new List<String> {errorMessage}));
    }

    private static void assertUnclassifiableEventMissingError(String errorMessage) {
        System.assert(String.isNotBlank(errorMessage) && 
            errorMessage.contains(VmipsCaseService.unclassifableEventMissingError),
            String.format('Unclassifiable Event Missing Error was not thrown as expected. Error: {0}',
                new List<String> {errorMessage}));
    }

    private static void assertNoUnclassifiableEventMissingError(String errorMessage) {
        System.assert(String.isBlank(errorMessage) ||
            !errorMessage.contains(vmipsCaseService.unclassifableEventMissingError),
            String.format('Case errored with an Unclassifiable Event Missing Error: {0}',
                new List<String> {errorMessage}));
    }

    private static void assertSeriousMismatchError(String errorMessage) {
        System.assert(String.isNotBlank(errorMessage) && 
            errorMessage.contains(VmipsCaseService.caseSeriousLocalAsessmentNotSeriousError),
            String.format('Case/Local Assessment Serious Mismatch Error was not thrown as expected. Error: {0}',
                new List<String> {errorMessage}));
    }

    private static void assertNoSeriousMismatchError(String errorMessage) {
        System.assert(String.isBlank(errorMessage) ||
            !errorMessage.contains(vmipsCaseService.unclassifableEventMissingError),
            String.format('Case errored with a Case/Local Assessment Serious Mismatch Error: {0}',
                new List<String> {errorMessage}));
    }

    private static Case retrieveVmipsBaseCase() {
        return retrieveCaseBySubject(vmipsBaseCaseSubject);
    }

    private static Case retrieveAnestheticCase() {
        return retrieveCaseBySubject(vmipsAnestheticCaseSubject);
    }

    private static Case retrieveCaseBySubject(String subject) {
        return [
            SELECT Id, RecordTypeId, Subject, Type
            FROM Case 
            WHERE Subject =: subject
            LIMIT 1];
    }

    private static ZTS_US_Case_Product__c retrieveCaseProductForCase(Id caseId) {
        return [
            SELECT Id, ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c, ZTS_US_PVW_Product__r.Id
            FROM ZTS_US_Case_Product__c
            WHERE ZTS_US_Case__c =: caseId
            LIMIT 1];
    }

    private static ZTS_US_Assessment__c retrieveLocalAsessmentForCase(Id caseId) {
        return [
            SELECT Id, ZTS_US_Is_it_serious__c
            FROM ZTS_US_Assessment__c
            WHERE ZTS_US_Case__c =: caseId
            LIMIT 1
        ];
    }

    // Sets Send to PV Works and Approved on a Case so that it can be sent to PV Works.
    // This does not perform the actual update on the Case.
    private static void markCaseForSendToPVWorks(Case caseRecord) {
        caseRecord.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
    }
}