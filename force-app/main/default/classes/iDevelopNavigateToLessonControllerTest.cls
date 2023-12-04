@isTest
public class iDevelopNavigateToLessonControllerTest {
    
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
    public static void iDevelopNavigateToLessonTest(){        
        List<Lesson__c> lstLessons = [SELECT Id,Status__c,Lesson_Template__r.URL__c FROM Lesson__c LIMIT 1];
        Test.setCurrentPage(Page.iDevelopNavigateToLesson);
        ApexPages.currentPage().getParameters().put('lessonId', lstLessons[0].Id);
        Test.startTest();
        iDevelopNavigateToLessonController tempobj = new iDevelopNavigateToLessonController();
        tempobj.iDevelopNavigateToLesson();
        Test.stopTest();
        
        List<Lesson__c> lstUpdatedLessons = [SELECT Id,Status__c,Lesson_Template__r.URL__c FROM Lesson__c WHERE Id =: lstLessons[0].Id];
        System.assertEquals(System.Label.Reviewed, lstUpdatedLessons[0].Status__c);
        System.assertEquals('https://ww.zoetis.com', lstUpdatedLessons[0].Lesson_Template__r.URL__c);         
    }
    
    @isTest
    public static void iDevelopNavigateToLessonNegTest(){        
        List<Lesson__c> lstLessons = [SELECT Id,Status__c,Lesson_Template__c,Lesson_Template__r.URL__c FROM Lesson__c LIMIT 1];
        lstLessons[0].Lesson_Template__c = null;
        Update lstLessons;
        Test.setCurrentPage(Page.iDevelopNavigateToLesson);
        ApexPages.currentPage().getParameters().put('lessonId', lstLessons[0].Id);
        Test.startTest();
        iDevelopNavigateToLessonController tempobj = new iDevelopNavigateToLessonController();
        tempobj.iDevelopNavigateToLesson();
        Test.stopTest();
        
        List<Lesson__c> lstUpdatedLessons = [SELECT Id,Status__c,Lesson_Template__r.URL__c FROM Lesson__c WHERE Id =: lstLessons[0].Id];
        System.assertEquals('Assigned', lstUpdatedLessons[0].Status__c);
        System.assertEquals(null, lstUpdatedLessons[0].Lesson_Template__r.URL__c);                
    }
}