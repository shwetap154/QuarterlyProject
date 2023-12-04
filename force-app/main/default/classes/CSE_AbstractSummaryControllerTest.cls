/**
* @ClassName    : CSE_AbstractSummaryControllerTest
* @JIRATicket   : CSE-231
* @CreatedOn    : 7/22/2021
* @CreatedBy    : Madhu Goriparthi
* @Description  : Test class for populating Abstract Summary field on Event Narrative
**/

@isTest
public with sharing class CSE_AbstractSummaryControllerTest
{
    static final String REC_TYPE_DEVELOPER_NAME_CASE = 'Animal_Support';
    static final String ANIMAL_COMPLAINT_CASE_TYPE = 'Animal Complaint';
    static final String HUMAN_EXPOSURE_CASE_TYPE = 'Human Exposure';
    @TestSetup
    static void testData()
    {
        //Get Case Record Type
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(REC_TYPE_DEVELOPER_NAME_CASE).getRecordTypeId();
        
        //Create new Case Record
        Case caseRecord = (Case) SL_TestDataFactory.createSObject( new Case(RecordTypeId = caseRecordTypeId,
                                                                             Subject = 'Test Case for Abstract Summary',
                                                                             Type = ANIMAL_COMPLAINT_CASE_TYPE,
                                                                             ZTS_EU_Sub_Type__c = 'VMIPS',
                                                                             Origin = 'Phone',
                                                                             Priority = 'Medium',
                                                                             Status = 'Open',
                                                                             ZTS_US_Source__c = 'Attending Vet'),true);
        
        //Insert new Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative1 = (ZTS_US_Event_Narrative__c) SL_TestDataFactory.createSObject( new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyzlmnopq',
                                                                                                                                                ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                                                                                ZTS_US_Duration_text__c = '30',
                                                                                                                                                ZTS_US_Case__c = caseRecord.Id), true);
        
        caseRecord.ZTS_US_Event_Narrative__c = eventNarrative1.Id;
        update caseRecord;    
        
        ZTS_US_PVW_Product__c prod1 = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
            (   new ZTS_US_PVW_Product__c
             ( 
                 Name = 'VANGUARD PLUS 5/L',    
                 ZTS_US_MAH_Country__c = 'US',
                 ZTS_US_Active_Product__c = 'Yes'
             )
             ,   true
            );  
        
        Id zoetisRecordTypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId();
        Id nonZoetisRecordTypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Non_Zoetis_Product').getRecordTypeId();
        
        //Insert Case Product
        ZTS_US_Case_Product__c caseProduct2 = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject( new ZTS_US_Case_Product__c(ZTS_US_Case__c = caseRecord.Id,
                                                                                                                                    ZTS_US_PVW_Product__c = prod1.Id,
                                                                                                                                    ZTS_US_Product_problem_type__c='(Associated) Product Defect;Lack of Efficacy',
                                                                                                                                    ZTS_US_Defect_Product__c='Activation Failure;Expired product',
                                                                                                                                    ZTS_US_Filling_Packaging__c='Component Damaged/Defective;Container - Cannot Open',
                                                                                                                                    ZTS_US_Product_Role__c  = 'Suspect Product',
                                                                                                                                    ZTS_US_LOE_Reason__c='Improper Administration',
                                                                                                                                    ZTS_US_Serial_Number__c = 'XZMZ',
                                                                                                                                    ZTS_US_Product_Lot__c = 'XY2879',
                                                                                                                                    ZTS_US_Product_Used_Correctly__c = 'no',
                                                                                                                                    ZTS_US_Misuse_Types__c = 'Indication',
                                                                                                                                    ZTS_US_Previous_Exposure__c = 'Unknown',
                                                                                                                                    ZTS_US_Product_Agency__c = 'USDA',
                                                                                                                                    RecordTypeId = zoetisRecordTypeId), true);
        
        //Insert Concomitant Case Product
        ZTS_US_Case_Product__c caseProduct3 = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject( new ZTS_US_Case_Product__c(ZTS_US_Case__c = caseRecord.Id,
                                                                                                                                    ZTS_US_PVW_Product__c = prod1.Id,
                                                                                                                                    ZTS_US_Product_Role__c='Concomitant',
                                                                                                                                    ZTS_US_Non_Zoetis_Product_Name_Generic__c = 'test',
                                                                                                                                    ZTS_US_Non_Zoetis_Product_Brand__c = 'Test',
                                                                                                                                    ZTS_US_Non_Zoetis_Formulation__c = 'Aerosol',
                                                                                                                                    ZTS_US_Product_Used_Correctly__c = 'no',
                                                                                                                                    ZTS_US_Misuse_Types__c = 'Indication',
                                                                                                                                    ZTS_US_Previous_Exposure__c = 'unknown',
                                                                                                                                    RecordTypeId = nonZoetisRecordTypeId), true);
        
        //Insert Breed
        ZTS_US_Breed__c breed = (ZTS_US_Breed__c) SL_TestDataFactory.createSObject( new ZTS_US_Breed__c(Name = 'Tiger', ZTS_US_Species__c = 'Feline'), true);
        
        //Insert Animal
        ZTS_US_Animal__c animal = (ZTS_US_Animal__c) SL_TestDataFactory.createSObject( new ZTS_US_Animal__c(Name = 'Tessyyy',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID', ZTS_US_Species__c='Feline', ZTS_US_Breed__c = breed.Id,  ZTS_US_Date_of_Birth__c = Date.today().addDays( -1 ) ), true);
        
        //Insert case Animal
        ZTS_US_Case_Animal__c caseAnimal1 = (ZTS_US_Case_Animal__c) SL_TestDataFactory.createSObject( new ZTS_US_Case_Animal__c(ZTS_US_Case__c = caseRecord.Id, ZTS_US_Animal__c = animal.Id, ZTS_US_Animal_condition_prior_treatment__c = 'Critical', 
                                                                                                                               ZTS_US_Recovered__c = 1, ZTS_US_Died__c = 1, ZTS_US_Under_Treatment__c = 1, ZTS_US_Euthanized__c = 1, ZTS_US_Alive_with_Sequela__c = 1), true);
       
        ZTS_US_Event_Narrative__c eventNarrative = [ SELECT Id FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Case__c =: caseRecord.Id ];
        ZTS_US_VedDRA_Coding__c objVedraCoding = new ZTS_US_VedDRA_Coding__c(Name='Fever',
                                                                            ZTS_US_VEDDRA_Class__c = 'C',
                                                                            ZTS_US_VEDDRA_Status__c = 'Official',
                                                                            ZTS_US_Veddra_Display__c = 'Y',
                                                                            Version__c=45,
                                                                            VedDRA_Version__c = Label.Veddra_Version_For_Tests);
        insert objVedraCoding;
        
        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id,
                                                                        Duration_Units__c = 'Hour(s)', 
                                                                        ZTS_US_Number_of_pts_affected__c = 1, 
                                                                        ZTS_US_Start_Date__c = date.today(),
                                                                        ZTS_US_VedDRA_Coding__c =objVedraCoding.Id,
                                                                        ZTS_US_Ongoing__c = 'Yes',
                                                                        Sequence__c='1') ;
        insert testVedDRA;
    }
    
    public static Case getCaseRecord(){
       return [SELECT Id from Case LIMIT 1];
    }
    
    @isTest
    static void testupdateAbstractSummary()
    { 
        
        Case caseRecord = getCaseRecord();
        ZTS_US_Event_Narrative__c testEventNarrative = [ SELECT Id,ZTS_US_Outcome_of_Reaction__c,ZTS_US_Abstract_Summary__c FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Case__c =: caseRecord.Id ];
        testEventNarrative.ZTS_US_Reaction_Treated__c = 'Yes';
        testEventNarrative.ZTS_US_Treatment__c = 'Test';
        update testEventNarrative;
        
        Test.startTest();
        	CSE_AbstractSummaryController.updateAbstractSummary(testEventNarrative.Id);
        Test.stopTest();
        
        ZTS_US_Event_Narrative__c reQueriedEventNarrative = [ SELECT Id,ZTS_US_Abstract_Summary__c FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Case__c =: caseRecord.Id ];
        System.assertNotEquals(Null, reQueriedEventNarrative.ZTS_US_Abstract_Summary__c);
        System.assertEquals(true, reQueriedEventNarrative.ZTS_US_Abstract_Summary__c.contains('VANGUARD PLUS 5/L'),'Generated Abstract Summary is Updated with right Product Information');
    }
    
    @isTest
    static void testupdateAbstractSummaryWithAbstractSummary()
    { 
        Case caseRecord = getCaseRecord();

        //Insert Case Product
        ZTS_US_Case_Product__c caseProduct2 = [SELECT Id,ZTS_US_Product_problem_type__c FROM ZTS_US_Case_Product__c LIMIT 1 ];

        caseProduct2.ZTS_US_Product_problem_type__c='Adverse Reaction;(Associated) Product Defect;Lack of Efficacy';
        update caseProduct2;
       
        ZTS_US_Event_Narrative__c testEventNarrative = [ SELECT Id,ZTS_US_Outcome_of_Reaction__c,ZTS_US_Abstract_Summary__c FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Case__c =: caseRecord.Id ];
        
        
        Test.startTest();
        	CSE_AbstractSummaryController.updateAbstractSummary(testEventNarrative.Id);
        Test.stopTest();
        
        ZTS_US_Event_Narrative__c reQueriedEventNarrative = [ SELECT Id,ZTS_US_Abstract_Summary__c FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Case__c =: caseRecord.Id ];
        system.debug(reQueriedEventNarrative.ZTS_US_Abstract_Summary__c);
        System.assertNotEquals(Null, reQueriedEventNarrative.ZTS_US_Abstract_Summary__c);
        System.assertEquals(true, reQueriedEventNarrative.ZTS_US_Abstract_Summary__c.contains('Lack of Efficacy'),'Generated Abstract Summary is not updated with right Problem Type');
        System.assertEquals(true, reQueriedEventNarrative.ZTS_US_Abstract_Summary__c.contains('(Associated) Product Defect'),'Generated Abstract Summary is not updated with right Problem Type');
        
    }
    
}