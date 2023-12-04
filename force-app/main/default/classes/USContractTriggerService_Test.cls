@isTest
public class USContractTriggerService_Test {

    static TestMethod void testCase1(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration profile'];
        User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com', ZTS_EU_Market__c = 'United States',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                          UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest'); 
        u.ManagerID = usr.Id;
        insert u; 
        
        List<Account> acclist = new List<Account>();
        System.runAs(usr)
        {
            acclist = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            acclist[0].ZTS_EU_Market__c = 'United States';
            acclist[0].BillingStreet='B_ST_1';
			acclist[0].BillingCity='test_city';
			acclist[0].BillingCountry='United States';
			acclist[0].BillingState='TX';
			acclist[0].BillingPostalCode='12345';
            insert acclist;
        }

        System.runAs(u)
        {
            Test.startTest();
            Contract objContract = new Contract();
            Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('New_Contract').getRecordTypeId();
            objContract.Name = System.today().year() +' CAD MZR Bios Pricing';
            objContract.ZTS_US_Current_Tier__c = 'Elite';
            objContract.RecordTypeId = RecordTypeIdContact;
            objContract.AccountId = acclist[0].Id;
            objContract.ZTS_US_Leaders_Edge__c = true; 
            objContract.ZTS_US_BIOs_Field_Proposed_Tier__c = '7,500';
            insert objContract;
            objContract.Status = 'MZR PARAs Terms and Conditions Accepted';
            objContract.ZTS_US_End_Date_Interface__c = system.today()+1;
            update objContract;
            Account parentAcc = [Select Id,ZTS_US_MVP_Account__c From Account Where Id =: acclist[0].Id];
            system.assertEquals(true, parentAcc.ZTS_US_MVP_Account__c, 'Account should be marked as MVP account');
            Test.stopTest();
        }
    }
    
    static TestMethod void testCase2(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration profile'];
        User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com', ZTS_EU_Market__c = 'United States',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                          UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest'); 
        u.ManagerID = usr.Id;
        insert u; 
        
        List<Account> acclist = new List<Account>();
        System.runAs(usr)
        {
            acclist = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            acclist[0].ZTS_EU_Market__c = 'United States';
            acclist[0].BillingStreet='B_ST_1';
			acclist[0].BillingCity='test_city';
			acclist[0].BillingCountry='United States';
			acclist[0].BillingState='TX';
			acclist[0].BillingPostalCode='12345';
            insert acclist;
        }

        System.runAs(u)
        {
            Test.startTest();
            List<Contract> contractList = new List<Contract>();
            Contract objContract = new Contract();
            
            Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('New_Contract').getRecordTypeId();
            objContract.Name = System.today().year() +' LE Contract';
            objContract.ZTS_US_Current_Tier__c = 'Elite';
            objContract.RecordTypeId = RecordTypeIdContact;
            objContract.AccountId = acclist[0].Id;
            objContract.ZTS_US_Leaders_Edge__c = true; 
            objContract.ZTS_US_BIOs_Field_Proposed_Tier__c = '7,500';
            objContract.StartDate = system.today().addDays(-4);
            objContract.ContractTerm = 1;
            contractList.add(objContract);
            
            Contract objContract1 = new Contract();
            objContract1.Name = System.today().year() +' VGP PETCARE STRATEGIC (REBATE)';
            objContract1.ZTS_US_Current_Tier__c = 'Elite';
            objContract1.RecordTypeId = RecordTypeIdContact;
            objContract1.AccountId = acclist[0].Id;
            objContract1.ZTS_US_Leaders_Edge__c = true; 
            objContract1.ZTS_US_BIOs_Field_Proposed_Tier__c = '7,500';
            objContract1.StartDate = system.today().addDays(-4);
            objContract1.ContractTerm = 1;
            contractList.add(objContract1);
            
            Contract objContract2 = new Contract();
            objContract2.Name = System.today().year() +' PC MZR Paras';
            objContract2.ZTS_US_Current_Tier__c = 'Elite';
            objContract2.RecordTypeId = RecordTypeIdContact;
            objContract2.AccountId = acclist[0].Id;
            objContract2.ZTS_US_Leaders_Edge__c = true; 
            objContract2.ZTS_US_BIOs_Field_Proposed_Tier__c = '7,500';
            objContract2.StartDate = system.today().addDays(-4);
            objContract2.ContractTerm = 1;
            contractList.add(objContract2);
            
            Contract objContract3 = new Contract();
            objContract3.Name = System.today().year() +' PC MZR Theras';
            objContract3.ZTS_US_Current_Tier__c = 'Elite';
            objContract3.RecordTypeId = RecordTypeIdContact;
            objContract3.AccountId = acclist[0].Id;
            objContract3.ZTS_US_Leaders_Edge__c = true; 
            objContract3.ZTS_US_BIOs_Field_Proposed_Tier__c = '7,500';
            objContract3.StartDate = system.today().addDays(-4);
            objContract3.ContractTerm = 1;
            contractList.add(objContract3);
            
            Contract objContract4 = new Contract();
            objContract4.Name = System.today().year() +' EQ MZR Pricing';
            objContract4.ZTS_US_Current_Tier__c = 'Elite';
            objContract4.RecordTypeId = RecordTypeIdContact;
            objContract4.AccountId = acclist[0].Id;
            objContract4.ZTS_US_Leaders_Edge__c = true; 
            objContract4.ZTS_US_BIOs_Field_Proposed_Tier__c = '7,500';
            objContract4.StartDate = system.today().addDays(-4);
            objContract4.ContractTerm = 1;
            contractList.add(objContract4);
            
            insert contractList;
            
            contractList[1].ContractTerm = 2;
            contractList[2].ContractTerm = 2;
            contractList[3].ContractTerm = 2;
            contractList[4].ContractTerm = 2;
            
            contractList[0].Status = 'MZR PARAs Terms and Conditions Accepted';
            contractList[0].ZTS_US_End_Date_Interface__c = system.today()+1;
            contractList[0].StartDate = system.today().addDays(-2);
            update contractList;
            
            delete contractList[4];
            Account parentAcc = [Select Id,LE_Effective_Pricing_Date__c From Account Where Id =: acclist[0].Id];
            system.assertEquals(system.today().addDays(-2), parentAcc.LE_Effective_Pricing_Date__c, 'LE effective pricing date should be updated in parent account');
            Test.stopTest();
        }
    }
    
    static TestMethod void testCase3(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration profile'];
        User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com', ZTS_EU_Market__c = 'United States',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                          UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest'); 
        u.ManagerID = usr.Id;
        insert u; 
        
        List<Account> acclist = new List<Account>();
        System.runAs(usr)
        {
            acclist = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            acclist[0].ZTS_EU_Market__c = 'United States';
            acclist[0].BillingStreet='B_ST_1';
			acclist[0].BillingCity='test_city';
			acclist[0].BillingCountry='United States';
			acclist[0].BillingState='TX';
			acclist[0].BillingPostalCode='12345';
            insert acclist;
        }

        System.runAs(u)
        {
            Test.startTest();
            List<Contract> contractList = new List<Contract>();
            Contract objContract = new Contract();
            Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('New_Contract').getRecordTypeId();
            Id DxRecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('DX_MZR').getRecordTypeId();
            objContract.Name = System.today().year() +' LVS MZR';
            objContract.ZTS_US_Current_Tier__c = System.today().year() +' LVS MZR';
            objContract.ZTS_US_Pricing_Program_Name__c = System.today().year() +' LVS MZR';
            objContract.RecordTypeId = RecordTypeIdContact;
            objContract.AccountId = acclist[0].Id;
            objContract.StartDate = system.today().addDays(-4);
            objContract.ZTS_US_End_Date_Interface__c  = system.today().addDays(26);
            objContract.ContractTerm = 1;
            contractList.add(objContract);
            
            Contract objContract1 = new Contract();
            objContract1.Name = System.today().year() +' LVS MZR Preferred';
            objContract1.ZTS_US_Current_Tier__c = System.today().year() +' LVS MZR Preferred';
            objContract1.ZTS_US_Pricing_Program_Name__c = System.today().year() +' LVS MZR Preferred';
            objContract1.RecordTypeId = RecordTypeIdContact;
            objContract1.AccountId = acclist[0].Id;
            objContract1.StartDate = system.today().addDays(-4);
            objContract1.ZTS_US_End_Date_Interface__c  = system.today().addDays(26);
            objContract1.ContractTerm = 1;
            contractList.add(objContract1);
            
            Contract objContract2 = new Contract();
            objContract2.Name = System.today().year() +' DX MZR POC Pricing';
            objContract2.Contract_Type__c = 'DX MZR POC Agreement';
            objContract2.RecordTypeId = DxRecordTypeIdContact;
            objContract2.AccountId = acclist[0].Id;
            objContract2.StartDate = system.today().addDays(-4);
            objContract2.ZTS_US_End_Date_Interface__c  = system.today().addDays(26);
            objContract2.ContractTerm = 1;
            contractList.add(objContract2);
            
            Contract objContract3 = new Contract();
            objContract3.Name = System.today().year() +' DX MZR LAB Pricing';
            objContract3.Contract_Type__c = 'DX MZR LAB Agreement';
            objContract3.RecordTypeId = DxRecordTypeIdContact;
            objContract3.AccountId = acclist[0].Id;
            objContract3.StartDate = system.today().addDays(-4);
            objContract3.ZTS_US_End_Date_Interface__c  = system.today().addDays(26);
            objContract3.ContractTerm = 1;
            contractList.add(objContract3);
            
            Contract objContract4 = new Contract();
            objContract4.Name = System.today().year() +' DX MZR IMAGYST Pricing';
            objContract4.Contract_Type__c = 'DX MZR IMAGYST Agreement';
            objContract4.RecordTypeId = DxRecordTypeIdContact;
            objContract4.AccountId = acclist[0].Id;
            objContract4.StartDate = system.today().addDays(-4);
            objContract4.ZTS_US_End_Date_Interface__c  = system.today().addDays(26);
            objContract4.ContractTerm = 1;
            contractList.add(objContract4);
            insert contractList;
            
            contractList[1].ContractTerm = 2;
            contractList[2].ContractTerm = 2;
            contractList[3].ContractTerm = 2;
            contractList[4].ContractTerm = 2;
            update contractList;
            
            delete contractList[4];
            Account parentAcc = [Select Id,LVS_MZR_Account__c, LVS_MZR_Enrollment_Date__c,LVS_MZR_Status__c, LVS_MZR_Tier__c,
                                 DX_MZR_Imagyst_Enrollment_Date__c,DX_MZR_Lab_Enrollment_Date__c,DX_MZR_POC_Enrollment_Date__c From Account Where Id =: acclist[0].Id];
            System.debug('+++++++++'+ JSON.serialize(parentAcc));
            system.assertEquals(True, parentAcc.LVS_MZR_Account__c, 'Parent account should be marked for Livestock contract if active');
            system.assertEquals(parentAcc.DX_MZR_Lab_Enrollment_Date__c, objContract3.StartDate, 'Start date for DX Lab contract should be updated to parent account.');
            system.assertEquals(parentAcc.DX_MZR_POC_Enrollment_Date__c, objContract2.StartDate, 'Start date for DX POC contract should be updated to parent account.');
            system.assertEquals(parentAcc.LVS_MZR_Enrollment_Date__c, objContract1.StartDate, 'Start date for Livestock contract should be updated to parent account.');
            system.assertEquals(parentAcc.LVS_MZR_Status__c, 'Active', 'LVS MZR Status should be active on parent account if account have LiveStock contract.');
            system.assertEquals(parentAcc.LVS_MZR_Tier__c, 'LVS Preferred', 'LVS MZR tier should be LVS Preffered if contract have Preferred contract.');
            Test.stopTest();
        }
    }
}