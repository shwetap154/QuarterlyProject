/**
* File Name     :  RemoveDealFromQuoteLinesBatchable
* @description  :  Batchable class that implements the logic to remove incorrect deals from QuoteLines.
* @author       :  Ramiro Alvarez @ ATG - Advanced Technology Group.
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     4/23/20        Ramiro Alvarez @ ATG   Created the Class. Added the initial functionality.
* 2.0     5/20/20        Ramiro Alvarez @ ATG   Updated the Class. Added functionality to allow transalations using EmailTemplate.
*/

global class RemoveDealFromQuoteLinesBatchable implements Database.Batchable<sObject> {

    String dealId;
    static final Integer SCHEDULABLE_BATCH_SIZE = 200;

    String query = 'SELECT Id, SBQQ__Quote__c, Vistex_Deal_Header__c,SBQQ__Quote__r.ESign_Agreement__c,SBQQ__Quote__r.ApprovalStatus__c ' +
                    'FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.Is_Ordered__c = FALSE ';

    global RemoveDealFromQuoteLinesBatchable(String dealId) {
        query += 'AND Vistex_Deal_Header__c = \'' + dealId + '\'';
        this.dealId = dealId;
    }   
    
                    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
                
    global void execute(Database.BatchableContext BC, List<SBQQ__QuoteLine__c> scope) {
        System.debug(LoggingLevel.WARN, 'Scope: ' + scope);

        // Get quote Ids
        Set<Id> quoteIds = new Set<Id> ();        
        for (SBQQ__QuoteLine__c quoteline : scope) {
            quoteIds.add(quoteline.SBQQ__Quote__c);
        }

        if (quoteIds.isEmpty()) {
            System.debug('RemoveDealFromQuoteLinesBatchable, no lines to process: return');
            return;
        }

        // Ensure vistex deal is not null
        if (this.dealId != null) {

            //Look into agreeement obj to verify if the quote has a related agreement
            Map<Id,Id> quoteAgreementMap = new Map<Id,Id> ();
            List<echosign_dev1__SIGN_Agreement__c> relatedAgreements = [SELECT Id, Quote__c
                                                    FROM echosign_dev1__SIGN_Agreement__c
                                                    WHERE Quote__c != null AND Quote__c IN :quoteIds
                                                    ORDER BY CreatedDate ASC];

            for (echosign_dev1__SIGN_Agreement__c agreement : relatedAgreements) {
                quoteAgreementMap.put(agreement.Quote__c, agreement.Id);
            }
            System.debug('quoteAgreementMap: ' + quoteAgreementMap);

            List<SBQQ__QuoteLine__c> quotelinesToBeDeleted = new List<SBQQ__QuoteLine__c>();
            Set<Id> quotesToUpdateIds = new Set<Id> ();
            Set<Id> parentQuoteLinesIds = new Set<Id> ();
            Map<Id, String> quoteStatusMap = new Map<Id,String> ();

            for (SBQQ__QuoteLine__c quoteline : scope) {
                // Only add quotelines to list if quote doesn't have any related agreement
                if (!quoteAgreementMap.containsKey(quoteline.SBQQ__Quote__c)) {
                    quotelinesToBeDeleted.add(quoteline);
                    quotesToUpdateIds.add(quoteline.SBQQ__Quote__c);
                    parentQuoteLinesIds.add(quoteline.Id);
                    quoteStatusMap.put(quoteline.SBQQ__Quote__c,quoteline.SBQQ__Quote__r.ApprovalStatus__c);
                }
            }
            // Add child quotelines of those that are ready to be removed
            List<SBQQ__QuoteLine__c> childQuoteLines = [SELECT Id, SBQQ__RequiredBy__c
                                                        FROM SBQQ__QuoteLine__c
                                                        WHERE SBQQ__Quote__c IN :quotesToUpdateIds
                                                        AND (SBQQ__RequiredBy__c IN :parentQuoteLinesIds OR
                                                            (SBQQ__RequiredBy__c != NULL AND SBQQ__RequiredBy__r.SBQQ__RequiredBy__c IN :parentQuoteLinesIds) OR
                                                            (SBQQ__RequiredBy__c != NULL AND SBQQ__RequiredBy__r.SBQQ__RequiredBy__c != NULL AND SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c IN :parentQuoteLinesIds) OR
                                                            (Vistex_Manual_Add_on__c = true OR Vistex_Automatic_Add_on__c = true))
                                                            ];
            System.debug('Child quotelines: ' + childQuoteLines);
            quotelinesToBeDeleted.addAll(childQuoteLines);

            System.debug('quotelines to be deleted: ' + quotelinesToBeDeleted);

            // Delete parent and child quiotelines
            if(quotelinesToBeDeleted.size() > 0) {            
                Database.DeleteResult[] srQuoteLinesDelete = Database.delete(quotelinesToBeDeleted,false);
                for(Database.DeleteResult sr : srQuoteLinesDelete){
                    if(sr.isSuccess()){
                        System.debug('Successfully QuoteLines deleted');                        
                    }
                    else {
                        System.debug('Error trying to delete quotelines: ' + sr.getErrors());
                    }
                }
                
                List<SBQQ__Quote__c> quotesToUpdateList = new List<SBQQ__Quote__c> ();
                
                for (Id quoteId : quotesToUpdateIds) {
                    SBQQ__Quote__c quote = new SBQQ__Quote__c (Id = quoteId);
                    quote.SBQQ__Status__c = 'Draft';
                    quote.Vistex_Price_In_Sync__c = false;
                    if (quoteStatusMap.get(quoteId) == 'Approved') {
                        quote.ApprovalStatus__c = 'Recalled';
                    }                    
                    quotesToUpdateList.add(quote);
                }
                
                update quotesToUpdateList;

                // Update related quotes and send notification
                List<SBQQ__Quote__c> refreshedQuotesList = [SELECT Id, SBQQ__Status__c, SBQQ__SalesRep__c,SBQQ__SalesRep__r.Email,SBQQ__SalesRep__r.Name,ApprovalStatus__c,Vistex_Price_In_Sync__c,SBQQ__SalesRep__r.LanguageLocaleKey
                                                           FROM SBQQ__Quote__c
                                                           WHERE Id IN :quotesToUpdateIds
                                                           ORDER BY SBQQ__SalesRep__r.Email, SBQQ__SalesRep__r.LanguageLocaleKey];              

                List<EmailTemplate> emailTemplateList = [SELECT Id, Body, DeveloperName,Subject
                                                     FROM EmailTemplate
                                                     WHERE DeveloperName LIKE 'Fix_Quotes_%'];                                                     
                
                Map<String,EmailTemplate> languageBodyMap = new Map<String,EmailTemplate> ();
                for (EmailTemplate emailTemplate : emailTemplateList) {
                    languageBodyMap.put(emailTemplate.DeveloperName.substring(11,emailTemplate.DeveloperName.length()),emailTemplate);
                }                

                Map<String,List<SBQQ__Quote__c>> quotesByLangMap = new Map<String,List<SBQQ__Quote__c>> ();                
                for (SBQQ__Quote__c quote : refreshedQuotesList) {
                    if (languageBodyMap.containsKey(quote.SBQQ__SalesRep__r.LanguageLocaleKey)) {          
                        if (!quotesByLangMap.containsKey(quote.SBQQ__SalesRep__r.LanguageLocaleKey)) {
                            quotesByLangMap.put(quote.SBQQ__SalesRep__r.LanguageLocaleKey, new List<SBQQ__Quote__c> ());
                        }                        
                        quotesByLangMap.get(quote.SBQQ__SalesRep__r.LanguageLocaleKey).add(quote);
                    } else if (quote.SBQQ__SalesRep__r.LanguageLocaleKey == null || !languageBodyMap.containsKey(quote.SBQQ__SalesRep__r.LanguageLocaleKey)) {
                        if (!quotesByLangMap.containsKey('en_US')) {
                            quotesByLangMap.put('en_US', new List<SBQQ__Quote__c> ());
                        } 
                        // Set default to English
                        quotesByLangMap.get('en_US').add(quote);
                    }
                }
                
                for (String lang : quotesByLangMap.keySet()) {
                    sendEmail(quotesByLangMap.get(lang),languageBodyMap.get(lang));
                }
                
            }            

        }
        
    }

    private static void sendEmail(List<SBQQ__Quote__c> quotes, EmailTemplate translatedBodyMessage) {

        List<String> emailRecipients = new List<String>();
        emailRecipients.addAll(getEmailRecipients(quotes));

        if (emailRecipients.size()>0) {

            String grpNames = ' <br>';                                                              

            Map<String,List<SBQQ__Quote__c>> quotesByRep = new Map<String, List<SBQQ__Quote__c>> ();
            for (SBQQ__Quote__c quote : quotes) {                
                if (!quotesByRep.containsKey(quote.SBQQ__SalesRep__c)) {
                    List<SBQQ__Quote__c> newQuoteList = new List<SBQQ__Quote__c> ();                    
                    newQuoteList.add(quote);
                    quotesByRep.put(quote.SBQQ__SalesRep__c, newQuoteList);                    
                } else {
                    List<SBQQ__Quote__c> currQuoteList = quotesByRep.get(quote.SBQQ__SalesRep__c);
                    currQuoteList.add(quote);
                    quotesByRep.put(quote.SBQQ__SalesRep__c, currQuoteList);                    
                }
            }

            for(String key : quotesByRep.keySet()) {
                List<SBQQ__Quote__c> quotesVal = quotesByRep.get(key);
                grpNames += quotesVal[0].SBQQ__SalesRep__r.Name +  '<br>';
                for(SBQQ__Quote__c quote : quotesVal) {
                    grpNames += System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + quote.Id + '<br>';
                }
                grpNames += '<br>';
            }

            String bodyMessage = translatedBodyMessage.Body;
            bodyMessage = bodyMessage.replace('{!salesRepQuotes}', grpNames);

            String customSubject = translatedBodyMessage.Subject;
            System.debug('customSubject: ' + customSubject);
            String subjectUrl = 'Zoetis ' + System.URL.getSalesforceBaseUrl().toExternalForm();
            customSubject = customSubject.replace('{!customSubject}',subjectUrl);            
            
            // Send email.
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = emailrecipients;
            message.optOutPolicy = 'FILTER';
            message.subject = customSubject;
            message.setHtmlBody(bodyMessage);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            if(!Test.isRunningTest()) {    
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
        }        
    }
  

  private static Set<String> getEmailRecipients(List<SBQQ__Quote__c> quotes) {		
		Set<String> returnVal = new Set<String>();
		for(SBQQ__Quote__c quote : quotes){
			if(quote.SBQQ__SalesRep__r.Email != null) {
				returnVal.add(quote.SBQQ__SalesRep__r.Email);
			}
		}
		System.debug('Sending quote updated to draft, notification to: ' + returnVal);
		return returnVal;
	}

    

    global void finish(Database.BatchableContext bc) {
		
	}


}