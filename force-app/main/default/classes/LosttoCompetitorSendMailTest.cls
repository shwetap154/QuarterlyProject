@IsTest
public class LosttoCompetitorSendMailTest {
     @IsTest
   static void testEmailsSent(){
       List<String> emailList = new List<String>();
       emailList.add('test@gmail.com');
       emailList.add('test2@gmail.com');
       
       String emailTemplate = 'Template String';
       
        LosttoCompetitorSendMail.FlowInputs fi = new LosttoCompetitorSendMail.FlowInputs();
        fi.recipientEmailList = emailList;
        fi.emailTemplate = emailTemplate;
      
       Test.startTest();
       System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');
        
       LosttoCompetitorSendMail.sendLosttoCompetitorMails(new List<LosttoCompetitorSendMail.FlowInputs>{fi});

       System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
       Test.stopTest();
   }

}