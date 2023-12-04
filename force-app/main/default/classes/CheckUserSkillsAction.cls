/**
* File Name     :  CheckUserSkillsAction
* @description  :  Take inputs of UserServicePrecense and checks if the User or their profile is assigned to an input Skill
* @author       :  Christopher Hale @ Slalom
* Modification Log
---------------------------------------------------------------------------------------------------
* Ver.  Date        Author              	    Modification
---------------------------------------------------------------------------------------------------
* 1.0   10/25/2022	Christopher Hale @ Slalom	Created the Class.
* 1.1   10/31/2022  Christopher Hale @ Slalom   Modified class to check Service Resource Skills instead of Skill User/Skill Profile 
**/
public class CheckUserSkillsAction {
    @InvocableMethod(label='Is User assigned this Skill?' description='Inputs: "Online" Users | Skill - Output: User is assigned Skill?')
    public static List<Outputs> isUserAssociatedToSkill(List<Inputs> inputList) {
        List<Outputs> outputList = new List<Outputs>();
        Outputs output = new Outputs();

        //No inputs provided, stop execution
        if(inputList == null) { 
            output.isSkillAssigned = false;
            outputList.add(output);
            return outputList;
        }

        Inputs input = inputList[0];

        //No inputs provided, stop execution
        if(input.onlineUSPList == null) { 
            output.isSkillAssigned = false;
            outputList.add(output);
            return outputList;
        }
        if(String.isBlank(input.skillMasterLabel)) { 
            output.isSkillAssigned = false;
            outputList.add(output);
            return outputList;
        }

        //Assign inputs
        List<SObject> uspList = input.onlineUSPList;
        String skillName = input.skillMasterLabel;

        //Get Ids for query to find assigned skills for these users
        Set<Id> userIdSet = new Set<Id>();
        for(SObject usp : uspList) {
            userIdSet.add((Id)usp.get('UserId'));
        }

        //Get the Service Resource records for the Users
        List<ServiceResource> serviceResourceList = [
            SELECT Id, RelatedRecordId 
            FROM ServiceResource
            WHERE IsActive = true AND RelatedRecordId IN :userIdSet
        ];

        Datetime now = Datetime.now();
        //Get the effective assigned Skills for the retrieved Service Resources
        List<ServiceResourceSkill> serviceResourceSkillList = [
            SELECT Id 
            FROM ServiceResourceSkill 
            WHERE ServiceResourceId IN :serviceResourceList 
            AND Skill.MasterLabel = :skillName 
            AND (EffectiveEndDate = null OR EffectiveEndDate > :now)
        ];

        //Check if the skill is assigned to an "Online" user
        if(serviceResourceSkillList != null && serviceResourceSkillList.size() > 0) { 
            output.isSkillAssigned = true;
            outputList.add(output);
            return outputList;
        } else {
            output.isSkillAssigned = false;
            outputList.add(output);
            return outputList;
        }       
    }

    //Custom class required to input multiple parameters to an InvoccableMethod
    public class Inputs {
        @InvocableVariable(required=false)
        public List<SObject> onlineUSPList;
        @InvocableVariable(required=false)
        public String skillMasterLabel;
    }

    //Custom class required to output parameters from an InvoccableMethod
    public class Outputs {
        @InvocableVariable(required=false)
        public Boolean isSkillAssigned;
    }
}