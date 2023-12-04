//Batch apex to send email alert to Distributor For Order Submission
//Created By: Suvankar
//Updated by: Aritra(Cognizant)
//Modification Log:
//---------------------------------------------------------------------------------------------------------------------------------------
// Developer                Date               Description
//---------------------------------------------------------------------------------------------------------------------------------------
// Aritra(Cognizant)       10/25/2021          Updated the sender email with Org Wide Email Address (SC-008980)
// --------------------------------------------------------------------------------------------------------------------------------------
// Mahendra(Cognizant)	   12/06/2021		   Moved the send email logic out side of the loop (SC-008980)
// --------------------------------------------------------------------------------------------------------------------------------------
// Kalyan Nayak(Deloitte)  10/17/2023		   Bulkified the class as part of TPDEV-2185
//*****************************************************************************************************************************************/
//Alpha-30
global class alpha_OrderSubmissionReminder_Batch implements Database.Batchable<sObject> {
 
    global Database.QueryLocator start( Database.BatchableContext BC ) {
 //Getting Custom settings
 		Map<string,AlphaMarketCountry__c> csMap = new Map<string,AlphaMarketCountry__c> ();
        Map<String, AlphaMarketCountry__c> mcsMap = AlphaMarketCountry__c.getAll();
        system.debug(mcsMap);
        for(String str : mcsMap.keyset()){
            csMap.put(mcsMap.get(str).Market__c,mcsMap.get(str));
        }
        Set<String> Idset = csMap.keyset();
        String query = 'SELECT Id,Name,ZTS_EU_Market__c from Account where ZTS_EU_Market__c IN:  Idset  ' ;
        //String query = 'SELECT Id,Name from Account where Id = \'0011g00000u7SSd\'  ' ;
        return Database.getQueryLocator( query );
 
    }
   
    global void execute( Database.BatchableContext BC, List< Account > scope ) {
        system.debug('scope>>>'+scope);
        Map<string,List<Contact>> ConEmailList = new Map<string,List<Contact>>();//TPDEV-2185 Bulkified ConEmailList to store list of Contact instead of String.
		Map<Id,Contact> ConMAP = new Map<Id,Contact>();//TPDEV-2185 Bulkified ConEmailList to store list of Contact instead of String.
        Map<string,string> csMap = new Map<string,string> ();
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
            for(Contact Eachcon: [Select id,ZTS_EU_Market__c,Account.ZTS_EU_Market__c, Account.ZTS_EU_Country__c,email,Selected_For_Alert__c from Contact where accountId In: scope  and Selected_For_Alert__c = true]){
               system.debug('contact::'+Eachcon);
                if(ConEmailList.containsKey(Eachcon.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c)) {
                    	List<Contact> usersId = ConEmailList.get(Eachcon.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c);
                        //TPDEV-2185: Updated Eachcon.Email to Eachcon 
                        if(EachCon.Email != null){
                            usersId.add(Eachcon);
                        }
                        ConEmailList.put(Eachcon.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c, usersId);
                    } else {
                        if(Eachcon.Email != null)
                        //ConEmailList.put(Eachcon.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c, new List<string> { Eachcon.Email });
                        ConEmailList.put(Eachcon.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Market__c+'_'+Eachcon.Account.ZTS_EU_Country__c, new List<Contact> { Eachcon });
                    }
                if(Eachcon.Email != null)
                ConMap.put(Eachcon.Id,Eachcon);
            }
        }
        system.debug(ConEmailList);
        String[] toAddresses ;
        EmailTemplate emailTemplateOR;
        EmailTemplate emailTemplateORSpanish;
        for(EmailTemplate template: [SELECT Id,Name,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE Name in ('Distributor Order Submission Reminder Template','Distributor Order Submission Reminder Template - Spanish')]){
            if(template.Name=='Distributor Order Submission Reminder Template'){
             emailTemplateOR= template;
            }
        else if(template.Name=='Distributor Order Submission Reminder Template - Spanish'){
        	emailTemplateORSpanish= template; 
        	}
        }
        for(String eachStr : ConEmailList.keyset()){
                //Mail To DL
                for(Contact str : ConEmailList.get(eachStr)){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTreatTargetObjectAsRecipient( false );
                    email.setTargetObjectId(ConMap.get(Str.Id).Id);//TPDEV-2185  
                    toAddresses = new List<string>();
                                    if(str != null)
                                    toAddresses.add(str.Email);//TPDEV-2185
                                    system.debug(toAddresses);
                                    email.setToAddresses(toAddresses);
                    list<string> templst = eachStr.split('_');
                    if(templst[0] == 'Panama' || templst[0] == 'Costa Rica'){
                        email.setTemplateID(emailTemplateORSpanish.Id);
                    }
                    else{
                        email.setTemplateID(emailTemplateOR.Id);
                    } 
                    //Set email sender with the fetched org wide email address(SC-008980)
                    if (!orgAddresses.isEmpty()) {
                        email.setOrgWideEmailAddressId(orgAddresses[0].Id);
                    }
                    DistributorEmails.add(email);
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