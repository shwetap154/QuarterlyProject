/**
 * Selector class for Content Versions
 * @author Ethan Hirsch @ Zoetis Inc
 * @since 03-07-2023
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-07-2023   Ethan Hirsch @ Zoetis Inc   Initial Version with selectById
 * 1.1   05-10-2023   Sweta Kumari                Added Id and Title field in the query of selectById method  
 * 1.2   06/10/2023   Pranav Raut                 Added selectByContentDocumentId method to select Content Versiosn by ContentDocumentId
 */
public inherited sharing class ContentVersionsSelector {
    /**
     * Selects Content Versiosn by Id
     * @param ids 
     * @return  `List<ContentVersion>`
     */
    public static List<ContentVersion> selectById(Set<Id> ids) {
        return [
            SELECT Id,Title,ContentDocumentId
            FROM ContentVersion
            WHERE Id in: ids
        ];
    }

        /**
     * Selects Content Versiosn by ContentDocumentId
     * @param ids 
     * @return  `List<ContentVersion>`
     */
    public static List<ContentVersion> selectByContentDocumentId(String fileId) {
        return [SELECT Id,Title,FileType,ContentSize,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :fileId];
    }
    
    /**
     * Selects Content Versiosn by Id
     * @param ids 
     * @return  `List<ContentVersion>`
     */
    public static List<ContentVersion> selectBySetOfContentDocumentIds(Set<Id> ids) {
        return [SELECT Id,Title,FileType,ContentSize,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN:ids];
    }
}