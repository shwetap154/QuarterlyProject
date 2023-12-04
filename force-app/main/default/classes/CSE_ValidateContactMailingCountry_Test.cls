@isTest
public with sharing class CSE_ValidateContactMailingCountry_Test {

    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';

    //Test Method for updating the Mailing Country from the VMIPS Mailing country picklist field for case type = ANIMAL SUPPORT
	 @isTest
     static void test_validateContactRecordsForApproval_MailingCountry()
    {

        //Test contact for contact specific logic tests
        Contact testContact = (Contact) SL_TestDataFactory.createSObject
        (   new Contact
            (    ZTS_US_Institution__c = 'Purdue University'
                ,    Title = 'Test'
                ,    ZTS_US_Account_influence__c    = 'Decision Maker'
                ,    ZTS_US_Profession__c = 'Consultant'
                ,    ZTS_US_Job_Function__c = 'Operations'
            )
            ,   true
        );
        testContact.MailingStreet = '100 Main Street';
        testContact.MailingCity = 'Boston';
        testContact.VMIPS_Mailing_Country__c = 'United States';
        testContact.MailingCountry = '';
        Update testContact;
        
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        //test case created and inserted
        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId, 
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;

        Case_Contact__c caseContact = (Case_Contact__c) SL_TestDataFactory.createSObject( new Case_Contact__c(Case__c = testCase.Id, Contact__c = testContact.Id ), true);

        Contact contactTest = [SELECT ID, ZTS_US_Institution__c, Title, Gender__c, MailingCountry, VMIPS_Mailing_Country__c FROM Contact WHERE Title = 'Test' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Id caseTestId = caseTest.id;
        Id contactTestId = contactTest.id;
        Case_Contact__c caseContactTest = [SELECT ID, Contact__c, Case__c FROM Case_Contact__c WHERE Case__c = :caseTestId LIMIT 1];
        Set<String> fieldSet = new Set<String>{'MailingCountry', 'VMIPS_Mailing_Country__c'};
        Map<Id, Contact> mapTestContacts = new Map<Id, Contact>();
        mapTestContacts.put(contactTestId, contactTest);
        List<Case_Contact__c> listTestCaseContacts = new List<Case_Contact__c>();
        listTestCaseContacts.add(caseContactTest);
        CSE_ValidateContactMailingCountry.validateContactMailingCountry(listTestCaseContacts, mapTestContacts, fieldSet);
        //validate the expected and actual values
        System.assertEquals('United States', contactTest.MailingCountry, 'Failed to update the Mailing Country');
    }


    //Test Method for updating the Mailing Country from the VMIPS Mailing country picklist field for case type = HUMAN EXPOSURE
	 @isTest
     static void test_validateContactRecordsForApproval_MailingCountry_HECases()
    {

        //Test contact for contact specific logic tests
        Contact testContact = (Contact) SL_TestDataFactory.createSObject
        (   new Contact
            (    ZTS_US_Institution__c = 'Northeastern University'
                ,    Title = 'Test1'
                ,    ZTS_US_Account_influence__c    = 'Decision Maker'
                ,    ZTS_US_Profession__c = 'Consultant'
                ,    ZTS_US_Job_Function__c = 'Operations'
            )
            ,   true
        );
        testContact.MailingStreet = '444 Washington Street';
        testContact.MailingCity = 'Boston';
        testContact.VMIPS_Mailing_Country__c = 'United States';
        testContact.MailingCountry = '';
        Update testContact;
        
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        //test case created and inserted
        Case testCase = new Case(Subject = 'Test Case 1',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Human Exposure',
                            RecordTypeId = animalRecordtypeId, 
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;

        Case_Contact__c caseContact = (Case_Contact__c) SL_TestDataFactory.createSObject( new Case_Contact__c(Case__c = testCase.Id, Contact__c = testContact.Id ), true);

        Contact contactTest = [SELECT ID, ZTS_US_Institution__c, Title, Gender__c, MailingCountry, VMIPS_Mailing_Country__c FROM Contact WHERE Title = 'Test1' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject FROM Case WHERE Subject = 'Test Case 1' LIMIT 1];
        Id caseTestId = caseTest.id;
        Id contactTestId = contactTest.id;
        Case_Contact__c caseContactTest = [SELECT ID, Contact__c, Case__c FROM Case_Contact__c WHERE Case__c = :caseTestId LIMIT 1];
        Set<String> fieldSet = new Set<String>{'MailingCountry', 'VMIPS_Mailing_Country__c'};
        Map<Id, Contact> mapTestContacts = new Map<Id, Contact>();
        mapTestContacts.put(contactTestId, contactTest);
        List<Case_Contact__c> listTestCaseContacts = new List<Case_Contact__c>();
        listTestCaseContacts.add(caseContactTest);
        CSE_ValidateContactMailingCountry.validateContactMailingCountry(listTestCaseContacts, mapTestContacts, fieldSet);
        //validate the expected and actual values
        System.assertEquals('United States', contactTest.MailingCountry, 'Failed to update the Mailing Country');
    }

    //Test Method for updating the Mailing Country from the VMIPS Mailing country picklist field for case type = PRODUCT DEFECT
	 @isTest
     static void test_validateContactRecordsForApproval_MailingCountry_PDCases()
    {

        //Test contact for contact specific logic tests
        Contact testContact = (Contact) SL_TestDataFactory.createSObject
        (   new Contact
            (    ZTS_US_Institution__c = 'UMASS University'
                ,    Title = 'Test2'
                ,    ZTS_US_Account_influence__c    = 'Decision Maker'
                ,    ZTS_US_Profession__c = 'Consultant'
                ,    ZTS_US_Job_Function__c = 'Operations'
            )
            ,   true
        );
        testContact.MailingStreet = '100 Bolyston Street';
        testContact.MailingCity = 'Boston';
        testContact.VMIPS_Mailing_Country__c = 'United States';
        testContact.MailingCountry = '';
        Update testContact;
        
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        //test case created and inserted
        Case testCase = new Case(Subject = 'Test Case 2',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Product Defect Only',
                            RecordTypeId = animalRecordtypeId, 
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;

        Case_Contact__c caseContact = (Case_Contact__c) SL_TestDataFactory.createSObject( new Case_Contact__c(Case__c = testCase.Id, Contact__c = testContact.Id ), true);

        Contact contactTest = [SELECT ID, ZTS_US_Institution__c, Title, Gender__c, MailingCountry, VMIPS_Mailing_Country__c FROM Contact WHERE Title = 'Test2' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject FROM Case WHERE Subject = 'Test Case 2' LIMIT 1];
        Id caseTestId = caseTest.id;
        Id contactTestId = contactTest.id;
        Case_Contact__c caseContactTest = [SELECT ID, Contact__c, Case__c FROM Case_Contact__c WHERE Case__c = :caseTestId LIMIT 1];
        Set<String> fieldSet = new Set<String>{'MailingCountry', 'VMIPS_Mailing_Country__c'};
        Map<Id, Contact> mapTestContacts = new Map<Id, Contact>();
        mapTestContacts.put(contactTestId, contactTest);
        List<Case_Contact__c> listTestCaseContacts = new List<Case_Contact__c>();
        listTestCaseContacts.add(caseContactTest);
        CSE_ValidateContactMailingCountry.validateContactMailingCountry(listTestCaseContacts, mapTestContacts, fieldSet);
        //validate the expected and actual values
        System.assertEquals('United States', contactTest.MailingCountry, 'Failed to update the Mailing Country');
    }
}