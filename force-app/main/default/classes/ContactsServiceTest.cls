/**
 * @description       : Test class for ContactsService class
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
* @last modified on  : 04-19-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   1-24-2023    Padma Nerella @ Zoetis Inc  Added updateContactwithAccountEmailTest method TPDev-103
* 1.1   4-12-2023    Padma Nerella @ Zoetis Inc  Added updateRepContactStatusInactiveTest method TPDev-104
**/

@isTest
private class ContactsServiceTest {
    
    @TestSetup
    static void setup(){
        
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        testUser.ZTS_EU_Market__c = 'United Kingdom';
        
        System.runAs(testUser) {
            List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(3);
            for (Account account : accounts) {
                account.ZTS_EU_Market__c = 'United Kingdom';
                account.ZTS_EU_Account_Status__c = 'Active';
            }
            
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            insert accounts;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            List<Contact> contacts = ZTS_DataUtilityTest.createContactRecord(4);
            for (Contact contact : contacts) {
                contact.ZTS_EU_Contact_Status__c = 'Active';
                contact.ZTS_EU_Market__c = 'United Kingdom';
            }
            
            contacts[0].LastName = 'Contact0';
            contacts[0].AccountId = accounts[0].Id;
            contacts[1].AccountId = accounts[1].Id;
            contacts[1].LastName = 'Contact1';
            contacts[2].LastName = 'Contact02';
            contacts[2].AccountId = accounts[2].Id;
            
            insert contacts;
        }
    }
    
    @isTest
    static void updateContactwithAccountEmailTest(){
        
        List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(1);
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        Insert testAccts;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        List<Contact> conList = new List<Contact>();
        Contact cont = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
        cont.AccountId = testAccts[0].Id;
        cont.ZTS_EU_Contact_Status__c = 'Active';
        cont.ZTS_EU_Profession__c = 'Account Contact';
        cont.ZTS_US_Job_Function__c= 'Clinical Faculty';
        conList.add(cont);
        insert conList;
        
        testAccts[0].ZTS_Invalid_Email__c = true;
        List<Account> accountList = new List<Account>();
        accountList.add(testAccts[0]);  
        test.StartTest();
        DispatchTriggerHandler.firstTimeTracker.clear();
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        update accountList;
        test.StopTest();
        List<Contact> newContactList = [Select Id,ZTS_Invalid_Email__c,AccountId From Contact where AccountId IN:accountList and Id IN:conList];
        System.assertEquals(true,newContactList[0].ZTS_Invalid_Email__c);

    }
    @isTest
    static void updateRepContactStatusInactiveTest(){
        
        List<Account> accList = [Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where ZTS_EU_Market__c!='United States'];
        List<Account> accNewList = new List<Account>();
        
        for(Account acc:accList){
            acc.ZTS_EU_Account_Status__c = 'Inactive';
            accNewList.add(acc);
        }
        
        List<ZTS_EU_Affiliations__c> affiliationList = [Select id, Name, ZTS_EU_Contact__c,ZTS_EU_Account__c,ZTS_EU_Account__r.ZTS_EU_Account_Status__c,ZTS_EU_Contact__r.ZTS_EU_Contact_Status__c, ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c where ZTS_EU_Account__r.Id =:accNewList];
        
        Test.startTest();
        DispatchTriggerHandler.firstTimeTracker.clear();
        update accNewList;
        Test.stopTest();
        
        List<ZTS_EU_Affiliations__c> updatedAffiliationList = [Select id, Name, ZTS_EU_Contact__c,ZTS_EU_Account__c,ZTS_EU_Account__r.ZTS_EU_Account_Status__c,ZTS_EU_Contact__r.ZTS_EU_Contact_Status__c, ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c where ZTS_EU_Account__r.Id =:accNewList and ZTS_EU_Affiliation_Status__c ='Inactive'];
        
        System.assertEquals(3, updatedAffiliationList.size(), 'When Account status updated to inactive the affiliations associated to that account also gets updated to Inactive status');
        List<Contact> conList = [Select Id,ZTS_EU_Contact_Status__c from Contact where ZTS_EU_Contact_Status__c ='Inactive'];
        System.assertEquals(3, conList.size(), 'Contact status updated to inactive when affiliations status updated to inactive');
    }
    @isTest
    static void updateRepContactStatusWithTwoAffiliationsTest(){
        List<Account> accountsList = ZTS_DataUtilityTest.createAccountRecord(2);
        for (Account account : accountsList) {
            account.ZTS_EU_Market__c = 'United Kingdom';
            account.ZTS_EU_Account_Status__c = 'Active';
        }
        accountsList[0].Name = 'Account1';
        accountsList[1].Name = 'Account2';
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert accountsList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        List<Contact> contacts = ZTS_DataUtilityTest.createContactRecord(2);
        for (Contact contact : contacts) {
            contact.ZTS_EU_Contact_Status__c = 'Active';
            contact.ZTS_EU_Market__c = 'United Kingdom';
        }
        
        contacts[0].LastName = 'Contact0';
        contacts[0].AccountId = accountsList[0].Id;
        contacts[1].AccountId = accountsList[1].Id;
        contacts[1].LastName = 'Contact1';
        insert contacts;
        
        List<ZTS_EU_Affiliations__c> affiliations = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
        
        affiliations[0].ZTS_EU_Affiliation_Status__c = 'Active';
        affiliations[0].ZTS_EU_Account__c = accountsList[0].Id;
        affiliations[0].ZTS_EU_Contact__c = contacts[1].Id;
        insert affiliations;
        
        List<ZTS_EU_Affiliations__c> affiliationList = [Select id, Name, ZTS_EU_Contact__c,ZTS_EU_Account__c,ZTS_EU_Account__r.ZTS_EU_Account_Status__c,ZTS_EU_Contact__r.ZTS_EU_Contact_Status__c, ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c where ZTS_EU_Account__r.Id =:accountsList];
        
        accountsList[0].ZTS_EU_Account_Status__c = 'Inactive';
        Test.startTest();
        DispatchTriggerHandler.firstTimeTracker.clear();
        UtilityService.AccAffInsertRun = true;
        update accountsList;
        Test.stopTest();
        
        List<ZTS_EU_Affiliations__c> updatedAffiliationList = [Select id, Name, ZTS_EU_Contact__c,ZTS_EU_Account__c,ZTS_EU_Account__r.ZTS_EU_Account_Status__c,ZTS_EU_Contact__r.ZTS_EU_Contact_Status__c, ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c where ZTS_EU_Account__r.Id =:accountsList and ZTS_EU_Affiliation_Status__c ='Inactive'];
        
        System.assertEquals(2, updatedAffiliationList.size(), '2 affiliation records status updated to Inactive');
        
        List<Contact> conList = [Select Id,ZTS_EU_Contact_Status__c from Contact where Id =:contacts];
        for(Contact con :conList){
            if(con.Id == contacts[0].Id){
                System.assertEquals('Inactive',con.ZTS_EU_Contact_Status__c,'Contact status updated to inactive when affiliation updated to inactive status');
            }
            else if(con.Id == contacts[1].Id){
                System.assertEquals('Active',con.ZTS_EU_Contact_Status__c,'Contact status did not get updated to inactive since this contact is having two affilaition records one if the affiliation record is in still active');
            }
        }
    }
    
