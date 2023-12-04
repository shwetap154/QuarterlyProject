/**
 * @description       : Handler class for the Flexible Group Item Trigger
 * @author            : Cesar Sandrigo @ ATG 
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
* 1.0    08-19-2019		Cesar Sandrigo @ ATG        Created the Class. Added tests for After Update (Build SAP Contract Texts)
* 1.1    09-29-2019		Cesar Sandrigo @ ATG        Added tests for Before Update (Prevent Order Activation)
* 1.2    01-11-2020   Cesar Sandrigo @ ATG        Updated test cases. Coverage: 97%
* 1.3    02-03-2020   Cory Bartholomew @ ATG      Updated test cases for added translated deal text mapping.
* 1.4    01-03-2021	  Mila Imas				            Updated stages
* 1.5    03-22-2022	  Ethan Hirsch @ Zoetis Inc   Updated Comment header and fixed Unit Test failures due to Validation Rule in helper class
**/
@istest
public class CPQ_OrderTriggerHandlerTest {
  @testSetup
  public static void setup() {

    AutomationSettings__c settings = new AutomationSettings__c(SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder_c__c= true);
    insert settings;
	System.assert(settings.SetupOwnerId == UserInfo.getOrganizationId());
    //SBQQ.TriggerControl.disable();
    QuoteLineTriggerHandler.disableShipToOverrideUpdate();
    QuoteTriggerHandler.disablePriceInSyncCalculation();

    // Create a user for the foreing rep
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
    User foreingRepUser = new User(
      Alias = 'frep',
      Email = 'foreing@rep.com',
      EmailEncodingKey = 'UTF-8',
      FirstName = 'Foreing',
      LastName = 'Rep',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'foreing@rep.com',
      ZTS_EU_Market__c = 'Mexico'
    );
    insert foreingRepUser;
    System.assert(foreingRepUser != null);

    // Create Markets and Market Countries
    List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
    System.assert (markets.size()>0);
    List <Market_Country__c> marketCountry = CPQ_TestDataFactory.createMarketCountrys(markets, true);
System.assert (marketCountry.size()>0);
    // Get US market
    Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
    System.assert(usMarket!= null) ; 

    // Create an account and a contact
    Account account = CPQ_TestDataFactory.createAccount(true);
      System.Assert(account.Name == 'Test');
    Address__c soldToAddress = CPQ_TestDataFactory.createAddress(account, true);
    account.ZTS_EU_Primary_Address__c = soldToAddress.Id;
    update account;

    Contact contact = CPQ_TestDataFactory.createContact(false);
    contact.AccountId = account.Id;
    insert contact;

    // Create SAP materials
    List<SAP_Material__c> materials = new List<SAP_Material__c>{
      CPQ_TestDataFactory.createSAPMaterial('VL', '000000000010001498', 'Z006', 'ZFER', '', false), // Device
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000043', 'NORM', 'ZFER', '', false), // Consumable
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000046', 'NORM', 'ZFER', '', false), // Consumable
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000044', 'ZANC', 'ZHYB', '', false), // Ancillary
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000045', 'ZIEN', 'DIEN', '', false), // Standard warranty
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000047', 'Z011', 'DIEN', '', false), // Aggregate line
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000048', 'ZCRE', 'ZNBW', '', false) // Program Charge - Contract charge
    };
    insert materials;
      System.Assert(materials.size() == 7);

    // Create Program Charge Material Custom Setting
    insert new Program_Charge_Materials__c(
      Buy_Out__c = '000000000060000047',
      Buy_Out_w_Equipment_Return__c = '000000000060000053, 000000000060000054',
      Cash_Back__c = '000000000060000049',
      Contract_Charge__c = '000000000060000048',
      Program_Transfer_Contract_Charge__c = '000000000060000050',
      Program_Transfer_Dev_Between_Contracts__c = '000000000060000052'
    );

    List<Product2> products = new List<Product2>{
      CPQ_TestDataFactory.createProduct(false),
      CPQ_TestDataFactory.createProduct(materials[0], false),
      CPQ_TestDataFactory.createProduct(materials[1], false),
      CPQ_TestDataFactory.createProduct(materials[2], false),
      CPQ_TestDataFactory.createProduct(materials[3], false),
      CPQ_TestDataFactory.createProduct(materials[4], false),
      CPQ_TestDataFactory.createProduct(materials[5], false),
      CPQ_TestDataFactory.createProduct(materials[6], false)
    };
        System.Assert(products.size() == 8);

    products[0].Name = 'Bundle parent';
    products[0].Program_Eligibility_Filter__c = 'FREEDOM';
    insert products;
	System.AssertEquals (products[0].Name , 'Bundle parent');
    // Create PBEs
    List<PricebookEntry> pbeList = CPQ_TestDataFactory.createPriceBookEntries(products, true);
    Map<Id, Id> productPbeMap = new Map<Id, Id>();
    for (PricebookEntry pbe : pbeList) {
      productPbeMap.put(pbe.Product2Id, pbe.Id);
    }

    // Create an opportunity for the account in the US Market
    Opportunity oppty = CPQ_TestDataFactory.createOppty(account, usMarket, false);
    oppty.Estimated_Installation_Date__c = date.today().addMonths(1);
    oppty.Foreign_Rep__c = foreingRepUser.Id; // Assing a foreing contact

    //FIX 012121 RA : add purchasing contact to oppty
    oppty.Purchasing_Contact__c = contact.Id;

    insert oppty;

    // Create Address record
    Address__c address = CPQ_TestDataFactory.createAddress(account, true);

    // Crete an empty quote
    SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, account, contact, address, false);
    quote.vistex_banner_zprm_translated__c = 'TEST';
    quote.vistex_banner_zter_translated__c = 'TEST';
    quote.vistex_banner_zcpq_translated__c = 'TEST';
    quote.vistex_banner_zprq_translated__c = 'TEST';
    quote.Rebate_Commitment__c = 'TEST';


