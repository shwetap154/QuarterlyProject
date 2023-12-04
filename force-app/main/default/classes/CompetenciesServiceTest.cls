/**
* @description       : 
* @author            : Kalyan Nayak @ Zoetis Inc
* @group             : 
* @last modified on  : 02-15-2023
* @last modified by  : Kalyan Nayak @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   2-15-23    Kalyan Nayak @ Zoetis Inc     Added setupData and getCompetenceListTest method to get competency 
                                                 list records
**/
@isTest
private class CompetenciesServiceTest {

    //----------setupData start----------------
    @testSetup static void setupData() {
        //Coach
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User coach = TestDataFactory.createUser(adminProfileId, false);
        insert coach;
        
        //Coachee
        User coachee = TestDataFactory.createUser(adminProfileId, false);
        coachee.ManagerId = coach.Id;
        coachee.ZTS_EU_Market__c = 'Albania';
        coachee.PIT_Coaching_Group__c = 'SAM';
        insert coachee;
        
        //Competency Model 
        List<Competency_Model__c> lstCompetencyModel = TestDataFactory.createCompetencyModels(1); 
        insert lstCompetencyModel;
        
        //Competency
        List<Competency__c> lstCompetencies = TestDataFactory.createCompetencies(2, lstCompetencyModel[0].Id);
        insert lstCompetencies;
        
        //Data Translation
        Data_Translation__c lstDataTranslation = TestDataFactory.createDataTranslation(lstCompetencies[0].Id,null,null,'Competency Name Translation','en_US');
        insert lstDataTranslation;
        
        //Skills
        List<Skill__c> lstSkill = TestDataFactory.createSkills(2, lstCompetencies[0].Id);
        insert lstSkill;
        
        //Skills
        List<Skill__c> lstSkill1 = TestDataFactory.createSkills(2, lstCompetencies[1].Id);
        insert lstSkill1;
        
        //Skill Data Translation
        Data_Translation__c lstSkillDataTranslation = TestDataFactory.createDataTranslation(null,lstSkill1[0].Id,null,'Skill Eng Data Translation','en_US'); 
        insert lstSkillDataTranslation;
        
        //Skill2 Data Translation
        Data_Translation__c lstSkillDataTranslation2 = TestDataFactory.createDataTranslation(null,lstSkill1[1].Id,null,'Skill2 Eng Data Translation','en_US'); 
        insert lstSkillDataTranslation2;
 
        //Competency Group
        List<Competency_Group__c> lstCompetencyGroup = TestDataFactory.createCompetencyGroups(1,'Albania','SAM');
        insert lstCompetencyGroup;
        
        //Competency Group Assignment 
        List<Competency_Group_Assignment__c> lstCompGrpAssignment = TestDataFactory.createCompetencyGrpAssignments(1,lstCompetencyModel,lstCompetencyGroup);
		insert lstCompGrpAssignment;
        
        //Benchmark
        List<Benchmark__c> lstBenchmarks = TestDataFactory.createBenchmarks(1,coach.Id,coachee.Id);
        insert lstBenchmarks;
    }
    //------------setupData End-------------------
    
    @isTest static void getCompetenceListTest(){
        
        List<Benchmark__c> lstBenchmark = new List<Benchmark__c>([SELECT id, Market__c, Role__c FROM Benchmark__c LIMIT 1]);
        lstBenchmark[0].Market__c = 'Albania';
        lstBenchmark[0].Role__c = 'SAM';
        System.debug('lstBenchmark::'+ lstBenchmark);
        Test.startTest();
           Map<Id,List<Competency__c>> competencyList = CompetenciesService.getCompetenceList(lstBenchmark);
        system.debug('competencyList::'+ competencyList);
        Test.stopTest();
        System.assertEquals(2, competencyList.values()[0].size());
    }
}