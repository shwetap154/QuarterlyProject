/**
 * Test class for ContentDEocumentLinksSelector
 * @author Ethan Hirsch @ Zoetis Inc
 * @since 03-07-2023
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-07-2023   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for selectByTitlesAndLinkedEntityId
 * 2.0   04-04-2023   Sibin Kuriakose @ Zoetis Inc      Added method to Test selectContentDocumentById as part of TPDEV-428
 */
@isTest
private class ContentDocumentLinksSelectorTest {


    @isTest
    private static void selectByTitlesAndLinkedEntityId_Test() {
        Account a = TestDataFactory.createAccount_US('Test Account', true);
        String title = 'test';

        ContentVersion file = new ContentVersion(
            Title = title,
            PathOnClient = title,
            VersionData = Blob.valueOf(title),
            origin = 'H'
        );

        insert file;

        insert new ContentDocumentLink(
            LinkedEntityId = a.Id,
            ContentDocumentId = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id =: file.Id].ContentDocumentId
        );

        Test.startTest();
            List<ContentDocumentLink> links = ContentDocumentLinksSelector.selectByTitlesAndLinkedEntityId(
                new Set<String> {title}, new Set<Id> {a.Id});
        Test.stopTest();

        Assert.areEqual(1, links.size(), 'More/Less Content Document Links than expected were returned.');
    }

    /**     * @Description This method will test selectContentDocumentById method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 04-04-2023 
    */
    @isTest
    public static void selectContentDocumentByIdTest() {

        //Creating Content

        //First Record
        FAQ__kav tempKnow = new FAQ__kav();
        tempKnow.Title = 'Test Know';
        tempKnow.URLName = 'Test-Know';
        tempKnow.Description__c = 'Test-Know Description';
        tempKnow.Answer__c = 'Test-Know Content';
        tempKnow.Review_Article_In__c = '3 Months';
        tempKnow.Data_Category__c = 'All';
        insert tempKnow;

        String title = 'test';
        ContentVersion file = new ContentVersion(
            Title = title,
            PathOnClient = title,
            VersionData = Blob.valueOf(title),
            origin = 'H'
        );

        insert file;

        insert new ContentDocumentLink(
            LinkedEntityId = tempKnow.Id,
            ContentDocumentId = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id =: file.Id].ContentDocumentId
        );

        List<Id> recordId = new List<Id>();
        recordId.add(tempKnow.Id);
        Test.startTest();
            List<ContentDocumentLink> links = ContentDocumentLinksSelector.selectContentDocumentById(recordId);
        Test.stopTest();
        System.assertEquals(1,links.size());
    }
}