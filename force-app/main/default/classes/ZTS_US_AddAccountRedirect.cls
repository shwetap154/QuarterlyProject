/****************************************************************************************************************************************** 
 * Class Name       : ZTS_US_AddAccountRedirect
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
public with sharing class ZTS_US_AddAccountRedirect 
{
    ZTS_Events__c currentEventsRecord;
    public ZTS_US_Event_Account__c eventAcc     {get;set;}
    public String source                        {get;set;}
    
    public ZTS_US_AddAccountRedirect(ApexPages.StandardController controller){
        currentEventsRecord = (ZTS_Events__c)controller.getRecord();
        source = '';
        if(ApexPages.currentPage().getParameters().containsKey('isError')/* && ApexPages.currentPage().getParameters().get('isError') == 'true'*/){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The selected Contact(s) has already been added to the Event'));
        }
        eventAcc = new ZTS_US_Event_Account__c();
    }
    
    /* This method is used to create junction object between Event and Account 
    *  depending on whether the association already exists or not
    */
    public PageReference saveEventAccount(){
        System.debug('saveEventAccount  started::: ');
        List<String> listAccID = new List<String>();
        List<ZTS_US_Event_Account__c> listEventAccount = new List<ZTS_US_Event_Account__c>();
        String eventId = '';
        if(ApexPages.currentPage().getParameters().containsKey('eventId')){
            eventId = ApexPages.currentPage().getParameters().get('eventId');
            
            List<ZTS_Events__c> listEvents = [select Id from ZTS_Events__c where Id=: eventId];
            if(listEvents != null && listEvents.size() > 0){
                if(ApexPages.currentPage().getParameters().containsKey('records')){
                    listAccID = ApexPages.currentPage().getParameters().get('records').split(',');
                    /* Check if there are existing Event Account records. If so, do not insert the records and show an error message to the user */
                    List<ZTS_US_Event_Account__c> listExistingEvntAcc = [select ZTS_US_Event_Account__c, ZTS_US_Events__c from ZTS_US_Event_Account__c 
                                                                            where ZTS_US_Event_Account__c IN: listAccID and ZTS_US_Events__c=: eventId];
                    if(listExistingEvntAcc != null && listExistingEvntAcc.size() > 0){
                        PageReference pg = new PageReference('/apex/ZTS_US_Mass_Add_Account?records='+ApexPages.currentPage().getParameters().get('records')+'&eventId='+
                                                                ApexPages.currentPage().getParameters().get('eventId')+'&isError=true');
                        return pg;
                    }else{
                        for(String oAccId: listAccID){
                            ZTS_US_Event_Account__c eventAcc = new ZTS_US_Event_Account__c(ZTS_US_Event_Account__c= (ID)oAccId, ZTS_US_Events__c=eventId);
                            listEventAccount.add(eventAcc);
                        }
                        try{
                            if(listEventAccount != null && listEventAccount.size() > 0){
                                insert listEventAccount;
                            }
                            /* If the origin is from Account list page, redirect back to the list view page */
                            if(source == 'account'){
                                PageReference pg = new PageReference('/001');
                                pg.setRedirect(true);
                                return pg;
                            }
                        }catch(Exception e){
                            return null;
                        }
                    }
                }
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'We were unable to add Account to selected Event.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            return new PageReference('/'+eventId);
        }else{
            return null;
        }   
    }
    
    /* This method is used to assign event id parameter to the current page 
    */
    public PageReference fetchIDAndSave(){
        ApexPages.currentPage().getParameters().put('eventId', eventAcc.ZTS_US_Events__c);
        return saveEventAccount();
    }
}