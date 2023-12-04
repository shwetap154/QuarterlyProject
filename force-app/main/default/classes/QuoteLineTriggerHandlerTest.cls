/**
* File Name     :  QuoteLineTriggerHandlerTest
* @description  :  Test class for QuoteLineTrigger (SBQQ__QuoteLine__c object) and QuoteLineTriggerHandler
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/27         Cesar Sandrigo @ ATG     Created the Class. Added setup and test methods.
* 2.0     12/9         Cory Bartholomew @ ATG   Added testValidateAddressToAccountHierarchy().  Formatting fixes.  Test.StartTest for query Limit issues
* 2.1     08/18        Rahul Kumar @Deloitte    Added updateQTAnnualPurchaseComValue_Test_Insert , updateQTAnnualPurchaseComValue_Test_Update ,updateQuoteRebateEligProduct_Test_Insert and updateQuoteRebateEligProduct_Test_Update
*
*/
@istest
public class QuoteLineTriggerHandlerTest {
  @testSetup
  public static void setup() {
    // Create Markets and Market Countries
    List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
    CPQ_TestDataFactory.createMarketCountrys(markets, true);

    // Get US market
    Market__c usMarket = getMarketByName(markets, 'United States');

    // Create an account and a contact
    Account account = CPQ_TestDataFactory.createAccount(true);
    Contact contact = CPQ_TestDataFactory.createContact(false);
    contact.AccountId = account.Id;
    insert contact;    
    
    // Create Address record
    Address__c address = CPQ_TestDataFactory.createAddress(account, true);

    // Create an opportunity for the account in the US Market
    Opportunity oppty = CPQ_TestDataFactory.createOppty(account, usMarket, false);
    oppty.Purchasing_Contact__c = contact.Id;
    insert oppty;


    // Create an empty quote
    SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, account, contact, address, true);
      System.Assert(quote.id != null);

    // Create SAP material
    SAP_Material__c material = CPQ_TestDataFactory.createSAPMaterial('VL', '000000000010001498', 'NORM', 'ZFER', '', true);

    // Create product
    Product2 product = CPQ_TestDataFactory.createProduct(false);
    product.Name = 'Z Product';
    product.SAP_Material__c = material.Id;

    Product2 productParent = CPQ_TestDataFactory.createProduct(false);
    productParent.Name = 'Bundle parent';
    productParent.Program_Eligibility_Filter__c = 'FREEDOM';

    // Insert products
    insert new List<Product2>{ productParent, product };

