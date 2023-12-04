/*
* @Name: AddAttendeesAndContactController
* @Desciption: Add and Remove Attendees to the Call.
*              Displays the Contacts associated with the Account related to the Call.
*              Search for a Contact outside the Account.
*              Displays Attendees currently added to the call.
*              Add and Remove Colleagues to the Call.
*              Search for a User to be added as Colleague in the Calls
*              Displays Colleagues currently added to the call.

* @date Created:Dec 17, 2013
* @author Ketan Prakash Singh
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
12/17/2013       Ketan                    Created
03/25/2014       Akanksha                 Modified
05/23/2014       Teresa Sebastian         Modified

**************************************************************************************/

public with sharing class AddAttendeesAndContactController
{
    public List<Contact> lstCon {get;set;} {lstCon = new List<Contact>();}
    
   // list to store the Contacts associated to Account via AccountContactRole
   // public List<AccountContactRole> lstAccConRole {get;set;} {lstAccConRole = new List<AccountContactRole>();}
   
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
    //public Set<Id> setActiveAff = new Set<Id>();
    set<String> marketId = new set<String>();
    public addAttendeesAndContactController()
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
     // code to get Market of the Current Account
        if(accountId != null){
            //TPDEV-456
            List<Market_Setting__mdt> market = Market_Setting__mdt.getAll().values(); 
            Map<String, String> additionalMarketsMap = new Map<String, String>();
            for (Market_Setting__mdt marketSetting : market) {
                additionalMarketsMap.put(marketSetting.Market__c, marketSetting.Additional_Call_Colleague_Markets__c);
            }
           
            CurrentAccount = [Select a.Name, a.ZTS_EU_Market__c,(Select Id, Name From Contacts) From Account a 
                              where a.id = :accountId AND ZTS_EU_Market__c != 'United States'];
            if(CurrentAccount != null){
                if(CurrentAccount.ZTS_EU_Market__c != null){
                    String Currentaccmarket = CurrentAccount.ZTS_EU_Market__c;
                    marketId.add(Currentaccmarket);
                    Set<String> additionalMarketIds = new Set<String>();
                    if (additionalMarketsMap.containsKey(Currentaccmarket)) {
                        String additionalMarket = additionalMarketsMap.get(Currentaccmarket);         
                        if (additionalMarket != null) {
                            additionalMarketIds.addAll(new Set<String>(additionalMarket.split(',')));
                        }
                    }
                    marketId.addAll(additionalMarketIds);
                    //YTPDEV-456 end 
                }
            }
        system.debug('***********marketId**************'+marketId);
                for(Contact con: CurrentAccount.Contacts){
                    setContactId.add(con.Id);
                }                    
                system.debug('@@@@@@@@@setContactId is: '+setContactId);  
                 List<ZTS_EU_Affiliations__c> newconaf= [Select Id,ZTS_EU_Account__c,ZTS_EU_Contact__c,ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c where ZTS_EU_Account__c=:accountId AND ZTS_EU_Affiliation_Status__c='Active' AND ZTS_EU_Market_from_Parent__c != 'United States'];
                
                for(ZTS_EU_Affiliations__c acaf:newconaf){
                        
                            setContactId.add(acaf.ZTS_EU_Contact__c);
                    
                } 
                
                                    
                lstCon = [Select c.firstName,c.LastName,c.Name, c.AccountId,c.ZTS_EU_Contact_type__c, c.Id,c.ZTS_EU_Contact_Status__c From Contact c
                                 where c.Id in :setContactId AND ZTS_EU_Market__c != 'United States' and ZTS_EU_Contact_Status__c = 'Active' ORDER BY c.LastName,c.firstName ASC Nulls First]; //Shefali DEF-001028 8th June 12015 Added order by clause
                
            dispjobfunc=new Map<String,String>();   
                         
                             
                for(Contact con: lstCon){
                    // Used for the Add/Remove button
                    
                    mapConIdAndBool.put(con.Id,true);
                } 
                     
            }
            system.debug('@@@@@@@@@callId is: '+callId );                 
      if(callId != null){
                CurrentCall = [Select c.Name, c.Id, (Select Id, ZTS_EU_Contact__c,ZTS_EU_Represents_Account__c,ZTS_EU_Contact_Profession__c, Name, ZTS_EU_Employee__c From Attendees__r), (Select Id,ZTS_EU_Call__c,ZTS_EU_User_Email__c,ZTS_EU_User__c from Colleagues__r)  From Call__c c 
                                 where c.id = :callId AND c.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
                          
                // Used for Deleting the Attendee from Attendee section using Attendee Id
                mapAttendees.putAll(CurrentCall.Attendees__r); 
                system.debug('@@@@@@@@@mapAttendees is: '+mapAttendees); 
                mapColleagues.putAll(CurrentCall.Colleagues__r);
                
                for(Attendee__c att: CurrentCall.Attendees__r){
                    // Constructing a map of Contact Id and Attendee used for deletion of Attendee from Contact
                    if(att.ZTS_EU_Contact__c != null){
                        mapConIdAtten.put(att.ZTS_EU_Contact__c,att);
                        if(mapConIdAndBool.containsKey(att.ZTS_EU_Contact__c)){
                       
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
    // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
    public ApexPages.StandardSetController setConCont {
        get {
            if(setConCont == null && searchString != null && searchString != '' && ContactFlag == true) {
               
                String searchTxt= '%'+searchString +'%';
                system.debug('@@@@@searchTxt is: '+searchTxt);
                setConCont = new ApexPages.StandardSetController([SELECT Id,ZTS_EU_Contact_type__c,Name,Title, MailingCity, MailingState, Account.Name,AccountId, Account.Id, ownerId  FROM Contact 
                                                                    where (name like :searchTxt or Email like:searchTxt or Account.Name like :searchTxt) and 
                                                                    Id NOT IN :setContactId AND ZTS_EU_Market__c != 'United States' order by name limit 750]);
                
                // sets the number of records in each page set   
                   setConCont.setPageSize(15);
                
            }
            system.debug('@@@@@setConCont is: '+setConCont);
            //setConContTest = setConCont;
            return setConCont;
        }
        set;
    }
      // method to display new contact affiliation
  public void showContactCreation(){
        isRenderednew=true;
        system.debug('-------------conId:'+conId+'---'+ApexPages.currentPage().getParameters().get('accountId'));
        List<Contact> listCon = [select Id, ZTS_EU_Contact_type__c, AccountId from Contact where Id=: conId AND ZTS_EU_Market__c != 'United States'];
       // if(listCon != null && listCon.size() > 0){
            // accContAff = new ZTS_EU_Affiliations__c();
            //accContAff.ZTS_EU_Profession__c = listCon[0].ZTS_EU_Contact_type__c;
           // accContAff.ZTS_EU_Account__c = ApexPages.currentPage().getParameters().get('accountId');
           // accContAff.ZTS_EU_Contact__c = listCon[0].Id;
       // }
    }
    // Initialize setCon and return a list of records
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
                system.debug('@@@@@@@@@mapSearchedConIdAndBool is: '+mapSearchedConIdAndBool);
                } 
            system.debug('---------contact acc uids: '+listcontId+'----'+ listaccid);   
            jobfunction=new Map<String,String>();
            
            for(Attendee__c att: CurrentCall.Attendees__r){
                //Checks if the Searched Contacts are present as Attendees
                if(att.ZTS_EU_Contact__c != null){
                      if(mapSearchedConIdAndBool.containsKey(att.ZTS_EU_Contact__c)){
                        
                        //Used to flip Add/Remove Button on Searched Contacts
                        mapSearchedConIdAndBool.put(att.ZTS_EU_Contact__c,false);
                    }
                }
            }
            return (List<Contact>) setConCont.getRecords();
            //return listconaffwrapper;
        }
        else
        return null;
    }
    
    // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
  
    public ApexPages.StandardSetController setConUser {
        
        get {
             if(setConUser == null && searchString != null && searchString != '' && EmployeeFlag == true) {

                String searchTxt= '%'+searchString +'%';
                setConUser = new ApexPages.StandardSetController([SELECT Name,Email FROM User where (name like :searchTxt or Email like:searchTxt) and ZTS_EU_Market__c =: marketId order by name limit 750 ] );
                
                // sets the number of records in each page set   
                   setConUser.setPageSize(15);
                
            }
            //setConUserTest = setConUser;
            return setConUser;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<User> getUsers() {
        if(setConUser != null){
        List<User> lstTempUser = new List<User>();
            lstTempUser = (List<User>) setConUser.getRecords();
            for(User u: lstTempUser){
                mapSearchedUserIdAndBool.put(u.Id,true);
                   }  
            for(ZTS_EU_Colleague__c col: CurrentCall.Colleagues__r){
                //Checks if the Searched Employees are present as Attendees
                if(col.ZTS_EU_User__c != null){
                     if(mapSearchedUserIdAndBool.containsKey(col.ZTS_EU_User__c)){
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
    
    
    public pageReference search(){
        String URL='';
        isOnload = true;
            searchString=  EncodingUtil.urlEncode(searchString, 'UTF-8');
         if(EmployeeFlag){
          URL = '/apex/AddColleaguesAsAttendee?searchString='+searchString;
         }
         else if(ContactFlag){
          URL = '/apex/INTLAddAttendeesAndContact?searchString='+searchString;
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
/*
*@name: Add
*@description: Method for Adding new Attendee to the Call   
*/ 
 
     public PageReference Add(){
        
        
     system.debug('inside add attendies:');
        
        try{
            accContAff = new ZTS_EU_Affiliations__c();
            system.debug('Contact affiliation:'+accContAff);
           if(accContAff.ZTS_EU_Contact__c!=null ){
            conId = accContAff.ZTS_EU_Contact__c;
            }
            system.debug('Contact Id:'+conId);
            if(conId != null && conId != ''){
                
                if(accContAff.ZTS_EU_Contact__c!=null && accContAff.ZTS_EU_Account__c!=null){
                List<Contact> contaflst=[Select Id,Name, ZTS_EU_Contact_type__c from Contact where Id=:conId AND ZTS_EU_Market__c != 'United States'];
                if(contaflst != null && contaflst.size() > 0){
                    conAccName = ApexPages.currentPage().getParameters().get('accountId');
                    conName = contaflst[0].Name;
                }
                system.debug('-------------------'+contaflst[0].ZTS_EU_Contact_type__c+'--------'+conAccName+'--'+conName);
                }
                system.debug('conAccName Id:'+conAccName);
                 if(conAccName != null && conAccName != ''){
                    atten = new Attendee__c(Name = conName, ZTS_EU_call__c = callId,ZTS_EU_Represents_Account__c = conAccName,ZTS_EU_Contact__c = conId);
                 }
                
                else{
                    atten = new Attendee__c(Name = conName,ZTS_EU_call__c = callId,ZTS_EU_Contact__c = conId);  
                } 
                System.debug('###before insert atten');
                insert atten;
                System.debug('###after insert atten');
                
                 List<ZTS_EU_Discussion__c> newDList=new List<ZTS_EU_Discussion__c>();
                Set <String> dnameset= new Set<String>();
                List<ZTS_EU_Discussion__c> ListExistingDisc = [Select Id, Name,ZTS_EU_Call_Attendee__c,ZTS_EU_Call_Attendee__r.Name,ZTS_EU_Campaign__c,ZTS_EU_Campaign__r.Name,ZTS_EU_Discussion_Items__c,ZTS_EU_Discussion_Items__r.ZTS_EU_Discussion_Item_Title__c,ZTS_EU_Product__c,ZTS_EU_Product__r.Name from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__r.ZTS_EU_call__c=:callId AND ZTS_EU_Market__c != 'United States'];
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
                system.debug('Creating new attendee');
                if(profileName == 'EU Admin' || profileName == 'EU_Demo Profile' || profileName == 'EU_Rep Profile')
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
                coll = new ZTS_EU_Colleague__c(Name = empName,ZTS_EU_Call__c = callId,ZTS_EU_User__c = empId,ZTS_EU_Automatic_ECC_creation__c = 'Do not Create Automatically');
                //coll = new ZTS_EU_Colleague__c(Name = empName,ZTS_EU_Call__c = callId,ZTS_EU_User__c = empId);
                insert coll;
                system.debug('*******************coll*****************************'+coll.ZTS_EU_Automatic_ECC_creation__c);
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
        }       catch(Exception e){
            System.debug('###inside catch: ' + e.getMessage());
           ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'AddAttendeesAndContactController-Add');
           atten.addError('Error insert failed:'+e.getMessage()+'--'+e.getLineNumber());
            return null;
        }
        return null;
      }
      
/*
*@name: Remove Colleague
*@description: Method for Removing Attendee from the Call   
*/ 
 
     public PageReference RemoveCol(){
        system.debug('@@@@@@@@@attId is: '+attId);
        system.debug('@@@@@@@@@attConIdDel is: '+attConIdDel);
        system.debug('@@@@@@@@@attUserIdDel is: '+attUserIdDel);
        
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
            ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'AddAttendeesAndContactController-RemoveCol');
           // atten.addError('Error delete failed:'+e.getMessage());
            return null;
        }
        
        
        return null;
      }
      
      /*
*@name: Remove Attendees
*@description: Method for Removing Attendee from the Call   
*/ 
 
     public PageReference RemoveAttn(){
        system.debug('@@@@@@@@@attId is: '+attId);
        system.debug('@@@@@@@@@attConIdDel is: '+attConIdDel);
        system.debug('@@@@@@@@@attUserIdDel is: '+attUserIdDel);
        
        try{
            delete mapAttendees.get(attId);
           // queryCurrentCall();
            system.debug('@@@@@@@@@attUserIdDel is: '+attUserIdDel);
            system.debug('@@@@@@@@@attConIdDel is: '+attConIdDel);
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
            ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'AddAttendeesAndContactController-RemoveAttn');
            atten.addError('Error delete failed:'+e.getMessage());
            return null;
        }
        
        
        return null;
      }

    

/*
*@name: RemoveAttendee
*@description: Method for Removing Attendee from the Call directly from Contact/Employee   
*/ 
 
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
            ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'AddAttendeesAndContactController-RemoveAttendee');
            atten.addError('Error delete failed:'+e.getMessage());
            return null;
        }
        return null;
      }
      
/*
*@name: queryCurrentCall
*@description: Method for Retrieving the updated details of the Current Call(used for Ajax rerendering)   
*/ 
      
      public void queryCurrentCall(){
          
            CurrentCall = [Select c.Name, c.Id, c.ZTS_EU_Start_Date_Time__c,(Select Id,ZTS_EU_Contact__c, Name,ZTS_EU_Represents_Account__c,ZTS_EU_Contact_Profession__c, ZTS_EU_Employee__c From Attendees__r),(Select Id,Name,ZTS_EU_User_Email__c,ZTS_EU_Call__c,ZTS_EU_User__c from Colleagues__r) From Call__c c 
                                 where c.id = :callId AND c.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
                mapAttendees.putAll(CurrentCall.Attendees__r);
                mapColleagues.putAll(CurrentCall.Colleagues__r);
                
      }
/*
*@name: saveConact
*@description: This method is used to save the new contact that gets added when the Contact searched is not available in org.
*              The user decides to add a new Contact and it gets mapped to the Account from which call is created.
*/ 
    public pageReference  saveConact()
    {
        boolean ContactInsert = false;
        //Added by Aritra as per SC-003545
        String ContactName= '';
        Account oAccount = [SELECT ID,BillingCity,BillingCountry,BillingState,BillingStreet,BillingPostalCode FROM ACCOUNT WHERE ID = :accountid AND ZTS_EU_Market__c != 'United States'];
        Call__C oCall = [SELECT ZTS_EU_Start_Date_Time__c,contact_Employee__c FROM Call__C WHERE ID = :callid AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        Contact oContact =  new Contact(lastName = oContact.lastName ,
                                       phone = oContact.phone, 
                                       Email = oContact.email, 
                                       accountID = oAccount.ID,
                                       salutation = oContact.salutation,
                                       firstName = oContact.firstName,                                        
                                        MailingCity = oAccount.BillingCity,
                                        MailingCountry = oAccount.BillingCountry,
                                        MailingState = oAccount.BillingState,
                                        MailingStreet = oAccount.BillingStreet,
                                        MailingPostalCode = oAccount.BillingPostalCode,
                                        ZTS_EU_Contact_type__c = oContact.ZTS_EU_Contact_type__c);
        
        if(profileName == 'EU Admin' || profileName == 'EU_Demo Profile' || profileName == 'EU_Rep Profile')
        {
            oContact.ZTS_EU_Last_Call_date__C = Date.valueOf(oCall.ZTS_EU_Start_Date_Time__c);
        }
       
        try
        {
            insert(oContact);
            ContactInsert = true;
           
        }
        catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insert Failes:Contact'));
        }
        system.debug('Contact created ::' + oContact.id);   
        if(ContactInsert == true && ContactFlag == true)  
        { 
            if(oContact.salutation != '--None--' && oContact.salutation != NULL) ContactName = ContactName + oContact.salutation ;//Changed by Aritra : Added as per SC-003545
            if(oContact.firstName != '' && oContact.firstName != NULL) ContactName = ContactName + ' ' + oContact.firstName ;//Changed by Aritra : Added as per SC-003545
            if(oContact.lastName != '' && oContact.lastName != NULL) ContactName = ContactName + ' ' + oContact.lastName ;//Changed by Aritra : Added as per SC-003545
               
            Attendee__c att = new Attendee__c(Name = ContactName, ZTS_EU_call__c = callId,ZTS_EU_Contact__c = oContact.ID,ZTS_EU_Represents_Account__c = oAccount.ID );
            
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
        String URL = '/apex/INTLAddAttendeesAndContact?searchString='+'';
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
    
/*
*@name: flipFlop
*@description: This method is used by the VF page to set the page render flags appropriately.
*         
*/ 
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
  
/*
*@name: flipFlop1
*@description: This method is used by the VF page to set the page render flags appropriately.
*         
*/ 
   public void flipFlop1()
   {
       isRendered = false;
       isRendered1 = true;
       isRenderednew=false;
   }
 
 /*
*@name: updateContactForLastCallDate
*@description: This method is used to update the Contact with the Last Call Date.
*         
*/ 
   public void updateContactForLastCallDate(ID conId)
   {
        List<Attendee__c> listConAtt = new List<Attendee__c>();
        Map <id, Date> mapAttCall = new Map<id, Date>();
        List<aggregateResult> results = [SELECT max(ZTS_EU_call__r.ZTS_EU_Start_Date_Time__c) maxDate  FROM Attendee__C Where ZTS_EU_Contact__r.id = :conId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
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
       
}