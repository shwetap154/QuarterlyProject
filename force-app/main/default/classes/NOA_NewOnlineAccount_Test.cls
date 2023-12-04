/*************************************************************************************
* Name          :    NOA_NewOnlineAccount_Test
* Description   :    Test class to test NOA_NewOnlineAccount and NOA_EmailToExtonController class.
                     Also, please Test Run NOA_NewOnlineAccount_eSign_test class to test the eSign method of NOA_NewOnlineAccount class.
* Author        :    Tanmoy Bardhan(Cognizant)
 
Modification Log
----------------
Date                Developer                         Comments
-------------------------------------------------------------------------------------------------------
April 2, 2017       Tanmoy Bardhan(Cognizant)         Created
*******************************************************************************************************
April 12,2017       Oeeshi Roy Choudhury(Cognizant)   Modified
Oct   22,2018		Shiva Kudikilla (Cognizant)		  Updated to addNewShippingLocation testmethod
Jan   31,2019	    Shiva Kudikilla (Cognizant)		  Updated to include new scenarios
--------------------------------------------------------------------------------------------------------*/



@isTest(SeeAllData = False)
public class NOA_NewOnlineAccount_Test {
    public static Lead l;
    public static decimal s=0;
    public static Lead lea;
    public static Veterinarian_Information__c v;
    
    @TestSetup
    static void init(){
        Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Licensed_Vet').getRecordTypeId();
        l = new Lead(Do_you_have_a_licensed_veterinarian__c = 'Yes',Company = 'test Company', Salutation = 'Mr.',FirstName = 'Test_F',
                     LastName = 'Test_L',Email='a@a.com',Phone='123',Small_Animal__c=12.0,Equine__c=13.0,Beef__c=15.0,Dairy__c=14.0,Swine__c=15.0,Feed__c=14.0,Poultry__c=13.0,Business_Name__c = 'Test BN',
                     Customer_Type__c = 'University', Billing_Street_1__c = 'B_ST_1',Billing_Street_2__c = 'B_ST_2',
                     Billing_City__c = 'test-city',Billing_County__c = 'test-county',Billing_State__c = 'Indiana',Billing_Zip_Code__c='B123',
                     Billing_Phone__c = '231564879',Billing_Fax__c = '215498',Billing_Email__c = 'a@a.com',Shipping_Street_1__c = 's1',
                     Shipping_Street_2__c = 's2',Shipping_County__c = 'test_county',Shipping_City__c = 'test_city',Shipping_State__c = 'Indiana',
                     Shipping_Zip_Code__c = 's213',Shipping_Phone__c = '21354879',Shipping_Fax__c = '21354987',Shipping_Email__c = 'a@b.com',
                     Existing_account_with_Zoetis_at_this_Loc__c = 'No',Ownership_Change__c = 'No',Existing_account_with_Zoetis__c = 'No',
                     Sales_Tax_Status__c = 'Charge tax',RecordTypeID = recTypeId,Ownership_Type__c = 'Sole-proprietorship',SP_Name__c = 'SP test',
                     SP_Telephone__c = '213458',SP_Email__c = 'a@test.com',SP_Fax__c = '21356879',SP_Address__c = 'Add_Test',SP_County__c = 'testC',
                     SP_City__c = 'Test',SP_State__c = 'Indiana',SP_Zip__c = 'ZP213',Principal_Bank_Name__c = 'test bank',Total_number_of_practitioners__c=23,
                     Principal_Bank_Phone__c = '213546879',Trade_Reference_1_Company_Name__c = 'C1',Trade_Reference_1_Company_Phone__c = '21546879',
                     Trade_Reference_2_Company_Name__c = 'C2',Trade_Reference_2_Company_Phone__c = '21546879',Trade_Reference_3_Company_Name__c = 'C3',
                     Trade_Reference_3_Company_Phone__c = '2154689',Contact_Preference__c = 'Email',Authorization_Email__c = 'z@z.com', Market__c = 'United States');
            Insert l; 
            
        v = new Veterinarian_Information__c (Veterinarian_First_Name__c = 'test v_first',Veterinarian_Last_Name__c = 'test v_last',Primary__c=True,
                                             Veterinarian_Email__c = 'a@test.com',State_License__c = 'test SL',DEA__c = 'a_DEA',Veterinarian_Signature_Tag__c='testVet',
                                             Veterinarian_Role__c = 'Staff',Delete_Record__c = False,Lead__c = l.ID);
            Insert v;    
    }
    
