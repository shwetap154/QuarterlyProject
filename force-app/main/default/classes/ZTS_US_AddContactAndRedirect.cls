/****************************************************************************************************************************************** 
 * Class Name       : ZTS_US_AddContactAndRedirect 
 * Description      : The class is used to do the following 
                      1. Retrieve the selected accounts 
                      2. Add accounts to the event
                      3. Redirect to add contact page
                                    
 * Created By   : Deloitte Consulting
 * Created Date : May 5th, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sameep Agrawal           05/06/2014          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_US_AddContactAndRedirect 
{
    ZTS_Events__c currentEventsRecord;
    public ZTS_US_Event_Invitee__c eventCon     {get;set;}
    public String source                        {get;set;}
    
    public ZTS_US_AddContactAndRedirect (ApexPages.StandardController controller){
        currentEventsRecord = (ZTS_Events__c)controller.getRecord();
        source = '';
        if(ApexPages.currentPage().getParameters().containsKey('isError')/* && ApexPages.currentPage().getParameters().get('isError') == 'true'*/){
            system.debug('============isError: '+ ApexPages.currentPage().getParameters().get('isError'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The selected Contact(s) has already been added to the Event'));
        }
        eventCon = new ZTS_US_Event_Invitee__c();
    }
    
    /* This method is used to create association between Event and Contact depending on 
    *  whether association already exists between Event and Contact
    */
    public PageReference saveEventAccount(){
        List<ZTS_US_Event_Invitee__c> listEventInvitee = new List<ZTS_US_Event_Invitee__c>();
        List<String> listConID = new List<String>();
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        
        List<ZTS_Events__c> listEvents = [select Id from ZTS_Events__c where Id=: eventId AND ZTS_EU_Market__c != 'United States'];
        if(listEvents != null && listEvents.size() > 0){
            if(ApexPages.currentPage().getParameters().containsKey('records')){
                listConID = ApexPages.currentPage().getParameters().get('records').split(',');
                // Check for existing association. If it exists, then display error message to user
                List<ZTS_US_Event_Invitee__c> listExistingEvntInvitee = [select ZTS_US_Contact__c, ZTS_US_Event__c, ZTS_US_Invitation_Status__c from ZTS_US_Event_Invitee__c 
                                                                        where ZTS_US_Contact__c IN: listConID and ZTS_US_Event__c=: eventId
                                                                        AND ZTS_EU_Market__c != 'United States'];
                if(listExistingEvntInvitee != null && listExistingEvntInvitee.size() > 0){
                    PageReference pg = new PageReference('/apex/ZTS_US_Mass_Add_Contact?records='+ApexPages.currentPage().getParameters().get('records')+'&eventId='+
                                                            ApexPages.currentPage().getParameters().get('eventId')+'&isError=true');
                    return pg;
                }else{
                    for(String oAccId: listConID){
                        ZTS_US_Event_Invitee__c eventCon = new ZTS_US_Event_Invitee__c(ZTS_US_Contact__c= (ID)oAccId, ZTS_US_Event__c=eventId);
                        listEventInvitee.add(eventCon);
                    }
                    try{
                        if(listEventInvitee != null && listEventInvitee.size() > 0){
                            insert listEventInvitee;
                        }
                    }catch(Exception e){
                        return null;
                    }
                }
            }
        }else{
            return null;
        }
        return new PageReference('/'+eventId);
    }
}