/****************************************************************************************************************************************** 
 * Class Name       : USZTS_US_AddContactRedirect
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
 * Sohil shah(Cloud Sense)  12/03/2014          Added code for DEF-DEF-001535 (Sorting purpose)
 * Sohil Shah(Cloud Sense)  7/8/2015            Added Page Size + Search logic for DEF-001663 
*****************************************************************************************************************************************/
public with sharing class USZTS_US_AddContactRedirect 
{
    public ZTS_Events__c currentEventsRecord    {get;set;}
    List<ContactWrapper> categories             {get;set;}              
    private String sortDirection = 'ASC';
    private String sortExp = 'c.con.FirstName';
    List<ID> listAccID {get;set;}   
    List<ID> listContactId {get;set;}
    public String name {get; set;} // by Sohil - DEF-001663
    Public Integer size{get;set;} // by Sohil - DEF-001663
    public String searchStr;
    public string sortFullExp;
    public List<ContactWrapper> wrapContactList {get; set;}


    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                 
                 size = 1000; // by Sohil - DEF-001663
                listAccID = new List<ID>();
                listContactId = new List<ID>();
                String eventId = ApexPages.currentPage().getParameters().get('eventId');
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
                    [SELECT Name,FirstName,LastName,ZTS_US_Job_Function__c,ZTS_US_Degree__c,Account.Name,ZTS_US_Profession__c,Phone,Interface_Email__c FROM Contact where ZTS_EU_Contact_Status__c!='Inactive' and AccountId IN: listAccID and ID NOT IN: listContactId AND ZTS_EU_Market__c = 'United States' order by FirstName])); // by sohil DEF-001535 added order by name 
                    
                     con.setPageSize(size); // by Sohil - DEF-001663
            }
            return con;
        }
        set;
    }
    /* By Sohil - DEF-001663
    * action method to search for contacts whose Name,Account Name contains the entered text
    */
    public PageReference executeSearch()
    {
      
        searchStr='%' + String.valueOf(name) + '%';
        string status = 'Inactive';
        System.debug('sortFullExp----'+sortFullExp);
        if(sortFullExp == null)
        {
            con = new ApexPages.StandardSetController(Database.getQueryLocator(
            [SELECT Name,FirstName,LastName,ZTS_US_Job_Function__c,ZTS_US_Degree__c,Account.Name,ZTS_US_Profession__c,Phone,Interface_Email__c FROM Contact where ZTS_EU_Contact_Status__c!='Inactive' and AccountId IN: listAccID and ID NOT IN: listContactId and ((FirstName LIKE :searchStr) OR (LastName LIKE : searchStr) OR (Account.Name LIKE : searchStr)) AND ZTS_EU_Market__c = 'United States' order by FirstName]));               
        }
        else
        {
            con = new ApexPages.StandardSetController(Database.Query(
            'SELECT Name,FirstName,LastName,ZTS_US_Job_Function__c,ZTS_US_Degree__c,Account.Name,ZTS_US_Profession__c,Phone,Interface_Email__c FROM Contact where ZTS_EU_Contact_Status__c!=:status and AccountId IN: listAccID and ID NOT IN: listContactId and ((FirstName LIKE :searchStr) OR (LastName LIKE : searchStr) OR (Account.Name LIKE : searchStr)) AND ZTS_EU_Market__c = \'United States\' order by ' + sortFullExp));             
        }
        
        con.setPageSize(size);
        return null;
    } // EOC by Sohil Shah DEF -001663

    // Initialize con and return a list of records
    public List<Contact> getContacts() {
        return (List<Contact>) con.getRecords();
    }
    
    /* Method Name  : saveContacts
    *  Description  : This method is used to save the selected contacts and create junction between Contact and Event
    *  Return type  : PageReference
    *  Parameters   : None
    */
    public PageReference saveContacts(){
        List<ZTS_US_Event_Invitee__c> listEventInvitee = new List<ZTS_US_Event_Invitee__c>();
        List<String> listConID = new List<String>();
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        System.debug('categories----'+categories);
        System.debug('categories Size----'+categories.Size());
        for (ContactWrapper cw : categories) {
            if (cw.checked == true){
                listConID.add(cw.con.Id);
            }
        }
        System.debug('listConID----'+listConID);
        List<ZTS_US_Event_Invitee__c> listExistingEvntCon = [select ZTS_US_Contact__c, ZTS_US_Event__c from ZTS_US_Event_Invitee__c 
                                                                    where ZTS_US_Contact__c IN: listConID and ZTS_US_Event__c =: eventId AND ZTS_EU_Market__c = 'United States'];
        if(listExistingEvntCon != null && listExistingEvntCon.size() > 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The selected Contact(s) has already been added to the Event'));
        }else{
            for(String oConId: listConID){
                ZTS_US_Event_Invitee__c eventInv = new ZTS_US_Event_Invitee__c(ZTS_US_Contact__c = (ID)oConId, ZTS_US_Event__c=eventId);
                System.debug('eventInv----'+eventInv);
                listEventInvitee.add(eventInv);
            }
            
            System.debug('listEventInvitee----'+listEventInvitee);
            try{
                if(listEventInvitee != null && listEventInvitee.size() > 0){
                    System.debug('If loop');
                    insert listEventInvitee;
                    PageReference pg = new PageReference('/'+eventId);
                    pg.setRedirect(true);
                    return pg;
                }
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: '+e.getMessage()));
            }
        }
        return null;
    }
    
    /* Method Name  : cancel
    *  Description  : This method is used to cancel the selection of contacts and return to the event detail page
    *  Return type  : PageReference
    *  Parameters   : None
    */
    public PageReference cancel(){
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        PageReference page = new PageReference('/'+eventId);
        page.setRedirect(true);
        return page;
    }
    
    // returns a list of wrapper objects for the sObjects in the current page set
    public List<ContactWrapper> getCategories() {
        categories = new List<ContactWrapper>();
        for (Contact category : (List<Contact>)con.getRecords())
            categories.add(new ContactWrapper(category));
 
        return categories;
    }
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
    // returns the first page of records
    public void first() {
        con.first();
    }
 
    // returns the last page of records
    public void last() {
        con.last();
    }
 
    // returns the previous page of records
    public void previous() {
        con.previous();
    }
 
    // returns the next page of records
    public void next() {
        con.next();
    }
    
    public class ContactWrapper {
 
        public Boolean checked  { get; set; }
        public Contact con      { get; set;}
     
        public ContactWrapper(){
            con = new Contact();
            checked = false;
        }
     
        public ContactWrapper(Contact c){
            con = c;
            checked = false;
        }
    }
    
    public Pagereference SaveAcc()
     {
   
        List<Contact> ContactsToUpdate = new List<Contact>(); 
        for (ContactWrapper cw : categories) {
            if (cw.checked == true){
                ContactsToUpdate.add(cw.con);
            }
        }
       // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
     Database.DMLOptions dml = new Database.DMLOptions(); 
     dml.DuplicateRuleHeader.allowSave = true;
     dml.DuplicateRuleHeader.runAsCurrentUser = true;
     List<Database.SaveResult> sr = Database.update(ContactsToUpdate,dml);
       //update ContactsToUpdate;-- commented for SC-008149
      return null;
     }

  
      
      /*  
    * Sorting logic here    
    */
    public String sortExpression{
       
        get{
            return sortExp;
        }
        set{
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp){
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
                    System.debug('sortDirection--------'+sortDirection);}
            else
                sortDirection = 'ASC';
                sortExp = value;
                System.debug('sortExp--------'+sortExp);
            
        }
    }

    public String getSortDirection(){
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            System.debug('sortDirection--------'+sortDirection);
            return sortDirection;
                
    }

    public void setSortDirection(String value){  
        sortDirection = value;
        System.debug('sortDirection--------'+sortDirection);
    }
     /***
    * SortField - return sort by field. Default to Name
    ***/
    
   
    /* Method Name  : ViewSortData
    *  Description  : This method is used to sort the contact list based on selected column
    *  Return type  : PageReference
    *  Parameters   : None
   */
   public PageReference ViewSortData() {
       //build the full sort expression
        sortFullExp = sortExpression  + ' ' + sortDirection;
        system.debug('sortFullExp------'+sortFullExp);
        // By Sohil DEF-001535 for fetching the non-Inactive contacts when clicked on the column
        string status = 'Inactive';
        searchStr='%' + name + '%';
        if(name == null)
        {
            con = new ApexPages.StandardSetController(Database.Query('SELECT Name,FirstName,LastName,ZTS_US_Job_Function__c,ZTS_US_Degree__c,Account.Name,ZTS_US_Profession__c,Phone,Interface_Email__c FROM Contact where ZTS_EU_Contact_Status__c!=:status  and AccountId IN: listAccID and ID NOT IN: listContactId AND ZTS_EU_Market__c = \'United States\' order by '+ sortFullExp));        
        }
        else
        {
            con = new ApexPages.StandardSetController(Database.Query('SELECT Name,FirstName,LastName,ZTS_US_Job_Function__c,ZTS_US_Degree__c,Account.Name,ZTS_US_Profession__c,Phone,Interface_Email__c FROM Contact where ZTS_EU_Contact_Status__c!=:status  and AccountId IN: listAccID and ID NOT IN: listContactId and ((FirstName LIKE :searchStr) OR (LastName LIKE : searchStr) OR (Account.Name LIKE : searchStr)) AND ZTS_EU_Market__c = \'United States\' order by '+ sortFullExp));        
        }       
        con.setPageSize(size); 
       return null;
    }
    

  
}