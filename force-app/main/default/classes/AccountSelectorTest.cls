/**
 * @description       : Test class for AccountSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 05-14-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-07-2022   Ethan Hirsch @ Zoetis Inc   Initial Version
 * 1.1   04-14-2022   Ethan Hirsch @ Zoetis Inc   Remove constructor
 * 1.2   05-03-2022   Ethan Hirsch @ Zoetis Inc   Add test for selectAccountWithReferenceLabFields
 * 1.3   05-03-2022   Padma Nerella @ Zoetis Inc  Add test for selectInternationalAccountByIdWithContact
 * 1.4   05-09-2023   Padma Nerella @ Zoetis Inc  Add test for selectInternationalParentAccountsById
 * 1.5   05-10-2023   Padma Nerella @ Zoetis Inc  Add test for retrieveInternationalParentAccountsByIdQuery
 * 1.6   05-16-2023   Padma Nerella @ Zoetis Inc  Add test for selectAccountsWithDiagnosticAPs
 * 1.7   05-18-2023   Padma Nerella @ Zoetis Inc  Add test for SelectINTLParentAccs
**/
@isTest
private class AccountSelectorTest {
    private static final Integer maxAccountsPerMarket = 5;
    @TestSetup
    static void setup(){

        Id sysAdminProfId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        List<Account> accounts = ZTS_DataUtilityTest.createAccountRecord(maxAccountsPerMarket * 2);

        for (Integer i = 0; i < maxAccountsPerMarket * 2; i++) {
            if (i < maxAccountsPerMarket) {
                accounts[i].ZTS_EU_Market__c = 'United States';
            }
            else {
                accounts[i].ZTS_EU_Market__c = 'United Kingodm';
            }
        }
        insert accounts;
        List<Account> parentaccList = ZTS_DataUtilityTest.createAccountRecord(1);
        parentaccList[0].ZTS_EU_Market__c = 'United Kingdom';
        parentaccList[0].Name='ParentAccTest1';
        insert parentaccList;
        List<Account> insertTestaccList = new List<Account>();
        List<Account> testaccList = ZTS_DataUtilityTest.createAccountRecord(3);
        testaccList[0].ZTS_EU_Market__c = 'United Kingdom';
        testaccList[0].ZTS_EU_Account_Status__c='Active';
        testaccList[0].ZTS_EU_Parent_Id__c=parentaccList[0].Id;
        testaccList[1].ZTS_EU_Market__c = 'Canada';
        testaccList[1].ZTS_EU_Account_Status__c='Active';
        testaccList[1].ZTS_EU_Parent_Id__c=parentaccList[0].Id;
        testaccList[2].ZTS_EU_Market__c = 'United States';
        testaccList[2].ZTS_EU_Account_Status__c='Active';
        insertTestaccList.addall(testaccList);

        List<Account> diagnosticsAccount = ZTS_DataUtilityTest.createAccountRecord(3);
        diagnosticsAccount[0].Name='DiagnosticAccount1';
        diagnosticsAccount[1].Name='DiagnosticAccount2';
        diagnosticsAccount[2].Name='DiagnosticAccount3';
        insertTestaccList.addAll(diagnosticsAccount);
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        Insert insertTestaccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

        List<Contact> insertConList = new List<Contact>();
        List<Contact> conList = ZTS_DataUtilityTest.createContactRecord(3);
        conList[0].AccountId = testaccList[0].Id;
        conList[0].ZTS_EU_Contact_type__c = 'Farmer';
        conList[0].ZTS_EU_Contact_Status__c ='Active';
        conList[0].Certification_Status__c = true;
        conList[0].Email = 'test@Zoetis.com';
        conList[1].AccountId = testaccList[1].Id;
        conList[1].ZTS_EU_Contact_type__c = 'Veterinarian';
        conList[1].ZTS_EU_Contact_Status__c ='Active';
        conList[1].Email = 'test12@Zoetis.com';
        conList[1].Certification_Status__c = true;
        conList[2].AccountId = testaccList[2].Id;
        conList[2].ZTS_EU_Contact_type__c = 'Veterinarian';
        conList[2].ZTS_EU_Contact_Status__c ='Active';
        conList[2].Email = 'test12@Zoetis.com';
        conList[2].Certification_Status__c = true;
        insert conList;

        List<ZTS_EU_Territory__c> territories = new List<ZTS_EU_Territory__c>();
        ZTS_EU_Territory__c dscTerritory = TestDataFactory.createZTSTerritory(
            'United States',
            null,
            FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS,
            'Territory',
            false
        );

        territories.add(dscTerritory);

        ZTS_EU_Territory__c dtsTerritory = TestDataFactory.createZTSTerritory(
            'United States',
            null,
            FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS_TECH,
            'Territory',
            false
        );

        territories.add(dtsTerritory);
        ZTS_EU_Territory__c rdtsTerritory = TestDataFactory.createZTSTerritory(
            'United States',
            null,
            FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS_REGIONAL_TECH,
            'Territory',
            false
        );

        territories.add(rdtsTerritory);

        ZTS_EU_Territory__c insideSalesDXTerritory = TestDataFactory.createZTSTerritory(
            'United States',
            null,
            FieldForceSettingsService.FIELD_FORCE_INSIDE_SALES_DIAGNOSTICS,
            'Territory',
            false
        );

        territories.add(insideSalesDXTerritory);
        DispatchTriggerHandler.bypass('ZTS_EU_TerritoryTriggerHandler');
        insert territories;
        DispatchTriggerHandler.clearBypass('ZTS_EU_TerritoryTriggerHandler');

        List<User> usersToInsert = new List<User>();
        for(ZTS_EU_Territory__c territory : territories){
            User alignedUser = TestDataFactory.createUser(sysAdminProfId, false);
            if(territory.ZTS_Field_Force_Name__c == FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS){
                alignedUser.FirstName = 'DSC UserFirst';
                alignedUser.LastName = 'DSC UserLast';
            }else if(territory.ZTS_Field_Force_Name__c == FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS_TECH){
                alignedUser.FirstName = 'DTS UserFirst';
                alignedUser.LastName = 'DTS UserLast';
            }else if(territory.ZTS_Field_Force_Name__c == FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS_REGIONAL_TECH){
                alignedUser.FirstName = 'Regional UserFirst';
                alignedUser.LastName = 'Regional UserLast';
            }else if(territory.ZTS_Field_Force_Name__c == FieldForceSettingsService.FIELD_FORCE_INSIDE_SALES_DIAGNOSTICS){
                alignedUser.FirstName = 'ISDX UserFirst';
                alignedUser.LastName = 'ISDX UserLast';
            }
            usersToInsert.add(alignedUser);
        }
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        insert usersToInsert;
        DispatchTriggerHandler.clearBypass('UserTriggerHandler');


        List<ZTS_EU_Position__c> positions = new List<ZTS_EU_Position__c>();
        for(User usr : usersToInsert){
            if(usr.FirstName.containsIgnoreCase('DSC')){
                positions.add(CPQ_TestDataFactory.createZoetisPosition(usr, dscTerritory, false));
            }else if(usr.FirstName.containsIgnoreCase('DTS')){
                positions.add(CPQ_TestDataFactory.createZoetisPosition(usr, dtsTerritory, false));
            }else if(usr.FirstName.containsIgnoreCase('ISDX')){
                positions.add(CPQ_TestDataFactory.createZoetisPosition(usr, insideSalesDXTerritory, false));
            }else if(usr.FirstName.containsIgnoreCase('Regional')){
                positions.add(CPQ_TestDataFactory.createZoetisPosition(usr, rdtsTerritory, false));
            }
        }
        DispatchTriggerHandler.bypass('ZTS_EU_PositionTriggerHandler');
        insert positions;
        DispatchTriggerHandler.clearBypass('ZTS_EU_PositionTriggerHandler');

        List<ZTS_AccountTerritory__c> acctTerritories = new List<ZTS_AccountTerritory__c>();
        for(Account acc : diagnosticsAccount){
            for(ZTS_EU_Territory__c territory : territories){
                acctTerritories.add(TestDataFactory.createAccountTerritory(acc,territory,true,false));
            }
        }
        DispatchTriggerHandler.bypass('ZTS_AccountTerritoryTriggerHandler');
        insert acctTerritories;
        DispatchTriggerHandler.clearBypass('ZTS_AccountTerritoryTriggerHandler');
    }

