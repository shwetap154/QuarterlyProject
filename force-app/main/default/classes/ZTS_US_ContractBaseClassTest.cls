/**
 * @description       : Test class for ZTS_EU_AddtoCampaignRedirect
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-02-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                           Modification
 * 1.0   07-14-2014   Ketan Prakash Singh @ Deloitte   Initial Version
 * 1.1   08-02-2022   Ethan Hirsch @ Zoetis Inc        Remove SeeAllData from test. This does result in lost code 
 *                                                     coverage overall, but ZTS_US_ContractBaseClass is at 60%
 *                                                     before and after the change. This was done for best practices.
 *                                                     Create a User with a manager to run testZTS_US_ContractBaseClass
 *                                                     as to avoid any issues with the Contract Approval flow that uses the Manager.
**/
@isTest(SeeAllData = false)
public class ZTS_US_ContractBaseClassTest{
    Public static List<Contract> contrList = new List<Contract>();
    Public static list<string> lstContractIds = new List<string>();
    
    public static void createTestData(){
        contrList = ZTS_DataUtilityTest.createContractRecord(1);
        // David Stern, commenting out because this is horrible code.
        //contrList[0].RecordTypeId = System.Label.ZTS_US_Contract_Record_Type_Id_for_Contract_Renewal;
        contrList[0].RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Contract_Renewal' LIMIT 1].Id;
        contrList[0].ZTS_US_Field_Proposed_Tier__c = 'Elite';
        contrList[0].ZTS_US_Review_Committee_Proposed_Tier__c = 'Elite';
        insert contrList;
        for(Contract contr: contrList){
            lstContractIds.add(contr.id);
        }
        //Amitabh Code for Code Coverage
        List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);   
        insert accList;
        // David Stern, commented out hardcoded id, because this is horrible code.
         Contract contr1 = new Contract(name='Test',recordtypeid = [SELECT Id FROM RecordType WHERE DeveloperName = 'MVP_Proposal' LIMIT 1].Id,/*'01231000001AgxS'*/AccountId = accList[0].id,ZTS_US_Field_Proposed_Tier__c='Premier',ZTS_US_Review_Committee_Proposed_Tier__c='Premier',ZTS_US_BIOs_Proposed_Tier__c='10,000',ZTS_US_BIOs_Field_Proposed_Tier__c='10,000'); 
         insert contr1;
         ZTS_US_ContractBaseClass.SingleApproveRenewal(contr1); //create test class and pass Id here
        // End code
    }
    public static void createTestData_NegativeTest(){
        contrList = ZTS_DataUtilityTest.createContractRecord(1);
        // David Stern, commenting out because this is horrible code.
        //contrList[0].RecordTypeId = System.Label.ZTS_US_Contract_Record_Type_Id_for_Contract_Renewal;
        contrList[0].RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Contract_Renewal' LIMIT 1].Id;
        contrList[0].ZTS_US_Field_Proposed_Tier__c = NULL;
        contrList[0].ZTS_US_Review_Committee_Proposed_Tier__c = NULL;
        insert contrList;
        for(Contract contr: contrList){
            lstContractIds.add(contr.id);
        }
        List<Account> accList = new List<Account>();       
        for(Integer i=0;i<1;i++) {
            Account acc = new Account();         
            acc.name = 'Test Account'+i;
            acc.ZTS_US_Business_Class__c = NULL;
            acc.ZTS_EU_Country__c = 'United States';
            acc.BillingCity = NULL;
            acc.ZTS_US_State_Province__c  = NULL;
            acc.BillingStreet = NULL;  
            acc.ZTS_US_NARC_ID__c='NC'+(100*336)+i;
            accList.add(acc);    
        }    
        insert accList; 
        // David Stern, commenting this out because this code is horrible.
         Contract contr1 = new Contract(name='Test',recordtypeid = [SELECT Id FROM RecordType WHERE DeveloperName = 'MVP_Proposal' LIMIT 1].Id,/*'01231000001AgxS',*/AccountId = accList[0].id,ZTS_US_Field_Proposed_Tier__c=NULL,ZTS_US_Review_Committee_Proposed_Tier__c=NULL,ZTS_US_BIOs_Proposed_Tier__c=NULL,ZTS_US_BIOs_Field_Proposed_Tier__c='10,000'); 
         insert contr1;
         ZTS_US_ContractBaseClass.SingleApproveRenewal(contr1); //create test class and pass Id here
        // End code
    }
    static testmethod void testZTS_US_ContractBaseClass(){
        // Run this test as a User with a Manager to work around an issue with creating a Contract as a User without
        // a Manager.
        User testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        testUser.ManagerId = UserInfo.getUserId();
        
        System.runAs(testUser) {
            createTestData();
            Test.startTest();
            ZTS_US_ContractBaseClass.massApproveRenewal(lstContractIds);
            Test.stopTest();
        }
    }
    
}