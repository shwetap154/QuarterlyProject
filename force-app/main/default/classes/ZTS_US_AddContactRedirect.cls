/****************************************************************************************************************************************** 
 * Class Name       : ZTS_US_AddContactRedirect
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
public with sharing class ZTS_US_AddContactRedirect 
{
    public ZTS_Events__c currentEventsRecord    {get;set;}  
    public map<integer, boolean> masterCheckBox {get; set;}
    public integer noOfPages {get;set;}
    private String sortDirection = 'ASC';
    private String sortExp = 'c.con.FirstName';
    List<ID> listAccID {get;set;}   //Kaushik
    List<ID> listContactId {get;set;} //Kaushik
    public String name {get;set;} //Kaushik
    public String searchStr;
    public string sortFullExp;
    public Map<id,ContactWrapper> dataHoldingMap = new Map<id,ContactWrapper>();//Srinivas K:Added as part of the defect INC0511311
    public ZTS_US_AddContactRedirect(){     
        System.debug('Inside constructor');
        masterCheckBox = new map<integer, boolean>(); //Srinivas K:Added as part of the defect INC0511311
        masterCheckBox.put(1,false); //Srinivas K:Added as part of the defect INC0511311
        Categories = new list<ContactWrapper>(); //Srinivas K:Added as part of the defect INC0511311
        prepareList(); //Srinivas K:Added as part of the defect INC0511311
    }

    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                system.debug('Con is null');
                // Query for Contact records in standard set controller
                 listAccID = new List<ID>();
                 listContactId = new List<ID>();
                String eventId = ApexPages.currentPage().getParameters().get('eventId');
                system.debug('EventId...'+eventId);
                if(eventId != null && eventId != ''){
                    currentEventsRecord = [select Name,ZTS_US_Name__c from ZTS_Events__c where Id=: eventId AND ZTS_EU_Market__c != 'United States'];
                    system.debug('currentEventsRecord...'+currentEventsRecord);
                }
                for(ZTS_US_Event_Account__c evntAcc: [select ZTS_US_Event_Account__c from ZTS_US_Event_Account__c where ZTS_US_Events__c=: eventId]){
                    listAccID.add(evntAcc.ZTS_US_Event_Account__c);
                }
                for(ZTS_US_Event_Invitee__c evntInvitee : [select ZTS_US_Contact__c, ZTS_US_Event__c from ZTS_US_Event_Invitee__c 
                                                                    where ZTS_US_Event__c =: eventId
                                                                    AND ZTS_EU_Market__c != 'United States']){
                    listContactId.add(evntInvitee.ZTS_US_Contact__c);                                                   
                }
                
                con = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Name,FirstName,LastName,Account.Name,ZTS_EU_Profession__c,ZTS_EU_Contact_Status__c,Phone,Email FROM Contact where AccountId IN: listAccID and ID NOT IN: listContactId AND ZTS_EU_Market__c != 'United States' order by FirstName]));
                  //Srinivas K:Added as part of the defect INC0511311
                  con.setPageSize(20);   
                  system.debug('con.getRecords().size()===>'+con.getRecords().size());
                 //noOfPages = con.getRecords().size()/20 > 0?con.getRecords().size()/20+1:con.getRecords().size()/20;
                 noOfPages = con.getResultSize()/20 > 0? con.getResultSize()/20+1:con.getResultSize()/20;
                system.debug('noOfPages====>'+noOfPages); 
                for(integer i=1; i<=noOfPages;i++){
                    masterCheckBox.put(i,false);
                    system.debug('@@@masterCheckBox====>'+masterCheckBox);
                }
            }
            return con;
        }
        set;
    }

    public pagereference executesearch()
    {
        if(String.isNotEmpty(name))
        {
            searchstr='%' +string.valueOf(name) + '%' ;
            string status = 'Inactive';
            system.debug('searchstr....'+searchstr);
            system.debug('sortfullexp....'+sortFullExp);
            if (sortFullExp == null) {
               system.debug('You are inside null');
               system.debug('acclist' +listaccid);
               system.debug('listcontactid' +listContactId );
               iF (listContactId.SIZE() >0){
                   System.debug('Inside listcontactid NOT empty');
                       con = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Name,FirstName,LastName,Account.Name,Phone,ZTS_EU_Contact_Status__c,ZTS_EU_Profession__c,Email FROM Contact where ZTS_EU_Contact_Status__c!='Inactive' and AccountId IN: listAccID AND ID NOT IN: listContactId  AND ((FirstName LIKE :searchStr) OR (LastName LIKE : searchStr) OR (Account.Name LIKE : searchStr)) AND ZTS_EU_Market__c != 'United States' order by FirstName]));               
               } else
               {
                   System.debug('Inside listcontactid empty');
                  con = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Name,FirstName,LastName,Account.Name,Phone,ZTS_EU_Contact_Status__c,ZTS_EU_Profession__c,Email FROM Contact where ZTS_EU_Contact_Status__c!='Inactive' and AccountId IN: listAccID  AND ((FirstName LIKE :searchStr) OR (LastName LIKE : searchStr) OR (Account.Name LIKE : searchStr)) AND ZTS_EU_Market__c != 'United States' order by FirstName]));                
               }
           }
           else
           {
            con = new ApexPages.StandardSetController(Database.Query('SELECT Name,FirstName,LastName,Account.Name,ZTS_EU_Profession__c,Phone,ZTS_EU_Contact_Status__c,Email FROM Contact where ZTS_EU_Contact_Status__c!=:status and AccountId IN: listAccID and ID NOT IN: listContactId and ((FirstName LIKE :searchStr) OR (LastName LIKE : searchStr) OR (Account.Name LIKE : searchStr)) AND ZTS_EU_Market__c != \'United States\' order by ' + sortFullExp));             
           }
           con.setPageSize(20);
           prepareList();
           system.debug('After search: con.getRecords().size()===>'+con.getRecords().size());
        }
       return null; 
    }


    // Initialize con and return a list of records
    public List<Contact> getContacts() {
        return (List<Contact>) con.getRecords();
    }
    
    /* Method to save selected contacts as event invitees
    */
    public PageReference saveContacts(){
        List<ZTS_US_Event_Invitee__c> listEventInvitee = new List<ZTS_US_Event_Invitee__c>();
        List<String> listConID = new List<String>();
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        //Srinivas K:Added as part of the defect INC0511311
        contactDataInformationHold();
        for (ContactWrapper cw : dataHoldingMap.values()) {
            if (cw.checked){
                listConID.add(cw.con.Id);
            }
        }
        List<ZTS_US_Event_Invitee__c> listExistingEvntCon = [select ZTS_US_Contact__c, ZTS_US_Event__c from ZTS_US_Event_Invitee__c 
                                                                    where ZTS_US_Contact__c IN: listConID and ZTS_US_Event__c =: eventId
                                                                    AND ZTS_EU_Market__c != 'United States'];
        if(listExistingEvntCon != null && listExistingEvntCon.size() > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The selected Contact(s) has already been added to the Event'));
        }else{
            for(String oConId: listConID){
                ZTS_US_Event_Invitee__c eventInv = new ZTS_US_Event_Invitee__c(ZTS_US_Contact__c = (ID)oConId, ZTS_US_Event__c=eventId);
                listEventInvitee.add(eventInv);
            }
            try{
                if(listEventInvitee != null && listEventInvitee.size() > 0){
                    insert listEventInvitee;
                    PageReference pg = new PageReference('/'+eventId);
                    pg.setRedirect(true);
                    return pg;
                }
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The selected Contact(s) has already been added to the Event'));
            }
        }
        return null;
    }
    
    public PageReference cancel(){
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        PageReference page = new PageReference('/'+eventId);
        page.setRedirect(true);
        return page;
    }
    

    
    //Srinivas K:Added as part of the defect INC0511311
    public void prepareList(){
        categories = new List<ContactWrapper>();
        for (Contact category : (List<Contact>)con.getRecords()){
            //Srinivas K:Added as part of the defect INC0511311
            if(dataHoldingMap.containsKey(category.Id)){
                categories.add(new ContactWrapper(category,true));
            }
            else{
                categories.add(new ContactWrapper(category,false));
            }
        }
    }
    
    // returns a list of wrapper objects for the sObjects in the current page set
    public List<ContactWrapper> Categories {get;set;}
    //Srinivas K:Added as part of the defect INC0511311
    public pageReference selectAll(){
                for(ContactWrapper cw : Categories){
            system.debug('masterCheckBox====>'+masterCheckBox);
            cw.checked = masterCheckBox.get(pageNumber);
        }
        return null;
    }
    //Srinivas K:Added as part of the defect INC0511311
    public pageReference handleMasterCheckBox(){
        for(ContactWrapper cw : Categories){
            if(cw.checked == false){
               masterCheckBox.put(pageNumber,false);  
                break; 
            } 
        }
        return null;
    }
    
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            system.debug('con.getPageNumber()=====>'+con.getPageNumber());
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
    
        public PageReference clear(){
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        PageReference page = new PageReference('/'+eventId);
        page.setRedirect(true);
        return page;
    }
    // returns the first page of records
    public void first() {
        contactDataInformationHold();//Srinivas K:Added as part of the defect INC0511311
        try
        {
            con.first();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        prepareList(); //Srinivas K:Added as part of the defect INC0511311
    }
    
    public PageReference refr(){
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        PageReference page = new PageReference('/'+eventId);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference refr1(){
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        PageReference page = new PageReference('/'+eventId);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference refr2(){
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        PageReference page = new PageReference('/'+eventId);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference refr3(){
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        PageReference page = new PageReference('/'+eventId);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference refr4(){
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        PageReference page = new PageReference('/'+eventId);
        page.setRedirect(true);
        return page;
    }
 
    // returns the last page of records
    public void last() 
    {
        contactDataInformationHold();//Srinivas K:Added as part of the defect INC0511311
        //con.save();  Added this since the data issue throws exception in page.
        try
        {
            con.last();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        prepareList(); //Srinivas K:Added as part of the defect INC0511311
    }
 
    // returns the previous page of records
    public void previous() {
        contactDataInformationHold();//Srinivas K:Added as part of the defect INC0511311
        try
        {
            con.previous();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        prepareList(); //Srinivas K:Added as part of the defect INC0511311
    }
 
    // returns the next page of records
    public void next() {
        contactDataInformationHold();//Srinivas K:Added as part of the defect INC0511311
        try
        {
            con.next();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        prepareList(); //Srinivas K:Added as part of the defect INC0511311
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
        //Srinivas K:Added as part of the defect INC0511311
        public ContactWrapper(Contact c,Boolean t){
                this.con=c;
            this.checked=t;
            
        }
    }
    
    //Kaushik adding Save Contacts feature
    
    public Pagereference SaveAcc()
     {
   
        List<Contact> ContactsToUpdate = new List<Contact>(); 
        for (ContactWrapper cw : categories) {
            if (cw.checked == true){
                ContactsToUpdate.add(cw.con);
            }
        }
       update ContactsToUpdate;
      return null;
     }
    
    //Kaushik adding Save Contacts feature
    
    //Srinivas K:Added as part of the defect INC0511311
    public void contactDataInformationHold(){
        try{
                for(ContactWrapper cont:categories){
                system.debug('contactDataInformationHold===?');
                if(cont.checked){
                    dataHoldingMap.put(cont.con.id, cont);  
                }
                else{
                    if(dataHoldingMap.containsKey(cont.con.Id)){
                        dataHoldingMap.remove(cont.con.Id);                    
                    }
                }
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
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
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }

    public String getSortDirection(){
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }

    public void setSortDirection(String value){  
        sortDirection = value;
    }
      
    public PageReference ViewSortData() {
       //build the full sort expression
       sortFullExp = sortExpression  + ' ' + sortDirection;
       // Kaushik
       string status = 'Inactive';
       searchStr='%' + name + '%';
       if (name ==null){
            
            con = new ApexPages.StandardSetController(Database.Query('SELECT Name,FirstName,LastName,Account.Name,ZTS_EU_Profession__c,Email FROM Contact where ZTS_EU_Contact_Status__c!=:status  and AccountId IN: listAccID and ID NOT IN: listContactId AND ZTS_EU_Market__c != \'United States\' order by '+ sortFullExp));        
        }
        else
        {
            con = new ApexPages.StandardSetController(Database.Query('SELECT Name,FirstName,LastName,Account.Name,ZTS_EU_Profession__c,Email FROM Contact where ZTS_EU_Contact_Status__c!=:status  and AccountId IN: listAccID and ID NOT IN: listContactId and ((FirstName LIKE :searchStr) OR (LastName LIKE : searchStr) OR (Account.Name LIKE : searchStr)) AND ZTS_EU_Market__c != \'United States\' order by '+ sortFullExp));        
        }       
       
       // Kaushik
               con.setPageSize(20); 
               prepareList();
       //selectedValueQuery();
       //query the database based on the sort expression
       system.debug('sort expression >>>>>>>>>>>>>>>>>>>>'+sortFullExp);
       //soqlQuery+= 'ORDER BY '+sortFullExp;
       //system.debug('soql query >>>>>>>>>>>>>>>>>>>>'+soqlQuery);
       //getcreateDataTable();
       return null;
    }
}