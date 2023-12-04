/**********************************************************************************************************************************************
* Name   : ZFS_CreateAccount_Test
* Description  : This is the Test class for ZFS_CreateAccount
* Created By   : Oeeshi Roy Choudhury
* Created Date : Jan 03, 2017 
***********************************************************************************************************************************************
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0    4/12/2022      Aritra          Updated the Class.
***********************************************************************************************************************************************/
@isTest(seealldata=False)
public class ZFS_CreateAccount_Test {
    public static Lead l;
    
    
    
    static void init(){
        l = new Lead(Salutation = 'Mr.',FirstName = 'Test_F',LastName = 'Test_L',Email='a@a.com',Phone='123',
                     Shelter_Name__c = 'Test Shelter',Shelter_Website__c = 'www.test.com',Status = 'Open',Company='Shelter',
                     Type_of_Organization__c = 'Private Shelter (brick & mortar facility)',Do_you_currently_purchase_from_Zoetis__c = 'Yes',Shelter_Account_Name__c = 'Test',
                     annual_cat_dog__c = 'Yes',Existing_account_with_Zoetis__c = 'Yes', How_did_you_hear_about_us2__c = 'Zoetis Website',Do_you_have_a_licensed_veterinarian__c='Yes',
                     Account_Prefix__c = 'Mr.',Account_First_Name__c = 'Test_ACC_F',Account_Last_Name__c = 'Test_ACC_L',
                     Account_Location__c='Test_Loc',Zoetis_Account__c='test123z',Contact_Prefix__c = 'Mr.',Contact_Phone__c='655',
                     Contact_Email__c = 'ab@test.com',Contact_Fax__c = '546213',Billing_Street_1__c = 'B_ST_1',Billing_Street_2__c = 'B_ST_2',
                     Billing_City__c = 'test-city',Billing_County__c = 'test-county',Billing_State__c = 'Indiana',Billing_Zip_Code__c='123',
                     Shipping_Address_Type__c = 'Shelter',Puppy_Intakes_Yr__c=decimal.valueof('20'),Dog_Intakes_Yr__c=decimal.valueof('20'),Puppy_Adoptions_Yr__c = decimal.valueof('20'),
                     Dog_Adoptions_Yr__c = decimal.valueof('20'),Kitten_Intakes_Yr__c = decimal.valueof('20'),Cat_Intakes_Yr__c = decimal.valueof('20'),Kitten_Adoptions_Yr__c = decimal.valueof('20'),
                     Cat_Adoptions_yr__c = decimal.valueof('20'),Does_org_perform_Spay_Neuter_operations__c='Yes',In_House_Clinic__c='Yes',
                     Estimated_S_N_performed_average_yr__c = decimal.valueof('20'),Vet_Prefix__c = 'Mr.',Vet_First_Name__c = 'VET_F',
                     Vet_Last_Name__c = 'VET_L',DVM_Phone__c='213546',DVM_Address__c='ADD',DVM_Address_2__c='ADD2',DVM_City__c='VET_C',
                     DVM_County__c = 'VET_CO',DVM_State__c='Indiana',DVM_Zip__c='asf231',DVM_Email__c='a@gmail.com',DVM_Fax__c = '564',
                     DVM_ST__c='asf684uub',Principal_Bank_Name__c='HDFC',Principal_Bank_Phone__c='564213879',Authorization_Flag__c=true,
                     Contact_Preference__c = 'Fax',Sales_Tax_Status_Type__c = 'Non-profit',Sales_Tax_Status__c = 'Charge tax',
                     Tax_Permit__c = 'sdg564',I_agree_to_the_terms_and_conditions__c = True);
        Insert l;
        
        
        
        
    }
    
    static testMethod void testforLead(){ 
        init();
        Account acc = new Account(Name='Test_Account1',BillingStreet='B_ST_1',
                                  BillingCity='test_city',
                                  BillingCountry='United States',
                                  BillingState='TX',
                                  BillingPostalCode='12345',
                                  ZTS_US_Business_Class__c = 'Government/Non-Profit',
                                  ZTS_US_Sub_Class_1__c = 'Zoo, SPCA, Humane Society');
        Insert acc;
        
        Contact cont = new Contact();
        cont.FirstName='mnb';
        cont.LastName='hjk';
        cont.Email='p@a.com';
        cont.ZTS_US_Job_Function__c='Account Contact';
        cont.ZTS_US_Profession__c = 'Academia';
        cont.Accountid= acc.id;
        cont.ZTS_EU_Market__c = 'United States';
        cont.ZTS_US_Job_Function__c = 'Staff Specialist';
        cont.ZTS_US_Profession__c = 'Staff';
        insert cont;
        
        
        l.Zoetis_Account__c = 'SAP123';
        l.Billing_Street_1__c = 'B_ST_1';
        l.Billing_City__c='test-city';
        l.Billing_State__c='Indiana';
        l.Billing_Zip_Code__c='123';
        l.Status = 'Member';
        update l;
        
        State_Country__c sc = new State_Country__c();         
        sc.name = 'Test State';
        sc.ZTS_EU_Country__c = 'United States';
        sc.ZTS_EU_uniqueCOUNTY__c = 'Test State';
        insert sc;
        
        Address__c adrs=new Address__c(ZTS_EU_Account__c=acc.Id,ZTS_US_Address_Identifier__c = 'HINMDW41AAF3',
                                       ZTS_EU_Address_Type__c = 'Billing',ZTS_Address_Line_1__c='B_ST_1',
                                       ZTS_EU_City__c='test-city',ZTS_US_State_Province__c='Indiana',
                                       Zip_Postal_Code__c='123', ZTS_EU_State_County__c = sc.Id, ZTS_EU_Country__c = 'United States');
        insert adrs;
        l.Zoetis_Account__c=adrs.ZTS_US_Address_Identifier__c;
        update l;
        l.Step_Number__c =7;
        update l;
        
        
        test.startTest();
        
        ApexPages.StandardController scj = new ApexPages.standardController(l);
        ZFS_CreateAccount testSubmit = new ZFS_CreateAccount(scj);
        testSubmit.newAcc = acc;
        testSubmit.selectedAccId = acc.Id;
        testSubmit.submit();
        testSubmit.manageContact(acc);
        
        testSubmit.loadShelter(l.id);
        test.stopTest();
        
        
    }
    
    static testMethod void createNewAccountTest(){ 
        init();
        test.startTest();
        
        ApexPages.StandardController scj = new ApexPages.standardController(l);
        ZFS_CreateAccount testSubmit = new ZFS_CreateAccount(scj);
        Account acc = new Account(Name='Test_Account1',BillingStreet='B_ST_1',
                                  BillingCity='test_city',
                                  BillingCountry='United States',
                                  BillingState='TX',
                                  BillingPostalCode='12345',
                                  ZTS_US_Business_Class__c = 'Government/Non-Profit',
                                  ZTS_US_Sub_Class_1__c = 'Zoo, SPCA, Humane Society');
        testSubmit.newAcc = acc;
        testSubmit.createNewAccount();
        test.stopTest();
    }
    
    static testMethod void createNewAccountNegativeTest(){ 
        init();
        test.startTest();
        
        ApexPages.StandardController scj = new ApexPages.standardController(l);
        ZFS_CreateAccount testSubmit = new ZFS_CreateAccount(scj);
        testSubmit.createNewAccount();
        test.stopTest();
    }
    
    
}