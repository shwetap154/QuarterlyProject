/**
* @description       : 
* @author            : Kalyan Nayak @ Zoetis Inc
* @group             : 
* @last modified on  : 02-16-2023
* @last modified by  : Kalyan Nayak @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   2-16-23    Kalyan Nayak @ Zoetis Inc     Added setupData, getCompetenceDetailsTest1 and getCompetenceDetailsTest2 method to get competency 
                                                 list records
**/
@isTest
private class getCompetenciesInvocableActionTest {

    //----------setupData start----------------
    @testSetup static void setupData() {
        //Competency model records

         //First Record
         List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
         Competency_Model__c objCompetencymodel = new Competency_Model__c();
         objCompetencymodel.Name = 'competencymodeltest';
         objCompetencymodel.Status__c='Active';
         competencyModelList.add(objCompetencymodel);

         insert competencyModelList;
        
        //Competency group records
        List<Competency_Group__c> competencyGroupList = new List<Competency_Group__c>();
        Competency_Group__c objCompetencyGroup = new Competency_Group__c();
        objCompetencyGroup.Market__c = 'Albania';
        objCompetencyGroup.Role__c = 'SAM';
        competencyGroupList.add(objCompetencyGroup);
        
        insert competencyGroupList;
        
        //Competency Group Assignment records
        List<Competency_Group_Assignment__c> comGroupAssignList = new List<Competency_Group_Assignment__c>();
        Competency_Group_Assignment__c objComGroupAssign = new Competency_Group_Assignment__c();
        objComGroupAssign.Competency_Group__c = competencyGroupList[0].Id;
        objComGroupAssign.Competency_Model__c = competencyModelList[0].id;
        comGroupAssignList.add(objComGroupAssign);
        
        insert comGroupAssignList;
        
        //Competency records
        //first record
        List<Competency__c> competencyList = new List<Competency__c>();
        Competency__c objCompetency = new Competency__c();
        objCompetency.Name = 'Competencytest1';
        objCompetency.Competency_Model__c = competencyModelList[0].id;
        objCompetency.Order__c = 1;
        objCompetency.Status__c='Active';
        competencyList.add(objCompetency);
       
        //Second Record
        Competency__c objCompetency1 = new Competency__c();
        objCompetency1.Name = 'Competencytest1';
        objCompetency1.Competency_Model__c = competencyModelList[0].id;
        objCompetency1.Order__c =1;
        objCompetency1.Status__c='Draft';
        competencyList.add(objCompetency1);
        
        //Third Record
        Competency__c objCompetency2 = new Competency__c();
        objCompetency2.Name = 'Competencytest1';
        objCompetency2.Competency_Model__c = competencyModelList[0].id;
        objCompetency2.Order__c =1;
        objCompetency2.Status__c='Inactive';
        competencyList.add(objCompetency2);
        
        insert competencyList;
        
        //Data Translation records
        List<Data_Translation__c> dataTranslationList = new List<Data_Translation__c>();
        Data_Translation__c objDataTranslation = new Data_Translation__c();
        objDataTranslation.Name__c = 'DataTranslationTest';
        objDataTranslation.Language__c = 'en_US';
        objDataTranslation.Competency__c = competencyList[0].Id;
        dataTranslationList.add(objDataTranslation);
        
        insert dataTranslationList;
        
        //Skill records
        //First Record
        List<Skill__c> skillList = new List<Skill__c>();
        Skill__c objSkill = new Skill__c();
        objSkill.Name__c = 'SkillTest';
        objSkill.Competency__c = competencyList[0].Id;
        objSkill.Learning_Description__c = 'Skill Learning Description';
        objSkill.Applying_Description__c = 'Skill Applying Description';
        objSkill.Mastery_Description__c = 'Skill Mastery Description';
        objSkill.Order__c = 1;
        objSkill.Status__c='Active';
        skillList.add(objSkill);
        
        
        //Second Record
        Skill__c objSkill1 = new Skill__c();
        objSkill1.Name__c = 'SkillTest';
        objSkill1.Competency__c = competencyList[0].Id;
        objSkill1.Learning_Description__c = 'Skill Learning Description';
        objSkill1.Applying_Description__c = 'Skill Applying Description';
        objSkill1.Mastery_Description__c = 'Skill Mastery Description';
        objSkill1.Order__c = 1;
        objSkill1.Status__c='Draft';
        skillList.add(objSkill1);
        
        //Third Record
        Skill__c objSkill2 = new Skill__c();
        objSkill2.Name__c = 'SkillTest';
        objSkill2.Competency__c = competencyList[0].Id;
        objSkill2.Learning_Description__c = 'Skill Learning Description';
        objSkill2.Applying_Description__c = 'Skill Applying Description';
        objSkill2.Mastery_Description__c = 'Skill Mastery Description';
        objSkill2.Order__c = 1;
        objSkill2.Status__c='Inactive';
        skillList.add(objSkill2);
        
        insert skillList;
        
        //Benchmark records
        List<Benchmark__c> benchmarkList = new List<Benchmark__c>();
        Benchmark__c objBenchmark = new Benchmark__c();
        objBenchmark.Market__c = 'Albania';
        objBenchmark.Role__c = 'SAM';
        benchmarkList.add(objBenchmark);
        
        insert benchmarkList;
    }
    //------------setupData End-------------------
    
    @isTest static void getCompetenceDetailsTest1(){
        
        List<Benchmark__c> lstBenchmark = new List<Benchmark__c>([SELECT id, Market__c, Role__c FROM Benchmark__c LIMIT 1]);        
        List<getCompetenciesInvocableAction.InputVariables> listInput = new List<getCompetenciesInvocableAction.InputVariables>();
        getCompetenciesInvocableAction.InputVariables objInput = new getCompetenciesInvocableAction.InputVariables();
        Test.startTest();
        
        lstBenchmark[0].Market__c = 'Albania';
        lstBenchmark[0].Role__c = 'SAM';
        objInput.BenchmarkList = lstBenchmark[0];
        listInput.add(objInput);
        List<getCompetenciesInvocableAction.ReturnVariables> competencyList = getCompetenciesInvocableAction.getCompetenceDetails(listInput);
        Test.stopTest();
        System.assertEquals(1, competencyList.size());
    }
    
    @isTest static void getCompetenceDetailsTest2(){
        
        List<Benchmark__c> lstBenchmark = new List<Benchmark__c>([SELECT id, Market__c, Role__c FROM Benchmark__c LIMIT 1]);        
        List<getCompetenciesInvocableAction.InputVariables> listInput = new List<getCompetenciesInvocableAction.InputVariables>();
        getCompetenciesInvocableAction.InputVariables objInput = new getCompetenciesInvocableAction.InputVariables();
        Test.startTest();
        objInput.BenchmarkList = Null;
        listInput.add(objInput);
        List<getCompetenciesInvocableAction.ReturnVariables> competencyList = getCompetenciesInvocableAction.getCompetenceDetails(listInput);
        Test.stopTest();
        System.assertEquals(null, competencyList);
    }
}