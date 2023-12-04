/*************************************************************************************
* Name          :    USAddAttendeesAndContactController.
* Description   :    Add and Remove Attendees to the Call.
*                    Displays the Contacts associated with the Account related to the Call.
*                    Search for a Contact outside the Account.
*                    Displays Attendees currently added to the call.
* Author        :    Ketan Singh
 
Modification Log
----------------
Date             Developer              Comments
---------------------------------------------------------------------------------------
12/17/2013       Ketan Singh            Created

01/05/2014      Akanksha                Modified to incorporate latese call changes.
07/17/2017      Shiva Kudikilla         Added updateContactEmail method for contact Email update
**************************************************************************************/
public class USAddAttendeesAndContactController
{
    public List<Contact> lstCon {get;set;} {lstCon = new List<Contact>();}
    public String searchString{get;set;}
    public String accountId{get;set;}
    public String MailingCity{get;set;}
    public String MailingCountry{get;set;}
    public String MailingState{get;set;}
    public String MailingStreet{get;set;}
    public String MailingPostalCode{get;set;}
    public Account CurrentAccount {get;set;} {CurrentAccount = new Account ();}
    public Call__c CurrentCall {get;set;} {CurrentCall = new Call__c();}
    public Set<Id> setContactId = new Set<Id>();
    public Set<Id> setActiveAff = new Set<Id>();
    public Set<Id> setAttendeeId = new Set<Id>();
    public String callId{get;set;}
    public List<Attendee__c> lstAtten {get;set;} {lstAtten = new List<Attendee__c>();}
    public Attendee__c atten{set;get;}
    public ZTS_EU_Colleague__c coll{set;get;}
    public String attConIdDel{get;set;}
    public String conIdDel{get;set;}
    public String conId{get;set;}
    public String conName{get;set;}
    public String attId{get;set;}
    public map<Id,Attendee__c> mapAttendees {get;set;} {mapAttendees = new map<Id,Attendee__c>();}
    public map<Id,ZTS_EU_Colleague__c> mapColleagues {get;set;} {mapColleagues = new map<Id,ZTS_EU_Colleague__c>();}
    public map<Id,boolean> mapConIdAndBool {get;set;} {mapConIdAndBool = new map<Id,boolean>();}
    public map<Id,Attendee__c> mapConIdAtten {get;set;} {mapConIdAtten = new map<Id,Attendee__c>();}
    public map<Id,boolean> mapSearchedConIdAndBool {get;set;} {mapSearchedConIdAndBool = new map<Id,boolean>();}
    public String empId{get;set;}
    public String empName{get;set;}
    public string attUserIdDel{get;set;}
    public String userIdDel{get;set;}
    public map<Id,boolean> mapUserIdAndBool {get;set;} {mapUserIdAndBool = new map<Id,boolean>();}
    public map<Id,Attendee__c> mapUserIdAtten {get;set;} {mapUserIdAtten = new map<Id,Attendee__c>();}
    public map<Id,ZTS_EU_Colleague__c> mapUserIdColl {get;set;} {mapUserIdColl = new map<Id,ZTS_EU_Colleague__c>();}
    public map<Id,boolean> mapSearchedUserIdAndBool {get;set;} {mapSearchedUserIdAndBool = new map<Id,boolean>();}
    public String conAccName{get;set;}
    //for Contact and Attendee creation
    public Contact oContact{get; set;}{oContact = new Contact();}
    public String lastName{get; set;}
    public String title{get; set;}
    public String phone{get; set;}
    public String email{get; set;}
    public boolean isRendered{get; set;}
    public boolean isRendered1{get; set;}
    public boolean isRenderednew{get;set;}
    public boolean isOnLoad{get; set;}
    public boolean EmployeeFlag{get;set;}
    public boolean ContactFlag{get;set;}
    //for getting User profile Details
    public Id profileId=userinfo.getProfileId();
    public String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    public ZTS_EU_Affiliations__c accContAff {get;set;}
    public Map<String,String> jobfunction {get;set;}
    public Map<String,String> dispjobfunc {get;set;}
    /***********
        * Method name  : addAttendeesAndContactController
        * Description  : Get the details of attendee record.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
    public USaddAttendeesAndContactController()
    {
        isRendered = false;
        isRendered1 = true;
        isRenderednew = false;
        accContAff = new ZTS_EU_Affiliations__c();
        searchString = '';
        EmployeeFlag = false;
        ContactFlag = false;
     
        if(ApexPages.currentPage().getParameters().containsKey('isOnload')){
            if(ApexPages.currentPage().getParameters().get('isOnload') == 'true')
            {
                isOnload = true;
            }
            if(ApexPages.currentPage().getParameters().get('isOnload') == 'false')
            {
                isOnload = false;
            }    
        }
     
    if(ApexPages.currentPage().getParameters().containsKey('searchString')){
        searchString  = ApexPages.currentPage().getParameters().get('searchString');
    }
   if(ApexPages.currentPage().getParameters().containsKey('EmployeeFlag'))
     {
      if(ApexPages.currentPage().getParameters().get('EmployeeFlag') == 'true')
      EmployeeFlag = true;
      if(ApexPages.currentPage().getParameters().get('EmployeeFlag') == 'false')
      EmployeeFlag = false;
     }
     
     if(ApexPages.currentPage().getParameters().containsKey('ContactFlag'))
     {
      if(ApexPages.currentPage().getParameters().get('ContactFlag') == 'true')
      ContactFlag= true;
      if(ApexPages.currentPage().getParameters().get('ContactFlag') == 'false')
      ContactFlag= false;
     }
     if(ApexPages.currentPage().getParameters().containsKey('callId')){
         callId = ApexPages.currentPage().getParameters().get('callId');
     }  
     if(ApexPages.currentPage().getParameters().containsKey('accountId')){
         accountId = ApexPages.currentPage().getParameters().get('accountId');
     }
      if(accountId != null){ 
                List<Account> accts = [Select a.Name, (Select Id, Name From Contacts) From Account a where a.id = :accountId AND ZTS_EU_Market__c = 'United States' LIMIT 1];
                if (!accts.isEmpty())
                {
                    CurrentAccount = accts[0];
                    for(Contact con: CurrentAccount.Contacts){
                        setContactId.add(con.Id);
                    }                    
                    system.debug('@@@@@@@@@setContactId is: '+setContactId); 
                    // List of Active Account Contact Affiliations associated to a contact              
                    List<ZTS_EU_Affiliations__c> newconaf= [Select Id,ZTS_EU_Account__c,ZTS_EU_Contact__c,ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c where ZTS_EU_Account__c=:accountId AND ZTS_EU_Affiliation_Status__c<>'Inactive' AND ZTS_EU_Market_from_Parent__c = 'United States' ];
                    setContactId = new Set<ID>();
                    for(ZTS_EU_Affiliations__c acaf:newconaf){
                                setContactId.add(acaf.ZTS_EU_Contact__c);
                    }                                
                    lstCon = [Select c.Name, c.AccountId,c.ZTS_EU_Profession__c, c.Id From Contact c where c.Id in :setContactId AND ZTS_EU_Market__c = 'United States'];
                    list<ZTS_EU_Affiliations__c> accconfafflist = [Select Id,ZTS_EU_Job_Function__c,ZTS_EU_Contact__c,ZTS_EU_Account__c from ZTS_EU_Affiliations__c where ZTS_EU_Contact__c=:setContactId AND ZTS_EU_Market_from_Parent__c = 'United States' ORDER BY CreatedDate DESC];
                    for(Contact con: lstCon){
                        // Used for the Add/Remove button
                        mapConIdAndBool.put(con.Id,true);
                    } 
                }
        }
                          
            if(callId != null){
                 
                CurrentCall = [Select c.Name, c.Id,  (Select Id, ZTS_EU_Contact__c, ZTS_EU_Represents_Account__c,ZTS_US_Contact_Profession__c,ZTS_US_Account_On_Attendee__c,ZTS_US_Account_On_Attendee_Id__c,Name, ZTS_EU_Employee__c,ZTS_EU_Contact__r.Id,ZTS_EU_Contact__r.Email,ZTS_EU_Contact__r.ZTS_Invalid_Email__c,ZTS_EU_Contact__r.HasOptedOutOfEmail From Attendees__r),(Select Id,ZTS_EU_Call__c,ZTS_US_User_PIT_BU__c,ZTS_EU_User_Email__c,ZTS_EU_User__c from Colleagues__r)  From Call__c c where c.id = :callId ];
                // Used for Deleting the Attendee from Attendee section using Attendee Id
                mapAttendees.putAll(CurrentCall.Attendees__r); 
                system.debug('@@@@@@@@@mapAttendees is: '+mapAttendees); 
                mapColleagues.putAll(CurrentCall.Colleagues__r);
                
                for(Attendee__c att: CurrentCall.Attendees__r){
                    // Constructing a map of Contact Id and Attendee used for deletion of Attendee from Contact
                    if(att.ZTS_EU_Contact__c != null){
                        mapConIdAtten.put(att.ZTS_EU_Contact__c,att);
                        if(mapConIdAndBool.containsKey(att.ZTS_EU_Contact__c)){
                        system.debug('@@@@@@@@@att.ZTS_EU_Contact__c is: '+att.ZTS_EU_Contact__c);
                            mapConIdAndBool.put(att.ZTS_EU_Contact__c,false);
                        }
                    }
                    // Constructing a map of User Id and Attendee used for deletion of Attendee from Employee
                    if(att.ZTS_EU_Employee__c != null){
                        mapUserIdAtten.put(att.ZTS_EU_Employee__c,att);
                        if(mapUserIdAndBool.containsKey(att.ZTS_EU_Employee__c)){
                        system.debug('@@@@@@@@@att.ZTS_EU_Employee__c is: '+att.ZTS_EU_Employee__c);
                            mapUserIdAndBool.put(att.ZTS_EU_Employee__c,false);
                        }
                    }
                }                
                
            }    
    }
    /***********
        * Method name  : setConCont
        * Description  : Standard controller for the page.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/ 
    public ApexPages.StandardSetController setConCont {
        get {
            if(setConCont == null && searchString != null && searchString != '' && ContactFlag == true) {
                String searchTxt= '%'+searchString +'%';
                setConCont = new ApexPages.StandardSetController([SELECT Id,ZTS_EU_Profession__c,Name,Title, MailingCity, MailingState, Account.Name,AccountId, Account.Id, ownerId  FROM Contact where (name like :searchTxt or Email like:searchTxt or Account.Name like :searchTxt) and Id NOT IN :setContactId AND ZTS_EU_Market__c = 'United States' order by name limit 750]);
                
                // sets the number of records in each page set   
                   setConCont.setPageSize(15);
                
            }
            return setConCont;
        }
        set;
    }
    /***********
        * Method name  : showContactCreation
        * Description  : method to display new contact affiliation when contact searched doesn't exist.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/ 
    public void showContactCreation(){
        isRenderednew=true;
        List<Contact> listCon = [select Id, ZTS_EU_Profession__c, AccountId from Contact where Id=: conId AND ZTS_EU_Market__c = 'United States'];
        if(listCon != null && listCon.size() > 0){
            accContAff = new ZTS_EU_Affiliations__c();
            accContAff.ZTS_US_Profession__c = listCon[0].ZTS_EU_Profession__c;
            accContAff.ZTS_EU_Account__c = ApexPages.currentPage().getParameters().get('accountId');
            accContAff.ZTS_EU_Contact__c = listCon[0].Id;
        }
    }
    /***********
        * Method name  : getContacts
        * Description  : Initialize setCon and return a list of records
        * Return Type  : List<Contact>.
        * Parameters   : None.
    ***********/ 
    public List<Contact> getContacts(){
        if(setConCont != null){
            List<contact> lstTempCon = new List<Contact>();
            lstTempCon = (List<Contact>) setConCont.getRecords();
            List<id> listcontid = new List<id>();
            List<id> listaccid =new List<id>();
            for(Contact con: lstTempCon){
                    listcontid.add(con.id);
                    listaccid.add(con.AccountId);
                    mapSearchedConIdAndBool.put(con.Id,true);
                }  
                
           list<ZTS_EU_Affiliations__c> accconfafflist = [Select Id,ZTS_EU_Job_Function__c,ZTS_EU_Contact__c,ZTS_EU_Account__c from ZTS_EU_Affiliations__c where ZTS_EU_Contact__c=:listcontid AND ZTS_EU_Market_from_Parent__c = 'United States' ORDER BY CreatedDate DESC];
            
            List<conAffWrapper> listconaffwrapper= new List<conAffWrapper>();
            jobfunction=new Map<String,String>();
            for(ZTS_EU_Affiliations__c acaff:accconfafflist){
                    if(acaff.ZTS_EU_Contact__c !=null){
                    jobfunction.put(acaff.ZTS_EU_Contact__c,acaff.ZTS_EU_Job_Function__c);
                    }
              }
                       for(Attendee__c att: CurrentCall.Attendees__r){
                //Checks if the Searched Contacts are present as Attendees
                if(att.ZTS_EU_Contact__c != null){
                    if(mapSearchedConIdAndBool.containsKey(att.ZTS_EU_Contact__c)){
                        system.debug('@@@@@ inside if searched Contact is Attendee: '+att.ZTS_EU_Contact__c);
                        //Used to flip Add/Remove Button on Searched Contacts
                        mapSearchedConIdAndBool.put(att.ZTS_EU_Contact__c,false);
                    }
                }
            }
            return (List<Contact>) setConCont.getRecords();
        }
        else
        return null;
    }
    
