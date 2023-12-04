/**
 * @description       : Main Query class for Skill
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 02-07-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
**/
/*
Modification Log:
----------------------------------------------------------------------------
Developer            Date        Description
Sibin KUriaksoe    03-14-2023    Added selectBySkillList method to get Skill by Competency
Pranav Raut        07-19-2023    Added method selectSkillsByCompetencyWithCurrentUserTranslations to get Skills and its Data Translation based on Competencies 
sweta kumari       11-09-2023     Added selectSkillsByCometencyWithCurrentUserTranslationsObjective method to get Skills
----------------------------------------------------------------------------
*/

public with sharing class SkillsSelector {
    /**
     * @description this methode will select Skillsfor all the Competencies Passed 
     * @author Sibin KUriaksoe @ Zoetis Inc | 03-14-2023 
     * @param CompetencyList
	*/    
    public Static List<Skill__c> selectBySkillList(List<Competency__c> records){
        List<Skill__c> lstSkill = [
            SELECT Name, Name__c, Learning_Description__c, Applying_Description__c,Mastery_Description__c,Competency__c
            FROM Skill__c WHERE Competency__c  = :records AND Status__c = 'Active' ORDER BY Order__c ASC];
        
        return lstSkill;
    }
    
        /**
     * @Description : This method will select Skills and its Data Translation based on Competencies 
     * @Author      : Pranav Raut @ Zoetis Inc | 07-19-2023 
     * @Param       : CompetencyList
	*/    
    public Static List<Skill__c> selectSkillsByCompetencyWithCurrentUserTranslations(Set<Id> setCompetencyIds, String UserLanguage){
        return [SELECT Id,Name__c,Competency__c,Competency__r.Name,Order__c,
                (SELECT Id,Competency__c,Language__c,Name__c,Skill__c FROM Data_Translations__r WHERE Language__c =: UserLanguage) 
                FROM Skill__c
                WHERE Competency__c IN : setCompetencyIds AND Status__c = 'Active' ORDER BY Competency__r.Order__c,Order__c ASC
               ];         
    }
    
         /**
     * @Description : This method will select Skills 
     * @Author      : Sweta Kumari @ Zoetis Inc | 11-09-2023 
     * @Param       : CompetencyList
	*/   
    
    public static List<Skill__c> selectSkillsByCometencyWithCurrentUserTranslationsObjective(String competencyId)
    {
        List<Skill__c> skillsList = [SELECT Id,Name, Name__c, Learning_Description__c, Applying_Description__c,Mastery_Description__c,Competency__c
                                        FROM Skill__c where Competency__c =:competencyId];
           return skillsList ;
           
        
    }
}