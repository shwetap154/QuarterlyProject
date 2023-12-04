/**
 * @description       : Test class for BatchDetailTriggerHandler
 * @author            : Slalom
 * @group             : 
 * @last modified on  : 07-20-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-01-2022   Slalom                      Initial Version
 * 1.1   06-24-2022   Slalom                      Updates
 * 1.2   07-18-2022   Ethan Hirsch @ Zoetis Inc   Remove tests for getInformationFromPVWProduct. This has been moved
 *                                                to BatchDetailService.setFieldsFromPVWProduct with Unit Tests for 
 *                                                this method put in BatchDetailServiceTest.
 * 1.3   07-20-2022   Ethan Hirsch @ Zoetis Inc   Change ZTS_US_Qualifier__c to Lot and Serial Qualifier fields in
 *                                                getInformationFromPVWProduct tests.
 * 1.4   07-22-2022   Ethan Hirsch @ Zoetis Inc   Add additional assertions to Unit Tests to test more scenarios at once
 */
@IsTest
public class BatchDetailTriggerHandlerTest {
    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    static final String CASEPRODUCT_RT_ID = 'Zoetis_Product';
    
    @testSetup static void testSetup() { 
        Id animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
		Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        Case testCase = TestDataFactory.createCase(animalRecordtypeId);
        insert testCase;
        ZTS_US_PVW_Product__c prod = TestDataFactory.createProduct();
        insert prod;
        
        // This will automatically create a batch Detail
        ZTS_US_Case_Product__c cp=TestDataFactory.createCaseProduct(testCase.Id,prod.Id,CaseProductRTId);
        cp.ZTS_US_Serial_Number__c = '1245';
        insert cp;
    }
    
    @IsTest
    static void testBatchDetailUpdateFromCP(){
        ZTS_US_Case_Product__c cp = [select id,ZTS_US_Serial_Number__c from ZTS_US_Case_Product__c limit 1];
        cp.ZTS_US_Serial_Number__c ='12333';

        Test.startTest();
            update cp;
        Test.stopTest();

        Batch_Detail__c bdRecord = [SELECT Id, ZTS_US_Serial_Number__c FROM Batch_Detail__c WHERE ZTS_US_Case_Product__c =: cp.Id];

        System.assertEquals(cp.ZTS_US_Serial_Number__c, bdRecord.ZTS_US_Serial_Number__c, 'Failied to update the batch detail record when the case product is updated');
    }

    // Insert a Batch Detail off oa Case Product
	@IsTest
    static void testBatchDetailInsert(){
        Id animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
		Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        Case testCase = TestDataFactory.createCase(animalRecordtypeId);
        insert testCase;
        ZTS_US_PVW_Product__c prod = TestDataFactory.createProduct();
        insert prod;
        
        ZTS_US_Case_Product__c cp=TestDataFactory.createCaseProduct(testCase.Id,prod.Id,CaseProductRTId);

        Test.startTest();
            insert cp;
        Test.stopTest();

        List<Batch_Detail__c> bdRecords = [
            SELECT Id, ZTS_US_Primary__c, ZTS_US_Serial_Number__c 
            FROM Batch_Detail__c 
            WHERE ZTS_US_Case_Product__c =: cp.Id];

        System.assert(!bdRecords.isEmpty(), 'Failed to create Batch detail when Case Product is inserted');
        

        System.assertEquals(cp.ZTS_US_Serial_Number__c, bdRecords[0].ZTS_US_Serial_Number__c,
            'Serial Number not set on Batch Detail.');

        System.assert(bdRecords[0].ZTS_US_Primary__c,
            'Batch Detail was not set to primary as expected.');

        ZTS_US_Case_Product__c updatedCaseProduct = [
            SELECT Id, Primary_Batch_Detail__c
            FROM ZTS_US_Case_Product__c
            WHERE Id =: cp.Id];

        System.assertEquals(bdRecords[0].Id, updatedCaseProduct.Primary_Batch_Detail__c, 
            'Primary Batch Detail not set properly on the Case Product.');
    }
    
