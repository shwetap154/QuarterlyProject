//Batch apex to send email alert to Distributor,CL,Service Agent For  forecast Update
//Created By: Suvankar
//Updated by: Aritra(Cognizant)
//Modification Log:
//---------------------------------------------------------------------------------------------------------------------------------------
// Developer                Date               Description
//---------------------------------------------------------------------------------------------------------------------------------------
// Aritra(Cognizant)       10/25/2021          Updated the sender email with Org Wide Email Address (SC-008980)
// --------------------------------------------------------------------------------------------------------------------------------------
// Mahendra(Cognizant)	   12/06/2021		   Removed the filter in the query to fetch all contacts irrespective of the send alert 
// 											   flags and Moved the send email logic out side of the loop (SC-008980)
//*****************************************************************************************************************************************/
//Alpha-29


global class alpha_UpdateForecastEmailAlert_Batch implements Database.Batchable<sObject> {
 
    global Database.QueryLocator start( Database.BatchableContext BC ) {
 
        String query = 'SELECT Id,Name,Account__c,Account__r.ZTS_EU_Market__c, Account__r.ZTS_EU_Country__c FROM Forecast__c where (LastModifieddate = LAST_N_DAYS:7 )' ;
        //String query = 'SELECT Id,Name,Account__c,Account__r.ZTS_EU_Market__c, Account__r.ZTS_EU_Country__c FROM Forecast__c where Account__r.Id= \'0011g00000u7SSd\'  ' ;
        
         
        return Database.getQueryLocator( query );
 
    }
   
 global void execute( Database.BatchableContext BC, List< Forecast__c > scope ) {
        
        List<Forecast__History> forecastHistList = new List<Forecast__History>();
        Map<string,List<Forecast__c>> ForecastMarketCountrymap = new Map<string,List<Forecast__c>>();
        Map<string,List<string>> ConEmailList = new Map<string,List<string>>();
        Map<string,Contact> ConMap = new Map<string,Contact>();
        Map<string,AlphaMarketCountry__c> csMap = new Map<string,AlphaMarketCountry__c> ();
        Map<string,List<Forecast__c>> ForecastAccMap = new Map<string,List<Forecast__c>>();
     	List<Messaging.SingleEmailMessage> CSCLEmails = new List<Messaging.SingleEmailMessage>();
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
        for(Contact Eachcon: [Select id,email,Account.ZTS_EU_Market__c, Account.ZTS_EU_Country__c,Send_Alert_For_Forecast__c from Contact where accountId In: ForecastAccMap.keyset()]){
            //SC-008980 - Removed the filter (Send_Alert_For_Forecast__c=true) to send email notifications to the internal users(CS/CL)
            //irrespective of setting the send alert flags at contact level
            if(ConEmailList.containsKey(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c)) {
                    List<String> usersId = ConEmailList.get(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c);
                    if(Eachcon.Email != null)  
                    usersId.add(Eachcon.Email);
                    ConEmailList.put(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c, usersId);
                } else {
                if(Eachcon.Email != null)  
                    ConEmailList.put(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c, new List<string> { Eachcon.Email });
                }
            if(Eachcon.Email != null) 
            ConMap.put(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c,Eachcon);
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
            
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Distributor New Forecast Weekly Template'];
            EmailTemplate emailTemplateCSCL = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Zoetis Internal Update Forecast Weekly Template'];
            String[] toAddresses ;
            for(String eachStr : ConEmailList.keyset()){
                system.debug(ConEmailList.get(eachStr));
                //Mail To DL
                /*if(csMap.size()>0 && csMap.containskey(eachStr) && ForecastMarketCountrymap.size()>0 &&ForecastMarketCountrymap.containskey(eachStr) && ForecastMarketCountrymap.get(eachStr).size()>0) {
                    if(ConEmailList.get(eachStr) != null){
                        for(String str : ConEmailList.get(eachStr)){
                                    email.setTargetObjectId(ConMap.get(eachStr).Id); 
                                    toAddresses = new List<string>();
                                    toAddresses.add(str);
                            system.debug(toAddresses);
                                    email.setToAddresses(toAddresses);
                                    
                                    email.setTemplateID(emailTemplate.Id); 
                                    
                                    
                                    try{
                                        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                                        system.debug('Email sent>>>>>>>>>>>');
                                    }catch(exception e){
                                        system.debug(e.getCause());
                                    }
                           toAddresses.clear();
                        }
                         
                    }
                    
                }*/
                //Mail To CL & CS
                if(csMap.size()>0 && csMap.containskey(eachStr) && ForecastMarketCountrymap.size()>0 &&ForecastMarketCountrymap.containskey(eachStr) && ForecastMarketCountrymap.get(eachStr).size()>0){
                    if(csMap.containskey(eachStr) ){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTreatTargetObjectAsRecipient( false );
                        email.setTargetObjectId(ConMap.get(eachStr).Id);
                        toAddresses = new List<string>();
                        if(csMap.get(eachStr).CL_Email__c != null)
                        toAddresses.add(csMap.get(eachStr).CL_Email__c);
                        if(csMap.get(eachStr).CS_Agent_Email__c != null)
                        toAddresses.add(csMap.get(eachStr).CS_Agent_Email__c);
                        if(csMap.get(eachStr).CL_2_Email__c != null)
                        toAddresses.add(csMap.get(eachStr).CL_2_Email__c);
                        if(csMap.get(eachStr).CL_3_Email__c != null)
                        toAddresses.add(csMap.get(eachStr).CL_3_Email__c);
                        if(csMap.get(eachStr).CL_4_Email__c != null)
                        toAddresses.add(csMap.get(eachStr).CL_4_Email__c);
                        if(csMap.get(eachStr).CL_5_Email__c != null)
                        toAddresses.add(csMap.get(eachStr).CL_5_Email__c);
                        if(csMap.get(eachStr).CS_Agent_2_Email__c != null)
                        toAddresses.add(csMap.get(eachStr).CS_Agent_2_Email__c);
                        if(csMap.get(eachStr).CS_Agent_3_Email__c != null)
                        toAddresses.add(csMap.get(eachStr).CS_Agent_3_Email__c);
                        if(csMap.get(eachStr).CS_Agent_4_Email__c != null)
                        toAddresses.add(csMap.get(eachStr).CS_Agent_4_Email__c);
                        if(csMap.get(eachStr).CS_Agent_5_Email__c != null)
                        toAddresses.add(csMap.get(eachStr).CS_Agent_5_Email__c);

                        system.debug(toAddresses);
                        email.setToAddresses(toAddresses);
                        email.setWhatId(ConMap.get(eachStr).accountId);
                        email.setTemplateID(emailTemplateCSCL.Id);
                        //Set email sender with the fetched org wide email address(SC-008980)
                        if (!orgAddresses.isEmpty()) {
                            email.setOrgWideEmailAddressId(orgAddresses[0].Id);
                        }
                        CSCLEmails.add(email);
                        
                        toAddresses.clear();
                    }

                }                
            }
            
            //SC-008980 - moved this code out of the for loop to avoid email invocation limit
            try{
                Messaging.sendEmail(CSCLEmails);
            }catch(exception e){
                system.debug(e.getMessage());
            }
        }
    }   
    
    global void finish( Database.BatchableContext BC ) {
    }
 
}