/* 
	@description : Test class for the SL_CaseTriggerHandler class.
    The test class SL_CaseTriggerHandler_Test has been taking longer time to execute due to several test methods existed under single class.( JIRA Ticket TPDEV-1033 )
    To reduce the execution time, test methods are split across 2 classes.
    1. SL_CaseTriggerHandler_class
    2. SL_CaseTriggerHandler2_class
 
*/

@isTest
public with sharing class SL_CaseTriggerHandler2_Test {
     @testVisible static final String CASE_UPD_ERROR_ORIGIN = 'SL_CaseTriggerHandler_Test - testHandler(): update Case from list';
    static final String MDM_CHILD_CASE_MULTIPLE_SHIP_TO = CaseService.MDM_CHILD_CASE_MULTIPLE_SHIP_TO;
    static final String REFLABS_ONBOARDING_CASE_ON_HOLD_ERROR = CaseService.REFLABS_ONBOARDING_CASE_ON_HOLD_ERROR;
    static final String REFLABS_TYPE_MASTER_DATA = CaseService.REFLABS_TYPE_MASTER_DATA;
    static final String REFLABS_SUBTYPE_TYPE_ACCOUNT_CHANGE = CaseService.REFLABS_SUBTYPE_TYPE_ACCOUNT_CHANGE;
    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    static final String CASEPRODUCT_RT_ID = 'Zoetis_Product';
    static final string NONZOETIS_CASEPRODUCT_RT_ID = 'Non_Zoetis_Product';
    static final String LOCALASSESSMENT_RT_ID= 'ZTS_US_Local_Assessment';
    static final String PRODUCTASSESSMENT_RT_ID= 'ZTS_US_Product_Assessment';
    // This Account has a single Ship To Addresses
    static final String ACCOUNT1_ORG_CODE = '1000117840';
    static final String CONTACT1_REF_LABS_EMAIL = 'test2@reflabs.com';
    // This Account has an indirect Ship TO Address
    static final String ACCOUNT2_ORG_CODE = '1000117841';
    static final String CONTACT2_REF_LABS_EMAIL = 'test21@reflabs.com';
    // This Account has multiple Ship To Addresses
    static final String ACCOUNT3_ORG_CODE = '1000117839';
    static final string CONTACT3_REF_LABS_EMAIL = 'test@reflabs.com';
    static final string CONTACTNOACCOUNT_REF_LABS_EMAIL = 'testNA@reflabs.com';

    static String refLabsOnboardingRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ref_Labs_Onboarding').getRecordTypeId();

    
    @testSetup
    public static void setupData()
    {
        Allow_VMIPS_SIB_Email_Flag__c emailFlag = Allow_VMIPS_SIB_Email_Flag__c.getOrgDefaults();
        emailFlag.Is_Email_Sending_enabled__c = true;
        upsert emailFlag;
        
        Automation_Bypass__c bypassLogic = Automation_Bypass__c.getOrgDefaults();
        bypassLogic.Call_Bypass__c = true;
        upsert bypassLogic;

        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId(); 
        Date today = Date.today();
        Test.startTest();
        List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
        TriggerActivation__c tr = new TriggerActivation__c(Name = 'ZTS_EU_ServiceRequest',ZTS_EU_Bypass__c = true);
        triggerActiveList.add(tr);
        insert triggerActiveList;
        User u = getUserRecord('System Administrator','Canada');
        System.runAs(u)
        {
            State_Country__c stateCountry = new State_Country__c();
            stateCountry.Name = 'Madrid';
            stateCountry.ZTS_EU_Country__c = 'Spain';
            insert stateCountry;

            Account objAcc = (Account) SL_TestDataFactory.createSObject
            (   new Account
                (   Name = 'Test Company for Case'
                ,   ZTS_EU_Market__c = 'Baltics'
                ,   ZTS_EU_VAT_Code__c = '00011'
                ,   ZTS_EU_Account_Status__c = 'Active'
                ,   ZTS_EU_Zip_Postal_Code__c = '07306'
                ,   LIS_Org_Code__c = ACCOUNT1_ORG_CODE
                ,   ZTS_EU_Country__c = 'Spain'
                ,   ZTS_EU_State_County__c = stateCountry.Id
                )
            ,   false
            );
            Account objAcc2 = (Account) SL_TestDataFactory.createSObject
            (   new Account
                (   Name = 'Test Company for Case2'
                ,   ZTS_EU_Market__c = 'Brazil'
                ,   ZTS_EU_VAT_Code__c = '00012'
                ,   ZTS_EU_Account_Status__c = 'Active'
                ,   ZTS_EU_Zip_Postal_Code__c = '07306'
                ,   LIS_Org_Code__c = ACCOUNT2_ORG_CODE
                )
            ,   false
            );

            Account objAcc3 = (Account) SL_TestDataFactory.createSObject
            (   new Account
                (   Name = 'Test Account For RefLabs Portal'
                ,   ZTS_EU_Market__c = 'Canada'
                ,   ZTS_EU_VAT_Code__c = '00012'
                ,   ZTS_EU_Account_Status__c = 'Active'
                ,   ZTS_EU_Zip_Postal_Code__c = '07306'
                ,   LIS_Org_Code__c = ACCOUNT3_ORG_CODE
                )
            ,   false
            );

            Account diagnosticAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            diagnosticAccount.Name = CaseService.DIAGNOSTICS_ACCOUNT_NAME;

            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            insert new List<Account>{ objAcc, objAcc2, objAcc3, diagnosticAccount };
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');

            Primary_Contact_Inactive_Profile_List__c obj = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names',Profile__c = 'ZTS PL Business Administrator');
            Primary_Contact_Inactive_Profile_List__c obj1 = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names 1',Profile__c = 'ZTS PL Business Administrator');
            Primary_Contact_Inactive_Profile_List__c obj2 = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names 2',Profile__c = 'ZTS PL Business Administrator');
            insert new List<Primary_Contact_Inactive_Profile_List__c>{obj,obj1,obj2};

            Contact objCon = (Contact) SL_TestDataFactory.createSObject
            (   new Contact
                (   LastName = 'Test'
                ,   FirstName = 'Name'
                ,   AccountId = objAcc.Id
                ,   ZTS_EU_Contact_type__c = 'Analyst'
                ,   ZTS_EU_Market__c = 'Baltics'
                ,   RefLabs_Contact_Email__c = CONTACT1_REF_LABS_EMAIL
                ,   ZTS_US_Account_influence__c = 'Decision Maker'
                ,   ZTS_US_Profession__c = 'Consultant'
                ,   ZTS_US_Job_Function__c = 'Operations'
                )
            ,   false
            );
            Contact objCon2 = (Contact) SL_TestDataFactory.createSObject
            (   new Contact
                (   LastName = 'Test2'
                ,   FirstName = 'Name'
                ,   AccountId = objAcc2.Id
                ,   ZTS_EU_Contact_type__c = 'Analyst'
                ,   ZTS_EU_Market__c = 'Baltics'
                ,   RefLabs_Contact_Email__c = CONTACT2_REF_LABS_EMAIL
                ,   ZTS_US_Account_influence__c = 'Decision Maker'
                ,   ZTS_US_Profession__c = 'Consultant'
                ,   ZTS_US_Job_Function__c = 'Operations'
                )
            ,   false
            );

            Contact objCon3 = (Contact) SL_TestDataFactory.createSObject
            (   new Contact
                (   LastName = 'Contact'
                ,   FirstName = 'RefLabs'
                ,   AccountId = objAcc3.Id
                ,   ZTS_EU_Contact_type__c = 'Analyst'
                ,   ZTS_EU_Market__c = 'Canada'
                ,   RefLabs_Contact_Email__c = CONTACT3_REF_LABS_EMAIL
                ,   ZTS_US_Account_influence__c = 'Decision Maker'
                ,   ZTS_US_Profession__c = 'Consultant'
                ,   ZTS_US_Job_Function__c = 'Operations'
                )
            ,   false
            );

            Contact objConNoAccount = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
            objConNoAccount.RefLabs_Contact_Email__c = CONTACTNOACCOUNT_REF_LABS_EMAIL;
            objConNoAccount.ZTS_EU_Market__c = 'Canada';
            
            DispatchTriggerHandler.bypass('ContactTriggerHandler');
            insert new List<Contact>{ objCon, objCon2, objCon3, objConNoAccount};
            DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
            
            Address__c shipToAddress = new Address__c();
            shipToAddress.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Account_Address').getRecordTypeId();
            shipToAddress.Name = 'Evergreen Av. 1234567';
            shipToAddress.ZTS_EU_Account__c =  objAcc3.Id;
            shipToAddress.ZTS_EU_Address_Type__c = 'Ship To';
            shipToAddress.ZTS_EU_Country__c = 'Spain';
            shipToAddress.ZTS_EU_District__c = 'Madrid';
            shipToAddress.Zip_Postal_Code__c = '1234';
            shipToAddress.ZTS_EU_State_County__c = stateCountry.Id;
            shipToAddress.Ship_Indirect__c = 'N';
            shipToAddress.Is_Active__c = true;


            Address__c shipToAddress2 = new Address__c();
            shipToAddress2.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Account_Address').getRecordTypeId();
            shipToAddress2.Name = 'Evergreen Av. 1234567';
            shipToAddress2.ZTS_EU_Account__c =  objAcc3.Id;
            shipToAddress2.ZTS_EU_Address_Type__c = 'Ship To';
            shipToAddress2.ZTS_EU_Country__c = 'Spain';
            shipToAddress2.ZTS_EU_District__c = 'Madrid';
            shipToAddress2.Zip_Postal_Code__c = '1234';
            shipToAddress2.ZTS_EU_State_County__c = stateCountry.Id;
            shipToAddress2.Ship_Indirect__c = 'N';
            shipToAddress2.Is_Active__c = true;

            Address__c shipToAddress3 = new Address__c();
            shipToAddress3.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Account_Address').getRecordTypeId();
            shipToAddress3.Name = 'Evergreen Av. 1234567';
            shipToAddress3.ZTS_EU_Account__c =  objAcc.Id;
            shipToAddress3.ZTS_EU_Address_Type__c = 'Ship To';
            shipToAddress3.ZTS_EU_Country__c = 'Spain';
            shipToAddress3.ZTS_EU_District__c = 'Madrid';
            shipToAddress3.Zip_Postal_Code__c = '1234';
            shipToAddress3.ZTS_EU_State_County__c = stateCountry.Id;
            shipToAddress3.Ship_Indirect__c = 'N';
            shipToAddress3.Is_Active__c = true;
           
            Address__c shipToAddress4 = new Address__c();
            shipToAddress4.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Account_Address').getRecordTypeId();
            shipToAddress4.Name = 'Evergreen Av. 1234567';
            shipToAddress4.ZTS_EU_Account__c =  objAcc2.Id;
            shipToAddress4.ZTS_EU_Address_Type__c = 'Ship To';
            shipToAddress4.ZTS_EU_Country__c = 'Spain';
            shipToAddress4.ZTS_EU_District__c = 'Madrid';
            shipToAddress4.Zip_Postal_Code__c = '1234';
            shipToAddress4.ZTS_EU_State_County__c = stateCountry.Id;
            shipToAddress4.Ship_Indirect__c = 'Y';
            shipToAddress4.Is_Active__c = true;
            
            DispatchTriggerHandler.bypass('AddressTriggerHandler');
            insert new List<Address__c>{shipToAddress, shipToAddress2, shipToAddress3, shipToAddress4};
            DispatchTriggerHandler.clearBypass('AddressTriggerHandler');

            List<Case> cases = ZTS_DataUtilityTest.createCases(2, refLabsOnboardingRecordtypeId);
            for (Case testCase : cases) {
                testCase.Status = 'New';
                testCase.Origin = 'Phone';
                testCase.Type = 'Onboarding';
                testCase.Description = 'Existing Case';
        }

            cases[0].AccountId = objAcc2.Id;
            cases[0].ContactId = objCon2.Id;
            cases[1].AccountId = objAcc3.Id;
            cases[1].ContactId = objCon3.Id;
            insert cases;
        
            List<Entitlement> diagnosticEntitlements = retrieveDiagnosticsEntitlements();
            if (diagnosticEntitlements.isEmpty()) {
                Entitlement entitlementRecord = ZTS_DataUtilityTest.createEntitlement(
                    CaseService.DIAGNOSTICS_ENTITLEMENT_NAME, diagnosticAccount.Id);
            
                entitlementRecord.SlaProcessId = [
                    SELECT ID 
                    FROM SlaProcess 
                    WHERE Name =: CaseService.DIAGNOSTICS_ENTITLEMENT_NAME 
                    LIMIT 1].Id;

                insert entitlementRecord;
            }
        }

        Test.stopTest();
    }
      
    static User getUserRecord(String profileName,String market){
        Profile pf= [Select Id from profile where Name= :profileName];
        String orgId=UserInfo.getOrganizationId();
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000));
        String uniqueName=orgId+dateString+RandomId;
        User uu=new User(firstname = 'test11',
                         lastName = 'McCarthy1',
                         email = uniqueName + '@test' + orgId + '.org',
                         Username = uniqueName + '@test' + orgId + '.org',
                         EmailEncodingKey = 'ISO-8859-1',
                         Alias = uniqueName.substring(18, 23),
                         TimeZoneSidKey = 'America/Los_Angeles',
                         LocaleSidKey = 'en_US',
                         LanguageLocaleKey = 'en_US',
                         ProfileId = pf.Id,
                         ZTS_EU_Market__c = market);
        return uu;
    }

    @isTest
    private static void testBeforeInsertRefLabsPortalCasesConsult(){

        List<Account> lstAcc = new List<Account>{ retrieveAccountByLISOrgCode(ACCOUNT3_ORG_CODE) };
        List<Contact> lstCon = new List<Contact>{retrieveContactByRefLabsContactEmail(CONTACT3_REF_LABS_EMAIL)};


        String refLabsSupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Reference_Labs_Support').getRecordTypeId();
        String dataRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Data_Request').getRecordTypeId();

        List<Case> caseList = new List<Case>();

        Case newCase = new Case(Status = 'New',
                                Origin = 'RefLabs Portal',
                                Type = 'Consult',
                                Subject = 'RefLabs Portal Case test',
                                Description = 'Portal Case',
                                SuppliedEmail = CONTACT3_REF_LABS_EMAIL,
                                LIS_Org_Code__c = ACCOUNT3_ORG_CODE
                               );
        caseList.add(newCase);
        User u = getUserRecord('System Administrator','Canada');
        Test.startTest();
        Boolean exceptionOccurred = false;
        System.runAs(u){
            try{
                insert caseList;
            }
            catch(Exception ex){
                exceptionOccurred = true;
            }
            
        }
        Test.stopTest();

        System.assertEquals(false, exceptionOccurred, 'There should be no exception');
        ZRL_Portal_Case_Type_Mapping__mdt caseTypeMapping =  [
            SELECT Queue_Id__c
            FROM ZRL_Portal_Case_Type_Mapping__mdt
            WHERE Case_Type__c = 'Consult'
            AND Record_Type_Name__c  = 'Reference_Labs_Support'
            LIMIT 1][0];

        Case portalCase = [SELECT Id, AccountId, ContactId, Reflabs_Contact_Email__c, OwnerId, RecordTypeId, ZTS_EU_Market__c FROM Case WHERE Origin = 'RefLabs Portal'][0];


        System.assertEquals(lstAcc[0].Id, portalCase.AccountId, 'The new case should have the Account with LIS associated');
        System.assertEquals(lstAcc[0].ZTS_EU_Market__c, portalCase.ZTS_EU_Market__c, 'The new case should have the Market of its related Account.');
        System.assertEquals(lstCon[0].Id, portalCase.ContactId, 'The new case should have the Contact with RefLabs Email associated');
        System.assertEquals(caseTypeMapping.Queue_Id__c, portalCase.OwnerId, 'The owner should be consulting vet queue');
        System.assertEquals(refLabsSupportRecordTypeId,portalCase.RecordTypeId,  'Record Type should be RefLabs Support');
    }

    @isTest
    private static void testBeforeInsertRefLabsPortalCasesSupport(){

        List<Account> lstAcc = new List<Account>{ retrieveAccountByLISOrgCode(ACCOUNT3_ORG_CODE) };
        List<Contact> lstCon = new List<Contact>{retrieveContactByRefLabsContactEmail(CONTACT3_REF_LABS_EMAIL)};


        String refLabsSupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Reference_Labs_Support').getRecordTypeId();
        List<Case> caseList = new List<Case>();

        Case newCase = new Case(Status = 'New',
                                Origin = 'RefLabs Portal',
                                Type = 'Late Test',
                                Subject = 'RefLabs Portal Case test',
                                Description = 'Portal Case',
                                SuppliedEmail = CONTACT3_REF_LABS_EMAIL,
                                LIS_Org_Code__c = ACCOUNT3_ORG_CODE,
                                ZTS_EU_Market__c = 'United States'
                               );
        caseList.add(newCase);
        User u = getUserRecord('System Administrator','Canada');
        Test.startTest();
        Boolean exceptionOccurred = false;
        System.runAs(u){
            try{
                insert caseList;
            }
            catch(Exception ex){
                exceptionOccurred = true;
            }
            
        }
        Test.stopTest();

        System.assertEquals(false, exceptionOccurred, 'There should be no exception');
        Service_Cloud_Settings__mdt serviceCloudCustomMetadata =  [SELECT Ref_Labs_Customer_Service_Support_Queue__c  
                                                                    FROM Service_Cloud_Settings__mdt][0];

        Case portalCase = [SELECT Id, AccountId, ContactId, Reflabs_Contact_Email__c, OwnerId, RecordTypeId, ZTS_EU_Market__c FROM Case WHERE Origin = 'RefLabs Portal'][0];

        System.assertEquals(lstAcc[0].Id, portalCase.AccountId, 'The new case should have the Account with LIS associated');
        System.assertEquals(newCase.ZTS_EU_Market__c, portalCase.ZTS_EU_Market__c, 
            String.format(
                'The Market of the Case should not have changed since it was set manually. It should not change to the Account\'s Market of {0}',
                new List<String> {lstAcc[0].ZTS_EU_Market__c}));

        System.assertEquals(lstCon[0].Id, portalCase.ContactId, 'The new case should have the Contact with RefLabs Email associated');
        System.assertEquals(serviceCloudCustomMetadata.Ref_Labs_Customer_Service_Support_Queue__c, portalCase.OwnerId, 'The owner should be CS queue');
        System.assertEquals(refLabsSupportRecordTypeId,portalCase.RecordTypeId,  'Record Type should be RefLabs Support');
    }

    @isTest
    private static void testBeforeInsertRefLabsPortalCasesAccountChange(){

        List<Account> lstAcc = new List<Account>{ retrieveAccountByLISOrgCode(ACCOUNT3_ORG_CODE) };
        List<Contact> lstCon = new List<Contact>{retrieveContactByRefLabsContactEmail(CONTACT3_REF_LABS_EMAIL)};

        String dataRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Data_Request').getRecordTypeId();

        List<Case> caseList = new List<Case>();

        Case newCase = new Case(Status = 'New',
                                Origin = 'RefLabs Portal',
                                Type = 'Master Data Inquiry',
                                Subject = 'RefLabs Portal Case test',
                                Description = 'Portal Case',
                                SuppliedEmail = CONTACT3_REF_LABS_EMAIL,
                                LIS_Org_Code__c = ACCOUNT3_ORG_CODE
                               );
        caseList.add(newCase);
        User u = getUserRecord('System Administrator','Canada');
        Test.startTest();
        Boolean exceptionOccurred = false;
        System.runAs(u){
            try{
                insert caseList;
            }
            catch(Exception ex){
                exceptionOccurred = true;
            }
            
        }
        Test.stopTest();

        System.assertEquals(false, exceptionOccurred, 'There should be no exception');
        Service_Cloud_Settings__mdt serviceCloudCustomMetadata =  [SELECT Master_Data_Queue_ID__c  
                                                                    FROM Service_Cloud_Settings__mdt][0];

        Case portalCase = [SELECT Id, AccountId, ContactId, Reflabs_Contact_Email__c, OwnerId, RecordTypeId FROM Case WHERE Origin = 'RefLabs Portal'][0];

        System.assertEquals(lstAcc[0].Id, portalCase.AccountId, 'The new case should have the Account with LIS associated');
        System.assertEquals(lstCon[0].Id, portalCase.ContactId, 'The new case should have the Contact with RefLabs Email associated');
        System.assertEquals(serviceCloudCustomMetadata.Master_Data_Queue_ID__c, portalCase.OwnerId, 'The owner should be MDM queue');
        System.assertEquals(dataRequestRecordTypeId, portalCase.RecordTypeId,  'Record Type should be Data Request');
    }

    @isTest
    private static void testBeforeInsertRefLabsPortalCasesMultipleContacts(){

        List<Account> lstAcc = new List<Account>{ retrieveAccountByLISOrgCode(ACCOUNT1_ORG_CODE) };
        //List<Contact> lstCon = new List<Contact>( [SELECT Id FROM Contact WHERE RefLabs_Contact_Email__c = 'test@reflabs.com'] );

        String dataRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Data_Request').getRecordTypeId();

        List<Case> caseList = new List<Case>();

        Case newCase = new Case(Status = 'New',
                                Origin = 'RefLabs Portal',
                                Type = 'Master Data Inquiry',
                                Subject = 'RefLabs Portal Case test',
                                Description = 'Portal Case',
                                SuppliedEmail = 'test11@reflabs.com',
                                LIS_Org_Code__c = ACCOUNT1_ORG_CODE,
                                // Set Market to Canada as otherwise it will be set to the Market of Account 1.
                                // This will prevent the test User from beign able to edit the Case.
                                ZTS_EU_Market__c = 'Canada'
                               );
        caseList.add(newCase);
        User u = getUserRecord('System Administrator','Canada');
        Test.startTest();
        Boolean exceptionOccurred = false;
        System.runAs(u){
            try{
                insert caseList;
            }
            catch(Exception ex){
                exceptionOccurred = true;
            }
            
        }
        Test.stopTest();

        System.assertEquals(false, exceptionOccurred, 'There should be no exception');
        Service_Cloud_Settings__mdt serviceCloudCustomMetadata =  [SELECT Master_Data_Queue_ID__c  
                                                                    FROM Service_Cloud_Settings__mdt][0];

        Case portalCase = [SELECT Id, AccountId, ContactId, Reflabs_Contact_Email__c, OwnerId, RecordTypeId FROM Case WHERE Origin = 'RefLabs Portal'][0];

        System.assertEquals(lstAcc[0].Id, portalCase.AccountId, 'The new case should have the Account with LIS associated');
        System.assertEquals(null, portalCase.ContactId, 'The new case should not have any Contact associated');
        System.assertEquals(serviceCloudCustomMetadata.Master_Data_Queue_ID__c, portalCase.OwnerId, 'The owner should be MDM queue');
        System.assertEquals(dataRequestRecordTypeId, portalCase.RecordTypeId,  'Record Type should be Data Request');
    }

    @isTest
    private static void testAddressLogicForRefsOnboardingBeforeInsertMultipleShipTo(){
        List<Account> lstAcc = new List<Account>{ retrieveAccountByLISOrgCode(ACCOUNT3_ORG_CODE) };
        List<Contact> lstCon = new List<Contact>{retrieveContactByRefLabsContactEmail(CONTACT3_REF_LABS_EMAIL)};

        // Delete Case created in Test Setup
        delete retrieveExistingRefLabsOnboardingCases(lstAcc[0].Id);
        lstAcc[0].Reference_Lab_Customer__c = false;
        lstAcc[0].RefLabs_Existing_Onboarding_Case__c = false;
        update lstAcc;

        List<Case> caseList = new List<Case>();

        Case newCase = ZTS_DataUtilityTest.createCases(1,refLabsOnboardingRecordtypeId)[0];
      //  Case newCaseChild = ZTS_DataUtilityTest.createCases(1,refLabsOnboardingRecordtypeId)[0];
        newCase.Status = 'New';
        newCase.AccountId = lstAcc[0].Id;
        newCase.ContactId = lstCon[0].Id;
        newCase.Origin = 'Phone';
        newCase.Type = 'Onboarding';
        newCase.Description = 'Manual Onboarding case with multiple Ship to';
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Ref_Labs_Onboarding' ).getRecordTypeId();
        caseList.add(newCase);

        User u = getUserRecord('System Administrator','Canada');

        Test.startTest();
            Boolean exceptionOccurred = false;
            string exceptionMessage;
            System.runAs(u){
                try{
                    insert caseList;
                }
                catch(Exception ex){
                    exceptionOccurred = true;
                    exceptionMessage = ex.getMessage();
                }
                
            }
        Test.stopTest();
        System.assertEquals(false, exceptionOccurred, 
            string.format('An unexpected error occurred: {0}', new List<string> {exceptionMessage}));
        System.debug('newcase::'+newCase);
        Case updatedCase = [
            SELECT Id, Has_RefLabs_Multiple_Ship_To__c, Status
            FROM Case
            WHERE Id =: newCase.Id];
        
        System.assertEquals(true, updatedCase.Has_RefLabs_Multiple_Ship_To__c, 
            'Has_RefLabs_Multiple_Ship_To__c should be set to true for this test as the Account has multiple Ship Tos.');
        System.assertEquals('On Hold', updatedCase.Status);


    }

    @isTest
    private static void testAddressLogicForRefsOnboardingBeforeInsertSingleShipTo(){

        List<Account> lstAcc = new List<Account>{ retrieveAccountByLISOrgCode(ACCOUNT1_ORG_CODE) };
        List<Contact> lstCon = new List<Contact>{retrieveContactByRefLabsContactEmail(CONTACT1_REF_LABS_EMAIL)};

        String dataRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Data_Request').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();

        Case newCase = ZTS_DataUtilityTest.createCases(1,refLabsOnboardingRecordtypeId)[0];
        newCase.Status = 'New';
        newCase.AccountId = lstAcc[0].Id;
        newCase.ContactId = lstCon[0].Id;
        newCase.Origin = 'Phone';
        newCase.Type = 'Onboarding';
        newCase.Description = 'Manual Onboarding case with ONE Ship to';
        caseList.add(newCase);

        Address__c shipToAddress = retrieveShipToAddresses(lstAcc[0].Id)[0];
        system.assertEquals(false, shipToAddress.Reference_Labs_Ship_to__c,
            'Sanity check failed. Reference_Labs_Ship_to__c should be false on the Ship To Address.');

        User u = getUserRecord('System Administrator','Canada');
        Test.startTest();
        Boolean exceptionOccurred = false;
            string exceptionMessage;
        System.runAs(u){
            try{
                insert caseList;
            }
            catch(Exception ex){
                exceptionOccurred = true;
                    exceptionMessage = ex.getMessage();
            }
            
        }
        Test.stopTest();

        System.assertEquals(false, exceptionOccurred, 
            string.format('An unexpected error occurred: {0}', new List<string> {exceptionMessage}));

        List<Case> mdmCases = retrieveMdmChildCases(newCase.Id);
        System.assertEquals(true, mdmCases.isEmpty(), 'No Child case should be created');

        Case updatedCase = [
            SELECT Id, Has_RefLabs_Multiple_Ship_To__c
            FROM Case
            WHERE Id =: newCase.Id];
        
        System.assertEquals(false, updatedCase.Has_RefLabs_Multiple_Ship_To__c);

        shipToAddress = retrieveShipToAddresses(lstAcc[0].Id)[0];
        system.assertEquals(true, shipToAddress.Reference_Labs_Ship_to__c,
            'Reference_Labs_Ship_to__c should be true on the Ship To Address.');
    }

    @isTest
    private static void testAddressLogicForRefsOnboardingBeforeInsertSingleIndirectShipTo(){

        List<Account> lstAcc = new List<Account>{ retrieveAccountByLISOrgCode(ACCOUNT2_ORG_CODE) };
        List<Contact> lstCon = new List<Contact>{retrieveContactByRefLabsContactEmail(CONTACT2_REF_LABS_EMAIL)};

        // Delete Case created in Test Setup and remove making the Account as a Refs Lab Customer
        delete retrieveExistingRefLabsOnboardingCases(lstAcc[0].Id);
        lstAcc[0].Reference_Lab_Customer__c = false;
        lstAcc[0].RefLabs_Existing_Onboarding_Case__c = false;
        update lstAcc;

        String dataRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Data_Request').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();

        Case newCase = ZTS_DataUtilityTest.createCases(1,refLabsOnboardingRecordtypeId)[0];
        newCase.Status = 'New';
        newCase.AccountId = lstAcc[0].Id;
        newCase.ContactId = lstCon[0].Id;
        newCase.Origin = 'Phone';
        newCase.Type = 'Onboarding';
        newCase.Description = 'Manual Onboarding case with ONE INDIRECT Ship to';
        caseList.add(newCase);

        User u = getUserRecord('System Administrator','Canada');
        Test.startTest();
        Boolean exceptionOccurred = false;
            String exceptionMessage;
        System.runAs(u){
            try{
                insert caseList;
            }
            catch(Exception ex){
                exceptionOccurred = true;
                    exceptionMessage = ex.getMessage();
            }
            
        }
        Test.stopTest();

        System.assertEquals(false, exceptionOccurred, 
            string.format('An unexpected error occurred: {0}', new List<string> {exceptionMessage}));

        Case updatedCase = [
            SELECT Id, Status
            FROM Case 
            WHERE Id = :caseList[0].Id];

        System.assertEquals('On Hold', updatedCase.Status, 'The status of the case should be On Hold');
        
        List<Case> mdmCases = retrieveMdmChildCases(caseList[0].Id);
        system.assertEquals(0, mdmCases.size(), 'No MDM Cases should be created for this Case.');
    }

    @isTest
    private static void testAddressLogicForRefsOnboardingBeforeUpdateSingleIndirectShipToBlockUpdate() {
        List<Account> lstAcc = new List<Account>{ retrieveAccountByLISOrgCode(ACCOUNT2_ORG_CODE) };
        Case testCase = retrieveExistingRefLabsOnboardingCases(lstAcc[0].Id)[0];
        testCase.Status = 'In Progress';

        User u = getUserRecord('System Administrator','Canada');
        Test.startTest();
            Boolean exceptionOccurred = false;
            string exceptionMessage;
            System.runAs(u){
                try{
                    update testCase;
                }
                catch(Exception ex){
                    exceptionOccurred = true;
                    exceptionMessage = ex.getMessage();
                }
                
            }
        Test.stopTest();

        System.assertEquals(true, exceptionOccurred,
            'An error should have occurred preventing the Status update from going through.');

        System.assert(exceptionMessage.contains(REFLABS_ONBOARDING_CASE_ON_HOLD_ERROR), String.format(
            'Unexpected error occurred. Expected: {0}. Actual: {1}.', 
            new List<String> {REFLABS_ONBOARDING_CASE_ON_HOLD_ERROR, exceptionMessage}));
    }

    @isTest
    private static void testAddressLogicForRefsOnboardingBeforeUpdateSingleIndirectShipToAllowUpdate() {
        List<Account> lstAcc = new List<Account>{ retrieveAccountByLISOrgCode(ACCOUNT2_ORG_CODE) };

        // Update the Ship To Address to not be indirect so that the Case's Status can change.
        // THe address will now be picked up as the Reference Lab Ship To Address.
        Address__c address = retrieveShipToAddresses(lstAcc[0].Id)[0];
        address.Ship_Indirect__c = 'N';
        update address;
        
        Case testCase = retrieveExistingRefLabsOnboardingCases(lstAcc[0].Id)[0];
        testCase.Status = 'In Progress';

        User u = getUserRecord('System Administrator','Canada');
        Test.startTest();
            Boolean exceptionOccurred = false;
            string exceptionMessage;
            System.runAs(u){
                try{
                    update testCase;
                }
                catch(Exception ex){
                    exceptionOccurred = true;
                    exceptionMessage = ex.getMessage();
                }
                
            }
        Test.stopTest();

        System.assertEquals(false, exceptionOccurred, 
            string.format('An unexpected error occurred: {0}', new List<string> {exceptionMessage}));

        List<Case> mdmCases = retrieveMdmChildCases(testCase.Id);
        System.assertEquals(true, mdmCases.isEmpty(), 'No Child case should be created');

        Case updatedCase = [
            SELECT Id, Has_RefLabs_Multiple_Ship_To__c, Status
            FROM Case
            WHERE Id =: testCase.Id];
            
        System.assertEquals(false, updatedCase.Has_RefLabs_Multiple_Ship_To__c);

        address = retrieveShipToAddresses(lstAcc[0].Id)[0];
        system.assertEquals(true, address.Reference_Labs_Ship_to__c,
            'Reference_Labs_Ship_to__c should be true on the Ship To Address.');
    }

    @isTest
    private static void testAddressLogicForRefsOnboardingBeforeUpdateMultipleShipTosAllowUpdate() {
        List<Account> lstAcc = new List<Account>{ retrieveAccountByLISOrgCode(ACCOUNT3_ORG_CODE) };

        // Setting one of the Addresses as the Reference Labs Ship To will change the Case's Status from On Hold to New.
        Address__c address = retrieveShipToAddresses(lstAcc[0].Id)[0];
        address.Reference_Labs_Ship_to__c = true;
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        update address;
        DispatchTriggerHandler.clearBypass('AddressTriggerHandler');

        Case testCase = retrieveExistingRefLabsOnboardingCases(lstAcc[0].Id)[0];
        testCase.Description = 'Update Description';

        User u = getUserRecord('System Administrator','Canada');
        Test.startTest();
            Boolean exceptionOccurred = false;
            string exceptionMessage;
            System.runAs(u){
                try{
                    update testCase;
                }
                catch(Exception ex){
                    exceptionOccurred = true;
                    exceptionMessage = ex.getMessage();
                }
                
            }
        Test.stopTest();

        System.assertEquals(false, exceptionOccurred, 
            string.format('An unexpected error occurred: {0}', new List<string> {exceptionMessage}));

        Case updatedCase = [
            SELECT Id, Has_RefLabs_Multiple_Ship_To__c, Status
            FROM Case
            WHERE Id =: testCase.Id];
            
        System.assertEquals(false, updatedCase.Has_RefLabs_Multiple_Ship_To__c, 'Has_RefLabs_Multiple_Ship_To__c should be false');
        System.assertEquals('New', updatedCase.Status, 'Case Status should have changed to New');
    }

    @isTest
    private static void testAddressLogicForRefsOnboardingBeforeInsertMultipleCases() {
        Map<String, Account> accountByOrgCode = new Map<String, Account>();
        List<Id> accountIds = new List<Id>();
        for (Account account : retrieveAccountsByLISOrgCode(new List<String> {
                                    ACCOUNT1_ORG_CODE, ACCOUNT2_ORG_CODE, ACCOUNT3_ORG_CODE
                                })) {
            accountByOrgCode.put(account.LIS_Org_Code__c, account);
            accountIds.add(account.Id);
        }

        // Delete existing Cases to avoid errors with inserting new Cases
        delete [
            SELECT Id
            FROM Case
            WHERE AccountId in: accountIds
            AND RecordTypeId =: refLabsOnboardingRecordtypeId
        ];
        
        // Undo any updates to make the Account Ref Labs Accounts 
        for (Account account : accountByOrgCode.values()) {
            account.Reference_Lab_Customer__c = false;
            account.RefLabs_Existing_Onboarding_Case__c = false;
        }
        update accountByOrgCode.values();

        Map<String, Contact> contactsByRefLabsContactEmail = new Map<String, Contact>();
        for (Contact contact : [SELECT Id, RefLabs_Contact_Email__c
                                FROM CONTACT 
                                WHERE RefLabs_Contact_Email__c in: new List<String> {
                                    CONTACT1_REF_LABS_EMAIL, CONTACT2_REF_LABS_EMAIL, CONTACT3_REF_LABS_EMAIL}]) {
            contactsByRefLabsContactEmail.put(contact.RefLabs_Contact_Email__c, contact);
        }
        
        List<Case> testCases = ZTS_DataUtilityTest.createCases(4, refLabsOnboardingRecordtypeId);
        for (Case testCase : testCases) {
            testCase.Status = 'New';
            testCase.Origin = 'Phone';
            testCase.Type = 'Onboarding';
            testCase.Description = 'Existing Case';
        }

        testCases[0].AccountId = accountByOrgCode.get(ACCOUNT1_ORG_CODE).Id;
        testCases[0].ContactId = contactsByRefLabsContactEmail.get(CONTACT1_REF_LABS_EMAIL).Id;
        testCases[1].AccountId = accountByOrgCode.get(ACCOUNT2_ORG_CODE).Id;
        testCases[1].ContactId = contactsByRefLabsContactEmail.get(CONTACT2_REF_LABS_EMAIL).Id;
        testCases[2].AccountId = accountByOrgCode.get(ACCOUNT3_ORG_CODE).Id;
        testCases[2].ContactId = contactsByRefLabsContactEmail.get(CONTACT3_REF_LABS_EMAIL).Id;
        testCases[3].AccountId = accountByOrgCode.get(ACCOUNT1_ORG_CODE).Id;
        testCases[3].ContactId = contactsByRefLabsContactEmail.get(CONTACT1_REF_LABS_EMAIL).Id;

        User u = getUserRecord('System Administrator','Canada');

        Test.startTest();
            Boolean exceptionOccurred = false;
            string exceptionMessage;
            System.runAs(u){
                try{
                    insert testCases;
                }
                catch(Exception ex){
                    exceptionOccurred = true;
                    exceptionMessage = ex.getMessage();
                }
            }
        Test.stopTest();

        System.assertEquals(false, exceptionOccurred, 
            string.format('An unexpected error occurred: {0}', new List<string> {exceptionMessage}));

        for (Case updatedCase : [SELECT Id, Has_RefLabs_Multiple_Ship_To__c, Status
                                 FROM Case
                                 WHERE Id in: testCases]) {
            if (updatedCase.Id == testCases[2].Id ) {
                system.assertEquals(true, updatedCase.Has_RefLabs_Multiple_Ship_To__c);
            }
            else {
                system.assertEquals(false, updatedCase.Has_RefLabs_Multiple_Ship_To__c);
            }

            if (updatedCase.Id != testCases[0].Id && updatedCase.Id != testCases[3].Id) {
                system.assertEquals('On Hold', updatedCase.Status);
            }
            else {
                system.assertNotEquals('On Hold', updatedCase.Status);
            }
        }

        

        for(Address__c shipToAddress : retrieveShipToAddresses(accountIds)) {
            if (shipToAddress.ZTS_EU_Account__c == accountByOrgCode.get(ACCOUNT1_ORG_CODE).Id) {
                system.assertEquals(true, shipToAddress.Reference_Labs_Ship_to__c);
            }
            else {
                system.assertEquals(false, shipToAddress.Reference_Labs_Ship_to__c);
            }
        }
    }

    // This test verifies a User without access to the Address can update the Address.
    @isTest
    private static void testAddressLogicForRefsOnboardingBeforeInsertSingleShipTo_RxServiceUser(){

        List<Account> lstAcc = new List<Account>{ retrieveAccountByLISOrgCode(ACCOUNT1_ORG_CODE) };
        List<Contact> lstCon = new List<Contact>{retrieveContactByRefLabsContactEmail(CONTACT1_REF_LABS_EMAIL)};

        String dataRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Data_Request').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();

        Case newCase = ZTS_DataUtilityTest.createCases(1,refLabsOnboardingRecordtypeId)[0];
        newCase.Status = 'New';
        newCase.AccountId = lstAcc[0].Id;
        newCase.ContactId = lstCon[0].Id;
        newCase.Origin = 'Phone';
        newCase.Type = 'Onboarding';
        newCase.Description = 'Manual Onboarding case with ONE Ship to';
        caseList.add(newCase);

        Address__c shipToAddress = retrieveShipToAddresses(lstAcc[0].Id)[0];
        system.assertEquals(false, shipToAddress.Reference_Labs_Ship_to__c,
            'Sanity check failed. Reference_Labs_Ship_to__c should be false on the Ship To Address.');

        User u = getUserRecord('RX Service','Canada');
        insert u;

        // Create a Share so the User has access to the Account and Contact to avoid other security errros
        AccountShare share = new AccountShare();
        share.AccountId = lstAcc[0].Id;
        share.UserOrGroupId = u.Id;
        share.AccountAccessLevel = 'Edit';
        share.OpportunityAccessLevel = 'None';
        share.CaseAccessLevel = 'None';
        share.ContactAccessLevel = 'Read';
        share.RowCause = 'Manual';
        insert share;

        Test.startTest();
        Boolean exceptionOccurred = false;
            string exceptionMessage;
        System.runAs(u){
            try{
                insert caseList;
            }
            catch(Exception ex){
                exceptionOccurred = true;
                    exceptionMessage = ex.getMessage();
            }
            
        }
        Test.stopTest();

        System.assertEquals(false, exceptionOccurred, 
            string.format('An unexpected error occurred: {0}', new List<string> {exceptionMessage}));

        List<Case> mdmCases = retrieveMdmChildCases(newCase.Id);
        System.assertEquals(true, mdmCases.isEmpty(), 'No Child case should be created');

        Case updatedCase = [
            SELECT Id, Has_RefLabs_Multiple_Ship_To__c
            FROM Case
            WHERE Id =: newCase.Id];

        System.assertEquals(false, updatedCase.Has_RefLabs_Multiple_Ship_To__c);

        shipToAddress = retrieveShipToAddresses(lstAcc[0].Id)[0];
        system.assertEquals(true, shipToAddress.Reference_Labs_Ship_to__c,
            'Reference_Labs_Ship_to__c should be true on the Ship To Address.');
    }

    @isTest
    private static void testAddressLogicForRefsOnboardingBeforeInsertNullAccount(){
        List<Contact> lstCon = new List<Contact>{retrieveContactByRefLabsContactEmail(CONTACTNOACCOUNT_REF_LABS_EMAIL)};

        List<Case> caseList = new List<Case>();
        Case newCase = ZTS_DataUtilityTest.createCases(1,refLabsOnboardingRecordtypeId)[0];
        newCase.Status = 'New';
        newCase.ContactId = lstCon[0].Id;
        newCase.Origin = 'Phone';
        newCase.Type = 'Onboarding';
        newCase.Description = 'Manual Onboarding Case with no Account';
        caseList.add(newCase);
        
        User u = getUserRecord('System Administrator','Canada');
        Test.startTest();
            Boolean exceptionOccurred = false;
            string exceptionMessage;
            System.runAs(u){
        try{
                    insert caseList;
        }
        catch( Exception ex ) {
            exceptionOccurred = true;
                    exceptionMessage = ex.getMessage();
        }
        
    }
        Test.stopTest();

        System.assertEquals(false, exceptionOccurred, 
            string.format('An unexpected error occurred: {0}', new List<string> {exceptionMessage}));

        List<Case> mdmCases = retrieveMdmChildCases(newCase.Id);
        System.assertEquals(true, mdmCases.isEmpty(), 'No Child case should be created');

        Case updatedCase = [
            SELECT Id, Status
            FROM Case
            WHERE Id =: newCase.Id];

        System.assertEquals('On Hold', updatedCase.Status, 'Case Status should be set to On Hold');
    }
    
    @isTest
    private static void testbeforeInsertUpdatePrimaryLabLocation(){

        List<Account> lstAcc = new List<Account>( [SELECT Id,Send_In_Courier__c FROM Account WHERE LIS_Org_Code__c =: ACCOUNT1_ORG_CODE] );
        List<Contact> lstCon = new List<Contact>{retrieveContactByRefLabsContactEmail(CONTACT1_REF_LABS_EMAIL)};

        String dataRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Data_Request').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();

        Case newCase = new Case(Status = 'New',
                                RecordTypeId = refLabsOnboardingRecordtypeId,
                                AccountId = lstAcc[0].Id,
                                ContactId = lstCon[0].Id,
                                Origin = 'Phone',
                                Type = 'Onboarding',
                                Subject = 'Reflabs Test NO Child MDM',
                                Description = 'Manual Onboarding case with ONE Ship to',
                                Courier_Request_Type__c = '',
                                Send_In_Courier__c = 'UPS'
                               );
        caseList.add(newCase);
        User u = getUserRecord('System Administrator','Canada');
        Test.startTest();
        Boolean exceptionOccurred = false;
        System.runAs(u){
            try{
                insert caseList;
            }
            catch(Exception ex){
                exceptionOccurred = true;
            }
            
        }
        Test.stopTest();

        List<Case> mdmCases = [SELECT Id, Subject,status,Send_In_Courier__c,Courier_Request_Type__c, AccountId, ParentId, OwnerId, RecordTypeId FROM Case WHERE Id = :caseList[0].Id];

        //System.assertNotEquals('Closed', mdmCases[0].status , 'Case is in Closed Status');
        //System.assertEquals(true, mdmCases.isEmpty(), 'No Child case should be created');
    }


    @isTest
    private static void testCheckRefLabsContactOnOnboardingCaseClosure(){

        List<Account> lstAcc = new List<Account>{ retrieveAccountByLISOrgCode(ACCOUNT1_ORG_CODE) };
        List<Contact> lstCon = new List<Contact>{retrieveContactByRefLabsContactEmail(CONTACT1_REF_LABS_EMAIL)};

        String dataRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Data_Request').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();

        Case newCase = new Case(Status = 'New',
                                RecordTypeId = refLabsOnboardingRecordtypeId,
                                AccountId = lstAcc[0].Id,
                                ContactId = lstCon[0].Id,
                                Origin = 'Phone',
                                Type = 'Onboarding',
                                Subject = 'Reflabs Test NO Child MDM',
                                Description = 'Manual Onboarding case with ONE Ship to'
                               );
        caseList.add(newCase);
        User u = getUserRecord('System Administrator','Canada');
        Test.startTest();
        Boolean exceptionOccurred = false;
        System.runAs(u){
            try{
                insert caseList;
                caseList[0].Status = 'Closed';
                update caseList;
            }
            catch(Exception ex){
                exceptionOccurred = true;
            }
            
        }
        Test.stopTest();

        System.assertEquals(true, exceptionOccurred, 'Case with no RefLabs contact cannot be closed');
    }
    
    // Test for Case Validations when criteria is not met for Case Event Narrative
    @isTest
    public static void testSendCaseForApprovalInvalidNarrative()
    {
        setBypasses();
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint');
        insert newCase;
        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c();
        prod1.Name = 'Simparica Test';
        prod1.CurrencyIsoCode='USD';        
        prod1.ZTS_US_MAH_Country__c = 'US';
        prod1.ZTS_US_Active_Product__c = 'Yes';
        insert prod1;
        //Insert Case Product Record
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',
                                                                        ZTS_US_Product_problem_type__c = 'Ecotoxicity',
                                                                        ZTS_US_Product_Used_Correctly__c = 'Yes',
                                                                        RecordTypeId = CaseProductRTId);
        insert caseProduct1;

        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                ( ZTS_US_Assessment_PA__c = 'A - Probable/High'
                                                , ZTS_US_Expected_PA__c = 'No'
                                                , RecordTypeId = productAssessmentRTId
                                                , ZTS_US_Case__c = newCase.id
                                                )
                                                , true
                                                );
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                            (new ZTS_US_Assessment_Products__c
                                                            (ZTS_US_Assessment__c = productAssessment.Id
                                                            ,ZTS_US_PVW_Product__c = prod1.id
                                                            ),true
                                                            );

        
        //Insert Contact
        Contact contact = new Contact(
                LastName = 'Doe'
            ,   FirstName = 'Testone'
            ,   ZTS_US_Profession__c = 'Consultant'
            ,   ZTS_US_Job_Function__c = 'Operations');
        insert contact;
        //Insert Case Contact
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id);
        insert caseContact;
        //Insert Breed
        ZTS_US_Breed__c testBreed1 = new ZTS_US_Breed__c(Name = 'Boxer', ZTS_US_Species__c = 'Feline');
        insert testBreed1;
        //Insert Animal
        ZTS_US_Animal__c test_animal = new ZTS_US_Animal__c(Name = 'Tessjyyy'
                                                           ,ZTS_US_Breed__c = testBreed1.Id
                                                           ,ZTS_US_Species__c = 'Feline'
                                                           ,ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID'
                                                           ,ZTS_US_Age_from__c = 6.1
                                                           ,ZTS_US_Age_unit_from__c = 'Day(s)'
                                                           ,ZTS_US_Date_of_Birth__c = date.today()-500);
        insert test_animal;
        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = test_animal.Id );
        insert caseAnimal;
        // newCase.Status = 'Closed';
        //testing - Case validation criteria met
        clearBypasses();
        Boolean expectedExceptionThrown = false;
        Test.startTest();
        try{
            newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
            update newCase;
            
        }catch(Exception ex){            
            expectedExceptionThrown = true;

        }
        Test.stopTest(); 
        System.assertNotEquals(false, expectedExceptionThrown, 'The case shows an error message with missing required validations needed for it to be sent for approval.');        
    }

    @isTest
    static void test_validateRelatedRecordsForApproval_Positive(){
        setBypasses();
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_PVW_Product__c
            (  
                Name = 'VANGUARD PLUS 5/L',
                ZTS_US_MAH_Country__c = 'US',
                ZTS_US_Active_Product__c = 'Yes'
            )
            ,   true
        );

        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Case_Product__c
            (    ZTS_US_Administered_By__c   = 'Other'
                ,    ZTS_US_Dose__c = 5.4
                ,    ZTS_US_Dose_Unit__c = 'Bolus'
                ,    ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                ,    ZTS_US_Product_Used_Correctly__c = 'Yes'
                ,    ZTS_US_Case__c = testCase.id
                ,    ZTS_US_PVW_Product__c = testProduct.id
                ,    ZTS_US_Start_Date__c = date.today()
                ,    ZTS_US_End_Date__c = Date.today()
                ,    RecordTypeId = CaseProductRTId
            )
            ,   true
        );

        ZTS_US_Case_Product__c productTest = [SELECT ID, ZTS_US_Administered_By__c,ZTS_US_Dose__c,
         ZTS_US_Duration__c FROM ZTS_US_Case_Product__c WHERE ZTS_US_Dose__c = 5.4 LIMIT 1
         ];        
        Case caseTest = [SELECT ID, Status, Subject FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Set<String> fieldSet = new Set<String>();
        fieldSet.add('ZTS_US_Administered_By__c');
        fieldSet.add('ZTS_US_Dose__c');
        List<ZTS_US_Case_Product__c> listTestProducts = new List<ZTS_US_Case_Product__c>();
        listTestProducts.add(productTest);
        clearBypasses();
        Test.startTest();
        //SL_CaseTriggerHandler.validateRelatedRecordsForApproval(caseTest, listTestProducts, fieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateRelatedRecordsForApproval(caseTest, listTestProducts, fieldSet, idToCustomErrorMessages);
        List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        Test.stopTest();
        system.debug('validation errors' + validationErrors);
        system.assert(validationErrors == null || validationErrors.isEmpty(), 'We expect that there will be no validation errors on the related Case record');
    }
     @isTest
     static void test_validateRelatedRecordsForApproval_Negative(){
        setBypasses();
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_PVW_Product__c
            (  
                Name = 'VANGUARD PLUS 5/L',
                ZTS_US_MAH_Country__c = 'US',
                ZTS_US_Active_Product__c = 'Yes'
            )
            ,   true
        );
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Case_Product__c
            (    ZTS_US_Administered_By__c   = 'Other'
                ,    ZTS_US_Dose__c = 5.4
                ,    ZTS_US_Dose_Unit__c = 'Bolus'
                ,    ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                ,    ZTS_US_Product_Used_Correctly__c = 'Yes'
                ,    ZTS_US_Case__c = testCase.id
                ,    ZTS_US_PVW_Product__c = testProduct.id
                ,    ZTS_US_Start_Date__c= date.today()
                ,    ZTS_US_End_Date__c = Date.today()
                ,    RecordTypeId = CaseProductRTId
            )
            ,   true
        );

        ZTS_US_Case_Product__c productTest = [SELECT ID, ZTS_US_Administered_By__c, ZTS_US_Dose__c,
         ZTS_US_Duration__c, ZTS_US_Reason_for_use__c FROM ZTS_US_Case_Product__c WHERE ZTS_US_Dose__c = 5.4 LIMIT 1
         ];        
        Case caseTest = [SELECT ID, Status, Subject FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Set<String> fieldSet = new Set<String>();
        fieldSet.add('ZTS_US_Administered_By__c');
        fieldSet.add('ZTS_US_Dose__c');
        fieldSet.add('ZTS_US_Duration__c');
        fieldSet.add('ZTS_US_Reason_for_use__c');
        List<ZTS_US_Case_Product__c> listTestProducts = new List<ZTS_US_Case_Product__c>();
        listTestProducts.add(productTest);
        clearBypasses();
        Test.startTest();
        //SL_CaseTriggerHandler.validateRelatedRecordsForApproval(caseTest, listTestProducts, fieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateRelatedRecordsForApproval(caseTest, listTestProducts, fieldSet, idToCustomErrorMessages);
        //List<Database.Error> validationErrors = caseTest.getErrors();
        List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        Test.stopTest();
        system.debug('validation errors' + validationErrors);
        system.assert(!validationErrors.isEmpty(), 'We expect that there will be a validation error on the related Case record that will be added due to it having a null value for one of the fields in the field set');
     }

     @isTest
     static void test_validateCaseAnimalAndAnimalRecordsForApproval_Positive(){

        //Animal object and test Case for testing validateRelatedRecordsForApproval
        ZTS_US_Breed__c testBreed = (ZTS_US_Breed__c) SL_TestDataFactory.createSObject
        (    new ZTS_US_Breed__c
            (   Name = 'Boxer'
                ,  ZTS_US_Species__c = 'Canine'
            )
            ,    true
        );

        ZTS_US_Animal__c testAnimal = (ZTS_US_Animal__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Animal__c
            (    ZTS_US_Herd__c = true
                ,    ZTS_US_Reproductive_Status__c = 'Neutered'
                ,    ZTS_US_Breed__c = testBreed.Id
                ,    ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID'
                ,    ZTS_US_Species__c = 'Canine'
                ,    ZTS_US_Age_from__c = 6.1
                , ZTS_US_Age_unit_from__c = 'Day(s)'
            
                ,    ZTS_US_Date_of_Birth__c = date.today()-500
            )
            ,   true
        );

        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;

        ZTS_US_Case_Animal__c caseAnimal = (ZTS_US_Case_Animal__c) SL_TestDataFactory.createSObject( new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = testAnimal.Id), true);

        ZTS_US_Animal__c animalTest = [SELECT ID, ZTS_US_Age_from__c,ZTS_US_Age_unit_from__c,
                                        ZTS_US_Age_text__c,Age_units__c,ZTS_US_Herd__c, ZTS_US_Reacted__c, ZTS_US_Reproductive_Status__c 
                                        FROM ZTS_US_Animal__c WHERE ZTS_US_Reproductive_Status__c = 'Neutered' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Id caseTestId = caseTest.id;
        Id animalTestId = animalTest.id;
        ZTS_US_Case_Animal__c caseAnimalTest = [SELECT ID, ZTS_US_Animal__c, ZTS_US_Age_from__c,ZTS_US_Age_unit_from__c,
                                                ZTS_US_Age_text__c,Age_units__c,ZTS_US_Case__c, RecordType.DeveloperName 
                                                FROM  ZTS_US_Case_Animal__c WHERE ZTS_US_Case__c = :caseTestId];
        caseAnimalTest.ZTS_US_Age_text__c=4;
        Set<String> animalFieldSet = new Set<String>();
        animalFieldSet.add('ZTS_US_Herd__c');
        animalFieldSet.add('ZTS_US_Reproductive_Status__c');
        Set<String> caseAnimalFieldSet = new Set<String>();
        caseAnimalFieldSet.add('ZTS_US_Age_text__c');
        Map<Id, ZTS_US_Animal__c> mapTestAnimals = new Map<Id, ZTS_US_Animal__c>();
        mapTestAnimals.put(animalTestId, animalTest);
        List<ZTS_US_Case_Animal__c> listTestCaseAnimals = new List<ZTS_US_Case_Animal__c>();
        listTestCaseAnimals.add(caseAnimalTest);
        //SL_CaseTriggerHandler.validateAnimalRecordsForApproval(caseTest, listTestCaseAnimals, mapTestAnimals, animalFieldSet, caseAnimalFieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateAnimalRecordsForApproval(caseTest, listTestCaseAnimals, mapTestAnimals, animalFieldSet, caseAnimalFieldSet,idToCustomErrorMessages);
         List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        system.debug('validation errors' + validationErrors);
        system.assert(validationErrors== null || validationErrors.isEmpty(), 'We expect that there will be no validation errors on the related Case record');

     }
     @isTest
     static void test_validateAnimalRecordsForApproval_Negative(){

        //Animal object and test Case for testing validateRelatedRecordsForApproval
        ZTS_US_Breed__c testBreed = (ZTS_US_Breed__c) SL_TestDataFactory.createSObject
        (    new ZTS_US_Breed__c
            (   Name = 'Boxer'
                ,  ZTS_US_Species__c = 'Canine'
            )
            ,    true
        );

        ZTS_US_Animal__c testAnimal = (ZTS_US_Animal__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Animal__c
            (    ZTS_US_Herd__c = true
                ,    ZTS_US_Reproductive_Status__c = 'Neutered'
                ,    ZTS_US_Breed__c = testBreed.Id
                ,    ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID'
                ,    ZTS_US_Species__c = 'Canine'
                ,    ZTS_US_Age_from__c = 6.1
                , ZTS_US_Age_unit_from__c = 'Day(s)'
                ,    ZTS_US_Date_of_Birth__c = date.today()-500
            )
            ,   true
        );

        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;

        ZTS_US_Case_Animal__c caseAnimal = (ZTS_US_Case_Animal__c) SL_TestDataFactory.createSObject( new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = testAnimal.Id ), true);

        final String MISSING_REQUIRED_FIELD_ON_RELATED_RECORD = 'record is missing data';
        ZTS_US_Animal__c animalTest = [SELECT ID, ZTS_US_Age_from__c,ZTS_US_Age_unit_from__c,
                                        ZTS_US_Age_text__c,Age_units__c,ZTS_US_Herd__c, ZTS_US_Reacted__c, ZTS_US_Reproductive_Status__c 
                                        FROM ZTS_US_Animal__c WHERE ZTS_US_Reproductive_Status__c = 'Neutered' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Id caseTestId = caseTest.id;
        Id animalTestId = animalTest.id;
        ZTS_US_Case_Animal__c caseAnimalTest = [SELECT ID, ZTS_US_Animal__c, ZTS_US_Age_from__c,ZTS_US_Age_unit_from__c,
                                                        ZTS_US_Age_text__c,Age_units__c,ZTS_US_Case__c, RecordType.DeveloperName 
                                                        FROM  ZTS_US_Case_Animal__c WHERE ZTS_US_Case__c = :caseTestId];
        caseAnimalTest.ZTS_US_Age_text__c=4;
        Set<String> animalFieldSet = new Set<String>();
        animalFieldSet.add('ZTS_US_Herd__c');
        animalFieldSet.add('ZTS_US_Reacted__c');
        animalFieldSet.add('ZTS_US_Reproductive_Status__c');
        Set<String> caseAnimalFieldSet = new Set<String>();
        caseAnimalFieldSet.add('ZTS_US_Age_text__c');
        Map<Id, ZTS_US_Animal__c> mapTestAnimals = new Map<Id, ZTS_US_Animal__c>();
        mapTestAnimals.put(animalTestId, animalTest);
        List<ZTS_US_Case_Animal__c> listTestCaseAnimals = new List<ZTS_US_Case_Animal__c>();
        listTestCaseAnimals.add(caseAnimalTest);
        //SL_CaseTriggerHandler.validateAnimalRecordsForApproval(caseTest, listTestCaseAnimals, mapTestAnimals, animalFieldSet,caseAnimalFieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateAnimalRecordsForApproval(caseTest, listTestCaseAnimals, mapTestAnimals, animalFieldSet,caseAnimalFieldSet,idToCustomErrorMessages);      
        //List<String> validationErrors = VmipsCaseService.idToCustomErrorMessages.get(caseTest.Id);
         List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        system.debug('validation errors' + validationErrors);
        system.assert(!validationErrors.isEmpty(), 'We expect that there will be a validation error on the related Case record that will be added due to it having a null value for one of the fields in the field set');
     }
     @isTest
     static void test_validateCaseAnimalRecordsForApproval_Negative(){

        //Animal object and test Case for testing validateRelatedRecordsForApproval
        ZTS_US_Breed__c testBreed = (ZTS_US_Breed__c) SL_TestDataFactory.createSObject
        (    new ZTS_US_Breed__c
            (   Name = 'Boxer'
                ,  ZTS_US_Species__c = 'Canine'
            )
            ,    true
        );

        ZTS_US_Animal__c testAnimal = (ZTS_US_Animal__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Animal__c
            (    ZTS_US_Herd__c = true
                ,    ZTS_US_Reproductive_Status__c = 'Neutered'
                ,    ZTS_US_Breed__c = testBreed.Id
                ,    ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID'
                ,    ZTS_US_Species__c = 'Canine'
                ,    ZTS_US_Age_from__c = 6.1
                , ZTS_US_Age_unit_from__c = 'Day(s)'
                ,    ZTS_US_Date_of_Birth__c = date.today()-500
            )
            ,   true
        );

        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;

        ZTS_US_Case_Animal__c caseAnimal = (ZTS_US_Case_Animal__c) SL_TestDataFactory.createSObject( new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = testAnimal.Id ), true);

        final String MISSING_REQUIRED_FIELD_ON_RELATED_RECORD = 'record is missing data';
        ZTS_US_Animal__c animalTest = [SELECT ID, ZTS_US_Age_from__c,ZTS_US_Age_unit_from__c,
                                        ZTS_US_Age_text__c,Age_units__c,ZTS_US_Herd__c, ZTS_US_Reacted__c, ZTS_US_Reproductive_Status__c 
                                        FROM ZTS_US_Animal__c WHERE ZTS_US_Reproductive_Status__c = 'Neutered' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Id caseTestId = caseTest.id;
        Id animalTestId = animalTest.id;
        ZTS_US_Case_Animal__c caseAnimalTest = [SELECT ID, ZTS_US_Animal__c, ZTS_US_Age_from__c,ZTS_US_Age_unit_from__c,
                                                ZTS_US_Age_text__c,Age_units__c,ZTS_US_Case__c, RecordType.DeveloperName 
                                                FROM  ZTS_US_Case_Animal__c WHERE ZTS_US_Case__c = :caseTestId];
        Set<String> animalFieldSet = new Set<String>();
        animalFieldSet.add('ZTS_US_Herd__c');
        animalFieldSet.add('ZTS_US_Reacted__c');
        animalFieldSet.add('ZTS_US_Reproductive_Status__c');

        Set<String> caseAnimalFieldSet = new Set<String>();
        caseAnimalFieldSet.add('ZTS_US_Age_text__c');
        Map<Id, ZTS_US_Animal__c> mapTestAnimals = new Map<Id, ZTS_US_Animal__c>();
        mapTestAnimals.put(animalTestId, animalTest);
        List<ZTS_US_Case_Animal__c> listTestCaseAnimals = new List<ZTS_US_Case_Animal__c>();
        listTestCaseAnimals.add(caseAnimalTest);
        //SL_CaseTriggerHandler.validateAnimalRecordsForApproval(caseTest, listTestCaseAnimals, mapTestAnimals, animalFieldSet,caseAnimalFieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateAnimalRecordsForApproval(caseTest, listTestCaseAnimals, mapTestAnimals, animalFieldSet,caseAnimalFieldSet,idToCustomErrorMessages);
        //List<Database.Error> validationErrors = caseTest.getErrors();
         List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        system.debug('validation errors' + validationErrors);
        system.assert(!validationErrors.isEmpty(), 'We expect that there will be a validation error on the related Case record that will be added due to it having a null value for one of the fields in the field set');
     }
    @isTest
    static void test_validateContactEmailForApproval_Positive(){
		Contact testContact = (Contact) SL_TestDataFactory.createSObject
        (   new Contact
            (    ZTS_US_Institution__c = 'Purdue University'
                ,    Title = 'Test'
                ,    ZTS_US_Account_influence__c    = 'Decision Maker'
                ,    ZTS_US_Profession__c = 'Consultant'
                ,    ZTS_US_Job_Function__c = 'Operations'
                ,    Interface_Email__c  = 'test@zoetis.com'
                
            )
            ,   true
        );
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId, 
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;
        
        Case_Contact__c caseContact = (Case_Contact__c) SL_TestDataFactory.createSObject( new Case_Contact__c(Case__c = testCase.Id, Contact__c = testContact.Id ), true);
        caseContact.ZTS_US_Primary_Reporter__c = true ;
        update caseContact;
        Contact contactTest = [SELECT ID, ZTS_US_Institution__c, Title, Name, MailingCountry,Interface_Email__c, VMIPS_Mailing_Country__c, ZTS_EU_Market__c FROM Contact WHERE Title = 'Test' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject,ZTS_US_Do_Not_Notify_Reporter__c FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Id caseTestId = caseTest.id;
        Id contactTestId = contactTest.id;
        Case_Contact__c caseContactTest = [SELECT ID, Contact__c, Email__c, ZTS_US_Primary_Reporter__c,Case__c FROM Case_Contact__c WHERE Case__c = :caseTestId LIMIT 1];
        Set<String> fieldSet = new Set<String>{'ZTS_US_Institution__c', 'Title'};
        Map<Id, Contact> mapTestContacts = new Map<Id, Contact>();
        mapTestContacts.put(contactTestId, contactTest);
        List<Case_Contact__c> listTestCaseContacts = new List<Case_Contact__c>();
        listTestCaseContacts.add(caseContactTest);
        //SL_CaseTriggerHandler.validateContactRecordsForApproval(caseTest, listTestCaseContacts, mapTestContacts, fieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateContactRecordsForApproval(caseTest, listTestCaseContacts, mapTestContacts, fieldSet,idToCustomErrorMessages);
        List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        system.assert(validationErrors== null || validationErrors.isEmpty(), 'We expect that there will be no validation error on the related Case record that will be added due to it having a null value for one of the fields in the field set');
    }
    @isTest
    static void test_validateContactEmailForApproval_Negative(){
		Contact testContact = (Contact) SL_TestDataFactory.createSObject
        (   new Contact
            (    ZTS_US_Institution__c = 'Purdue University'
                ,    Title = 'Test'
                ,    ZTS_US_Account_influence__c    = 'Decision Maker'
                ,    ZTS_US_Profession__c = 'Consultant'
                ,    ZTS_US_Job_Function__c = 'Operations'
                
            )
            ,   true
        );
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId, 
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;
        
        Case_Contact__c caseContact = (Case_Contact__c) SL_TestDataFactory.createSObject( new Case_Contact__c(Case__c = testCase.Id, Contact__c = testContact.Id ), true);
        caseContact.ZTS_US_Primary_Reporter__c = true ;
        update caseContact;
        Contact contactTest = [SELECT ID, ZTS_US_Institution__c, Title, Name, MailingCountry,Interface_Email__c, VMIPS_Mailing_Country__c, ZTS_EU_Market__c FROM Contact WHERE Title = 'Test' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject,ZTS_US_Do_Not_Notify_Reporter__c FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Id caseTestId = caseTest.id;
        Id contactTestId = contactTest.id;
        Case_Contact__c caseContactTest = [SELECT ID, Contact__c, Email__c, ZTS_US_Primary_Reporter__c,Case__c FROM Case_Contact__c WHERE Case__c = :caseTestId LIMIT 1];
        Set<String> fieldSet = new Set<String>{'ZTS_US_Institution__c', 'Title'};
        Map<Id, Contact> mapTestContacts = new Map<Id, Contact>();
        mapTestContacts.put(contactTestId, contactTest);
        List<Case_Contact__c> listTestCaseContacts = new List<Case_Contact__c>();
        listTestCaseContacts.add(caseContactTest);
        //SL_CaseTriggerHandler.validateContactRecordsForApproval(caseTest, listTestCaseContacts, mapTestContacts, fieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateContactRecordsForApproval(caseTest, listTestCaseContacts, mapTestContacts, fieldSet,idToCustomErrorMessages);
        //List<Database.Error> validationErrors = caseTest.getErrors();
        List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        system.assert(!validationErrors.isEmpty(), 'We expect that there will be a validation error on the related Case record that will be added due to it having a null value for one of the fields in the field set');
    }
     @isTest
     static void test_validateContactRecordsForApproval_Positive(){

        //Test contact for contact specific logic tests
        Contact testContact = (Contact) SL_TestDataFactory.createSObject
        (   new Contact
            (    ZTS_US_Institution__c = 'Purdue University'
                ,    Title = 'Test'
                ,    ZTS_US_Account_influence__c    = 'Decision Maker'
                ,    ZTS_US_Profession__c = 'Consultant'
                ,    ZTS_US_Job_Function__c = 'Operations'
            )
            ,   true
        );

        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId, 
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;

        Case_Contact__c caseContact = (Case_Contact__c) SL_TestDataFactory.createSObject( new Case_Contact__c(Case__c = testCase.Id, Contact__c = testContact.Id ), true);

        final String MISSING_REQUIRED_FIELD_ON_RELATED_RECORD = 'record is missing data';
        Contact contactTest = [SELECT ID, ZTS_US_Institution__c, Title, Name, MailingCountry, VMIPS_Mailing_Country__c, ZTS_EU_Market__c FROM Contact WHERE Title = 'Test' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Id caseTestId = caseTest.id;
        Id contactTestId = contactTest.id;
        Case_Contact__c caseContactTest = [SELECT ID, Contact__c, Email__c, ZTS_US_Primary_Reporter__c,Case__c FROM Case_Contact__c WHERE Case__c = :caseTestId LIMIT 1];
        Set<String> fieldSet = new Set<String>{'ZTS_US_Institution__c', 'Title'};
        Map<Id, Contact> mapTestContacts = new Map<Id, Contact>();
        mapTestContacts.put(contactTestId, contactTest);
        List<Case_Contact__c> listTestCaseContacts = new List<Case_Contact__c>();
        listTestCaseContacts.add(caseContactTest);
        //SL_CaseTriggerHandler.validateContactRecordsForApproval(caseTest, listTestCaseContacts, mapTestContacts, fieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateContactRecordsForApproval(caseTest, listTestCaseContacts, mapTestContacts, fieldSet,idToCustomErrorMessages);
         List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        system.debug('validation errors' + validationErrors);
        system.assert(validationErrors== null || validationErrors.isEmpty(), 'We expect that there will be no validation errors on the related Case record');
     }
    
    //Test Method for Contact Regex check ASCII
     @isTest
     static void test_validateContactRecordsForApproval_Regex(){

        //Test contact for contact specific logic tests
        Contact testContact = (Contact) SL_TestDataFactory.createSObject
        (   new Contact
            (    ZTS_US_Institution__c = 'Purdue University'
                ,    Title = 'Test'
                ,    ZTS_US_Account_influence__c    = 'Decision Maker'
                ,    ZTS_US_Profession__c = 'Consultant'
                ,    ZTS_US_Job_Function__c = 'Operations'
            )
            ,   true
        );
        testContact.MailingCity ='.??';
        testContact.VMIPS_Mailing_Country__c = 'United States';
        testContact.MailingStreet = '100 Main St';
        testContact.MailingState = 'MA';
        testContact.MailingPostalCode ='02132';
        testContact.ZTS_EU_Market__c = 'United States';

        update testContact;
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId, 
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;

        Case_Contact__c caseContact = (Case_Contact__c) SL_TestDataFactory.createSObject( new Case_Contact__c(Case__c = testCase.Id, Contact__c = testContact.Id ), true);
        final String CONTACT_ADDRESS_REGEX_ERROR = 'Contact Mailing Address cannot have special characters.';

        Contact contactTest = [SELECT ID, ZTS_US_Institution__c, Title,MailingStreet, MailingCity, MailingPostalCode, MailingState,  MailingCountry, VMIPS_Mailing_Country__c, ZTS_EU_Market__c, Gender__c FROM Contact WHERE Title = 'Test' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Id caseTestId = caseTest.id;
        Id contactTestId = contactTest.id;
        Case_Contact__c caseContactTest = [SELECT ID, Contact__c, Email__c, ZTS_US_Primary_Reporter__c,Case__c FROM Case_Contact__c WHERE Case__c = :caseTestId LIMIT 1];
        Set<String> fieldSet = new Set<String>{'ZTS_US_Institution__c', 'Title', 'Gender__c'};
        Map<Id, Contact> mapTestContacts = new Map<Id, Contact>();
        mapTestContacts.put(contactTestId, contactTest);
        List<Case_Contact__c> listTestCaseContacts = new List<Case_Contact__c>();
        listTestCaseContacts.add(caseContactTest);
        //SL_CaseTriggerHandler.validateContactRecordsForApproval(caseTest, listTestCaseContacts, mapTestContacts, fieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateContactRecordsForApproval(caseTest, listTestCaseContacts, mapTestContacts, fieldSet,idToCustomErrorMessages);
        //List<Database.Error> validationErrors = caseTest.getErrors();
        List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        system.debug('validation errors' + validationErrors);
        system.assert(!validationErrors.isEmpty(), 'We expect that there will be a validation error on the related Case record that will be added due to it having a ASCII Character.');
     }
     @isTest
     static void test_validateContactRecordsForApproval_Negative(){

        //Test contact for contact specific logic tests
        Contact testContact = (Contact) SL_TestDataFactory.createSObject
        (   new Contact
            (    ZTS_US_Institution__c = 'Purdue University'
                ,    Title = 'Test'
                ,    ZTS_US_Account_influence__c    = 'Decision Maker'
                ,    ZTS_US_Profession__c = 'Consultant'
                ,    ZTS_US_Job_Function__c = 'Operations'
            )
            ,   true
        );
        testContact.VMIPS_Mailing_Country__c = 'United States';
        testContact.ZTS_EU_Market__c = 'United States';
        testContact.MailingCity = 'Boston';
        testContact.MailingStreet = '100 Main St';
        testContact.MailingState = 'MA';
        testContact.MailingPostalCode ='02132';

        update testContact;

        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId, 
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
        ( new ZTS_US_PVW_Product__c
        (
        Name = 'FLU DETECT SWINE',
        ZTS_US_Product_Category__c = 'DIAG',
        ZTS_US_MAH_Country__c = 'US',
        ZTS_US_Active_Product__c = 'Yes'
        )
        , true
        );

        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct =    (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Product_Agency__c = 'USDA'
                                                , ZTS_US_Case__c = testCase.Id
                                                , ZTS_US_PVW_Product__c = testProduct.id
                                                , ZTS_US_Start_Date__c = date.today()
                                                , ZTS_US_End_Date__c = date.today()
                                                , RecordTypeId = CaseProductRTId
                                                )
                                                , true
                                                );

        Case_Contact__c caseContact = (Case_Contact__c) SL_TestDataFactory.createSObject( new Case_Contact__c(Case__c = testCase.Id, Contact__c = testContact.Id ), true);
        final String MISSING_REQUIRED_FIELD_ON_RELATED_RECORD = 'record is missing data';
        Contact contactTest = [SELECT ID, ZTS_US_Institution__c, Title,MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry, VMIPS_Mailing_Country__c, ZTS_EU_Market__c, Gender__c FROM Contact WHERE Title = 'Test' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Id caseTestId = caseTest.id;
        Id contactTestId = contactTest.id;
        Case_Contact__c caseContactTest = [SELECT ID, Contact__c, Email__c,ZTS_US_Primary_Reporter__c, Case__c FROM Case_Contact__c WHERE Case__c = :caseTestId LIMIT 1];
        Set<String> fieldSet = new Set<String>{'ZTS_US_Institution__c', 'Title', 'Gender__c', 'MailingCountry'};
        Map<Id, Contact> mapTestContacts = new Map<Id, Contact>();
        mapTestContacts.put(contactTestId, contactTest);
        List<Case_Contact__c> listTestCaseContacts = new List<Case_Contact__c>();
        listTestCaseContacts.add(caseContactTest);
        //SL_CaseTriggerHandler.validateContactRecordsForApproval(caseTest, listTestCaseContacts, mapTestContacts, fieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateContactRecordsForApproval(caseTest, listTestCaseContacts, mapTestContacts, fieldSet, idToCustomErrorMessages);
        //List<Database.Error> validationErrors = caseTest.getErrors();
        List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        system.debug('validation errors' + validationErrors);
        system.assert(!validationErrors.isEmpty(), 'We expect that there will be a validation error on the related Case record that will be added due to it having a null value for one of the fields in the field set');
     }
     @isTest
     static void test_validateVeddraRecordsForApproval_Positive(){
        setBypasses();
        //Event Narrative & Veddra for Veddra test
        ZTS_US_Event_Narrative__c testEventNarrative = (ZTS_US_Event_Narrative__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Event_Narrative__c
            (    ZTS_US_Duration_text__c = 'test'
            )
            ,   true
        );

        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred',
                            ZTS_US_Event_Narrative__c = testEventNarrative.Id
                            );
        insert testCase;

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
        ( new ZTS_US_PVW_Product__c
        (
        Name = 'FLU DETECT SWINE',
        ZTS_US_Product_Category__c = 'DIAG',
        ZTS_US_MAH_Country__c = 'US',
        ZTS_US_Active_Product__c = 'Yes'
        )
        , true
        );

        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct =    (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Product_Agency__c = 'USDA'
                                                , ZTS_US_Case__c = testCase.Id
                                                , ZTS_US_PVW_Product__c = testProduct.id
                                                , ZTS_US_Start_Date__c = date.today()
                                                , ZTS_US_End_Date__c = date.today()
                                                , RecordTypeId = CaseProductRTId
                                                )
                                                , true
                                                );

        ZTS_US_VedDRA_Event__c testVedDRA = (ZTS_US_VedDRA_Event__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_VedDRA_Event__c
            (    ZTS_US_Event_Narrative__c   = testEventNarrative.id
                ,    Duration_Units__c = 'Hour(s)'
                ,    ZTS_US_End_Date__c = date.today(),
                     ZTS_US_Start_Date__c = Date.today()
            )
            ,   true
        );

        final String MISSING_REQUIRED_FIELD_ON_RELATED_RECORD = 'record is missing data';
        ZTS_US_VedDRA_Event__c testVeddraEvent = [SELECT ID, Name, ZTS_US_Event_Narrative__c, Duration_Units__c, ZTS_US_Number_of_pts_affected__c FROM ZTS_US_VedDRA_Event__c WHERE Duration_Units__c = 'Hour(s)' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject, ZTS_US_Event_Narrative__c FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Id caseTestId = caseTest.id;
        ZTS_US_Event_Narrative__c eventNarrativeTest = [SELECT ID FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Duration_text__c = 'test' LIMIT 1];
        Id eventNarrativeTestId = eventNarrativeTest.id;
        List<ZTS_US_VedDRA_Event__c> listTestVeddraEvents = new List<ZTS_US_VedDRA_Event__c>();
        listTestVeddraEvents.add(testVeddraEvent);
        Map<Id, List<ZTS_US_VedDRA_Event__c>> narrativeToVeddraEvents = new Map<Id, List<ZTS_US_VedDRA_Event__c>>();
        narrativeToVeddraEvents.put(eventNarrativeTestId, listTestVeddraEvents);
        Set<String> fieldSet = new Set<String>{'Duration_Units__c'};
        clearBypasses();
        Test.startTest();
        //SL_CaseTriggerHandler.validateVeddraRecordsForApproval(caseTest, narrativeToVeddraEvents, fieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateVeddraRecordsForApproval(caseTest, narrativeToVeddraEvents, fieldSet,idToCustomErrorMessages);
        List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        test.stopTest();
        system.debug('validation errors' + validationErrors);
        system.assert(validationErrors== null || validationErrors.isEmpty(), 'We expect that there will be no validation errors on the related Case record');
     }
     @isTest
     static void test_validateVeddraRecordsForApproval_Negative(){
        
        //Event Narrative & Veddra for Veddra test
        ZTS_US_Event_Narrative__c testEventNarrative = (ZTS_US_Event_Narrative__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Event_Narrative__c
            (    ZTS_US_Duration_text__c = 'test'
            )
            ,   true
        );


        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred',
                            ZTS_US_Event_Narrative__c = testEventNarrative.Id
                            );
        insert testCase;
        ZTS_US_PVW_Product__c prod = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        insert prod;      
        ZTS_US_Case_Product__c caseProduct = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert caseProduct;

        ZTS_US_VedDRA_Event__c testVedDRA = (ZTS_US_VedDRA_Event__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_VedDRA_Event__c
            (    ZTS_US_Event_Narrative__c   = testEventNarrative.id
                ,    Duration_Units__c = 'Hour(s)'
                ,    ZTS_US_End_Date__c = date.today(), 
                     ZTS_US_Start_Date__c = Date.today()
            )
            ,   true
        );

        final String MISSING_REQUIRED_FIELD_ON_RELATED_RECORD = 'record is missing data';
        ZTS_US_VedDRA_Event__c testVeddraEvent = [SELECT ID, Name, ZTS_US_Event_Narrative__c, Duration_Units__c, ZTS_US_Number_of_pts_affected__c FROM ZTS_US_VedDRA_Event__c WHERE Duration_Units__c = 'Hour(s)' LIMIT 1];
        Case caseTest = [SELECT ID, Status, Subject, ZTS_US_Event_Narrative__c FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Id caseTestId = caseTest.id;
        ZTS_US_Event_Narrative__c eventNarrativeTest = [SELECT ID FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Duration_text__c = 'test' LIMIT 1];
        Id eventNarrativeTestId = eventNarrativeTest.id;
        List<ZTS_US_VedDRA_Event__c> listTestVeddraEvents = new List<ZTS_US_VedDRA_Event__c>();
        listTestVeddraEvents.add(testVeddraEvent);
        Map<Id, List<ZTS_US_VedDRA_Event__c>> narrativeToVeddraEvents = new Map<Id, List<ZTS_US_VedDRA_Event__c>>();
        narrativeToVeddraEvents.put(eventNarrativeTestId, listTestVeddraEvents);
        Set<String> fieldSet = new Set<String>{'Duration_Units__c', 'ZTS_US_Number_of_pts_affected__c'};
        //SL_CaseTriggerHandler.validateVeddraRecordsForApproval(caseTest, narrativeToVeddraEvents, fieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateVeddraRecordsForApproval(caseTest, narrativeToVeddraEvents, fieldSet,idToCustomErrorMessages);   
        //List<Database.Error> validationErrors = caseTest.getErrors();
        List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        system.debug('validation errors' + validationErrors);
        system.assert(!validationErrors.isEmpty(), 'We expect that there will be a validation error on the related Case record that will be added due to it having a null value for one of the fields in the field set');
     }
    
    @isTest
    static void test_validateCaseFieldsForApproval_Positive(){

        //Event Narrative & Veddra for Veddra test
        ZTS_US_Event_Narrative__c testEventNarrative = (ZTS_US_Event_Narrative__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Event_Narrative__c
            (    ZTS_US_Duration_text__c = 'test'
            )
            ,   true
        );

        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred',
                            ZTS_US_Event_Narrative__c = testEventNarrative.Id
                            );
        insert testCase;
        final String MISSING_REQUIRED_FIELD = 'Case is missing data';
        Case caseTest = [SELECT ID, Status, Subject, ZTS_US_Event_Narrative__c, ZTS_US_Information_Type__c FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Set<String> fieldSet = new Set<String>{'ZTS_US_Event_Narrative__c', 'ZTS_US_Information_Type__c'};
        //SL_CaseTriggerHandler.validateCaseFieldsForApproval(caseTest, fieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateCaseFieldsForApproval(caseTest, fieldSet,idToCustomErrorMessages);
         List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        system.debug('validation errors' + validationErrors);
        system.assert(validationErrors== null || validationErrors.isEmpty(), 'We expect that there will be no validation errors on the Case object');

    }
     @isTest
     static void test_validateCaseFieldsForApproval_Negative(){
         //Event Narrative & Veddra for Veddra test
        ZTS_US_Event_Narrative__c testEventNarrative = (ZTS_US_Event_Narrative__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Event_Narrative__c
            (    ZTS_US_Duration_text__c = 'test'
            )
            ,   true
        );

        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred',
                            ZTS_US_Event_Narrative__c = testEventNarrative.Id
                            );
        insert testCase;

        final String MISSING_REQUIRED_FIELD = 'Case is missing data';
        Case caseTest = [SELECT ID, Status, Subject, ZTS_US_Event_Narrative__c, ZTS_US_Information_Type__c, ZTS_US_Date_First_Valid__c FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Set<String> fieldSet = new Set<String>{'ZTS_US_Event_Narrative__c', 'ZTS_US_Information_Type__c', 'ZTS_US_Date_First_Valid__c'};
        //SL_CaseTriggerHandler.validateCaseFieldsForApproval(caseTest, fieldSet);
        Map<Id, List<String>> idToCustomErrorMessages = new Map<Id, List<String>>();
        VmipsCaseService.validateCaseFieldsForApproval(caseTest, fieldSet,idToCustomErrorMessages);
         List<String> validationErrors = idToCustomErrorMessages.get(caseTest.Id);
        system.debug('validation errors' + validationErrors);
        system.assert(!validationErrors.isEmpty(), 'We expect that there will be a validation error on the Case object because it has no value for the Date First Valid field');
     }
     //This method is used in Validate the Reportability field test methods 
    public static void makeData(){
        //Case Animal created is mandatory to create Case Products
        ZTS_US_Breed__c testBreed = (ZTS_US_Breed__c) SL_TestDataFactory.createSObject
        (    new ZTS_US_Breed__c
            (   Name = 'Boxer'
                ,  ZTS_US_Species__c = 'Canine'
            )
            ,    true
        );
        ZTS_US_Animal__c testAnimal = (ZTS_US_Animal__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Animal__c
            (    ZTS_US_Herd__c = true
                ,ZTS_US_Reproductive_Status__c = 'Neutered'
                ,ZTS_US_Breed__c = testBreed.Id
                ,ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID'
                ,ZTS_US_Species__c = 'Canine'
                ,ZTS_US_Age_from__c = 6.1
                ,ZTS_US_Age_unit_from__c = 'Day(s)'
                ,ZTS_US_Weight__c = 9
                ,ZTS_US_Weight_units__c = 'Grams'
                ,ZTS_US_Date_of_Birth__c = date.today()-500
            )
            ,   true
        );
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred'
                            );
        insert testCase;

        ZTS_US_Case_Animal__c caseAnimal = (ZTS_US_Case_Animal__c) SL_TestDataFactory.createSObject( new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = testAnimal.Id ), true);
    }
    @isTest
    static void test_validateReportability_Positive(){
        makeData();
        List<Case> caseList = [SELECT id from Case LIMIT 1];

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                            (
                                            Name = 'FLU DETECT SWINE',
                                            ZTS_US_Product_Category__c = 'DIAG',
                                            ZTS_US_MAH_Country__c = 'US',
                                            ZTS_US_Active_Product__c = 'Yes'
                                            )
                                            , true
                                            );

        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct =    (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Product_Agency__c = 'USDA'
                                                , ZTS_US_Case__c = caseList[0].id
                                                , ZTS_US_PVW_Product__c = testProduct.id
                                                , ZTS_US_Start_Date__c = date.today()
                                                , ZTS_US_End_Date__c = date.today()
                                                , RecordTypeId = CaseProductRTId
                                                )
                                                , true
                                                );
                
        Id CaseAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c caseAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                ( ZTS_US_Local_Assessment__c = 'USDA'
                                                , RecordTypeId = CaseAssessmentRTId
                                                , ZTS_US_Reportability__c = 'Non-Reportable'
                                                , ZTS_US_Case__c = caseList[0].id
                                                )
                                                , true
                                                );


        Test.startTest();
        //String errorMsg = SL_CaseTriggerHandler.validateAssessmentReportability(caseList);
        String errorMsg = VmipsCaseService.validateAssessmentReportability(caseList);
        System.AssertEquals(true , String.isBlank(errorMsg), 'Assertion Failed Error message is not blank');
        Test.stopTest();
    }
    @isTest
    static void test_ValidateDiagReportability_Negative(){

        makeData();
        List<Case> caseList = [SELECT id from Case];

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                            (
                                            Name = 'FLU DETECT SWINE',
                                            ZTS_US_Product_Category__c = 'DIAG',
                                            ZTS_US_MAH_Country__c = 'US',
                                            ZTS_US_Active_Product__c = 'Yes'
                                            )
                                            , true
                                            );

        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct =(ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_Case_Product__c
                                            ( ZTS_US_Administered_By__c = 'Other'
                                            , ZTS_US_Dose__c = 5.4
                                            , ZTS_US_Dose_Unit__c = 'Bolus'
                                            , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                            , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                            , ZTS_US_Product_Agency__c = 'USDA'
                                            , ZTS_US_Case__c = caseList[0].id
                                            , ZTS_US_PVW_Product__c = testProduct.id
                                            , ZTS_US_Start_Date__c = date.today()
                                            , ZTS_US_End_Date__c = date.today()
                                            , RecordTypeId = CaseProductRTId
                                            )
                                            , true
                                            );
            
        Id CaseAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c caseAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                ( ZTS_US_Local_Assessment__c = 'USDA'
                                                , RecordTypeId = CaseAssessmentRTId
                                                , ZTS_US_Case__c = caseList[0].id
                                                )
                                                , true
                                                );
        Test.startTest();
        //String errorMsg = SL_CaseTriggerHandler.validateAssessmentReportability(caseList);
        String errorMsg = VmipsCaseService.validateAssessmentReportability(caseList);
        System.Assert(errorMsg.contains('Please add USDA Reportability on Assessment'));
        Test.stopTest();
    }
    @isTest
    static void test_ValidateBioG1Reportability_Negative(){

        makeData();
        List<Case> caseList = [SELECT id from Case];

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                            (
                                            Name = 'FLU DETECT SWINE',
                                            ZTS_US_Product_Category__c = 'BIO',
                                            ZTS_US_MAH_Country__c = 'US',
                                            ZTS_US_Active_Product__c = 'Yes'
                                            )
                                            , true
                                            );


        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Product_problem_type__c = 'Adverse Reaction'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Product_Agency__c = 'USDA'
                                                , ZTS_US_Case__c = caseList[0].id
                                                , ZTS_US_PVW_Product__c = testProduct.id
                                                , ZTS_US_Start_Date__c = date.today()
                                                , ZTS_US_End_Date__c = date.today()
                                                , RecordTypeId = CaseProductRTId
                                                )
                                                , true
                                                );
                
        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c localAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                ( ZTS_US_Local_Assessment__c = 'USDA'
                                                , ZTS_US_Is_it_serious__c ='Yes'
                                                , ZTS_US_Reportability__c = 'Non-Reportable'
                                                , RecordTypeId = localAssessmentRTId
                                                , ZTS_US_Case__c = caseList[0].id
                                                )
                                                , true
                                                );
        ZTS_US_Assessment_Products__c localAssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                       (new ZTS_US_Assessment_Products__c
                                                       (ZTS_US_Assessment__c = localAssessment.Id
                                                       ,ZTS_US_PVW_Product__c = testProduct.id

                                                       ),true
                                                        );
        
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                ( ZTS_US_Assessment_PA__c = 'A - Probable/High'
                                                , ZTS_US_Expected_PA__c = 'No'
                                                , RecordTypeId = productAssessmentRTId
                                                , ZTS_US_Case__c = caseList[0].id
                                                )
                                                , true
                                                );
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                            (new ZTS_US_Assessment_Products__c
                                                            (ZTS_US_Assessment__c = productAssessment.Id
                                                            ,ZTS_US_PVW_Product__c = testProduct.id
                                                            ),true
                                                                );
        
        Test.startTest();
        //String errorMsg = SL_CaseTriggerHandler.validateAssessmentReportability(caseList);
        String errorMsg = VmipsCaseService.validateAssessmentReportability(caseList);
        system.debug('Mytest1....'+errorMsg);
        System.AssertEquals('USDA Reportability should be 15-day report',errorMsg);
        Test.stopTest();
    }
    @isTest
    static void test_ValidateBioG2Reportability_Negative(){

        makeData();
        List<Case> caseList = [SELECT id from Case];

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                            (Name = 'FLU DETECT SWINE'
                                            ,ZTS_US_Product_Category__c = 'BIO'
                                            ,ZTS_US_MAH_Country__c = 'US'
                                            ,ZTS_US_Active_Product__c = 'Yes'
                                            )
                                            , true
                                            );


        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Product_problem_type__c = '(Associated) Product Defect'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                ,ZTS_US_Product_Agency__c = 'USDA'
                                                , ZTS_US_Case__c = caseList[0].id
                                                , ZTS_US_PVW_Product__c = testProduct.id
                                                ,ZTS_US_Start_Date__c = date.today()
                                                , ZTS_US_End_Date__c = date.today()
                                                ,ZTS_US_Filling_Packaging__c = 'Appearance'
                                                ,ZTS_US_Defect_Product__c = 'Activation Failure'
                                                ,ZTS_US_Defect_Shipping__c = 'Damaged - courier'
                                                , RecordTypeId = CaseProductRTId
                                                )
                                                , true
                                                );
                
        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c localAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                ( ZTS_US_Local_Assessment__c = 'USDA'
                                                , ZTS_US_Is_it_serious__c ='Yes'
                                                , RecordTypeId = localAssessmentRTId
                                                , ZTS_US_Case__c = caseList[0].id
                                                )
                                                , true
                                                );
        ZTS_US_Assessment_Products__c localAssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                       (new ZTS_US_Assessment_Products__c
                                                       (ZTS_US_Assessment__c = localAssessment.Id
                                                       ,ZTS_US_PVW_Product__c = testProduct.id

                                                       ),true
                                                        );
        
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                ( ZTS_US_Assessment_PA__c = 'A - Probable/High'
                                                , ZTS_US_Expected_PA__c = 'No'
                                                , RecordTypeId = productAssessmentRTId
                                                , ZTS_US_Case__c = caseList[0].id
                                                )
                                                , true
                                                );
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                            (new ZTS_US_Assessment_Products__c
                                                            (ZTS_US_Assessment__c = productAssessment.Id
                                                            ,ZTS_US_PVW_Product__c = testProduct.id
                                                            ),true
                                                                );
        
        Test.startTest();
        //String errorMsg = SL_CaseTriggerHandler.validateAssessmentReportability(caseList);
        String errorMsg = VmipsCaseService.validateAssessmentReportability(caseList);
        system.debug('Mytest1....'+errorMsg);
        System.Assert(errorMsg.contains('Please add USDA Reportability on Assessment'));
        Test.stopTest();
    }
    @isTest
    static void test_ValidateBioG1PeriodicReportability_Negative(){

        makeData();
        List<Case> caseList = [SELECT id from Case];

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                            (Name = 'FLU DETECT SWINE'
                                            ,ZTS_US_Product_Category__c = 'BIO'
                                            ,ZTS_US_MAH_Country__c = 'US'
                                            ,ZTS_US_Active_Product__c = 'Yes'
                                           
                                            )
                                            , true
                                            );


        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Product_problem_type__c = 'Adverse Reaction'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Product_Agency__c = 'USDA'
                                                , ZTS_US_Case__c = caseList[0].id
                                                , ZTS_US_PVW_Product__c = testProduct.id
                                                , ZTS_US_Start_Date__c = date.today()
                                                , ZTS_US_End_Date__c = date.today()
                                                , RecordTypeId = CaseProductRTId
                                                )
                                                , true
                                                );
                
        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c localAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                ( ZTS_US_Local_Assessment__c = 'USDA'
                                                , ZTS_US_Is_it_serious__c ='Yes'
                                                , RecordTypeId = localAssessmentRTId
                                                , ZTS_US_Case__c = caseList[0].id
                                                )
                                                , true
                                                );
        ZTS_US_Assessment_Products__c localAssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                       (new ZTS_US_Assessment_Products__c
                                                       (ZTS_US_Assessment__c = localAssessment.Id
                                                       ,ZTS_US_PVW_Product__c = testProduct.id

                                                       ),true
                                                        );
        
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                ( ZTS_US_Assessment_PA__c = 'A - Probable/High'
                                                , ZTS_US_Expected_PA__c = 'Yes'
                                                , RecordTypeId = productAssessmentRTId
                                                , ZTS_US_Case__c = caseList[0].id
                                                )
                                                , true
                                                );
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                            (new ZTS_US_Assessment_Products__c
                                                            (ZTS_US_Assessment__c = productAssessment.Id
                                                            ,ZTS_US_PVW_Product__c = testProduct.id
                                                            ),true
                                                                );
        
        Test.startTest();
        //String errorMsg = SL_CaseTriggerHandler.validateAssessmentReportability(caseList);
        String errorMsg = VmipsCaseService.validateAssessmentReportability(caseList);
        system.debug('Mytest1....'+errorMsg);
        System.AssertEquals('USDA Reportability should be Periodic Report',errorMsg);
        Test.stopTest();
    }
    @isTest
    static void test_ValidateBioG3Reportability_Negative(){

        makeData();
        List<Case> caseList = [SELECT id from Case];

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                            (Name = 'FLU DETECT SWINE'
                                            ,ZTS_US_Product_Category__c = 'BIO'
                                            ,ZTS_US_MAH_Country__c = 'US'
                                            ,ZTS_US_Active_Product__c = 'Yes'
                                           
                                            )
                                            , true
                                            );


        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Product_Agency__c = 'USDA'
                                                , ZTS_US_Case__c = caseList[0].id
                                                , ZTS_US_PVW_Product__c = testProduct.id
                                                ,ZTS_US_Start_Date__c = date.today()
                                                , ZTS_US_End_Date__c = date.today()                
                                                , RecordTypeId = CaseProductRTId
                                                )
                                                , true
                                                );
                
        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c localAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                ( ZTS_US_Local_Assessment__c = 'USDA'
                                                , ZTS_US_Is_it_serious__c ='Yes'
                                                , RecordTypeId = localAssessmentRTId
                                                , ZTS_US_Case__c = caseList[0].id
                                                )
                                                , true
                                                );
        ZTS_US_Assessment_Products__c localAssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                       (new ZTS_US_Assessment_Products__c
                                                       (ZTS_US_Assessment__c = localAssessment.Id
                                                       ,ZTS_US_PVW_Product__c = testProduct.id
                                                       ),true
                                                        );
        
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                ( ZTS_US_Assessment_PA__c = 'A - Probable/High'
                                                , ZTS_US_Expected_PA__c = 'No'
                                                , RecordTypeId = productAssessmentRTId
                                                , ZTS_US_Case__c = caseList[0].id
                                                )
                                                , true
                                                );
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                            (new ZTS_US_Assessment_Products__c
                                                            (ZTS_US_Assessment__c = productAssessment.Id
                                                            ,ZTS_US_PVW_Product__c = testProduct.id
                                                            ),true
                                                                );
        
        Test.startTest();
        //String errorMsg = SL_CaseTriggerHandler.validateAssessmentReportability(caseList);
        String errorMsg = VmipsCaseService.validateAssessmentReportability(caseList);
        system.debug('Mytest1....'+errorMsg);
        System.AssertEquals('USDA Reportability should be Non-Reportable',errorMsg);
        Test.stopTest();
    }

