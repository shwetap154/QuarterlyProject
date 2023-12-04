/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Contract_UtilsTest
* Description   :  Test class for ZTS_US_AllContractTrigger trigger         
* @author       :  Ketan Prakash Singh
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Ketan             Created the Class.

********************************************************************************************************************************************/
@isTest(SeeAllData = false)
public class ZTS_US_Contract_UtilsTest{
    Public static List<Contract> contrList = new List<Contract>();
    Public static Map<ID,Contract> mapContrIdCon = new Map<ID,Contract>();
    

    public static void createTestData1(){
        
        contrList = ZTS_DataUtilityTest.createContractRecord(1);
        contrList[0].RecordTypeId = System.Label.ZTS_US_Contract_Record_Type_Id_for_Contract_Renewal;
        contrList[0].ZTS_US_Field_Proposed_Tier__c = 'Elite';
        contrList[0].ZTS_US_Review_Committee_Proposed_Tier__c = 'Elite';
        contrList[0].Status = 'TM Resubmit';
        contrList[0].ZTS_US_Approval_Status__c = 'Pending';
        contrList[0].ZTS_US_Diff_Proposed_Current__c = -1.0;
        contrList[0].RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Tier_Change').getRecordTypeId();
        contrList[0].ZTS_US_Submitter_Comments__c = 'Test';
        contrList[0].ZTS_US_Submitted_for_Approval__c = true;
        
        
         
        
        insert contrList;
    }
    
    public static void createTestData2(){
        contrList = new List<Contract>();
        mapContrIdCon = new Map<ID,Contract>();
        contrList = ZTS_DataUtilityTest.createContractRecord(1);
        contrList[0].RecordTypeId = System.Label.ZTS_US_Contract_Record_Type_Id_for_Contract_Renewal;
        contrList[0].ZTS_US_Field_Proposed_Tier__c = 'Elite';
        contrList[0].ZTS_US_Review_Committee_Proposed_Tier__c = 'Elite';
        contrList[0].Status = 'New';
        contrList[0].ZTS_US_Approval_Status__c = 'Pending';
        contrList[0].ZTS_US_Diff_Proposed_Current__c = -1.0;
        contrList[0].RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Tier_Change').getRecordTypeId();
        contrList[0].ZTS_US_Submitter_Comments__c = 'Test';
        contrList[0].ZTS_US_Submitted_for_Approval__c = true;
         
        insert contrList;
        
        for(Contract c : contrList){
            mapContrIdCon.put(c.Id,c);    
        }
        
        
        contrList[0].ZTS_US_Approval_Status__c = 'Pending Approval';
        contrList[0].ZTS_US_Submitted_for_Approval__c = true;
        
        update contrList;
    }

    static testmethod void testZTS_US_Contract_Utils1(){
        createTestData1();
        Test.startTest();
        ZTS_US_Contract_Utils.statusUpdateOnUnanimousApprOrRejec(contrList,mapContrIdCon);
        ZTS_US_Contract_Utils.submitForApproval(contrList,mapContrIdCon);
        //ZTS_US_Contract_Utils.RequireRejectionComment(contrList,mapContrIdCon);
        ZTS_US_Contract_Utils.diffCalc(contrList);
       //ZTS_US_Contract_Utils.UpdateDirector(contrList);
        Test.stopTest();
    }
    
    static testmethod void testZTS_US_Contract_Utils2(){
        createTestData2();
        Test.startTest();
        ZTS_US_Contract_Utils.statusUpdateOnUnanimousApprOrRejec(contrList,mapContrIdCon);
        ZTS_US_Contract_Utils.submitForApproval(contrList,mapContrIdCon);
        ZTS_US_Contract_Utils.RequireRejectionComment(contrList,mapContrIdCon);
        ZTS_US_Contract_Utils.diffCalc(contrList);
        ZTS_US_Contract_Utils.UpdateDirector(contrList);
        Test.stopTest();
    } 

