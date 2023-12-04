/**
* Selector class for Benchmarks
* @author Ethan Hirsch @ Zoetis Inc
* @since 03-03-2023
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   03-03-2023   Ethan Hirsch @ Zoetis Inc   Initial Version with selectByIdWithObservations
* 1.1   04-10-2023   Ethan Hirsch @ Zoetis Inc   Update selectByIdWithObservations to return Coachee__r.LanguageLocaleKey
* 1.2   16-10-2023   Neeraj Rautela @Deloitte    Added previousBenchmarkId method to fetch previous benchmark of the coachee
*/
public inherited sharing class BenchmarksSelector {
    /**
* Selects Benchmarks and includes the related Observations
* @param benchmarkIds 
* @return  `List<Benchmark__c>`
*/
    public static List<Benchmark__c> selectByIdWithObservations(Set<Id> benchmarkIds) {
        return [
            SELECT Id, Type__c, Self_Observation_Required__c, Coachee__c, Coachee__r.Name, Owner.Name, Coachee__r.LanguageLocaleKey, CreatedDate,
            (SELECT Id, Type__c FROM Observations__r) 
            FROM Benchmark__c
            WHERE Id in: benchmarkIds
        ];
    }
       
    /*
   * Selects Previous Benchmarks 
   * @param coacheeId 
   * @return  `benchmark`
   */
    public static Benchmark__c selectPreviousBenchmark(String currentBenchmarkId, String coacheeId, DateTime createdDate) {
        for(Benchmark__c benchmark : [
            SELECT Id
            FROM Benchmark__c
            WHERE Type__c = 'Coach' 
            AND Status__c = 'Completed' 
            AND  Id != :currentBenchmarkId 
            AND Coachee__c = :coacheeId
            AND CreatedDate <= :createdDate
            ORDER BY CreatedDate DESC LIMIT 1
        ]){
            return benchmark;
        }
        return null;
    }
    
}