/**
 * @description       : Test Class for NOA_Financially_Authorized_Person__c
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             :
 * @last modified on  : 09-07-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   08-29-2023   Padma Nerella @ Zoetis Inc     Add selectByLeadIdTest method
 * 1.2   09-07-2023   Padma Nerella @ Zoetis Inc     Modified API Version to 58 
 **/
@isTest
private class FinanciallyAuthorizedPersonSelectorTest {
    
    @TestSetup
    static void setup(){
        
        List<Lead> noaLead = TestDataFactory.createLeadRec(1);
        noaLead[0].FirstName='lead';
        noaLead[0].LastName='leadLast';
        noaLead[0].Business_Name__c ='Petco 1773 FT Myers Hospital';
        insert noaLead;
        
        List<NOA_Financially_Authorized_Person__c> noaFinanciallyAuthPersonInsertList = new List<NOA_Financially_Authorized_Person__c>();
        List<NOA_Financially_Authorized_Person__c> noaFinanciallyAuthPersonList1 = TestDataFactory.createFinanciallyAuthorizedPerson(1,noaLead[0].Id);
        noaFinanciallyAuthPersonList1[0].Email__c = 'noaAuth@Zoetis.com';
        noaFinanciallyAuthPersonList1[0].Primary__c = true;
        noaFinanciallyAuthPersonInsertList.addAll(noaFinanciallyAuthPersonList1);
        
        insert noaFinanciallyAuthPersonInsertList;
    }
    
    @isTest
    static void selectByLeadIdTest(){
        List<NOA_Financially_Authorized_Person__c> authList1 = [Select Id,Email__c,Primary__c,Lead__c from NOA_Financially_Authorized_Person__c];
        List<Lead> leadList = [Select Id from Lead];
        Set<Id> leadIdSet = new Set<Id>();
        for(Lead ld:leadList){
            leadIdSet.add(ld.Id);
        }
        Test.startTest();
        List<NOA_Financially_Authorized_Person__c> authList = FinanciallyAuthorizedPersonSelector.selectByLeadId(leadIdSet);
        Test.stopTest();
        Assert.areEqual(1,authList.size(),'One Financially Authorized Person retrived');
    }

}