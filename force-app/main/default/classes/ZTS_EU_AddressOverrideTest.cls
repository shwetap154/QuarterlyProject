/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.

* Name          :   ZTS_EU_AddressOverrideTest .
* Description   :    This is used to test ZTS_EU_AddressOverride.
* Author        :    Sunil

Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
5/26/2014       Sunil                       Created
*/
@isTest(seeAllData= false)
public with sharing class ZTS_EU_AddressOverrideTest {
    public static testMethod void testaddRedirectMethod(){		
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert acclist;
            List<Address__c> addlist = ZTS_EU_DataUtilityTest.createAddressRecord(1);
            List<Address__c> insertAddList = new List<Address__c>();
            for(Address__c a : addlist){			
                a.ZTS_EU_Account__c = acclist[0].id;
                insertAddList.add(a);
            }
            insert insertAddList;
            Address__c addObj = new Address__c(id =insertAddList[0].id);		
            PageReference pageRef = Page.ZTS_EU_AddressNewOverride;
            Test.setCurrentPage(pageRef);
            Id addRecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Account_Address').getRecordTypeId();
            ApexPages.currentPage().getParameters().put('accId',acclist[0].id);
            ApexPages.currentPage().getParameters().put('RecordType',addRecordTypeId);
            ApexPages.StandardController stdAdd = new ApexPages.StandardController(addObj);
            ZTS_EU_AddressOverride addOverObj = new ZTS_EU_AddressOverride(stdAdd);
            Test.startTest();
            addOverObj.addRedirect();
            Test.stopTest();
        }
    }
}