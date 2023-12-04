/****************************************************************************************************************************************** 
* Class Name       : USZTS_US_AddNewContactRedirect
* Description      : The class is used to do the following 
1. Redirect to add New contact Record

* Created By   : Mounica NVS
* Created Date : Feb 17th, 2021
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------------------------
* Mounica               17/02/2021          Added New Contact creation logic for SC-006387 for creation of new contact and add that contact as Invitee
* Aritra(Cognizant)     29/11/2021          Added new Methods to show matching contact results table on screen and also allow users to select from those 
*                      						matching contacts list if there is a duplicate detected while saving contact record. (SC-008149)
* Prasun (Cognizant)    04/06/2023          TPDEV-320 Modified the code to handle duplicate contact selection according to new duplicate rule (FirstName+LastName+Colleague Entered Email)
***********************************************************************************************************************************************************/

public with sharing class USZTS_US_AddNewContactRedirect {
    public Boolean isContactCreation {get;set;}
    public Contact objCon {get;set;}
    List<ID> listAccID {get;set;}   
    List<ID> listContactId {get;set;}
    Public Integer size{get;set;} 
    public ZTS_Events__c currentEventsRecord    {get;set;}
    public string strAccountId{get;set;} 
    public boolean showFirstSaveSection{get;set;}
    public boolean showDupSaveSection{get;set;}
    public List<Contact> duplicateContactDetails{get;set;}
    public String selectedContactId{get;set;}
    
    public List<contact> selectcon{get;set;}
    public List<contactWrap> allContactsWrap{get;set;}
    public Map<String,Contact> allContactsMap{get;set;}
    
    public USZTS_US_AddNewContactRedirect(){  
        isContactCreation = false; 
        objCon = new Contact();
        duplicateContactDetails = new List<Contact>();
        allContactsWrap = new List<contactWrap>();
        allContactsMap = new Map<String,Contact>();
        showFirstSaveSection = true;
        showDupSaveSection = false;
    }
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                
                size = 1000; 
                listAccID = new List<ID>();
                listContactId = new List<ID>();
                String eventId = ApexPages.currentPage().getParameters().get('eventId');
                system.debug('eventId_Con__' + eventId);
                if(eventId != null && eventId != ''){
                    currentEventsRecord = [select Name,ZTS_US_Name__c from ZTS_Events__c where Id=: eventId AND ZTS_EU_Market__c = 'United States'];
                }
                for(ZTS_US_Event_Account__c evntAcc: [select ZTS_US_Event_Account__c from ZTS_US_Event_Account__c where ZTS_US_Events__c=: eventId]){
                    listAccID.add(evntAcc.ZTS_US_Event_Account__c);
                }
                for(ZTS_US_Event_Invitee__c evntInvitee : [select ZTS_US_Contact__c, ZTS_US_Event__c from ZTS_US_Event_Invitee__c 
                                                           where ZTS_US_Event__c =: eventId
                                                           AND ZTS_EU_Market__c = 'United States']){
                                                               listContactId.add(evntInvitee.ZTS_US_Contact__c);                                                   
                                                           }
                
                con = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Name,FirstName,LastName,ZTS_US_Job_Function__c,ZTS_US_Degree__c,AccountId,Account.Name,ZTS_US_Profession__c,Phone,Interface_Email__c,ZTS_EU_Contact_Status__c FROM Contact where ZTS_EU_Contact_Status__c!='Inactive' and AccountId IN: listAccID and ID NOT IN: listContactId AND ZTS_EU_Market__c = 'United States' order by FirstName])); // by sohil DEF-001535 added order by name // AccountId field in query added by Mounica for SC-006387
                
                con.setPageSize(size); 
            }
            return con;
        }
        set;
    }
    public PageReference cancel(){
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        PageReference page = new PageReference('/'+eventId);
        page.setRedirect(true);
        return page;
    }
    
    public List<SelectOption> getAllAccountbyEvent(){
        List<SelectOption> lstAccOptions = new List<SelectOption>();
        for(ZTS_US_Event_Account__c getAccDetails:[SELECT id,ZTS_US_Event_Account__c,ZTS_US_Event_Account__r.Name  FROM ZTS_US_Event_Account__c WHERE ZTS_US_Events__c=:ApexPages.currentPage().getParameters().get('eventId') ]){
            lstAccOptions.add(new SelectOption(getAccDetails.ZTS_US_Event_Account__c,getAccDetails.ZTS_US_Event_Account__r.Name));
        }
        return lstAccOptions;
    }
    //Aritra Changed this method code to show matching Contacts in screen if duplicates detected during contact save(SC-008149)
    public PageReference customSaveContact(){  
        List<Id> listDuplicateIds = new List<id>();
        try{
            objCon.AccountId = strAccountId;
            Database.SaveResult sr = Database.insert(objCon, false);
            //If error occurred while insert
            if (!sr.isSuccess()) {
                Datacloud.DuplicateResult duplicateResult;
                for(Database.Error duplicateError : sr.getErrors()){
                    duplicateResult = ((Database.DuplicateError)duplicateError).getDuplicateResult();
                }
                //If the error is duplicate detected error
                if(duplicateResult.getMatchResults().size()>0)
                {
                    showFirstSaveSection = false;
                    showDupSaveSection = true;
                    for(Datacloud.MatchResult duplicateMatchResult : duplicateResult.getMatchResults()) {
                        for(Datacloud.MatchRecord duplicateMatchRecord : duplicateMatchResult.getMatchRecords()) {
                            listDuplicateIds.add(duplicateMatchRecord.getRecord().Id);
                        }
                    }
                    system.debug('listDuplicateIds ->'+listDuplicateIds);
                    
                    getDupContactDetails(listDuplicateIds);
                }
            }
            //If there is no error while inserting the contact
            //Then add event invitee with the contact created
            else{
                String eventId = ApexPages.currentPage().getParameters().get('eventId');
                ZTS_US_Event_Invitee__c evntInvt = new ZTS_US_Event_Invitee__c();
                evntInvt.ZTS_US_Contact__c = objCon.Id;
                evntInvt.ZTS_US_Event__c = eventId;
                insert evntInvt;           
                PageReference page = new PageReference('/'+eventId);
                page.setRedirect(true);
                return page;
            }         
        }catch(Exception e){
            System.debug('Error occured....'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            
        }
        return null;
    }
    //Aritra Changed this method code if to save contact if user confirms to create duplicate contact even after showing matching records(SC-008149)
    public PageReference saveDuplicateContact(){  
        try{
            String cId= CreateDuplicateRecordUtil.createDuplicateRecord(JSON.serialize(objCon, false),'Contact');
            system.debug('cId ->' + cId);
            if(cId != 'ERROR')
            {
                String eventId = ApexPages.currentPage().getParameters().get('eventId');
                ZTS_US_Event_Invitee__c evntInvt = new ZTS_US_Event_Invitee__c();
                evntInvt.ZTS_US_Contact__c = Id.valueOf(cId);
                evntInvt.ZTS_US_Event__c = eventId;
                insert evntInvt;
                
                PageReference page = new PageReference('/'+eventId);
                page.setRedirect(true);
                System.debug('i am here inside try'+ page);
                return page;
            }
        }
        catch(Exception e)
        {
            System.debug('Error occured....'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            
        }
        return null;
    }
    public PageReference customCancelContact(){  
        isContactCreation = false;
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        PageReference page = new PageReference('/'+eventId);
        page.setRedirect(true);
        return page;
    }
    //Aritra created this method code to show matching contact details if duplicates detected during contact creation(SC-008149)
    public void getDupContactDetails(List<Id> selectedIds) {
        //system.debug('I am fetching duplicate details');
        //duplicateContactDetails = [Select Id, Name, Account_Name__c, Full_Contact_Name__c, Interface_Email__c, Phone,ZTS_US_Profession__c,ZTS_US_Job_Function__c from Contact where id in :selectedIds];
        for(Contact c:[Select Id, Name, Account_Name__c, Full_Contact_Name__c, Interface_Email__c, Phone,ZTS_US_Profession__c,ZTS_US_Job_Function__c,ZTS_EU_Contact_Status__c from Contact where id in :selectedIds] ){
            allContactsWrap.add(new contactWrap(false,c));
            allContactsMap.put(c.Id,c);
        }
    }
    
    public void disableCheckbox()
    {
        //iterate over your wrapper and set isSelected false except selected one
        for(contactWrap c: allContactsWrap)
        {
            if(c.con.Id == selectedContactId && c.isSelected){
                
            }
            else{
                c.isSelected = false;
            }
        }
    }
    
    //Aritra created this method to associate the selected contact from the matching records' list (SC-008149)
    public PageReference associateSelectedCon()
    {
        try{
            List<String> listConID = new List<String>();
            Integer countSelectedContact=0;
            for (contactWrap cw : allContactsWrap) {
                if (cw.isSelected == true){
                    selectedContactId = cw.con.Id;
                    countSelectedContact ++;
                }
            }
            
            if(countSelectedContact!= 0)
            {
                CreateDuplicateRecordUtil.createAffiliation(Id.valueOf(selectedContactId), strAccountId); // Added as part of TPDEV-320
                String eventId = ApexPages.currentPage().getParameters().get('eventId');
                ZTS_US_Event_Invitee__c evntInvt = new ZTS_US_Event_Invitee__c();
                evntInvt.ZTS_US_Contact__c = Id.valueOf(selectedContactId);
                evntInvt.ZTS_US_Event__c = eventId;
                insert evntInvt;
                
                PageReference page = new PageReference('/'+eventId);
                page.setRedirect(true);
                
                return page;
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a contact from the list of existing')); 
                return null;
            }
        }
        catch(Exception e)
        {
            System.debug('Error occured....'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            
        }
        return null;
        
    }
    
    public List<contactWrap> getAllContacts()
    {            
        return allContactsWrap;
    }
    
    //Wrapper class to show list of matching contacts in the datatable along with respective checkbox 
    public class contactWrap{
        public boolean isSelected {get;set;}
        public contact con {get;set;}
        public contactWrap(boolean s,contact c){
            isSelected = s;
            con = c;
        }
    }
    
    
}