    // Insert Batch Detail manually instead of from the Case Product
	@IsTest
    static void testBatchDetailInsert2()
    {
		Id caseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        
        Case testCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName =: RECORDTYPE_CASE_ANIMAL_SUPPORT_STR LIMIT 1];
        ZTS_US_PVW_Product__c prod = [SELECT Id FROM ZTS_US_PVW_Product__c LIMIT 1];
        
        ZTS_US_Case_Product__c cp = TestDataFactory.createCaseProduct(testCase.Id,prod.Id,caseProductRTId);
        cp.ZTS_US_Serial_Number__c = null;
        insert cp;

        List<Batch_Detail__c> autoCreatedBatchDetails = [SELECT Id FROM Batch_Detail__c WHERE ZTS_US_Case_Product__c =: cp.Id];

        System.assert(autoCreatedBatchDetails.isEmpty(), 'Unexpected Batch Details were created for this Case Product.');

        Batch_Detail__c bd =TestDataFactory.batchDetail(cp.Id);
        bd.ZTS_US_Serial_Number__c = '1245';
        Test.startTest();
            insert bd;
        Test.stopTest();

        ZTS_US_Case_Product__c updatedCaseProduct = [
            SELECT Id, ZTS_US_Serial_Number__c, Primary_Batch_Detail__c
            FROM ZTS_US_Case_Product__c
            WHERE Id =: cp.Id];

        System.assertEquals(bd.Id, updatedCaseProduct.Primary_Batch_Detail__c,
            'Primary Batch Detail was not set to the new Batch Detail.');

        System.assertEquals(bd.ZTS_US_Serial_Number__c, updatedCaseProduct.ZTS_US_Serial_Number__c, 
            'Serial Number was not copied from Case Product to Batch Detail.');

        Batch_Detail__c updatedBatchDetail = [
            SELECT Id, ZTS_US_Primary__c
            FROM Batch_Detail__c
            WHERE Id =: bd.Id];

