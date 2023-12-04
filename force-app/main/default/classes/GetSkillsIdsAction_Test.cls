/**
* File Name     :  GetSkillsIdsAction_Test
* @description  :  Tests that a skill is returned from the Apex Action GetSkillsIdsAction
* @author       :  Christopher Hale @ Slalom
* Modification Log
===================================================================================================
* Ver.  Date        Author              	    Modification
---------------------------------------------------------------------------------------------------
* 1.0   09/23/2022	Christopher Hale @ Slalom	Created the Class.
**/
@isTest
private class GetSkillsIdsAction_Test {
    private static testMethod void getSkillIdFromSkillName() {
        //Set up input of skill to pass in to the Apex Action
        List<GetSkillsIdsAction.BotInput> biList = new List<GetSkillsIdsAction.BotInput>();
        GetSkillsIdsAction.BotInput bi = new GetSkillsIdsAction.BotInput();
        bi.skillName = 'Zoetisus';
        biList.add(bi);

        List<List<Id>> skillIdListList = GetSkillsIdsAction.getSkillId(biList);

        Boolean isSkillReturned = false;
        if(skillIdListList != null) {
            isSkillReturned = (skillIdListList[0] != null);
        }

        System.assert(isSkillReturned, 'Skill was returned using the skillName: ' + bi.skillName);
    }
}