/**
 * Test class for iDevelopBenchmarkReportController
 * @author Ethan Hirsch @ Zoetis Inc
 * @since 03-02-2023 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-02-2023   Ethan Hirsch @ Zoetis Inc   Add Tests for Page constructors without Self-Observation,
 *                                                constructor for CompetencySkillAverageScore, and compareTo on
 *                                                HighestLowestScore
 * 1.1   04-03-2023   Ethan Hirsch @ Zoetis Inc   Add Tests for Page constructors with Self-Observations including
 *                                                various testings of gap calculations
 * 1.2   04-10-2023   Ethan Hirsch @ Zoetis Inc   Update constructor_BenchmarkWithTranslations_Test to test
 *                                                Competency Model translations
 */
@isTest
private class iDevelopBenchmarkReportControllerTest {
    private static final String noSkillsModelName = 'No Skills Model';
    private static final String skillsModelName = 'Skills Model';
    private static final String coachUserName = 'testcoach@zoetis.com.test';
    private static final String coacheeUserName = 'testcoachee@zoetis.com.test';

    @TestSetup
    private static void setup(){
        List<Competency_Model__c> competencyModels = TestDataFactory.createCompetencyModels(2);
        competencyModels[0].Name = noSkillsModelName;
        competencyModels[1].Name = skillsModelName;
        insert competencyModels;

        List<Competency__c> competenciesWithSkills = new List<Competency__c>();

        List<Competency__c> competencies = new List<Competency__c>();
        for (Competency_Model__c model : competencyModels) {
            List<Competency__c> newCompetencies = TestDataFactory.createCompetencies(3, model.Id);
            competencies.addAll(newCompetencies);

            if (model.Name == skillsModelName) {
                competenciesWithSkills.addAll(newCompetencies);
            }
        }

        insert competencies;

        List<Skill__c> skills = new List<Skill__c>();
        for (Competency__c competency : competenciesWithSkills) {
            skills.addAll(TestDataFactory.createSkills(2, competency.Id));
        }

        insert skills;

        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User coach = TestDataFactory.createUser(adminProfileId, false);
        coach.Username = coachUserName;
        insert coach;

        User coachee = TestDataFactory.createUser(adminProfileId, false);
        coachee.ManagerId = coach.Id;
        coachee.Username = coacheeUserName;
        insert coachee;
    }
   
    @isTest
    private static void constructor_NoBenchmark_Test() {
        Test.setCurrentPage(Page.iDevelopBenchmarkReport);

        Test.startTest();
            iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
                new ApexPages.StandardController(new Benchmark__c()));
        Test.stopTest();

        Assert.isTrue(controller.BenchmarkScores.isEmpty(), 'No Benchmark Scores should be created');
        Assert.isNull(controller.CoacheeName, 'Coachee Name should be blank');
        Assert.isNull(controller.RaterName, 'Rater Name should be blank');
        Assert.isNull(controller.Title, 'Title should be blank');

        Assert.areEqual(System.now().format('dd/MM/yyyy'), controller.CurrentDate,
            'Current Date was not set as expected.');

        Assert.isNull(controller.BenchmarkId, 'Benchmark Id should not be set');
        Assert.isTrue(controller.HighestScores.isEmpty(), 'No Highest Scores should be created');
        Assert.isTrue(controller.LowestScores.isEmpty(), 'No Lowest Scores should be created');
        Assert.isTrue(controller.LowestScoringCompetencies.isEmpty(), 'LowestScoringCompetencies should be empty');
        Assert.areEqual(Url.getSalesforceBaseUrl().toExternalForm(), controller.SalesforceBaseUrl,
            'Base URL is not set as expected.');

        assertSelfObservationNotSet(controller);
    }

    @isTest
    private static void constructor_BenchmarkNoObservedCompetencies_Test() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];

        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        insert benchmark;

        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);

        Test.startTest();
            iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
                new ApexPages.StandardController(benchmark));
        Test.stopTest();

        Assert.isTrue(controller.BenchmarkScores.isEmpty(), 'No Benchmark Scores should be created');
        Assert.areEqual(coachee.Name, controller.CoacheeName, 'Coachee Name should be set');
        Assert.areEqual(coachee.Manager.Name, controller.RaterName, 'Rater/Manager Name should be set');
        Assert.areEqual(String.format('{0}{1}',
            new List<String>{coachee.Name, System.Label.iDevelop_Benchmark_Report_File_Name_Suffix}),
            controller.Title, 'Title not set as expected');

        Assert.areEqual(System.now().format('dd/MM/yyyy'), controller.CurrentDate,
            'Current Date was not set as expected.');

        Assert.areEqual(benchmark.Id, controller.BenchmarkId, 'Benchmark Id should be set');
        Assert.isTrue(controller.HighestScores.isEmpty(), 'No Highest Scores should be created');
        Assert.isTrue(controller.LowestScores.isEmpty(), 'No Lowest Scores should be created');
        Assert.isTrue(controller.LowestScoringCompetencies.isEmpty(), 'LowestScoringCompetencies should be empty');
        assertSelfObservationNotSet(controller);
    }
