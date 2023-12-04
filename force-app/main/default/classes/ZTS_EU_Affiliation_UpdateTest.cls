/**
 * @description       : Test class for ZTS_EU_Affiliation_Update
 * @author            : Mayukh Deb @ Cognizant
 * @group             : 
 * @last modified on  : 04-11-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-07-2022   Mayukh Deb @ Cognizant      Initial Version
 * 1.1   07-30-2021   Unknown                     Unknown Updates
 * 1.2   06-07-2022   Ethan Hirsch @ Zoetis Inc   Update references to JPN & North Asia Profiles to not include &
 *                                                as part of changes to Profile names to avoid Copado deployment issues. 
 * 1.3   08-03-2022   Ethan Hirsch @ Zoetis Inc   Add additional Unit Tests for updateContactAffiliation to verify 
 *                                                functionality and a bug fix around a null exception when an Account
 *                                                errors.
 * 1.4   08-03-2022   Ethan Hirsch @ Zoetis Inc   Bypass Triggers in test setup to save on limits to resolve errors
 * 1.5   11-21-2022   Ethan Hirsch @ Zoetis Inc   Bypass the Contact Trigger in updateContactAffilation_ContactInactiveUpdateLastAffiliationToSetAccountInactive
 *                                                to account for it running on Affiliation update due to a new rollup field being introduced on Contact.
 * 1.6   04-18-2023   Padma Nerella @ Zoetis Inc  Removed updateAccountContactAffilation method execution in test class, moved this logic AffiliationsServiceTest class
**/
@isTest(SeeAllData=false)
private class ZTS_EU_Affiliation_UpdateTest{
    private static final String CONTACT_SINGLE_ACCOUNT_RELATION_LASTNAME = 'SingleContact';
    private static final String CONTACT_MULTIPLE_ACCOUNT_RELATION_LASTNAME1 = 'MultipleContact1';
    private static final String CONTACT_MULTIPLE_ACCOUNT_RELATION_LASTNAME2 = 'MultipleContact2';
    private static final String ACCOUNT_MULTIPLE_CONTACT_AFFILIATIONS_NAME = 'MultiRelationAccount';

    @TestSetup
    private static void setup(){
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        testUser.ZTS_EU_Market__c = 'United Kingdom';

        System.runAs(testUser) {
            // Disable Triggers to save on limits and execution times
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            DispatchTriggerHandler.bypass('ContactTriggerHandler');
            DispatchTriggerHandler.bypass('ZTS_EU_AffiliationsTriggerHandler');
            List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(3);
            for (Account account : accounts) {
                account.ZTS_EU_Market__c = 'United Kingdom';
                account.ZTS_EU_Account_Status__c = 'Active';
            }

            accounts[1].Name = ACCOUNT_MULTIPLE_CONTACT_AFFILIATIONS_NAME;

            insert accounts;
            
            List<Contact> contacts = ZTS_DataUtilityTest.createContactRecord(3);
            for (Contact contact : contacts) {
                contact.ZTS_EU_Contact_Status__c = 'Active';
                contact.ZTS_EU_Market__c = 'United Kingdom';
            }
            
            contacts[0].LastName = CONTACT_SINGLE_ACCOUNT_RELATION_LASTNAME;
            // Setting Account will automatically create an Affiliation only if triggers are enabled
            contacts[0].AccountId = accounts[0].Id;
            contacts[1].LastName = CONTACT_MULTIPLE_ACCOUNT_RELATION_LASTNAME1;
            contacts[2].LastName = CONTACT_MULTIPLE_ACCOUNT_RELATION_LASTNAME2;

            insert contacts;

            List<ZTS_EU_Affiliations__c> affiliations = ZTS_DataUtilityTest.createAccConAffiliationRecord(4);
            affiliations[0].ZTS_EU_Affiliation_Status__c = 'Active';
            affiliations[0].ZTS_EU_Account__c = accounts[1].Id;
            affiliations[0].ZTS_EU_Contact__c = contacts[1].Id;

            affiliations[1].ZTS_EU_Affiliation_Status__c = 'Active';
            affiliations[1].ZTS_EU_Account__c = accounts[1].Id;
            affiliations[1].ZTS_EU_Contact__c = contacts[2].Id;

            affiliations[2].ZTS_EU_Affiliation_Status__c = 'Active';
            affiliations[2].ZTS_EU_Account__c = accounts[2].Id;
            affiliations[2].ZTS_EU_Contact__c = contacts[2].Id;

            affiliations[3].ZTS_EU_Affiliation_Status__c = 'Active';
            affiliations[3].ZTS_EU_Account__c = accounts[0].Id;
            affiliations[3].ZTS_EU_Contact__c = contacts[0].Id;

            insert affiliations;
            // Clear Bypasses for regular tests
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
            DispatchTriggerHandler.clearBypass('ZTS_EU_AffiliationsTriggerHandler');
        }
    }

