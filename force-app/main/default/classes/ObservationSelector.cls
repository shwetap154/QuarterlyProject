/**
 * Selector class for Observations * @author sai saranya siruvuri @ Deloitte
 * @since 22-06-2023
 * Modifications Log
 * Ver   Date         Author                      Modifications
 * ---------------------------------------------------------------------------  
 * 1.0   06-26-2023   sai saranya siruvuri        Created Class to retreive data from observation Object As part of TPDEV-1213
 */
public inherited sharing class ObservationSelector {
    /**
     * Selects Observations with BenchmarkIds
     * @param benchmarkIds 
     * @return  `List<Observations>`
     */
    public static List<Observation__c> selectByBenchmarkId(Set<Id> benchmarkIds) {
        return [
            SELECT Id,Comments__c,CreatedDate, Type__c from Observation__c  WHERE Benchmark__r.Id = :benchmarkIds
        ];
    }
}