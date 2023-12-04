/*************************************************************************************
* Name          :    ContactAttendeeCleanupBatch
* Description   :    Batch class to update RecentCallers field on Contact based on Call Owner
* Author        :    Shiva Kudikilla(Cognizant)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
Jul 12, 2018     Shiva Kudikilla(Cognizant)         Created

**************************************************************************************/
global class ContactAttendeeCleanupBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    { 
        return Database.getQueryLocator([SELECT ID,ZTS_EU_call__c, ZTS_EU_call__r.ZTS_EU_Call_Owner__c, ZTS_EU_Contact__c,CREATEDDATE FROM Attendee__c WHERE CreatedDate = THIS_YEAR AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States']);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Attendee__c> attendees) {
        Map<Id, List<Id>> callIdToContactsIdList = new Map<Id, List<Id>>();
        Map<Id, Id> callToOwnerMap = new Map<Id, Id>();
        Set<Id> contactIds = new Set<Id>();
        
        for(Attendee__c at : attendees){
            if(callIdToContactsIdList.get(at.ZTS_EU_call__c) == null){
                callIdToContactsIdList.put(at.ZTS_EU_call__c, new List<Id>());
            }
            List<Id> contIdList = callIdToContactsIdList.get(at.ZTS_EU_call__c);
            contIdList.add(at.ZTS_EU_Contact__c);
            contactIds.add(at.ZTS_EU_Contact__c);
            callIdToContactsIdList.put(at.ZTS_EU_call__c, contIdList);
            callToOwnerMap.put(at.ZTS_EU_call__c, at.ZTS_EU_call__r.ZTS_EU_Call_Owner__c);
        }
        Map<Id,Contact> contactsToUpdateMap = new Map<Id, Contact>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, RecentCallers__c from Contact where Id in :contactIds AND ZTS_EU_Market__c = 'United States']);
        For(Id callid: callIdToContactsIdList.keySet()){
            for(Id contid: callIdToContactsIdList.get(callid)){
                Contact contact = null;
                if(contactsToUpdateMap.get(contid) == null){
                    contact = contactMap.get(contid);
                }else{
                    contact = contactsToUpdateMap.get(contid);    
                }
                Id callOwner = callToOwnerMap.get(callid);
                if(contact.RecentCallers__c == null){
                    contact.RecentCallers__c = '';
                }
                if(contact.RecentCallers__c != null && contact.RecentCallers__c.length() <= 235 && !contact.RecentCallers__c.contains(callOwner)){
                    contact.RecentCallers__c = contact.RecentCallers__c + ';' + callOwner;
                    contactsToUpdateMap.put(contact.Id, contact);
                }
            }
            
        }
        
        System.debug('...all call map...' + callIdToContactsIdList);
        System.debug('...all call Owner map...' + callToOwnerMap);
        System.debug('...final contacts...' + contactsToUpdateMap.values());
        
        if(contactsToUpdateMap.values() != null && contactsToUpdateMap.values().size() > 0){
            try{ 
                Database.update(contactsToUpdateMap.values(), false); 
            }catch(Exception ex){
                System.debug('Exception updating RecentCallers field on Contacts');
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('All contacts updated successfully with userIds in RecentCallers field');
    }
}