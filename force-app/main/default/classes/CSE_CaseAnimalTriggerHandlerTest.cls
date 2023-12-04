/****************************************************************************************************************************************** 
 * Trigger Name : CSE_CaseAnimalTriggerHandlerTest
 * Description  : All Trigger Test Logic for CaseAnimal object.
 * Created By   : Slalom(Venkat Joginapally) 
 * Created Date : 13th September, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                      Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Venkat Joginapally          09/13/2021             Created 
 * Christain Brandt                                   Added code  
*****************************************************************************************************************************************/
@isTest
public with sharing class CSE_CaseAnimalTriggerHandlerTest {
    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';

    @isTest
    private static void CSE_CaseAnimalTriggerHandlerPositiveTest() {        
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
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',
                                                                        ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert caseProduct1;

        ZTS_US_Breed__c breed = new ZTS_US_Breed__c(Name = 'Kitty',ZTS_US_Species__c = 'Feline');
        insert breed;
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Breed__c=breed.Id,ZTS_US_Species__c='Feline',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                        ZTS_US_Age_from__c=10,ZTS_US_Age_unit_from__c='Year(s)');
        insert animal;
        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = animal.Id );
        insert caseAnimal;
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
        ZTS_US_Outcome_of_Reaction__c = 'Died',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Case__c = newCase.Id);
        insert eventNarrative;
        newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_SUCCESS;              
        update newCase;

        Boolean exceptionThrownMessage = false;
        Test.startTest();
        try{
            delete caseAnimal;
        } catch(DmlException ex){
            exceptionThrownMessage =  ex.getMessage().contains(CSE_CaseAnimalTriggerHandler.CASE_ANIMAL_APPROVEDCASE_DELETE_ERROR) ? true : false;
        }
        Test.stopTest();
        System.assertNotEquals(false, exceptionThrownMessage,  'Deletion should trigger an error message as there has to be atleast one case animal for the approved case'); 
    }
    /*  These two tests don't really make sense, there's a validation rule preventing more than one case animal to a given case
    @isTest
    private static void CSE_CaseAnimalTriggerHandlerNegativeTest() {        
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
                                                                        ZTS_US_Product_Role__c = 'Concomitant',
                                                                        ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert caseProduct1;
        ZTS_US_Breed__c breed = new ZTS_US_Breed__c(Name = 'Kitty',ZTS_US_Species__c = 'Feline');
        insert breed;
        //Insert Animals
        List<ZTS_US_Animal__c> animalList = new  List<ZTS_US_Animal__c>();
        animalList.add(new ZTS_US_Animal__c(Name = 'Test1', ZTS_US_Species__c='Feline', ZTS_US_Breed__c=breed.Id,ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                            ZTS_US_Age_from__c=10,ZTS_US_Age_unit_from__c='Year(s)'));   
        animalList.add(new ZTS_US_Animal__c(Name = 'Test2', ZTS_US_Species__c='Feline', ZTS_US_Breed__c=breed.Id,ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_IDD',
                                            ZTS_US_Age_from__c=10,ZTS_US_Age_unit_from__c='Year(s)'));
        insert animalList;

        //Insert Case Animal
        List<ZTS_US_Case_Animal__c> caseAnimalList = new  List<ZTS_US_Case_Animal__c>();
        caseAnimalList.add(new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = animalList[0].Id));
        caseAnimalList.add(new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = animalList[1].Id));
        insert caseAnimalList;

        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
        ZTS_US_Outcome_of_Reaction__c = 'Died',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Case__c = newCase.Id);
        insert eventNarrative;
        newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        newCase.ZTS_US_Approved__c = true;
        newCase.Send_to_PV_Works__c = true;
        update newCase;       
        //testing - Case validation criteria met
        Test.startTest();
        delete caseAnimalList[0];
        Test.stopTest(); 
        List<ZTS_US_Case_Animal__c> existingCaseAnimals = [SELECT Id FROM ZTS_US_Case_Animal__c WHERE ZTS_US_Case__c =: newCase.Id];
        System.assertEquals(1, existingCaseAnimals.size(), 'One case animal record should be deleted and there should only be one existing and shoud not throw an error on deletion');                
    }

    @isTest
    private static void CSE_CaseAnimalTriggerHandlerDeleteMultipleTest() {        
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
                                                                        ZTS_US_Product_Role__c = 'Concomitant',
                                                                        ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert caseProduct1;
        ZTS_US_Breed__c breed = new ZTS_US_Breed__c(Name = 'Kitty',ZTS_US_Species__c = 'Feline');
        insert breed;
        //Insert Animals
        List<ZTS_US_Animal__c> animalList = new  List<ZTS_US_Animal__c>();
        animalList.add(new ZTS_US_Animal__c(Name = 'Test1', ZTS_US_Species__c='Feline',ZTS_US_Breed__c=breed.Id,ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                            ZTS_US_Age_from__c=10,ZTS_US_Age_unit_from__c='Year(s)'));   
        animalList.add(new ZTS_US_Animal__c(Name = 'Test2', ZTS_US_Species__c='Feline',ZTS_US_Breed__c=breed.Id,ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_IDD',
                                            ZTS_US_Age_from__c=10,ZTS_US_Age_unit_from__c='Year(s)'));
        insert animalList;

        //Insert Case Animal
        List<ZTS_US_Case_Animal__c> caseAnimalList = new  List<ZTS_US_Case_Animal__c>();
        caseAnimalList.add(new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = animalList[0].Id));
        caseAnimalList.add(new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = animalList[1].Id));
        insert caseAnimalList;

        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
        ZTS_US_Outcome_of_Reaction__c = 'Died',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Case__c = newCase.Id);
        insert eventNarrative;
        newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        newCase.ZTS_US_Approved__c = true;
        newCase.Send_to_PV_Works__c = true;
        update newCase;       
        //testing - Case validation criteria met
        Boolean exceptionThrownMessage = false;
        Test.startTest();
        try{
            delete caseAnimalList;
        } catch(DmlException ex){
            exceptionThrownMessage =  ex.getMessage().contains(CSE_CaseAnimalTriggerHandler.CASE_ANIMAL_APPROVEDCASE_DELETE_ERROR) ? true : false;                 
        }
        Test.stopTest(); 
        System.assertNotEquals(false, exceptionThrownMessage,  'Deletion should trigger an error message as there has to be atleast one case animal for the approved case');
    }*/
    @isTest
    private static void testAnimalSyncBeforeInsertAfterUpdate() {        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Insert Sync Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint');
        insert new Case[]{newCase};
        ZTS_US_Breed__c breed = new ZTS_US_Breed__c(Name = 'Kitty',ZTS_US_Species__c = 'Feline');
        insert breed;
        
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Breed__c=breed.Id,ZTS_US_Species__c='Feline',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                        ZTS_US_Age_from__c=10,ZTS_US_Age_unit_from__c='Year(s)',ZTS_US_Weight__c =10,ZTS_US_Weight_units__c='Pounds');
        
        insert animal;
        
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = animal.Id );
        insert caseAnimal;
        
        Test.startTest();

        //testing before insert
        ZTS_US_Case_Animal__c syncedCaseAnimal = [ SELECT Id,ZTS_US_Age_from__c,ZTS_US_Age_unit_from__c,ZTS_US_Weight__c,ZTS_US_Weight_units__c
                                                    FROM ZTS_US_Case_Animal__c 
                                                    WHERE Id=:caseAnimal.Id LIMIT 1];
        system.assertEquals(animal.ZTS_US_Age_from__c,syncedCaseAnimal.ZTS_US_Age_from__c);
        system.assertEquals(animal.ZTS_US_Age_unit_from__c,syncedCaseAnimal.ZTS_US_Age_unit_from__c);
        system.assertEquals(animal.ZTS_US_Weight__c,syncedCaseAnimal.ZTS_US_Weight__c);
        system.assertEquals(animal.ZTS_US_Weight_units__c,syncedCaseAnimal.ZTS_US_Weight_units__c);

        //testing after update
        syncedCaseAnimal.ZTS_US_Weight_units__c = 'Pounds';
        syncedCaseAnimal.ZTS_US_Weight__c = 5;
        syncedCaseAnimal.ZTS_US_Age_from__c = 5;
        update syncedCaseAnimal;

        ZTS_US_Animal__c updatedAnimal = [ SELECT Id,ZTS_US_Age_from__c,ZTS_US_Age_unit_from__c,ZTS_US_Weight__c 
                                            FROM ZTS_US_Animal__c 
                                            WHERE Id=:animal.Id LIMIT 1];
        system.assertEquals(syncedCaseAnimal.ZTS_US_Weight__c,updatedAnimal.ZTS_US_Weight__c);
        //age should not have synced because the case patient age was less than the patient age.
        system.assertEquals(10,updatedAnimal.ZTS_US_Age_from__c);


        Test.stopTest();
    }
    @isTest
    private static void testAnimalSyncBeforeUpdate() {        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Insert Sync Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint');
        insert new Case[]{newCase};
        ZTS_US_Breed__c breed = new ZTS_US_Breed__c(Name = 'Kitty',ZTS_US_Species__c = 'Feline');
        insert breed;
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Breed__c=breed.Id,ZTS_US_Species__c='Feline',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                        ZTS_US_Weight__c=10,ZTS_US_Weight_units__c='Pounds',
                                                        ZTS_US_Age_unit_to__c ='Minutes',
                                                        ZTS_US_Age_unit_from__c ='Minutes',
                                                        ZTS_US_Age_to__c = 7,ZTS_US_Age_from__c = 6);
        insert animal;
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id,ZTS_US_Weight__c=1,ZTS_US_Weight_units__c='Pounds',
                                                                    ZTS_US_Age_unit_to__c ='Minutes',
                                                                    ZTS_US_Age_unit_from__c ='Minutes',
                                                                    ZTS_US_Age_to__c = 7,ZTS_US_Age_from__c = 6);      
        insert caseAnimal;  
        Test.startTest();

        //testing before update
        caseAnimal.ZTS_US_Animal__c = animal.Id;
        update caseAnimal;
        ZTS_US_Case_Animal__c syncedCaseAnimal = [ SELECT Id,ZTS_US_Weight__c,ZTS_US_Weight_units__c 
                                                    FROM ZTS_US_Case_Animal__c 
                                                    WHERE Id=:caseAnimal.Id LIMIT 1];
        system.assertEquals(animal.ZTS_US_Weight__c,syncedCaseAnimal.ZTS_US_Weight__c);

        Test.stopTest();
    }
    @isTest
    private static void testAnimalHouseHoldValidationUpdatePositive() { 
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Insert Sync Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint');
        insert new Case[]{newCase};
        Account household = new Account(Name='test',BillingStreet='123 test',BillingCity='ny',
                                        BillingState='ny',BillingPostalCode='12345',BillingCountry='United States');
        insert household;
        Contact petOwner = new Contact(LastName='test',AccountId=household.id,ZTS_US_Profession__c='Dad',ZTS_US_Job_Function__c='Owner');
        insert petOwner;
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = petOwner.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id);
        insert caseContact;
        ZTS_US_Breed__c breed = new ZTS_US_Breed__c(Name = 'Kitty',ZTS_US_Species__c = 'Feline');
        insert breed;
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Breed__c=breed.Id,ZTS_US_Species__c='Feline',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                        ZTS_US_Age_from__c=10,ZTS_US_Age_unit_from__c='Year(s)',ZTS_US_Pet_Owner__c=petOwner.Id);
        insert animal;
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id,ZTS_US_Age_from__c=1,ZTS_US_Age_unit_from__c='Day(s)');      
        insert caseAnimal;
        Test.startTest();
        //testing before update
        caseAnimal.ZTS_US_Animal__c = animal.Id;
        update caseAnimal;
        Test.stopTest();
        
        ZTS_US_Case_Animal__c updatedCaseAnimal = [ SELECT Id,ZTS_US_Animal__c
                                                    FROM ZTS_US_Case_Animal__c 
                                                    WHERE Id=:caseAnimal.Id LIMIT 1];
        system.assertEquals(animal.Id,updatedCaseAnimal.ZTS_US_Animal__c);
    }
    @isTest
    private static void testAnimalHouseHoldValidationUpdateNegative() {
        Account household = new Account(Name='test',BillingStreet='123 test',BillingCity='ny',
                                        BillingState='ny',BillingPostalCode='12345',BillingCountry='United States');
        insert household;
        Contact petOwner = new Contact(LastName='test',AccountId=household.id,ZTS_US_Profession__c='Dad',ZTS_US_Job_Function__c='Owner');
        insert petOwner;
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Insert Sync Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint');
        insert new Case[]{newCase};
        ZTS_US_Breed__c breed = new ZTS_US_Breed__c(Name = 'Kitty',ZTS_US_Species__c = 'Feline');
        insert breed;
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Breed__c=breed.Id,ZTS_US_Species__c='Feline',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                        ZTS_US_Age_from__c=10,ZTS_US_Age_unit_from__c='Year(s)',ZTS_US_Pet_Owner__c=petOwner.Id);
        insert animal;
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id,ZTS_US_Age_from__c=1,ZTS_US_Age_unit_from__c='Day(s)');      
        insert caseAnimal;
        Test.startTest();
        //testing before update
        caseAnimal.ZTS_US_Animal__c = animal.Id;
        try{
            update caseAnimal;
            ZTS_US_Case_Animal__c updatedCaseAnimal = [ SELECT Id,ZTS_US_Animal__c
                                                FROM ZTS_US_Case_Animal__c 
                                                WHERE Id=:caseAnimal.Id LIMIT 1];
            system.assertEquals(null,updatedCaseAnimal.ZTS_US_Animal__c);
        }
        catch(Exception e){
            system.assert(e.getMessage().contains('Before adding this Case Patient'));
        }
        Test.stopTest();
    }
    @isTest
    private static void testAnimalHouseHoldValidationInsertPositive() {                   
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Insert Sync Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint');
        insert new Case[]{newCase};
        Account household = new Account(Name='test',BillingStreet='123 test',BillingCity='ny',
                                        BillingState='ny',BillingPostalCode='12345',BillingCountry='United States');
        insert household;
        Contact petOwner = new Contact(LastName='test',AccountId=household.id,ZTS_US_Profession__c='Dad',ZTS_US_Job_Function__c='Owner');
        insert petOwner;
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = petOwner.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id);
        insert caseContact;
        ZTS_US_Breed__c breed = new ZTS_US_Breed__c(Name = 'Kitty',ZTS_US_Species__c = 'Feline');
        insert breed;
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Breed__c=breed.Id,ZTS_US_Species__c='Feline',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                        ZTS_US_Age_from__c=10,ZTS_US_Age_unit_from__c='Year(s)',ZTS_US_Pet_Owner__c=petOwner.Id);
        insert animal;
        Test.startTest();
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Animal__c=animal.Id,ZTS_US_Case__c = newCase.Id,ZTS_US_Age_from__c=1,ZTS_US_Age_unit_from__c='Day(s)');      
        insert caseAnimal;
        Test.stopTest();
        
        ZTS_US_Case_Animal__c updatedCaseAnimal = [ SELECT Id,ZTS_US_Animal__c
                                                    FROM ZTS_US_Case_Animal__c 
                                                    WHERE Id=:caseAnimal.Id LIMIT 1];
        system.assertEquals(animal.Id,updatedCaseAnimal.ZTS_US_Animal__c);
    }
    @isTest
    private static void testAnimalHouseHoldValidationInsertNegative() {        
        
        Account household = new Account(Name='test',BillingStreet='123 test',BillingCity='ny',
                                        BillingState='ny',BillingPostalCode='12345',BillingCountry='United States');
        insert household;
        Contact petOwner = new Contact(LastName='test',AccountId=household.id,ZTS_US_Profession__c='Dad',ZTS_US_Job_Function__c='Owner');
        insert petOwner;
            
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Insert Sync Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint');
        insert new Case[]{newCase};
        ZTS_US_Breed__c breed = new ZTS_US_Breed__c(Name = 'Kitty',ZTS_US_Species__c = 'Feline');
        insert breed;
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Breed__c=breed.Id,ZTS_US_Species__c='Feline',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                        ZTS_US_Age_from__c=10,ZTS_US_Age_unit_from__c='Year(s)',ZTS_US_Pet_Owner__c=petOwner.Id);
        insert animal;
        
        Test.startTest();
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Animal__c=animal.Id,ZTS_US_Case__c = newCase.Id,ZTS_US_Age_from__c=1,
                                                                        ZTS_US_Age_unit_from__c='Day(s)');      
        try{
            insert caseAnimal;
            system.assertEquals(null,caseAnimal.Id);
        }
        catch(Exception e){
            system.assert(e.getMessage().contains('Before adding this Case Patient'));
        }
        Test.stopTest();
    }
}