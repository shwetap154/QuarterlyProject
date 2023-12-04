/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 11-06-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modification Log:
----------------------------------------------------------------------------
Developer			Date		Description
Padma Nerella		11-06-2023	Retrieve Action plan recod by Id
Padma Nerella		11-27-2023	Retrieve Action plan recods by iCoachFormId
----------------------------------------------------------------------------
**/
public class ActionPlanSelector {

    public static Action_Plan__c selectById(Set<Id> actionPlanId){
        Action_Plan__c actPlan = [SELECT Id, iCoach_Form__r.Id FROM Action_Plan__c WHERE Id =:actionPlanId];
        return actPlan;
    }
    
    public static List<Action_Plan__c> selectyByiCoachFormId(Set<Id> icoachFormId){
        list<Action_Plan__c> actionplanList = [SELECT  Id,Name,iCoach_Form__c, iCoach_Form__r.Status__c, Action__c,To_Be_Completed__c, Competency__c, Skill__c, Rating__c From Action_Plan__c WHERE iCoach_Form__c =:icoachFormId];
        return actionplanList;
    }
}