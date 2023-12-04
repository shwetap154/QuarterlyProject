/**
 * Test class for ContentVersionsSelector
 * @author Ethan Hirsch @ Zoetis Inc
 * @since 03-07-2023
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-07-2023   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for selectById
 * 2.0   06-10-2023   Pranav Raut 			      Added selectByContentDocumentId_Test to test selectByContentDocumentId method in ContentVersionsSelector
 */
@isTest
private class ContentVersionsSelectorTest {
    @isTest
    private static void selectById_Test() {
        ContentVersion file = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test',
            VersionData = Blob.valueOf('Test'),
            origin = 'H'
        );

        insert file;

        Test.startTest();
            List<ContentVersion> files = ContentVersionsSelector.selectById(new Set<Id>{file.Id});
        Test.stopTest();

        Assert.areEqual(1, files.size(), 'More/Less files returned than expected.');
    }
    
    @isTest
    private static void selectByContentDocumentId_Test() {
        List<ContentVersion> lstContentVersion = TestDataFactory.createContentVersion(1,'Test Document','TestDocument.pdf','Test content',true);
        insert lstContentVersion;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:lstContentVersion[0].Id].ContentDocumentId;
        Test.startTest();
        List<ContentVersion> files = ContentVersionsSelector.selectByContentDocumentId(conDocId);
        Test.stopTest();
        Assert.areEqual(1, files.size(), 'More/Less files returned than expected.');
    }
}