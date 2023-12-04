/*************************************************************************************************************
* File Name     :  ZTS_GL_accUpdateClassTest
* Description   :  Test class for ZTS_GL_accUpdateClass
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/16         Akanksha          Created the Class.
* 1.1     2/24         Padma             Removed ContactsService.updateContactwithAccountEmail methode out  no test code running for this logic TPDEV-103
***************************************************************************************************************/

@isTest
public class ZTS_GL_accUpdateClassTest{
    @testSetup 
    static void setup()
    {
		ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
    }
    static testMethod void validate_UpdateAccOnCont(){
        User manager = new User();
        manager = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        manager.FirstName = 'manager';
        manager.zts_eu_market__c = 'United States';
        insert manager;
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        usr.ManagerId = manager.Id;
        insert usr;
        
        System.runAs(usr)
        {
            Test.startTest();
            ZTS_DataUtilityTest.activateTriggerSettings();
            List<Account> accList=new List<Account>();
            accList=ZTS_DataUtilityTest.createAccountRecord(1,56);
            accList[0].ZTS_EU_Market__c = 'United States';
            insert accList;
            List <Contact> contList= new List <Contact>();
            contList=ZTS_DataUtilityTest.createContactRecord(1);
            contList[0].ZTS_EU_Market__c = 'United States';
            insert contList;
            ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Account__c= accList[0].Id);
            insert aff;
            List<ZTS_EU_Affiliations__c> aconaffListNew= new List<ZTS_EU_Affiliations__c>();
            aconaffListNew.add(aff);
            List<Account> accListnew=new List<Account>();
            accListnew=ZTS_DataUtilityTest.createAccountRecord(1,54);
            insert accListnew;
            List <Contact> contListnew= new List <Contact>();
            contListnew=ZTS_DataUtilityTest.createContactRecord(1);
            contListnew[0].ZTS_EU_Market__c = 'United States';
            insert contListnew;
            List<ZTS_Animal_Count_Potential__c> lstanimalcount = ZTS_DataUtilityTest.createAnimalCount(accList);
            insert lstanimalcount;
            delete lstanimalcount;
            undelete lstanimalcount;
            ZTS_EU_Affiliations__c aff2 = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contListnew[0].Id, ZTS_EU_Account__c= accListnew[0].Id);
            insert aff2;
            List<ZTS_EU_Affiliations__c> aconaffListOld= new List<ZTS_EU_Affiliations__c>();
            aconaffListOld.add(aff2);
            Map<Id,ZTS_EU_Affiliations__c> mapold=new Map<Id,ZTS_EU_Affiliations__c>();
            mapold.put(aconaffListNew[0].Id,aconaffListNew[0]);
            update aconaffListNew;
            Map<Id,ZTS_EU_Affiliations__c> mapnew=new Map<Id,ZTS_EU_Affiliations__c>();
            mapnew.put(aconaffListNew[0].Id,aconaffListNew[0]);
            
            List < ZTS_EU_Territory__c > customterrList = ZTS_DataUtilityTest.createCustomTerritory(10);
            insert customterrList;
            
            List < ZTS_AccountTerritory__c > accterr = ZTS_DataUtilityTest.createAccountTerritory(acclist, customterrList);
            insert accterr;
            
