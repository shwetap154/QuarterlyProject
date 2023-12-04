@isTest
public class ZTS_US_AllContractTrigger_Test{
    public static List<Contract> contrList = new List<Contract>();
    public static Map<ID,Contract> mapContrIdCon = new Map<ID,Contract>();
    
    public static void createTestData1(){
        contrList = ZTS_DataUtilityTest.createContractRecord(1);
        contrList[0].RecordTypeId = System.Label.ZTS_US_Contract_Record_Type_Id_for_Contract_Renewal;
        contrList[0].ZTS_US_Field_Proposed_Tier__c = 'Elite';
        contrList[0].ZTS_US_Review_Committee_Proposed_Tier__c = 'Elite';
        contrList[0].ZTS_US_End_Date_Interface__c = system.today();
        contrList[0].Status = 'TM Resubmit';
        contrList[0].ZTS_US_Approval_Status__c = 'Pending';
        contrList[0].ZTS_US_Diff_Proposed_Current__c = -1.0;
        contrList[0].RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Tier_Change').getRecordTypeId();
        contrList[0].ZTS_US_Submitter_Comments__c = 'Test';
        contrList[0].ZTS_US_Submitted_for_Approval__c = true;
        contrList[0].StartDate =system.today();
        //contrList[0].EndDate = system.today()+1; field not writeable
         
        insert contrList;
    }
   
