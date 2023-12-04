/**
Class Name	    : KnowledgeSelectorTest
Description	    : Test Class created as part of TPDEV-431 for the LessonTemplateSelector Class. 
Created By		: Sibin Kuriakose
Created Date	: 05-05-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				05-05-2023	 Created methods to Test Methods on LessonTemplateSelector
*/
@isTest
public class LessonTemplateSelectorTest {
    /**     * @Description This method will setup the Test data      
                * @Author      Sibin Kuriakose @ Zoetis Inc | 05-05-2023 
    */
    @TestSetup
    private static void setup(){
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User coach = TestDataFactory.createUser(adminProfileId, false);
        insert coach;

        User coachee = TestDataFactory.createUser(adminProfileId, false);
        coachee.ManagerId = coach.Id;
        insert coachee;
        
        List<Competency_Model__c> competencyModels = TestDataFactory.createCompetencyModels(1);
        insert competencyModels;

        List<Competency__c> competencies = TestDataFactory.createCompetencies(2, competencyModels[0].Id);
        insert competencies;

        List<Skill__c> skills = TestDataFactory.createSkills(2, competencies[0].Id);
        insert skills;

        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coach.Id)[0];
        insert benchmark;

        List<Observation__c> observations = TestDataFactory.createObservations(1, benchmark.Id, 'Coach');
        insert observations;

        List<Observed_Competency__c> observedCompetencies = new List<Observed_Competency__c>();
        for (Skill__c skill : skills) {
            observedCompetencies.add(TestDataFactory.createObservedCompetency(competencies[0].Id, skill.Id,
                '5', observations[0].Id));
        }

        insert observedCompetencies;

        List<Lesson_Template__c> lessonTemplates = new List<Lesson_Template__c>();
        for (Skill__c skill : skills) {
            lessonTemplates.addAll(TestDataFactory.createLessonTemplates(1, null, skill.Id, 
                'en_US'));
        }

        insert lessonTemplates;

        List<Lesson__c> lessons = new List<Lesson__c>();
        for (integer i = 0; i < lessonTemplates.size(); i++) {
            Lesson__c lesson = TestDataFactory.createLesson(lessonTemplates[i].Name, lessonTemplates[i].Id,
                observedCompetencies[i].Id);

            lessons.add(lesson);
        }

        insert lessons;
    }


    /**     * @Description This method will test selectByCompSkillIdLang method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 05-05-2023 
    */
    @isTest
    private static void selectByCompSkillIdLang_Test() {
        List<Observed_Competency__c> lstObscomprecords = [SELECT Id,Competency__c,Skill__c FROM Observed_Competency__c LIMIT 2];
        List<Id> lstcomps = new List<Id>();
        List<Id> lstskill = new List<Id>();
        for(Observed_Competency__c temp : lstObscomprecords){
            lstcomps.add(temp.Competency__c);
            lstskill.add(temp.Skill__c);
        }
        String lang = 'en_US';
        Test.startTest();
        List<Lesson_Template__c> lstavailLessonEng = LessonTemplateSelector.selectByCompSkillIdLang(lstcomps,lstskill,lang);
        Test.stopTest();
        
        Assert.areEqual(2, lstavailLessonEng.size(), 'Expected Lessons retrieved');
        
    }

    /**     * @Description This method will test selectById method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 05-05-2023 
    */
    @isTest
    private static void selectById_Test() {
        List<Lesson_Template__c> lstObscomprecords = [SELECT Id FROM Lesson_Template__c LIMIT 2];
        List<Id> recId = new List<Id>();
        for(Lesson_Template__c temp : lstObscomprecords){
            recId.add(temp.Id);
        }
        String lang = 'en_US';
        Test.startTest();
        List<Lesson_Template__c> lstlesstemplate = LessonTemplateSelector.selectById(recId);
        Test.stopTest();
        
        Assert.areEqual(2, lstlesstemplate.size(), 'Expected Lessons retrieved');
        
    }
}