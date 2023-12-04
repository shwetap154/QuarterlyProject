/**
Class Name	    : IDevelop_select_Lessons_controllerTest
Description	    : Test Class created as part of TPDEV-64 for the IDevelop_select_Lessons_controller Class. 
Created By		: Sibin Kuriakose
Created Date	: 05-05-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				05-05-2023	 Created methods to Test Methods on IDevelop_select_Lessons_controller
*/
@isTest
public class IDevelop_select_Lessons_controllerTest {

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
                '3', observations[0].Id));
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

        List<Lesson_Template__c> lessonTemplates2 = new List<Lesson_Template__c>();
        for (Skill__c skill : skills) {
            lessonTemplates2.addAll(TestDataFactory.createLessonTemplates(1, null, skill.Id, 
                'en_US'));
        }
        insert lessonTemplates2;

        List<Lesson_Template__c> lessonTemplates3 = new List<Lesson_Template__c>();
        for (Competency__c competency : competencies) {
            lessonTemplates3.addAll(TestDataFactory.createLessonTemplates(1,competencies[1].Id, null, 
                'en_US'));
        }
        insert lessonTemplates3;

        List<Observed_Competency__c> observedCompetencies2 = new List<Observed_Competency__c>();
        observedCompetencies2.add(TestDataFactory.createObservedCompetency(competencies[1].Id, null,'3', observations[0].Id));

        insert observedCompetencies2;
    }

    /**     * @Description This method will test getRecommendedLessons method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 05-05-2023
    */
    @isTest
    private static void getRecommendedLessons_Test() {
        List<Observed_Competency__c> lstObscomprecords = [SELECT Id,Competency__c,Skill__c,Score__c FROM Observed_Competency__c];
        List<Benchmark__c> lstBenchmark = new List<Benchmark__c>();
        List<Benchmark__c> lstBenchmark2 = [SELECT Id FROM Benchmark__c];
        List<User> lstUser = [SELECT Id FROM User LIMIT 1];
        
        Test.startTest();
        List<IDevelop_select_Lessons_controller.WrapFnlCompLesson> wrapLessonList = IDevelop_select_Lessons_controller.getRecommendedLessons(lstObscomprecords,lstBenchmark,lstUser);
        List<IDevelop_select_Lessons_controller.WrapFnlCompLesson> wrapLessonList2 = IDevelop_select_Lessons_controller.getRecommendedLessons(lstObscomprecords,lstBenchmark2,lstUser);
        Test.stopTest();
        
        Assert.areEqual(3, wrapLessonList.size(), 'Expected Lessons retrieved');
        Assert.areEqual(2, wrapLessonList2.size(), 'Expected Lessons retrieved');        
    }

    
}