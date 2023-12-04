/**
Class Name      : BenchmarksService
Description     : Service Class created as part of TPDEV-422 for the Benchmarks object. 
Created By      : Raut, Pranav Krushnarao
Created Date    : 02-28-2023

Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer                    Date         Description
-------------------------------------------------------------------------------------------------------------------------
01   Raut, Pranav Krushnarao    02-28-2023   Added Methods to throw an error when user tries to complete benchmark if not all Competencies have been rated or the Self-Observation is not completed
02   Raut, Pranav Krushnarao    05-22-2023   Added code to handle the bulkification of Competency Group Assignments having same competency group but diffrent Competency Model.
03   Raut, Pranav Krushnarao    06-30-2023   Added code to display Error with the competencies which are not rated.
04   Kalyan Nayak               07-14-2023   Added getUnscocredCompetencies method to get competencies which are not rated.
*/
public With Sharing class BenchmarksService {
/**     
* @Description : As part of TPDEV-422 this method will throw an error when user tries to complete benchmark if not all Competencies have been rated or the Self-Observation is not completed        
* @Author      : Raut, Pranav Krushnarao @ Zoetis Inc | 02-28-2023
*/
    public static void benchmarkMarkCompleteValidations(Map<Id,Benchmark__c> mapNewBenchmarks, Map<Id,Benchmark__c> mapOldBenchmarks) {  
        
        Map<Id,Benchmark__c> mapBenchmarkToComplete = new Map<Id,Benchmark__c>(); 
        
        for(Benchmark__c objBenchmark : mapNewBenchmarks.values()){
            if(objBenchmark.Status__c != null && mapOldBenchmarks.get(objBenchmark.Id).Status__c != objBenchmark.Status__c && objBenchmark.Status__c == System.Label.Completed_Benchmark_Status && objBenchmark.Market__c != null ){
                mapBenchmarkToComplete.put(objBenchmark.Id, objBenchmark);                      
            }                
        }
        
        Map<Id,Boolean> mapBenchmark = new Map<Id,Boolean>();
        for(Benchmark__c objBench : BenchmarksSelector.selectByIdWithObservations(mapBenchmarkToComplete.keySet())){
            If(!objBench.Observations__r.IsEmpty()){
                mapBenchmark.put(objBench.Id, True); 
            }
            else{
                mapBenchmark.put(objBench.Id, False); 
            } 
        }
        
        //Get Unscored Competency on Benchmark 
        Map<id,List<Competency__c>> mapBenIdAndUnscoredCom = getUnscocredCompetencies(mapBenchmarkToComplete.values());
        
        //Show Error for each Benchmark
        String allCompetencyName = '';
        for(Benchmark__c objBenchmark : mapBenchmarkToComplete.values()){
            if(mapBenIdAndUnscoredCom.containsKey(objBenchmark.Id)){
                Integer i = 1;
                for(Competency__c objCom : mapBenIdAndUnscoredCom.get(objBenchmark.Id)){
                    allCompetencyName = allCompetencyName + i+'. '+objCom.Name +  '\n';
                    i++;
                } 
            }
            
            if(mapBenchmark.get(objBenchmark.Id) == True && 
               ((mapBenIdAndUnscoredCom.containsKey(objBenchmark.Id) && !mapBenIdAndUnscoredCom.get(objBenchmark.Id).isEmpty()) ||
                (objBenchmark.Self_Observation_Required__c == true && objBenchmark.Self_Observation_Complete__c == false))
              ){
                  objBenchmark.addError(System.Label.Completed_Benchmark_Validations_Error_Message + '\n' +
                                        System.Label.The_following_Competencies_and_Skills_are_not_rated + '\n' +                                        
                                        allCompetencyName);            
              }
            else if(mapBenchmark.get(objBenchmark.Id) == False && mapBenIdAndUnscoredCom.containsKey(objBenchmark.Id) ){
                objBenchmark.addError(System.Label.Completed_Benchmark_Validations_Error_Message + '\n' +
                                      System.Label.The_following_Competencies_and_Skills_are_not_rated + '\n' +                                        
                                      allCompetencyName);  
            }
        }                   
    }
    
/*
* @description : This method to get unscored competency on Benchmark
* @author      : Kalyan Nayak @ Zoetis Inc | 07-14-2023 
* @param       : List<Benchmark__c>
*/    
    public static Map<id,List<Competency__c>> getUnscocredCompetencies(List<Benchmark__c> lstBenchmark){
        Map<Id,Competency__c> mapAllCompetencies = new Map<Id,Competency__c>(); 
        Map<Id,Benchmark__c> mapBenchmarkToComplete = new Map<Id,Benchmark__c>(lstBenchmark);
        Map<id,List<Competency__c>> mapBenchmarkWithCompetency = new Map<id,List<Competency__c>>();
        mapBenchmarkWithCompetency = CompetenciesService.getCompetenceList(lstBenchmark);
        
        Map<Id,Set<Id>> mapBenchMarkCompetencyIds = new Map<Id,Set<Id>>();
        Set<Id> setCompetenciesIdonObsCom = new Set<Id>(); 
        
        //Map of Scored Competencies on Benchmark
        List<Observed_Competency__c> lstObsCompetency = ObservedCompetenciesSelector.selectByBenchmarks(mapBenchmarkToComplete.keySet());
        if(lstObsCompetency != null && !lstObsCompetency.isEmpty()){
            for(Observed_Competency__c objObsCompetency : lstObsCompetency){                                
                Id benchmarkId = objObsCompetency.Observation__r.Benchmark__c;
                if (!mapBenchMarkCompetencyIds.containsKey(benchmarkId)) {
                    mapBenchMarkCompetencyIds.put(benchmarkId, new Set<Id>());
                }
                if(objObsCompetency.Observation__r.Type__c == System.Label.Observation_Type){
                    mapBenchMarkCompetencyIds.get(benchmarkId).add(objObsCompetency.Competency__c);                        
                }                
            }            
        }
        
        //Comparing unscored Competencies list with scored competencies List
        Map<id,List<Competency__c>> mapBenIdAndUnscoredCom = new Map<id,List<Competency__c>>();
        for(Id objB : mapBenchmarkWithCompetency.keySet()){
            if(mapBenchMarkCompetencyIds.containsKey(objB)){
                List<Competency__c> lstNotScoredCompetency = new List<Competency__c>();
                for(Competency__c objComp : mapBenchmarkWithCompetency.get(objB))
                {
                    if(!mapBenchmarkCompetencyIds.get(objB).contains(objComp.Id)){
                        lstNotScoredCompetency.add(objComp);
                    }
                }  
                mapBenIdAndUnscoredCom.put(objB,lstNotScoredCompetency);
            }else{
                mapBenIdAndUnscoredCom.put(objB,mapBenchmarkWithCompetency.get(objB));
            }
        } 
        return mapBenIdAndUnscoredCom;
    }  
}