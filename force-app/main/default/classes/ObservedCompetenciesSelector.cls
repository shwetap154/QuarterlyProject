/**
 * @description       : Selector Class for Observation Competency
 * @author            : Raut, Pranav Krushnarao @ Zoetis Inc
 * @group             : 
 * @last modified on  : 03-03-2023
 * @last modified by  : Hirsch, Ethan @ Zoetis Inc
 * Modification Log:
----------------------------------------------------------------------------
Developer           Date        Description
Raut, Pranav        03-02-2023  Added selectByBenchmarks method to get Observation Competency.
Hirsch, Ethan       03-03-2023  Added selectByObservations method to get Observed Competency
Sibin Kuriakose     05-05-2023  Added selectByListBenchmarks, selectByListObservedCompetecy & selectByObsCompCompIdSkillId method to get Observed Competency
----------------------------------------------------------------------------
**/
public inherited sharing class ObservedCompetenciesSelector {
    
   /**
     * @description : Method will select Observation Competency for the Benchmarks. 
     * @author      : Raut, Pranav @ Zoetis Inc | 03-02-2023 
     * @param       : Set<Id> setBenchmarksIds
    **/
    Public static List<Observed_Competency__c> selectByBenchmarks(Set<Id> setBenchmarksIds){
        List<Observed_Competency__c> lstObsCompetency = [SELECT Id,Competency__c,Score__c,Observation__c,Observation__r.Benchmark__c,Skill__c,Skill_Translation__c,
                                                         Observation__r.Benchmark__r.Market__c, Observation__r.Benchmark__r.Role__c,Observation__r.Type__c
                                                         FROM Observed_Competency__c 
                                                         WHERE Observation__r.Type__c =: System.Label.Observation_Type AND Observation__r.Benchmark__c IN : setBenchmarksIds];
        return lstObsCompetency;
    }

    /**
     * @description : Method will select Observed Competency for the Observations. 
     * @author      : Hirsch, Ethan @ Zoetis Inc | 03-02-2023 
     * @param observationIds 
     */
    public static List<Observed_Competency__c> selectByObservations(Set<Id> observationIds) {
        return [
            SELECT Id, Competency__c, Competency__r.Name, Competency__r.Competency_Model__c,
                   Competency__r.Competency_Model__r.Name, Skill__r.Name__c, Skill__c, Observation__r.Type__c,
                   Score__c, Competency_Translation__r.Name,Competency_Translation__r.Name__c, Skill_Translation__r.Name__c
            FROM Observed_Competency__c
            WHERE Observation__c in: observationIds];
    }

    /**
     * @description : Method will select Observation Competency for the List of Benchmarks. 
     * @author      : Sibin Kuriakose @ Zoetis Inc | 05-05-2023 
     * @param       : List<Benchmark> lstBenchmark
    **/
    public static List<Observed_Competency__c> selectByListBenchmarks(List<Benchmark__c> lstBenchmark){
        List<Observed_Competency__c> lstobscomp = [SELECT Id,Competency__c,Skill__c,Competency_Translation__r.Name__c,Skill_Translation__r.Name__c,
                                                  Skill__r.Name__c,Competency__r.Name FROM Observed_Competency__c WHERE Observation__r.Benchmark__c = :lstBenchmark];
        return lstobscomp;
    }

    /**
     * @description : Method will select Observation Competency for the List of Observation Competencies. 
     * @author      : Sibin Kuriakose @ Zoetis Inc | 05-05-2023 
     * @param       : List<Observed_Competency__c> lstObscomprecords
    **/
    public static List<Observed_Competency__c> selectByListObservedCompetecy(List<Observed_Competency__c> lstObscomprecords){
        List<Observed_Competency__c> lstobscomp = [SELECT Id,Competency_Translation__r.Name__c,Skill_Translation__r.Name__c,Skill__r.Name__c,Competency__r.Name,Observation__r.Benchmark__c
                                                  FROM Observed_Competency__c WHERE Id = :lstObscomprecords];
        return lstobscomp;
    }

    /**
     * @description : Method will select Observation Competency for the List of Observation Competencies with Competency and skills. 
     * @author      : Sibin Kuriakose @ Zoetis Inc | 05-05-2023 
     * @param       : List<Observed_Competency__c> lstObscomprecords
    **/
    public static List<Observed_Competency__c> selectByObsCompCompIdSkillId(List<Observed_Competency__c> lstObscomprecords, List<Id> lstcomps, List<Id> lstskill){
        List<Observed_Competency__c> lstobscomp = [SELECT Id,Competency__c,Skill__c FROM Observed_Competency__c WHERE Id = :lstObscomprecords AND 
                                                  (Competency__c = :lstcomps OR Skill__c = :lstskill)];
  
        return lstobscomp;
    }
}