    // Create PBEs
    insert new List<PricebookEntry>{
      CPQ_TestDataFactory.createPriceBookEntry(productParent, false),
      CPQ_TestDataFactory.createPriceBookEntry(product, false)
    };
  }

  private static Market__c getMarketByName(List<Market__c> markets, String name) {
    for (Market__c market : markets) {
      if (market.Name.equalsIgnoreCase(name))
        return market;
    }

    return null;
  }

  @istest
  public static void updateQuoteVistexPricingInSyncFlag_Test() {
    // Get the quote created in the setup
    SBQQ__Quote__c quote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c LIMIT 1];

    // Get the products created in the setup -- Order by name so I make sure 'Z Product is the second in the list'
    List<Product2> products = [
      SELECT
        Id,
        Name,
        SAP_Material__c,
        SBQQ__BillingFrequency__c,
        SBQQ__BillingType__c,
        SBQQ__ChargeType__c,
        SBQQ__PricingMethod__c,
        Description,
        SBQQ__SubscriptionBase__c,
        SBQQ__SubscriptionPricing__c,
        CPQ_Material_Type__c
      FROM Product2
      ORDER BY Name
    ];

    Product2 productParent = products[0];
    Product2 productChild = products[1];

    Test.StartTest();
    // Simulate the price was retrieved from Vistex
    quote.Vistex_Price_In_Sync__c = true;
    update quote;

    // Insert bundle parent line
    SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
    parentLine.SBQQ__Bundle__c = true;
    insert parentLine;

    // Refresh the quote
    quote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];

    /* Assert pricing information is still in sync since this
     * a Bundle parent line, and it doens't affect the price */
    System.Assert(quote.Vistex_Price_In_Sync__c);

    // Insert child line
    SBQQ__QuoteLine__c childLine = CPQ_TestDataFactory.createQuoteLine(quote, productChild, false);
    childLine.SBQQ__RequiredBy__c = parentLine.Id;
    insert childLine;

    // Refresh the quote
    quote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];

    // Assert pricing information is not in sync anymore
    System.Assert(!quote.Vistex_Price_In_Sync__c);

    // Simulate the price was retrieved from Vistex
    quote.Vistex_Price_In_Sync__c = true;
    update quote;

    // Refresh the quote
    quote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];

    // Check price info is in sync
    System.Assert(quote.Vistex_Price_In_Sync__c);

    // Update the quantity
    childLine.SBQQ__Quantity__c = 5;
    update childLine;
    Test.StopTest();
    // Refresh the quote
    quote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];

    // Check price info is not valid anymore
    System.Assert(!quote.Vistex_Price_In_Sync__c);
  }

  @istest
  public static void setQuoteVistexPricingInSyncFlagOnQuoteLineDeletion_Test() {
    // Get the quote created in the setup
    SBQQ__Quote__c quote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c LIMIT 1];

    // Get the products created in the setup -- Order by name so I make sure 'Z Product is the second in the list'
    List<Product2> products = [
      SELECT
        Id,
        Name,
        SAP_Material__c,
        SBQQ__BillingFrequency__c,
        SBQQ__BillingType__c,
        SBQQ__ChargeType__c,
        SBQQ__PricingMethod__c,
        Description,
        SBQQ__SubscriptionBase__c,
        SBQQ__SubscriptionPricing__c,
        CPQ_Material_Type__c
      FROM Product2
      ORDER BY Name
    ];

    Product2 productParent = products[0];
    Product2 productChild = products[1];

    //Adding test.startTest to get us some more query Limits
    Test.StartTest();
    // Simulate the price was retrieved from Vistex
    quote.Vistex_Price_In_Sync__c = true;
    update quote;

    // Insert bundle parent line
    SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
    parentLine.SBQQ__Bundle__c = true;
    insert parentLine;

    // Refresh the quote
    quote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];

    /* Assert pricing information is still in sync since this
     * a Bundle parent line, and it doens't affect the price */
    System.Assert(quote.Vistex_Price_In_Sync__c);

    // Insert child line
    SBQQ__QuoteLine__c childLine = CPQ_TestDataFactory.createQuoteLine(quote, productChild, false);
    childLine.SBQQ__RequiredBy__c = parentLine.Id;
    insert childLine;

    // Refresh the quote
    quote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];

    // Assert pricing information is not in sync anymore
    System.Assert(!quote.Vistex_Price_In_Sync__c);

    // Simulate the price was retrieved from Vistex
    quote.Vistex_Price_In_Sync__c = true;
    update quote;
    Test.StopTest();
    // Refresh the quote
    quote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];

    // Check price info is in sync
    System.Assert(quote.Vistex_Price_In_Sync__c);

    // Remove quote line
    delete childLine;

    // Refresh the quote
    quote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];

    // Check price info is not valid anymore
    System.Assert(!quote.Vistex_Price_In_Sync__c);
  }
  @istest
  public static void testGetTranslatedDealText() {
    //Create Deal
    Vistex_Deal_Header__c deal = CPQ_TestDataFactory.createVistexDealHeader('8675309', '1436', true);

    //Create Vistex Banners
    Vistex_Banner_E1EDKT1__c bannerZCPQ = CPQ_TestDataFactory.createVistexBanner(deal, null, 'EN', false);
    Vistex_Banner_E1EDKT1__c bannerZPRM = CPQ_TestDataFactory.createVistexBanner(deal, null, 'EN', false);
    bannerZPRM.TDID__c = 'ZPRM';
    bannerZPRM.E1EDKT1_Ext_Id__c += '1';
    Vistex_Banner_E1EDKT1__c bannerZTER = CPQ_TestDataFactory.createVistexBanner(deal, null, 'EN', false);
    bannerZTER.TDID__c = 'ZTER';
    bannerZTER.E1EDKT1_Ext_Id__c += '2';
    Vistex_Banner_E1EDKT1__c bannerZPRQ = CPQ_TestDataFactory.createVistexBanner(deal, null, 'EN', false);
    bannerZPRQ.TDID__c = 'ZPRQ';
    bannerZPRQ.E1EDKT1_Ext_Id__c += '3';
    List<Vistex_Banner_E1EDKT1__c> banners = new List<Vistex_Banner_E1EDKT1__c>{ bannerZCPQ, bannerZPRM, bannerZTER, bannerZPRQ };
    insert banners;

    //Create Vistex Child Banners
    List<Vistex_Child_Banner_E1EDKT2__c> childBanners = new List<Vistex_Child_Banner_E1EDKT2__c>();
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZCPQ, 'ZCPQLine1', true, 1, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZCPQ, 'ZCPQLine2', false, 2, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZTER, 'ZTERLine1', true, 1, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZTER, 'ZTERLine2', false, 2, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZPRM, 'ZPRMLine1', true, 1, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZPRM, 'ZPRMLine2', false, 2, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZPRQ, 'ZPRQLine1', true, 1, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZPRQ, 'ZPRQLine2', false, 2, false));
    insert childBanners;

    SBQQ.TriggerControl.disable();
    //Get quote and product to use on new quoteline
    SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
    Product2 product = [
      SELECT
        Id,
        SBQQ__BillingFrequency__c,
        SBQQ__BillingType__c,
        SBQQ__ChargeType__c,
        SBQQ__PricingMethod__c,
        Description,
        SBQQ__SubscriptionBase__c,
        SBQQ__SubscriptionPricing__c,
        CPQ_Material_Type__c
      FROM Product2
      LIMIT 1
    ];
    System.assertNotEquals(null, quote, 'A quote was not returned from TestSetup()');
    System.assertNotEquals(null, product, 'A product was not returned from TestSetup()');

    //create new quote line to hit trigger
    SBQQ__QuoteLine__c quoteLine = CPQ_TestDataFactory.createQuoteLine(quote, product, false);
    quoteLine.Vistex_Deal_ID__c = deal.DEALNUM__c;

    //Insert quoteline and validate text translations
    Test.StartTest();
    insert quoteLine;
    Test.StopTest();
    SBQQ.TriggerControl.enable();
    //requery Quote Line data
    SBQQ__QuoteLine__c quoteLineAfter = [
      SELECT
        Id,
        vistex_banner_zprm_translated__c,
        vistex_banner_zter_translated__c,
        vistex_banner_zcpq_translated__c,
        vistex_banner_zprq_translated__c
      FROM SBQQ__QuoteLine__c
      WHERE Id = :quoteLine.Id
    ];
 
    System.assertEquals(
      'ZPRMLine1 ZPRMLine2',
      quoteLineAfter.vistex_banner_zprm_translated__c,
      'The zprm text was not returned translated correctly from the vistex banners'
    );
    System.assertEquals(
      'ZTERLine1 ZTERLine2',
      quoteLineAfter.vistex_banner_zter_translated__c,
      'The zter text was not returned translated correctly from the vistex banners'
    );
    System.assertEquals(
      'ZCPQLine1 ZCPQLine2',
      quoteLineAfter.vistex_banner_zcpq_translated__c,
      'The zcpq text was not returned translated correctly from the vistex banners'
    );
    System.assertEquals(
      'ZPRQLine1 ZPRQLine2',
      quoteLineAfter.vistex_banner_zprq_translated__c,
      'The zprq text was not returned translated correctly from the vistex banners'
    );
  }

  @istest
  public static void testRemoveDealTextFromQuote() {
    //Create Deal
    Vistex_Deal_Header__c deal = CPQ_TestDataFactory.createVistexDealHeader('8675309', '1436', true);

    //Create Vistex Banners
    Vistex_Banner_E1EDKT1__c bannerZCPQ = CPQ_TestDataFactory.createVistexBanner(deal, null, 'EN', false);
    Vistex_Banner_E1EDKT1__c bannerZPRM = CPQ_TestDataFactory.createVistexBanner(deal, null, 'EN', false);
    bannerZPRM.TDID__c = 'ZPRM';
    bannerZPRM.E1EDKT1_Ext_Id__c += '1';
    Vistex_Banner_E1EDKT1__c bannerZTER = CPQ_TestDataFactory.createVistexBanner(deal, null, 'EN', false);
    bannerZTER.TDID__c = 'ZTER';
    bannerZTER.E1EDKT1_Ext_Id__c += '2';
    Vistex_Banner_E1EDKT1__c bannerZPRQ = CPQ_TestDataFactory.createVistexBanner(deal, null, 'E', false);
    bannerZPRQ.TDID__c = 'ZPRQ';
    bannerZPRQ.E1EDKT1_Ext_Id__c += '3';
    List<Vistex_Banner_E1EDKT1__c> banners = new List<Vistex_Banner_E1EDKT1__c>{ bannerZCPQ, bannerZPRM, bannerZTER, bannerZPRQ };
    insert banners;

    //Create Vistex Child Banners
    List<Vistex_Child_Banner_E1EDKT2__c> childBanners = new List<Vistex_Child_Banner_E1EDKT2__c>();
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZCPQ, 'ZCPQLine1', true, 1, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZCPQ, 'ZCPQLine2', false, 2, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZTER, 'ZTERLine1', true, 1, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZTER, 'ZTERLine2', false, 2, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZPRM, 'ZPRMLine1', true, 1, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZPRM, 'ZPRMLine2', false, 2, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZPRQ, 'ZPRQLine1', true, 1, false));
    childBanners.add(CPQ_TestDataFactory.createVistexChildBanner(bannerZPRQ, 'ZPRQLine2', false, 2, false));
    insert childBanners;
    SBQQ.TriggerControl.disable();
    //Get quote and product to use on new quoteline
    SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
    Product2 product = [
      SELECT
        Id,
        SBQQ__BillingFrequency__c,
        SBQQ__BillingType__c,
        SBQQ__ChargeType__c,
        SBQQ__PricingMethod__c,
        Description,
        SBQQ__SubscriptionBase__c,
        SBQQ__SubscriptionPricing__c,
        CPQ_Material_Type__c
      FROM Product2
      LIMIT 1
    ];
    System.assertNotEquals(null, quote, 'A quote was not returned from TestSetup()');
    System.assertNotEquals(null, product, 'A product was not returned from TestSetup()');

    //create new quote line to hit trigger
    SBQQ__QuoteLine__c quoteLine = CPQ_TestDataFactory.createQuoteLine(quote, product, false);
    quoteLine.Vistex_Deal_ID__c = deal.DEALNUM__c;

    insert quoteLine;

    //delete quote line and query quote to check that fields are null/false

    Test.StartTest();
    delete quoteLine;
    Test.StopTest();
    SBQQ.TriggerControl.enable();
    SBQQ__Quote__c quoteAfter = [
      SELECT
        Id,
        QT_Display_Promo__c,
        vistex_banner_zprm_translated__c,
        vistex_banner_zter_translated__c,
        QT_Display_Termination_Clause__c,
        vistex_banner_zcpq_translated__c,
        QT_Display_Program_Prerequisite__c,
        vistex_banner_zprq_translated__c,
        QT_Display_ZPRQ_field__c
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    System.assertEquals(null, quoteAfter.vistex_banner_zprm_translated__c);
    System.assertEquals(null, quoteAfter.vistex_banner_zter_translated__c);
    System.assertEquals(null, quoteAfter.vistex_banner_zcpq_translated__c);
    System.assertEquals(null, quoteAfter.vistex_banner_zprq_translated__c);
    System.assertEquals(false, quoteAfter.QT_Display_Promo__c);
    System.assertEquals(false, quoteAfter.QT_Display_Termination_Clause__c);
    System.assertEquals(false, quoteAfter.QT_Display_Program_Prerequisite__c);
    System.assertEquals(false, quoteAfter.QT_Display_ZPRQ_field__c);
  }
    
    //Commented below method because we are not using QuoteLine.Ship_to_location__c - By Rahul Deloitte
