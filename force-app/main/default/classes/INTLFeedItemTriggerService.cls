/****************************************************************************************************************************************** 
 * Trigger Name : FeedItemTriggerHandler
 * Description  : All Dispatch Trigger Logic for FeedItem object.
 * Created By   : Slalom(Alex Carstairs) 
 * Created Date : 7th December, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs           12/07/2020         Created 
*****************************************************************************************************************************************/
public with sharing class INTLFeedItemTriggerService {
    public static void beforeInsert(List<FeedItem> triggerNew) {
        Set<Id> parentid = new Set<Id>();   
        for(FeedItem fItem : triggerNew){
            parentid.add(fItem.ParentId);
        }
        
        Map<Id,Account> mpAccount = new Map<Id,Account>([SELECT Id, ZTS_EU_Market__c FROM Account WHERE ZTS_EU_Market__c = 'Poland' and Id IN : parentid]);       
        Map<Id,Contact> mpContact = new Map<Id,Contact>([SELECT Id, ZTS_EU_Market__c FROM Contact WHERE ZTS_EU_Market__c = 'Poland' and Id IN : parentid]);       
        for(FeedItem fI : triggerNew){
            if(mpAccount.containskey(fI.parentid) || mpContact.containskey(fI.parentid)){
                fI.addError('No free text comments allowed on this account/contact');
            }
        }
    }
}