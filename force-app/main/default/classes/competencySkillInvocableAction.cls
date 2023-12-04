/**
* Class Name	     : competencySkillInvocableAction
* @description       : Invocable class for retrive the coachee's applicable Competency and Its related Skills which are not scored on Benchmark
* @author            : Pranav Raut @ Zoetis Inc
* @last modified on  : 06-28-2023
* @last modified by  : Pranav Raut @ Zoetis Inc

* Modification Log:
----------------------------------------------------------------------------
Ver  Developer		  Date		    Description
01   Pranav Raut	  06-28-2023	Added getCompetenceSkillDetails method to get Competencies & Skill to return it to the iDevelop - Complete Benchmark flow
----------------------------------------------------------------------------
**/
public with sharing class competencySkillInvocableAction {    
    /**
* @description : This methode is being used in the iDevelop - Complete Benchmark flow to get all the unscored competencies and skills
* @author      : Pranav Raut @ Zoetis Inc | 06-28-2023 
* @param       : BenchmarkList
*/
    @InvocableMethod(label='Get Competencies & Its related Skills' description='Returns the list of competency & Name' category='Competency__c')
    public static List<ReturnVariables> getCompetenceSkillDetails(List<InputVariables> inputVariables) {
        
        List<Benchmark__c> lstBenchmark = new List<Benchmark__c>();
        Map<Id,Benchmark__c> mapBenchmarkToComplete = new Map<Id,Benchmark__c>();
        List<ReturnVariables> returnVarsList = new List<ReturnVariables>();
        ReturnVariables result = new ReturnVariables();
        
        if(inputVariables.get(0).BenchmarkList != Null){
            //Inputs from flow
            lstBenchmark.add(inputVariables.get(0).BenchmarkList);            
        }
        
        //Get all applicable Competencies based on Benchmark Market and Role 
        List<Competency__c> lstNotScoredCompetency = new List<Competency__c>();
        Map<id,List<Competency__c>> mapCompetencyWithBenchmark = BenchmarksService.getUnscocredCompetencies(lstBenchmark);
        if(!mapCompetencyWithBenchmark.isEmpty()){
            for(Id objId : mapCompetencyWithBenchmark.keySet()){
                lstNotScoredCompetency.addall(mapCompetencyWithBenchmark.get(objId));
            }  
        }
        
        String allSkillName = '';  
        if(!lstNotScoredCompetency.isEmpty()){
            result.outputCollection = lstNotScoredCompetency;
            returnVarsList.add(result);            
        }
        
        if(returnVarsList != null && !returnVarsList.isEmpty()){
            return returnVarsList;
        }
        else{
            return null;
        }        
    }
    
    public class InputVariables{        
        @InvocableVariable
        public Benchmark__c BenchmarkList;
    }     
    public class ReturnVariables{        
        @InvocableVariable
        public List<Competency__c> outputCollection;
    }  
    
}