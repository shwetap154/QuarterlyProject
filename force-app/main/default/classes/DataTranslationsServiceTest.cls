/**
* @description       : 
* @author            : Suprabha Acharya @ Zoetis Inc
* @group             : 
* @last modified on  : 02-15-2023
* @last modified by  : Suprabha Acharya @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                            Modification
* 1.0   2-15-2023    Suprabha Acharya @ Zoetis Inc   Added setupData and DataTranslationsServiceTest
**/
@isTest 
public class DataTranslationsServiceTest {
    
    //----------setupData start----------------
    @testSetup static void setupData() {
        
        List<Competency_Model__c> competencyModels = TestDataFactory.createCompetencyModels(1);
        insert competencyModels;
        
        // Create competencies using the Test Data Factory method
        List<Competency__c> competencies = TestDataFactory.createCompetencies(1, competencyModels[0].Id);
        insert competencies;
        
        // Create skills using the Test Data Factory method
        List<Skill__c> skills = TestDataFactory.createSkills(1, competencies[0].Id);
        insert skills;
        
        Data_Translation__c dataTrans=TestDataFactory.createDataTranslation(competencies[0].Id, null, 'testDataTransCompetency', 'fr');
        insert dataTrans;
        Data_Translation__c dataTrans1=TestDataFactory.createDataTranslation(null,skills[0].Id ,'testDataTransSkill', 'fr');
        insert dataTrans1;
    }
    
    //------------setupData End-------------------    
    
    @isTest
    public static void  dataTransValidationsTest(){

        List<Competency__c> lstCompetencies = [SELECT Id FROM Competency__c LIMIT 1];
        Test.startTest();
        try{
            Data_Translation__c objDT = new Data_Translation__c();
            objDT.Competency__c = lstCompetencies[0].Id;
            objDT.Name__c = 'TestDTComp';
            objDT.Language__c = 'fr';
            insert objDT;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.DuplicateDataTransError) ? true : false;
            System.assertEquals(true,expectedExceptionThrown);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void  dataTransValidationsTest1(){

        List<Skill__c> lstSkills = [SELECT Id FROM Skill__c LIMIT 1];
        Test.startTest();
        try{
            Data_Translation__c objDT = new Data_Translation__c();
            objDT.Skill__c = lstSkills[0].Id;
            objDT.Name__c = 'TestDTSkill';
            objDT.Language__c = 'de';
            insert objDT;
            
            objDT.Language__c = 'fr';
            update objDT;

        }
        catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.DuplicateDataTransError) ? true : false;
           System.debug('Msg = '+e.getMessage());
            System.assertEquals(true,expectedExceptionThrown);
        }
        Test.stopTest();
    }
}