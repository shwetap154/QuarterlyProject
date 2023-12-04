public class LosttoCompetitorSendMail {
     public class FlowInputs {         
        @InvocableVariable public List<String> recipientEmailList;         
        @InvocableVariable public String emailTemplate;     
    }
    @InvocableMethod
    public static void sendLosttoCompetitorMails(List<FlowInputs> flowInputs){
        System.debug('flowInputs are' + flowInputs);
        List<String> toEmailAddressList;
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        for(FlowInputs flowInput: flowInputs){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            toEmailAddressList = new list<String>();
            for(String email:flowInput.recipientEmailList){
                if(email!=null && email!=''){
                    toEmailAddressList.add(email);
                }
            }
            if(toEmailAddressList.size()>0){
                System.debug('toEmailAddressList' + toEmailAddressList);
                message.toAddresses = toEmailAddressList;
                message.subject = 'New Zoetis Lost To Competitor Entry';
                message.htmlBody = flowInput.emailTemplate ;
                messageList.add(message); 
            }
        }
        if(messageList.size()>0){
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messageList);
                System.debug('email result are '+ results);
            }catch(Exception  e){
                System.debug('Error got '+ e);
                
            }
            
            
        }
        
        
    }


}