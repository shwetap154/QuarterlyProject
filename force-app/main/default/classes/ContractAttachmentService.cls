/**
* @ClassName    : ContractAttachmentService
* @SystemChange : SC-010022
* @CreatedOn    : 10/02/2022
* @CreatedBy    : Prasun Dubey (Cognizant)
* @Description  : Class in process attachment sent by bader rutter team and add them to Account depending upon the NARC Id passed through the system.
**/
global class ContractAttachmentService implements Messaging.InboundEmailHandler {
    
    static final string DIV_ID = 'attachmentInfo';
    static final string OPENING_TAG = '{';
    static final string CLOSING_TAG = '}';
    static final string NARC_KEY = 'Narc';
    static final string ATTACHMENT_KEY = 'Attachment';

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        try{
            String emailBody = email.htmlBody;
            if(emailBody != null){
                String firstPart = emailBody.substring(emailBody.indexOf(DIV_ID));
                String firstPartJSON = firstPart.substring(firstPart.indexOf(OPENING_TAG));
                String jsonStr = firstPartJSON.substring(0, firstPartJSON.indexOf(CLOSING_TAG)+1);
                Object obj = JSON.deserializeUntyped(jsonStr.unescapeHtml4());
                Map<String,Object> jsonBody = (Map<String,Object>) obj;
                String accountNARC = String.valueOf(jsonBody.get(NARC_KEY));
                Account acc = [Select Id From Account Where ZTS_US_NARC_ID__c =: accountNARC];
                
                List<Attachment> attachments = new List<Attachment>();
                for (Messaging.Inboundemail.BinaryAttachment tAttachment : email.binaryAttachments ) {
                    if(tAttachment.filename.equalsIgnoreCase(String.valueOf(jsonBody.get(ATTACHMENT_KEY)))){
                        Attachment attachment = new Attachment();
                        
                        attachment.Name = tAttachment.fileName;
                        attachment.Body = tAttachment.body;
                        attachment.ParentId = acc.Id;
                        attachments.add(attachment);
                    }
                }
                insert attachments;
            }
        }catch(Exception ex){
            ZTS_EU_Logger.error(ex.getMessage()+ ex.getStackTraceString(),null, 'ContractAttachmentService');
            System.debug('Error'+ ex.getStackTraceString());
        }
        
        result.success = true;
        return result;
    }
}