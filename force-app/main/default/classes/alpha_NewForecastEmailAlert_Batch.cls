//Batch apex to send email alert to Distributor,CL,Service Agent For new forecast
//Created By: Suvankar
//Updated by: Aritra(Cognizant)
//Modification Log:
//---------------------------------------------------------------------------------------------------------------------------------------
// Developer                Date               Description
//---------------------------------------------------------------------------------------------------------------------------------------
// Aritra(Cognizant)       10/25/2021          Updated the sender email with Org Wide Email Address (SC-008980)
// --------------------------------------------------------------------------------------------------------------------------------------
// Mahendra(Cognizant)	   12/06/2021		   Updated the email notification logic to notify CS/CL irrespecitve of Send Alert Flags and
// 											   moved the send email logic out side of loop (SC-008980)
//*****************************************************************************************************************************************/
//Alpha-10

global class alpha_NewForecastEmailAlert_Batch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        
        
        //Dynamic soql
        String query = 'SELECT Id,Name,Account__c,Account__r.ZTS_EU_Market__c, Account__r.ZTS_EU_Country__c FROM Forecast__c where (createddate = LAST_N_DAYS:7 )' ;
        //single soql
        //String query = 'SELECT Id,Name,Account__c,Account__r.ZTS_EU_Market__c, Account__r.ZTS_EU_Country__c FROM Forecast__c where Account__r.Id= \'0012A00002IffRj\'  '  ;
        
        return Database.getQueryLocator( query );
        
    }
    
	global void execute( Database.BatchableContext BC, List< Forecast__c > scope ) {
        
        List<Forecast__History> forecastHistList = new List<Forecast__History>();
        Map<string,List<Forecast__c>> ForecastMarketCountrymap = new Map<string,List<Forecast__c>>();
        Map<string,List<Contact>> ConEmailList = new Map<string,List<Contact>>();//TPDEV-1875 Bulkified ConEmailList to store list of Contact instead of String.
		Map<Id,Contact> ConMapDL = new Map<Id,Contact>();//TPDEV-1875 changed ConMapDL to store Id and contact.
        Map<string,AlphaMarketCountry__c> csMap = new Map<string,AlphaMarketCountry__c> ();
        Map<string,List<Forecast__c>> ForecastAccMap = new Map<string,List<Forecast__c>>();
        List<Messaging.SingleEmailMessage> DistributorEmails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> CSCLEmails = new List<Messaging.SingleEmailMessage>();
        Map<String, Boolean> sendAlertFlagMap = new Map<String, Boolean>();//SC-008980 - To identify send alert flag is enabled or not
        //Fetch the Org Wide Email addresses(SC-008980)
       
        List<OrgWideEmailAddress> orgAddresses = [
            SELECT Id, Address, DisplayName
            FROM OrgWideEmailAddress
            WHERE Address = 'noreply@zoetis.com'
        ];
        
        //Getting Custom settings
        Map<String, AlphaMarketCountry__c> mcsMap = AlphaMarketCountry__c.getAll();
        system.debug(mcsMap);
        for(String str : mcsMap.keyset()){
            csMap.put(mcsMap.get(str).Market__c+'_'+mcsMap.get(str).Country__c,mcsMap.get(str));
        }
        
        if(scope.size()>0){
            forecastHistList = [SELECT Id FROM Forecast__History where createddate = LAST_N_DAYS:7];
            
            for(Forecast__c eachFr : scope){
                if(ForecastAccMap.containsKey(eachFr.Account__r.Id)) {
                    List<Forecast__c> usersId = ForecastAccMap.get(eachFr.Account__r.Id);
                    usersId.add(eachFr);
                    ForecastAccMap.put(eachFr.Account__r.Id, usersId);
                } else {
                    ForecastAccMap.put(eachFr.Account__r.Id, new List<Forecast__c> { eachFr });
                }
                
            }
        }
        system.debug(ForecastAccMap);
        for(Contact Eachcon: [Select id,Email,Account.ZTS_EU_Market__c, Account.ZTS_EU_Country__c,Send_Alert_For_Forecast__c,ZTS_EU_Market__c from Contact where accountId In: ForecastAccMap.keyset()]){
            //SC-008980 - Removed the filter (Send_Alert_For_Forecast__c = true) from the where clause of the above query to send
            //the email notifications to internal users (CS/CL) irrespective of the flags set at contact level
            if(ConEmailList.containsKey(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c)) {               
                List<Contact> usersId = ConEmailList.get(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c);
                if(Eachcon.Email != null)                   
                      usersId.add(Eachcon);
                ConEmailList.put(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c, usersId);
            } else {
                if(Eachcon.Email != null)   
                    ConEmailList.put(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c, new List<Contact> { Eachcon });
            }

            if(Eachcon.Email != null){
                if(Eachcon.Send_Alert_For_Forecast__c){//SC-008980 - To identify the contacts with send alert flags set as true
                    sendAlertFlagMap.put(Eachcon.Email, true);
                }else{
                    sendAlertFlagMap.put(Eachcon.Email, false);
                }
                ConMapDL.put(Eachcon.Id, Eachcon);                                     
            }
        }      

        system.debug(ConEmailList); 
        if(forecastHistList.size()>0){
            for(Forecast__c eachFr : scope){
                if(ForecastMarketCountrymap.containsKey(eachFr.Account__r.ZTS_EU_Market__c+'_'+eachFr.Account__r.ZTS_EU_Country__c)) {
                    List<Forecast__c> usersId = ForecastMarketCountrymap.get(eachFr.Account__r.ZTS_EU_Market__c+'_'+eachFr.Account__r.ZTS_EU_Country__c);
                    usersId.add(eachFr);
                    ForecastMarketCountrymap.put(eachFr.Account__r.ZTS_EU_Market__c+'_'+eachFr.Account__r.ZTS_EU_Country__c, usersId);
                } else {
                    ForecastMarketCountrymap.put(eachFr.Account__r.ZTS_EU_Market__c+'_'+eachFr.Account__r.ZTS_EU_Country__c, new List<Forecast__c> { eachFr });
                }
            }
            system.debug(ForecastMarketCountrymap.keyset());       
            system.debug(csMap.keyset());
            EmailTemplate emailTemplate,emailTemplateSpanish;
            EmailTemplate emailTemplateCSCL,emailTemplateCSCLSpanish;
                
            for(EmailTemplate template1: [Select Id,name,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Distributor New Forecast Weekly Template' or name = 'Distributor New Forecast Weekly Template - Spanish' ]){
                if(template1.name=='Distributor New Forecast Weekly Template'){
                    emailTemplate=template1;
                }else if(template1.name=='Distributor New Forecast Weekly Template - Spanish'){
                    emailTemplateSpanish=template1;
                }
            }
            
            for(EmailTemplate template2:  [Select Id,name,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Zoetis Internal New Forecast Weekly Template' or name ='Zoetis Internal New Forecast Weekly Template - Spanish']){
                if(template2.name=='Zoetis Internal New Forecast Weekly Template'){
                    emailTemplateCSCL=template2;
                }else if(template2.name=='Zoetis Internal New Forecast Weekly Template - Spanish'){
                    emailTemplateCSCLSpanish=template2;
                }
            }
            
            String[] toAddresses ;
            String[] toAddresses1 ;
            for(String eachStr : ConEmailList.keyset()){
                system.debug(ConEmailList.get(eachStr));
                //Mail To DL
                if( ForecastMarketCountrymap.size()>0 &&ForecastMarketCountrymap.containskey(eachStr) && ForecastMarketCountrymap.get(eachStr).size()>0) {
                    if(ConEmailList.get(eachStr) != null){
                        //Fetching a single contact detail from a list of contact and looped through it-TPDEV 1875
				  		for(Contact str : ConEmailList.get(eachStr)){
                            if(sendAlertFlagMap.containsKey(str.Email) && sendAlertFlagMap.get(str.Email)){
                                system.debug('Email str::'+str);
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                email.setTreatTargetObjectAsRecipient( false );
                                email.setTargetObjectId(ConMapDL.get(str.Id).Id); 
                                
                                toAddresses = new List<string>();
                                toAddresses.clear();
                                toAddresses.add(str.Email);
                                system.debug(toAddresses);
                                email.setToAddresses(toAddresses);
                                
                                
                                //Sending spanish email if market is costa rica or panama as part of TPDEV-1026
                                Contact objcon= ConMapDL.get(str.Id);
                                if(objcon.ZTS_EU_Market__c =='Panama' || objcon.ZTS_EU_Market__c =='Costa Rica')
                                {
                                  email.setTemplateID(emailTemplateSpanish.Id);	                                   
                                }
                                else{
                                    email.setTemplateID(emailTemplate.Id); 
                                }
                                
                                
                                //Set email sender with the fetched org wide email address(SC-008980)
                                if (!orgAddresses.isEmpty()) {
                                    email.setOrgWideEmailAddressId(orgAddresses[0].Id);
                                }
                                DistributorEmails.add(email);                             
                            }
                        }
                    }
                }
               
                //Mail To CL & CS
                if(csMap.size()>0 && csMap.containskey(eachStr) && ForecastMarketCountrymap.size()>0 &&ForecastMarketCountrymap.containskey(eachStr) && ForecastMarketCountrymap.get(eachStr).size()>0){
                    if(csMap.containskey(eachStr) ){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTreatTargetObjectAsRecipient( false );  
                        List<Contact> contacts = ConEmailList.get(eachStr);//Fetched list of contacts and added the first record to send mail.               
						email.setTargetObjectId(contacts[0].Id);
                       	                        
                        toAddresses1 = new List<string>();
                        if(csMap.get(eachStr).CL_Email__c != null)
                            toAddresses1.add(csMap.get(eachStr).CL_Email__c);
                        if(csMap.get(eachStr).CS_Agent_Email__c != null)
                            toAddresses1.add(csMap.get(eachStr).CS_Agent_Email__c);
                        if(csMap.get(eachStr).CL_2_Email__c != null)
                            toAddresses1.add(csMap.get(eachStr).CL_2_Email__c);
                        if(csMap.get(eachStr).CL_3_Email__c != null)
                            toAddresses1.add(csMap.get(eachStr).CL_3_Email__c);
                        if(csMap.get(eachStr).CL_4_Email__c != null)
                            toAddresses1.add(csMap.get(eachStr).CL_4_Email__c);
                        if(csMap.get(eachStr).CL_5_Email__c != null)
                            toAddresses1.add(csMap.get(eachStr).CL_5_Email__c);
                        if(csMap.get(eachStr).CS_Agent_2_Email__c != null)
                            toAddresses1.add(csMap.get(eachStr).CS_Agent_2_Email__c);
                        if(csMap.get(eachStr).CS_Agent_3_Email__c != null)
                            toAddresses1.add(csMap.get(eachStr).CS_Agent_3_Email__c);
                        if(csMap.get(eachStr).CS_Agent_4_Email__c != null)
                            toAddresses1.add(csMap.get(eachStr).CS_Agent_4_Email__c);
                        if(csMap.get(eachStr).CS_Agent_5_Email__c != null)
                            toAddresses1.add(csMap.get(eachStr).CS_Agent_5_Email__c);
                        system.debug(toAddresses1);
                        email.setToAddresses(toAddresses1);                        
                        email.setWhatId(contacts[0].accountId);
                        
                        //Sending Spanish mail for alpha market country custom setting language = es as part of TPDEV-1026 & TPDEV-1012
                        if(csMap.get(eachStr).Language__c == 'es'){
                              email.setTemplateID(emailTemplateCSCLSpanish.Id);
                        }else{
                            email.setTemplateID(emailTemplateCSCL.Id);
                        }
                        
                        //Set email sender with the fetched org wide email address(SC-008980)
                        if (!orgAddresses.isEmpty()) {
                            email.setOrgWideEmailAddressId(orgAddresses[0].Id);
                        }
                        system.debug(email);
                        CSCLEmails.add(email);
                        toAddresses1.clear();
                    }
                    
                }                
            }
            
            //Send email to Distributors - SC-008980 (moved this code out of for loop to avoid email invocation limit)
            try{
                Messaging.sendEmail(DistributorEmails);
            }catch(exception e){
                system.debug(e.getCause());
            }
            
            //Send email to CS/CL - SC-008980 (moved this code out of for loop to avoid email invocation limit)
            try{
                Messaging.sendEmail(CSCLEmails);
            }catch(exception e){
                system.debug(e.getCause());
            }
        }
    }   
    
    global void finish( Database.BatchableContext BC ) {
    }
    
}