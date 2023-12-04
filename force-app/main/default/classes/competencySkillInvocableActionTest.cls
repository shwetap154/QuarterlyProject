/**
* Class Name	     : competencySkillInvocableActionTest
* @description       : Test Class for competencySkillInvocableAction.
* @author            : Pranav Raut @ Zoetis Inc
* @last modified on  : 06-30-2023
* @last modified by  : Pranav Raut @ Zoetis Inc

* Modification Log:
----------------------------------------------------------------------------
Ver  Developer		  Date		    Description
01   Pranav Raut	  06-30-2023	Added Setup data and getCompetenceSkillDetailsTest method to unit test of competencySkillInvocableAction class.
----------------------------------------------------------------------------
**/
@IsTest
public class competencySkillInvocableActionTest {    
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
        
        //Skills
        List<Skill__c> lstSkill = TestDataFactory.createSkills(2, lstCompetencies[0].Id);
        insert lstSkill;
        
        //Skills
        List<Skill__c> lstSkill1 = TestDataFactory.createSkills(2, lstCompetencies[1].Id);
        insert lstSkill1;
 
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
    //------------setupData End----------------
   
    @isTest static void getCompetenceSkillDetailsTest(){        
        List<Benchmark__c> lstBenchmark = new List<Benchmark__c>([SELECT id, Market__c, Role__c FROM Benchmark__c LIMIT 1]);        
        List<competencySkillInvocableAction.InputVariables> lstInput = new List<competencySkillInvocableAction.InputVariables>();
        competencySkillInvocableAction.InputVariables objInput = new competencySkillInvocableAction.InputVariables();
        Test.startTest();
                
        lstBenchmark[0].Market__c = 'Albania';
        lstBenchmark[0].Role__c = 'SAM';
        
        Observation__c objObs = new Observation__c();
        objObs.Benchmark__r = lstBenchmark[0];
        objObs.Benchmark__c = lstBenchmark[0].Id;  
        objObs.Type__c = 'Coach' ;
        Insert objObs;

        List<Competency__c> lstCompetency = [SELECT Id,Name,Competency_Model__c FROM Competency__c WHERE Name = 'Competency - 0' LIMIT 1 ];
        List<Skill__c> lstSkill = [SELECT Id,Competency__c FROM Skill__c WHERE Competency__c =: lstCompetency[0].Id];
        Observed_Competency__c objObsCom = new Observed_Competency__c();
        objObsCom.Observation__r = objObs;
        objObsCom.Competency__c = lstCompetency[0].Id;
        objObsCom.Skill__c = lstSkill[0].Id;
        objObsCom.Observation__c = objObsCom.Observation__r.Id;
        objObsCom.Score__c = '2';
        insert  objObsCom;
  
        objInput.BenchmarkList = lstBenchmark[0];
        lstInput.add(objInput);
        List<competencySkillInvocableAction.ReturnVariables> competencyList = competencySkillInvocableAction.getCompetenceSkillDetails(lstInput);
        Test.stopTest();

        //No of Uscored Competency
        System.assertEquals(1, competencyList.size()); 
        
        //Name of Uscored Competency 
        System.assertEquals('Competency - 1',competencyList[0].outputCollection[0].Name); 
    }
    
    @isTest static void getCompetenceSkillDetailsTest1(){ 
        List<Benchmark__c> lstBenchmark = new List<Benchmark__c>([SELECT id, Market__c, Role__c FROM Benchmark__c LIMIT 1]);        
        List<competencySkillInvocableAction.InputVariables> lstInput = new List<competencySkillInvocableAction.InputVariables>();
        competencySkillInvocableAction.InputVariables objInput = new competencySkillInvocableAction.InputVariables();
        Test.startTest();
        objInput.BenchmarkList = null;
        lstInput.add(objInput);
        List<competencySkillInvocableAction.ReturnVariables> competencyList = competencySkillInvocableAction.getCompetenceSkillDetails(lstInput);
        Test.stopTest();
        System.assertEquals(null, competencyList); 
    }

}