/*
This code is written to meet integration requirement for 'Australia Vaccination Register' project. 
A rest utility has been built in Touchpoint to insert/update/delete Contact records from crown peak system.
Aritra Chakraborty   Cognizant Technology Solutions

*/

@RestResource(URLMAPPING='/Contact/REST/*')
global class AUS_CP_REST_CONTACT {

@httpget
    global static list<Contact> doget(){
    
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    
    list<Contact> contactList = new list<Contact>();
    String contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
    
    IF (contactId !=null && contactId !=''){
    contactList = [select ID,
                    Email,
                    Password__c,
                    FirstName,
                    LastName,
                    Phone,
                    RegistryReminderDisabled__c,
                    HasOptedOutofEmail,
                    ZTS_EU_Opt_Out_Date_Email__c,
                    ZTS_EU_City__c,
                    ZTS_EU_Zip_Postal_Code__c,
                    ZTS_EU_District__c,
                    RecordType.Name,
             		ZTS_EU_Contact_type__c,
                    ZTS_EU_Country__c,
                    ZTS_EU_Market__c,
                    Hendra_Monthly_Email_Preference__c,
                    Account.ZTS_EU_Address_Line_1__c,
                    Account.ZTS_EU_Address_Line_2__c,
                    Account.ZTS_EU_Account_Status__c,
                    Account.ZTS_EU_Rep_Account_Status__c,
                    OwnerID,
                    ZTS_EU_Species_Specialty__c,
                    Is_Government_official__c,
                    Account.ID,
                    Account.ZTS_EU_Zoetis_SFDC_ID__c,
                    Contact.ZTS_EU_Zoetis_SFDC_ID__c,
                    Mkto_Sync_Permission__c,
                    Vets_Australia__c,
                    VetsAustraliaLastLogin__c
 					from Contact where ZTS_EU_External_ID__c =:contactId AND ZTS_EU_Market__c != 'United States'];
      if(contactList.size()>0)
   	  {
        for (Contact a : contactList) 
        {
            if(a.Email == '' || a.Email == null){a.Email = null;}
            if(a.Password__c == '' || a.Password__c == null){a.Password__c = null;}
            if(a.LastName == '' ||a.LastName == null){ a.LastName = null;}
            if(a.Phone == '' ||a.Phone == null){ a.Phone = null;}
            if(a.ZTS_EU_City__c == '' ||a.ZTS_EU_City__c == null){ a.ZTS_EU_City__c = null;}
            if(a.ZTS_EU_Zip_Postal_Code__c == '' ||a.ZTS_EU_Zip_Postal_Code__c == null){ a.ZTS_EU_Zip_Postal_Code__c = null;}
            if(a.ZTS_EU_District__c == '' ||a.ZTS_EU_District__c == null){ a.ZTS_EU_District__c = null;}
            if(a.ZTS_EU_Contact_type__c == '' ||a.ZTS_EU_Contact_type__c == null){ a.ZTS_EU_Contact_type__c = null;}
            if(a.ZTS_EU_Country__c == '' ||a.ZTS_EU_Country__c == null){ a.ZTS_EU_Country__c = null;}
            if(a.ZTS_EU_Market__c == '' ||a.ZTS_EU_Market__c == null){ a.ZTS_EU_Market__c = null;}
            if(a.ZTS_EU_Species_Specialty__c == '' ||a.ZTS_EU_Species_Specialty__c == null){ a.ZTS_EU_Species_Specialty__c = null;}
            if(a.Mkto_Sync_Permission__c == '' ||a.Mkto_Sync_Permission__c == null){ a.Mkto_Sync_Permission__c = null;}
            
         }
            
            
      }
        
	
    return contactList;
    }
    
    else{
        
    system.debug(contactId);
    contactList =  [select ID,
                    Email,
                    Password__c,
                    FirstName,
                    LastName,
                    Phone,
                    RegistryReminderDisabled__c,
                    HasOptedOutofEmail,
                    ZTS_EU_Opt_Out_Date_Email__c,
                    ZTS_EU_City__c,
                    ZTS_EU_Zip_Postal_Code__c,
                    ZTS_EU_District__c,
                    RecordType.Name,
             		ZTS_EU_Contact_type__c,
                    ZTS_EU_Country__c,
                    ZTS_EU_Market__c,
                    Hendra_Monthly_Email_Preference__c,
                    Account.ZTS_EU_Address_Line_1__c,
                    Account.ZTS_EU_Address_Line_2__c,
                    Account.ZTS_EU_Account_Status__c,
                    Account.ZTS_EU_Rep_Account_Status__c,
                    OwnerID,
                    ZTS_EU_Species_Specialty__c,
                    Is_Government_official__c,
                    Account.ID,
                    Account.ZTS_EU_Zoetis_SFDC_ID__c,
                    Contact.ZTS_EU_Zoetis_SFDC_ID__c,
                    Mkto_Sync_Permission__c,
                    Vets_Australia__c,
                    VetsAustraliaLastLogin__c
 					from Contact  WHERE ZTS_EU_Market__c != 'United States' limit 40];
        
    			
    			return contactList;
    	}
    }

@httppatch
    global static list<Contact> dopatch(){
    
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
              
    contactWrapperResp cwrapper_resp = new contactWrapperResp();
	List<Contact> lstContactToReturn = new List<Contact>();
    
    contactWrapperReq a_req = (contactWrapperReq) JSON.deserializeStrict(req.requestBody.toString(), contactWrapperReq.class);
    List<Contact> contactList = [select id, ZTS_EU_Zoetis_SFDC_ID__c from Contact where ZTS_EU_External_ID__c!= null and  ZTS_EU_External_ID__c =:a_req.ext_id AND ZTS_EU_Market__c != 'United States' LIMIT 1];
     
    	if(contactList.size()>0)
   		{
            Contact contactRec = contactList[0];
            	contactRec.Email=a_req.email;
                contactRec.Password__c=a_req.password;
                contactRec.FirstName=a_req.firstName;
                contactRec.LastName=a_req.lastName;
                contactRec.Phone=a_req.phone;
                contactRec.RegistryReminderDisabled__c=a_req.registryReminderDisabled;
                contactRec.ZTS_EU_Opt_Out_Email__c=a_req.isEmailOptOut;
                contactRec.ZTS_EU_Opt_Out_Date_Email__c=a_req.emailOptOutDate;
                contactRec.ZTS_EU_City__c=a_req.city;
                contactRec.ZTS_EU_Zip_Postal_Code__c=a_req.postalCode;
                contactRec.ZTS_EU_District__c=a_req.district;
                List<recordtype> rectypeList = [select id from recordtype where developername = : a_req.recordtype and SobjectType='Contact'];
           			if(rectypeList.size()>0){contactRec.recordtypeid = rectypeList[0].id;}
				contactRec.ZTS_EU_Address_Line_1__c=a_req.addressLine1;
            	contactRec.ZTS_EU_Address_Line_2__c=a_req.addressLine2;
                contactRec.ZTS_EU_Country__c=a_req.country;
                contactRec.ZTS_EU_Market__c=a_req.market;
                contactRec.Hendra_Monthly_Email_Preference__c=a_req.emailPreference;

                contactRec.OwnerID=a_req.owner_id;
            	contactRec.ZTS_EU_Contact_type__c = a_req.contact_type;
                contactRec.ZTS_EU_Species_Specialty__c=a_req.speciesSpecialty;
                contactRec.Is_Government_official__c=a_req.isGovernmentofficial;
            	List<Account> lstAccount = [Select Id,Name from Account where Name =:a_req.accountName AND ZTS_EU_Market__c != 'United States' limit 1];
            		if(lstAccount.size()>0){contactRec.AccountId =lstAccount[0].Id;}

                contactRec.Mkto_Sync_Permission__c=a_req.syncPermission;
                contactRec.Vets_Australia__c=a_req.vetsAustralia;
                contactRec.VetsAustraliaLastLogin__c=a_req.vetsAustralia_LastLoginDate;   				
            
            		cwrapper_resp.email=a_req.email;
                    cwrapper_resp.password=a_req.password;
                    cwrapper_resp.firstName=a_req.firstName;
                    cwrapper_resp.lastName=a_req.lastName;
                    cwrapper_resp.phone=a_req.phone;
                    cwrapper_resp.registryReminderDisabled=a_req.registryReminderDisabled;
                    cwrapper_resp.isEmailOptOut=a_req.isEmailOptOut;
                    cwrapper_resp.emailOptOutDate=a_req.emailOptOutDate;
                    cwrapper_resp.city=a_req.city;
                    cwrapper_resp.postalCode=a_req.postalCode;
                    cwrapper_resp.district=a_req.district;
                    cwrapper_resp.recordType=a_req.recordType;
                    cwrapper_resp.contact_type=a_req.contact_type;
                    cwrapper_resp.country=a_req.country;
                    cwrapper_resp.market=a_req.market;
                    cwrapper_resp.emailPreference=a_req.emailPreference;
                    cwrapper_resp.addressLine1=a_req.addressLine1;
                    cwrapper_resp.addressLine2=a_req.addressLine2;
                    cwrapper_resp.accountStatus=a_req.accountStatus;
                    cwrapper_resp.repAccountStatus=a_req.repAccountStatus;
                    cwrapper_resp.owner_id=a_req.owner_id;
                    cwrapper_resp.speciesSpecialty=a_req.speciesSpecialty;
                    cwrapper_resp.isGovernmentofficial=a_req.isGovernmentofficial;
                    cwrapper_resp.accountName=a_req.accountName;
                    cwrapper_resp.account_ZoetisSFDCID=a_req.account_ZoetisSFDCID;
                    cwrapper_resp.contact_ZoetisSFDCID=a_req.contact_ZoetisSFDCID;
                    cwrapper_resp.syncPermission=a_req.syncPermission;
                    cwrapper_resp.vetsAustralia=a_req.vetsAustralia;
                    cwrapper_resp.vetsAustralia_LastLoginDate=a_req.vetsAustralia_LastLoginDate;
            		cwrapper_resp.ext_id=a_req.ext_id;

            
            try{
            		update contactRec;
            		lstContactToReturn.add(contactRec);
            		
                
                	res.addHeader('Content-Type','application/json');
                    res.StatusCode = 201;
                	system.debug(cwrapper_resp);
                    String JSONMsg1= JSON.serialize(cwrapper_resp);
                    system.debug(JSONMsg1);
                    cwrapper_resp.message ='Your Contact record updated successfully';
                    cwrapper_resp.status = 'Success';
                    system.debug('Response Code'+res.statusCode);
                
                    if (res.statusCode==201)
                    {
                        system.debug('Successfully Inserted');
                        res.addHeader('Content-Type','application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(cwrapper_resp,true));
                        system.debug('Insert log'+res.statuscode +',' +res.responseBody);
                        ErrorLog_CrownPeak__c errortable = new ErrorLog_CrownPeak__c();
                        errortable.Status__c = 'Success';
                        errortable.Details__c = JSONMsg1;
                        Insert errortable;
                    }
            }
            catch(Exception e)
            {
					res.responseBody = Blob.valueOf(e.getMessage());
                    res.statusCode = 500;
                    cwrapper_resp.message = e.getMessage();
                    cwrapper_resp.errorcode = 500;
                    cwrapper_resp.status = 'Failure';
                    system.debug('Error occurred'+res.responsebody);
                    ErrorLog_CrownPeak__c errortable = new ErrorLog_CrownPeak__c();
                    errortable.Details__c = JSON.serialize(cwrapper_resp);
                    errortable.Status__c = 'Failure';
                    insert errortable;
                    return null;                
            }
        }
    
     return lstContactToReturn; 
       
        
    }
 
@httppost
  global static list<Contact> dopost(){
        
        RestRequest req = RestContext.request;
    	RestResponse res = RestContext.response;
              
    	contactWrapperResp cwrapper_resp = new contactWrapperResp();
        List<Contact> lstContactToReturn = new List<Contact>();
        contactWrapperReq a_req = (contactWrapperReq) JSON.deserializeStrict(req.requestBody.toString(), contactWrapperReq.class);
       
      	
           system.debug('Initial Json'+a_req);
           Contact contactRec = new Contact();
       				contactRec.Email=a_req.email;
                    contactRec.Password__c=a_req.password;
                    contactRec.FirstName=a_req.firstName;
                    contactRec.LastName=a_req.lastName;
                    contactRec.Phone=a_req.phone;
                    contactRec.RegistryReminderDisabled__c=a_req.registryReminderDisabled;
                    contactRec.ZTS_EU_Opt_Out_Email__c=a_req.isEmailOptOut;
                    contactRec.ZTS_EU_Opt_Out_Date_Email__c=a_req.emailOptOutDate;
                    contactRec.ZTS_EU_City__c=a_req.city;
                    contactRec.ZTS_EU_Zip_Postal_Code__c=a_req.postalCode;
                    contactRec.ZTS_EU_District__c=a_req.district;
                    List<recordtype> rectypeList = [select id from recordtype where developername = : a_req.recordtype and SobjectType='Contact'];
                        if(rectypeList.size()>0){contactRec.recordtypeid = rectypeList[0].id;}
    				contactRec.ZTS_EU_Address_Line_1__c=a_req.addressLine1;
            		contactRec.ZTS_EU_Address_Line_2__c=a_req.addressLine2;
                    contactRec.ZTS_EU_Country__c=a_req.country;
                    contactRec.ZTS_EU_Market__c=a_req.market;
                    contactRec.Hendra_Monthly_Email_Preference__c=a_req.emailPreference;
    
                    contactRec.OwnerID=a_req.owner_id;
      				contactRec.ZTS_EU_Contact_type__c = a_req.contact_type;
                    contactRec.ZTS_EU_Species_Specialty__c=a_req.speciesSpecialty;
                    contactRec.Is_Government_official__c=a_req.isGovernmentofficial;
                    List<Account> lstAccount = [Select Id,Name from Account where Name =:a_req.accountName AND ZTS_EU_Market__c != 'United States' limit 1];
                        if(lstAccount.size()>0){contactRec.AccountId  = lstAccount[0].Id;}
    
                    contactRec.Mkto_Sync_Permission__c=a_req.syncPermission;
                    contactRec.Vets_Australia__c=a_req.vetsAustralia;
                    contactRec.VetsAustraliaLastLogin__c=a_req.vetsAustralia_LastLoginDate;
      				contactRec.ZTS_EU_Contact_Status__c='Active';
      				contactRec.ZTS_EU_External_ID__c=a_req.ext_id;
      
      				cwrapper_resp.email=a_req.email;
                    cwrapper_resp.password=a_req.password;
                    cwrapper_resp.firstName=a_req.firstName;
                    cwrapper_resp.lastName=a_req.lastName;
                    cwrapper_resp.phone=a_req.phone;
                    cwrapper_resp.registryReminderDisabled=a_req.registryReminderDisabled;
                    cwrapper_resp.isEmailOptOut=a_req.isEmailOptOut;
                    cwrapper_resp.emailOptOutDate=a_req.emailOptOutDate;
                    cwrapper_resp.city=a_req.city;
                    cwrapper_resp.postalCode=a_req.postalCode;
                    cwrapper_resp.district=a_req.district;
                    cwrapper_resp.recordType=a_req.recordType;
                    cwrapper_resp.contact_type=a_req.contact_type;
                    cwrapper_resp.country=a_req.country;
                    cwrapper_resp.market=a_req.market;
                    cwrapper_resp.emailPreference=a_req.emailPreference;
                    cwrapper_resp.addressLine1=a_req.addressLine1;
                    cwrapper_resp.addressLine2=a_req.addressLine2;
                    cwrapper_resp.accountStatus=a_req.accountStatus;
                    cwrapper_resp.repAccountStatus=a_req.repAccountStatus;
                    cwrapper_resp.owner_id=a_req.owner_id;
                    cwrapper_resp.speciesSpecialty=a_req.speciesSpecialty;
                    cwrapper_resp.isGovernmentofficial=a_req.isGovernmentofficial;
                    cwrapper_resp.accountName=a_req.accountName;
                    cwrapper_resp.account_ZoetisSFDCID=a_req.account_ZoetisSFDCID;
                    cwrapper_resp.contact_ZoetisSFDCID=a_req.contact_ZoetisSFDCID;
                    cwrapper_resp.syncPermission=a_req.syncPermission;
                    cwrapper_resp.vetsAustralia=a_req.vetsAustralia;
                    cwrapper_resp.vetsAustralia_LastLoginDate=a_req.vetsAustralia_LastLoginDate;
      				cwrapper_resp.ext_id=a_req.ext_id;
      try{
            insert contactRec;
        	system.debug(contactRec);
        	lstContactToReturn.add(contactRec);
        	system.debug(lstContactToReturn);
          
           	res.addHeader('Content-Type','application/json');
          	res.StatusCode = 201;
        
        
        			
        
            system.debug(cwrapper_resp);
            String JSONMsg1= JSON.serialize(cwrapper_resp);
            system.debug(JSONMsg1);
            cwrapper_resp.message ='Your Contact record inserted successfully';
            cwrapper_resp.status = 'Success';
            system.debug('Response Code'+res.statusCode);
        
            if (res.statusCode==201)
            {
                system.debug('Successfully Inserted');
                res.addHeader('Content-Type','application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(cwrapper_resp,true));
                system.debug('Insert log'+res.statuscode +',' +res.responseBody);
                ErrorLog_CrownPeak__c errortable = new ErrorLog_CrownPeak__c();
                errortable.Status__c = 'Success';
                errortable.Details__c = JSONMsg1;
                Insert errortable;
            }
        }
        
        
        catch(exception e){
            res.responseBody = Blob.valueOf(e.getMessage());
            res.statusCode = 500;
            cwrapper_resp.message = e.getMessage();
            cwrapper_resp.errorcode = 500;
            cwrapper_resp.status = 'Failure';
            system.debug('Error occurred'+res.responsebody);
            ErrorLog_CrownPeak__c errortable = new ErrorLog_CrownPeak__c();
            errortable.Details__c = JSON.serialize(cwrapper_resp);
            errortable.Status__c = 'Failure';
            insert errortable;
            return null;
        }
        
        return lstContactToReturn;
  
  }

    
 
  global class contactWrapperReq{
     
      	Public String email;
        Public String password;
        Public String firstName;
        Public String lastName;
        Public String phone;
        Public Boolean registryReminderDisabled;
        Public Boolean isEmailOptOut;
        Public Date emailOptOutDate;
        Public String city;
        Public String postalCode;
        Public String district;
        Public String recordType;
        Public String contact_type;
        Public String country;
        Public String market;
        Public Boolean emailPreference;
        Public String addressLine1;
        Public String addressLine2;
        Public String accountStatus;
        Public String repAccountStatus;
        Public String owner_id;
        Public String speciesSpecialty;
        Public String isGovernmentofficial;
        Public String accountName;
        Public String account_ZoetisSFDCID;
        Public String contact_ZoetisSFDCID;
        Public String syncPermission;
        Public Boolean vetsAustralia;
        Public DateTime vetsAustralia_LastLoginDate;
      	Public string ext_id;
      
      global contactWrapperReq(){
             
         }
  }
  
  
  global class contactWrapperResp{
      	Public String email;
        Public String password;
        Public String firstName;
        Public String lastName;
        Public String phone;
        Public Boolean registryReminderDisabled;
        Public Boolean isEmailOptOut;
        Public Date emailOptOutDate;
        Public String city;
        Public String postalCode;
        Public String district;
        Public String recordType;
        Public String contact_type;
        Public String country;
        Public String market;
        Public Boolean emailPreference;
        Public String addressLine1;
        Public String addressLine2;
        Public String accountStatus;
        Public String repAccountStatus;
        Public String owner_id;
        Public String speciesSpecialty;
        Public String isGovernmentofficial;
        Public String accountName;
        Public String account_ZoetisSFDCID;
        Public String contact_ZoetisSFDCID;
        Public String syncPermission;
        Public Boolean vetsAustralia;
        Public DateTime vetsAustralia_LastLoginDate;
      	Public string ext_id;
      	public  string message;
      	public  Integer errorcode;
      	public string status;
  
      global contactWrapperResp(){
      
  		}
  }

    
    

}