//Test method added for Previous Benchmark    
     @isTest
    private static void constructor_PreviousBenchmarkNoObservedCompetencies_Test() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];
        
        Benchmark__c previousBenchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        previousBenchmark.Type__c = 'Coach'; 
        previousBenchmark.Status__c = 'Completed';
        insert previousBenchmark;
        
        List<Observation__c> previousObservations = TestDataFactory.createObservations(3, previousBenchmark.Id, 'Coach');
        String expectedComment = 'Test Comments';
        previousObservations[0].Comments__c = expectedComment;
        insert previousObservations;
        
        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        benchmark.Type__c = 'Coach';
        insert benchmark;
        
        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);
        
        Test.startTest();
        iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
            new ApexPages.StandardController(benchmark));
        Test.stopTest();

        Assert.areEqual(controller.PreviousObservationPresent , true, 'Previous Benchmark should be available.');
    }
    
    @isTest
    private static void constructor_PreviousBenchmarkNoObservedCompetenciesOther_Test() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];
        
        Benchmark__c previousBenchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        previousBenchmark.Type__c = 'Other'; 
        previousBenchmark.Status__c = 'Completed';
        insert previousBenchmark;
        
        List<Observation__c> previousObservations = TestDataFactory.createObservations(3, previousBenchmark.Id, 'Coach');
        String expectedComment = 'Test Comments';
        previousObservations[0].Comments__c = expectedComment;
        insert previousObservations;
        
        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        benchmark.Type__c = 'Coach';
        insert benchmark;
        
        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);
        
        Test.startTest();
        iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
            new ApexPages.StandardController(benchmark));
        Test.stopTest();

        Assert.areEqual(controller.PreviousObservationPresent , false, 'Previous Benchmark should be available.');
    }
    
    @isTest
    private static void constructor_PreviousBenchmarkNoObservedCompetenciesCoach_Test() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];
        
        Benchmark__c previousBenchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        previousBenchmark.Type__c = 'Coach'; 
        previousBenchmark.Status__c = 'Completed';
        insert previousBenchmark;
        
        List<Observation__c> previousObservations = TestDataFactory.createObservations(3, previousBenchmark.Id, 'Coach');
        String expectedComment = 'Test Comments';
        previousObservations[0].Comments__c = expectedComment;
        insert previousObservations;
        
        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        benchmark.Type__c = 'Other';
        insert benchmark;
        
        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);
        
        Test.startTest();
        iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
            new ApexPages.StandardController(benchmark));
        Test.stopTest();

        Assert.areEqual(controller.PreviousObservationPresent , false, 'Previous Benchmark should be available.');
    }
  
    @isTest
    private static void constructor_BenchmarkCompetenciesOnly_Test() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];

        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        insert benchmark;

        List<Observation__c> observations = TestDataFactory.createObservations(3, benchmark.Id, 'Coach');
        String expectedComment = 'Test Comments';
        observations[0].Comments__c = expectedComment;
        insert observations;

        Map<Id, Competency__c> competencyMap = new Map<Id, Competency__c>();
        Map<Id, Decimal> averageScoreByCompetencyId = new Map<Id, Decimal>();
        Map<Decimal, Id> competencyIdByAverageScore = new Map<Decimal, Id>(); 
        List<Observed_Competency__c> observedCompetencies = new List<Observed_Competency__c>();
        Integer score = 1;
        Decimal overallScore = 0;
        for (Competency__c competency : [
            SELECT Id, Name
            FROM Competency__c
            WHERE Competency_Model__r.Name =: noSkillsModelName
        ]) {
            competencyMap.put(competency.Id, competency);

            for (Observation__c observation : observations) {                
                observedCompetencies.add(TestDataFactory.createObservedCompetency(competency.Id, null,
                    String.valueOf(score), observation.Id));
            }
            
            Decimal averageScore = score++;
            averageScoreByCompetencyId.put(competency.Id, averageScore);
            competencyIdByAverageScore.put(averageScore, competency.Id);

            overallScore += averageScore;
        }

        Integer totalCompetencies = competencyMap.size();

        insert observedCompetencies;

        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);
        
        Test.startTest();
            iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
                new ApexPages.StandardController(benchmark));
        Test.stopTest();

        Assert.areEqual(1, controller.BenchmarkScores.size(), 'There should be one Benchmark Score');
        System.assertEquals(1, controller.CoachObservations.size(), 'There should be one comment');

        for (iDevelopBenchmarkReportController.CompetencyModelScore modelScore : controller.BenchmarkScores) {
            Assert.areEqual(noSkillsModelName, modelScore.Name, 'Model Name as not set as expected');

            
            Assert.areEqual(totalCompetencies, modelScore.CompetencySkillAverageScores.size(),
                'More/Less Competency Scores were created than expected.');

            Assert.areEqual(overallScore / totalCompetencies, modelScore.ManagerOverallScore, 'Overall Score was not set as expected');

            for (iDevelopBenchmarkReportController.CompetencySkillAverageScore competencyScore : modelScore.CompetencySkillAverageScores) {
                Assert.isTrue(competencyMap.containsKey(competencyScore.RecordId), String.format(
                    'Competency {0} was returned unexpectedly', new List<Object>{competencyScore.Name}));

                Competency__c competency = competencyMap.get(competencyScore.RecordId);
                Assert.areEqual(competency.Name, competencyScore.Name, 'Name was not set as expected.');
                Assert.areEqual(observations.size(), competencyScore.ManagerDirectScores.size(),
                    'Scores should match the total number of Observations');
                
                Assert.isTrue(competencyScore.SkillScoresMap.isEmpty(), 'There should be no Manager Skill Scores');

                Assert.areEqual(averageScoreByCompetencyId.get(competencyScore.RecordId),
                    competencyScore.ManagerAverageScore, 'Manager Average Score was not set as expected');
            }
        }

        Assert.areEqual(coachee.Name, controller.CoacheeName, 'Coachee Name should be set');
        Assert.areEqual(coachee.Manager.Name, controller.RaterName, 'Coachee Name should be set');
        Assert.areEqual(String.format('{0}{1}',
            new List<String>{coachee.Name, System.Label.iDevelop_Benchmark_Report_File_Name_Suffix}),
            controller.Title, 'Title not set as expected');

        Assert.areEqual(System.now().format('dd/MM/yyyy'), controller.CurrentDate,
            'Current Date was not set as expected.');

        Assert.areEqual(benchmark.Id, controller.BenchmarkId, 'Benchmark Id should be set');

        List<Decimal> allScores = new List<Decimal>(competencyIdByAverageScore.keySet());
        allScores.sort();

        for (integer i = 0; i < controller.HighestScores.size(); i++) {
            iDevelopBenchmarkReportController.HighestLowestScore highScore = controller.HighestScores[i];
            Decimal expectedScore = allScores[allScores.size() - i - 1];

            Assert.areEqual(i + 1, highScore.Rank, 'Rank not set as expected.');
            Assert.areEqual(expectedScore, highScore.Score,
                'The highest score was not set as expected');

            Competency__c competency = competencyMap.get(competencyIdByAverageScore.get(expectedScore));

            Assert.areEqual(competency.Name, highScore.Competency, 'High Score not set to the expected Competency');
            Assert.areEqual(competency.Name, highScore.Skill, 'High Score not set to the expected Skill');
        }

        for (integer i = 0; i < controller.LowestScores.size(); i++) {
            iDevelopBenchmarkReportController.HighestLowestScore lowScore = controller.LowestScores[i];
            Decimal expectedScore = allScores[i];

            Assert.areEqual(i + 1, lowScore.Rank, 'Rank not set as expected.');
            Assert.areEqual(expectedScore, lowScore.Score,
                'The lowest score was not set as expected');

            Competency__c competency = competencyMap.get(competencyIdByAverageScore.get(expectedScore));

            Assert.areEqual(competency.Name, lowScore.Competency, 'Low Score not set to the expected Competency');
            Assert.areEqual(competency.Name, lowScore.Skill, 'Low Score not set to the expected Skill');
        }
        
        for (integer i = 0; i < controller.LowestScoringCompetencies.size(); i++) {
            iDevelopBenchmarkReportController.CompetencyRecommendedELearnings lowScore = controller.LowestScoringCompetencies[i];
            Decimal expectedScore = allScores[i];

            Assert.isNull(lowScore.Rank, 'Rank should not be set.');

            Competency__c competency = competencyMap.get(competencyIdByAverageScore.get(expectedScore));

            Assert.areEqual(competency.Id, lowScore.RecordId, 'Low Score not set to the expected Record');
            Assert.areEqual(competency.Name, lowScore.Name, 'Name was not set as expected');
            Assert.isTrue(lowScore.RecommendedELearnings.isEmpty(), 'No eLearnings should have been added');
            Assert.isTrue(!lowScore.HasELearnings, 'No eLearnings should have been added');
        }

        assertSelfObservationNotSet(controller);
    }

    @isTest
    private static void constructor_BenchmarkCompetenciesAndSkillsAndLearning_Test() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];

        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        insert benchmark;

        List<Observation__c> observations = TestDataFactory.createObservations(3, benchmark.Id, 'Coach');
        insert observations;

        Map<Id, Competency__c> competencyMap = new Map<Id, Competency__c>();
        Map<Id, Skill__c> skillMap = new Map<Id, SKill__c>();
        Map<Id, List<Competency__c>> competenciesByModelId = new Map<Id, List<Competency__c>>();
        Map<String, Id> competencyModelIdByName = new Map<String, Id>();
        Map<Id, Decimal> averageScoreByCompetencyId = new Map<Id, Decimal>();
        Map<Decimal, List<Id>> recordIdsByAverageScore = new Map<Decimal, List<Id>>(); 
        Map<Id, Decimal> averageScoreBySkillId = new Map<Id, Decimal>();
        Map<Id, Decimal> overallScoreByCompetencyModelId = new Map<Id, Decimal>();
        List<Observed_Competency__c> lowScoringObservedCompetencies = new List<Observed_Competency__c>();
        Integer score = 1;

        // Setup 1 Observed Competency per Competency or Competency's Skill
        // Score is incremented for each Competency or Skill
        List<Observed_Competency__c> observedCompetencies = new List<Observed_Competency__c>();
        for (Competency__c competency : [
            SELECT Id, Name, Competency_Model__c, Competency_Model__r.Name,
                (SELECT Id, Name, Competency__c FROM Skills__r)
            FROM Competency__c
            WHERE Competency_Model__r.Name in: new List<String> {noSkillsModelName, SkillsModelName}
        ]) {
            competencyMap.put(competency.Id, competency);

            if (!competenciesByModelId.containsKey(competency.Competency_Model__c)) {
                competenciesByModelId.put(competency.Competency_Model__c, new List<Competency__c>());
            }
            competenciesByModelId.get(competency.Competency_Model__c).add(competency);
            competencyModelIdByName.put(competency.Competency_Model__r.Name, competency.Competency_Model__c);

            Decimal competencyAverage;

            // If Scores goes over 9 start back at 1
            if (score > 9) {
                score = 1;
            }

            if (competency.Skills__r?.isEmpty() == false) {
                Decimal allSkillsAverages = 0;
                for (Skill__c skill : competency.Skills__r) {
                    skillMap.put(skill.Id, skill);

                    if (score > 9) {
                        score = 1;
                    }

                    for (Observation__c observation : observations) {
                        Observed_Competency__c observedCompetency = TestDataFactory.createObservedCompetency(competency.Id, skill.Id,
                            String.valueOf(score), observation.Id);

                        observedCompetencies.add(observedCompetency);

                        // Since we use every Score value, any Observed Competency with a Score of 3 or less will be low scoring
                        if (score <= 3) {
                            lowScoringObservedCompetencies.add(observedCompetency);
                        }
                    }

                    Decimal averageScore = score++;
                    averageScoreBySkillId.put(skill.Id, averageScore);
                    if (!recordIdsByAverageScore.containsKey(averageScore)) {
                        recordIdsByAverageScore.put(averageScore, new List<Id>());
                    }
                    recordIdsByAverageScore.get(averageScore).add(skill.Id);

                    allSkillsAverages += averageScore;
                }
                
                competencyAverage = allSkillsAverages / competency.Skills__r.size();
            }
            else {
                for (Observation__c observation : observations) {
                    Observed_Competency__c observedCompetency = TestDataFactory.createObservedCompetency(competency.Id, null,
                        String.valueOf(score), observation.Id);

                    observedCompetencies.add(observedCompetency);

                    // Since we use every Score value, any Observed Competency with a Score of 3 or less will be low scoring
                    if (score <= 3) {
                        lowScoringObservedCompetencies.add(observedCompetency);
                    }
                }

                competencyAverage = score++;

                if (!recordIdsByAverageScore.containsKey(competencyAverage)) {
                    recordIdsByAverageScore.put(competencyAverage, new List<Id>());
                }
                
                recordIdsByAverageScore.get(competencyAverage).add(competency.Id);
            }

            averageScoreByCompetencyId.put(competency.Id, competencyAverage);

            Decimal overallScore = 0;
            if (overallScoreByCompetencyModelId.containsKey(competency.Competency_Model__c)) {
                overallScore = overallScoreByCompetencyModelId.get(competency.Competency_Model__c);
            }

            overallScore += competencyAverage;

            overallScoreByCompetencyModelId.put(competency.Competency_Model__c, overallScore);
        }

        insert observedCompetencies;

        List<Lesson_Template__c> lessonTemplates = new List<Lesson_Template__c>();
        Map<Id, Lesson_Template__c> lessonTemplateByObservedCompetencyId = new Map<Id, Lesson_Template__c>();
        // There will be 3 records per Competency/Skill. Incrementing by 6 will create a Lesson for every other Competency/Skill.
        for (integer i = 0; i < lowScoringObservedCompetencies.size(); i += 6) {
            Observed_Competency__c observedCompetency = lowScoringObservedCompetencies[i];

            Id competencyId;
            Id skillId;
            if (observedCompetency.Skill__c == null) {
                competencyId = observedCompetency.Competency__c;
                skillId = null;
            }
            else {
                competencyId = null;
                skillId = observedCompetency.Skill__c;
            }

            List<Lesson_Template__c> newTemplates = TestDataFactory.createLessonTemplates(2, competencyId, skillId,'en_US');

            lessonTemplates.addAll(newTemplates);

            // Add each Skill/Competency's Observed Competency to lessonTemplateByObservedCompetencyId to create a
            // unique Lesson for each Observed Competency.
            for (integer j = 0; j < newTemplates.size(); j++) {
                lessonTemplateByObservedCompetencyId.put(lowScoringObservedCompetencies[i + j].Id, newTemplates[j]);
            }
        }

        insert lessonTemplates;

        List<Lesson__c> lessons = new List<Lesson__c>();
        Map<Id, List<Lesson__c>> lessonsByCompetencyOrSkillId = new Map<Id, List<Lesson__c>>();
        for (Id observedCompetencyId : lessonTemplateByObservedCompetencyId.keySet()) {
            Lesson_Template__c lessonTemplate = lessonTemplateByObservedCompetencyId.get(observedCompetencyId);

            Lesson__c lesson = TestDataFactory.createLesson(lessonTemplate.Name, lessonTemplate.Id,
                observedCompetencyId);

            lesson.Lesson_Template__r = lessonTemplate;
            lessons.add(lesson);

            Id keyId = lessonTemplate.Competency__c != null
                       ? lessonTemplate.Competency__c
                       : lessonTemplate.Skill__c;
            
            if (!lessonsByCompetencyOrSkillId.containsKey(keyId)) {
                lessonsByCompetencyOrSkillId.put(keyId, new List<Lesson__c>());
            }

            lessonsByCompetencyOrSkillId.get(keyId).add(lesson);
        }

        insert lessons;

        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);
        
        Test.startTest();
            iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
                new ApexPages.StandardController(benchmark));
        Test.stopTest();

        Assert.areEqual(coachee.Name, controller.CoacheeName, 'Coachee Name should be set');
        Assert.areEqual(coachee.Manager.Name, controller.RaterName, 'Rater Name should be set');
        Assert.areEqual(String.format('{0}{1}',
            new List<String>{coachee.Name, System.Label.iDevelop_Benchmark_Report_File_Name_Suffix}),
            controller.Title, 'Title not set as expected');

        Assert.areEqual(System.now().format('dd/MM/yyyy'), controller.CurrentDate,
            'Current Date was not set as expected.');

        Assert.areEqual(benchmark.Id, controller.BenchmarkId, 'Benchmark Id should be set');

        Assert.areEqual(2, controller.BenchmarkScores.size(), 'There should be two Benchmark Score');

        for (iDevelopBenchmarkReportController.CompetencyModelScore modelScore : controller.BenchmarkScores) {
            Assert.isTrue(competencyModelIdByName.containsKey(modelScore.Name),
                String.format('Unexpected Model Name {0}', new List<String>{modelScore.Name}));

            Id competencyModelId = competencyModelIdByName.get(modelScore.Name);
            List<Competency__c> competencies = competenciesByModelId.get(competencyModelId);

            Assert.areEqual(competencies.size(), modelScore.CompetencySkillAverageScores.size(),
                'More/Less Competency Scores were created than expected.');

            Decimal overallScore = overallScoreByCompetencyModelId.get(competencyModelId) / competencies.size();

            Assert.areEqual(overallScore, modelScore.ManagerOverallScore);

            for (iDevelopBenchmarkReportController.CompetencySkillAverageScore competencyScore : modelScore.CompetencySkillAverageScores) {
                Assert.isTrue(competencyMap.containsKey(competencyScore.RecordId), String.format(
                    'Competency {0} was returned unexpectedly', new List<Object>{competencyScore.Name}));

                Competency__c competency = competencyMap.get(competencyScore.RecordId);
                Assert.areEqual(competency.Name, competencyScore.Name, 'Competency Name was not set as expected.');

                if (competency.Skills__r?.isEmpty() == false) {
                    Assert.isTrue(competencyScore.ManagerDirectScores.isEmpty(), 'There should be no Manager Direct Scores');

                    Assert.areEqual(competency.Skills__r.size(), competencyScore.SkillScores.size(),
                        'More/Less Skill Scores than expected.');

                    for (iDevelopBenchmarkReportController.CompetencySkillAverageScore skillScore : competencyScore.SkillScores) {
                        Skill__c skill = skillMap.get(skillScore.RecordId);
                        Assert.areEqual(skill.Name, skillScore.Name, 'Skill Name was not set as expected.');
                        Assert.areEqual(observations.size(), skillScore.ManagerDirectScores.size(),
                            'Scores should match the total number of Observations');
                    
                        Assert.isTrue(skillScore.SkillScoresMap.isEmpty(), 'There should be no Manager Skill Scores');

                        Assert.areEqual(averageScoreBySkillId.get(skillScore.RecordId),
                            skillScore.ManagerAverageScore, 'Score was not set as expected');
                    }
                }
                else {
                    Assert.areEqual(observations.size(), competencyScore.ManagerDirectScores.size(),
                        'Scores should match the total number of Observations');
                    
                    Assert.isTrue(competencyScore.SkillScoresMap.isEmpty(), 'There should be no Manager Skill Scores');
                }

                Assert.areEqual(averageScoreByCompetencyId.get(competencyScore.RecordId),
                    competencyScore.ManagerAverageScore, 'Score was not set as expected');
            }
        }

        List<Decimal> allScores = new List<Decimal>(recordIdsByAverageScore.keySet());
        allScores.sort();

        Integer highScoreIndex = 0;
        Integer highScoreRank = 1;
        for (integer i = allScores.size() - 1; i >= 0 && highScoreIndex < controller.HighestScores.size(); i--) {
            Decimal expectedScore = allScores[i];

            for (Id recordId : recordIdsByAverageScore.get(expectedScore)) {
                iDevelopBenchmarkReportController.HighestLowestScore highScore = controller.HighestScores[highScoreIndex++];
                Assert.areEqual(highScoreRank, highScore.Rank, 'Rank not set as expected.');
                Assert.areEqual(expectedScore, highScore.Score,
                    'The highest score was not set as expected');
                
                String expectedCompetencyName;
                String expectedSkilLName;
                if (competencyMap.containsKey(recordId)) {
                    Competency__c competency = competencyMap.get(recordId);
                    expectedCompetencyName = competency.Name;
                    expectedSkilLName = competency.Name;
                }
                else if (skillMap.containsKey(recordId)) {
                    Skill__c skill = skillMap.get(recordId);
                    expectedSkilLName = skill.Name;
                    expectedCompetencyName = competencyMap.get(skill.Competency__c).Name;
                }

                Assert.areEqual(expectedCompetencyName, highScore.Competency, 'High Score not set to the expected Competency');
                Assert.areEqual(expectedSkilLName, highScore.Skill, 'High Score not set to the expected Skill');
            }

            highScoreRank++;
        }

        Integer lowScoreIndex = 0;
        for (integer i = 0; i < allScores.size() && lowScoreIndex < controller.LowestScores.size(); i++) {
            Decimal expectedScore = allScores[i];

            for (Id recordId : recordIdsByAverageScore.get(expectedScore)) {
                iDevelopBenchmarkReportController.HighestLowestScore lowScore = controller.LowestScores[lowScoreIndex++];
                Assert.areEqual(i + 1, lowScore.Rank, 'Rank not set as expected.');
                Assert.areEqual(expectedScore, lowScore.Score,
                    'The low score was not set as expected');
                
                String expectedCompetencyName;
                String expectedSkilLName;
                if (competencyMap.containsKey(recordId)) {
                    Competency__c competency = competencyMap.get(recordId);
                    expectedCompetencyName = competency.Name;
                    expectedSkilLName = competency.Name;
                }
                else if (skillMap.containsKey(recordId)) {
                    Skill__c skill = skillMap.get(recordId);
                    expectedSkilLName = skill.Name;
                    expectedCompetencyName = competencyMap.get(skill.Competency__c).Name;
                }

                Assert.areEqual(expectedCompetencyName, lowScore.Competency, 'Low Score not set to the expected Competency');
                Assert.areEqual(expectedSkilLName, lowScore.Skill, 'Low Score not set to the expected Skill');
            }
        }
        
        lowScoreIndex = 0;
        Integer rankIndex = 1;
        for (integer i = 0; i < allScores.size() && lowScoreIndex < controller.LowestScoringCompetencies.size(); i++) {
            Decimal expectedScore = allScores[i];

            Boolean incrementRank = false;
            for (Id recordId : recordIdsByAverageScore.get(expectedScore)) {
                iDevelopBenchmarkReportController.CompetencyRecommendedELearnings lowScore = controller.LowestScoringCompetencies[lowScoreIndex++];
                Assert.areEqual(recordId, lowScore.RecordId, 'Low Score not set to the expected Record');

                String expectedName;
                if (competencyMap.containsKey(recordId)) {
                    expectedName = competencyMap.get(recordId).Name;
                }
                else {
                    expectedName = skillMap.get(recordId).Name;
                }
                
                Assert.areEqual(expectedName, lowScore.Name, 'Name was not set as expected.');

                if (lessonsByCompetencyOrSkillId.containsKey(lowScore.RecordId)) {
                    incrementRank = true;
                    Assert.areEqual(rankIndex, lowScore.Rank, 'Rank was not set as expected');
                    Assert.isTrue(lowScore.HasELearnings, 'eLearnings should have been added');
                    
                    List<Lesson__c> expectedLessons = lessonsByCompetencyOrSkillId.get(lowScore.RecordId);
                    // To avoid ordering issues Lessons are not asserted
                    Assert.areEqual(expectedLessons.size(), lowScore.RecommendedELearnings.size(),
                        'More/less Lessons were added than expected.');
                }
                else {
                    Assert.isNull(lowScore.Rank, 'Rank should not be set.');
                    Assert.isTrue(lowScore.RecommendedELearnings.isEmpty(), 'No eLearnings should have been added');
                    Assert.isTrue(!lowScore.HasELearnings, 'No eLearnings should have been added');
                }
            }

            if (incrementRank) {
                rankIndex++;
            }
        }

        assertSelfObservationNotSet(controller);
    }

    @isTest
    private static void constructor_BenchmarkWithTranslations_Test() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];

        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        insert benchmark;

        List<Observation__c> observations = TestDataFactory.createObservations(2, benchmark.Id, 'Coach');
        insert observations;

        Map<Id, Skill__c> skillMap = new Map<Id, SKill__c>();
        List<Observed_Competency__c> observedCompetencies = new List<Observed_Competency__c>();
        List<Data_Translation__c> dataTranslations = new List<Data_Translation__c>();
        Map<Id, Data_Translation__c> translationsByCompetencyOrSkillId = new Map<Id, Data_Translation__c>();
        Map<Id, List<Observed_Competency__c>> observedCompetenciesBySkillId = new Map<Id, List<Observed_Competency__c>>();
        Integer score = 1;

        Id competencyModelId;
        for (Competency__c competency : [
            SELECT Id, Name, Competency_Model__c,
                (SELECT Id, Name, Name__c, Competency__c FROM Skills__r)
            FROM Competency__c
            WHERE Competency_Model__r.Name =: SkillsModelName
            LIMIT 3
        ]) {
            competencyModelId = competency.Competency_Model__c;
            
            Data_Translation__c competencyTranslation = TestDataFactory.createDataTranslation(competency.Id, null,
                String.format('Translated - {0}', new List<String>{competency.Name}), 'en_US');

            dataTranslations.add(competencyTranslation);
            translationsByCompetencyOrSkillId.put(competency.Id, competencyTranslation);

            for (Skill__c skill : competency.Skills__r) {
                skillMap.put(skill.Id, skill);

                observedCompetenciesBySkillId.put(skill.Id, new List<Observed_Competency__c>());
                for (Observation__c observation : observations) {
                    Observed_Competency__c observedCompetency = TestDataFactory.createObservedCompetency(competency.Id,
                        skill.Id, String.valueOf(score), observation.Id);

                        observedCompetencies.add(observedCompetency);
                        observedCompetenciesBySkillId.get(skill.Id).add(observedCompetency);
                }

                score++;

                Data_Translation__c skillTranslation =TestDataFactory.createDataTranslation(null, skill.Id,
                    String.format('Translated - {0}', new List<String>{skill.Name__c}), 'en_US');

                dataTranslations.add(skillTranslation);

                translationsByCompetencyOrSkillId.put(skill.Id, skillTranslation);
            }
        }

        String competencyModelTranslatedName = String.format('Translated - {0}', new List<String>{SkillsModelName});
        dataTranslations.add(TestDataFactory.createDataTranslation(null, null, competencyModelId,
            competencyModelTranslatedName, 'en_US'));

        insert dataTranslations;

        for (Id skillId : observedCompetenciesBySkillId.keySet()) {
            for (Observed_Competency__c observedCompetency : observedCompetenciesBySkillId.get(skillId)) {
                observedCompetency.Competency_Translation__c = translationsByCompetencyOrSkillId.get(
                    observedCompetency.Competency__c).Id;

                observedCompetency.Skill_Translation__c = translationsByCompetencyOrSkillId.get(skillId).Id;
            }
        }

        insert observedCompetencies;

        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);
        
        Test.startTest();
            iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
                new ApexPages.StandardController(benchmark));
        Test.stopTest();

        Assert.areEqual(coachee.Name, controller.CoacheeName, 'Coachee Name was not set as expected');
        Assert.areEqual(coachee.Manager.Name, controller.RaterName, 'Rater Name was not set as expected');
        Assert.areEqual(String.format('{0}{1}',
            new List<String>{coachee.Name, System.Label.iDevelop_Benchmark_Report_File_Name_Suffix}),
            controller.Title, 'Title not set as expected');

        Assert.areEqual(System.now().format('dd/MM/yyyy'), controller.CurrentDate,
            'Current Date was not set as expected.');

        Assert.areEqual(benchmark.Id, controller.BenchmarkId, 'Benchmark Id should be set');

        Assert.areEqual(1, controller.BenchmarkScores.size(), 'There should be one Benchmark Score');

        for (iDevelopBenchmarkReportController.CompetencyModelScore modelScore : controller.BenchmarkScores) {
            Assert.areEqual(competencyModelTranslatedName, modelScore.Name, 'Model Score was not set as expected.');

            for (iDevelopBenchmarkReportController.CompetencySkillAverageScore competencyScore : modelScore.CompetencySkillAverageScores) {
                Assert.areEqual(translationsByCompetencyOrSkillId.get(competencyScore.RecordId).Name__c,
                    competencyScore.Name, 'Competency Name was not set as expected.');

                for (iDevelopBenchmarkReportController.CompetencySkillAverageScore skillScore : competencyScore.SkillScores) {
                    Assert.areEqual(translationsByCompetencyOrSkillId.get(skillScore.RecordId).Name__c, skillScore.Name,
                        'Skill Name was not set as expected.');
                }
            }
        }

        for (Integer i = 0; i < controller.HighestScores.size(); i++) {
            iDevelopBenchmarkReportController.HighestLowestScore highScore = controller.HighestScores[i];
            Data_Translation__c skillTranslation = translationsByCompetencyOrSkillId.get(highScore.RecordId);

            Skill__c skill = skillMap.get(highScore.RecordId);
            Data_Translation__c competencyTranslation = translationsByCompetencyOrSkillId.get(skill.Competency__c);

            Assert.areEqual(competencyTranslation.Name__c, highScore.Competency,
                'High Score not set to the expected Competency');

            Assert.areEqual(skillTranslation.Name__c, highScore.Skill, 'High Score not set to the expected Skill');
        }

        for (integer i = 0; i < controller.LowestScores.size(); i++) {
            iDevelopBenchmarkReportController.HighestLowestScore lowScore = controller.LowestScores[i];
            Data_Translation__c skillTranslation = translationsByCompetencyOrSkillId.get(lowScore.RecordId);

            Skill__c skill = skillMap.get(lowScore.RecordId);
            Data_Translation__c competencyTranslation = translationsByCompetencyOrSkillId.get(skill.Competency__c);

            Assert.areEqual(competencyTranslation.Name__c, lowScore.Competency,
                'Low Score not set to the expected Competency');
                
            Assert.areEqual(skillTranslation.Name__c, lowScore.Skill, 'Low Score not set to the expected Skill');
        }
        
        for (integer i = 0; i < controller.LowestScoringCompetencies.size(); i++) {
            iDevelopBenchmarkReportController.CompetencyRecommendedELearnings lowScore = controller.LowestScoringCompetencies[i];
            Data_Translation__c skillTranslation = translationsByCompetencyOrSkillId.get(lowScore.RecordId);

            Assert.areEqual(skillTranslation.Name__c, lowScore.Name,
                'Low Score not set to the expected Competency');
        }

        assertSelfObservationNotSet(controller);
    }

    @isTest
    private static void highestLowestScore_Compare_To_Positive_Test() {
        iDevelopBenchmarkReportController.HighestLowestScore score1 = new iDevelopBenchmarkReportController.HighestLowestScore(
            new iDevelopBenchmarkReportController.CompetencySkillAverageScore('Test', null, null), 'Competency', null);

        score1.Score = 8;

        iDevelopBenchmarkReportController.HighestLowestScore score2 = new iDevelopBenchmarkReportController.HighestLowestScore(
            new iDevelopBenchmarkReportController.CompetencySkillAverageScore('Test 2', null, null), 'Competency', null);

        score2.Score = 9;

        Test.startTest();
            Integer compareValue = score2.compareTo(score1);
        Test.stopTest();

        Assert.areEqual(1, compareValue, 'Compare value should be positive');
    }

    @isTest
    private static void highestLowestScore_Compare_To_Negative_Test() {
        iDevelopBenchmarkReportController.HighestLowestScore score1 = new iDevelopBenchmarkReportController.HighestLowestScore(
            new iDevelopBenchmarkReportController.CompetencySkillAverageScore('Test', null, null), 'Competency', null);

        score1.Score = 9;

        iDevelopBenchmarkReportController.HighestLowestScore score2 = new iDevelopBenchmarkReportController.HighestLowestScore(
            new iDevelopBenchmarkReportController.CompetencySkillAverageScore('Test 2', null, null), 'Competency', null);

        score2.Score = 8;

        Test.startTest();
            Integer compareValue = score2.compareTo(score1);
        Test.stopTest();

        Assert.areEqual(-1, compareValue, 'Compare value should be negative');
    }

    @isTest
    private static void highestLowestScore_Compare_To_Equal_Test() {
        iDevelopBenchmarkReportController.HighestLowestScore score1 = new iDevelopBenchmarkReportController.HighestLowestScore(
            new iDevelopBenchmarkReportController.CompetencySkillAverageScore('Test', null, null), 'Competency', null);

        score1.Score = 8;

        iDevelopBenchmarkReportController.HighestLowestScore score2 = new iDevelopBenchmarkReportController.HighestLowestScore(
            new iDevelopBenchmarkReportController.CompetencySkillAverageScore('Test 2', null, null), 'Competency', null);

        score2.Score = 8;

        Test.startTest();
            Integer compareValue = score2.compareTo(score1);
        Test.stopTest();

        Assert.areEqual(0, compareValue, 'Compare value should be 0');
    }

    @isTest
    private static void competencySkillAverageScore_NullScore_Test() {
        iDevelopBenchmarkReportController.CompetencySkillAverageScore averageScore = new iDevelopBenchmarkReportController.CompetencySkillAverageScore(
            'Test', null, null);

        Test.startTest();
            averageScore.add(new Observed_Competency__c(Observation__r = new Observation__c(Type__c = 'Coach')), null);
        Test.stopTest();
        
        Assert.areEqual(0, averageScore.ManagerDirectScores[0], 'Score should be 0');
    }

    @isTest
    private static void savePDF_Test_NewFile() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];

        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        insert benchmark;

        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);

        iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
                new ApexPages.StandardController(benchmark));
            
        controller.pdfFile = 'Test';
        Test.startTest();
            controller.savePDF();
        Test.stopTest();

        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LInkedEntityId =: benchmark.Id];

        Assert.areEqual(1, contentDocumentLinks.size(), 'More Content Document Links found than expected');

        ContentVersion file = [
            SELECT Id, Title
            FROM ContentVersion
            WHERE ContentDocumentId =: contentDocumentLinks[0].ContentDocumentId
        ];
        
        Assert.areEqual(String.format('{0}.pdf', new List<String>{controller.Title}),
            file.Title, 'File Title was not set as expected.');
    }

    @isTest
    private static void savePDF_Test_ExistingFile() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];

        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        insert benchmark;

        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);

        iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
                new ApexPages.StandardController(benchmark));

        String fileName = String.format('{0}.pdf', new List<String>{controller.Title});

        ContentVersion file = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName,
            VersionData = EncodingUtil.base64Decode('ABC'),
            origin = 'H'
        );

        insert file;

        insert new ContentDocumentLink(
                LInkedEntityId = benchmark.Id,
                ContentDocumentId = [
                    SELECT ContentDocumentId
                    FROM ContentVersion
                    WHERE Id =: file.Id LIMIT 1].ContentDocumentId
            );
            
        controller.pdfFile = 'Test';

        Test.startTest();
            controller.savePDF();
        Test.stopTest();

        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LInkedEntityId =: benchmark.Id];

        Assert.areEqual(1, contentDocumentLinks.size(), 'More/Less Content Document Links found than expected');

        List<ContentVersion> files = [
            SELECT Id, Title
            FROM ContentVersion
            WHERE ContentDocumentId =: contentDocumentLinks[0].ContentDocumentId
        ];

        Assert.areEqual(2, files.size(), '2 Files should be created on the same Content Document');
    }

    @isTest
    private static void constructor_BenchmarkWithSelfObservationAndAllData() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name, LanguageLocaleKey
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];

        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        insert benchmark;

        List<Observation__c> coachObservations = TestDataFactory.createObservations(3, benchmark.Id, 'Coach');
        Observation__c selfObservation = TestDataFactory.createObservations(1, benchmark.Id, 'Self')[0];

        List<Observation__c> allObservations = new List<Observation__c>();
        allObservations.addAll(coachObservations);
        allObservations.add(selfObservation);
        insert allObservations;

        Map<Id, Competency__c> competencyMap = new Map<Id, Competency__c>();
        Map<Id, Skill__c> skillMap = new Map<Id, SKill__c>();
        Map<Id, List<Competency__c>> competenciesByModelId = new Map<Id, List<Competency__c>>();
        Map<String, Id> competencyModelIdByName = new Map<String, Id>();
        Map<Id, Decimal> averageScoreByCompetencyId = new Map<Id, Decimal>();
        Map<Id, Decimal> selfAverageScoreByCompetencyId = new Map<Id, Decimal>();
        Map<Decimal, List<Id>> recordIdsByAverageScore = new Map<Decimal, List<Id>>(); 
        Map<Decimal, List<Id>> recordIdsByGap = new Map<Decimal, List<Id>>();
        Map<Id, Decimal> averageScoreBySkillId = new Map<Id, Decimal>();
        Map<Id, Decimal> selfAverageScoreBySkillId = new Map<Id, Decimal>();
        Map<Id, Decimal> overallScoreByCompetencyModelId = new Map<Id, Decimal>();
        Map<Id, Decimal> selfOverallScoreByCompetencyModelId = new Map<Id, Decimal>();
        List<Observed_Competency__c> lowScoringObservedCompetencies = new List<Observed_Competency__c>();
        Integer score = 1;

        // Setup 1 Observed Competency per Competency or Competency's Skill
        // Score is incremented for each Competency or Skill
        List<Observed_Competency__c> observedCompetencies = new List<Observed_Competency__c>();
        for (Competency__c competency : [
            SELECT Id, Name, Competency_Model__c, Competency_Model__r.Name,
                (SELECT Id, Name, Competency__c FROM Skills__r)
            FROM Competency__c
            WHERE Competency_Model__r.Name in: new List<String> {noSkillsModelName, SkillsModelName}
        ]) {
            competencyMap.put(competency.Id, competency);

            if (!competenciesByModelId.containsKey(competency.Competency_Model__c)) {
                competenciesByModelId.put(competency.Competency_Model__c, new List<Competency__c>());
            }
            competenciesByModelId.get(competency.Competency_Model__c).add(competency);
            competencyModelIdByName.put(competency.Competency_Model__r.Name, competency.Competency_Model__c);

            Decimal competencyAverage;
            Decimal selfCompetencyAverage;

            // If Scores goes over 9 start back at 1
            if (score > 9) {
                score = 1;
            }

            if (competency.Skills__r?.isEmpty() == false) {
                Decimal allSkillsAverages = 0;
                Decimal allSkillsSelfAverage = 0;
                for (Skill__c skill : competency.Skills__r) {
                    skillMap.put(skill.Id, skill);

                    if (score > 9) {
                        score = 1;
                    }

                    for (Observation__c observation : coachObservations) {
                        Observed_Competency__c observedCompetency = TestDataFactory.createObservedCompetency(competency.Id, skill.Id,
                            String.valueOf(score), observation.Id);

                        observedCompetencies.add(observedCompetency);

                        // Since we use every Score value, any Observed Competency with a Score of 3 or less will be low scoring
                        if (score <= 3) {
                            lowScoringObservedCompetencies.add(observedCompetency);
                        }
                    }

                    // Calculate Self score as the reverse of the averageScore
                    Decimal selfScore = 10 - score;
                    
                    Decimal averageScore = score++;
                    averageScoreBySkillId.put(skill.Id, averageScore);
                    if (!recordIdsByAverageScore.containsKey(averageScore)) {
                        recordIdsByAverageScore.put(averageScore, new List<Id>());
                    }

                    recordIdsByAverageScore.get(averageScore).add(skill.Id);

                    allSkillsAverages += averageScore;

                    observedCompetencies.add(TestDataFactory.createObservedCompetency(competency.Id, skill.Id,
                        String.valueOf(selfScore), selfObservation.Id));

                    selfAverageScoreBySkillId.put(skill.Id, selfScore);

                    allSkillsSelfAverage += selfScore;

                    Decimal gap = averageScore - selfScore;
                    if (!recordIdsByGap.containsKey(gap)) {
                        recordIdsByGap.put(gap, new List<Id>());
                    }

                    recordIdsByGap.get(gap).add(skill.Id);
                }
                
                competencyAverage = allSkillsAverages / competency.Skills__r.size();
                selfCompetencyAverage = allSkillsSelfAverage / competency.Skills__r.size();
            }
            else {
                for (Observation__c observation : coachObservations) {
                    Observed_Competency__c observedCompetency = TestDataFactory.createObservedCompetency(competency.Id, null,
                        String.valueOf(score), observation.Id);

                    observedCompetencies.add(observedCompetency);

                    // Since we use every Score value, any Observed Competency with a Score of 3 or less will be low scoring
                    if (score <= 3) {
                        lowScoringObservedCompetencies.add(observedCompetency);
                    }
                }

                // Calculate Self score as the reverse of the averageScore
                Decimal selfScore = 10 - score;

                competencyAverage = score++;
                selfCompetencyAverage = selfScore;

                if (!recordIdsByAverageScore.containsKey(competencyAverage)) {
                    recordIdsByAverageScore.put(competencyAverage, new List<Id>());
                }
                
                recordIdsByAverageScore.get(competencyAverage).add(competency.Id);
                
                Decimal gap = competencyAverage - selfCompetencyAverage;

                if (!recordIdsByGap.containsKey(gap)) {
                    recordIdsByGap.put(gap, new List<Id>());
                }

                recordIdsByGap.get(gap).add(competency.Id);

                observedCompetencies.add(TestDataFactory.createObservedCompetency(competency.Id, null,
                    String.valueOf(selfScore), selfObservation.Id));
            }

            averageScoreByCompetencyId.put(competency.Id, competencyAverage);
            
            selfAverageScoreByCompetencyId.put(competency.Id, selfCompetencyAverage);

            Decimal overallScore = 0;
            if (overallScoreByCompetencyModelId.containsKey(competency.Competency_Model__c)) {
                overallScore = overallScoreByCompetencyModelId.get(competency.Competency_Model__c);
            }

            overallScore += competencyAverage;

            overallScoreByCompetencyModelId.put(competency.Competency_Model__c, overallScore);

            Decimal selfOverallScore = 0;
            if (selfOverallScoreByCompetencyModelId.containsKey(competency.Competency_Model__c)) {
                selfOverallScore = selfOverallScoreByCompetencyModelId.get(competency.Competency_Model__c);
            }

            selfOverallScore += selfCompetencyAverage;

            selfOverallScoreByCompetencyModelId.put(competency.Competency_Model__c, selfOverallScore);
        }

        insert observedCompetencies;

        List<Lesson_Template__c> lessonTemplates = new List<Lesson_Template__c>();
        Map<Id, Lesson_Template__c> lessonTemplateByObservedCompetencyId = new Map<Id, Lesson_Template__c>();
        // There will be 3 records per Competency/Skill. Incrementing by 6 will create a Lesson for every other Competency/Skill.
        for (integer i = 0; i < lowScoringObservedCompetencies.size(); i += 6) {
            Observed_Competency__c observedCompetency = lowScoringObservedCompetencies[i];

            Id competencyId;
            Id skillId;
            if (observedCompetency.Skill__c == null) {
                competencyId = observedCompetency.Competency__c;
                skillId = null;
            }
            else {
                competencyId = null;
                skillId = observedCompetency.Skill__c;
            }

            List<Lesson_Template__c> newTemplates = TestDataFactory.createLessonTemplates(2, competencyId, skillId,'en_US');

            lessonTemplates.addAll(newTemplates);

            // Add each Skill/Competency's Observed Competency to lessonTemplateByObservedCompetencyId to create a
            // unique Lesson for each Observed Competency.
            for (integer j = 0; j < newTemplates.size(); j++) {
                lessonTemplateByObservedCompetencyId.put(lowScoringObservedCompetencies[i + j].Id, newTemplates[j]);
            }
        }

        insert lessonTemplates;

        List<Lesson__c> lessons = new List<Lesson__c>();
        Map<Id, List<Lesson__c>> lessonsByCompetencyOrSkillId = new Map<Id, List<Lesson__c>>();
        for (Id observedCompetencyId : lessonTemplateByObservedCompetencyId.keySet()) {
            Lesson_Template__c lessonTemplate = lessonTemplateByObservedCompetencyId.get(observedCompetencyId);

            Lesson__c lesson = TestDataFactory.createLesson(lessonTemplate.Name, lessonTemplate.Id,
                observedCompetencyId);

            lesson.Lesson_Template__r = lessonTemplate;
            lessons.add(lesson);

            Id keyId = lessonTemplate.Competency__c != null
                       ? lessonTemplate.Competency__c
                       : lessonTemplate.Skill__c;
            
            if (!lessonsByCompetencyOrSkillId.containsKey(keyId)) {
                lessonsByCompetencyOrSkillId.put(keyId, new List<Lesson__c>());
            }

            lessonsByCompetencyOrSkillId.get(keyId).add(lesson);
        }

        insert lessons;

        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);
        
        Test.startTest();
            iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
                new ApexPages.StandardController(benchmark));
        Test.stopTest();

        Assert.areEqual(coachee.Name, controller.CoacheeName, 'Coachee Name should be set');
        Assert.areEqual(coachee.Manager.Name, controller.RaterName, 'Rater Name should be set');
        Assert.areEqual(String.format('{0}{1}',
            new List<String>{coachee.Name, System.Label.iDevelop_Benchmark_Report_File_Name_Suffix}),
            controller.Title, 'Title not set as expected');

        Assert.areEqual(System.now().format('dd/MM/yyyy'), controller.CurrentDate,
            'Current Date was not set as expected.');

        Assert.areEqual(benchmark.Id, controller.BenchmarkId, 'Benchmark Id should be set');

        Assert.areEqual(true, controller.SelfObservationPresent, 'Self-Observation should be present.');

        Assert.areEqual(2, controller.BenchmarkScores.size(), 'There should be two Benchmark Score');

        for (iDevelopBenchmarkReportController.CompetencyModelScore modelScore : controller.BenchmarkScores) {
            Assert.isTrue(competencyModelIdByName.containsKey(modelScore.Name),
                String.format('Unexpected Model Name {0}', new List<String>{modelScore.Name}));

            Id competencyModelId = competencyModelIdByName.get(modelScore.Name);
            List<Competency__c> competencies = competenciesByModelId.get(competencyModelId);

            Assert.areEqual(competencies.size(), modelScore.CompetencySkillAverageScores.size(),
                'More/Less Competency Scores were created than expected.');

            Decimal overallScore = overallScoreByCompetencyModelId.get(competencyModelId) / competencies.size();

            Assert.areEqual(overallScore, modelScore.ManagerOverallScore, 'Manager Overall Score was not set as expected.');

            Decimal selfOverallScore = selfOverallScoreByCompetencyModelId.get(competencyModelId) / competencies.size();

            Assert.areEqual(selfOverallScore, modelScore.SelfOverallScore, 'Self Overall Score was not set as expected.');

            for (iDevelopBenchmarkReportController.CompetencySkillAverageScore competencyScore : modelScore.CompetencySkillAverageScores) {
                Assert.isTrue(competencyMap.containsKey(competencyScore.RecordId), String.format(
                    'Competency {0} was returned unexpectedly', new List<Object>{competencyScore.Name}));

                Competency__c competency = competencyMap.get(competencyScore.RecordId);
                Assert.areEqual(competency.Name, competencyScore.Name, 'Competency Name was not set as expected.');

                if (competency.Skills__r?.isEmpty() == false) {
                    Assert.isTrue(competencyScore.ManagerDirectScores.isEmpty(), 'There should be no Manager Direct Scores');

                    Assert.areEqual(competency.Skills__r.size(), competencyScore.SkillScores.size(),
                        'More/Less Skill Scores than expected.');

                    for (iDevelopBenchmarkReportController.CompetencySkillAverageScore skillScore : competencyScore.SkillScores) {
                        Skill__c skill = skillMap.get(skillScore.RecordId);
                        Assert.areEqual(skill.Name, skillScore.Name, 'Skill Name was not set as expected.');
                        Assert.areEqual(coachObservations.size(), skillScore.ManagerDirectScores.size(),
                            'Manager Scores should match the total number of Observations');
                    
                        Assert.isTrue(skillScore.SkillScoresMap.isEmpty(), 'There should be no Manager Skill Scores');

                        Assert.areEqual(averageScoreBySkillId.get(skillScore.RecordId),
                            skillScore.ManagerAverageScore, 'Manager Average Score was not set as expected');

                        Assert.areEqual(selfAverageScoreBySkillId.get(skillScore.RecordId),
                            skillScore.SelfAverageScore, 'Self Average Score was not set as expected');

                        Assert.areEqual(skillScore.ManagerAverageScore - skillScore.SelfAverageScore,
                            skillScore.ManagerToSelfGap, 'Self to Manager Gap not set as expected.');
                    }
                }
                else {
                    Assert.areEqual(coachObservations.size(), competencyScore.ManagerDirectScores.size(),
                        'Manager Scores should match the total number of Observations');
                    
                    Assert.isTrue(competencyScore.SkillScoresMap.isEmpty(), 'There should be no Manager Skill Scores');
                }

                Assert.areEqual(averageScoreByCompetencyId.get(competencyScore.RecordId),
                    competencyScore.ManagerAverageScore, 'Manager Average Score was not set as expected');

                Assert.areEqual(selfAverageScoreByCompetencyId.get(competencyScore.RecordId),
                    competencyScore.SelfAverageScore, 'Self Average Score was not set as expected');

                Assert.areEqual(competencyScore.ManagerAverageScore - competencyScore.SelfAverageScore,
                    competencyScore.ManagerToSelfGap, 'Self to Manager Gap not set as expected.');
            }
        }

        List<Decimal> allScores = new List<Decimal>(recordIdsByAverageScore.keySet());
        allScores.sort();

        Integer highScoreIndex = 0;
        Integer highScoreRank = 1;
        for (integer i = allScores.size() - 1; i >= 0 && highScoreIndex < controller.HighestScores.size(); i--) {
            Decimal expectedScore = allScores[i];

            for (Id recordId : recordIdsByAverageScore.get(expectedScore)) {
                iDevelopBenchmarkReportController.HighestLowestScore highScore = controller.HighestScores[highScoreIndex++];
                Assert.areEqual(highScoreRank, highScore.Rank, 'Rank not set as expected.');
                Assert.areEqual(expectedScore, highScore.Score,
                    'The highest score was not set as expected');
                
                SkillCompetencyName expectedSkillAndCompetencyName = determineHighScoreSkillCompetencyName(recordId, competencyMap, skillMap);

                Assert.areEqual(expectedSkillAndCompetencyName.CompetencyName, highScore.Competency, 'High Score not set to the expected Competency');
                Assert.areEqual(expectedSkillAndCompetencyName.SkillName, highScore.Skill, 'High Score not set to the expected Skill');
            }

            highScoreRank++;
        }

        Integer lowScoreIndex = 0;
        for (integer i = 0; i < allScores.size() && lowScoreIndex < controller.LowestScores.size(); i++) {
            Decimal expectedScore = allScores[i];

            for (Id recordId : recordIdsByAverageScore.get(expectedScore)) {
                iDevelopBenchmarkReportController.HighestLowestScore lowScore = controller.LowestScores[lowScoreIndex++];
                Assert.areEqual(i + 1, lowScore.Rank, 'Rank not set as expected.');
                Assert.areEqual(expectedScore, lowScore.Score,
                    'The low score was not set as expected');
                
                SkillCompetencyName expectedSkillAndCompetencyName = determineHighScoreSkillCompetencyName(recordId, competencyMap, skillMap);

                Assert.areEqual(expectedSkillAndCompetencyName.CompetencyName, lowScore.Competency, 'Low Score not set to the expected Competency');
                Assert.areEqual(expectedSkillAndCompetencyName.SkillName, lowScore.Skill, 'Low Score not set to the expected Skill');
            }
        }
        
        lowScoreIndex = 0;
        Integer rankIndex = 1;
        for (integer i = 0; i < allScores.size() && lowScoreIndex < controller.LowestScoringCompetencies.size(); i++) {
            Decimal expectedScore = allScores[i];

            Boolean incrementRank = false;
            for (Id recordId : recordIdsByAverageScore.get(expectedScore)) {
                iDevelopBenchmarkReportController.CompetencyRecommendedELearnings lowScore = controller.LowestScoringCompetencies[lowScoreIndex++];
                Assert.areEqual(recordId, lowScore.RecordId, 'Low Score not set to the expected Record');

                String expectedName;
                if (competencyMap.containsKey(recordId)) {
                    expectedName = competencyMap.get(recordId).Name;
                }
                else {
                    expectedName = skillMap.get(recordId).Name;
                }
                
                Assert.areEqual(expectedName, lowScore.Name, 'Name was not set as expected.');

                if (lessonsByCompetencyOrSkillId.containsKey(lowScore.RecordId)) {
                    incrementRank = true;
                    Assert.areEqual(rankIndex, lowScore.Rank, 'Rank was not set as expected');
                    Assert.isTrue(lowScore.HasELearnings, 'eLearnings should have been added');
                    
                    List<Lesson__c> expectedLessons = lessonsByCompetencyOrSkillId.get(lowScore.RecordId);
                    // To avoid ordering issues Lessons are not asserted
                    Assert.areEqual(expectedLessons.size(), lowScore.RecommendedELearnings.size(),
                        'More/less Lessons were added than expected.');
                }
                else {
                    Assert.isNull(lowScore.Rank, 'Rank should not be set.');
                    Assert.isTrue(lowScore.RecommendedELearnings.isEmpty(), 'No eLearnings should have been added');
                    Assert.isTrue(!lowScore.HasELearnings, 'No eLearnings should have been added');
                }
            }

            if (incrementRank) {
                rankIndex++;
            }
        }

        List<Decimal> allGaps = new List<Decimal>(recordIdsByGap.keySet());
        allGaps.sort();

        Integer topGapIndex = 0;
        Integer topGapRank = 1;
        for (integer i = allGaps.size() - 1; i >= 0 && topGapIndex < controller.TopPositiveGaps.size(); i--) {
            Decimal expectedGap = allGaps[i];

            for (Id recordId : recordIdsByGap.get(expectedGap)) {
                iDevelopBenchmarkReportController.HighestLowestGap topGap = controller.TopPositiveGaps[topGapIndex++];
                Assert.areEqual(topGapRank, topGap.Rank, 'Rank not set as expected.');
                Assert.areEqual(expectedGap, topGap.Gap, 'The Top Gap\'s gap was not set as expected');

                SkillCompetencyName expectedSkillAndCompetencyName = determineHighScoreSkillCompetencyName(recordId, competencyMap, skillMap);

                Assert.areEqual(expectedSkillAndCompetencyName.CompetencyName, topGap.Competency, 'Top Gap not set to the expected Competency');
                Assert.areEqual(expectedSkillAndCompetencyName.SkillName, topGap.Skill, 'Top Gap not set to the expected Skill');
            }

            topGapRank++;
        }

        Integer lowGapIndex = 0;
        for (integer i = 0; i < allGaps.size() && lowGapIndex < controller.TopNegativeGaps.size() ; i++) {
            Decimal expectedGap = allGaps[i];

            for (Id recordId : recordIdsByGap.get(expectedGap)) {
                iDevelopBenchmarkReportController.HighestLowestGap negativeGap = controller.TopNegativeGaps[lowGapIndex++];
                Assert.areEqual(i + 1, negativeGap.Rank, 'Rank not set as expected.');
                Assert.areEqual(expectedGap, negativeGap.Gap);

                SkillCompetencyName expectedSkillAndCompetencyName = determineHighScoreSkillCompetencyName(recordId, competencyMap, skillMap);

                Assert.areEqual(expectedSkillAndCompetencyName.CompetencyName, negativeGap.Competency, 'Negative Gap not set to the expected Competency');
                Assert.areEqual(expectedSkillAndCompetencyName.SkillName, negativeGap.Skill, 'Negative Gap not set to the expected Skill');
            }
        }
    }
    
    @isTest
    private static void constructor_BenchmarkWithSelfObservationsPositiveGapsOnly() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];

        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        insert benchmark;

        Observation__c coachObservation = TestDataFactory.createObservations(1, benchmark.Id, 'Coach')[0];
        Observation__c selfObservation = TestDataFactory.createObservations(1, benchmark.Id, 'Self')[0];

        insert new List<Observation__c> {coachObservation, selfObservation};

        Integer score = 9;
        List<Observed_Competency__c> observedCompetencies = new List<Observed_Competency__c>();
        Map<Id, Decimal> expectedScoreByCompetencyId = new Map<Id, Decimal>();
        Map<Id, Decimal> expectedSelfScoreByCompetencyId = new Map<Id, Decimal>();
        Map<Decimal, List<Id>> recordIdsByGap = new Map<Decimal, List<Id>>();

        for (Competency__c competency : [
            SELECT Id, Name, Competency_Model__c, Competency_Model__r.Name,
                (SELECT Id, Name, Competency__c FROM Skills__r)
            FROM Competency__c
            WHERE Competency_Model__r.Name =: noSkillsModelName
        ]) {
            // If Scores goes over 9 start back at 1
            if (score < 1) {
                score = 9;
            }

            observedCompetencies.add(TestDataFactory.createObservedCompetency(competency.Id,
                null, String.valueOf(score), coachObservation.Id));

            expectedScoreByCompetencyId.put(competency.Id, score);

            Integer selfScore = 10 - score;
            observedCompetencies.add(TestDataFactory.createObservedCompetency(competency.Id,
                null, String.valueOf(selfScore), selfObservation.Id));

            expectedSelfScoreByCompetencyId.put(competency.Id, selfScore);

            Decimal gap = score - selfScore;

            if (!recordIdsByGap.containsKey(gap)) {
                recordIdsByGap.put(gap, new List<Id>());
            }

            recordIdsByGap.get(gap).add(competency.Id);

            score--;
        }

        insert observedCompetencies;

        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);
        
        Test.startTest();
            iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
                new ApexPages.StandardController(benchmark));
        Test.stopTest();

        // Verify Score and gap is set properly for each record as a sanity check
        for (iDevelopBenchmarkReportController.CompetencyModelScore modelScore : controller.BenchmarkScores) {
            
            for (iDevelopBenchmarkReportController.CompetencySkillAverageScore competencyScore : modelScore.CompetencySkillAverageScores) {
                Assert.isTrue(expectedScoreByCompetencyId.containsKey(competencyScore.RecordId), String.format(
                    'Competency {0} was returned unexpectedly', new List<Object>{competencyScore.Name}));                

                Assert.areEqual(expectedScoreByCompetencyId.get(competencyScore.RecordId),
                    competencyScore.ManagerAverageScore, 'Manager Average Score was not set as expected');

                Assert.areEqual(expectedSelfScoreByCompetencyId.get(competencyScore.RecordId),
                    competencyScore.SelfAverageScore, 'Self Average Score was not set as expected');

                Assert.areEqual(competencyScore.ManagerAverageScore - competencyScore.SelfAverageScore,
                    competencyScore.ManagerToSelfGap, 'Self to Manager Gap not set as expected.');
            }
        }

        List<Decimal> allGaps = new List<Decimal>(recordIdsByGap.keySet());
        allGaps.sort();

        Integer topGapIndex = 0;
        Integer topGapRank = 1;
        for (integer i = allGaps.size() - 1; i >= 0 && topGapIndex < controller.TopPositiveGaps.size(); i--) {
            Decimal expectedGap = allGaps[i];

            for (Id recordId : recordIdsByGap.get(expectedGap)) {
                iDevelopBenchmarkReportController.HighestLowestGap topGap = controller.TopPositiveGaps[topGapIndex++];
                Assert.areEqual(topGapRank, topGap.Rank, 'Rank not set as expected.');
                Assert.areEqual(expectedGap, topGap.Gap, 'The Top Gap\'s gap was not set as expected');
            }

            topGapRank++;
        }
        
        Assert.isTrue(controller.TopNegativeGaps.isEmpty(), 'Negative Gaps was not empty as expected.');
    }

    @isTest
    private static void constructor_BenchmarkWithSelfObservationsNegativeGapsOnly() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];

        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        insert benchmark;

        Observation__c coachObservation = TestDataFactory.createObservations(1, benchmark.Id, 'Coach')[0];
        Observation__c selfObservation = TestDataFactory.createObservations(1, benchmark.Id, 'Self')[0];

        insert new List<Observation__c> {coachObservation, selfObservation};

        Integer score = 1;
        List<Observed_Competency__c> observedCompetencies = new List<Observed_Competency__c>();
        Map<Id, Decimal> expectedScoreByCompetencyId = new Map<Id, Decimal>();
        Map<Id, Decimal> expectedSelfScoreByCompetencyId = new Map<Id, Decimal>();
        Map<Decimal, List<Id>> recordIdsByGap = new Map<Decimal, List<Id>>();

        for (Competency__c competency : [
            SELECT Id, Name, Competency_Model__c, Competency_Model__r.Name,
                (SELECT Id, Name, Competency__c FROM Skills__r)
            FROM Competency__c
            WHERE Competency_Model__r.Name =: noSkillsModelName
        ]) {
            // If Scores goes over 9 start back at 1
            if (score > 9) {
                score = 1;
            }

            observedCompetencies.add(TestDataFactory.createObservedCompetency(competency.Id,
                null, String.valueOf(score), coachObservation.Id));

            expectedScoreByCompetencyId.put(competency.Id, score);

            Integer selfScore = 10 - score;
            observedCompetencies.add(TestDataFactory.createObservedCompetency(competency.Id,
                null, String.valueOf(selfScore), selfObservation.Id));

            expectedSelfScoreByCompetencyId.put(competency.Id, selfScore);

            Decimal gap = score - selfScore;

            if (!recordIdsByGap.containsKey(gap)) {
                recordIdsByGap.put(gap, new List<Id>());
            }

            recordIdsByGap.get(gap).add(competency.Id);

            score++;
        }

        insert observedCompetencies;

        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);
        
        Test.startTest();
            iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
                new ApexPages.StandardController(benchmark));
        Test.stopTest();

        // Verify Score and gap is set properly for each record as a sanity check
        for (iDevelopBenchmarkReportController.CompetencyModelScore modelScore : controller.BenchmarkScores) {
            
            for (iDevelopBenchmarkReportController.CompetencySkillAverageScore competencyScore : modelScore.CompetencySkillAverageScores) {
                Assert.isTrue(expectedScoreByCompetencyId.containsKey(competencyScore.RecordId), String.format(
                    'Competency {0} was returned unexpectedly', new List<Object>{competencyScore.Name}));                

                Assert.areEqual(expectedScoreByCompetencyId.get(competencyScore.RecordId),
                    competencyScore.ManagerAverageScore, 'Manager Average Score was not set as expected');

                Assert.areEqual(expectedSelfScoreByCompetencyId.get(competencyScore.RecordId),
                    competencyScore.SelfAverageScore, 'Self Average Score was not set as expected');

                Assert.areEqual(competencyScore.ManagerAverageScore - competencyScore.SelfAverageScore,
                    competencyScore.ManagerToSelfGap, 'Self to Manager Gap not set as expected.');
            }
        }

        List<Decimal> allGaps = new List<Decimal>(recordIdsByGap.keySet());
        allGaps.sort();

        Assert.isTrue(controller.TopPositiveGaps.isEmpty(), 'Positive Gaps was not empty as expected.');

        Integer lowGapIndex = 0;
        for (integer i = 0; i < allGaps.size() && lowGapIndex < controller.TopNegativeGaps.size() ; i++) {
            Decimal expectedGap = allGaps[i];

            for (Id recordId : recordIdsByGap.get(expectedGap)) {
                iDevelopBenchmarkReportController.HighestLowestGap negativeGap = controller.TopNegativeGaps[lowGapIndex++];
                Assert.areEqual(i + 1, negativeGap.Rank, 'Rank not set as expected.');
                Assert.areEqual(expectedGap, negativeGap.Gap);
            }
        }
    }

    @isTest
    private static void constructor_BenchmarkWithSelfObservationsEqualScores() {
        User coachee = [
            SELECT Id, Name, ManagerId, Manager.Name
            FROM User
            WHERE Username =: coacheeUserName
            LIMIT 1];

        Benchmark__c benchmark = TestDataFactory.createBenchmarks(1, coachee.Id, coachee.ManagerId)[0];
        insert benchmark;

        Observation__c coachObservation = TestDataFactory.createObservations(1, benchmark.Id, 'Coach')[0];
        Observation__c selfObservation = TestDataFactory.createObservations(1, benchmark.Id, 'Self')[0];

        insert new List<Observation__c> {coachObservation, selfObservation};

        Integer score = 1;
        List<Observed_Competency__c> observedCompetencies = new List<Observed_Competency__c>();
        Map<Id, Decimal> expectedScoreByCompetencyId = new Map<Id, Decimal>();
        Map<Id, Decimal> expectedSelfScoreByCompetencyId = new Map<Id, Decimal>();

        for (Competency__c competency : [
            SELECT Id, Name, Competency_Model__c, Competency_Model__r.Name,
                (SELECT Id, Name, Competency__c FROM Skills__r)
            FROM Competency__c
            WHERE Competency_Model__r.Name =: noSkillsModelName
        ]) {
            // If Scores goes over 9 start back at 1
            if (score > 9) {
                score = 1;
            }

            observedCompetencies.add(TestDataFactory.createObservedCompetency(competency.Id,
                null, String.valueOf(score), coachObservation.Id));

            expectedScoreByCompetencyId.put(competency.Id, score);

            observedCompetencies.add(TestDataFactory.createObservedCompetency(competency.Id,
                null, String.valueOf(score), selfObservation.Id));

            expectedSelfScoreByCompetencyId.put(competency.Id, score);

            score++;
        }

        insert observedCompetencies;

        Test.setCurrentPage(Page.iDevelopBenchmarkReport);
        ApexPages.currentPage().getParameters().put('id', benchmark.Id);
        
        Test.startTest();
            iDevelopBenchmarkReportController controller = new iDevelopBenchmarkReportController(
                new ApexPages.StandardController(benchmark));
        Test.stopTest();

        // Verify Score and gap is set properly for each record as a sanity check
        for (iDevelopBenchmarkReportController.CompetencyModelScore modelScore : controller.BenchmarkScores) {
            
            for (iDevelopBenchmarkReportController.CompetencySkillAverageScore competencyScore : modelScore.CompetencySkillAverageScores) {
                Assert.isTrue(expectedScoreByCompetencyId.containsKey(competencyScore.RecordId), String.format(
                    'Competency {0} was returned unexpectedly', new List<Object>{competencyScore.Name}));                

                Assert.areEqual(expectedScoreByCompetencyId.get(competencyScore.RecordId),
                    competencyScore.ManagerAverageScore, 'Manager Average Score was not set as expected');

                Assert.areEqual(expectedSelfScoreByCompetencyId.get(competencyScore.RecordId),
                    competencyScore.SelfAverageScore, 'Self Average Score was not set as expected');

                Assert.areEqual(0, competencyScore.ManagerToSelfGap, 'Self to Manager Gap not set as expected.');
            }
        }

        Assert.isTrue(controller.TopPositiveGaps.isEmpty(), 'Positive Gaps was not empty as expected.');
        Assert.isTrue(controller.TopNegativeGaps.isEmpty(), 'Negative Gaps was not empty as expected.');
    }

    private static void assertSelfObservationNotSet(iDevelopBenchmarkReportController controller) {
        Assert.isFalse(controller.SelfObservationPresent, 'Self-Observation should nto be present.');
        Assert.isTrue(controller.TopPositiveGaps.isEmpty(), 'No Positive Gaps should be populated without an estimate');
        Assert.isTrue(controller.TopNegativeGaps.isEmpty(), 'No Negative Gaps should be populated without an estimate');
    }

    private static SkillCompetencyName determineHighScoreSkillCompetencyName(Id recordId, Map<Id, Competency__c> competencyMap, Map<Id, Skill__c> skillMap) {
        String expectedCompetencyName;
        String expectedSkillName;

        if (competencyMap.containsKey(recordId)) {
            Competency__c competency = competencyMap.get(recordId);
            expectedCompetencyName = competency.Name;
            expectedSkillName = competency.Name;
        }
        else if (skillMap.containsKey(recordId)) {
            Skill__c skill = skillMap.get(recordId);
            expectedSkillName = skill.Name;
            expectedCompetencyName = competencyMap.get(skill.Competency__c).Name;
        }

        return new SkillCompetencyName(expectedSkillName, expectedCompetencyName);
    }

    private class SkillCompetencyName
    {
        public String SkillName {get; set;}
        public String CompetencyName {get; set;}

        public SkillCompetencyName(String skillName, String competencyName) {
            this.SkillName = skillName;
            this.CompetencyName = competencyName;
        }
    }
}