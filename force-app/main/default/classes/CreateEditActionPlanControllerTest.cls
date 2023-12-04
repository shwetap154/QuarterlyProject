/**
 * @description       : Test class for CreateEditActionPlanControlle class
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 11-14-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                          Modification
 * 1.0   11-14-2023   Padma Nerella @ Zoetis Inc      
**/
@isTest
private class CreateEditActionPlanControllerTest {
    
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
    
    @istest
    private static void getActionPlanByIdTest(){
        List<Action_Plan__c> actionPlanList = [Select Id, iCoach_Form__c from Action_Plan__c];
        
        Test.StartTest();
        List<Action_Plan__c> actionPlanListRetrieved = CreateEditActionPlanController.getActionPlanById(actionPlanList[0].Id);
        Test.StopTest();
        
        Assert.areEqual(actionPlanList.size(),actionPlanListRetrieved.size(),'Two Action plan records are retived to display');
    }
    
    @istest
    private static void getRelatedFilesByRecordIdTest(){
        List<Action_Plan__c> actionPlanList = [Select Id, iCoach_Form__c from Action_Plan__c];
        list<Id> recordIds = new list<Id>();
        String Title = 'Test';
        
        map<Id,List<ContentDocument>> fileByLinkedEntityMap1 = new map<Id,List<ContentDocument>>();
        for(Action_Plan__c actionId:actionPlanList){
            recordIds.add(actionId.Id);
        }
        
        ContentVersion actionPlanFile1 = new ContentVersion(
            Title = Title,
            PathOnClient = Title,
            VersionData = EncodingUtil.base64Decode('ABC'),
            origin = 'H'
        );
        
        insert actionPlanFile1;
        
        insert new ContentDocumentLink(
            LInkedEntityId = actionPlanList[0].Id,
            ContentDocumentId = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id =: actionPlanFile1.Id LIMIT 1].ContentDocumentId
        );
        ContentVersion actionPlanFile2 = new ContentVersion(
            Title = Title,
            PathOnClient = Title,
            VersionData = EncodingUtil.base64Decode('ABC'),
            origin = 'H'
        );
        
        insert actionPlanFile2;
        
        insert new ContentDocumentLink(
            LInkedEntityId = actionPlanList[1].Id,
            ContentDocumentId = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id =: actionPlanFile2.Id LIMIT 1].ContentDocumentId
        );
        List<ContentDocumentLink> insertContentDocumentLinkList = [Select Id,LInkedEntityId,ContentDocumentId from ContentDocumentLink where LInkedEntityId IN:recordIds];
        Test.Starttest();
        Map<ID, List<ContentDocument>> contentDocumentwithLinkedEntityMap = CreateEditActionPlanController.getRelatedFilesByRecordId(recordIds);
        Test.StopTest();
        
        Assert.areEqual(insertContentDocumentLinkList.size(),contentDocumentwithLinkedEntityMap.values().size());
        
    }
    
    @isTest
    private static void updateActionPlanRecordsTest(){
        List<Action_Plan__c> actionPlanList = [Select Id, iCoach_Form__c,Action__c,To_Be_Completed__c from Action_Plan__c];
        List<Action_Plan__c> updateActionPlanList = new List<Action_Plan__c>();
        
        actionPlanList[0].Action__c='Test1';
        actionPlanList[0].To_Be_Completed__c = System.Today();
        actionPlanList[1].Action__c='Test2';
        actionPlanList[1].To_Be_Completed__c = System.Today()+1;
        updateActionPlanList.add(actionPlanList[0]);
        updateActionPlanList.add(actionPlanList[1]);
        String json = JSON.serialize(updateactionPlanList);
        Test.Starttest();
        CreateEditActionPlanController.updateActionPlanRecords(json);
        Test.StopTest();
        List<Action_Plan__c> latestActionPlanList = [Select Id, iCoach_Form__c,Action__c,To_Be_Completed__c from Action_Plan__c where Id IN:updateActionPlanList];
        
        Assert.areEqual(actionPlanList.size(),latestActionPlanList.size(),'Equal amount of records retrieved');
        for(Action_Plan__c actionPlanData: latestActionPlanList){
            if(actionPlanData.Action__c=='Test1'){
                Assert.areEqual('Test1',actionPlanList[0].Action__c,'ActionPlan 1st record updated Action field successfully');
            } else{
                Assert.areEqual('Test2',actionPlanList[1].Action__c,'ActionPlan 2nd record updated Action field successfully');
            }
        }
        
    }
    @isTest
    private static void updateActionPlanRecordsForceExceptionTest(){
        List<Action_Plan__c> actionPlanList = [Select Id, iCoach_Form__c,Action__c,To_Be_Completed__c from Action_Plan__c];
        List<Action_Plan__c> updateActionPlanList = new List<Action_Plan__c>();
        
        actionPlanList[0].Action__c='Test1';
        actionPlanList[0].To_Be_Completed__c = System.Today();
        actionPlanList[1].Action__c='Test2';
        actionPlanList[1].To_Be_Completed__c = System.Today()+1;
        updateActionPlanList.add(actionPlanList[0]);
        updateActionPlanList.add(actionPlanList[1]);
        String json = JSON.serialize(updateactionPlanList);
        CreateEditActionPlanController.forceExceptionToFailRequest = true;
        Test.Starttest();
        CreateEditActionPlanController.updateActionPlanRecords(json);
        Test.StopTest();
        List<Action_Plan__c> latestActionPlanList = [Select Id, iCoach_Form__c,Action__c,To_Be_Completed__c from Action_Plan__c where Id IN:updateActionPlanList];
        for(Action_Plan__c actionPlanData: latestActionPlanList){
            if(actionPlanData.Action__c=='Test1'){
                Assert.areEqual('Test1',actionPlanList[0].Action__c,'Exception ocurred ActionPlan 1st record did not updated Action field successfully');
            } else{
                Assert.areEqual('Test2',actionPlanList[1].Action__c,'Exception ocurred ActionPlan 2nd record did not updated Action field successfully');
            }
        }
    }
   @istest
    private static void getActionPlanByIdForceExpectionTest(){
        List<Action_Plan__c> actionPlanList = [Select Id, iCoach_Form__c from Action_Plan__c];
        CreateEditActionPlanController.forceExceptionToRecieveActionPlanId = true;
        Test.StartTest();
        CreateEditActionPlanController.getActionPlanById(actionPlanList[0].Id);
        Test.StopTest();
        List<Action_Plan__c> returnActionPlanList = [Select Id, iCoach_Form__c from Action_Plan__c where Id=:actionPlanList[0].Id];
        Assert.areNotEqual(0,returnActionPlanList.size(),'Exception ocurred in receiving Action plan records to display');
    }
}