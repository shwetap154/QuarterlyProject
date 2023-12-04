/**
 * @description       : Test class for the Controller of SL_New_Service_Request page.
 * @author            : Akshay Agrawal @ Silverline
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-30-2019   Premraj K K @ Silverline    Initial Version JIRA Ticket LIGHTNI-1557
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc   Add header and fix errors due to Contact validation rule and Account Market defaulting to US
**/
@isTest
public with sharing class SL_NewServiceRequestController_Test {

    @isTest
    public static void testControllerForAccount() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        System.runAs(usr)
        {
            Account objAccount = (Account)SL_TestDataFactory.createSObject(new Account(Name='Test Account 1', BillingPostalCode = '00000', BillingCity = 'testCity', BillingState = 'testState', BillingStreet = 'testStreet', ZTS_EU_Market__c = 'United Kingdom', ZTS_EU_Zip_Postal_Code__c = '00001'), true);
            //insert objAccount;
            
            Contact objContact = (Contact)SL_TestDataFactory.createSObject(new Contact(FirstName='Test C', LastName='Test Contact 1', AccountId = objAccount.Id, ZTS_EU_Market__c = 'United Kingdom'), true);
            //insert objContact;
            
            objAccount.ZTS_EU_Primary_Contact__c = objContact.Id;
            update objAccount;
            
            PageReference pageRef = Page.SL_NewServiceRequest;      
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', objAccount.Id);
            
            ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(new List<Case>());
        
            SL_NewServiceRequestController objCntl = new SL_NewServiceRequestController(setCon);
            objCntl.redirectToURL();
            objCntl.backToView();
            system.assertNotEquals(objCntl.defaultValues, null);
        }
        
    }
    
    @isTest
    public static void testControllerForContact() {        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        System.runAs(usr)
        {
            Account objAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            objAccount.BillingPostalCode = '00000';
            objAccount.BillingCity = 'testCity';
            objAccount.BillingState = 'testState';
            objAccount.BillingStreet = 'testStreet';
            objAccount.ZTS_EU_Market__c = 'United Kingdom';
            insert objAccount;
            
            Contact objContact = ZTS_DataUtilityTest.createContactRecord(1)[0];
            objContact.AccountId = objAccount.Id;
            objContact.ZTS_EU_Market__c = 'United Kingdom';
            insert objContact;
            
            PageReference pageRef = Page.SL_NewServiceRequest;      
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', objContact.Id);
            ApexPages.currentPage().getParameters().put('def_account_id', objAccount.Id);
            ApexPages.currentPage().getParameters().put('def_contact_id', objContact.Id);
            ApexPages.currentPage().getParameters().put('retURL', '/'+objContact.Id);
            String recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
            ApexPages.currentPage().getParameters().put('RecordType', recordtypeId);
            
            ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(new List<Case>());
            SL_NewServiceRequestController objCntl = new SL_NewServiceRequestController(setCon);
            objCntl.redirectToURL();
            objCntl.backToView();
            system.assertNotEquals(objCntl.defaultValues, null);
            
            ApexPages.StandardController stdCon = new ApexPages.StandardController(new Case());
            SL_NewServiceRequestController objStdSrvcCon = new SL_NewServiceRequestController(stdCon);
            objStdSrvcCon.redirectToURL();
            system.assertNotEquals(objStdSrvcCon.defaultValues, null);
        }
    }
}