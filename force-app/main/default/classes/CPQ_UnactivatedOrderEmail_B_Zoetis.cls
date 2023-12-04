/**
* @description       : Send email to Quote Owners if Order is not activated in given time frame
* @author            : Rahul Kumar @Deloitte
* @test class        : CPQ_UnactivatedOrderEmail_T_Zoetis

* Modifications Log
* Ver   Date         Author                       Modification
* 1.0   06-21-2023   Rahul Kumar @Deloitte        Initial Version
* 1.1	09-06-2023	 Nicholas Grasseschi @CTS	  TPDEV-1897 - Updated query filter for 'CreatedDate >= :hoursAgo' to create a "time box" for Order emails to be sent -> reduces instances of emails received
**/

public class CPQ_UnactivatedOrderEmail_B_Zoetis implements Database.Batchable<SObject>, Database.Stateful , Schedulable {
    Integer noOfHours = Test.isRunningTest() == true ? -1 : -12; // -1 if test since Order created before System.now()
    DateTime hoursAgo = DateTime.now().addHours(noOfHours);
    String emailSubjectStr = System.Label.CPQ_Unactivated_Order_Email_Subject;
    String emailBodyEndStr = System.Label.CPQ_Unactivated_Order_Email_End;
    
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        // Query unactivated orders created within the last 12 hours (TPDEV-1897)
        try
        {	
            Id cpqOrderNonPinRecordTypeId = OrderHandler.withoutPreInstallOrderRTId; 
            Id cpqOrderPinRecordTypeId = OrderHandler.preInstallOrderRTId;
            List<Id> listOfId = new List <ID>{cpqOrderNonPinRecordTypeId, cpqOrderPinRecordTypeId};
                String query = 'SELECT Id, OrderNumber, CreatedDate, SBQQ__Quote__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.Owner.Email, SBQQ__Quote__r.Owner.FirstName, SBQQ__Quote__r.Owner.LastName ,Account_Name__c,SAP_Account_ID__c, CPQ_Order_Activation_Email_Sent__c FROM Order WHERE CPQ_Order_Activation_Email_Sent__c = True AND RecordTypeId IN :listOfId AND Status != \'Activated\' AND CreatedDate >= :hoursAgo';
            //System.debug('start query > ' + query);
            return Database.getQueryLocator(query);
        }
        catch (Exception ex)
        {
            System.debug('Error in CPQ_UnactivatedOrderEmail_B_Zoetis class , method = Start , Error = ' + ex.getMessage());
        }
        return null;
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        try
        {
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage message;
            List<OrgWideEmailAddress> orgWideAddress = [Select id , address , displayName, purpose from OrgWideEmailAddress  where displayName = 'Zoetis' AND Purpose = 'UserSelection'];       
            String salesforceBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            
            // Iterate through unactivated order owner id and create email notifications
            for (Order obj : (List<Order>) scope) {
                // System.debug('obj order id ' + obj.id);
                String quoteOwnerEmail = obj.SBQQ__Quote__r.Owner.Email;
                //System.debug('quoteOwnerEmail ' + quoteOwnerEmail);
                if(quoteOwnerEmail!= null && !quoteOwnerEmail.containsIgnoreCase('invalid'))
                {
                    message = new Messaging.SingleEmailMessage();
                    message.setOrgWideEmailAddressId(orgWideAddress.get(0).id);
                    message.setSubject(emailSubjectStr);
                    message.toaddresses = new String []{quoteOwnerEmail};
                    String emailBody = '<html><body>';
                    emailBody += '<p>Hi ' +obj.SBQQ__Quote__r.Owner.FirstName+' '+ obj.SBQQ__Quote__r.Owner.LastName  + ',</p>';
                    emailBody += '<p>Order <a href="' + salesforceBaseUrl + '/' + obj.Id + '">' + obj.OrderNumber + '</a> created on ' + obj.CreatedDate.format('yyyy/MM/dd') + ' for Quote- <a href="' + salesforceBaseUrl + '/' + obj.SBQQ__Quote__c + '">' + obj.SBQQ__Quote__r.Name + '</a> on Account ' + obj.Account_Name__c + ' {' + obj.SAP_Account_ID__c + '} '+emailBodyEndStr+'</p>';
                    emailBody += '<p>Thank you</p>';
                    emailBody += '</body></html>';
                    message.setHtmlBody(emailBody);
                    mailList.add(message);
                }
                
            }
            
            // Send email notifications
            if (!mailList.isEmpty()) {
                Messaging.sendEmail(mailList);
            } 
        }
        catch(Exception ex)
        {
            System.debug('Error in CPQ_UnactivatedOrderEmail_B_Zoetis class , method = Execute , Error = ' + ex.getMessage());
        }
        
    }
    
    public void finish(Database.BatchableContext BC) 
    {
        // Implement any post-processing logic here
    }
    
    //Schedulable Interface    
    public void execute(SchedulableContext ctx)
    {
        CPQ_UnactivatedOrderEmail_B_Zoetis batchObject = new CPQ_UnactivatedOrderEmail_B_Zoetis();
        Id batchId = Database.executeBatch(batchObject, 200);
    }
}