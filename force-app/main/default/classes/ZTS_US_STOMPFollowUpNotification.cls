public with sharing class ZTS_US_STOMPFollowUpNotification
{
    public static void sendEmail(List<PIT_STOMP__c> STOMPList)
    {
        List<PIT_STOMP__c> stompToUpdateList = new List<PIT_STOMP__c>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Id> userIds = new List<Id>();
        for(PIT_STOMP__c stomp: STOMPList)
        {
            userIds.add(stomp.PIT_Approving_Vet__c);
        }
            
        Map<Id,User> us = new Map<Id,User>([Select id,Name, Email from User where id IN :Userids AND ZTS_EU_Market__c = 'United States']);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'Stomp Reminder'];
        for(PIT_STOMP__c stomp: STOMPList)
        {
            string ToEmailId ;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();           
            sendTo.add(us.get(stomp.PIT_Approving_Vet__c).email); 
            List<String> CcTo = new List<String>();
            //CcTo.add('laxmikanthreddy.tankari@zoetis.com');
            mail.setToAddresses(sendTo);
            mail.setCcAddresses(CcTo);
            //mail.setSenderDisplayName(us.Name);
            //mail.setReplyTo('example@zoetis.com');
            
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }    
            mail.setSubject('Reminder: Follow Up on STOMP '+ stomp.PIT_STOMP_Initiation_Number__c);
            String body = 'Dr '+us.get(stomp.PIT_Approving_Vet__c).Name +',<br/><br/>' + 'You approved <b>STOMP ' + stomp.PIT_STOMP_Initiation_Number__c + '</b> on <b>' + stomp.CreatedDate.date().format() + '</b> through <b>' + stomp.PIT_Diagnostic_Lab__c + '</b>.';
            body = body + '<br/>';
            body = body + 'Please be sure to check the VDL web site for results and follow up with <b>' + stomp.PIT_Account__r.Name + '</b>.';
            body = body + '<br/>';
            body = body + 'Upon completion of your follow up meeting with <b>' + stomp.PIT_Account__r.Name + '</b>, please enter "Follow Up Notes", the "Date the follow up was completed" and the "Outcome of the STOMP" in Touchpoint.';
            body = body + '<br/>';
            body = body + '<br/>';
            body = body + 'Thank You.';
            String StringBody = String.valueOf(body);          
            mail.setHTMLBody(StringBody);
            emails.add(mail);
            //Messaging.sendEmail(new Messaging.SingleEmailmessage[] {mail});
            stomp.Mail_Sent__c = true;
            stompToUpdateList.add(stomp);   
        }
         Messaging.sendEmail(emails);
        update stompToUpdateList;
    }
}