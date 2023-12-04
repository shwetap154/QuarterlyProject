/******************************************************************************************************************************************
 * Class Name   : EventInviteeListController
 * Description  : Controller class for Event Invitee actions ans buttons
 * Created By   : Slalom/Art Smorodin
 * Created Date : 1 May 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin(Slalom)     05/01/2020          Created.
 *****************************************************************************************************************************************/
public with sharing class EventInviteeListController {

    public List<ZTS_US_Event_Invitee__c> selInviteeLst;
    public String invitIds;
    public String eventId;

    public EventInviteeListController(ApexPages.StandardSetController cntlr){
        //Getting list of ids from records selected in the list view 
        selInviteeLst = cntlr.getSelected();
        invitIds = '';  
        for(ZTS_US_Event_Invitee__c invt : selInviteeLst){
            invitIds += invt.Id + ',';            
        }
        invitIds = invitIds.removeEnd(','); 
        String retURL  = ApexPages.CurrentPage().getparameters().get('vfRetURLInSFX');
        if(retURL != null && retURL.contains('o/ZTS_US_Event_Invitee__c/list')){
            //this means button was clicked from the Tab/List view for this object
            //in this case redirect should be taken back to the list view
            eventId = null;
        }
        else {
            //this means that button was clicked from the Event record page related list 
            // and redirect should be taken to this Event record 
            eventId  = ApexPages.CurrentPage().getparameters().get('id');
        }
        System.debug(eventId);
    } 

    public PageReference redirectToLC(){
        String pageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');
        //Redirecting to AURA component and pass list of ids as a parameter 
        String returnUrl = '/lightning/cmp/c__InviteeProcessListView?c__listofInvitees='+invitIds+'&c__pageName='+pageName+'&c__eventId='+eventId;
        PageReference pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }

    @AuraEnabled(cacheable=true)
    public static List<ZTS_US_Event_Invitee__c> getRecords(String idList) {
        Set<Id> updatedIdList = new Set<Id>(); 
        if(idList.contains(',')){

            List<String> getList= new List<String>(idList.split(','));
            for (String newID :getList){
                updatedIdList.add(Id.valueOf(newID));
            }
        }
        else updatedIdList.add(Id.valueOf(idList));

        return [
            SELECT Id,ZTS_US_Invitation_Status__c,ZTS_US_Event__c
            FROM ZTS_US_Event_Invitee__c
            WHERE Id =:updatedIdList
        ];
    }
}