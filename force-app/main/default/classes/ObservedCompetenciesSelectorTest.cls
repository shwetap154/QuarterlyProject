/**
* @description       : Test class for ObservedCompetenciesSelector
* @author            : Hirsch, Ethan @ Zoetis Inc
* @group             : 
* @last modified on  : 03-06-2023
* @last modified by  :
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   03-06-2023   Raut, Pranav Krushnarao     Initial version with tests for selectByObservations and selectByBenchmarks
* 2.0   05-05-2023   Sibin Kuriakose             Added method to test selectByListBenchmarks, selectByListObservedCompetecy & selectByObsCompCompIdSkillId methods
**/
@isTest
private class ObservedCompetenciesSelectorTest {
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
    private static void selectByObservations_Test() {
        Set<Id> observationIds = new Map<Id, Observation__c>([SELECT Id FROM Observation__c]).keySet();
        
        Test.startTest();
            List<Observed_Competency__c> observedCompetencies = ObservedCompetenciesSelector.selectByObservations(observationIds);
        Test.stopTest();

        Assert.areEqual(2, observedCompetencies.size(), 'More/Less Observed Competencies were returned than expected.');
    }
    
    @isTest
    private static void selectByBenchmarks_Test(){
        Set<Id> benchmarkIds = new Map<Id, Benchmark__c>([SELECT Id FROM Benchmark__c]).keySet();
        Test.startTest();
        List<Observed_Competency__c> lstObsCompetency = ObservedCompetenciesSelector.selectByBenchmarks(benchmarkIds);
        Test.stopTest();
        Assert.areEqual(2, lstObsCompetency.size(), 'More/Less Observed Competencies were returned than expected.');
    }

    @isTest
    private static void selectByListBenchmarks_Test(){
        List<Benchmark__c> benchmark = [SELECT Id FROM Benchmark__c];
        Test.startTest();
        List<Observed_Competency__c> lstObsCompetency = ObservedCompetenciesSelector.selectByListBenchmarks(benchmark);
        Test.stopTest();
        Assert.areEqual(2, lstObsCompetency.size(), 'More/Less Observed Competencies were returned than expected.');
    }

    @isTest
    private static void selectByListObservedCompetecy_Test(){
        List<Observed_Competency__c> lstObscomprecords = [SELECT Id FROM Observed_Competency__c];
        Test.startTest();
        List<Observed_Competency__c> lstObsCompetency = ObservedCompetenciesSelector.selectByListObservedCompetecy(lstObscomprecords);
        Test.stopTest();
        Assert.areEqual(2, lstObsCompetency.size(), 'More/Less Observed Competencies were returned than expected.');
    }

    @isTest
    private static void selectByObsCompCompIdSkillId_Test(){
        List<Id> lstcomps = new List<Id>();
        List<Id> lstskill = new List<Id>();
        List<Observed_Competency__c> lstObscomprecords = [SELECT Id,Competency__c,Skill__c FROM Observed_Competency__c];
        for(Observed_Competency__c temp : lstObscomprecords){
            lstcomps.add(temp.Competency__c);
            lstskill.add(temp.Skill__c);
        }
        Test.startTest();
        List<Observed_Competency__c> lstObsCompetency = ObservedCompetenciesSelector.selectByObsCompCompIdSkillId(lstObscomprecords,lstcomps,lstskill);
        Test.stopTest();
        Assert.areEqual(2, lstObsCompetency.size(), 'More/Less Observed Competencies were returned than expected.');
    }
}