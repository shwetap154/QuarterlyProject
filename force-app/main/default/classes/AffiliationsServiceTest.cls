/**
 * @description       :
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             :
 * @last modified on  : 04-18-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Ver   Date         Author                      Modification
 * 1.0   04-11-2023   Padma Nerella @ Zoetis Inc  Added updateAccountContactAffilationStatusInactiveTest and updateAccountContactAffilationNameFromAccTest methods and noUpdatesAccConAffStatusFromBadAddressOnAccTest
**/
@isTest
private class AffiliationsServiceTest {
    
    @TestSetup
    private static void setup(){
        
        String CONTACT_SINGLE_ACCOUNT_RELATION_LASTNAME = 'SingleContact';
        String CONTACT_MULTIPLE_ACCOUNT_RELATION_LASTNAME1 = 'MultipleContact1';
        String CONTACT_MULTIPLE_ACCOUNT_RELATION_LASTNAME2 = 'MultipleContact2';
        String ACCOUNT_MULTIPLE_CONTACT_AFFILIATIONS_NAME = 'MultiRelationAccount';
        
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
            
            List<Account> usAccounts = ZTS_DataUtilityTest.createAccountRecord(1);
            usAccounts[0].ZTS_EU_Market__c = 'United States';
            usAccounts[0].ZTS_EU_Account_Status__c = 'Active';
            
            insert usAccounts;
            
            List<Contact> usContacts = ZTS_DataUtilityTest.createContactRecord(1);
            usContacts[0].ZTS_EU_Contact_Status__c = 'Active';
            usContacts[0].ZTS_EU_Market__c = 'United States';
            
            usContacts[0].LastName = 'US Contact - Affliation Test';
            usContacts[0].AccountId = usAccounts[0].Id;
            
            insert usContacts;
            
            List<ZTS_EU_Affiliations__c> usAffiliations = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
            usAffiliations[0].ZTS_EU_Affiliation_Status__c = 'Active';
            usAffiliations[0].ZTS_EU_Account__c = usAccounts[0].Id;
            usAffiliations[0].ZTS_EU_Contact__c = usContacts[0].Id;
            usAffiliations[0].ZTS_US_Profession__c = 'Academia';
            usAffiliations[0].ZTS_US_Job_Function__c= 'Administration';
            
            insert usAffiliations;
            
            // Clear Bypasses for regular tests
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
            DispatchTriggerHandler.clearBypass('ZTS_EU_AffiliationsTriggerHandler');
        }
    }
    
    @isTest
    private static void updateAccountContactAffilationStatusInactiveTest(){
        
        List<Account> accTriggeroldList = [Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where ZTS_EU_Market__c!='United States'];
        List<Account> accTriggerNewList = new List<Account>();
        Map<id,Account> accTriggeroldMap = new map<Id,Account>([Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where Id IN:accTriggeroldList]);
        
        for(Account acc:accTriggeroldList){
            acc.ZTS_EU_Account_Status__c = 'Inactive';
            accTriggerNewList.add(acc);
        }
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update accTriggerNewList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        Map<id,Account> accTriggerNewMap = new Map<Id, Account>([Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where Id IN:accTriggerNewList]);
        
        Test.startTest();
        AffiliationsService.updateAccountContactAffilation(accTriggerNewList,accTriggeroldList,accTriggerNewMap,accTriggeroldMap);
        Test.stopTest();
        
        List<ZTS_EU_Affiliations__c> updatedAffiliationList = [Select id, Name, ZTS_EU_Contact__c,ZTS_EU_Account__c, ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c where ZTS_EU_Affiliation_Status__c ='Inactive' AND ZTS_EU_Account__r.Id =:accTriggerNewList];
        
        List<Contact> conList = [Select Id,ZTS_EU_Contact_Status__c from Contact where ZTS_EU_Contact_Status__c ='Inactive'];
        
        System.assertEquals(4, updatedAffiliationList.size(), '4 affiliation records updated affilation status to Inactive');
        System.assertEquals(3, conList.size(), 'updateAccConAffilition method kicks of contactservice class to update contact status to Inactive');
    }
    
    @isTest
    private static void updateAccountContactAffilationNameFromAccTest(){
        List<Account> accTriggeroldList = [Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where ZTS_EU_Market__c!='United States'];
        List<Account> accTriggerNewList = new List<Account>();
        Map<id,Account> accTriggeroldMap = new map<Id,Account>([Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where Id IN:accTriggeroldList]);
        
        for(Account acc:accTriggeroldList){
            acc.Name = 'NameChanged';
            accTriggerNewList.add(acc);
        }
        
        Map<id,Account> accTriggerNewMap = new Map<Id, Account>([Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where Id IN:accTriggerNewList]);
        accTriggerNewMap.putAll(accTriggerNewList);
        
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update accTriggerNewMap.values();
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        Test.startTest();
        AffiliationsService.updateAccountContactAffilation(accTriggerNewList,accTriggeroldList,accTriggerNewMap,accTriggeroldMap);
        Test.stopTest();
        
        List<ZTS_EU_Affiliations__c> updatedAffiliationList1 = [Select id, Name, ZTS_EU_Contact__c,ZTS_EU_Account__c,ZTS_EU_Account__r.Name,ZTS_EU_Contact__r.LastName, ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c where Name Like'%@ NameChanged'];
        System.assertEquals(4,updatedAffiliationList1.size(), '4 affiliation records name updated');
    }
    
    @isTest
    private static void noUpdatesAccConAffStatusFromBadAddressOnAccTest(){
        List<Account> accTriggeroldList = [Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where ZTS_EU_Market__c!='United States'];
        List<Account> accTriggerNewList = new List<Account>();
        Map<id,Account> accTriggeroldMap = new map<Id,Account>([Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where Id IN:accTriggeroldList]);
        
        for(Account acc:accTriggeroldList){
            acc.ZTS_EU_Account_Status__c = 'Bad_Address';
            accTriggerNewList.add(acc);
        }
        Map<id,Account> accTriggerNewMap = new Map<Id, Account>([Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where Id IN:accTriggerNewList]);
        
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update accTriggerNewList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        Test.startTest();
        AffiliationsService.updateAccountContactAffilation(accTriggerNewList,accTriggeroldList,accTriggerNewMap,accTriggeroldMap);
        Test.stopTest();
        
        List<ZTS_EU_Affiliations__c> updatedAffiliationList1 = [Select id, Name, ZTS_EU_Contact__c,ZTS_EU_Account__c,ZTS_EU_Account__r.Name,ZTS_EU_Contact__r.LastName, ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c where ZTS_EU_Account__r.Id =:accTriggerNewList AND ZTS_EU_Affiliation_Status__c ='Active'];
        
        System.assertEquals(4, updatedAffiliationList1.size(), '4 affiliation records did not update when Account status updated to Bad-Address');
    }
    
    @isTest
    private static void affiliationNameUpdateTest(){
        List<Account> accTriggeroldList = [Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where ZTS_EU_Market__c = 'United States'];
        List<Account> accTriggerNewList = new List<Account>();
        Map<id,Account> accTriggeroldMap = new map<Id,Account>([Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where Id IN:accTriggeroldList]);
        
        for(Account acc:accTriggeroldList){
            acc.Name = 'updatedName';
            accTriggerNewList.add(acc);
        }
        
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        update accTriggerNewList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        Test.startTest();
        AffiliationsService.updateAffliliationName(accTriggerNewList);
        Test.stopTest();
        
        List<ZTS_EU_Affiliations__c> updatedAffiliationList1 = [Select id, Name from ZTS_EU_Affiliations__c where ZTS_EU_Account__r.Id =:accTriggerNewList];
        
        System.assert(updatedAffiliationList1[0].Name.contains(accTriggerNewList[0].Name), 'Affiliation name is updated');
    }
    
    @isTest
    private static void affiliationNameUpdateOnMergeTest(){
        ZTS_EU_Affiliations__c usAffiliation = [Select Id, Name, ZTS_EU_Account__c from ZTS_EU_Affiliations__c where ZTS_EU_Market_from_Parent__c = 'United States'];
        Account childAccount = [Select Id, Name From Account Where Id =: usAffiliation.ZTS_EU_Account__c limit 1];
        
        List<Account> gainingAccounts = ZTS_DataUtilityTest.createAccountRecord(1);
        gainingAccounts[0].ZTS_EU_Market__c = 'United States';
        gainingAccounts[0].ZTS_EU_Account_Status__c = 'Active';
        
        insert gainingAccounts;
        Test.startTest();
        merge gainingAccounts[0] childAccount;
        Test.stopTest();
        
        List<ZTS_EU_Affiliations__c> updatedAffiliationList1 = [Select id, Name from ZTS_EU_Affiliations__c where Id =:usAffiliation.Id];
        System.assert(updatedAffiliationList1[0].Name.contains(gainingAccounts[0].name), 'Merged account\'s affiliation name is updated');
    }
    
    @isTest
    private static void affiliationNameBulkUpdate(){
        List<Account> accTriggeroldList = [Select Id,ZTS_EU_Market__c,ZTS_EU_Account_Status__c,Name from Account where ZTS_EU_Market__c = 'United States'];
        List<ZTS_EU_Affiliations__c> previousAffiliationList = [Select Id From ZTS_EU_Affiliations__c Where ZTS_EU_Account__c =: accTriggeroldList[0].Id];
        User testUser = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        System.runAs(testUser){
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            DispatchTriggerHandler.bypass('ContactTriggerHandler');
            DispatchTriggerHandler.bypass('ZTS_EU_AffiliationsTriggerHandler');
            DispatchTriggerHandler.bypass('RingLeadTrigger');
            
            List<Contact> conList = new List<Contact>();
            for(Integer i =0; i< 25; i++){
                Contact con = new Contact();
                con.ZTS_EU_Contact_Status__c = 'Active';
                con.LastName = 'US Contact - Affliation Test_'+ i;
                con.AccountId = accTriggeroldList[0].Id;
                con.ZTS_US_Profession__c = 'Account Contact';
                con.ZTS_US_Job_Function__c = 'Account Contact';
                conList.add(con);                           
            }
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            Database.SaveResult[] srList = Database.insert(conList,dml);
            
            List<ZTS_EU_Affiliations__c> affliationList = new List<ZTS_EU_Affiliations__c>();
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){
                    ZTS_EU_Affiliations__c affiliation= new ZTS_EU_Affiliations__c();
                    affiliation.ZTS_EU_Affiliation_Status__c = 'Active';
                    affiliation.ZTS_EU_Account__c = accTriggeroldList[0].Id;
                    affiliation.ZTS_EU_Contact__c = sr.getId();
                    affiliation.ZTS_US_Profession__c = 'Academia';
                    affiliation.ZTS_US_Job_Function__c= 'Administration';
                    affliationList.add(affiliation);
                }
            }
            insert affliationList;
            
            accTriggeroldList[0].Name = 'UpdatedName';
            update accTriggeroldList;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
            DispatchTriggerHandler.clearBypass('ZTS_EU_AffiliationsTriggerHandler');
            DispatchTriggerHandler.clearBypass('RingLeadTrigger');
        }
        Test.startTest();
        AffiliationsService.updateAffliliationName(accTriggeroldList);
        Test.stopTest();
        
        List<ZTS_EU_Affiliations__c> updatedAffiliationList1 = [Select id, Name from ZTS_EU_Affiliations__c where Name like '%UpdatedName%'];
        
        System.assertEquals(updatedAffiliationList1.Size(), previousAffiliationList.size() + 25, 'Affiliations name was not updated as much as expected.');
    }
}