/**
* @ClassName    : CSE_LongTextAreaAuditTrailHelper_Test
* @SystemChange : SC-009661
* @Description  : Test class for LongTextAreaAuditTrailHelper class
* Modifications Log
* Ver   Date         Author                      	Modification
* 1.0   04-04-2023   Harvinder Kaur @ Zoetis Inc 	Removed Deactivated picklist values from ZTS_US_Interval_Unit__c
**/
@isTest
public with sharing class CSE_LongTextAreaAuditTrailHelper_Test {
    static final String PRODUCTASSESSMENT_RT_ID= 'ZTS_US_Product_Assessment';
    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';

    public static void makeData(){
        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
       ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Species__c='Feline', 
                                                       ZTS_US_Weight_units__c= 'Grams',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                       ZTS_US_Unknown__c = 1, ZTS_US_Under_Treatment__c = 1,
                                                      ZTS_US_Total__c = 5678937, ZTS_US_Sex__c = 'Male',ZTS_US_Weight__c = 9,
                                                      ZTS_US_Recovered__c = 1, ZTS_US_Reacted__c = 6, 
                                                      ZTS_US_Reproductive_Status__c = 'Neutered', ZTS_US_Exposed__c = 6,
                                                      ZTS_US_Euthanized__c = 1,ZTS_US_Died__c = 1,ZTS_US_Breed__c = Breed1.id,
                                                      ZTS_US_Age_unit_to__c ='Minutes',ZTS_US_Age_unit_from__c ='Minutes',
                                                      ZTS_US_Age_to__c =6.1,ZTS_US_Age_from__c = 6.1,
                                                      ZTS_US_Animal_condition_prior_treatment__c = 'Good',
                                                      ZTS_US_Alive_with_Sequela__c = 1);
       insert testUSAnimal;
       String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

       Case testCase = new Case(Subject = 'Test Case',
                           Status = 'New',
                           Origin = 'Email',
                           Type = 'Animal Complaint',
                           RecordTypeId = animalRecordtypeId,                                
                           ZTS_US_Information_Type__c = 'Erred'
                           );
       insert testCase;

       //ZTS_US_Case_Animal__c caseAnimal = (ZTS_US_Case_Animal__c) SL_TestDataFactory.createSObject( new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = testAnimal.Id ), true);
   }
    @isTest
    public static void validateAuditRecord_Animal()
    {
        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Species__c='Feline', 
                                                      ZTS_US_Weight_units__c= 'Grams',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                      ZTS_US_Unknown__c = 1, ZTS_US_Under_Treatment__c = 1,
                                                      ZTS_US_Total__c = 5678937, ZTS_US_Sex__c = 'Male',
                                                      ZTS_US_Recovered__c = 1, ZTS_US_Reacted__c = 6, ZTS_US_Weight__c = 9,
                                                      ZTS_US_Reproductive_Status__c = 'Neutered', ZTS_US_Exposed__c = 6,
                                                      ZTS_US_Euthanized__c = 1,ZTS_US_Died__c = 1,ZTS_US_Breed__c = Breed1.id,
                                                      ZTS_US_Age_unit_to__c ='Minutes',ZTS_US_Age_unit_from__c ='Minutes',
                                                      ZTS_US_Age_to__c = 6.1,ZTS_US_Age_from__c =6.1,
                                                             ZTS_US_Animal_condition_prior_treatment__c = 'Good',
                                                      ZTS_US_Alive_with_Sequela__c = 1);
        insert testUSAnimal;
        test.startTest();
        testUSAnimal.ZTS_US_Concomitant_medical_conditions__c = 'Test Audit Trail record';
        update testUSAnimal;
        test.stopTest();
        ZTS_US_CSE_Audit_Trail__c newAuditRec = [Select Id, Field_Name__c,New_Value__c,Old_Value__c,Object_Label__c,Object_Name__c,Record_Id__c from ZTS_US_CSE_Audit_Trail__c 
                                                    WHERE Field_Name__c = 'ZTS_US_Concomitant_medical_conditions__c' LIMIT 1];
        System.assertEquals(testUSAnimal.Id,newAuditRec.Record_Id__c);
        System.assertEquals('ZTS_US_Concomitant_medical_conditions__c',newAuditRec.Field_Name__c);
        System.assertEquals(null,newAuditRec.Old_Value__c);
        System.assertEquals('Test Audit Trail record',newAuditRec.New_Value__c);
        System.assertEquals('Patient',newAuditRec.Object_Label__c);

    }
    
    @isTest
    public static void validateAuditRecord_Assessment()
    {
        makeData();
        List<Case> caseList = [SELECT id from Case LIMIT 1];
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  new ZTS_US_Assessment__c(ZTS_US_Expected_PA__c = 'No',
                                                                           RecordTypeId = productAssessmentRTId,
                                                                           ZTS_US_Dechallenge_PA__c = 'Abated',
                                                                           ZTS_US_Rechallenge_PA__c = 'No recurrence',
                                                                           ZTS_US_Case__c = caseList[0].id,
                                                                           ZTS_US_Assessor__c = UserInfo.getUserId(),
                                                                           ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason');
        
        insert productAssessment;
        test.startTest();
        productAssessment.ZTS_US_Reason_for_Assessment_PA__c = 'Test Audit Trail record';
        update productAssessment;
        test.stopTest();
        ZTS_US_CSE_Audit_Trail__c newAuditRec = [Select Id, Field_Name__c,New_Value__c,Old_Value__c,Object_Name__c,Object_Label__c,Record_Id__c from ZTS_US_CSE_Audit_Trail__c 
                                                WHERE Field_Name__c = 'ZTS_US_Reason_for_Assessment_PA__c' LIMIT 1];
        System.assertEquals(productAssessment.Id,newAuditRec.Record_Id__c);
        System.assertEquals('ZTS_US_Reason_for_Assessment_PA__c',newAuditRec.Field_Name__c);
        System.assertEquals('Testing Reason',newAuditRec.Old_Value__c);
        System.assertEquals('Test Audit Trail record',newAuditRec.New_Value__c);
        System.assertEquals('Assessment',newAuditRec.Object_Label__c);
    }

    @isTest
    public static void validateAuditRecord_EventNarrative()
    {
        makeData();
        List<Case> caseList = [SELECT id from Case LIMIT 1];
         //Insert Event Narrative record
         ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
         ZTS_US_Outcome_of_Reaction__c = 'Died',
         ZTS_US_Duration_text__c = '30',
         ZTS_US_Reaction_Treated__c ='Yes',
         ZTS_US_Treatment__c = 'Test treatment',
         ZTS_US_Case__c = caseList[0].Id);
         insert eventNarrative;
       
        test.startTest();
        
        CSE_EventNarrativeTriggerHandler enHandler = new CSE_EventNarrativeTriggerHandler();
        DispatchTriggerHandler.setRecursionContexts(enHandler);
        eventNarrative.ZTS_US_Event_Narrative_Summary_Field__c = 'Test Audit Trail record';
        update eventNarrative;

        test.stopTest();
        
        ZTS_US_CSE_Audit_Trail__c newAuditRec = [Select Id, Field_Name__c,New_Value__c,Old_Value__c,Object_Name__c,Object_Label__c,Record_Id__c from ZTS_US_CSE_Audit_Trail__c 
                                                    WHERE Field_Name__c = 'ZTS_US_Event_Narrative_Summary_Field__c' LIMIT 1];
        

        System.assertEquals(eventNarrative.Id,newAuditRec.Record_Id__c);
        System.assertEquals('ZTS_US_Event_Narrative_Summary_Field__c',newAuditRec.Field_Name__c);
        System.assertEquals('xyozlmno',newAuditRec.Old_Value__c);
        System.assertEquals('Test Audit Trail record',newAuditRec.New_Value__c);
        System.assertEquals('Event Narrative',newAuditRec.Object_Label__c);


    }


    @isTest
    public static void validateAuditRecord_VedDraEvent()
    {
        makeData();
        List<Case> caseList = [SELECT id from Case LIMIT 1];
         //Insert Event Narrative record
         ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
         ZTS_US_Outcome_of_Reaction__c = 'Died',
         ZTS_US_Duration_text__c = '30',
         ZTS_US_Reaction_Treated__c ='Yes',
         ZTS_US_Treatment__c = 'Test treatment',
         ZTS_US_Case__c = caseList[0].Id);
         insert eventNarrative;
         //Create PVW Product record
         ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c();
         prod1.Name = 'Simparica Test';
         prod1.CurrencyIsoCode='USD';        
         prod1.ZTS_US_MAH_Country__c = 'US';
         prod1.ZTS_US_Active_Product__c = 'Yes'; 
         prod1.ZTS_US_Formulation_Text__c = 'test';
         prod1.ZTS_US_Brand__c = 'Test Brand';
         insert prod1;
         
         //Insert Case Product Record
         Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId();
         ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = caseList[0].Id,
                                                                         ZTS_US_PVW_Product__c = prod1.Id,
                                                                         ZTS_US_Previous_Exposure__c = 'No',
                                                                         ZTS_US_Product_Role__c = 'Suspect Product',
                                                                         ZTS_US_Product_Used_Correctly__c ='Yes',
                                                                         ZTS_US_Product_problem_type__c = 'Ecotoxicity',
                                                                         ZTS_US_Start_Date__c = date.today()-5,
                                                                         ZTS_US_End_Date__c = date.today()-2,
                                                                         ZTS_US_Serial_Number__c = 'test',
                                                                         ZTS_US_Route__c = 'Implant',
                                                                         ZTS_US_Reason_for_use__c = 'testy', 
                                                                         ZTS_US_Qualifier__c = 'Invalid',
                                                                         ZTS_US_Previous_Reaction__c = 'No',
                                                                         ZTS_US_Ongoing__c = True,
                                                                         ZTS_US_Product_Lot__c = 'test',
                                                                         ZTS_US_Per__c = 4.5,
                                                                         //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                                         ZTS_US_Interval_Unit__c = 'mg',
                                                                         ZTS_US_Frequency_Unit__c = 'Minutes',
                                                                         ZTS_US_Frequency__c = 4 ,
                                                                         RecordTypeId = CaseProductRTId,
                                                                         ZTS_US_Expiry_Date__c = Date.today(), 
                                                                         ZTS_US_Duration_Unit__c = 'Minutes', 
                                                                         ZTS_US_Duration__c = 8, 
                                                                         ZTS_US_Dose_Unit__c = 'Bolus', 
                                                                         ZTS_US_Product_Agency__c = 'FDA',
                                                                         ZTS_US_Dose__c = 5.4,
                                                                         ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable',
                                                                         ZTS_US_Administered_By__c = 'Attending Vet');
         insert caseProduct1;
 
         ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, Duration_Units__c = 'Hour(s)', ZTS_US_Number_of_pts_affected__c = 1, ZTS_US_Start_Date__c = date.today()-3,ZTS_US_End_Date__c = date.today()-1, ZTS_US_Ongoing__c = 'No');
         insert testVedDRA;
       
        test.startTest();
        testVedDRA.ZTS_US_Notes__c = 'Test VedDra Audit';
        update testVedDRA;
        test.stopTest();

        ZTS_US_CSE_Audit_Trail__c newAuditRec1 = [Select Id, Field_Name__c,New_Value__c,Old_Value__c,Object_Name__c,Object_Label__c,Record_Id__c from ZTS_US_CSE_Audit_Trail__c 
                                                    WHERE Field_Name__c = 'ZTS_US_Notes__c' LIMIT 1];
        System.assertEquals(testVedDRA.Id,newAuditRec1.Record_Id__c);
        System.assertEquals('ZTS_US_Notes__c',newAuditRec1.Field_Name__c);
        System.assertEquals(null,newAuditRec1.Old_Value__c);
        System.assertEquals('Test VedDra Audit',newAuditRec1.New_Value__c);
        System.assertEquals('VedDRA Event',newAuditRec1.Object_Label__c);
    }
    

    @isTest
    public static void validateAuditRecord_Negative()
    {
        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', 
                                                      ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', 
                                                            ZTS_US_Species__c='Feline', 
                                                            ZTS_US_Weight_units__c= 'Grams',
                                                            ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                            ZTS_US_Unknown__c = 0, 
                                                            ZTS_US_Under_Treatment__c = 0,
                                                            ZTS_US_Total__c = 7, 
                                                            ZTS_US_Sex__c = 'Male',
                                                            ZTS_US_Recovered__c = 7, 
                                                            ZTS_US_Reacted__c = 7, 
                                                            ZTS_US_Reproductive_Status__c = 'Neutered', 
                                                            ZTS_US_Exposed__c = 7,
                                                            ZTS_US_Euthanized__c = 0,
                                                            ZTS_US_Died__c = 0,
                                                            ZTS_US_Breed__c = Breed1.id,
                                                            ZTS_US_Age_unit_to__c ='Minutes',
                                                            ZTS_US_Age_unit_from__c ='Minutes',
                                                            ZTS_US_Age_to__c = 6.1,
                                                            ZTS_US_Age_from__c = 6.1,
                                                            ZTS_US_Weight__c = 9,
                                                            ZTS_US_Animal_condition_prior_treatment__c = 'Good',
                                                            ZTS_US_Alive_with_Sequela__c = 0);
        insert testUSAnimal;
        test.startTest();
        testUSAnimal.ZTS_US_Age_to__c = 6.1;
        update testUSAnimal;
        test.stopTest();
        List<ZTS_US_CSE_Audit_Trail__c> newAuditRec = [Select Id, Field_Name__c,New_Value__c,Old_Value__c,Object_Name__c,Record_Id__c from ZTS_US_CSE_Audit_Trail__c 
                                                        WHERE Field_Name__c = 'ZTS_US_Age_to__c' LIMIT 1];
        System.assertEquals(0,newAuditRec.size());
    }
}