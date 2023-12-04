/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 02-10-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   2-13-2-23    Padma Nerella @ Zoetis Inc  Added selectCompetencySetwithLessonTemplateTest method to get competency 
list with lesson template records
* 2.0	02-13-2023	 Kalyan Nayak @ Zoetis Inc   Added setupData and selectByCompetencyModelTest methods to get Competecny
list
* 3.0	06-30-2023	 Pranav Raut @ Zoetis Inc    Added selectByCompetencyIdTest methods to get Competecny list
**/
@isTest
private class  CompetenciesSelectorTest {
    
    @isTest
    private static void selectCompetencySetwithLessonTemplateTest(){
        
        List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
        Competency_Model__c competencymodel = new Competency_Model__c();
        competencymodel.Name = 'competencymodeltest';
        competencyModelList.add(competencymodel);
        competencymodel.Status__c='Active';
        insert competencyModelList;
        
        List<Competency__c> competencyList = new List<Competency__c>();
        Competency__c competency = new Competency__c();
        competency.Name = 'Competencytest1';
        competency.Competency_Model__c = competencyModelList[0].id;
        competency.Order__c = 1;
        competency.Status__c='Active';
        competencyList.add(competency);
        insert competencyList;
        
        List<Lesson_Template__c> lessontemplateList = new List<Lesson_Template__c>();
        Lesson_Template__c lessontemplate = new Lesson_Template__c();
        lessontemplate.Name = 'lessontemplatetest1';
        lessontemplate.URL__c ='testUrl';
        lessontemplate.Language__c ='en_US';
        lessontemplate.Description__c ='testDescription';
        lessontemplate.Competency__c =competencyList[0].Id;
        lessontemplateList.add(lessontemplate);
        
        insert lessontemplateList;
        
        set<Id> CompetencyId = new Map<Id, Competency__c>( [Select Id from Competency__c]).keySet();
        
        Test.startTest();
        List<Competency__c> competencyListWithLessonTemplate = CompetenciesSelector.selectCompetencyListwithLessonTemplate(CompetencyId);
        Test.stopTest();
        System.assertEquals(1, competencyListWithLessonTemplate.size());
        
    }
    
    //----------setupData start----------------
    @testSetup static void setupData() {
        //Competency model records
        //First Record
         List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
         Competency_Model__c objCompetencymodel = new Competency_Model__c();
         objCompetencymodel.Name = 'competencymodeltest';
         objCompetencymodel.Status__c='Active';
         competencyModelList.add(objCompetencymodel);
         
         //Second Record
         Competency_Model__c objCompetencymodel2 = new Competency_Model__c();
         objCompetencymodel2.Name = 'competencymodeltest1';
         objCompetencymodel2.Status__c='Draft';
         competencyModelList.add(objCompetencymodel2);
        //Third Record
        Competency_Model__c objCompetencymodel3 = new Competency_Model__c();
        objCompetencymodel3.Name = 'competencymodeltest2';
        objCompetencymodel3.Status__c='Inactive';
        competencyModelList.add(objCompetencymodel3);

         insert competencyModelList;
        
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
    }
    //---------setupData End-------------------
    
    @isTest
    private static void selectByCompetencyTest(){
        List<Competency__c> listCompetency = new List<Competency__c>( [Select Id from Competency__c]);
        //List<id> comId = new List<Id>();
        //comId.add(CompetencyModelId[0].Id);
        Test.startTest();
        List<Competency__c> competencyList = CompetenciesSelector.selectByCompetencyList(listCompetency);
        Test.stopTest();
        System.assertEquals(3, competencyList.size());
        
    }
    
    @isTest
    private static void selectByCompetencyModelSetTest(){
        List<Competency_Model__c> CompetencyModelId = new List<Competency_Model__c>( [Select Id from Competency_Model__c]);
        Set<Id> setComModelId = new Set<Id>();
        setComModelId.add(CompetencyModelId[0].Id);        
        Test.startTest();
        List<Competency__c> competencyList = CompetenciesSelector.selectByCompetencyModelSet(setComModelId);
        Test.stopTest();
        System.assertEquals(1, competencyList.size());
        
    }
    
    @isTest
    private static void selectByCompetencyIdTest(){
        set<Id> setCompetencyId = new Map<Id, Competency__c>( [Select Id from Competency__c]).keySet();
        Test.startTest();
        List<Competency__c> competencyList = CompetenciesSelector.selectByCompetencyId(setCompetencyId);
        Test.stopTest();
        System.assertEquals(3, competencyList.size());       
    }
}