/*******************************************************************************************************************************************
* File Name     :  SL_AccountTriggerHandler_Test
* Description   :  Test class for SL_AccountTriggerHandler
* @author       :  Chandra Keerthi
* Modification Log
---------------------------------------------------------------------------------------------------
* Ver.    Date          Author                     Modification
* 1.0     3-9-2023      Padma Nerella @ Zoetis Inc  Added test cases to getAccountsWithEmailChanges method
* 1.1     3-29-2023     Padma Nerella @ Zoetis Inc  Added test cases to test onbeforeDelete method 
---------------------------------------------------------------------------------------------------

***************************************************************************************************************/
@isTest
public class SL_AccountTriggerHandler_Test{
    static testMethod void validate_ZTS_AddressCreation(){
        
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        
        List<Account> accList=new List<Account>();
        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.activateTriggerSettings();
            accList = ZTS_DataUtilityTest.createAccountRecord(5);
            accList[0].ZTS_Business_Class__c = 'Producers';
            accList[1].ZTS_Business_Class__c = 'Veterinarian';
            accList[0].ZTS_EU_Market__c = 'Croatia';
            accList[1].ZTS_EU_Market__c = 'Egypt';
            accList[2].ZTS_EU_Market__c = 'Egypt';
            accList[3].ZTS_EU_Market__c = 'Egypt';
            accList[4].ZTS_EU_Market__c = 'Egypt';
            accList[1].Email__c= 'testemail@zoetis.com';
            accList[2].Email__c= 'testemail@zoetis.com';  
            insert accList;
            
            ZTS_EU_Bring_Offline__c bringOffline1 = new ZTS_EU_Bring_Offline__c(ZTS_EU_Account__c = accList[0].Id); 
            ZTS_EU_Bring_Offline__c bringOffline2 = new ZTS_EU_Bring_Offline__c(ZTS_EU_Account__c = accList[1].Id); 
            ZTS_EU_Bring_Offline__c bringOffline3 = new ZTS_EU_Bring_Offline__c(ZTS_EU_Account__c = accList[2].Id); 
            ZTS_EU_Bring_Offline__c bringOffline4 = new ZTS_EU_Bring_Offline__c(ZTS_EU_Account__c = accList[3].Id); 
            ZTS_EU_Bring_Offline__c bringOffline5 = new ZTS_EU_Bring_Offline__c(ZTS_EU_Account__c = accList[4].Id); 
            insert new List<ZTS_EU_Bring_Offline__c>{bringOffline1,bringOffline2,bringOffline3,bringOffline4,bringOffline5};            
                
                ZTS_EU_Account_Position__c accPos1 = new ZTS_EU_Account_Position__c();
            accPos1.ZTS_EU_Active__c = true;
            accPos1.ZTS_EU_Account__c = accList[0].Id;
            
            ZTS_EU_Account_Position__c accPos2 = new ZTS_EU_Account_Position__c();
            accPos2.ZTS_EU_Active__c = true;
            accPos2.ZTS_EU_Account__c = accList[1].Id;
            
            ZTS_EU_Account_Position__c accPos3 = new ZTS_EU_Account_Position__c();
            accPos3.ZTS_EU_Active__c = true;
            accPos3.ZTS_EU_Account__c = accList[2].Id;
            
            ZTS_EU_Account_Position__c accPos4 = new ZTS_EU_Account_Position__c();
            accPos4.ZTS_EU_Active__c = true;
            accPos4.ZTS_EU_Account__c = accList[3].Id;
            
            ZTS_EU_Account_Position__c accPos5 = new ZTS_EU_Account_Position__c();
            accPos5.ZTS_EU_Active__c = true;
            accPos5.ZTS_EU_Account__c = accList[4].Id;
            insert new List<ZTS_EU_Account_Position__c>{accPos1,accPos2,accPos3,accPos4,accPos5};
                
                ZTS_addrCreationAndUpdateFromAccount.chkUpdate = true;
            accList[0].BillingStreet ='Test 1 Street';
            accList[4].parentId= accList[0].id;
            accList[1].Email__c= 'testChangeemail@zoetis.com';
            accList[2].Email__c= 'testChangeemail@zoetis.com'; 
            update accList;
            List <Contact> contList= new List <Contact>();
            contList=ZTS_DataUtilityTest.createContactRecord(1);
            contList[0].AccountId = accList[0].Id;
            contList[0].FirstName = 'test1234';
            insert contList;
            accList[0].BillingStreet ='Test 2 Street';
            
            accList[1].Email__c= 'testChangesemail@zoetis.com';
            accList[2].Email__c= 'testChangesemail@zoetis.com'; 
            update accList;
            ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Account__c = accList[3].Id);
            insert aff;
            accList[3].ZTS_EU_Account_Status__c='Inactive';
            
