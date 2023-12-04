/**
 * @description       : Unit Test class for DiagnosticCaseService
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 05-20-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   04-23-2022   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   04-29-2022   Ethan Hirsch @ Zoetis Inc      Change Primary_Lab_Location__c to be set to a random active value
 * 1.2   05-20-2022   Ethan Hirsch @ Zoetis Inc      Add Unit Tests for setReferenceLabFieldsByAccount method
 *       08/04/2022   Padma Nerella @zoetis Inc      Accessing Custom metedate FieldForceSetting Stores Metadata related to Zoetis Field Force, including Name, and any other Field Force Specific Settings TPBuild-53 
**/
@isTest
private class DiagnosticCaseServiceTest {
    private static final Integer MAX_ACCOUNTS = 2;
    private static final String setDiagnosticFieldsAccount1Name = 'setDiagnosticFieldsAccount1';
    private static final String setDiagnosticFieldsAccount2Name = 'setDiagnosticFieldsAccount2';
    @TestSetup
    static void makeData(){

        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('AddressTriggerHandler');

        TriggerActivation__c tr = new TriggerActivation__c(Name = 'ZTS_EU_ServiceRequest',ZTS_EU_Bypass__c = true);
        insert tr;

        Id sysAdminProfId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        List<Account> accounts = new List<Account>();
        List<Account> allAccounts = new List<Account>();

        // Create Test Accounts
        for(Integer i = 0;i<MAX_ACCOUNTS;i++){
            accounts.add(TestDataFactory.createAccount_US('RefLabs TestAcct ' + i, false));
        }

        allAccounts.addAll(accounts);

        // A Validation Rule on Case prevents Send In Courier from being set to Courier
        // if Courier_Service_Eligibility__c is not Eligible.
        // As the validation rule and field was not ready with this code, this logic is written to work with or without the field.
        Boolean setCourierServiceElgibility = Schema.SObjectType.Account.fields.getMap().containsKey('Courier_Service_Eligibility__c');

        // All fields copied from Account to Contact in DiagnosticCaseService.setDiagnosticFieldsOnCaseFromAccount are set here
        Account diagnosticsAccount1 = TestDataFactory.createAccount_US(setDiagnosticFieldsAccount1Name, false);
        // Courier Service Provider is a dependent picklist of Primary Lab Location.
        // Values are specifically chosen that exist in Production.
        // TPDEV-637 replaced 'Akron, OH' to 'Dallas, TX '
        diagnosticsAccount1.Primary_Lab_Location__c = 'Dallas, TX ';

        diagnosticsAccount1.Courier_Request_Type__c = TestDataFactory.retrieveFirstActivePicklistValue('Account',
            'Courier_Request_Type__c');
        
        // Dropbox Needed if Courier is a dependent picklist of Send In Carrier.
        // Values are specifically chosen that exist in Production
        diagnosticsAccount1.Send_In_Courier__c = 'Courier';
        diagnosticsAccount1.Courier_Service_Provider__c = 'Lab Logistics';
        diagnosticsAccount1.Days_of_Pickup__c = TestDataFactory.retrieveFirstActivePicklistValue('Account', 
            'Days_of_Pickup__c');

        diagnosticsAccount1.Dropbox_Needed_if_Courier__c = 'Yes';
        diagnosticsAccount1.Pick_ups_Per_Day__c = 10;
        diagnosticsAccount1.Preferred_Pickup_Time__c = 'Morning';
        diagnosticsAccount1.Start_Date__c = System.today().addDays(5);
        diagnosticsAccount1.UPS_PPP_Customer__c = 'Customer';
        diagnosticsAccount1.UPS_PPP_Pickup_Location__c = 'Location';
        diagnosticsAccount1.Will_Call_Time__c = 'Afternoon';

        if (setCourierServiceElgibility) {
            diagnosticsAccount1.put('Courier_Service_Eligibility__c', 'Eligible');
        }
        
        allAccounts.add(diagnosticsAccount1);

        Account diagnosticsAccount2 = TestDataFactory.createAccount_US(setDiagnosticFieldsAccount2Name, false);
        diagnosticsAccount2.Send_In_Courier__c = 'UPS';
        diagnosticsAccount2.UPS_PPP_Pickup_Location__c = 'Location2';
         // TPDEV-637 replaced 'Akron, OH' to 'Dallas, TX '
        diagnosticsAccount2.Primary_Lab_Location__c = 'Dallas, TX';
        diagnosticsAccount2.Courier_Service_Provider__c = 'Lab Logistics';
        diagnosticsAccount2.Days_of_Pickup__c = TestDataFactory.retrieveFirstActivePicklistValue('Account', 
            'Days_of_Pickup__c');

        diagnosticsAccount2.Courier_Request_Type__c = TestDataFactory.retrieveFirstActivePicklistValue('Account',
            'Courier_Request_Type__c');

        diagnosticsAccount2.Pick_ups_Per_Day__c = 5;
        diagnosticsAccount2.Preferred_Pickup_Time__c = 'Afternoon';
        diagnosticsAccount2.Start_Date__c = System.today().addDays(10);
        diagnosticsAccount2.UPS_PPP_Customer__c = 'Customer';
        diagnosticsAccount2.Will_Call_Time__c = 'Evening';

        if (setCourierServiceElgibility) {
            diagnosticsAccount2.put('Courier_Service_Eligibility__c', 'Eligible');
        }

        allAccounts.add(diagnosticsAccount2);

        insert allAccounts;

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
        insert territories;

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

        insert usersToInsert;

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

        insert positions;

        // For Each Account
        List<ZTS_AccountTerritory__c> acctTerritories = new List<ZTS_AccountTerritory__c>();
        List<Address__c> addresses = new List<Address__c>();
        List<Contact> contacts = new List<Contact>();
        List<Contact> allContacts = new List<Contact>();
        for(Account acc : accounts){
            // Align Territories to Account
            for(ZTS_EU_Territory__c territory : territories){
                acctTerritories.add(TestDataFactory.createAccountTerritory(acc,territory,true,false));
            }

            // Create Ref Labs Ship To Address
            Address__c addr = new Address__c();
            addr.ZTS_Address_Line_1__c = '123 Main Street';
            addr.Name = '123 Main Street';
            addr.ZTS_EU_City__c = 'Parsippany';
            addr.ZTS_EU_District__c = 'A';
            addr.Zip_Postal_Code__c = '07054';
            addr.ZTS_EU_Country__c = 'United States';
            addr.ZTS_EU_Account__c = acc.Id;
            addr.ZTS_EU_Address_Type__c = 'Ship Address';
            addr.Is_Active__c = true;
            addr.LIS_Number__c = '1234';
            addr.Reference_Labs_Ship_to__c = true;
            addresses.add(addr);

            // Create Ref Labs Contact
            Contact con = new Contact();
            con.FirstName = 'TestConFirst ' + acc.Id;
            con.LastName = 'TestConLast ' + acc.Id;
            con.AccountId = acc.Id;
            con.ZTS_US_Profession__c = 'Veterinarian';
            con.ZTS_US_Job_Function__c = 'Veterinary Resident';
            contacts.add(con);
        }

        Contact diagnosticsContact = TestDataFactory.createContact(diagnosticsAccount2.Id, false);
        diagnosticsContact.ZTS_US_Profession__c = 'Veterinarian';
        diagnosticsContact.ZTS_US_Job_Function__c = 'Owner';

        Contact noAccountContact = TestDataFactory.createContact(null, false);
        noAccountContact.ZTS_US_Profession__c = 'Veterinarian';
        noAccountContact.ZTS_US_Job_Function__c = 'Owner';

        allContacts.addAll(contacts);
        allContacts.add(diagnosticsContact);
        allContacts.add(noAccountContact);

        insert acctTerritories;
        insert addresses;
        insert allContacts;


        // For Each Account
        // Create Test Onboarding Cases which are ready to be Closed
        // We do this separately because we need the Contact Ids from above
        List<Case> cases = new List<Case>();
        for(Account acc : accounts){
            Case cs = new Case();
            cs.Subject = 'Ref Labs Onboarding';
            cs.Description = 'Test 123';
            cs.AccountId = acc.Id;
            cs.RecordTypeId = DiagnosticCaseService.refLabsOnboardingRecordtypeId;
            for(Contact c : contacts){
                if(c.AccountId == acc.Id){
                    cs.ContactId = c.Id;
                }
            }
            cs.Primary_Lab_Location__c = TestDataFactory.retrieveFirstActivePicklistValue('Case', 'Primary_Lab_Location__c');
            cs.Status = 'New';
            cases.add(cs);
        }

       insert cases;
        
        DispatchTriggerHandler.clearAllBypasses();
    }

