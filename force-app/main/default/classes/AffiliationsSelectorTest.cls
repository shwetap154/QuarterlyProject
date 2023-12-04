/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-18-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   4-17-2023    Padma Nerella @ Zoetis Inc  Add selectInternationalAffiliationsByAccountTest,selectUnitedStatesAffiliationsById,selectInternationalAffiliationsById
**/
@isTest
private class AffiliationsSelectorTest {
    
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
    
    @isTest
    private static void selectInternationalAffiliationsByAccountTest(){
        List<Account> newAccList = new List<Account>();
        List<ZTS_EU_Affiliations__c> affList = [select ZTS_EU_Account__r.id,ZTS_EU_Affiliation_Status__c, Name from ZTS_EU_Affiliations__c];
        for(ZTS_EU_Affiliations__c aff:affList){
            newAccList.add(aff.ZTS_EU_Account__r);
        }
        Test.startTest();
        List<ZTS_EU_Affiliations__c> affListToUpdate = AffiliationsSelector.selectInternationalAffiliationsByAccount(newAccList);
        Test.stopTest();
        System.assertEquals(4,affListToUpdate.size(), '4 affiliation record retruned to update');
    }
    
    @isTest
    private static void selectInternationalAffiliationsById(){
        List<ZTS_EU_Affiliations__c> newAffList = new List<ZTS_EU_Affiliations__c>();
        List<ZTS_EU_Affiliations__c> aff1List = [select ZTS_EU_Account__r.id,ZTS_EU_Affiliation_Status__c, Name from ZTS_EU_Affiliations__c];
        for(ZTS_EU_Affiliations__c aff:aff1List){
            newAffList.add(aff);
        }
        Test.startTest();
        List<ZTS_EU_Affiliations__c> internationalAffList1 = AffiliationsSelector.selectInternationalAffiliationsById(newAffList);
        Test.stopTest();
        System.assertEquals(4,internationalAffList1.size(),'4 affiliation record retrieved');
        
    }
    @isTest
    private static void selectUnitedStatesAffiliationsById(){
        List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(2);
        for (Account account : accounts) {
            account.ZTS_EU_Market__c = 'United States';
            account.ZTS_EU_Account_Status__c = 'Active';
        }
        
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert accounts;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        List<Contact> contacts = ZTS_DataUtilityTest.createContactRecord(2);
        for (Contact contact : contacts) {
            contact.ZTS_EU_Contact_Status__c = 'Active';
            contact.ZTS_EU_Market__c = 'United States';
        }
        
        insert contacts;
        
        List<ZTS_EU_Affiliations__c> affiliationList = [Select id, Name, ZTS_EU_Contact__c,ZTS_EU_Account__c,ZTS_EU_Account__r.ZTS_EU_Account_Status__c,ZTS_EU_Contact__r.ZTS_EU_Contact_Status__c, ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c where ZTS_EU_Account__r.Id =:accounts];
        Test.startTest();
        List<ZTS_EU_Affiliations__c> usAffList1 = AffiliationsSelector.selectInternationalAffiliationsById(affiliationList);
        Test.stopTest();
        
        System.assertEquals(0,usAffList1.size(),'0 affiliation record retrieved');
    }
}