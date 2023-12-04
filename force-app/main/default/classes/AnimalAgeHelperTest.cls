@isTest
public with sharing class AnimalAgeHelperTest {
    @TestSetup
    static void makeData(){
        //Get Case Record Type
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();

        //Create Case Record
        Case testCase = new Case(RecordTypeId = caseRecordTypeId,
                                Subject = 'Test Case',
                                Type = 'Inquiry',
                                Origin = 'Email',
                                Priority = 'Medium',
                                Status = 'Open');
        insert testCase;
        ZTS_US_Breed__c breedAnimal = new ZTS_US_Breed__c(Name = 'Kitty',ZTS_US_Species__c = 'Feline');
        ZTS_US_Breed__c breedHuman = new ZTS_US_Breed__c(Name = 'Human',ZTS_US_Species__c = 'Human');
        insert new ZTS_US_Breed__c[]{breedAnimal,breedHuman};
    }
    @isTest
    static void testAgeValidationAnimalUpdate()
    {
        ZTS_US_Breed__c breed = [SELECT Id FROM ZTS_US_Breed__c WHERE ZTS_US_Species__c = 'Feline' LIMIT 1];
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Gato', ZTS_US_Breed__c=breed.Id,ZTS_US_Species__c='Feline',
                                                        ZTS_US_Date_of_Birth__c=date.today().addYears(-1));
        insert animal;
        Boolean errorThrown = false;
        try{
            animal.ZTS_US_Age_from__c = 2;
            animal.ZTS_US_Age_unit_from__c = 'Year(s)';
            update animal;
        }
        catch(Exception e){
            system.assert(e.getMessage().contains('Age cannot exceed Date of Birth'));
            errorThrown=true;
        }
        system.assertEquals(true,errorThrown);
    }

    @isTest
    static void testAgeValidationHumanAnimalUpdate()
    {
        ZTS_US_Breed__c breed = [SELECT Id FROM ZTS_US_Breed__c WHERE ZTS_US_Species__c = 'Human' LIMIT 1];
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Charles', ZTS_US_Breed__c=breed.Id,ZTS_US_Species__c='Human',
                                                        ZTS_US_Date_of_Birth__c=date.today().addMonths(-1));
        insert animal;
        Boolean errorThrown = false;
        try{
            animal.ZTS_US_Age_text__c = 2;
            animal.Age_units__c = 'Month(s)';
            update animal;
        }
        catch(Exception e){
            system.assert(e.getMessage().contains('Age cannot exceed Date of Birth'));
            errorThrown=true;
        }
        system.assertEquals(true,errorThrown);

        errorThrown=false;
        DispatchTriggerHandler.firstTimeTracker.clear();
        try{
            animal.ZTS_US_Age_text__c = 2;
            animal.Age_units__c = 'Day(s)';
            update animal;
        }
        catch(Exception e){
            errorThrown=true;
        }
        system.assertEquals(false,errorThrown);

    }
    
    @isTest
    static void testAgeValidationCaseAnimalInsert()
    {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        ZTS_US_Breed__c breed = [SELECT Id FROM ZTS_US_Breed__c WHERE ZTS_US_Species__c = 'Feline' LIMIT 1];
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Gato', ZTS_US_Breed__c=breed.Id,ZTS_US_Species__c='Feline',
                                                        ZTS_US_Date_of_Birth__c=date.today().addYears(-1));
        insert animal;
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = animal.Id
                                                                        ,ZTS_US_Age_from__c=2,ZTS_US_Age_unit_from__c = 'Year(s)');
        Test.startTest();
        Boolean errorThrown = false;
        try{
            insert caseAnimal;
        }
        catch(Exception e){
            system.assert(e.getMessage().contains('Age cannot exceed Date of Birth'));
            errorThrown=true;
        }
        system.assertEquals(true,errorThrown);
        errorThrown = false;
        
        DispatchTriggerHandler.firstTimeTracker.clear();
        try{
            caseAnimal.ZTS_US_Age_unit_from__c = 'Month(s)';
            insert caseAnimal;
        }
        catch(Exception e){
            system.debug(e.getMessage());
            errorThrown=true;
        }
        system.assertEquals(false,errorThrown);
        Test.stopTest();

    }
    @isTest
    static void testAgeValidationCaseAnimalUpdate()
    {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        ZTS_US_Breed__c breed = [SELECT Id FROM ZTS_US_Breed__c WHERE ZTS_US_Species__c = 'Feline' LIMIT 1];
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Gato', ZTS_US_Breed__c=breed.Id,ZTS_US_Species__c='Feline',
                                                        ZTS_US_Date_of_Birth__c=date.today().addYears(-1));
        insert animal;
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = animal.Id);
        insert caseAnimal;                                                          
        Test.startTest();
        Boolean errorThrown = false;
        DispatchTriggerHandler.firstTimeTracker.clear();
        try{
            caseAnimal.ZTS_US_Age_from__c=2;
            caseAnimal.ZTS_US_Age_unit_from__c = 'Year(s)';
            update caseAnimal;
        }
        catch(Exception e){
            system.assert(e.getMessage().contains('Age cannot exceed Date of Birth'));
            errorThrown=true;
        }
        system.assertEquals(true,errorThrown);
        errorThrown = false;
        DispatchTriggerHandler.firstTimeTracker.clear();
        try{
            caseAnimal.ZTS_US_Age_from__c=2;
            caseAnimal.ZTS_US_Age_unit_from__c = 'Month(s)';
            update caseAnimal;
        }
        catch(Exception e){
            system.debug(e.getMessage());
            errorThrown=true;
        }
        system.assertEquals(false,errorThrown);
        Test.stopTest();

    }
    @isTest
    static void testAgeValidationCaseAnimalHumanUpdate()
    {
        Id humanRT = Schema.SObjectType.ZTS_US_Case_Animal__c.getRecordTypeInfosByDeveloperName().get('Human').getRecordTypeId();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        ZTS_US_Breed__c breed = [SELECT Id FROM ZTS_US_Breed__c WHERE ZTS_US_Species__c = 'Human' LIMIT 1];
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Guy', ZTS_US_Breed__c=breed.Id,ZTS_US_Species__c='Human',
                                                        ZTS_US_Date_of_Birth__c=date.today().addDays(-2));
        insert animal;
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = animal.Id,RecordTypeId=humanRT);
        insert caseAnimal;                                                          
        Test.startTest();
        Boolean errorThrown = false;
        DispatchTriggerHandler.firstTimeTracker.clear();
        try{
            caseAnimal.ZTS_US_Age_text__c=1;
            caseAnimal.Age_units__c = 'Month(s)';
            update caseAnimal;
        }
        catch(Exception e){
            system.assert(e.getMessage().contains('Age cannot exceed Date of Birth'));
            errorThrown=true;
        }
        system.assertEquals(true,errorThrown);
        errorThrown = false;
        DispatchTriggerHandler.firstTimeTracker.clear();
        try{
            caseAnimal.ZTS_US_Age_text__c=1;
            caseAnimal.Age_units__c = 'Day(s)';
            update caseAnimal;
        }
        catch(Exception e){
            system.debug(e.getMessage());
            errorThrown=true;
        }
        system.assertEquals(false,errorThrown);
        Test.stopTest();

    }
}