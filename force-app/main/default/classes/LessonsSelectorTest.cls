/**
 * Test class for LessonsSelector
 * @author Ethan Hirsch @ Zoetis Inc
 * @since 03-03-2023
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-03-2023   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for selectByObservedCompetencyCompetency
 * 2.0   05-05-2023   Sibin Kuriakose              Added Test Method to cover selectByListObservedCompetency, selectByLessonTemplate & selectByListLessonId
 * 3.0   05-30-2023   Padma Nerella @ Zoetis Inc  Modified selectByObservedCompetencyCompetencyAndBenchmark method by adding Set of BenchmarkId as a parameter
 */
@isTest
private class LessonsSelectorTest {
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

    @isTest
    private static void selectByObservedCompetencyCompetencyAndBenchmark_Test() {
        Set<Id> competencyIds = new Map<Id, Competency__c>([SELECT Id FROM Competency__c]).keySet();
        Set<Id> benchmarkIdSet = new Map<Id, Benchmark__c>([Select Id From Benchmark__c]).KeySet();
        Test.startTest();
            List<Lesson__c> lessons = LessonsSelector.selectByObservedCompetencyCompetencyAndBenchmark(competencyIds,benchmarkIdSet);
        Test.stopTest();

        Assert.areEqual(2, lessons.size(), 'More/Less Lessons retrieved than expected');
    }
    
    @isTest
    private static void selectByLessonId_Test() {
        Id lessonId = [SELECT Id FROM Lesson__c LIMIT 1].Id;
        Test.startTest();
        List<Lesson__c> lstLessons = LessonsSelector.selectByLessonId(lessonId);
        Test.stopTest();
        
        Assert.areEqual(1, lstLessons.size(), 'Expected Lessons retrieved');
        
    }

    @isTest
    private static void selectByListObservedCompetency_Test() {
        List<Observed_Competency__c> lstobscomp = [SELECT Id FROM Observed_Competency__c];

        Test.startTest();
            List<Lesson__c> lessons = LessonsSelector.selectByListObservedCompetency(lstobscomp);
        Test.stopTest();

        Assert.areEqual(2, lessons.size(), 'More/Less Lessons retrieved than expected');
    }

    @isTest
    private static void selectByLessonTemplate_Test() {
        List<Lesson_Template__c> lsttemplessonLang = [SELECT Id FROM Lesson_Template__c];
		Id benchId = [SELECT Id FROM Benchmark__c].Id;
        List<Id> lstbenchId = new List<Id>();
        lstbenchId.add(benchId);

        Test.startTest();
            List<Lesson__c> lessons = LessonsSelector.selectByLessonTemplateBench(lsttemplessonLang,lstbenchId);
        Test.stopTest();

        Assert.areEqual(2, lessons.size(), 'More/Less Lessons retrieved than expected');
    }

    @isTest
    private static void selectByListLessonId_Test() {
        List<Lesson__c> lessonId = [SELECT Id FROM Lesson__c LIMIT 2];
        List<Id> recId = new List<id>();
        for(Lesson__c temp : lessonId){
            recId.add(temp.Id);
        }
        Test.startTest();
        List<Lesson__c> lstLessons = LessonsSelector.selectByListLessonId(recId);
        Test.stopTest();
        
        Assert.areEqual(2, lstLessons.size(), 'Expected Lessons retrieved');
        
    }
}