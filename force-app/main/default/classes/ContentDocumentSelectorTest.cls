/**
Class Name	    : ContentDocumentSelectorTest
Description	    : Test Class created as part of TPDEV-428 for the ContentDocumentSelector Class. 
Created By		: Sibin Kuriakose
Created Date	: 04-04-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				04-04-2023	 Created methods to Test Methods on ContentDocumentSelector
*/
@isTest
public class ContentDocumentSelectorTest {
    /**     * @Description This method will test selectContentById method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 04-04-2023 
    */
    @isTest
    public static void selectContentDocumentIdTest() {

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

        ContentVersion tempId = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id =: file.Id];

        List<Id> recordId = new List<Id>();
        recordId.add(tempId.ContentDocumentId);
        Test.startTest();
            List<ContentDocument> links = ContentDocumentSelector.selectContentById(recordId);
        Test.stopTest();
        System.assertEquals(1,links.size());
    }
}