public with sharing class ZTS_EU_AccountSegmentThresholdService {

    public static void beforeInsert(List<Account_Segmentation_threshold__c> triggerNew){
        ZTS_EU_Account_Segmentation_Rating.validateRating(triggerNew, true, false);
    }

    public static void beforeUpdate(List<Account_Segmentation_threshold__c> triggerNew, Map<Id, Account_Segmentation_threshold__c> triggerOldMap){
        List<Account_Segmentation_threshold__c> triggerRecords = new List<Account_Segmentation_threshold__c>();
        for(Account_Segmentation_threshold__c ast : triggerNew){
            if(ast.ZTS_EU_Threshold_Maximum_Value_Potential__c != triggerOldMap.get(ast.Id).ZTS_EU_Threshold_Maximum_Value_Potential__c || ast.ZTS_EU_Threshold_Maximum_Value_Potential__c == null){
                triggerRecords.add(ast);
            }   
        }

        if(!triggerRecords.isEmpty()) {
            ZTS_EU_Account_Segmentation_Rating.validateRating(triggerRecords,false,true);
        }
    }

    public static void beforeDelete(List<Account_Segmentation_threshold__c> triggerOld){
        ZTS_EU_Account_Segmentation_Rating.validateRating(triggerOld, false, false);
    }
}