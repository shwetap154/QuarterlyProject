/**
 * @description       : Test class for ZTS_EU_ContactAddinsertfromAccount, 
 *     which is called fromt he Intl Contact Trigger
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-21-2014   Unknown                     Initial Version
 * 1.1   03-21-2022   Ethan Hirsch @ Zoetis Inc   Fix failing Unit Tests by running tests as an International User
**/
@isTest
private class testZTS_EU_ContactAddinsertfromAccount {

    @isTest
    private static void ZTS_EU_ContactAddinsertfromAccount() {
        test.startTest();
       
            Set<Id> setAcc = new Set<Id>();
            list<account> lstAccount = new list<account>();
            List<Contact> lstcon = new List<Contact>();
            User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'eltonUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;
            List<Account> Accountrecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
        	System.runAs(usr)
            {
                insert Accountrecord;
            
                       
                setAcc.add(Accountrecord[0].id);

                List<Address__c> Addressrecord = ZTS_EU_DataUtilityTest.createAddressRecord(1);
                List<Address__c> lstadd =new  List<Address__c>();
                for(Address__c addr : Addressrecord){
                addr.ZTS_EU_Account__c = Accountrecord[0].id;
                lstadd.add(addr);
                }
                insert lstadd;

                List<Account> lstAcc = new List<Account>();
                for(account acc: Accountrecord){
                acc.ZTS_EU_Primary_Address__c = lstadd[0].id;
                acc.ZTS_EU_Market__c = 'United States';
                acc.BillingPostalCode = '00000'; 
                acc.BillingCity = 'testCity';
                acc.BillingState = 'testState'; 
                acc.BillingStreet = 'testStreet';
                lstAcc.add(acc);
                } 
                update lstAcc;
                contact c = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
                c.lastname = 'con';
                c.firstname = 'test';
                c.Accountid = lstAcc[0].id;
                lstcon.add(c);
                insert lstcon;
                
                ZTS_EU_ContactAddinsertfromAccount.ContactAddinsertfromAccount(setAcc, lstcon);
                ZTS_EU_ContactAddinsertfromAccount.insertAddress(lstcon);
            }
            
            
        
        test.stopTest();
        
    }
}