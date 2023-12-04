/****************************************************************************************************************************************** 
 * Trigger Name : CSE_CaseProductTriggerHandlerTest
 * Description  : All Trigger Test Logic for CaseProduct object.
 * Created By   : Slalom(Venkat Joginapally) 
 * Created Date : 13th September, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                      Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Venkat Joginapally          09/13/2021             Created 
 * Christain Brandt                                   Added code  
 * Madhu Goriparthi                                   Added code
 * Ethan Hirsch @ Zoetis Inc   07/18/2022             Removed tests for getInformationFromPVWProduct.
 *                                                    This has been moved to Batch Details.
 * Ethan Hirsch @ Zoetis Inc   08/01/2022             Add test to SyncLotAndSerialFromCaseProductToBatchDetail_Test to
 *                                                    confirm Serial is reset if its cleared, but a Serial can be found off a Lot.
*****************************************************************************************************************************************/

@isTest
public with sharing class CSE_CaseProductTriggerHandlerTest {
    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    static final String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId(); 
    static final String CASEPRODUCT_RT_ID = 'Zoetis_Product';
    static final String LOCALASSESSMENT_RT_ID= 'ZTS_US_Local_Assessment';
    static final String PRODUCTASSESSMENT_RT_ID= 'ZTS_US_Product_Assessment';
    static final String TESTLOT = 'Lot1';
    static final String TESTSER = 'Ser1';

    @testSetup
    public static void setupData(){
        
        Case testCase = new Case(Subject = 'Test Case',
        Status = 'New',
        Origin = 'Email',
        Type = 'Animal Complaint',
        RecordTypeId = animalRecordtypeId,
        Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_SUCCESS);
        insert testCase;

        // When a Case Product is linked to a PVW Product with ZTS_US_Product_Category__c = 'PHRM', the Case Product Product_Agency should be auto populated as FDA
        ZTS_US_PVW_Product__c testFDAProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_PVW_Product__c
            (  
            Name = 'Test FDA Product',
            ZTS_US_Product_Category__c = 'PHRM',
            ZTS_US_MAH_Country__c = 'US',
            ZTS_US_Active_Product__c = 'Yes'
            )
        ,   true
        );

        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Case_Product__c
            (    ZTS_US_Administered_By__c   = 'Other'
            ,    ZTS_US_Dose__c = 5.4
            ,    ZTS_US_Dose_Unit__c = 'Bolus'
            ,    ZTS_US_Product_problem_type__c = 'Ecotoxicity'
            ,    ZTS_US_Product_Used_Correctly__c = 'Yes'
            ,    ZTS_US_Case__c = testCase.id
            ,    ZTS_US_PVW_Product__c = testFDAProduct.id
            )
        ,   true
        );

        // Case to have 2 Case Products of different Agencies (USDA & FDA)
        Case testCase2 = new Case(Subject = 'Test Case 2',
        ZTS_US_First_Received_Date__c = Date.newinstance(2022, 1, 27),
        ZTS_US_Date_First_Valid__c = Date.newinstance(2022, 1, 27),
        ZTS_US_Information_Type__c = 'Reportable',
        ZTS_US_Country__c = 'USA',
        ZTS_US_Source__c = 'Attending Vet',
        ZTS_US_Is_it_serious_CA__c = 'No',
        Status = 'New',
        Origin = 'Email',
        Type = 'Animal Complaint',
        RecordTypeId = animalRecordtypeId);
        insert testCase2;

        List<ZTS_US_PVW_Batch_Number__c> batchNumbers = new List<ZTS_US_PVW_Batch_Number__c>();
        batchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(testFDAProduct.Id, TESTLOT, 'LOT', 1000));
        batchNumbers.add(ZTS_DataUtilityTest.createPVWBatchNumber(testFDAProduct.Id, TESTSER, 'SER', 1000));
        insert batchNumbers;
    }

    @isTest
    private static void CSE_CaseProductTriggerHandlerPositiveTest() {        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_SUCCESS);
        insert newCase;
      //Create PVW Product record
           ZTS_US_PVW_Product__c prod1 = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_PVW_Product__c
            ( 
            Name = 'VANGUARD PLUS 5/L',    
            ZTS_US_MAH_Country__c = 'US',
            ZTS_US_Active_Product__c = 'Yes'
            )
        ,   true
        );
        //Insert Case Product Record
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert caseProduct1;
        
        //testing - Case validation criteria met
        Boolean exceptionThrownMessage = false;
        Test.startTest();
        try{
            delete caseProduct1;
        } catch(DmlException ex){
            exceptionThrownMessage =  ex.getMessage().contains(CSE_CaseProductTriggerHandler.CASE_PRODUCT_APPROVEDCASE_DELETE_ERROR) ? true : false;            
        }
        Test.stopTest(); 
        System.assertNotEquals(false, exceptionThrownMessage,  'Deletion should trigger an error message as there has to be atleast one case product for the approved case');        
    }

    @isTest
    private static void CSE_CaseProductTriggerHandlerNegativeTest() {        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_SUCCESS);
        insert newCase;
        //Insert Contact
		Contact contact = new Contact(LastName = 'Doe', FirstName = 'Testone',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant');
        insert contact;
        //Insert Case Contact
		Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id);
		insert caseContact;
        //Insert PVW Product records
        List<ZTS_US_PVW_Product__c> prodList = new List<ZTS_US_PVW_Product__c>();          
        prodList.add(new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L', ZTS_US_MAH_Country__c='US',ZTS_US_Active_Product__c= 'Yes'));   
        prodList.add(new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L', ZTS_US_MAH_Country__c='US',ZTS_US_Active_Product__c= 'Yes'));
        insert prodList;
        
        //Insert Case Product Records           
        List<ZTS_US_Case_Product__c> caseProductList = new  List<ZTS_US_Case_Product__c>();
        caseProductList.add(new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                       ZTS_US_PVW_Product__c = prodList[0].Id,
                                                       ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes'));
        caseProductList.add(new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                       ZTS_US_PVW_Product__c = prodList[1].Id,
                                                       ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes'));
        insert caseProductList;
        //testing - Case validation criteria met
        Test.startTest();
        delete caseProductList[0];
        Test.stopTest(); 
        List<ZTS_US_Case_Product__c> existingCaseProducts = [SELECT Id FROM ZTS_US_Case_Product__c WHERE ZTS_US_Case__c =: newCase.Id];
        System.assertEquals(1, existingCaseProducts.size(), 'One case product record should be deleted and there should only be one existing and shoud not throw an error on deletion');                
    }

    @isTest
    private static void CSE_CaseProductTriggerHandlerDeleteMultipleTest() {        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_SUCCESS);
        insert newCase;
        //Insert PVW Product records
        List<ZTS_US_PVW_Product__c> prodList = new List<ZTS_US_PVW_Product__c>();          
        prodList.add(new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L', ZTS_US_MAH_Country__c='US',ZTS_US_Active_Product__c= 'Yes'));   
        prodList.add(new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L', ZTS_US_MAH_Country__c='US',ZTS_US_Active_Product__c= 'Yes'));
        insert prodList;
        
        //Insert Case Product Records           
        List<ZTS_US_Case_Product__c> caseProductList = new  List<ZTS_US_Case_Product__c>();
        caseProductList.add(new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                       ZTS_US_PVW_Product__c = prodList[0].Id,
                                                       ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes'));
        caseProductList.add(new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                       ZTS_US_PVW_Product__c = prodList[1].Id,
                                                       ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes'));
        insert caseProductList;
        
        //testing - Case validation criteria met
        Boolean exceptionThrownMessage = false;
        Test.startTest();
        try{
            delete caseProductList;
        } catch(DmlException ex){
            exceptionThrownMessage =  ex.getMessage().contains(CSE_CaseProductTriggerHandler.CASE_PRODUCT_APPROVEDCASE_DELETE_ERROR) ? true : false;            
        }
        Test.stopTest(); 
        System.assertNotEquals(false, exceptionThrownMessage,  'Deletion should trigger an error message as there has to be atleast one case product for the approved case');
    }
    @isTest
    private static void deleteTriggerRestrictionTest() {        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_SUCCESS);
        insert newCase;
        
        //Insert PVW Product records
        List<ZTS_US_PVW_Product__c> prodList = new List<ZTS_US_PVW_Product__c>();          
        prodList.add(new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L', ZTS_US_MAH_Country__c='US',ZTS_US_Active_Product__c= 'Yes'));   
        prodList.add(new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 10/L', ZTS_US_MAH_Country__c='US',ZTS_US_Active_Product__c= 'Yes'));  
        prodList.add(new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 15/L', ZTS_US_MAH_Country__c='US',ZTS_US_Active_Product__c= 'Yes'));
        insert prodList;
        
        //Insert Case Product Records           
        
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                                            ZTS_US_PVW_Product__c = prodList[0].Id,
                                                                            ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                                            ZTS_US_PVW_Product__c = prodList[1].Id,
                                                                            ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct3 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                                            ZTS_US_PVW_Product__c = prodList[2].Id,
                                                                            ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c[] caseProductList = new  ZTS_US_Case_Product__c[]{caseProduct1,caseProduct2,caseProduct3};
        insert caseProductList;

        ZTS_US_Product_Investigation__c investigation = new ZTS_US_Product_Investigation__c(ZTS_US_Case__c = newCase.Id,ZTS_US_Case_Product__c=caseProduct1.Id);
        insert investigation;

        ZTS_US_Case_Agency_Submission__c agencySubmission = new ZTS_US_Case_Agency_Submission__c(Case__c=newcase.Id,
                                                                                                 Case_Product__c=caseProduct2.Id,
                                                                                                 Agency_Name__c='FDA');
        insert agencySubmission;

        Boolean exceptionThrownMessage = false;
        Test.startTest();
        try{
            delete caseProduct1;
        } catch(DmlException ex){
            exceptionThrownMessage =  ex.getMessage().contains(CSE_CaseProductTriggerHandler.CASE_PRODUCT_INVESTIGATION_DELETE_ERROR) ? true : false;            
        }
        System.assertEquals(true, exceptionThrownMessage,  'Deletion should trigger an error message, you cannot delete a product once an investigation is logged');
        
        DispatchTriggerHandler.firstTimeTracker.clear();
        exceptionThrownMessage = false;
        try{
            delete caseProduct2;
        } catch(DmlException ex){
            exceptionThrownMessage =  ex.getMessage().contains(CSE_CaseProductTriggerHandler.CASE_PRODUCT_AGENCY_DELETE_ERROR) ? true : false;            
        }
        System.assertEquals(true, exceptionThrownMessage,  'Deletion should trigger an error message, you cannot delete a product once an investigation is logged');

        DispatchTriggerHandler.firstTimeTracker.clear();
        exceptionThrownMessage = false;
        try{
            delete caseProduct3;
        } catch(DmlException ex){
            exceptionThrownMessage =  (ex.getMessage().contains(CSE_CaseProductTriggerHandler.CASE_PRODUCT_INVESTIGATION_DELETE_ERROR)
                                        || ex.getMessage().contains(CSE_CaseProductTriggerHandler.CASE_PRODUCT_AGENCY_DELETE_ERROR)) ? true : false;            
        }
        System.assertEquals(false, exceptionThrownMessage,  'The error should not throw, there is no investigation on this product');
        
        Test.stopTest(); 
    }

    @isTest
    private static void sendtoPVWorksTest_positive(){
       final String EXCEPTION_MESSAGE = 'cannot be set to null';
       Case testCase = [SELECT ID, TYPE, RecordTypeId, Sync_Status__c, Subject FROM CASE WHERE Subject = 'Test Case' LIMIT 1];
       ZTS_US_Case_Product__c testCaseProduct = [SELECT ID, ZTS_US_Dose_Unit__c, ZTS_US_Case__c FROM ZTS_US_Case_Product__c LIMIT 1];
       testCaseProduct.ZTS_US_Dose_Unit__c = 'Tablets';
       test.startTest();
           try{
            update testCaseProduct;
            }catch(Exception ex){
            System.Assert(false, 'the test should never throw an error');
            }
        test.stopTest();
        Id testCaseProductId = testCaseProduct.id;
        ZTS_US_Case_Product__c queriedCaseProduct = [SELECT ID, ZTS_US_Dose_Unit__c FROM ZTS_US_Case_Product__c WHERE Id = :testCaseProductId LIMIT 1];
        System.assertEquals(queriedCaseProduct.ZTS_US_Dose_Unit__c, 'Tablets', 'the field should have successfully been changed to Tablets');
    }


    @isTest
    private static void sendtoPVWorksTest_negative(){
       //using only a portion of the error message to check whether or not it works
       final String EXCEPTION_MESSAGE = 'cannot be set to null';
       Case testCase = [SELECT ID, TYPE, RecordTypeId, Sync_Status__c, Subject FROM CASE WHERE Subject = 'Test Case' LIMIT 1];
       ZTS_US_Case_Product__c testCaseProduct = [SELECT ID, ZTS_US_Dose_Unit__c,ZTS_US_Dose__c,
        ZTS_US_Case__c FROM ZTS_US_Case_Product__c LIMIT 1];
       testCaseProduct.ZTS_US_Dose_Unit__c = null;
       testCaseProduct.ZTS_US_Dose__c = null;
       Boolean exceptionThrownMessage = false;
       test.startTest();
           try{
               update testCaseProduct;
           }catch(Exception ex){
               exceptionThrownMessage =  ex.getMessage().contains(EXCEPTION_MESSAGE) ? true : false;
               System.assertEquals(true, exceptionThrownMessage, 'We expect that there will be a validation error on the record due to one of its fields on its approval field set becoming a null value');
           }
       test.stopTest();
       ZTS_US_Case_Product__c testCaseProduct1 = [SELECT ID, ZTS_US_Dose_Unit__c, ZTS_US_Case__c FROM ZTS_US_Case_Product__c WHERE ZTS_US_Dose_Unit__c= null  LIMIT 1];

       System.assertEquals(null,testCaseProduct1.ZTS_US_Dose_Unit__c, 'We expected that an error would be thrown due to a required field being set to null');
    }

    @isTest
    private static void SyncLotAndSerialFromCaseProductToBatchDetail_Test() {
        Case testCase = [SELECT ID, TYPE, RecordTypeId, Sync_Status__c, Subject FROM CASE WHERE Subject = 'Test Case' LIMIT 1];
        ZTS_US_PVW_Product__c pvwProduct = [SELECT ID FROM ZTS_US_PVW_Product__c WHERE Name = 'Test FDA Product' LIMIT 1];

        Id zoetisProductRecordTypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct = ZTS_DataUtilityTest.createCaseProducts(1, zoetisProductRecordTypeId,
            testCase.Id, pvwProduct.Id)[0];

        caseProduct.ZTS_US_Product_Lot__c = TESTLOT;

        Test.startTest();
            insert caseProduct;

            caseProduct = [
                SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, Primary_Batch_Detail__c
                FROM ZTS_US_Case_Product__c
                WHERE Id =: caseProduct.Id
                LIMIT 1];

            System.assertEquals(TESTLOT, caseProduct.ZTS_US_Product_Lot__c, 'Lot Was changed unexpectedly');
            System.assertEquals(TESTSER, caseProduct.ZTS_US_Serial_Number__c, 'Serial Number was not set as expected.');

            List<Batch_Detail__c> batchDetails = [
                SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Primary__c
                FROM Batch_Detail__c
                WHERE ZTS_US_Case_Product__c =: caseProduct.Id];

            System.assertEquals(1, batchDetails.size(), 'More/Less Batch Details were created than expected.');

            System.assertEquals(TESTLOT, batchDetails[0].ZTS_US_Product_Lot__c, 'Lot Was not set as expected');
            System.assertEquals(TESTSER, batchDetails[0].ZTS_US_Serial_Number__c, 'Serial Number was not set as expected.');
            System.assert(batchDetails[0].ZTS_US_Primary__c, 'Primary was not set to true as expected.');
            System.assertEquals(batchDetails[0].Id, caseProduct.Primary_Batch_Detail__c, 'Primary Batch Detail was not set as expected.');

            // Let Case Products and Batch Detail triggers run again
            DispatchTriggerHandler.firstTimeTracker.clear();

            caseProduct.ZTS_US_Serial_Number__c = null;
            update caseProduct;

            caseProduct = [
                SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, Primary_Batch_Detail__c
                FROM ZTS_US_Case_Product__c
                WHERE Id =: caseProduct.Id
                LIMIT 1];

            System.assertEquals(TESTLOT, caseProduct.ZTS_US_Product_Lot__c, 'Lot Was changed unexpectedly');
            System.assertEquals(TESTSER, caseProduct.ZTS_US_Serial_Number__c, 'Serial Number was not set as expected.');

            batchDetails = [
                SELECT Id, ZTS_US_Product_Lot__c, ZTS_US_Serial_Number__c, ZTS_US_Primary__c
                FROM Batch_Detail__c
                WHERE ZTS_US_Case_Product__c =: caseProduct.Id];

            System.assertEquals(1, batchDetails.size(), 'More/Less Batch Details were created than expected.');

            System.assertEquals(TESTLOT, batchDetails[0].ZTS_US_Product_Lot__c, 'Lot Was not set as expected');
            System.assertEquals(TESTSER, batchDetails[0].ZTS_US_Serial_Number__c, 'Serial Number was not set as expected.');            
        Test.stopTest();
    }
}