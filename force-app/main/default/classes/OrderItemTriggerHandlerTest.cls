/**
 * @description       : Test class for OrderItemTriggerHandler and OrderItemTrigger trigger
 * @author            : Cesar Sandrigo @ ATG - Advanced Technology Group
 * @group             : 
 * @last modified on  : 07-26-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-19-2019		Cesar Sandrigo @ ATG        Created the Class.
 * 1.1   08-23-2019		Cesar Sandrigo @ ATG        Added test for new methods.
 * 1.2   08-23-2019		Cesar Sandrigo @ ATG        Fixed test cases. Coverage: 88%
 * 1.3   07-26-2022   Ethan Hirsch @ Zoetis Inc   Set Auto_Ship_Frequency__c to fix Unit Tests. 
 *                                                Disable Triggers in test setup to save on limits.
 **/
@istest
public class OrderItemTriggerHandlerTest {
  private static string FLEX_GROUP_NUMBER_QTY = '000156';
  private static string FLEX_GROUP_NUMBER_VALUE = '000157';

  @testSetup
  public static void setup() {
    // Disable Triggers to improve performance and save on limits
    DispatchTriggerHandler.bypass('AccountTriggerHandler');
    DispatchTriggerHandler.bypass('AddressTriggerHandler');
    DispatchTriggerHandler.bypass('ContactTriggerHandler');
    DispatchTriggerHandler.bypass('OpportunityTriggerHandler');
    DispatchTriggerHandler.bypass('UserTriggerHandler');
   /* DispatchTriggerHandler.bypass('QuoteTriggerHandler');
    DispatchTriggerHandler.bypass('QuoteLineTriggerHandler');
    DispatchTriggerHandler.bypass('MarketEnableTriggerHandler');*/
    SBQQ.TriggerControl.disable();
      
    test.startTest();

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

    Contact contact = CPQ_TestDataFactory.createContact(true);

    // Create SAP materials
    List<SAP_Material__c> materials = new List<SAP_Material__c>{
      CPQ_TestDataFactory.createSAPMaterial('VL', '000000000060000040', 'Z006', 'ZFER', '', false), // Device
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000041', 'NORM', 'DIEN', '', false), // Consumable
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000042', 'NORM', 'DIEN', '', false), // Consumable
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000043', 'Z011', 'DIEN', '', false), // Aggregate Commitment Material
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000044', 'ZANC', 'ZHYB', '', false), // Ancillary
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000045', 'ZIEN', 'ZNBW', '', false), // Standard warranty
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000046', 'DIEN', 'ZNBW', '', false), // Extended warranty
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000047', 'ZCRE', 'ZNBW', '', false), // Program Charge - Buy_Out__c
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000048', 'ZCRE', 'ZNBW', '', false), // Program Charge - Cash_Back__c
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000049', 'ZCRE', 'ZNBW', '', false), // Program Charge - Contract_Charge__c
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000050', 'ZDEB', 'ZNBW', '', false), // Program Charge - Program_Transfer_Contract_Charge__c
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000051', 'ZDEB', 'ZNBW', '', false), // Program Charge - Program_Transfer_Residual_Parameter__c
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000052', 'Z012', 'DIEN', '', false), // Program_Transfer_Dev_Between_Contracts__c
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000053', 'ZDEB', 'ZNBW', '', false), // Buy_Out_w_Equipment_Return__c
      CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000054', 'ZDEB', 'ZNBW', '', false) // Buy_Out_w_Equipment_Return__c
    };
    insert materials;

    // Create Program Charge Material Custom Setting
    insert new Program_Charge_Materials__c(
      Buy_Out__c = '000000000060000047',
      Buy_Out_w_Equipment_Return__c = '000000000060000053, 000000000060000054',
      Cash_Back__c = '000000000060000048',
      Contract_Charge__c = '000000000060000049',
      Program_Transfer_Contract_Charge__c = '000000000060000050',
      Program_Transfer_Dev_Between_Contracts__c = '000000000060000052'
    );

    // Create products for each material
    Product2 parentBundle = CPQ_TestDataFactory.createProduct(false);
    parentBundle.Name = 'Bundle parent';
    parentBundle.Program_Eligibility_Filter__c = 'FREEDOM';

    List<Product2> products = new List<Product2>{ parentBundle };

    for (SAP_Material__c material : materials) {
      products.add(CPQ_TestDataFactory.createProduct(material, false));
    }
    insert products;

    // Create PBEs
    List<PricebookEntry> pbeList = CPQ_TestDataFactory.createPriceBookEntries(products, true);
    Map<Id, Id> productPbeMap = new Map<Id, Id>();
    for (PricebookEntry pbe : pbeList) {
      productPbeMap.put(pbe.Product2Id, pbe.Id);
    }

    // Create an opportunity for the account in the US Market
    Opportunity oppty = CPQ_TestDataFactory.createOppty(account, usMarket, true);

        // Create an empty quote
    SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, account, contact, soldToAddress, false);
	quote.Vistex_Price_In_Sync__c = true;
    quote.SBQQ__Status__c = 'Approved';
    insert quote;
      