   static testmethod void testLEContract(){
    User u = [select id , name,lastname from user where profile.name='Integration profile' and lastname='Admin' AND ZTS_EU_Market__c = 'United States' limit 1];
        List<Account> acct = new List<Account>();
        acct = ZTS_DataUtilityTest.createAccountRecord(1);
        insert acct;
        List<Contract> con = new List<Contract>();
        Contract cntrs = new Contract(name = 'Test LE Contract',Accountid = acct[0].id,ZTS_US_Current_Tier__c='Prestige',ZTS_US_Field_Proposed_Tier__c='Prestige'); 
        con.add(cntrs);
        System.runas(u){
        
        insert con;
          con[0].ZTS_US_End_Date_Interface__c = System.today()+10;
          update cntrs;
        }
    
    }
 
    static testmethod void testLEContractupdate(){
    //User u = [select id , name,lastname from user where profile.name='Integration profile' and lastname='Admin' AND ZTS_EU_Market__c = 'United States' limit 1];
    User u = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration profile', false);
    u.ZTS_EU_Market__c = 'United States';
        List<Account> acct = new List<Account>();
        acct = ZTS_DataUtilityTest.createAccountRecord(1);
        acct[0].ZTS_EU_Market__c = 'United States';
        insert acct;
        List<Contract> con = new List<Contract>();
        Contract cntrs = new Contract(name = 'Test LE Contract',Accountid = acct[0].id,ZTS_US_Current_Tier__c='Prestige',ZTS_US_Field_Proposed_Tier__c='Prestige',startdate=System.today(),ZTS_US_End_Date_Interface__c=System.today()+5); 
        con.add(cntrs);
        System.runas(u){
        
        insert con;
          con[0].ZTS_US_End_Date_Interface__c = System.today()+10;
          update cntrs;
        }
    
    }
    
     static testmethod void testMVPBIOS(){
        User u = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration profile', false);        List<Account> acct = new List<Account>();
        acct = ZTS_DataUtilityTest.createAccountRecord(1);
        acct[0].ZTS_EU_Market__c = 'United States';
        insert acct;
        List<Contract> con = new List<Contract>();
        Contract cntrs = new Contract(name = 'Test Bios Contract',Accountid = acct[0].id,ZTS_US_Current_Tier__c='Prestige',ZTS_US_Field_Proposed_Tier__c='Prestige',startdate=System.today(),ZTS_US_End_Date_Interface__c=System.today()+5); 
        con.add(cntrs);
        System.runas(u){
        
        insert con;
          con[0].ZTS_US_End_Date_Interface__c = System.today()+10;
          update cntrs;
        }
    
    }
    
    static testmethod void testMZR(){
        User u = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration profile', false);        List<Account> acct = new List<Account>();
        acct = ZTS_DataUtilityTest.createAccountRecord(1);
        acct[0].ZTS_EU_Market__c = 'United States';
        insert acct;
        List<Contract> con = new List<Contract>();
        Contract cntrs = new Contract(name = 'MZR Pricing',Accountid = acct[0].id,ZTS_US_Current_Tier__c='Prestige',ZTS_US_Field_Proposed_Tier__c='Prestige',startdate=System.today(),ZTS_US_End_Date_Interface__c=System.today()+5); 
        con.add(cntrs);
        System.runas(u){
        
        insert con;
          con[0].ZTS_US_End_Date_Interface__c = System.today()+10;
          update cntrs;
        }
    
    }
    
    
    //Added by Tanmoy Das 
    //For LE
        static testmethod void testLE(){
        User u = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration profile', false);        List<Account> acct = new List<Account>();
        acct = ZTS_DataUtilityTest.createAccountRecord(1);
        acct[0].ZTS_EU_Market__c = 'United States';
        insert acct;
        List<Contract> con = new List<Contract>();
        Contract cntrs = new Contract(name = 'LE',Accountid = acct[0].id,ZTS_US_Current_Tier__c='Prestige',ZTS_US_Field_Proposed_Tier__c='Prestige',startdate=System.today(),ZTS_US_End_Date_Interface__c=System.today()+5); 
        con.add(cntrs);
        System.runas(u){
        
        insert con;
          con[0].ZTS_US_End_Date_Interface__c = System.today()+10;
          update cntrs;
        }
    
    }
    
