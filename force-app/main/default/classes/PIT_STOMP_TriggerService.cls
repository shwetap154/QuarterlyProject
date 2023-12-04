public without sharing class PIT_STOMP_TriggerService {

    public static void setOwnerManager(List<PIT_STOMP__c> stompList) {
        Set<Id> owners = new Set<Id>();
        
        for(PIT_STOMP__c stomp : stompList) {
            owners.add(stomp.OwnerId);
        }
        
        Map<id, User> idToUserMap = new Map<id, User>([SELECT id, ManagerId FROM User WHERE id in: owners AND ZTS_EU_Market__c = 'United States']);
        
        for(PIT_STOMP__c stomp : stompList) {
            stomp.PIT_Owner_Manager__c = idToUserMap.get(stomp.OwnerId).ManagerId;
        }
    }
  
}