/****************************************************************************************************************************************** 
* Class Name : ContractAttachmentService_Test
* Description  : Test class for ContractAttachmentService
* Created By   : Yadagiri
* Created Date : 14/02/2023
*****************************************************************************************************************************************/
@isTest
public class ContractAttachmentService_Test {
    
    static testMethod void TestinBoundEmail()
        
    {
        User testUser =  ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        testUser.FirstName = 'testUserFirstName';
        testUser.zts_eu_market__c = 'United States';
        insert testUser;
        List<Account> testAccounts = new List<Account>();
        System.runAs(testUser) {
            testAccounts = ZTS_DataUtilityTest.createAccountRecord(2,13546);
            insert testAccounts; 
        }
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        List<string> emails = new List<string>{'testbandi@gmail.com','testbandi123@gmail.com'};
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = emails;
        email.htmlBody = '<div> attachmentInfo { "Narc": "NC13546000", "Attachment":"textfileone.txt"} </div>';
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        ContractAttachmentService  testInbound=new ContractAttachmentService();
        testInbound.handleInboundEmail(email, env);
        
        List<Attachment> attachments = [Select Id,Name from Attachment Where ParentId =: testAccounts[0].Id];
        
        System.assertEquals(attachment.fileName, attachments[0].Name, 'Should be the same attachment came from mail');
        System.assertEquals(attachments.size() , 1,  'Should be the only attachment came from mail');
        
    }
}