    static testmethod void updateAccountContractDetailsTest(){
        User usr2 = new User();
        usr2 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr2.FirstName = 'intlUser2';
        usr2.LastName = 'intlUserLast2';
        usr2.zts_eu_market__c = 'United Kingdom';
        insert usr2;
       
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        usr.ManagerID = usr2.Id;
        insert usr;

        System.runAs(usr)
        {
            Test.StartTest();
                Account objAccount = new Account();
                List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(1);
                objAccount = acclist[0];
                objAccount.ZTS_EU_Market__c = 'United Kingdom';
                objAccount.Name = 'Test Account';
                objAccount.ZTS_US_NARC_ID__c = '7778787';
                objAccount.ZTS_US_Contract_Tier__c='Elite';
                objAccount.ZTS_US_VGP_Enrollment_Status__c = 'VGP Enrolled';
                objAccount.VGP_Enrollment_Date__c=system.today();
                objAccount.VGP_End_Date__c=system.today()+1;
                objAccount.MZR_Status__c = 'Active';
                insert objAccount;
                objAccount.LE_End_Date__c = system.today();
                update objAccount;
                
                Contract objContract = new Contract();
                Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('MVP_Proposal').getRecordTypeId();
                objContract.Name = '2018 CAD MZR Bios Pricing';
                objContract.ZTS_US_Current_Tier__c = 'Elite';
                objContract.RecordTypeId = RecordTypeIdContact;
                objContract.AccountId = objAccount.Id;
                objContract.ZTS_US_Leaders_Edge__c = true; 
            	objContract.ZTS_US_BIOs_Field_Proposed_Tier__c = '7,500';
                Profile p = [SELECT Id FROM Profile WHERE Name='Integration profile'];
                User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com', ZTS_EU_Market__c = 'United Kingdom',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                                UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest'); 
            	u.ManagerID = usr2.Id;
                insert u; 
                System.runAs(u) { 
                    Profile p1 = [SELECT Id,Name FROM Profile WHERE Id= :UserInfo.getProfileId()];
                    System.debug('Current Profile in TEST: ' + p1.Name);
                    insert objContract; 
                    objContract.Status = 'MZR PARAs Terms and Conditions Accepted';
                    objContract.ZTS_US_End_Date_Interface__c = system.today()+1;
                    update objContract;
                }  
                List<Contract> conList = new List<Contract>();
                conList.add(objContract);
                ZTS_US_Contract_Utils.updateAccountContractDetails(conList, null);
                ZTS_US_Contract_Utils.submitForApproval(contrList,mapContrIdCon);
                
                List<Contract> conList2 = new List<Contract>();
                Map<ID,Contract> mapContrIdCon = new Map<ID,Contract>();
                        
                for(Contract c : contrList){
                    mapContrIdCon.put(c.Id,c);    
                }
                Test.StopTest();
                ZTS_US_Contract_Utils.populateTerritoryOnContract(conList2);
                ZTS_US_Contract_Utils.submitForApproval(contrList,mapContrIdCon);
                ZTS_US_Contract_Utils.updateAccountContractDetails(conList2,null);     
            }
    }
    
    static testmethod void updateAccountContractDetailsTest1(){
       	User usr2 = new User();
        usr2 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr2.FirstName = 'intlUser2';
        usr2.LastName = 'intlUserLast2';
        usr2.zts_eu_market__c = 'United Kingdom';
        insert usr2;

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        usr.ManagerID = usr2.Id;
        insert usr;

        System.runAs(usr)
        {
            Test.StartTest();
                Account objAccount = new Account();
                List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(1);
                objAccount = acclist[0];
                objAccount.ZTS_EU_Market__c = 'United Kingdom';
                objAccount.Name = 'Test Account';
                objAccount.ZTS_US_NARC_ID__c = '777874487';
                objAccount.MZR_Status__c = 'Not Eligible';
                objAccount.MZR_Accepted_Declined_Date__c = null;
                objAccount.MZR_Enrollment_Start_Date__c = null;
                objAccount.MZR_Enrollment_Date__c = null;
                objAccount.MZR_Account__c = false;

                insert objAccount;
                
                Contract objContract = new Contract();
                Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('MZR_PARAS_Proposal').getRecordTypeId();
                objContract.Name = 'CAD MZR PC PARA Pricing';
                objContract.ZTS_US_Current_Tier__c = 'Elite';
                objContract.RecordTypeId = RecordTypeIdContact;
                objContract.AccountId = objAccount.Id;
            	objContract.PetCare_MZR_PARAS_Field_Proposed_Tier__c = '75,000';
                
                //objContract.Status = 'Active';
                objContract.ZTS_US_Leaders_Edge__c = true; 
                Profile p = [SELECT Id FROM Profile WHERE Name='Integration profile'];
                User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com', ZTS_EU_Market__c = 'United Kingdom',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                                UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest'); 
            	u.ManagerID = usr2.Id;
                insert u; 
                System.runAs(u) { 
                    Profile p1 = [SELECT Id,Name FROM Profile WHERE Id= :UserInfo.getProfileId()];
                    System.debug('Current Profile in TEST: ' + p1.Name);
                    insert objContract; 
                    objContract.Status = 'Active';
                    objContract.Status = 'MZR PARAs Terms and Conditions Accepted';
                    objContract.ZTS_US_End_Date_Interface__c = system.today()+1;
                    update objContract;
                }  
                List<Contract> conList = new List<Contract>();
                conList.add(objContract);
                ZTS_US_Contract_Utils.updateAccountContractDetails(conList, null);
                ZTS_US_Contract_Utils.submitForApproval(contrList,mapContrIdCon);
            
                List<Contract> conList12 = new List<Contract>();
                Map<ID,Contract> mapContrIdCon = new Map<ID,Contract>();
                
                for(Contract c : contrList){
                    mapContrIdCon.put(c.Id,c);    
                }
                Test.StopTest();
                ZTS_US_Contract_Utils.populateTerritoryOnContract(conList12);
                ZTS_US_Contract_Utils.submitForApproval(contrList,mapContrIdCon);
                ZTS_US_Contract_Utils.updateAccountContractDetails(conList12,null);     
            }
    }
    
    static testmethod void updateAccountContractDetailsTest2(){
       	User usr2 = new User();
        usr2 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr2.FirstName = 'intlUser2';
        usr2.LastName = 'intlUserLast2';
        usr2.zts_eu_market__c = 'United Kingdom';
        insert usr2;

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        usr.ManagerID = usr2.Id;
        insert usr;

        System.runAs(usr)
        {  
            Test.startTest();
            Account objAccount = new Account();
            List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            objAccount = acclist[0];
            objAccount.ZTS_EU_Market__c = 'United Kingdom';
            objAccount.Name = 'Test Account';
            objAccount.ZTS_US_NARC_ID__c = '777874487';
            objAccount.MZR_Status__c = 'Eligible';
            
            insert objAccount;
            
            Contract objContract = new Contract();
            Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('MVP_Proposal').getRecordTypeId();
            objContract.Name = '2018 MZR Pricing';
            objContract.ZTS_US_Current_Tier__c = 'Elite';
            objContract.RecordTypeId = RecordTypeIdContact;
            objContract.AccountId = objAccount.Id;
            objContract.ZTS_US_Leaders_Edge__c = true; 
            objContract.ZTS_US_BIOs_Field_Proposed_Tier__c = '7,500';
            Profile p = [SELECT Id FROM Profile WHERE Name='Integration profile'];
            User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com', ZTS_EU_Market__c = 'United Kingdom',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                            UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest'); 
            u.ManagerID = usr2.Id;
            insert u; 
            System.runAs(u) { 
                Profile p1 = [SELECT Id,Name FROM Profile WHERE Id= :UserInfo.getProfileId()];
                System.debug('Current Profile in TEST: ' + p1.Name);
                insert objContract; 
                objContract.Status = 'Active';
                objContract.Status = 'MZR PARAs Terms and Conditions Accepted';
                objContract.ZTS_US_End_Date_Interface__c = system.today()+1;
                update objContract;
            }  
            List<Contract> conList = new List<Contract>();
            conList.add(objContract);
            ZTS_US_Contract_Utils.updateAccountContractDetails(conList, null);
            ZTS_US_Contract_Utils.submitForApproval(contrList,mapContrIdCon);
        
            List<Contract> conList12 = new List<Contract>();
            Map<ID,Contract> mapContrIdCon = new Map<ID,Contract>();
                
            for(Contract c : contrList){
                mapContrIdCon.put(c.Id,c);    
            }
            Test.StopTest();
            ZTS_US_Contract_Utils.populateTerritoryOnContract(conList12);
            ZTS_US_Contract_Utils.submitForApproval(contrList,mapContrIdCon);
            ZTS_US_Contract_Utils.updateAccountContractDetails(conList12,null);     
        }
    }
    
    static testmethod void updateAccountContractDetailsTest3(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            Test.StartTest();      
                Account objAccount = new Account();
                List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(1);
                objAccount = acclist[0];
                objAccount.ZTS_EU_Market__c = 'United Kingdom';
                objAccount.Name = 'Test Account';
                objAccount.ZTS_US_NARC_ID__c = '777874487';
                objAccount.MZR_Status__c = 'Not Eligible';
                objAccount.ZTS_US_VGP_Enrollment_Status__c = 'VGP Enrolled';
                objAccount.VGP_Enrollment_Date__c= system.today();
                objAccount.VGP_End_Date__c=system.today()+1;
                insert objAccount;
                
                Contract objContract = new Contract();
                Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Contract_Read_Only').getRecordTypeId();
                objContract.Name = 'CAD - Strategic';
                objContract.ZTS_US_Current_Tier__c = 'Elite';
                objContract.RecordTypeId = RecordTypeIdContact;
                objContract.AccountId = objAccount.Id;
                objContract.ZTS_US_Leaders_Edge__c = true; 
                
                Profile p = [SELECT Id FROM Profile WHERE Name='Integration profile'];
                User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com', ZTS_EU_Market__c = 'United Kingdom',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                                UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest'); 
                insert u; 
                System.runAs(u) { 
                    Profile p1 = [SELECT Id,Name FROM Profile WHERE Id= :UserInfo.getProfileId()];
                    System.debug('Current Profile in TEST: ' + p1.Name);
                    insert objContract; 
                    objContract.Status = 'Active';
                    objContract.Status = 'MZR PARAs Terms and Conditions Accepted';
                    objContract.ZTS_US_End_Date_Interface__c = system.today()-1;
                    update objContract;
                } 
                List<Contract> conList = new List<Contract>();
                conList.add(objContract);
                ZTS_US_Contract_Utils.updateAccountContractDetails(conList, null);
                ZTS_US_Contract_Utils.submitForApproval(contrList,mapContrIdCon);
                
                List<Contract> conList12 = new List<Contract>();
                Map<ID,Contract> mapContrIdCon = new Map<ID,Contract>();
                
                for(Contract c : contrList){
                    mapContrIdCon.put(c.Id,c);    
                }
                Test.StopTest();
                ZTS_US_Contract_Utils.populateTerritoryOnContract(conList12);
                ZTS_US_Contract_Utils.submitForApproval(contrList,mapContrIdCon);
                ZTS_US_Contract_Utils.updateAccountContractDetails(conList12,null);     
            }
    }
    
    //Added on 12042018
    
    static testmethod void updateAccountContractDetailsTest4(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            Test.StartTest();      
                Account objAccount = new Account();
                List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(1);
                objAccount = acclist[0];
                objAccount.ZTS_EU_Market__c = 'United Kingdom';
                objAccount.Name = 'Test Account';
                objAccount.ZTS_US_NARC_ID__c = '777874487';
                objAccount.MZR_Status__c = null;
                objAccount.ZTS_US_VGP_Enrollment_Status__c = 'VGP Enrolled';
                objAccount.ZTS_US_Contract_Tier__c='Elite';
                objAccount.VGP_Enrollment_Date__c= system.today();
                objAccount.VGP_End_Date__c=system.today()+1;
                insert objAccount;
                
                Contract objContract = new Contract();
                Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Contract_Read_Only').getRecordTypeId();
                objContract.Name = 'LE';
                objContract.ZTS_US_Current_Tier__c = 'Premier';
                objContract.RecordTypeId = RecordTypeIdContact;
                objContract.AccountId = objAccount.Id;
                objContract.ZTS_US_Leaders_Edge__c = true;
                //objContract.EndDate = system.today()+10; field not writeable
                
                Profile p = [SELECT Id FROM Profile WHERE Name='Integration profile'];
                User u = new User(Alias = 'suser', Email='shivashankar.kudikilla@cognizant.com', ZTS_EU_Market__c = 'United Kingdom',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York',
                                UserName='shivashankar.kudikilla@cognizant.com.skintegrationprofiletest'); 
                insert u; 
                System.runAs(u) { 
                    Profile p1 = [SELECT Id,Name FROM Profile WHERE Id= :UserInfo.getProfileId()];
                    System.debug('Current Profile in TEST: ' + p1.Name);
                    insert objContract; 
                    objContract.Status = 'Active';
                    objContract.Status = 'MZR PARAs Terms and Conditions Accepted';
                    objContract.ZTS_US_End_Date_Interface__c = system.today()-1;
                    update objContract;
                } 
                List<Contract> conList = new List<Contract>();
                conList.add(objContract);
                ZTS_US_Contract_Utils.updateAccountContractDetails(conList, null);
                ZTS_US_Contract_Utils.submitForApproval(contrList,mapContrIdCon);
                
                List<Contract> conList12 = new List<Contract>();
                Map<ID,Contract> mapContrIdCon = new Map<ID,Contract>();
                
                for(Contract c : contrList){
                    mapContrIdCon.put(c.Id,c);    
                }
                Test.StopTest();
                ZTS_US_Contract_Utils.populateTerritoryOnContract(conList12);
                ZTS_US_Contract_Utils.submitForApproval(contrList,mapContrIdCon);
                ZTS_US_Contract_Utils.updateAccountContractDetails(conList12,null);     
            }
    }
}