    /***********
        * Method name  : setConUser
        * Description  : Standard controller for the page.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/ 
    public ApexPages.StandardSetController setConUser {
        get {
            system.debug('********************************'+setConUser +'@@@@@@'+searchString+'$$$$$$$$$'+EmployeeFlag );
            if(setConUser == null && searchString != null && searchString != '' && EmployeeFlag == true) {
                String searchTxt= '%'+searchString +'%';
                setConUser = new ApexPages.StandardSetController([SELECT Name,Email,PIT_BUs__c FROM User where (name like :searchTxt or Email like:searchTxt) AND ZTS_EU_Market__c = 'United States' order by name limit 750 ] );
                // sets the number of records in each page set   
                   setConUser.setPageSize(15);
            }
            //setConUserTest = setConUser;
            return setConUser;
        }
        set;
    }
    /***********
        * Method name  : getUsers
        * Description  : Initialize setCon and return a list of records to add as Colleagues
        * Return Type  : List<User>.
        * Parameters   : None.
    ***********/ 
    public List<User> getUsers() {
        if(setConUser != null){
        List<User> lstTempUser = new List<User>();
            lstTempUser = (List<User>) setConUser.getRecords();
            for(User u: lstTempUser){
                mapSearchedUserIdAndBool.put(u.Id,true);
                system.debug('@@@@@@@@@mapSearchedUserIdAndBool is: '+mapSearchedUserIdAndBool);
                }  
            for(ZTS_EU_Colleague__c col: CurrentCall.Colleagues__r){
                //Checks if the Searched Employees are present as Attendees
                if(col.ZTS_EU_User__c != null){
                    system.debug('@@@@@@@@@mapSearchedUserIdAndBool.containsKey(col.ZTS_EU_User__c is: '+mapSearchedUserIdAndBool.containsKey(col.ZTS_EU_User__c));
                    if(mapSearchedUserIdAndBool.containsKey(col.ZTS_EU_User__c)){
                        system.debug('@@@@@ inside if searched Employee is Attendee: '+col.ZTS_EU_User__c);
                        //Used to flip Add/Remove Button on Searched Employees
                        mapSearchedUserIdAndBool.put(col.ZTS_EU_User__c,false);
                    }
                }
            }
        return (List<User>) setConUser.getRecords();
        }
        else
        return null;
    }
    /***********
        * Method name  : Search
        * Description  : Method for Searching Attendee on the Call 
        * Return Type  : pageReference.
        * Parameters   : None.
    ***********/ 
 
