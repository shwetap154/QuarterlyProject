trigger CPQErrorLogTrigger on Error_Log__c (after insert) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){          
            List<String> emailRecipients = new List<String>();
            emailRecipients.addAll(getEmailRecipients());
            if (emailRecipients.size()>0){
                String logInfo = 'Error Log info: (Error Type, Developer Message)<br><br>';                                                              
                
                for(Error_Log__c log : Trigger.new){
                logInfo += System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + log.Id + ' <br>';
                logInfo += 'Error Type: ' + log.Error_Type__c + ': '+ log.Developer_Message__c + '<br><br>';
                }  
                String bodyMessage = Trigger.new.size() + ' error(s) occurred in CPQ.  Timestamp:  ' + Datetime.now() + '<br>' + logInfo;
                
                // Send email.
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = emailrecipients;
                message.optOutPolicy = 'FILTER';
                message.subject = 'Zeotis ' + System.URL.getSalesforceBaseUrl().toExternalForm() + ' One or More Errors Have Occurred';
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
    } 

    public Set<String> getEmailRecipients(){
        List<CPQNotificationSettings__c> notificationSettings = [SELECT Recipient__c FROM CPQNotificationSettings__c WHERE CPQ_Error_Log_Created__c = true ];
        Set<String> returnVal = new Set<String>();
        for(CPQNotificationSettings__c userNotification : notificationSettings){
            if(userNotification.Recipient__c != null){
                returnVal.add(userNotification.Recipient__c);
            }
        }
        System.debug('Sending error log notification to: ' + returnVal);
        return returnVal;
    }
}