    //For Bios
    static testmethod void testBIOS(){
        User u = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration profile', false);        List<Account> acct = new List<Account>();
        acct = ZTS_DataUtilityTest.createAccountRecord(1);
        acct[0].ZTS_EU_Market__c = 'United States';
        insert acct;
        List<Contract> con = new List<Contract>();
        Contract cntrs = new Contract(name = 'Bios',Accountid = acct[0].id,ZTS_US_Current_Tier__c='Prestige',ZTS_US_Field_Proposed_Tier__c='Prestige',startdate=System.today(),ZTS_US_End_Date_Interface__c=System.today()+5); 
        con.add(cntrs);
        System.runas(u){
        
        insert con;
          con[0].ZTS_US_End_Date_Interface__c = System.today()+10;
          update cntrs;
        }
    
    }
    
    //For VGP
    static testmethod void testVGPContract(){
        User u = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration profile', false);        List<Account> acct = new List<Account>();
        acct = ZTS_DataUtilityTest.createAccountRecord(1);
        acct[0].ZTS_EU_Market__c = 'United States';
        insert acct;
        List<Contract> con = new List<Contract>();
        Contract cntrs = new Contract(name = 'VGP PETCARE STRATEGIC (REBATE)',Accountid = acct[0].id,ZTS_US_Current_Tier__c='Prestige',ZTS_US_Field_Proposed_Tier__c='Prestige',startdate=System.today(),ZTS_US_End_Date_Interface__c=System.today()+5); 
        con.add(cntrs);
        System.runas(u){
        
        insert con;
          con[0].ZTS_US_End_Date_Interface__c = System.today()+10;
          update cntrs;
        }
    
    }
    
    //for 'PC MZR Paras'
     static testmethod void testPCPARAS(){
        User u = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration profile', false);        List<Account> acct = new List<Account>();
        acct = ZTS_DataUtilityTest.createAccountRecord(1);
        acct[0].ZTS_EU_Market__c = 'United States';
        insert acct;
        List<Contract> con = new List<Contract>();
        Contract cntrs = new Contract(name = 'PC MZR Paras',Accountid = acct[0].id,ZTS_US_Current_Tier__c='Prestige',ZTS_US_Field_Proposed_Tier__c='Prestige',startdate=System.today(),ZTS_US_End_Date_Interface__c=System.today()+5); 
        con.add(cntrs);
        System.runas(u){
        
        insert con;
          con[0].ZTS_US_End_Date_Interface__c = System.today()+10;
          update cntrs;
        }
    
    }
    // for 'PC MZR Theras'
         static testmethod void testPCTHERAS(){
        User u = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration profile', false);        List<Account> acct = new List<Account>();
        acct = ZTS_DataUtilityTest.createAccountRecord(1);
        acct[0].ZTS_EU_Market__c = 'United States';
        insert acct;
        List<Contract> con = new List<Contract>();
        Contract cntrs = new Contract(name = 'PC MZR Theras',Accountid = acct[0].id,ZTS_US_Current_Tier__c='Prestige',ZTS_US_Field_Proposed_Tier__c='Prestige',startdate=System.today(),ZTS_US_End_Date_Interface__c=System.today()+5); 
        con.add(cntrs);
        System.runas(u){
        
        insert con;
          con[0].ZTS_US_End_Date_Interface__c = System.today()+10;
          update cntrs;
        }
    
    }
    
    //MZR Pricing
    
