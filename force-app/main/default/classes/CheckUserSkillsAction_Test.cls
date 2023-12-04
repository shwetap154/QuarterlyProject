/**
* File Name     :  CheckUserSkillsAction_Test
* @description  :  Tests that someone with the correct/incorrect profile is/is not assigned the Zoey Chatbot CS Skill
* @author       :  Christopher Hale @ Slalom
* Modification Log
---------------------------------------------------------------------------------------------------
* Ver.  Date        Author              	    Modification
---------------------------------------------------------------------------------------------------
* 1.0   10/25/2022	Christopher Hale @ Slalom	Created the Class.
**/
@isTest
public class CheckUserSkillsAction_Test {
    @isTest
    public static void UserHasSkill() {
        //Get User with Rx Service Profile and Online Service Presence
        User rxServiceUser = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'Rx Service' LIMIT 1];
        ServicePresenceStatus sps = [SELECT Id FROM ServicePresenceStatus WHERE MasterLabel = 'Online' LIMIT 1];
        Skill skill = [SELECT Id FROM Skill WHERE MasterLabel = 'Zoey Chatbot CS' LIMIT 1];

        //Create a new USP
        UserServicePresence usp = new UserServicePresence();
        usp.UserId = rxServiceUser.Id;
        usp.ServicePresenceStatusId = sps.Id;
        insert usp;

        //Create the retrieved user as a service resource
        ServiceResource sr = new ServiceResource();
        sr.Name = rxServiceUser.Id;
        sr.IsActive = true;
        sr.RelatedRecordId = rxServiceUser.Id;
        sr.ResourceType = 'A';
        insert sr;

        //Assign the chatbot skill to the service resource
        ServiceResourceSkill srs = new ServiceResourceSkill();
        srs.ServiceResourceId = sr.Id;
        srs.SkillId = skill.Id;
        srs.SkillLevel = 2;
        srs.EffectiveStartDate = Datetime.now();
        insert srs;

        //Build the inputs
        List<UserServicePresence> uspList = new List<UserServicePresence>();
        uspList.add(usp);

        List<CheckUserSkillsAction.Inputs> inputList = new List<CheckUserSkillsAction.Inputs>();
        CheckUserSkillsAction.Inputs input = new CheckUserSkillsAction.Inputs();
        input.onlineUSPList = uspList;
        input.skillMasterLabel = 'Zoey Chatbot CS';
        inputList.add(input);

        //Run the logic to see if the PIU is assigned the skill
        List<CheckUserSkillsAction.Outputs> outputList = CheckUserSkillsAction.isUserAssociatedToSkill(inputList);
        CheckUserSkillsAction.Outputs output = outputList[0];

        System.assertEquals(true, output.isSkillAssigned);
    }

    @isTest
    public static void UserDoesNotHaveSkill() {
        //Get User with Rx Service Profile and Online Service Presence
        User rxServiceUser = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'Rx Service' LIMIT 1];
        ServicePresenceStatus sps = [SELECT Id FROM ServicePresenceStatus WHERE MasterLabel = 'Online' LIMIT 1];
        Skill skill = [SELECT Id FROM Skill WHERE MasterLabel = 'Zoey Chatbot CS' LIMIT 1];

        //Create a new USP
        UserServicePresence usp = new UserServicePresence();
        usp.UserId = rxServiceUser.Id;
        usp.ServicePresenceStatusId = sps.Id;
        insert usp;

        //Create the retrieved user as a service resource
        ServiceResource sr = new ServiceResource();
        sr.Name = rxServiceUser.Id;
        sr.IsActive = true;
        sr.RelatedRecordId = rxServiceUser.Id;
        sr.ResourceType = 'A';
        insert sr;

        //Build the inputs
        List<UserServicePresence> uspList = new List<UserServicePresence>();
        uspList.add(usp);

        List<CheckUserSkillsAction.Inputs> inputList = new List<CheckUserSkillsAction.Inputs>();
        CheckUserSkillsAction.Inputs input = new CheckUserSkillsAction.Inputs();
        input.onlineUSPList = uspList;
        input.skillMasterLabel = 'Zoey Chatbot CS';
        inputList.add(input);

        //Run the logic to see if the PIU is assigned the skill
        List<CheckUserSkillsAction.Outputs> outputList = CheckUserSkillsAction.isUserAssociatedToSkill(inputList);
        CheckUserSkillsAction.Outputs output = outputList[0];

        System.assertEquals(false, output.isSkillAssigned);
    }

    @isTest
    public static void NothingPassedIn() {
        //Run the logic with nothing passed in
        List<CheckUserSkillsAction.Outputs> outputList = CheckUserSkillsAction.isUserAssociatedToSkill(null);
        CheckUserSkillsAction.Outputs output = outputList[0];

        System.assertEquals(false, output.isSkillAssigned);
    }

    @isTest
    public static void NoOneOnline() {
        List<CheckUserSkillsAction.Inputs> inputList = new List<CheckUserSkillsAction.Inputs>();
        CheckUserSkillsAction.Inputs input = new CheckUserSkillsAction.Inputs();
        input.onlineUSPList = null;
        input.skillMasterLabel = 'Zoey Chatbot CS';
        inputList.add(input);

        //Run the logic with no Users Online passed in
        List<CheckUserSkillsAction.Outputs> outputList = CheckUserSkillsAction.isUserAssociatedToSkill(inputList);
        CheckUserSkillsAction.Outputs output = outputList[0];

        System.assertEquals(false, output.isSkillAssigned);
    }

    @isTest
    public static void NoSkillProvided() {
        //Get User with System Admin Profile and Online Service Presence
        User rxServiceUser = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'Rx Service' LIMIT 1];
        ServicePresenceStatus sps = [SELECT Id FROM ServicePresenceStatus WHERE MasterLabel = 'Online' LIMIT 1];

        //Create a new USP
        UserServicePresence usp = new UserServicePresence();
        usp.UserId = rxServiceUser.Id;
        usp.ServicePresenceStatusId = sps.Id;
        insert usp;

        //Build the inputs
        List<UserServicePresence> uspList = new List<UserServicePresence>();
        uspList.add(usp);

        List<CheckUserSkillsAction.Inputs> inputList = new List<CheckUserSkillsAction.Inputs>();
        CheckUserSkillsAction.Inputs input = new CheckUserSkillsAction.Inputs();
        input.onlineUSPList = uspList;
        input.skillMasterLabel = null;
        inputList.add(input);

        //Run the logic with no Skill passed in
        List<CheckUserSkillsAction.Outputs> outputList = CheckUserSkillsAction.isUserAssociatedToSkill(inputList);
        CheckUserSkillsAction.Outputs output = outputList[0];

        System.assertEquals(false, output.isSkillAssigned);
    }
}