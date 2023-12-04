/**
* File Name     :  CPQ_QuoteAddressUtilsTest
* @description  :  Test coverage for address utils.
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     1/27/2020		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/5/2020		Cory Bartholomew @ ATG     Added descriptions.

**/

@isTest
public  class CPQ_QuoteAddressUtilsTest {
    @isTest
    static void testQuoteAddressUtil(){
        List<Account> accts = new List<Account>();
        Account acct1 = CPQ_TestDataFactory.createAccount(false);
        Account acct2 = CPQ_TestDataFactory.createAccount(false);
        Account acct3 = CPQ_TestDataFactory.createAccount(false);
        Account acct4 = CPQ_TestDataFactory.createAccount(false);
        Account acct5 = CPQ_TestDataFactory.createAccount(false);
        accts.addAll(new List<Account>{acct1,acct2,acct3,acct4,acct5});
        insert accts;
        acct2.ParentId = acct1.Id;
        acct3.ParentId = acct2.Id;
        acct4.ParentId = acct3.Id;
        acct5.ParentId = acct4.Id;
        update accts;

        List<Address__c> addresses = new List<Address__c>();
        addresses.add(CPQ_TestDataFactory.createAddress(acct1, false));
        addresses.add(CPQ_TestDataFactory.createAddress(acct2, false));
        addresses.add(CPQ_TestDataFactory.createAddress(acct3, false));
        insert addresses;
        
        List<Account> queriedAccounts = CPQ_QuoteAddressUtils.queryAccountHierarchy(new Set<Id>{acct1.Id});
        System.assertEquals(5, queriedAccounts.size(), 'The account hierarchy query did not return the correct results.');
        Map<Id, List<Account>> parentAccountMap = CPQ_QuoteAddressUtils.buildParentAccountMap(new Set<Id>{acct1.Id},queriedAccounts);
        System.assertEquals(1, parentAccountMap.keySet().size());
    }
}