        static testmethod void testMZRPricing(){
        User u = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration profile', false);        List<Account> acct = new List<Account>();
        acct = ZTS_DataUtilityTest.createAccountRecord(1);
        acct[0].ZTS_EU_Market__c = 'United States';
        insert acct;
        List<Contract> con = new List<Contract>();
        Contract cntrs = new Contract(name = 'MZR Pricing',Accountid = acct[0].id,ZTS_US_Current_Tier__c='Prestige',ZTS_US_Field_Proposed_Tier__c='Prestige',startdate=System.today(),ZTS_US_End_Date_Interface__c=System.today()+5); 
        con.add(cntrs);
        System.runas(u){
        
        insert con;
          con[0].ZTS_US_End_Date_Interface__c = System.today()+10;
          update cntrs;
        }
    
    }
    
    
    //code ends here
    
   
    
    
    static testmethod void testVGP(){
        User u = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration profile', false);        List<Account> acct = new List<Account>();
        acct = ZTS_DataUtilityTest.createAccountRecord(1);
        acct[0].ZTS_EU_Market__c = 'United States';
        insert acct;
        List<Contract> con = new List<Contract>();
        Contract cntrs = new Contract(name = 'Test VGP PETCARE STRATEGIC (REBATE)',Accountid = acct[0].id,ZTS_US_Current_Tier__c='Prestige',ZTS_US_Field_Proposed_Tier__c='Prestige',startdate=System.today(),ZTS_US_End_Date_Interface__c=System.today()+5); 
        con.add(cntrs);
        System.runas(u){
        
        insert con;
          con[0].ZTS_US_End_Date_Interface__c = System.today()+10;
          update cntrs;
        }
    
    }
    
    //Used to test the updateDeletedLocationSupplier method for all location supplier and delete
    static testmethod void updateDeletedLocationSupplierTest(){
        
        //Create Account
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.ZTS_US_NARC_ID__c = '00000';
        objAccount.ZTS_EU_Market__c = 'United States';
        objAccount.BillingPostalCode = '12345';
        objAccount.BillingCity = 'Boca Raton';
        objAccount.BillingState = 'Florida';
        objAccount.BillingStreet = 'Elm Lane';
        insert objAccount;
        
        //Create Child Accounts 
        Account objchild;
        List<Account> accList = new List<Account>();
        for(Integer count=0; count < 4; count++){
            objchild = new Account();
            objchild.Name = 'Test Account ' +  count + 1;
            objchild.ParentId = objAccount.Id;
            objchild.ZTS_US_NARC_ID__c = '0000' + count + 1;
            objchild.BillingStreet = 'Street' +  count + 1;
            objchild.BillingCity = 'City' +  count + 1;
            objchild.BillingState = 'FL';
            objchild.BillingPostalCode = '0001' + count + 1;
            objchild.BillingCountry = 'United States';
            objchild.ZTS_EU_Market__c = 'United States';
            accList.add(objchild);
        }
        insert accList;
        
        //Insert Account Affiliations
        List<ZTS_EU_Account_Affiliations__c> lstAffiliations = new List<ZTS_EU_Account_Affiliations__c>();
        ZTS_EU_Account_Affiliations__c aff = null;
        Integer counter =0;
        for(Account acc: accList){
            aff = new ZTS_EU_Account_Affiliations__c();
            aff.ZTS_EU_Account__c = objAccount.Id;
            aff.ZTS_EU_Affiliated_Account__c = acc.Id;
            if(counter < 2){
                aff.ZTS_US_Role__c = 'Supplier' ;
            }else{
                aff.ZTS_US_Role__c = 'Distributor' ;
            }
            lstAffiliations.add(aff);
        }
        insert lstAffiliations;
        
        
        //Create Contract
        Contract objContract = new Contract();
        objContract.Name = 'Contract 1';
        objContract.AccountId = objAccount.Id;
        insert objContract;
        
              
        objContract.Deleted_Locations__c = 'checked-uncheked-unchecked-unchecked';
        objContract.Deleted_Suppliers__c = 'checked-uncheked';
        objContract.Deleted_Distributors__c = 'checked-uncheked';
        List<Contract> conList = new List<Contract>();
        conList.add(objContract);
        ZTS_US_Contract_Utils.updateDeletedLocationSupplier(conList);   
        
              
        //system.assertEquals('Test Account 01,Street01, City01, FL, 000101, United States', conList[0].Deleted_Suppliers__c );
        //system.assertEquals('Test Account 31,Street31, City31, FL, 000131, United States', conList[0].Deleted_Suppliers__c );
        
    }
    
    static testmethod void doFormattingTest(){
        Decimal dec = 12345;
        String formattedDec = ZTS_US_Contract_Utils.doFormatting(dec, 0);
        System.assertEquals('12,345', formattedDec);
    }
    
