/**
* @description       : Test class for ActionPlanSelector
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 11-27-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   11-27-2023   Padma Nerella @ Zoetis Inc  Initial Version
**/
@isTest
private class ActionPlanSelectorTest {
    
    @testSetup
    private static void setup(){
        
        iCoach_Form__c icoachForm = TestDataFactory.createiCoachFormRec();
        insert icoachForm;
        
        List<Competency_Model__c> competencyModels = TestDataFactory.createCompetencyModels(2);
        insert competencyModels;
        
        List<Competency__c> competencies = TestDataFactory.createCompetencies(2, competencyModels[0].Id);
        insert competencies;
        
        List<iCoach_Form_Objective__c> iCoachFormObjectListToInsert = TestDataFactory.createiCoachFormObjectives(2,icoachForm.id,competencyModels,competencies);
        insert iCoachFormObjectListToInsert;
        //Action Plan records creates automatically when iCoachFormObjectives created
    }
    
    @isTest
    private static void selectByIdTest(){
        //Action Plan records creates automatically when iCoachFormObjectives created
        List<Action_Plan__c> actionplan = [Select id from Action_Plan__c limit 1];
        Set<Id> actionPlanIdSet =  new Set<id>{actionplan[0].Id};
        test.StartTest();
        Action_Plan__c actionplanretrieved = ActionPlanSelector.selectById(actionPlanIdSet);
        Test.stopTest();
        Assert.areEqual(actionplan[0].Id,actionplanretrieved.Id,'Same Action Plan record retrieved');
        
    }
    
    @istest
    private static void selectyByiCoachFormIdTest(){
        List<iCoach_Form__c> icoachFromlist = [Select Id from iCoach_Form__c];
        Set<Id> icoachFormIdSet = new Set<Id>{icoachFromlist[0].Id};
        List<Action_Plan__c> actionplanList = [Select id,iCoach_Form__c from Action_Plan__c where iCoach_Form__c =:icoachFromlist[0].Id];
        Test.Starttest();
        list<Action_Plan__c> actionplanListRetrieved = ActionPlanSelector.selectyByiCoachFormId(icoachFormIdSet);
        Test.Stoptest();
        Assert.areEqual(actionplanList.size(),actionplanListRetrieved.size(),'two Action plan records are retrived');
    }

}