            ZTS_GL_accUpdateClass accup= new ZTS_GL_accUpdateClass();
            aconaffListNew=[Select Id,ZTS_EU_Contact__c,ZTS_EU_Account__c,ZTS_US_LE_Contact__c,ZTS_EU_Account_influence__c,ZTS_US_Job_Function__c,ZTS_US_Primary_Account__c from  ZTS_EU_Affiliations__c]; 
            accup.UpdateAccOnCont(aconaffListNew,aconaffListOld,mapnew,mapold,false,true); 
            Contact con = [Select Id,MailingCity,MailingCountry,Account.BillingCity,Account.BillingCountry From Contact Where Id =: aconaffListNew[0].ZTS_EU_Contact__c Limit 1];
            system.assertEquals(con.MailingCity, con.Account.BillingCity);
            system.assertEquals(con.MailingCountry, con.Account.BillingCountry);
            Test.stopTest();
        }
    }
    
    public static testMethod void validate_updateContactsStatusInactive(){
        User manager = new User();
        manager = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        manager.FirstName = 'manager';
        manager.zts_eu_market__c = 'United States';
        insert manager;
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        usr.ManagerId = manager.id;
        insert usr;
        
        System.runAs(usr)
        {
            Test.startTest();
            ZTS_DataUtilityTest.activateTriggerSettings();
            List<Account> accList=new List<Account>();
            accList=ZTS_DataUtilityTest.createAccountRecord(2,38);
            insert accList;
            accList[0].MZR_Status__c = 'Eligible';
            accList[0].ZTS_US_MVP_Account__c = false;
            accList[0].ZTS_US_MVP_BIOS__c = null;
            accList[0].MZR_Tier__c = null;
            accList[0].ZTS_US_VGP_Enrollment_Status__c = 'Customer Accepted T&C – enrollment in Process';
            accList[0].ZTS_EU_Market__c = 'United States';
            update accList;
            List <Contact> contList= new List <Contact>();
            contList=ZTS_DataUtilityTest.createContactRecord(2);
            contList[0].ZTS_EU_Contact_Status__c = 'Active';
            contList[0].ZTS_EU_Market__c = 'United States';
            contList[1].ZTS_EU_Market__c = 'United States';
            insert contList;
            ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Affiliation_Status__c = 'Active', ZTS_EU_Account__c= accList[0].Id);
            insert aff; 
            ZTS_EU_Affiliations__c aff2 = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Affiliation_Status__c = 'Inactive', ZTS_EU_Account__c= accList[1].Id);
            insert aff2;
            ZTS_DataUtilityTest.activateTriggerSettings();
            List<Contract> contrList = ZTS_DataUtilityTest.createContractRecord(1);
            contrList[0].RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('New_Contract').getRecordTypeId();
            contrList[0].ZTS_US_Field_Proposed_Tier__c = 'Animal Health Account'; 
            contrList[0].Status = 'New';   
            contrList[0].ZTS_US_Submitter_Comments__c = 'Test'; 
            contrList[0].Name = '2019 LE Agreement';
            contrList[0].AccountId = accList[0].Id;
            insert contrList;
            accList[0].ZTS_US_NARC_Id__c = '12333';
            update accList[0];
            contrList[0].Contract_Type__c = 'Proposal';
            contrList[0].Send_Email_to_LE_Owner__c = true;
            update contrList[0];
            
            
            Set<Id> contIdSet= new Set<Id>();
            for(Contact c : [Select Id from Contact]){
                contIdSet.add(c.Id);
            }
            Map<Id, Account> historyMap = new Map<Id, Account>(accList);
            for(Account oh : accList)
            {
                historyMap.put(oh.Id, oh);
            }
            ZTS_GL_accUpdateClass accup= new ZTS_GL_accUpdateClass();
            accup.updateContactsStatus(contIdSet);
            USSL_AccountTriggerHandler SLACC = new USSL_AccountTriggerHandler();
            SLACC.onBeforeInsert(accList);
            SLACC.onBeforeDelete(accList);
            SLACC.onAfterDelete(accList);
            ZTS_US_addrCreationAndUpdateFromAccount.updateAccConAffInactive(accList);
            ZTS_US_addrCreationAndUpdateFromAccount.updatenullvaluesonchildaccounts(historyMap);
            List<Contact>  contacts = [Select Id,ZTS_EU_Contact_Status__c FROM Contact WHERE Id in : contIdSet AND ZTS_EU_Market__c = 'United States'];
            for(Contact con: contacts){
                system.assertNotEquals(con.ZTS_EU_Contact_Status__c, 'Inactive');
            }
            Test.stopTest();
        }
    }
    
    static testMethod void validate_updateContactsStatusActive(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            Test.startTest();
            ZTS_DataUtilityTest.activateTriggerSettings();
            List<Account> accList=new List<Account>();
            accList=ZTS_DataUtilityTest.createAccountRecord(2,38);
            insert accList;
            accList[0].MZR_Status__c = 'Active';
            accList[0].ZTS_US_MVP_Account__c = false;
            accList[0].ZTS_US_MVP_BIOS__c = 'False';
            accList[0].MZR_Tier__c = null;
            accList[0].ZTS_US_VGP_Enrollment_Status__c = 'Customer Accepted T&C – enrollment in Process';
            accList[0].ZTS_EU_Market__c = 'United States';
            update accList;
            List <Contact> contList= new List <Contact>();
            contList=ZTS_DataUtilityTest.createContactRecord(2);
            contList[0].ZTS_EU_Contact_Status__c = 'Active';
            contList[0].ZTS_EU_Market__c = 'United States';
            contList[1].ZTS_EU_Market__c = 'United States';
            insert contList;
            ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Affiliation_Status__c = 'Inactive', ZTS_EU_Account__c= accList[0].Id);
            insert aff; 
            ZTS_EU_Affiliations__c aff2 = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Affiliation_Status__c = 'Inactive', ZTS_EU_Account__c= accList[1].Id);
            insert aff2;
            Set<Id> contIdSet= new Set<Id>();
            for(Contact c : [Select Id from Contact]){
                contIdSet.add(c.Id);
            }
            ZTS_GL_accUpdateClass accup= new ZTS_GL_accUpdateClass();
            accup.updateContactsStatus(contIdSet);
            Contact con = [Select Id,ZTS_EU_Contact_Status__c From Contact Where Id =: contList[0].Id limit 1];
            system.assertEquals(con.ZTS_EU_Contact_Status__c, 'Inactive');
            Test.stopTest();
        }
    }
    
    static testMethod void validate_whenAccNarcd(){
        User manager = new User();
        manager = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        manager.FirstName = 'manager';
        manager.zts_eu_market__c = 'United States';
        insert manager;
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        usr.ManagerId = manager.Id;
        insert usr;
        
        System.runAs(usr)
        {
            Test.startTest();
            List<Account> accList=new List<Account>();
            accList=ZTS_DataUtilityTest.createAccountRecord(1,1);
            accList[0].ZTS_US_NARC_Id__c = null;
            insert accList;
            accList[0].MZR_Status__c = 'Not Eligible';
            accList[0].ZTS_US_MVP_Account__c = false;
            accList[0].ZTS_US_MVP_BIOS__c = 'False';
            accList[0].MZR_Tier__c = null;
            accList[0].ZTS_US_VGP_Enrollment_Status__c = 'Customer Accepted T&C – enrollment in Process';
            update accList;
            ZTS_DataUtilityTest.activateTriggerSettings();
            List<Contract> contrList = ZTS_DataUtilityTest.createContractRecord(1);
            contrList[0].RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('New_Contract').getRecordTypeId();
            contrList[0].ZTS_US_Field_Proposed_Tier__c = 'Animal Health Account'; 
            contrList[0].Status = 'New';   
            contrList[0].ZTS_US_Submitter_Comments__c = 'Test'; 
            contrList[0].Name = '2019 LE Agreement';
            contrList[0].AccountId = accList[0].Id;
            insert contrList;
            accList[0].ZTS_US_NARC_Id__c = '12333';
            update accList[0];
            contrList[0].Contract_Type__c = 'Proposal';
            contrList[0].Send_Email_to_LE_Owner__c = true;
            update contrList[0];
            Test.stopTest();
        }
    }
    
    static testMethod void validate_whenParentAccProgChanged(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser21';
        usr.ZTS_EU_Market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            Test.startTest();
            Account parent = new Account(Name='Test Parent',BillingStreet='test_b', BillingCity='test_c',BillingPostalCode='test_pc', BillingCountry='United States',BillingState='TX');
            parent.ZTS_EU_Market__c = 'United States';         
            insert parent;
            Account child = new Account(Name='Test child',ParentId=parent.Id,BillingStreet='test_b', BillingCity='test_c',BillingPostalCode='test_pc', BillingCountry='United States',BillingState='TX');
            child.ZTS_EU_Market__c = 'United States';
            insert child;
            parent.ZTS_US_MVP_Account__c = True;
            parent.MZR_PARAs_Account__c = True;
            parent.ZTS_US_MVP_BIOS__c = '1000';
            parent.MZR_PARAs_Tier__c = '2000';
            ZTS_DataUtilityTest.activateTriggerSettings(); 
            update parent;
            Account childAcc = [Select Id,ZTS_US_MVP_Account__c,MZR_PARAs_Account__c From Account Where Id = :child.Id AND ZTS_EU_Market__c = 'United States' Limit 1];
            
            system.assertEquals(childAcc.MZR_PARAs_Account__c, false);
            system.assertEquals(childAcc.ZTS_US_MVP_Account__c, false);
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
            ZTS_DataUtilityTest.activateTriggerSettings();
            List<Account> accList=new List<Account>();
            accList = ZTS_DataUtilityTest.createAccountRecord(6);
            for (Account a : accList)
            {
                a.BillingStreet='test_b';
                a.BillingCity='test_c';
                a.BillingPostalCode='test_pc';
                a.BillingCountry='United States';
                a.BillingState='TX';
                a.ZTS_EU_Market__c = 'United States';
            }
            insert accList;
            ZTS_US_addrCreationAndUpdateFromAccount.chkUpdate = true;
            accList[0].BillingStreet ='Test 1 Street';
            accList[4].parentId= accList[0].id;
            accList[5].parentId= accList[0].id;   
            update accList;
            
            accList[0].MZR_Status__c ='Active';
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
            update accList;
            
            delete accList[4];
            
            Test.startTest();
            Account master = new Account(Name='Account1',BillingStreet='test_b', BillingCity='test_c',BillingPostalCode='test_pc', BillingCountry='United States',BillingState='TX');
            insert master;        
            Account[] duplicates = new Account[]{new Account(Name='Account1, Inc.',BillingStreet='test_b', BillingCity='test_c',BillingPostalCode='test_pc', BillingCountry='United States',BillingState='TX'), new Account(Name='Account 1',BillingStreet='test_b', BillingCity='test_c',BillingPostalCode='test_pc', BillingCountry='United States',BillingState='TX')};
                insert duplicates;        
            Database.MergeResult[] results = Database.merge(master, duplicates, false);
            
            
            ZTS_US_checkTriggerRun.resetAll();
            Map<Id, Account> acctsMap = new Map<Id, Account>();
            
            for(Account acct : accList) 
                acctsMap.put(acct.Id, acct);
            
            Set<Id> contIdSet= new Set<Id>();
            for(Contact c : [Select Id from Contact]){
                contIdSet.add(c.Id);
            }
            Map<Id, Account> historyMap = new Map<Id, Account>(accList);
            for(Account oh : accList)
            {
                historyMap.put(oh.Id, oh);
            }
            Test.stopTest();
            System.assertNotEquals(accList.size(),0);
        } 
    }
    
    static testmethod void updateAccTest()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            ZTS_DataUtilityTest.activateTriggerSettings();
            List<Account> accList=new List<Account>();
            accList = ZTS_DataUtilityTest.createAccountRecord(4);
            Integer i = 1;
            for (Account a : accList)
            {
                a.BillingStreet='test_b';
                a.BillingCity='test_c';
                a.BillingPostalCode='test_pc';
                a.BillingCountry='United States';
                a.BillingState='TX';
                a.ZTS_EU_Market__c = 'United States';
                a.ZTS_US_NARC_ID__c = 'testId'+i;
                i++;
                a.ZTS_US_VGP_Enrollment_Status__c = 'test';
            }
            insert accList;
            
            List <Contact> contList= new List <Contact>();
            contList=ZTS_DataUtilityTest.createContactRecord(2);
            contList[0].ZTS_EU_Contact_Status__c = 'Active';
            contList[0].ZTS_EU_Market__c = 'United States';
            contList[1].ZTS_EU_Market__c = 'United States';
            contList[0].AccountId = accList[0].Id;
            contList[1].AccountId = accList[1].Id;
            insert contList;

            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            List<ZTS_Animal_Count_Potential__c> lstanimalcount = ZTS_DataUtilityTest.createAnimalCount(accList);
            insert lstanimalcount;

            DispatchTriggerHandler.firstTimeTracker = new Set<String>();

            ZTS_US_addrCreationAndUpdateFromAccount.chkUpdate = true;
            accList[0].BillingStreet ='Test 1 Street';
            accList[2].parentId= accList[0].id;
            accList[3].parentId= accList[0].id;   
            update accList;
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            
            accList[0].MZR_Status__c ='Eligible';
            accList[0].ZTS_US_VGP_Enrollment_Status__c='VGP Enrolled';
            accList[0].ZTS_US_MVP_Account__c=false;   
            update accList;
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();

            accList[0].MZR_Status__c ='Eligible';
            accList[0].ZFS_Status__c = 'Member';
            update accList;
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            
            accList[0].ZTS_US_VGP_Enrollment_Status__c ='VGP Enrolled'; 
            update accList;
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            
            accList[2].parentId= accList[0].id;
            accList[0].MZR_Status__c = 'Active';
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update accList;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            
            accList[2].MZR_Status__c = 'Active';
            update accList;
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            
            accList[0].parentId = null;
            accList[0].MZR_Status__c = 'Not Eligible';
            accList[2].parentId= accList[0].id;
            update accList;
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            
            accList[2].parentId= accList[1].id;
            update accList[2];
            USStaticACFVars.mapOldACFLoser.put(accList[2].Id,lstanimalcount);
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            delete accList[2];
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            
            Test.startTest();
            
            Account master = new Account(Name='Account1',BillingStreet='test_b', BillingCity='test_c',BillingPostalCode='test_pc', BillingCountry='United States',BillingState='TX');
            insert master;    
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();    
            Account[] duplicates = new Account[]{new Account(Name='Account1, Inc.',BillingStreet='test_b', BillingCity='test_c',BillingPostalCode='test_pc', BillingCountry='United States',BillingState='TX'), new Account(Name='Account 1',BillingStreet='test_b', BillingCity='test_c',BillingPostalCode='test_pc', BillingCountry='United States',BillingState='TX')};
                insert duplicates;     
                DispatchTriggerHandler.firstTimeTracker = new Set<String>();   
            Database.MergeResult[] results = Database.merge(master, duplicates, false);
            
            ZTS_US_checkTriggerRun.resetAll();
            
            accList[0].MZR_Status__c = 'Active';
            accList[0].ZTS_US_VGP_Enrollment_Status__c ='VGP Enrolled'; 
            
            Map<Id, Account> acctsMap = new Map<Id, Account>();
            
            for(Account acct : accList)
                acctsMap.put(acct.Id, acct);
            
            Set<Id> contIdSet= new Set<Id>();
            for(Contact c : [Select Id from Contact]){
                contIdSet.add(c.Id);
            }
            Map<Id, Account> historyMap = new Map<Id, Account>(accList);
            for(Account oh : accList)
            {
                historyMap.put(oh.Id, oh);
            }
            Test.stopTest();
            System.assertNotEquals(accList.size(),0);
        } 
    }
    
    static TestMethod void affiliatedContactsTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr){
            Test.startTest();
            ZTS_DataUtilityTest.activateTriggerSettings();
            List<Account> accList=new List<Account>();
            accList = ZTS_DataUtilityTest.createAccountRecord(6);
            Integer i = 1;
            for (Account a : accList)
            {
                a.BillingStreet='test_b';
                a.BillingCity='test_c';
                a.BillingPostalCode='test_pc';
                a.BillingCountry='United States';
                a.BillingState='TX';
                a.ZTS_EU_Market__c = 'United States';
                a.ZTS_US_NARC_ID__c = 'testId'+i;
                i++;
                a.ZTS_US_VGP_Enrollment_Status__c = 'test';
            }
            insert accList;
            
            List <Contact> contList= new List <Contact>();
            contList=ZTS_DataUtilityTest.createContactRecord(2);
            contList[0].ZTS_EU_Contact_Status__c = 'Active';
            contList[0].ZTS_EU_Market__c = 'United States';
            contList[1].ZTS_EU_Market__c = 'United States';
            contList[0].AccountId = accList[0].Id;
            contList[1].AccountId = accList[1].Id;
            contList[0].ZTS_US_LE_Contact__c = 'Primary';
            contList[1].ZTS_US_LE_Contact__c = 'Primary';
            insert contList;
            
            Contact con = ZTS_DataUtilityTest.createContactRecord(1)[0];
            con.ZTS_EU_Contact_Status__c = 'Active';
            con.ZTS_EU_Market__c = 'United States';
            insert con;
            
            List<ZTS_EU_Affiliations__c>  affiliations = [Select Id,ZTS_EU_Market_from_Parent__c,ZTS_EU_Contact__c,Profit_Solver_Contact__c,ZTS_EU_Account__c,ZTS_US_LE_Contact__c,ZTS_EU_Account_influence__c,ZTS_US_Job_Function__c,ZTS_US_Primary_Account__c from  ZTS_EU_Affiliations__c];
            ZTS_EU_Affiliations__c updated = affiliations[0].clone();
            updated.ZTS_US_LE_Contact__c = 'Backup';
            Map<Id,ZTS_EU_Affiliations__c> oldMap = new Map<Id,ZTS_EU_Affiliations__c>();
            oldMap.put(affiliations[0].Id,updated);
            
            Map<Id,ZTS_EU_Affiliations__c> newMap = new Map<Id,ZTS_EU_Affiliations__c>();
            newMap.put(affiliations[0].Id,updated);
            ZTS_GL_accUpdateClass cls = new ZTS_GL_accUpdateClass();
            cls.UpdateAccOnCont(new List<ZTS_EU_Affiliations__c>{affiliations[0]}, new List<ZTS_EU_Affiliations__c>{affiliations[0]},
                                                  newMap, oldMap, true, false);
            
            Contact updatedCon = [Select ZTS_US_LE_Contact__c From Contact Where Id =: affiliations[0].ZTS_EU_Contact__c];
            
            system.assertEquals(updatedCon.ZTS_US_LE_Contact__c, affiliations[0].ZTS_US_LE_Contact__c);
            Test.stopTest();
        }
    }
}