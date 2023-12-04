public with sharing class CustomInviteeLWCController {
    @AuraEnabled(cacheable=true)
    public static List<ZTS_US_Event_Invitee__c> getRecords(String test) {
        Set<Id> updatedIdList = new Set<Id>(); 
        if(test.contains(',')){

            List<String> getList= new List<String>(test.split(','));
            for (String newID :getList){
                updatedIdList.add(Id.valueOf(newID));
            }
        }
        else updatedIdList.add(Id.valueOf(test));

        return [
            SELECT Id,ZTS_US_Invitation_Status__c
            FROM ZTS_US_Event_Invitee__c
            WHERE Id =:updatedIdList
        ];
    }
}