    // Set Primary Quote. This won't occur when Unit Tests are disabled.
    oppty.SBQQ__PrimaryQuote__c = quote.Id;
    update oppty;

    // Insert bundle parent line
    SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, products[0], false);
    parentLine.SBQQ__Bundle__c = true;
    parentLine.SBQQ__PricebookEntryId__c = productPbeMap.get(products[0].Id);
    insert parentLine;

    // Retrieve all the products
    products = [
      SELECT
        Id,
        Name,
        SBQQ__ChargeType__c,
        SBQQ__PricingMethod__c,
        SAP_Product_Number__c,
        Description,
        SBQQ__SubscriptionBase__c,
        SBQQ__SubscriptionPricing__c,
        CPQ_Material_Type__c,
        CPQ_Material_Type_Group__c,
        SBQQ__BillingType__c,
        SBQQ__BillingFrequency__c
      FROM Product2
      WHERE Name != 'Bundle parent'
    ];

    List<SBQQ__QuoteLine__c> childQuoteLines = new List<SBQQ__QuoteLine__c>();

    // Flag to know if I'm procesing the first consumable or the second. TODO: This can be improved.
    Boolean firstConsumableProcessed = false;

    for (Product2 prod : products) {
      if (prod.CPQ_Material_Type__c.equals('Consumable')) {
        /**  Spread line for Quantity Commitment ***/
        SBQQ__QuoteLine__c quantitySpreadLine = CPQ_TestDataFactory.createQuoteLine(quote, prod, false);
        quantitySpreadLine.SBQQ__PricebookEntryId__c = productPbeMap.get(prod.Id);
        quantitySpreadLine.Supplier__c = 'Zoetis';
        quantitySpreadLine.Estimated_Quantity__c = 10;
        quantitySpreadLine.Is_Spread_Commitment_Line__c = true; // This is set by a price-rule, is not a formula anymore, so I have to set it manually.
        quantitySpreadLine.Flexible_Group__c = FLEX_GROUP_NUMBER_QTY;

        // Second consumable spread line will have auto-ship
        if (firstConsumableProcessed) {
          quantitySpreadLine.Auto_Ship_Quantity__c = 10;
          quantitySpreadLine.Auto_Ship_Day_of_Month__c = '1';
          quantitySpreadLine.Auto_Ship_Frequency__c = 'Monthly';
        }
        childQuoteLines.add(quantitySpreadLine);

        /**  Spread line for Value Commitment ***/
        SBQQ__QuoteLine__c valueSpreadLine = CPQ_TestDataFactory.createQuoteLine(quote, prod, false);
        valueSpreadLine.SBQQ__PricebookEntryId__c = productPbeMap.get(prod.Id);
        valueSpreadLine.Supplier__c = 'Zoetis';
        valueSpreadLine.Estimated_Amount__c = 500;
        valueSpreadLine.Is_Spread_Commitment_Line__c = true;
        valueSpreadLine.Flexible_Group__c = FLEX_GROUP_NUMBER_QTY;

        // Second consumable spread line will have auto-ship
        if (firstConsumableProcessed) {
          valueSpreadLine.Auto_Ship_Quantity__c = 10;
          valueSpreadLine.Auto_Ship_Day_of_Month__c = '1';
          valueSpreadLine.Auto_Ship_Frequency__c = 'Monthly';
        }
        childQuoteLines.add(valueSpreadLine);

        /**  Specific Commitmet Line ***/
        SBQQ__QuoteLine__c specificCommitLine = CPQ_TestDataFactory.createQuoteLine(quote, prod, false);
        specificCommitLine.SBQQ__PricebookEntryId__c = productPbeMap.get(prod.Id);
        specificCommitLine.Specific_Commitment__c = true;
        specificCommitLine.Supplier__c = 'Co-Sourced';
        specificCommitLine.CPQ_Commitment_Quantity__c = 20;
        specificCommitLine.Commitment_UOM__c = 'EA';

        // Second consumable specific commitment line will have auto-ship and zero-price
        if (firstConsumableProcessed) {
          specificCommitLine.Supplier__c = 'Zoetis';
          specificCommitLine.SBQQ__Discount__c = 100;
          specificCommitLine.Auto_Ship_Quantity__c = 10;
          specificCommitLine.Auto_Ship_Day_of_Month__c = '1';
          specificCommitLine.CPQ_Commitment_Quantity__c = 40;
          specificCommitLine.Auto_Ship_Frequency__c = 'Monthly';
        }
        childQuoteLines.add(specificCommitLine);

        firstConsumableProcessed = true;
      } else if (prod.CPQ_Material_Type__c.equals('Aggregate Commitment Service Item')) {
        // Aggregate Commitment Lines

        // Aggregate value line
        SBQQ__QuoteLine__c aggregateValueLine = CPQ_TestDataFactory.createQuoteLine(quote, prod, false);
        aggregateValueLine.SBQQ__PricebookEntryId__c = productPbeMap.get(prod.Id);
        aggregateValueLine.Supplier__c = 'Zoetis';
        aggregateValueLine.CPQ_Commitment_Value__c = 1000;
        aggregateValueLine.Flexible_Group__c = FLEX_GROUP_NUMBER_VALUE;

        // Aggregate quantity line
        SBQQ__QuoteLine__c aggregateQuantityLine = CPQ_TestDataFactory.createQuoteLine(quote, prod, false);
        aggregateQuantityLine.SBQQ__PricebookEntryId__c = productPbeMap.get(prod.Id);
        aggregateQuantityLine.Supplier__c = 'Zoetis';
        aggregateQuantityLine.Flexible_Group__c = FLEX_GROUP_NUMBER_QTY;
        aggregateQuantityLine.CPQ_Commitment_Quantity__c = 20; // Quantity Commitment
        aggregateQuantityLine.Commitment_UOM__c = 'EA';

        childQuoteLines.add(aggregateValueLine);
        childQuoteLines.add(aggregateQuantityLine);
      } else if (prod.CPQ_Material_Type_Group__c.equals('Program Charge')) {
        // Program Charge
        SBQQ__QuoteLine__c ql = CPQ_TestDataFactory.createQuoteLine(quote, prod, false);

        switch on prod.SAP_Product_Number__c {
          when '000000000060000047' {
            ql.Program_Charge_Type__c = 'Buy Out';
          }
          when '000000000060000048' {
            ql.Program_Charge_Type__c = 'Buy Out - Equipment Return';
          }
          when '000000000060000049' {
            ql.Program_Charge_Type__c = 'Cash Back';
          }
          when '000000000060000050' {
            ql.Program_Charge_Type__c = 'Cash Back';
          }
          when '000000000060000051' {
            ql.Program_Charge_Type__c = 'Contract Charge';
          }
          when '000000000060000052' {
            ql.Program_Charge_Type__c = 'PT - Residual Parameter';
          }
          when '000000000060000053' {
            ql.Program_Charge_Type__c = 'PT - Contract Charge';
          }
          when '000000000060000054' {
            ql.Program_Charge_Type__c = 'PT - Transfer Device Between Contracts';
          }
        }
        ql.SBQQ__PricebookEntryId__c = productPbeMap.get(prod.Id);
        ql.Supplier__c = 'Zoetis'; // Default Supplier = Zoetis
        childQuoteLines.add(ql);
      } else {
        // Device, Ancillary, Warranties
        SBQQ__QuoteLine__c ql = CPQ_TestDataFactory.createQuoteLine(quote, prod, false);
        ql.SBQQ__PricebookEntryId__c = productPbeMap.get(prod.Id);
        ql.Supplier__c = 'Zoetis'; // Default Supplier = Zoetis
        childQuoteLines.add(ql);
      }
    }
      
	System.debug('childQuoteLines, size: ' + childQuoteLines.size());
    insert childQuoteLines;


    // Approve quote
   /* quote.Vistex_Price_In_Sync__c = true;
    quote.SBQQ__Status__c = 'Approved';
    update quote;*/

    // Reenable Triggers to be sure they're enabled for Unit Tests
    DispatchTriggerHandler.clearAllBypasses();
    SBQQ.TriggerControl.enable();
    Test.stopTest();
  }

  @istest
  public static void calculateSAPItemCaterogyAndUsageType_OK() {
    SBQQ__Quote__c quote = [SELECT Id, Name, SBQQ__Account__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c LIMIT 1];

    Test.startTest();

    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed Won', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

        //assertNoErrorsWereLogged();

    // Get the order
    Order order = getOrderAndOrderItems(quote.Id);

    // Validate Order and Items were created
    System.assert(order != null);
    System.assertEquals(20, order.OrderItems.size());

    // Validate all the order items have a Usage Type and Item category
    assertItemCategoryAndUsageTypeArePopulated(order.OrderItems);

    for (OrderItem oItem : order.OrderItems) {
      // Device
      if (oItem.SBQQ__QuoteLine__r.CPQ_Material_Type__c == 'Service Item with Billing Plan') {
        // Check item category
        System.assertEquals('Z035', oItem.SAP_Item_Category__c);
        // Check Usage Type
        System.assertEquals('OLC', oItem.SAP_Usage_Type__c);
      }
    }
  }

  @istest
  public static void calculateSAPItemCaterogyAndUsageType_NoProgramChargeType() {
    // Get the quote
    SBQQ__Quote__c quote = [
      SELECT
        Id,
        Name,
        SBQQ__Account__c,
        SBQQ__Opportunity2__c,
        (
          SELECT Id, SBQQ__Number__c, SBQQ__Product__r.CPQ_Material_Type_Group__c, Program_Charge_Type__c
          FROM SBQQ__LineItems__r
          WHERE SBQQ__Product__r.CPQ_Material_Type_Group__c = 'Program Charge'
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
      
	
      
    for (Integer i = 0; i < quote.SBQQ__LineItems__r.size(); i++) {
      SBQQ__QuoteLine__c line = quote.SBQQ__LineItems__r[i];

      switch on (Math.mod(i, 3)) {
        when 0 {
          System.debug('Program_Charge_Type__c was: ' + line.Program_Charge_Type__c + ' - will be: null');
          quoteLinesToUpdate.add(new SBQQ__QuoteLine__c(Id = line.Id, Program_Charge_Type__c = null));
        }
        when 1 {
          System.debug('Program_Charge_Type__c was: ' + line.Program_Charge_Type__c + ' - will be: [empty]');
          quoteLinesToUpdate.add(new SBQQ__QuoteLine__c(Id = line.Id, Program_Charge_Type__c = ''));
        }
        when 2 {
          System.debug('Program_Charge_Type__c was: ' + line.Program_Charge_Type__c + ' - will be: An invalid value');
          quoteLinesToUpdate.add(new SBQQ__QuoteLine__c(Id = line.Id, Program_Charge_Type__c = 'An invalid value'));
        }
      }
    }
    update quoteLinesToUpdate;

    Test.startTest();

    // Order the opportunity
    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed Won', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

    /* Expecting 14 errors
     */
    List<Error_Log__c> errors = [SELECT Id FROM Error_Log__c];
        System.assertEquals(15, errors.size());

    // Get the order
    Order order = getOrderAndOrderItems(quote.Id);

    // Validate Order and Items were created
    System.assert(order != null);
    System.assertEquals(20, order.OrderItems.size());

    List<OrderItem> orderItemsThatAreNoProgramCharge = new List<OrderItem>();

    // Exclude Program Charge lines, since it's expected they don't have a Item Category and Usage type populated for this scenario
    for (OrderItem oi : order.OrderItems) {
      if (
        !oi.SBQQ__QuoteLine__r.CPQ_Material_Type__c.equals('Debit or Contract Charge') &&
        !oi.SBQQ__QuoteLine__r.CPQ_Material_Type__c.equals('Credit or Cash Back')
      ) {
        orderItemsThatAreNoProgramCharge.add(oi);
      }
    }

    // Validate all the order items have a Usage Type and Item category
    assertItemCategoryAndUsageTypeArePopulated(orderItemsThatAreNoProgramCharge);
  }

  @istest
  public static void calculateSAPItemCaterogyAndUsageType_SupplierZoetis_WithInstallment() {
    SBQQ__Quote__c quote = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c LIMIT 1];
	
      Test.startTest();
    // Set an installment plan for the quote
    quote.Installment_Plan__c = true;
    quote.Number_of_Installments__c = 12;
    quote.SBQQ__BillingFrequency__c = 'Monthly';
    quote.Easy_Installments_Max_Time__c = 12;
    update quote;

    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed Won', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

    // Get the order
    Order order = getOrderAndOrderItems(quote.Id);

    // Validate Order and Items were created
    System.assert(order != null);
    System.assertEquals(20, order.OrderItems.size());

    // Validate all the order items have a Usage Type and Item category
    assertItemCategoryAndUsageTypeArePopulated(order.OrderItems);

    for (OrderItem oItem : order.OrderItems) {
      // Device
      if (oItem.SBQQ__QuoteLine__r.CPQ_Material_Type__c == 'Device') {
        // Check item category
        System.assertEquals('Z004', oItem.SAP_Item_Category__c);
        // Check Usage Type
        System.assertEquals('DSD', oItem.SAP_Usage_Type__c);
      }
    }
  }

  @istest
  public static void calculateSAPItemCaterogyAndUsageType_ThirdPartyLease() {
    SBQQ__Quote__c quote = [
      SELECT
        Id,
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
            SBQQ__PricebookEntryId__c,
            SBQQ__PartnerDiscount__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];
	
      Test.startTest();
    // Set the supplier as the Distributor for all of them
    for (SBQQ__QuoteLine__c quoteLine : quote.SBQQ__LineItems__r) {
      // Device: 3rd-party Lease, Zero priced
      if (quoteLine.CPQ_Material_Type__c == 'Device') {
        quoteLine.Lease_Type__c = 'Device Sale/Third Party Lease';
        quoteLine.Lease__c = true;
      }
    }
    update quote.SBQQ__LineItems__r;

    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed Won', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

    // Get the order
    Order order = getOrderAndOrderItems(quote.Id);

    // Validate Order and Items were created
    System.assert(order != null);
    System.assertEquals(20, order.OrderItems.size());

    // Validate all the order items have a Usage Type and Item category
    assertItemCategoryAndUsageTypeArePopulated(order.OrderItems);

    for (OrderItem oItem : order.OrderItems) {
      // Device
      if (oItem.SBQQ__QuoteLine__r.CPQ_Material_Type__c == 'Device') {
        // Check item category
        System.assertEquals('Z021', oItem.SAP_Item_Category__c);
        // Check Usage Type
        System.assertEquals('3PL', oItem.SAP_Usage_Type__c);
      }
    }
  }

  @istest
  public static void calculateSAPItemCaterogyAndUsageType_SalesTypeLease() {
    SBQQ__Quote__c quote = [
      SELECT
        Id,
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
            SBQQ__PricebookEntryId__c,
            SBQQ__PartnerDiscount__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];
      
	Test.startTest();
    // Set the supplier as the Distributor for all of them
    for (SBQQ__QuoteLine__c quoteLine : quote.SBQQ__LineItems__r) {

      // Device: 3rd-party Lease, Zero priced
      if (quoteLine.CPQ_Material_Type__c == 'Device') {
        quoteLine.Lease_Type__c = 'Sales Type Lease';
        quoteLine.Lease__c = true;
      }
    }
    update quote.SBQQ__LineItems__r;

    

    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed Won', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

    // Get the order
    Order order = getOrderAndOrderItems(quote.Id);

    // Validate Order and Items were created
    System.assert(order != null);
    System.assertEquals(20, order.OrderItems.size());

    // Validate all the order items have a Usage Type and Item category
    assertItemCategoryAndUsageTypeArePopulated(order.OrderItems);

    for (OrderItem oItem : order.OrderItems) {
      // Device
      if (oItem.SBQQ__QuoteLine__r.CPQ_Material_Type__c == 'Device') {
        // Check item category
        System.assertEquals('Z021', oItem.SAP_Item_Category__c);
        // Check Usage Type
        System.assertEquals('SL', oItem.SAP_Usage_Type__c);
      }
    }
  }

  /**
   * Lease Type = Sales Type Lease AND Lease = false
   * THEN => Direct Sale
   */
  @istest
  public static void calculateSAPItemCaterogyAndUsageType_SalesTypeLease_NoLease() {
    SBQQ__Quote__c quote = [
      SELECT
        Id,
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
            SBQQ__PricebookEntryId__c,
            SBQQ__PartnerDiscount__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];
	Test.startTest();
    // Set the supplier as the Distributor for all of them
    for (SBQQ__QuoteLine__c quoteLine : quote.SBQQ__LineItems__r) {
      // Device: 3rd-party Lease, Zero priced
      if (quoteLine.CPQ_Material_Type__c == 'Device') {
        quoteLine.Lease_Type__c = 'Sales Type Lease';
        quoteLine.Lease__c = false;
      }
    }
    update quote.SBQQ__LineItems__r;

    

    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed Won', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

    // Get the order
    Order order = getOrderAndOrderItems(quote.Id);

    // Validate Order and Items were created
    System.assert(order != null);
    System.assertEquals(20, order.OrderItems.size());

    // Validate all the order items have a Usage Type and Item category
    assertItemCategoryAndUsageTypeArePopulated(order.OrderItems);

    for (OrderItem oItem : order.OrderItems) {
      // Device
      if (oItem.SBQQ__QuoteLine__r.CPQ_Material_Type__c == 'Device') {
        // Check item category
        System.assertEquals('Z021', oItem.SAP_Item_Category__c);
        // Check Usage Type
        System.assertEquals('DSD', oItem.SAP_Usage_Type__c);
      }
    }
  }

  @istest
  public static void calculateSAPItemCaterogyAndUsageType_OperationalLease() {
    SBQQ__Quote__c quote = [
      SELECT
        Id,
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
            SBQQ__PricebookEntryId__c,
            SBQQ__PartnerDiscount__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];
	Test.startTest();
    // Set the supplier as the Distributor for all of them
    for (SBQQ__QuoteLine__c quoteLine : quote.SBQQ__LineItems__r) {
      // Device: 3rd-party Lease, Zero priced
      if (quoteLine.CPQ_Material_Type__c == 'Device') {
        quoteLine.Lease_Type__c = 'Operating Lease';
        quoteLine.Lease__c = true;
      }
    }
    update quote.SBQQ__LineItems__r;

    

    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed Won', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

    // Get the order
    Order order = getOrderAndOrderItems(quote.Id);

    // Validate Order and Items were created
    System.assert(order != null);
    System.assertEquals(20, order.OrderItems.size());

    // Validate all the order items have a Usage Type and Item category
    assertItemCategoryAndUsageTypeArePopulated(order.OrderItems);

    for (OrderItem oItem : order.OrderItems) {
      // Device
      if (oItem.SBQQ__QuoteLine__r.CPQ_Material_Type__c == 'Device') {
        // Check item category
        System.assertEquals('Z044', oItem.SAP_Item_Category__c);
        // Check Usage Type
        System.assertEquals('OLD', oItem.SAP_Usage_Type__c);
      }
    }
  }

  @istest
  public static void calculateSAPItemCaterogyAndUsageType_SKUCommitment_AutoShip_NoZeroPrice() {
    SBQQ__Quote__c quote = [
      SELECT
        Id,
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
            SBQQ__PricebookEntryId__c,
            SBQQ__PartnerDiscount__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    Test.startTest();

    Opportunity oppty = new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = 'Closed Won', SBQQ__Ordered__c = true);
    update oppty;

    Test.stopTest();

    // Get the order
    Order order = getOrderAndOrderItems(quote.Id);

    // Validate Order and Items were created
    System.assert(order != null);
    System.assertEquals(20, order.OrderItems.size());

    // Validate all the order items have a Usage Type and Item category
    assertItemCategoryAndUsageTypeArePopulated(order.OrderItems);

    for (OrderItem oItem : order.OrderItems) {
      // Device
      if (oItem.Specific_Commitment__c && oItem.Auto_Ship__c) {
        // Check item category
        System.assertEquals('Z003', oItem.SAP_Item_Category__c);
        // Check Usage Type
        System.assertEquals('AS', oItem.SAP_Usage_Type__c);
      }
    }
  }

  /**
   *
   */
  private static void assertItemCategoryAndUsageTypeArePopulated(List<OrderItem> orderItems) {
    for (OrderItem oItem : orderItems) {
      if (oItem.Product2.Name == 'Bundle parent' || oItem.Is_Spread_Commitment_Line__c) {
        continue;
      }

      // Check item category and
      System.assert(
        !String.isBlank(oItem.SAP_Item_Category__c) && !String.isBlank(oItem.SAP_Usage_Type__c),
        'Missing Item Category or the Usage Type [' +
        oItem.SBQQ__QuoteLine__r.CPQ_Material_Type__c +
        ' - ' +
        oItem.SBQQ__QuoteLine__r.Supplier__c +
        ']: ' +
        oItem
      );
    }
  }

  /**
   *
   */
  private static void assertNoErrorsWereLogged() {
    List<Error_Log__c> errors = [SELECT Id, Developer_Message__c, Message__c FROM Error_Log__c];

    if (!errors.isEmpty()) {
      System.debug(LoggingLevel.WARN, 'Error: ' + errors[0]);
    }

    System.assert(errors.isEmpty(), 'One or more errors found: ' + (errors.isEmpty() ? '' : errors[0].Developer_Message__c));
  }

  /**
   *
   */
  private static Order getOrderAndOrderItems(Id quoteId) {
    return [
      SELECT
        Id,
        (
          SELECT
            Id,
            SAP_Usage_Type__c,
            SAP_Item_Category__c,
            Auto_Ship__c,
            UnitPrice,
            Exclude_from_SAP__c,
            Product2.Name,
            SBQQ__QuoteLine__r.Auto_Ship__c,
            SBQQ__QuoteLine__r.CPQ_Material_Type__c,
            SBQQ__QuoteLine__r.Supplier__c,
            Is_Spread_Commitment_Line__c,
            Is_Aggregate_Commitment_Line__c,
            Specific_Commitment__c,
            CPQ_Commitment_Quantity__c
          FROM OrderItems
          WHERE Product2.Name != 'Bundle parent'
        )
      FROM Order
      WHERE SBQQ__Quote__c = :quoteId
      LIMIT 1
    ];
  }
}