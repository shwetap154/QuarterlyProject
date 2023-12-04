/****************************************************************************************************************************************** 
 * Class Name   : CSE_AnimalTriggerHandlerTest
 * Description  : This trigger will handle all test coverage for  CSE_AnimalTriggerHandler
 * Created By   : Slalom Consulting/ Christian Kildal-Brandt
 * Created Date : September 20th 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer               				  Date                Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Christian Kildal-Brandt(Slalom)      09/20/2021              Created 
 * Venkat Joginapally					10/27/2021				Updated to Dispatch Trigger Framework
*****************************************************************************************************************************************/

@isTest
public with sharing class CSE_AnimalTriggerHandlerTest {
    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    static final String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId(); 

    @TestSetup
    static void makeData(){
        Case testCase = new Case(Subject = 'Test Case',
        Status = 'New',
        Origin = 'phone',
        Type = 'Animal Complaint',
        RecordTypeId = animalRecordtypeId,
        Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_SUCCESS);
        insert testCase;
        
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', ZTS_US_Species__c = 'Feline');
        insert Breed1;

        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Species__c='Feline', 
                                                            ZTS_US_Weight_units__c= 'Grams',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                            ZTS_US_Unknown__c = 1, ZTS_US_Under_Treatment__c = 1,
                                                            ZTS_US_Total__c = 5678937, ZTS_US_Sex__c = 'Male',
                                                            ZTS_US_Recovered__c = 1, ZTS_US_Reacted__c = 6, 
                                                            ZTS_US_Reproductive_Status__c = 'Neutered', ZTS_US_Exposed__c = 6,
                                                            ZTS_US_Euthanized__c = 1,ZTS_US_Died__c = 1,ZTS_US_Breed__c = Breed1.id,
                                                            ZTS_US_Age_unit_to__c ='Minutes',ZTS_US_Age_unit_from__c ='Minutes',
                                                            ZTS_US_Age_to__c = 6.1,ZTS_US_Age_from__c = 6.1,
                                                             ZTS_US_Animal_condition_prior_treatment__c = 'Good',
                                                            ZTS_US_Alive_with_Sequela__c = 1, ZTS_US_Weight__c = 9 );
        insert testUSAnimal;

        ZTS_US_Case_Animal__c testCaseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Animal__c = testUSAnimal.id, ZTS_US_Case__c = testCase.Id);
        insert testCaseAnimal;
    }

    @isTest
    private static void test_CSE_AnimalTriggerHandler_positive(){
        final String EXCEPTION_MESSAGE = 'cannot be set to null';
        ZTS_US_Animal__c testAnimal = [SELECT ID, ZTS_US_Species__c, ZTS_US_Sex__c FROM ZTS_US_Animal__c WHERE ZTS_US_Species__c = 'Feline' LIMIT 1];
        testAnimal.ZTS_US_Sex__c='Female';
        test.startTest();
        try{
            update testAnimal;
        }catch(Exception ex){
            System.Assert(false, 'the test should never throw an error');
        }
        ZTS_US_Animal__c newTestAnimal = [SELECT ID, ZTS_US_Species__c, ZTS_US_Sex__c FROM ZTS_US_Animal__c WHERE ZTS_US_Species__c = 'Feline' LIMIT 1];
        System.Assert(newTestAnimal.ZTS_US_Sex__c == 'Female', 'the field should have successfully been changed to Female');
        test.stopTest();
    }

    @isTest
    private static void test_CSE_AnimalTriggerHandler_negative(){
        final String EXCEPTION_MESSAGE = 'cannot be set to null';
        ZTS_US_Animal__c testAnimal = [SELECT ID, ZTS_US_Species__c, ZTS_US_Sex__c FROM ZTS_US_Animal__c WHERE ZTS_US_Species__c = 'Feline' LIMIT 1];
        testAnimal.ZTS_US_Sex__c=null;
        Boolean exceptionThrownMessage = false;
        test.startTest();
        try{
            update testAnimal;
        }catch(Exception ex){
            exceptionThrownMessage =  ex.getMessage().contains(EXCEPTION_MESSAGE) ? true : false;
            System.assertEquals(true, exceptionThrownMessage, 'We expect that there will be a validation error on the related Animal record due to one of its fields on its approval field set becoming a null value');
        }
        test.stopTest();
        System.assert(exceptionThrownMessage, 'The update should have thrown an error due to the required field being set to null');
    }  
    //test method to only acheive test coverage for unused trigger events beforedelete, afterdelete, afterundelete.
    @isTest
    private static void CSE_AnimalTriggerHandler_Delete(){      

        ZTS_US_Animal__c newTestAnimaltest = [SELECT ID, ZTS_US_Species__c, ZTS_US_Sex__c FROM ZTS_US_Animal__c WHERE ZTS_US_Species__c = 'Feline' LIMIT 1];
        delete newTestAnimaltest;
        undelete newTestAnimaltest;
    }
}