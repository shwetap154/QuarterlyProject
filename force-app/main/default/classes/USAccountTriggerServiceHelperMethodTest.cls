/**
 * @description       : Class written to test USStatusAndFieldUpdates
 * @author            : David Stern @ Slalom
 * @group             : 
 * @last modified on  : 07-25-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   09-16-2020   David Stern @ Slalom        Created the Class. Added the initial test functions.
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc   Add class header
 * 1.2   07-25-2022   Ethan Hirsch @ Zoetis Inc   Reduce NUM_ACCOUNTS to 7 from 35 due to CPU Timeouts
 **/
@isTest
public class USAccountTriggerServiceHelperMethodTest 
{

    static final Integer NUM_ACCOUNTS = 7;
    static final Integer NUM_CONTACTS = NUM_ACCOUNTS;
    static final Integer NUM_TERRITORIES = NUM_ACCOUNTS;

    static final String US_USER_FN = 'USUser';

    @testSetup
    public static void testSetup()
    {        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = US_USER_FN;
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            String mzrTier = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('MZR_Tier__c').getDescribe().getPicklistValues()[0].getLabel();
            List<Account> testAccounts = ZTS_DataUtilityTest.createAccountRecord(NUM_ACCOUNTS);
            for(Account testAccount : testAccounts) {
                testAccount.ZTS_EU_Market__c = 'United States';
                testAccount.ZTS_EU_Account_Status__c = 'Active';
                testAccount.LE_Program_Owner__c = US_USER_FN;
                testAccount.MZR_Program_Owner__c = US_USER_FN;
                testAccount.VGP_Program_Owner__c = US_USER_FN;
                testAccount.MZR_Account__c = true;
                testAccount.ZFS_Status__c = null;
                testAccount.MZR_Tier__c = mzrTier;
            }
            insert testAccounts;
            
            List<Contact> testContacts = ZTS_DataUtilityTest.createContactRecord(NUM_CONTACTS);
            for(Integer i=0; i<NUM_CONTACTS; i++) {
                testContacts[i].ZTS_EU_Market__c = 'United States';
                testContacts[i].AccountId = testAccounts[i].Id;
                testContacts[i].MZR_Contact__c = 'test';
                testContacts[i].ZTS_EU_Contact_Status__c = 'Active';
            }
            
            List<ZTS_EU_Territory__c> testTerritories = ZTS_DataUtilityTest.createCustomTerritory(NUM_TERRITORIES); 
            for(Integer i=0; i<NUM_TERRITORIES; i++) {
                testTerritories[i].Name = '8181-0'+i;
            }

            List<SObject> contactsNTerritories = new List<SObject>();
            contactsNTerritories.addAll(testContacts);
            contactsNTerritories.addAll(testTerritories);
            insert contactsNTerritories;
         
            List<ZTS_AccountTerritory__c> testAccountTerritories = ZTS_DataUtilityTest.createAccountTerritory(testAccounts, testTerritories);
            insert testAccountTerritories;
            
            List<ZTS_EU_Account_Position__c> testAccountPositions = new List<ZTS_EU_Account_Position__c>();
            for(Integer i=0; i<NUM_ACCOUNTS; i++) {
                ZTS_EU_Account_Position__c testAccountPosition = new ZTS_EU_Account_Position__c(
                    ZTS_EU_Account__c = testAccounts[i].Id, 
                    ZTS_AccountTerritory__c = testAccountTerritories[i].Id,
                    MZR_Program_Owner__c = 'test'
                );
                testAccountPositions.add(testAccountPosition);
            }
            insert testAccountPositions;
        }        
    }

    @isTest
    public static void testUSStatusAndFieldUpdates()
    {
        User usr = [
            SELECT Id
            FROM User
            WHERE FirstName = :US_USER_FN
        ];
        System.runAs(usr)
        {
            // for asserts, query for contact, position, and acct.
        	List<Account> testAccounts = [
                SELECT Id, LE_Program_Owner__c, MZR_Program_Owner__c, VGP_Program_Owner__c, MZR_Account__c,
                	   MZR_Status__c, MZR_PARAs_Account__c, ZTS_US_MVP_Account__c, ZFS_Status__c
                FROM Account
                WHERE LE_Program_Owner__c = :US_USER_FN
            ];
            
            for(Integer i=0; i<NUM_ACCOUNTS/2; i++) {
                testAccounts[i].ZTS_US_MVP_Account__c = true;
                testAccounts[i].MZR_PARAs_Account__c = true;
                testAccounts[i].ZFS_Status__c = 'Member';
                testAccounts[i].MZR_Status__c = 'Eligible';
                testAccounts[i].LE_Program_Owner__c = 'newUSUser';
                testAccounts[i].MZR_Program_Owner__c = 'newUSUser';
                testAccounts[i].VGP_Program_Owner__c = 'newUSUser';
                testAccounts[i].MZR_Account__c = false;
            }
            
            Test.startTest();
            	update testAccounts;
            Test.stopTest();
            
            List<Account> updatedAccounts = [
                SELECT Id, Previous_LE_Program_Owner__c, Previous_MZR_Program_Owner__c, Previous_VGP_Program_Owner__c, 
                	   MZR_Derm_Rebate__c, MZR_Tier__c
                FROM Account
                WHERE LE_Program_Owner__c = 'newUSUser'
            ];
            
            List<Contact> updatedContacts = [
                SELECT Id, MZR_Contact__c
                FROM Contact
                WHERE AccountId IN :updatedAccounts
            ];
            
            List<ZTS_EU_Account_Position__c> updatedAccountPositions = [
                SELECT Id, MZR_Program_Owner__c
                FROM ZTS_EU_Account_Position__c
                WHERE ZTS_EU_Account__c IN :updatedAccounts
            ];
            
            System.assertEquals(NUM_ACCOUNTS/2, updatedAccounts.size(), 'Half of the accounts should be returned');
            for(Account updatedAccount : updatedAccounts) {
                System.assertEquals(US_USER_FN, updatedAccount.Previous_LE_Program_Owner__c);
                System.assertEquals(US_USER_FN, updatedAccount.Previous_MZR_Program_Owner__c);
                System.assertEquals(US_USER_FN, updatedAccount.Previous_VGP_Program_Owner__c);
                System.assertEquals(true, updatedAccount.MZR_Derm_Rebate__c, 'MZR Derm Rebate should now be set to true');
                System.assertEquals(null, updatedAccount.MZR_Tier__c, 'MZR tier should be blank');
            }
            
            System.assertEquals(NUM_CONTACTS/2, updatedContacts.size(), 'Half of the contacts should be returned');
            for(Contact updatedContact : updatedContacts) {
                System.assertEquals(null, updatedContact.MZR_Contact__c, 'MZR contact should now be blank');
            }
            
            System.assertEquals(NUM_ACCOUNTS/2, updatedAccountPositions.size(), 'Half of the account positions should be returned');
            for(ZTS_EU_Account_Position__c updatedAccountPosition : updatedAccountPositions) {
                System.assertEquals(null, updatedAccountPosition.MZR_Program_Owner__c, 'MZR Program Owner should now be blank');
            }
        }
    }
}