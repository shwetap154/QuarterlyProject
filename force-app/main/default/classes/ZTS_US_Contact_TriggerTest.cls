/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Contact_TriggerTest
* Description   :  Test class for ZTS_US_Contact_Trigger
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/11         Akanksha          Created the Class.
* 1.1     01/02        Kaushik Ghosh     updated to include PE(Pet Owner) criteria
* 1.2     10/01/2021    Chelsea Paice    Adding US Profession and Job Function to regular contacts
* 1.3     10/05/2021   Chelsea Paice     Adding test class for phone number update
* 1.4     02/23/2022   Chelsea Paice     Adding test class for contact primary account address change
* 1.5     06/20/2022   Aritra(Cognizant) Updated method "contactPrimaryAccountAddressChange" (SC-008149)

***************************************************************************************************************/
@isTest
public class ZTS_US_Contact_TriggerTest
{
    static testMethod void validate_ZTS_US_Contact_Trigger()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr){
            List<Account> objAcc = ZTS_DataUtilityTest.createAccountRecord(1);
            objAcc[0].ZTS_EU_Market__c = 'United States';
            insert objAcc;
            
            List <Contact> conList= new List <Contact>();
            Contact con= new Contact(
                firstname='Test First',
                lastname = 'Test Last',
                ZTS_EU_Profession__c='Executive Leadership',
                ZTS_Job_Function__c='CEO/President',
                ZTS_US_Profession__c='Executive Leadership',
                ZTS_US_Job_Function__c='CEO/President',
                ZTS_EU_Market__c = 'United States'
            );
            conList.add(con);
            Test.startTest();
            insert conList;
            conList[0].firstname='TestnewFM';
            update conList;
            
            
            PetOwnerAccountId__c objCS = new PetOwnerAccountId__c();
            objCS.Name = 'Pet Owner';
            objCs.account_id__c = objAcc[0].Id;
            insert objCS;
            
            MarketGeoMapping__c mcs = new MarketGeoMapping__c(Geo__c='CLAR',Name = 'Brazil');
            insert mcs;
            
            produceraccountid__c objPA = new produceraccountid__c();
            objPA.Name = 'Producer Owner';
            objPA.Account_Id__c = objAcc[0].Id;
            insert objPA;
            
            EquineAccountId__c objEA = new EquineAccountId__c();
            objEA.Name = 'Equine Owner';
            objEA.Account_Id__c = objAcc[0].Id;
            insert objEA;
            
            //Adding following lines to satisfy Pet Owner contact records which will hold dummy account id upon creation ...Kaushik 12.19.2016
            Id petOwnerContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_Pet_Owner').getRecordTypeId();
            contact petownercon = new contact(
                firstname='petowner',
                lastname='pet',
                recordtypeid=petOwnerContactRecTypeId,
                ZTS_EU_Market__c = 'United States'
            );
            insert petownercon;
            //End....PE scenario
            
            Id producerOwnerContactRecTypeId= Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_SER_Producer_Account').getRecordTypeId();
            contact producerownercon = new contact(
                firstname='producerowner',
                lastname='test',
                ZTS_EU_Profession__c='Executive Leadership',
                ZTS_Job_Function__c='CEO/President',
                ZTS_US_Profession__c='Executive Leadership',
                ZTS_US_Job_Function__c='CEO/President',
                recordtypeid=producerOwnerContactRecTypeId,
                ZTS_EU_Market__c = 'United States'
            );
            insert producerownercon; //End....Producer Account Owner scenario
            Id equineOwnerContactRecTypeId= Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_SER_Equine_Account').getRecordTypeId();
            contact equineownercon = new contact(
                firstname='equineowner',
                lastname='test',
                ZTS_EU_Profession__c='Executive Leadership',
                ZTS_Job_Function__c='CEO/President',
                ZTS_US_Profession__c='Executive Leadership',
                ZTS_US_Job_Function__c='CEO/President',
                recordtypeid=equineOwnerContactRecTypeId,
                ZTS_EU_Market__c = 'United States'
            );
            insert equineownercon; //End....Equine Account Owner scenario
            
            Contact equineownerContact = [Select Id,AccountId,Account.name From Contact Where Id =: equineownercon.Id];
            
            System.assertEquals(equineownerContact.Account.name, 'equineowner test EQO' , 'EQO Account checking');
            Test.stopTest();
        }
    }
    
    static testMethod void validate_ZTS_US_EduCreationAndUpdateFromContact()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'Germany';
        usr.ZTS_EU_Is_Admin__c = true;
        insert usr;
        
        System.runAs(usr)
        {
            List <Contact> contList= new List <Contact>();
            contList=ZTS_DataUtilityTest.createContactRecord(1);
            contList[0].HasOptedOutOfEmail=true;
            contList[0].phone= '9864453746';
            contList[0].ZTS_EU_Market__c='Germany';
            contList[0].ZTS_EU_Opt_Out_Email__c = True;
            insert contList;
            List<Account> accList=new List<Account>();
            accList=ZTS_DataUtilityTest.createAccountRecord(1,87);
            insert accList;
            
            contList[0].firstname = 'Test First1';
            contList[0].lastname = 'Test Contact1';
            contList[0].ZTS_US_Institution__c='Auburn University';
            contList[0].ZTS_US_DVM_Year__c='2005';
            contList[0].ZTS_EU_Market__c='Germany';
            contList[0].phone= '63383653533';
            contList[0].HasOptedOutOfEmail=false;
            contList[0].ZTS_EU_Opt_Out_Email__c = True;
            update contlist[0];    
            Test.startTest();
            ZTS_US_Education_Background__c edu= new ZTS_US_Education_Background__c(ZTS_US_Contact__c=contList[0].Id,ZTS_US_Type__c='DVM');
            ZTS_US_EduCreationAndUpdateFromContact.createEducationRecord(contList);
            List <Contact> newcontList= new List <Contact>();
            newcontList=ZTS_DataUtilityTest.createContactRecord(1);
            newcontList[0].ZTS_US_Institution__c='Tufts University';
            newcontList[0].ZTS_US_DVM_Year__c='2009';
            newcontList[0].phone='746473634';
            insert newcontList;
            newcontList[0].firstname = 'NewUpdateTest';
            newcontList[0].ZTS_EU_Contact_Status__c ='Active';
            newcontList[0].phone ='636383638';
            update newcontList;
            
            Map<Id,Contact> conIdMap=new Map<Id,Contact>();
            conIdMap.put(newcontList[0].Id,newcontList[0]);
            newcontList[0].ZTS_US_Institution__c='Tufts University';
            newcontList[0].ZTS_US_DVM_Year__c='2011';
            
            update newcontList;
            ZTS_US_EduCreationAndUpdateFromContact.updateEducationRecord(newcontList,conIdMap);
            contList[0].ZTS_EU_Contact_Status__c='Inactive';
            update contList;
            ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Account__c = accList[0].Id);
            insert aff;
            
            ZTS_US_EduCreationAndUpdateFromContact.updateAccConAffInactive(contList);
            
            ZTS_EU_Affiliations__c affi = [Select Id,ZTS_EU_Affiliation_Status__c From ZTS_EU_Affiliations__c Where Id = :aff.Id];
            
            System.assertEquals(affi.ZTS_EU_Affiliation_Status__c, 'Inactive', 'Related contact should be inactivated too');
            
            Test.stopTest();
            Delete contList;
        }
        
        
    }
    
    static testMethod void contactPhoneTest() {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'Germany';
        insert usr;
        
        System.runAs(usr){
            List<Account> objAcc = ZTS_DataUtilityTest.createAccountRecord(2);
            for (Account acc : objAcc) {
                acc.Name = 'Horse Owner Account A';
                acc.ZTS_EU_Market__c = 'United States';
            }
            insert objAcc;
            
            List<Address__c> addresses = ZTS_DataUtilityTest.createAddressrec(objAcc);
            for(Address__c addr: addresses){
                addr.ZTS_EU_Address_Type__c = 'Ship To';
                addr.Is_Active__c = true;
                addr.Ship_Indirect__c = 'N';
                addr.LIS_Number__c = '12132';
            }
            
            insert addresses;
            
            EquineAccountId__c ea = new EquineAccountId__c();
            ea.Name = 'Test';
            ea.Account_Id__c = objAcc[0].Id;
            insert ea;
            
            Id producerOwnerContactRecTypeId= Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_SER_Producer_Account').getRecordTypeId();
            Id equineOwnerContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_SER_Equine_Account').getRecordTypeId();
            Id accountContactId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Account_Contact').getRecordTypeId();
            
            List <Contact> conList= new List <Contact>();
            Contact con1 = new Contact(
                firstname='Test First',
                lastname = 'Test Last 1',
                ZTS_EU_Profession__c='Executive Leadership',
                ZTS_Job_Function__c='CEO/President',
                ZTS_US_Profession__c='Veterinarian',
                ZTS_US_Job_Function__c='Associate',
                AccountId = objAcc[0].Id,
                Reference_Lab_Contact__c = true,
                ZTS_EU_Market__c = 'United States',
                Phone = '(555) 234-5678',
                RefLabs_Email_Default__c = true,
                RefLabs_Results_Email__c = 'test@test.com',
                RecordTypeId = accountContactId
            );
            conList.add(con1);
            Contact con2 = new Contact(
                firstname='Tst Frst',
                lastname = 'Tst Lst 1',
                ZTS_EU_Profession__c='Executive Leadership',
                ZTS_Job_Function__c='CEO/President',
                ZTS_US_Profession__c='Veterinarian',
                ZTS_US_Job_Function__c='Associate',
                AccountId = objAcc[0].Id,
                Reference_Lab_Contact__c = true,
                ZTS_EU_Market__c = 'United States',
                Phone = '(555) 234-5678',
                RefLabs_Email_Default__c = true,
                RefLabs_Results_Email__c = 'test@test.com',
                RecordTypeId = producerOwnerContactRecTypeId,
                ZTS_EU_Opt_Out_Email__c=true
            );
            conList.add(con2);
            Contact con3 = new Contact(
                firstname='Test1 First1',
                lastname = 'Test1 Last2',
                ZTS_EU_Profession__c='Executive Leadership',
                ZTS_Job_Function__c='CEO/President',
                ZTS_US_Profession__c='Veterinarian',
                ZTS_US_Job_Function__c='Associate',
                AccountId = objAcc[0].Id,
                Reference_Lab_Contact__c = true,
                ZTS_EU_Market__c = 'United States',
                Phone = '(555) 234-5678',
                RefLabs_Email_Default__c = true,
                RefLabs_Results_Email__c = 'test@test.com',
                RecordTypeId = equineOwnerContactRecTypeId
            );
            conList.add(con3);
            
            insert conList;
            
            List<Contact> contactAfterInsert = [SELECT Id,Phone FROM Contact WHERE AccountId = :objAcc[0].Id];
            System.assertEquals('+15552345678',contactAfterInsert[0].Phone);
            List<Contact> contactsForUpsert = new List<Contact>();
            contactAfterInsert[0].Phone = '(555) 234-5678';
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            
            Test.startTest();
            update contactAfterInsert[0];
            Contact con4 = new Contact(
                firstname='New',
                lastname = ' Contact',
                ZTS_EU_Profession__c='Executive Leadership',
                ZTS_Job_Function__c='CEO/President',
                ZTS_US_Profession__c='Executive Leadership',
                ZTS_US_Job_Function__c='CEO/President',
                AccountId = objAcc[0].Id,
                ZTS_EU_Market__c = 'United States',
                Phone = '(555) 234-5678'
            );
            insert con4;
            
            
            List<Contact> contactsAfterUpsert = [SELECT Id,Phone,Name FROM Contact WHERE AccountId = :objAcc[0].Id];
            for (Contact con : contactsAfterUpsert) {
                System.assertEquals('+15552345678',con.Phone);
            }
            Contact horseOwnerContact = [Select Id, AccountId, Account.name From Contact Where RecordTypeId =:equineOwnerContactRecTypeId];
            
            System.assertEquals(horseOwnerContact.Account.Name, 'Test1 First1 Test1 Last2 EQO', 'Enquine account creation');
            Test.stopTest();
        }
    }
    
    static testMethod void contactPrimaryAccountAddressChange() {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        System.runAs(usr){
            List<Account> objAcc = ZTS_DataUtilityTest.createAccountRecord(2);
            Integer acctNum = 1;
            for (Account acc : objAcc) {
                acc.Name = 'test acc ' + acctNum;
                acc.ZTS_EU_Market__c = 'United States';
                acc.BillingStreet = 'Test Street ' + acctNum;
                acc.BillingCity = 'Test City';
                acc.BillingState = 'WI';
                acc.BillingPostalCode = '23456';
                acc.BillingCountry = 'United States';
                acctNum++;
            }
            insert objAcc;
            
            
            Contact con1 = new Contact(
                firstname='Test First',
                lastname = 'Test Last 1',
                ZTS_EU_Profession__c='Executive Leadership',
                ZTS_Job_Function__c='CEO/President',
                ZTS_US_Profession__c='Executive Leadership',
                ZTS_US_Job_Function__c='CEO/President',
                AccountId = objAcc[0].Id,
                ZTS_EU_Market__c = 'United States',
                Phone = '(555) 234-5678'
            );
            
            insert con1;
            System.assertEquals(objAcc[0].Id,con1.AccountId);
            String acctStreet = objAcc[1].BillingStreet;
            
            Test.startTest();
            //Added for SC-008149
            //Aritra Added below 2 lines as the Contact Trigger was not being fired previously, hence the test method was failing
            ContactTriggerHandler handler = new ContactTriggerHandler();
            DispatchTriggerHandler.setRecursionContexts(handler);
            //-End of change
            con1.AccountId = objAcc[1].Id;
            update con1;
            Test.stopTest();
            
            Contact updatedContact = [SELECT Id,MailingStreet FROM Contact WHERE Id = :con1.Id];
            System.assertEquals(acctStreet,updatedContact.MailingStreet);
        }
    }
    static testMethod void beforeInsert()
    {
        Test.startTest();
        //CheckRecursiveTrigger.run = true;
        //ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'Germany';
        insert usr;
        
        
        
        System.runAs(usr)
        {
            State_Country__c testStateCountry = TestDataFactory.createStateCountry('Germany', 'Germany', true);
            State_Country__c testStateCountry1 = TestDataFactory.createStateCountry('Albania', 'Albania', true);
            State_Country__c testCommune = TestDataFactory.createStateCountry('Test Commune', 'Test Commune', false);
            testCommune.ZTS_EU_Parent_State_Country__c = testStateCountry.Id;
            insert testCommune;
            Map<id,Contact>conmapold=new Map<id,Contact>();
            Map<id,Contact>conmapnew=new Map<id,Contact>();
            List <Contact> contList= new List <Contact>();
            contList=ZTS_DataUtilityTest.createContactRecord(1);
            contList[0].ZTS_EU_Opt_Out_Email__c=true;
            contList[0].HasOptedOutOfEmail=false;
            contList[0].phone= '8765453746';
            contList[0].ZTS_EU_Country__c = 'Germany';
            contList[0].ZTS_EU_State_County__c = testStateCountry.id;
            
            
            conmapnew.put(contList[0].id,contList[0]);
            insert contList;
            List<Account> accList=new List<Account>();
            accList=ZTS_DataUtilityTest.createAccountRecord(1,87);
            insert accList;
            contList[0].firstname = 'Test First1';
            contList[0].lastname = 'Test Contact1';
            contList[0].ZTS_US_Institution__c='Auburn University';
            contList[0].ZTS_US_DVM_Year__c='2005';
            contList[0].ZTS_EU_Market__c='Germany';
            contList[0].HasOptedOutOfEmail=true;
            contList[0].phone= '63637383864';
            contList[0].ZTS_EU_Country__c = 'Albania';
            contList[0].ZTS_EU_State_County__c = testStateCountry1.id;
            
            //conmapold.put(contList[0].id,contList[0]);
            //CheckRecursiveTrigger.run = true;
            update contlist[0]; 
            //system.assertEquals(contlist[0].HasOptedOutOfEmail, contlist[0].ZTS_EU_Opt_Out_Email__c);
            Contact updatedContact = [SELECT Id, firstname, lastname, ZTS_US_Institution__c,HasOptedOutOfEmail,ZTS_US_DVM_Year__c,ZTS_EU_Opt_Out_Email__c, ZTS_EU_Market__c, phone, ZTS_EU_Country__c, ZTS_EU_State_County__c FROM Contact WHERE Id = :contList[0].Id];
            System.assertEquals('Test First1', updatedContact.firstname);
            System.assertEquals('Test Contact1', updatedContact.lastname);
            system.assertEquals(updatedContact.HasOptedOutOfEmail, updatedContact.ZTS_EU_Opt_Out_Email__c);
            //INTLContactTriggerService.beforeUpdate(contList,conmapnew,contList,conmapold);
            Test.stopTest();
            
        } 
    }
    
    
    static testMethod void beforeUpdate()
    {

        Test.startTest();
        List<Contact> triggerOld = new List<Contact>();
        List<Contact> triggernew = new List<Contact>();
        Map<Id, Contact> triggerOldMap = new Map<Id, Contact>();
        Map<Id, Contact> triggerNewMap = new Map<Id, Contact>();
        
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.ZTS_EU_Market__c = 'Germany'; 
        usr.ZTS_EU_Is_Admin__c = true;
        insert usr;
        
        list<MarketGeoMapping__c> MarketGeoMappingSetting = new list<MarketGeoMapping__c>();
        MarketGeoMappingSetting.add(createMarketGeoMappingSetting('United Kingdom','SKU'));
        
        insert MarketGeoMappingSetting;
        
        Account diagnosticAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
        //insert diagnosticAccount;
        System.runAs(usr)
        {
            Contact con = new Contact(); 
            con.firstname='Test First';
            con.lastname = 'Test Contact'; 
            con.ZTS_EU_Profession__c='Executive Leadership';
            con.ZTS_US_Profession__c='Executive Leadership';
            con.ZTS_Job_Function__c='CEO/President';
            con.ZTS_US_Job_Function__c='CEO/President';
            con.ZTS_EU_Market__c = 'Germany'; 
            con.HasOptedOutOfEmail=True;
            con.phone= '73463473783';
            con.ZTS_EU_Opt_Out_Email__c = True;
            con.AccountId = diagnosticAccount.id;
            con.ZTS_EU_Contact_Status__c = 'Active'; 
            insert con;
            triggerOld.add(con);
            triggerOldMap.put(con.id, con);
            
            contact cont = [select id,ZTS_EU_City_Country__c,Full_Contact_Name__c,ZTS_EU_Contact_Status__c,ZTS_EU_Contact_type__c,ZTS_EU_Market__c,
                            ZTS_EU_Create_Samples__c,Certification_Status__c from contact where ZTS_EU_Profession__c='Executive Leadership'];
            cont.firstname = 'Test First1';
            cont.lastname = 'Test Contact1';
            cont.ZTS_US_Institution__c='Auburn University'; 
            cont.ZTS_US_DVM_Year__c='2005';
            cont.ZTS_EU_Market__c='Germany';
            cont.phone= '63383653533';
            cont.HasOptedOutOfEmail=false;
            cont.ZTS_EU_Opt_Out_Email__c = false;
            con.ZTS_EU_Contact_Status__c = 'Pending Email';
            //CheckRecursiveTrigger.run = true;
            
            update cont;
            triggernew.add(cont);
            triggerNewMap.put(cont.id, cont);
            
            INTLContactTriggerService.beforeUpdate(triggerOld,triggerOldMap,triggernew,triggerNewMap);
            
            INTLContactTriggerService.afterInsert(triggernew,triggerNewMap); 
            
            
        }
        INTLContactTriggerService.beforeUpdate(triggerOld,triggerOldMap,triggernew,triggerNewMap);
        
        
        for (Contact c : triggernew) {
            System.assertEquals('Active', c.ZTS_EU_Contact_Status__c);
            system.assertEquals(c.HasOptedOutOfEmail, c.ZTS_EU_Opt_Out_Email__c);//Rachana added to make sure TPDEV-479 works perfectly
        }
        
      
        INTLContactTriggerService.afterInsert(triggernew,triggerNewMap);
        
        Test.stopTest();
    }
    
    static testMethod void beforeUpdate_contactfieldmap1()
    {
        Test.startTest();
        List<Contact> triggerOld = new List<Contact>();
        List<Contact> triggernew = new List<Contact>();
        Map<Id, Contact> triggerOldMap = new Map<Id, Contact>();
        Map<Id, Contact> triggerNewMap = new Map<Id, Contact>();
        
        
        
        
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'Germany';
        usr.ZTS_EU_Is_Admin__c = true;
        insert usr;
        
        List<Account> objAcc = ZTS_DataUtilityTest.createAccountRecord(1);
        insert objAcc;
        
        System.runAs(usr)
        {
            Contact con = new Contact(); 
            con.firstname='Test First';
            con.lastname = 'Test Contact'; 
            con.ZTS_EU_Profession__c='Executive Leadership';
            con.ZTS_US_Profession__c='Executive Leadership';
            con.ZTS_Job_Function__c='CEO/President';
            con.ZTS_US_Job_Function__c='CEO/President';
            con.ZTS_EU_Market__c = 'Germany';
            con.HasOptedOutOfEmail=false;
            con.phone= '73463473783';
            con.ZTS_EU_Opt_Out_Email__c = True;
            con.AccountId = objAcc[0].id;
            con.ZTS_EU_Contact_Status__c = 'Active';  
            insert con;
            triggerOld.add(con);
            triggerOldMap.put(con.id, con);
            
            contact cont = [select id,AccountId,ZTS_EU_City_Country__c,Full_Contact_Name__c,ZTS_EU_Contact_Status__c,ZTS_EU_Contact_type__c,ZTS_EU_Market__c,
                            ZTS_EU_Create_Samples__c,Certification_Status__c from contact where ZTS_EU_Profession__c='Executive Leadership'];
            cont.firstname = 'Test First1';
            cont.lastname = 'Test Contact1';
            cont.ZTS_US_Institution__c='Auburn University'; 
            cont.ZTS_US_DVM_Year__c='2005';
            cont.ZTS_EU_Market__c='Germany';
            cont.phone= '63383653533';
            cont.HasOptedOutOfEmail=false;
            cont.ZTS_EU_Opt_Out_Email__c = false;
            con.ZTS_EU_Contact_Status__c = 'Pending Email'; 
            //CheckRecursiveTrigger.run = true;
            
            update cont;
            triggernew.add(cont);
            triggerNewMap.put(cont.id, cont);
            
            
            
            INTLContactTriggerService.beforeUpdate(triggerOld,triggerOldMap,triggernew,triggerNewMap);
            
            INTLContactTriggerService.afterInsert(triggernew,triggerNewMap); 
            delete cont;
        }
        for (Contact c : triggernew) {
            System.assertEquals('Active', c.ZTS_EU_Contact_Status__c);
            system.assertEquals(c.HasOptedOutOfEmail, c.ZTS_EU_Opt_Out_Email__c);//Rachana added to make sure TPDEV-479 works perfectly
        }
        
        
        INTLContactTriggerService.afterInsert(triggernew,triggerNewMap);
        
        Test.stopTest();
    }
    
    static testMethod void beforeUpdates_contactfieldmap2()
    {
        Test.startTest();
        List<Contact> triggerOld = new List<Contact>();
        List<Contact> triggernew = new List<Contact>();
        Map<Id, Contact> triggerOldMap = new Map<Id, Contact>();
        Map<Id, Contact> triggerNewMap = new Map<Id, Contact>();
        
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.ZTS_EU_Market__c = 'Spain'; 
        usr.ZTS_EU_Is_Admin__c = true;
        insert usr;
        
        list<MarketGeoMapping__c> MarketGeoMappingSetting = new list<MarketGeoMapping__c>();
        MarketGeoMappingSetting.add(createMarketGeoMappingSetting('United Kingdom','SKU'));
        
        insert MarketGeoMappingSetting;
        
        AccountAndContactOwnerId__c acc1 = new AccountAndContactOwnerId__c(Name = 'Test User', Market__c = usr.ZTS_EU_Market__c, OwnerId__c = usr.id);
        insert acc1;
        
        Account diagnosticAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
        List<Account> accList=new List<Account>();
        accList=ZTS_DataUtilityTest.createAccountRecord(1,87);
        //insert accList;
        
        
        System.runAs(usr)
        {
            Contact con = new Contact(); 
            con.firstname='Test First';
            con.lastname = 'Test Contact'; 
            con.ZTS_EU_Profession__c='Executive Leadership';
            con.ZTS_US_Profession__c='Executive Leadership';
            con.ZTS_Job_Function__c='CEO/President';
            con.ZTS_US_Job_Function__c='CEO/President';
            //con.ZTS_EU_Market__c = 'Germany'; 
            con.HasOptedOutOfEmail=True;
            con.phone= '73463473783';
            con.ZTS_EU_Opt_Out_Email__c = True;
            con.AccountId = accList[0].id;
            con.ZTS_EU_Contact_Status__c = 'Active'; 
            insert con;
            triggerOld.add(con);
            triggerOldMap.put(con.id, con);
            
            contact cont = [select id,ZTS_EU_City_Country__c,Full_Contact_Name__c,ZTS_EU_Contact_Status__c,ZTS_EU_Contact_type__c,ZTS_EU_Market__c,
                            ZTS_EU_Create_Samples__c,Certification_Status__c from contact where ZTS_EU_Profession__c='Executive Leadership'];
            cont.firstname = 'Test First1';
            cont.lastname = 'Test Contact1';
            cont.ZTS_US_Institution__c='Auburn University'; 
            cont.ZTS_US_DVM_Year__c='2005';
            //cont.ZTS_EU_Market__c='Germany';
            cont.phone= '63383653533';
            cont.HasOptedOutOfEmail=false;
            cont.ZTS_EU_Opt_Out_Email__c = false;
            con.ZTS_EU_Contact_Status__c = 'Pending Email';
            //CheckRecursiveTrigger.run = true;
            
            update cont;
            
            triggernew.add(cont);
            triggerNewMap.put(cont.id, cont);
            
            INTLContactTriggerService.beforeUpdate(triggerOld,triggerOldMap,triggernew,triggerNewMap);
            //INTLContactTriggerService.afterUpdate(triggerOld,triggerOldMap,triggernew,triggerNewMap);
            INTLContactTriggerService.afterInsert(triggernew,triggerNewMap); 
            
        }
        for (Contact c : triggernew) {
            System.assertEquals('Active', c.ZTS_EU_Contact_Status__c);
            system.assertEquals(c.HasOptedOutOfEmail, c.ZTS_EU_Opt_Out_Email__c);//Rachana added to make sure TPDEV-479 works perfectly
        }
        
        
        INTLContactTriggerService.afterInsert(triggernew,triggerNewMap);
        
        Test.stopTest();
    }
    
    public static MarketGeoMapping__c createMarketGeoMappingSetting(string name, string potentialLevel){
        MarketGeoMapping__c marketGeoMapping = new MarketGeoMapping__c(name = name,Product_Potential_Level__c = potentialLevel, Applicable_for_Samples_batch_process__c = True);
        return marketGeoMapping;                                                                           
    }
    static testMethod void AtlasIntegration_field_Override(){
        
        AutomationSettings__c automationSettings = new AutomationSettings__c(Atlas_Integration_User__c = '0054z000009MnHBAA0');
        insert automationSettings;
        
        List<Contact> triggerOld = new List<Contact>();
        List<Contact> triggerNew = new List<Contact>();
        Map<Id, Contact> triggerOldMap = new Map<Id, Contact>();
        Map<Id, Contact> triggerNewMap = new Map<Id, Contact>();
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        Contact oldContact = new Contact(
            FirstName='Test First',
            lastname = 'Test Last',
            ZTS_EU_Middle_Name__c='Test Middle',
            ZTS_US_Atlas_Id__c='12345',
            Email=null,
            MobilePhone='1234567891',
            ZTS_EU_Profession__c='Executive Leadership',
            ZTS_Job_Function__c='CEO/President',
            ZTS_US_Profession__c='Executive Leadership',
            ZTS_US_Job_Function__c='CEO/President',
            ZTS_EU_Market__c = 'United States'
        );
        insert oldContact;
        
        Contact newContact = new Contact(
            Id = oldContact.Id,
            FirstName = null,
            lastname = 'Test Last',
            ZTS_EU_Middle_Name__c='Test Middle Update',
            ZTS_US_Atlas_Id__c='12345',
            Email='test@test.com',
            MobilePhone=null,
            ZTS_EU_Profession__c='Executive Leadership',
            ZTS_Job_Function__c='CEO/President',
            ZTS_US_Profession__c='Executive Leadership',
            ZTS_US_Job_Function__c='CEO/President',
            ZTS_EU_Market__c = 'United States'
        );
        
        
        triggerOld.add(oldContact);
        triggerOldMap.put(oldContact.Id, oldContact);
        triggerNew.add(newContact);
        triggerNewMap.put(newContact.Id, newContact);
        System.runAs(new User(Id = AutomationSettings.Atlas_Integration_User__c)) {
            test.startTest();
            USContactTriggerService.beforeUpdate(triggerOld, triggerOldMap, triggerNew, triggerNewMap);
            test.stopTest();
            system.assertEquals('Test First', newContact.FirstName,'first name didn\'t get updated to a null');
            system.assertEquals('Test Middle Update', newContact.ZTS_EU_Middle_Name__c,'middle name got updated to a new value');
            system.assertEquals('test@test.com',newContact.Email,'email was updated from the null value to a new updated value');
            
        }
    }
    
}