    static testmethod void MyUnitTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> acclist=new List<Account>();
            List<Account> acclist1=new List<Account>();
            List<Account> acclist2=new List<Account>();
            List<Contact> conlst=new List<Contact>();
            list<ZTS_EU_Affiliations__c> listofAff = new List<ZTS_EU_Affiliations__c>();
            Map<id,Account> accmp=new Map<id,Account>();
            Map<id,Account> accmp1=new Map<id,Account>();
            
            
            
            Account acc=new Account(Name='testAccount',ZTS_EU_Account_Status__c='Inactive',ZTS_EU_Reason__c='Out of Business',
                                    ZTS_EU_Market__c='United Kingdom',
                                    Practice_Management_Software__c = 'Other',
                                    Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                    ZTS_EU_Zip_Postal_Code__c = '12345');
            insert acc;
            acc.ZTS_EU_Account_Status__c = 'Active';
            Update acc;
            
            Account acc5=new Account(Name='testAccount2', 
                                     ZTS_EU_Reason__c='Out of Business',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Account_Status__c = 'Active',
                                     ZTS_EU_Zip_Postal_Code__c = '12345');
            insert acc5;
            Test.startTest();
            ZTS_EU_Account_Affiliations__c accaff = new ZTS_EU_Account_Affiliations__c(ZTS_EU_Affiliation_Status__c='Active',ZTS_EU_Affiliated_Account__c=acc.id, ZTS_EU_Account__c = acc5.Id);
            insert accaff;
            Account acc1=new Account(Name='testAccount1',ZTS_EU_Account_Status__c='Inactive',ZTS_EU_Reason__c='Out of Business',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345');
            insert acc1;
            //acc1.Name='Test123';
            //  update acc1;
            Account acc2=new Account(Name='test',ZTS_EU_Account_Status__c='Bad_Address',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345');
            insert acc2;
            
            Account acc3=new Account(Name='test345',ZTS_EU_Account_Status__c='Active',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345');
            insert acc3;
            /*Account acc3=[Select Id from Account  where id =: acc.id  AND ZTS_EU_Market__c != 'United States'];
acc3.ZTS_EU_Account_Status__c='Active';
update acc3;*/
            Contact contest=new Contact(FirstName='firstname',LastName='testContact',ZTS_EU_Rep_Contact_Status__c='Inactive',ZTS_EU_Reason_for_Inactivation__c='Moved',ZTS_EU_Contact_Status__c='Inactive');
            insert contest;
            Contact contest2=new Contact(FirstName='first',Lastname='test',ZTS_EU_Rep_Contact_Status__c='Active',ZTS_EU_Contact_Status__c='Active');
            insert contest2;
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            Contact contest3=new Contact(FirstName='first',Lastname='test',ZTS_EU_Rep_Contact_Status__c='Active',ZTS_EU_Contact_Status__c='Active', ZTS_EU_Market__c = 'United Kingdom');
            insert contest3;
            conlst.add(contest);
            conlst.add(contest2);
            acclist.add(acc);
            acclist1.add(acc1);
            acclist2.add(acc2);
            accmp.put(acc.id, acc);
            accmp1.put(acc.id,new Account(Id = acc.Id, ZTS_EU_Account_Status__c = 'Inactive',
                                          ZTS_EU_Market__c='United Kingdom',
                                          Practice_Management_Software__c = 'Other',
                                          Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                          ZTS_EU_Zip_Postal_Code__c = '12345'));
            
            
            ZTS_EU_Affiliations__c testAffiliations=new ZTS_EU_Affiliations__c(ZTS_EU_Account__c=acc.id,  ZTS_EU_Contact__c=contest.id, ZTS_EU_Affiliation_Status__c ='Active',Name ='test');
            insert testAffiliations;
            listofAff.add(testAffiliations);
            ZTS_EU_Affiliations__c testAffiliations2=new ZTS_EU_Affiliations__c(ZTS_EU_Account__c=acc2.id,  ZTS_EU_Contact__c=contest.id, ZTS_EU_Affiliation_Status__c ='Active',Name ='test2');
            insert testAffiliations2;
            listofAff.add(testAffiliations2);
            ZTS_EU_Affiliations__c testAffiliations3=new ZTS_EU_Affiliations__c(ZTS_EU_Account__c=acc3.id,  ZTS_EU_Contact__c=contest2.id, ZTS_EU_Affiliation_Status__c ='Active',Name ='test3');
            insert testAffiliations3;
            
            acc3.ZTS_EU_Primary_Contact__c = contest2.id;
            update acc3;
            
          
            
           
            
       
            try{
              delete testAffiliations3 ;
            }
            catch(Exception e)
            {
                 Boolean expectedExceptionThrown =  e.getMessage().contains('Please change the primary contact of the account before deleting this affiliation record.') ? true : false;
            system.assertEquals(expectedExceptionThrown,true);       
            }
            

            ZTS_EU_Affiliation_Update.UpdateContactAffilation(conlst);
            ZTS_EU_Affiliation_Update.myFlag = false;
            
            ZTS_EU_Affiliation_Update.createAccountContactAffiliationRecord(conlst);
            ZTS_EU_Affiliation_Update.updateAccountContactAffiliationRecord(conlst);
            ZTS_EU_Affiliation_Update.deleteAccountContactAffiliationRecord(conlst);
            ZTS_EU_Affiliation_Update.updateAccountAffiliation(acclist,accmp1,accmp);
            Test.stopTest();
        }
        
    }
    
    static testmethod void testDeleteAccounts(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Account acc=new Account(Name='test',ZTS_EU_Account_Status__c='Bad_Address',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345');
            insert acc;
            
            delete acc;
        }
    }
    
    static testmethod void testAccountTeamCreation(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Data Admin';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> testAccounts = new List<Account>();
            Account acc=new Account(Name='test',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345');
            testAccounts.add(acc);
            insert testAccounts;
            
            ZTS_EU_Territory__c testTerritory = new ZTS_EU_Territory__c(Name = 'test',
                                                                        ZTS_EU_Market__c='United Kingdom');
            insert testTerritory;
            
            ZTS_EU_Position__c testPosition = new ZTS_EU_Position__c(ZTS_EU_Territory__c = testTerritory.Id,
                                                                     ZTS_EU_Employee__c = acc.OwnerId);
            insert testPosition;
            
            ZTS_createAccountTeams.AccountTeamCreation(testAccounts);
            List<ZTS_EU_Account_Position__c> accountTeamList = [Select Id from ZTS_EU_Account_Position__c];
            System.assert(accountTeamList.size()>0, 'Failed to create account teams');
        }
    }
    
    static testmethod void testDeleteAccountsAff(){
        
        ZTS_GL_Account_Affiliation_Reverse_Roles__c newCustomSetting = new ZTS_GL_Account_Affiliation_Reverse_Roles__c();
        newCustomSetting.Name = 'Member of';
        newCustomSetting.ZTS_GL_Reverse_Role__c = 'Branch of';
        insert newCustomSetting;
        
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Data Admin';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> testAccounts = new List<Account>();
            Account acc=new Account(Name='test',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345');
            testAccounts.add(acc);
            Account acc2=new Account(Name='testAccount2', 
                                     ZTS_EU_Reason__c='Out of Business',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Account_Status__c = 'Active',
                                     ZTS_EU_Zip_Postal_Code__c = '12345');
            testAccounts.add(acc2);
            insert testAccounts;
            
      ZTS_EU_Account_Affiliations__c accaff = new ZTS_EU_Account_Affiliations__c(ZTS_EU_Affiliation_Status__c='Active',ZTS_EU_Affiliated_Account__c=acc.id, ZTS_EU_Account__c = acc2.Id,ZTS_EU_Role__c='Member Of');
            insert accaff;
            
            ZTS_EU_BUG_Parentpopulate.deleteAccountsAff(testAccounts);
            List<ZTS_EU_Account_Affiliations__c> testAccountAff = [Select Id from ZTS_EU_Account_Affiliations__c];   
            System.assert(testAccountAff.size()==0, 'Failed to delete account affiliation');
            
            undelete accaff;
            
            List<ZTS_EU_Account_Affiliations__c> testAccountAff2 = [Select Id from ZTS_EU_Account_Affiliations__c];   
            System.assert(testAccountAff2.size()>0, 'Failed to undelete account affiliation');
        }
    }
    
    static testmethod void testUpdateAccounts(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Data Admin';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> testAccounts = new List<Account>();
            Map<Id, Account> testParentAcc = new Map<Id, Account>();
            Account acc=new Account(Name='test',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345');
            insert acc;
            
            Account acc2=new Account(Name='testAccount2', 
                                     ZTS_EU_Reason__c='Out of Business',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Account_Status__c = 'Active',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     parentId = acc.Id);
            insert acc2;
            testParentAcc.put(acc2.Id, acc);
            testAccounts.add(acc2);
            ZTS_EU_BUG_Parentpopulate.updateAccounts(testAccounts, testParentAcc);
        }
    }
    
    static testmethod void testHQRating_Update(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Data Admin';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Map<Id, Account> testNewAcc = new Map<Id, Account>();
            Map<Id, Account> testOldAcc = new Map<Id, Account>();
            Account acc=new Account(Name='test',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A');
            insert acc;
            
            Account acc2=new Account(Name='testAccount2', 
                                     ZTS_EU_Reason__c='Out of Business',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Account_Status__c = 'Active',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     parentId = acc.Id,
                                     ZTS_EU_Parent_Id__c = acc.Id,
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'B');
            insert acc2;
            
            testNewAcc.put(acc2.Id, acc2);
            testOldAcc.put(acc2.Id, acc);
            
            ZTS_EU_HQRating_Update.HQRating_Update(testNewAcc, testOldAcc);
            
            List<Account> childAccount = [Select Id, ZTS_EU_CA_HQ_Penetration_Rating__c From Account Where Name = 'testAccount2'];
            System.assertEquals('A', childAccount[0].ZTS_EU_CA_HQ_Penetration_Rating__c, 'Failed to update Account');
        }
    }
    
    static testmethod void testUpdateParentAccount(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Data Admin';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Map<Id, Account> testNewAcc = new Map<Id, Account>();
            Map<Id, Account> testOldAcc = new Map<Id, Account>();
            List<Account> testAccounts = new List<Account>();
            Account acc=new Account(Name='test',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A');
            insert acc;
            
            Account acc2=new Account(Name='testAccount2', 
                                     ZTS_EU_Reason__c='Out of Business',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Account_Status__c = 'Active',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     parentId = acc.Id,
                                     ZTS_EU_Parent_Id__c = acc.Id,
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'B',
                                     ZTS_EU_Vetsave_ID__c = 'test',
                                     ZTS_EU_Vetsave_HO_ID__c = 'test');
            insert acc2;
            
            Account acc3=new Account(Name='testAccount2', 
                                     ZTS_EU_Reason__c='Out of Business',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Account_Status__c = 'Active',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'B');
            insert acc3;
            
            VetSave_Market__c testVetSave = new VetSave_Market__c();
            testVetSave.Name = 'United Kingdom';
            testVetSave.Market__c = 'United Kingdom';
            insert testVetSave;
            
            Vetsave_UK__c testVetSaveUK = new Vetsave_UK__c();
            testVetSaveUK.Name = 'United Kingdom';
            testVetSaveUK.Market__c = 'United Kingdom';
            insert testVetSaveUK;
            
            System.debug('vetsave test data: '+[select id, name from VetSave_Market__c]);
            testNewAcc.put(acc2.Id, acc2);
            testOldAcc.put(acc2.Id, acc);
            testOldAcc.put(acc3.Id, acc);
            testAccounts.add(acc2);
            testAccounts.add(acc3);
            ZTS_EU_Account_Vetsave_Functionality.updateParentAccount(testAccounts, testOldAcc, true, true, true);
        }
    }
    
    static testmethod void testPopulatePotentialRegion(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Data Admin';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> testAccounts = new List<Account>();           
            Account acc6=new Account(Name='test6',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='Italy',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     Type = 'Vet Practice');
            insert acc6;
            
            Account acc7=new Account(Name='test7',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='Italy',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     Type = 'Farm');
            insert acc7;
            
            Account acc8=new Account(Name='test8',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='Italy',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     Type = 'Dealer');
            insert acc8;

            testAccounts.add(acc6);
            testAccounts.add(acc7);
            testAccounts.add(acc8);
            ZTS_addrCreationAndUpdateFromAccount.populatePotentialRegion(testAccounts);
        }
    }
    
