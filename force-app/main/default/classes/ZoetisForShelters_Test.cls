/*************************************************************************************
* Name          :    ZoetisForShelters_Test
* Description   :    Test class to test ZoetisForShelters class. 
* Author        :    Tanmoy Bardhan(Cognizant)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
Dec 29, 2016       Tanmoy Bardhan(Cognizant)         Created

**************************************************************************************/

@isTest(seealldata=false)
public class ZoetisForShelters_Test {
  public static Lead l;

  static void init() {
    l = new Lead(
      Salutation = 'Mr.',
      FirstName = 'Test_F',
      LastName = 'Test_L',
      Job_Role__c = 'Veterinarian',
      Email = 'a@a.com',
      Phone = '123',
      Shelter_Name__c = 'Test Shelter',
      Shelter_Website__c = 'www.test.com',
      Status = 'Open',
      Company = 'Shelter',
      Type_of_Organization__c = 'Private Shelter (brick & mortar facility)',
      Do_you_currently_purchase_from_Zoetis__c = 'Yes',
      Shelter_Account_Name__c = 'Test',
      annual_cat_dog__c = 'Yes',
      Existing_account_with_Zoetis__c = 'Yes',
      How_did_you_hear_about_us__c = 'Zoetis Website',
      Do_you_have_a_licensed_veterinarian__c = 'Yes',
      Wellness_Center__c = 'Non-profit wellness center',
      Account_Prefix__c = 'Mr.',
      Account_First_Name__c = 'Test_ACC_F',
      Account_Last_Name__c = 'Test_ACC_L',
      Zoetis_Account__c = 'test123z',
      Contact_Prefix__c = 'Mr.',
      Contact_Phone__c = '655',
      Contact_Email__c = 'ab@test.com',
      Contact_Fax__c = '546213',
      Billing_Street_1__c = 'B_ST_1',
      Billing_Street_2__c = 'B_ST_2',
      Billing_City__c = 'test-city',
      Billing_County__c = 'test-county',
      Billing_State__c = 'Indiana',
      Billing_Zip_Code__c = '123',
      Shipping_Address_Type__c = 'Shelter',
      Puppy_Intakes_Yr__c = decimal.valueof('20'),
      Dog_Intakes_Yr__c = decimal.valueof('20'),
      Puppy_Adoptions_Yr__c = decimal.valueof('20'),
      Dog_Adoptions_Yr__c = decimal.valueof('20'),
      Kitten_Intakes_Yr__c = decimal.valueof('20'),
      Cat_Intakes_Yr__c = decimal.valueof('20'),
      Kitten_Adoptions_Yr__c = decimal.valueof('20'),
      Cat_Adoptions_yr__c = decimal.valueof('20'),
      Does_org_perform_Spay_Neuter_operations__c = 'Yes',
      In_House_Clinic__c = 'Yes',
      Estimated_S_N_performed_average_yr__c = decimal.valueof('20'),
      Vet_Prefix__c = 'Mr.',
      Vet_First_Name__c = 'VET_F',
      Vet_Last_Name__c = 'VET_L',
      DVM_Phone__c = '213546',
      DVM_Address__c = 'ADD',
      DVM_Address_2__c = 'ADD2',
      DVM_City__c = 'VET_C',
      DVM_County__c = 'VET_CO',
      DVM_State__c = 'Indiana',
      DVM_Zip__c = 'asf231',
      DVM_Email__c = 'a@gmail.com',
      DVM_Fax__c = '564',
      DVM_ST__c = 'asf684uub',
      Principal_Bank_Name__c = 'HDFC',
      Principal_Bank_Phone__c = '564213879',
      Authorization_Flag__c = true,
      Contact_Preference__c = 'Fax',
      Sales_Tax_Status_Type__c = 'Non-profit',
      Sales_Tax_Status__c = 'Tax Exempt',
      Tax_Permit__c = 'sdg564',
      I_agree_to_the_terms_and_conditions__c = true,
      Market__c = 'United States'
    );
    insert l;
  }

  static testMethod void testBasicInformation() {
    init();
    PageReference pageRef = Page.ZFS_BasicInformation;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
    zfs.returnToApplication();
  }
  static testMethod void testBasicInformationError() {
    init();
    l.Shelter_Name__c = null;
    update l;
    PageReference pageRef = Page.ZFS_BasicInformation;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
  }