    @isTest
    private static void testSendReportingContactsToLIS() {
        
        ZTS_DataUtilityTest.activateTriggerSettings();
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> accountRecordsList = ZTS_DataUtilityTest.createAccountRecord(1);
            accountRecordsList[0].Reference_Lab_Customer__c = true;
            accountRecordsList[0].LIS_Org_Code__c = '123456';
            insert accountRecordsList;
            
            State_Country__c stc = new State_Country__c();
            stc.name = 'test co';
            stc.ZTS_EU_Country__c = 'Albania';
            insert stc;
            
            Address__c adds = new Address__c();
            adds.name = 'test line';
            adds.ZTS_EU_Account__c = accountRecordsList[0].Id;
            adds.ZTS_EU_Address_Type__c = 'Shipping';
            adds.ZTS_EU_District__c = 'Teast';
            adds.ZTS_EU_Country__c = 'Albania';
            adds.ZTS_EU_State_County__c = stc.id;
            adds.Zip_Postal_Code__c = '738747';
            adds.ZTS_US_Source_Account_Number__c = '908090';
            adds.Is_Active__c = true;
            adds.LIS_Number__c = '99999test';
            adds.Ship_Indirect__c = 'N';
            insert adds;
            
            Address__c adds1 = new Address__c();
            adds1.name = 'test line';
            adds1.ZTS_EU_Account__c = accountRecordsList[0].Id;
            adds1.ZTS_EU_Address_Type__c = 'Shipping';
            adds1.ZTS_EU_District__c = 'Teast';
            adds1.ZTS_EU_Country__c = 'Albania';
            adds1.ZTS_EU_State_County__c = stc.id;
            adds1.Zip_Postal_Code__c = '738747';
            adds1.ZTS_US_Source_Account_Number__c = '908090';
            adds1.Is_Active__c = true;
            adds1.LIS_Number__c = '99999test';
            adds1.Ship_Indirect__c = 'N';
            insert adds1;
            
            List<Contact> contactRecordList = ZTS_DataUtilityTest.createContactRecord(1);
            for ( Contact con : contactRecordList ) {
                con.AccountId = accountRecordsList[0].id;
                con.Reference_Lab_Contact__c = true;
                con.ZTS_US_Profession__c = 'Veterinarian';
                con.ZTS_US_Job_Function__c = 'Associate';
                con.RefLabs_Email_Default__c = true;
                con.RefLabs_Results_Email__c = 'test@test.com';
            }
            insert contactRecordList;
            
            contactRecordList[0].Send_To_LIS__c = false;
            update contactRecordList;
            
            test.startTest();
            
            AccountTriggerHandler accTriggerHandler = new AccountTriggerHandler();
            DispatchTriggerHandler.setRecursionContexts(accTriggerHandler);
            accountRecordsList[0].LIS_Org_Code__c = '78967671';
            update accountRecordsList;
            
            test.stopTest();
            
            List<Contact> relatedReportingContacts =
                [   SELECT  Id, Send_To_LIS__c
                 FROM    Contact
                 WHERE   AccountId IN :accountRecordsList             
                ];
            
            System.assertEquals(true, relatedReportingContacts[0].Send_To_LIS__c,'The Contact is marked as RefLabs contact');
            System.assertEquals(true, accountRecordsList[0].Reference_Lab_Customer__c,'Reference_Lab_Customer is true');
            
        }
        
    }
    
     @isTest
    private static void testSendReportingContactsToLIS2() {
        
        ZTS_DataUtilityTest.activateTriggerSettings();
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> accountRecordsList = ZTS_DataUtilityTest.createAccountRecord(1);
            accountRecordsList[0].Reference_Lab_Customer__c = true;
            accountRecordsList[0].LIS_Org_Code__c = '123456';
            insert accountRecordsList;
            
            State_Country__c stc = new State_Country__c();
            stc.name = 'test co';
            stc.ZTS_EU_Country__c = 'Albania';
            insert stc;
            
            Address__c adds = new Address__c();
            adds.name = 'test line';
            adds.ZTS_EU_Account__c = accountRecordsList[0].Id;
            adds.ZTS_EU_Address_Type__c = 'Shipping';
            adds.ZTS_EU_District__c = 'Teast';
            adds.ZTS_EU_Country__c = 'Albania';
            adds.ZTS_EU_State_County__c = stc.id;
            adds.Zip_Postal_Code__c = '738747';
            adds.ZTS_US_Source_Account_Number__c = '908090';
            adds.Is_Active__c = true;
            adds.LIS_Number__c = '99999test';
            adds.Ship_Indirect__c = 'N';
            insert adds;
            
            Address__c adds1 = new Address__c();
            adds1.name = 'test line';
            adds1.ZTS_EU_Account__c = accountRecordsList[0].Id;
            adds1.ZTS_EU_Address_Type__c = 'Shipping';
            adds1.ZTS_EU_District__c = 'Teast';
            adds1.ZTS_EU_Country__c = 'Albania';
            adds1.ZTS_EU_State_County__c = stc.id;
            adds1.Zip_Postal_Code__c = '738747';
            adds1.ZTS_US_Source_Account_Number__c = '908090';
            adds1.Is_Active__c = true;
            adds1.LIS_Number__c = '99999test';
            adds1.Ship_Indirect__c = 'N';
            insert adds1; 
            
            List<Contact> contactRecordList = ZTS_DataUtilityTest.createContactRecord(1);
            for ( Contact con : contactRecordList ) {
                con.AccountId = accountRecordsList[0].id;
                con.Reference_Lab_Contact__c = true;
                con.ZTS_US_Profession__c = 'Veterinarian';
                con.ZTS_US_Job_Function__c = 'Associate';
                con.RefLabs_Email_Default__c = true;
                con.RefLabs_Results_Email__c = 'test@test.com';
            }
            insert contactRecordList;
            
            contactRecordList[0].Send_To_LIS__c = false;
           // update contactRecordList;
            Map<Id, Contact> contactoldmap = new Map<Id, Contact>(); 
            contactoldmap.put(contactRecordList[0].id, contactRecordList[0]);
            test.startTest();
            
            AccountTriggerHandler accTriggerHandler = new AccountTriggerHandler();
            DispatchTriggerHandler.setRecursionContexts(accTriggerHandler);
            accountRecordsList[0].LIS_Org_Code__c = '78967671';
            update accountRecordsList;
            
            ContactsService.updateSendTOLIS(contactRecordList,null,true);
            
            test.stopTest();
            
            List<Contact> relatedReportingContacts =
                [   SELECT  Id, Send_To_LIS__c
                 FROM    Contact
                 WHERE   AccountId IN :accountRecordsList             
                ];
            
            System.assertEquals(true, relatedReportingContacts[0].Send_To_LIS__c,'The Contact is marked as RefLabs contact');
            System.assertEquals(true, accountRecordsList[0].Reference_Lab_Customer__c,'Reference_Lab_Customer is true');
            
        }
        
    }
    
    
   
}