trigger FlexibleGroupTriggger on Flexible_Group__c (before insert, after insert) {


  if(Trigger.isAfter){
    if(Trigger.isInsert){          
      List<String> emailRecipients = new List<String>();
      emailRecipients.addAll(getEmailRecipients());
      if (emailRecipients.size()>0){
        String grpNames = 'Flexible Group info: (Id, Group#)<br>';                                                              
        
        for(Flexible_Group__c grp : Trigger.new){
          grpNames += System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + grp.Id + ': '+ grp.Flexible_Group_Number__c + '<br>';
        }  
        String bodyMessage = Trigger.new.size() + ' Vistex Flexible Groups were inserted into the org.  Timestamp:  ' + Datetime.now() + '<br>' + grpNames;
        
        // Send email.
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailrecipients;
        message.optOutPolicy = 'FILTER';
        message.subject = 'Zeotis ' + System.URL.getSalesforceBaseUrl().toExternalForm() + ' New Vistex Flexible Groups Were Inserted';
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
      //Call handler for CPQATG-736: Update Flexible Group Items that not have a related parent
      FlexibleGroupTrigggerHandler.updateFlexibleGroupItemRelation(Trigger.newMap);
    }
  } 

  public Set<String> getEmailRecipients(){
		List<CPQNotificationSettings__c> notificationSettings = [SELECT Recipient__c FROM CPQNotificationSettings__c WHERE Vistex_Flexible_Group_Created__c = true ];
		Set<String> returnVal = new Set<String>();
		for(CPQNotificationSettings__c userNotification : notificationSettings){
			if(userNotification.Recipient__c != null){
				returnVal.add(userNotification.Recipient__c);
			}
		}
		System.debug('Sending flexible group load notification to: ' + returnVal);
		return returnVal;
	}
}