    public pageReference search(){
        String URL='';
        isOnload = true;
         System.debug('**********searchString: '+searchString+'==============='+EmployeeFlag);  
         searchString=  EncodingUtil.urlEncode(searchString, 'UTF-8');
         if(EmployeeFlag){
          URL = '/apex/AddColleaguesAsAttendee?searchString='+searchString;
         }
         else if(ContactFlag){
          URL = '/apex/AddAttendeesAndContact?searchString='+searchString;
         }
         if(EmployeeFlag)
             URL = URL + '&EmployeeFlag=true';
         else
             URL = URL + '&EmployeeFlag=false';
         if(ContactFlag)
             URL = URL + '&ContactFlag=true';
          else
             URL = URL + '&ContactFlag=false';
         if(callId != null){
             URL = URL + '&callId='+callId;
         }
         if(accountId != null){
             URL = URL + '&accountId='+accountId;
         }
         if(isOnload != null){
             URL = URL + '&isOnload='+isOnload;
         }
         pageReference pg =  new pageReference(URL );
         pg.setRedirect(true);
         return pg;
    }
    /***********
        * Method name  : Add
        * Description  : Method for Adding new Attendee to the Call  
        * Return Type  : pageReference.
        * Parameters   : None.
    ***********/ 
     public PageReference Add(){
        try{
            //accContAff = new ZTS_US_Account_Contact_Affiliations__c();
            if(accContAff.ZTS_EU_Contact__c!=null ){
            conId = accContAff.ZTS_EU_Contact__c;
            }
            system.debug('david condID: ' + conId);
            if(conId != null && conId != ''){
                if(accContAff.ZTS_EU_Contact__c!=null && accContAff.ZTS_EU_Account__c!=null){
                List<Contact> contaflst=[Select Id,Name, ZTS_EU_Profession__c from Contact where Id=:conId AND ZTS_EU_Market__c = 'United States'];
                    if(contaflst != null && contaflst.size() > 0){
                        conAccName = ApexPages.currentPage().getParameters().get('accountId');
                        conName = contaflst[0].Name;
                    }
                }
                system.debug('david conAccName: ' + conAccName);
                if(conAccName != null && conAccName != ''){
                    atten = new Attendee__c(Name = conName,ZTS_EU_call__c = callId,ZTS_EU_Represents_Account__c = conAccName,ZTS_EU_Contact__c = conId);
                }
                else{
                    atten = new Attendee__c(Name = conName,ZTS_EU_call__c = callId,ZTS_EU_Contact__c = conId);  
                }  
                insert atten;
                system.debug('ATTEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEENTION ' + atten);
                //when an attendee is added, corresponding discussions related to call will be added.
                List<ZTS_EU_Discussion__c> newDList=new List<ZTS_EU_Discussion__c>();
                Set <String> dnameset= new Set<String>();
                List<ZTS_EU_Discussion__c> ListExistingDisc = [Select Id, Name,ZTS_EU_Call_Attendee__c,ZTS_EU_Call_Attendee__r.Name,ZTS_EU_Campaign__c,ZTS_EU_Campaign__r.Name,ZTS_EU_Discussion_Items__c,ZTS_EU_Discussion_Items__r.ZTS_EU_Discussion_Item_Title__c,ZTS_EU_Product__c,ZTS_EU_Product__r.Name from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__r.ZTS_EU_call__c=:callId AND ZTS_EU_Market__c = 'United States'];
                for (ZTS_EU_Discussion__c d:ListExistingDisc){
                        if(!dnameset.contains(d.Name)){
                            dnameset.add(d.Name);
                            ZTS_EU_Discussion__c newdisc= new ZTS_EU_Discussion__c();
                            newdisc.ZTS_EU_Call_Attendee__c=atten.id;
                                if(d.ZTS_EU_Campaign__c!=null){
                                newdisc.ZTS_EU_Campaign__c=d.ZTS_EU_Campaign__c;
                                newdisc.Name=d.ZTS_EU_Campaign__r.Name;
                                }
                                else if(d.ZTS_EU_Discussion_Items__c!=null){
                                newdisc.ZTS_EU_Discussion_Items__c=d.ZTS_EU_Discussion_Items__c;
                                newdisc.Name=d.ZTS_EU_Discussion_Items__r.ZTS_EU_Discussion_Item_Title__c;
                                }
                                else if(d.ZTS_EU_Product__c!=null){
                                newdisc.ZTS_EU_Product__c=d.ZTS_EU_Product__c;
                                newdisc.Name=d.ZTS_EU_Product__r.Name;
                                }
                            newDList.add(newdisc);
                        }
                }
                insert newDList;
                // To Update Last Call Date on contact object once attendee is created.
                updateContactForLastCallDate(conId);
                // to add the Attendee to map so that null pointer 
                // exception is avoided on direct deletion from contact Button
                mapConIdAtten.put(conId,atten);
                // to flip the button on Add Click for Contacts
                if(mapConIdAndBool.containsKey(conId)){
                    mapConIdAndBool.put(conId,false);
                }
                if(mapSearchedConIdAndBool.containsKey(conId)){
                    mapSearchedConIdAndBool.put(conId,false);
                }
                conId = '';
                conAccName = '';
            }
            
            
            if(empId != null && empId != ''){
                coll = new ZTS_EU_Colleague__c(Name = empName,ZTS_EU_Call__c = callId,ZTS_EU_User__c = empId);
                insert coll;
                
                // to add the Attendee to map so that null pointer 
                // exception is avoided on direct deletion from Employee Button
                mapUserIdColl.put(empId,coll);
                // to flip the button on Add Click for Employees
                if(mapUserIdAndBool.containsKey(empId)){
                    mapUserIdAndBool.put(empId,false);
                }
                if(mapSearchedUserIdAndBool.containsKey(empId)){
                    mapSearchedUserIdAndBool.put(empId,false);
                }
                empId = '';
            }
            
            queryCurrentCall();
        }
        catch(Exception e){
            atten.addError('Error insert failed:'+e.getMessage()+'--'+e.getLineNumber());
            return null;
        }
        return null;
      }
    /***********
        * Method name  : RemoveCol
        * Description  : Method for Removing Colleagues from the Call   
        * Return Type  : pageReference.
        * Parameters   : None.
    ***********/ 
     public PageReference RemoveCol(){
        try{
            delete mapColleagues.get(attId);
           // queryCurrentCall();
            system.debug('@@@@@@@@@attUserIdDel is: '+attUserIdDel);
            // to flip the button on Remove Click for Contacts
            if(attConIdDel != null && attConIdDel != ''){
                mapConIdAndBool.put(attConIdDel,true);
            }
            
            // to flip the button on Remove Click for Employees
            if(attUserIdDel != null && attUserIdDel != ''){
                mapUserIdAndBool.put(attUserIdDel,true);
            }
            
            queryCurrentCall();
        }
        
        catch(Exception e){
            atten.addError('Error delete failed:'+e.getMessage());
            return null;
        }
        
        
        return null;
      }
    /***********
        * Method name  : RemoveAttn
        * Description  : Method for Removing Attendee from the Call page   
        * Return Type  : pageReference.
        * Parameters   : None.
    ***********/ 
     public PageReference RemoveAttn(){
        try{
            delete mapAttendees.get(attId);
           // queryCurrentCall();
            system.debug('@@@@@@@@@attUserIdDel is: '+attUserIdDel);
            // to flip the button on Remove Click for Contacts
            if(attConIdDel != null && attConIdDel != ''){
                mapConIdAndBool.put(attConIdDel,true);
            }
            
            // to flip the button on Remove Click for Employees
            if(attUserIdDel != null && attUserIdDel != ''){
                mapUserIdAndBool.put(attUserIdDel,true);
            }
            
            queryCurrentCall();
        }
        
        catch(Exception e){
            atten.addError('Error delete failed:'+e.getMessage());
            return null;
        }
        return null;
      }
    /***********
        * Method name  : RemoveAttendee
        * Description  : Method for Removing Attendee from the Call directly from Contact/Employee page   
        * Return Type  : pageReference.
        * Parameters   : None.
    ***********/ 
     public PageReference RemoveAttendee(){
        
        try{
            if(conIdDel != null && conIdDel != ''){
                system.debug('@@@@@@@@@conIdDel is: '+conIdDel);
                delete mapConIdAtten.get(conIdDel);
                
                // to flip the button on Remove Click of Contacts
                if(mapConIdAndBool.containsKey(conIdDel)){
                    mapConIdAndBool.put(conIdDel,true);
                }
                if(mapSearchedConIdAndBool.containsKey(conIdDel)){
                    mapSearchedConIdAndBool.put(conIdDel,true);
                }
                conIdDel = '';
            }
            
            if(userIdDel != null && userIdDel != ''){
                system.debug('@@@@@@@@@userIdDel is: '+userIdDel);
                delete mapUserIdColl.get(userIdDel);
                
                // to flip the button on Remove Click of Employees
                if(mapUserIdAndBool.containsKey(userIdDel)){
                    mapUserIdAndBool.put(userIdDel,true);
                }
                if(mapSearchedUserIdAndBool.containsKey(userIdDel)){
                    mapSearchedUserIdAndBool.put(userIdDel,true);
                }
                userIdDel = '';
            }
            
            queryCurrentCall();
        }
        catch(Exception e){
            atten.addError('Error delete failed:'+e.getMessage());
            return null;
        }
        return null;
      }
      /***********
        * Method name  : queryCurrentCall
        * Description  : Method for Retrieving the updated details of the Current Call(used for Ajax rerendering)    
        * Return Type  : void.
        * Parameters   : None.
    ***********/
      public void queryCurrentCall(){
          
            CurrentCall = [Select c.Name, c.Id, c.ZTS_EU_Start_Date_Time__c,(Select Id, ZTS_EU_Contact__c, Name,ZTS_EU_Represents_Account__c,ZTS_US_Contact_Profession__c,ZTS_US_Account_On_Attendee__c,ZTS_US_Account_On_Attendee_Id__c, ZTS_EU_Employee__c,ZTS_EU_Contact__r.Email,ZTS_EU_Contact__r.ZTS_Invalid_Email__c,ZTS_EU_Contact__r.HasOptedOutOfEmail From Attendees__r),(Select Id,Name,ZTS_US_User_PIT_BU__c,ZTS_EU_User_Email__c,ZTS_EU_Call__c,ZTS_EU_User__c from Colleagues__r) From Call__c c 
                                 where c.id = :callId ];
                mapAttendees.putAll(CurrentCall.Attendees__r);
                mapColleagues.putAll(CurrentCall.Colleagues__r);
                
      }
      /***********
        * Method name  : saveConact
        * Description  : Method to save a call once save button is clicked.      
        * Return Type  : pageReference.
        * Parameters   : None.
    ***********/
    public pageReference  saveConact()
    {
        boolean ContactInsert = false;
        Account oAccount = [SELECT ID,BillingCity,BillingCountry,BillingState,BillingStreet,BillingPostalCode FROM ACCOUNT WHERE ID = :accountid AND ZTS_EU_Market__c = 'United States'];
        Call__C oCall = [SELECT ZTS_EU_Start_Date_Time__c FROM Call__C WHERE ID = :callid];
        Contact oContact =  new Contact(lastName = oContact.lastName ,
                                       phone = oContact.phone, 
                                       Interface_Email__c = oContact.Interface_Email__c, 
                                       accountID = oAccount.ID,
                                       salutation = oContact.salutation,
                                       firstName = oContact.firstName,                                        
                                        MailingCity = oAccount.BillingCity,
                                        MailingCountry = oAccount.BillingCountry,
                                        MailingState = oAccount.BillingState,
                                        MailingStreet = oAccount.BillingStreet,
                                        MailingPostalCode = oAccount.BillingPostalCode);
        
        if(profileName == 'EU Admin' || profileName == 'EU_Demo Profile' || profileName == 'EU_Rep Profile')
        {
            oContact.ZTS_EU_Last_Call_date__C = Date.valueOf(oCall.ZTS_EU_Start_Date_Time__c);
        }
       
        try
        {
            system.debug('-----------isrendered----'+ isrendered);
            
            oContact.ZTS_EU_Profession__c = accContAff.ZTS_US_Profession__c;
            oContact.ZTS_Job_Function__c = accContAff.ZTS_EU_Job_Function__c;
            insert(oContact);
            ContactInsert = true;
            System.debug('---QUERY--------'+[Select Id from ZTS_EU_Affiliations__c where ZTS_EU_Contact__c=:oContact.Id AND ZTS_EU_Account__c=:oContact.AccountId AND ZTS_EU_Market_from_Parent__c = 'United States']);
            ZTS_EU_Affiliations__c tempAccContAff = [Select Id from ZTS_EU_Affiliations__c where ZTS_EU_Contact__c=:oContact.Id AND ZTS_EU_Account__c=:oContact.AccountId AND ZTS_EU_Market_from_Parent__c = 'United States' limit 1];
            
            tempAccContAff.ZTS_US_Profession__c = accContAff.ZTS_US_Profession__c;
            tempAccContAff.ZTS_EU_Job_Function__c = accContAff.ZTS_EU_Job_Function__c;
            tempAccContAff.ZTS_EU_Account_influence__c = accContAff.ZTS_EU_Account_influence__c;
            if(tempAccContAff != null){
                system.debug('------ZTS_US_Profession__c------'+accContAff.ZTS_US_Profession__c);
                accContAff.ZTS_EU_Affiliation_Status__c='Inactive';
                update tempAccContAff;
            }
        }
        catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insert Failes:Contact'));
        }
        system.debug('Contact created ::' + oContact.id);   
        if(ContactInsert == true && ContactFlag == true)  
        { 
            String conName = '';
            if(oContact.salutation != '--None--' && oContact.salutation != NULL) conName = conName + oContact.salutation ;
            if(oContact.firstName != '' && oContact.firstName != NULL)conName = conName + ' ' + oContact.firstName ;
            if(oContact.lastName != '' && oContact.lastName != NULL)conName = conName + ' ' + oContact.lastName ;
               
            Attendee__c att = new Attendee__c(Name = conName, ZTS_EU_call__c = callId,ZTS_EU_Contact__c = oContact.ID,ZTS_EU_Represents_Account__c = oAccount.ID );
            try
            {
                insert(att);
            }
           catch(Exception e)
           {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insert Failes:Attendee'));
           }    
           system.debug('attendee created :' + att);
        }
        searchString=  EncodingUtil.urlEncode(searchString, 'UTF-8');
        String URL = '/apex/AddAttendeesAndContact?searchString='+'';
        if(EmployeeFlag){
         URL = URL + '&EmployeeFlag=true';
        }
        else{
            URL = URL + '&EmployeeFlag=false';
        }
        if(ContactFlag)
            URL = URL + '&ContactFlag=true';
        else
            URL = URL + '&ContactFlag=false';
        if(callId != null){
            URL = URL + '&callId='+callId;
        }
        if(accountId != null){
         URL = URL + '&accountId='+accountId;
        }
        if(isOnload != null){
             URL = URL + '&isOnload='+isOnload;
        }    
        system.debug('printing boolean' + isOnload);
        pageReference pg =  new pageReference(URL );
        pg.setRedirect(true);
        return pg;   
    }
    /***********
        * Method name  : saveConactAff
        * Description  : Method to save ACA once a contact is created from the attendees page.       
        * Return Type  : pageReference.
        * Parameters   : None.
    ***********/
    public void saveConactAff(){
        system.debug('==========accContAff.job----'+ accContAff.ZTS_EU_Contact__c+'----'+apexPages.currentPage().getParameters().get('accountId')+'-----'+accContAff.ZTS_EU_Unique_Primary_key__c);
        if(accContAff != null){
            accContAff.ZTS_EU_Account__c = ApexPages.currentPage().getParameters().get('accountId');
            insert accContAff;
            
        }
      Add();
      accContAff= new ZTS_EU_Affiliations__c();
     isRenderednew =false;
    }
    /***********
        * Method name  : flipFlop
        * Description  : Method to alternate the boolean values being used in the class.       
        * Return Type  : void.
        * Parameters   : None.
    ***********/
   public void flipFlop()
   {    
      isRenderednew =false;
       if(isRendered == false)
       {
            isRendered = true;
            isRendered1 = false;
            
            
       }
       else
       {     
            isRendered = false;
            
       }     
        system.debug('printing boolean ' + isOnload);
   } 
   public void flipFlop1()
   {
       isRendered = false;
       isRendered1 = true;
       isRenderednew=false;
   }
   /***********
        * Method name  : updateContactForLastCallDate
        * Description  : Method to update last call date for a contact       
        * Return Type  : void.
        * Parameters   : None.
    ***********/
   public void updateContactForLastCallDate(ID conId)
   {
        List<Attendee__c> listConAtt = new List<Attendee__c>();
        Map <id, Date> mapAttCall = new Map<id, Date>();
        List<aggregateResult> results = [SELECT max(ZTS_EU_call__r.ZTS_EU_Start_Date_Time__c) maxDate  FROM Attendee__C Where ZTS_EU_Contact__r.id = :conId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States'];
        Contact oCon = new Contact(id=conId);
        for(aggregateResult ar : results)
        {
            //Date maxdate = ar.get('')
           oCon.ZTS_EU_Last_Call_date__C = Date.valueOf(ar.get('maxDate'));
             
           //oCon.Last_Call_date__C = system.today() -1 ;
            system.debug('Creating new attendee' +oCon );
        }
        update(oCon);
    }
    /***********
        * Method name  : conAffWrapper
        * Description  : Wrapper class for contact and related affiliations.      
        * Return Type  : void.
        * Parameters   : None.
    ***********/
     public class conAffWrapper{
            public Contact contactObj{get;set;}
            public String jobfunction{get;set;}
            public conAffWrapper(Contact con, String jobf){
                contactObj = con;
                jobfunction = jobf;
                          
            }
      }      

    /**
     * Created this method for SC-002280 -- Provide an ability to update contact email from Call form
     * 
     * */
    public void updateContactEmail(){
        List<Id> contIdEmailList = new List<Id>();
        for(Attendee__c attendee: CurrentCall.Attendees__r){
            contIdEmailList.add(attendee.ZTS_EU_Contact__c);
        }
        System.debug('...Contact Ids...before update..' + contIdEmailList); 
        
        Map<String, Contact> existingConMap = new Map<String, Contact>(); 
        for(Contact conObj : [Select c.Id,c.Email,c.Interface_Email__c,c.Interface_Email_Opt_Out__c from Contact c where id in :contIdEmailList AND ZTS_EU_Market__c = 'United States']){
                existingConMap.put(conObj.Id, conObj);
        }

        List<Contact> contsToUpdate = new List<Contact>(); 
        for(Attendee__c attendee: CurrentCall.Attendees__r){
            //System.debug('Comparing=='+attendee.ZTS_EU_Contact__r.Email+'==='+existingConMap.get(attendee.ZTS_EU_Contact__c).Email+'==');
            //System.debug('***IF***' + (attendee.ZTS_EU_Contact__r.Email != existingConMap.get(attendee.ZTS_EU_Contact__c).Email) );

            if(attendee.ZTS_EU_Contact__r.Email != existingConMap.get(attendee.ZTS_EU_Contact__c).Email){
                Contact con = existingConMap.get(attendee.ZTS_EU_Contact__c);
                con.Interface_Email__c = attendee.ZTS_EU_Contact__r.Email;
                //con.Interface_Email_Opt_Out__c = false;
                //con.ZTS_Invalid_Email__c = false;
                contsToUpdate.add(con);
            }
        }
        
        if(contsToUpdate.size() > 0){
            try{
                System.debug('Updating the contact...' + contsToUpdate);
                update contsToUpdate;
            }catch(Exception ex){
                System.debug('Exception occuring while updating contact email: '+ex);
            }
        } 
        
    }

}