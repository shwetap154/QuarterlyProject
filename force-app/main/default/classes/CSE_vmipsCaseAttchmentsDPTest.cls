/******************************************************//**
@class      CSE_vmipsCaseAttchmentsDPTest
@brief      Test class for CSE_vmipsCaseAttchmentsDPTest. CSEPVW-95

@revision   04-08-2022  Ahmed Elawad
Created.

@copyright  (c)2022, Zoetis
**********************************************************/

@isTest
public with sharing class CSE_vmipsCaseAttchmentsDPTest {
    
    // Setup core records for tests. Account, case, Sortable Data Grid & related field records
    @TestSetup
    static void setup(){
        
        // get VMIPS Case record type
        Id recTypeVMIPS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support')?.getRecordTypeId();
        // create account
        Account acc = TestDataFactory.createAccount_US('CSE_vmipsCaseAttchmentsDPTest', true);
        
        // create contact on account
        Contact cntct = new Contact(AccountId=acc.Id, 
                                    FirstName='Test', 
                                    LastName='Contact', 
                                    Email='CSEVMIPSTest@Test.Test',
                                    ZTS_US_Account_influence__c='Key Decision Maker',
                                    ZTS_US_Profession__c='Academia',
                                    ZTS_US_Job_Function__c='Account Contact');
        INSERT cntct;
        
        // create vmips animal complaint case
        Case newCase = new Case(AccountId=acc.Id,
                                recordTypeId=recTypeVMIPS,
                                Type='Animal Complaint',
                                Origin='Phone',
                                Priority='Medium',
                                ZTS_US_First_Received_Date__c=Date.today(),
                                Status='Open' );
        INSERT newCase;
        
        // create sdg record
        sortablegrid__SDG__c sdgRec = new sortablegrid__SDG__c( sortablegrid__All_Rows__c=false, 
                                                               CurrencyIsoCode='USD', 
                                                               sortablegrid__Default_Sort__c='ContentDocument.LatestPublishedVersion.Title ASC', 
                                                               sortablegrid__Debug__c=true, 
                                                               sortablegrid__Enable_cache__c=true, 
                                                               sortablegrid__DisableSharing__c=false, 
                                                               sortablegrid__Filter__c='ContentDocument.LatestPublishedVersion.FileType != \'SNOTE\'', 
                                                               sortablegrid__Is_Valid__c=true, 
                                                               sortablegrid__Parent_Field_Name__c='LinkedEntityId', 
                                                               Name='Case Attachments VMIPS',
                                                               sortablegrid__SDG_Tag__c='CaseAttachmentsVMIPS', 
                                                               sortablegrid__sObjectName__c='ContentDocumentLink');
        INSERT sdgRec;
        
        // create sdg related record fields
        List<sortablegrid__SDG_Field__c> fields =
            new List<sortablegrid__SDG_Field__c>{
                new sortablegrid__SDG_Field__c(
                    sortablegrid__APIName__c='ContentDocument.LatestPublishedVersionId',
                    CurrencyIsoCode='USD',
                    sortablegrid__FieldOrder__c=5.0,
                    sortablegrid__Hide_Filter__c=false,
                    sortablegrid__is_valid_field__c=true,
                    sortablegrid__Override_Label__c='Document ID',
                    sortablegrid__sdg__c=sdgRec.Id),
                    new sortablegrid__SDG_Field__c(
                        sortablegrid__APIName__c='ContentDocument.LatestPublishedVersion.Send_to_PV_Works__c',
                        CurrencyIsoCode='USD',
                        sortablegrid__FieldOrder__c=6.0,
                        sortablegrid__Hide_Filter__c=false,
                        sortablegrid__is_valid_field__c=true,
                        sortablegrid__sdg__c=sdgRec.Id)
                    };
		INSERT fields;
    }
    
    // test LoadSDG
    static testmethod void LoadSDGTest() {
        CSE_vmipsCaseAttchmentsDP vmpipsDataProvider = new CSE_vmipsCaseAttchmentsDP();
        
        Test.StartTest();
        sortablegrid.SDG result = vmpipsDataProvider.LoadSDG('Test', ''); 
        Test.stopTest();
        
        // Assert results contain edit action and VMIPS Case attachment fields.
        System.assertEquals(result.SDGActions.size(), 1, 'Failed to retrieve all actions for component');
        System.assertEquals(result.SDGFields.size(), 6, 'Failed to retrieve all fields for component');
    }
    
    // test LoadSDG with default data
    static testmethod void getDataPositiveTest() {
        // load test account and case
        Account acc = [SELECT ID FROM ACCOUNT WHERE name='CSE_vmipsCaseAttchmentsDPTest'];
        Case testCase = [SELECT id FROM CASE WHERE AccountId=:acc.Id];
        Contact contactForCase = [SELECT Id FROM Contact WHERE AccountId=:acc.Id LIMIT 1];
        // loadthe data provider and initialize request object
        CSE_vmipsCaseAttchmentsDP vmpipsDataProvider = new CSE_vmipsCaseAttchmentsDP();
        sortablegrid.SDG loadedSDG = vmpipsDataProvider.LoadSDG('Test', '');
        sortablegrid.SDGRequest request = new sortablegrid.SDGRequest();
        
        // load requst attributes
        request.PageSize = 10;
        request.pageid = 1;
        request.filters = null; // populate filters for testing code: sortablegrid.SDGFilter type
        request.ParentRecordID = testCase.Id;
        request.SortColumn = null; // poplate sort
        request.sortOrder = 'A';
        
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = testCase.Id; 
        insert email;
        
        // verify results contain no records to start
        sortablegrid.SDGResult result = CSE_vmipsCaseAttchmentsDP.getData(loadedSDG, request);
        
        // Create content document and content version links
        Blob bodyBlob=Blob.valueOf('Test ContentVersion'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Test', 
            PathOnClient ='attachmentFilename.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        // insert a link for the case
        List<ContentDocumentLink> contentDocLinksToinsert = new List<ContentDocumentLink>();
        contentDocLinksToinsert.add(new ContentDocumentLink(LinkedEntityId = testCase.id, contentdocumentid = contentVersion_2.contentdocumentid, ShareType = 'V'));
        contentDocLinksToinsert.add(new ContentDocumentLink(LinkedEntityId = email.id, contentdocumentid = contentVersion_2.contentdocumentid, ShareType = 'V'));
        Insert contentDocLinksToinsert;
        
        // rerun the get data function. This should return the newly 
        // inserted document links on the case
        result = CSE_vmipsCaseAttchmentsDP.getData(loadedSDG, request);
        System.assertEquals(2, result.data.size(), 'Did not return 2 content document links');
    }
    
    
    // test LoadSDG with default data
    static testmethod void getDataNegativeTest() {
        // load test account and case
        Account acc = [SELECT ID FROM ACCOUNT WHERE name='CSE_vmipsCaseAttchmentsDPTest'];
        Case testCase = [SELECT id FROM CASE WHERE AccountId=:acc.Id];
        
        // loadthe data provider and initialize request object
        CSE_vmipsCaseAttchmentsDP vmpipsDataProvider = new CSE_vmipsCaseAttchmentsDP();
        sortablegrid.SDG loadedSDG = vmpipsDataProvider.LoadSDG('Test', '');
        sortablegrid.SDGRequest request = new sortablegrid.SDGRequest();
        
        // load requst attributes
        request.PageSize = 10;
        request.pageid = 1;
        request.filters = null; // populate filters for testing code: sortablegrid.SDGFilter type
        request.ParentRecordID = testCase.Id;
        request.SortColumn = null; // poplate sort
        request.sortOrder = 'A';
        
        // verify results contain no records to start
        sortablegrid.SDGResult result = CSE_vmipsCaseAttchmentsDP.getData(loadedSDG, request);
        
        System.assertEquals(result.data.size(), 0, 'Did not return an empty result for no attachments');
    }
    // test constructFilterString
    static testmethod void constructFilterString() {
        List<String> filters = new List<String>();
        List<sortablegrid.SDGFilter> filterList = new List<sortablegrid.SDGFilter>();
        Map<String, String> sortordertofieldAPIname = new Map<String, String>();
        sortablegrid.SDGFilter filter1 = new sortablegrid.SDGFilter();
        
        filter1.FilterOperator = 'CONTAINS';
        filter1.FilterValue = 'test';
        filter1.SDGFieldID = '1';
        sortordertofieldAPIname.put('1', 'Title');
        sortordertofieldAPIname.put('6', 'Name');
        sortordertofieldAPIname.put('4', 'CreateDate');
        
        // add date: = not= starts ends contains notcontains
        // add string: = not= starts ends contains notcontains
        CSE_vmipsCaseAttchmentsDP.constructFilterString(filters, filter1, sortordertofieldAPIname);
        filter1.FilterOperator = 'NOTCONTAINS';
        CSE_vmipsCaseAttchmentsDP.constructFilterString(filters, filter1, sortordertofieldAPIname);
        filter1.FilterOperator = 'NOT=';
        CSE_vmipsCaseAttchmentsDP.constructFilterString(filters, filter1, sortordertofieldAPIname);
        filter1.FilterOperator = 'STARTS';
        CSE_vmipsCaseAttchmentsDP.constructFilterString(filters, filter1, sortordertofieldAPIname);
        filter1.FilterOperator = 'ENDS';
        CSE_vmipsCaseAttchmentsDP.constructFilterString(filters, filter1, sortordertofieldAPIname);
        filter1.FilterOperator = '=';
        CSE_vmipsCaseAttchmentsDP.constructFilterString(filters, filter1, sortordertofieldAPIname);
        // verify result contiains fields
        
        // verify the filter list
        System.assertEquals(filters.size(), 6);
        
        String field1Filterresult1 = filters[0];
        String field1Filterresult2 = filters[2];
        String field1Filterresult3 = filters[3];
        System.assertEquals(field1Filterresult1, 'Title like \'%test%\'');
        
        // test different fid
        filters = new List<String>();
        
        // add filters 
        filter1.SDGFieldID = '6';
        filter1.FilterOperator = '=';
        CSE_vmipsCaseAttchmentsDP.constructFilterString(filters, filter1, sortordertofieldAPIname);
        
        System.assertEquals(filters.size(), 1);
        
        String field2Filterresult1 = filters[0];
        System.assertEquals(field2Filterresult1, 'Name = test');
        
        // test different fid
        filters = new List<String>();
        filter1.SDGFieldID = '4';
        filter1.FilterOperator = 'TODAY';
        filter1.FilterValue = 'TODAY';
        
        // add filters 
        CSE_vmipsCaseAttchmentsDP.constructFilterString(filters, filter1, sortordertofieldAPIname);
        filter1.FilterOperator = 'NOT=';
        filter1.FilterValue = '2022-01-01';
        CSE_vmipsCaseAttchmentsDP.constructFilterString(filters, filter1, sortordertofieldAPIname);
        filter1.FilterOperator = '=';
        CSE_vmipsCaseAttchmentsDP.constructFilterString(filters, filter1, sortordertofieldAPIname);
        filter1.FilterOperator = 'LT';
        CSE_vmipsCaseAttchmentsDP.constructFilterString(filters, filter1, sortordertofieldAPIname);
        filter1.FilterOperator = 'GT';
        CSE_vmipsCaseAttchmentsDP.constructFilterString(filters, filter1, sortordertofieldAPIname);
        
        // test added filters
        System.assertEquals(filters.size(), 5);
        System.assertEquals(filters[0], 'CreateDate = TODAY');
        System.assertEquals(filters[1], '(NOT CreateDate = 2022-01-01T12:00:00Z)'); 
        System.assertEquals(filters[2], 'CreateDate = 2022-01-01T12:00:00Z');
        System.assertEquals(filters[3], 'CreateDate < 2022-01-01T12:00:00Z');
        System.assertEquals(filters[4], 'CreateDate > 2022-01-01T12:00:00Z');
    }
}