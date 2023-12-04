/*
This code is written to meet integration requirement for 'Australia Vaccination Register' project. 
A rest utility has been built in Touchpoint to insert/update/delete Account records from crown peak system.
Aritra Chakraborty   Cognizant Technology Solutions

*/

@RestResource(URLMAPPING='/Account/REST/*')
global class AUS_CP_REST_ACCOUNT {

@httpget
    global static list<Account> doget(){
    
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    
    list<Account> accountList = new list<Account>();
    String searchtext = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
    
    IF (searchtext !=null && searchtext !=''){
    accountList = [select ID,
                    Email__c,
                    Name,
                    ZTS_EU_Main_Phone__c,
                    Send_Owner_Reminders__c,
                    ZTS_EU_Opt_Out_Email__c,
                    ZTS_EU_Opt_Out_Date_Email__c,
                    ZTS_EU_City__c,
                    ZTS_EU_Zip_Postal_Code__c,
                    ZTS_EU_District__c,
                    ZTS_EU_Sub_Type__c,
                    RecordType.Name,
                    Type,
                    ZTS_EU_Country__c,
                    ZTS_EU_Market__c,
                    Email_Preference__c,
                    ZTS_EU_Address_Line_1__c,
                    ZTS_EU_Address_Line_2__c,
                    ZTS_EU_State_County__c,
                    ZTS_EU_State_County_Value__c,
                    ZTS_EU_Account_Status__c,
                    ZTS_EU_Rep_Account_Status__c,
                    ZTS_EU_Reason__c,
                    ZTS_EU_TSF_PBC__c,
                    OwnerID,
                    ZTS_EU_Account_Count__c,
                    ZTS_EU_Preferred_Language__c,
                    ZTS_EU_Potential_Region__c,
                   	ZTS_EU_Customer_ID__c,
                    ZTS_EU_Zoetis_SFDC_ID__c from Account where ZTS_EU_Customer_ID__c =:searchtext or Email__c =:searchtext];
    if(accountList.size()>0)
    {
        for (Account a : accountList) 
        {
            if(a.Email__c == '' || a.Email__c == null){a.Email__c = null;}
            if(a.ZTS_EU_Main_Phone__c == '' || a.ZTS_EU_Main_Phone__c == null){a.ZTS_EU_Main_Phone__c = null;}
            if(a.ZTS_EU_City__c == '' ||a.ZTS_EU_City__c == null){ a.ZTS_EU_City__c = null;}
            if(a.ZTS_EU_Zip_Postal_Code__c == '' ||a.ZTS_EU_Zip_Postal_Code__c == null){ a.ZTS_EU_Zip_Postal_Code__c = null;}
            if(a.ZTS_EU_District__c == '' ||a.ZTS_EU_District__c == null){ a.ZTS_EU_District__c = null;}
            if(a.ZTS_EU_Sub_Type__c == '' ||a.ZTS_EU_Sub_Type__c == null){ a.Email__c = null;}
            if(a.Type == '' ||a.Type == null){ a.Type = null;}
            if(a.ZTS_EU_Country__c == '' ||a.ZTS_EU_Country__c == null){ a.ZTS_EU_Country__c = null;}
            if(a.ZTS_EU_Market__c == '' ||a.ZTS_EU_Market__c == null){ a.ZTS_EU_Market__c = null;}
            if(a.Email_Preference__c == '' ||a.Email_Preference__c == null){ a.Email_Preference__c = null;}
            if(a.ZTS_EU_Address_Line_1__c == '' ||a.ZTS_EU_Address_Line_1__c == null){ a.ZTS_EU_Address_Line_1__c = null;}
            if(a.ZTS_EU_Address_Line_2__c == '' ||a.ZTS_EU_Address_Line_2__c == null){ a.ZTS_EU_Address_Line_2__c = null;}
            if(a.ZTS_EU_State_County__c == null) { a.ZTS_EU_State_County__c = null;}
            if(a.ZTS_EU_Account_Status__c == '' ||a.ZTS_EU_Account_Status__c == null){ a.ZTS_EU_Account_Status__c = null;}
            if(a.ZTS_EU_Rep_Account_Status__c == '' ||a.ZTS_EU_Rep_Account_Status__c == null){ a.ZTS_EU_Rep_Account_Status__c = null;}
            if(a.ZTS_EU_Reason__c == '' ||a.ZTS_EU_Reason__c == null){ a.ZTS_EU_Reason__c = null;}
            if(a.ZTS_EU_TSF_PBC__c == '' ||a.ZTS_EU_TSF_PBC__c == null){ a.ZTS_EU_TSF_PBC__c = null;}
            if(a.ZTS_EU_Preferred_Language__c == '' ||a.ZTS_EU_Preferred_Language__c == null){ a.ZTS_EU_Preferred_Language__c = null;}
            if(a.ZTS_EU_Potential_Region__c == '' ||a.ZTS_EU_Potential_Region__c == null){ a.ZTS_EU_Potential_Region__c = null;}
            if(a.ZTS_EU_Customer_ID__c == '' ||a.ZTS_EU_Customer_ID__c == null){ a.ZTS_EU_Customer_ID__c = null;}
         }
            
            
      }
	
    return accountList;
}

    
    else{
        
    system.debug(searchtext);
    accountList =  [select ID,
                    Email__c,
                    Name,
                    ZTS_EU_Main_Phone__c,
                    Send_Owner_Reminders__c,
                    ZTS_EU_Opt_Out_Email__c,
                    ZTS_EU_Opt_Out_Date_Email__c,
                    ZTS_EU_City__c,
                    ZTS_EU_Zip_Postal_Code__c,
                    ZTS_EU_District__c,
                    ZTS_EU_Sub_Type__c,
                    RecordType.Name,
                    Type,
                    ZTS_EU_Country__c,
                    ZTS_EU_Market__c,
                    Email_Preference__c,
                    ZTS_EU_Address_Line_1__c,
                    ZTS_EU_Address_Line_2__c,
                    ZTS_EU_State_County__c,
                    ZTS_EU_State_County_Value__c,
                    ZTS_EU_Account_Status__c,
                    ZTS_EU_Rep_Account_Status__c,
                    ZTS_EU_Reason__c,
                    ZTS_EU_TSF_PBC__c,
                    OwnerID,
                    ZTS_EU_Account_Count__c,
                    ZTS_EU_Preferred_Language__c,
                    ZTS_EU_Potential_Region__c,
                    ZTS_EU_Customer_ID__c,
                    ZTS_EU_Zoetis_SFDC_ID__c from Account limit 40];
    			
    			return accountList;
    	}
    }

@httppatch
    global static list<Account> dopatch(){
    
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
              
    accountWrapperResp awrapper_resp = new accountWrapperResp();
	List<Account> lstAccountToReturn = new List<Account>();
    
    accountWrapperReq a_req = (accountWrapperReq) JSON.deserializeStrict(req.requestBody.toString(), accountWrapperReq.class);
    List<Account> accountList = [select id, ZTS_EU_Zoetis_SFDC_ID__c from Account where ZTS_EU_Customer_ID__c!= null and  ZTS_EU_Customer_ID__c =:a_req.ext_id LIMIT 1];
    List<State_Country__c> statecountyList = new List<State_Country__c>(); 
    	if(accountList.size()>0)
   		{
            Account accountRec = accountList[0];
      				accountRec.Email__c=a_req.email;
                    accountRec.Name=a_req.Name;
                    accountRec.ZTS_EU_Main_Phone__c=a_req.Phone;
                    accountRec.Send_Owner_Reminders__c=a_req.send_Owner_Reminders;
                    accountRec.ZTS_EU_Opt_Out_Email__c=a_req.isEmailOptOut;
                    accountRec.ZTS_EU_Opt_Out_Date_Email__c=a_req.emailOptOutDate;
                    accountRec.ZTS_EU_City__c=a_req.city;
                    accountRec.ZTS_EU_Zip_Postal_Code__c=a_req.zipcode;
                    accountRec.ZTS_EU_District__c=a_req.district;
                    accountRec.ZTS_EU_Sub_Type__c=a_req.subtype;
                    accountRec.Type=a_req.account_type;
                    accountRec.ZTS_EU_Country__c=a_req.country;
                    accountRec.ZTS_EU_Market__c=a_req.market;
                    accountRec.Email_Preference__c=a_req.email_preference;
                    accountRec.ZTS_EU_Address_Line_1__c=a_req.addressLine1;
                    accountRec.ZTS_EU_Address_Line_2__c=a_req.addressLine2;
                    accountRec.ZTS_EU_Account_Status__c=a_req.account_status;
                    accountRec.ZTS_EU_Rep_Account_Status__c=a_req.rep_account_status;
            		accountRec.ZTS_EU_Reason__c = a_req.inactive_reason;
                    accountRec.ZTS_EU_TSF_PBC__c=a_req.tsfpbc;
                    accountRec.OwnerID=a_req.owner_id;
                    accountRec.ZTS_EU_Preferred_Language__c=a_req.preferred_Language;
                    accountRec.ZTS_EU_Potential_Region__c=a_req.Potential_Region;
            		if(a_req.statecountyval != '')
                    {
                        statecountyList =[Select id from State_Country__c where Name = :a_req.statecountyval and ZTS_EU_Country__c = :a_req.country];
                        if(statecountyList.size()>0){accountRec.ZTS_EU_State_County__c = statecountyList[0].id;}
                    }
            		else{accountRec.ZTS_EU_State_County__c = null;}
                	List<recordtype> rectypeList = [select id from recordtype where developername = : a_req.recordtype and SobjectType='Account'];
           			if(rectypeList.size()>0){accountRec.recordtypeid = rectypeList[0].id;}
            
            		awrapper_resp.email=a_req.email;
                    awrapper_resp.Name=a_req.Name;
                    awrapper_resp.Phone=a_req.Phone;
                    awrapper_resp.send_Owner_Reminders=a_req.send_Owner_Reminders;
                    awrapper_resp.isEmailOptOut=a_req.isEmailOptOut;
                    awrapper_resp.emailOptOutDate=a_req.emailOptOutDate;
                    awrapper_resp.city=a_req.city;
                    awrapper_resp.zipcode=a_req.zipcode;
                    awrapper_resp.district=a_req.district;
                    awrapper_resp.subtype=a_req.subtype;
                    awrapper_resp.account_type=a_req.account_type;
                    awrapper_resp.country=a_req.country;
                    awrapper_resp.market=a_req.market;
                    awrapper_resp.email_preference=a_req.email_preference;
                    awrapper_resp.addressLine1=a_req.addressLine1;
                    awrapper_resp.addressLine2=a_req.addressLine2;
            		if(statecountyList.size()>0){awrapper_resp.statecounty=statecountyList[0].id;}
                    awrapper_resp.statecountyval=a_req.statecountyval;
                    awrapper_resp.account_status=a_req.account_status;
                    awrapper_resp.rep_account_status=a_req.rep_account_status;
            		awrapper_resp.inactive_reason=a_req.inactive_reason;
                    awrapper_resp.tsfpbc=a_req.tsfpbc;
                    awrapper_resp.owner_id=a_req.owner_id;
                    awrapper_resp.preferred_Language=a_req.preferred_Language;
                    awrapper_resp.Potential_Region=a_req.Potential_Region;
            		awrapper_resp.recordtype = a_req.recordtype;
           			awrapper_resp.ext_id = a_req.ext_id;
            		awrapper_resp.zoetis_sfdc_id = a_req.zoetis_sfdc_id;
            
            try{
            		update accountRec;
            		lstAccountToReturn.add(accountRec);
            		
                
                	res.addHeader('Content-Type','application/json');
                    res.StatusCode = 201;
                	system.debug(awrapper_resp);
                    String JSONMsg1= JSON.serialize(awrapper_resp);
                    system.debug(JSONMsg1);
                    awrapper_resp.message ='Your Account record updated successfully';
                    awrapper_resp.status = 'Success';
                    system.debug('Response Code'+res.statusCode);
                
                    if (res.statusCode==201)
                    {
                        system.debug('Successfully Inserted');
                        res.addHeader('Content-Type','application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(awrapper_resp,true));
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
                    awrapper_resp.message = e.getMessage();
                    awrapper_resp.errorcode = 500;
                    awrapper_resp.status = 'Failure';
                    system.debug('Error occurred'+res.responsebody);
                    ErrorLog_CrownPeak__c errortable = new ErrorLog_CrownPeak__c();
                    errortable.Details__c = JSON.serialize(awrapper_resp);
                    errortable.Status__c = 'Failure';
                    insert errortable;
                    return null;                
            }
        }
    
     return lstAccountToReturn; 
       
        
    }
 
@httppost
  global static list<Account> dopost(){
        
        RestRequest req = RestContext.request;
    	RestResponse res = RestContext.response;
              
    	accountWrapperResp awrapper_resp = new accountWrapperResp();
        List<Account> lstAccountToReturn = new List<Account>();
        accountWrapperReq a_req = (accountWrapperReq) JSON.deserializeStrict(req.requestBody.toString(), accountWrapperReq.class);
        List<State_Country__c> statecountyList = new List<State_Country__c>(); 
      	
           system.debug('Initial Json'+a_req);
           Account accountRec = new Account();
       				accountRec.Email__c=a_req.email;
                    accountRec.Name=a_req.Name;
                    accountRec.ZTS_EU_Main_Phone__c=a_req.Phone;
                    accountRec.Send_Owner_Reminders__c=a_req.send_Owner_Reminders;
                    accountRec.ZTS_EU_Opt_Out_Email__c=a_req.isEmailOptOut;
                    accountRec.ZTS_EU_Opt_Out_Date_Email__c=a_req.emailOptOutDate;
                    accountRec.ZTS_EU_City__c=a_req.city;
                    accountRec.ZTS_EU_Zip_Postal_Code__c=a_req.zipcode;
                    accountRec.ZTS_EU_District__c=a_req.district;
                    accountRec.ZTS_EU_Sub_Type__c=a_req.subtype;
                    accountRec.Type=a_req.account_type;
                    accountRec.ZTS_EU_Country__c=a_req.country;
                    accountRec.ZTS_EU_Market__c=a_req.market;
                    accountRec.Email_Preference__c=a_req.email_preference;
                    accountRec.ZTS_EU_Address_Line_1__c=a_req.addressLine1;
                    accountRec.ZTS_EU_Address_Line_2__c=a_req.addressLine2;
                    accountRec.ZTS_EU_Account_Status__c=a_req.account_status;
                    accountRec.ZTS_EU_Rep_Account_Status__c=a_req.rep_account_status;
      				accountRec.ZTS_EU_Reason__c = a_req.inactive_reason;
                    accountRec.ZTS_EU_TSF_PBC__c=a_req.tsfpbc;
                    accountRec.OwnerID=a_req.owner_id;
                    accountRec.ZTS_EU_Preferred_Language__c=a_req.preferred_Language;
                    accountRec.ZTS_EU_Potential_Region__c=a_req.Potential_Region;
      				if(a_req.statecountyval != '')
                    {
                        statecountyList =[Select id from State_Country__c where Name = :a_req.statecountyval and ZTS_EU_Country__c = :a_req.country];
                        if(statecountyList.size()>0){accountRec.ZTS_EU_State_County__c = statecountyList[0].id;}
                    }
      				else{accountRec.ZTS_EU_State_County__c = null;}
            		List<recordtype> rectypeList = [select id from recordtype where developername = : a_req.recordtype and SobjectType='Account'];
           			if(rectypeList.size()>0){accountRec.recordtypeid = rectypeList[0].id;}
           			accountRec.ZTS_EU_Customer_ID__c = a_req.ext_id;
      
      				awrapper_resp.email=a_req.email;
                    awrapper_resp.Name=a_req.Name;
                    awrapper_resp.Phone=a_req.Phone;
                    awrapper_resp.send_Owner_Reminders=a_req.send_Owner_Reminders;
                    awrapper_resp.isEmailOptOut=a_req.isEmailOptOut;
                    awrapper_resp.emailOptOutDate=a_req.emailOptOutDate;
                    awrapper_resp.city=a_req.city;
                    awrapper_resp.zipcode=a_req.zipcode;
                    awrapper_resp.district=a_req.district;
                    awrapper_resp.subtype=a_req.subtype;
                    awrapper_resp.account_type=a_req.account_type;
                    awrapper_resp.country=a_req.country;
                    awrapper_resp.market=a_req.market;
                    awrapper_resp.email_preference=a_req.email_preference;
                    awrapper_resp.addressLine1=a_req.addressLine1;
                    awrapper_resp.addressLine2=a_req.addressLine2;
      				if(statecountyList.size()>0){awrapper_resp.statecounty=statecountyList[0].id;}
      				awrapper_resp.statecountyval=a_req.statecountyval;
                    awrapper_resp.account_status=a_req.account_status;
                    awrapper_resp.rep_account_status=a_req.rep_account_status;
      				awrapper_resp.inactive_reason=a_req.inactive_reason;
                    awrapper_resp.tsfpbc=a_req.tsfpbc;
                    awrapper_resp.owner_id=a_req.owner_id;
                    awrapper_resp.preferred_Language=a_req.preferred_Language;
                    awrapper_resp.Potential_Region=a_req.Potential_Region;
            		awrapper_resp.recordtype = a_req.recordtype;
           			awrapper_resp.ext_id = a_req.ext_id;
      try{
            insert accountRec;
        	system.debug(accountRec);
        	lstAccountToReturn.add(accountRec);
        	system.debug(lstAccountToReturn);
          
           	res.addHeader('Content-Type','application/json');
          	res.StatusCode = 201;
        
        
        			
        
            system.debug(awrapper_resp);
            String JSONMsg1= JSON.serialize(awrapper_resp);
            system.debug(JSONMsg1);
            awrapper_resp.message ='Your Account record inserted successfully';
            awrapper_resp.status = 'Success';
            system.debug('Response Code'+res.statusCode);
        
            if (res.statusCode==201)
            {
                system.debug('Successfully Inserted');
                res.addHeader('Content-Type','application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(awrapper_resp,true));
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
            awrapper_resp.message = e.getMessage();
            awrapper_resp.errorcode = 500;
            awrapper_resp.status = 'Failure';
            system.debug('Error occurred'+res.responsebody);
            ErrorLog_CrownPeak__c errortable = new ErrorLog_CrownPeak__c();
            errortable.Details__c = JSON.serialize(awrapper_resp);
            errortable.Status__c = 'Failure';
            insert errortable;
            return null;
        }
        
        return lstAccountToReturn;
  
  }

    
 
  global class accountWrapperReq{
     
      public string email;
      public string Name;
      public string Phone;
      public boolean send_Owner_Reminders;
      public boolean isEmailOptOut;
      public Date emailOptOutDate;
      public string city;
      public string zipcode;
      public string district;
      public string subtype;
      public string account_type;
      public string country;
      public string market;
      public string email_preference;
      public string addressLine1;
      public string addressLine2;
      public Id statecounty;
      public string statecountyval;
      public string account_status;
      public string rep_account_status;
      public string inactive_reason;
      public string tsfpbc;
      public string preferred_Language;
	  public string Potential_Region;
      public string zoetis_sfdc_id;
      public string owner_id;
      public string recordtype;
      public string ext_id;
      
      global accountWrapperReq(){
             
         }
  }
  
  
  global class accountWrapperResp{
      public string email;
      public string Name;
      public string Phone;
      public boolean send_Owner_Reminders;
      public boolean isEmailOptOut;
      public Date emailOptOutDate;
      public string city;
      public string zipcode;
      public string district;
      public string subtype;
      public string account_type;
      public string country;
      public string market;
      public string email_preference;
      public string addressLine1;
      public string addressLine2;
      public Id statecounty;
      public string statecountyval;
      public string account_status;
      public string rep_account_status;
      public string inactive_reason;
      public string tsfpbc;
      public string preferred_Language;
	  public string Potential_Region;
      public string zoetis_sfdc_id;
      public string owner_id;
      public string recordtype;
      public string ext_id;
      public  string message;
      public  Integer errorcode;
      public string status;
  
      global accountWrapperResp(){
      
  		}
  }

    
    

}