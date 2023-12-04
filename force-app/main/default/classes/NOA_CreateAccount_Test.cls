/**********************************************************************************************************************************************
* Name   : NOA_CreateAccount_Test
* Description  : This is the Test class for NOA_CreateAccount
* Created By   : Oeeshi Roy Choudhury
* Created Date : April 03, 2017 
***********************************************************************************************************************************************/

@isTest(SeeAllData=False)
public class NOA_CreateAccount_Test {
    
    public static Lead l;
    
    public static Account acc1;
    public static Veterinarian_Information__c vt;
    public static Veterinarian_Information__c vt1;
    
    
    static void test()
    {
        Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Licensed_Vet').getRecordTypeId();
        
        l=new Lead(Salutation='Mr.',Company='xyz',Email='a@a.com',Phone='123',FirstName='Test_1',LastName='test_l',Business_Name__c='Cognizant',Customer_Type__c='Vet Practice',
                   Small_Animal__c=8, Equine__c=6,Beef__c=6,Dairy__c=4,Swine__c=9,Feed__c=4,Poultry__c=5,Eggs__c=4,Turkey__c=7,Broiler__c=12, Shipping_Street_1__c='shipStreet1',Shipping_Street_2__c='shipStreet2',
                   Shipping_County__c='India',Shipping_City__c='Kol',Shipping_State__c='WB',Shipping_Zip_Code__c='45586',Shipping_Phone__c='678899',Shipping_Fax__c='899345',Shipping_Email__c='shipEmail@test.com',
                   Billing_Street_1__c='test_st1',Billing_Street_2__c='test_st2',Billing_County__c='India',Billing_City__c='Kol',Billing_State__c='WB',Billing_Zip_Code__c='45586',Billing_Phone__c='678899',Billing_Fax__c='899345',
                   Billing_Email__c='shipEmail@test.com',Existing_account_with_Zoetis_at_this_Loc__c='No',Authorization_Email__c='abc@test.com',Ownership_Change__c='No',Existing_account_with_Zoetis__c='Yes',
                   Zoetis_Account__c='HINMDW41AAF3',Existing_Account_Name__c='Test_Account1',Sales_Tax_Status__c ='Charge tax',RecordTypeID = recTypeId,Type_of_Business__c='Diagnostic Laboratory', Specialty_Description__c = 'Feline');
        insert l;
        
        acc1=new Account(Name='Test_Account1',BillingStreet='test_st1', BillingCity='test_city',BillingCountry='United States',BillingState='TX',BillingPostalCode='ert',ZFS_Status__c='Member');
        insert acc1;
        
        
        
        
        system.debug('account id match-->'+acc1.Id);
        system.debug('account name match-->'+acc1.Name);
        
        
        List<Account> acList=new List<Account>();
        acList.add(acc1);
        
        State_Country__c sc = new State_Country__c();
        sc.Name = 'Sachsen';
        sc.ZTS_EU_Country__c = 'Country1';
        insert sc;
        
        Address__c adrs=new Address__c(ZTS_EU_Account__c=acc1.Id,ZTS_EU_Address_Type__c='Primary',ZTS_US_Address_Identifier__c = 'HINMDW41AAF3',
                                       ZTS_Address_Line_1__c='test_st1', ZTS_EU_City__c = 'Kol',ZTS_US_State_Province__c='WB',ZTS_EU_State_County__c = sc.Id, 
                                       Zip_Postal_Code__c = '45586', ZTS_EU_Country__c = 'Country1');
        insert adrs;
        
        Contact c1=new Contact(AccountId=acc1.id,FirstName='Test_1',LastName='test_l',Interface_Email__c='test@abc.com',Phone='123',ZTS_US_Profession__c='Veterinarian',ZTS_US_Job_Function__c='Associate Vet');
        insert c1; 
        //ZTS_EU_Affiliations__c nac=new ZTS_EU_Affiliations__c(Name='Test_1 Test_2@Test_Account1',ZTS_EU_Account__c=acc1.Id, ZTS_EU_Contact__c=c1.Id, ZTS_US_Job_Function__c='Associate Vet');
        //insert nac;  
        
        vt1=new Veterinarian_Information__c(Lead__c=l.Id,Veterinarian_First_Name__c='Test_1',Veterinarian_Last_Name__c='test_l',Veterinarian_Email__c='test@abc.com',Delete_Record__c=false,Veterinarian_Role__c='Owner');
        insert vt1;
        
        
    }
    
    
    static testmethod void testforCreateNewAccount()
    {
        test(); 
        PageReference pageRef1 = Page.NOA_CreateAccount;
        Test.setCurrentPage(pageRef1);
        ApexPages.StandardController sc4 = new ApexPages.standardController(l);
        NOA_CreateAccount ob3=new NOA_CreateAccount(sc4);
        Account newAcc = new Account(Name='Test_Account1',BillingStreet='test_st1', BillingCity='test_city',BillingCountry='United States',BillingState='TX',BillingPostalCode='ert');
        Database.DMLOptions dml = new Database.DMLOptions(); 
 		dml.DuplicateRuleHeader.allowSave = true;
 		dml.DuplicateRuleHeader.runAsCurrentUser = true;
		Database.SaveResult sr = Database.insert(newAcc,dml);
        //Insert newAcc;
        List<Account> accList = [Select Name,BillingStreet,BillingCity,BillingCountry,BillingState,BillingPostalCode from Account where BillingStreet='test_st1' AND ZTS_EU_Market__c = 'United States'];
        for (Account a : accList){
            ob3.newAcc.Name = a.Name;
            ob3.newAcc.BillingStreet = a.BillingStreet;
            ob3.newAcc.BillingCity = a.BillingCity;
            ob3.newAcc.BillingState = a.BillingState;
            ob3.newAcc.BillingPostalCode = a.BillingPostalCode;
        }
        ob3.createNewAccount();
    }
    
