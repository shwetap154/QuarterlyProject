/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_ConRedirectTest
* Description   :  Test class for ZTS_EU_ConRedirect
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_ConRedirectTest {
    
    public static testMethod void validate_ZTS_EU_ConRedirectTest(){
        
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Contact> contList = ZTS_EU_DataUtilityTest1.createContactRecord(1);
            contList[0].ZTS_EU_Market__c = 'United Kingdom';
            insert contList;
            Contact cont= new Contact(id = contList[0].id);
            PageReference pageRef = Page.ZTS_EU_ContactNewRedirect;
            Test.setCurrentPage(pageRef);
            Id contRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();
            ApexPages.currentPage().getParameters().put('RecordType',contRecordTypeId);      
            ApexPages.currentPage().getParameters().put('accId',contList[0].AccountId);    
            ApexPages.StandardController stdCont = new ApexPages.StandardController(cont);                        
            ZTS_EU_ConRedirect contObj = new ZTS_EU_ConRedirect(stdCont);
            Test.startTest();
            contObj.conRedirect();
            contObj.backToView();
            system.assertNotEquals(contList.size(),0);
            Test.stopTest();
        }
    }
}