//CSE_569: Positive test method for validating Assessments records and the fields in those records before sending it to PV Works.
    @isTest
    static void test_ValidateAssessments_Positive(){
    setBypasses();
    String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Product Defect Only',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred',
                            ZTS_US_Date_First_Valid__c = date.today());
        insert testCase;

        //Insert Contact
        Contact contact = new Contact(
                LastName = 'Doe'
            ,   FirstName = 'Testone'
            ,   ZTS_US_Profession__c = 'Consultant'
            ,   ZTS_US_Job_Function__c = 'Operations'
            ,   MailingCity = 'Cambridge'
            ,   MailingState = 'Massachusetts'
            ,   MailingStreet = '383 Somerville'
            ,   MailingPostalCode = '02141'
            ,   MailingCountry = 'USA');
        insert contact;

        //Insert Case Contact
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = testCase.Id);
        insert caseContact;

        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Species__c='Feline', 
                                                       ZTS_US_Weight_units__c= 'Grams',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                       ZTS_US_Sex__c = 'Male',
                                                      ZTS_US_Weight__c = 9,
                                                      ZTS_US_Reproductive_Status__c = 'Neutered', ZTS_US_Exposed__c = 6,
                                                      ZTS_US_Breed__c = Breed1.id,
                                                      ZTS_US_Age_unit_to__c ='Minutes',ZTS_US_Age_unit_from__c ='Minutes',
                                                      ZTS_US_Age_to__c = 6.1, ZTS_US_Age_from__c =6.1,
                                                             ZTS_US_Animal_condition_prior_treatment__c = 'Good'
                                                       );
        insert testUSAnimal;

        //Insert Case Animal
        //ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = testUSAnimal.Id ,
        //ZTS_US_Total__c = 1,  ZTS_US_Exposed__c = 1,ZTS_US_Reacted__c = 1, ZTS_US_Alive_with_Sequela__c = 1);
        //insert caseAnimal;
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Reaction_Treated__c ='Yes',
        ZTS_US_Treatment__c = 'Test treatment',
        ZTS_US_Case__c = testCase.Id);
        insert eventNarrative;

        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, Duration_Units__c = 'Hour(s)', ZTS_US_Number_of_pts_affected__c = 1, ZTS_US_Start_Date__c = date.today()-1, ZTS_US_Ongoing__c = 'Yes');
        insert testVedDRA;
    
        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_PVW_Product__c
                                                    (Name = 'FLU DETECT SWINE'
                                                        ,ZTS_US_Product_Category__c = 'BIO'
                                                        ,ZTS_US_MAH_Country__c = 'US'
                                                        ,ZTS_US_Active_Product__c = 'Yes'
                                                        ,ZTS_US_Formulation_Text__c = 'Test'
                                                    )
                                                    , true
                                            );

        ZTS_US_PVW_Product__c testProduct1 = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                                (Name = 'ANTISEDAN'
                                                    ,ZTS_US_Product_Category__c = 'PHRM'
                                                    ,ZTS_US_MAH_Country__c = 'US'
                                                    ,ZTS_US_Active_Product__c = 'Yes'
                                                    ,ZTS_US_Formulation_Text__c = 'Test'
                                                )
                                                , true
                                            );

        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Product_Agency__c = 'USDA'
                                                , ZTS_US_Case__c = testCase.id
                                                , ZTS_US_Serial_Number__c = '6587'
                                                , ZTS_US_PVW_Product__c = testProduct.id
                                                , ZTS_US_Start_Date__c = date.today()-3
                                                , ZTS_US_End_Date__c = date.today()                
                                                , RecordTypeId = CaseProductRTId
                                                , ZTS_US_Route__c = 'Implant'
                                                , ZTS_US_Reason_for_use__c = 'testy'
                                                , ZTS_US_Qualifier__c = 'Invalid'
                                                , ZTS_US_Previous_Exposure__c = 'No'
                                                , ZTS_US_Previous_Reaction__c = 'No'
                                                , ZTS_US_Product_Lot__c = 'test'
                                                , ZTS_US_Per__c = 4.5
                                                 //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                , ZTS_US_Interval_Unit__c = 'mg'
                                                , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                , ZTS_US_Frequency__c = 4
                                                , ZTS_US_Expiry_Date__c = date.today()
                                                )
                                                , true
                                                );

        ZTS_US_Case_Product__c caseProduct1 = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Product_Agency__c = 'FDA'
                                                , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Case__c = testCase.id
                                                , ZTS_US_Serial_Number__c = '6587'
                                                , ZTS_US_PVW_Product__c = testProduct1.id
                                                , ZTS_US_Start_Date__c = date.today()-3
                                                , ZTS_US_End_Date__c = date.today()                
                                                , RecordTypeId = CaseProductRTId
                                                , ZTS_US_Route__c = 'Implant'
                                                , ZTS_US_Reason_for_use__c = 'testy'
                                                , ZTS_US_Qualifier__c = 'Invalid'
                                                , ZTS_US_Previous_Exposure__c = 'No'
                                                , ZTS_US_Previous_Reaction__c = 'No'
                                                , ZTS_US_Product_Lot__c = 'test'
                                                , ZTS_US_Per__c = 4.5
                                                 //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                , ZTS_US_Interval_Unit__c = 'mg'
                                                , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                , ZTS_US_Frequency__c = 4
                                                , ZTS_US_Expiry_Date__c = date.today()
                                                )
                                                , true
                                                );
        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c localAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                    ( ZTS_US_Local_Assessment__c = 'USDA'
                                                        , ZTS_US_Is_it_serious__c ='Yes'
                                                        , RecordTypeId = localAssessmentRTId
                                                        , ZTS_US_Case__c = testCase.id
                                                        , ZTS_US_Reportability__c = 'Non-Reportable'
                                                        , ZTS_US_Assessor__c = UserInfo.getUserId()
                                                        , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
                                                    )
                                                    , true
                                                );
        ZTS_US_Assessment_Products__c localAssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                       (new ZTS_US_Assessment_Products__c
                                                       (ZTS_US_Assessment__c = localAssessment.Id
                                                        ,ZTS_US_PVW_Product__c = testProduct.id
                                                       ),true
                                                        );
        
        ZTS_US_Assessment__c localAssessment1 =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                    ( new ZTS_US_Assessment__c
                                                        ( ZTS_US_Local_Assessment__c = 'FDA'
                                                            , ZTS_US_Is_it_serious__c ='Yes'
                                                            , RecordTypeId = localAssessmentRTId
                                                            , ZTS_US_Case__c = testCase.id
                                                            , ZTS_US_Reportability__c = 'Non-Reportable'
                                                            , ZTS_US_Assessor__c = UserInfo.getUserId()
                                                            , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
                                                        )
                                                        , true
                                                    );
        ZTS_US_Assessment_Products__c localAssessProduct1 = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                                (new ZTS_US_Assessment_Products__c
                                                                    (ZTS_US_Assessment__c = localAssessment1.Id
                                                                        ,ZTS_US_PVW_Product__c = testProduct1.id
                                                                    ),true
                                                                );
        
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                    (  ZTS_US_Expected_PA__c = 'No'
                                                        , RecordTypeId = productAssessmentRTId
                                                        , ZTS_US_Case__c = testCase.id
                                                        , ZTS_US_Dechallenge_PA__c = 'Abated'
                                                        , ZTS_US_Rechallenge_PA__c = 'No recurrence'
                                                        , ZTS_US_Assessor__c = UserInfo.getUserId()
                                                        , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
                                                    )
                                                    , true
                                                );
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                            (new ZTS_US_Assessment_Products__c
                                                                (ZTS_US_Assessment__c = productAssessment.Id
                                                                    ,ZTS_US_PVW_Product__c = testProduct.id
                                                                ),true
                                                            );

        ZTS_US_Assessment__c productAssessment1 =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                    ( new ZTS_US_Assessment__c
                                                        (  ZTS_US_Expected_PA__c = 'No'
                                                            , RecordTypeId = productAssessmentRTId
                                                            , ZTS_US_Case__c = testCase.id
                                                            , ZTS_US_Dechallenge_PA__c = 'Abated'
                                                            , ZTS_US_Rechallenge_PA__c = 'No recurrence'
                                                            , ZTS_US_Assessor__c = UserInfo.getUserId()
                                                            , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
                                                        )
                                                        , true
                                                    );
        
        ZTS_US_Assessment_Products__c productsssessProduct1 = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                                (new ZTS_US_Assessment_Products__c
                                                                    (ZTS_US_Assessment__c = productAssessment1.Id
                                                                        ,ZTS_US_PVW_Product__c = testProduct1.id
                                                                    ),true
                                                                );
        
        testCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        update testCase;
        clearBypasses();
        Test.startTest();  
        testCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
        update testCase;

        Test.stopTest();
        Case queriedCase = [SELECT Id, Sync_Status__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(VmipsCaseSyncStatusHandler.SYNC_READY, testCase.Sync_Status__c, 'Status marked ready when case has all the required validations.');
  }//test_ValidateAssessments_Positive

    //CSE_569: Negative test method for validating Assessments records and the fields in those records before sending it to PV Works.
    @isTest
    static void test_ValidateAssessments_Negative(){
    setBypasses();
    String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred',
                            ZTS_US_Date_First_Valid__c = date.today()
                            );
        insert testCase;

        //Insert Contact
        Contact contact = new Contact(
                LastName = 'Doe'
            ,   FirstName = 'Testone'
            ,   ZTS_US_Profession__c = 'Consultant'
            ,   ZTS_US_Job_Function__c = 'Operations'
            ,   MailingCity = 'Cambridge'
            ,   MailingState = 'Massachusetts'
            ,   MailingStreet = '383 Somerville'
            ,   MailingPostalCode = '02141'
            ,   MailingCountry = 'USA');
        insert contact;

        //Insert Case Contact
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = testCase.Id);
        insert caseContact;

        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Species__c='Feline', 
                                                       ZTS_US_Weight_units__c= 'Grams',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                       ZTS_US_Sex__c = 'Male',
                                                      ZTS_US_Weight__c = 9, 
                                                      ZTS_US_Reproductive_Status__c = 'Neutered', ZTS_US_Exposed__c = 6,
                                                       ZTS_US_Breed__c = Breed1.id,
                                                      ZTS_US_Age_unit_to__c ='Minutes',ZTS_US_Age_unit_from__c ='Minutes',
                                                      ZTS_US_Age_to__c =6.1,ZTS_US_Age_from__c =6.1,
                                                             ZTS_US_Animal_condition_prior_treatment__c = 'Good'
                                                       );
        insert testUSAnimal;

        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = testUSAnimal.Id ,
        ZTS_US_Total__c = 1,  ZTS_US_Exposed__c = 1,ZTS_US_Reacted__c = 1, ZTS_US_Alive_with_Sequela__c = 1,ZTS_US_Age_unit_to__c ='Minutes',ZTS_US_Age_unit_from__c ='Minutes',
        ZTS_US_Age_to__c = 6.1,ZTS_US_Age_from__c = 6.1,ZTS_US_Weight_units__c= 'Grams',ZTS_US_Weight__c = 9);
        insert caseAnimal;
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
        ZTS_US_Outcome_of_Reaction__c = 'Died',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Reaction_Treated__c ='Yes',
        ZTS_US_Treatment__c = 'Test treatment',
        ZTS_US_Case__c = testCase.Id);
        insert eventNarrative;

        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, Duration_Units__c = 'Hour(s)', ZTS_US_Number_of_pts_affected__c = 1, ZTS_US_Start_Date__c = date.today()-1, ZTS_US_Ongoing__c = 'Yes');
        insert testVedDRA;
    
    
    ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                            (Name = 'FLU DETECT SWINE'
                                            ,ZTS_US_Product_Category__c = 'BIO'
                                            ,ZTS_US_MAH_Country__c = 'US'
                                            ,ZTS_US_Active_Product__c = 'Yes'
                                            ,ZTS_US_Formulation_Text__c = 'Test'
                                            )
                                            , true
                                            );


        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Product_Agency__c = 'USDA'
                                                , ZTS_US_Case__c = testCase.id
                                                , ZTS_US_Serial_Number__c = '6587'
                                                , ZTS_US_PVW_Product__c = testProduct.id
                                                , ZTS_US_Start_Date__c = date.today()-3
                                                , ZTS_US_End_Date__c = date.today()                
                                                , RecordTypeId = CaseProductRTId
                                                , ZTS_US_Route__c = 'Implant'
                                                , ZTS_US_Reason_for_use__c = 'testy'
                                                , ZTS_US_Qualifier__c = 'Invalid'
                                                , ZTS_US_Previous_Exposure__c = 'No'
                                                , ZTS_US_Previous_Reaction__c = 'No'
                                                , ZTS_US_Product_Lot__c = 'test'
                                                , ZTS_US_Per__c = 4.5
                                                 //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                , ZTS_US_Interval_Unit__c = 'mg'
                                                , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                , ZTS_US_Frequency__c = 4
                                                , ZTS_US_Expiry_Date__c = date.today()
                                                )
                                                , true
                                                );
        
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                    (  ZTS_US_Expected_PA__c = 'No'
                                                        , RecordTypeId = productAssessmentRTId
                                                        , ZTS_US_Case__c = testCase.id
                                                        , ZTS_US_Dechallenge_PA__c = 'Abated'
                                                        , ZTS_US_Rechallenge_PA__c = 'No recurrence'
                                                        , ZTS_US_Assessor__c = UserInfo.getUserId()
                                                        , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
                                                    )
                                                    , true
                                                );
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                            (new ZTS_US_Assessment_Products__c
                                                            (ZTS_US_Assessment__c = productAssessment.Id
                                                            ,ZTS_US_PVW_Product__c = testProduct.id
                                                            ),true
                                                                );

        Boolean expectedExceptionThrown = false;
        List<ZTS_US_Assessment__c> lstAssesments = [SELECT Id,
                                                           Name
                                                      FROM ZTS_US_Assessment__c
                                                     WHERE Id = :productAssessment.Id];
        
        clearBypasses();
        Test.startTest();
        try{
            testCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
            testCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
            update testCase;
        }catch(Exception ex){       
            expectedExceptionThrown = true;         
        }
        Test.stopTest();
        System.assertNotEquals(false, expectedExceptionThrown, 'The case shows an error message with missing required records needed for it to be sent for approval.');         
    }//test_ValidateAssessments_Negative

    ////CSE_569: Positive test method for validating Assessments fields before sending it to PV Works.
   @isTest
    static void test_validateAssessmentMethod_Positive(){
        setBypasses();
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred',
                            ZTS_US_Date_First_Valid__c = date.today()
                            );
        insert testCase;

        //Insert Contact
        Contact contact = new Contact(
                LastName = 'Doe'
            ,   FirstName = 'Testone'
            ,   ZTS_US_Profession__c = 'Consultant'
            ,   ZTS_US_Job_Function__c = 'Operations'
            ,   MailingCity = 'Cambridge'
            ,   MailingState = 'Massachusetts'
            ,   MailingStreet = '383 Somerville'
            ,   MailingPostalCode = '02141'
            ,   MailingCountry = 'USA');
        insert contact;

        //Insert Case Contact
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = testCase.Id);
        insert caseContact;

        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Species__c='Feline', 
                                                       ZTS_US_Weight_units__c= 'Grams',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                       ZTS_US_Sex__c = 'Male',
                                                      ZTS_US_Weight__c = 9,
                                                      ZTS_US_Reproductive_Status__c = 'Neutered', ZTS_US_Exposed__c = 6,
                                                      ZTS_US_Breed__c = Breed1.id,
                                                      ZTS_US_Age_unit_to__c ='Minutes',ZTS_US_Age_unit_from__c ='Minutes',
                                                      ZTS_US_Age_to__c = 6.1,ZTS_US_Age_from__c = 6.1,
                                                             ZTS_US_Animal_condition_prior_treatment__c = 'Good'
                                                      );
        insert testUSAnimal;

        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = testUSAnimal.Id,
        ZTS_US_Alive_with_Sequela__c = 1, ZTS_US_Reacted__c = 1, ZTS_US_Exposed__c = 1 ,ZTS_US_Total__c = 1,ZTS_US_Age_unit_to__c ='Minutes',ZTS_US_Age_unit_from__c ='Minutes',
        ZTS_US_Age_to__c = 6.1,ZTS_US_Age_from__c = 6.1,ZTS_US_Weight_units__c= 'Grams',ZTS_US_Weight__c = 9);
        insert caseAnimal;
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
        //ZTS_US_Outcome_of_Reaction__c = 'Alive with Sequeala',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Reaction_Treated__c ='Yes',
        ZTS_US_Treatment__c = 'Test treatment',
        ZTS_US_Case__c = testCase.Id);
        insert eventNarrative;

        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, Duration_Units__c = 'Hour(s)', ZTS_US_Number_of_pts_affected__c = 1, ZTS_US_Start_Date__c = date.today()-1, ZTS_US_Ongoing__c = 'Yes');
        insert testVedDRA;
    
    ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                            (Name = 'FLU DETECT SWINE'
                                            ,ZTS_US_Product_Category__c = 'BIO'
                                            ,ZTS_US_MAH_Country__c = 'US'
                                            ,ZTS_US_Active_Product__c = 'Yes'
                                            ,ZTS_US_Formulation_Text__c = 'Test'
                                            )
                                            , true
                                            );

        ZTS_US_PVW_Product__c testProduct1 = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                                (Name = 'ANTISEDAN'
                                                    ,ZTS_US_Product_Category__c = 'PHRM'
                                                    ,ZTS_US_MAH_Country__c = 'US'
                                                    ,ZTS_US_Active_Product__c = 'Yes'
                                                    ,ZTS_US_Formulation_Text__c = 'Test'
                                                )
                                                , true
                                            );


        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Product_Agency__c = 'USDA'
                                                , ZTS_US_Case__c = testCase.id
                                                , ZTS_US_Serial_Number__c = '6587'
                                                , ZTS_US_PVW_Product__c = testProduct.id
                                                , ZTS_US_Start_Date__c = date.today()-3
                                                , ZTS_US_End_Date__c = date.today()                
                                                , RecordTypeId = CaseProductRTId
                                                , ZTS_US_Route__c = 'Implant'
                                                , ZTS_US_Reason_for_use__c = 'testy'
                                                , ZTS_US_Qualifier__c = 'Invalid'
                                                , ZTS_US_Previous_Exposure__c = 'No'
                                                , ZTS_US_Previous_Reaction__c = 'No'
                                                , ZTS_US_Product_Lot__c = 'test'
                                                , ZTS_US_Per__c = 4.5
                                                 //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                , ZTS_US_Interval_Unit__c = 'mg'
                                                , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                , ZTS_US_Frequency__c = 4
                                                , ZTS_US_Expiry_Date__c = date.today()
                                                )
                                                , true
                                                );

        ZTS_US_Case_Product__c caseProduct1 = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Product_Agency__c = 'USDA'
                                                , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Case__c = testCase.id
                                                , ZTS_US_Serial_Number__c = '6587'
                                                , ZTS_US_PVW_Product__c = testProduct1.id
                                                , ZTS_US_Start_Date__c = date.today()-3
                                                , ZTS_US_End_Date__c = date.today()                
                                                , RecordTypeId = CaseProductRTId
                                                , ZTS_US_Route__c = 'Implant'
                                                , ZTS_US_Reason_for_use__c = 'testy'
                                                , ZTS_US_Qualifier__c = 'Invalid'
                                                , ZTS_US_Previous_Exposure__c = 'No'
                                                , ZTS_US_Previous_Reaction__c = 'No'
                                                , ZTS_US_Product_Lot__c = 'test'
                                                , ZTS_US_Per__c = 4.5
                                                //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                , ZTS_US_Interval_Unit__c = 'mg'
                                                , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                , ZTS_US_Frequency__c = 4
                                                ,  ZTS_US_Expiry_Date__c = date.today()
                                                )
                                                , true
                                                );
        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c localAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                    ( ZTS_US_Local_Assessment__c = 'USDA'
                                                        , ZTS_US_Is_it_serious__c ='Yes'
                                                        , RecordTypeId = localAssessmentRTId
                                                        , ZTS_US_Case__c = testCase.id
                                                        , ZTS_US_Reportability__c = 'Non-Reportable'
                                                        , ZTS_US_Assessor__c = UserInfo.getUserId()
                                                        , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
                                                    )
                                                    , true
                                                );
        ZTS_US_Assessment_Products__c localAssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                       (new ZTS_US_Assessment_Products__c
                                                       (ZTS_US_Assessment__c = localAssessment.Id
                                                        ,ZTS_US_PVW_Product__c = testProduct.id
                                                       ),true
                                                        );

        ZTS_US_Assessment__c localAssessment1 =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                    ( ZTS_US_Local_Assessment__c = 'USDA'
                                                        , ZTS_US_Is_it_serious__c ='Yes'
                                                        , RecordTypeId = localAssessmentRTId
                                                        , ZTS_US_Case__c = testCase.id
                                                        , ZTS_US_Reportability__c = 'Non-Reportable'
                                                        , ZTS_US_Assessor__c = UserInfo.getUserId()
                                                        , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
                                                    )
                                                    , true
                                                );
        ZTS_US_Assessment_Products__c localAssessProduct1 = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                       (new ZTS_US_Assessment_Products__c
                                                       (ZTS_US_Assessment__c = localAssessment1.Id
                                                        ,ZTS_US_PVW_Product__c = testProduct1.id
                                                       ),true
                                                        );
        
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                    (  ZTS_US_Expected_PA__c = 'No'
                                                        , RecordTypeId = productAssessmentRTId
                                                        , ZTS_US_Case__c = testCase.id
                                                        , ZTS_US_Dechallenge_PA__c = 'Abated'
                                                        , ZTS_US_Rechallenge_PA__c = 'No recurrence'
                                                        , ZTS_US_Assessor__c = UserInfo.getUserId()
                                                        , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
                                                    )
                                                    , true
                                                );
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                            (new ZTS_US_Assessment_Products__c
                                                                (ZTS_US_Assessment__c = productAssessment.Id
                                                                    ,ZTS_US_PVW_Product__c = testProduct.id
                                                                ),true
                                                            );

        ZTS_US_Assessment__c productAssessment1 =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                    ( new ZTS_US_Assessment__c
                                                        (  ZTS_US_Expected_PA__c = 'No'
                                                            , RecordTypeId = productAssessmentRTId
                                                            , ZTS_US_Case__c = testCase.id
                                                            , ZTS_US_Dechallenge_PA__c = 'Abated'
                                                            , ZTS_US_Rechallenge_PA__c = 'No recurrence'
                                                            , ZTS_US_Assessor__c = UserInfo.getUserId()
                                                            , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
                                                        )
                                                        , true
                                                    );
        
        ZTS_US_Assessment_Products__c productsssessProduct1 = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                                (new ZTS_US_Assessment_Products__c
                                                                    (ZTS_US_Assessment__c = productAssessment1.Id
                                                                        ,ZTS_US_PVW_Product__c = testProduct1.id
                                                                    ),true
                                                                );


        

        List<ZTS_US_Case_Product__c> lstQueriedProds = [SELECT ID, 
                                                               ZTS_US_Administered_By__c, 
                                                               ZTS_US_Dose__c, 
                                                               ZTS_US_Duration__c, 
                                                               ZTS_US_Product_Role__c,
                                                               ZTS_US_Product_Agency__c,
                                                               ZTS_US_PVW_Product__c,
                                                               ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c, 
                                                               ZTS_US_Case__c
                                                          FROM ZTS_US_Case_Product__c 
                                                         WHERE ZTS_US_Dose__c = 5.4
                                                         LIMIT 1];        
        Case objQueriedCase = [SELECT ID, 
                                      Status, 
                                      Subject,
                                      Type
                                 FROM Case 
                                WHERE Id = :testCase.Id
                                LIMIT 1];
        
        List<ZTS_US_Assessment__c> lstAssesments = [SELECT Id,
                                                        Name,
                                                        ZTS_US_Assessor__c,
                                                        ZTS_US_Dechallenge_PA__c,
                                                        ZTS_US_Rechallenge_PA__c,
                                                        ZTS_US_Is_it_serious__c,
                                                        ZTS_US_Local_Assessment__c,
                                                        ZTS_US_Reason_for_Assessment_PA__c,
                                                        RecordType.DeveloperName,
                                                        ZTS_US_Reportability__c,
                                                        ZTS_US_Expected_PA__c,
                                                        ZTS_US_Assessment_PA__c,
                                                        (SELECT Id,
                                                                ZTS_US_Assessment__c,
                                                                ZTS_US_PVW_Product__c
                                                            FROM Assessment_Products__r)
                                                    FROM ZTS_US_Assessment__c];
        clearBypasses();
        testCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
    
        testCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
        Test.startTest(); 
        //SL_CaseTriggerHandler.validateAssessmentRecords(objQueriedCase, lstQueriedProds, lstAssesments);
        VmipsCaseService.validateAssessmentRecords(objQueriedCase, lstQueriedProds, lstAssesments);
        Test.stopTest();
        List<Database.Error> validationErrors = objQueriedCase.getErrors();
        system.debug('validation errors' + validationErrors);
        system.assert(validationErrors.isEmpty(), 'We expect that there will be no validation errors on the related Case record');
    }//test_validateAssessmentRecordsMethod_Positive

    //CSE_569 Negative Test To validate the validateAssessmentRecords Method for missing required field validations
    @isTest
    static void test_validateAssessmentMethodFields_Negative(){
        setBypasses();
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Phone',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred',
                            ZTS_US_Date_First_Valid__c = date.today()
                            );
        insert testCase;

        //Insert Contact
        Contact contact = new Contact(
                LastName = 'Doe'
            ,   FirstName = 'Testone'
            ,   ZTS_US_Profession__c = 'Consultant'
            ,   ZTS_US_Job_Function__c = 'Operations'
            ,   MailingCity = 'Cambridge'
            ,   MailingState = 'Massachusetts'
            ,   MailingStreet = '383 Somerville'
            ,   MailingPostalCode = '02141'
            ,   MailingCountry = 'USA');
        insert contact;

        //Insert Case Contact
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = testCase.Id);
        insert caseContact;

        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Species__c='Feline', 
                                                       ZTS_US_Weight_units__c= 'Grams',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                       ZTS_US_Sex__c = 'Male',
                                                      ZTS_US_Weight__c = 9,
                                                      ZTS_US_Reproductive_Status__c = 'Neutered', 
                                                      ZTS_US_Breed__c = Breed1.id,
                                                      ZTS_US_Age_unit_to__c ='Minutes',ZTS_US_Age_unit_from__c ='Minutes',
                                                      ZTS_US_Age_to__c = 6.1,ZTS_US_Age_from__c =6.1,
                                                             ZTS_US_Animal_condition_prior_treatment__c = 'Good'
                                                      );
        insert testUSAnimal;

        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = testUSAnimal.Id,
        ZTS_US_Total__c = 1,  ZTS_US_Exposed__c = 1,ZTS_US_Reacted__c = 1, ZTS_US_Alive_with_Sequela__c = 1,ZTS_US_Age_unit_to__c ='Minutes',ZTS_US_Age_unit_from__c ='Minutes',
        ZTS_US_Age_to__c = 6.1,ZTS_US_Age_from__c = 6.1,ZTS_US_Weight_units__c= 'Grams',ZTS_US_Weight__c = 9);
        insert caseAnimal;
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
        //ZTS_US_Outcome_of_Reaction__c = 'Died',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Reaction_Treated__c ='Yes',
        ZTS_US_Treatment__c = 'Test treatment',
        ZTS_US_Case__c = testCase.Id);
        insert eventNarrative;

        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, Duration_Units__c = 'Hour(s)', ZTS_US_Number_of_pts_affected__c = 1, ZTS_US_Start_Date__c = date.today()-1, ZTS_US_Ongoing__c = 'Yes');
        insert testVedDRA;
    
    ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                            (Name = 'FLU DETECT SWINE'
                                            ,ZTS_US_Product_Category__c = 'BIO'
                                            ,ZTS_US_MAH_Country__c = 'US'
                                            ,ZTS_US_Active_Product__c = 'Yes'
                                            ,ZTS_US_Formulation_Text__c = 'Test'
                                            )
                                            , true
                                            );


        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Case__c = testCase.id
                                                , ZTS_US_Serial_Number__c = '6587'
                                                , ZTS_US_PVW_Product__c = testProduct.id
                                                , ZTS_US_Start_Date__c = date.today()-3
                                                , ZTS_US_End_Date__c = date.today()                
                                                , RecordTypeId = CaseProductRTId
                                                , ZTS_US_Route__c = 'Implant'
                                                , ZTS_US_Reason_for_use__c = 'testy'
                                                , ZTS_US_Qualifier__c = 'Invalid'
                                                , ZTS_US_Previous_Exposure__c = 'No'
                                                , ZTS_US_Previous_Reaction__c = 'No'
                                                , ZTS_US_Product_Lot__c = 'test'
                                                , ZTS_US_Per__c = 4.5
                                                 //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                , ZTS_US_Interval_Unit__c = 'mg'
                                                , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                , ZTS_US_Frequency__c = 4
                                                , ZTS_US_Expiry_Date__c = date.today()
                                                )
                                                , true
                                                );

        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c localAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                    ( ZTS_US_Local_Assessment__c = 'USDA'
                                                        , ZTS_US_Is_it_serious__c ='Yes'
                                                        , RecordTypeId = localAssessmentRTId
                                                        , ZTS_US_Case__c = testCase.id
                                                        , ZTS_US_Reportability__c = 'Non-Reportable'
                                                        , ZTS_US_Assessor__c = UserInfo.getUserId()
                                                        , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
                                                    )
                                                    , true
                                                );
        ZTS_US_Assessment_Products__c localAssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                        (new ZTS_US_Assessment_Products__c
                                                        (ZTS_US_Assessment__c = localAssessment.Id
                                                        ,ZTS_US_PVW_Product__c = testProduct.id
                                                        ),true
                                                        );
                                                        
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                    (  ZTS_US_Expected_PA__c = 'No'
                                                        , RecordTypeId = productAssessmentRTId
                                                        , ZTS_US_Case__c = testCase.id
                                                        , ZTS_US_Dechallenge_PA__c = 'Abated'
                                                        , ZTS_US_Rechallenge_PA__c = 'No recurrence'
                                                    )
                                                    , true
                                                );

        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                            (new ZTS_US_Assessment_Products__c
                                                                (ZTS_US_Assessment__c = productAssessment.Id
                                                                    ,ZTS_US_PVW_Product__c = testProduct.id
                                                                ),true
                                                            );

        testCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        
        List<ZTS_US_Case_Product__c> lstQueriedProds = [SELECT ID, 
                                                               ZTS_US_Administered_By__c, 
                                                               ZTS_US_Dose__c, 
                                                               ZTS_US_Duration__c, 
                                                               ZTS_US_Product_Role__c,
                                                               ZTS_US_Product_Agency__c,
                                                               ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c, 
                                                               ZTS_US_PVW_Product__c,

                                                               ZTS_US_Case__c
                                                          FROM ZTS_US_Case_Product__c 
                                                         WHERE ZTS_US_Dose__c = 5.4
                                                         LIMIT 1];        
        Case objQueriedCase = [SELECT ID, 
                                      Status, 
                                      Subject,
                                      Type
                                 FROM Case 
                                WHERE Id = :testCase.Id
                                LIMIT 1];
        
            List<ZTS_US_Assessment__c> lstAssesments = [SELECT Id,
                                                            Name,
                                                            ZTS_US_Assessor__c,
                                                            ZTS_US_Dechallenge_PA__c,
                                                            ZTS_US_Rechallenge_PA__c,
                                                            ZTS_US_Is_it_serious__c,
                                                            ZTS_US_Local_Assessment__c,
                                                            ZTS_US_Reason_for_Assessment_PA__c,
                                                            RecordType.DeveloperName,
                                                            ZTS_US_Reportability__c,
                                                            ZTS_US_Expected_PA__c,
                                                            ZTS_US_Assessment_PA__c,
                                                            ZTS_US_Case__r.Type, 
                                                            (SELECT Id,
                                                                    ZTS_US_Assessment__c,
                                                                    ZTS_US_PVW_Product__c
                                                                FROM Assessment_Products__r)
                                                        FROM ZTS_US_Assessment__c];
        clearBypasses();
        Test.startTest();
        String errors_Assessment;
        String expectedValue;
       
        //errors_Assessment = SL_CaseTriggerHandler.validateAssessmentRecords(objQueriedCase, lstQueriedProds, lstAssesments);
        errors_Assessment = VmipsCaseService.validateAssessmentRecords(objQueriedCase, lstQueriedProds, lstAssesments);        
        List<ZTS_US_Assessment__c> lstMissingFieldValueAssesment = [SELECT Id,
                                                                            Name, ZTS_US_Case__c
                                                                       FROM ZTS_US_Assessment__c
                                                                      WHERE Id =:productAssessment.Id];
        Test.stopTest();
        List<Database.Error> validationErrors = objQueriedCase.getErrors();
        system.assert(validationErrors.isEmpty(), 'We expect that there will be validation errors on the related Case record with missing required fields on Case Assessments');
        expectedValue = String.format( VmipsCaseService.MISSING_REQUIRED_FIELD_ON_RELATED_RECORD, new List<String>{ (lstMissingFieldValueAssesment[0].getSObjectType().getDescribe().getLabel()+' '+lstMissingFieldValueAssesment[0].Name), (String)Schema.getGlobalDescribe().get(lstMissingFieldValueAssesment[0].getSobjectType().getDescribe().getName()).getDescribe().fields.getMap().get('ZTS_US_Assessment_PA__c').getDescribe().getLabel() });
        system.AssertEquals(expectedValue, errors_Assessment, 'We expect that there will be validation errors on the related Case record with missing required fields on Case Assessments');
     }
    
    //CSE_569: Negative test method for validateAssessmentRecords Method for validating Assessment records.
    @isTest
    static void test_ValidateAssessmentMethodRecords_Negative(){
        setBypasses();
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();

        Case testCase = new Case(Subject = 'Test Case',
                            Status = 'New',
                            Origin = 'Email',
                            Type = 'Animal Complaint',
                            RecordTypeId = animalRecordtypeId,                                
                            ZTS_US_Information_Type__c = 'Erred',
                            ZTS_US_Date_First_Valid__c = date.today()
                            );
        insert testCase;

        //Insert Contact
        Contact contact = new Contact(
                LastName = 'Doe'
            ,   FirstName = 'Testone'
            ,   ZTS_US_Profession__c = 'Consultant'
            ,   ZTS_US_Job_Function__c = 'Operations'
            ,   MailingCity = 'Cambridge'
            ,   MailingState = 'Massachusetts'
            ,   MailingStreet = '383 Somerville'
            ,   MailingPostalCode = '02141'
            ,   MailingCountry = 'USA');
        insert contact;

        //Insert Case Contact
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = testCase.Id);
        insert caseContact;

        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Species__c='Feline', 
                                                       ZTS_US_Weight_units__c= 'Grams',ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                       ZTS_US_Sex__c = 'Male',
                                                      ZTS_US_Weight__c = 9,
                                                      ZTS_US_Reproductive_Status__c = 'Neutered', ZTS_US_Exposed__c = 6,
                                                      ZTS_US_Breed__c = Breed1.id,
                                                      ZTS_US_Age_unit_to__c ='Minutes',ZTS_US_Age_unit_from__c ='Minutes',
                                                      ZTS_US_Age_to__c = 6.1,ZTS_US_Age_from__c = 6.1,
                                                             ZTS_US_Animal_condition_prior_treatment__c = 'Good'
                                                      );
        insert testUSAnimal;

        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, ZTS_US_Animal__c = testUSAnimal.Id,
        ZTS_US_Total__c = 1,  ZTS_US_Exposed__c = 1,ZTS_US_Reacted__c = 1, ZTS_US_Alive_with_Sequela__c = 1,ZTS_US_Age_unit_to__c ='Minutes',ZTS_US_Age_unit_from__c ='Minutes',
        ZTS_US_Age_to__c = 6.1,ZTS_US_Age_from__c = 6.1,ZTS_US_Weight_units__c= 'Grams',ZTS_US_Weight__c = 9);
        insert caseAnimal;
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
        ZTS_US_Outcome_of_Reaction__c = 'Died',
        ZTS_US_Duration_text__c = '30',
        ZTS_US_Reaction_Treated__c ='Yes',
        ZTS_US_Treatment__c = 'Test treatment',
        ZTS_US_Case__c = testCase.Id);
        insert eventNarrative;

    ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                            (Name = 'FLU DETECT SWINE'
                                            ,ZTS_US_Product_Category__c = 'BIO'
                                            ,ZTS_US_MAH_Country__c = 'US'
                                            ,ZTS_US_Active_Product__c = 'Yes'
                                            ,ZTS_US_Formulation_Text__c = 'Test'
                                            )
                                            , true
                                            );


        ZTS_US_PVW_Product__c testProduct1 = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
                                            ( new ZTS_US_PVW_Product__c
                                                (Name = 'ANTISEDAN'
                                                    ,ZTS_US_Product_Category__c = 'PHRM'
                                                    ,ZTS_US_MAH_Country__c = 'US'
                                                    ,ZTS_US_Active_Product__c = 'Yes'
                                                    ,ZTS_US_Formulation_Text__c = 'Test'
                                                )
                                                , true
                                            );

        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Product_Agency__c = 'USDA'
                                                , ZTS_US_Case__c = testCase.id
                                                , ZTS_US_Serial_Number__c = '6587'
                                                , ZTS_US_PVW_Product__c = testProduct.id
                                                , ZTS_US_Start_Date__c = date.today()-3
                                                , ZTS_US_End_Date__c = date.today()                
                                                , RecordTypeId = CaseProductRTId
                                                , ZTS_US_Route__c = 'Implant'
                                                , ZTS_US_Reason_for_use__c = 'testy'
                                                , ZTS_US_Qualifier__c = 'Invalid'
                                                , ZTS_US_Previous_Exposure__c = 'No'
                                                , ZTS_US_Previous_Reaction__c = 'No'
                                                , ZTS_US_Product_Lot__c = 'test'
                                                , ZTS_US_Per__c = 4.5
                                                //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                , ZTS_US_Interval_Unit__c = 'mg'
                                                , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                , ZTS_US_Frequency__c = 4
                                                ,ZTS_US_Expiry_Date__c = date.today()
                                                )
                                                , true
                                                );

        ZTS_US_Case_Product__c caseProduct1 = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Case_Product__c
                                                ( ZTS_US_Administered_By__c = 'Other'
                                                , ZTS_US_Dose__c = 5.4
                                                , ZTS_US_Dose_Unit__c = 'Bolus'
                                                , ZTS_US_Product_Agency__c = 'FDA'
                                                , ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable'
                                                , ZTS_US_Product_problem_type__c = 'Ecotoxicity'
                                                , ZTS_US_Product_Used_Correctly__c = 'Yes'
                                                , ZTS_US_Case__c = testCase.id
                                                , ZTS_US_Serial_Number__c = '6587'
                                                , ZTS_US_PVW_Product__c = testProduct1.id
                                                , ZTS_US_Start_Date__c = date.today()-3
                                                , ZTS_US_End_Date__c = date.today()                
                                                , RecordTypeId = CaseProductRTId
                                                , ZTS_US_Route__c = 'Implant'
                                                , ZTS_US_Reason_for_use__c = 'testy'
                                                , ZTS_US_Qualifier__c = 'Invalid'
                                                , ZTS_US_Previous_Exposure__c = 'No'
                                                , ZTS_US_Previous_Reaction__c = 'No'
                                                , ZTS_US_Product_Lot__c = 'test'
                                                , ZTS_US_Per__c = 4.5
                                                 //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                , ZTS_US_Interval_Unit__c = 'mg'
                                                , ZTS_US_Frequency_Unit__c = 'Minutes'
                                                , ZTS_US_Frequency__c = 4
                                                , ZTS_US_Expiry_Date__c = date.today()
                                                )
                                                , true
                                                );
 
        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();

        ZTS_US_Assessment__c localAssessment1 =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                    ( new ZTS_US_Assessment__c
                                                        ( ZTS_US_Local_Assessment__c = 'FDA'
                                                            , ZTS_US_Is_it_serious__c ='Yes'
                                                            , RecordTypeId = localAssessmentRTId
                                                            , ZTS_US_Case__c = testCase.id
                                                            , ZTS_US_Reportability__c = 'Non-Reportable'
                                                            , ZTS_US_Assessor__c = UserInfo.getUserId()
                                                            , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
                                                        )
                                                        , true
                                                    );
        ZTS_US_Assessment_Products__c localAssessProduct1 = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                                (new ZTS_US_Assessment_Products__c
                                                                    (ZTS_US_Assessment__c = localAssessment1.Id
                                                                        ,ZTS_US_PVW_Product__c = testProduct1.id
                                                                    ),true
                                                                );
        
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
                                                ( new ZTS_US_Assessment__c
                                                    (  ZTS_US_Expected_PA__c = 'No'
                                                        , RecordTypeId = productAssessmentRTId
                                                        , ZTS_US_Case__c = testCase.id
                                                        , ZTS_US_Dechallenge_PA__c = 'Abated'
                                                        , ZTS_US_Rechallenge_PA__c = 'No recurrence'
                                                        , ZTS_US_Assessor__c = UserInfo.getUserId()
                                                        , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
                                                    )
                                                    , true
                                                );
                                                

        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, Duration_Units__c = 'Hour(s)', ZTS_US_Number_of_pts_affected__c = 1, ZTS_US_Start_Date__c = date.today()-1, ZTS_US_Ongoing__c = 'Yes');
        insert testVedDRA;
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
                                                            (new ZTS_US_Assessment_Products__c
                                                                (ZTS_US_Assessment__c = productAssessment.Id
                                                                    ,ZTS_US_PVW_Product__c = testProduct.id
                                                                ),true
                                                            );

        List<ZTS_US_Case_Product__c> lstQueriedProds = [SELECT ID, 
                                                               ZTS_US_Administered_By__c, 
                                                               ZTS_US_Dose__c, 
                                                               ZTS_US_Duration__c, 
                                                               ZTS_US_Product_Role__c,
                                                               ZTS_US_Product_Agency__c,
                                                               ZTS_US_PVW_Product__c,
                                                               ZTS_US_PVW_Product__r.ZTS_US_Product_Category__c, 
                                                               ZTS_US_Case__c
                                                          FROM ZTS_US_Case_Product__c 
                                                         WHERE ZTS_US_Dose__c = 5.4
                                                         LIMIT 1];        
        Case objQueriedCase = [SELECT ID, 
                                      Status, 
                                      Subject
                                 FROM Case 
                                WHERE Id = :testCase.Id
                                LIMIT 1];
        List<ZTS_US_Assessment__c> lstAssesments = [SELECT Id,
                                                           Name,
                                                           ZTS_US_Assessor__c,
                                                           ZTS_US_Dechallenge_PA__c,
                                                           ZTS_US_Rechallenge_PA__c,
                                                           ZTS_US_Is_it_serious__c,
                                                           ZTS_US_Local_Assessment__c,
                                                           ZTS_US_Reason_for_Assessment_PA__c,
                                                           RecordType.DeveloperName,
                                                           ZTS_US_Reportability__c,
                                                           ZTS_US_Expected_PA__c,
                                                           (SELECT Id,
                                                                   ZTS_US_Assessment__c,
                                                                   ZTS_US_PVW_Product__c
                                                              FROM Assessment_Products__r)
                                                      FROM ZTS_US_Assessment__c];
        clearBypasses();
        Test.startTest(); 
        testCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        String errors_Assessment;
        //errors_Assessment = SL_CaseTriggerHandler.validateAssessmentRecords(objQueriedCase, lstQueriedProds, lstAssesments);
        errors_Assessment = VmipsCaseService.validateAssessmentRecords(objQueriedCase, lstQueriedProds, lstAssesments);
        Test.stopTest();
        system.assertEquals(VmipsCaseService.CASE_ASSESSMENT_ERROR, errors_Assessment, 'We expect that there will be validation errors on the related Case record with missing Case Assessments');
    }
  @isTest
    private static void testSetDiagnosticEntitlementOnDiagnosticCaseInsert() {
        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        Case testCase = ZTS_DataUtilityTest.createCases(1, diagRecordTypeId)[0];

        Test.startTest();
            insert testCase;
        Test.stopTest();

        Id diagnosticsEntitlementId = retrieveDiagnosticsEntitlements()[0].Id;
        Case updatedCase = [SELECT Id, EntitlementId FROM Case WHERE Id =: testCase.Id];

        system.assertEquals(diagnosticsEntitlementId, updatedCase.EntitlementId, 
            'Entitlement was not set to the Diagnostics Entitlement Id');
    }
    
  @isTest
    private static void testSetDiagnosticEntitlementOnDiagnosticCaseUpdate() {
        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        // Retrieve a Case setup in the testSetup method.
        Case testCase = [SELECT ID FROM Case WHERE RecordType.DeveloperName !=: diagRecordTypeId LIMIT 1];

        testCase.RecordTypeId = diagRecordTypeId;
        Test.startTest();
            update testCase;
        Test.stopTest();

        Id diagnosticsEntitlementId = retrieveDiagnosticsEntitlements()[0].Id;
        Case updatedCase = [SELECT Id, EntitlementId FROM Case WHERE Id =: testCase.Id];

        system.assertEquals(diagnosticsEntitlementId, updatedCase.EntitlementId, 
            'Entitlement was not set to the Diagnostics Entitlement Id');
    }
 @isTest
    private static void testSetDiagnosticEntitlementOnDiagnosticCaseInsertNoDiagnosticEntitlement() {
        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        Case testCase = ZTS_DataUtilityTest.createCases(1, diagRecordTypeId)[0];

        delete retrieveDiagnosticsEntitlements();

        Test.startTest();
            insert testCase;
        Test.stopTest();

        Case updatedCase = [SELECT Id, EntitlementId FROM Case WHERE Id =: testCase.Id];

        system.assertEquals(null, updatedCase.EntitlementId, 
            'Entitlement was set unexpectedly.');
    }
    
 private static List<Entitlement> retrieveDiagnosticsEntitlements() {
        return  [
            SELECT Id
            FROM Entitlement
            WHERE Name =: CaseService.DIAGNOSTICS_ENTITLEMENT_NAME
            AND SlaProcess.Name =: CaseService.DIAGNOSTICS_ENTITLEMENT_NAME
            AND Account.Name =: CaseService.DIAGNOSTICS_ACCOUNT_NAME];
        
    }    
    
  private static Account retrieveAccountByLISOrgCode(String orgCode) {
        return retrieveAccountsByLISOrgCode(new List<String> {orgCode})[0];
    }
 
     private static Contact retrieveContactByRefLabsContactEmail(string email) {
        return [
            SELECT Id
            FROM Contact
            WHERE RefLabs_Contact_Email__c =: email
            LIMIT 1];
    }
  private static List<Case> retrieveExistingRefLabsOnboardingCases(Id parentAccountId) {
        return [
            SELECT Id, Status, Has_RefLabs_Multiple_Ship_To__c
            FROM Case
            WHERE AccountId =: parentAccountId
            AND RecordTypeId =: refLabsOnboardingRecordtypeId
        ];
    }
    
