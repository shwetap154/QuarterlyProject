trigger VistexDealTrigger on Vistex_Deal_Header__c (before insert, after insert, after update) {

  if(Trigger.isAfter){
    if(Trigger.isInsert){          
        List<String> emailRecipients = new List<String>();
		    emailRecipients.addAll(getEmailRecipients());
        if (emailRecipients.size()>0){
          String dealNames = 'Deals info: (Id, Name)<br>';                                                              
          
          for(Vistex_Deal_Header__c deal : Trigger.new){
            dealNames += System.URL.getSalesforceBaseUrl().toExternalForm() + '/'  + deal.Id + ': '+ deal.DEALNUM_EXT__c + '<br>';
          }  
          System.debug('DealNames  ' + dealNames);
          String bodyMessage = Trigger.new.size() + ' vistex deals were inserted into the org.  Timestamp:  ' + Datetime.now() + '<br>' + dealNames;
          
          // Send email.
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.toAddresses = emailrecipients;
          message.optOutPolicy = 'FILTER';
          message.subject = 'Zeotis ' + System.URL.getSalesforceBaseUrl().toExternalForm() + ' New Vistex Deals Were Inserted';
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
  
    }
    if(Trigger.isUpdate) {
      
      /* Fix 10012020 - TODO:This should be moved to asyc process

      Set<Id> vistexHeadersIds = new Set<Id> ();
      //Get custom setting to check if CPQ Bundle updates is enable
      CPQBundleUpdates__c param = CPQBundleUpdates__c.getInstance();
      Boolean doReplace = (Boolean) param.isEnableBundleUpdate__c;
      System.debug('vistex header doReplace, ' + doReplace);

      for(Vistex_Deal_Header__c deal : Trigger.new) {        
        Long difCreationMin = (deal.LastModifiedDate.getTime() - deal.CreatedDate.getTime())/60000;
        System.debug('vistex header diffcreationmin, ' + difCreationMin);
        if (difCreationMin > 10 && doReplace && deal.Exclude_From_Batch__c == false) {
          vistexHeadersIds.add(deal.Id);
        } 
      }

      List<Product2> listProducts = [SELECT Id, Vistex_Deal_Header__c FROM Product2 WHERE Vistex_Deal_Header__c IN :vistexHeadersIds];
      Set<Id> headersIdsToBeUpd = new Set<Id> ();
      for (Product2 product : listProducts) {
        headersIdsToBeUpd.add(product.Vistex_Deal_Header__c);
      }

      if (!headersIdsToBeUpd.isEmpty()) {
        System.debug('vistex header updated: ' + headersIdsToBeUpd);
        VistexDealTriggerHandler.updateExistingProducts(headersIdsToBeUpd);
      }
      
      */
    }
  } 

 public Set<String> getEmailRecipients(){
		List<CPQNotificationSettings__c> notificationSettings = [SELECT Recipient__c FROM CPQNotificationSettings__c WHERE Vistex_Deal_Header__c = true ];
		Set<String> returnVal = new Set<String>();
		for(CPQNotificationSettings__c userNotification : notificationSettings){
			if(userNotification.Recipient__c != null){
				returnVal.add(userNotification.Recipient__c);
			}
		}
		System.debug('Sending vistex deal creation message to: ' + returnVal);
		return returnVal;
  }

}