/**
* @description       : Test class for the SL_CaseTriggerHandler class. (JIRA Ticket LIGHTNI-1662)
* @author            : Akshay Agrawal @ [Unknown]
* @group             : 
* @last modified on  : 04-04-2023
* @last modified by  : Harvinder Kaur @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   10-16-2019   Akshay Agrawal @ [Unknown]  Initial Version
* 1.1   UNKNOWN      Poonami Dalvi @ [Unknown]   Unknown Updates
* 1.2   03-23-2022   Ethan Hirsch @ Zoetis Inc   Add additional assertions and unit tests for logic around Refs Onboarding Type Case Address logic
* 1.3   03-24-2022   Ethan Hirsch @ Zoetis Inc   Add additional unit tests to verify null handling and updating for a Refs Onboarding Type Case.
* 1.4   03-31-2022   Ethan Hirsch @ Zoetis Inc   Fix Unit Test failures due to validation rules on ZTS_US_VedDRA_Event__c.ZTS_US_VedDRA_Coding__c by setting ZTS_US_VEDDRA_Status__c to Official
*                                                Fix Unit Test failures caused by too many SOQL Queries in testSetup by disabling triggers while setting up data.
* 1.5 04-12-2022     Ethan Hirsch @ Zoetis Inc   Update testAddressLogicForRefsOnboardingBeforeUpdateMultipleShipTosAllowUpdate to bypass the Address Trigger
* 1.6   05-09-2022   Ethan Hirsch @ Zoetis Inc   Remove testBeforeInsertUpdateOnBoardingCaseStatus as coverage for this logic is now in DiagnosticCaseServiceTest
* 1.7   05-20-2022   Ethan Hirsch @ Zoetis Inc   Fix a bug in testBeforeInsertRefLabsPortalCasesConsult where it relied on the Service Cloud Setting Metadata's 
*                                                Ref_Labs_Customer_Service_Support_Queue__c field to match the Case Mapping Type for Consult's Queue.
* 1.8   07-12-2022   Ethan Hirsch @ Zoetis Inc   Remove tests for validateUnclassifiableAdverseEventForApproval and this has been moved to VmipsCaseServiceTest
* 1.9   11-03-2022   Ethan Hirsch @ Zoetis Inc   Update testBeforeInsertRefLabsPortalCasesSupport and testBeforeInsertRefLabsPortalCasesConsult to confirm Market is set correctly.
*                                                Update testBeforeInsertRefLabsPortalCasesMultipleContacts to avoid an error with not being able to edit a Case in another Market.
* 1.10  11-15-2022   Ethan Hirsch @ Zoetis Inc   Update cloneRelatedList_Test to verify a Case can be cloned with Event Narrative and Case Products are cloned properly
* 1.11  04-04-2023   Harvinder Kaur @ Zoetis Inc Removed Deactivated picklist values from ZTS_US_Interval_Unit__c
**/
@isTest
public with sharing class SL_CaseTriggerHandler_Test
{
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
    
    @isTest
    public static void testHandler()
    {
        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        List<Account> lstAcc = new List<Account>( [SELECT Id FROM Account ORDER BY ZTS_EU_Market__c] );
        List<Contact> lstCon = new List<Contact>( [SELECT Id FROM Contact ORDER BY ZTS_EU_Market__c] );
        Diagnostics_Error_Codes__c objErrorCode = (Diagnostics_Error_Codes__c)SL_TestDataFactory.createSObject(new Diagnostics_Error_Codes__c(Name = 'test Message', Active__c = true), true);
        SAP_Material__c objSAPM = (SAP_Material__c)SL_TestDataFactory.createSObject(new SAP_Material__c(SAP_Item_Category_Group__c = 'NORM', SAP_Product_Number__c = 'TestProductID132'), true);
        Product2 objProd = (Product2)SL_TestDataFactory.createSObject(new Product2(Name = 'Test Product',
                                                                                   IsActive = true,
                                                                                   ProductCode = '123456',
                                                                                   SAP_Material__c = objSAPM.Id), true);
        List<Case> lstCases = new List<Case>();
        for(Integer i=0; i<2; i++) {
            lstCases.add(new Case(AccountId = lstAcc[0].Id,
                                  ContactId = lstCon[0].Id,
                                  RecordTypeId = diagRecordTypeId,
                                  Status = 'New',
                                  Origin = 'Email',
                                  Type = 'Other',
                                  Subject = 'Test Market Queue Assignment',
                                  Description = 'Test',
                                  ZTS_EU_Needed_By__c = Datetime.now()));
            
        }
        lstCases[0].Primary_Error_Code__c = objErrorCode.Id;
        lstCases[0].Primary_Consumable__c = objProd.Id;
        lstCases[0].Primary_Lot_Num_Unknown__c = true;
        insert lstCases;
        System.assertEquals(2, [SELECT Id FROM Case WHERE Skip_L1__c = true].size());
        lstCases = [SELECT Id, Subject FROM Case WHERE Skip_L1__c = true];
        for(Case obj : lstCases) {
            obj.Subject = 'Test Market Queue Assignment Update';
            obj.AccountId = lstAcc[1].Id;
            obj.ContactId = lstCon[1].Id;
        }
        lstCases[0].ContactId = null;
        lstCases[0].Primary_Lot_Num__c = '123456';
        lstCases[0].Primary_Lot_Num_Unknown__c = false;
        Test.startTest();
        update lstCases;
        Delete [Select Id From Case_Contact__c];
        lstCases[1].ContactId = lstCon[0].Id;
        // update lstCases[1];
        // System.assertEquals(2, [SELECT Id FROM Case WHERE AccountId = :lstAcc[1].Id].size());
        User u = getUserRecord('System Administrator','Canada');
        System.runAs(u){
            Case_Consumable__c objCC = (Case_Consumable__c)SL_TestDataFactory.createSObject(new Case_Consumable__c( Case__c = lstCases[1].Id,
                                                                                                                   Lot_Num_Unknown__c = true,
                                                                                                                   Consumable_Product__c = objProd.Id,
                                                                                                                   Diagnostics_Error_Code__c = objErrorCode.Id,
                                                                                                                   Primary__c = true,
                                                                                                                   Rotor_Credit__c = 1), true);
            Rotor_Transaction__c objTxn = [SELECT Id, Locked__c, Case_Consumable__c FROM Rotor_Transaction__c  LIMIT 1];
            objTxn.Locked__c = true;
            update objTxn;
            Test.stopTest();
            try
            {
                lstCases[1].Primary_Error_Code__c = objErrorCode.Id;
                lstCases[1].Primary_Consumable__c = objProd.Id;
                lstCases[1].Primary_Lot_Num__c = '123456';
                update lstCases[1];
                lstCases[1].Primary_Error_Code__c = null;
                lstCases[1].Primary_Consumable__c = null;
                update lstCases[1];
            }
            
            catch(DmlException dex)
            {
                String errorMessages = '';
                for (Integer i = 0; i < dex.getNumDml(); i++) {
                    System.debug(CASE_UPD_ERROR_ORIGIN);
                    System.debug('DML Message: ' + dex.getDmlMessage(i));
                    errorMessages += dex.getDmlMessage(i) + '\n';
                }
                errorMessages.removeEnd('\n');
                ZTS_EU_Logger.notify = true;
                ZTS_EU_Logger.error(errorMessages,null, CASE_UPD_ERROR_ORIGIN);
            }
            
            
            try
            {
                lstCases[0].Primary_Error_Code__c = null;
                lstCases[0].Primary_Consumable__c = null;
                lstCases[0].Primary_Lot_Num_Unknown__c = false;
                update lstCases[0];
            }
            
            catch(DmlException dex)
            {
                String errorMessages = '';
                for (Integer i = 0; i < dex.getNumDml(); i++) {
                    System.debug(CASE_UPD_ERROR_ORIGIN);
                    System.debug('DML Message: ' + dex.getDmlMessage(i));
                    errorMessages += dex.getDmlMessage(i) + '\n';
                }
                errorMessages.removeEnd('\n');
                ZTS_EU_Logger.notify = true;
                ZTS_EU_Logger.error(errorMessages,null, CASE_UPD_ERROR_ORIGIN);
            }
        }
        SL_AvoidCaseConsumableRecursion objCntrl = new SL_AvoidCaseConsumableRecursion();
        SL_AvoidCaseConsumableRecursion.isCaseUpdate = false;
    }
    
    @isTest
    public static void test_SL_CaseTriggerHandler()
    {
        
        List<Account> lstAcc = new List<Account>( [SELECT Id FROM Account ORDER BY ZTS_EU_Market__c] );
        List<Contact> lstCon = new List<Contact>( [SELECT Id FROM Contact ORDER BY ZTS_EU_Market__c] );
        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        Diagnostics_Error_Codes__c objErrorCode = (Diagnostics_Error_Codes__c)SL_TestDataFactory.createSObject(new Diagnostics_Error_Codes__c(Name = 'test Message', Active__c = true), true);
        SAP_Material__c objSAPM = (SAP_Material__c)SL_TestDataFactory.createSObject(new SAP_Material__c(SAP_Item_Category_Group__c = 'NORM', SAP_Product_Number__c = 'TestProductID132'), true);
        Product2 objProd = (Product2)SL_TestDataFactory.createSObject(new Product2(Name = 'Test Product',
                                                                                   IsActive = true,
                                                                                   ProductCode = '123456',
                                                                                   SAP_Material__c = objSAPM.Id), true);
        List<Case> lstCases = new List<Case>();
        for(Integer i=0; i<2; i++) {
            lstCases.add(new Case(AccountId = lstAcc[0].Id,
                                  ContactId = lstCon[0].Id,
                                  RecordTypeId = diagRecordTypeId,
                                  Status = 'New',
                                  Origin = 'Email',
                                  Type = 'Other',
                                  Subject = 'Test Market Queue Assignment',
                                  Rotor_Credit__c = 10,
                                  Description = 'Test'));
            
        }
        lstCases[0].Primary_Error_Code__c = objErrorCode.Id;
        lstCases[0].Primary_Consumable__c = objProd.Id;
        lstCases[0].Primary_Lot_Num_Unknown__c = true;
        User u = getUserRecord('System Administrator','Canada');
        System.runAs(u){
            if(NULL <> lstCases && lstCases.size() > 0){
                insert lstCases;
            }
            System.assertEquals(2, [SELECT Id FROM Case WHERE Skip_L1__c = true].size());
            //lstCases = [SELECT Id, Subject FROM Case WHERE Skip_L1__c = true];
            for(Case obj : lstCases) {
                obj.Subject = 'Test Market Queue Assignment Update';
                obj.AccountId = lstAcc[1].Id;
                obj.ContactId = lstCon[1].Id;
            }
            lstCases[0].ContactId = null;
            lstCases[0].Primary_Lot_Num__c = '123456';
            lstCases[0].Primary_Lot_Num_Unknown__c = false;
            Test.startTest();
            update lstCases;
            Case_Consumable__c objCC1 = [Select Id, Rotor_Credit__c, Primary__c From Case_Consumable__c Where Rotor_Credit__c =10 Limit 1];
            objCC1.Rotor_Credit__c = 50;
            SL_AvoidCaseConsumableRecursion.isCaseUpdate = true;
            update objCC1;
            Rotor_Transaction__c objRT = [SELECT Id, Account__c, Case_Consumable__c, Locked__c
                                          FROM Rotor_Transaction__c
                                          WHERE Case_Consumable__c=: objCC1.Id];
            objRT.Locked__c = true;
            update objRT;
            for(Case obj : lstCases) {
                obj.Subject = 'Test Market Queue Assignment Update';
                obj.AccountId = lstAcc[0].Id;
                obj.ContactId = lstCon[0].Id;
            }
            try
            {
                update lstCases;
            }
            catch(Exception ex)
            {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('The Account cannot be changed once Rotor Transactions have been locked.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            
            lstCases[0].Primary_Error_Code__c = null;
            lstCases[0].Primary_Consumable__c = null;
            Case objCase = new Case(AccountId = lstAcc[0].Id,
                                    ContactId = lstCon[0].Id,
                                    RecordTypeId = diagRecordTypeId,
                                    Status = 'New',
                                    Origin = 'Email',
                                    Type = 'Other',
                                    Subject = 'Test Market Queue Assignment',
                                    Description = 'Test',
                                    Primary_Error_Code__c = objErrorCode.Id,
                                    Primary_Consumable__c = objProd.Id,
                                    Primary_Lot_Num_Unknown__c = true);
            insert objCase;
            try
            {
                objCase.Primary_Error_Code__c = null;
                objCase.Primary_Consumable__c = null;
                objCase.Primary_Lot_Num_Unknown__c = false;              
                update objCase;
            }
            catch(Exception ex)
            {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Primary Case Consumable record cannot be deleted.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest();
        }
        
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
    public static void clone_ResetFields_Test(){
        List<Account> lstAcc = new List<Account>( [SELECT Id FROM Account ORDER BY ZTS_EU_Market__c] );
        List<Contact> lstCon = new List<Contact>( [SELECT Id FROM Contact ORDER BY ZTS_EU_Market__c] );
        
        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        
        Case newCase = new Case(AccountId = lstAcc[0].Id,
                                ContactId = lstCon[0].Id,
                                RecordTypeId = diagRecordTypeId,
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Complaint',
                                Subject = 'Test Cloning case',
                                Description = 'Test',
                                Send_to_PV_Works__c = true,
                                PV_Works_Status__c = 'Completed. Case closed',
                                PV_Works_Event_Narrative__c = 'Test Narrative',
                                ZTS_EU_Sub_Type__c ='Human Exposure',
                                Adverse_Event_Start_Date__c = Date.today()
                               );
        insert newCase;
        // Clone created case
        Case clonedCase = newCase.clone(false, false, false, false);
        Test.startTest();
        // insert cloned case
        insert clonedCase;
        Test.stopTest();
        //query the cloned case, with reset fields in filter
        List<Case> clonedCases = [Select id ,PV_Works_Status__c from Case where Send_to_PV_Works__c = false
                                  and AccountId =: lstAcc[0].Id];
        // verify the list has one cloned record
        System.assertEquals(1, clonedCases.size());
        System.assertEquals(null,clonedCases[0].PV_Works_Status__c);
    }
    
    @isTest
    public static void cloneRelatedList_Test(){
        List<Case> existingCases = [SELECT ID FROM Case];
        List<Account> lstAcc = new List<Account>( [SELECT Id FROM Account ORDER BY ZTS_EU_Market__c] );
        List<Contact> lstCon = new List<Contact>( [SELECT Id FROM Contact ORDER BY ZTS_EU_Market__c] );
        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        
        Case newCase = new Case(AccountId = lstAcc[0].Id,
                                ContactId = lstCon[0].Id,
                                RecordTypeId = animal_SupportRecordTypeId,
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                Subject = 'Test Cloning case',
                                Description = 'Test',
                                Send_to_PV_Works__c = false,
                                PV_Works_Status__c = 'Completed. Case closed',
                                PV_Works_Event_Narrative__c = 'Test Narrative',
                                ZTS_EU_Sub_Type__c ='Human Exposure',
                                Adverse_Event_Start_Date__c = Date.today(),
                                // Set fields that should be cleared out
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Information_Type__c = 'Information Only'
                               );
        insert newCase;
        
        Case insertedCase = [
            SELECT Id, ZTS_US_Event_Narrative__c
            FROM Case
            WHERE Id =: newCase.Id
            LIMIT 1];
        
        // Make sure there is an Event Narrative to confirm it gets cleared out.
        // This may be created by a Flow
        if (insertedCase.ZTS_US_Event_Narrative__c == null) {
            ZTS_US_Event_Narrative__c eventNarrative = ZTS_DataUtilityTest.createEventNarratives(1, insertedCase.Id)[0];
            insert eventNarrative;
            
            insertedCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
            update insertedCase;
        }
        
        // Set the Event Narrative so it gets cloned.
        newCase.ZTS_US_Event_Narrative__c = insertedCase.ZTS_US_Event_Narrative__c;
        
        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c();
        prod1.Name = 'Simparica Test';
        prod1.CurrencyIsoCode='USD';        
        prod1.ZTS_US_MAH_Country__c = 'US';
        prod1.ZTS_US_Active_Product__c = 'Yes';
        insert prod1;
        //Insert Case Product Record
        
        Map<String, Schema.RecordTypeInfo> caseProductRecordTypeMap = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName();
        Id CaseProductRTId = caseProductRecordTypeMap.get(CASEPRODUCT_RT_ID).getRecordTypeId();
        Id nonZoetisCaseProductRecordTypeId = caseproductRecordTypeMap.get(NONZOETIS_CASEPRODUCT_RT_ID).getRecordTypeId();
        
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                                         ZTS_US_PVW_Product__c = prod1.Id,
                                                                         ZTS_US_Product_Role__c = 'Suspect Product',
                                                                         ZTS_US_Product_problem_type__c = 'Adverse Reaction',
                                                                         ZTS_US_Product_Used_Correctly__c='Yes',
                                                                         RecordTypeId = CaseProductRTId);
        
        
        ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                                         ZTS_US_Product_Role__c = 'Concomitant',
                                                                         ZTS_US_Product_Used_Correctly__c = 'Unknown',
                                                                         RecordTypeId = nonZoetisCaseProductRecordTypeId);
        insert new List<ZTS_US_Case_Product__c>{caseProduct1, caseProduct2} ; 
            // Clone created case
            Case clonedCase = newCase.clone(false, false, false, false);
        
        Test.startTest();
        // insert cloned case
        insert clonedCase;
        Test.stopTest();
        //query the cloned case, with reset fields in filter
        List<Case> clonedCases = [Select id from Case WHERE Id not in: existingCases];
        // verify the list has one cloned record
        System.assertEquals(2, clonedCases.size());
        
        // Confirm fields are cleared and Case Products are cloned
        clonedCase = [
            SELECT Id, ZTS_US_Date_First_Valid__c, ZTS_US_First_Received_Date__c, ZTS_US_Event_Narrative__c, ZTS_US_Information_Type__c,
            (
                SELECT Id, ZTS_US_PVW_Product__c, ZTS_US_Product_Role__c, ZTS_US_Product_problem_type__c, 
                ZTS_US_Product_Used_Correctly__c, RecordTypeId
                FROM Case_Products__r)
            FROM Case
            WHERE Id =: clonedCase.Id
            LIMIT 1];
        System.assertEquals(null, clonedCase.ZTS_US_Date_First_Valid__c, 'Date First Valid was not cleared as expected.');
        System.assertEquals(null, clonedCase.ZTS_US_First_Received_Date__c, 'First Received Date was not cleared as expected.');
        System.assertNotEquals(insertedCase.ZTS_US_Event_Narrative__c, clonedCase.ZTS_US_Event_Narrative__c,
                               'Event Narrative was not set to a different value as expected.');
        
        System.assertEquals(null, clonedCase.ZTS_US_Information_Type__c, 'Information Type was not cleared as expected.');
        
        System.assertEquals(2, clonedCase.Case_Products__r.size(), 'Cases were not cloned as expected.');
        
        Boolean foundCaseProduct1 = false;
        Boolean foundCaseProduct2 = false;
        for (ZTS_US_Case_Product__c caseProduct : clonedCase.Case_Products__r) {
            ZTS_US_Case_Product__c expectedProduct;
            if (caseProduct.ZTS_US_PVW_Product__c == prod1.Id) {
                expectedProduct = caseProduct1;
                
                System.assert(!foundCaseProduct1, 'Case Product 1 was found twice unexpectedly.');
                foundCaseProduct1 = true;
            }
            else {
                expectedProduct = caseProduct2;
                
                System.assert(!foundCaseProduct2, 'Case Product 2 was found twice unexpectedly.');
                foundCaseProduct2 = true;
            }
            
            System.assertEquals(expectedProduct.ZTS_US_PVW_Product__c, caseProduct.ZTS_US_PVW_Product__c,
                                'ZTS_US_PVW_Product__c did not clone as expected.');
            System.assertEquals(expectedProduct.ZTS_US_Product_Role__c, caseProduct.ZTS_US_Product_Role__c,
                                'ZTS_US_Product_Role__c did not clone as expected.');
            
            System.assertEquals(expectedProduct.ZTS_US_Product_problem_type__c, caseProduct.ZTS_US_Product_problem_type__c,
                                'ZTS_US_Product_problem_type__c did not clone as expected.');
            
            System.assertEquals(expectedProduct.ZTS_US_Product_Used_Correctly__c,
                                caseProduct.ZTS_US_Product_Used_Correctly__c,
                                'ZTS_US_Product_Used_Correctly__c did not clone as expected.');
            
            System.assertEquals(expectedProduct.RecordTypeId, caseProduct.RecordTypeId,
                                'RecordTypeId did not clone as expected.');
        }
    }
    @isTest
    public static void checkAppliedCreditsTest(){
        List<Account> lstAcc = new List<Account>( [SELECT Id FROM Account ORDER BY ZTS_EU_Market__c limit 1] );
        List<Contact> lstCon = new List<Contact>( [SELECT Id FROM Contact ORDER BY ZTS_EU_Market__c limit 1] );
        
        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        Diagnostics_Error_Codes__c objErrorCode = (Diagnostics_Error_Codes__c)SL_TestDataFactory.createSObject(new Diagnostics_Error_Codes__c(Name = 'test Message', Active__c = true), true);
        
        SAP_Material__c objSAPM = (SAP_Material__c)SL_TestDataFactory.createSObject(new SAP_Material__c(SAP_Item_Category_Group__c = 'NORM', SAP_Product_Number__c = 'TestProductID132'), true);
        
        Product2 objProd = (Product2)SL_TestDataFactory.createSObject(new Product2(Name = 'Test Product',
                                                                                   IsActive = true,
                                                                                   ProductCode = '123456',
                                                                                   SAP_Material__c = objSAPM.Id), true);
        
        
        Case newCase = new Case(AccountId = lstAcc[0].Id,
                                ContactId = lstCon[0].Id,
                                RecordTypeId = diagRecordTypeId,
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Complaint',
                                Subject = 'Test Cloning case',
                                Description = 'Test',
                                Primary_Consumable__c = objProd.id,
                                Rotor_Credit__c = 30,
                                Primary_Lot_Num_Unknown__c = true
                               );
        User u = getUserRecord('System Administrator','Canada');
        System.runAs(u){
            insert newCase;
        }
        // check if case consumable is created
        Case_Consumable__c objCC1 = [Select Id, Rotor_Credit__c,Case__c, Primary__c From Case_Consumable__c Where Case__c =: newCase.id];
        System.assertEquals(objCC1.Rotor_Credit__c, 30,'Assertion Failed. Rotor Credits did not match.');
        System.assertEquals(objCC1.Case__c, newCase.Id,'Assertion Failed. Incorrect case');
        // check for rotor credit record
        Rotor_Transaction__c rotor_transaction = [Select Id,Rotor_Credit__c ,Locked__c, Case_Consumable__c,Product__c from Rotor_Transaction__c
                                                  where Case_Consumable__c = :objCC1.Id and Product__c =:objProd.id limit 1];
        rotor_transaction.Locked__c = true;
        update rotor_transaction;
        Test.startTest();
        //Try updating Rotor Credits on case
        try{
            newCase.Rotor_Credit__c = 35;
            update newCase;
        }catch(Exception ex){
            //update fails
            System.assertEquals(true,ex.getMessage().contains('Cannot be modified'));
        }
        Test.stopTest();
    }
    
    // Test for Case Validations when Case meets required criteria
    @isTest
    public static void testSendCaseForApproval()
    {
        setBypasses();
        Account objAcc = (Account) SL_TestDataFactory.createSObject
            (   new Account
             (   Name = 'Test Account'
              ,   ZTS_EU_Market__c = 'United States'
              ,   ZTS_EU_VAT_Code__c = '00011'
              ,   ZTS_EU_Account_Status__c = 'Active'
              ,   ZTS_EU_Zip_Postal_Code__c = '07306'
              ,   LIS_Org_Code__c = '1000117840'
              ,   BillingPostalCode = '12345'
              ,   BillingCity = 'testTown'
              ,   BillingState = 'NY'
              ,   BillingStreet = '123 Test'
             )
             ,   true
            );
        
        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Phone',
                                Type = 'Animal Complaint',
                                ZTS_US_Source__c = 'Human Patient',
                                ZTS_US_Information_Type__c = 'Erred',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Country__c = 'USA',
                                ZTS_US_Is_it_serious_CA__c = 'No',
                                ZTS_US_Date_First_Valid__c = Date.today(),
                                ZTS_US_Do_Not_Notify_Reporter__c = true,
                                AccountId = objAcc.Id );
        insert newCase;
        
        
        
        //Insert Contact
        Contact contact = new Contact(
            LastName = 'Doe'
            ,   FirstName = 'Testone'
            ,   ZTS_US_Profession__c = 'Consultant'
            ,   ZTS_US_Job_Function__c = 'Practice Mgt'
            ,   MailingStreet = '20 W 34th St'
            ,   MailingCity = 'New York'
            ,   MailingState = 'NY'
            ,   MailingPostalCode = '10001'
            ,   MailingCountry = 'US'
            ,   Interface_Email__c = 'test@zoetis.com');
        insert contact;
        
        //Insert Case Contact
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id, ZTS_US_Primary_Reporter__c=true,Sequence__c='1');
        insert caseContact;
        
        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c();
        prod1.Name = 'Simparica Test';
        prod1.CurrencyIsoCode='USD';        
        prod1.ZTS_US_MAH_Country__c = 'US';
        prod1.ZTS_US_Active_Product__c = 'Yes'; 
        prod1.ZTS_US_Formulation_Text__c = 'test';
        prod1.ZTS_US_Brand__c = 'Test Brand';
        insert prod1;
        
        //Insert Case Product Record
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                                         ZTS_US_PVW_Product__c = prod1.Id,
                                                                         ZTS_US_Previous_Exposure__c = 'No',
                                                                         ZTS_US_Product_Role__c = 'Suspect Product',
                                                                         ZTS_US_Product_Used_Correctly__c ='Yes',
                                                                         ZTS_US_Product_problem_type__c = 'Ecotoxicity',
                                                                         ZTS_US_Start_Date__c = date.today(),
                                                                         ZTS_US_Serial_Number__c = 'test',
                                                                         ZTS_US_Route__c = 'Implant',
                                                                         ZTS_US_Reason_for_use__c = 'testy', 
                                                                         ZTS_US_Qualifier__c = 'Invalid',
                                                                         ZTS_US_Previous_Reaction__c = 'No',
                                                                         ZTS_US_Ongoing__c = True,
                                                                         ZTS_US_Product_Lot__c = 'test',
                                                                         ZTS_US_Per__c = 4.5,
                                                                         //ZTS_US_Interval_Unit__c = 'Minutes', for TPDEV-425
                                                                         ZTS_US_Interval_Unit__c = 'mg',
                                                                         ZTS_US_Frequency_Unit__c = 'Minutes',
                                                                         ZTS_US_Frequency__c = 4 ,
                                                                         RecordTypeId = CaseProductRTId,
                                                                         ZTS_US_Expiry_Date__c = Date.today(), 
                                                                         ZTS_US_Duration_Unit__c = 'Minutes', 
                                                                         ZTS_US_Duration__c = 8, 
                                                                         ZTS_US_Dose_Unit__c = 'Bolus', 
                                                                         ZTS_US_Product_Agency__c = 'FDA',
                                                                         ZTS_US_Dose__c = 5.4,
                                                                         ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable',
                                                                         ZTS_US_Administered_By__c = 'Attending Vet',
                                                                         Sequence__c='1');
        insert caseProduct1;
        
        Batch_Detail__c batchDetail1 = new Batch_Detail__c(ZTS_US_Case_Product__c=caseProduct1.Id,ZTS_US_Product_Lot__c='123',Sequence__c='1');
        insert batchDetail1;
        
        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c localAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
            ( new ZTS_US_Assessment__c
             ( ZTS_US_Local_Assessment__c = 'FDA'
              , ZTS_US_Is_it_serious__c ='Yes'
              , RecordTypeId = localAssessmentRTId
              , ZTS_US_Case__c = newCase.id
              , ZTS_US_Reportability__c = 'Non-Reportable'
              , ZTS_US_Assessor__c = UserInfo.getUserId()
              , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
              , Sequence__c = '1'
             )
             , true
            );
        ZTS_US_Assessment_Products__c localAssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
            (new ZTS_US_Assessment_Products__c
             (ZTS_US_Assessment__c = localAssessment.Id
              ,ZTS_US_PVW_Product__c = prod1.id
             ),true
            );
        
        
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment =  (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
            ( new ZTS_US_Assessment__c
             (  ZTS_US_Expected_PA__c = 'No'
              , RecordTypeId = productAssessmentRTId
              , ZTS_US_Case__c = newCase.Id
              , ZTS_US_Dechallenge_PA__c = 'Abated'
              , ZTS_US_Rechallenge_PA__c = 'No recurrence'
              , ZTS_US_Assessment_PA__c = 'N - Unlikely/Low'
              , ZTS_US_Assessor__c = UserInfo.getUserId()
              , ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
             )
             , true
            );
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c) SL_TestDataFactory.createSObject
            (new ZTS_US_Assessment_Products__c
             (ZTS_US_Assessment__c = productAssessment.Id
              ,ZTS_US_PVW_Product__c = prod1.id
             ),true
            );
        
        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Lynx Cat', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', 
                                                             ZTS_US_Species__c='Feline', 
                                                             Age_units__c = 'Year(s)',
                                                             ZTS_US_Weight_units__c= 'Grams',
                                                             ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                             ZTS_US_Sex__c = 'Male',
                                                             ZTS_US_Weight__c = 9,
                                                             ZTS_US_Reproductive_Status__c = 'Neutered', 
                                                             ZTS_US_Breed__c = Breed1.id,
                                                             ZTS_US_Age_unit_to__c ='Minutes',
                                                             ZTS_US_Age_unit_from__c ='Minutes',
                                                             ZTS_US_Age_to__c = 5.4,
                                                             ZTS_US_Age_from__c = 5.4,
                                                             ZTS_US_Animal_condition_prior_treatment__c = 'Good'
                                                            );
        insert testUSAnimal;
        
        
        //testing - Case validation criteria met
        List<Case> testCase;
        
        
        // ******** This section of code was moved from outside startTest() to inside because data creation outside was hitting SOQL limits due to flows **********
        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, 
                                                                     ZTS_US_Animal__c = testUSAnimal.Id,
                                                                     Age_units__c = 'Year(s)',
                                                                     ZTS_US_Weight_units__c= 'Grams',
                                                                     ZTS_US_Unknown__c = 0, 
                                                                     ZTS_US_Under_Treatment__c = 0,
                                                                     ZTS_US_Total__c = 1, 
                                                                     ZTS_US_Recovered__c = 0, 
                                                                     ZTS_US_Reacted__c = 1,
                                                                     ZTS_US_Weight__c = 9,
                                                                     ZTS_US_Reproductive_Status__c = 'Neutered', 
                                                                     ZTS_US_Exposed__c = 1,
                                                                     ZTS_US_Euthanized__c = 0,
                                                                     ZTS_US_Died__c = 0,
                                                                     ZTS_US_Age_unit_to__c ='Minutes',
                                                                     ZTS_US_Age_unit_from__c ='Minutes',
                                                                     ZTS_US_Age_to__c = 5.4,
                                                                     ZTS_US_Age_from__c = 5.4,
                                                                     ZTS_US_Animal_condition_prior_treatment__c = 'Good',
                                                                     ZTS_US_Alive_with_Sequela__c = 1);
        insert caseAnimal;
        
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                 ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                 ZTS_US_Duration_text__c = '30',
                                                                                 ZTS_US_Reaction_Treated__c ='Yes',
                                                                                 ZTS_US_Treatment__c = 'Test treatment',
                                                                                 ZTS_US_Case__c = newCase.Id);
        System.debug('');
        insert eventNarrative;
        
        ZTS_US_VedDRA_Coding__c objVedraCoding = new ZTS_US_VedDRA_Coding__c(Name='Fever',
                                                                             ZTS_US_VEDDRA_Class__c = 'C',
                                                                             ZTS_US_VEDDRA_Status__c = 'Official',
                                                                             ZTS_US_Veddra_Display__c = 'Y',
                                                                             Version__c=45,
                                                                             VedDRA_Version__c = Label.Veddra_Version_For_Tests);
        insert objVedraCoding;
        
        ZTS_US_VedDRA_Coding__c objVedraCoding1 = new ZTS_US_VedDRA_Coding__c(Name='Found Dead',
                                                                              ZTS_US_VEDDRA_Class__c = 'C',
                                                                              ZTS_US_VEDDRA_Status__c = 'Official',
                                                                              ZTS_US_Veddra_Display__c = 'Y',
                                                                              Version__c=34,
                                                                              ZTS_US_Preferred_Term__c = 'Death',
                                                                              VedDRA_Version__c = Label.Veddra_Version_For_Tests);
        insert objVedraCoding1;
        
        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id,
                                                                        Duration_Units__c = 'Hour(s)', 
                                                                        ZTS_US_Number_of_pts_affected__c = 1, 
                                                                        ZTS_US_Start_Date__c = date.today(),
                                                                        ZTS_US_VedDRA_Coding__c =objVedraCoding.Id,
                                                                        ZTS_US_Ongoing__c = 'Yes',
                                                                        Sequence__c='1') ;
        insert testVedDRA;
        ZTS_US_VedDRA_Event__c testVedDRA1 =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id,
                                                                         Duration_Units__c = 'Hour(s)', 
                                                                         ZTS_US_Number_of_pts_affected__c = 1, 
                                                                         ZTS_US_Start_Date__c = date.today(),
                                                                         ZTS_US_VedDRA_Coding__c =objVedraCoding1.Id,
                                                                         ZTS_US_Ongoing__c = 'Yes',
                                                                         Sequence__c='2') ;
        insert testVedDRA1;
        newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        update newCase;
        clearBypasses();
        Test.startTest();
        newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
        // newCase.Status = 'Closed';
        // *************
        update newCase;
        testCase = [SELECT Id, Sync_Status__c FROM Case WHERE Id = :newCase.Id];
        Test.stopTest(); 
        System.assertEquals(VmipsCaseSyncStatusHandler.SYNC_READY, testCase[0].Sync_Status__c, 'Sync Status shows Ready when case has all the required validations.');
        
        ZTS_US_CSE_Audit_Trail__c[] auditTrails = [SELECT Id,Sequence_Lock__c FROM ZTS_US_CSE_Audit_Trail__c WHERE Case__c = : newCase.Id];
        for(ZTS_US_CSE_Audit_Trail__c auditTrail:auditTrails){
            system.assertEquals(true,auditTrail.Sequence_Lock__c);
        }
    }
    
    // Test for Case Validations when criteria is not met
    @isTest
    public static void testSendCaseForApprovalInvalid()
    {
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation- error message',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Erred',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today());
        insert newCase;
        //testing - Case validation criteria not met
        Boolean expectedExceptionThrown = false;
        Test.startTest();
        try
        { 
            newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
            // newCase.Status = 'Closed';
            update newCase;
        }
        catch(Exception ex)
        {
            expectedExceptionThrown = true;
        }
        Test.stopTest();
        System.assertNotEquals(false, expectedExceptionThrown, 'The case shows an error message with missing required validations needed for it to be sent for approval.');  
    }
    
    // Test for Case Validations when criteria is not met for Case Products
    @isTest
    public static void testSendCaseForApprovalInvalidProducts()
    {
        setBypasses();
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animal_SupportRecordTypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint');
        insert newCase;
        //Insert Contact
        Contact contact = new Contact(
            LastName = 'Doe'
            ,   FirstName = 'Testone'
            ,   ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID'
            ,   ZTS_US_Profession__c = 'Consultant'
            ,   ZTS_US_Job_Function__c = 'Operations');
        insert contact;
        //Insert Case Contact
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id);
        insert caseContact;
        //Insert Breed
        ZTS_US_Breed__c testBreed0 = new ZTS_US_Breed__c(Name = 'Boxer', ZTS_US_Species__c = 'Feline');
        insert testBreed0;
        //Insert Animal
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Tessjyyy'
                                                       ,ZTS_US_Breed__c = testBreed0.Id
                                                       ,ZTS_US_Species__c = 'Feline'
                                                       ,ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID'
                                                       ,ZTS_US_Age_from__c = 6.1
                                                       ,ZTS_US_Age_unit_from__c = 'Day(s)'
                                                       ,ZTS_US_Date_of_Birth__c = date.today()-500);
        insert animal;
        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = animal.Id,
                                                                     ZTS_US_Total__c = 1,  ZTS_US_Exposed__c = 1,ZTS_US_Reacted__c = 1, ZTS_US_Alive_with_Sequela__c = 1);
        insert caseAnimal;
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                 ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                 ZTS_US_Duration_text__c = '30',
                                                                                 ZTS_US_Case__c = newCase.Id);
        insert eventNarrative;
        
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
        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, Duration_Units__c = 'Hour(s)', ZTS_US_Number_of_pts_affected__c = 1, ZTS_US_Start_Date__c = date.today()-1, ZTS_US_Ongoing__c = 'Yes');
        insert testVedDRA;
        newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        // newCase.Status = 'Closed';
        //testing - Case validation criteria met
        clearBypasses();
        Test.startTest();
        Boolean expectedExceptionThrown = false;
        try{
            newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
            update newCase;
        }catch(Exception ex){      
            
            expectedExceptionThrown = true;
            // expectedExceptionThrown = ex.getMessage().contains(SL_CaseTriggerHandler.CASE_MISSING_TEXT + SL_CaseTriggerHandler.CASE_PRODUCTS_ERROR + SL_CaseTriggerHandler.CASE_ERROR_TEXT);            
        }
        
        Test.stopTest();   
        System.assertNotEquals(false, expectedExceptionThrown, 'The case shows an error message with missing required validations needed for it to be sent for approval.');      
    }
    // Test for Case Validations when criteria is not met for Case Animals
    @isTest
    public static void testSendCaseForApprovalInvalidAnimal()
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
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                 ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                 ZTS_US_Duration_text__c = '30',
                                                                                 ZTS_US_Case__c = newCase.Id);
        insert eventNarrative;
        
        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, Duration_Units__c = 'Hour(s)', ZTS_US_Number_of_pts_affected__c = 1, ZTS_US_Start_Date__c = date.today()-1, ZTS_US_Ongoing__c = 'Yes');
        insert testVedDRA;
        
        ZTS_US_Assessment__c testAssessment = (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
            (   new ZTS_US_Assessment__c
             (    ZTS_US_Dechallenge_PA__c = 'Abated',
              ZTS_US_Expected_PA__c = 'Yes',
              ZTS_US_Case__c = newCase.id
             )
             ,   true
            );
        
        newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
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
    
    // Test for Case Validations when criteria is not met for Case Contacts
    @isTest
    public static void testSendCaseForApprovalInvalidContact()
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
        //Insert Breed
        ZTS_US_Breed__c testBreed = new ZTS_US_Breed__c(Name = 'Boxer', ZTS_US_Species__c = 'Feline');
        insert testBreed;
        //Insert Animal
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Tessjyyy'
                                                       ,ZTS_US_Breed__c = testBreed.Id
                                                       ,ZTS_US_Species__c='Feline'
                                                       ,ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID'
                                                       ,ZTS_US_Age_from__c = 6.1
                                                       ,ZTS_US_Age_unit_from__c = 'Day(s)'
                                                       ,ZTS_US_Date_of_Birth__c = date.today()-500
                                                       
                                                      );
        insert animal;
        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(   ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = animal.Id,
                                                                     ZTS_US_Reacted__c = 4
                                                                     ,ZTS_US_Unknown__c = 1
                                                                     ,ZTS_US_Recovered__c = 1
                                                                     ,ZTS_US_Euthanized__c = 0
                                                                     ,ZTS_US_Died__c = 0
                                                                     ,ZTS_US_Under_Treatment__c = 1
                                                                     ,ZTS_US_Alive_with_Sequela__c = 1); 
        insert caseAnimal;
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                 ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                 ZTS_US_Duration_text__c = '30',
                                                                                 ZTS_US_Case__c = newCase.Id);
        insert eventNarrative;
        
        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, Duration_Units__c = 'Hour(s)', ZTS_US_Number_of_pts_affected__c = 1, ZTS_US_Start_Date__c = date.today()-1, ZTS_US_Ongoing__c = 'Yes');
        insert testVedDRA;
        
        ZTS_US_Assessment__c testAssessment = (ZTS_US_Assessment__c) SL_TestDataFactory.createSObject
            (   new ZTS_US_Assessment__c
             (    ZTS_US_Dechallenge_PA__c = 'Abated',
              ZTS_US_Expected_PA__c = 'Yes',
              ZTS_US_Case__c = newCase.id
             )
             ,   true
            );
        
        newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
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
    
    
    
    // Test for Event Patient Outcomes
    /*@isTest
public static void test_ValidatePatientOutcomesDied()
{
String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
Case newCase = new Case(RecordTypeId = animalRecordtypeId,
Subject = 'Test Case for Case Approval Validation',
Status = 'New',
Origin = 'Email',
Type = 'Animal Complaint',
ZTS_US_Information_Type__c = 'Erred',
ZTS_US_First_Received_Date__c = Date.today(),
ZTS_US_Date_First_Valid__c = Date.today());
insert newCase;

// Insert Breed
ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', 
ZTS_US_Species__c = 'Feline');
insert Breed1;
//Insert Animal
ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', 
ZTS_US_Species__c='Feline', 
ZTS_US_Weight_units__c= 'Grams',
ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
ZTS_US_Sex__c = 'Male',
ZTS_US_Reproductive_Status__c = 'Neutered', 
ZTS_US_Breed__c = Breed1.id,
ZTS_US_Age_unit_to__c ='Minutes',
ZTS_US_Age_unit_from__c ='Minutes',
ZTS_US_Age_to__c = 6.1,
ZTS_US_Age_from__c = 6.1,
ZTS_US_Weight__c = 9,
ZTS_US_Animal_condition_prior_treatment__c = 'Good',
ZTS_US_Died__c = 1,
ZTS_US_Reacted__c = 1,
ZTS_US_Total__c = 1,
ZTS_US_Exposed__c =1);

insert testUSAnimal;

Map<Id,ZTS_US_Animal__c> animalMap = new Map<Id,ZTS_US_Animal__c>();
animalMap.put(testUSAnimal.Id,testUSAnimal);

//Insert Case Animal
ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = testUSAnimal.Id ,ZTS_US_Total__c = 1,  ZTS_US_Exposed__c = 1,ZTS_US_Reacted__c = 1, ZTS_US_Alive_with_Sequela__c = 1
);
insert caseAnimal;

caseAnimal.ZTS_US_Died__c = 1;
caseAnimal.ZTS_US_Reacted__c = 2;
caseAnimal.ZTS_US_Total__c = 2;
caseAnimal.ZTS_US_Exposed__c =2;
update caseAnimal;

//Insert Event Narrative record
ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
ZTS_US_Outcome_of_Reaction__c = 'Euthanized',
ZTS_US_Duration_text__c = '30',
ZTS_US_Reaction_Treated__c ='Yes',
ZTS_US_Treatment__c = 'Test treatment',
ZTS_US_Case__c = newCase.Id);
insert eventNarrative;
Map<Id,ZTS_US_Event_Narrative__c> eventNarrativeMap = new Map<Id,ZTS_US_Event_Narrative__c>();
eventNarrativeMap.put(eventNarrative.Id,eventNarrative);

ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, 
Duration_Units__c = 'Hour(s)', 
ZTS_US_Number_of_pts_affected__c = 1, 
ZTS_US_Start_Date__c = date.today()-1, 
ZTS_US_Ongoing__c ='Yes') ;
insert testVedDRA;

newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;

newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
Test.startTest();
SL_CaseTriggerHandler.validateCaseAnimals(animalMap,eventNarrativeMap);
Test.stopTest(); 
ZTS_US_Event_Narrative__c eventNarrativeQuery = [SELECT Id,ZTS_US_Outcome_of_Reaction__c from ZTS_US_Event_Narrative__c WHERE Id = : eventNarrative.Id];
System.assertEquals('Died', eventNarrativeQuery.ZTS_US_Outcome_of_Reaction__c);

}
@isTest
public static void test_ValidatePatientOutcomesEuthanized()
{
String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
Case newCase = new Case(RecordTypeId = animalRecordtypeId,
Subject = 'Test Case for Case Approval Validation',
Status = 'New',
Origin = 'Email',
Type = 'Animal Complaint',
ZTS_US_Information_Type__c = 'Erred',
ZTS_US_First_Received_Date__c = Date.today(),
ZTS_US_Date_First_Valid__c = Date.today());
insert newCase;

// Insert Breed
ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', 
ZTS_US_Species__c = 'Feline');
insert Breed1;
//Insert Animal
ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', 
ZTS_US_Species__c='Feline', 
ZTS_US_Weight_units__c= 'Grams',
ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
ZTS_US_Sex__c = 'Male',
ZTS_US_Reproductive_Status__c = 'Neutered', 
ZTS_US_Breed__c = Breed1.id,
ZTS_US_Age_unit_to__c ='Minutes',
ZTS_US_Age_unit_from__c ='Minutes',
ZTS_US_Age_to__c = 6.1,
ZTS_US_Age_from__c = 6.1,
ZTS_US_Weight__c = 9,
ZTS_US_Animal_condition_prior_treatment__c = 'Good',
ZTS_US_Euthanized__c = 1,
ZTS_US_Reacted__c = 1,
ZTS_US_Total__c = 1,
ZTS_US_Exposed__c =1
);
insert testUSAnimal;

Map<Id,ZTS_US_Animal__c> animalMap = new Map<Id,ZTS_US_Animal__c>();
animalMap.put(testUSAnimal.Id,testUSAnimal);

//Insert Case Animal
ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = testUSAnimal.Id,
ZTS_US_Total__c = 1,  ZTS_US_Exposed__c = 1,ZTS_US_Reacted__c = 1, ZTS_US_Alive_with_Sequela__c = 1);
insert caseAnimal;
//Insert Event Narrative record
ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
ZTS_US_Outcome_of_Reaction__c = 'Died',
ZTS_US_Duration_text__c = '30',
ZTS_US_Reaction_Treated__c ='Yes',
ZTS_US_Treatment__c = 'Test treatment',
ZTS_US_Case__c = newCase.Id);
insert eventNarrative;
Map<Id,ZTS_US_Event_Narrative__c> eventNarrativeMap = new Map<Id,ZTS_US_Event_Narrative__c>();
eventNarrativeMap.put(eventNarrative.Id,eventNarrative);

ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, 
Duration_Units__c = 'Hour(s)', 
ZTS_US_Number_of_pts_affected__c = 1, 
ZTS_US_Start_Date__c = date.today()-1, 
ZTS_US_Ongoing__c ='Yes');
insert testVedDRA;

newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;

newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
Test.startTest();
SL_CaseTriggerHandler.validateCaseAnimals(animalMap,eventNarrativeMap);
Test.stopTest(); 
ZTS_US_Event_Narrative__c eventNarrativeQuery = [SELECT Id,ZTS_US_Outcome_of_Reaction__c from ZTS_US_Event_Narrative__c WHERE Id = : eventNarrative.Id];
System.assertEquals('Euthanized', eventNarrativeQuery.ZTS_US_Outcome_of_Reaction__c);
}
@isTest
public static void test_ValidatePatientOutcomesAlive()
{
String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
Case newCase = new Case(RecordTypeId = animalRecordtypeId,
Subject = 'Test Case for Case Approval Validation',
Status = 'New',
Origin = 'Email',
Type = 'Animal Complaint',
ZTS_US_Information_Type__c = 'Erred',
ZTS_US_First_Received_Date__c = Date.today(),
ZTS_US_Date_First_Valid__c = Date.today());
insert newCase;

// Insert Breed
ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', 
ZTS_US_Species__c = 'Feline');
insert Breed1;
//Insert Animal
ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', 
ZTS_US_Species__c='Feline', 
ZTS_US_Weight_units__c= 'Grams',
ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
ZTS_US_Sex__c = 'Male',
ZTS_US_Reproductive_Status__c = 'Neutered', 
ZTS_US_Breed__c = Breed1.id,
ZTS_US_Age_unit_to__c ='Minutes',
ZTS_US_Age_unit_from__c ='Minutes',
ZTS_US_Age_to__c = 6.1,
ZTS_US_Age_from__c = 6.1,
ZTS_US_Weight__c = 9,
ZTS_US_Animal_condition_prior_treatment__c = 'Good',
ZTS_US_Alive_with_Sequela__c = 1,
ZTS_US_Reacted__c = 1,
ZTS_US_Total__c = 1,
ZTS_US_Exposed__c =1
);
insert testUSAnimal;

Map<Id,ZTS_US_Animal__c> animalMap = new Map<Id,ZTS_US_Animal__c>();
animalMap.put(testUSAnimal.Id,testUSAnimal);

//Insert Case Animal
ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = testUSAnimal.Id,
ZTS_US_Total__c = 1,  ZTS_US_Exposed__c = 1,ZTS_US_Reacted__c = 1, ZTS_US_Alive_with_Sequela__c = 1);
insert caseAnimal;
//Insert Event Narrative record
ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
ZTS_US_Outcome_of_Reaction__c = 'Euthanized',
ZTS_US_Duration_text__c = '30',
ZTS_US_Reaction_Treated__c ='Yes',
ZTS_US_Treatment__c = 'Test treatment',
ZTS_US_Case__c = newCase.Id);
insert eventNarrative;
Map<Id,ZTS_US_Event_Narrative__c> eventNarrativeMap = new Map<Id,ZTS_US_Event_Narrative__c>();
eventNarrativeMap.put(eventNarrative.Id,eventNarrative);

ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, 
Duration_Units__c = 'Hour(s)', 
ZTS_US_Number_of_pts_affected__c = 1, 
ZTS_US_Start_Date__c = date.today()-1, 
ZTS_US_Ongoing__c ='Yes');
insert testVedDRA;

newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;

newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
Test.startTest();
SL_CaseTriggerHandler.validateCaseAnimals(animalMap,eventNarrativeMap);
Test.stopTest(); 
ZTS_US_Event_Narrative__c eventNarrativeQuery = [SELECT Id,ZTS_US_Outcome_of_Reaction__c from ZTS_US_Event_Narrative__c WHERE Id = : eventNarrative.Id];
System.assertEquals('Alive with sequelae', eventNarrativeQuery.ZTS_US_Outcome_of_Reaction__c);
}
@isTest
public static void test_ValidatePatientOutcomesRemains()
{
String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
Case newCase = new Case(RecordTypeId = animalRecordtypeId,
Subject = 'Test Case for Case Approval Validation',
Status = 'New',
Origin = 'Email',
Type = 'Animal Complaint',
ZTS_US_Information_Type__c = 'Erred',
ZTS_US_First_Received_Date__c = Date.today(),
ZTS_US_Date_First_Valid__c = Date.today());
insert newCase;

// Insert Breed
ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', 
ZTS_US_Species__c = 'Feline');
insert Breed1;
//Insert Animal
ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', 
ZTS_US_Species__c='Feline', 
ZTS_US_Weight_units__c= 'Grams',
ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
ZTS_US_Sex__c = 'Male',
ZTS_US_Reproductive_Status__c = 'Neutered', 
ZTS_US_Breed__c = Breed1.id,
ZTS_US_Age_unit_to__c ='Minutes',
ZTS_US_Age_unit_from__c ='Minutes',
ZTS_US_Age_to__c = 6.1,
ZTS_US_Age_from__c = 6.1,
ZTS_US_Weight__c = 9,
ZTS_US_Animal_condition_prior_treatment__c = 'Good',
ZTS_US_Under_Treatment__c = 1,
ZTS_US_Reacted__c = 1,
ZTS_US_Total__c = 1,
ZTS_US_Exposed__c =1
);
insert testUSAnimal;

Map<Id,ZTS_US_Animal__c> animalMap = new Map<Id,ZTS_US_Animal__c>();
animalMap.put(testUSAnimal.Id,testUSAnimal);

//Insert Case Animal
ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = testUSAnimal.Id,
ZTS_US_Total__c = 1, ZTS_US_Unknown__c = 1, ZTS_US_Reacted__c = 1, ZTS_US_Exposed__c = 1


);
insert caseAnimal;
//Insert Event Narrative record
ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
ZTS_US_Outcome_of_Reaction__c = 'Euthanized',
ZTS_US_Duration_text__c = '30',
ZTS_US_Reaction_Treated__c ='Yes',
ZTS_US_Treatment__c = 'Test treatment',
ZTS_US_Case__c = newCase.Id);
insert eventNarrative;
Map<Id,ZTS_US_Event_Narrative__c> eventNarrativeMap = new Map<Id,ZTS_US_Event_Narrative__c>();
eventNarrativeMap.put(eventNarrative.Id,eventNarrative);

ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, 
Duration_Units__c = 'Hour(s)', 
ZTS_US_Number_of_pts_affected__c = 1, 
ZTS_US_Start_Date__c = date.today()-1, 
ZTS_US_Ongoing__c ='Yes');
insert testVedDRA;

newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;

newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
Test.startTest();
SL_CaseTriggerHandler.validateCaseAnimals(animalMap,eventNarrativeMap);
Test.stopTest(); 
ZTS_US_Event_Narrative__c eventNarrativeQuery = [SELECT Id,ZTS_US_Outcome_of_Reaction__c from ZTS_US_Event_Narrative__c WHERE Id = : eventNarrative.Id];
System.assertEquals('Remains under treatment', eventNarrativeQuery.ZTS_US_Outcome_of_Reaction__c);
}
@isTest
public static void test_ValidatePatientOutcomesUnknown()
{
String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
Case newCase = new Case(RecordTypeId = animalRecordtypeId,
Subject = 'Test Case for Case Approval Validation',
Status = 'New',
Origin = 'Email',
Type = 'Animal Complaint',
ZTS_US_Information_Type__c = 'Erred',
ZTS_US_First_Received_Date__c = Date.today(),
ZTS_US_Date_First_Valid__c = Date.today());
insert newCase;

// Insert Breed
ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', 
ZTS_US_Species__c = 'Feline');
insert Breed1;
//Insert Animal
ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', 
ZTS_US_Species__c='Feline', 
ZTS_US_Weight_units__c= 'Grams',
ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
ZTS_US_Sex__c = 'Male',
ZTS_US_Reproductive_Status__c = 'Neutered', 
ZTS_US_Breed__c = Breed1.id,
ZTS_US_Age_unit_to__c ='Minutes',
ZTS_US_Age_unit_from__c ='Minutes',
ZTS_US_Age_to__c = 6.1,
ZTS_US_Age_from__c = 6.1,
ZTS_US_Weight__c = 9,
ZTS_US_Animal_condition_prior_treatment__c = 'Good',
ZTS_US_Unknown__c = 1,
ZTS_US_Reacted__c = 1,
ZTS_US_Total__c = 1,
ZTS_US_Exposed__c =1
);
insert testUSAnimal;

Map<Id,ZTS_US_Animal__c> animalMap = new Map<Id,ZTS_US_Animal__c>();
animalMap.put(testUSAnimal.Id,testUSAnimal);

//Insert Case Animal
ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = testUSAnimal.Id,
ZTS_US_Total__c = 1,  ZTS_US_Exposed__c = 1,ZTS_US_Reacted__c = 1, ZTS_US_Alive_with_Sequela__c = 1);
insert caseAnimal;
//Insert Event Narrative record
ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
ZTS_US_Outcome_of_Reaction__c = 'Euthanized',
ZTS_US_Duration_text__c = '30',
ZTS_US_Reaction_Treated__c ='Yes',
ZTS_US_Treatment__c = 'Test treatment',
ZTS_US_Case__c = newCase.Id);
insert eventNarrative;
Map<Id,ZTS_US_Event_Narrative__c> eventNarrativeMap = new Map<Id,ZTS_US_Event_Narrative__c>();
eventNarrativeMap.put(eventNarrative.Id,eventNarrative);

ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, 
Duration_Units__c = 'Hour(s)', 
ZTS_US_Number_of_pts_affected__c = 1, 
ZTS_US_Start_Date__c = date.today()-1, 
ZTS_US_Ongoing__c ='Yes');
insert testVedDRA;

newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;

newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
Test.startTest();
SL_CaseTriggerHandler.validateCaseAnimals(animalMap,eventNarrativeMap);
Test.stopTest(); 
ZTS_US_Event_Narrative__c eventNarrativeQuery = [SELECT Id,ZTS_US_Outcome_of_Reaction__c from ZTS_US_Event_Narrative__c WHERE Id = : eventNarrative.Id];
System.assertEquals('Unknown', eventNarrativeQuery.ZTS_US_Outcome_of_Reaction__c);
}
@isTest
public static void test_ValidatePatientOutcomesRecovered()
{
String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
Case newCase = new Case(RecordTypeId = animalRecordtypeId,
Subject = 'Test Case for Case Approval Validation',
Status = 'New',
Origin = 'Email',
Type = 'Animal Complaint',
ZTS_US_Information_Type__c = 'Erred',
ZTS_US_First_Received_Date__c = Date.today(),
ZTS_US_Date_First_Valid__c = Date.today());
insert newCase;

// Insert Breed
ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', 
ZTS_US_Species__c = 'Feline');
insert Breed1;
//Insert Animal
ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', 
ZTS_US_Species__c='Feline', 
ZTS_US_Weight_units__c= 'Grams',
ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
ZTS_US_Sex__c = 'Male',
ZTS_US_Reproductive_Status__c = 'Neutered', 
ZTS_US_Breed__c = Breed1.id,
ZTS_US_Age_unit_to__c ='Minutes',
ZTS_US_Age_unit_from__c ='Minutes',
ZTS_US_Age_to__c = 6.1,
ZTS_US_Age_from__c = 6.1,
ZTS_US_Weight__c = 9,
ZTS_US_Animal_condition_prior_treatment__c = 'Good',
ZTS_US_Recovered__c = 1,
ZTS_US_Reacted__c = 1,
ZTS_US_Total__c = 1,
ZTS_US_Exposed__c =1
);
insert testUSAnimal;

Map<Id,ZTS_US_Animal__c> animalMap = new Map<Id,ZTS_US_Animal__c>();
animalMap.put(testUSAnimal.Id,testUSAnimal);

//Insert Case Animal
ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = testUSAnimal.Id,
ZTS_US_Total__c = 1,  ZTS_US_Exposed__c = 1,ZTS_US_Reacted__c = 1, ZTS_US_Alive_with_Sequela__c = 1

);
insert caseAnimal;
//Insert Event Narrative record
ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
ZTS_US_Outcome_of_Reaction__c = 'Euthanized',
ZTS_US_Duration_text__c = '30',
ZTS_US_Reaction_Treated__c ='Yes',
ZTS_US_Treatment__c = 'Test treatment',
ZTS_US_Case__c = newCase.Id);
insert eventNarrative;
Map<Id,ZTS_US_Event_Narrative__c> eventNarrativeMap = new Map<Id,ZTS_US_Event_Narrative__c>();
eventNarrativeMap.put(eventNarrative.Id,eventNarrative);

ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id, 
Duration_Units__c = 'Hour(s)', 
ZTS_US_Number_of_pts_affected__c = 1, 
ZTS_US_Start_Date__c = date.today()-1, 
ZTS_US_Ongoing__c ='Yes');
insert testVedDRA;

newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;

newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
Test.startTest();
SL_CaseTriggerHandler.validateCaseAnimals(animalMap,eventNarrativeMap);
Test.stopTest(); 
ZTS_US_Event_Narrative__c eventNarrativeQuery = [SELECT Id,ZTS_US_Outcome_of_Reaction__c from ZTS_US_Event_Narrative__c WHERE Id = : eventNarrative.Id];
System.assertEquals('Recovered', eventNarrativeQuery.ZTS_US_Outcome_of_Reaction__c);
}
@isTest
public static void test_ValidatePatientOutcomes_Negative()
{
String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
Case newCase = new Case(RecordTypeId = animalRecordtypeId,
Subject = 'Test Case for Case Approval Validation',
Status = 'New',
Origin = 'Email',
Type = 'Animal Complaint',
ZTS_US_Information_Type__c = 'Erred',
ZTS_US_First_Received_Date__c = Date.today(),
ZTS_US_Date_First_Valid__c = Date.today());
insert newCase;
//Insert Event Narrative record
ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
ZTS_US_Outcome_of_Reaction__c = 'Euthanized',
ZTS_US_Duration_text__c = '30',
ZTS_US_Reaction_Treated__c ='Yes',
ZTS_US_Treatment__c = 'Test treatment',
ZTS_US_Case__c = newCase.Id);
insert eventNarrative;
Map<Id,ZTS_US_Event_Narrative__c> eventNarrativeMap = new Map<Id,ZTS_US_Event_Narrative__c>();
eventNarrativeMap.put(eventNarrative.Id,eventNarrative);
Test.startTest();
SL_CaseTriggerHandler.validateCaseAnimals(null,eventNarrativeMap);
Test.stopTest(); 
List<ZTS_US_Event_Narrative__c> eventNarrativeQuery = [SELECT Id,ZTS_US_Outcome_of_Reaction__c from ZTS_US_Event_Narrative__c WHERE Id=:eventNarrative.Id ];
System.assertEquals('Euthanized',eventNarrativeQuery[0].ZTS_US_Outcome_of_Reaction__c);
}*/
    
    @IsTest
    static void test_setEmailBody()
    {
        
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        
        Account objAcc = (Account) SL_TestDataFactory.createSObject
            (   new Account
             (   Name = 'Test Account'
              ,   ZTS_EU_Market__c = 'United States'
              ,   ZTS_EU_VAT_Code__c = '00011'
              ,   ZTS_EU_Account_Status__c = 'Active'
              ,   ZTS_EU_Zip_Postal_Code__c = '07306'
              ,   BillingPostalCode = '12345'
              ,   BillingCity = 'testTown'
              ,   BillingState = 'NY'
              ,   BillingStreet = '123 Test'
              ,   LIS_Org_Code__c = ACCOUNT1_ORG_CODE
             )
             ,   true
            );
        
        Contact objCon = (Contact) SL_TestDataFactory.createSObject
            (   new Contact
             (   LastName = 'Test'
              ,   FirstName = 'ContactName'
              ,   AccountId = objAcc.Id
              ,   ZTS_EU_Contact_type__c = 'Analyst'
              ,   ZTS_EU_Market__c = 'United States'
              ,   RefLabs_Contact_Email__c = 'test2@cse.com'
              ,   ZTS_US_Account_influence__c = 'Decision Maker'
              ,   ZTS_US_Profession__c = 'Consultant'
              ,   ZTS_US_Job_Function__c = 'Operations'
             )
             ,   true
            );
        
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Erred',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today(), 
                                AccountId = objAcc.Id,
                                ContactId = objCon.Id );
        insert newCase;
        
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
                                                                         ZTS_US_Product_Used_Correctly__c='Yes',
                                                                         ZTS_US_Product_problem_type__c = 'Lack of Efficacy',
                                                                         RecordTypeId = CaseProductRTId);
        insert caseProduct1; 
        
        List<ZTS_US_Case_Product__c> relatedCaseProducts = new List<ZTS_US_Case_Product__c>{caseProduct1};
            //Insert Event Narrative record
            ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                     ZTS_US_Outcome_of_Reaction__c = 'Euthanized',
                                                                                     ZTS_US_Duration_text__c = '30',
                                                                                     ZTS_US_Reaction_Treated__c ='Yes',
                                                                                     ZTS_US_Treatment__c = 'Test treatment',
                                                                                     ZTS_US_Case__c = newCase.Id);
        insert eventNarrative;
        
        newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        update newCase;
        
        Case aCase = [ SELECT Id, 
                      Account.Name,
                      CaseNumber, 
                      Owner.Name,
                      Account.ZTS_US_NARC_Id__c,
                      Contact.Name,
                      ZTS_US_Case_Products_Text__c,
                      ZTS_US_Event_Narrative__r.ZTS_US_Event_Narrative_Summary_Field__c,Email_Thread_Id__c
                      FROM Case 
                      WHERE Id = :newCase.Id
                     ];
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
        DispatchTriggerHandler.clearBypass('AddressTriggerHandler');
        Test.startTest();
        SL_CaseTriggerHandler handler = new SL_CaseTriggerHandler();
        String emailBody = handler.setEmailBody( aCase );
        
        Test.stopTest();
        
        System.assert( String.isNotBlank( emailBody ), 'We expect to have returned an email body' );        
        
    }
    
    
    @isTest
    static void ValidateHumanFields_Negative(){
        
        setBypasses();
        
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        
        Case testCase = new Case(Subject = 'Test Case',
                                 Status = 'New',
                                 Origin = 'Email',
                                 Type = 'Human Exposure',
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
        ZTS_US_Animal__c testHuman = new ZTS_US_Animal__c(Name = 'TestHumanfields', 
                                                          ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                          ZTS_US_Job_Occupation__c = 'Dev',
                                                          ZTS_US_Sex__c = 'Male',
                                                          ZTS_US_Species__c='Human', 
                                                          ZTS_US_Age_text__c = 6.1,
                                                          Age_units__c = 'Day(s)',
                                                          ZTS_US_Date_of_Birth__c = date.newInstance(2008, 1, 30),
                                                          ZTS_US_Weight_units__c= 'Grams',
                                                          ZTS_US_Human_Weight__c = 47,
                                                          ZTS_US_Patient_Died__c = 'No'
                                                         );
        insert testHuman;
        
        
        String humanRecordType = Schema.SObjectType.ZTS_US_Case_Animal__c.getRecordTypeInfosByDeveloperName().get('Human').getRecordTypeId();
        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = testCase.Id, 
                                                                     ZTS_US_Animal__c = testHuman.Id,
                                                                     RecordTypeId = humanRecordType,
                                                                     ZTS_US_Total__c = 1,
                                                                     ZTS_US_Unknown__c = 0, 
                                                                     ZTS_US_Under_Treatment__c = 0,
                                                                     ZTS_US_Recovered__c = 0, 
                                                                     ZTS_US_Reacted__c = 1, 
                                                                     ZTS_US_Exposed__c = 1,
                                                                     ZTS_US_Euthanized__c = 0,
                                                                     ZTS_US_Alive_with_Sequela__c = 1);
        insert caseAnimal;
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                 ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                 ZTS_US_Duration_text__c = '30',
                                                                                 ZTS_US_Reaction_Treated__c ='Yes',
                                                                                 ZTS_US_Treatment__c = 'Test treatment',
                                                                                 ZTS_US_Case__c = testCase.Id);
        insert eventNarrative;
        
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        
        
        //Product
        ZTS_US_PVW_Product__c prod = new ZTS_US_PVW_Product__c(Name = 'Simparica Test',
                                                               CurrencyIsoCode='USD',
                                                               ZTS_US_MAH_Country__c = 'US',
                                                               ZTS_US_Active_Product__c = 'Yes');
        
        insert prod;      
        
        //Case Product
        ZTS_US_Case_Product__c caseProduct = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod.Id,
                                                                        ZTS_US_Product_problem_type__c = 'Adverse Reaction',
                                                                        ZTS_US_Product_Used_Correctly__c='Yes',
                                                                        RecordTypeId = CaseProductRTId);
        
        insert caseProduct;
        
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
        String errorMessage = '';
        try{
            update testCase;
        }
        catch(Exception ex){
            System.debug('Exception from test debug '+ ex.getMessage());
            errorMessage = ex.getMessage();
        }
        
        System.assertEquals(true, String.isNotBlank(errorMessage), 'Case should give an error as related Patient record is missing data in the ZTS_US_Died__c field');
        Test.stopTest();
    }
    
    @IsTest
    static void test_insert_CaseContact()
    {
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        
        Case testCase = new Case(Subject = 'Test Case',
                                 Status = 'New',
                                 Origin = 'Email',
                                 Type = 'Human Exposure',
                                 RecordTypeId = animalRecordtypeId,                                
                                 ZTS_US_Information_Type__c = 'Erred',
                                 ZTS_US_Date_First_Valid__c = date.today()
                                );
        insert testCase;
        
        Account testAccount = new Account(Name='Test Account'
                                          ,   BillingPostalCode = '12345'
                                          ,   BillingCity = 'testTown'
                                          ,   BillingState = 'NY'
                                          ,   BillingStreet = '123 Test');
        insert testAccount;
        
        //Insert Contact
        Contact testContact = new Contact(
            LastName = 'Doe'
            ,   FirstName = 'Testone'
            ,   AccountId=testAccount.Id
            ,   ZTS_US_Profession__c = 'Consultant'
            ,   ZTS_US_Job_Function__c = 'Operations'
            ,   MailingCity = 'Cambridge'
            ,   MailingState = 'Massachusetts'
            ,   MailingStreet = '383 Somerville'
            ,   MailingPostalCode = '02141'
            ,   MailingCountry = 'USA');
        insert testContact;
        
        
        testCase.ContactId = testContact.Id;
        
        Test.startTest();
        new SL_CaseTriggerHandler().insertCaseContact( new List<Case>{ testCase } );
        Test.stopTest();
        
        List<Case_Contact__c> caseContacts = [ SELECT Id FROM Case_Contact__c WHERE Contact__c = :testContact.Id ];
        
        System.assert( !caseContacts.isEmpty(), 'We expect to have a matching case contact' );
    }
    
    
    @IsTest
    static void test_filter_for_narrative_changes()
    {
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        
        Case testCase = new Case(Subject = 'Test Case',
                                 Status = 'New',
                                 Origin = 'Email',
                                 Type = 'Human Exposure',
                                 RecordTypeId = animalRecordtypeId,                                
                                 ZTS_US_Information_Type__c = 'Erred',
                                 ZTS_US_Date_First_Valid__c = date.today()
                                );
        insert testCase;
        
        
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c testEventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                     ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                     ZTS_US_Duration_text__c = '30',
                                                                                     ZTS_US_Reaction_Treated__c ='Yes',
                                                                                     ZTS_US_Treatment__c = 'Test treatment' );
        
        insert testEventNarrative;
        
        Test.startTest();
        Case sampleNewCase = new Case( Id = testCase.Id, ZTS_US_Event_Narrative__c = testEventNarrative.Id, RecordTypeId = animalRecordtypeId );
        List<Case> triggerNew = new List<Case>{ sampleNewCase };
            Map<Id, Case> triggerOldMap = new Map<Id, Case>{ testCase.Id => testCase };
                
                
                List<Case> filteredCases = SL_CaseTriggerHelper.filterCasesForEventNarrativeChanges( triggerNew, triggerOldMap);
        
        Test.stopTest();
        
        System.assert( !filteredCases.isEmpty(), 'We expect to have filtered out a case with a changed event narrative id' );
        
    }
    
    @IsTest
    static void test_conflicting_narrative_same_update()
    {
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        
        Case testCase = new Case(Subject = 'Test Case',
                                 Status = 'New',
                                 Origin = 'Email',
                                 Type = 'Human Exposure',
                                 RecordTypeId = animalRecordtypeId,                                
                                 ZTS_US_Information_Type__c = 'Erred',
                                 ZTS_US_Date_First_Valid__c = date.today()
                                );
        
        Case secondTestCase = new Case(Subject = 'Test Case2',
                                       Status = 'New',
                                       Origin = 'Email',
                                       Type = 'Human Exposure',
                                       RecordTypeId = animalRecordtypeId,                                
                                       ZTS_US_Information_Type__c = 'Erred',
                                       ZTS_US_Date_First_Valid__c = date.today()
                                      );
        
        insert new List<Case>{ testCase, secondTestCase };
            
            
            //Insert Event Narrative record
            ZTS_US_Event_Narrative__c testEventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                         ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                         ZTS_US_Duration_text__c = '30',
                                                                                         ZTS_US_Reaction_Treated__c ='Yes',
                                                                                         ZTS_US_Treatment__c = 'Test treatment' );
        
        insert testEventNarrative;
        
        Boolean didThrowException = false;
        Test.startTest();
        
        testCase.ZTS_US_Event_Narrative__c = testEventNarrative.Id;
        secondTestCase.ZTS_US_Event_Narrative__c = testEventNarrative.Id;
        
        try 
        {
            update new List<Case>{ testCase, secondTestCase };
                }
        catch ( DMLException dmle )
        {
            didThrowException = true;
        }
        
        Test.stopTest();    
        
        System.assert( didThrowException, 'We expect to have thrown an exception on the update.' );
        
    }
    
    @IsTest
    static void test_conflicting_narrative_existing_case()
    {
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c testEventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                     ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                     ZTS_US_Duration_text__c = '30',
                                                                                     ZTS_US_Reaction_Treated__c ='Yes',
                                                                                     ZTS_US_Treatment__c = 'Test treatment' );
        
        insert testEventNarrative;
        
        Case testCase = new Case(Subject = 'Test Case',
                                 Status = 'New',
                                 Origin = 'Email',
                                 Type = 'Human Exposure',
                                 RecordTypeId = animalRecordtypeId,                                
                                 ZTS_US_Information_Type__c = 'Erred',
                                 ZTS_US_Date_First_Valid__c = date.today(), 
                                 ZTS_US_Event_Narrative__c = testEventNarrative.Id
                                );
        
        Case secondTestCase = new Case(Subject = 'Test Case2',
                                       Status = 'New',
                                       Origin = 'Email',
                                       Type = 'Human Exposure',
                                       RecordTypeId = animalRecordtypeId,                                
                                       ZTS_US_Information_Type__c = 'Erred',
                                       ZTS_US_Date_First_Valid__c = date.today()
                                      );
        
        insert new List<Case>{ testCase, secondTestCase };
            
            Boolean didThrowException = false;
        Test.startTest();
        
        secondTestCase.ZTS_US_Event_Narrative__c = testEventNarrative.Id;
        
        try 
        {
            update secondTestCase;
        }
        catch ( DMLException dmle )
        {
            didThrowException = true;
        }
        
        Test.stopTest();    
        
        System.assert( didThrowException, 'We expect to have thrown an exception on the update.' );
    }
    
    @IsTest
    static void test_event_narrative_conflict_on_insert()
    {
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        
        //Insert Event Narrative record
        ZTS_US_Event_Narrative__c testEventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                     ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                     ZTS_US_Duration_text__c = '30',
                                                                                     ZTS_US_Reaction_Treated__c ='Yes',
                                                                                     ZTS_US_Treatment__c = 'Test treatment' );
        
        insert testEventNarrative;
        
        Case testCase = new Case(Subject = 'Test Case',
                                 Status = 'New',
                                 Origin = 'Email',
                                 Type = 'Human Exposure',
                                 RecordTypeId = animalRecordtypeId,                                
                                 ZTS_US_Information_Type__c = 'Erred',
                                 ZTS_US_Date_First_Valid__c = date.today(), 
                                 ZTS_US_Event_Narrative__c = testEventNarrative.Id
                                );
        
        Case secondTestCase = new Case(Subject = 'Test Case2',
                                       Status = 'New',
                                       Origin = 'Email',
                                       Type = 'Human Exposure',
                                       RecordTypeId = animalRecordtypeId,                                
                                       ZTS_US_Information_Type__c = 'Erred',
                                       ZTS_US_Date_First_Valid__c = date.today()
                                      );
        
        insert testCase;
        
        Boolean didThrowException = false;
        Test.startTest();
        
        secondTestCase.ZTS_US_Event_Narrative__c = testEventNarrative.Id;
        
        try 
        {
            insert secondTestCase;
        }
        catch ( DMLException dmle )
        {
            didThrowException = true;
        }
        
        Test.stopTest();    
        
        System.assert( didThrowException, 'We expect to have thrown an exception on the insert.' );
    }
    
    
    @IsTest
    static void testValidateProductProblemType(){
        Id animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        //Case
        Case testCase = new Case(Status = 'Open',
                                 Origin = 'Email',
                                 Type = 'Animal Complaint',
                                 RecordTypeId = animalRecordtypeId);
        insert testCase;
        //Product
        ZTS_US_PVW_Product__c prod = new ZTS_US_PVW_Product__c(Name = 'Simparica Test',
                                                               CurrencyIsoCode='USD',
                                                               ZTS_US_MAH_Country__c = 'US',
                                                               ZTS_US_Active_Product__c = 'Yes');
        
        insert prod;      
        
        //Case Product
        ZTS_US_Case_Product__c caseProduct = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod.Id,
                                                                        ZTS_US_Product_problem_type__c = 'Adverse Reaction',
                                                                        ZTS_US_Product_Used_Correctly__c='Yes',
                                                                        RecordTypeId = CaseProductRTId);
        
        insert caseProduct;
        
        testCase.Type='Human Exposure';
        Boolean didThrowException=false;
        try{
            update testCase;
        }
        catch (exception e )
        {
            didThrowException = true;
        }
        
    }
    
    
    private static List<Case> retrieveMdmChildCases(Id parentCaseId) {
        return retrieveMdmChildCases(new List<Id>{parentCaseId});
    }
    
    @IsTest
    static void testValidateProductsUsedCorrectly(){
        Id animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        //Case
        Case testCase = new Case(Status = 'Open',
                                 Origin = 'Email',
                                 Type = 'Animal Complaint',
                                 RecordTypeId = animalRecordtypeId);
        insert testCase;
        //Product
        ZTS_US_PVW_Product__c prod = new ZTS_US_PVW_Product__c(Name = 'Simparica Test',
                                                               CurrencyIsoCode='USD',
                                                               ZTS_US_MAH_Country__c = 'US',
                                                               ZTS_US_Active_Product__c = 'Yes');
        
        insert prod;      
        
        //Case Product
        ZTS_US_Case_Product__c caseProduct = new ZTS_US_Case_Product__c(ZTS_US_Case__c = testCase.Id,
                                                                        ZTS_US_PVW_Product__c = prod.Id,
                                                                        ZTS_US_Product_problem_type__c = 'Adverse Reaction',
                                                                        ZTS_US_Product_Used_Correctly__c= 'Yes',
                                                                        RecordTypeId = CaseProductRTId
                                                                       );
        
        insert caseProduct;
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                 ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                 ZTS_US_Duration_text__c = '30',
                                                                                 ZTS_US_Reaction_Treated__c ='Yes',
                                                                                 ZTS_US_Treatment__c = 'Test treatment',
                                                                                 ZTS_US_Case__c = testCase.Id);
        
        insert eventNarrative;
        
        ZTS_US_VedDRA_Coding__c vedraCoding = new ZTS_US_VedDRA_Coding__c(Name='Fever',
                                                                          ZTS_US_VEDDRA_Class__c = 'C',
                                                                          ZTS_US_VEDDRA_Status__c = 'Official',
                                                                          ZTS_US_Veddra_Display__c = 'Y',
                                                                          Version__c=22,
                                                                          VedDRA_Version__c = Label.Veddra_Version_For_Tests
                                                                         );
        insert vedraCoding;
        
        ZTS_US_VedDRA_Event__c vedDRAEvent =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id,
                                                                         Duration_Units__c = 'Hour(s)', 
                                                                         ZTS_US_Number_of_pts_affected__c = 1, 
                                                                         ZTS_US_Start_Date__c = date.today(),
                                                                         ZTS_US_VedDRA_Coding__c =vedraCoding.Id,
                                                                         ZTS_US_Ongoing__c = 'Yes') ;
        insert vedDRAEvent;
        
        testCase.Type='Human Exposure';
        Boolean didThrowException=false;
        try{
            update testCase;
        }
        catch (exception e )
        {
            didThrowException = true;
        }
    }
    
    
    private static List<Case> retrieveMdmChildCases(List<Id> parentCaseIds) {
        return [
            SELECT Id, Subject, Description, AccountId, ParentId, OwnerId, RecordTypeId, Type, Sub_Type_2__c, ContactId, Origin
            FROM Case 
            WHERE ParentId in: parentCaseIds];
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
    
    private static List<Case> retrieveExistingRefLabsOnboardingCases(Id parentAccountId) {
        return [
            SELECT Id, Status, Has_RefLabs_Multiple_Ship_To__c
            FROM Case
            WHERE AccountId =: parentAccountId
            AND RecordTypeId =: refLabsOnboardingRecordtypeId
        ];
    }
    
    private static List<Account> retrieveAccountsByLISOrgCode(List<String> orgCodes) {
        return [
            SELECT ID, LIS_Org_Code__c, ZTS_EU_Market__c
            FROM Account
            WHERE LIS_Org_Code__c in: orgCodes
        ];
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
    
    private static void assertMdmChildCase(Case mdmCase, Case parentCase) {
        String dataRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Data_Request').getRecordTypeId();
        
        Service_Cloud_Settings__mdt serviceCloudCustomMetadata =  [
            SELECT Master_Data_Queue_ID__c  
            FROM Service_Cloud_Settings__mdt
            WHERE MasterLabel = 'DEFAULT'
            LIMIT 1];
        
        System.assertEquals(parentCase.Id, mdmCase.ParentId, 'The new case should have the Parent case assigned');
        
        System.assertEquals(MDM_CHILD_CASE_MULTIPLE_SHIP_TO, mdmCase.Subject, 
                            'The case should have the expected subject');
        
        System.assertEquals(MDM_CHILD_CASE_MULTIPLE_SHIP_TO, mdmCase.Description, 
                            'The case should have the expected Description');
        
        System.assertEquals(dataRequestRecordTypeId, mdmCase.RecordTypeId, 'Record Type should be Data Request');
        System.assertEquals(serviceCloudCustomMetadata.Master_Data_Queue_ID__c, mdmCase.OwnerId,
                            'The owner should be MDM queue');
        
        System.assertEquals(REFLABS_TYPE_MASTER_DATA, mdmCase.Type,
                            'The case should have the expected Type');
        
        System.assertEquals(REFLABS_SUBTYPE_TYPE_ACCOUNT_CHANGE, mdmCase.Sub_Type_2__c,
                            'The case should have the expected SubType');
        
        System.assertEquals(parentCase.AccountId, mdmCase.AccountId, 
                            'The new case should have the Account of the Parent Case');
        
        System.assertEquals(parentCase.ContactId, mdmCase.ContactId, 
                            'The new case should have the Contact of the Parent Case');
        
        System.assertEquals(parentCase.Origin, mdmCase.Origin, 
                            'The new case should have the Origin of the Parent Case');
    }
    
    private static List<Entitlement> retrieveDiagnosticsEntitlements() {
        return  [
            SELECT Id
            FROM Entitlement
            WHERE Name =: CaseService.DIAGNOSTICS_ENTITLEMENT_NAME
            AND SlaProcess.Name =: CaseService.DIAGNOSTICS_ENTITLEMENT_NAME
            AND Account.Name =: CaseService.DIAGNOSTICS_ACCOUNT_NAME];
        
    }
    
    @IsTest
    static void testValidateVedraCode(){
        
        Id animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        //Case
        Case testCase = new Case(Status = 'Open',
                                 Origin = 'Email',
                                 Type = 'Animal Complaint',
                                 RecordTypeId = animalRecordtypeId);
        insert testCase;
        
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
        
        
        
        
        ZTS_US_VedDRA_Coding__c vedraCoding = new ZTS_US_VedDRA_Coding__c(Name='Fever',
                                                                          ZTS_US_VEDDRA_Class__c = 'A',
                                                                          ZTS_US_VEDDRA_Status__c = 'Official',
                                                                          ZTS_US_Veddra_Display__c = 'Y',
                                                                          Version__c=22,
                                                                          VedDRA_Version__c = Label.Veddra_Version_For_Tests
                                                                         );
        insert vedraCoding;
        
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                 ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                 ZTS_US_Duration_text__c = '30',
                                                                                 ZTS_US_Reaction_Treated__c ='Yes',
                                                                                 ZTS_US_Treatment__c = 'Test treatment',
                                                                                 ZTS_US_Case__c = testCase.Id);
        
        insert eventNarrative;
        
        ZTS_US_VedDRA_Event__c vedDRAEvent =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id,
                                                                         Duration_Units__c = 'Hour(s)', 
                                                                         ZTS_US_Number_of_pts_affected__c = 1, 
                                                                         ZTS_US_Start_Date__c = date.today(),
                                                                         ZTS_US_VedDRA_Coding__c =vedraCoding.Id,
                                                                         ZTS_US_Ongoing__c = 'Yes') ;
        insert vedDRAEvent;
        
        testCase.Type='Human Exposure';
        Boolean didThrowException=false;
        try{
            update testCase;
        }
        catch (exception e )
        {
            didThrowException = true;
        }
        System.assert( didThrowException, 'We expect to have thrown an exception on the insert.' );
        
    }
    
    @IsTest
    static void testValidateInvalidVedraCode(){
        
        Id animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        //Case
        Case testCase = new Case(Status = 'Open',
                                 Origin = 'Email',
                                 Type = 'Human Exposure',
                                 RecordTypeId = animalRecordtypeId);
        insert testCase;    
        
        
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
        
        
        
        
        
        ZTS_US_VedDRA_Coding__c vedraCoding = new ZTS_US_VedDRA_Coding__c(Name='Fever',
                                                                          ZTS_US_VEDDRA_Class__c = 'H',
                                                                          ZTS_US_VEDDRA_Status__c = 'Official',
                                                                          ZTS_US_Veddra_Display__c = 'Y',
                                                                          Version__c=22,
                                                                          VedDRA_Version__c = Label.Veddra_Version_For_Tests
                                                                         );
        insert vedraCoding;
        
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                 ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                 ZTS_US_Duration_text__c = '30',
                                                                                 ZTS_US_Reaction_Treated__c ='Yes',
                                                                                 ZTS_US_Treatment__c = 'Test treatment',
                                                                                 ZTS_US_Case__c = testCase.Id);
        
        insert eventNarrative;
        
        ZTS_US_VedDRA_Event__c vedDRAEvent =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id,
                                                                         Duration_Units__c = 'Hour(s)', 
                                                                         ZTS_US_Number_of_pts_affected__c = 1, 
                                                                         ZTS_US_Start_Date__c = date.today(),
                                                                         ZTS_US_VedDRA_Coding__c =vedraCoding.Id,
                                                                         ZTS_US_Ongoing__c = 'Yes') ;
        insert vedDRAEvent;
        
        testCase.Type='Animal Complaint';
        Boolean didThrowException=false;
        try{
            update testCase;
        }
        catch (exception e )
        {
            didThrowException = true;
        }
        System.assert( didThrowException, 'We expect to have thrown an exception on the insert.' );
    }
    @isTest
    private static void testCaseSyncStatusCheck(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case testCase = new Case(RecordTypeId = animalRecordtypeId,
                                 Subject = 'Test Case for Case Approval Validation',
                                 Status = 'New',
                                 Origin = 'Phone',
                                 Type = 'Animal Complaint',
                                 ZTS_US_Information_Type__c = 'Erred',
                                 ZTS_US_First_Received_Date__c = Date.today(),
                                 ZTS_US_Date_First_Valid__c = Date.today(),
                                 Sync_Status__c='Synced Successfully with PV Works');
        insert testCase;
        Test.startTest();
        testCase.ZTS_US_Country__c = 'USA';
        update testCase;
        Case updatedCase = [SELECT ID,Sync_Status__c FROM Case WHERE Id =:testCase.Id LIMIT 1];
        system.assertEquals('Re-Approval Needed',updatedCase.Sync_Status__c);
        Test.stopTest();
    }
    @isTest
    private static void testCaseSyncStatusCheckNegative(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case testCase = new Case(RecordTypeId = animalRecordtypeId,
                                 Subject = 'Test Case for Case Approval Validation',
                                 Status = 'New',
                                 Origin = 'Phone',
                                 Type = 'Animal Complaint',
                                 ZTS_US_Information_Type__c = 'Erred',
                                 ZTS_US_First_Received_Date__c = Date.today(),
                                 ZTS_US_Date_First_Valid__c = Date.today(),
                                 Sync_Status__c='Synced Successfully with PV Works');
        insert testCase;
        Test.startTest();
        testCase.Subject = 'Update';
        update testCase;
        Case updatedCase = [SELECT ID,Sync_Status__c FROM Case WHERE Id =:testCase.Id LIMIT 1];
        
        system.assertEquals(testCase.Sync_Status__c,updatedCase.Sync_Status__c);
        Test.stopTest();
    }
    
    @isTest
    private static void testVmipsIntegrationCaseBlock(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case testCase = new Case(RecordTypeId = animalRecordtypeId,
                                 Subject = 'Test Case for Case Approval Validation',
                                 Status = 'New',
                                 Origin = 'Phone',
                                 Type = 'Animal Complaint',
                                 ZTS_US_Information_Type__c = 'Erred',
                                 ZTS_US_First_Received_Date__c = Date.today(),
                                 ZTS_US_Date_First_Valid__c = Date.today(),
                                 Sync_Status__c='Synced Successfully with PV Works');
        insert testCase;
        testCase.PVW_External_ID__c = '12345';
        update testCase;
        Test.startTest();
        testCase.Subject = 'update';
        String errorMessage = '';
        try{
            update testCase;
        }
        catch(exception e){
            errorMessage = e.getMessage();
        }
        system.assert(String.isNotBlank(errorMessage) && errorMessage.contains(VmipsCaseSyncStatusHandler.CASE_NOT_ELIGIBLE_FOR_PVW));
        Test.stopTest();
    }
    @isTest
    private static void testVmipsCloneValidation(){
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        String caseProductRecordTypeId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get('Zoetis_Product').getRecordTypeId();
        
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
        
        Case parentCase = new Case(RecordTypeId = animalRecordtypeId,
                                   Subject = 'Test Case for Case Approval Validation',
                                   Status = 'New',
                                   Origin = 'Phone',
                                   Type = 'Animal Complaint',
                                   ZTS_US_Product__c=testProduct.Id);
        insert parentCase;
        
        
        
        /*ZTS_US_Case_Product__c parentCaseProduct = new ZTS_US_Case_Product__c(ZTS_US_Case__c=parentCase.Id,RecordTypeId = caseProductRecordTypeId);
insert parentCaseProduct;*/
        Test.startTest();
        
        Case clonedCase = parentCase.clone(false, false, false, false);
        
        String errorMessage = '';
        try{
            insert clonedCase;
        }
        catch(exception e){
            errorMessage = e.getMessage();
        }
        system.assert(String.isNotBlank(errorMessage) && errorMessage.contains('must be entered prior to cloning a Case'));
        
        ZTS_US_Case_Product__c parentCaseProduct = [SELECT Id FROM ZTS_US_Case_Product__c WHERE ZTS_US_Case__c = :parentCase.Id LIMIT 1];
        system.assert(parentCaseProduct!=null);
        
        parentCaseProduct.ZTS_US_Product_Role__c = 'Suspect Product';
        parentCaseProduct.ZTS_US_Product_problem_type__c = 'Adverse Reaction';
        parentCaseProduct.ZTS_US_Product_Used_Correctly__c = 'Yes';
        update parentCaseProduct;
        
        insert clonedCase;
        system.assert(clonedCase.Id!=null);
        
        Test.stopTest();
        
    }
    // Test for Case Validations when Case meets required criteria
    @isTest
    public static void testCompanyAssessmentRequiredFields() {
        setBypasses();
        Account objAcc = (Account)SL_TestDataFactory.createSObject(new Account(
            Name = 'Test Account',
            ZTS_EU_Market__c = 'United States',
            ZTS_EU_VAT_Code__c = '00011',
            ZTS_EU_Account_Status__c = 'Active',
            ZTS_EU_Zip_Postal_Code__c = '07306',
            LIS_Org_Code__c = '1000117840',
            BillingPostalCode = '12345',
            BillingCity = 'testTown',
            BillingState = 'NY',
            BillingStreet = '123 Test'
        ), true);
        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        Case newCase = new Case(
            RecordTypeId = animal_SupportRecordTypeId,
            Subject = 'Test Case for Case Approval Validation',
            Status = 'New',
            Origin = 'Phone',
            Type = 'Animal Complaint',
            ZTS_US_Source__c = 'Human Patient',
            ZTS_US_Information_Type__c = 'Erred',
            ZTS_US_First_Received_Date__c = Date.today(),
            ZTS_US_Country__c = 'USA',
            ZTS_US_Is_it_serious_CA__c = 'No',
            ZTS_US_Date_First_Valid__c = Date.today(),
            ZTS_US_Do_Not_Notify_Reporter__c = true,
            AccountId = objAcc.Id
        );
        insert newCase;
        
        //Insert Contact
        Contact contact = new Contact(
                LastName = 'Doe'
            ,   FirstName = 'Testone'
            ,   ZTS_US_Profession__c = 'Consultant'
            ,   ZTS_US_Job_Function__c = 'Practice Mgt'
            ,   MailingStreet = '20 W 34th St'
            ,   MailingCity = 'New York'
            ,   MailingState = 'NY'
            ,   MailingPostalCode = '10001'
            ,   MailingCountry = 'US'
            ,   Interface_Email__c = 'test@zoetis.com');
        insert contact;
        
        //Insert Case Contact
        Case_Contact__c caseContact = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id, ZTS_US_Primary_Reporter__c = true, Sequence__c = '1');
        insert caseContact;
        
        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c();
        prod1.Name = 'Simparica Test';
        prod1.CurrencyIsoCode = 'USD';
        prod1.ZTS_US_MAH_Country__c = 'US';
        prod1.ZTS_US_Active_Product__c = 'Yes';
        prod1.ZTS_US_Formulation_Text__c = 'test';
        prod1.ZTS_US_Brand__c = 'Test Brand';
        insert prod1;
        
        //Insert Case Product Record
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newCase.Id,
                                                                         ZTS_US_PVW_Product__c = prod1.Id,
                                                                         ZTS_US_Previous_Exposure__c = 'No',
                                                                         ZTS_US_Product_Role__c = 'Suspect Product',
                                                                         ZTS_US_Product_Used_Correctly__c = 'Yes',
                                                                         ZTS_US_Product_problem_type__c = 'Ecotoxicity',
                                                                         ZTS_US_Start_Date__c = Date.today(),
                                                                         ZTS_US_Serial_Number__c = 'test',
                                                                         ZTS_US_Route__c = 'Implant',
                                                                         ZTS_US_Reason_for_use__c = 'testy',
                                                                         ZTS_US_Qualifier__c = 'Invalid',
                                                                         ZTS_US_Previous_Reaction__c = 'No',
                                                                         ZTS_US_Ongoing__c = true,
                                                                         ZTS_US_Product_Lot__c = 'test',
                                                                         ZTS_US_Per__c = 4.5,
                                                                         ZTS_US_Interval_Unit__c = 'mg',
                                                                         ZTS_US_Frequency_Unit__c = 'Minutes',
                                                                         ZTS_US_Frequency__c = 4,
                                                                         RecordTypeId = CaseProductRTId,
                                                                         ZTS_US_Expiry_Date__c = Date.today(),
                                                                         ZTS_US_Duration_Unit__c = 'Minutes',
                                                                         ZTS_US_Duration__c = 8,
                                                                         ZTS_US_Dose_Unit__c = 'Bolus',
                                                                         ZTS_US_Product_Agency__c = 'FDA',
                                                                         ZTS_US_Dose__c = 5.4,
                                                                         ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable',
                                                                         ZTS_US_Administered_By__c = 'Attending Vet',
                                                                         Sequence__c = '1');
        insert caseProduct1;
        
        Batch_Detail__c batchDetail1 = new Batch_Detail__c(ZTS_US_Case_Product__c = caseProduct1.Id, ZTS_US_Product_Lot__c = '123', Sequence__c = '1');
        insert batchDetail1;
        
        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c localAssessment = (ZTS_US_Assessment__c)SL_TestDataFactory.createSObject(new ZTS_US_Assessment__c(
            ZTS_US_Local_Assessment__c = 'FDA',
            ZTS_US_Is_it_serious__c = 'Yes',
            RecordTypeId = localAssessmentRTId,
            ZTS_US_Case__c = newCase.id,
            ZTS_US_Reportability__c = 'Non-Reportable',
            ZTS_US_Assessor__c = UserInfo.getUserId(),
            ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason',
            Sequence__c = '1'
        ), true);
        ZTS_US_Assessment_Products__c localAssessProduct = (ZTS_US_Assessment_Products__c)SL_TestDataFactory.createSObject(new ZTS_US_Assessment_Products__c(
            ZTS_US_Assessment__c = localAssessment.Id,
            ZTS_US_PVW_Product__c = prod1.Id
        ), true);
        
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment = (ZTS_US_Assessment__c)SL_TestDataFactory.createSObject(new ZTS_US_Assessment__c(
            ZTS_US_Expected_PA__c = 'No',
            RecordTypeId = productAssessmentRTId,
            ZTS_US_Case__c = newCase.Id,
            ZTS_US_Dechallenge_PA__c = 'Abated',
            ZTS_US_Rechallenge_PA__c = 'No recurrence',
            ZTS_US_Assessment_PA__c = 'N - Unlikely/Low',
            ZTS_US_Assessor__c = UserInfo.getUserId(),
            ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
        ), true);
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c)SL_TestDataFactory.createSObject(new ZTS_US_Assessment_Products__c(
            ZTS_US_Assessment__c = productAssessment.Id,
            ZTS_US_PVW_Product__c = prod1.Id
        ), true);
        
        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Lynx Cat', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        
        // Insert Animal
        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy', 
                                                             ZTS_US_Species__c='Feline', 
                                                             Age_units__c = 'Year(s)',
                                                             ZTS_US_Weight_units__c= 'Grams',
                                                             ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID',
                                                             ZTS_US_Sex__c = 'Male',
                                                             ZTS_US_Weight__c = 9,
                                                             ZTS_US_Reproductive_Status__c = 'Neutered', 
                                                             ZTS_US_Breed__c = Breed1.id,
                                                             ZTS_US_Age_unit_to__c ='Minutes',
                                                             ZTS_US_Age_unit_from__c ='Minutes',
                                                             ZTS_US_Age_to__c = 5.4,
                                                             ZTS_US_Age_from__c = 5.4,
                                                             ZTS_US_Animal_condition_prior_treatment__c = 'Good'
                                                            );
        insert testUSAnimal;
        
        // Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, 
                                                                     ZTS_US_Animal__c = testUSAnimal.Id,
                                                                     Age_units__c = 'Year(s)',
                                                                     ZTS_US_Weight_units__c= 'Grams',
                                                                     ZTS_US_Unknown__c = 0, 
                                                                     ZTS_US_Under_Treatment__c = 0,
                                                                     ZTS_US_Total__c = 1, 
                                                                     ZTS_US_Recovered__c = 0, 
                                                                     ZTS_US_Reacted__c = 1,
                                                                     ZTS_US_Weight__c = 9,
                                                                     ZTS_US_Reproductive_Status__c = 'Neutered', 
                                                                     ZTS_US_Exposed__c = 1,
                                                                     ZTS_US_Euthanized__c = 0,
                                                                     ZTS_US_Died__c = 0,
                                                                     ZTS_US_Age_unit_to__c ='Minutes',
                                                                     ZTS_US_Age_unit_from__c ='Minutes',
                                                                     ZTS_US_Age_to__c = 5.4,
                                                                     ZTS_US_Age_from__c = 5.4,
                                                                     ZTS_US_Animal_condition_prior_treatment__c = 'Good',
                                                                     ZTS_US_Alive_with_Sequela__c = 1);
        insert caseAnimal;
        
        // Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
                                                                                 ZTS_US_Outcome_of_Reaction__c = 'Died',
                                                                                 ZTS_US_Duration_text__c = '30',
                                                                                 ZTS_US_Reaction_Treated__c ='Yes',
                                                                                 ZTS_US_Treatment__c = 'Test treatment',
                                                                                 ZTS_US_Case__c = newCase.Id);
        insert eventNarrative;
        
        ZTS_US_VedDRA_Coding__c objVedraCoding = new ZTS_US_VedDRA_Coding__c(Name='Fever',
                                                                             ZTS_US_VEDDRA_Class__c = 'C',
                                                                             ZTS_US_VEDDRA_Status__c = 'Official',
                                                                             ZTS_US_Veddra_Display__c = 'Y',
                                                                             Version__c=22,
                                                                             VedDRA_Version__c = Label.Veddra_Version_For_Tests);
        insert objVedraCoding;
        
        ZTS_US_VedDRA_Coding__c objVedraCoding1 = new ZTS_US_VedDRA_Coding__c(Name='Found Dead',
                                                                              ZTS_US_VEDDRA_Class__c = 'C',
                                                                              ZTS_US_VEDDRA_Status__c = 'Official',
                                                                              ZTS_US_Veddra_Display__c = 'Y',
                                                                              Version__c=12,
                                                                              ZTS_US_Preferred_Term__c = 'Death',
                                                                              VedDRA_Version__c = Label.Veddra_Version_For_Tests);
        insert objVedraCoding1;
        
        ZTS_US_VedDRA_Event__c testVedDRA =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id,
                                                                        Duration_Units__c = 'Hour(s)', 
                                                                        ZTS_US_Number_of_pts_affected__c = 1, 
                                                                        ZTS_US_Start_Date__c = date.today(),
                                                                        ZTS_US_VedDRA_Coding__c =objVedraCoding.Id,
                                                                        ZTS_US_Ongoing__c = 'Yes',
                                                                        Sequence__c='1') ;
        insert testVedDRA;
        
        ZTS_US_VedDRA_Event__c testVedDRA1 =  new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.id,
                                                                         Duration_Units__c = 'Hour(s)', 
                                                                         ZTS_US_Number_of_pts_affected__c = 1, 
                                                                         ZTS_US_Start_Date__c = date.today(),
                                                                         ZTS_US_VedDRA_Coding__c =objVedraCoding1.Id,
                                                                         ZTS_US_Ongoing__c = 'Yes',
                                                                         Sequence__c='2') ;
        insert testVedDRA1;
        
        newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        newCase.ZTS_US_Is_it_serious_CA__c = 'Yes';
        update newCase;
        clearBypasses();
        
        Test.startTest();
        
        // Set the Sync_Status__c field to SYNC_READY
        newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;       
        String errorMessage = '';
        
        try {
            // Attempt to update the Case
            update newCase;
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        
        // Check if the exception message contains the expected text
        System.assert(String.isNotBlank(errorMessage) && errorMessage.contains('When Company Assessment is marked as Serious'));
        
        // Set ZTS_US_Other_CA__c to true and ZTS_US_Date_Deemed_Serious__c to today
        newCase.ZTS_US_Other_CA__c = true;
        newCase.ZTS_US_Date_Deemed_Serious__c = Date.today();
        errorMessage = '';
        
        try {
            // Attempt to update the Case again
            update newCase;
        } catch (Exception e) {
            errorMessage = e.getMessage();      
        }
        System.assert(String.isBlank(errorMessage));       
        // Stop test execution
        Test.stopTest();
    }
    
    
    @isTest
    public static void testAnimalAgeRequiredSendToPV() {
        setBypasses();
        Account objAcc = (Account)SL_TestDataFactory.createSObject(new Account(
            Name = 'Test Account',
            ZTS_EU_Market__c = 'United States',
            ZTS_EU_VAT_Code__c = '00011',
            ZTS_EU_Account_Status__c = 'Active',
            ZTS_EU_Zip_Postal_Code__c = '07306',
            LIS_Org_Code__c = '1000117840',
            BillingPostalCode = '12345',
            BillingCity = 'testTown',
            BillingState = 'NY',
            BillingStreet = '123 Test'
        ), true);
        
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        Case newCase = new Case(
            RecordTypeId = animal_SupportRecordTypeId,
            Subject = 'Test Case for Case Approval Validation',
            Status = 'New',
            Origin = 'Phone',
            Type = 'Animal Complaint',
            ZTS_US_Source__c = 'Human Patient',
            ZTS_US_Information_Type__c = 'Erred',
            ZTS_US_First_Received_Date__c = Date.today(),
            ZTS_US_Country__c = 'USA',
            ZTS_US_Is_it_serious_CA__c = 'No',
            ZTS_US_Date_First_Valid__c = Date.today(),
            ZTS_US_Do_not_notify_reporter__c = true,
            AccountId = objAcc.Id
        );
        insert newCase;
        
        // Insert Contact
        Contact contact = new Contact(
            LastName = 'Doe',
            FirstName = 'Testone',
            ZTS_US_Profession__c = 'Consultant',
            ZTS_US_Job_Function__c = 'Practice Mgt',
            MailingStreet = '20 W 34th St',
            MailingCity = 'New York',
            MailingState = 'NY',
            MailingPostalCode = '10001',
            MailingCountry = 'US',
            Interface_Email__c = 'test@zoetis.com'
        );
        insert contact;
        
        // Insert Case Contact
        Case_Contact__c caseContact = new Case_Contact__c(
            Contact__c = contact.Id,
            ZTS_US_Contact_Role__c = 'Pharmacist',
            Case__c = newCase.Id,
            ZTS_US_Primary_Reporter__c = true,
            Sequence__c = '1'
        );
        insert caseContact;
        
        // Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c();
        prod1.Name = 'Simparica Test';
        prod1.CurrencyIsoCode = 'USD';
        prod1.ZTS_US_MAH_Country__c = 'US';
        prod1.ZTS_US_Active_Product__c = 'Yes';
        prod1.ZTS_US_Formulation_Text__c = 'test';
        prod1.ZTS_US_Brand__c = 'Test Brand';
        insert prod1;
        
        // Insert Case Product Record
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                                         ZTS_US_PVW_Product__c = prod1.Id,
                                                                         ZTS_US_Previous_Exposure__c = 'No',
                                                                         ZTS_US_Product_Role__c = 'Suspect Product',
                                                                         ZTS_US_Product_Used_Correctly__c = 'Yes',
                                                                         ZTS_US_Product_problem_type__c = 'Ecotoxicity',
                                                                         ZTS_US_Start_Date__c = date.today(),
                                                                         ZTS_US_Serial_Number__c = 'test',
                                                                         ZTS_US_Route__c = 'Implant',
                                                                         ZTS_US_Reason_for_use__c = 'testy',
                                                                         ZTS_US_Qualifier__c = 'Invalid',
                                                                         ZTS_US_Previous_Reaction__c = 'No',
                                                                         ZTS_US_Ongoing__c = True,
                                                                         ZTS_US_Product_Lot__c = 'test',
                                                                         ZTS_US_Per__c = 4.5,
                                                                         ZTS_US_Interval_Unit__c = 'mg', // Assuming this is Age Units
                                                                         ZTS_US_Frequency_Unit__c = 'Minutes',
                                                                         ZTS_US_Frequency__c = 4,
                                                                         RecordTypeId = CaseProductRTId,
                                                                         ZTS_US_Expiry_Date__c = Date.today(),
                                                                         ZTS_US_Duration_Unit__c = 'Minutes',
                                                                         ZTS_US_Duration__c = 8,
                                                                         ZTS_US_Dose_Unit__c = 'Bolus',
                                                                         ZTS_US_Product_Agency__c = 'FDA',
                                                                         ZTS_US_Dose__c = 5.4,
                                                                         ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable',
                                                                         ZTS_US_Administered_By__c = 'Attending Vet',
                                                                         Sequence__c = '1'
                                                                        );
        insert caseProduct1;
        
        Batch_Detail__c batchDetail1 = new Batch_Detail__c(ZTS_US_Case_Product__c = caseProduct1.Id, ZTS_US_Product_Lot__c = '123', Sequence__c = '1');
        insert batchDetail1;
        
        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c localAssessment = (ZTS_US_Assessment__c)SL_TestDataFactory.createSObject(new ZTS_US_Assessment__c(
            ZTS_US_Local_Assessment__c = 'FDA',
            ZTS_US_Is_it_serious__c = 'Yes',
            RecordTypeId = localAssessmentRTId,
            ZTS_US_Case__c = newCase.Id,
            ZTS_US_Reportability__c = 'Non-Reportable',
            ZTS_US_Assessor__c = UserInfo.getUserId(),
            ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason',
            Sequence__c = '1'
        ), true);
        ZTS_US_Assessment_Products__c localAssessProduct = (ZTS_US_Assessment_Products__c)SL_TestDataFactory.createSObject(new ZTS_US_Assessment_Products__c(
            ZTS_US_Assessment__c = localAssessment.Id,
            ZTS_US_PVW_Product__c = prod1.Id
        ), true);
        
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment = (ZTS_US_Assessment__c)SL_TestDataFactory.createSObject(new ZTS_US_Assessment__c(
            ZTS_US_Expected_PA__c = 'No',
            RecordTypeId = productAssessmentRTId,
            ZTS_US_Case__c = newCase.Id,
            ZTS_US_Dechallenge_PA__c = 'Abated',
            ZTS_US_Rechallenge_PA__c = 'No recurrence',
            ZTS_US_Assessment_PA__c = 'N - Unlikely/Low',
            ZTS_US_Assessor__c = UserInfo.getUserId(),
            ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
        ), true);
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c)SL_TestDataFactory.createSObject(new ZTS_US_Assessment_Products__c(
            ZTS_US_Assessment__c = productAssessment.Id,
            ZTS_US_PVW_Product__c = prod1.Id
        ), true);
        
        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c(Name = 'Lynx Cat', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        // Insert Animal
        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(Name = 'Tessjyyy',
                                                             ZTS_US_Species__c = 'Feline',
                                                             ZTS_US_Weight_units__c = 'Grams',
                                                             ZTS_US_Atlas_Id__c = 'PETOWNER_ATLAS_ID',
                                                             ZTS_US_Sex__c = 'Male',
                                                             ZTS_US_Weight__c = 9,
                                                             ZTS_US_Reproductive_Status__c = 'Neutered',
                                                             ZTS_US_Breed__c = Breed1.Id,
                                                             ZTS_US_Animal_condition_prior_treatment__c = 'Good',
                                                             ZTS_US_Age_from__c = 8, // Assuming this is Age
                                                             ZTS_US_Age_unit_from__c = 'Month(s)' // Assuming this is Age Units
                                                            );
        insert testUSAnimal;
        // Insert Case Animal
        //String animalPatientRecordTypeId = Schema.SObjectType.ZTS_US_Case_Animal__c.getRecordTypeInfosByDeveloperName().get('Animal').getRecordTypeId();
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id,
                                                                     //RecordTypeId = animalPatientRecordTypeId,
                                                                     ZTS_US_Animal__c = testUSAnimal.Id,
                                                                     ZTS_US_Weight_units__c = 'Grams',
                                                                     ZTS_US_Unknown__c = 0,
                                                                     ZTS_US_Under_Treatment__c = 0,
                                                                     ZTS_US_Total__c = 1,
                                                                     ZTS_US_Recovered__c = 0,
                                                                     ZTS_US_Reacted__c = 1,
                                                                     ZTS_US_Weight__c = 9,
                                                                     ZTS_US_Reproductive_Status__c = 'Neutered',
                                                                     ZTS_US_Exposed__c = 1,
                                                                     ZTS_US_Euthanized__c = 0,
                                                                     ZTS_US_Died__c = 0,
                                                                     ZTS_US_Animal_condition_prior_treatment__c = 'Good',
                                                                     ZTS_US_Alive_with_Sequela__c = 1                                                                    
                                                                    );
        insert caseAnimal;
        
        // Insert Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(
            ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
            ZTS_US_Outcome_of_Reaction__c = 'Died',
            ZTS_US_Duration_text__c = '30',
            ZTS_US_Reaction_Treated__c = 'Yes',
            ZTS_US_Treatment__c = 'Test treatment',
            ZTS_US_Case__c = newCase.Id
        );
        insert eventNarrative;
        
        ZTS_US_VedDRA_Coding__c objVedraCoding = new ZTS_US_VedDRA_Coding__c(Name = 'Fever',
                                                                             ZTS_US_VEDDRA_Class__c = 'C',
                                                                             ZTS_US_VEDDRA_Status__c = 'Official',
                                                                             ZTS_US_Veddra_Display__c = 'Y',
                                                                             Version__c = 22,
                                                                             VedDRA_Version__c = Label.Veddra_Version_For_Tests
                                                                            );
        insert objVedraCoding;
        
        ZTS_US_VedDRA_Coding__c objVedraCoding1 = new ZTS_US_VedDRA_Coding__c(Name = 'Found Dead',
                                                                              ZTS_US_VEDDRA_Class__c = 'C',
                                                                              ZTS_US_VEDDRA_Status__c = 'Official',
                                                                              ZTS_US_Veddra_Display__c = 'Y',
                                                                              Version__c = 56,
                                                                              ZTS_US_Preferred_Term__c = 'Death',
                                                                              VedDRA_Version__c = Label.Veddra_Version_For_Tests
                                                                             );
        insert objVedraCoding1;
        
        ZTS_US_VedDRA_Event__c testVedDRA = new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.Id,
                                                                       Duration_Units__c = 'Hour(s)',
                                                                       ZTS_US_Number_of_pts_affected__c = 1,
                                                                       ZTS_US_Start_Date__c = Date.today(),
                                                                       ZTS_US_VedDRA_Coding__c = objVedraCoding.Id,
                                                                       ZTS_US_Ongoing__c = 'Yes',
                                                                       Sequence__c = '1'
                                                                      );
        insert testVedDRA;
        ZTS_US_VedDRA_Event__c testVedDRA1 = new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c = eventNarrative.Id,
                                                                        Duration_Units__c = 'Hour(s)',
                                                                        ZTS_US_Number_of_pts_affected__c = 1,
                                                                        ZTS_US_Start_Date__c = Date.today(),
                                                                        ZTS_US_VedDRA_Coding__c = objVedraCoding1.Id,
                                                                        ZTS_US_Ongoing__c = 'Yes',
                                                                        Sequence__c = '2'
                                                                       );
        insert testVedDRA1;
        newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        update newCase;
        clearBypasses();
        Test.startTest();
        newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
        String errorMessage = '';
        try {
            update newCase;
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        system.assert(String.isNotBlank(errorMessage) && errorMessage.contains(VmipsCaseService.CASE_ANIMAL_AGE_ERROR));
        caseAnimal.ZTS_US_Age_from__c = 8;
        caseAnimal.ZTS_US_Age_unit_from__c = 'Month(s)';  
        update caseAnimal;
        errorMessage = '';
        try{
             update newCase;
        }
        catch(Exception e){
            errorMessage = e.getMessage();
        }
        system.assert(String.isBlank(errorMessage));
        Test.stopTest();
    }
    
    @isTest
    public static void testHumanAgeRequiredSendToPV() {
        // Set bypasses for testing
        setBypasses();
        
        // Create a test Account
        Account objAcc = (Account)SL_TestDataFactory.createSObject(
            new Account(
                Name = 'Test Account',
                ZTS_EU_Market__c = 'United States',
                ZTS_EU_VAT_Code__c = '00011',
                ZTS_EU_Account_Status__c = 'Active',
                ZTS_EU_Zip_Postal_Code__c = '07306',
                LIS_Org_Code__c = '1000117840',
                BillingPostalCode = '12345',
                BillingCity = 'testTown',
                BillingState = 'NY',
                BillingStreet = '123 Test'
            ),
            true
        );
        
        // Define the Record Type for 'Animal Support' Cases
        String animal_SupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId();
        
        // Create a new Case with specified details
        Case newCase = new Case(
            RecordTypeId = animal_SupportRecordTypeId,
            Subject = 'Test Case for Case Approval Validation',
            Status = 'New',
            Origin = 'Phone',
            Type = 'Human Exposure',
            ZTS_US_Source__c = 'Human Patient',
            ZTS_US_Information_Type__c = 'Erred',
            ZTS_US_First_Received_Date__c = Date.today(),
            ZTS_US_Country__c = 'USA',
            ZTS_US_Is_it_serious_CA__c = 'No',
            ZTS_US_Date_First_Valid__c = Date.today(),
            ZTS_US_Do_Not_Notify_Reporter__c = true,
            AccountId = objAcc.Id
        );
        insert newCase;
        
        // Insert a Contact record
        Contact contact = new Contact(
            LastName = 'Doe',
            FirstName = 'Testone',
            ZTS_US_Profession__c = 'Consultant',
            ZTS_US_Job_Function__c = 'Practice Mgt',
            MailingStreet = '20 W 34th St',
            MailingCity = 'New York',
            MailingState = 'NY',
            MailingPostalCode = '10001',
            MailingCountry = 'US',
            Interface_Email__c = 'test@zoetis.com'
        );
        insert contact;
        
        // Create a Case_Contact__c record
        Case_Contact__c caseContact = new Case_Contact__c(
            Contact__c = contact.Id,
            ZTS_US_Contact_Role__c = 'Pharmacist',
            Case__c = newCase.Id,
            ZTS_US_Primary_Reporter__c = true,
            Sequence__c = '1'
        );
        insert caseContact;
        
        // Create a PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c();
        prod1.Name = 'Simparica Test';
        prod1.CurrencyIsoCode = 'USD';
        prod1.ZTS_US_MAH_Country__c = 'US';
        prod1.ZTS_US_Active_Product__c = 'Yes';
        prod1.ZTS_US_Formulation_Text__c = 'test';
        prod1.ZTS_US_Brand__c = 'Test Brand';
        insert prod1;
        
        // Insert a Case Product Record
        Id CaseProductRTId = Schema.SObjectType.ZTS_US_Case_Product__c.getRecordTypeInfosByDeveloperName().get(CASEPRODUCT_RT_ID).getRecordTypeId();
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(
            ZTS_US_Case__c = newCase.Id,
            ZTS_US_PVW_Product__c = prod1.Id,
            ZTS_US_Previous_Exposure__c = 'No',
            ZTS_US_Product_Role__c = 'Suspect Product',
            ZTS_US_Product_Used_Correctly__c = 'Yes',
            ZTS_US_Product_problem_type__c = 'Ecotoxicity',
            ZTS_US_Start_Date__c = Date.today(),
            ZTS_US_Serial_Number__c = 'test',
            ZTS_US_Route__c = 'Implant',
            ZTS_US_Reason_for_use__c = 'testy',
            ZTS_US_Qualifier__c = 'Invalid',
            ZTS_US_Previous_Reaction__c = 'No',
            ZTS_US_Ongoing__c = true,
            ZTS_US_Product_Lot__c = 'test',
            ZTS_US_Per__c = 4.5,
            ZTS_US_Interval_Unit__c = 'mg', // Updated this field
            ZTS_US_Frequency_Unit__c = 'Minutes',
            ZTS_US_Frequency__c = 4,
            RecordTypeId = CaseProductRTId,
            ZTS_US_Expiry_Date__c = Date.today(),
            ZTS_US_Duration_Unit__c = 'Minutes',
            ZTS_US_Duration__c = 8,
            ZTS_US_Dose_Unit__c = 'Bolus',
            ZTS_US_Product_Agency__c = 'FDA',
            ZTS_US_Dose__c = 5.4,
            ZTS_US_Attending_Vet_Suspicion_Level__c = 'Not Applicable',
            ZTS_US_Administered_By__c = 'Attending Vet',
            Sequence__c = '1'
        );
        insert caseProduct1;
        
        // Create a Batch_Detail__c record
        Batch_Detail__c batchDetail1 = new Batch_Detail__c(
            ZTS_US_Case_Product__c = caseProduct1.Id,
            ZTS_US_Product_Lot__c = '123',
            Sequence__c = '1'
        );
        insert batchDetail1;
        
        // Create a local assessment record
        Id localAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(LOCALASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c localAssessment = (ZTS_US_Assessment__c)SL_TestDataFactory.createSObject(
            new ZTS_US_Assessment__c(
                ZTS_US_Local_Assessment__c = 'FDA',
                ZTS_US_Is_it_serious__c = 'Yes',
                RecordTypeId = localAssessmentRTId,
                ZTS_US_Case__c = newCase.Id,
                ZTS_US_Reportability__c = 'Non-Reportable',
                ZTS_US_Assessor__c = UserInfo.getUserId(),
                ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason',
                Sequence__c = '1'
            ),
            true
        );
        
        // Create an assessment product record for the local assessment
        ZTS_US_Assessment_Products__c localAssessProduct = (ZTS_US_Assessment_Products__c)SL_TestDataFactory.createSObject(
            new ZTS_US_Assessment_Products__c(
                ZTS_US_Assessment__c = localAssessment.Id,
                ZTS_US_PVW_Product__c = prod1.Id
            ),
            true
        );
        
        // Create a product assessment record
        Id productAssessmentRTId = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get(PRODUCTASSESSMENT_RT_ID).getRecordTypeId();
        ZTS_US_Assessment__c productAssessment = (ZTS_US_Assessment__c)SL_TestDataFactory.createSObject(
            new ZTS_US_Assessment__c(
                ZTS_US_Expected_PA__c = 'No',
                RecordTypeId = productAssessmentRTId,
                ZTS_US_Case__c = newCase.Id,
                ZTS_US_Dechallenge_PA__c = 'Abated',
                ZTS_US_Rechallenge_PA__c = 'No recurrence',
                ZTS_US_Assessment_PA__c = 'N - Unlikely/Low',
                ZTS_US_Assessor__c = UserInfo.getUserId(),
                ZTS_US_Reason_for_Assessment_PA__c = 'Testing Reason'
            ),
            true
        );
        
        // Create an assessment product record for the product assessment
        ZTS_US_Assessment_Products__c productsssessProduct = (ZTS_US_Assessment_Products__c)SL_TestDataFactory.createSObject(
            new ZTS_US_Assessment_Products__c(
                ZTS_US_Assessment__c = productAssessment.Id,
                ZTS_US_PVW_Product__c = prod1.Id
            ),
            true
        );
        
        // Insert a Breed record
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c(Name = 'Human', ZTS_US_Species__c = 'Human');
        insert Breed1;
        
        // Insert an Animal record
        ZTS_US_Animal__c testUSAnimal = new ZTS_US_Animal__c(
            Name = 'TestHumanfields',
            ZTS_US_Breed__c = Breed1.Id,
            ZTS_US_Atlas_Id__c = 'PETOWNER_ATLAS_ID',
            ZTS_US_Job_Occupation__c = 'Dev',
            ZTS_US_Sex__c = 'Male',
            ZTS_US_Species__c = 'Human',
            ZTS_US_Weight_units__c = 'Grams',
            ZTS_US_Human_Weight__c = 47,
            ZTS_US_Patient_Died__c = 'No'   
        );
        insert testUSAnimal;
        
        // Insert a Case Animal record for the human patient
        String humanPatientRecordTypeId = Schema.SObjectType.ZTS_US_Case_Animal__c.getRecordTypeInfosByDeveloperName().get('Human').getRecordTypeId();
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(
            ZTS_US_Case__c = newCase.Id,
            RecordTypeId = humanPatientRecordTypeId,
            ZTS_US_Animal__c = testUSAnimal.Id,
            ZTS_US_Age_text__c = 6.1,
            Age_units__c = 'Day(s)',
            ZTS_US_Weight_units__c = 'Grams',
            ZTS_US_Unknown__c = 0,
            ZTS_US_Under_Treatment__c = 0,
            ZTS_US_Total__c = 1,
            ZTS_US_Recovered__c = 0,
            ZTS_US_Reacted__c = 1,
            ZTS_US_Weight__c = 9,
            ZTS_US_Exposed__c = 1,
            ZTS_US_Euthanized__c = 0,
            ZTS_US_Died__c = 0,
            ZTS_US_Patient_Died__c = 'No',
            ZTS_US_Alive_with_Sequela__c = 1
        );
        insert caseAnimal;
        
        // Create an Event Narrative record
        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c(
            ZTS_US_Event_Narrative_Summary_Field__c = 'xyozlmno',
            ZTS_US_Outcome_of_Reaction__c = 'Died',
            ZTS_US_Duration_text__c = '30',
            ZTS_US_Reaction_Treated__c = 'Yes',
            ZTS_US_Treatment__c = 'Test treatment',
            ZTS_US_Case__c = newCase.Id
        );
        insert eventNarrative;
        
        // Create two VedDRA Coding records
        ZTS_US_VedDRA_Coding__c objVedraCoding = new ZTS_US_VedDRA_Coding__c(
            Name = 'Fever',
            ZTS_US_VEDDRA_Class__c = 'C',
            ZTS_US_VEDDRA_Status__c = 'Official',
            ZTS_US_Veddra_Display__c = 'Y',
            Version__c = 22,
            VedDRA_Version__c = Label.Veddra_Version_For_Tests
        );
        insert objVedraCoding;
        
        ZTS_US_VedDRA_Coding__c objVedraCoding1 = new ZTS_US_VedDRA_Coding__c(
            Name = 'Found Dead',
            ZTS_US_VEDDRA_Class__c = 'C',
            ZTS_US_VEDDRA_Status__c = 'Official',
            ZTS_US_Veddra_Display__c = 'Y',
            ZTS_US_Preferred_Term__c = 'Death',
            Version__c = 34,
            VedDRA_Version__c = Label.Veddra_Version_For_Tests
        );
        insert objVedraCoding1;
        
        // Create two VedDRA Event records
        ZTS_US_VedDRA_Event__c testVedDRA = new ZTS_US_VedDRA_Event__c(
            ZTS_US_Event_Narrative__c = eventNarrative.Id,
            Duration_Units__c = 'Hour(s)',
            ZTS_US_Number_of_pts_affected__c = 1,
            ZTS_US_Start_Date__c = Date.today(),
            ZTS_US_VedDRA_Coding__c = objVedraCoding.Id,
            ZTS_US_Ongoing__c = 'Yes',
            Sequence__c = '1'
        );
        insert testVedDRA;
        
        ZTS_US_VedDRA_Event__c testVedDRA1 = new ZTS_US_VedDRA_Event__c(
            ZTS_US_Event_Narrative__c = eventNarrative.Id,
            Duration_Units__c = 'Hour(s)',
            ZTS_US_Number_of_pts_affected__c = 1,
            ZTS_US_Start_Date__c = Date.today(),
            ZTS_US_VedDRA_Coding__c = objVedraCoding1.Id,
            ZTS_US_Ongoing__c = 'Yes',
            Sequence__c = '2'
        );
        insert testVedDRA1;
        
        // Update the Case to reference the Event Narrative
        newCase.ZTS_US_Event_Narrative__c = eventNarrative.Id;
        update newCase;
        
        // Clear bypasses for testing
        clearBypasses();
        
        // Start the test
        Test.startTest();
        
        // Set the Sync_Status__c field to SYNC_READY
        newCase.Sync_Status__c = VmipsCaseSyncStatusHandler.SYNC_READY;
        String errorMessage = '';
        
        try {
            update newCase;
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        
        // Ensure an error message is present and it contains the expected error code
        system.assert(String.isNotBlank(errorMessage) && errorMessage.contains(VmipsCaseService.CASE_ANIMAL_AGE_ERROR));
        
        // Update the testUSAnimal's age
        testUSAnimal.ZTS_US_Age_text__c = 8;
        testUSAnimal.Age_units__c = 'Month(s)';
        errorMessage = '';
        
        try {
            update testUSAnimal;
        } catch (Exception e) {
            errorMessage = e.getMessage();
        } 
      
        System.debug('Error string' + errorMessage);
        system.assert(String.isBlank(errorMessage));
        Test.stopTest();
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