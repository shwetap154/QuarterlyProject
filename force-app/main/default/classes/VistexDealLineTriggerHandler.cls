/**
* File Name     :  VistexDealLineTriggerHandler
* @description  :  Helper class for the Vistex Deal Line Trigger
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     11/7/2019		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/7/2020		Cory Bartholomew @ ATG     Added descriptions.

**/


public with sharing class VistexDealLineTriggerHandler {
    public List<Vistex_Deal_Line_E1KOMG__c> triggerNew;
    public Map<Id,Vistex_Deal_Line_E1KOMG__c> triggerOldMap;
    public Map<Id,Vistex_Deal_Header__c> deals;    
    private List<String> emailRecipients = new List<String>();
	
    public VistexDealLineTriggerHandler(List<Vistex_Deal_Line_E1KOMG__c> triggerNew, Map<Id,Vistex_Deal_Line_E1KOMG__c> triggerOldMap) {
        this.triggerNew = triggerNew;
        this.triggerOldMap = triggerOldMap;
        this.deals =  queryVistexDeals(ApexUtils.pluckIdSet(triggerNew, 'DEALK01_Ext_Id__c'));
        this.emailRecipients.addAll(getEmailRecipients()); 
    }    

    public void afterInsert(){
        List<String> messagesToSend = new List<String>();
        for(Vistex_Deal_Line_E1KOMG__c line : this.triggerNew){
            if(this.deals.containsKey(line.DEALK01_Ext_Id__c)){
                String message = checkLineInsertedAfterDeal(line, this.deals.get(line.DEALK01_Ext_Id__c));
                if(message != null){
                    messagesToSend.add(message);
                }
            }
        }
        if(messagesToSend.size() > 0 && this.emailRecipients.size() > 0){
            notifyIfDealChanged(messagesToSend);
        }        
    }

    public void afterUpdate(){
        List<String> messagesToSend = new List<String>();
        for(Vistex_Deal_Line_E1KOMG__c line : this.triggerNew){
            if(this.triggerOldMap.containsKey(line.Id)){
                String message = checkMarkedForDelete(line, this.triggerOldMap.get(line.Id));
                if(message != null){
                    messagesToSend.add(message);
                }
            }
        }
        if(messagesToSend.size() > 0 && this.emailRecipients.size() > 0){
            notifyIfDealChanged(messagesToSend);
        }      
    }

    
    /**
    * @description Sends email to subscribed users if a deal was changed
    * @param messagesToSend The messages to deliver
    */
    public void notifyIfDealChanged(List<String> messagesToSend){
        String bodyMessage = String.join(messagesToSend, '<br>');
        
        // Send email.
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = this.emailRecipients;
        message.optOutPolicy = 'FILTER';
        message.subject = 'Zeotis ' + System.URL.getSalesforceBaseUrl().toExternalForm() + ' Vistex Deals Were Changed';
        message.setHtmlBody(bodyMessage);
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        if(!Test.isRunningTest()){    
        	Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);        
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
        

    }

    /**
    * @description Query the vistex deal info needed for logic
    * @param dealIds The deal Ids associated to the deal lines
    */
    public static Map<Id, Vistex_Deal_Header__c> queryVistexDeals(Set<Id> dealIds){
        return new Map<Id, Vistex_Deal_Header__c>([
            SELECT Id, Name, BOART_AG__c, Commitment_Indicator__c, CURRENCY__c, DEALK01_Ext_Id__c, DEALNUM__c, DEALNUM_EXT__c, DEALTXT__c, 
            ORGID__c, QULAF__c, Transaction_Type_CPQ__c, VALID_FROM__c, VALID_TO__c, CPQ_Transaction_Type_Text__c, CreatedDate, LastModifiedDate
            FROM Vistex_Deal_Header__c
            WHERE Id IN: dealIds
        ]);
    }
  
    /**
    * @description If a deal line was inserted a day or more after the deal was created,  notify that something has changed
    * @param line The deal line to check
    * @param deal The deal associated to the line
    */
    public static String checkLineInsertedAfterDeal(Vistex_Deal_Line_E1KOMG__c line, Vistex_Deal_Header__c deal){        
        Date lineCreated = Date.newInstance(line.CreatedDate.Year(),line.CreatedDate.Month(),Line.CreatedDate.Day());
        Date dealCreated = Date.newInstance(deal.CreatedDate.Year(),deal.CreatedDate.Month(),deal.CreatedDate.Day());        
        if(dealCreated.daysBetween(lineCreated) >= 1){
            return 'Deal ' +  deal.Name + ' Was changed. Deal Line ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + line.Id + 
                    ' was inserted to the deal after original creation';
        }else{
            return null;
        }
    }

    /**
    * @description If a deal line was updated as marked for deletion, notify
    * @param newLine The updated line
    * @param oldLine The existing values before the record was updated
    */
    public static String checkMarkedForDelete(Vistex_Deal_Line_E1KOMG__c newLine, Vistex_Deal_Line_E1KOMG__c oldLine){        
        if(oldLine.LOEVM_KO__c == null && newLine.LOEVM_KO__c != null){
            return ' Deal Line ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + newline.Id + 
                    ' was marked for deletion.  Please remove the product option from the deal bundle.';
        }else{
            return null;
        }     
    }

    /**
    * @description Find the users who subscribe to this message notification
    */
    public Set<String> getEmailRecipients(){
		List<CPQNotificationSettings__c> notificationSettings = [SELECT Recipient__c FROM CPQNotificationSettings__c WHERE Vistex_Deal_Changed__c = true ];
		Set<String> returnVal = new Set<String>();
		for(CPQNotificationSettings__c userNotification : notificationSettings){
			if(userNotification.Recipient__c != null){
				returnVal.add(userNotification.Recipient__c);
			}
		}
		System.debug('Sending vistex deal changed message to: ' + returnVal);
		return returnVal;
	}

    

}