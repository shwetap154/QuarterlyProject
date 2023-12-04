/**
* @description       : Skill Service test class
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 02-10-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   2-13-2023    Padma Nerella @ Zoetis Inc  Added competencyWithLessontemplateTest,competencyWithoutLessonTemplateTest and 
                                                 competencyBlukTest to test Block Addition of Skills to Competencies which already 
                                                 contain Lesson Templates
**/
@isTest
private class SkillsServiceTest {
    

    @isTest
    static void competencyWithLessonTemplateTest(){

        List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
        String errorMsg = System.Label.Cannot_Insert_Skill;
        Competency_Model__c competencymodel = new Competency_Model__c();
        competencymodel.Name = 'competencymodeltest';
        competencymodel.Status__c='Active';
        competencyModelList.add(competencymodel);

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
        
        Skill__c skill = new Skill__c ();
        skill.Competency__c =competencyList[0].Id;
        skill.Order__c = 1;
        skill.Status__c='Active';

        Test.startTest();
        Database.SaveResult result = Database.insert(skill, false);
        Test.stopTest();
        
        System.assert(result.isSuccess() == false, 'Skill record got inserted unexpectedly');
        System.assertEquals(1,result.getErrors().size(),'More or less errors then expected');
        System.assertEquals(errorMsg,result.getErrors()[0].getMessage());

    }
    
     @isTest
    static void competencyWithoutLessonTemplateTest(){
        String errorMsg = System.Label.Cannot_Insert_Skill;

        List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
        Competency_Model__c competencymodelSkill = new Competency_Model__c();
        competencymodelSkill.Name = 'competencymodeltest';
        competencymodelSkill.Status__c='Active';
        competencyModelList.add(competencymodelSkill);

        insert competencyModelList;

        List<Competency__c> competencySkillList = new List<Competency__c>();
        Competency__c competencySkill = new Competency__c();
        competencySkill.Name = 'Competencytest1';
        competencySkill.Competency_Model__c = competencyModelList[0].id;
        competencySkill.Order__c = 1;
        competencySkill.Status__c='Active';
        competencySkillList.add(competencySkill);
        insert competencySkillList;
        
        Skill__c skill = new Skill__c ();
        skill.Competency__c =competencySkillList[0].Id;
        skill.Name__c = 'TestSkill';
        skill.Status__c='Active';
        skill.Order__c = 1;

        Test.startTest();
        Database.SaveResult result = Database.insert(skill, true);
        Test.stopTest();

        System.assert(result.isSuccess() == true,'Skill Record inserted unsuccessfully unexpectedly.');
        System.assert(result.getErrors().size() == 0);

    }
    
     @isTest
    static void competencyWithLessonTemplateAndWithoutLessonTemplateBulkTest(){
        
        String errorMsg = System.Label.Cannot_Insert_Skill;
        List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
        Competency_Model__c competencymodel = new Competency_Model__c();
        competencymodel.Name = 'competencymodeltest';
        competencymodel.Status__c='Active';
        competencyModelList.add(competencymodel);

        insert competencyModelList;

        List<Competency__c> competencyList = new List<Competency__c>();
        Competency__c competency1 = new Competency__c();
        competency1.Name = 'Competencytest1';
        competency1.Competency_Model__c = competencyModelList[0].id;
        competency1.Order__c = 1;
        competency1.Status__c='Active';
        competencyList.add(competency1);
        
        Competency__c competency2 = new Competency__c();
        competency2.Name = 'Competencytest1';
        competency2.Competency_Model__c = competencyModelList[0].id;
        competency2.Order__c = 2;
        competency2.Status__c='Active';
        competencyList.add(competency2);
        insert competencyList;
        
        List<Lesson_Template__c> lessontemplateList = new List<Lesson_Template__c>();
        Lesson_Template__c lessontemplate = new Lesson_Template__c();
        lessontemplate.Name = 'lessontemplatetest1';
        lessontemplate.URL__c ='testUrl';
        lessontemplate.Language__c ='en_US';
        lessontemplate.Description__c ='testDescription';
        lessontemplate.Competency__c =competencyList[1].Id;
        lessontemplateList.add(lessontemplate);

        insert lessontemplateList;
        
        List<Skill__c> skillList = new List<Skill__c>();
        Skill__c skill = new Skill__c ();
        skill.Competency__c =competencyList[0].Id;
        skill.Name__c = 'TestSkill1';
        skill.Order__c = 1;
        skill.Status__c='Active';
        skillList.add(skill);
        
        Skill__c skill2 = new Skill__c ();
        skill2.Competency__c =competencyList[1].Id;
        skill2.Name__c = 'TestSkill2';
        skill2.Order__c = 2;
        skill2.Status__c='Active';
        skillList.add(skill2);
        
        Test.startTest();
        Database.SaveResult[] result = Database.insert(skillList, false);
        Test.stopTest();
        
        Integer totalSuccess =0;
        Integer totalErrors =0;
        for (Database.SaveResult sr : result) {
            if (sr.isSuccess()) {
                System.assert(sr.isSuccess(), 'Skill record inserted sucessfully.');
                System.assert(sr.isSuccess(),sr.Id);
                totalSuccess++;
            }
            else {
                    System.assert(!sr.isSuccess());
                    System.assert(sr.getErrors().size() > 0);
                    System.assertEquals(errorMsg,
                                        sr.getErrors()[0].getMessage());
                    totalErrors++;
                
            }
        }
        
        System.assertEquals(1, totalSuccess,'Only one Skill record should have gotten inserted succesfully');
        System.assertEquals(1, totalErrors,'Only 1 Skill record should have errored');
    }
 
}