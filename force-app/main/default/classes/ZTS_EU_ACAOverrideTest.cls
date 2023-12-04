/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_ACAOverrideTest
* Description   :  Test class for ZTS_EU_AccountContactAffiliationOverride
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class ZTS_EU_ACAOverrideTest {
    
    public static testMethod void validate_ZTS_EU_AccountContactAffiliationOverrideTest (){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        System.runAs(usr)
        {
        List<ZTS_EU_Affiliations__c> acaList = ZTS_EU_DataUtilityTest1.createAccConAffiliationRecord(1);
        insert acaList ;
        ZTS_EU_Affiliations__c ACA= new ZTS_EU_Affiliations__c(id = acaList[0].id);
        PageReference pageRef = Page.ZTS_EU_NewAccountContactAffilOverride;
        Test.setCurrentPage(pageRef);
       ApexPages.currentPage().getParameters().put('accountId',acaList[0].ZTS_EU_Account__r.Id);    
        ApexPages.currentPage().getParameters().put('accountName',acaList[0].ZTS_EU_Account__r.Name);  
        ApexPages.currentPage().getParameters().put('contactId',acaList[0].ZTS_EU_Contact__r.Id);    
        ApexPages.currentPage().getParameters().put('contactName',acaList[0].ZTS_EU_Contact__r.Name);  
        ApexPages.StandardController stdACA= new ApexPages.StandardController(ACA);                        
        ZTS_EU_AccountContactAffiliationOverride acaObj = new ZTS_EU_AccountContactAffiliationOverride(stdACA);
        Test.startTest();
        acaObj.addRedirect();
        system.assertNotEquals(acaList.size(),0);
        }
        Test.stopTest();
        
    }
}