        System.assert(updatedBatchDetail.ZTS_US_Primary__c, 'Batch Detail was not made Primary as expected.');
    } 

    @IsTest
    static void testBatchDetailBeforeDelete()
    {
        Id animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case testCase = [SELECT ID FROM Case WHERE RecordTypeId = :animalRecordTypeId LIMIT 1];
        //Insert PVW Product records
        List<ZTS_US_PVW_Product__c> prodList = new List<ZTS_US_PVW_Product__c>();          
        prodList.add(new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L', ZTS_US_MAH_Country__c='US',ZTS_US_Active_Product__c= 'Yes'));   
        prodList.add(new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 10/L', ZTS_US_MAH_Country__c='US',ZTS_US_Active_Product__c= 'Yes'));
        prodList.add(new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 15/L', ZTS_US_MAH_Country__c='US',ZTS_US_Active_Product__c= 'Yes'));
        insert prodList;
        
        //Insert Case Product Records           
        
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id,
                                                                            ZTS_US_PVW_Product__c = prodList[0].Id,
                                                                            ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id,
                                                                            ZTS_US_PVW_Product__c = prodList[1].Id,
                                                                            ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct3 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id,
                                                                            ZTS_US_PVW_Product__c = prodList[2].Id,
                                                                            ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert new ZTS_US_Case_Product__c[]{caseProduct1,caseProduct2,caseProduct3};

        Batch_Detail__c bd1 = new Batch_Detail__c(ZTS_US_Case_Product__c=caseProduct1.Id);
        Batch_Detail__c bd2 = new Batch_Detail__c(ZTS_US_Case_Product__c=caseProduct2.Id);
        Batch_Detail__c bd3 = new Batch_Detail__c(ZTS_US_Case_Product__c=caseProduct3.Id);
        insert new Batch_Detail__c[]{bd1,bd2,bd3};

        ZTS_US_Product_Investigation__c investigation = new ZTS_US_Product_Investigation__c(ZTS_US_Case__c = testCase.Id,
                                                                                            ZTS_US_Case_Product__c=caseProduct1.Id,
                                                                                            ZTS_US_Batch_Detail__c=bd1.Id);
        insert investigation;

        ZTS_US_Case_Agency_Submission__c agencySubmission = new ZTS_US_Case_Agency_Submission__c(Case__c=testCase.Id,
                                                                                                 Case_Product__c=caseProduct2.Id,
                                                                                                 Agency_Name__c='FDA');
        insert agencySubmission;
        
        Boolean exceptionThrownMessage = false;
        Test.startTest();
        try{
            delete bd1;
        } catch(DmlException ex){
            exceptionThrownMessage =  ex.getMessage().contains(BatchDetailTriggerHelper.BATCH_DETAIL_INVESTIGATION_DELETE_ERROR) ? true : false;            
        }
        System.assertEquals(true, exceptionThrownMessage,  'Deletion should trigger an error message, you cannot delete a batch detail once an investigation is logged');
        
        DispatchTriggerHandler.firstTimeTracker.clear();
        exceptionThrownMessage = false;
        try{
            delete bd2;
        } catch(DmlException ex){
            exceptionThrownMessage =  ex.getMessage().contains(BatchDetailTriggerHelper.BATCH_DETAIL_AGENCY_DELETE_ERROR) ? true : false;            
        }
        System.assertEquals(true, exceptionThrownMessage,  'Deletion should trigger an error message, you cannot delete a batch detail once an agency submission is logged');
        
        DispatchTriggerHandler.firstTimeTracker.clear();

        exceptionThrownMessage = false;
        try{
            delete bd3;
        } catch(DmlException ex){
            exceptionThrownMessage =  (ex.getMessage().contains(BatchDetailTriggerHelper.BATCH_DETAIL_INVESTIGATION_DELETE_ERROR) 
                                        || ex.getMessage().contains(BatchDetailTriggerHelper.BATCH_DETAIL_AGENCY_DELETE_ERROR)) ? true : false;            
        }
        System.assertEquals(false, exceptionThrownMessage,  'The error should not throw, there is no investigation or agency submission on this batch detail');
        
        Test.stopTest();
        

    }  

    @IsTest
    static void testBatchDetailAfterDelete()
    {
        Batch_Detail__c bd = [
            SELECT Id, ZTS_US_Case_Product__c
            FROM Batch_Detail__c
            LIMIT 1];

        Test.startTest();
            delete bd;
        Test.stopTest();

        ZTS_US_Case_Product__c cp = [
            SELECT Id,ZTS_US_Serial_Number__c
            FROM ZTS_US_Case_Product__c
            LIMIT 1];
        
        System.assert(String.isBlank(cp.ZTS_US_Serial_Number__c),
            String.format('Serial Number not cleared as expected. Current Value: {0}',
                new List<String> {cp.ZTS_US_Serial_Number__c}));

    }    

    @isTest
    private static void getInformationFromPVWProductTest() {        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                
                                Type = 'Animal Complaint');
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
        
        
		List<ZTS_US_PVW_Batch_Number__c> listPVWBatchNumber = new List<ZTS_US_PVW_Batch_Number__c>();
        Date expiryDate = Date.today();
		ZTS_US_PVW_Batch_Number__c objPVWBatchNumber = new ZTS_US_PVW_Batch_Number__c(ZTS_US_Batch_Number__c='534244',
                                                       ZTS_US_PVW_Product__c = prodList[0].Id,
                                                       ZTS_US_Expiry_Date__c = expiryDate,
                                                       ZTS_US_Batch_Type__c ='LOT',
                                                       ZTS_US_Lot_Link_Number__c=1211);
        listPVWBatchNumber.add(objPVWBatchNumber);
        
        ZTS_US_PVW_Batch_Number__c objPVWBatchNumber1 = new ZTS_US_PVW_Batch_Number__c(ZTS_US_Batch_Number__c='534241',
                                                       ZTS_US_PVW_Product__c = prodList[0].Id,
                                                       ZTS_US_Batch_Type__c ='DIL',
                                                       ZTS_US_Expiry_Date__c = expiryDate,
                                                       ZTS_US_Lot_Link_Number__c=1211);
        
        ZTS_US_PVW_Batch_Number__c objPVWBatchNumber2 = new ZTS_US_PVW_Batch_Number__c(ZTS_US_Batch_Number__c='534241',
                                                       ZTS_US_PVW_Product__c = prodList[0].Id,
                                                       ZTS_US_Batch_Type__c ='SER',
                                                       ZTS_US_Expiry_Date__c = expiryDate,
                                                       ZTS_US_Lot_Link_Number__c=1211);
        listPVWBatchNumber.add(objPVWBatchNumber1);
        listPVWBatchNumber.add(objPVWBatchNumber2);
        
        insert listPVWBatchNumber;
        List<ZTS_US_Case_Product__c> caseProductList = new  List<ZTS_US_Case_Product__c>();
        caseProductList.add(new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                       ZTS_US_PVW_Product__c = prodList[0].Id,
                                                       ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes'));
        caseProductList.add(new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                       ZTS_US_PVW_Product__c = prodList[1].Id,
                                                       ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes'));
        
        
        insert caseProductList;



        List<Batch_Detail__c> batchDetailTest = new List<Batch_Detail__c>();
        batchDetailTest.add(new Batch_Detail__c( ZTS_US_Case_Product__c = caseProductList[0].Id, ZTS_US_Serial_Number__c = '534241'));


        insert batchDetailTest;
        
        Test.startTest(); 
            try{
                Batch_Detail__c objCaseProduct = [select id ,Serial_Qualifier__c from Batch_Detail__c where ZTS_US_Serial_Number__c='534241' limit 1];
                System.assertEquals(objCaseProduct.Serial_Qualifier__c,'Valid','wrong InValid qualifier');
            } catch(DmlException ex){
                            
            }
        Test.stopTest(); 
        
    }
    
    @isTest
    private static void getInformationFromPVWProductNegativeTest() {        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                
                                Type = 'Animal Complaint');
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
        
		List<ZTS_US_PVW_Batch_Number__c> listPVWBatchNumber = new List<ZTS_US_PVW_Batch_Number__c>();
        Date expiryDate = Date.today();
		ZTS_US_PVW_Batch_Number__c objPVWBatchNumber = new ZTS_US_PVW_Batch_Number__c(ZTS_US_Batch_Number__c='534244',
                                                       ZTS_US_PVW_Product__c = prodList[0].Id,
                                                       ZTS_US_Expiry_Date__c = expiryDate,
                                                       ZTS_US_Batch_Type__c ='LOT',
                                                       ZTS_US_Lot_Link_Number__c=1211);
        listPVWBatchNumber.add(objPVWBatchNumber);
        
        ZTS_US_PVW_Batch_Number__c objPVWBatchNumber1 = new ZTS_US_PVW_Batch_Number__c(ZTS_US_Batch_Number__c='534241',
                                                       ZTS_US_PVW_Product__c = prodList[0].Id,
                                                       ZTS_US_Batch_Type__c ='DIL',
                                                       ZTS_US_Expiry_Date__c = expiryDate,
                                                       ZTS_US_Lot_Link_Number__c=1211);
        
        ZTS_US_PVW_Batch_Number__c objPVWBatchNumber2 = new ZTS_US_PVW_Batch_Number__c(ZTS_US_Batch_Number__c='534241',
                                                       ZTS_US_PVW_Product__c = prodList[0].Id,
                                                       ZTS_US_Batch_Type__c ='SER',
                                                       ZTS_US_Expiry_Date__c = expiryDate,
                                                       ZTS_US_Lot_Link_Number__c=1211);
        listPVWBatchNumber.add(objPVWBatchNumber1);
        listPVWBatchNumber.add(objPVWBatchNumber2);
        
        insert listPVWBatchNumber;
        
        List<Batch_Detail__c> batchDetailTest = new List<Batch_Detail__c>();
        batchDetailTest.add(new Batch_Detail__c( ZTS_US_Case_Product__c = caseProductList[0].Id, ZTS_US_Product_Lot__c = '53433'));


        insert batchDetailTest;
        
        Test.startTest(); 
            try{
                Batch_Detail__c objBatchDetail = [select id ,Lot_Qualifier__c from Batch_Detail__c where ZTS_US_Product_Lot__c='53433' limit 1];
                System.assertEquals(objBatchDetail.Lot_Qualifier__c,'Invalid','Not valid qualifier');
            } catch(DmlException ex){
                      
            }
        Test.stopTest(); 
        
    }
    
    
}