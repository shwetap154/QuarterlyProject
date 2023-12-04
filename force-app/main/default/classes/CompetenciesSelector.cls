/**
* @description       : Selector class for Competency
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 02-10-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   02-10-2023   Padma Nerella @ Zoetis Inc  TPdev-164 Block Addition of Skills to Competencies which already contain Lesson Templates
* 2.0	02-16-2023	 Kalyan Nayak @ Zoetis Inc	 TPDEV-58 Core Competency Skills
* 3.0	02-16-2023	 Pranav Raut @ Zoetis Inc	 TPDEV-1176 Added the method to retriveretrive the competencies based on Competency Id
* 4.0   11-09-2023   sweta kumari @ Zoetis Inc    Added selectedCompetencyiCoachFormObjective method to get competencies 
**/
public inherited sharing class CompetenciesSelector{
    
    /**
     * @description this methode will select the competencies with lesson template
     * @author Padma Nerella @ Zoetis Inc | 02-10-2023 
     * @param CompetencyId
     */
    public static List<Competency__c> selectCompetencyListwithLessonTemplate(set<Id> CompetencyId){

       List<Competency__c> competencyList = [Select Id from Competency__c where Id in(Select Competency__c from Lesson_Template__c  where Competency__c In:CompetencyId) AND Status__c = 'Active'];
        return competencyList;
    }
    
    /**
     * @description :This method will select the competencies based on set of Competency Model Ids
     * @author      :Raut, Pranav Krushnarao @ Zoetis Inc | 02-10-2023 
     * @param       :set of Competency Model Ids
     */
    Public Static List<Competency__c> selectByCompetencyModelSet(Set<Id> comModelId){
        List<Competency__c> lstCompetency = [SELECT Id, Name,Order__c, Competency_Model__c,(Select Id,Order__c, Name__c From Skills__r WHERE Status__c = 'Active' ORDER BY Order__c ASC) FROM Competency__c WHERE Competency_Model__c IN: comModelId AND Status__c = 'Active' ORDER BY Competency_Model__c, Order__c ASC];
        return lstCompetency;
    }
    
    /**
     * @description :This method will select the competencies based on List of Competency
     * @author      :Sibin Kuriakose @ Zoetis Inc | 02-10-2023 
     * @param       :List of Competencies
     */
    public Static List<Competency__c> selectByCompetencyList(List<Competency__c> records){
        
        List<Competency__c> lstCompetency = [
            SELECT Name, Learning_Description__c, Applying_Description__c,Mastery_Description__c,Skill_Count__c
            FROM Competency__c WHERE Id = :records ORDER BY Competency_Model__c, Order__c ASC];
        
        	return lstCompetency;
    }
    
      /**
     * @description :This method will retrive the competencies based on Competency Id
     * @author      :Pranav Raut @ Zoetis Inc | 06-30-2023 
     * @param       :List of Competencies
     */
    public Static List<Competency__c> selectByCompetencyId(Set<Id> CompIds){
        
        List<Competency__c> lstCompetency = [
            SELECT Name, Learning_Description__c, Applying_Description__c,Mastery_Description__c,Skill_Count__c
            FROM Competency__c WHERE Id IN :CompIds ORDER BY Competency_Model__c, Order__c ASC];
        
        	return lstCompetency;
    }
    
    
      /**
     * @description :This method will retrive the competency
     * @author      :Sweta Kumari @ Zoetis Inc | 11-09-2023 
     * @param       :List of Competencies
     */
    public Static List<Competency__c> selectCompetencyiCoachFormObjective(Set<Id> competencyModelId){
            List<Competency__c> competencyList = [SELECT Id,Name,Learning_Description__c,Applying_Description__c,Mastery_Description__c, Competency_Model__c
                                                   FROM Competency__c WHERE Competency_Model__c IN :competencyModelId];  
              return competencyList;
       
         
    }
    
    
}