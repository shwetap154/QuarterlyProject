public with sharing class OrderAttachmentsController {
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getAttachments(String orderId) {
        List<ContentDocument> attachments = new List<ContentDocument>();
        
        for(ContentDocumentLink link : [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.ContentSize
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId = :orderId]) {
            attachments.add(link.ContentDocument);
        }
        
        return attachments;
    }
}