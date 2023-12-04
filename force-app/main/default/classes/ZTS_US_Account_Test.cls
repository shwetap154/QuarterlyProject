/**
 * Includes various test for US Accounts
 * @author Unknown
 * @since 07-29-2020
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-29-2020   Unknown                     Initial Version
 * 1.1   01-23-2023   Ethan Hirsch @ Zoetis Inc   Add tests for ZTS_US_addrCreationAndUpdateFromAccount to verify unhandled exceptions are handled.
 *                                                Methods covered are createAddressRecord, updateAddressRecord, updateAccConAffInactive, and createAnimalCountFTE
 * 1.2  01-26-2023   Padma Nerella @ Zoetis Inc   Add test methods to test get account with email changes and process those changes on contact for email changes
 */
@isTest
public class ZTS_US_Account_Test{
    
    static final String OPPORTUNITY_INST_ERROR_ORIGIN = 'ZTS_US_Account_Test - testContractedServices(): insert Opportunity ';
    private static final String TEST_ERROR_ACCOUNT_NAME = 'Test Error Account';

    @TestSetup
    private static void setup(){
        Test.startTest();
            Account testErrorAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            testErrorAccount.Name = TEST_ERROR_ACCOUNT_NAME;
            insert testErrorAccount;

            Contact testErrorContact = ZTS_DataUtilityTest.createContactRecord(1)[0];
            testErrorContact.ZTS_EU_Market__c = 'United States';
            testErrorContact.AccountId = testErrorAccount.Id;
            
            // Skip the Contact Trigger to save on limits. Especially for validate_AttendeeTriggerTest
            DispatchTriggerHandler.bypass('ContactTriggerHandler');
            insert testErrorContact;
            DispatchTriggerHandler.clearBypass('ContactTriggerHandler');

            DispatchTriggerHandler.bypass('ZTS_EU_AffiliationsTriggerHandler');
            ZTS_EU_Affiliations__c testAffiliation = ZTS_DataUtilityTest.createAccConAffiliationRecord(1)[0];
            testAffiliation.ZTS_EU_Account__c = testErrorAccount.Id;
            testAffiliation.ZTS_EU_Contact__c = testErrorContact.Id;
            insert testAffiliation;
            DispatchTriggerHandler.clearBypass('ZTS_EU_AffiliationsTriggerHandler');
        
        Account testacc = ZTS_DataUtilityTest.createAccountRecord(1)[0];
        testacc.Name='TestAccount';
        testacc.ZTS_EU_Market__c ='United States';
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        Insert testacc;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        Id accountContactId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Account_Contact').getRecordTypeId();
        List<Contact> conList = new List<Contact>();
        Contact cont = ZTS_DataUtilityTest.createContactRecord(1)[0];
        cont.AccountId = testacc.Id;
        cont.ZTS_US_Profession__c = 'Account Contact';
        cont.ZTS_US_Job_Function__c = 'Account Contact';
        cont.RecordTypeId =accountContactId;
        cont.ZTS_EU_Contact_Status__c = 'Active';
        conList.add(cont);
        insert conList;
        system.debug('conList in Setup method: '+conList);
    
        Test.stopTest();
    }
    