    static void initDiagnostics(){
        Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Diagnostic_or_Reproduction').getRecordTypeId();
        lea = new Lead(Company = 'test Company', FirstName = 'Test_F',LastName = 'Test_L',Email='a@a.com',Phone='123',Business_Name__c = 'Test BN',
                       Billing_Street_1__c = 'B_ST_1',Billing_Street_2__c = 'B_ST_2',Small_Animal__c=12.0,Equine__c=13.0,Beef__c=15.0,Dairy__c=14.0,Swine__c=15.0,Feed__c=14.0,Poultry__c=13.0,
                       Billing_City__c = 'test-city',Billing_County__c = 'test-county',Billing_State__c = 'Indiana',Billing_Zip_Code__c='B123',
                       Billing_Phone__c = '231564879',Billing_Fax__c = '215498',Billing_Email__c = 'a@a.com',Shipping_Street_1__c = 's1',
                       Shipping_Street_2__c = 's2',Shipping_County__c = 'test_county',Shipping_City__c = 'test_city',Shipping_State__c = 'Indiana',
                       Shipping_Zip_Code__c = 's213',Shipping_Phone__c = '21354879',Shipping_Fax__c = '21354987',Shipping_Email__c = 'a@b.com',
                       Type_of_Business__c = 'Reproduction Services',Sales_Tax_Status__c = 'Charge tax',
                       Principal_Bank_Name__c = 'test bank',Principal_Bank_Phone__c = '213546879',Trade_Reference_1_Company_Name__c = 'C1',
                       Trade_Reference_1_Company_Phone__c = '21546879',Trade_Reference_2_Company_Name__c = 'C2',
                       Trade_Reference_2_Company_Phone__c = '21546879',Trade_Reference_3_Company_Name__c = 'C3',
                       Trade_Reference_3_Company_Phone__c = '2154689',Contact_Preference__c = 'Fax',RecordTypeID = recTypeId);
          Insert lea;             
    }
    
    static testMethod void testIdentifyFormWithoutSpecies(){
        //init();
        Lead record = [Select Id,Customer_Type__c,Customer_Sub_Type__c from Lead];
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(record);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.identifyForm();
        record.Customer_Type__c = 'Producer';
        record.Customer_Sub_Type__c = Null;
        update record;
        Lead Updatedrecord = [Select Id from Lead];
        ApexPages.StandardController newsc = new ApexPages.StandardController(record);
        NOA_NewOnlineAccount Updatednoa = new NOA_NewOnlineAccount(newsc);
        Updatednoa.identifyForm();
        
        Lead leadwithoutID = new Lead(Company = 'TestC',LastName = 'test LN', Market__c = 'United States');
        PageReference pageRefBI = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRefBI);
        ApexPages.StandardController BIsc = new ApexPages.StandardController(leadwithoutID);
        NOA_NewOnlineAccount BInoa = new NOA_NewOnlineAccount(BIsc);
        BInoa.identifyForm();
        
        Lead leadwithoutIDDR = new Lead(Company = 'TestC',LastName = 'test LN', Market__c = 'United States');
        PageReference pageRefDR = Page.NOA_DiagnosticsorReproductiveServices;
        Test.setCurrentPage(pageRefDR);
        ApexPages.StandardController DRsc = new ApexPages.StandardController(leadwithoutID);
        NOA_NewOnlineAccount DRnoa = new NOA_NewOnlineAccount(DRsc);
        DRnoa.identifyForm();
        