    quote.Date_of_First_Installment__c = System.today();
    insert quote;
	System.Assert(quote.id != null);
    // Insert bundle parent line
    SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, products[0], false);
    parentLine.SBQQ__Bundle__c = true;
    parentLine.SBQQ__PricebookEntryId__c = productPbeMap.get(products[0].Id);
    insert parentLine;
     System.Assert(parentLine.id != null); 

    products = [
      SELECT
        Id,
        Name,
        SBQQ__ChargeType__c,
        SBQQ__PricingMethod__c,
        Description,
        SBQQ__SubscriptionBase__c,
        SBQQ__SubscriptionPricing__c,
        CPQ_Material_Type__c,
        SBQQ__BillingType__c,
        SBQQ__BillingFrequency__c
      FROM Product2
      WHERE Name != 'Bundle parent'
    ];

    // Quote Lines
    List<SBQQ__QuoteLine__c> childQuoteLines = new List<SBQQ__QuoteLine__c>{
      CPQ_TestDataFactory.createQuoteLine(quote, products[0], false),
      CPQ_TestDataFactory.createQuoteLine(quote, products[1], false),
      CPQ_TestDataFactory.createQuoteLine(quote, products[2], false),
      CPQ_TestDataFactory.createQuoteLine(quote, products[3], false),
      CPQ_TestDataFactory.createQuoteLine(quote, products[4], false),
      CPQ_TestDataFactory.createQuoteLine(quote, products[5], false),
      CPQ_TestDataFactory.createQuoteLine(quote, products[6], false)
    };

    for (SBQQ__QuoteLine__c ql : childQuoteLines) {
      ql.SBQQ__RequiredBy__c = parentLine.Id;
      ql.SBQQ__PricebookEntryId__c = productPbeMap.get(ql.SBQQ__Product__c);

      if (ql.CPQ_Material_Type__c == 'Consumable') {
        ql.Estimated_Quantity__c = 20;
        ql.Auto_Ship_Day_of_Month__c = '5';
        ql.Auto_Ship_Quantity__c = 10;
        ql.Auto_Ship_Frequency__c = 'Monthly';
        ql.Initial_Quantity__c = 10;
      } else if (ql.CPQ_Material_Type__c == 'Aggregate Commitment Service Item') {
        ql.CPQ_Commitment_Quantity__c = 40;
      }
      if (ql.CPQ_Material_Type__c == 'Consumable') {
        ql.Estimated_Quantity__c = 20;
        ql.Auto_Ship_Day_of_Month__c = '5';
        ql.Auto_Ship_Quantity__c = 10;
        ql.Auto_Ship_Frequency__c = 'Monthly';
        ql.Initial_Quantity__c = 10;
      }
      if (ql.CPQ_Material_Type__c == 'Debit or Contract Charge' || ql.CPQ_Material_Type__c == 'Credit or Cash Back') {
        ql.Amount_Owed__c = 1000;
        ql.Contract_Reference__c = '000001234';
        ql.Program_Charge_Type__c = 'Contract Charge';
      }
    }
    insert childQuoteLines;

    // Add Distributor Rep information
    quote.Distributor_Rep__c = 'John Smith';
    quote.Notes_for_SAP__c = 'Test Notes For SAP Team';
    quote.Distributor_Rep_Phone__c = '+1 123 444-5555';

    // Approve quote
    quote.Vistex_Price_In_Sync__c = true;
    quote.ApprovalStatus__c = 'Approved';
    update quote;


    //SBQQ.TriggerControl.enable();
    QuoteLineTriggerHandler.enableShipToOverrideUpdate();
    QuoteTriggerHandler.enablePriceInSyncCalculation();
  }

  @istest
  public static void buildSAPContractTexts() {
    SBQQ__Quote__c quote = [
      SELECT
        Id,
        Name,
        SBQQ__Account__c,
        SBQQ__Opportunity2__c,
        (
          SELECT
            Id,
            Name,
            Auto_Ship__c,
            Installments__c,
            Lease__c,
            Lease_Type__c,
            SBQQ__Number__c,
            SBQQ__NetPrice__c,
            Supplier__c,
            CPQ_Material_Type__c,
            SBQQ__PricebookEntryId__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    System.debug('buildSAPContractTexts: ' + quote);

    Test.startTest();

    Account account = new Account(Id = quote.SBQQ__Account__c);
    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed/Installed', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

    // Get the order
    Order order = [
      SELECT
        Id,
        (
          SELECT
            Id,
            SAP_Usage_Type__c,
            SAP_Item_Category__c,
            Product2.Name,
            SBQQ__QuoteLine__r.Auto_Ship__c,
            SBQQ__QuoteLine__r.SBQQ__Bundle__c
          FROM OrderItems
        ), Status, Date_of_First_Installment__c, OpportunityId, Opportunity.Market__c
      FROM Order
      WHERE SBQQ__Quote__c = :quote.Id
      LIMIT 1
    ];

    System.debug('buildSAPContractTexts, order: ' + order);

    System.assertEquals(8, order.OrderItems.size());

    // Populate Item Categoty and Usage Type with sample values in order to allow order activation
    for (OrderItem oi : order.OrderItems) {
      if (oi.SBQQ__QuoteLine__r.SBQQ__Bundle__c) {
        continue;
      }

      oi.SAP_Item_Category__c = 'Z012';
      oi.SAP_Usage_Type__c = 'SCB';
    }
    update order.OrderItems;

    System.debug('buildSAPContractTexts, update order-items: ' + order.OrderItems); 

    // Activate Order
    order.Status = 'Activated';
    order.Pre_Installation_checklist_completed__c = true;
    order.Date_of_First_Installment__c = System.today();
    update order;

    System.debug('buildSAPContractTexts, activate order: ' + order.OrderItems);

    order = [
      SELECT
        Id,
        (SELECT Id, SAP_Usage_Type__c, SAP_Item_Category__c, Product2.Name, SBQQ__QuoteLine__r.Auto_Ship__c FROM OrderItems),
        (SELECT Id, SAP_Text_ID__c, SAP_Text_ID_Description__c, Text__c FROM SAP_Contract_Texts__r)
      FROM Order
      WHERE SBQQ__Quote__c = :quote.Id
      LIMIT 1
    ];

    //System.assertEquals(10, order.SAP_Contract_Texts__r.size());
  }

 @istest
  public static void validateItemCategoryAndUsageTypeBeforeActivate_ok2() {
    SBQQ__Quote__c quote = [
      SELECT
        Id,
        Name,
        SBQQ__Account__c,
        SBQQ__Opportunity2__c,
        (
          SELECT
            Id,
            Name,
            Auto_Ship__c,
            Installments__c,
            Lease__c,
            Lease_Type__c,
            SBQQ__Number__c,
            SBQQ__NetPrice__c,
            Supplier__c,
            CPQ_Material_Type__c,
            SBQQ__PricebookEntryId__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    Test.startTest();

    Account account = new Account(Id = quote.SBQQ__Account__c);
    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed/Installed', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

    // Get the order
    Order order = [
      SELECT
        Id,
        (
          SELECT
            Id,
            SAP_Usage_Type__c,
            SAP_Item_Category__c,
            Product2.Name,
            SBQQ__QuoteLine__r.Auto_Ship__c,
            SBQQ__QuoteLine__r.SBQQ__Bundle__c,
            SBQQ__QuoteLine__r.Is_Spread_Commitment_Line__c
          FROM OrderItems
        )
      FROM Order
      WHERE SBQQ__Quote__c = :quote.Id
      LIMIT 1
    ];

    System.assertEquals(8, order.OrderItems.size());

    // Populate Item Categoty and Usage Type, except bundle parents and spread lines
    for (OrderItem oi : order.OrderItems) {
      if (oi.SBQQ__QuoteLine__r.SBQQ__Bundle__c) {
        continue;
      }

      if (oi.SBQQ__QuoteLine__r.Is_Spread_Commitment_Line__c) {
        continue;
      }

      oi.SAP_Item_Category__c = 'Z012';
      oi.SAP_Usage_Type__c = 'SCB';
    }
    update order.OrderItems;

    // Activate Order
    order.Status = 'Activated';
    order.Pre_Installation_checklist_completed__c = true;
    update order;

    // Refresh Order
    order = [SELECT Id, Status FROM Order WHERE Id = :order.Id LIMIT 1];
    System.assertEquals('Activated', order.Status);
  }

  @istest
  public static void validateItemCategoryAndUsageTypeBeforeActivate_fail() {
    SBQQ__Quote__c quote = [
      SELECT
        Id,
        Name,
        SBQQ__Account__c,
        SBQQ__Opportunity2__c,
        (
          SELECT
            Id,
            Name,
            Auto_Ship__c,
            Installments__c,
            Lease__c,
            Lease_Type__c,
            SBQQ__Number__c,
            SBQQ__NetPrice__c,
            Supplier__c,
            CPQ_Material_Type__c,
            SBQQ__PricebookEntryId__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    Test.startTest();

    Account account = new Account(Id = quote.SBQQ__Account__c);
    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed/Installed', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

    // Get the order
    Order order = [
      SELECT
        Id,
        (
          SELECT
            Id,
            SAP_Usage_Type__c,
            SAP_Item_Category__c,
            Product2.Name,
            SBQQ__QuoteLine__r.Auto_Ship__c,
            SBQQ__QuoteLine__r.SBQQ__Bundle__c,
            SBQQ__QuoteLine__r.Is_Spread_Commitment_Line__c
          FROM OrderItems
        )
      FROM Order
      WHERE SBQQ__Quote__c = :quote.Id
      LIMIT 1
    ];

    System.assertEquals(8, order.OrderItems.size());

    // Populate Item Categoty and Usage Type, except bundle parents and spread lines
    for (OrderItem oi : order.OrderItems) {
      if (oi.SBQQ__QuoteLine__r.SBQQ__Bundle__c) {
        continue;
      }

      if (oi.SBQQ__QuoteLine__r.Is_Spread_Commitment_Line__c) {
        continue;
      }

      // Clear some Item Category fields to
      oi.SAP_Item_Category__c = null;
      oi.SAP_Usage_Type__c = null;
    }
    update order.OrderItems;

    // Activate Order
    order.Status = 'Activated';
    order.Pre_Installation_checklist_completed__c = true;

    Boolean exceptionThrown = false;
    try {
      update order;
    } catch (System.DmlException ex) {
      exceptionThrown = true;
    }
    System.Assert(exceptionThrown, 'No exception was thrown on update.');

    // Refresh Order
    order = [SELECT Id, Status FROM Order WHERE Id = :order.Id LIMIT 1];
    System.assertNotEquals('Activated', order.Status);
  }

  @istest
  public static void validateWithPreInstallRTAssignment() {
    SBQQ__Quote__c quote = [
      SELECT
        Id,
        Name,
        SBQQ__Account__c,
        SBQQ__Opportunity2__c,
        (
          SELECT
            Id,
            Name,
            Auto_Ship__c,
            Installments__c,
            Lease__c,
            Lease_Type__c,
            SBQQ__Number__c,
            SBQQ__NetPrice__c,
            Supplier__c,
            CPQ_Material_Type__c,
            SBQQ__PricebookEntryId__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    Test.startTest();

    Account account = new Account(Id = quote.SBQQ__Account__c);
    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed/Installed', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

    // Get the order
    Order order = [
      SELECT
        Id,
        RecordTypeId,
        (
          SELECT
            Id,
            SAP_Usage_Type__c,
            SAP_Item_Category__c,
            Product2.Name,
            SBQQ__QuoteLine__r.Auto_Ship__c,
            SBQQ__QuoteLine__r.SBQQ__Bundle__c,
            SBQQ__QuoteLine__r.Is_Spread_Commitment_Line__c
          FROM OrderItems
        )
      FROM Order
      WHERE SBQQ__Quote__c = :quote.Id
      LIMIT 1
    ];

    System.assertEquals(
      OrderHandler.preInstallOrderRTId,
      order.RecordTypeId,
      'Is_PreInstallCheckList_Enable__c = true should have Pre-Install Record Type'
    );
  } 

  @istest
  public static void validateWithoutPreInstallRTAssignment() {
    SBQQ__Quote__c quote = [
      SELECT
        Id,
        Name,
        SBQQ__Account__c,
        SBQQ__Opportunity2__c,
        (
          SELECT
            Id,
            Name,
            Auto_Ship__c,
            Installments__c,
            Lease__c,
            Lease_Type__c,
            SBQQ__Number__c,
            SBQQ__NetPrice__c,
            Supplier__c,
            CPQ_Material_Type__c,
            SBQQ__PricebookEntryId__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    Market__c usMarket = [
      SELECT 
        Id,
        Is_PreInstallCheckList_Enable__c 
      FROM Market__c 
      WHERE Name = 'United States' 
      LIMIT 1
    ];
    usMarket.Is_PreInstallCheckList_Enable__c = false;
    update usMarket;

    Test.startTest();

    Account account = new Account(Id = quote.SBQQ__Account__c);
    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed/Installed', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

    // Get the order
    Order order = [
      SELECT
        Id,
        RecordTypeId,
        (
          SELECT
            Id,
            SAP_Usage_Type__c,
            SAP_Item_Category__c,
            Product2.Name,
            SBQQ__QuoteLine__r.Auto_Ship__c,
            SBQQ__QuoteLine__r.SBQQ__Bundle__c,
            SBQQ__QuoteLine__r.Is_Spread_Commitment_Line__c
          FROM OrderItems
        )
      FROM Order
      WHERE SBQQ__Quote__c = :quote.Id
      LIMIT 1
    ];

    System.assertEquals(
      OrderHandler.withoutPreInstallOrderRTId,
      order.RecordTypeId,
      'Is_PreInstallCheckList_Enable__c = false should have Without Pre-Install Record Type'
    );
  } 
}