  static testMethod void testQualificationCriteria() {
    init();
    PageReference pageRef = Page.ZFS_QualificationCriteria;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.previous();
    zfs.saveShelter();
    zfs.saveExit();
    zfs.reset();
    zfs.discard();
  }
  static testMethod void testQualificationCriteriaStep() {
    init();
    l.Step_Number__c = 4;      
      l.Type_of_Organization__c = 'Spay/Neuter Group (No direct adoptions)';
      l.annual_cat_dog__c = 'Yes';
      l.Do_you_currently_purchase_from_Zoetis__c = 'Yes';
      l.Existing_account_with_Zoetis__c = 'No';
      l.How_did_you_hear_about_us2__c = 'Zoetis Website';
      l.Do_you_have_a_licensed_veterinarian__c = 'Yes';
    update l;
    PageReference pageRef = Page.ZFS_QualificationCriteria;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
      
  }

  static testMethod void testQualificationCriteriaStep2() {
    init();
    l.Step_Number__c = 1;
    l.Status = 'Pre-Qualification Not Eligible';
    update l;
    PageReference pageRef = Page.ZFS_QualificationCriteria;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
  }

  static testMethod void testDownloadFlag() {
    init();
    PageReference pageRef = Page.ZFS_downloadForm;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    System.assertEquals(true, zfs.downloadFlag);
  }

  static testMethod void testReadOnly() {
    init();
    l.Status = 'Unqualified - Aligned Account';
    update l;
    PageReference pageRef = Page.ZFS_downloadForm;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    System.assertEquals(true, zfs.readonly);
  }

  static testMethod void testResetDummy() {
    init();
    l.LastName = 'reset-dummy';
    update l;
    PageReference pageRef = Page.ZFS_downloadForm;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    System.assertEquals(null, zfs.shelter.LastName);
  }

  static testMethod void testConstructorPageName() {
    init();
    PageReference pageRef = Page.ZFS_downloadForm;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('phone', '5555555555');
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    System.assertEquals(
      'ZFS_downloadForm'.toLowerCase(),
      zfs.pageName.toLowerCase()
    );
  }

  static testMethod void testQualificationCriteriaError() {
    init();
    l.Type_of_Organization__c = 'Other';
    update l;
    PageReference pageRef = Page.ZFS_QualificationCriteria;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
    //zfs.adobeSendForSignature();
  }
  static testMethod void testQualificationCriteriaErrorOne() {
    init();
    l.Type_of_Organization__c = null;
    update l;
    PageReference pageRef = Page.ZFS_QualificationCriteria;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
  }
  static testMethod void testQualificationCriteriaErrorTwo() {
    init();
    l.Existing_account_with_Zoetis__c = 'No';
    update l;
    PageReference pageRef = Page.ZFS_QualificationCriteria;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
    zfs.createNullFields();
  }

  static testMethod void testQualificationCriteriaErrorThree() {
    init();
    l.Type_of_Organization__c = 'Other';
    l.annual_cat_dog__c = 'No';
    l.Do_you_have_a_licensed_veterinarian__c = 'No';
    l.How_did_you_hear_about_us2__c = 'Zoetis Website';
    l.If_Other_please_describe__c = 'other reason';
    l.Type_of_Sanctuary_Animals_Other__c = 'Animal';
    l.Type_of_Sanctuary_Animals__c = 'Other';
    //l.Status = 'Pre-Qualification Not Eligible';
    update l;
    PageReference pageRef = Page.ZFS_QualificationCriteria;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveExit();
  }

  static testMethod void testContact() {
    init();
    l.Shipping_Address_Type__c = 'Same as Billing';
    l.Step_Number__c = 2;
    update l;
    PageReference pageRef = Page.ZFS_Contact;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.copyBillingAddress();
    zfs.saveShelter();
    //zfs.previous();
    //zfs.saveExit();
    //zfs.reset();
    //zfs.discard();
  }
  static testMethod void testContactError() {
    init();
    l.Contact_Phone__c = null;
    update l;
    PageReference pageRef = Page.ZFS_Contact;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
  }

