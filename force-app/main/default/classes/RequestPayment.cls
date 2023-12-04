/*
    * Class :RequestPayment> Java Script calling from Request Button on event : Send an Email to PEI Support for Payment request
    * Created: 8th aug,2015
    * Author: Sohil Shah (CloudSense)
    * Reference: DEF-001710
*/
global class RequestPayment
{
    @AuraEnabled(cacheable=true)
    webservice static void paymentRequestOnEvent(id event)
    {
        ZTS_Events__c eventRec = new ZTS_Events__c();
        eventRec = [Select id,Name,createdByID,Specific_Payment_Information__c from ZTS_Events__c where id=:event AND ZTS_EU_Market__c = 'United States'];
        String eventNumber = eventRec.Name;
        String leaderId = eventRec.createdByID;
        User us = [Select Id, Name, Email from User where id=:leaderId AND ZTS_EU_Market__c = 'United States'];
        String leaderEmail = us.Email;
        String leaderName = us.Name;
        String sUrlRewrite = System.URL.getSalesforceBaseUrl().getHost();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add('PEISupportServices@zoetis.com');
        List<String> CcTo = new List<String>();
        CcTo.add(us.email);
        mail.setToAddresses(sendTo);
        mail.setCcAddresses(CcTo);
        //mail.setSenderDisplayName(leaderName);
        mail.setReplyTo(leaderEmail);
        //mail.setTemplateId('00Xe0000000EOgv');
        //mail.setTargetObjectId('005i0000004XH4I');    
        //mail.setSaveAsActivity(false);
        mail.setSubject('Request for Payment  ' + eventNumber );
        String body = 'Please process payment for event: ' ;
        body = body + eventNumber;      
        body = body + '\n';        
        body = body + '\n';
        body = body + '\n';
        body = body + 'Payment Instructions:';
        body = body + '\n';
        body = body + eventRec.Specific_Payment_Information__c;
        body = body + '\n';
        body = body + '\n';
        body = body + '\n';
        body = body + 'Event Link: ';
        body = body + eventNumber;
        body = body  +  '\n https://'+ sUrlRewrite +'/' + String.valueOf(eventRec.id);
        body = body + '\n';
        body = body + '\n';
        body = body + '\n';
        body = body + 'Thank You.';
        body = body + '\n';
        body = body + Userinfo.getName() ;        
        String StringBody = String.valueOf(body);          
        mail.setPlainTextBody(StringBody);
        Messaging.sendEmail(new Messaging.SingleEmailmessage[] {mail});
            
    }
}