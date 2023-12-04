/**
Class Name	    : lessonsServiceTest
Description	    : Test Class created as part of TPDEV-95 for lessonsService Class. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 04-26-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver   Developer					     Date		  Description
-------------------------------------------------------------------------------------------------------------------------
01    Raut, Pranav Krushnarao      	 04-26-2023   Added Test Methods for Testing lessonsService class,
*/
@isTest
public class lessonsServiceTest {
    
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
        
        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coach.Id)[0];
        insert benchmark;
        
        List<Observation__c> observations = TestDataFactory.createObservations(1, benchmark.Id, 'Coach');
        insert observations;
        
        List<Observed_Competency__c> observedCompetencies = new List<Observed_Competency__c>();
        for (Competency__c competency : competencies) {
            observedCompetencies.add(TestDataFactory.createObservedCompetency(competency.Id, null,
                                                                              '5', observations[0].Id));
        }        
        insert observedCompetencies;
        
        List<Lesson_Template__c> lessonTemplates = new List<Lesson_Template__c>();
        for (Competency__c competency : competencies) {
            lessonTemplates.addAll(TestDataFactory.createLessonTemplates(1, competency.Id, null,
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
    
    //Postive Scenarios 
    @isTest
    private static void updateLessonStatusToReviewedTest() {
        List<Lesson__c> lstLessons = [SELECT Id,Status__c,Lesson_Template__r.URL__c FROM Lesson__c LIMIT 1];
        Test.startTest();
        String lessonTemplateURL = lessonsService.updateLessonStatusToReviewed(lstLessons[0].Id);
        Test.stopTest();
        
        List<Lesson__c> lstUpdatedLessons = [SELECT Id,Status__c,Lesson_Template__r.URL__c FROM Lesson__c WHERE Id =: lstLessons[0].Id];
        System.assertEquals(System.Label.Reviewed, lstUpdatedLessons[0].Status__c);
        System.assertEquals(lessonTemplateURL, lstUpdatedLessons[0].Lesson_Template__r.URL__c);        
    }
    
    //Negetive Scenarios 
    @isTest
    private static void updateLessonStatusToReviewedNegTest() {
        
        List<Lesson__c> lstLessons = [SELECT Id,Status__c,Lesson_Template__c,Lesson_Template__r.URL__c FROM Lesson__c LIMIT 1];
        lstLessons[0].Lesson_Template__c = null;
        update lstLessons;
        Test.startTest();
        String lessonTemplateURL = lessonsService.updateLessonStatusToReviewed(lstLessons[0].Id);
        Test.stopTest();
        
        List<Lesson__c> lstUpdatedLessons = [SELECT Id,Status__c,Lesson_Template__r.URL__c FROM Lesson__c WHERE Id =: lstLessons[0].Id];
        System.assertEquals('Assigned', lstUpdatedLessons[0].Status__c);
        System.assertEquals(null, lstUpdatedLessons[0].Lesson_Template__r.URL__c);        
    }    
}