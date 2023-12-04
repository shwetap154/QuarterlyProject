/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 11-06-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modification Log:
----------------------------------------------------------------------------
Developer			Date		Description
Padma Nerella		11-06-2023	Edit methods to CreateEditActionPlan and return the values to JS in LWC
----------------------------------------------------------------------------
**/
public class CreateEditActionPlanController {
    
    @testVisible private static Boolean forceExceptionToRecieveActionPlanId = false;
    @AuraEnabled(cacheable=true)
    public static list<Action_Plan__c> getActionPlanById(Id actionplanId) {
        List<Action_Plan__c> returnActionPlanDisplayList = new List<Action_Plan__c>();
        Set<Id> iCoachFormIdSet = new Set<Id>();
        try{
            if(forceExceptionToRecieveActionPlanId){
                integer y = 1 / 0;
            }
            if(actionplanId != null){
                Set<Id> actionplanIdSet = new Set<Id>{actionplanId};
                Action_Plan__c actionplan = ActionPlanSelector.selectById(actionplanIdSet);
                iCoachFormIdSet.add(actionplan.iCoach_Form__r.Id);
            }
            list<Action_Plan__c> actionplanListToDisplay = ActionPlanSelector.selectyByiCoachFormId(iCoachFormIdSet);
            return actionplanListToDisplay;
        }catch(Exception e){
            Logger.error('Exception occurred in retrieving Action Plan List to display: ' + e.getMessage());
            return null;
        }
        
    }
    
    @AuraEnabled
    public static Map<ID, List<ContentDocument>> getRelatedFilesByRecordId(list<Id> recordIds) {
        System.debug('getRelatedFilesByRecordId'+recordIds);
        List<ContentDocumentLink> files = ContentDocumentLinksSelector.selectContentDocumentById(recordIds);
        Set<ID> fileIDs = new Set<ID>();
        map<Id,List<ContentDocument>> fileByLinkedEntityMap = new map<Id,List<ContentDocument>>();
        for(Id recordId : recordIds){
            fileByLinkedEntityMap.put(recordId,new List<ContentDocument>());
        }
        for (ContentDocumentLink docLink : files) {
            fileByLinkedEntityMap.get(docLink.LinkedEntityId).add(docLink.ContentDocument);
        }
        return fileByLinkedEntityMap;
    }
    @testVisible private static Boolean forceExceptionToFailRequest = false;
    @AuraEnabled
    public static String updateActionPlanRecords(String jsonString){
        try{
            if(forceExceptionToFailRequest){
                integer y = 1 / 0;
            }
            if(jsonString != null ){
                System.debug(jsonString);
                List<WrapperClass> mapData = (List<WrapperClass>)JSON.deserialize(jsonString,List<WrapperClass>.class);
                System.debug(mapData);
                List<Action_Plan__c> accPlanList=new List<Action_Plan__c>();
                for(WrapperClass obj : mapData){
                    System.debug(obj.id);
                    Action_Plan__c accPlanObj=new Action_Plan__c();
                    accPlanObj.Id=obj.id;
                    accPlanObj.Action__c=obj.value;
                    accPlanObj.To_Be_Completed__c=obj.dateValue;
                    accPlanList.add(accPlanObj);
                }
                if(!accPlanList.isEmpty()){
                    update accPlanList;
                }
            }
        }catch(Exception e){
            Logger.error('Exception occurred in updating action plan fields Action and To Be Completed: ' + e.getMessage());
            return 'error';
        }
        return 'success';
    }
    public class WrapperClass {
        public String id;
        public String value;
        public Date dateValue;
    }
}