private static List<Address__c> retrieveShipToAddresses(List<Id> accountIds) {
        return [
            SELECT Id, Reference_Labs_Ship_to__c, ZTS_EU_Account__c
            FROM Address__c
            WHERE ZTS_EU_Account__c in: accountIds
            AND ZTS_EU_Address_Type__c = 'Ship To'
        ];
    }
    
 private static List<Address__c> retrieveShipToAddresses(Id accountId) {
        return retrieveShipToAddresses(new List<Id> {accountId});
    }

 private static List<Case> retrieveMdmChildCases(List<Id> parentCaseIds) {
        return [
            SELECT Id, Subject, Description, AccountId, ParentId, OwnerId, RecordTypeId, Type, Sub_Type_2__c, ContactId, Origin
            FROM Case 
            WHERE ParentId in: parentCaseIds];
    }
    
  private static List<Case> retrieveMdmChildCases(Id parentCaseId) {
        return retrieveMdmChildCases(new List<Id>{parentCaseId});
    }
    
 private static List<Account> retrieveAccountsByLISOrgCode(List<String> orgCodes) {
        return [
            SELECT ID, LIS_Org_Code__c, ZTS_EU_Market__c
            FROM Account
            WHERE LIS_Org_Code__c in: orgCodes
        ];
    }
 private static void setBypasses(){
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('BatchDetailTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_CaseContactTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_CaseProductTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_AnimalTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_CaseAnimalTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_AssessmentTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_EventNarrativeTriggerHandler');
        DispatchTriggerHandler.bypass('CSE_VedDraEventTriggerHandler');
        CustomSettingService.setTriggerBypass('ZTS_EU_ServiceRequest', true);
    }
    private static void clearBypasses(){
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
        DispatchTriggerHandler.clearBypass('AddressTriggerHandler');
        DispatchTriggerHandler.clearBypass('BatchDetailTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_CaseContactTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_CaseProductTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_AnimalTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_CaseAnimalTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_AssessmentTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_EventNarrativeTriggerHandler');
        DispatchTriggerHandler.clearBypass('CSE_VedDraEventTriggerHandler');
        CustomSettingService.setTriggerBypass('ZTS_EU_ServiceRequest', false);
    }


}