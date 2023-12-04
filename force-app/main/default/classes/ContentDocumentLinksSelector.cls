/**
 * Selector class for Content Document Links
 * @author Ethan Hirsch @ Zoetis Inc
 * @since 03-07-2023
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-07-2023   Ethan Hirsch @ Zoetis Inc   Initial Version with selectByTitlesAndLinkedEntityId
 * 2.0   04-04-2023   Sibin Kuriakose @ Zoetis Inc   Added method to Retrive list of ContentDocumentLink records having Id same as RecordId as part of TPDEV-428
 * 3.0   10-11-2023   Kalyan Nayak @ Zoetis Inc   Added some fields in selectContentDocumentById Method's Query
 */
public inherited sharing class ContentDocumentLinksSelector {
    /**
     * Select Content Document Links by Title and Linked Entity Id
     * @param titles 
     * @param linkedEntityIds 
     * @return  `List<ContentDocumentLink>`
     */
    public static List<ContentDocumentLink> selectByTitlesAndLinkedEntityId(Set<String> titles, Set<Id> linkedEntityIds) {
        return [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE ContentDocument.Title in: titles
            AND LinkedEntityId in: linkedEntityIds];
    }

    /**     * @Description To Retrive list of ContentDocumentLink records having Id same as RecordId     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 04-04-2023
			* @param       List of Id
    */
    public static List<ContentDocumentLink> selectContentDocumentById(List<Id> recordId) {
        
        List<ContentDocumentLink> templstDoc = [SELECT ContentDocumentId,LinkedEntityId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId,ContentDocument.LatestPublishedVersion.VersionDataURL,ContentDocument.FileType, ContentDocument.ContentSize FROM ContentDocumentLink WHERE LinkedEntityId IN: recordId];
        return templstDoc;
    }
    
}