    static testMethod void validate_AttendeeTriggerTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.LastName = 'intlUser';
        usr.Email = 'intlUser@gmail.com';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        System.runAs(usr)
        {
            List <Attendee__c> attendeeList= ZTS_DataUtilityTest.createAttendee(1);
            
            Call__c myCall = [SELECT Id, ZTS_EU_Call_Owner__c FROM Call__c WHERE Id = :attendeeList[0].ZTS_EU_call__c];
            myCall.ZTS_EU_Call_Owner__c = usr.Id;
            update myCall;
            
            List<ZTS_EU_Colleague__c> createColleague = ZTS_DataUtilityTest.createColleague(1);
            List<ZTS_Events__c> Eventrec = ZTS_DataUtilityTest.createEvents(1);
            Eventrec[0].ZTS_US_Event_Category__c = 'CPAC';
            List<User> usersLis = ZTS_DataUtilityTest.createcoacherUser();
            for (User u : usersLis) u.ZTS_EU_Market__c = 'United States';
            Test.startTest();
            
            insert attendeeList;
            insert createColleague;
            insert Eventrec;
            insert usersLis;
            attendeeList[0].ZTS_EU_Campaign_Response__c='test';
            delete Eventrec;
            delete createColleague;
            update attendeeList;
            delete attendeeList;
            Test.stopTest();
        }
    }
    
    static testMethod void testContractedServices(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        System.runAs(usr)
        {
            Test.starttest();
            
            try{
                
                List<Account> accountRecord = ZTS_DataUtilityTest.createAccountRecord(1,6);
                insert accountRecord;
                system.debug('-----accountRecord.id----'+ accountRecord[0].id);
                ZTS_US_Contracted_Services__c cs = new ZTS_US_Contracted_Services__c();
                cs.ZTS_US_Account_Name__c = accountRecord[0].id;
                cs.ZTS_US_Status__c = 'Active';
                insert cs;
                
                Id rtId = null;
                if(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('People_First') != null){
                    rtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('People_First').getRecordTypeId();        
                }
                
                Opportunity opp = new Opportunity();
                opp.AccountId = accountRecord[0].Id;
                opp.name = 'PeopleFirst Opportunity Test';    
                date today= date.today();   
                opp.CloseDate= today.addDays(7);
                opp.StageName= 'Prospecting';   
                opp.Type='PeopleFirst';
                opp.RecordTypeid=rtId ;
                opp.Service_Contract__c='PeopleFirst - LCP Enrollment';
                insert opp;  
                
            }
            catch(DmlException dex)
            {
                String errorMessages = '';
                for (Integer i = 0; i < dex.getNumDml(); i++) {
                    System.debug(OPPORTUNITY_INST_ERROR_ORIGIN);
                    System.debug('DML Message: ' + dex.getDmlMessage(i));
                    errorMessages += dex.getDmlMessage(i) + '\n';
                }
                errorMessages.removeEnd('\n');
                ZTS_EU_Logger.notify = true;
                ZTS_EU_Logger.error(errorMessages,null, OPPORTUNITY_INST_ERROR_ORIGIN);
            }
            
            Test.stoptest();
        }
    }
    
    static testMethod void beforeDeleteTest()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        System.runAs(usr)
        {
            
            Test.StartTest();
            List<Account> accList = ZTS_DataUtilityTest.createAccountRecord(1);
            
            try{
                insert accList ;
            }
            catch(Exception e){
                System.debug('error'+e);
            }
            
            List<Call__c>callList = ZTS_DataUtilityTest.createCallRecord(1);
            callList[0].ZTS_EU_Call_Owner__c = usr.Id;
            insert callList;
            callList[0].ZTS_EU_Status__c = 'Submitted';
            callList[0].ZTS_EU_Submitted_Date__c=System.today()+1;
            
            set<string> objNames = new set<String>();
            objNames.add('Account');
            objNames.add('ZTS_EU_Species_Product__c');
            list<recordtype> recordtypesLst = new list<recordtype>();
            recordtypesLst = [select id, developerName,SobjectType from recordtype where SobjectType in :objNames ];
            
            map<string, string> recordtypeMap = new map<string, string>();
            
            for(Recordtype r : recordtypesLst){
                string objName_DeveloperName = r.SobjectType +'-'+ r.developerName;
                recordtypeMap.put(objName_DeveloperName, r.id);
                system.debug('objName_DeveloperName>>:'+objName_DeveloperName);
            }
            
            ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
            tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
            insert tgRecord;
            
            ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
            brandRecord = createProdHierarchyRecord('Ph 2','Brand','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
            insert brandRecord;
            
            ZTS_US_Sample__c sample= new ZTS_US_Sample__c(ZTS_US_Product__c = brandRecord.Id, ZTS_US_Item_Code__c='ABC1233',ZTS_US_Lot__c='LOT1',ZTS_US_Start_Quantity__c=15);
            insert sample;
            List<ZTS_US_Sample__c> sampleList=new List <ZTS_US_Sample__c>();
            sampleList.add(sample);
            List<ZTS_US_Sample__c> newsampleList=new List <ZTS_US_Sample__c>();
            ZTS_US_Sample_Drop__c samdrop= new ZTS_US_Sample_Drop__c(ZTS_US_Sample__c=sampleList[0].Id,ZTS_EU_Quantity__c=3,
                                                                     ZTS_US_Account__c = accList[0].Id,ZTS_US_Call__c = callList[0].Id);
            update callList;                                            
            insert samdrop;
            delete samdrop;
            Test.stopTest();
        }
    }
    
    static testMethod void beforeDeleteTest1()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            Test.StartTest();
            List<Account> accList1 = ZTS_DataUtilityTest.createAccountRecord(1);
            insert accList1;
            List<Call__c>callList1 = ZTS_DataUtilityTest.createCallRecord(1);
            insert callList1;
            callList1[0].ZTS_EU_Status__c = 'Submitted';
            callList1[0].ZTS_EU_Submitted_Date__c=System.today()+1;
            
            set<string> objNames = new set<String>();
            objNames.add('Account');
            objNames.add('ZTS_EU_Species_Product__c');
            list<recordtype> recordtypesLst = new list<recordtype>();
            recordtypesLst = [select id, developerName,SobjectType from recordtype where SobjectType in :objNames ];
            
            map<string, string> recordtypeMap = new map<string, string>();
            
            for(Recordtype r : recordtypesLst){
                string objName_DeveloperName = r.SobjectType +'-'+ r.developerName;
                recordtypeMap.put(objName_DeveloperName, r.id);
                system.debug('objName_DeveloperName>>:'+objName_DeveloperName);
            }
            
            ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
            tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
            insert tgRecord;
            
            ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
            brandRecord = createProdHierarchyRecord('Ph 2','Brand','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
            insert brandRecord;
            
            ZTS_US_Sample__c sample= new ZTS_US_Sample__c(ZTS_US_Product__c = brandRecord.Id, ZTS_US_Item_Code__c='ABC1233',ZTS_US_Lot__c='LOT1',ZTS_US_Start_Quantity__c=15);
            insert sample;
            List<ZTS_US_Sample__c> sampleList=new List <ZTS_US_Sample__c>();
            sampleList.add(sample);
            List<ZTS_US_Sample__c> newsampleList=new List <ZTS_US_Sample__c>();
            ZTS_US_Sample_Drop__c samdrop= new ZTS_US_Sample_Drop__c(ZTS_US_Sample__c=sampleList[0].Id,ZTS_EU_Quantity__c=3,
                                                                     ZTS_US_Account__c = accList1[0].Id,ZTS_US_Call__c = callList1[0].Id);
            update callList1;                                            
            insert samdrop;
            delete samdrop;
            Test.stopTest();
        }
    }
    
    public static testMethod void updateAccOnPrimAddrCreationTest(){
        AddressTriggerHandler addressHandler = new AddressTriggerHandler();
        addressHandler.disableTrigger = true;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            Account acc = new Account();         
            acc.name = 'Test Account1';
            acc.ZTS_US_Business_Class__c = 'Veterinarian';
            acc.ZTS_US_NARC_ID__c='NC';
            acc.MZR_Status__c ='Eligible';
            acc.BillingPostalCode = '00000';
            acc.BillingCity = 'testCity';
            acc.BillingState = 'testSate';
            acc.BillingStreet = 'testStreet';
            acc.ZTS_EU_Market__c = 'United States';
            insert acc;
            
            List<Address__c> addList = new List<Address__c>();
            
            List<State_Country__c> scList1 = new List<State_Country__c>();    
            State_Country__c sc1 = new State_Country__c();         
            sc1.name = 'County';
            sc1.ZTS_EU_Country__c = 'United States';
            sc1.ZTS_EU_uniqueCOUNTY__c = 'United States';
            insert sc1;
            
            for(Integer i=0;i<1;i++) {
                Address__C addr = new Address__C();
                addr.ZTS_EU_Primary__c = true;
                addr.ZTS_US_Primary__c = true;
                addr.ZTS_Address_Line_1__c  = 'Test Street'+i;
                addr.Zip_Postal_Code__c ='12345';
                addr.State_Province__c = 'New York';
                addr.ZTS_EU_Country__c ='United States';
                addr.ZTS_EU_City__c  = 'New York';
                addr.ZTS_EU_Address_Line_2__c ='Test Addr' + i;
                addr.ZTS_EU_Account__c = acc.id;
                addr.ZTS_EU_State_County__c = sc1.Id;
                addr.ZTS_EU_Market_from_Parent__c = 'United States';
                addList.add(addr);
            }
            
            insert addList;
            
            Map<Id,Address__C> addressMap = new Map<Id,Address__C>();
            for(Address__c a: addList){
                addressMap.put(a.Id, a);
            }
            Test.startTest();
            ZTS_addrUpdateOnAccount.updateAccOnPrimAddrCreation(addList,addressMap);
            Test.stopTest();
            
            List<Account> actualAccounts = [SELECT Id, BillingCity, BillingCountry, BillingPostalCode FROM Account WHERE Id = :acc.Id];
            System.assertEquals(addList[0].ZTS_EU_City__c, actualAccounts[0].BillingCity, 'City from address should not be set on Account');
            System.assertEquals(addList[0].ZTS_EU_Country__c, actualAccounts[0].BillingCountry, 'Country from address should not be set on Account');
            System.assertEquals(addList[0].Zip_Postal_Code__c, actualAccounts[0].BillingPostalCode, 'Postal code from address should not be set on Account');
        }
    }
    
    public static testMethod void updateAccOnPrimAddrCreationTest1(){
        AddressTriggerHandler addressHandler = new AddressTriggerHandler();
        addressHandler.disableTrigger = true;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            Account acc1 = new Account();         
            acc1.name = 'Test Account1';
            acc1.ZTS_US_VGP_Enrollment_Status__c = 'Customer Accepted T&C – enrollment in Process';
            acc1.ZTS_US_NARC_ID__c='NC';
            acc1.MZR_Status__c ='Eligible';
            acc1.BillingPostalCode = '00000';
            acc1.BillingCity = 'testCity';
            acc1.BillingState = 'testSate';
            acc1.BillingStreet = 'testStreet';
            acc1.ZTS_EU_Market__c = 'United States';
            insert acc1;
            
            List<Address__c> addList1 = new List<Address__c>();
            
            List<State_Country__c> scList1 = new List<State_Country__c>();    
            State_Country__c sc1 = new State_Country__c();         
            sc1.name = 'County';
            sc1.ZTS_EU_Country__c = 'United States';
            sc1.ZTS_EU_uniqueCOUNTY__c = 'United States';
            insert sc1;
            
            for(Integer i=0;i<1;i++) {
                Address__C addr = new Address__C();
                //addr.ZTS_EU_Primary__c = true;
                addr.ZTS_US_Primary__c = true;
                addr.ZTS_Address_Line_1__c  = 'Test Street'+i;
                addr.Zip_Postal_Code__c ='12345';
                addr.State_Province__c = 'New York';
                addr.ZTS_EU_Country__c ='United States';
                addr.ZTS_EU_City__c  = 'New York';
                addr.ZTS_EU_Address_Line_2__c ='Test Addr' + i;
                addr.ZTS_EU_Account__c = acc1.id;
                addr.ZTS_EU_State_County__c = sc1.Id;
                addr.ZTS_EU_Market_from_Parent__c = 'United States';
                addList1.add(addr);
            }
            
            insert addList1;
            
            Map<Id,Address__C> addressMap = new Map<Id,Address__C>();
            for(Address__c a: addList1){
                addressMap.put(a.Id, a);
            }
            Test.startTest();
            ZTS_addrUpdateOnAccount.updateAccOnPrimAddrCreation(addList1,addressMap);
            Test.stopTest();
            
            List<Account> actualAccounts = [SELECT Id, BillingCity, BillingCountry, BillingPostalCode FROM Account WHERE Id = :acc1.Id];
            System.assertEquals(addList1[0].ZTS_EU_City__c, actualAccounts[0].BillingCity, 'City from address should not be set on Account');
            System.assertEquals(addList1[0].ZTS_EU_Country__c, actualAccounts[0].BillingCountry, 'Country from address should not be set on Account');
            System.assertEquals(addList1[0].Zip_Postal_Code__c, actualAccounts[0].BillingPostalCode, 'Postal code from address should not be set on Account');
        }
    }
    
    static List<ZTS_Events__c> listEvents;
    static List<Account> listAccount;
    static List<Contact> listContact;
    static Task tak;
    static List<Call__c> listCalls;
    static List<ZTS_EU_Discussion__c> discList;
    static ZTS_EU_Colleague__c coll;
    static Attendee__c att;
    
    public static void createTestData(Integer narcVal)
    {
        
        listAccount = ZTS_DataUtilityTest.createAccountRecord(1, narcVal);
        for (Account acc : listAccount) acc.ZTS_EU_Market__c = 'United States';
        insert listAccount;
        
        update listAccount;
        listCalls = createCalls(listAccount);
        
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        listContact = ZTS_DataUtilityTest.createContactRecord(1);
        listContact[0].ZTS_EU_Market__c = 'United States';
        insert listCalls;
        insert listContact;
        
        
        
        List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(1);
        insert customterrList;
        customterrList[0].ZTS_FieldForce_ID__c = 'testName';
        update customterrList;
        
        List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
        insert userterrlist;
        ZTS_US_Call_CS__c callCS = new ZTS_US_Call_CS__c(Name='testName', ZTS_US_Sub_Type_Value__c='Account,SampleDrop',ZTS_US_Sub_Type_Value_2__c='Test Sample Drop');
        insert callCS;
        
        List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(listAccount, customterrList);
        insert accterr;
        ZTS_EU_Account_Position__c accPos = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_NotificationUser__c=UserInfo.getUserId(),ZTS_Alignment_Date__c=system.today(),ZTS_AccountTerritory__c=accterr[0].Id);
        
    }
    
    static testMethod void createStandardControllerT()
    {
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            createTestData(153);
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            
            
            salesCall.accountChange();
            test.stoptest();
        }
    }
    
    
    static testMethod void createStandardControllerTest()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            createTestData(154);
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            
            State_Country__c sc1 = new State_Country__c();         
            sc1.name = 'County';
            sc1.ZTS_EU_Country__c = 'United States';
            sc1.ZTS_EU_uniqueCOUNTY__c = 'United States';
            insert sc1;
            
            SalesCallController salesCall = new SalesCallController(sc);
            Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='New York',ZTS_US_Street__c='test street',ZTS_EU_Country__c='United States',Zip_Postal_Code__c ='440013', ZTS_EU_State_County__c = sc1.Id);
            insert address;
            
            test.stopTest();
        }
    }
    public static List<Call__c> createCalls(List<Account> listAcct)
    {
        List<Call__c> listCall = new List<Call__c>();
        for(Account acc: listAcct){
            Call__c call = new Call__c(ZTS_EU_Account__c=acc.Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2),
                                       ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned',Name='Account Call',ZTS_EU_Next_Call_Date__c=system.today(),ZTS_EU_Submitted_Date__c=System.Today());
            listCall.add(call);
        }
        
        return listCall;
        
    }
    
    static testMethod void validate_ZTS_US_AddressCreation()
    { 
         DispatchTriggerHandler.bypass('AT_AccountAuditTrigger');
         DispatchTriggerHandler.bypass('AccountTriggerHandler');
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        List<Account> accList=new List<Account>();
        accList = ZTS_DataUtilityTest.createAccountRecord(6);
        for (Account acc: accList)
        {  
           acc.ZTS_EU_Market__c='United States';
        }
        accList[0].ZTS_US_Business_Class__c = 'Producers';
        accList[1].ZTS_US_Business_Class__c = 'Veterinarian';
        Test.startTest();
        System.runAs(usr)
        {
            insert accList;  
        }
        
        ZTS_US_addrCreationAndUpdateFromAccount.chkUpdate = true;
        accList[0].BillingStreet ='Test 1 Street';
        accList[4].parentId= accList[0].id;
        System.runAs(usr)
        {
         
             update new List<Account>{accList[0], accList[4]};

        }
        User usr2 = new User();
        usr2 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr2.FirstName = 'eltonUser';
        usr2.zts_eu_market__c = 'United States';
        insert usr2;
        System.runAs(usr2){
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        }
        
        List <Contact> contList= new List <Contact>();
        contList=ZTS_DataUtilityTest.createContactRecord(1);
        contList[0].AccountId = accList[0].Id;
        System.runAs(usr2)
        {
            insert contList;
        }
        
        accList[0].BillingStreet ='Test 2 Street';
        System.runAs(usr2)
        {  
         
            update accList[0]; 
            
            
            ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Account__c = accList[3].Id);
            insert aff;
            accList[3].ZTS_EU_Account_Status__c='Inactive';
            accList[3].MZR_Status__c ='Active';
            accList[3].ZTS_US_InactiveReason__c = 'Test reason';
            ZTS_US_checkTriggerRun.resetAll();
           
            update accList[3];
           
            accList[5].ZTS_US_VGP_Enrollment_Status__c='VGP Enrolled';
            ZTS_US_checkTriggerRun.resetAll();
           
            update accList[5];
            
            accList[5].ZTS_US_MVP_Account__c=true;
            ZTS_US_checkTriggerRun.resetAll();
           
            update accList[5];
            accList[4].parentId= null;
            ZTS_US_checkTriggerRun.resetAll();
            DispatchTriggerHandler.firstTimeTracker.clear();
            update accList[4];
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            DispatchTriggerHandler.clearBypass('AT_AccountAuditTrigger');

        }
        Test.stopTest();
        
        System.assertNotEquals(accList.size(),0);
    }
    
    
    static testmethod void testupdateAccountContractDetails()
    {
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        System.runAs(usr)
        {
            List<Account> accList=new List<Account>();
            accList = ZTS_DataUtilityTest.createAccountRecord(6);
            accList[0].ZTS_US_Business_Class__c = 'Producers';
            accList[1].ZTS_US_Business_Class__c = 'Veterinarian';
            Test.startTest();
            insert accList;
            accList[2].parentId = accList[0].id;
            ZTS_US_checkTriggerRun.resetAll();
            update accList;
            
            ZTS_US_checkTriggerRun.resetAll();
            accList[2].ZTS_US_MVP_Account__c = true;
            update accList;
            Test.stopTest();
        }
    }
    
    static testmethod void updatecontractdetailschildaccountsTest()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        System.runAs(usr)
        {
            List<Account> accList=new List<Account>();
            accList = ZTS_DataUtilityTest.createAccountRecord(6);
            Test.startTest();
            insert accList;
            ZTS_US_addrCreationAndUpdateFromAccount.chkUpdate = true;
            accList[0].BillingStreet ='Test 1 Street';
            accList[4].parentId= accList[0].id;
            accList[5].parentId= accList[0].id;   
            update accList;            
            
            /*accList[0].MZR_Status__c ='Active';
accList[0].ZTS_US_VGP_Enrollment_Status__c='VGP Enrolled';
accList[0].ZTS_US_MVP_Account__c=true; 

update accList;
accList[0].MZR_Status__c ='Eligible';
accList[0].ZFS_Status__c = 'Member';
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
update accList;*/
            delete accList[4];
            
            
            Account master = new Account(Name='Account1', BillingPostalCode = '00000', BillingCity = 'test', BillingState = 'test', BillingStreet = 'test');
            insert master;        
            Account[] duplicates = new Account[]{new Account(Name='Account1, Inc.', BillingPostalCode = '00000', BillingCity = 'test', BillingState = 'test', BillingStreet = 'test'), new Account(Name='Account 1', BillingPostalCode = '00000', BillingCity = 'test', BillingState = 'test', BillingStreet = 'test')};
                insert duplicates;        
            Database.MergeResult[] results = Database.merge(master, duplicates, false);
            
            
            ZTS_US_checkTriggerRun.resetAll();
            
            accList[0].MZR_Status__c = 'Active';
            accList[0].ZTS_US_VGP_Enrollment_Status__c ='VGP Enrolled'; 
            update accList[0];
            
            Test.stopTest();
            System.assertNotEquals(accList.size(),0);
        }
    }
    static ZTS_EU_Species_Product__c createProdHierarchyRecord(String speciesProdName,String recType,String Market,String recTypeId,string parentRecord)
    {
        ZTS_EU_Species_Product__c speciesProdRec = new ZTS_EU_Species_Product__c(Name= speciesProdName,
                                                                                 ZTS_EU_Type__c= recType ,
                                                                                 ZTS_EU_Market__c= Market,
                                                                                 RecordTypeID = recTypeId,
                                                                                 ZTS_EU_Parent_Species_Product__c = parentRecord);
        
        return speciesProdRec;                                                                           
    }

    static testMethod void USaccountPhoneTest() {
        List<Account> objAcc = ZTS_DataUtilityTest.createAccountRecord(1);
        for (Account acc : objAcc) {
            acc.Name = 'test acc';
            acc.ZTS_EU_Market__c = 'United States';
            acc.Phone = '(555) 234-5678';
        }

        Test.startTest();
            insert objAcc;
            List<Account> accountsAfterInsert = [SELECT Id,Phone FROM Account WHERE Name = 'test acc'];
            for (Account acc : accountsAfterInsert) {
                System.assertEquals('+15552345678',acc.Phone);
                acc.Phone = '(555) 234-5679';
            }
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            update accountsAfterInsert;
        Test.stopTest();

        List<Account> accountsAfterUpdate = [SELECT Id,Phone FROM Account WHERE Name = 'test acc'];
        for (Account acc : accountsAfterUpdate) {
            System.assertEquals('+15552345679',acc.Phone);
        }
    }

    @isTest
    private static void ZTS_US_addrCreationAndUpdateFromAccount_createAddressRecord_Exception_Test() {
        Account testAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];

        ZTS_US_addrCreationAndUpdateFromAccount.forceExceptionCreateAddressRecord = true;
        Test.startTest();
            insert testAccount;
        Test.stopTest();

        System.assert(ZTS_US_addrCreationAndUpdateFromAccount.forceExceptionCreateAddressRecord,
            'An error did not occur when calling createAddressRecord as expected.');

        List<Address__c> addressRecords = [
            SELECT ID
            FROM Address__c
            WHERE ZTS_EU_Account__c =: testAccount.Id];

        System.assertEquals(0, addressRecords.size(), 'Address Records were created unexpectedly.');
    }

    @isTest
    private static void ZTS_US_addrCreationAndUpdateFromAccount_updateAddressRecord_Exception_Test() {
        Account testErrorAccount = [
            SELECT Id
            FROM Account
            WHERE Name =: TEST_ERROR_ACCOUNT_NAME
            LIMIT 1];

        testErrorAccount.BillingStreet = '932 Update St.';

        ZTS_US_addrCreationAndUpdateFromAccount.forceExceptionUpdateAddressRecord = true;
        Test.startTest();
            update testErrorAccount;
        Test.stopTest();

        System.assert(ZTS_US_addrCreationAndUpdateFromAccount.caughtExceptionUpdateAddressRecord,
            'An error did not occur when calling updateAddressRecord as expected.');

        Address__c updatedAddress = [
            SELECT ID, ZTS_Address_Line_1__c
            FROM Address__c
            WHERE ZTS_EU_Account__c =: testErrorAccount.Id
            AND ZTS_US_Primary__c = true
            LIMIT 1];

        System.assertNotEquals(testErrorAccount.BillingStreet, updatedAddress.ZTS_Address_Line_1__c,
            'Address was updated unexpectedly.');
    }

    @isTest
    private static void ZTS_US_addrCreationAndUpdateFromAccount_updateAccConAffInactive_Exception_Test() {
        Account testErrorAccount = [
            SELECT Id
            FROM Account
            WHERE Name =: TEST_ERROR_ACCOUNT_NAME
            LIMIT 1];

        testErrorAccount.ZTS_EU_Account_Status__c = ZTS_GlobalConstants.INACTIVE_STATUS;

        ZTS_US_addrCreationAndUpdateFromAccount.forceExceptionUpdateAccConAffInactive = true;
        Test.startTest();
            update testErrorAccount;
        Test.stopTest();

        System.assert(ZTS_US_addrCreationAndUpdateFromAccount.caughtExceptionUpdateAccConAffInactive,
            'An error did not occur when calling updateAccConAffInactive');

        List<ZTS_EU_Affiliations__c> affilliations = [
            SELECT Id, ZTS_EU_Affiliation_Status__c
            FROM ZTS_EU_Affiliations__c
            WHERE ZTS_EU_Account__c =: testErrorAccount.Id];

        for (ZTS_EU_Affiliations__c affiliation : affilliations) {
            System.assertNotEquals(ZTS_GlobalConstants.INACTIVE_STATUS, affiliation.ZTS_EU_Affiliation_Status__c,
                'Affiliation was inactivated unexpectedly');
        }
    }

    @isTest
    private static void ZTS_US_addrCreationAndUpdateFromAccount_createAnimalCountFTE_Exception_Test() {
        Account testAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
        testAccount.ZTS_US_Business_Class__c = ZTS_GlobalConstants.ACCNT_BUSINESSCLASS_PRODUCERS;

        ZTS_US_addrCreationAndUpdateFromAccount.forceExceptionCreateAnimalCountFTE = true;
        Test.startTest();
            insert testAccount;
        Test.stopTest();

        System.assert(ZTS_US_addrCreationAndUpdateFromAccount.caughtExceptionCreateAnimalCountFTE,
            'An error did not occur when calling createAnimalCountFTE as expected.');

        List<ZTS_Animal_Count_Potential__c> animalCountPotentials = [
            SELECT ID
            FROM ZTS_Animal_Count_Potential__c
            WHERE ZTS_EU_Account__c =: testAccount.Id];

        System.assertEquals(0, animalCountPotentials.size(), 'Animal Count Potential Records were created unexpectedly.');
    }
    @isTest
    private static void getAccountsWithEmailChangesTest(){
        
        List<Account> accList = [Select Id,Name,ZTS_EU_Market__c,Email__c From Account where Name ='TestAccount'];
        List<Contact> conList = [Select Id,Interface_Email__c,AccountId From Contact where AccountId IN: accList];
        
        accList[0].Email__c = 'test12348@zoetis.com';
        List<Account> accountList = new List<Account>();
        accountList.add(accList[0]);  
        test.StartTest();
        DispatchTriggerHandler.firstTimeTracker.clear();
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        update accountList;
        test.StopTest();
        List<Contact> newContactList = [Select Id,Interface_Email__c,AccountId From Contact where AccountId IN:accountList and Id IN: conList];
        System.assertEquals('test12348@zoetis.com',newContactList[0].Interface_Email__c,'Contact Colleague Entered Email field value changed');
    }
    
    
    @isTest
    private static void getAccountsWithInvalidEmailChangesTest(){
        List<Account> accList = [Select Id,Name,ZTS_EU_Market__c,Email__c,ZTS_Invalid_Email__c From Account where Name ='TestAccount'];
        List<Contact> conList = [Select Id,Interface_Email__c,AccountId,ZTS_Invalid_Email__c From Contact where AccountId IN: accList];
        
        accList[0].ZTS_Invalid_Email__c = true;
        List<Account> accountList = new List<Account>();
        accountList.add(accList[0]);  
        test.StartTest();
        DispatchTriggerHandler.firstTimeTracker.clear();
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        update accountList;
        test.StopTest();
        List<Contact> newContactList = [Select Id,ZTS_Invalid_Email__c,AccountId From Contact where AccountId IN:accountList and Id IN:conList];
        System.assertEquals(true,newContactList[0].ZTS_Invalid_Email__c,'Contact Invalid Email field value changed');
    }
    @isTest
    private static void getAccountsWithNOEmailChangesTest(){
        
        List<Account> accList = [Select Id,Name,ZTS_EU_Market__c,Email__c From Account where Name ='TestAccount'];
        List<Contact> conList = [Select Id,Interface_Email__c,AccountId From Contact where AccountId IN: accList];
        
        accList[0].Name = 'TestAccount21';
        List<Account> accountList = new List<Account>();
        accountList.add(accList[0]);  
        test.StartTest();
        DispatchTriggerHandler.firstTimeTracker.clear();
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        update accountList;
        test.StopTest();
        
        List<Contact> newContactList = [Select Id,ZTS_Invalid_Email__c,AccountId From Contact where AccountId IN:accountList and Id IN:conList And ZTS_Invalid_Email__c=true];
        System.assertEquals(0,newContactList.size(),'No changes on contact record');
    }
    @isTest
    private static void getBulkAccountsWithEmailChangesTest(){
      List<Account> testAccounts = new List<Account>();
        testAccounts.addAll(ZTS_DataUtilityTest.createAccountRecord(6));
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert testAccounts;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Id rtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Account_Contact').getRecordTypeId(); 
        List<Contact> testContacts = new List<Contact>();
        testContacts.addAll(ZTS_DataUtilityTest.createContactRecord(6));
        for(Integer i=0; i<6; i++) {
            testContacts[i].AccountId = testAccounts[i].Id;
            testContacts[i].ZTS_EU_Market__c = 'United States';
            testContacts[i].ZTS_US_Profession__c = 'Account Contact';
            testContacts[i].ZTS_US_Job_Function__c = 'Account Contact';
            testContacts[i].ZTS_EU_Contact_Status__c = 'Active';
            testContacts[i].RecordTypeId =rtId;
        }
        insert testContacts;
        
        testAccounts[0].Email__c = 'test@zoetis.com';
        testAccounts[1].Email__c = 'test@zoetis.com';
        testAccounts[2].ZTS_EU_Opt_Out_Email__c = true;
        testAccounts[3].ZTS_EU_Opt_Out_Email__c = true;
        testAccounts[4].ZTS_Invalid_Email__c = true;
        testAccounts[5].ZTS_Invalid_Email__c = true;
        test.StartTest();
        DispatchTriggerHandler.firstTimeTracker.clear();
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        update testAccounts;
        test.StopTest();
        
        
        List<Contact> newContactList = [Select Id,ZTS_Invalid_Email__c,AccountId,ZTS_EU_Opt_Out_Email__c,Interface_Email__c From Contact where AccountId IN:testAccounts and Id IN:testContacts];
        System.assertEquals(6, newContactList.size(),'6 contact records found with email,Email Opt Out and Invalid Email changes');
        List<Contact> newContactList1 = [Select Id,ZTS_Invalid_Email__c,AccountId,ZTS_EU_Opt_Out_Email__c,Interface_Email__c From Contact where AccountId IN:testAccounts and Id IN:testContacts and Interface_Email__c = 'test@zoetis.com' ];
        List<Contact> newContactList2 = [Select Id,ZTS_Invalid_Email__c,AccountId,ZTS_EU_Opt_Out_Email__c,Interface_Email__c From Contact where AccountId IN:testAccounts and Id IN:testContacts and ZTS_Invalid_Email__c = true];
        List<Contact> newContactList3 = [Select Id,ZTS_Invalid_Email__c,AccountId,ZTS_EU_Opt_Out_Email__c,Interface_Email__c From Contact where AccountId IN:testAccounts and Id IN:testContacts and ZTS_EU_Opt_Out_Email__c = true];
        
        System.assertEquals(2, newContactList1.size(),'2 contact records found with email changes');
        System.assertEquals(2, newContactList2.size(),'2 contact records found with Invalid Email changes');
        System.assertEquals(2, newContactList3.size(),'2 contact records found with Email Opt Out changes');
        System.assertEquals('test@zoetis.com', newContactList1[0].Interface_Email__c,'Contact email changed sucessfully');
        System.assertEquals(true, newContactList2[0].ZTS_Invalid_Email__c,'Contact ZTS_Invalid_Email__c changed sucessfully');
        System.assertEquals(true, newContactList3[0].ZTS_EU_Opt_Out_Email__c, 'Contact ZTS_EU_Opt_Out_Email__c changed sucessfully');
        
        
    }
        

}