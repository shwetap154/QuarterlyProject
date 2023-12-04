/****************************************************************************************************************************************** 
 * Class Name       : ZTS_US_ContactEditController
 * Description      : The class is used to do the following 
                      1. Edit Contacts after they are added to event 
                      2. Redirect to event page
                                    
 * Created By   : Laxmikanth(cloudsense Consulting)
 * Created Date : March 14th, 2016
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Laxmikanth Tankari           03/14/2016          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_US_ContactEditController 
{
    public ZTS_Events__c currentEventsRecord    {get;set;}
    List<ContactWrapper> categories             {get;set;}              
    private String sortDirection = 'ASC';
    private String sortExp = 'c.con.FirstName';
    List<ID> listContactId {get;set;}
    // List<ID> listAccID {get;set;}  
    public String name {get; set;} // by Sohil - DEF-001663
    Public Integer size{get;set;} // by Sohil - DEF-001663
    public String searchStr;
    public string sortFullExp;
    public ZTS_US_ContactEditController(){         
    }
  

    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                 
                 size = 1000; // by Sohil - DEF-001663
                listContactId = new List<ID>();
                String eventId = ApexPages.currentPage().getParameters().get('eventId');
                if(eventId != null && eventId != ''){
                    currentEventsRecord = [select Name,ZTS_US_Name__c from ZTS_Events__c where Id=: eventId AND ZTS_EU_Market__c != 'United States'];
                }
                for(ZTS_US_Event_Invitee__c evntInvitee : [select ZTS_US_Contact__c, ZTS_US_Event__c from ZTS_US_Event_Invitee__c 
                                                                    where ZTS_US_Event__c =: eventId
                                                                    AND ZTS_EU_Market__c != 'United States']){
                    listContactId.add(evntInvitee.ZTS_US_Contact__c);                                                   
                }
                
                con = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Name,FirstName,LastName,ZTS_EU_Profession__c,Account.Name,ZTS_EU_Contact_Status__c,Phone,Email FROM Contact where ID IN: listContactId AND ZTS_EU_Market__c != 'United States' order by FirstName])); // by sohil DEF-001535 added order by name 
                    
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
            [SELECT Name,FirstName,LastName,ZTS_EU_Profession__c,Account.Name,Phone,ZTS_EU_Contact_Status__c,Email FROM Contact where ID IN: listContactId and ((FirstName LIKE :searchStr) OR (LastName LIKE : searchStr) OR (Account.Name LIKE : searchStr)) AND ZTS_EU_Market__c != 'United States' order by FirstName]));               
        }
        else
        {
            con = new ApexPages.StandardSetController(Database.Query(
            'SELECT Name,FirstName,LastName,Account.Name,ZTS_EU_Profession__c,Phone,Email,ZTS_EU_Contact_Status__c FROM Contact where ID IN: listContactId and ((FirstName LIKE :searchStr) OR (LastName LIKE : searchStr) OR (Account.Name LIKE : searchStr)) AND ZTS_EU_Market__c != \'United States\' order by ' + sortFullExp));             
        }
        
        con.setPageSize(size);
        return null;
    } // EOC by Sohil Shah DEF -001663

    // Initialize con and return a list of records
    public List<Contact> getContacts() {
        return (List<Contact>) con.getRecords();
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
            con = new ApexPages.StandardSetController(Database.Query('SELECT Name,FirstName,LastName,Account.Name,ZTS_EU_Contact_Status__c,Phone,Email,ZTS_EU_Profession__c FROM Contact where ID IN: listContactId AND ZTS_EU_Market__c != \'United States\' order by '+ sortFullExp));        
        }
        else
        {
            con = new ApexPages.StandardSetController(Database.Query('SELECT Name,FirstName,LastName,Email,Account.Name,ZTS_EU_Contact_Status__c,Phone,ZTS_EU_Profession__c FROM Contact ID IN: listContactId and ((FirstName LIKE :searchStr) OR (LastName LIKE : searchStr) OR (Account.Name LIKE : searchStr)) AND ZTS_EU_Market__c != \'United States\' order by '+ sortFullExp));        
        }       
        con.setPageSize(size); 
       return null;
    }
       
  
}