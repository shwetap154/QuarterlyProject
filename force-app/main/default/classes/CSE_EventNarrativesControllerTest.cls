/**
 * @description       : Test classes for CSE_EventNarrativesController.
 * @author            : Madhu Goriparthi @ Slalom
 * @group             : 
 * @last modified on  : 06-03-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-15-2021   Madhu Goriparthi @ Slalom   Initial Version for Ticket CSE-231
 * 1.1   06-03-2022   Ethan Hirsch @ Zoetis Inc   Fix validation errors and update test setup method.
 * 1.2   09-15-2022   Madhur Verma @ Slalom       Adding fixes for CASS Project
**/
@isTest
public with sharing class CSE_EventNarrativesControllerTest
{
    static final String REC_TYPE_DEVELOPER_NAME_CASE = 'Animal_Support';
    @TestSetup
    static void testData()
    {
        Date today = Date.today();
        //Get Case Record Type
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(REC_TYPE_DEVELOPER_NAME_CASE).getRecordTypeId();
        
        //Create new Case Record
        // Use a value for Status other than Open. 
        // Setting Status to open kicks off logic in CSE Milestone Automation that is data dependent on an Entitlement
        // in the Service Cloud Settings Custom Metadata Type's CSE Entitlment Name field.
        Case newTestCase = (Case) SL_TestDataFactory.createSObject( new Case(RecordTypeId = caseRecordTypeId,
                                                                            Subject = 'Test Case One',
                                                                            Type = 'Animal Complaint',
                                                                            ZTS_EU_Sub_Type__c = 'Extra Label Use',
                                                                            Origin = 'Email',
                                                                            Priority = 'Medium',
                                                                            Status = 'New',
                                                                            ZTS_US_Inquiry_Topic__c='Age'),true);
        
        
        //Insert new Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative1 = (ZTS_US_Event_Narrative__c) SL_TestDataFactory.createSObject( new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = '',
                                                                                                                                                ZTS_US_Duration_text__c = '30',
                                                                                                                                                ZTS_US_End_Date__c = today,
                                                                                                                                                ZTS_US_Case__c = newTestCase.Id), true);
      
        
        newTestCase.ZTS_US_Event_Narrative__c = eventNarrative1.Id;
        update newTestCase;
        
        //Insert Contact
        Contact contact = (Contact) SL_TestDataFactory.createSObject( new Contact(LastName = 'Doe', FirstName = 'Testoneone', ZTS_US_Profession__c = 'Consultant', ZTS_US_Job_Function__c = 'Operations', ZTS_US_Atlas_Id__c= 'PETOWNER_ATLAS_ID'), true);
        
        //Insert Case Contact
        Case_Contact__c caseContact = (Case_Contact__c) SL_TestDataFactory.createSObject( new Case_Contact__c( Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Unknown', Case__c = newTestCase.Id ), true);
        
        ZTS_US_Breed__c breed = (ZTS_US_Breed__c) SL_TestDataFactory.createSObject(ZTS_DataUtilityTest.createBreeds(1, 'Canine')[0], true);

        //Insert Animal
        ZTS_US_Animal__c animal = ZTS_DataUtilityTest.createAnimals(1, System.today().addDays(-10))[0];
        animal.Name = 'Tessy';
        animal.ZTS_US_Species__c = 'Canine';
        animal.ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID';
        animal.ZTS_US_Breed__c = breed.Id;
        animal = (ZTS_US_Animal__c) SL_TestDataFactory.createSObject(animal, true);

        //Insert case Animal
        ZTS_US_Case_Animal__c caseAnimal = (ZTS_US_Case_Animal__c) SL_TestDataFactory.createSObject( new ZTS_US_Case_Animal__c( ZTS_US_Case__c = newTestCase.Id, ZTS_US_Animal__c = animal.Id, ZTS_US_Animal_condition_prior_treatment__c='Good' ), true);
        
        //Insert Product       
        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_PVW_Product__c
            ( 
            Name = 'VANGUARD PLUS 5/L',    
            ZTS_US_MAH_Country__c = 'US',
            ZTS_US_Active_Product__c = 'Yes'
            )
        ,   true
        );  
        
        //Insert case Product
        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Case_Product__c
            (    ZTS_US_Administered_By__c   = 'Other'
            ,    ZTS_US_Dose_Unit__c = 'Bolus'
            ,    ZTS_US_Dose__c = 10
            ,    ZTS_US_Product_problem_type__c = 'Adverse Reaction'
            ,	 ZTS_US_Product_Role__c  = 'Suspect Product'
            ,    ZTS_US_Product_Used_Correctly__c = 'No'
            ,	 ZTS_US_Misuse_Types__c = 'Dosage'
            ,    ZTS_US_Case__c = newTestCase.id
            ,    ZTS_US_PVW_Product__c = testProduct.id
            ,    ZTS_US_Start_Date__c = system.today().addDays(-10)
            )
        ,   true
        );     
        
    }
    
    @isTest
    static void testUpdateEventNarrativeWithCaseProduct()
    { 
        Case myCase = [ Select Id, CreatedDate, ZTS_EU_Sub_Type__c from Case ];
        Case_Contact__c myCaseContact = [ SELECT ZTS_US_Contact_Role__c FROM Case_Contact__c WHERE Case__c = :myCase.Id ];
        ZTS_US_Case_Animal__c testCaseAnimal = [SELECT ZTS_US_Animal_condition_prior_treatment__c, ZTS_US_Animal__r.ZTS_US_Species__c FROM ZTS_US_Case_Animal__c];
        
        ZTS_US_Event_Narrative__c testEventNarrative = [ SELECT Id, ZTS_US_Event_Narrative_Summary_Field__c FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Case__c =: myCase.Id LIMIT 1];
        ZTS_US_Case_Product__c caseProduct = [SELECT ZTS_US_Product_problem_type__c, ZTS_US_Misuse_Types__c FROM ZTS_US_Case_Product__c ];
        ZTS_US_PVW_Product__c prod1 = [SELECT Name FROM ZTS_US_PVW_Product__c ];
        //Insert Template
        String template = '{DATE}: A {Contact} reported a/an {Case Type} and {Misuse Type} involving {Product(s)} in a/an {species} with {HealthStatus} with relevant condition(s)/illness(es). The following product(s) were administered concomitantly: {Product(s)}.';
        testEventNarrative.ZTS_US_Event_Narrative_Summary_Field__c = template;

        String caseCreationDate = String.valueOf(Date.valueOf(myCase.CreatedDate).format());
        template = template.replace('{DATE}', caseCreationDate);
        template = template.replace('{Contact}', myCaseContact.ZTS_US_Contact_Role__c);
        template = template.replace('{Case Type}', caseProduct.ZTS_US_Product_problem_type__c);
        template = template.replace('{Misuse Type}', caseProduct.ZTS_US_Misuse_Types__c);
        template = template.replace('{HealthStatus}', testCaseAnimal.ZTS_US_Animal_condition_prior_treatment__c);
        template = template.replace('{species}', testCaseAnimal.ZTS_US_Animal__r.ZTS_US_Species__c);
        template = template.replace('{Product(s)}', prod1.Name);
        
        Test.startTest();
        //CSE_EventNarrativesController.updateEventNarrative(testEventNarrativeIds);
        update testEventNarrative;
        Test.stopTest();
        
        ZTS_US_Event_Narrative__c reQueriedEventNarrative = [ SELECT Id,ZTS_US_Event_Narrative_Summary_Field__c FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Case__c =: myCase.Id ];
        System.assertEquals(template, reQueriedEventNarrative.ZTS_US_Event_Narrative_Summary_Field__c, 'Generated Event Narrative without Case Products');
        
    }

    @isTest
    static void testUpdateEventNarrativeNegative()
    { 
        Date today = Date.today();
        Case testCase = [ Select Id, CreatedDate, ZTS_EU_Sub_Type__c from Case ];
        Case_Contact__c myCaseContact = [ SELECT ZTS_US_Contact_Role__c FROM Case_Contact__c WHERE Case__c = :testCase.Id ];
        ZTS_US_Case_Product__c[] caseProducts = [SELECT ID FROM ZTS_US_Case_Product__c WHERE ZTS_US_Case__c = :testCase.Id];
        delete caseProducts;

        
        
        ZTS_US_Event_Narrative__c testEventNarrative = [ SELECT Id, ZTS_US_Event_Narrative_Summary_Field__c FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Case__c =: testCase.Id LIMIT 1];
        //Insert Template
        String template = '{DATE}: A {Contact} reported a/an {Case Type} and {Misuse Type} involving {Product(s)} in a/an {species} with {HealthStatus} with relevant condition(s)/illness(es). The following product(s) were administered concomitantly: {Product(s)}.';
        
        Test.startTest();
        String saveError;
        try{
            testEventNarrative.ZTS_US_Event_Narrative_Summary_Field__c = template;
            update testEventNarrative;
        }
        catch (exception e){
            saveError = e.getMessage();
        }
        
        Test.stopTest();
        
        System.assert(saveError!=null && saveError.contains('We were unable'));
            
    }
    
}