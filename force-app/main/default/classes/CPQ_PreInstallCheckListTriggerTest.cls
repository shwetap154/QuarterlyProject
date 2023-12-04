/**
 * @description       : Test class for CPQ_PreInstallCheckListTrigger
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-20-2021   Ramiro Alvarez @ ATG        Initial Version (Based on Trigger Handler)
 * 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc   Fix Unit Test failures due to Validation Rules and update file comment header
**/
@Istest
public class CPQ_PreInstallCheckListTriggerTest {
    

  @TestSetup
  static void makeData() {
    // Disable Triggers to improve performance and save on limits
    DispatchTriggerHandler.bypass('AccountTriggerHandler');
    DispatchTriggerHandler.bypass('AddressTriggerHandler');
    DispatchTriggerHandler.bypass('ContactTriggerHandler');
    DispatchTriggerHandler.bypass('OpportunityTriggerHandler');
    DispatchTriggerHandler.bypass('UserTriggerHandler');
    SBQQ.TriggerControl.disable();
    // Create Markets and Market Countries
    List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
    CPQ_TestDataFactory.createMarketCountrys(markets, true);

    // Get US market
    Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');

    // Create an account and a contact
    Account account = CPQ_TestDataFactory.createAccount(true);
    Address__c soldToAddress = CPQ_TestDataFactory.createAddress(account, true);
    account.ZTS_EU_Primary_Address__c = soldToAddress.Id;
    update account;

    Contact contact = CPQ_TestDataFactory.createContact(false);
    contact.AccountId = account.Id;
    insert contact;

    // Create an opportunity for the account in the US Market
    Opportunity oppty = CPQ_TestDataFactory.createOppty(account, usMarket, false);
    oppty.Purchasing_Contact__c = contact.Id; // 05242021 - Fix
    insert oppty;

    // Create Address record
    Address__c address = CPQ_TestDataFactory.createAddress(account, true);

    // Crete an empty quote
    SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, account, contact, address, false);
    quote.Address__c = soldToAddress.Id;
    quote.Ship_To_Address__c = soldToAddress.Id;
    quote.Sales_Org_Market__c = usMarket.Id;
    insert quote;

    // Create SAP materials
    List<SAP_Material__c> materials = new List<SAP_Material__c>{
      CPQ_TestDataFactory.createSAPMaterial('VL', '000000000010001498', 'NORM', 'ZFER', '', false),
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000043', 'DIEN', 'DIEN', '', false),
      CPQ_TestDataFactory.createSAPMaterial('ST', '000000000016001285', 'ZANC', 'ZFER', '', false)
    };
    insert materials;

    // Create product
    Product2 product = CPQ_TestDataFactory.createProduct(false);
    product.SAP_Material__c = materials[0].Id;

    Product2 productWarranty = CPQ_TestDataFactory.createProduct(false);
    productWarranty.SAP_Material__c = materials[1].Id;

    Product2 productAncillary = CPQ_TestDataFactory.createProduct(false);
    productWarranty.SAP_Material__c = materials[2].Id;

    Product2 productParent = CPQ_TestDataFactory.createProduct(false);
    productParent.Name = 'Bundle parent';
    productParent.Program_Eligibility_Filter__c = 'FREEDOM';

    // Insert products
    insert new List<Product2>{ productParent, product, productWarranty, productAncillary };

    // Create PBEs
    insert new List<PricebookEntry>{
      CPQ_TestDataFactory.createPriceBookEntry(productParent, false),
      CPQ_TestDataFactory.createPriceBookEntry(productWarranty, false),
      CPQ_TestDataFactory.createPriceBookEntry(product, false),
      CPQ_TestDataFactory.createPriceBookEntry(productAncillary, false)
    };

    // Insert bundle parent line
    SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
    parentLine.SBQQ__Bundle__c = true;
    insert parentLine;

    // Insert child line
    SBQQ__QuoteLine__c childLine1 = CPQ_TestDataFactory.createQuoteLine(quote, product, false);
    childLine1.SBQQ__RequiredBy__c = parentLine.Id;

    // Insert child line
    SBQQ__QuoteLine__c childLine2 = CPQ_TestDataFactory.createQuoteLine(quote, productAncillary, false);
    childLine2.SBQQ__RequiredBy__c = parentLine.Id;
    childLine2.CPQ_Material_Type__c = 'Ancillary';

    List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{ childLine1, childLine2 };
    insert lines;    
  }

  @istest
  public static void handleBeforeUpdate_nonCompleted_test() {
    
    PreInstallCheckList__c preInstallList = [SELECT Id, Clinic_Communications_Question_1__c FROM PreInstallCheckList__c LIMIT 1];

    preInstallList.Clinic_Communications_Question_1__c = 'Yes';
    update preInstallList;    

    System.debug('test preInstallList: ' + preInstallList);

  }

  @istest
  public static void handleBeforeUpdate_Completed_test() {
    
    PreInstallCheckList__c preInstallList = [SELECT Id, Clinic_Communications_Question_1__c FROM PreInstallCheckList__c LIMIT 1];
    preInstallList.Is_Clinic_Communic_Relevant_for_Quote__c = false;
    preInstallList.Is_Clinic_Delivery_Relevant_for_Quote__c = false;
    preInstallList.Is_Clinic_Electical_Relevant_for_Quote__c = false;
    preInstallList.Is_Cloud_Internet_Relevant_for_Quote__c = false;
    preInstallList.Is_InstallationTrain_Relevant_for_Quote__c = false;
    preInstallList.Is_Is_VETSCAN_HM5_Relevant_for_Quote__c = false;
    preInstallList.Is_iSTAT_Alinity_Relevant_for_Quote__c = false;
    preInstallList.Is_VETSCAN_FUSE_Relevant_for_Quote__c = false;
    preInstallList.Is_VETSCAN_IMAGYST_Relevant_for_Quote__c = false;
    preInstallList.Is_VETSCAN_SA_Relevant_for_Quote__c = false;
    preInstallList.Is_VETSCAN_VS2_Relevant_for_Quote__c = false;
    preInstallList.Is_VETSCAN_Vspro_Relevant_for_Quote__c = false;
    preInstallList.Is_VETSCAN_VUE_Relevant_for_Quote__c = false;

    preInstallList.Analizer_to_be_Removed__c = 'test';
    preInstallList.Analizer_to_be_Removed_SAP_Num__c = 'test';
    preInstallList.Analizer_to_be_Removed_Serial__c = 'test';

    update preInstallList;    

    PreInstallCheckList__c preInstallList2 = [SELECT Id, Analizer_to_be_Removed_Complete__c,
        Clinic_Communications_Complete__c,
        Clinic_Delivery_Complete__c,
        Clinic_Electrical_Complete__c,
        Cloud_Internet_Complete__c,	
        i_STAT_Alinity_Complete__c,	
        Installation_Training_Complete__c,
        VETSCAN_FUSE_Complete__c,
        VETSCAN_HM5_Complete__c,
        VETSCAN_IMAGYST_Complete__c,
        VETSCAN_SA_Complete__c,
        VETSCAN_VS2_Complete__c,
        VETSCAN_Vspro_Complete__c,
        VETSCAN_VUE_Complete__c
        FROM PreInstallCheckList__c LIMIT 1];

    System.debug('test preInstallList 2: ' + preInstallList2);

  }
  
}