    /**
    * @description Tests the returnClosedRefLabOnboardingCases method to make sure 
    * that it correctly returns a list of newly closed Ref Lab Onboarding Cases
    * @author Morgan Marchese @ Zoetis Inc | 04-23-2022 
    **/
    @isTest
    static void returnClosedRefLabOnboardingCases_TEST(){
        List<Case> cases = [SELECT Id,AccountId,RecordTypeId,Status FROM Case WHERE Subject = 'Ref Labs Onboarding' AND Status != 'Closed'];
        System.assertEquals(2,cases.size(),'Should Be One Open Onboarding Case Per Account');
        Map<Id,Case> oldCases = new Map<Id,Case>();
        cases[0].Status = 'Closed';
        oldCases.put(cases[0].Id,new Case(Id = cases[0].Id,Status='New'));
        oldCases.put(cases[1].Id,cases[1]);

        List<Case> closedRefLabCases = new List<Case>();
        Test.startTest();
        closedRefLabCases = DiagnosticCaseService.returnClosedRefLabOnboardingCases(cases, oldCases);
        Test.stopTest();
        System.assertEquals(1, closedRefLabCases.size());
    }

    /**
    * @description Creates Ref Lab In Service Cases from Closed Onboarding Cases.
    * Default Assignment Logic when all Account Positions are found is to assign to 
    * the Diagnostics Tech Solutions Position (DTS)
    * @author Morgan Marchese @ Zoetis Inc | 04-23-2022 
    **/
    @isTest
    static void createRefLabsInServiceCases_ToDTS_TEST(){
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Account.Name !=: setDiagnosticFieldsAccount2Name AND AccountId != null];
        List<Case> cases = [SELECT Id,AccountId,RecordTypeId,Status FROM Case WHERE Subject = 'Ref Labs Onboarding' AND Status != 'Closed'];
        Id expectedOwnerId = [SELECT Id FROM User WHERE FirstName = 'DTS UserFirst' LIMIT 1].Id;
        
        System.assertEquals(2, cases.size());
        for(Contact con : contacts){
            con.Reference_Lab_Contact__c = true;
            con.RefLabs_Email_Default__c = true;
            con.RefLabs_Contact_Email__c = 'testemail+reflabs@zoetis.com';
            con.RefLabs_Results_Email__c = 'testemail+reflabs@zoetis.com';
        }

        update contacts;

