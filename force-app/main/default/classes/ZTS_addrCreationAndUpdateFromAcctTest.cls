/**
 * @description       : Test class for ZTS_addrCreationAndUpdateFromAccount
 * @author            : Teresa @ Deloitte Consulting
 * @group             : 
 * @last modified on  : 03-17-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                          Modification
 * 1.0   07-16-????   Teresa @ Deloitte Consulting    Created the Class.
 * 2.0   10-13-2017   Shiva Kudikilla @ Cognizant     Updated for SC-002202 MZR Listening Logic
 * 2.1   07-07-2022   Ethan Hirsch @ Zoetis Inc       Fix issues with inserting Contacts that caused Unit Test failures. 
 *                                                    Set Market on Account to United Kingdom so code coverage is applied to ZTS_addrCreationAndUpdateFromAccount
 * 2.2   02-24-2023   Padma nerella @ Zoetis Inc      Removed ContactsService.updateContactwithAccountEmail methode out  no test code running for this logic TPDEV-103
**/
@isTest
public class ZTS_addrCreationAndUpdateFromAcctTest{
    @testSetup
    static void testSetup()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
       
    }
    static testMethod void validate_ZTS_AddressCreation(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        ZTS_DataUtilityTest.activateTriggerSettings();
        List<Account> accList=new List<Account>();
        accList = ZTS_DataUtilityTest.createAccountRecord(6);
        setMarketOnAccounts(accList);
        accList[0].ZTS_Business_Class__c = 'Producers';
        accList[1].ZTS_Business_Class__c = 'Veterinarian';
        Test.startTest();
        
        System.runAs(usr)
        {
            insert accList;
        }
        ZTS_addrCreationAndUpdateFromAccount.chkUpdate = true;
        accList[0].BillingStreet ='Test 1 Street';
        accList[4].parentId= accList[0].id;
        System.runAs(usr)
        {
            update accList;
        }
        List <Contact> contList= new List <Contact>();
        contList=ZTS_DataUtilityTest.createContactRecord(1);
        contList[0].AccountId = accList[0].Id;
        contList[0].ZTS_EU_Market__c = 'United Kingdom';
        System.runAs(usr)
        {
            insert contList;
        }
        accList[0].BillingStreet ='Test 2 Street';
        update accList;
        ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Account__c = accList[3].Id);
        insert aff;
        accList[3].ZTS_EU_Account_Status__c='Inactive';
        Test.stopTest();
        accList[3].MZR_Status__c ='Active';
        ZTS_checkTriggerRun.resetAll();
        update accList;
        accList[3].ZTS_US_VGP_Enrollment_Status__c='VGP Enrolled';
        accList[3].ZTS_EU_Reason__c = 'Moved';
        ZTS_checkTriggerRun.resetAll();
        update accList;
        accList[3].ZTS_MVP_Account__c=true;
        ZTS_checkTriggerRun.resetAll();
        update accList;
        accList[4].parentId= null;
        ZTS_checkTriggerRun.resetAll();
        update accList;
        System.assertNotEquals(accList.size(),0);
    }
    
    static testmethod void testupdateAccountContractDetails(){
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
            User usr1 = [SELECT Id, ZTS_EU_Primary_Business_Unit__c,ZTS_EU_Market__c,Profile.name FROM User WHERE id=: UserInfo.getUserId()];
            ZTS_DataUtilityTest.activateTriggerSettings();
            List<Account> accList=new List<Account>();
            accList = ZTS_DataUtilityTest.createAccountRecord(6);
            setMarketOnAccounts(accList);
            accList[0].ZTS_Business_Class__c = 'Producers';
            accList[1].ZTS_Business_Class__c = 'Veterinarian';
            Test.startTest();
            insert accList;
            //ZTS_addrCreationAndUpdateFromAccount.updateAccountContractDetails(accList);
            ZTS_addrCreationAndUpdateFromAccount.setAccountStatus(accList,usr1);
            ZTS_addrCreationAndUpdateFromAccount.splitAccountName(accList[0]);
            accList[2].parentId = accList[0].id;
            ZTS_checkTriggerRun.resetAll();
            update accList;
            ZTS_checkTriggerRun.resetAll();
            accList[2].ZTS_MVP_Account__c = true;
            update accList;
            Test.stopTest();
        }
    } 
    
    static testmethod void updatecontractdetailschildaccountsTest()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'test';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            ZTS_DataUtilityTest.activateTriggerSettings();
            List<Account> accList=new List<Account>();
            accList = ZTS_DataUtilityTest.createAccountRecord(6);
            setMarketOnAccounts(accList);
            insert accList;
            
            Map<Id, Account> triggerNew = new Map<Id, Account>();
            for(Account acc : accList)
                triggerNew.put(acc.Id, acc);
            
            ZTS_addrCreationAndUpdateFromAccount.chkUpdate = true;
            accList[0].BillingStreet ='Test 1 Street';
            accList[4].parentId= accList[0].id;
            accList[5].parentId= accList[0].id;   
            update accList;
            
            Contact ct =  ZTS_DataUtilityTest.createContactRecord(1)[0];
            ct.ZTS_EU_Profession__c = 'Account Contact';
            ct.ZTS_EU_Contact_Status__c = 'Active';
            ct.AccountId = accList[0].Id;
            ct.ZTS_EU_Market__c = 'United Kingdom';

            insert ct;
            
            accList[0].MZR_Status__c ='Active';
            accList[0].ZTS_US_VGP_Enrollment_Status__c='VGP Enrolled';
            accList[0].ZTS_MVP_Account__c=true;   
            //ZTS_addrCreationAndUpdateFromAccount.updatecontractdetailschildaccounts(triggerNew);
            ZTS_ZoetisException ze = new ZTS_ZoetisException ();
            ze.exceptionName = 'test';
            
            Test.startTest();
            update accList;
            accList[0].MZR_Status__c ='Eligible';
            accList[0].ZTS_EU_Account_Status__c = 'Member';
            update accList;
            
            accList[0].ZTS_US_VGP_Enrollment_Status__c ='VGP Enrolled'; 
            update accList;
            
            accList[4].parentId= accList[0].id;
            accList[0].MZR_Status__c = 'Active';
            update accList;
            
            accList[0].MZR_Status__c = 'Active';
            update accList;
            
            accList[0].parentId = null;
            accList[0].MZR_Status__c = 'Not Eligible';
            accList[4].parentId= accList[0].id;
            update accList;
            
            delete accList[4];
            
            Test.stopTest();
            
            List<Account> accList2=new List<Account>();
            accList2 = ZTS_DataUtilityTest.createAccountRecord(1);
            setMarketOnAccounts(accList);
            Account master = accList2[0];
            master.Name = 'Account1';
            insert master;       
            List<Account> duplicates = new List<Account>();
            Account dup1 = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            dup1.Name = 'Account1, Inc.';
            Account dup2 = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            dup2.Name = 'Account1';
            duplicates.add(dup1);
            duplicates.add(dup2);
            setMarketOnAccounts(duplicates);
            
            insert duplicates;        
            Database.MergeResult[] results = Database.merge(master, duplicates, false);
            
            
            ZTS_checkTriggerRun.resetAll();
            
            accList[0].MZR_Status__c = 'Active';
            accList[0].ZTS_US_VGP_Enrollment_Status__c ='VGP Enrolled'; 
            update accList[0];
            
            System.assertNotEquals(accList.size(),0);
        }
    }

    private static void setMarketOnAccounts(List<Account> accounts) {
        for (Account account : accounts) {
            account.ZTS_EU_Market__c = 'United Kingdom';
        }
    }
}