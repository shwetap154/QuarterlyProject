/*******************************************************************************************************************************************
* File Name     :  ZTS_US_ContractTierChangesTest
* Description   :           
* @author       :  Ketan Prakash Singh
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/14         Ketan             Created the Class.

********************************************************************************************************************************************/
@isTest
public class ZTS_US_ContractTierChangesTest{
    Public static List<Contract> contrList = new List<Contract>();
    
    public static void createTestData(){
        
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        System.runAs(intlUsr) {
            contrList = ZTS_DataUtilityTest.createContractRecord(1);
            contrList[0].RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Contract_Renewal').getRecordTypeId();
            contrList[0].ZTS_US_External_ID__c = 'Test123';
            contrList[0].ZTS_US_Submitter_Comments__c = 'Test';
            contrList[0].ZTS_US_Current_Tier__c = 'Elite';
            contrList[0].ZTS_US_Field_Proposed_Tier__c = 'Elite';
            //contrList[0].ZTS_US_Review_Committee_Proposed_Tier__c = 'Elite';
            insert contrList;
        }
        
    }
    
    
    static testmethod void testZTS_US_ContractTierChanges(){
        createTestData();
        
        ApexPages.standardController cont =  new ApexPages.StandardController(contrList[0]);
        PageReference myPage = Page.ZTS_US_ContractTierChanges;
        myPage.getParameters().put('contractId',contrList[0].id);
        test.setCurrentPage(myPage);
        ZTS_US_ContractTierChanges conTierChange = new ZTS_US_ContractTierChanges(cont);
        
        Test.startTest();
        conTierChange.SubmitForApproval();
        Test.stopTest();
    }
}