    static testmethod void testSetAccountStatus(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Data Admin';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        User usr2 = new User();
        usr2 = ZTS_EU_DataUtilityTest.createUserWithProfile('JPN and North Asia Field Based Function', false);
        usr2.FirstName = 'Data Admin';
        usr2.zts_eu_market__c = 'Japan';
        insert usr2;
        
        User usr3 = new User();
        usr3 = ZTS_EU_DataUtilityTest.createUserWithProfile('JPN and North Asia Business Administrator', false);
        usr3.FirstName = 'Data Admin';
        usr3.zts_eu_market__c = 'Japan';
        insert usr3;
        
        System.runAs(usr)
        {
            List<Account> testAccounts = new List<Account>();
            Account acc=new Account(Name='test',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     ZTS_EU_Sub_Type__c = 'Use or may use FTAI');
            insert acc;
            
            testAccounts.add(acc);
            ZTS_addrCreationAndUpdateFromAccount.setAccountStatus(testAccounts, usr);
            ZTS_addrCreationAndUpdateFromAccount.setAccountStatus(testAccounts, usr2);
            ZTS_addrCreationAndUpdateFromAccount.setAccountStatus(testAccounts, usr3);
        }
    }
    
    static testmethod void testSyncOptOutFlagGermany(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Data Admin';
        usr.zts_eu_market__c = 'Germany';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> testAccounts = new List<Account>();
            Account acc=new Account(Name='test',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='Germany',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     ZTS_EU_Sub_Type__c = 'Use or may use FTAI');
            insert acc;
            
            testAccounts.add(acc);
            ZTS_addrCreationAndUpdateFromAccount.syncOptOutFlagGermany(testAccounts);
        }
    }
    
    static testmethod void testSplitAccountNameonupdate(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Data Admin';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Account acc=new Account(Name='test',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     ZTS_EU_Sub_Type__c = 'Use or may use FTAI');
            insert acc;
            
            Account acc2=new Account(Name='testioqwyeweuiwieweweioweuweuwoeoioeuwasdasdad',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     ZTS_EU_Sub_Type__c = 'Use or may use FTAI');
            insert acc2;
             Account acc3=new Account(Name='testio qwyeweu iwieweweioweuw euwoeoioeuwas dasdadhj hkjhsdkja dhhdjgcyhuufd',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     ZTS_EU_Sub_Type__c = 'Use or may use FTAI');
            insert acc3;
             Account acc4=new Account(Name='testio qwyeweu iwieweweioweuw euwoeoioeuwas dasdadhj hkjhsdkja dhhdjgcy huufdhjgdggdughgsd hgagdgsdhgsdsdhjhdghgsafdg',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     ZTS_EU_Sub_Type__c = 'Use or may use FTAI');
            insert acc4;
            ZTS_addrCreationAndUpdateFromAccount.splitAccountNameonupdate(acc);
            ZTS_addrCreationAndUpdateFromAccount.splitAccountNameonupdate(acc2);
            ZTS_addrCreationAndUpdateFromAccount.splitAccountNameonupdate(acc3);
            ZTS_addrCreationAndUpdateFromAccount.splitAccountNameonupdate(acc4);
            ZTS_addrCreationAndUpdateFromAccount.splitAccountName(acc2);
        }
    }
    
    static testmethod void testIsAddressChanged(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Data Admin';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Account acc=new Account(Name='test',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     ZTS_EU_Sub_Type__c = 'Use or may use FTAI',
                                     BillingCity = 'testCity1');
            insert acc;
            
            Account acc2=new Account(Name='testioqwyeweuiwieweweioweuweuwoeoioeuwasdasdad',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     ZTS_EU_Sub_Type__c = 'Use or may use FTAI',
                                     BillingCity = 'testCity2');
            insert acc2;
            
            ZTS_addrCreationAndUpdateFromAccount.isAddressChanged(acc, acc2);
        }
    }
    
    static testmethod void testUpdateAddressRecord(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Data Admin';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> newAccount = new list<Account>();
            Map<Id, Account> oldAccount = new Map<Id, Account>();
            Account acc=new Account(Name='test',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     ZTS_EU_Sub_Type__c = 'Use or may use FTAI',
                                     BillingCity = 'testCity1',
                                     BillingStreet = 'testStreet1');
            insert acc;
            
            Account acc2=new Account(Name='testioqwyeweuiwieweweioweuweuwoeoioeuwasdasdad',ZTS_EU_Account_Status__c='Pending',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '12345',
                                     ZTS_EU_CA_HQ_Penetration_Rating__c = 'A',
                                     ZTS_EU_Sub_Type__c = 'Use or may use FTAI',
                                     BillingCity = 'testCity2',
                                     BillingStreet = 'testStreet2');
            insert acc2;
            
            State_Country__c sc = new State_Country__c();
            sc.name = 'testName';
            sc.ZTS_EU_Country__c = 'testCountry';
            insert sc;
            
            Address__c testAddress = new Address__c(Zip_Postal_Code__c = '00000',
                                                    ZTS_EU_Street__c = 'testStreet',
                                                    ZTS_Address_Line_1__c = 'testline1',
                                                    ZTS_EU_Address_Line_2__c = 'testline2',
                                                    State_Province__c = 'testState',
                                                    ZTS_EU_Primary__c = true,
                                                    ZTS_EU_Country__c = 'testCountry',
                                                    ZTS_EU_City__c = 'testCity',
                                                    ZTS_EU_Account__c = acc.Id,
                                                    ZTS_EU_State_County__c = sc.id);
            insert testAddress;
            System.debug('address record test :'+[Select a.Zip_Postal_Code__c, a.ZTS_EU_Street__c, a.ZTS_Address_Line_1__c, a.ZTS_EU_Address_Line_2__c, a.State_Province__c, a.ZTS_EU_Primary__c, a.ZTS_EU_Country__c, a.ZTS_EU_City__c, a.ZTS_EU_Account__c From Address__c a]);
            newAccount.add(acc);
            oldAccount.put(acc.Id, acc2);

            ZTS_addrCreationAndUpdateFromAccount.chkUpdate = true;
            ZTS_addrCreationAndUpdateFromAccount.updateAddressRecord(newAccount, oldAccount);
        }
    }
    
    static testmethod void testUpdateAccConAffInactive(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Data Admin';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> newAccount = new list<Account>();
            
            Account acc=new Account(Name='testAccount', 
                                     ZTS_EU_Reason__c='Out of Business',
                                     ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Account_Status__c = 'Inactive',
                                     ZTS_EU_Zip_Postal_Code__c = '12345');
            insert acc;
            
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            Contact contest=new Contact(FirstName='firstname',
                                        LastName='testContact',
                                        ZTS_EU_Rep_Contact_Status__c='Inactive',
                                        ZTS_EU_Reason_for_Inactivation__c='Moved',
                                        ZTS_EU_Contact_Status__c='Inactive',
                                        AccountId = acc.Id,
                                        ZTS_EU_Market__c = 'United Kingdom');
            insert contest;
            //ZTS_EU_Affiliations__c accaff = new ZTS_EU_Affiliations__c(ZTS_EU_Affiliation_Status__c='Inactive', ZTS_EU_Account__c = acc.Id, ZTS_EU_Contact__c = contest.Id, Name ='testAff');
            //insert accaff;
            
            
            newAccount.add(acc);

            ZTS_addrCreationAndUpdateFromAccount.updateAccConAffInactive(newAccount);
            
            List<ZTS_EU_Affiliations__c> accaff = [Select Id, ZTS_EU_Affiliation_Status__c From ZTS_EU_Affiliations__c where ZTS_EU_Account__c =: acc.Id];
            System.assertEquals('Inactive', accaff[0].ZTS_EU_Affiliation_Status__c, 'Failed to change status of affiliation');
        }
    }
    
    @isTest
    private static void updateContactAffilation_ContactInactiveUpdateAffiliationAndAccount() {
        Contact testContact = [
            SELECT Id
            FROM Contact
            WHERE Lastname =: CONTACT_SINGLE_ACCOUNT_RELATION_LASTNAME
            LIMIT 1];

        testContact.ZTS_EU_Contact_Status__c = 'Inactive';

        Test.startTest();
            update testContact;
        Test.stopTest();

        ZTS_EU_Affiliations__c testAffiliation = [
            SELECT Id, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account__c
            FROM ZTS_EU_Affiliations__c
            WHERE ZTS_EU_Contact__c =: testContact.Id
            LIMIT 1];
        
        System.assertEquals('Inactive', testAffiliation.ZTS_EU_Affiliation_Status__c,
            'Affiliation Status was not changed to inactive as expected.');

        Account testAccount = [
            SELECT Id, ZTS_EU_Account_Status__c
            FROM Account
            WHERE Id =: testAffiliation.ZTS_EU_Account__c];

        System.assertEquals('Inactive', testAccount.ZTS_EU_Account_Status__c, 
            'Account Status was not changed to inactive as expected.');
    }

    @isTest
    private static void updateContactAffilation_ContactNonInactiveUpdateNoRecordUpdates() {
        Contact testContact = [
            SELECT Id
            FROM Contact
            WHERE Lastname =: CONTACT_SINGLE_ACCOUNT_RELATION_LASTNAME
            LIMIT 1];

        testContact.ZTS_EU_Contact_Status__c = 'Pending';

        Test.startTest();
            update testContact;
        Test.stopTest();

        ZTS_EU_Affiliations__c testAffiliation = [
            SELECT Id, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account__c
            FROM ZTS_EU_Affiliations__c
            WHERE ZTS_EU_Contact__c =: testContact.Id
            LIMIT 1];
        
        System.assertEquals('Active', testAffiliation.ZTS_EU_Affiliation_Status__c,
            'Affiliation Status was changed unexpectedly.');

        Account testAccount = [
            SELECT Id, ZTS_EU_Account_Status__c
            FROM Account
            WHERE Id =: testAffiliation.ZTS_EU_Account__c];

        System.assertEquals('Active', testAccount.ZTS_EU_Account_Status__c, 
            'Account Status was changed unexpectedly.');
    }

    @isTest
    private static void updateContactAffilation_ContactInactiveUpdateAffiliationOnly() {
        Contact testContact = [
            SELECT Id
            FROM Contact
            WHERE Lastname =: CONTACT_MULTIPLE_ACCOUNT_RELATION_LASTNAME1
            LIMIT 1];

        testContact.ZTS_EU_Contact_Status__c = 'Inactive';

        Test.startTest();
            update testContact;
        Test.stopTest();

        ZTS_EU_Affiliations__c testAffiliation = [
            SELECT Id, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account__c
            FROM ZTS_EU_Affiliations__c
            WHERE ZTS_EU_Contact__c =: testContact.Id
            LIMIT 1];
        
        System.assertEquals('Inactive', testAffiliation.ZTS_EU_Affiliation_Status__c,
            'Affiliation Status was not set to inactive as expected.');

        Account testAccount = [
            SELECT Id, ZTS_EU_Account_Status__c
            FROM Account
            WHERE Id =: testAffiliation.ZTS_EU_Account__c];

        System.assertEquals('Active', testAccount.ZTS_EU_Account_Status__c, 
            'Account Status was changed unexpectedly.');
    }

    @isTest
    private static void updateContactAffilation_ContactInactiveUpdateLastAffiliationToSetAccountInactive() {
        ZTS_EU_Affiliations__c otherAffiliation = [
            SELECT Id
            FROM ZTS_EU_Affiliations__c
            WHERE ZTS_EU_Account__r.Name =: ACCOUNT_MULTIPLE_CONTACT_AFFILIATIONS_NAME
            AND ZTS_EU_Contact__r.LastName =: CONTACT_MULTIPLE_ACCOUNT_RELATION_LASTNAME2
        ];

        otherAffiliation.ZTS_EU_Affiliation_Status__c = 'Inactive';

        // Bypass triggers to save processing time and avoid any issues updating the Contact later.
        DispatchTriggerHandler.bypass('ZTS_EU_AffiliationsTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        update otherAffiliation;
        DispatchTriggerHandler.clearBypass('ZTS_EU_AffiliationsTriggerHandler');
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');

        Contact testContact = [
            SELECT Id
            FROM Contact
            WHERE Lastname =: CONTACT_MULTIPLE_ACCOUNT_RELATION_LASTNAME1
            LIMIT 1];

        testContact.ZTS_EU_Contact_Status__c = 'Inactive';

        Test.startTest();
            update testContact;
        Test.stopTest();

        ZTS_EU_Affiliations__c testAffiliation = [
            SELECT Id, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account__c
            FROM ZTS_EU_Affiliations__c
            WHERE ZTS_EU_Contact__c =: testContact.Id
            LIMIT 1];
        
        System.assertEquals('Inactive', testAffiliation.ZTS_EU_Affiliation_Status__c,
            'Affiliation Status was not set to inactive as expected.');

        Account testAccount = [
            SELECT Id, ZTS_EU_Account_Status__c
            FROM Account
            WHERE Id =: testAffiliation.ZTS_EU_Account__c];

        System.assertEquals('Inactive', testAccount.ZTS_EU_Account_Status__c, 
            'Account Status was not set to inactive as expected.');
    }

    @isTest
    private static void updateContactAffilation_ContactInactiveUpdateMultipleAffiliationsMultipleAccounts() {
        Contact testContact = [
            SELECT Id
            FROM Contact
            WHERE Lastname =: CONTACT_MULTIPLE_ACCOUNT_RELATION_LASTNAME2
            LIMIT 1];

        testContact.ZTS_EU_Contact_Status__c = 'Inactive';

        Test.startTest();
            update testContact;
        Test.stopTest();

        Set<Id> accountIds = new Set<Id>();
        for (ZTS_EU_Affiliations__c testAffiliation :[
            SELECT Id, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account__c
            FROM ZTS_EU_Affiliations__c
            WHERE ZTS_EU_Contact__c =: testContact.Id]) {
            System.assertEquals('Inactive', testAffiliation.ZTS_EU_Affiliation_Status__c,
                'Affiliation Status was not set to inactive as expected.');

            accountIds.add(testAffiliation.ZTS_EU_Account__c);
        }

        for (Account testAccount : [
            SELECT Id, Name, ZTS_EU_Account_Status__c
            FROM Account
            WHERE Id in: accountIds]) {
            // This Account should not have changed as there is another Active Affiliation
            If (testAccount.Name == ACCOUNT_MULTIPLE_CONTACT_AFFILIATIONS_NAME) {
                System.assertEquals('Active', testAccount.ZTS_EU_Account_Status__c, 
                    'Account Status was changed unexpectedly.');
            }
            else {
                // This Account should have changed as there is only one Affiliation
                System.assertEquals('Inactive', testAccount.ZTS_EU_Account_Status__c, 
                    'Account Status was not set to inactive as expected.');
            }
        }
    }

    @isTest
    private static void updateContactAffiliation_MultipleContacts() {
        List<Contact> contacts = new List<Contact>();
        Contact singleAccountContact;
        for (Contact testContact : [
            SELECT Id, LastName,
            (SELECT ID, ZTS_EU_Account__c FROM Accounts_and_Contacts__r)
            FROM Contact
            WHERE LastName in: new List<String> {CONTACT_SINGLE_ACCOUNT_RELATION_LASTNAME,
                CONTACT_MULTIPLE_ACCOUNT_RELATION_LASTNAME1,CONTACT_MULTIPLE_ACCOUNT_RELATION_LASTNAME2}
            ]) {

            // Updates to this Contact should error
            if (testContact.LastName == CONTACT_SINGLE_ACCOUNT_RELATION_LASTNAME) {
                singleAccountContact = testContact;
                // Force an error for the related Account
                ZTS_EU_Affiliation_Update.forceUpdateRepAccountStatusErrorId = testContact.Accounts_and_Contacts__r[0].ZTS_EU_Account__c;
            }

            testContact.ZTS_EU_Contact_Status__c = 'Inactive';

            contacts.add(testContact);
        }

        Test.startTest();
            List<Database.SaveResult> saveResults = Database.update(contacts, false);
        Test.stopTest();

        for (integer i = 0; i < saveResults.size(); i++) {
            Database.SaveResult saveResult = saveResults[i];

            if (contacts[i].Id == singleAccountContact.Id) {
                System.assert(!saveResult.isSuccess(), 'Single Account Contact updated successfully unexpectedly');
            }
            else {
                System.assert(saveResult.isSuccess(), String.format('Failed to update Contact unexpectedly {0}',
                    new List<Object> {saveResult.getErrors()}));
            }
        }

        // Due to the Contact Trigger not allowing recursion, the succesful update of Contacts does not run any triggers.
        // No additional assertions are made as no Affiliations or Contacts are updated.
    }
}