    @isTest
    private static void getRecordListById_US_Test() {
        Test.startTest();
            List<Account> accounts = AccountSelector.newInstance().selectByIdAndMarket(
                retrieveAllAccountIds(), true);
        Test.stopTest();

        system.assertEquals(9, accounts.size(), 'More/Less US Accounts than expected were returned');
    }

    @isTest
    private static void getRecordListById_INTL_Test() {
        Test.startTest();
            List<Account> accounts = AccountSelector.newInstance().selectByIdAndMarket(
                retrieveAllAccountIds(), false);
        Test.stopTest();

        system.assertEquals(8, accounts.size(), 'More/Less INTL Accounts than expected were returned');
    }

    @isTest
    private static void selectAccountWithReferenceLabFields_Test() {
        Set<Id> accountIds = new Map<Id, Account>([
            SELECT Id
            FROM Account
            LIMIT : maxAccountsPerMarket
        ]).keySet();
        
        Test.startTest();
        List<Account> accounts = AccountSelector.newInstance().selectAccountWithReferenceLabFields(accountIds);
        Test.stopTest();
        
        system.assertEquals(maxAccountsPerMarket, accounts.size(), 'Each Account Id should return one Account');
    }
    
    private static List<Id> retrieveAllAccountIds() {
        return new List<Id>(
            new Map<Id, Account>([SELECT ID FROM ACCOUNT]).keySet()
        );
    }
    