    static testmethod void updateAccountContractDetailsTest(){
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.ZTS_US_NARC_ID__c = '00000';
        objAccount.ZTS_EU_Market__c = 'United States';
        objAccount.BillingPostalCode = '12345';
        objAccount.BillingCity = 'Boca Raton';
        objAccount.BillingState = 'Florida';
        objAccount.BillingStreet = 'Elm Lane';
        insert objAccount;
        
        Contract objContract = new Contract();
        Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('MVP_Proposal').getRecordTypeId();
        objContract.Name = '2018 CAD MZR Bios Pricing';
        objContract.ZTS_US_Current_Tier__c = '2018 CAD MZR Bios $40k';
        objContract.RecordTypeId = RecordTypeIdContact;
        objContract.AccountId = objAccount.Id;
        //objContract.Status = 'Active';
        objContract.ZTS_US_Leaders_Edge__c = true; 
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration profile'];
        User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                          UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest',  ZTS_EU_Market__c = 'United States'); 
        insert u; 
        System.runAs(u) { 
            Profile p1 = [SELECT Id,Name FROM Profile WHERE Id= :UserInfo.getProfileId()];
            System.debug('Current Profile in TEST: ' + p1.Name);
            insert objContract; 
            objContract.Status = 'Active';
            update objContract;
        }  
        List<Contract> conList = new List<Contract>();
        conList.add(objContract);
        ZTS_US_Contract_Utils.updateAccountContractDetails(conList, null);
        
        Account a = new Account(Name = 'Account With Account Team',ZTS_US_Business_Class__c = 'Breeder',ZTS_EU_Account_Status__c = 'Pending');
        a.BillingPostalCode = '12345';
        a.BillingCity = 'Boca Raton';
        a.BillingState = 'Florida';
        a.BillingStreet = 'Elm Lane';
        a.ZTS_EU_Market__c = 'United States';
        List<Account> accountList = new List<Account>();
        accountList.add(a); 
        ZTS_EU_Territory__c territory = new ZTS_EU_Territory__c(Name = 'Test Territory',ZTS_US_Synced__c = true);
        territory.ZTS_EU_Market__c = 'United States';
        insert territory;
        ZTS_EU_Position__c userTerritory = new ZTS_EU_Position__c(ZTS_EU_Territory__c = territory.id,ZTS_EU_Employee__c = a.OwnerId);
        insert userTerritory;   
        Test.StartTest();           
        insert accountList;
        //ZTS_createAccountTeams myObject = new ZTS_createAccountTeams();
        ZTS_createAccountTeams.AccountTeamCreation(accountList);
        Contract objContract2 = new Contract(); 
        objContract2.Name = 'Contract $12233 Test';
        objContract2.RecordTypeId = RecordTypeIdContact;
        objContract2.AccountId = a.Id; 
        objContract2.ZTS_US_Leaders_Edge__c = true;
        insert objContract2;  
        
        List<Contract> conList2 = new List<Contract>();
        conList.add(objContract2);
        Test.StopTest();
        ZTS_US_Contract_Utils.populateTerritoryOnContract(conList2);
         
    }
    
