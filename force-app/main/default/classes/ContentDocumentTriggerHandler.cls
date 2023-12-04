public with sharing class ContentDocumentTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    //Field used for ContentDocumentLink segmentation logic
    private Schema.sObjectField parentField = ContentDocumentLink.LinkedEntityId.getDescribe().getSObjectField();
    private Schema.sObjectField marketField = User.ZTS_EU_Market__c.getDescribe().getSObjectField();
    @testVisible static boolean SKIP_INSERT_TRIGGER = false;
    @testVisible static final String EMAIL_RECORD_PREFIX = '02s';

    public void beforeInsert(List<SObject> triggerNew) {
       
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        // CSEPVW-120: Ahmed Elawad. Share email file attachments on vmips case with case owner
        // COMMENTING OUT WORK RELATED TO CSEPVW-120 DUE TO DEFECT INC2570483
        /*Map<Id, ContentDocument> triggerNewReferenceMap = new Map<Id, ContentDocument>();
        for (SObject obj : triggerNew) {
            triggerNewReferenceMap.put(obj.Id, (ContentDocument)obj);
        }

        List<ContentDocumentLink> linksForContentDocuments = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :triggerNewReferenceMap.keySet()];

        if (!linksForContentDocuments.isEmpty()) {
            USContentDocumentTriggerService.giveVmipsCaseOwnerAccessToEmailFile(linksForContentDocuments, triggerNewReferenceMap);
        }*/

    }
    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        List<Id> ContentDocumentIds = new List<Id>();
        for (SObject obj : triggerOld) ContentDocumentIds.add(obj.Id);
        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :ContentDocumentIds];

        List<User> users = createUserList(contentDocumentLinks);   
        List<ContentDocumentLink> documentLinksToUsers = createContentDocumentLinksWithUsers(contentDocumentLinks);
        List<ContentDocumentLink> documentLinksToObjects = createContentDocumentLinksListWithUsers(contentDocumentLinks);

        //Filter triggerOld List for US Content Documents 
        List<ContentDocumentLink> UsOldListContentDocumentLinkToProcess = filter(documentLinksToUsers, users, documentLinksToObjects, parentField, marketField, true);
        //Filter triggerOldMap Map for US Content Documents return Map
        Map<Id,ContentDocumentLink> UsOldMapContentDocumentLinkToProcess = new Map<Id, ContentDocumentLink>(UsOldListContentDocumentLinkToProcess);
        //Filter triggerOld List for INTL Content Documents 
        List<ContentDocumentLink> IntlOldListContentDocumentLinkToProcess = filter(documentLinksToUsers, users, documentLinksToObjects, parentField, marketField, false);
        //Filter triggerOldMap Map for INTL Content Documents return Map
        Map<Id,ContentDocumentLink> IntlOldMapContentDocumentLinkToProcess = new Map<Id, ContentDocumentLink>(IntlOldListContentDocumentLinkToProcess);
        
        if (!UsOldListContentDocumentLinkToProcess.isEmpty() && !UsOldMapContentDocumentLinkToProcess.isEmpty()) 
            USContentDocumentTriggerService.beforeDelete(UsOldListContentDocumentLinkToProcess, UsOldMapContentDocumentLinkToProcess);
        
    }
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        List<Id> ContentDocumentIds = new List<Id>();
        for (SObject obj : triggerNew) ContentDocumentIds.add(obj.Id);
        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE ContentDocumentId IN :ContentDocumentIds];
        List<User> users = createUserList(contentDocumentLinks);   
        List<ContentDocumentLink> documentLinksToUsers = createContentDocumentLinksWithUsers(contentDocumentLinks);
        List<ContentDocumentLink> documentLinksToObjects = createContentDocumentLinksListWithUsers(contentDocumentLinks);
        //Filter triggerNew List for US Content Documents 
        List<ContentDocumentLink> UsNewListContentDocumentLinkToProcess = filter(documentLinksToUsers, users, documentLinksToObjects, parentField, marketField, true);
        //Filter triggerNewMap Map for US Content Documents return Map
        Map<Id,ContentDocumentLink> UsNewMapContentDocumentLinkToProcess = new Map<Id, ContentDocumentLink>(UsNewListContentDocumentLinkToProcess);
        //Filter triggerNew List for INTL Content Documents 
        List<ContentDocumentLink> IntlNewListContentDocumentLinkToProcess = filter(documentLinksToUsers, users, documentLinksToObjects, parentField, marketField, false);
        //Filter triggerNewMap Map for INTL Content Documents return Map
        Map<Id,ContentDocumentLink> IntlNewMapContentDocumentLinkToProcess = new Map<Id, ContentDocumentLink>(IntlNewListContentDocumentLinkToProcess);
        if (!UsNewListContentDocumentLinkToProcess.isEmpty() && !UsNewMapContentDocumentLinkToProcess.isEmpty()) 
            USContentDocumentTriggerService.afterInsert(UsNewListContentDocumentLinkToProcess, UsNewMapContentDocumentLinkToProcess);

    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {

        List<Id> ContentDocumentIdsOld = new List<Id>();
        for (SObject obj : triggerOld) ContentDocumentIdsOld.add(obj.Id);

        List<Id> ContentDocumentIdsNew = new List<Id>();
        for (SObject obj : triggerNew) ContentDocumentIdsNew.add(obj.Id);

        List<ContentDocumentLink> contentDocumentLinksOld = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE ContentDocumentId IN :ContentDocumentIdsOld];
        List<ContentDocumentLink> contentDocumentLinksNew = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE ContentDocumentId IN :ContentDocumentIdsNew];
        // lsit of all users shared with on case
        List<User> users = createUserList(contentDocumentLinksOld);   
        // list of content document links for users
        List<ContentDocumentLink> documentLinksToUsersOld = createContentDocumentLinksWithUsers(contentDocumentLinksOld);
        // non user content document links on case
        List<ContentDocumentLink> documentLinksToObjectsOld = createContentDocumentLinksListWithUsers(contentDocumentLinksOld);
        List<ContentDocumentLink> documentLinksToUsersNew = createContentDocumentLinksWithUsers(contentDocumentLinksNew);
        List<ContentDocumentLink> documentLinksToObjectsNew = createContentDocumentLinksListWithUsers(contentDocumentLinksNew);
        //Filter triggerOld List for US Content Documents 
        List<ContentDocumentLink> UsOldListContentDocumentLinkToProcess = filter(documentLinksToUsersOld, users, documentLinksToObjectsOld, parentField, marketField, true);
        //Filter triggerOldMap Map for US Content Documents return Map
        Map<Id,ContentDocumentLink> UsOldMapContentDocumentLinkToProcess = new Map<Id, ContentDocumentLink>(UsOldListContentDocumentLinkToProcess);
        //Filter triggerNew List for US Content Documents 
        List<ContentDocumentLink> UsNewListContentDocumentLinkToProcess = filter(documentLinksToUsersNew, users, documentLinksToObjectsNew, parentField, marketField, true);
        //Filter triggerNewMap Map for US Content Documents return Map
        Map<Id,ContentDocumentLink> UsNewMapContentDocumentLinkToProcess = new Map<Id, ContentDocumentLink>(UsNewListContentDocumentLinkToProcess);

        //Filter triggerOld List for INTL Content Documents 
        List<ContentDocumentLink> IntlOldListContentDocumentLinkToProcess = filter(documentLinksToUsersOld, users, documentLinksToObjectsOld, parentField, marketField, false);
        //Filter triggerOldMap Map for INTL Content Documents return Map
        Map<Id,ContentDocumentLink> IntlOldMapContentDocumentLinkToProcess = new Map<Id, ContentDocumentLink>(IntlOldListContentDocumentLinkToProcess);
        //Filter triggerNew List for INTL Content Documents 
        List<ContentDocumentLink> IntlNewListContentDocumentLinkToProcess = filter(documentLinksToUsersNew, users, documentLinksToObjectsNew, parentField, marketField, false);
        //Filter triggerNewMap Map for INTL Content Documents return Map
        Map<Id,ContentDocumentLink> IntlNewMapContentDocumentLinkToProcess = new Map<Id, ContentDocumentLink>(IntlNewListContentDocumentLinkToProcess);

        if (!UsOldListContentDocumentLinkToProcess.isEmpty() && !UsOldMapContentDocumentLinkToProcess.isEmpty()) 
            USContentDocumentTriggerService.afterUpdate(UsOldListContentDocumentLinkToProcess, UsOldMapContentDocumentLinkToProcess, UsNewListContentDocumentLinkToProcess, UsNewMapContentDocumentLinkToProcess);
    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) 
    {
        List<Id> ContentDocumentIds = new List<Id>();
        for (SObject obj : triggerOld) ContentDocumentIds.add(obj.Id);

        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :ContentDocumentIds];

        List<User> users = createUserList(contentDocumentLinks);   
        List<ContentDocumentLink> documentLinksToUsers = createContentDocumentLinksWithUsers(contentDocumentLinks);
        List<ContentDocumentLink> documentLinksToObjects = createContentDocumentLinksListWithUsers(contentDocumentLinks);

        //Filter triggerOld List for US Content Documents 
        List<ContentDocumentLink> UsOldListContentDocumentLinkToProcess = filter(documentLinksToUsers, users, documentLinksToObjects, parentField, marketField, true);
        //Filter triggerOldMap Map for US Content Documents return Map
        Map<Id,ContentDocumentLink> UsOldMapContentDocumentLinkToProcess = new Map<Id, ContentDocumentLink>(UsOldListContentDocumentLinkToProcess);
        //Filter triggerOld List for INTL Content Documents 
        List<ContentDocumentLink> IntlOldListContentDocumentLinkToProcess = filter(documentLinksToUsers, users, documentLinksToObjects, parentField, marketField, false);
        //Filter triggerOldMap Map for INTL Content Documents return Map
        Map<Id,ContentDocumentLink> IntlOldMapContentDocumentLinkToProcess = new Map<Id, ContentDocumentLink>(IntlOldListContentDocumentLinkToProcess);

        if (!UsOldListContentDocumentLinkToProcess.isEmpty() && !UsOldMapContentDocumentLinkToProcess.isEmpty()) 
            USContentDocumentTriggerService.afterDelete(UsOldListContentDocumentLinkToProcess, UsOldMapContentDocumentLinkToProcess);

    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) 
    {
        List<Id> ContentDocumentIds = new List<Id>();
        for (SObject obj : triggerNew) ContentDocumentIds.add(obj.Id);

        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE ContentDocumentId IN :ContentDocumentIds];

        List<User> users = createUserList(contentDocumentLinks);
        List<ContentDocumentLink> documentLinksToUsers = createContentDocumentLinksWithUsers(contentDocumentLinks);
        List<ContentDocumentLink> documentLinksToObjects = createContentDocumentLinksListWithUsers(contentDocumentLinks);

        //Filter triggerNew List for US Content Documents 
        List<ContentDocumentLink> UsOldListContentDocumentLinkToProcess = filter(documentLinksToUsers, users, documentLinksToObjects, parentField, marketField, true);
        //Filter triggerNewMap Map for US Content Documents return Map
        Map<Id,ContentDocumentLink> UsOldMapContentDocumentLinkToProcess = new Map<Id, ContentDocumentLink>(UsOldListContentDocumentLinkToProcess);
        //Filter triggerNew List for INTL Content Documents 
        List<ContentDocumentLink> IntlOldListContentDocumentLinkToProcess = filter(documentLinksToUsers, users, documentLinksToObjects, parentField, marketField, false);
        //Filter triggerNewMap Map for INTL Content Documents return Map
        Map<Id,ContentDocumentLink> IntlOldMapContentDocumentLinkToProcess = new Map<Id, ContentDocumentLink>(IntlOldListContentDocumentLinkToProcess);

        if (!UsOldListContentDocumentLinkToProcess.isEmpty() && !UsOldMapContentDocumentLinkToProcess.isEmpty()) 
            USContentDocumentTriggerService.afterUndelete(UsOldListContentDocumentLinkToProcess, UsOldMapContentDocumentLinkToProcess);
    }


    /***************************************************************
     *                      Private Methods                        *
     ***************************************************************/
    
     // create a list of contentdocuments with only non user objects
    private static List<ContentDocumentLink> createContentDocumentLinksListWithUsers(List<ContentDocumentLink> ContentDocumentLinks)
    {
        List<ContentDocumentLink> nonUserContentDocuments = new List<ContentDocumentLink>();
        for (ContentDocumentLink contentDocumentLink : ContentDocumentLinks)
        {
            String s = ((String)contentDocumentLink.LinkedEntityId);

            if(!s.startsWith('005'))
            {
                nonUserContentDocuments.add(contentDocumentLink);
            }
        }

        return nonUserContentDocuments;
    }

    // create a list of contentdocuments with only user objects
    private static List<ContentDocumentLink> createContentDocumentLinksWithUsers(List<ContentDocumentLink> ContentDocumentLinks)
    {
        List<ContentDocumentLink> userContentDocuments = new List<ContentDocumentLink>();
        for (ContentDocumentLink contentDocumentLink : ContentDocumentLinks)
        {
            String s = ((String)contentDocumentLink.LinkedEntityId);
            if(s.startsWith('005'))
            {
                userContentDocuments.add(contentDocumentLink);
            }
        }
        return userContentDocuments;
    }

    // create a list of users that the contendocuments look up to
    private static List<User> createUserList(List<ContentDocumentLink> ContentDocumentLinks)
    {
        List<Id> userIds = new List<Id>();
        for (ContentDocumentLink a : (List<ContentDocumentLink>) ContentDocumentLinks)
        {
            if (((String)a.LinkedEntityId).startsWith('005')) userIds.add(a.LinkedEntityId);
        } 

        return [SELECT Id, ZTS_EU_Market__c FROM User WHERE Id IN :userIds];
    }

    // filter list based on boolean value
    private static List<ContentDocumentLink> filter(List<ContentDocumentLink> listToFilter, 
                                                    List<User> parentObjects, 
                                                    List<ContentDocumentLink> CDLwithObjects, 
                                                    Schema.sObjectField parentField, 
                                                    Schema.sObjectField marketField, Boolean isEqual) 
    {
        List<ContentDocumentLink> filteredUserContentDocuments = TriggerHandlerExtension.filter(listToFilter, marketField, parentField, parentObjects, isEqual);

        List<ContentDocumentLink> segmentedCDLs = new List<ContentDocumentLink>();

        // cespvw-120: Ahmed Elawad 
        // Add cdlMap logic to ensure duplicate contentDocumentLinks are not added to segmentedCDLs
        Map<Id, ContentDocumentLink> cdlMap = new Map<Id, ContentDocumentLink>(); 
        for (ContentDocumentLink cdl : CDLwithObjects)
        {
            for(ContentDocumentLink filteredCDL : filteredUserContentDocuments)
            {
                if((cdl.ContentDocumentId == filteredCDL.ContentDocumentId) && !cdlMap.keySet().contains(cdl.Id) )
                {
                    cdlMap.put(cdl.Id, cdl);
                }
            }
        }
        return cdlMap.values();
    }

}