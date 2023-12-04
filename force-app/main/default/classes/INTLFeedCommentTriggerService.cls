/****************************************************************************************************************************************** 
 ****************************************************************************************************************************************** 
 * Trigger Name : INTLFeedCommentTriggerService
 * Description  : Service class for FeedComment trigger.
 * Created By   : Alex Carstairs/Slalom 
 * Created Date : 7th December, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                        Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)        12/07/2020         Created
*****************************************************************************************************************************************/
public with sharing class INTLFeedCommentTriggerService {
    public static void beforeInsert(List<FeedComment> triggerNew) {
        Set<Id> parentid = new Set<Id>();   
        for(FeedComment fComm : triggerNew){
            parentid.add(fComm.ParentId);
        }

        Map<Id,Account> mpAccount = new Map<Id,Account>([SELECT Id, ZTS_EU_Market__c FROM Account WHERE ZTS_EU_Market__c = 'Poland' and Id IN : parentid]);       
        Map<Id,Contact> mpContact = new Map<Id,Contact>([SELECT Id, ZTS_EU_Market__c FROM Contact WHERE ZTS_EU_Market__c = 'Poland' and Id IN : parentid]);  

        for(FeedComment fC : triggerNew){
           if(mpAccount.containskey(fC.parentid) || mpContact.containskey(fC.parentid)){
                fC.addError('No free text comments allowed on this account/contact');
            }
        }
    }
}