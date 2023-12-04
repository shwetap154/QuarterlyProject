//Batch apex to send email alert to Distributor For stock and forecast Submission
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
//Alpha-24
global class alpha_StockAndForecastReminder_Batch implements Database.Batchable<sObject> {
 
    global Database.QueryLocator start( Database.BatchableContext BC ) {
 //Getting Custom settings
 		Map<string,AlphaMarketCountry__c> csMap = new Map<string,AlphaMarketCountry__c> ();
        Map<String, AlphaMarketCountry__c> mcsMap = AlphaMarketCountry__c.getAll();
        system.debug(mcsMap);
        for(String str : mcsMap.keyset()){
            csMap.put(mcsMap.get(str).Market__c,mcsMap.get(str));
        }
        Set<String> Idset = csMap.keyset();
        
        String query = 'SELECT Id,Name,ZTS_EU_Market__c from Account where ZTS_EU_Market__c IN:  Idset ' ;
        return Database.getQueryLocator( query );
 
    }
   
    global void execute( Database.BatchableContext BC, List< Account > scope ) {
        system.debug('scope>>>'+scope);
 		Map<string,List<string>> ConEmailList = new Map<string,List<string>>();
        Map<string,string> csMap = new Map<string,string> ();
        Map<string,Contact> ConMap = new Map<string,Contact>();
        List<Messaging.SingleEmailMessage> DistributorEmails = new List<Messaging.SingleEmailMessage>();
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
            csMap.put(mcsMap.get(str).Market__c+'_'+mcsMap.get(str).Country__c,str);
        }
        
        if(scope.size()>0){
            for(Contact Eachcon: [Select id,Account.ZTS_EU_Market__c, Account.ZTS_EU_Country__c,email,Send_Alert_For_Forecast__c,Send_Alert_For_Stock__c from Contact where accountId In: scope and (Send_Alert_For_Forecast__c = true OR Send_Alert_For_Stock__c = true) ]){
                if(ConEmailList.containsKey(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c)) {
                        List<String> usersId = ConEmailList.get(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c);
                        if(EachCon.Email != null){
                            usersId.add(Eachcon.Email);
                        }
                        ConEmailList.put(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c, usersId);
                    } else {
                        if(Eachcon.Email != null)
                        ConEmailList.put(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c, new List<string> { Eachcon.Email });
                    }
                if(Eachcon.Email != null)
                ConMap.put(Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c,Eachcon);
            }
        }
        system.debug(ConEmailList);
        String[] toAddresses ;
        EmailTemplate emailTemplateStockForecastReminder;
        EmailTemplate emailTemplateStockForecastReminderSpanish;
        for(EmailTemplate objTemplate: [Select Id,Subject,Name,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name IN ('Distributor Stock And Forecast Update Reminder Template','Distributor Stock And Forecast Update Reminder Template - Spanish')]){
            if(objTemplate.Name=='Distributor Stock And Forecast Update Reminder Template'){
                emailTemplateStockForecastReminder= objTemplate;
            }
            else if(objTemplate.Name=='Distributor Stock And Forecast Update Reminder Template - Spanish'){
                emailTemplateStockForecastReminderSpanish= objTemplate; 
            }
        }
        
        for(String eachStr : ConEmailList.keyset()){
                //Mail To DL
                for(String str : ConEmailList.get(eachStr)){
                	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTreatTargetObjectAsRecipient( false );
                    email.setTargetObjectId(ConMap.get(eachStr).Id); 
                    toAddresses = new List<string>();
                            		if(str != null)
                            		toAddresses.add(str);
                            		system.debug(toAddresses);
                                    email.setToAddresses(toAddresses);
                    
                    //Set Email Template Id
                    list<string> lstMarket = eachStr.split('_');
                    if(lstMarket[0] == 'Panama' || lstMarket[0] == 'Costa Rica'){
                        email.setTemplateID(emailTemplateStockForecastReminderSpanish.Id);
                    }
                    else{
                        email.setTemplateID(emailTemplateStockForecastReminder.Id);
                    }  					
                    //Set email sender with the fetched org wide email address(SC-008980)
                    if (!orgAddresses.isEmpty()) {
                        email.setOrgWideEmailAddressId(orgAddresses[0].Id);
                    }
                    DistributorEmails.add(email);
                    toAddresses.clear();
                }
        }
        //Send email to Distributors - SC-008980 (moved this code out of for loop to avoid email invocation limit)
        try{
            Messaging.sendEmail(DistributorEmails,false);
         
            system.debug('Email Sent>>>>>>>>>>>>>>>>>');
        }catch(exception e){
            system.debug(e.getMessage());
        }
    }   
    
    global void finish( Database.BatchableContext BC ) {
    }
 
}