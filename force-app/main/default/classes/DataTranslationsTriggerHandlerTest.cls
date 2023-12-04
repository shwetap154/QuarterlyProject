/**
* @description       : 
* @author            : Suprabha Acharya @ Zoetis Inc
* @group             : 
* @last modified on  : 07-03-2023
* @last modified by  : Suprabha Acharya @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                            Modification
* 1.0   07-03-2023    Suprabha Acharya @ Zoetis Inc   Added DataTranslationsTriggerHandlerTest
**/
@isTest
public class DataTranslationsTriggerHandlerTest {
    @isTest
    private static void beforeInsert(){
List<Competency_Model__c> competencyModels = TestDataFactory.createCompetencyModels(1);
        insert competencyModels;
        // Create competencies using the Test Data Factory method
        List<Competency__c> competencies = TestDataFactory.createCompetencies(1, competencyModels[0].Id);
        insert competencies;
        // Create skills using the Test Data Factory method
        List<Skill__c> skills = TestDataFactory.createSkills(1, competencies[0].Id);
        insert skills;
        Data_Translation__c dataTrans=TestDataFactory.createDataTranslation(competencies[0].Id, null, 'testdata', 'fr');
        insert dataTrans;
        Data_Translation__c dataTrans1=TestDataFactory.createDataTranslation(null,skills[0].Id ,'testdata', 'fr');
        insert dataTrans1;
}
    @isTest
    public static void  beforeUpdate(){
        Test.startTest();
        List<Competency_Model__c> competencyModels = TestDataFactory.createCompetencyModels(1);
        insert competencyModels;
        // Create competencies using the Test Data Factory method
        List<Competency__c> competencies = TestDataFactory.createCompetencies(1, competencyModels[0].Id);
        insert competencies;
        // Create skills using the Test Data Factory method
        List<Skill__c> skills = TestDataFactory.createSkills(1, competencies[0].Id);
        insert skills;
        Data_Translation__c dataTrans=TestDataFactory.createDataTranslation(competencies[0].Id, null, 'testdata', 'fr');
        insert dataTrans;
        Data_Translation__c dataTrans1=TestDataFactory.createDataTranslation(null,skills[0].Id ,'testdata', 'fr');
        insert dataTrans1;

        dataTrans1.Language__c = 'en_US';
        update dataTrans1;
        Test.stopTest();
    }
 
}