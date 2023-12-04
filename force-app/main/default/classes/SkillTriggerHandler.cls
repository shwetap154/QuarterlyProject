/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 02-10-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   2-13-2023    Padma Nerella @ Zoetis Inc  Added SkillsService.blockSkillCreationWhenCompetencyHasLessonTemplates
                                                 in before insert method to Block Addition of Skills to Competencies which 
                                                 already contain Lesson Templates TPdev-164
**/
public with sharing class SkillTriggerHandler extends TriggerHandler {
   
    
    public override void beforeInsert() {
        
        //TPdev-164 Block Addition of Skills to Competencies which already contain Lesson Templates  
        SkillsService.blockSkillCreationWhenCompetencyHasLessonTemplates(trigger.new);
    
    }
    
}