    @isTest 
    static void updateAccountContractDetailsTest2(){ 
        Account objAccount = new Account();
        objAccount.Name = 'Test Account2';
        objAccount.ZTS_US_NARC_ID__c = '000001';
        objAccount.BillingPostalCode = '12345';
        objAccount.BillingCity = 'Boca Raton';
        objAccount.BillingState = 'Florida';
        objAccount.BillingStreet = 'Elm Lane';
        objAccount.ZTS_EU_Market__c = 'United States';
        insert objAccount;
        Account a = new Account(Name = 'Account With Account Team',ZTS_US_Business_Class__c = 'Breeder',ZTS_EU_Account_Status__c = 'Pending', ZTS_EU_Market__c = 'United States');
        a.BillingPostalCode = '12345';
        a.BillingCity = 'Boca Raton';
        a.BillingState = 'Florida';
        a.BillingStreet = 'Elm Lane';
        a.ZTS_EU_Market__c = 'United States';
        Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('MVP_Proposal').getRecordTypeId();
        List<Account> accountList = new List<Account>();
        accountList.add(a); 
        ZTS_EU_Territory__c territory = new ZTS_EU_Territory__c(Name = 'Test Territory',ZTS_US_Synced__c = true, ZTS_EU_Market__c = 'United States');
        insert territory;
        ZTS_EU_Position__c userTerritory = new ZTS_EU_Position__c(ZTS_EU_Territory__c = territory.id,ZTS_EU_Employee__c = a.OwnerId);
        insert userTerritory;   
        //Test.startTest();
        Contract objCont = new Contract(); 
        objCont.Name = '2018 CAD MZR Bios Pricing';
        objCont.ZTS_US_Current_Tier__c = '2018 CAD MZR Bios $10k';
        objCont.RecordTypeId = RecordTypeIdContact;
        objCont.AccountId = objAccount.Id;   
        Profile p = [SELECT Id,Name FROM Profile WHERE Name='Integration Profile']; 
        User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                          UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest', ZTS_EU_Market__c = 'United States'); 
        insert u; 
        system.debug([SELECT Name from User Where Id =: u.Id AND ZTS_EU_Market__c = 'United States']);
        List<Contract> conList3 = new List<Contract>();
        System.runAs(u) { 
            Profile p1 = [SELECT Id,Name FROM Profile WHERE Id= :UserInfo.getProfileId()];
            System.debug('Current Profile in TEST2: ' + p1.Name);
            insert objCont;  
            System.debug('...Profile Name in Test2...' + objCont.CreatedBy);  
            conList3.add(objCont); 
            ZTS_US_Contract_Utils.updateAccountContractDetails(conList3, null);
        }  
        //Test.stopTest();
        System.runAs(u) { 
            Contract objCont2 = new Contract(); 
            objCont2.Name = '2018 PC MZR Paras'; 
            objCont2.RecordTypeId = RecordTypeIdContact;
            objCont2.AccountId = objAccount.Id; 
            objCont2.status = 'TM Resubmit';
            List<Contract> conList4 = new List<Contract>();
            conList4.add(objCont2);
            ZTS_US_Contract_Utils.statusUpdateOnUnanimousApprOrRejec(conList4,null);
        }
    }
    
    @isTest 
    static void updateAccountContractDetailsTest3(){ 
        Account objAccount = new Account();
        objAccount.Name = 'Test Account2';
        objAccount.ZTS_US_NARC_ID__c = '000001';
        objAccount.ZTS_EU_Market__c = 'United States';
        objAccount.BillingPostalCode = '12345';
        objAccount.BillingCity = 'Boca Raton';
        objAccount.BillingState = 'Florida';
        objAccount.BillingStreet = 'Elm Lane';
        insert objAccount;
        Account a = new Account(Name = 'Account With Account Team',ZTS_US_Business_Class__c = 'Breeder',ZTS_EU_Account_Status__c = 'Pending');
        a.BillingPostalCode = '12345';
        a.BillingCity = 'Boca Raton';
        a.BillingState = 'Florida';
        a.BillingStreet = 'Elm Lane';
        a.ZTS_EU_Market__c = 'United States';
        Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('MVP_Proposal').getRecordTypeId();
        List<Account> accountList = new List<Account>();
        accountList.add(a); 
        ZTS_EU_Territory__c territory = new ZTS_EU_Territory__c(Name = 'Test Territory',ZTS_US_Synced__c = true, ZTS_EU_Market__c = 'United States');
        insert territory;
        ZTS_EU_Position__c userTerritory = new ZTS_EU_Position__c(ZTS_EU_Territory__c = territory.id,ZTS_EU_Employee__c = a.OwnerId);
        insert userTerritory;   
        //Test.startTest();
         Contract objCont = new Contract(); 
        objCont.Name = '2018 PC MZR Paras Contract';
        objCont.ZTS_US_Current_Tier__c = '2018 CAD MZR Bios $10k';
        objCont.RecordTypeId = RecordTypeIdContact;
        objCont.AccountId = objAccount.Id;  
         //added by Ramya
         Contract objCont2 = new Contract();        
        objCont2.Name = '2018 PC MZR Theras Contract';
        objCont2.ZTS_US_Current_Tier__c = '2018 CAD MZR Theras $20k';
        objCont2.RecordTypeId = RecordTypeIdContact;
        objCont2.AccountId = objAccount.Id; 
        Profile p = [SELECT Id,Name FROM Profile WHERE Name='Integration Profile']; 
        User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                          UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest', ZTS_EU_Market__c = 'United States'); 
        insert u;  
        List<Contract> conList3 = new List<Contract>();
        System.runAs(u) { 
            Profile p1 = [SELECT Id,Name FROM Profile WHERE Id= :UserInfo.getProfileId()]; 
            insert objCont;   
            insert objCont2;
            conList3.add(objCont); 
            conList3.add(objCont2); 
            ZTS_US_Contract_Utils.updateAccountContractDetails(conList3, null);
        }   
    }
    
