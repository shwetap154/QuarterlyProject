public class cse_caseApexActions {

    @testVisible static final String TEST_CONST = 'cse_caseApexActions - {METHOD}: super brief summation of what caused error';
    
    // for the provided case IDs, get all the related email attachments and update the ownership so that the new case owner
   // has the ownership rights of the email attachments
    @InvocableMethod(
        label='Give new case owner Email File Ownership' 
        description='provides full access to new VMIPS case owners' 
        category='case'
    )
    public static void giveNewvmipsCaseOwnerFileAccess(List<cse_caseApexActionsRequest> request) {
        if (request == null || request.isEmpty()) return;
        // go over all requests
        Map<Id, contentDocument> docsToUpdate = new Map<Id, contentDocument>();

        for (Integer i = 0; i < request.size(); i++) {
            Case oldcase = request.get(i).oldCase;
            Case newCase = request.get(i).newCase;
            List<EmailMessage> emailList = request.get(i).emails;
            
            // Check for valid conditions, if not, quit early
            if (
                oldcase == null 
                || newCase == null 
                || emaillist.isEmpty() 
                || newCase.OwnerId.getSObjectType() != User.SObjectType
            ) return;
            
            Map<Id, EmailMessage> emails = new map<id, EmailMessage>();
            for (EmailMessage em : emailList) {
                emails.put(em.id, em);
            }
            Set<Id> contentDocumentIds = new Set<Id>();
            
            // get all cdls for email ids in list
            // ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>([SELECT Id, LinkedEntityId, 
                                                                                        ContentDocumentId, ContentDocument.OwnerId
                                                                                        FROM ContentDocumentLink
                                                                                        WHERE LinkedEntityId In : emails.keySet()
                                                                                        OR LinkedEntityId = : oldCase.ownerid ]);
            
            List<ContentDocumentLink> userOnlyContentDocumentLinks = new List<ContentDocumentLink>();
            // iterate content documenbt linlks
            for (ContentDocumentLink link : contentDocumentLinks ) {
                String linkedEntityId = ((String)link.LinkedEntityId);
                Boolean cdlReferencesEmail = linkedEntityId.startsWith('02s');
                if (cdlReferencesEmail) {
                    contentDocumentIds.add(link.ContentDocumentId);
                }
                // otherwise add cdl to user cdl set
                userOnlyContentDocumentLinks.add(link);
            }
                
            // iterate user cdl set
            for (contentDocumentLink userlink :userOnlyContentDocumentLinks ) {
                // if the cd id is in the cd id set
                    // update the owner to the new case owner
                    // add the cdl to an update list  
                if (contentDocumentIds.contains(userLink.ContentDocumentId)) {
                    contentDocument updatedDoc = new contentDocument(); 
                    updatedDoc.id = userLink.ContentDocumentId;
                    updatedDoc.OwnerId = newCase.ownerId;
                    docsToUpdate.put(updatedDoc.id, updatedDoc);
                }
                
            }
        }

        // if the update list isn't empty
        if (!docsToUpdate.isEmpty()) {
            try {
                update docsToUpdate.values();
            }catch(DmlException dex) {
                if (!Test.isRunningTest()) USContentDocumentTriggerService.logError(dex, 'giveNewvmipsCaseOwnerFileAccess');
            }
        }
        
        
    }
       
    public class cse_caseApexActionsRequest{
        
        @InvocableVariable
        public Case oldCase;

        @InvocableVariable
        public Case newCase;
        
        @InvocableVariable
        public List<EmailMessage> emails;
    }
}