  static testMethod void testContactShippingAddressShelter() {
    init();
    l.Shipping_Address_Type__c = 'Shelter';
    l.Shipping_Street_1__c = 'S_ST_1';
    l.Shipping_Street_2__c = 'S_ST_2';
    l.Shipping_City__c = 's_city';
    l.Shipping_County__c = 's_County';
    l.Shipping_State__c = 'Indiana';
    l.Shipping_Zip_Code__c = 'S_IN123';
    update l;
    PageReference pageRef = Page.ZFS_Contact;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc1 = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc1);
    zfs.saveShelter();
    zfs.createNullShelterAndVet();
  }
  static testMethod void testContactShippingAddressShelterError() {
    init();
    l.Shipping_Street_1__c = null;
    update l;
    PageReference pageRef = Page.ZFS_Contact;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc1 = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc1);
    zfs.saveShelter();
  }

  static testMethod void testContactShippingAddressVet() {
    init();
    l.Shipping_Address_Type__c = 'Veterinarian';
    l.Shipping_Street_1__c = 'S_ST_1';
    l.Shipping_Street_2__c = 'S_ST_2';
    l.Shipping_City__c = 's_city';
    l.Shipping_County__c = 's_County';
    l.Shipping_State__c = 'Indiana';
    l.Shipping_Zip_Code__c = 'S_IN123';
    update l;
    PageReference pageRef = Page.ZFS_Contact;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
    zfs.saveExit();
  }
  static testMethod void testContactShippingAddressVetError() {
    init();
    l.Shipping_Address_Type__c = 'Veterinarian';
    l.Shipping_Street_1__c = null;
    update l;
    PageReference pageRef = Page.ZFS_Contact;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc1 = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc1);
    zfs.saveShelter();
  }

  static testMethod void testStats() {
    init();
    l.Step_Number__c = 3;
    l.Resurrenders_for_Cats__c = 100;
    l.Resurrenders_for_Dogs__c = 100;
    l.Max_Capacity_for_Cats__c = 100;
    l.Max_Capacity_for_Dogs__c = 100;
    l.Does_org_perform_Spay_Neuter_operations__c = 'Yes';
    l.In_House_Clinic__c = 'Yes';
    l.Type_of_Organization__c = 'Other';
    l.Puppy_Intakes_Yr__c = 0.5;
    update l;
    PageReference pageRef = Page.ZFS_Stats;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
  }
  static testMethod void testStatsError() {
    init();
    l.Puppy_Intakes_Yr__c = null;
    update l;
    PageReference pageRef = Page.ZFS_Stats;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
  }

  static testMethod void testVet() {
    init();
    l.Step_Number__c = 4;
    update l;
    PageReference pageRef = Page.ZFS_VeterinarianInformation;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
    //zfs.previous();
    //zfs.saveExit();
    //zfs.reset();
  }
  static testMethod void testVetError() {
    init();
    l.Vet_First_Name__c = null;
    update l;
    PageReference pageRef = Page.ZFS_VeterinarianInformation;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
  }

  static testMethod void testReference() {
    init();
    l.Step_Number__c = 5;
    l.Trade_Reference_1_Company_Name__c = 'XYZ';
    l.Trade_Reference_1_Company_Phone__c = '924393494320';
    l.Trade_Reference_2_Company_Name__c = 'XYZ2';
    l.Trade_Reference_2_Company_Phone__c = '40932849023';
    l.Trade_Reference_3_Company_Name__c = 'XYZ3';

    update l;
    PageReference pageRef = Page.ZFS_References;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
  }
  static testMethod void testReferenceError() {
    init();
    l.Principal_Bank_Name__c = null;
    update l;
    PageReference pageRef = Page.ZFS_References;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
  }

  static testMethod void testSalesTaxStatus() {
    init();
    l.Step_Number__c = 5;
    update l;
    PageReference pageRef = Page.ZFS_SalesTaxStatus;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
  }
  static testMethod void testSalesTaxStatusError() {
    init();
    l.I_agree_to_the_terms_and_conditions__c = false;
    update l;
    PageReference pageRef = Page.ZFS_SalesTaxStatus;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
  }
  static testMethod void testSalesTaxStatusErrorOne() {
    init();
    l.Tax_Permit__c = null;
    update l;
    PageReference pageRef = Page.ZFS_SalesTaxStatus;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.saveShelter();
  }

  static testMethod void testSalesTaxStatusAttachment() {
    init();
    PageReference pageRef = Page.ZFS_SalesTaxStatus;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.npoAtt.Name = 'Test Attachment';
    zfs.npoAtt.Body = Blob.valueOf('Test Data 123 546 879');
    zfs.uploadNpoAtt();
    zfs.saveShelter();
  }

  //Testing the code coverage for ZFS_EmailToExtonController class
  static testMethod void testReviewAndSubmit() {
    init();
    Account acc = new Account(
      Name = 'Test_Account1',
      BillingStreet = 'B_ST_1',
      BillingCity = 'test_city',
      BillingCountry = 'United States',
      BillingState = 'TX',
      BillingPostalCode = '123'
    );
    insert acc;
    //l.Billing_State__c=acc.BillingState;
    update l;

    State_Country__c sc1 = new State_Country__c();
    sc1.Name = 'Sachsen';
    sc1.ZTS_EU_Country__c = 'United States';
    insert sc1;

    Address__c adrs = new Address__c(
      ZTS_EU_State_County__c = sc1.Id,
      ZTS_EU_Account__c = acc.Id,
      ZTS_US_Address_Identifier__c = 'HINMDW41AAF3',
      ZTS_EU_Address_Type__c = 'Billing',
      ZTS_Address_Line_1__c = 'B_ST_1',
      ZTS_EU_City__c = 'test-city',
      ZTS_US_State_Province__c = 'Indiana',
      Zip_Postal_Code__c = '123',
      ZTS_EU_Country__c = 'United States'
    );
    insert adrs;
    l.Zoetis_Account__c = adrs.ZTS_US_Address_Identifier__c;
    update l;
    l.Step_Number__c = 7;
    update l;
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.npoAtt.Name = 'Test Attachment';
    zfs.npoAtt.Body = Blob.valueOf('Test Data 123 546 879');
    zfs.uploadNpoAtt();
    zfs.submitShelter();
  }

  //Testing the code coverage for ZFS_EmailToExtonController class
  static testMethod void testReviewAndSubmit1() {
    init();
    Account acc1 = new Account(
      Name = 'Test_Account1',
      BillingStreet = 'B_ST_1',
      BillingCity = 'test_city',
      BillingCountry = 'United States',
      BillingState = 'TX',
      BillingPostalCode = '123'
    );
    insert acc1;
    l.Billing_State__c = acc1.BillingState;
    l.Shelter_Account_Name__c = 'bnm';
    l.Step_Number__c = 7;
    l.Signature_Status__c = 'Out for Signature';
    update l;
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.npoAtt.Name = 'Test Attachment';
    zfs.npoAtt.Body = Blob.valueOf('Test Data 123 546 879');
    zfs.uploadNpoAtt();

    zfs.adobeSendForSignature();
    List<echosign_dev1__SIGN_Agreement__c> agreements = [
      SELECT Id
      FROM echosign_dev1__SIGN_Agreement__c
    ];
    System.assertEquals(!agreements.isEmpty(), false);
    zfs.submitShelter();
  }

  static testMethod void testReviewAndSubmitUploadSignedAtt() {
    init();
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.signedAtt.Name = 'Test Attachment';
    zfs.signedAtt.Body = Blob.valueOf('Test Data 123 546 879');
    zfs.uploadSignedAtt();
    //zfs.continueSubmit();
    zfs.submitShelter();
    echosign_dev1__SIGN_Data_Mapping__c agrTemp1 = new echosign_dev1__SIGN_Data_Mapping__c(
      Name = 'ZFSLeadDM'
    );
    insert agrTemp1;

    zfs.adobeSendForSignature();
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
      ZoetisForShelters.sendForSignatureRemote(agreements[0].Id);
    }
    Test.stopTest();
    zfs.submittedFormRedirect();    
  }
    
    /*static testMethod void testReviewAndSubmitUploadSignedAttFail() {
    init();
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.signedAtt.Name = 'Test Attachment';
    zfs.signedAtt.Body = Blob.valueOf('Test Data 123 546 879');
    zfs.uploadSignedAtt();
    //zfs.continueSubmit();
    zfs.submitShelter();
    echosign_dev1__SIGN_Data_Mapping__c agrTemp1 = new echosign_dev1__SIGN_Data_Mapping__c(
      Name = 'ZFSLeadDM'
    );
    insert agrTemp1;

    zfs.adobeSendForSignature();
    List<echosign_dev1__SIGN_Agreement__c> agreements = [
      SELECT Id
      FROM echosign_dev1__SIGN_Agreement__c
    ];
    System.assertEquals(!agreements.isEmpty(), true);
    Test.startTest();

    Test.setMock(
      HttpCalloutMock.class,
      new AdobeWS_SendForSignatureMock(
        302,
        'Success',
        '{"success":false}',
         new Map<String, String>{'Location' => '/test/'}
      )
    );
    if (!agreements.isEmpty()) {
        try{
            ZoetisForShelters.sendForSignatureRemote(agreements[0].Id);
        }catch(Exception e){
            
        }
    }
    Test.stopTest();
    zfs.submittedFormRedirect();    
  }*/
  static testMethod void testReviewAndSubmitAttError() {
    init();
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.npoAtt.Name = 'Test Attachment';
    zfs.npoAtt.Body = Blob.valueOf('Test Data 123 546 879');
    zfs.uploadNpoAtt();
    //zfs.continueSubmit();
    zfs.submitShelter();
  }

  static testMethod void testReviewAndSubmitUploadOtherAttachment() {
    init();
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.otherAtt.Name = 'Test Attachment';
    zfs.otherAtt.Body = Blob.valueOf('Test Data 123 546 879');
    zfs.uploadOtherAttachment();
    zfs.deleteOtherAtt();
  }

  static testMethod void testLoadAttDesc() {
    init();
    Attachment att = new Attachment();
    att.Name = 'Test Name';
    Blob b = Blob.valueOf('Test Data 123 546 879000');
    att.Body = b;
    att.ParentId = l.Id;
    att.Description = 'NPO 501(c)';
    insert att;
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.npoAtt.Name = 'Test Attachment';
    zfs.npoAtt.Body = Blob.valueOf('Test Data 123 546 879');
    zfs.uploadNpoAtt();
  }

  static testMethod void testLoadAttDescSign() {
    init();
    Attachment att = new Attachment();
    att.Name = 'Test Name';
    Blob b = Blob.valueOf('Test Data 123 546 879000');
    att.Body = b;
    att.ParentId = l.Id;
    att.Description = 'Signed Application Form';
    insert att;
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.signedAtt.Name = 'Test Attachment';
    zfs.signedAtt.Body = Blob.valueOf('Test Data 123 546 879');
    zfs.uploadSignedAtt();
  }
  static testMethod void testDelOtherAtt() {
    //***********Need to Work On**********
    init();
    Attachment att = new Attachment();
    att.Name = 'Test Name';
    Blob b = Blob.valueOf('Test Data 123 546 879000');
    att.Body = b;
    att.ParentId = l.Id;
    att.Description = 'ABC';
    insert att;
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.signedAtt.Name = 'Test Attachment';
    zfs.signedAtt.Body = Blob.valueOf('Test Data 123 546 879');
    zfs.deleteOtherAtt();
  }

  static testMethod void testUploadNpoAttExcpetion() {
    init();
    Attachment att = new Attachment();
    att.Name = 'Test Name';
    Blob b = Blob.valueOf('Test Data 123 546 879000');
    att.Body = b;
    att.ParentId = l.Id;
    insert att;
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.npoAtt = att;
    zfs.uploadNpoAtt();
  }

  static testMethod void testUploadSignedAttException() {
    init();
    Attachment att = new Attachment();
    att.Name = 'Test Name';
    Blob b = Blob.valueOf('Test Data 123 546 879000');
    att.Body = b;
    att.ParentId = l.Id;
    insert att;
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.signedAtt = att;
    zfs.uploadSignedAtt();
  }

  static testMethod void testUploadOtherAttachmentException() {
    init();
    Attachment att = new Attachment();
    att.Name = 'Test Name';
    Blob b = Blob.valueOf('Test Data 123 546 879000');
    att.Body = b;
    att.ParentId = l.Id;
    insert att;
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.otherAtt = att;
    zfs.uploadOtherAttachment();
  }

  static testMethod void testUploadNpoAttNull() {
    init();
    Attachment att = new Attachment();
    att.Name = 'Test Name';
    Blob b = Blob.valueOf('Test Data 123 546 879000');
    att.Body = b;
    att.ParentId = l.Id;
    insert att;
    PageReference pageRef = Page.ZFS_ReviewAndSubmit;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.uploadNpoAtt();
    zfs.uploadSignedAtt();
    zfs.uploadOtherAttachment();
  }

  static testMethod void testFetchShelter() {
    init();
    String ApplicationNo = '';
    String emailId;
    List<Lead> appNo = [
      SELECT Email, Shelter_Application_Number__c
      FROM Lead
      WHERE Vet_Last_Name__c = 'VET_L' AND Market__c = 'United States'
    ];
    for (Lead lead : appNo) {
      ApplicationNo = lead.Shelter_Application_Number__c;
      emailId = lead.Email;
    }
    PageReference pageRef = Page.ZFS_homepage;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.applicationNo = ApplicationNo;
    zfs.emailId = emailId;
    Test.startTest();
    zfs.fetchShelter();
    Test.stopTest();
  }

  static testMethod void testFetchShelterNull() {
    init();
    String ApplicationNo = 'thisIsFake';
    String emailId = 'NotReal@TotallyFake.com';
    PageReference pageRef = Page.ZFS_homepage;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.applicationNo = ApplicationNo;
    zfs.emailId = emailId;
    Test.clearApexPageMessages();
    Test.startTest();
    zfs.fetchShelter();
    Test.stopTest();
    System.assert(
      ApexPages.hasMessages(),
      'This should cause a NULL Shelter, and return an Apex Page Message'
    );
  }

  static testMethod void testFetchShelterOutForSignature() {
    init();
    String ApplicationNo = '';
    String emailId;
    l.Signature_Status__c = 'Out for Signature';
    update l;
    List<Lead> appNo = [
      SELECT Email, Shelter_Application_Number__c
      FROM Lead
      WHERE Vet_Last_Name__c = 'VET_L' AND Market__c = 'United States'
    ];
    for (Lead lead : appNo) {
      ApplicationNo = lead.Shelter_Application_Number__c;
      emailId = lead.Email;
    }
    PageReference pageRef = Page.ZFS_homepage;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.applicationNo = ApplicationNo;
    zfs.emailId = emailId;
    Test.startTest();
    zfs.fetchShelter();
    Test.stopTest();
    System.assertEquals(true, zfs.readonly);
  }

  static testMethod void testFetchShelterPreQualStep2() {
    init();
    String ApplicationNo = '';
    String emailId;
    l.Status = 'Pre-Qualification Not Eligible';
    l.Step_Number__c = 2;
    update l;
    List<Lead> appNo = [
      SELECT Email, Shelter_Application_Number__c
      FROM Lead
      WHERE Vet_Last_Name__c = 'VET_L' AND Market__c = 'United States'
    ];
    for (Lead lead : appNo) {
      ApplicationNo = lead.Shelter_Application_Number__c;
      emailId = lead.Email;
    }
    PageReference pageRef = Page.ZFS_homepage;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.applicationNo = ApplicationNo;
    zfs.emailId = emailId;
    Test.startTest();
    zfs.fetchShelter();
    Test.stopTest();
  }

  static testMethod void testFetchShelterPreQualStep4() {
    init();
    String ApplicationNo = '';
    String emailId;
    l.Status = 'Pre-Qualification Not Eligible';
    l.Step_Number__c = 4;
    update l;
    List<Lead> appNo = [
      SELECT Email, Shelter_Application_Number__c
      FROM Lead
      WHERE Vet_Last_Name__c = 'VET_L' AND Market__c = 'United States'
    ];
    for (Lead lead : appNo) {
      ApplicationNo = lead.Shelter_Application_Number__c;
      emailId = lead.Email;
    }
    PageReference pageRef = Page.ZFS_homepage;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.applicationNo = ApplicationNo;
    zfs.emailId = emailId;
    Test.startTest();
    zfs.fetchShelter();
    Test.stopTest();
  }

  static testMethod void testFetchShelterError() {
    init();
    PageReference pageRef = Page.ZFS_homepage;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.applicationNo = '2215164259';
    zfs.fetchShelter();
  }

  static testMethod void testFetchShelterErrorOne() {
    init();
    PageReference pageRef = Page.ZFS_homepage;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.applicationNo = '';
    zfs.emailId = 'a@a.com';
    zfs.fetchShelter();
  }

  static testMethod void testWebsite() {
    init();
    l.LeadSource = 'ZoetisWebSite';
    update l;
    PageReference pageRef = Page.ZFS_homepage;
    pageRef.getParameters().put('source', 'ZoetisWebsite');
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.applicationNo = '12081627';
    //zfs.fetchShelter();
  }

  static testMethod void testCreateShelterFromWebSite() {
    init();
    l.company = 'ZoetisWebSite';
    update l;
    ApexPages.StandardController sc = new ApexPages.StandardController(l);
    ZoetisForShelters zfs = new ZoetisForShelters(sc);
    zfs.createShelterFromWebSite();
  }
}