    @isTest
    private static void selectAccountToUpdateCertificationStatus() {
        
        List<Contact> contactList = [Select Id,Email,ZTS_EU_Contact_type__c,Account.Certification_Status__c,Certification_Status__c,AccountId from Contact where (ZTS_EU_Contact_type__c ='Farmer' OR ZTS_EU_Contact_type__c ='Veterinarian')];
        Set<Id> accIdSet =  new Set<Id>();
        for(Contact con:contactList){
            accIdSet.add(con.AccountId);
        }
        Test.startTest();
        AccountSelector.newInstance().selectInternationalAccountByIdWithContacts(accIdSet);
        Test.stopTest();
        List<Account> getAccountsToUpdate = [Select Id,Certification_Status__c from Account where Certification_Status__c=true];
        System.assertEquals(2, getAccountsToUpdate.size(),'2 accounts selcted to update certification status');
    }
    
    @isTest
    private static void selectUnitedStatesAccountToUpdateCertificationStatus() {
        List<Contact> contactList = [Select Id,Email,ZTS_EU_Contact_type__c,Account.Certification_Status__c,Certification_Status__c,AccountId,Account.ZTS_EU_Market__c from Contact];
        Set<Id> accIdSet =  new Set<Id>();
        for(Contact con:contactList){
            if(con.Account.ZTS_EU_Market__c =='United States'){
                accIdSet.add(con.AccountId);
            }
        }
        Test.startTest();
        List<Account> getAccountsToUpdate = AccountSelector.newInstance().selectInternationalAccountByIdWithContacts(accIdSet);
        Test.stopTest();
        System.assertEquals(0, getAccountsToUpdate.size(),'Account will be retrieved only when market is International market');
    }

    @isTest
    private static void selectInternationalParentAccountsByIdTest(){
        Set<Id> parentAccIds = new Set<Id>();
        List<Account> parentAccList = [Select Id,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c,ZTS_EU_Market__c from Account where ZTS_EU_Market__c !='United States'];
        
        for(Account acc :parentAccList){
            if(acc.ZTS_EU_Parent_Id__c!=null){
                parentAccIds.add(acc.ZTS_EU_Parent_Id__c);
            }
        }
        Test.startTest();
        List<Account> accList1 = AccountSelector.newInstance().selectInternationalParentAccountsById(parentAccIds,5);
        Test.stopTest();
        
        System.assertEquals(5, accList1.size(),'5 Accounts are retrieved to update the corporate flag');
    }
    
    @isTest
    private static void retrieveInternationalParentAccountsByIdQueryTest(){
        Set<Id> parentAccIds = new Set<Id>();
        List<Account> parentAccList = [Select Id,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c,ZTS_EU_Market__c from Account where ZTS_EU_Market__c !='United States'];
        for(Account acc :parentAccList){
            if(acc.ZTS_EU_Parent_Id__c!=null){
                parentAccIds.add(acc.ZTS_EU_Parent_Id__c);
            }
        }
        Test.startTest();
        String retrievedParentAccListQuery = AccountSelector.newInstance().retrieveInternationalParentAccountsByIdQuery(parentAccIds);
        Test.stopTest();
        System.assert(String.isNotBlank(retrievedParentAccListQuery), 'retrieveInternationalParentAccountsByIdQuery is not empty');
    }

    @isTest
    private static void selectAccountsWithDiagnosticAPsTest(){
        List<String> accNames = new List<String>{'DiagnosticAccount1','DiagnosticAccount2','DiagnosticAccount3'};
        List<Account> accList =[Select Id, Name,ZTS_EU_Market__c From Account where Name IN:accNames];
        Set<Id> accountIdSet = new Set<Id>();
        for(Account acc : accList){
            accountIdSet.add(acc.Id);
        }
        Test.startTest();
        List<Account> diagnosticAccList = AccountSelector.newInstance().selectAccountsWithDiagnosticAPs( accountIdSet);
        Test.stopTest();

        System.assertEquals(3, diagnosticAccList.size(), '3 diagnostic accounts are retrived');

    }
    
    @isTest
    private static void SelectINTLparentAccsTest(){
        Set<Id> parentAccIds = new Set<Id>();
        List<Account> parentAccList = [Select Id,ZTS_EU_Parent_Id__c,ZTS_EU_Corporate_Flag__c,ZTS_EU_Market__c from Account where ZTS_EU_Market__c!='United States'];
        for(Account acc :parentAccList){
            if(acc.ZTS_EU_Parent_Id__c!=null){
                parentAccIds.add(acc.ZTS_EU_Parent_Id__c);
            }
        }
        Test.startTest();
        List<Account> returnParentAccList = AccountSelector.newInstance().SelectINTLParentAccs(parentAccIds);
        Test.stopTest();
        System.assertEquals(6, returnParentAccList.size(), '6 Parent accounts retrieved');
    }
    
}