/**
 * @description       : All Trigger Test Logic for CaseContact object.
 * @author            : Venkat Joginapally @ Slalom
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   09-13-2021   Venkat Joginapally @ Slalom Created
 * 1.1   Unknown      Christain Brandt @ Slalom   Added Code
 * 1.2   03-22-2022   Ethan Hirsch @ Zoetis Inc   Move data setup into testSetup and fix validation errors
**/
@isTest
public class CSE_CaseContactTriggerHandlerTest {
    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    static final String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId(); 
    @testSetup
    public static void setupData(){
        Case testCase = new Case(Subject = 'Test Case',
        Status = 'New',
        Origin = 'Email',
        Type = 'Animal Complaint',
        RecordTypeId = animalRecordtypeId,
        Sync_Status__c=VmipsCaseSyncStatusHandler.SYNC_SUCCESS);
        insert testCase;

        Contact testContact = new Contact(LastName = 'Doe', FirstName = 'Testone', ZTS_US_Account_influence__c = 'Decision Maker'
                ,   ZTS_US_Profession__c = 'Consultant'
                ,   ZTS_US_Job_Function__c = 'Operations');
        insert testContact;
        
        Case_Contact__c testCaseContact = new Case_Contact__c(Contact__c = testContact.id, ZTS_US_Primary_Reporter__c = true, Primary__c = false, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = testCase.Id);
        insert testCaseContact;
    }

    @isTest
    private static void CSE_CaseContactPhoneBypassTest(){
        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCaseTest = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'Open',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Reportable',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today()
                                );
        insert newCaseTest;
        
        //updated Sync status Synced Successfully with PV Works
        newCaseTest.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_SUCCESS;
        update newCaseTest;

        //Insert Contact
		Contact contact = new Contact(LastName = 'Doe', FirstName = 'Testone',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant' , Phone = '12345678', ZTS_EU_Market__c = 'United States');
        insert contact;
 
        //Insert Case Contact
		Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, Phone_Five9__c = '1234567' , ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCaseTest.Id );
		insert caseContact;

        Test.startTest();
        //updated phone 
        contact.Phone = '3255786832';
        update contact; 
        Test.stopTest();

        Case testCase = [SELECT Id,Sync_Status__c FROM Case WHERE id  =: newCaseTest.Id limit 1];
        System.assertEquals(VmipsCaseSyncStatusHandler.SYNC_SUCCESS, testCase.Sync_Status__c);
    } 
    
     @isTest
    private static void CSE_CaseContactTriggerHandlerPositiveTest() {        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                Sync_Status__c=VmipsCaseSyncStatusHandler.SYNC_SUCCESS);
        insert newCase;
        //Insert Contact
		Contact contact = new Contact(LastName = 'Doe', FirstName = 'Testone',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant');
        insert contact;
        //Insert Case Contact
		Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id);
		insert caseContact;
        //testing - Case validation criteria met
        Boolean exceptionThrownMessage = false;
        Test.startTest();
        try{
            delete caseContact;
        } catch(DmlException ex){
            exceptionThrownMessage =  ex.getMessage().contains(CSE_CaseContactTriggerHandler.CASE_CONTACT_APPROVEDCASE_DELETE_ERROR) ? true : false;                    
        }
        Test.stopTest(); 
        System.assertNotEquals(false, exceptionThrownMessage,  'Deletion should trigger an error message as there has to be atleast one case contact for the approved case');
  
     Case syncStatus = [SELECT status, Id,Sync_Status__c FROM Case WHERE id  =: newCase.Id limit 1];
        System.debug('syncStatus positive test class method is is ***' +syncStatus); 
    }

    @isTest
    private static void CSE_CaseContactTriggerHandlerNegativeTest() {   
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                Sync_Status__c=VmipsCaseSyncStatusHandler.SYNC_SUCCESS);
        insert newCase;
        //Insert Contact
		List<contact> contactList = new  List<contact>();
        contactList.add(new Contact(LastName = 'Last1', FirstName = 'First1',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant'));   
        contactList.add(new Contact(LastName = 'Last2', FirstName = 'First2',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant'));
        insert contactList;

        //Insert Case Contact		
        List<Case_Contact__c> caseContactList = new  List<Case_Contact__c>();
        caseContactList.add(new Case_Contact__c(Contact__c = contactList[0].Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id));
        caseContactList.add(new Case_Contact__c(Contact__c = contactList[1].Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id));
        insert caseContactList;
        //testing - Case validation criteria met
        Test.startTest();
        delete caseContactList[0];
        Test.stopTest(); 
        List<Case_Contact__c> existingCaseContacts = [SELECT Id FROM Case_Contact__c WHERE Case__c =: newCase.Id];
        System.assertEquals(1, existingCaseContacts.size(), 'One case contact record should be deleted and there should only be one existing and shoud not throw an error on deletion');                
    }

    @isTest
    private static void CSE_CaseContactTriggerHandlerDeleteMultipleTest() {      
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                Sync_Status__c=VmipsCaseSyncStatusHandler.SYNC_SUCCESS);
        insert newCase;
        //Insert Contact
		List<contact> contactList = new  List<contact>();
        contactList.add(new Contact(LastName = 'Last1', FirstName = 'First1',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant'));   
        contactList.add(new Contact(LastName = 'Last2', FirstName = 'First2',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant'));
        insert contactList;
        
        //Insert Case Contact		
        List<Case_Contact__c> caseContactList = new  List<Case_Contact__c>();
        caseContactList.add(new Case_Contact__c(Contact__c = contactList[0].Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id));
        caseContactList.add(new Case_Contact__c(Contact__c = contactList[1].Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id));
        insert caseContactList;
        //testing - Case validation criteria met
        Boolean exceptionThrownMessage = false;
        Test.startTest();
        try{
            delete caseContactList;
        } catch(DmlException ex){
            exceptionThrownMessage =  ex.getMessage().contains(CSE_CaseContactTriggerHandler.CASE_CONTACT_APPROVEDCASE_DELETE_ERROR) ? true : false;                   
        }
        Test.stopTest(); 
        System.assertNotEquals(false, exceptionThrownMessage,  'Deletion should trigger an error message as there has to be atleast one case contact for the approved case');
   
     Case syncStatus = [SELECT status, Id,Sync_Status__c FROM Case WHERE id  =: newCase.Id limit 1];
        System.debug('syncStatus CSE_CaseContactTriggerHandlerDeleteMultipleTest method is is ***' +syncStatus); 
    }  
    
}