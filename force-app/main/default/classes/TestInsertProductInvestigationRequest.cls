@isTest
public with sharing class TestInsertProductInvestigationRequest {

    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    static final String CASEPRODUCT_RT_ID = 'Zoetis_Product';


    @isTest
    public static void TestInsertProductInvestigationRequest() {

        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Erred',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today());
        insert newCase;


        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c();
        prod1.Name = 'Simparica Test';
        prod1.CurrencyIsoCode='USD';        
        prod1.ZTS_US_MAH_Country__c = 'US';
        prod1.ZTS_US_Active_Product__c = 'Yes';

        insert prod1;
        //Insert Case Product Record
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',
                                                                        ZTS_US_Product_Used_Correctly__c='Yes',
                                                                        ZTS_US_Product_problem_type__c = 'Lack of Efficacy',
                                                                        RecordTypeId = CaseProductRTId);
        insert caseProduct1; 

        List<Batch_Detail__c> batchDetails = new List<Batch_Detail__c>();
        
        Batch_Detail__c aBatchDetail = new Batch_Detail__c();
        aBatchDetail.ZTS_US_Case_Product__c = caseProduct1.Id;
        aBatchDetail.ZTS_US_Product_Lot__c = 'LOT-1234';
        aBatchDetail.LOT_Investigation_Requested__c = true;
        
        insert aBatchDetail;
        Batch_Detail__c aBatchDetail1 = new Batch_Detail__c();
        aBatchDetail1.ZTS_US_Case_Product__c = caseProduct1.Id;
        aBatchDetail1.ZTS_US_Serial_Number__c = 'SER-1234';
        aBatchDetail1.SER_Investigation_Requested__c = true;


        insert aBatchDetail1;


        




        List<List<ZTS_US_Product_Investigation__c>> productInvestigations = new List<List<ZTS_US_Product_Investigation__c>>();

        List<ZTS_US_Product_Investigation__c> listProductInvestigations = new List<ZTS_US_Product_Investigation__c>();

        ZTS_US_Product_Investigation__c aProductInvestigation = new ZTS_US_Product_Investigation__c();
        aProductInvestigation.ZTS_US_Batch_Detail__c = aBatchDetail.Id;
        aProductInvestigation.ZTS_US_Case_Product__c = caseProduct1.Id;
        aProductInvestigation.ZTS_US_Current_Investigation_Status__c = 'Active';
        aProductInvestigation.ZTS_US_Case__c = newCase.Id;
        aProductInvestigation.ZTS_US_Current_Investigation_Status_Date__c = Date.today();
        aProductInvestigation.ZTS_US_Investigation_Type__c = 'Lot';

        listProductInvestigations.add(aProductInvestigation);

        productInvestigations.add(listProductInvestigations);


        Test.startTest();
        InsertProductInvestigationRequest.insertAccounts(productInvestigations);
        Test.stopTest();




    }
}