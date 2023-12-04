/**
* @description       : Logic for current open Case Record and related record field values show into PDF format.
* @author            : Jagadeeswararo G
* @group             : 
* @last modified on  : 11-21-2023
* @last modified by  : Jagadeeswararo G
* Modifications Log
* Ver   Date         Author                      Modification
**/
@isTest
public class CasePDFControllerTest {
    static final String CASEPRODUCT_RT_ID = 'Zoetis_Product';
    static final String ACCOUNT1_ORG_CODE = '1000117840';
    static final String PRODUCTASSESSMENT_RT_ID= 'ZTS_US_Product_Assessment';
    static final string NONZOETIS_CASEPRODUCT_RT_ID = 'Non_Zoetis_Product';
    @isTest
    public static void testSendCaseForApprovalInvalidNarrative()
    {
        setBypasses();
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint');
        insert newCase;
        //Create PVW Product record
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
                                                                        ZTS_US_Product_problem_type__c = 'Ecotoxicity',
                                                                        ZTS_US_Product_Used_Correctly__c = 'Yes',
                                                                        RecordTypeId = CaseProductRTId,
                                                                        ZTS_US_Product_Lot__c='123',ZTS_US_Start_Date__c=system.today(),ZTS_US_Dose_Unit__c='Bolus',
                                                                        ZTS_US_LOE_Reason__c='test',
                                                                        ZTS_US_Attending_Vet_Suspicion_Level__c='Not applicable',ZTS_US_Previous_Exposure__c='No',
                                                                        ZTS_US_Previous_Reaction__c='No',ZTS_US_Reason_for_use__c='test');
        insert caseProduct1;

        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                ( ZTS_US_Assessment_PA__c = 'A - Probable/High'
                                                , ZTS_US_Expected_PA__c = 'No'
                                                , RecordTypeId = productAssessmentRTId
                                                , ZTS_US_Case__c = newCase.id
                                                )
                                                , true
                                                );
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                            (new ZTS_US_Assessment_Products__c
                                                            (ZTS_US_Assessment__c = productAssessment.Id
                                                            ,ZTS_US_PVW_Product__c = prod1.id
                                                            ),true
                                                            );

        //Insert CaseProduct Record
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                 ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                 ZTS_US_Duration_text__c = '30',
                                                                                 ZTS_US_Reaction_Treated__c ='Yes',
                                                                                 ZTS_US_Treatment__c = 'Test treatment',
                                                                                 ZTS_US_Case__c = newCase.Id);
        System.debug('');
        insert eventNarrative;
         //Insert veddra Record
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
         newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
       //address
         Account objAcc = (Account) SL_TestDataFactory.createSObject
                (   new Account
                 (   Name = 'Test Account For RefLabs Portal'
                  ,   ZTS_EU_Market__c = 'Canada'
                  ,   ZTS_EU_VAT_Code__c = '00012'
                  ,   ZTS_EU_Account_Status__c = 'Active'
                  ,   ZTS_EU_Zip_Postal_Code__c = '07306'
                  ,   LIS_Org_Code__c = ACCOUNT1_ORG_CODE
                 )
                 ,   false
                );
        insert objAcc;
        State_Country__c stateCountry = new State_Country__c();
            stateCountry.Name = 'Madrid';
            stateCountry.ZTS_EU_Country__c = 'Spain';
            insert stateCountry;
         Address__c shipToAddress = new Address__c();
            shipToAddress.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Account_Address').getRecordTypeId();
            shipToAddress.Name = 'Evergreen Av. 1234567';
            shipToAddress.ZTS_EU_Account__c =  objAcc.Id;
            shipToAddress.ZTS_EU_Address_Type__c = 'Ship To';
            shipToAddress.ZTS_EU_Country__c = 'Spain';
        	shipToAddress.Address_Line_4__c ='Test';
        	shipToAddress.ZTS_EU_Address_Line_3__c='Test';
        	shipToAddress.ZTS_EU_Address_Line_2__c='Test';
        	shipToAddress.ZTS_EU_City__c='test';
        	shipToAddress.ZTS_EU_Brick_Code__c='test';
            shipToAddress.ZTS_EU_District__c = 'Madrid';
            shipToAddress.Zip_Postal_Code__c = '1234';
            shipToAddress.ZTS_EU_State_County__c = stateCountry.Id;
            shipToAddress.Ship_Indirect__c = 'Y';
            shipToAddress.Is_Active__c = true;
        insert shipToAddress;
        //Insert Contact
        Contact contact = new Contact(
                LastName = 'Doe'
            ,   FirstName = 'Testone'
            ,   ZTS_US_Profession__c = 'Consultant'
            ,   ZTS_US_Job_Function__c = 'Operations'
        	,	ZTS_EU_Primary_Address__c = shipToAddress.Id);
        insert contact;newCase.ContactId=contact.Id;update newCase;
        //Insert Case Contact
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id,ZTS_US_Primary_Reporter__c=true);
        insert caseContact;
        //Insert Breed
        ZTS_US_Breed__c testBreed1 = new ZTS_US_Breed__c(Name = 'Boxer', ZTS_US_Species__c = 'Feline');
        insert testBreed1;
        //Insert Animal
        ZTS_US_Animal__c test_animal = new ZTS_US_Animal__c(Name = 'Tessjyyy'
                                                           ,ZTS_US_Breed__c = testBreed1.Id
                                                           ,ZTS_US_Species__c = 'Feline'
                                                           ,ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID'
                                                           ,ZTS_US_Age_from__c = 6.1
                                                           ,ZTS_US_Age_unit_from__c = 'Day(s)'
                                                           ,ZTS_US_Date_of_Birth__c = date.today()-500);
        insert test_animal;
        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = test_animal.Id );
        insert caseAnimal;
        clearBypasses();
        Boolean expectedExceptionThrown = false;
        ApexPages.currentPage().getParameters().put('id', newCase.Id);
        Test.startTest();
        CasePDFController cpdfc=new CasePDFController();
        Test.stopTest(); 
       
    }
     private static void setBypasses(){
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('BatchDetailTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_CaseContactTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_CaseProductTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_AnimalTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_CaseAnimalTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_AssessmentTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_EventNarrativeTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_VedDraEventTriggerHandler');
        CustomSettingService.setTriggerBypass('ZTS_EU_ServiceRequest', true);
    }
    private static void clearBypasses(){
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
        DispatchTriggerHandler.clearBypass('AddressTriggerHandler');
        DispatchTriggerHandler.clearBypass('BatchDetailTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_CaseContactTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_CaseProductTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_AnimalTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_CaseAnimalTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_AssessmentTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_EventNarrativeTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_VedDraEventTriggerHandler');
        CustomSettingService.setTriggerBypass('ZTS_EU_ServiceRequest', false);
    }
}