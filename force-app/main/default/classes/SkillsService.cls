/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 02-10-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   02-10-2023   Padma Nerella @ Zoetis Inc  Added blockSkillCreationWhenCompetencyHasLessonTemplate method to 
                                                 Block Addition of Skills to Competencies which already contain 
                                                 Lesson Templates TPdev-164
**/
public with sharing class SkillsService {
    

    /**
     * @description this methode will not allowed to add a Skill to a Competency if that Competency already has related Lesson Templates
     * @author Padma Nerella @ Zoetis Inc | 02-10-2023 
     * @param skilltriggerNew 
     */
    public static void blockSkillCreationWhenCompetencyHasLessonTemplates(List<Skill__c> skilltriggerNew) {
        
        List<Skill__c> skillList = new List<Skill__c>();
        List<Competency__c> competencyListwithLessonTemplate = new List<Competency__c>();
        Set<Id> compentencyIdSet = New Set<Id>();
        final String Cannot_Insert_Skillrecord = System.Label.Cannot_Insert_Skill;
        if(skilltriggerNew !=null){
            for(Skill__c skill : skilltriggerNew){
                if(skill.Competency__c != null){
                    compentencyIdSet.add(skill.Competency__c);                    
                }
            }
        }
        
        competencyListwithLessonTemplate = CompetenciesSelector.selectCompetencyListwithLessonTemplate(compentencyIdSet); 

        Set<Id> competencySetwithLessonTemplate = new Map<Id, Competency__c>(competencyListwithLessonTemplate ).keySet();
       
        for(Skill__c skill : skilltriggerNew){
            if(competencySetwithLessonTemplate.contains(skill.Competency__c)){
                skill.Competency__c.addError(Cannot_Insert_Skillrecord);
            }
        }
        
    }
    
}