/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 02-07-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Ver   Date         Author                      Modification
 * 1.0   2-13-2023    Padma Nerella @ Zoetis Inc  Added SkillTriggerHandler method
**/
trigger SkillTrigger on Skill__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    new SkillTriggerHandler().run();

}