        for(Case cs : cases){
            cs.Status = 'Closed';
            cs.Onboarding_processes_complete__c = true;
        }
        Test.startTest();
        update cases;
        Test.stopTest();

        List<Case> inServiceCases = [SELECT Id FROM Case WHERE Type = 'In Service' AND OwnerId = :expectedOwnerId];
        System.assertEquals(2, inServiceCases.size()); 
    }
    
         /**
    * @description Creates Ref Lab In Service Cases from Closed Onboarding Cases.
    * Assignment Logic when DTS Account Position is not found is to assign to 
    * the Regional Diagnostics Tech Specialists Position
    * @author Morgan Marchese @ Zoetis Inc | 04-23-2022 
    **/
    @isTest
    static void createRefLabsInServiceCases_ToRDTS_TEST(){
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Account.Name !=: setDiagnosticFieldsAccount2Name AND AccountId != null];
        List<Case> cases = [SELECT Id,AccountId,RecordTypeId,Status FROM Case WHERE Subject = 'Ref Labs Onboarding' AND Status != 'Closed'];
        List<ZTS_EU_Account_Position__c> accountPositions = [SELECT Id FROM ZTS_EU_Account_Position__c WHERE (ZTS_EU_Employee__c LIKE '%DTS%')];
        delete accountPositions;
        Id expectedOwnerId = [SELECT Id FROM User WHERE FirstName = 'Regional UserFirst' LIMIT 1].Id;

        System.assertEquals(2, cases.size());
        for(Contact con : contacts){
            con.Reference_Lab_Contact__c = true;
            con.RefLabs_Email_Default__c = true;
            con.RefLabs_Contact_Email__c = 'testemail+reflabs@zoetis.com';
            con.RefLabs_Results_Email__c = 'testemail+reflabs@zoetis.com';
        }

        update contacts;

        for(Case cs : cases){
            cs.Status = 'Closed';
            cs.Onboarding_processes_complete__c = true;
        }
        Test.startTest();
        update cases;
        Test.stopTest();

        List<Case> inServiceCases = [SELECT Id FROM Case WHERE Type = 'In Service' AND OwnerId = :expectedOwnerId];
        System.assertEquals(2, inServiceCases.size()); 
    }

    
    /**
    * @description Creates Ref Lab In Service Cases from Closed Onboarding Cases.
    * Assignment Logic when DTS Account Positions isn't found is to assign to 
    * the Diagnostics Solution Consultant (DSC)
    * @author Morgan Marchese @ Zoetis Inc | 04-23-2022 
    **/
    @isTest
    static void createRefLabsInServiceCases_ToDSC_TEST(){
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Account.Name !=: setDiagnosticFieldsAccount2Name AND AccountId != null];
        List<Case> cases = [SELECT Id,AccountId,RecordTypeId,Status FROM Case WHERE Subject = 'Ref Labs Onboarding' AND Status != 'Closed'];
        List<ZTS_EU_Account_Position__c> accountPositions = [SELECT Id FROM ZTS_EU_Account_Position__c WHERE (ZTS_EU_Employee__c LIKE '%DTS%' OR ZTS_EU_Employee__c LIKE '%Regional%')];
        delete accountPositions;
        Id expectedOwnerId = [SELECT Id FROM User WHERE FirstName = 'DSC UserFirst' LIMIT 1].Id;

        System.assertEquals(2, cases.size());
        for(Contact con : contacts){
            con.Reference_Lab_Contact__c = true;
            con.RefLabs_Email_Default__c = true;
            con.RefLabs_Contact_Email__c = 'testemail+reflabs@zoetis.com';
            con.RefLabs_Results_Email__c = 'testemail+reflabs@zoetis.com';
        }

        update contacts;

        for(Case cs : cases){
            cs.Status = 'Closed';
            cs.Onboarding_processes_complete__c = true;
        }
        Test.startTest();
        update cases;
        Test.stopTest();

        List<Case> inServiceCases = [SELECT Id FROM Case WHERE Type = 'In Service' AND OwnerId = :expectedOwnerId];
        System.assertEquals(2, inServiceCases.size()); 
    }

    /**
    * @description Creates Ref Lab In Service Cases from Closed Onboarding Cases.
    * Assignment Logic when DTS/DSC Account Positions aren't found is to assign to 
    * the Inside Sales Diagnostics (ISDX) Position
    * @author Morgan Marchese @ Zoetis Inc | 04-23-2022 
    **/
    @isTest
    static void createRefLabsInServiceCases_ToISDX_TEST(){
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Account.Name !=: setDiagnosticFieldsAccount2Name AND AccountId != null];
        List<Case> cases = [SELECT Id,AccountId,RecordTypeId,Status FROM Case WHERE Subject = 'Ref Labs Onboarding' AND Status != 'Closed'];
        List<ZTS_EU_Account_Position__c> accountPositions = [SELECT Id FROM ZTS_EU_Account_Position__c WHERE (ZTS_EU_Employee__c LIKE '%DTS%' OR ZTS_EU_Employee__C LIKE '%DSC%' OR ZTS_EU_Employee__c LIKE '%Regional%')];
        delete accountPositions;
        Id expectedOwnerId = [SELECT Id FROM User WHERE FirstName = 'ISDX UserFirst' LIMIT 1].Id;

        System.assertEquals(2, cases.size());
        for(Contact con : contacts){
            con.Reference_Lab_Contact__c = true;
            con.RefLabs_Email_Default__c = true;
            con.RefLabs_Contact_Email__c = 'testemail+reflabs@zoetis.com';
            con.RefLabs_Results_Email__c = 'testemail+reflabs@zoetis.com';
        }

        update contacts;

        for(Case cs : cases){
            cs.Status = 'Closed';
            cs.Onboarding_processes_complete__c = true;
        }
        Test.startTest();
        update cases;
        Test.stopTest();

        List<Case> inServiceCases = [SELECT Id FROM Case WHERE Type = 'In Service' AND OwnerId = :expectedOwnerId];
        System.assertEquals(2, inServiceCases.size()); 
    }
    


    /**
    * @description Creates Ref Lab In Service Cases from Closed Onboarding Cases.
    * Assignment Logic when no matching Account Positions are found is to assign to 
    * the Ref Lab Onboarding Queue
    * @author Morgan Marchese @ Zoetis Inc | 04-23-2022 
    **/
    @isTest
    static void createRefLabsInServiceCases_ToQueue_TEST(){
        List<ZTS_EU_Account_Position__c> accountPositions = [SELECT Id FROM ZTS_EU_Account_Position__c];
        delete accountPositions;
        Id expectedOwnerId = DiagnosticCaseService.refLabsQueues.get(DiagnosticCaseService.REFLABS_ONBOARDING_Q_DEVNAME).Id;

        List<Contact> contacts = [SELECT Id FROM Contact WHERE Account.Name !=: setDiagnosticFieldsAccount2Name AND AccountId != null];
        List<Case> cases = [SELECT Id,AccountId,RecordTypeId,Status FROM Case WHERE Subject = 'Ref Labs Onboarding' AND Status != 'Closed'];

        System.assertEquals(2, cases.size());
        for(Contact con : contacts){
            con.Reference_Lab_Contact__c = true;
            con.RefLabs_Email_Default__c = true;
            con.RefLabs_Contact_Email__c = 'testemail+reflabs@zoetis.com';
            con.RefLabs_Results_Email__c = 'testemail+reflabs@zoetis.com';
        }

        update contacts;

        for(Case cs : cases){
            cs.Status = 'Closed';
            cs.Onboarding_processes_complete__c = true;
        }
        Test.startTest();
        update cases;
        Test.stopTest();

        List<Case> inServiceCases = [SELECT Id FROM Case WHERE Type = 'In Service' AND OwnerId =: expectedOwnerId];
        System.assertEquals(2, inServiceCases.size()); 
    }

    @isTest
    private static void setDiagnosticFieldsOnCaseFromAccount_RefLabOnboarding_AllFields_Test() {
        Account testAccount = retrieveAccountWithRefLabFields();

        Case testCase = ZTS_DataUtilityTest.createCases(1, DiagnosticCaseService.refLabsOnboardingRecordtypeId)[0];
        testCase.AccountId = testAccount.Id;
        testCase.Type = DiagnosticCaseService.REFLABS_COURIER_TYPE;

        Test.startTest();
            insert testCase;
        Test.stopTest();

        testCase = retrieveCaseWithRefLabFields(testCase.Id);

        System.assertEquals(testAccount.Primary_Lab_Location__c, testCase.Primary_Lab_Location__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Courier_Request_Type__c, testCase.Courier_Request_Type__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Send_In_Courier__c, testCase.Send_In_Courier__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Courier_Service_Provider__c, testCase.Courier_Service_Provider__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Days_of_Pickup__c, testCase.Days_of_Pickup__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Dropbox_Needed_if_Courier__c, testCase.Dropbox_Needed__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Pick_ups_Per_Day__c, testCase.Pickups_Per_Day__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Preferred_Pickup_Time__c, testCase.Preferred_Pickup_Time__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Start_Date__c, testCase.Start_Date__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.UPS_PPP_Customer__c, testCase.UPS_PPP_Customer__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.UPS_PPP_Pickup_Location__c, testCase.UPS_PPP_Pickup_Location__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Will_Call_Time__c, testCase.Will_Call_Time__c,
            'Account and Case should have the same value.');

        System.assertEquals(false, testCase.Send_Courier_Notification__c,
            'Send Courier Notification should be false.');
        
        Account updatedAccount = retrieveAccountWithOnboardingCaseStatus(testAccount.Id);
        system.assertEquals(true, updatedAccount.Onboarding_Case_Status__c,
            'Onboarding_Case_Status__c should be set to true.');
    }

    @isTest
    private static void setDiagnosticFieldsOnCaseFromAccount_RefLabOnboarding_SetFieldsOnCase_Test() {
        Account testAccount = retrieveAccountWithRefLabFields();

        Case testCase = ZTS_DataUtilityTest.createCases(1, DiagnosticCaseService.refLabsOnboardingRecordtypeId)[0];
        testCase.AccountId = testAccount.Id;
        testCase.Type = DiagnosticCaseService.REFLABS_COURIER_TYPE;
        // Automation in SL_CaseTriggerHandler.beforeInsertUpdatePrimaryLabLocation will set this field to Louisville, KY automatically
        // Courier_Service_Provider__c is a dependent picklist of Primary_Lab_Location__c, so changing this will cause errors.
        testCase.Primary_Lab_Location__c = 'Louisville, KY';
        testCase.Courier_Request_Type__c = TestDataFactory.retrieveFirstActivePicklistValue('Case',
            'Courier_Request_Type__c');

        testCase.Send_In_Courier__c = 'UPS';
        testCase.Courier_Service_Provider__c = 'Lab Logistics';
        testCase.Days_of_Pickup__c = 'Tue';
        testCase.Pickups_Per_Day__c = 5;
        testCase.Preferred_Pickup_Time__c = 'Afternoon';
        testCase.Start_Date__c = System.today().addDays(10);
        testCase.UPS_PPP_Customer__c = 'Case Customer';
        testCase.UPS_PPP_Pickup_Location__c = 'Case Location';
        testCase.Will_Call_Time__c = 'Morning';

        Test.startTest();
            insert testCase;
        Test.stopTest();

        Case updatedCase = retrieveCaseWithRefLabFields(testCase.Id);

        System.assertEquals(testCase.Primary_Lab_Location__c, updatedCase.Primary_Lab_Location__c,
            buildCaseFieldChangedError('Primary_Lab_Location__c', testAccount.Primary_Lab_Location__c));
        
        System.assertEquals(testCase.Courier_Request_Type__c, updatedCase.Courier_Request_Type__c,
            buildCaseFieldChangedError('Courier_Request_Type__c', testAccount.Courier_Request_Type__c));
        
        System.assertEquals(testCase.Send_In_Courier__c, updatedCase.Send_In_Courier__c,
            buildCaseFieldChangedError('Send_In_Courier__c', testAccount.Send_In_Courier__c));
        
        System.assertEquals(testCase.Courier_Service_Provider__c, updatedCase.Courier_Service_Provider__c,
            buildCaseFieldChangedError('Courier_Service_Provider__c', testAccount.Courier_Service_Provider__c));
        
        System.assertEquals(testCase.Days_of_Pickup__c, updatedCase.Days_of_Pickup__c,
            buildCaseFieldChangedError('Days_of_Pickup__c', testAccount.Days_of_Pickup__c));
        
        System.assertEquals(testCase.Dropbox_Needed__c, updatedCase.Dropbox_Needed__c,
            buildCaseFieldChangedError('Dropbox_Needed__c', testAccount.Dropbox_Needed_if_Courier__c));
        
        System.assertEquals(testCase.Pickups_Per_Day__c, updatedCase.Pickups_Per_Day__c,
            buildCaseFieldChangedError('Pickups_Per_Day__c', testAccount.Pick_ups_Per_Day__c));
        
        System.assertEquals(testCase.Preferred_Pickup_Time__c, updatedCase.Preferred_Pickup_Time__c,
            buildCaseFieldChangedError('Preferred_Pickup_Time__c', testAccount.Preferred_Pickup_Time__c));
        
        System.assertEquals(testCase.Start_Date__c, updatedCase.Start_Date__c,
            buildCaseFieldChangedError('Start_Date__c', testAccount.Start_Date__c));
        
        System.assertEquals(testCase.UPS_PPP_Customer__c, updatedCase.UPS_PPP_Customer__c,
            buildCaseFieldChangedError('UPS_PPP_Customer__c', testAccount.UPS_PPP_Customer__c));
        
        System.assertEquals(testCase.UPS_PPP_Pickup_Location__c, updatedCase.UPS_PPP_Pickup_Location__c,
            buildCaseFieldChangedError('UPS_PPP_Pickup_Location__c', testAccount.UPS_PPP_Pickup_Location__c));
        
        System.assertEquals(testCase.Will_Call_Time__c, updatedCase.Will_Call_Time__c,
            buildCaseFieldChangedError('Will_Call_Time__c', testAccount.Will_Call_Time__c));
        
        System.assertEquals(false, testCase.Send_Courier_Notification__c,
            'Send Courier Notification should be false.');

        Account updatedAccount = retrieveAccountWithOnboardingCaseStatus(testAccount.Id);
        system.assertEquals(true, updatedAccount.Onboarding_Case_Status__c,
            'Onboarding_Case_Status__c should be set to true.');
    }

    @isTest
    private static void setDiagnosticFieldsOnCaseFromAccount_RefLabOnboarding_NonCourier_Test() {
        Account testAccount = retrieveAccountWithRefLabFields();

        Case testCase = ZTS_DataUtilityTest.createCases(1, DiagnosticCaseService.refLabsOnboardingRecordtypeId)[0];
        testCase.AccountId = testAccount.Id;
        testCase.Type = 'Onboarding';
        // New is the Default value for the Onboarding Record Type
        testCase.Courier_Request_Type__c = 'New';

        Test.startTest();
            insert testCase;
        Test.stopTest();

        Case updatedCase = retrieveCaseWithRefLabFields(testCase.Id);

        System.assertEquals(testAccount.Primary_Lab_Location__c, updatedCase.Primary_Lab_Location__c,
            'Primary_Lab_Location__c should match on the Case and Account.');

        System.assertEquals(testCase.Courier_Request_type__c, updatedCase.Courier_Request_Type__c,
            buildCaseFieldChangedError('Courier_Request_type__c', testAccount.Courier_Request_type__c));

        System.assertEquals(null, updatedCase.Send_In_Courier__c,
            'Value should be null.');

        System.assertEquals(null, updatedCase.Courier_Service_Provider__c,
            'Value should be null.');

        System.assertEquals(null, updatedCase.Days_of_Pickup__c,
            'Value should be null.');

        System.assertEquals(null, updatedCase.Dropbox_Needed__c,
            'Value should be null.');

        System.assertEquals(null, updatedCase.Pickups_Per_Day__c,
            'Value should be null.');

        System.assertEquals(null, updatedCase.Preferred_Pickup_Time__c,
            'Value should be null.');

        System.assertEquals(null, updatedCase.Start_Date__c,
            'Value should be null.');

        System.assertEquals(null, updatedCase.UPS_PPP_Customer__c,
            'Value should be null.');

        System.assertEquals(null, updatedCase.UPS_PPP_Pickup_Location__c,
            'Value should be null.');

        System.assertEquals(null, updatedCase.Will_Call_Time__c,
            'Value should be null.');

        System.assertEquals(false, updatedCase.Send_Courier_Notification__c,
            'Value should be false.');

        Account updatedAccount = retrieveAccountWithOnboardingCaseStatus(testAccount.Id);
        system.assertEquals(true, updatedAccount.Onboarding_Case_Status__c,
            'Onboarding_Case_Status__c should be set to true.');
    }

    @isTest
    private static void setDiagnosticFieldsOnCaseFromAccount_RefLabOnboarding_FromContact_Test() {
        Contact testContact = retrieveContactWithAccountRefLabFields();

        Case testCase = ZTS_DataUtilityTest.createCases(1, DiagnosticCaseService.refLabsOnboardingRecordtypeId)[0];
        testCase.ContactId = testContact.Id;
        testCase.Type = DiagnosticCaseService.REFLABS_COURIER_TYPE;

        Test.startTest();
            insert testCase;
        Test.stopTest();

        testCase = retrieveCaseWithRefLabFields(testCase.Id);

        System.assertEquals(testContact.Account.Primary_Lab_Location__c, testCase.Primary_Lab_Location__c,
            'Account and Case should have the same value.');

        System.assertEquals(testContact.Account.Courier_Request_Type__c, testCase.Courier_Request_Type__c,
            'Account and Case should have the same value.');

        System.assertEquals(testContact.Account.Send_In_Courier__c, testCase.Send_In_Courier__c,
            'Account and Case should have the same value.');

        System.assertEquals(testContact.Account.Courier_Service_Provider__c, testCase.Courier_Service_Provider__c,
            'Account and Case should have the same value.');

        System.assertEquals(testContact.Account.Days_of_Pickup__c, testCase.Days_of_Pickup__c,
            'Account and Case should have the same value.');

        System.assertEquals(testContact.Account.Dropbox_Needed_if_Courier__c, testCase.Dropbox_Needed__c,
            'Account and Case should have the same value.');

        System.assertEquals(testContact.Account.Pick_ups_Per_Day__c, testCase.Pickups_Per_Day__c,
            'Account and Case should have the same value.');

        System.assertEquals(testContact.Account.Preferred_Pickup_Time__c, testCase.Preferred_Pickup_Time__c,
            'Account and Case should have the same value.');

        System.assertEquals(testContact.Account.Start_Date__c, testCase.Start_Date__c,
            'Account and Case should have the same value.');

        System.assertEquals(testContact.Account.UPS_PPP_Customer__c, testCase.UPS_PPP_Customer__c,
            'Account and Case should have the same value.');

        System.assert(String.isblank(testCase.UPS_PPP_Pickup_Location__c),
            'UPS PPP Pickup Location should be blank.');

        System.assertEquals(testContact.Account.Will_Call_Time__c, testCase.Will_Call_Time__c,
            'Account and Case should have the same value.');

        System.assertEquals(false, testCase.Send_Courier_Notification__c,
            'Send Courier Notification should be false.');
        
        Account updatedAccount = retrieveAccountWithOnboardingCaseStatus(testContact.AccountId);
        system.assertEquals(true, updatedAccount.Onboarding_Case_Status__c,
            'Onboarding_Case_Status__c should be set to true.');
    }

    @isTest
    private static void setDiagnosticFieldsOnCaseFromAccount_RefLabSupport_Test() {
        Account testAccount = retrieveAccountWithRefLabFields();

        Case testCase = ZTS_DataUtilityTest.createCases(1, DiagnosticCaseService.refLabsSupportRecordtypeId)[0];
        testCase.AccountId = testAccount.Id;
        testCase.Type = DiagnosticCaseService.REFLABS_COURIER_TYPE;

        Test.startTest();
            insert testCase;
        Test.stopTest();

        testCase = retrieveCaseWithRefLabFields(testCase.Id);

        System.assertEquals(testAccount.Primary_Lab_Location__c, testCase.Primary_Lab_Location__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Courier_Request_Type__c, testCase.Courier_Request_Type__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Send_In_Courier__c, testCase.Send_In_Courier__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Courier_Service_Provider__c, testCase.Courier_Service_Provider__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Days_of_Pickup__c, testCase.Days_of_Pickup__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Dropbox_Needed_if_Courier__c, testCase.Dropbox_Needed__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Pick_ups_Per_Day__c, testCase.Pickups_Per_Day__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Preferred_Pickup_Time__c, testCase.Preferred_Pickup_Time__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Start_Date__c, testCase.Start_Date__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.UPS_PPP_Customer__c, testCase.UPS_PPP_Customer__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.UPS_PPP_Pickup_Location__c, testCase.UPS_PPP_Pickup_Location__c,
            'Account and Case should have the same value.');

        System.assertEquals(testAccount.Will_Call_Time__c, testCase.Will_Call_Time__c,
            'Account and Case should have the same value.');

        System.assertEquals(false, testCase.Send_Courier_Notification__c,
            'Send Courier Notification should be false.');
        
        Account updatedAccount = retrieveAccountWithOnboardingCaseStatus(testAccount.Id);
        system.assertEquals(false, updatedAccount.Onboarding_Case_Status__c,
            'Onboarding_Case_Status__c should be set to false.');
    }

    @isTest
    private static void setDiagnosticFieldsOnCaseFromAccount_RefLabSupport_SendCourierNotification_Test() {
        Account testAccount = retrieveAccountWithRefLabFields(setDiagnosticFieldsAccount2Name);

        Case testCase = ZTS_DataUtilityTest.createCases(1, DiagnosticCaseService.refLabsSupportRecordtypeId)[0];
        testCase.AccountId = testAccount.Id;
        testCase.Type = DiagnosticCaseService.REFLABS_COURIER_TYPE;
        testCase.Send_In_Courier__c = 'Courier';

        Test.startTest();
            insert testCase;
        Test.stopTest();

        Case updatedCase = retrieveCaseWithRefLabFields(testCase.Id);

        // A subset of fields are tested in this unit test

        System.assertEquals(testCase.Send_In_Courier__c, updatedCase.Send_In_Courier__c,
            buildCaseFieldChangedError('Send_In_Courier__c', testAccount.Send_In_Courier__c));

        System.assert(String.isBlank(updatedCase.UPS_PPP_Pickup_Location__c), String.format(
            'UPS_PPP_Pickup_Location__c should be blank. Actual: {0}',
            new List<Object>{updatedCase.UPS_PPP_Pickup_Location__c}));

        System.assertEquals(true, updatedCase.Send_Courier_Notification__c,
            'Send Courier Notification should be true.');
        
        Account updatedAccount = retrieveAccountWithOnboardingCaseStatus(testAccount.Id);
        system.assertEquals(false, updatedAccount.Onboarding_Case_Status__c,
            'Onboarding_Case_Status__c should be set to false.');
    }

    @isTest
    private static void setDiagnosticFieldsOnCaseFromAccount_NoAccountOrContact_Test() {
        Case testCase = ZTS_DataUtilityTest.createCases(1, DiagnosticCaseService.refLabsOnboardingRecordtypeId)[0];
        testCase.Type = DiagnosticCaseService.REFLABS_COURIER_TYPE;
        testCase.Courier_Request_Type__c = TestDataFactory.retrieveFirstActivePicklistValue('Case',
            'Courier_Request_Type__c');

        Test.startTest();
            insert testCase;
        Test.stopTest();

        Case updatedCase = retrieveCaseWithRefLabFields(testCase.Id);

        // Just a single field is asserted as the main purpose of this test is to make sure no errors occur.
        System.assertEquals(testCase.Courier_Request_Type__c, updatedCase.Courier_Request_Type__c,
            'Courier_Request_Type__c should not have changed.');
    }

    @isTest
    private static void setDiagnosticFieldsOnCaseFromAccount_ContactNoAccount_Test() {
        Case testCase = ZTS_DataUtilityTest.createCases(1, DiagnosticCaseService.refLabsOnboardingRecordtypeId)[0];
        testCase.Type = DiagnosticCaseService.REFLABS_COURIER_TYPE;
        testCase.Courier_Request_Type__c = TestDataFactory.retrieveFirstActivePicklistValue('Case',
            'Courier_Request_Type__c');

        testCase.ContactId = [
            SELECT Id
            FROM Contact
            WHERE AccountId = null
            LIMIT 1].Id;

        Test.startTest();
            insert testCase;
        Test.stopTest();

        Case updatedCase = retrieveCaseWithRefLabFields(testCase.Id);

        // Just a single field is asserted as the main purpose of this test is to make sure no errors occur.
        System.assertEquals(testCase.Courier_Request_Type__c, updatedCase.Courier_Request_Type__c,
            'Courier_Request_Type__c should not have changed.');
    }

    @isTest
    private static void setDiagnosticFieldsOnCaseFromAccount_Multiple_Test() {
        Map<String, Account> accountsByName = new Map<String, Account>();
        for (Account account : [
            SELECT Id, Courier_Request_Type__c, Primary_Lab_Location__c, Pick_ups_Per_Day__c, 
                   Courier_Service_Provider__c, Preferred_Pickup_Time__c, Dropbox_Needed_if_Courier__c,
                   Send_In_Courier__c, Days_of_Pickup__c, Start_Date__c, UPS_PPP_Customer__c,
                   UPS_PPP_Pickup_Location__c, Will_Call_Time__c, Name
            FROM Account 
            WHERE Name in: new List<String> {setDiagnosticFieldsAccount1Name, setDiagnosticFieldsAccount2Name}]) {
            accountsByName.put(account.Name, account);
        }

        Contact contact = retrieveContactWithAccountRefLabFields();

        List<Case> testCases = new List<Case>();
        Case testCase1 = ZTS_DataUtilityTest.createCases(1, DiagnosticCaseService.refLabsOnboardingRecordtypeId)[0];
        testCase1.AccountId = accountsByName.get(setDiagnosticFieldsAccount1Name).Id;
        testCase1.Type = DiagnosticCaseService.REFLABS_COURIER_TYPE;
        testCases.add(testCase1);

        Case testCase2 = ZTS_DataUtilityTest.createCases(1, DiagnosticCaseService.refLabsSupportRecordtypeId)[0];
        testCase2.ContactId = contact.Id;
        testCase2.Type = DiagnosticCaseService.REFLABS_COURIER_TYPE;
        testCases.add(testCase2);

        Case testCase3 = ZTS_DataUtilityTest.createCases(1, DiagnosticCaseService.refLabsOnboardingRecordtypeId)[0];
        testCase3.AccountId = accountsByName.get(setDiagnosticFieldsAccount2Name).Id;
        testCase3.Type = DiagnosticCaseService.REFLABS_COURIER_TYPE;
        testCases.add(testCase3);

        Case testCase4 = ZTS_DataUtilityTest.createCases(1, DiagnosticCaseService.refLabsOnboardingRecordtypeId)[0];
        testCase4.Type = 'Onboarding';
        testCase4.AccountId = accountsByName.get(setDiagnosticFieldsAccount1Name).Id;
        testCases.add(testCase4);

        Test.startTest();
            insert testCases;
        Test.stopTest();

        for (Case updatedCase : [
            SELECT Id, Primary_Lab_Location__c, Courier_Request_Type__c, Send_In_Courier__c,
                Courier_Service_Provider__c, Days_of_Pickup__c, Dropbox_Needed__c, Pickups_Per_Day__c,
                Preferred_Pickup_Time__c, Start_Date__c, UPS_PPP_Customer__c, UPS_PPP_Pickup_Location__c,
                Will_Call_Time__c, Send_Courier_Notification__c
            FROM Case
            WHERE Id in: testCases]) {
            // Only a subest of fields are checked in this unit test to keep it shorter
            Account testAccount = null;
            if (updatedCase.Id == testCase1.Id) {
                testAccount = accountsByName.get(setDiagnosticFieldsAccount1Name);
                // UPS PPP Pickup Location will vary by Account and Case
                System.assertEquals(testAccount.UPS_PPP_Pickup_Location__c, updatedCase.UPS_PPP_Pickup_Location__c,
                    'Account and Case should have the same value.');
            }
            else if (updatedCase.Id == testCase2.Id || updatedCase.Id == testCase3.Id) {
                testAccount = accountsByName.get(setDiagnosticFieldsAccount2Name);

                System.assert(String.isBlank(updatedCase.UPS_PPP_Pickup_Location__c), String.format(
                    'UPS_PPP_Pickup_Location__c should be blank. Actual: {0}',
                    new List<Object> {updatedCase.UPS_PPP_Pickup_Location__c}));
            }
            else if (updatedCase.Id == testCase4.Id) {
                // Only Primary Lab Location should be set on this Account
                Account otherAccount = accountsByName.get(setDiagnosticFieldsAccount1Name);
                System.assertEquals(otherAccount.Primary_Lab_Location__c, updatedCase.Primary_Lab_Location__c,
                    'Account and Case should have the same value.');

                System.assert(String.isBlank(updatedCase.Send_In_Courier__c), String.format(
                    'Send_In_Courier__c should be blank. Actual: {0}',
                    new List<Object> {updatedCase.Send_In_Courier__c}));

                System.assert(String.isBlank(updatedCase.UPS_PPP_Pickup_Location__c), String.format(
                    'UPS_PPP_Pickup_Location__c should be blank. Actual: {0}',
                    new List<Object> {updatedCase.UPS_PPP_Pickup_Location__c}));
            }

            if (testAccount != null) {
                System.assertEquals(testAccount.Primary_Lab_Location__c, updatedCase.Primary_Lab_Location__c,
                    'Account and Case should have the same value.');

                System.assertEquals(testAccount.Send_In_Courier__c, updatedCase.Send_In_Courier__c,
                    'Account and Case should have the same value.');
            }
        }

        Set<Id> accountIds = new Map<Id, Account>(accountsByName.values()).keySet();
        for (Account updatedAccount : [
            SELECT Id, Onboarding_Case_Status__c, Name
            FROM Account
            WHERE Id in: accountIds]) {
            System.assertEquals(true, updatedAccount.Onboarding_Case_Status__c,
                'Onboarding Case Status should be true.');
        }
    }

    private static Account retrieveAccountWithRefLabFields() {
        return retrieveAccountWithRefLabFields(setDiagnosticFieldsAccount1Name);
    }

    private static Account retrieveAccountWithRefLabFields(string accountName) {
        return [
            SELECT Id, Courier_Request_Type__c, Primary_Lab_Location__c, Pick_ups_Per_Day__c, 
                   Courier_Service_Provider__c, Preferred_Pickup_Time__c, Dropbox_Needed_if_Courier__c,
                   Send_In_Courier__c, Days_of_Pickup__c, Start_Date__c, UPS_PPP_Customer__c,
                   UPS_PPP_Pickup_Location__c, Will_Call_Time__c
            FROM Account 
            WHERE Name =: accountName
            LIMIT 1];
    }

    private static Contact retrieveContactWithAccountRefLabFields() {
        return [
            SELECT Id, AccountId, Account.Courier_Request_Type__c, Account.Primary_Lab_Location__c,
                   Account.Pick_ups_Per_Day__c, Account.Courier_Service_Provider__c, Account.Preferred_Pickup_Time__c,
                   Account.Dropbox_Needed_if_Courier__c, Account.Send_In_Courier__c, Account.Days_of_Pickup__c,
                   Account.Start_Date__c, Account.UPS_PPP_Customer__c, Account.UPS_PPP_Pickup_Location__c,
                   Account.Will_Call_Time__c
            FROM Contact
            WHERE Account.Name =: setDiagnosticFieldsAccount2Name
            LIMIT 1
        ];
    }

    private static Account retrieveAccountWithOnboardingCaseStatus(Id accountId) {
        return [
            SELECT Id, Onboarding_Case_Status__c
            FROM Account
            WHERE Id =: accountId
        ];
    }

    private static Case retrieveCaseWithRefLabFields(Id caseId) {
        return [
            SELECT Id, Primary_Lab_Location__c, Courier_Request_Type__c, Send_In_Courier__c,
                   Courier_Service_Provider__c, Days_of_Pickup__c, Dropbox_Needed__c, Pickups_Per_Day__c,
                   Preferred_Pickup_Time__c, Start_Date__c, UPS_PPP_Customer__c, UPS_PPP_Pickup_Location__c,
                   Will_Call_Time__c, Send_Courier_Notification__c
            FROM Case
            WHERE Id =: caseId
            LIMIT 1];
    }

    private static string buildCaseFieldChangedError(string fieldName, object accountValue) {
        return string.format('The value for {0} should match between Cases. Account Value for comparision: {1}',
            new List<Object> {fieldName, accountValue});
    }
}