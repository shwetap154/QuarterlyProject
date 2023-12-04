/**
* @description       : Selector class for Competency
* @author            : Sibin KUriaksoe @ Zoetis Inc
* @group             : 
* @last modified on  : 03-14-2023
* @last modified by  : 
* Modifications Log
* Ver   Date         Author                        Modification
* 1.0   03-14-2023   Sibin KUriaksoe @ Zoetis Inc  TPdev-164 Block Addition of Skills to Competencies which already contain Lesson Templates
**/
@isTest
public inherited sharing class SkillsSelectorTest {
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
        
        //Competency records
        //First Record
        List<Competency__c> competencyList = new List<Competency__c>();
        Competency__c objCompetency = new Competency__c();
        objCompetency.Name = 'Competencytest1';
        objCompetency.Competency_Model__c = competencyModelList[0].id;
        objCompetency.Order__c =1;
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
    private static void selectBySkillListTest(){
        
        List<Competency__c> lstCompetencyId = new List<Competency__c>( [Select Id from Competency__c]);
        Test.startTest();
        List<Skill__c> lstSkills = SkillsSelector.selectBySkillList(lstCompetencyId);
        Test.stopTest();
        System.assertEquals(1, lstSkills.size());
        
    }
    
    @isTest
    private static void selectSkillsByCompetencyTest(){
        String UserLanguage = UserInfo.getLanguage();
        Set<Id> setCompetencyId = new Map<Id, Competency__c>([select Id FROM Competency__c]).keySet();
        Test.startTest();
        List<Skill__c> lstSkills = SkillsSelector.selectSkillsByCompetencyWithCurrentUserTranslations(setCompetencyId,UserLanguage);
        Test.stopTest();
        System.assertEquals(1, lstSkills.size());
        
    }
    
}