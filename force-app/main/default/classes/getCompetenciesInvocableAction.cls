/**
* @description       : 
* @author            : Kalyan Nayak @ Zoetis Inc
* @group             : 
* @last modified on  : 02-16-2023
* @last modified by  : Kalyan Nayak @ Zoetis Inc
* Modification Log:
----------------------------------------------------------------------------
Developer			Date		Description
Kalyan Nayak		02-16-2023	Added getCompetenceDetails method to get Competencies and return it to the iDevelop - Select Competencies flow
----------------------------------------------------------------------------
**/
public with sharing class getCompetenciesInvocableAction {

    /**
     * @description this methode is being used in the iDevelop - Select Competencies flow to get all the competencies
     * @author Kalyan Nayak @ Zoetis Inc | 02-16-2023 
     * @param BenchmarkList
     */
    @InvocableMethod(label='Get Competencies' description='Returns the list of competency Name' category='Competency__c')
    public static List<ReturnVariables> getCompetenceDetails(List<InputVariables> inputVariables) {
        
        List<ReturnVariables> returnVarsList = new List<ReturnVariables>();
        ReturnVariables result = new ReturnVariables();
        
        if(inputVariables.get(0).BenchmarkList != Null){
            //get the inputs
            List<Benchmark__c> listBenchmark = new List<Benchmark__c>();
            listBenchmark.add(inputVariables.get(0).BenchmarkList);
            
            List<Competency__c> lstCompetency = new List<Competency__c>();
            Map<id,List<Competency__c>> mapCompetencyWithBenchmark = new Map<id,List<Competency__c>>(CompetenciesService.getCompetenceList(listBenchmark));
            if(!mapCompetencyWithBenchmark.isEmpty()){
                for(Id objId : mapCompetencyWithBenchmark.keySet()){
                    lstCompetency.addall(mapCompetencyWithBenchmark.get(objId));
                }
                
                result.outputCollection = lstCompetency;
                returnVarsList.add(result);
            } 
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