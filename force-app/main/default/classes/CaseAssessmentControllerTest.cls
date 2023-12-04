/**
 * @description       : Test class for CaseAssessmentController class
 * @author            : Apurva Verma @ Slalom
 * @group             : 
 * @last modified on  : 04-04-2023
 * @last modified by  : Harvinder Kaur @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                          Modification
 * 1.0   07-01-2021   Apurva Verma @ Slalom           Created the Test Class.
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc       Fix issues with inserting a VedDRA Event due to the related VedDRA Coding
 * 1.2   12-22-2022   Ahmed Elawad @ slalom           CASS-943: update test methods to assign Zoetis product role as Suspect product: createProductAssessmentTest2, testData, createLocalAssessmentTest2
 * 1.3   04-04-2023   Harvinder Kaur @ Zoetis Inc     Removed Deactivated picklist values from ZTS_US_Interval_Unit__c
**/
@isTest
public with sharing class CaseAssessmentControllerTest
{

    static final String REC_TYPE_DEVELOPER_NAME_CASE = 'Animal_Support';
    static final String REC_TYPE_DEVELOPER_NAME_LOCAL_ASSESSMENT = 'ZTS_US_Local_Assessment';
    static final String REC_TYPE_DEVELOPER_NAME_PRODUCT_ASSESSMENT = 'ZTS_US_Product_Assessment';

    static final String localAssessmentRT = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(REC_TYPE_DEVELOPER_NAME_LOCAL_ASSESSMENT).getRecordTypeId();
    static final String productAssessmentRT = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(REC_TYPE_DEVELOPER_NAME_PRODUCT_ASSESSMENT).getRecordTypeId();

        @TestSetup
        static void testData()
        {
            //Insert Event Narrative record
            ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c();
            insert eventNarrative;

            //Get Case Record Type
            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(REC_TYPE_DEVELOPER_NAME_CASE).getRecordTypeId();

            //Create Case Record
            Case testCase = new Case(RecordTypeId = caseRecordTypeId,
                                    Subject = 'Test Case',
                                    Type = 'Inquiry',
                                    Origin = 'Email',
                                    Priority = 'Medium',
                                    Status = 'Open',
                                    ZTS_US_Event_Narrative__c = eventNarrative.Id);
            insert testCase;

            ZTS_US_PVW_Product__c testProduct1 = new ZTS_US_PVW_Product__c
                                                (Name = 'FLU DETECT SWINE'
                                                    ,ZTS_US_Product_Category__c = 'BIO'
                                                    ,ZTS_US_MAH_Country__c = 'US'
                                                    ,ZTS_US_Active_Product__c = 'Yes'
                                                    ,ZTS_US_Formulation_Text__c = 'Test'
                                                );
            ZTS_US_PVW_Product__c testProduct2 = new ZTS_US_PVW_Product__c
                                                (Name = 'FLU DETECT SWINE PLUS'
                                                    ,ZTS_US_Product_Category__c = 'BIO'
                                                    ,ZTS_US_MAH_Country__c = 'US'
                                                    ,ZTS_US_Active_Product__c = 'Yes'
                                                    ,ZTS_US_Formulation_Text__c = 'Test'
                                                );

            ZTS_US_PVW_Product__c testProduct3 =  new ZTS_US_PVW_Product__c
                                                        (Name = 'ANTISEDAN'
                                                            ,ZTS_US_Product_Category__c = 'PHRM'
                                                            ,ZTS_US_MAH_Country__c = 'US'
                                                            ,ZTS_US_Active_Product__c = 'Yes'
                                                            ,ZTS_US_Formulation_Text__c = 'Test'
                                                        );
            ZTS_US_PVW_Product__c testProduct4 =  new ZTS_US_PVW_Product__c
                                                    (Name = 'ANTICOUPE'
                                                        ,ZTS_US_Product_Category__c = 'PHRM'
                                                        ,ZTS_US_MAH_Country__c = 'US'
                                                        ,ZTS_US_Active_Product__c = 'Yes'
                                                        ,ZTS_US_Formulation_Text__c = 'Test'
                                                    );
            insert new ZTS_US_PVW_Product__c[]{testProduct1,testProduct2,testProduct3,testProduct4};

            //Insert 1st Case Product Record
            ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id
                                                                            ,ZTS_US_Administered_By__c = 'Other'
                                                                            ,ZTS_US_Dose__c = 5.4
                                                                            , ZTS_US_Dose_Unit__c = 'Bolus'
                                                                            , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                                            , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                                            , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                                            , ZTS_US_Serial_Number__c = '6587'
                                                                            , ZTS_US_PVW_Product__c = testProduct1.id
                                                                            , ZTS_US_Start_Date__c = date.today()-3
                                                                            , ZTS_US_End_Date__c = date.today()
                                                                            , ZTS_US_Route__c = 'Implant'
                                                                            , ZTS_US_Reason_for_use__c = 'testy'
                                                                            , ZTS_US_Qualifier__c = 'Invalid'
                                                                            , ZTS_US_Previous_Exposure__c = 'No'
                                                                            , ZTS_US_Previous_Reaction__c = 'No'
                                                                            , ZTS_US_Product_Lot__c = 'test'
                                                                            , ZTS_US_Per__c = 4.5
                                                                             //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                                            , ZTS_US_Interval_Unit__c = 'mg'
                                                                            , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                                            , ZTS_US_Frequency__c = 4
                                                                            , ZTS_US_Expiry_Date__c = date.today()
                                                                            ,ZTS_US_Product_Agency__c = 'USDA'
                                                                            ,ZTS_US_Product_Role__c = 'Suspect Product');
            insert caseProduct1;

            //Insert 2nd Case Product Record
            ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id
                                                                            ,ZTS_US_Administered_By__c = 'Other'
                                                                            , ZTS_US_Dose__c = 5.4
                                                                            , ZTS_US_Dose_Unit__c = 'Bolus'
                                                                            , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                                            , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                                            , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                                            , ZTS_US_Serial_Number__c = '6587'
                                                                            , ZTS_US_PVW_Product__c = testProduct3.id
                                                                            , ZTS_US_Start_Date__c = date.today()-3
                                                                            , ZTS_US_End_Date__c = date.today()
                                                                            , ZTS_US_Route__c = 'Implant'
                                                                            , ZTS_US_Reason_for_use__c = 'testy'
                                                                            , ZTS_US_Qualifier__c = 'Invalid'
                                                                            , ZTS_US_Previous_Exposure__c = 'No'
                                                                            , ZTS_US_Previous_Reaction__c = 'No'
                                                                            , ZTS_US_Product_Lot__c = 'test'
                                                                            , ZTS_US_Per__c = 4.5
                                                                             //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                                            , ZTS_US_Interval_Unit__c = 'mg'
                                                                            , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                                            , ZTS_US_Frequency__c = 4
                                                                            , ZTS_US_Expiry_Date__c = date.today()
                                                                            , ZTS_US_Product_Agency__c = 'FDA'
                                                                            , ZTS_US_Product_Role__c = 'Suspect Product');
            insert caseProduct2;

            //Insert Veddra Codes
            ZTS_US_VedDRA_Coding__c veddraCodes = new ZTS_US_VedDRA_Coding__c(Name = 'FVR',
                                                                                ZTS_US_Is_Serious__c = 'No',
                                                                                ZTS_US_VEDDRA_Status__c = 'Official',
                                                                                ZTS_US_Veddra_Display__c = 'Y',
                                                                                Version__c=19,
                                                                                Veddra_Version__c = Label.Veddra_Version_For_Tests);
            insert veddraCodes;

            //Insert Veddra Events to the Event Narrative
            ZTS_US_VedDRA_Event__c veddraEvent = new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.Id,
                                                                            ZTS_US_Ongoing__c = 'Unknown',
                                                                            ZTS_US_VedDRA_Coding__c = veddraCodes.Id);
            insert veddraEvent;
        }

        @isTest
        static void createLocalAssessmentTest()
        {
            Case myCase = [ SELECT Id FROM Case WHERE Subject = 'Test Case'];

            Test.startTest();
            CaseAssessmentController.createLocalAssessment(myCase.Id);
            Test.stopTest();
            
            List<ZTS_US_Assessment__c> localAssessRecCreated = [ SELECT Id, ZTS_US_Case__c 
                                                                FROM ZTS_US_Assessment__c 
                                                                WHERE ZTS_US_Case__c=: myCase.Id 
                                                                AND RecordTypeId =: localAssessmentRT ];

            System.assertEquals(2, localAssessRecCreated.size(),'2 Local Assessment Records are created - FDA and USDA');
        }

        @isTest
        static void createLocalAssessmentTest2()
        {
            Case myCase = [ SELECT Id FROM Case WHERE Subject = 'Test Case'];

            ZTS_US_PVW_Product__c testProduct2 =  [SELECT ID FROM ZTS_US_PVW_Product__c WHERE Name = 'FLU DETECT SWINE PLUS' LIMIT 1];
            ZTS_US_PVW_Product__c testProduct4 =  [SELECT ID FROM ZTS_US_PVW_Product__c WHERE Name = 'ANTICOUPE' LIMIT 1];

            ZTS_US_Case_Product__c caseProduct3 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = myCase.Id
                                                                            ,ZTS_US_Administered_By__c = 'Other'
                                                                            , ZTS_US_Dose__c = 5.4
                                                                            , ZTS_US_Dose_Unit__c = 'Bolus'
                                                                            , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                                            , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                                            , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                                            , ZTS_US_Serial_Number__c = '6587'
                                                                            , ZTS_US_PVW_Product__c = testProduct2.id
                                                                            , ZTS_US_Start_Date__c = date.today()-3
                                                                            , ZTS_US_End_Date__c = date.today()
                                                                            , ZTS_US_Route__c = 'Implant'
                                                                            , ZTS_US_Reason_for_use__c = 'testy'
                                                                            , ZTS_US_Qualifier__c = 'Invalid'
                                                                            , ZTS_US_Previous_Exposure__c = 'No'
                                                                            , ZTS_US_Previous_Reaction__c = 'No'
                                                                            , ZTS_US_Product_Lot__c = 'test'
                                                                            , ZTS_US_Per__c = 4.5
                                                                             //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                                            , ZTS_US_Interval_Unit__c = 'mg'
                                                                            , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                                            , ZTS_US_Frequency__c = 4
                                                                            , ZTS_US_Expiry_Date__c = date.today()
                                                                            , ZTS_US_Product_Agency__c = 'FDA'
                                                                            , ZTS_US_Product_Role__c = 'Suspect Product');
            ZTS_US_Case_Product__c caseProduct4 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = myCase.Id
                                                                            ,ZTS_US_Administered_By__c = 'Other'
                                                                            , ZTS_US_Dose__c = 5.4
                                                                            , ZTS_US_Dose_Unit__c = 'Bolus'
                                                                            , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                                            , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                                            , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                                            , ZTS_US_Serial_Number__c = '6587'
                                                                            , ZTS_US_PVW_Product__c = testProduct4.id
                                                                            , ZTS_US_Start_Date__c = date.today()-3
                                                                            , ZTS_US_End_Date__c = date.today()
                                                                            , ZTS_US_Route__c = 'Implant'
                                                                            , ZTS_US_Reason_for_use__c = 'testy'
                                                                            , ZTS_US_Qualifier__c = 'Invalid'
                                                                            , ZTS_US_Previous_Exposure__c = 'No'
                                                                            , ZTS_US_Previous_Reaction__c = 'No'
                                                                            , ZTS_US_Product_Lot__c = 'test'
                                                                            , ZTS_US_Per__c = 4.5
                                                                             //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                                            , ZTS_US_Interval_Unit__c = 'mg'
                                                                            , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                                            , ZTS_US_Frequency__c = 4
                                                                            , ZTS_US_Expiry_Date__c = date.today()
                                                                            , ZTS_US_Product_Agency__c = 'FDA'
                                                                            , ZTS_US_Product_Role__c = 'Suspect Product');

            /*                                                                
            //Insert Local Assessment Record
            ZTS_US_Assessment__c localAssessment = new ZTS_US_Assessment__c(ZTS_US_Case__c = myCase.Id,
                                                                            ZTS_US_Local_Assessment__c = 'FDA',
                                                                            RecordTypeId = localAssessmentRT);
            insert localAssessment;*/
            Test.startTest();
            //on first run, there are two products on the case, each with a different agency.  should create 2 assessments with 1 assessment product each.
            CaseAssessmentController.createLocalAssessment(myCase.Id);
            List<ZTS_US_Assessment__c> localAssessRecCreated = [ SELECT Id, ZTS_US_Case__c, ZTS_US_Local_Assessment__c,
                                                                    (SELECT Id,ZTS_US_Assessment__c,ZTS_US_PVW_Product__c,
                                                                            ZTS_US_PVW_Product__r.Name,ZTS_US_PVW_Product__r.Product_Agency__c
                                                                     FROM Assessment_Products__r)
                                                                FROM ZTS_US_Assessment__c 
                                                                WHERE ZTS_US_Case__c=: myCase.Id 
                                                                AND RecordTypeId =: localAssessmentRT ];
            system.assertEquals(2,localAssessRecCreated.size());
            for(ZTS_US_Assessment__c localAssess : localAssessRecCreated){
                system.assertEquals(1,localAssess.Assessment_Products__r.size());
            }

            insert new ZTS_US_Case_Product__c[]{caseProduct3,caseProduct4};
            //on first run, there are four products on the case, across two different agencies.  should not create additional assessments but should add 2 assessment products.
            CaseAssessmentController.createLocalAssessment(myCase.Id);
            Test.stopTest();

            List<ZTS_US_Assessment__c> requeryLocalAssessRecCreated = [ SELECT Id, ZTS_US_Case__c, ZTS_US_Local_Assessment__c,
                                                                    (SELECT Id,ZTS_US_Assessment__c,ZTS_US_PVW_Product__c,
                                                                            ZTS_US_PVW_Product__r.Name,ZTS_US_PVW_Product__r.Product_Agency__c
                                                                     FROM Assessment_Products__r)
                                                                FROM ZTS_US_Assessment__c 
                                                                WHERE ZTS_US_Case__c=: myCase.Id 
                                                                AND RecordTypeId =: localAssessmentRT ];
            system.assertEquals(2,requeryLocalAssessRecCreated.size());
            for(ZTS_US_Assessment__c localAssess : requeryLocalAssessRecCreated){
                system.assertEquals(2,localAssess.Assessment_Products__r.size());
            }

            }

        @isTest
        static void createProductAssessmentTest()
        {
            Case myCase = [ SELECT Id FROM Case WHERE Subject = 'Test Case'];

            Test.startTest();
            CaseAssessmentController.createProductAssessment(myCase.Id);
            Test.stopTest();

            List<ZTS_US_Assessment_Products__c> assessmentProdRecordsCreated = [ SELECT Id, ZTS_US_Assessment__c, ZTS_US_Case_ID__c  
                                                                        FROM ZTS_US_Assessment_Products__c
                                                                        WHERE ZTS_US_Case_ID__c =: myCase.Id];
                                                                       
            System.assertEquals(2, assessmentProdRecordsCreated.size(),'Assessment Products Records are created');  
        }   

        @isTest
        static void createProductAssessmentTest2()
        {
            Case myCase = [ SELECT Id FROM Case WHERE Subject = 'Test Case'];

            ZTS_US_PVW_Product__c testProduct3 = [ SELECT Id FROM ZTS_US_PVW_Product__c WHERE Name = 'ANTISEDAN' LIMIT 1];

            //Insert 3rd Case Product Record
            ZTS_US_Case_Product__c caseProduct3 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = myCase.Id
                                                                            ,ZTS_US_Administered_By__c = 'Other'
                                                                            , ZTS_US_Dose__c = 5.4
                                                                            , ZTS_US_Dose_Unit__c = 'Bolus'
                                                                            , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                                            , ZTS_US_Product_Agency__c = 'USDA'
                                                                            , ZTS_US_Serial_Number__c = '6587'
                                                                            , ZTS_US_PVW_Product__c = testProduct3.id
                                                                            , ZTS_US_Start_Date__c = date.today()-3
                                                                            , ZTS_US_End_Date__c = date.today()
                                                                            , ZTS_US_Route__c = 'Implant'
                                                                            , ZTS_US_Reason_for_use__c = 'testy'
                                                                            , ZTS_US_Qualifier__c = 'Invalid'
                                                                            , ZTS_US_Previous_Exposure__c = 'No'
                                                                            , ZTS_US_Previous_Reaction__c = 'No'
                                                                            , ZTS_US_Product_Lot__c = 'test'
                                                                            , ZTS_US_Per__c = 4.5
                                                                             //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                                            , ZTS_US_Interval_Unit__c = 'mg'
                                                                            , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                                            , ZTS_US_Frequency__c = 4
                                                                            , ZTS_US_Expiry_Date__c = date.today()
                                                                            ,ZTS_US_Product_Used_Correctly__c ='Yes'
                                                                            ,ZTS_US_Product_Role__c = 'Suspect Product');
            insert caseProduct3;

            ZTS_US_Assessment__c prodAssessment = new ZTS_US_Assessment__c(ZTS_US_Case__c = myCase.Id,
                                                                            RecordTypeId = productAssessmentRT);
            insert prodAssessment;

            ZTS_US_Assessment_Products__c assessmentProd = new ZTS_US_Assessment_Products__c(ZTS_US_Assessment__c = prodAssessment.Id);
            
            insert assessmentProd;

            Test.startTest();
                CaseAssessmentController.createProductAssessment(myCase.Id);
            Test.stopTest();
            
            List<ZTS_US_Assessment_Products__c> assessmentProdRecordsCreated = [ SELECT Id, ZTS_US_Assessment__c, ZTS_US_Case_ID__c  
                                                                        FROM ZTS_US_Assessment_Products__c
                                                                        WHERE ZTS_US_Case_ID__c =: myCase.Id];
                                  
            System.assertEquals(3, assessmentProdRecordsCreated.size(),'The number of assessment products should equal the number of products');
        }

        @isTest
        static void createLocalAssessmentNegativeTest()
        {
            Case myCase = [ SELECT Id FROM Case WHERE Subject = 'Test Case'];

            //Insert Local Assessment Record
            ZTS_US_Assessment__c localAssessment1 = new ZTS_US_Assessment__c(ZTS_US_Case__c = myCase.Id,
                                                                            ZTS_US_Local_Assessment__c = 'FDA',
                                                                            RecordTypeId = localAssessmentRT);
            insert localAssessment1;

            ZTS_US_Assessment__c localAssessment2 = new ZTS_US_Assessment__c(ZTS_US_Case__c = myCase.Id,
                                                                            ZTS_US_Local_Assessment__c = 'USDA',
                                                                            RecordTypeId = localAssessmentRT);
            insert localAssessment2;

            Test.startTest();
            CaseAssessmentController.createLocalAssessment(myCase.Id);
            Test.stopTest();

            List<ZTS_US_Assessment__c> localAssessRecCreated = [ SELECT Id, ZTS_US_Case__c, ZTS_US_Local_Assessment__c
                                                                FROM ZTS_US_Assessment__c 
                                                                WHERE ZTS_US_Case__c=: myCase.Id 
                                                                AND RecordTypeId =: localAssessmentRT ];

            System.assertNotEquals(0, localAssessRecCreated.size(),'Local Assessment record already exists for both Agencies FDA and USDA');
        }
}