        Lead leadwithoutIDNoPR = new Lead(Company = 'TestC',LastName = 'test LN', Market__c = 'United States');       
        ApexPages.StandardController NoPRsc = new ApexPages.StandardController(leadwithoutIDNoPR);
        NOA_NewOnlineAccount NoPRnoa = new NOA_NewOnlineAccount(NoPRsc);
        NoPRnoa.identifyForm();

        
    }
     
    
    static testMethod void testIdentifyFormWithSpecies(){
        Lead l = [Select Id,Customer_Type__c,Customer_Sub_Type__c,Do_you_have_a_licensed_veterinarian__c from Lead];
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        l.Do_you_have_a_licensed_veterinarian__c = 'Yes';
        Update l;
        system.debug('Test Lic vet ==>'+l.Do_you_have_a_licensed_veterinarian__c);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        system.debug('Test Lic vet1 ==>'+l.Do_you_have_a_licensed_veterinarian__c);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        system.debug('Test Lic vet2 ==>'+l.Do_you_have_a_licensed_veterinarian__c);
        system.debug('Test Lic vet3 ==>'+noa.newOnlineAcc.Do_you_have_a_licensed_veterinarian__c);
        noa.species.add('Cats & Dogs');
        noa.newOnlineAcc = l;
        noa.identifyForm();
        system.debug('Test Lic vet4 ==>'+l.Do_you_have_a_licensed_veterinarian__c);
        system.debug('Test Lic vet5 ==>'+noa.newOnlineAcc.Do_you_have_a_licensed_veterinarian__c);
    }
    
    static testMethod void testIdentifyFormVetNo(){
        Lead record = [Select Id,Customer_Type__c,Customer_Sub_Type__c,Do_you_have_a_licensed_veterinarian__c from Lead];
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        record.Do_you_have_a_licensed_veterinarian__c = 'No';
        Update record;
        ApexPages.StandardController sc = new ApexPages.StandardController(record);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.species.add('Cats & Dogs');
        noa.newOnlineAcc = record;
        noa.identifyForm();
    }
    
    static testMethod void testIdentifyFormHorse(){
         Lead record = [Select Id,Customer_Type__c,Customer_Sub_Type__c from Lead];
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(record);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.species.add('Horses');
        noa.identifyForm();
    }
    
    static testMethod void testBasicInfo(){
        Lead l = [Select Id,Customer_Type__c,Customer_Sub_Type__c from Lead];
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.sameAsBilling = True;
        noa.copyBillingToShipping();
        noa.saveNewOnlineAccount();
        noa.resetForm();
    }
    
    static testMethod void testUploadTaxAtt(){ 
        Lead l = [Select Id,Customer_Type__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Sales_Tax_Status__c = 'Tax Exempt';
        l.Tax_Permit__c = 'test213';
        Update l;
        PageReference pageRef = Page.NOA_ReviewAndSubmit;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.taxAtt.Name = 'Test Attachment';
        noa.taxAtt.Body = Blob.valueOf('Test Data 123 546 879');
        noa.uploadTaxAtt();
        noa.saveNewOnlineAccount();
        noa.loadAttachments(l.ID);
        noa.taxAtt.Name = 'Test ';
        noa.taxAtt.Body = Blob.valueOf('Test 123 546 879');
         noa.uploadTaxAtt();
        noa.saveNewOnlineAccount();
        noa.taxAtt.Name = 'Test Attachment';
        noa.uploadTaxAtt();
        noa.discard();
    }
    
    static testMethod void testVet(){
        Lead l = [Select Id,Customer_Type__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        PageReference pageRef = Page.NOA_VeterinarianInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
        noa.previous();
        noa.resetForm();
        noa.saveExit();
    }
    
    static testMethod void testAddVet(){
        Lead lead = new Lead(Company = 'TestC',LastName = 'test LN', Market__c = 'United States');
        Insert lead;
        PageReference pageRef = Page.NOA_VeterinarianInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lead);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.addVet();
        lead.RecordTypeId = null;
        update lead;
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void testOwnerInfo(){
       Lead l = [Select Id,Customer_Type__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
       PageReference pageRef = Page.NOA_OwnershipInformation;
       Test.setCurrentPage(pageRef);
       ApexPages.StandardController sc = new ApexPages.StandardController(l);
       NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
       noa.saveNewOnlineAccount();
    }
    
    static testMethod void testReview(){ // this method is also used to cover NOA_EmailToExtonController class
        Lead l = [Select Id,Customer_Type__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Existing_account_with_Zoetis__c = 'Yes';
        l.Existing_Account_Name__c = 'Test Account Name';
        l.Zoetis_Account__c = '123';
        Update l;
        PageReference pageRef = Page.NOA_ReviewAndSubmit;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.returnToApplication();
        noa.signedAtt.name = 'Test Signed Attachment';
        noa.signedAtt.Body = Null;
        noa.uploadSignedAtt();
        noa.loadAttachments(l.ID);
        noa.signedAtt.Body = Blob.valueOf('Test Data 123 546 879');
        noa.uploadSignedAtt();
        noa.loadAttachments(l.ID);
        noa.signedAtt.Body = Blob.valueOf('Test 123 546 879');
        noa.uploadSignedAtt();
        noa.loadAttachments(l.ID);
        noa.otherAtt.name = 'Test Signed Attachment';
        noa.otherAtt.Body = Null;
        noa.uploadOtherAtt();
        noa.otherAtt.Body = Blob.valueOf('Test Data 123 546 879');
        noa.uploadOtherAtt();
        noa.otherAtt.Body = Blob.valueOf('Test Data 123 546 777');
        noa.taxAtt.parentId = l.id;
        noa.taxAtt.Description='test';
        noa.uploadOtherAtt();
        noa.loadAttachments(l.ID);
        noa.deleteOtherAtt();
        noa.submitNOA();
        noa.uploadSalesTaxAtt();
        noa.loadAttachments(l.ID);
        noa.taxAtt.name = 'Test Signed Attachment';
        noa.taxAtt.Body = Blob.valueOf('Test Data 123 546 879');
        noa.uploadSalesTaxAtt();
        noa.loadAttachments(l.ID);
        noa.taxAtt.name = 'Test Signed Attachment';
        noa.taxAtt.Body = Blob.valueOf('Test Data 123 546');
        noa.uploadSalesTaxAtt();
    }
    
    static testMethod void testFetch(){
        Lead l = [Select Id,Customer_Type__c,status,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.status = 'Permanent Pending';
        Update l;
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);        
        noa.applicationNo = Null;
        noa.fetchNOA();
        noa.applicationNo = '123';
        noa.fetchNOA();
        noa.applicationNo = [Select NOA_Application_Number__c from Lead where ID =: l.ID AND Market__c = 'United States'].NOA_Application_Number__c;
        noa.emailId = 'a@a.com';
        noa.fetchNOA();
    }
    
    static testmethod void testFetchNOA() {
        Lead l = [Select Id,Customer_Type__c,status,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Status = 'Open';
        update l;
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.applicationNo = null;
        noa.emailId = 'a@a.com';
        noa.fetchNOA();
     
    }
    static testmethod void testFetchNOA1() {
        Lead l = [Select Id,Customer_Type__c,status,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Status = 'To be Deleted';
        update l;
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.applicationNo = '123';
        noa.emailId = 'a@a.com';
        noa.fetchNOA();
     
    }
    
    static testMethod void testFetchInvalidAppNo(){
        Lead l = [Select Id,Customer_Type__c,status,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.applicationNo = [Select NOA_Application_Number__c from Lead where ID =: l.ID AND Market__c = 'United States'].NOA_Application_Number__c;
        noa.fetchNOA();
    }
    
    static testMethod void testCreateForm(){
        Lead l = [Select Id,Customer_Type__c,status,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Do_you_have_a_licensed_veterinarian__c = 'Yes';
        Update l;
        PageReference pageRef = Page.NOA_Distribution;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.newOnlineAcc = l;
        noa.createFormOne();
    }
    
    static testMethod void testCreateFormVetNo(){
        Lead l = [Select Id,Customer_Type__c,status,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        PageReference pageRef = Page.NOA_Distribution;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.createFormOne();
    }
    
    static testMethod void testIdentifyFormDiag(){
        Lead l = [Select Id,Customer_Type__c,status,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.species.add('Diagnostics');
        noa.identifyForm();
        
    }
    
    static testMethod void testDiag(){
        initDiagnostics();
        PageReference pageRef = Page.NOA_DiagnosticsorReproductiveServices;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lea);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
        
    }
    
    static testMethod void validateBasicInfo(){
        Lead l = [Select Id,Customer_Type__c,status,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.FirstName = Null;
        Update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateBasicInfoOne(){
        Lead l = [Select Id,Customer_Type__c,status,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Customer_Type__c = 'Other';
        l.Customer_Type_Other__c = '';
        Update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateBasicInfoTwo(){
        Lead l = [Select Id,Customer_Type__c,status,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Ownership_Change__c = 'Yes';
        l.Date_of_Ownership_Change__c = Null;
        Update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateBasicInfoThree(){
        Lead l = [Select Id,Ownership_Change__c,Date_of_Ownership_Change__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Ownership_Change__c = 'Yes';
        l.Date_of_Ownership_Change__c = date.newInstance(2018, 9, 15);
        Update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateBasicInfoFour(){
        Lead l = [Select Id,Ownership_Change__c,Date_of_Ownership_Change__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Existing_account_with_Zoetis__c = 'Yes';
        l.Existing_Account_Name__c = null;
        Update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateBasicInfoFive(){
        Lead l = [Select Id,Ownership_Change__c,Date_of_Ownership_Change__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Sales_Tax_Status__c = 'Tax Exempt';
        l.Tax_Permit__c = Null;
        l.Small_Animal__c = 10;
        l.Equine__c = 10;
        l.Beef__c = 20;
        l.Dairy__c = 30;
        l.Swine__c = 10;
        l.Feed__c = 10;
        l.Poultry__c = 10;
        Update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateBasicInfoSix(){
        Lead l = [Select Id,Ownership_Change__c,Date_of_Ownership_Change__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Sales_Tax_Status__c = 'Tax Exempt';
        l.Tax_Permit__c = 'df215';
        Update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateBasicInfoSeven(){
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Small_Animal__c = Null;
        l.Equine__c = Null;
        l.Beef__c = Null;
        l.Dairy__c = Null;
        l.Swine__c = Null;
        l.Feed__c = Null;
        l.Poultry__c = Null;
        Update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
        
        
    }
    
    static testmethod void validateBasicInfoEight()
    {
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Billing_City__c=Null;
        l.Billing_State__c= Null;
        update l;
        PageReference pageRef1 = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef1);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc1);
        noa.saveNewOnlineAccount();
     }
     
    static testmethod void ValidateforBasicInfoPage() {
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Salutation = 'Mr';
       /* l.FirstName = Null;
       // l.LastName = Null;
        l.Applicant_Role__c = Null;
        l.Email = Null;- Namrata*/
		l.Applicant_Role__c = 'Owner';
        update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.validateCurrentPage('Submit');
             
    }
    
    static testmethod void ValidateforBasicInfoPage1() {
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Phone = Null;
        l.Business_Name__c = Null;
        l.Customer_Type__c = Null;
        l.Billing_Street_1__c = Null;
        update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.validateCurrentPage('Submit');
    }
    
    static testmethod void ValidateforBasicInfoPage2() {
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Customer_Type__c = 'Other';
        l.Customer_Type_Other__c = Null;
        update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.validateCurrentPage('Submit');
    }
    
    static testmethod void ValidateforBasicInfoPage3() {
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Ownership_Change__c = 'Yes';
        l.Date_of_Ownership_Change__c = Null;
        update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.validateCurrentPage('Submit');
        
    }
    
    static testmethod void ValidateforBasicInfoPage4() {
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Existing_account_with_Zoetis__c = 'Yes';
        l.Existing_Account_Name__c = Null;
        update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.validateCurrentPage('Submit');
        
    }
    
     
    static testmethod void testforSaveNewOnlineAcc()
    {
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Ownership_Type__c='Partnership';        
        l.Partership_Name__c = 'test name';
        l.Partnership_Title_or_Officer_Info_1__c ='o1';
        l.Partership_Address__c = 'pa';
        l.Partership_City__c = 'pc';
        l.Partership_County__c = 'pC';
        l.Partership_State__c = 'ps';
        l.Partership_Zip__c = 'pz';
        l.Partership_Telephone__c = '213';
        l.Partership_Email__c = 'a@a.com';
        l.Partership_Name_2__c = 'PN';
        l.Partnership_Title_or_Officer_Info_2__c = 'o2';
        l.Partership_Address_2__c = 'pa2';
        l.Partership_City_2__c = 'pc2';
        l.Partership_County_2__c = 'pc2';
        l.Partership_State_2__c = 'ps2';
        l.Partership_Zip_2__c = 'pz2';
        l.Partership_Fax__c = 'pf2';
        update l;
        PageReference pageRef = Page.NOA_OwnershipInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    
  
    
    static testMethod void validateOwnershipInfo(){
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Ownership_Type__c = Null;
        Update l;
        PageReference pageRef = Page.NOA_OwnershipInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateOwnershipInfoOne(){
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Ownership_Type__c = 'Sole-proprietorship';
        l.SP_Name__c = Null;
        Update l;
        PageReference pageRef = Page.NOA_OwnershipInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateOwnershipInfoTwo(){//Need to work on
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Ownership_Type__c = 'Partnership';
        //l.Partership_Name__c = Null;
        l.Partership_Fax__c = Null;
        Update l;
        PageReference pageRef = Page.NOA_OwnershipInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateOwnershipInfoThree(){ //Need to work on
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Ownership_Type__c = 'Corporation';
        l.CLG_Telephone__c = Null;
        l.Has_your_company_filed_bankruptcy__c = 'Yes';
        l.Type_of_bankruptcy__c = Null;
        l.Bankrupt_File_Date__c = Null;
        Update l;
        PageReference pageRef = Page.NOA_OwnershipInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateOwnershipInfoFour(){ //Need to work on
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Ownership_Type__c = 'Corporation';
        l.CLG_Name__c = 'Xyz';
        l.CLG_Address__c = 'test';
        l.CLG_City__c = 'City';
        l.CLG_Company__c = 'Cmpany';
		l.CLG_County__c = 'County';
        l.CLG_Email__c = 'Myemail@xyz.in';
        l.CLG_State__c ='Ohio';
        l.CLG_Telephone__c = '210983092183';
        l.CLG_Zip__c = '1234';
        l.Buyer_Name__c = 'Tom';
        l.Buyer_Phone__c = '214324324'; 
        l.Years_in_Business__c = '6';
        l.Controller_Name__c = 'CN' ;
        l.Controller_Phone__c = '23409324094'; 
        l.Accounts_Payable_Contact_Name__c = 'isahdkja';
        l.Accounts_Payable_Contacts_Phone__c = '94023402944';
        l.Has_your_company_filed_bankruptcy__c = 'No';
      	l.RecordTypeId = null;
        //l.Bankrupt_File_Date__c = Date.newInstance(2018, 9, 15);
        Update l;
        PageReference pageRef = Page.NOA_OwnershipInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateVetInfo(){ 
        Lead le = new Lead(Company = 'VetC',LastName = 'test LN');
        Insert le;
        Veterinarian_Information__c vetc = new Veterinarian_Information__c(Veterinarian_First_Name__c = 'test v_first',
                                                                           Veterinarian_Last_Name__c = 'test v_last',
                                                                           Veterinarian_Email__c = 'a@test.com',
                                                                           State_License__c = 'test SL',DEA__c = 'a_DEA',
                                                                           Veterinarian_Role__c = 'Staff',Delete_Record__c = True,
                                                                           Primary__c=true,
                                                                           Lead__c = le.ID);
        Insert vetc;
        PageReference pageRef = Page.NOA_VeterinarianInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(le);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateVetInfoOne(){
        Lead le = new Lead(Company = 'VetC',LastName = 'reset-dummy');
        PageReference pageRef = Page.NOA_VeterinarianInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(le);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.vetList.add(Null);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateDiag(){ 
        initDiagnostics();
        lea.Business_Name__c = Null;
        Update lea;
        PageReference pageRef = Page.NOA_DiagnosticsorReproductiveServices;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lea);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateDiagOne(){ 
        initDiagnostics();
        lea.Sales_Tax_Status__c = 'Tax Exempt';
        lea.Tax_Permit__c = Null;
        Update lea;
        PageReference pageRef = Page.NOA_DiagnosticsorReproductiveServices;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lea);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateDiagTwo(){ 
        initDiagnostics();
        lea.Sales_Tax_Status__c = 'Tax Exempt';
        lea.Tax_Permit__c = 'fd213';
        Update lea;
        PageReference pageRef = Page.NOA_DiagnosticsorReproductiveServices;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lea);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateDiagThree(){ 
        initDiagnostics();
        lea.Small_Animal__c = Null;
        lea.Equine__c = Null;
        lea.Beef__c = Null;
        lea.Dairy__c = Null;
        Update lea;
        PageReference pageRef = Page.NOA_DiagnosticsorReproductiveServices;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lea);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateDiagFour(){ 
        initDiagnostics();
        lea.Contact_Preference__c = 'Email';
        lea.Authorization_Email__c = Null;
        Update lea;
        PageReference pageRef = Page.NOA_DiagnosticsorReproductiveServices;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lea);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.saveNewOnlineAccount();
    }
    
    static testMethod void validateDiagFive(){ 
        initDiagnostics();
        PageReference pageRef = Page.NOA_ReviewAndSubmit;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lea);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.submitNOA();
    }
    
    static testMethod void validateDiagSix(){ // this method is also used to cover NOA_EmailToExtonController class
        initDiagnostics();
        PageReference pageRef = Page.NOA_ReviewAndSubmit;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lea);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.signedAtt.Name = 'Test Att';
        noa.signedAtt.Body = Blob.valueOf('Test 123 546 879');
        noa.submitNOA();
    }
    
    static testmethod void validateDiagSeven()
    {
          initDiagnostics();
        lea.Partership_City__c= Null;
        lea.Applicant_Role__c = 'Owner';
        update lea;
         PageReference pageRef = Page.NOA_DiagnosticsorReproductiveServices;
         Test.setCurrentPage(pageRef);
         ApexPages.StandardController sc = new ApexPages.StandardController(lea);
         NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.validateCurrentPage('ab');

    }
         
    static testMethod void testCreateNullFields(){
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Tax_Permit__c='abc';
        l.Ownership_Type__c = 'Partnership';
        l.Partership_Name__c = 'test name';
        l.Partnership_Title_or_Officer_Info_1__c ='o1';
        l.Partership_Address__c = 'pa';
        l.Partership_City__c = 'pc';
        l.Partership_County__c = 'pC';
        l.Partership_State__c = 'ps';
        l.Partership_Zip__c = 'pz';
        l.Partership_Telephone__c = '213';
        l.Partership_Email__c = 'a@a.com';
        l.Partership_Name_2__c = 'PN';
        l.Partnership_Title_or_Officer_Info_2__c = 'o2';
        l.Partership_Address_2__c = 'pa2';
        l.Partership_City_2__c = 'pc2';
        l.Partership_County_2__c = 'pc2';
        l.Partership_State_2__c = 'ps2';
        l.Partership_Zip_2__c = 'pz2';
        l.Partership_Fax__c = 'pf2';
        Update l;
        PageReference pageRef = Page.NOA_OwnershipInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.createNullFields();
    }
    
    static testMethod void testCreateNullFieldsOne(){
       Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.Customer_Type__c = 'University';
        l.Poultry__c = Null;
        l.Existing_account_with_Zoetis__c = 'No';
        Update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.createNullFields();
    }
    
    static testMethod void testSaveExit(){ // Need to work on
        Lead l = [Select Id,Small_Animal__c,Equine__c,Sales_Tax_Status__c,Tax_Permit__c,Customer_Sub_Type__c from Lead];
        l.RecordTypeId = null;
        l.Applicant_Role__c = 'Owner';
        Update l;
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.hasErrors = false;
        noa.saveExit();
    }
     
    
    static testMethod void testSetStepNumber(){
        Lead l = [Select Id from Lead];
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.setStepNumber('NOA_BasicAndFacilityInformation');
    }
    
    static testMethod void testSetStepNumberOne(){
        Lead l = [Select Id from Lead];
        PageReference pageRef = Page.NOA_DiagnosticsorReproductiveServices;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.setStepNumber('NOA_DiagnosticsorReproductiveServices');
    }
    
    static testMethod void testException(){ // This method is used to cover the Catch and Exception part of the main class
        Lead l = [Select Id from Lead];
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        try{
            Delete l;
        }catch(Exception e){
            noa.resetForm();
            noa.saveExit();
            noa.submitNOA();
            noa.discard();
        }
        noa.resetForm();
        noa.saveExit();
        noa.submitNOA();
        noa.discard();
    }
    
    static testMethod void testAddNewShippingLocation(){
        Lead l = [Select Id from Lead];
        Lead ld = [Select Id,Email,NOA_Application_Number__c from Lead where lastname='Test_L' AND Market__c = 'United States' limit 1];
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(ld);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.applicationNo = ld.NOA_Application_Number__c;
        noa.emailId = ld.Email;
        noa.newOnlineAcc = ld; 
        PageReference pr = noa.addNewShippingLocation();
        System.assert(pr.getParameters().get('id') != null); 
    }

    static testMethod void testNewVetApplication(){
        Lead ld = new Lead();
        PageReference pageRef = Page.NOA_BasicAndFacilityInformation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(ld);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        System.assert(ld.RecordTypeId != null);
    }
    
    static testMethod void testNewDxApplication(){
        Lead ld = new Lead();
        PageReference pageRef = Page.NOA_DiagnosticsorReproductiveServices;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(ld);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        System.assert(ld.RecordTypeId != null);
    }
    
    static testMethod void testReviewandSubmit(){
        //init();
        Lead ld = [Select Id,NOA_Application_Number__c from Lead where lastname='Test_L' AND Market__c = 'United States' limit 1]; 
        ld.Ownership_Type__c = 'Sole-proprietorship';
        ld.SP_Email__c = 'test@test.com';
        update ld;
        PageReference pageRef = Page.NOA_ReviewAndSubmit;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(ld);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.leadId = ld.Id; 
        echosign_dev1__SIGN_Data_Mapping__c objSDM = new echosign_dev1__SIGN_Data_Mapping__c();
        objSDM.Name = 'NOALeadDM';
        insert objSDM;    
        noa.adobeSendForSignature();noa.submittedFormRedirect();
    }
    static testMethod void testReviewAndSubmitUploadSignedAtt() {
    init();
    PageReference pageRef = Page.NOA_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
    noa.signedAtt.Name = 'Test Attachment';
    noa.signedAtt.Body = Blob.valueOf('Test Data 123 546 879');
    noa.uploadSignedAtt();
    noa.submitNOA();
    echosign_dev1__SIGN_Data_Mapping__c agrTemp1 = new echosign_dev1__SIGN_Data_Mapping__c(
      Name = 'NOALeadDM'
    );
    insert agrTemp1;

    noa.adobeSendForSignature();
    List<echosign_dev1__SIGN_Agreement__c> agreements = [
      SELECT Id
      FROM echosign_dev1__SIGN_Agreement__c
    ];
    System.assertEquals(!agreements.isEmpty(), true);
    Test.startTest();

    Test.setMock(
      HttpCalloutMock.class,
      new AdobeWS_SendForSignatureMock(
        200,
        'Success',
        '{"success":true}',
        new Map<String, String>()
      )
    );
    if (!agreements.isEmpty()) {
      NOA_NewOnlineAccount.sendForSignatureRemote(agreements[0].Id);
    }
    Test.stopTest();
    noa.submittedFormRedirect();    
  }
    static testMethod void tesIdentifyForm(){
        Lead l = [Select Id from Lead];
        l.Customer_Type__c = null;
        update l;
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        pageRef = noa.identifyForm(); 
        List<Apexpages.Message> pageMessages = Apexpages.getMessages();
        System.assert(pageMessages != null && pageMessages.size()>0 );
    }
 	
    static testMethod void tesIdentifyFormForProducer(){
        Lead l = [Select Id from Lead];
        l.Customer_Type__c = 'Producer';
        l.Customer_Sub_Type__c = null;
        update l;
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.identifyForm();
        List<Apexpages.Message> pageMessages = ApexPages.getMessages();
        System.assert(pageMessages != null && pageMessages.size()>0 );
    }
    
    static testMethod void tesIdentifyFormForProducerOther(){
       Lead l = [Select Id from Lead];
        l.Customer_Type__c = 'Producer';
        l.Customer_Sub_Type__c = 'Other';
        update l;
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        PageReference pr = noa.identifyForm(); 
        System.assert(pr.getUrl().contains('NOA_Distribution'));
    }
    
    static testMethod void tesIdentifyFormForLaboratory(){
        Lead l = [Select Id,Customer_Type__c from Lead];
        l.Customer_Type__c = 'Laboratory'; 
        update l;
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        PageReference pr = noa.identifyForm(); 
        System.assert(pr.getUrl().contains('NOA_DiagnosticsorReproductiveServices'));
    }

    static testMethod void setSpecialtyOptions() {
       Lead l = [Select Id,Customer_Type__c from Lead];
        l.Customer_Type__c = 'Vet Practice'; 
        update l;
        PageReference pageRef = Page.NOA_homepage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);

        List<SelectOption> hospitalTypes;
        List<SelectOption> hospitalSubTypes;

        Test.startTest();
            hospitalTypes = noa.getHospitalTypeItems();
            hospitalSubTypes = noa.getHospitalSubTypeItems();
            noa.hospitalType = 'Feline';
            noa.setSpecialtyOptions();
        Test.stopTest();

        System.assert(hospitalTypes.size() > 0);
        System.assert(hospitalSubTypes.size() > 0);
        System.assert(noa.newOnlineAcc.Specialty_Hospital__c);

        noa.hospitalType = 'Specialty';
        noa.hospitalSubType = 'SpecialtyWithEmergency';
        noa.setSpecialtyOptions();
        System.assert(noa.newOnlineAcc.Specialty_Hospital__c);
        System.assertEquals('SpecialtyWithEmergency',noa.newOnlineAcc.Specialty_Description__c);
    }
    

}