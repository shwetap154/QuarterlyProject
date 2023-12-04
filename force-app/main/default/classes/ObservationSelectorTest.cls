/**
* @description       : Test class for ObservationSelector
* @author            : Sai Saranya Siruvuri @ Deloitte
* @group             : 
* @last modified on  : 06-26-2023
* @last modified by  :
* Modifications Log
* Ver   Date         Author                      Modification
*--------------------------------------------------------------------------------------------------------
* 1.0   06-26-2023   Sai Saranya Siruvuri     Initial version with tests for selectByObservations and selectByBenchmarks
* 
**/
@isTest
private class ObservationSelectorTest {
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

        List<Observation__c> observations = TestDataFactory.createObservations(2, benchmark.Id, 'Coach');
        insert observations;

        List<Observed_Competency__c> observedCompetencies = new List<Observed_Competency__c>();
        for (integer i = 0; i < observations.size(); i++) {
            observedCompetencies.add(TestDataFactory.createObservedCompetency(competencies[i].Id, null,
                '5', observations[i].Id));
        }

        insert observedCompetencies;
    }

    @isTest
    private static void selectByBenchmarkId_Test() {
        Set<Id> BenchmarkIds = new Map<Id, Benchmark__c>([SELECT Id FROM Benchmark__c]).keySet();
        
        Test.startTest();
            List<Observation__c> lstObservations = ObservationSelector.selectByBenchmarkId(BenchmarkIds);
        Test.stopTest();

        Assert.areEqual(2, lstObservations.size(), 'More/Less Observations were returned than expected.');
    }

}