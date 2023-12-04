/**
 * Test class for BenchmarkSelector
 * @author Ethan Hirsch @ Zoetis Inc
 * @since 03-03-2023
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-03-2023   Ethan Hirsch @ Zoetis Inc   Initial Version with Tests for selectByIdWithObservations
 */
@isTest
private class BenchmarksSelectorTest {
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

        List<Benchmark__c> benchmarks = TestDataFactory.createBenchmarks(2, coachee.Id, coach.Id);
        insert benchmarks;

        List<Observation__c> observations = new List<Observation__c>();
        for (Benchmark__c benchmark : benchmarks){
            observations.addAll(TestDataFactory.createObservations(2, benchmark.Id, 'Coach'));
        }

        insert observations;
    }

    @isTest
    private static void selectByIdWithObservations_Test() {
        Set<Id> benchmarkIds = new Map<Id, Benchmark__c>([SELECT Id FROM Benchmark__c]).keySet();

        Test.startTest();
            List<Benchmark__c> benchmarks = BenchmarksSelector.selectByIdWithObservations(benchmarkIds);
        Test.stopTest();

        Assert.areEqual(2, benchmarks.size(), 'More/Less Benchmarks than expected.');
        for (Benchmark__c benchmark : benchmarks) {
            Assert.areEqual(2, benchmark.Observations__r.size(), 'More/Less Observations than expected on the Benchmark');
        }
    }
    

    @isTest
    private static void selectPreviousBenchmark_Test() {
        List<Benchmark__c> benchmarkRecs = [SELECT Id, Coachee__c, CreatedDate FROM Benchmark__c ORDER BY CREATEDDATE ASC LIMIT 2];
        for(Benchmark__c benchmarkRec :benchmarkRecs){
            benchmarkRec.Type__c = 'Coach';
            benchmarkRec.Status__c = 'Completed';
        }
        update benchmarkRecs;

        Test.startTest();
            Benchmark__c selectPreviousBenchmark = BenchmarksSelector.selectPreviousBenchmark(benchmarkRecs[1].Id, benchmarkRecs[1].Coachee__c, benchmarkRecs[1].CreatedDate);
        Test.stopTest();
        Assert.areEqual(selectPreviousBenchmark.Id, benchmarkRecs[0].Id, 'Previous Benchmark not found.');
    }

}