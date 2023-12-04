/*******************************************************************************************************************************************
* File Name     :  ZTS_US_ContactAffiliation_UpdateTest
* Description   :  Test class for ZTS_US_ContactAffiliation_Update
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/16         Akanksha          Created the Class.
***************************************************************************************************************/
@isTest(SeeAllData=false)
public class ZTS_US_ContactAffiliation_UpdateTest{
    static testMethod void validate_UpdateContactAffilation(){
        
        List<Account> accListnew = ZTS_DataUtilityTest.createAccountRecord(1,79);
        for (Account acc : acclistNew) acc.ZTS_EU_Market__c = 'United States';
        insert accListnew ;
        Map<Id,Account>newaccmap= new Map<Id,Account>();
        newaccmap.put(accListnew[0].Id,accListnew[0]);
        List<Account> accListold = ZTS_DataUtilityTest.createAccountRecord(1,54);
        for(Account acc : accListold) acc.ZTS_EU_Market__c = 'United States';
        insert accListold ;
        Map<Id,Account>oldaccmap= new Map<Id,Account>();
        oldaccmap.put(accListold[0].Id,accListold[0]);
        Account testAccount = new Account();
        testAccount.ZTS_EU_Account_Status__c = 'Active';
        testAccount.Name='Test Account' ;
        testAccount.ZTS_EU_Market__c = 'United States';
        testAccount.BillingPostalCode = '00000';
        testAccount.BillingCity = 'testCity';
        testAccount.BillingState = 'testState';
        testAccount.BillingStreet = 'testStreet';
        testAccount.ZTS_EU_Market__c = 'United States';
        insert testAccount;

        List <Contact> contListold= new List <Contact>();
        Contact conold=new Contact(AccountId= testAccount.Id,
                                    firstname='Test First1',
                                    lastname = 'Test Contact1',
                                    ZTS_US_Account_influence__c='Decision Maker',
                                    ZTS_EU_Profession__c='Executive Leadership',
                                    ZTS_Job_Function__c='CFO',
                                    ZTS_EU_Contact_Status__c='Pending', 
                                    ZTS_US_LE_Contact__c = 'Primary', 
                                    ZTS_US_Profit_Solver_Contact__c = true,
                                    ZTS_EU_Market__c = 'United States',
                                    ZTS_US_Profession__c = 'Executive Leadership',
                                    ZTS_US_Job_Function__c = 'CEO/President'
                                );
        
        contListold.add(conold);
        insert contListold;
            List<ZTS_EU_Affiliations__c> Accconaffrecord = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
            List<ZTS_EU_Affiliations__c> Accconaffrecordlst = new List<ZTS_EU_Affiliations__c>();
            for(ZTS_EU_Affiliations__c acconaff : Accconaffrecord){
            //  acconaff.ZTS_US_Account__c = accListold[0].id;
                acconaff.ZTS_EU_Account__c = testAccount.Id;
                acconaff.ZTS_EU_Contact__c = contListold[0].id;
                acconaff.ZTS_EU_Affiliation_Status__c = 'Active';
                acconaff.ZTS_EU_Account_influence__c = 'Key Decision Maker';
                acconaff.ZTS_US_Profession__c='Executive Leadership';
                acconaff.Profit_Solver_Contact__c=False;
                acconaff.ZTS_US_Job_Function__c='CEO/President';

                //acconaff.ZTS_US_LE_Contact__c=False;
                
                Accconaffrecordlst.add(acconaff);
            }
            //insert Accconaffrecordlst;
        
        List <Contact> contListnewUpd= new List <Contact>();
        
        
        Map<Id,Contact> oldMap = new Map<Id, Contact>([SELECT Id, firstname, lastname, ZTS_US_Account_influence__c, ZTS_EU_Profession__c, 
        ZTS_Job_Function__c, ZTS_EU_Contact_Status__c, ZTS_US_LE_Contact__c, ZTS_US_Profit_Solver_Contact__c FROM Contact
        WHERE Id = :contListold[0].Id]);
        
        /*Map<Id,Contact> oldMap=new Map<Id,Contact>();
        oldMap.put(contListnew[0].Id,contListnew[0]);*/
        conold.ZTS_US_Account_influence__c='Not defined';
        conold.ZTS_EU_Profession__c='Dealer';
        conold.ZTS_EU_Contact_Status__c = 'Inactive';
        conold.ZTS_EU_Profession__c='Communications';
        conold.ZTS_Job_Function__c ='Pharmacist';
        contListnewUpd.add(conold);
        
        update contListnewUpd;
        
        Map<Id,Contact> newMap = new Map<Id, Contact>([SELECT Id, firstname, lastname, ZTS_US_Account_influence__c, ZTS_EU_Profession__c, 
        ZTS_Job_Function__c, ZTS_EU_Contact_Status__c, ZTS_US_LE_Contact__c, ZTS_US_Profit_Solver_Contact__c, ZTS_US_Profession__c, ZTS_US_Job_Function__c FROM Contact
        WHERE Id = :contListnewUpd[0].Id]);
        
        /*Map<Id,Contact> newMap=new Map<Id,Contact>();
        newMap.put(contListnewUpd[0].Id,contListnewUpd[0]);*/
          
        
       List <Account> AccListolds= new List <Account>();
        Account Accold=new Account(	Name='Demo1',ZTS_EU_Address_Line_1__c ='test1',ZTS_EU_Account_Status__c='Pending',
        ZTS_US_Buying_Class__c='PROSPECT',ZFS_Status__c='Member',ZTS_EU_Country__c='US',ZTS_US_NARC_ID__c='0000000000',BillingPostalCode = '00000',
		BillingCity = 'testCity',BillingState = 'testState',BillingStreet = 'testStreet', ZTS_EU_Zip_Postal_Code__c = '22335', ZTS_EU_Market__c = 'United States');
        AccListolds.add(Accold);
        insert AccListolds;
        
       List<Account> Acc1 =  ZTS_DataUtilityTest.createAccountRecord(1,1);
       for(Account acc : acc1) acc.ZTS_EU_Market__c = 'United States';
       insert Acc1;
        Map<Id,Account> oldAccMaps = new Map<Id, Account>([SELECT Id,Name,ZTS_EU_Address_Line_1__c,ZTS_EU_Account_Status__c,
        ZTS_US_Buying_Class__c,ZFS_Status__c,ZTS_EU_Country__c FROM Account
        WHERE Id = :AccListolds[0].Id]);
         List <Account> AccListnewUpd= new List <Account>();
         Accold.ZTS_EU_Account_Status__c = 'Inactive';
        Accold.ZTS_US_InactiveReason__c = 'testReason';
        AccListnewUpd.add(Accold);
        update AccListnewUpd;
        system.debug('checkabc-->'+AccListnewUpd);
        
        Map<Id,Account> newAccMaps = new Map<Id, Account>([SELECT Id,Name,ZTS_EU_Address_Line_1__c,ZTS_EU_Account_Status__c,
        ZTS_US_Buying_Class__c,ZFS_Status__c,ZTS_EU_Country__c FROM Account
        WHERE Id = :AccListnewUpd[0].Id]);
        
        
        
        Test.startTest();
        /*contListnew[0].ZTS_EU_Profession__c = 'Veterinarian';
        contListnew[0].ZTS_Job_Function__c = 'Intern';*/
        
        List<ZTS_EU_Account_Affiliations__c> Accaf = ZTS_DataUtilityTest.createAccAffiliationRecord(1);
        for(ZTS_EU_Account_Affiliations__c Acaf : Accaf){
            Acaf.ZTS_EU_Account__c = Acc1[0].Id;	
            Acaf.ZTS_EU_Affiliated_Account__c = AccListolds[0].Id;   
        }
        insert Accaf;
        
        ZTS_US_ContactAffiliation_Update.prepopulateAccountAddrInfo(contListold);
        system.debug('stuq-------->'+contListnewUpd);
         ZTS_US_ContactAffiliation_Update.UpdateContactAffilation(contListnewUpd,contListold,newMap,oldMap);
        ZTS_US_ContactAffiliation_Update.createAccountContactAffiliationRecord(contListold);
      
        ZTS_US_ContactAffiliation_Update.updateAccountAffiliation(AccListolds,newAccMaps,oldAccMaps);
        
        ZTS_US_ContactAffiliation_Update.populateAccContactAffPositions(Accconaffrecordlst);
        Test.stopTest();
    }
}