/*  
  @istest
  public static void testValidateAddressToAccountHierarchy() {
    //get Products from testSetup()
    List<Product2> products = [
      SELECT
        Id,
        Name,
        SAP_Material__c,
        SBQQ__BillingFrequency__c,
        SBQQ__BillingType__c,
        SBQQ__ChargeType__c,
        SBQQ__PricingMethod__c,
        Description,
        SBQQ__SubscriptionBase__c,
        SBQQ__SubscriptionPricing__c,
        CPQ_Material_Type__c
      FROM Product2
      ORDER BY Name
    ];

    //Stage account hierarchy with addresses for testing
    Account parentAccount = [SELECT Id FROM Account LIMIT 1];

    Account childAccount = new Account();
    childAccount.Name = 'TestChild';
    childAccount.ZTS_EU_Market__c = 'United States';
    childAccount.Practice_Management_Software__c = 'Animana';
    childAccount.ParentId = parentAccount.Id;
    childAccount.BillingPostalCode = '00000';
    childAccount.BillingCity = 'testCity';
    childAccount.BillingState = 'testState';
    childAccount.BillingStreet = 'testStreet';
    insert childAccount;

    Account unrelatedAccount = new Account();
    unrelatedAccount.Name = 'Unrelated';
    unrelatedAccount.ZTS_EU_Market__c = 'United States';
    unrelatedAccount.Practice_Management_Software__c = 'Animana';
    unrelatedAccount.BillingPostalCode = '00000';
    unrelatedAccount.BillingCity = 'testCity';
    unrelatedAccount.BillingState = 'testState';
    unrelatedAccount.BillingStreet = 'testStreet';
    insert unrelatedAccount;

    //Create one address in hierarchy and one not in hierarchy
    List<Address__c> addressesToInsert = new List<Address__c>();
    Address__c inHierarchy = CPQ_TestDataFactory.createAddress(childAccount, false);
    Address__c notInHierarchy = CPQ_TestDataFactory.createAddress(unrelatedAccount, false);
    addressesToInsert.addAll(new List<Address__c>{ inHierarchy, notInHierarchy });
    insert addressesToInsert;

    SBQQ__Quote__c quote = [SELECT Id, SBQQ__Account__c, Ship_To_Address__c FROM SBQQ__Quote__c LIMIT 1];
    quote.SBQQ__Account__c = parentAccount.Id;
    update quote;
    SBQQ__QuoteLine__c quoteLine = CPQ_TestDataFactory.createQuoteLine(quote, products[0], false);
    quoteLine.Ship_To_Address__c = notInHierarchy.Id;
    try {
      insert quoteLine;
    } catch (Exception e) {
      System.assertEquals(false, e.getMessage().contains('Ship to Address is not within the account hierarchy'));
    }
  }
*/
  @IsTest
  public static void updateShipToOverrideForSpecificCommitment_Test() {
    // Get the quote created in the setup
    SBQQ__Quote__c quote = [SELECT Id, (SELECT Id FROM Ship_to_Configurations__r) FROM SBQQ__Quote__c LIMIT 1];

    // Get the products created in the setup -- Order by name so I make sure 'Z Product is the second in the list'
    List<Product2> products = [
      SELECT
        Id,
        Name,
        SAP_Material__c,
        SBQQ__BillingFrequency__c,
        SBQQ__BillingType__c,
        SBQQ__ChargeType__c,
        SBQQ__PricingMethod__c,
        Description,
        SBQQ__SubscriptionBase__c,
        SBQQ__SubscriptionPricing__c,
        CPQ_Material_Type__c
      FROM Product2
      ORDER BY Name
    ];

    Product2 productParent = products[0];
    Product2 productChild = products[1];

    // Insert bundle parent line
    SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
    parentLine.SBQQ__Bundle__c = true;
    insert parentLine;

    // Insert child line
    SBQQ__QuoteLine__c childLine = CPQ_TestDataFactory.createQuoteLine(quote, productChild, false);
    childLine.SBQQ__Quantity__c = 1;
    childLine.CPQ_Commitment_Quantity__c = 200;
    childLine.Specific_Commitment__c = true;
    childLine.SBQQ__RequiredBy__c = parentLine.Id;
    insert childLine;

    Ship_To_Quantity_Override__c shipToOverride = CPQ_TestDataFactory.createShipToQuantityOverride(
      childLine,
      quote.Ship_to_Configurations__r[0],
      100,
      true
    );

    Test.StartTest();
    // change line quantity
    childLine.SBQQ__Quantity__c = 200;
    update childLine;

    Test.StopTest();

    // refresh the override
    shipToOverride = [SELECT Id, Quantity__c FROM Ship_To_Quantity_Override__c WHERE Id = :shipToOverride.Id];

    System.assertEquals(200, shipToOverride.Quantity__c);
  }

  @IsTest
  public static void updateShipToOverrideForSpecificCommitment_Bypass_Test() {
    // Get the quote created in the setup
    SBQQ__Quote__c quote = [SELECT Id, (SELECT Id FROM Ship_to_Configurations__r) FROM SBQQ__Quote__c LIMIT 1];

    // Get the products created in the setup -- Order by name so I make sure 'Z Product is the second in the list'
    List<Product2> products = [
      SELECT
        Id,
        Name,
        SAP_Material__c,
        SBQQ__BillingFrequency__c,
        SBQQ__BillingType__c,
        SBQQ__ChargeType__c,
        SBQQ__PricingMethod__c,
        Description,
        SBQQ__SubscriptionBase__c,
        SBQQ__SubscriptionPricing__c,
        CPQ_Material_Type__c
      FROM Product2
      ORDER BY Name
    ];

    Product2 productParent = products[0];
    Product2 productChild = products[1];

    // Insert bundle parent line
    SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
    parentLine.SBQQ__Bundle__c = true;
    insert parentLine;

    // Insert child line
    SBQQ__QuoteLine__c childLine = CPQ_TestDataFactory.createQuoteLine(quote, productChild, false);
    childLine.SBQQ__Quantity__c = 1;
    childLine.CPQ_Commitment_Quantity__c = 200;
    childLine.Specific_Commitment__c = true;
    childLine.SBQQ__RequiredBy__c = parentLine.Id;
    insert childLine;

    Ship_To_Quantity_Override__c shipToOverride = CPQ_TestDataFactory.createShipToQuantityOverride(
      childLine,
      quote.Ship_to_Configurations__r[0],
      100,
      true
    );

    Test.StartTest();

    QuoteLineTriggerHandler.disableShipToOverrideUpdate();

    // change line quantity
    childLine.SBQQ__Quantity__c = 400;
    update childLine;

    // refresh the override
    shipToOverride = [SELECT Id, Quantity__c FROM Ship_To_Quantity_Override__c WHERE Id = :shipToOverride.Id];
    System.assertEquals(100, shipToOverride.Quantity__c);

    QuoteLineTriggerHandler.enableShipToOverrideUpdate();

    // change line quantity
    childLine.SBQQ__Quantity__c = 200;
    update childLine;

    // refresh the override
    shipToOverride = [SELECT Id, Quantity__c FROM Ship_To_Quantity_Override__c WHERE Id = :shipToOverride.Id];
    System.assertEquals(200, shipToOverride.Quantity__c);

    Test.StopTest();
  }
    
  @IsTest
    public static void updateQTAnnualPurchaseComValue_Test_Insert() {
        
        // Get the quote created in the setup
        SBQQ__Quote__c quote = [SELECT Id,SBQQ__Account__c, QT_Sales_Program__c, MAT_Purchase_Dollars_Rx__c , MAT_Purchase_Dollars_Dx__c FROM SBQQ__Quote__c LIMIT 1];
        
        // Get the products created in the setup -- Order by name so I make sure 'Z Product is the second in the list'
        List<Product2> products = [
            SELECT
            Id,
            Name,
            SAP_Material__c,
            SBQQ__BillingFrequency__c,
            SBQQ__BillingType__c,
            SBQQ__ChargeType__c,
            SBQQ__PricingMethod__c,
            Description,
            SBQQ__SubscriptionBase__c,
            SBQQ__SubscriptionPricing__c,
            CPQ_Material_Type__c
            FROM Product2
            ORDER BY Name
        ];
        
        Product2 productParent = products[0];
        Product2 productChild = products[1];
        
        Test.startTest();
        // Insert bundle parent line
        SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
        parentLine.SBQQ__SubscriptionTerm__c = 5;
        insert parentLine;
        System.Assert(parentLine.id != null);
        System.Assert(parentLine.id != null);
        
        // Insert child line
        SBQQ__QuoteLine__c childLine = CPQ_TestDataFactory.createQuoteLine(quote, productChild, false);
        childLine.CPQ_Material_Type__c = 'Aggregate Commitment Service Item' ;
        childLine.CPQ_Commitment_Value__c = 20;
        childLine.SBQQ__RequiredBy__c = parentLine.Id;
        childLine.Aggregate_Commitment_Type__c = 'Rx';
        insert childLine;
        System.assert(childLine.id != null);
        
        System.assertEquals(48, [select QT_Annual_Purchase_Com_Value__c from SBQQ__QuoteLine__c where id =: childLine.id].QT_Annual_Purchase_Com_Value__c);

        Test.stopTest();
        
    }
    
    
    @IsTest
    public static void updateQTAnnualPurchaseComValue_Test_Update() {
        
        // Get the quote created in the setup
        SBQQ__Quote__c quote = [SELECT Id, MAT_Purchase_Dollars_Rx__c , MAT_Purchase_Dollars_Dx__c FROM SBQQ__Quote__c LIMIT 1];
        
        // Get the products created in the setup -- Order by name so I make sure 'Z Product is the second in the list'
        List<Product2> products = [
            SELECT
            Id,
            Name,
            SAP_Material__c,
            SBQQ__BillingFrequency__c,
            SBQQ__BillingType__c,
            SBQQ__ChargeType__c,
            SBQQ__PricingMethod__c,
            Description,
            SBQQ__SubscriptionBase__c,
            SBQQ__SubscriptionPricing__c,
            CPQ_Material_Type__c
            FROM Product2
            ORDER BY Name
        ];
        
        Product2 productParent = products[0];
        Product2 productChild = products[1];
        
        Test.startTest();
        // Insert bundle parent line
        SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
        parentLine.SBQQ__SubscriptionTerm__c = 5;
        insert parentLine;
        System.Assert(parentLine.id != null);
        
        // Insert child line
        SBQQ__QuoteLine__c childLine = CPQ_TestDataFactory.createQuoteLine(quote, productChild, false);
        childLine.CPQ_Commitment_Value__c = 10;
        childLine.SBQQ__RequiredBy__c = parentLine.Id;
        insert childLine;
        System.assert(childLine.id != null);
        
        System.assertEquals(null, [select QT_Annual_Purchase_Com_Value__c from SBQQ__QuoteLine__c where id =: childLine.id].QT_Annual_Purchase_Com_Value__c);
         
        childLine.CPQ_Material_Type__c = CPQ_CONSTANT_Zoetis.STRING_AGGR_CMNT_SER;
        update childLine;
        System.assertEquals(24, [select QT_Annual_Purchase_Com_Value__c from SBQQ__QuoteLine__c where id =: childLine.id].QT_Annual_Purchase_Com_Value__c);
        
        childLine.CPQ_Commitment_Value__c = 60;
        update childLine;
        System.assertEquals(144, [select QT_Annual_Purchase_Com_Value__c from SBQQ__QuoteLine__c where id =: childLine.id].QT_Annual_Purchase_Com_Value__c);
        
        Test.stopTest();
        
    }
    
     @IsTest
    public static void updateQuoteRebateEligProduct_Test_Insert() {
        
        // Get the quote created in the setup
        SBQQ__Quote__c quote = [SELECT Id, Product_Template_Logic__c, Rebate_Eligible_Product__c FROM SBQQ__Quote__c LIMIT 1];
        
        // Get the products created in the setup -- Order by name so I make sure 'Z Product is the second in the list'
        List<Product2> products = [
            SELECT
            Id,
            Name,
            SAP_Material__c,
            SBQQ__BillingFrequency__c,
            SBQQ__BillingType__c,
            SBQQ__ChargeType__c,
            SBQQ__PricingMethod__c,
            Description,
            SBQQ__SubscriptionBase__c,
            SBQQ__SubscriptionPricing__c,
            CPQ_Material_Type__c,
            Rebate_Calculator_Eligible__c
            FROM Product2
            ORDER BY Name
        ];
        
        Product2 product1 = products[0];
        product1.Rebate_Calculator_Eligible__c = true;
        product1.Family = 'Programs';
        update product1;
        System.assertEquals(true,  product1.Rebate_Calculator_Eligible__c);
        
        Product2 product2 = products[1];
        
        Test.startTest();

        // Insert bundle parent line
        SBQQ__QuoteLine__c rebateQuoteLine = CPQ_TestDataFactory.createQuoteLine(quote, product1, false);
        SBQQ__QuoteLine__c nonRebateQuoteLine = CPQ_TestDataFactory.createQuoteLine(quote, product2, false);
		List<SBQQ__QuoteLine__c>lineList = new List<SBQQ__QuoteLine__c>{rebateQuoteLine,nonRebateQuoteLine};
        insert lineList;
        
        System.assert(lineList[0].id != null); 
        System.assertEquals(true, [Select id, Rebate_Eligible_Product__c from SBQQ__Quote__c where id = :quote.id].Rebate_Eligible_Product__c);
        Test.stopTest();
        
    }
    
         @IsTest
    public static void updateQuoteRebateEligProduct_Test_update() {
        
        // Get the quote created in the setup
        SBQQ__Quote__c quote = [SELECT Id, Product_Template_Logic__c, Rebate_Eligible_Product__c FROM SBQQ__Quote__c LIMIT 1];
        
        // Get the products created in the setup -- Order by name so I make sure 'Z Product is the second in the list'
        List<Product2> products = [
            SELECT
            Id,
            Name,
            SAP_Material__c,
            SBQQ__BillingFrequency__c,
            SBQQ__BillingType__c,
            SBQQ__ChargeType__c,
            SBQQ__PricingMethod__c,
            Description,
            SBQQ__SubscriptionBase__c,
            SBQQ__SubscriptionPricing__c,
            CPQ_Material_Type__c,
            Rebate_Calculator_Eligible__c,
            Template_logic__c
            FROM Product2
            ORDER BY Name
        ];
        
        Product2 product1 = products[0];
        product1.Rebate_Calculator_Eligible__c = true;
        product1.Family = 'Programs';
        product1.Template_logic__c = '5';
        update product1;
        System.assertEquals(true,  product1.Rebate_Calculator_Eligible__c);
        
        Product2 product2 = products[1];
        
        Test.startTest();

        // Insert bundle parent line
        SBQQ__QuoteLine__c nonRebateQuoteLine1 = CPQ_TestDataFactory.createQuoteLine(quote, product2, false);
        SBQQ__QuoteLine__c nonRebateQuoteLine2 = CPQ_TestDataFactory.createQuoteLine(quote, product2, false);
		List<SBQQ__QuoteLine__c>lineList = new List<SBQQ__QuoteLine__c>{nonRebateQuoteLine1,nonRebateQuoteLine2};
        insert lineList;
        
        System.assert(lineList[0].id != null); 
        System.assertEquals(false, [Select id, Rebate_Eligible_Product__c from SBQQ__Quote__c where id = :quote.id].Rebate_Eligible_Product__c);
        nonRebateQuoteLine1.SBQQ__Product__c = product1.id;
        update nonRebateQuoteLine1;
        System.assertEquals(true, [Select id, Is_Rebate_Calculator_Enabled__c from SBQQ__QuoteLine__c where id = :nonRebateQuoteLine1.id].Is_Rebate_Calculator_Enabled__c);
        System.assertEquals(true, [Select id, Rebate_Eligible_Product__c from SBQQ__Quote__c where id = :quote.id].Rebate_Eligible_Product__c);
        System.assertEquals('5', [Select id, Product_Template_Logic__c from SBQQ__Quote__c where id = :quote.id].Product_Template_Logic__c);
        Test.stopTest();
        
    }
    
         @IsTest
    public static void updateQuoteRebateEligProduct_Test_Delete() {
        
        // Get the quote created in the setup
        SBQQ__Quote__c quote = [SELECT Id, Product_Template_Logic__c, Rebate_Eligible_Product__c FROM SBQQ__Quote__c LIMIT 1];
        
        // Get the products created in the setup -- Order by name so I make sure 'Z Product is the second in the list'
        List<Product2> products = [
            SELECT
            Id,
            Name,
            SAP_Material__c,
            SBQQ__BillingFrequency__c,
            SBQQ__BillingType__c,
            SBQQ__ChargeType__c,
            SBQQ__PricingMethod__c,
            Description,
            SBQQ__SubscriptionBase__c,
            SBQQ__SubscriptionPricing__c,
            CPQ_Material_Type__c,
            Rebate_Calculator_Eligible__c
            FROM Product2
            ORDER BY Name
        ];
        
        Product2 product1 = products[0];
        product1.Rebate_Calculator_Eligible__c = true;
        product1.Family = 'Programs';
        update product1;
        System.assertEquals(true,  product1.Rebate_Calculator_Eligible__c);
        
        Product2 product2 = products[1];
        
        Test.startTest();

        // Insert bundle parent line
        SBQQ__QuoteLine__c rebateQuoteLine = CPQ_TestDataFactory.createQuoteLine(quote, product1, false);
        SBQQ__QuoteLine__c nonRebateQuoteLine = CPQ_TestDataFactory.createQuoteLine(quote, product2, false);
		List<SBQQ__QuoteLine__c>lineList = new List<SBQQ__QuoteLine__c>{rebateQuoteLine,nonRebateQuoteLine};
        insert lineList;
        
        System.assert(lineList[0].id != null); 
        SBQQ__Quote__c quoteBeforeDelete = [Select id, Rebate_Eligible_Product__c from SBQQ__Quote__c where id = :quote.id limit 1];
        System.assertEquals(true, quoteBeforeDelete.Rebate_Eligible_Product__c);
        
        List<SBQQ__QuoteLine__c> deleteLineList = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__c =: quote.id];
        System.assertEquals(2, deleteLineList.size());
        
        delete deleteLineList;
        SBQQ__Quote__c quoteAfterDelete = [Select id, Rebate_Eligible_Product__c,Product_Template_Logic__c from SBQQ__Quote__c where id = :quote.id limit 1];                          
        System.assertEquals(false, quoteAfterDelete.Rebate_Eligible_Product__c);
        System.assertEquals(null, quoteAfterDelete.Product_Template_Logic__c);
        Test.stopTest();
        
    }
    
}