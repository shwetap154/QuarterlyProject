public with sharing class AccountHelper {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountList() {
        return [SELECT id, Name, Theraupeutic_Group__c,Applicable_Product_Lines__c, Product_Sales__c, APR__c, AUG__c, FEB__c, MAY__c, Grand_Total__c FROM Account where Theraupeutic_Group__c != null];
    }
}