    @isTest 
    static void mzrPricingCurrentTierUpdateTest(){
        ZTS_DataUtilityTest.activateTriggerSettings();
        Account objAccount = new Account();
        objAccount.Name = 'Test Account5';
        objAccount.ZTS_US_NARC_ID__c = '1234321';
        objAccount.ZTS_EU_Market__c = 'United States';   
        objAccount.BillingPostalCode = '12345';
        objAccount.BillingCity = 'Boca Raton';
        objAccount.BillingState = 'Florida';
        objAccount.BillingStreet = 'Elm Lane';     
        insert objAccount;
        Account a = new Account(Name = 'Account With Account Team',ZTS_US_Business_Class__c = 'Breeder',ZTS_EU_Account_Status__c = 'Pending', ZTS_EU_Market__c = 'United States');
        a.BillingPostalCode = '12345';
        a.BillingCity = 'Boca Raton';
        a.BillingState = 'Florida';
        a.BillingStreet = 'Elm Lane';
        a.ZTS_EU_Market__c = 'United States';
        Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Active_Contract').getRecordTypeId();
        List<Account> accountList = new List<Account>();
        accountList.add(a); 
        ZTS_EU_Territory__c territory = new ZTS_EU_Territory__c(Name = 'Test Territory',ZTS_US_Synced__c = true, ZTS_EU_Market__c = 'United States');
        insert territory;
        ZTS_EU_Position__c userTerritory = new ZTS_EU_Position__c(ZTS_EU_Territory__c = territory.id,ZTS_EU_Employee__c = a.OwnerId);
        insert userTerritory;   
        //Test.startTest();
        Contract objCont = new Contract(); 
        objCont.Name = '2019 EQ MZR PRICING';
        objCont.ZTS_US_Current_Tier__c = '2019 EQ MZR T5 TOPAZ';
        objCont.RecordTypeId = RecordTypeIdContact;
        objCont.AccountId = objAccount.Id;   
        objCont.StartDate = System.today();
        objCont.ContractTerm = 12;
        //added by ramya 
        Contract objCont2 = new Contract(); 
        objCont2.Name = '2019 LE Premier';
        objCont2.ZTS_US_Current_Tier__c = 'Premier';
        objCont2.RecordTypeId = RecordTypeIdContact;
        objCont2.AccountId = objAccount.Id;   
        objCont2.StartDate = System.today();
        objCont2.ContractTerm = 12;
        Contract objCont3 = new Contract(); 
        objCont3.Name = '2019 EQ MZR 1 PRICING';
        objCont3.ZTS_US_Current_Tier__c = '2019 EQ MZR T5 TOPAZ1';
        objCont3.RecordTypeId = RecordTypeIdContact;
        objCont3.AccountId = objAccount.Id;   
        objCont3.StartDate = System.today()-65;
        objCont3.ContractTerm = 1;
        //objCont.EndDate = Date.newInstance(2030, 12, 9);
        Profile p = [SELECT Id,Name FROM Profile WHERE Name='Integration Profile']; 
        User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                          UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest', ZTS_EU_Market__c = 'United States'); 
        insert u; 
        Test.startTest();  
        System.runAs(u) { 
            Profile p1 = [SELECT Id,Name FROM Profile WHERE Id= :UserInfo.getProfileId()]; 
            System.assertEquals(p1.Name,'Integration Profile');
            insert objCont;   
            insert objCont2;
            insert objCont3;
            objCont.ZTS_US_Current_Tier__c = 'T4 - Coral ($100,000 - $199,999)';
            objCont2.StartDate = System.today()+10;
            objCont3.StartDate = System.today()-64;
            update objCont2;
            update objCont; 
            update objCont3;
        }
        Test.stopTest();
        System.debug('CON0-->'+[SELECT Id, ZTS_US_Current_Tier__c FROM Contract]);
        Account act = [Select id,MZR_Tier__c from Account where id = :objCont.AccountId AND ZTS_EU_Market__c = 'United States' limit 1][0];
                System.assertEquals('T4 - Coral ($100,000 - $199,999)', act.MZR_Tier__c);
        
    }
 