    static testmethod void testforCreateNewAccountException()
    {
        test();
        PageReference pageRef1 = Page.NOA_CreateAccount;
        Test.setCurrentPage(pageRef1);
        ApexPages.StandardController sc4 = new ApexPages.standardController(l);
        NOA_CreateAccount ob3=new NOA_CreateAccount(sc4);
        ob3.newAcc.Name = 'test';
        ob3.newAcc.BillingStreet = 'test1';
        ob3.newAcc.BillingCity = 'test2';
        ob3.newAcc.BillingState = 'test_state';
        ob3.newAcc.BillingPostalCode = 'test4';
        ob3.createNewAccount();
        
        Account acnt=new Account(Name='test_a',BillingStreet='test_b', BillingCity='test_c',BillingPostalCode='test_pc', BillingCountry='United States',BillingState='TX');
        insert acnt;
        PageReference pageRef2 = Page.NOA_CreateAccount;
        Test.setCurrentPage(pageRef2);
        ApexPages.StandardController sc_new = new ApexPages.standardController(l);
        NOA_CreateAccount test_ob=new NOA_CreateAccount(sc_new); 
        test_ob.createNewAccount(); 
    }
    
    static void init()
    {
        Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Licensed_Vet').getRecordTypeId();
        
        
        
        l=new Lead(Salutation='Mr.',Company='xyz',Email='a@a.com',Phone='123',FirstName='Test_1',LastName='test_l',Business_Name__c='Cognizant',Customer_Type__c='Vet Practice',
                   Small_Animal__c=8, Equine__c=6,Beef__c=6,Dairy__c=4,Swine__c=9,Feed__c=4,Poultry__c=5,Eggs__c=4,Turkey__c=7,Broiler__c=12, Shipping_Street_1__c='shipStreet1',Shipping_Street_2__c='shipStreet2',
                   Shipping_County__c='India',Shipping_City__c='Kol',Shipping_State__c='WB',Shipping_Zip_Code__c='45586',Shipping_Phone__c='678899',Shipping_Fax__c='899345',Shipping_Email__c='shipEmail@test.com',
                   Billing_Street_1__c='test_st1',Billing_Street_2__c='test_st2',Billing_County__c='India',Billing_City__c='Kol',Billing_State__c='WB',CLG_State__c='test',Billing_Zip_Code__c='45586',Billing_Phone__c='678899',Billing_Fax__c='899345',
                   Billing_Email__c='shipEmail@test.com',Existing_account_with_Zoetis_at_this_Loc__c='Yes',Existing_Account_Name__c='Test_Account1',Authorization_Email__c='abc@test.com',Ownership_Change__c='No',Existing_account_with_Zoetis__c='Yes',
                   Zoetis_Account__c='HINMDW41AAF3',Sales_Tax_Status__c ='Charge tax',isNewAccCreatedFlag__c=false,RecordTypeID = recTypeId);
        insert l;
        
        acc1=new Account(Name='Test_Account1',BillingStreet='test_st1', BillingCity='test_city',BillingCountry='United States',BillingState='TX',BillingPostalCode='ert');
        insert acc1;
        
        
        
        system.debug('account id match for submit-->'+acc1.Id);
        system.debug('account name match for submit-->'+acc1.Name);
        
        
        List<Account> acList=new List<Account>();
        acList.add(acc1);
        
        
        vt=new Veterinarian_Information__c(Lead__c=l.Id,Veterinarian_First_Name__c='VetTest2',Veterinarian_Last_Name__c='VetLast1',Veterinarian_Email__c='vtTest@test.com',Delete_Record__c=true);
        insert vt;
        
        vt1=new Veterinarian_Information__c(Lead__c=l.Id,Veterinarian_First_Name__c='VetTest2',Veterinarian_Last_Name__c='VetLast1',Veterinarian_Email__c='vtTest@test.com',Delete_Record__c=false,Veterinarian_Role__c='Owner');
        insert vt1;
        
        system.debug('Vet delete record--->'+vt.Delete_Record__c);
        
    }
    
