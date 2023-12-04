//Batch apex to send email alert to Distributor,CL,Service Agent For  Stock Update
//Created By: Suvankar
//Updated by: Aritra(Cognizant)
//Modification Log:
//---------------------------------------------------------------------------------------------------------------------------------------
// Developer                Date               Description
//---------------------------------------------------------------------------------------------------------------------------------------
// Aritra(Cognizant)       10/25/2021          Updated the sender email with Org Wide Email Address (SC-008980)
// --------------------------------------------------------------------------------------------------------------------------------------
// Mahendra(Cognizant)	   12/06/2021		   Moved the send email logic out side of the loop (SC-008980)
//*****************************************************************************************************************************************/
//Alpha-50
global class alpha_UpdateStockEmailAlert_Batch implements Database.Batchable<sObject> {
 
    global Database.QueryLocator start( Database.BatchableContext BC ) {
 
        String query = 'SELECT Id,Name,Account__c,Account__r.Id,Account__r.ZTS_EU_Market__c, Account__r.ZTS_EU_Country__c FROM Stock__c where (createddate = LAST_N_DAYS:7 )' ;
        return Database.getQueryLocator( query );
 
    }
   
    global void execute( Database.BatchableContext BC, List< Stock__c > scope ) {
        system.debug('scope>>>>'+scope);
 		List<Stock__History> StockHistList = new List<Stock__History>();
        Map<string,List<Stock__c>> StockMarketCountrymap = new Map<string,List<Stock__c>>();
        Map<string,List<string>> ConEmailMap = new Map<string,List<string>>();
        Map<string,Contact> ConMap = new Map<string,Contact>();
        Map<string,Contact> ConDistMap = new Map<string,Contact>();
        Map<string,AlphaMarketCountry__c> csMap = new Map<string,AlphaMarketCountry__c> ();
        Set<Id> accIdList = new Set<Id>();
        Map<string,boolean> conEmailToCheck = new Map<string,boolean>();
        List<Messaging.SingleEmailMessage> DistributorEmails = new List<Messaging.SingleEmailMessage>();
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
            for(Stock__c eachstock : scope){
                accIdList.add(eachstock.Account__r.Id);
                
            }
            StockHistList = [SELECT Id FROM Stock__History where createddate = LAST_N_DAYS:7];
        }
        
        for(Contact Eachcon: [Select id,ZTS_EU_Market__c,Account.ZTS_EU_Market__c, Account.ZTS_EU_Country__c,email,accountId,Send_Alert_For_Stock__c from Contact where accountId In: accIdList ]){
            if(ConEmailMap.containsKey(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c)) {
                    List<String> usersId = ConEmailMap.get(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c);
                    if(Eachcon.Email != null)
                	usersId.add(Eachcon.Email);
                    ConEmailMap.put(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c, usersId);
                } else {
                    if(Eachcon.Email != null)
                    ConEmailMap.put(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c, new List<string> { Eachcon.Email });
                }
            if(Eachcon.Email != null)
            ConMap.put(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c+'_'+Eachcon.Email,Eachcon);
            if(Eachcon.Email != null)
            ConDistMap.put(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c,Eachcon);
            if(Eachcon.Email != null)
            conEmailToCheck.put(Eachcon.Email,Eachcon.Send_Alert_For_Stock__c);
        }
 system.debug(scope);
        if(StockHistList.size()>0){
            for(Stock__c eachFr : scope){
                if(StockMarketCountrymap.containsKey(eachFr.Account__r.ZTS_EU_Market__c+'_'+eachFr.Account__r.ZTS_EU_Country__c)) {
                    List<Stock__c> usersId = StockMarketCountrymap.get(eachFr.Account__r.ZTS_EU_Market__c+'_'+eachFr.Account__r.ZTS_EU_Country__c);
                    usersId.add(eachFr);
                    StockMarketCountrymap.put(eachFr.Account__r.ZTS_EU_Market__c+'_'+eachFr.Account__r.ZTS_EU_Country__c, usersId);
                } else {
                    StockMarketCountrymap.put(eachFr.Account__r.ZTS_EU_Market__c+'_'+eachFr.Account__r.ZTS_EU_Country__c, new List<Stock__c> { eachFr });
                }
            }
            system.debug('StockMarketCountrymap>>>'+StockMarketCountrymap);
            EmailTemplate emailTemplate;
            EmailTemplate emailTemplateCSCL;
            EmailTemplate emailTemplateSTSpanish;
            EmailTemplate emailTemplateDST;
            for(EmailTemplate template: [SELECT Id,Name,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE Name in ('Distributor Stock Update Weekly Template','Zoetis Internal Stock Update Weekly Template','Zoetis Internal Stock Update Weekly Template - Spanish','Distributor Stock Update Weekly Template - Spanish')  OR DeveloperName IN ('Zoetis_Internal_Stock_Update_Weekly_Template')]){
                if(template.Name=='Distributor Stock Update Weekly Template'){
                    emailTemplate = template;
                }
            else if(template.DeveloperName=='Zoetis_Internal_Stock_Update_Weekly_Template'){
                emailTemplateCSCL = template; 
                }
            else if(template.Name=='Zoetis Internal Stock Update Weekly Template - Spanish'){
                emailTemplateSTSpanish = template;
                }
            else if(template.Name=='Distributor Stock Update Weekly Template - Spanish'){
                emailTemplateDST = template;
                }
            }
            String[] toAddresses ;
            for(String eachStr : ConEmailMap.keyset()){
                system.debug(eachStr);
                //Mail To DL
                if(ConEmailMap.size()>0 && ConEmailMap.containskey(eachStr) && StockMarketCountrymap.size()>0 && StockMarketCountrymap.containskey(eachStr) && StockMarketCountrymap.get(eachStr).size()>0) {
                    system.debug(ConEmailMap.get(eachStr));
                    
                    
                     
                        for(String str : ConEmailMap.get(eachStr)){
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            		email.setTreatTargetObjectAsRecipient( false );
                        			email.setTargetObjectId(ConMap.get(eachStr+'_'+str).Id); 
                            		//email.setWhatId(param1);
                           			toAddresses = new List<string>();
                            		if(str != null && conEmailToCheck.containskey(str) && conEmailToCheck.get(str)==true)
                            		toAddresses.add(str);
                            		system.debug(toAddresses);
                                    email.setToAddresses(toAddresses);
                                    Contact tempcon = ConMap.get(eachStr+'_'+str);
                                    if(tempcon.ZTS_EU_Market__c == 'Panama' || tempcon.ZTS_EU_Market__c == 'Costa Rica'){
                                        email.setTemplateID(emailTemplateDST.Id); 
                                    }
                                    else{
                                        email.setTemplateID(emailTemplate.Id); 
                                    }
                            		//Set email sender with the fetched org wide email address(SC-008980)
                                    if (!orgAddresses.isEmpty()) {
                                        email.setOrgWideEmailAddressId(orgAddresses[0].Id);
                                    }
                            if(str != null && conEmailToCheck.containskey(str) && conEmailToCheck.get(str)==true)
                                    DistributorEmails.add(email);
                           toAddresses.clear();
                    	}
                         
                    
                    
                }
                //Mail To CL & CS
                if(csMap.size()>0 && csMap.containskey(eachStr) && StockMarketCountrymap.size()>0 &&StockMarketCountrymap.containskey(eachStr) && StockMarketCountrymap.get(eachStr).size()>0){
					
                    if(csMap.containskey(eachStr) ){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTreatTargetObjectAsRecipient( false );
                        email.setTargetObjectId(ConDistMap.get(eachStr).Id);
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
                        email.setWhatId(ConDistMap.get(eachStr).accountId);
                        if(csMap.get(eachStr).Language__c == 'es'){
                            email.setTemplateID(emailTemplateSTSpanish.Id);
                        }
                        else{
                            email.setTemplateID(emailTemplateCSCL.Id);
                        }
                        //Set email sender with the fetched org wide email address(SC-008980)
                        if (!orgAddresses.isEmpty()) {
                            email.setOrgWideEmailAddressId(orgAddresses[0].Id);
                        }
                        CSCLEmails.add(email);
                        toAddresses.clear();
                    }
                    
                    
                    

                }                
            }
            
            //Send email to Distributors - SC-008980 (moved this code out of for loop to avoid email invocation limit)
            try{
                Messaging.sendEmail(DistributorEmails);
                system.debug('Email sent>>>>>>>>>>>');
            }catch(exception e){
                system.debug(e.getMessage());
            }
            
            //Send email to CS/CL - SC-008980 (moved this code out of for loop to avoid email invocation limit)
            try{
                Messaging.sendEmail(CSCLEmails);
                system.debug('Email sent>>>>>>>>>>>');
            }catch(exception e){
                system.debug(e.getMessage());
            }
        }
    }   
    
    global void finish( Database.BatchableContext BC ) {
    }
 
}