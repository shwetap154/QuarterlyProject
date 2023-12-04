@isTest
public with sharing class updateAccountsFromBatchTest 
{
    @isTest
    public static void updateAccountsFromBatchTest() 
    {        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> accounts = ZTS_EU_DataUtilityTest1.createAccountRecord(1);
            insert accounts;
            
            ZTS_EU_Net_Sales__c newNetSale = new ZTS_EU_Net_Sales__c(ZTS_EU_Account__c = accounts[0].Id, ZTS_EU_Date__c = System.today() - 1, CurrencyIsoCode = 'CAD');
            ZTS_EU_Sales__c newSale = new ZTS_EU_Sales__c(ZTS_EU_Account__c = accounts[0].Id, ZTS_EU_Date__c = System.today() - 2, CurrencyIsoCode = 'CAD');
            ZTS_EU_Accounting_Period__c newAccountingPeriod = new ZTS_EU_Accounting_Period__c(ZTS_EU_AP_Start_Editable__c = System.today() - 3, 
                                                                                              ZTS_EU_AP_End_Editable__c = System.today() - 1, 
                                                                                              ZTS_EU_Market__c = 'United Kingdom', 
                                                                                              ZTS_EU_Account_Period__c = '01',
                                                                                              ZTS_EU_No_of_Working_Days__c = 3);
            
            insert new List<SObject>{newNetSale, newSale, newAccountingPeriod};                
                
            Test.startTest();
            	updateAccountsFromBatch ap = new updateAccountsFromBatch(accounts);
            Test.stopTest();
        }
    }
}