    static testmethod void testforSubmit()
    {
        test();
        
        PageReference pageRef = Page.NOA_CreateAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc2 = new ApexPages.standardController(l);
        NOA_CreateAccount ob1=new NOA_CreateAccount(sc2); 
        ob1.submit();
        
        
    }
    
    
    
    static testmethod void testforManageVetContacts()
    {
        
        init();
        test.startTest();
        
        
        ApexPages.StandardController sc1 = new ApexPages.standardController(l);
        NOA_CreateAccount obj=new NOA_CreateAccount(sc1);
        
        obj.manageContact(acc1);
        obj.manageVetContacts(acc1);
        obj.selectedAccId=acc1.id;
        obj.submit();
        test.stopTest();
        
    }
    
    static testmethod void testForDuplicateVetContacts()
        
    {
        test(); 
       /* Contact newCon=new Contact(AccountId=acc1.id,FirstName='Con_Fname',LastName='Con_Lname',Interface_Email__c='con@gmail.com',Phone='12345',ZTS_US_Profession__c='Staff',ZTS_US_Job_Function__c='Owner');
        insert newCon;
        vt1=new Veterinarian_Information__c(Lead__c=l.Id,Veterinarian_First_Name__c='Con_Fname',Veterinarian_Last_Name__c='Con_Lname',Veterinarian_Email__c='con@gmail.com');
        insert vt1; 
        List<Veterinarian_Information__c> vt2=new List<Veterinarian_Information__c>();
        vt2.add(vt1);*/
        
        
       /* system.debug('Contact Firstname check'+newCon.FirstName);
        system.debug('Contact lastname check'+newCon.LastName);
        system.debug('Contact email check'+newCon.Email);
        system.debug('Vet Firstname check'+vt1.Veterinarian_First_Name__c);
        system.debug('vet lastname check'+vt1.Veterinarian_Last_Name__c);
        system.debug('vet email check'+vt1.Veterinarian_Email__c);
        system.debug('Vet delete record'+vt1.Delete_Record__c); */
        
        PageReference pageReff = Page.NOA_CreateAccount;
        Test.setCurrentPage(pageReff);
        ApexPages.StandardController std = new ApexPages.standardController(l);
        NOA_CreateAccount ob3=new NOA_CreateAccount(std);
        
        ob3.manageVetContacts(acc1);
        
    }
    
    static testmethod void testCreateBusinessClassMap()
    {
        test();
        PageReference pageRef1 = Page.NOA_CreateAccount;
        Test.setCurrentPage(pageRef1);
        ApexPages.StandardController std = new ApexPages.standardController(l);
        NOA_CreateAccount ob=new NOA_CreateAccount(std);
        
        ob.createBusinessClassMap();
        
        
        
    }
    
}