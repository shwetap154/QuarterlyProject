/**
 * @description       : Test class for alphaCustomLibraryController
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   09-17-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc      Fix an error with there being only one Contentworkspace
**/
@isTest
public class alphaCustomLibraryController_Test {

    
    public static testmethod void alphaDistReadOnly(){
        List<ContentWorkSpace> contentWorkSpaces = [SELECT ID FROM CONTENTWORKSPACE LIMIT 2];

        // Make sure there are at least 2 Content Workspaces for this Unit Test
        if (contentWorkSpaces.size() < 2) {
            List<ContentWorkspace> newContentWorkspaces = new List<ContentWorkspace>();
            for (integer i = contentWorkSpaces.size(); i <= 1; i++) {
                newContentWorkspaces.add(new contentWorkSpace(
                    Name = 'Test Library',
                    DeveloperName = 'Test_Library'
                ));
            }

            System.runAs(new User(Id = UserInfo.getUserId())) {
                insert newContentWorkspaces;
            }

            contentWorkSpaces.addAll(newContentWorkspaces);
        }
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Distributor Customer Service'];
        
        State_Country__c sc = new State_Country__c();
        sc.Name = 'Test State-Country';
        sc.ZTS_EU_Country__c = 'United Kingdom';
        insert sc;
        account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = 'ALPHA';
        acc.ZTS_EU_Country__c='United Kingdom';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        acc.ZTS_EU_State_County__c = sc.Id;
        acc.BillingStreet = '123 Street';
        acc.BillingCity = 'Parsippany';
        acc.BillingState = 'New Jersey';
        acc.BillingPostalCode = '07054';
        acc.BillingCountry = 'United States';
        insert acc;
        List<Id> accId = new List<Id>();
        accId.add(acc.id);
        contact con=new contact();
        con.ZTS_EU_Market__c = 'ALPHA';
        con.lastname='test last';
        con.accountid=acc.id;
        con.email='test@email.com';
        insert con;
        User usr = new User(alias = 'standt', email='standarduser@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                            localesidkey='fr', profileid = p.Id, ZTS_EU_Market__c = '123456',
                            timezonesidkey='America/Los_Angeles', username='testUser@testsales.com');
        insert usr;
        
        Product2 prod = new Product2(Name = 'Laptop X200',
                                     Family = 'Hardware');
        insert prod;
        
        alphaCustomLibraryController.getMarket(usr.Id);
        alphaCustomLibraryController.getFiles(usr.Id,true);
        alphaCustomLibraryController.accountSearch(accId);

        List<String> libraryList = new List<String>();
        libraryList.add('Library Content');
        alphaCustomLibraryController.getLibraries(libraryList);
        
        ContentVersion newFile = new ContentVersion();
        newFile.Title = 'Test File';
        newFile.PathOnClient = 'https://www.google.com';
        newFile.VersionData = Blob.valueOf('a');
        newFile.RecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Library_Content').getRecordTypeId();
        insert newFile;
        newFile = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :newFile.Id];

        ContentDocumentLink newLink = new ContentDocumentLink();
        newLink.ContentDocumentId = newFile.ContentDocumentId;
        newLink.ShareType = 'I';
        newLink.Visibility = 'AllUsers';
        newLink.LinkedEntityId = contentWorkSpaces[0].Id;
        insert newLink;

        List<String> cvList = new List<String>();
        cvList.add(newFile.Id);
        alphaCustomLibraryController.getFileLibraries(cvList);
        alphaCustomLibraryController.changeLibraries(cvList, contentWorkSpaces[1].Id);
        
        List<Map<String, Object>> saveFilesData = new List<Map<String, Object>>();
        Map<String, Object> saveFilesDataInside = new Map<String, Object>();
        List<Object> adList = new List<Object>();
        Map<String, String> adMap = new Map<String, String>();
        adMap.put('Id', 'test'); 
        adList.add(adMap);
        List<Object> amList = new List<Object>();
        Map<String, String> amMap = new Map<String, String>();
        amMap.put('value', 'ALPHA'); 
        amList.add(amMap);
        List<Object> asList = new List<Object>();
        Map<String, String> asMap = new Map<String, String>();
        asMap.put('value', 'Equine'); 
        asList.add(asMap);
        saveFilesDataInside.put('Id', newFile.Id);
        saveFilesDataInside.put('Title', 'a');
        saveFilesDataInside.put('Library', contentWorkSpaces[0].Id);
        saveFilesDataInside.put('Product_Line__c', 'Advocin');
        saveFilesDataInside.put('Applicable_Distributors__c', adList);
        saveFilesDataInside.put('Applicable_Markets__c', amList);
        saveFilesDataInside.put('Applicable_Species__c', asList);
        saveFilesData.add(saveFilesDataInside);
        alphaCustomLibraryController.saveFiles(saveFilesData);
        
        Map<String, Object> fileData = new Map<String, Object>();
        fileData.put('title', 'a');
        fileData.put('library', contentWorkSpaces[0].Id);
        fileData.put('productLine', 'Advocin');
        fileData.put('path', 'a');
        List<Object> speciesList = new List<Object>();
        speciesList.add('Poultry');
        fileData.put('species', speciesList);
        List<Object> marketList = new List<Object>();
        marketList.add('ALPHA');
        fileData.put('market', marketList);
        List<Object> distributorList = new List<Object>();
        distributorList.add(adMap);
        fileData.put('distributor', distributorList);
        alphaCustomLibraryController.uploadFile(EncodingUtil.Base64Encode(Blob.valueOf('a')), fileData);

        alphaCustomLibraryController.deleteFile(newFile.Id);
        alphaCustomLibraryController.downloadFile(newFile.Id);
    }
}