/**
* File Name     :  GetSkillsIdsAction
* @description  :  Gets the Ids form the input skill so the Bot can utilize Skills Based Routing
* @author       :  Christopher Hale @ Slalom
* Modification Log
===================================================================================================
* Ver.  Date        Author              	    Modification
---------------------------------------------------------------------------------------------------
* 1.0   09/23/2022	Christopher Hale @ Slalom	Created the Class.
**/
public with sharing class GetSkillsIdsAction {
    @InvocableMethod(label='Get Skills Id Based on Friendly Name' description='Return Id of Skill') 
    public static List<List<Id>> getSkillId(List<BotInput> botInputList) {
        //Get list of skill name from input we want to target for routing
        Set<String> pertinentSkillNames = new Set<String>();
        for (BotInput botInput : botInputList) {
            pertinentSkillNames.add(botInput.skillName);
        }
                
        //Get the Skill Ids for routing
        List<Skill> desiredSkillIdList = [SELECT Id FROM Skill WHERE MasterLabel IN :pertinentSkillNames];

        //Place the returned Skill Ids in a list
        List<Id> skillsIds = new List<Id>();
        for(Skill skill: desiredSkillIdList) {
            skillsIds.add(skill.Id);
        }
        
        return new List<List<Id>> {skillsIds};
    }

    public class BotInput {
        @InvocableVariable(required=false)
        public String skillName;
    }
}