            Test.startTest();
            accList[3].MZR_Status__c ='Active';
            ZTS_checkTriggerRun.resetAll();
            update accList;
            accList[3].ZTS_US_VGP_Enrollment_Status__c='VGP Enrolled';
            accList[3].ZTS_EU_Reason__c = 'Moved';
            ZTS_checkTriggerRun.resetAll();
            update accList;
            accList[3].ZTS_MVP_Account__c=true;
            ZTS_checkTriggerRun.resetAll();
            update accList;
            accList[4].parentId= null;
            ZTS_checkTriggerRun.resetAll();
            update accList;
            Test.stopTest();
        }
        System.assertNotEquals(accList.size(),0);
    }
    
    
    static testmethod void testupdateAccountContractDetails(){
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        
        List<Account> accList=new List<Account>();
        System.runAs(intlUsr) {
            
            ZTS_DataUtilityTest.activateTriggerSettings();
            List<Account> lstOldAcc = new List<Account>();
            Map<id,Account> mapAcc = new Map<id,Account>();
            lstOldAcc = [SELECT id,name FROM Account WHERE ZTS_EU_Market__c != 'United States' LIMIT 2];
            for(Account a:lstOldAcc){
                mapAcc.put(a.Id,a);
            }
            accList = ZTS_DataUtilityTest.createAccountRecord(3);
            accList[0].ZTS_Business_Class__c = 'Producers';
            accList[0].ZTS_EU_Corporate_Flag__c = true;
            accList[1].ZTS_Business_Class__c = 'Veterinarian';
            accList[0].ZTS_EU_Market__c = 'Croatia';
            accList[1].ZTS_EU_Market__c = 'Egypt';
            accList[2].ZTS_EU_Market__c = 'Egypt';
            Test.startTest();
            insert accList;
            accList[2].parentId = accList[0].id;
            //accList[2].ZTS_EU_Parent_Id__c = accList[0].id;
            ZTS_checkTriggerRun.resetAll();
            update accList;
            ZTS_checkTriggerRun.resetAll();
            accList[2].ZTS_MVP_Account__c = true;
            update accList;
            Test.stopTest();
            
            System.assertEquals([SELECT Id, ZTS_EU_Parent_Id__c FROM Account WHERE Id = :accList[2].Id].ZTS_EU_Parent_Id__c, accList[2].Id);
        }
    } 
    static testmethod void updatecontractdetailschildaccountsTest()
    {
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        
        List<Account> accList=new List<Account>();
        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.activateTriggerSettings();
            DispatchTriggerHandler.bypass('ContactTriggerHandler');
            DispatchTriggerHandler.bypass('ZTS_EU_AffiliationsTriggerHandler');
            DispatchTriggerHandler.bypass('RingLeadTrigger');
            accList = ZTS_DataUtilityTest.createAccountRecord(6);
            for(Integer i=0;i<6;i++)
                accList[i].ZTS_EU_Market__c='United Kingdom';
            //DispatchTriggerHandler.bypass('AccountTriggerHandler');
            insert accList;
            //DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            ZTS_addrCreationAndUpdateFromAccount.chkUpdate = true;
            accList[0].BillingStreet ='Test 1 Street';
            accList[4].parentId= accList[0].id;
            accList[5].parentId= accList[0].id;   
            update accList;
            
            accList[0].MZR_Status__c ='Active';
            accList[0].ZTS_US_VGP_Enrollment_Status__c='VGP Enrolled';
            accList[0].ZTS_MVP_Account__c=true;   
            
            
            update accList;
            accList[0].MZR_Status__c ='Eligible';
            accList[0].ZTS_EU_Account_Status__c = 'Member';
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
            ZTS_EU_Species_Product__c bu=new ZTS_EU_Species_Product__c(Name='PROD1');
            insert bu;
            ZTS_EU_Species__c species=new ZTS_EU_Species__c(Name='Cat',ZTS_EU_Business_Unit__c=bu.id,ZTS_EU_Species__c='ABC');
            List<ZTS_EU_Account_Species_Potential__c> asclist=new List<ZTS_EU_Account_Species_Potential__c>();
            for(ZTS_EU_Account_Species_Potential__c asc1:asclist){
                asc1.Account__c=accList[4].id;
                asc1.ZTS_EU_Species_Potential__c=species.id;
                asc1.CurrencyIsoCode='CAD';
            }
            insert asclist;
            SL_AccountTriggerHandler h = new SL_AccountTriggerHandler(); 
            h.onBeforeDelete(accList);
            delete accList[4];
            
            Test.startTest();
            Account master = ZTS_DataUtilityTest.createAccountRecord(1)[0];

            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            insert master; // Name='Account1'
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            Account dup1 = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            dup1.Name += ', Inc'; // Name='Account1, Inc.'
            Account dup2 = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            dup1.Name += ' 1'; // Name='Account1 1
            Account[] duplicates = new Account[]{dup1, dup2};
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
                insert duplicates;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');        
            Database.MergeResult[] results = Database.merge(master, duplicates, false);
            
            
            ZTS_checkTriggerRun.resetAll();
            
            accList[0].MZR_Status__c = 'Active';
            accList[0].ZTS_US_VGP_Enrollment_Status__c ='VGP Enrolled'; 
            update accList[0];
            
            Test.stopTest();
            
            
            DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
            DispatchTriggerHandler.clearBypass('ZTS_EU_AffiliationsTriggerHandler');
            DispatchTriggerHandler.clearBypass('RingLeadTrigger');
        }
        System.assertNotEquals(accList.size(),0);
    }
    static testmethod void onAfterDeleteTest(){
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        
        List<Account> accList=new List<Account>();
        System.runAs(intlUsr) {
            Test.startTest();
            Map<Id, List<ZTS_EU_Account_Species_Potential__c>> mapACPIdToAnimalCountPotentials = new Map<Id, List<ZTS_EU_Account_Species_Potential__c>>();
            accList = ZTS_DataUtilityTest.createAccountRecord(1);
            //accList[0].ZTS_EU_Market__c='Canada';
            insert accList;
            ZTS_EU_Species_Product__c bu=new ZTS_EU_Species_Product__c(Name='PROD1');
            insert bu;
            ZTS_EU_Species__c species=new ZTS_EU_Species__c(Name='Cat',ZTS_EU_Business_Unit__c=bu.id,ZTS_EU_Species__c='ABC');
            List<ZTS_EU_Account_Species_Potential__c> asclist=new List<ZTS_EU_Account_Species_Potential__c>();
            for(ZTS_EU_Account_Species_Potential__c asc1:asclist){
                asc1.Account__c=accList[0].id;
                asc1.ZTS_EU_Species_Potential__c=species.id;
                asc1.CurrencyIsoCode='CAD';
            }
            insert asclist;
            // mapACPIdToAnimalCountPotentials.put(accList[1].id,asclist);
            delete accList[0];
            
            System.assertEquals(0, [SELECT Count() FROM ZTS_EU_Account_Species_Potential__c where Account__r.Id IN:accList]);
            Test.stopTest();
        }
    }
    static testmethod void splitAccountNameTest(){
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        
        System.runAs(intlUsr) {
            test.starttest();
            //st<Account> acclist1 = new list<Account>();
            Account acc = new Account();
            acc.Name= 'Test2 acount test for split functionality after gcp2 abc nmp ournb hdnfn skhjdbs';
            acc.ZTS_EU_Market__c='Spain';
            acc.Type='Administration';
            acc.ZTS_EU_Sub_Type__c='Academic';
            acc.ZTS_EU_Zip_Postal_Code__c='12345';
            insert acc;
            
            Account acc2 = new Account();
            acc2.Name= 'Test account test for split functionality after gcp test test test testy abc xyz ajjf oie';
            acc2.ZTS_EU_Market__c='Germany';
            acc2.Type='Administration';
            acc2.ZTS_EU_Sub_Type__c='Academic';
            acc2.ZTS_EU_Zip_Postal_Code__c='1234567';
            insert acc2;
            ZTS_addrCreationAndUpdateFromAccount.splitAccountName(acc);
            ZTS_addrCreationAndUpdateFromAccount.splitAccountName(acc2);
            test.stopTest();
            System.assert('Test2 acount test for split' == [SELECT Id, ZTS_EU_Account_Name_1__c FROM Account WHERE Id = :acc.Id].ZTS_EU_Account_Name_1__c);
            
        }
    }
    
    static testmethod void splitAccountNameOnUpdateTest(){
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        
        System.runAs(intlUsr) {
            test.starttest();
            //st<Account> acclist1 = new list<Account>();
            Account acc = new Account();
            acc.Name= 'Test2 acount test for split functionality after gcp2 abc nmp ournb hdnfn skhjdbs';
            acc.ZTS_EU_Market__c='Spain';
            acc.Type='Administration';
            acc.ZTS_EU_Sub_Type__c='Academic';
            acc.ZTS_EU_Zip_Postal_Code__c='12345';
            insert acc;
            
            acc.Name = 'Test3 acount test for split functionality after gcp2 abc nmp ournb hdnfn skhjdbs';
            update acc;
            
            Account acc2 = new Account();
            acc2.Name= 'Test account test for split functionality after gcp test test test testy abc xyz ajjf oie';
            acc2.ZTS_EU_Market__c='Germany';
            acc2.Type='Administration';
            acc2.ZTS_EU_Sub_Type__c='Academic';
            acc2.ZTS_EU_Zip_Postal_Code__c='1234567';
            insert acc2;
            
            acc2.Name = 'Test4 account test for split functionality after gcp test test test testy abc xyz ajjf oie';
            update acc;
            ZTS_addrCreationAndUpdateFromAccount.splitAccountNameonupdate(acc);
            ZTS_addrCreationAndUpdateFromAccount.splitAccountNameonupdate(acc2);
            
            System.assert('Test2 acount test for split' == [SELECT Id, ZTS_EU_Account_Name_1__c FROM Account WHERE Id = :acc.Id].ZTS_EU_Account_Name_1__c);
            test.stopTest();
        }
    }
    
    static testmethod void populatePotentialRegionTest()
    {
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        
        List<Account> accList=new List<Account>();
        System.runAs(intlUsr) 
        {
            test.startTest();
            Account acc0 = new Account();
            acc0.Name='Test_Populate';
            acc0.ZTS_EU_Market__c='Brazil';
            acc0.ZTS_EU_Sub_Type__c='Use or may use FTAI';
            acc0.ZTS_EU_Zip_Postal_Code__c='1234567';
            acc0.ZTS_EU_VAT_Code__c='12364567';
            acclist.add(acc0);
            
            Account acc1 = new Account();
            acc1.Name='Test_Populate1';
            acc1.ZTS_EU_Market__c='Brazil';
            acc1.ZTS_EU_Sub_Type__c='Hospital';
            acc1.ZTS_EU_Zip_Postal_Code__c='12345677';
            acc1.ZTS_EU_VAT_Code__c='12345679';
            acclist.add(acc1);
            
            Account acc2 = new Account();
            acc2.Name='Test_Populate2';
            acc2.ZTS_EU_Market__c='Brazil';
            acc2.ZTS_EU_Sub_Type__c='Clinic+Petshop';
            acc2.ZTS_EU_Zip_Postal_Code__c='12345678';
            acc2.ZTS_EU_VAT_Code__c='123457';
            acclist.add(acc2);
            
            Account acc3 = new Account();
            acc3.Name='Test_Populate3';
            acc3.ZTS_EU_Market__c='Brazil';
            acc3.Type='Petshop';
            acc3.ZTS_EU_Sub_Type__c='Petshop';
            acc3.ZTS_EU_Zip_Postal_Code__c='123456789';
            acc3.ZTS_EU_VAT_Code__c='1234567';
            acclist.add(acc3);
            
            Account acc4 = new Account();
            acc4.Name='Test_Populate4';
            acc4.ZTS_EU_Market__c='Italy';
            acc4.Type='Vet Practice';
            acc4.ZTS_EU_Sub_Type__c='Beef';
            acc4.ZTS_EU_Zip_Postal_Code__c='1234567837';
            acc4.ZTS_EU_VAT_Code__c='12345647';
            acclist.add(acc4);
            
            Account acc5 = new Account();
            acc5.Name='Test_Populate5';
            acc5.ZTS_EU_Market__c='Italy';
            acc5.Type='Farm';
            acc5.ZTS_EU_Sub_Type__c='cattle';
            acc5.ZTS_EU_Zip_Postal_Code__c='1234567831';
            acc5.ZTS_EU_VAT_Code__c='12345646';
            acclist.add(acc5);
            
            Account acc6 = new Account();
            acc6.Name='Test_Populate6';
            acc6.ZTS_EU_Market__c='Italy';
            acc6.Type='Industy Association';
            acc6.ZTS_EU_Sub_Type__c='Beef';
            acc6.ZTS_EU_Zip_Postal_Code__c='1234567832';
            acc6.ZTS_EU_VAT_Code__c='12345649';
            acclist.add(acc6);
            
            
            insert acclist;
            ZTS_addrCreationAndUpdateFromAccount.populatePotentialRegion(acclist);
            
            List<Account> accounts = [
                SELECT Id, ZTS_EU_Potential_Region__c, ZTS_EU_Market__c, ZTS_EU_Sub_Type__c, Type
                FROM Account
            ];
            
            for (Account acc : accounts)
            {
                /*
if(acc.ZTS_EU_Market__c == 'Brazil')
{
if(acc.ZTS_EU_Sub_Type__c.contains('Use or may use FTAI'))
{
System.assert(acc.ZTS_EU_Potential_Region__c == '4');
}
else if(acc.ZTS_EU_Sub_Type__c.contains('Hospital') || acc.ZTS_EU_Sub_Type__c.contains('Use or may use AI'))
{
System.assert(acc.ZTS_EU_Potential_Region__c == '3');
}
else if(acc.ZTS_EU_Sub_Type__c.contains('Clinic+Petshop') || acc.ZTS_EU_Sub_Type__c.contains('Natural Breeding with Breeding Season'))
{
System.assert(acc.ZTS_EU_Potential_Region__c == '2');
}
else if(acc.ZTS_EU_Sub_Type__c.contains('Petshop') || acc.ZTS_EU_Sub_Type__c.contains('Natural Breeding without Breeding Season'))
{
System.assert(acc.ZTS_EU_Potential_Region__c == '1');
}
else 
{
System.assert(acc.ZTS_EU_Potential_Region__c == '1');
}
}*/
                if(acc.ZTS_EU_Market__c == 'Italy')
                {
                    if((acc.Type==('Vet Practice')) ||  (acc.Type==('Vet Practice/Petshop') ))
                    {
                        System.assert(acc.ZTS_EU_Potential_Region__c == '1');
                    }
                    else if(acc.Type==('Farm'))
                    {
                        System.assert(acc.ZTS_EU_Potential_Region__c == '2');
                    }
                    else
                    {
                        System.assert(acc.ZTS_EU_Potential_Region__c == '3');
                    }
                    
                }
            }
        }
    }
    
    static testmethod void syncOptOutFlagGermanyTest(){
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        
        System.runAs(intlUsr) 
        {
            test.startTest();
            Account acc = new Account();
            acc.Name='Test_Populate';
            acc.ZTS_EU_Market__c='Germany';
            acc.ZTS_EU_Sub_Type__c='Use or may use FTAI';
            acc.ZTS_EU_Zip_Postal_Code__c='1234567';
            acc.ZTS_EU_VAT_Code__c='12364567';
            
            insert acc;
            
            Contact c = new Contact();
            c.FirstName = 'Rob';
            c.LastName = 'Stark';
            c.ZTS_EU_Market__c='Germany';
            c.ZTS_EU_Zip_Postal_Code__c='1234567';
            c.Email = 'test@gmail.com';
            c.AccountId = acc.Id;
            insert c;
            
            acc.Email__c = 'test@gmail.com';
            update acc;
            
            System.assertEquals([SELECT Id, ZTS_EU_Opt_Out_Email__c FROM Contact WHERE Id = :c.Id].ZTS_EU_Opt_Out_Email__c, false);
            test.stopTest();
        }
        
    }
    
    static testmethod void isAddressChangedTest(){
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        
        System.runAs(intlUsr) {
            test.startTest();
            Account acc = new Account();
            acc.Name='Test_Populate';
            acc.ZTS_EU_Market__c='Germany';
            acc.ZTS_EU_Sub_Type__c='Use or may use FTAI';
            acc.ZTS_EU_Zip_Postal_Code__c='1234567';
            acc.ZTS_EU_VAT_Code__c='12364567';
            acc.BillingPostalCode = '00000';
            acc.BillingCity = 'testCity';
            acc.BillingState = 'testState';
            acc.BillingStreet = 'testStreet';
            
            insert acc;
            
            Account acc2 = new Account();
            acc2.Name='Test_Populate';
            acc2.ZTS_EU_Market__c='Germany';
            acc2.ZTS_EU_Sub_Type__c='Use or may use FTAI';
            acc2.ZTS_EU_Zip_Postal_Code__c='1234567';
            acc2.ZTS_EU_VAT_Code__c='12364567';
            acc2.BillingPostalCode = '00002';
            acc2.BillingCity = 'testCity2';
            acc2.BillingState = 'testState2';
            acc2.BillingStreet = 'testStreet2';
            
            insert acc2;
            System.assertEquals(true, ZTS_addrCreationAndUpdateFromAccount.isAddressChanged(acc, acc2));
            test.stopTest();
        }
        
    }
    @TestSetup static void dataSetup() {
       
        Test.startTest();
        List<Account> insertTestaccList = new List<Account>();
        List<Account> testaccList = ZTS_DataUtilityTest.createAccountRecord(2);
        testaccList[0].ZTS_EU_Market__c = 'United Kingdom';
        testaccList[0].ZTS_EU_Account_Status__c='active';
        testaccList[1].ZTS_EU_Market__c = 'Canada';
        testaccList[1].ZTS_EU_Account_Status__c='active';
        insertTestaccList.addall(testaccList);
        
        List<Account> accList = new List<Account>();
        accList.addAll(ZTS_DataUtilityTest.createAccountRecord(6));
        for(Integer i=0; i<6; i++) {
            accList[i].Name ='Acc'+i;
            accList[i].ZTS_EU_Market__c='Spain';
            accList[i].ZTS_EU_Account_Status__c='active';
        }
        insertTestaccList.addAll(accList);
        
        List<Account> accountMergeList = ZTS_DataUtilityTest.createAccountRecord(6);
        accountMergeList[0].Name = 'Master';
        accountMergeList[0].ZTS_EU_Market__c = 'Spain';
        accountMergeList[1].Name = 'Master Child';
        accountMergeList[1].ZTS_EU_Market__c = 'Spain';
        accountMergeList[2].Name = 'Master2';
        accountMergeList[2].ZTS_EU_Market__c = 'Spain';
        accountMergeList[3].Name = 'Master2 Child';
        accountMergeList[3].ZTS_EU_Market__c = 'Spain';
        accountMergeList[4].Name = 'Master3';
        accountMergeList[4].ZTS_EU_Market__c = 'Canada';
        accountMergeList[5].Name = 'Master3 Child';
        accountMergeList[5].ZTS_EU_Market__c = 'Canada';
        insertTestaccList.addAll(accountMergeList);
        
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        Insert insertTestaccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        List<Contact> conList = new List<Contact>();
        Contact cont = ZTS_DataUtilityTest.createContactRecord(1)[0];
        cont.AccountId = testaccList[0].Id;
        cont.ZTS_EU_Contact_Status__c = 'Active';
        cont.ZTS_Job_Function__c = 'Account Contact';
        cont.ZTS_EU_Profession__c = 'Account Contact';
        conList.add(cont);
        insert conList; 
        
        DispatchTriggerHandler.firstTimeTracker = new Set<String>();
        List<ZTS_EU_Species_Product__c> speciesProductList = ZTS_DataUtilityTest.createEUSpeciesProductRec(2);
        speciesProductList[0].ZTS_EU_Market__c='Canada';
        insert speciesProductList;
 
        
        DispatchTriggerHandler.firstTimeTracker = new Set<String>();
        List<ZTS_EU_Species__c> speciesList = new List<ZTS_EU_Species__c>();
        
        List<ZTS_EU_Species__c> species = ZTS_DataUtilityTest.createEUSpeciesRec(1,speciesProductList[0].Id);
        species[0].ZTS_EU_Market__c='Canada';
        speciesList.add(species[0]);
        List<ZTS_EU_Species__c> species1 = ZTS_DataUtilityTest.createEUSpeciesRec(2,speciesProductList[1].Id);
        speciesList.addAll(species1);
        Insert speciesList;
        
        Test.stopTest();
     
    }
    
    static testmethod void getAccountsWithEmailChangesTest(){
        
        List<Account> accList = [Select Id,Name,ZTS_EU_Market__c,Email__c From Account where ZTS_EU_Market__c ='United Kingdom' LIMIT 1];
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
    
    
    
    static testmethod void getAccountsWithInvalidEmailChangesTest(){
        List<Account> accList = [Select Id,Name,ZTS_EU_Market__c,Email__c,ZTS_Invalid_Email__c From Account where ZTS_EU_Market__c ='United Kingdom' LIMIT 1];
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
    
    static testmethod void getAccountsWithNOEmailChangesTest(){
        
        List<Account> accList = [Select Id,Name,ZTS_EU_Market__c,Email__c From Account where ZTS_EU_Market__c ='United Kingdom' LIMIT 1];
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
    
    static testmethod void getBulkAccountsWithEmailChangesTest(){
        
        List<Account> testAccounts = new List<Account>();
        testAccounts.addAll(ZTS_DataUtilityTest.createAccountRecord(8));
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        insert testAccounts;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        Map<Id, Account> oldAccountMap = new Map<Id, Account>(
            [SELECT Id, Name,Email__c,ZTS_US_Email_Opt_Out__c,ZTS_Invalid_Email__c FROM Account WHERE Id IN :testAccounts]
        );
        List<Contact> testContacts = new List<Contact>();
        testContacts.addAll(ZTS_DataUtilityTest.createContactRecord(8));
        for(Integer i=0; i<8; i++) {
            testContacts[i].AccountId = testAccounts[i].Id;
            testContacts[i].ZTS_EU_Profession__c = 'Account Contact';
            testContacts[i].ZTS_Job_Function__c = 'Account Contact';
            testContacts[i].ZTS_EU_Contact_Status__c = 'Active';
            testContacts[i].FirstName = 'test1234';
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
        System.assertEquals(8, newContactList.size(),'8 contact records found with email,Email Opt Out and Invalid Email changes');
        List<Contact> newContactList1 = [Select Id,ZTS_Invalid_Email__c,AccountId,ZTS_EU_Opt_Out_Email__c,Interface_Email__c From Contact where AccountId IN:testAccounts and Id IN:testContacts and Interface_Email__c = 'test@zoetis.com' ];
        List<Contact> newContactList2 = [Select Id,ZTS_Invalid_Email__c,AccountId,ZTS_EU_Opt_Out_Email__c,Interface_Email__c From Contact where AccountId IN:testAccounts and Id IN:testContacts and ZTS_Invalid_Email__c = true];
        List<Contact> newContactList3 = [Select Id,ZTS_Invalid_Email__c,AccountId,ZTS_EU_Opt_Out_Email__c,Interface_Email__c From Contact where AccountId IN:testAccounts and Id IN:testContacts and ZTS_EU_Opt_Out_Email__c = true];
        List<Contact> contactsNoChangesList = [SELECT Id,Interface_Email__c,ZTS_EU_Opt_Out_Email__c ,ZTS_Invalid_Email__c From Contact WHERE AccountId IN :testAccounts and ZTS_Invalid_Email__c = False AND ZTS_EU_Opt_Out_Email__c = False AND Interface_Email__c != 'test@zoetis.com'];

        
        System.assertEquals(2, newContactList1.size(),'2 contact records found with email changes');
        System.assertEquals(2, newContactList2.size(),'2 contact records found with Invalid Email changes');
        System.assertEquals(2, newContactList3.size(),'2 contact records found with Email Opt Out changes');
        System.assertEquals('test@zoetis.com', newContactList1[0].Interface_Email__c,'Contact email changed sucessfully');
        System.assertEquals(true, newContactList2[0].ZTS_Invalid_Email__c,'Contact ZTS_Invalid_Email__c changed sucessfully');
        System.assertEquals(true, newContactList3[0].ZTS_EU_Opt_Out_Email__c, 'Contact ZTS_EU_Opt_Out_Email__c changed sucessfully');
        System.assertEquals(2, contactsNoChangesList.size(),'No changes on 2 contact records');
        
    }
    
    static testmethod void onBeforeDeleteTest(){
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;  
        
        
        List<Account> accList = [Select Id,Name,ZTS_EU_Market__c,Email__c,MasterRecordId From Account where ZTS_EU_Market__c ='Canada' LIMIT 1];
        
        
        System.runAs(usr)
        {
            List<ZTS_EU_Species_Product__c> speciesProductList = [Select Id,ZTS_EU_Market__c from ZTS_EU_Species_Product__c where ZTS_EU_Market__c='Canada' LIMIT 1];
            List<ZTS_EU_Species__c> speciesList = [Select Id,ZTS_EU_Market__c from ZTS_EU_Species__c where ZTS_EU_Market__c='Canada' LIMIT 1];
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            ZTS_EU_Account_Species_Potential__c asp1= ZTS_DataUtilityTest.createEUAccountSpeciesPotentialRec(speciesList[0].Id,accList[0].Id);
            insert asp1;
            
            test.startTest();
            SL_AccountTriggerHandler h = new SL_AccountTriggerHandler(); 
            h.onBeforeDelete(accList);
            test.stopTest();
            List<ZTS_EU_Account_Species_Potential__c> accountspeciespotentialList1 = [SELECT Id FROM ZTS_EU_Account_Species_Potential__c where Account__r.Id IN:accList];
            System.assertEquals(0,accountspeciespotentialList1.size(),'1 accountspeciespotential deleted when account is deleted');
        }
        
    }
    
    static testmethod void onBeforeDeleteBulkTest(){
        
        List<Account> accList = [Select Id,ZTS_EU_Market__c,MasterRecordId From Account where ZTS_EU_Market__c ='Spain'];
        List<ZTS_EU_Species_Product__c> speciesProductList = [Select Id,ZTS_EU_Market__c from ZTS_EU_Species_Product__c where ZTS_EU_Market__c='Spain'];
        List<ZTS_EU_Species__c> speciesList = [Select Id,ZTS_EU_Market__c from ZTS_EU_Species__c where ZTS_EU_Market__c='Spain'];
        List<ZTS_EU_Account_Species_Potential__c> accSpeciesPotentialrecList = new List<ZTS_EU_Account_Species_Potential__c>();
        for(Integer i =0;i<6;i++){
            accSpeciesPotentialrecList.add(ZTS_DataUtilityTest.createEUAccountSpeciesPotentialRec(speciesList[0].Id,accList[i].Id));
        }
        insert accSpeciesPotentialrecList;
       
        test.startTest();
        List<Account> deleteAccList = new List<Account>();
        deleteAccList.add(accList[0]);
        deleteAccList.add(accList[1]);
        deleteAccList.add(accList[2]);
        SL_AccountTriggerHandler h = new SL_AccountTriggerHandler();
        h.onBeforeDelete(deleteAccList);
        List<Account> accNonDeleteList = new List<Account>();
        accNonDeleteList.add(accList[3]);
        accNonDeleteList.add(accList[4]);
        accNonDeleteList.add(accList[5]);
        test.stopTest();
        
        List<ZTS_EU_Account_Species_Potential__c> accountspeciespotentialList = [SELECT Id,Account__c FROM ZTS_EU_Account_Species_Potential__c where Account__r.Id IN:deleteAccList];
        List<ZTS_EU_Account_Species_Potential__c> accountspeciespotentialList1 = [SELECT Id,Account__c  FROM ZTS_EU_Account_Species_Potential__c where Account__r.Id IN:accNonDeleteList];
        System.assertEquals(0,accountspeciespotentialList.size(),'3 accountspeciespotential deleted when account is deleted');
        System.assertEquals(3,accountspeciespotentialList1.size(),'3 accountspeciespotential records did not get deleted when account is not deleted');
        
        
    }
    
    static testmethod void onAfterDeleteTest1(){
       
        String masterAcc = null;
        Id master1ChildAcc =null;
        SObject master2Acc =null;
        Id master2ChildAcc=null;
        SObject master1object;
        
        List<Account> accList = [Select Id, Name,ZTS_EU_Market__c From Account where Name LIKE 'Master%'];
        for(Account acc :accList){
            if(acc.Name=='Master'){
                master1object = acc;
            }
            else if(acc.Name=='Master Child'){
                master1ChildAcc =acc.Id;
            }
            else if(acc.Name=='Master2'){
                master2Acc =acc;
            }
            else if(acc.Name=='Master2 Child'){
                master2ChildAcc = acc.Id;
            }
        }
        
        
        List<ZTS_EU_Species__c> speciesList = [Select Id,ZTS_EU_Market__c from ZTS_EU_Species__c where ZTS_EU_Market__c='Spain' LIMIT 2];
        
        List<ZTS_EU_Account_Species_Potential__c> accSpeciesPotentialInsertList = new List<ZTS_EU_Account_Species_Potential__c>();
        DispatchTriggerHandler.firstTimeTracker = new Set<String>();
        ZTS_EU_Account_Species_Potential__c asp1= ZTS_DataUtilityTest.createEUAccountSpeciesPotentialRec(speciesList[0].Id,master1ChildAcc);
        accSpeciesPotentialInsertList.add(asp1);
        ZTS_EU_Account_Species_Potential__c asp2= ZTS_DataUtilityTest.createEUAccountSpeciesPotentialRec(speciesList[1].Id,master2Acc.Id);
        accSpeciesPotentialInsertList.add(asp2);
        insert accSpeciesPotentialInsertList;
        
        Test.startTest();
        Database.MergeResult result1 = Database.merge(master1object, master1ChildAcc, false);
        Database.MergeResult result2 = Database.merge(master2Acc, master2ChildAcc, false);        
        Test.stopTest();
        
        List<ZTS_EU_Account_Species_Potential__c> asp1mergeList = [SELECT Id,Account__c FROM ZTS_EU_Account_Species_Potential__c where Account__c =:master1object.Id AND ZTS_EU_Species_Potential__c =:speciesList[0].Id];
        System.assertEquals(1,asp1mergeList.size(), 'Account species potential account and species record transferred to masteraccount');
        List<ZTS_EU_Account_Species_Potential__c> asp1mergeList1 = [SELECT Id,Account__c FROM ZTS_EU_Account_Species_Potential__c where Account__c =:master1ChildAcc];
        System.assertEquals(0,asp1mergeList1.size(), 'Account species potential got deleted fom child account when accounts mergerd');
        List<ZTS_EU_Account_Species_Potential__c> asp1mergeList3 = [SELECT Id,Account__c FROM ZTS_EU_Account_Species_Potential__c where Account__c =:master2Acc.Id];
        System.assertEquals(1,asp1mergeList3.size(), 'Account species potential stays on master account when child record merged');
       
    }
    
    static testmethod void onAfterDeleteTest2(){
      
        SObject master1object;
        Id master1ChildAcc;

        List<Account> accList = [Select Id, Name,ZTS_EU_Market__c From Account where Name LIKE 'Master%'];
        for(Account acc :accList){
            if(acc.Name=='Master'){
                master1object = acc;
            }
            else if(acc.Name=='Master Child'){
                master1ChildAcc =acc.Id;
            }

        }
      
        List<ZTS_EU_Species__c> speciesList = [Select Id,ZTS_EU_Market__c from ZTS_EU_Species__c where ZTS_EU_Market__c='Spain' LIMIT 2];
        
        List<ZTS_EU_Account_Species_Potential__c> aspList = new List<ZTS_EU_Account_Species_Potential__c>();
        DispatchTriggerHandler.firstTimeTracker = new Set<String>();
        ZTS_EU_Account_Species_Potential__c asp1= ZTS_DataUtilityTest.createEUAccountSpeciesPotentialRec(speciesList[0].Id,master1ChildAcc);
        aspList.add(asp1);
        ZTS_EU_Account_Species_Potential__c asp2= ZTS_DataUtilityTest.createEUAccountSpeciesPotentialRec(speciesList[1].Id,master1object.Id);
        aspList.add(asp2);

        insert aspList;
        Test.startTest();
        Database.MergeResult result = Database.merge(master1object, master1ChildAcc, false);
        Test.stopTest();
        
        System.assertEquals(master1object.Id,result.Id);
        List<ZTS_EU_Account_Species_Potential__c> asp1MergeList = [SELECT Id,Account__c FROM ZTS_EU_Account_Species_Potential__c where Account__c =:master1object.Id AND (ZTS_EU_Species_Potential__c =:speciesList[0].Id OR ZTS_EU_Species_Potential__c =:speciesList[1].Id)];
        System.assertEquals(2,asp1mergeList.size(), '1 Account species potential and species record transferred to masteraccount');
        
    }
    
    static testmethod void onAfterDeleteDuplicateAccountSpeciesRecordTest3(){
        
        SObject master3object;
        Id master3ChildAcc;
        List<Account> accList = [Select Id, Name,ZTS_EU_Market__c From Account where Name LIKE 'Master%'];
        for(Account acc :accList){
            if(acc.Name=='Master3'){
                master3object =acc;
            }
            else if(acc.Name=='Master3 Child'){
                master3ChildAcc = acc.Id;
            }
        }
        
        List<ZTS_EU_Species__c> speciesList = [Select Id,ZTS_EU_Market__c from ZTS_EU_Species__c where ZTS_EU_Market__c='Canada' LIMIT 1];
        DispatchTriggerHandler.firstTimeTracker = new Set<String>();
        List<ZTS_EU_Account_Species_Potential__c> aspList = new List<ZTS_EU_Account_Species_Potential__c>();
        ZTS_EU_Account_Species_Potential__c asp3= ZTS_DataUtilityTest.createEUAccountSpeciesPotentialRec(speciesList[0].Id,master3object.Id);
        aspList.add(asp3);
        ZTS_EU_Account_Species_Potential__c asp4=ZTS_DataUtilityTest.createEUAccountSpeciesPotentialRec(speciesList[0].Id,master3ChildAcc);
        aspList.add(asp4);
        insert aspList;
        
        Test.startTest();
        Database.MergeResult result1 = Database.merge(master3object, master3ChildAcc, false);
        Test.stopTest();
        List<ZTS_EU_Account_Species_Potential__c> asp1MergeList2 = [SELECT Id,Account__c FROM ZTS_EU_Account_Species_Potential__c where (Account__c =:master3object.Id AND ZTS_EU_Species_Potential__c =:speciesList[0].Id)];
        System.assertEquals(1,asp1MergeList2.size(), '1 duplicate Account species potential record deleted from child account');
    }
        
}