     @isTest 
    static void mzrBiosPricingCurrentTierUpdateTest(){
        ZTS_DataUtilityTest.activateTriggerSettings();
        Account objAccount = new Account();
        objAccount.Name = 'Test Account5';
        objAccount.ZTS_US_NARC_ID__c = '1234321';
        objAccount.ZTS_EU_Market__c = 'United States';
        objAccount.BillingPostalCode = '12345';
        objAccount.BillingCity = 'Boca Raton';
        objAccount.BillingState = 'Florida';
        objAccount.BillingStreet = 'Elm Lane';
        insert objAccount;
        Account a = new Account(Name = 'Account With Account Team',ZTS_US_Business_Class__c = 'Breeder',ZTS_EU_Account_Status__c = 'Pending', ZTS_EU_Market__c = 'United States');
        a.BillingPostalCode = '12345';
        a.BillingCity = 'Boca Raton';
        a.BillingState = 'Florida';
        a.BillingStreet = 'Elm Lane';
        a.ZTS_EU_Market__c = 'United States';
        Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Active_Contract').getRecordTypeId();
        //List<Account> accountList = new List<Account>();
        //accountList.add(a); 
        ZTS_EU_Territory__c territory = new ZTS_EU_Territory__c(Name = 'Test Territory',ZTS_US_Synced__c = true, ZTS_EU_Market__c = 'United States');
        insert territory;
        ZTS_EU_Position__c userTerritory = new ZTS_EU_Position__c(ZTS_EU_Territory__c = territory.id,ZTS_EU_Employee__c = a.OwnerId);
        insert userTerritory;   
        //Test.startTest();
        Contract objCont = new Contract(); 
        objCont.Name = '2019 PC MZR Bios Pricing';
        objCont.ZTS_US_Current_Tier__c = '2019 PC MZR Bios $50K';
        objCont.RecordTypeId = RecordTypeIdContact;
        objCont.AccountId = objAccount.Id;   
        objCont.StartDate = System.today();
        objCont.ContractTerm = 12;
        //objCont.EndDate = Date.newInstance(2030, 12, 9);
        Profile p = [SELECT Id,Name FROM Profile WHERE Name='Integration Profile']; 
        User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                          UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest', ZTS_EU_Market__c = 'United States'); 
        insert u;   
        System.runAs(u) { 
            Profile p1 = [SELECT Id,Name FROM Profile WHERE Id= :UserInfo.getProfileId()]; 
            Test.startTest();
            insert objCont;   
            objCont.ZTS_US_Current_Tier__c = '2019 PC MZR Bios $80K';
            system.debug('$$$ objCont: '+objCont);
            System.debug('$$$ before update call');
            update objCont; 
            Test.stopTest();
        }
        System.debug('$$$ queried back '+[SELECT Id, ZTS_US_Current_Tier__c FROM Contract]); 
        Account act = [Select id,ZTS_US_MVP_BIOS__c from Account where id = :objCont.AccountId AND ZTS_EU_Market__c = 'United States'][0];
        System.assertEquals('$80,000', act.ZTS_US_MVP_BIOS__c);
    }
              }