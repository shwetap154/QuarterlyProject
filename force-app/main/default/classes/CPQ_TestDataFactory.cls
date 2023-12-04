/**
 * @description       : Utils class to create any types of data used in all test classes for the CPQ build
 * @author            : Cory Bartholomew @ ATG and  Cesar Sandrigo @ ATG - Advanced Technology Group  
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
* 1.0   06-18-2019    Cory Bartholomew @ ATG      Created the Class.
* 2.0   02-05-2020    Cory Bartholomew @ ATG      Added descriptions.
* 2.1   06-06-2020    Cesar Sandrigo @ ATG        Added creation of CPQ Localization objects
* 2.2   03-22-2022    Ethan Hirsch @ Zoetis Inc   Update Contact creation to set fields required by a Validation Rule.
* 2.2   03-22-2022    Mila Imas @ Zoetis Inc      Update Quote creation to set required field.
* 2.3   08-15-2023    Nicholas Grasseschi @ CTS   Update Opportunity, Quote, and Order creation to set field values values based on related records
**/

@IsTest
public with sharing class CPQ_TestDataFactory {
  public static Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();

  public void activateOrder(Order order) {
    order.status = 'Activated';
    order.SBQQ__PriceCalcStatus__c = 'Not Needed';
    update order;
  }

  public static Account createAccount(Boolean doInsert) {
    Account account = new Account();
    account.Name = 'Test';
    account.ZTS_EU_Market__c = 'United States';
    account.Practice_Management_Software__c = 'Animana';
    account.BillingPostalCode = '00000';
    account.BillingCity = 'testCity';
    account.BillingState = 'testState';
    account.BillingStreet = 'testStreet';
    account.ZTS_EU_District__c = 'test';
    if (doInsert) {
      insert account;
    }
    return account;
  }

  public static Lead createLead(Boolean doInsert) {
    Lead lead = new Lead();
    lead.IsConverted = false;
    lead.Lead_Assignment_Status__c = '';
    lead.FirstName = 'US';
    lead.LastName = 'QATEST';
    lead.Lead_Assignment_Processed__c = false;
    lead.State = 'mt';
    lead.Status = 'Open';
    if (doInsert) {
      insert lead;
    }
    return lead;
  }

  public static Lead createLead(
    String firstName,
    String lastName,
    String street,
    String city,
    String state,
    String postalCode,
    String country,
    String companyName,
    Boolean doInsert
  ) {
    Lead lead = new Lead();
    lead.IsConverted = false;
    lead.Lead_Assignment_Status__c = '';
    lead.FirstName = firstName;
    lead.LastName = lastName;
    lead.Lead_Assignment_Processed__c = false;
    lead.Street = street;
    lead.City = city;
    lead.State = state;
    lead.PostalCode = postalCode;
    lead.Country = country;
    lead.Company = companyName;
    lead.Status = 'Open';
    if (doInsert) {
      insert lead;
    }
    return lead;
  }

  public static Address__c createAddress(Account acc, Boolean doInsert) {
    State_Country__c stateCountry = new State_Country__c();
    stateCountry.Name = 'Madrid';
    stateCountry.ZTS_EU_Country__c = 'Spain';
    insert stateCountry;

    return createAddress(acc, stateCountry, doInsert);
  }

  public static Address__c createAddress(Account acc, State_Country__c stateCountry, Boolean doInsert) {
    Address__c address = new Address__c();
    address.RecordTypeId = getRecordType('ZTS_EU_Account_Address');
    address.Name = 'Evergreen Av. 1234';
    address.ZTS_EU_Account__c = acc.Id;
    address.ZTS_EU_Address_Type__c = 'Invoice';
    address.ZTS_EU_Country__c = 'Spain';
    address.ZTS_EU_District__c = 'Madrid';
    address.Zip_Postal_Code__c = '1234';
    address.ZTS_EU_State_County__c = stateCountry.Id;
    address.ZTS_US_Source_Account_Number__c = '1000009537';

    if (doInsert) {
      insert address;
    }
    return address;
  }

  public static List<Market__c> createMarkets(Boolean doInsert) {
    List<Market__c> markets = new List<Market__c>();

    markets.add(
      new Market__c(
        Name = 'United Kingdom',
        CurrencyIsoCode = 'GBP',
        Distribution_Channel__c = 'x',
        Price_Book__c = Test.getStandardPricebookId(),
        Sales_Org__c = '7974',
        Vistex_Order_Type__c = 'xx',
        Vistex_Pricing_Procedure__c = 'xx',
        Item_Value_after_Vistex_Discount__c = 'COND_SUBTOT4'
      )
    );

    markets.add(
      new Market__c(
        Name = 'Australia',
        CurrencyIsoCode = 'USD',
        Distribution_Channel__c = 'x',
        Price_Book__c = Test.getStandardPricebookId(),
        Sales_Org__c = '7903',
        Vistex_Order_Type__c = 'xx',
        Vistex_Pricing_Procedure__c = 'xx',
        Item_Value_after_Vistex_Discount__c = 'COND_SUBTOT4'
      )
    );

    markets.add(
      new Market__c(
        Name = 'Brazil',
        CurrencyIsoCode = 'BRL',
        Distribution_Channel__c = 'x',
        Price_Book__c = Test.getStandardPricebookId(),
        Sales_Org__c = '2116',
        Vistex_Order_Type__c = 'xx',
        Vistex_Pricing_Procedure__c = 'xx',
        Item_Value_after_Vistex_Discount__c = 'COND_SUBTOT4'
      )
    );

    markets.add(
      new Market__c(
        Name = 'Mexico',
        CurrencyIsoCode = 'MXN',
        Distribution_Channel__c = 'x',
        Price_Book__c = Test.getStandardPricebookId(),
        Sales_Org__c = '7945',
        Vistex_Order_Type__c = 'xx',
        Vistex_Pricing_Procedure__c = 'xx',
        Item_Value_after_Vistex_Discount__c = 'COND_SUBTOT4'
      )
    );

    markets.add(
      new Market__c(
        Name = 'United States',
        CurrencyIsoCode = 'USD',
        Distribution_Channel__c = '10',
        Division__c = '00',
        Price_Book__c = Test.getStandardPricebookId(),
        Sales_Org__c = '1436',
        Vistex_Order_Type__c = 'ZC01',
        Vistex_Pricing_Procedure__c = 'YSTC01',
        Item_Value_after_Vistex_Discount__c = 'COND_SUBTOT4',
        Add_Consumables_Ancillaries_Available__c= true,
        Is_PreInstallCheckList_Enable__c = true
      )
    );

    markets.add(
      new Market__c(
        Name = 'Canada',
        CurrencyIsoCode = 'CAD',
        Distribution_Channel__c = 'x',
        Price_Book__c = Test.getStandardPricebookId(),
        Sales_Org__c = '7910',
        Vistex_Order_Type__c = 'xx',
        Vistex_Pricing_Procedure__c = 'xx',
        Item_Value_after_Vistex_Discount__c = 'COND_SUBTOT4'
      )
    );
    if (doInsert) {
      insert markets;
      createCPQHarcodedCustomSettings_MarketIds(markets);
    }
    return markets;
  }

  public static void createCPQHarcodedCustomSettings_MarketIds(List<Market__c> markets) {
    CPQ_Hardcoded_Ids__c hardcodedMarketIds = new CPQ_Hardcoded_Ids__c();
    hardcodedMarketIds.SetupOwnerId = UserInfo.getOrganizationId();

    for (Market__c market : markets) {
      switch on market.Name {
        when 'Australia' {
          hardcodedMarketIds.Market_Australia__c = market.Id;
        }
        when 'Brazil' {
          hardcodedMarketIds.Market_Brazil__c = market.Id;
        }
        when 'Mexico' {
          hardcodedMarketIds.Market_Mexico__c = market.Id;
        }
        when 'United States' {
          hardcodedMarketIds.Market_United_States__c = market.Id;
        }
        when 'Canada' {
          hardcodedMarketIds.Market_Canada__c = market.Id;
        }
        when 'United Kingdom' {
          hardcodedMarketIds.Market_United_Kingdom__c = market.Id;
        }
      }
    }
    insert hardcodedMarketIds;
  }

  public static Market__c getMarketByName(List<Market__c> markets, String name) {
    for (Market__c market : markets) {
      if (market.Name.equalsIgnoreCase(name))
        return market;
    }

    return null;
  }

  public static List<Market_Country__c> createMarketCountrys(List<Market__c> markets, Boolean doInsert) {
    List<Market_Country__c> marketCountrys = new List<Market_Country__c>();

    for (Market__c market : markets) {
      switch on market.Name {
        when 'Canada' {
          marketCountrys.add(
            new Market_Country__c(Country__c = 'Canada', Languages__c = 'EN; FR', Market__c = market.Id, CurrencyIsoCode = 'CAD')
          );
        }
        when 'United States' {
          marketCountrys.add(
            new Market_Country__c(Country__c = 'United States', Languages__c = 'EN', Market__c = market.Id, CurrencyIsoCode = 'USD')
          );
        }
        when 'Mexico' {
          marketCountrys.add(
            new Market_Country__c(Country__c = 'Mexico', Languages__c = 'ES', Market__c = market.Id, CurrencyIsoCode = 'MXN')
          );
        }
        when 'Brazil' {
          marketCountrys.add(
            new Market_Country__c(Country__c = 'Brazil', Languages__c = 'PT', Market__c = market.Id, CurrencyIsoCode = 'BRL')
          );
        }
        when 'Australia' {
          marketCountrys.add(
            new Market_Country__c(Country__c = 'Australia', Languages__c = 'EN', Market__c = market.Id, CurrencyIsoCode = 'USD')
          );
        }
        when 'United Kingdom' {
          marketCountrys.add(
            new Market_Country__c(Country__c = 'United Kingdom', Languages__c = 'EN', Market__c = market.Id, CurrencyIsoCode = 'GBP')
          );
        }
      }
    }
    if (doInsert) {
      insert marketCountrys;
    }
    return marketCountrys;
  }

  public static Contact createContact(Boolean doInsert) {
    //contact
    Contact testContact = new Contact();
    testContact.FirstName = 'Test Last Name1';
    testContact.LastName = 'Test Last Name';
    testContact.ZTS_US_Profession__c='Executive Leadership';
    testContact.ZTS_US_Job_Function__c='CEO/President';
    if (doInsert) {
      insert testContact;
    }
    return testContact;
  }

  public static Opportunity createOppty(Account account, Market__c market, Boolean doInsert) {
    //Oppty
    Opportunity opportunity = new Opportunity();
    opportunity.Name = 'AA Test';
    opportunity.AccountId = account.Id;
    opportunity.CloseDate = Date.Today();
    opportunity.Probability = 10;
    opportunity.TotalOpportunityQuantity = 0;
    opportunity.StageName = 'Qualified';
    opportunity.Customer_Language__c = 'English';
    if (market != null) {
      opportunity.Country1__c = market.Name; 
      opportunity.Market__c = market.Id;
      opportunity.CurrencyIsoCode = market.CurrencyIsoCode;
      opportunity.Pricebook2Id = market.Price_Book__c;
      opportunity.Sales_Org1__c = market.Sales_Org__c + ' ' + market.Name; 
    } else {
      opportunity.Country1__c = 'United States';
      opportunity.CurrencyIsoCode = 'USD';
      opportunity.Pricebook2Id = Test.getStandardPricebookId();
      opportunity.Sales_Org1__c = '1436 United States';
    }
    if (doInsert) {
      insert opportunity;
    }
    return opportunity;
  }

  // FIXME: do not use this method anymore, use the one with the address instead. Remove this method when it has no more references
  public static SBQQ__Quote__c createQuote(Opportunity oppty, Account account, Contact contact, Boolean doInsert) {
    SBQQ__Quote__c quote = new SBQQ__Quote__c();
    quote.SBQQ__Primary__c = true;
    quote.SBQQ__Type__c = 'Quote';
    quote.SBQQ__Status__c = 'Draft';
    quote.SBQQ__Account__c = account.Id;
    quote.SBQQ__ExpirationDate__c = oppty.CloseDate;
    quote.SBQQ__BillingCity__c = 'Aurora';
    quote.SBQQ__BillingCountry__c = 'US';
    quote.SBQQ__BillingName__c = 'H & R BLOCK CENTRAL DENVER';
    quote.SBQQ__BillingPostalCode__c = '80014';
    quote.SBQQ__BillingState__c = 'CO';
    quote.SBQQ__BillingStreet__c = '13693 E. Iliff Ave Ste 110';
    quote.SBQQ__Opportunity2__c = oppty.Id;
    quote.SBQQ__PriceBook__c = Test.getStandardPricebookId();
    quote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
    quote.SBQQ__PrimaryContact__c = contact.Id;
    quote.SBQQ__ShippingCity__c = 'Aurora';
    quote.SBQQ__ShippingCountry__c = 'US';
    quote.SBQQ__ShippingName__c = 'H & R BLOCK CENTRAL DENVER';
    quote.SBQQ__ShippingPostalCode__c = '80014';
    quote.SBQQ__ShippingState__c = 'CO';
    quote.SBQQ__ShippingStreet__c = '13693 E. Iliff Ave Ste 110';
    quote.SBQQ__StartDate__c = Date.today();
    quote.SBQQ__SubscriptionTerm__c = 12;
    quote.Consumable_Supplier__c = 'Zoetis';
    if (doInsert) {
      insert quote;
    }
    return quote;
  }

  public static SBQQ__Quote__c createQuote(Opportunity oppty, Account account, Contact contact, Address__c addr, Boolean doInsert) {
    SBQQ__Quote__c quote = new SBQQ__Quote__c();
    quote.SBQQ__Primary__c = true;
    quote.SBQQ__Type__c = 'Quote';
    quote.SBQQ__Status__c = 'Draft';
    quote.Requested_Installation_Date__c= Date.today();
    quote.SBQQ__Account__c = account.Id;
    quote.SBQQ__ExpirationDate__c = oppty.CloseDate;
    quote.SBQQ__BillingCity__c = 'Aurora';
    quote.SBQQ__BillingCountry__c = 'US';
    quote.SBQQ__BillingName__c = 'H & R BLOCK CENTRAL DENVER';
    quote.SBQQ__BillingPostalCode__c = '80014';
    quote.SBQQ__BillingState__c = 'CO';
    quote.SBQQ__BillingStreet__c = '13693 E. Iliff Ave Ste 110';
    quote.SBQQ__Opportunity2__c = oppty.Id;
    quote.SBQQ__PriceBook__c = oppty.Pricebook2Id;
    quote.SBQQ__PricebookId__c = oppty.Pricebook2Id;
    quote.SBQQ__PrimaryContact__c = contact.Id;
    quote.SBQQ__ShippingCity__c = 'Aurora';
    quote.SBQQ__ShippingCountry__c = 'US';
    quote.SBQQ__ShippingName__c = 'H & R BLOCK CENTRAL DENVER';
    quote.SBQQ__ShippingPostalCode__c = '80014';
    quote.SBQQ__ShippingState__c = 'CO';
    quote.SBQQ__ShippingStreet__c = '13693 E. Iliff Ave Ste 110';
    quote.SBQQ__StartDate__c = Date.today();
    quote.SBQQ__SubscriptionTerm__c = 12;
    quote.Consumable_Supplier__c = 'Zoetis';
    quote.Vistex_Price_In_Sync__c = true;
    quote.Address__c = addr.Id;
    quote.Bill_To_Address__c = addr.Id;
    quote.Payer_Address__c = addr.Id;
    quote.Ship_To_Address__c = addr.Id;
    quote.CurrencyIsoCode = oppty.CurrencyIsoCode;

    if (doInsert) {
      insert quote;
    }
    return quote;
  }

  public static Product2 createProduct(Boolean doInsert) {
    return createProduct(null, doInsert);
  }

  public static Product2 createProduct(SAP_Material__c sapMaterial, Boolean doInsert) {
    Product2 product = new Product2();
    product.Name = sapMaterial != null ? sapMaterial.CPQ_Material_Type__c + ' Product' : 'Digital Package';
    product.Description = 'Digital Package';
    product.Family = 'Test Product Digital';
    product.IsActive = true;
    product.ProductCode = sapMaterial != null
      ? sapMaterial.SAP_Product_Number__c
      : String.valueOf(Integer.valueof(Math.random() * 1000000000));
    product.SBQQ__AssetAmendmentBehavior__c = 'Default';
    product.SBQQ__AssetConversion__c = 'One per quote line';
    product.SBQQ__BillingFrequency__c = 'Monthly';
    product.SBQQ__BillingType__c = 'Advance';
    product.SBQQ__BlockPricingField__c = 'Quantity';
    product.SBQQ__ChargeType__c = 'Recurring';
    product.SBQQ__ConfigurationEvent__c = 'Always';
    product.SBQQ__ConfigurationType__c = 'Allowed';
    product.SBQQ__DefaultQuantity__c = 1;
    product.SBQQ__HasConfigurationAttributes__c = true;
    product.SBQQ__OptionLayout__c = 'Sections';
    product.SBQQ__PriceEditable__c = true;
    product.SBQQ__PricingMethod__c = 'List';
    product.SBQQ__QuantityEditable__c = true;
    product.SBQQ__QuantityScale__c = 0;
    product.SBQQ__SubscriptionBase__c = 'List';
    product.SBQQ__SubscriptionPricing__c = 'Fixed Price';
    product.SBQQ__SubscriptionTerm__c = 1;
    product.SBQQ__SubscriptionType__c = 'Renewable';
    product.SAP_Material__c = sapMaterial == null ? null : sapMaterial.Id;
    product.Product_External_ID__c = ApexUtils.randomString(30);
    if (doInsert) {
      insert product;
    }
    return product;
  }

  public static Pricebook2 createPricebook(String name, String salesOrg, Boolean doInsert) {
    //pricebook entry
    Pricebook2 pb = new Pricebook2();
    pb.Name = name;
    pb.SAP_Sales_Org_ID__c = salesOrg;
    pb.IsActive = true;

    if (doInsert) {
      insert pb;
    }
    return pb;
  }

  public static List<PricebookEntry> createPriceBookEntries(List<Product2> products, Boolean doInsert) {
    List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();

    for (Product2 prod : products) {
      priceBookEntries.add(createPriceBookEntry(prod, false));
    }

    if (doInsert) {
      insert priceBookEntries;
    }
    return priceBookEntries;
  }

  public static PricebookEntry createPriceBookEntry(Product2 product, Boolean doInsert) {
    return createPriceBookEntry(product, new Pricebook2(Id = Test.getStandardPricebookId()), 'USD', doInsert);
  }

  public static PricebookEntry createPriceBookEntry(Product2 product, String currencyCode, Boolean doInsert) {
    return createPriceBookEntry(product, new Pricebook2(Id = Test.getStandardPricebookId()), currencyCode, doInsert);
  }

  public static PricebookEntry createPriceBookEntry(Product2 product, Pricebook2 pricebook, String currencyCode, Boolean doInsert) {
    return createPriceBookEntry(product, pricebook, currencyCode, null, doInsert);
  }

  public static PricebookEntry createPriceBookEntry(
    Product2 product,
    Pricebook2 pricebook,
    String currencyCode,
    SAP_Price_Entry__c priceEntry,
    Boolean doInsert
  ) {
    //pricebook entry
    PricebookEntry testPbEntry = new PricebookEntry();
    testPbEntry.Pricebook2Id = pricebook.Id;
    testPbEntry.Product2Id = product.Id;
    testPbEntry.UnitPrice = 10;
    testPbEntry.IsActive = true;
    testPbEntry.CurrencyIsoCode = currencyCode;
    testPbEntry.SAP_Price_Entry__c = priceEntry == null ? null : priceEntry.Id;
    if (doInsert) {
      insert testPbEntry;
    }
    return testPbEntry;
  }

  public static SBQQ__QuoteLine__c createQuoteLine(SBQQ__Quote__c quote, Product2 product, Boolean doInsert) {
    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
    quoteLine.SBQQ__BillingFrequency__c = product.SBQQ__BillingFrequency__c;
    quoteLine.SBQQ__BillingType__c = product.SBQQ__BillingType__c;
    quoteLine.SBQQ__Bundle__c = false;
    quoteLine.SBQQ__ChargeType__c = product.SBQQ__ChargeType__c;
    quoteLine.SBQQ__PricingMethod__c = product.SBQQ__PricingMethod__c;
    quoteLine.SBQQ__ComponentListTotal__c = 100;
    quoteLine.SBQQ__ComponentTotal__c = 100;
    quoteLine.SBQQ__CustomerPrice__c = 100;
    quoteLine.SBQQ__Description__c = product.Description;
    quoteLine.SBQQ__ListPrice__c = 100;
    quoteLine.SBQQ__NetPrice__c = 100;
    quoteLine.SBQQ__OriginalPrice__c = 100;
    quoteLine.SBQQ__PartnerPrice__c = 100;
    quoteLine.SBQQ__Product__c = product.Id;
    quoteLine.SBQQ__PricebookEntryId__c = null;
    quoteLine.SBQQ__ProrateMultiplier__c = 1;
    quoteLine.SBQQ__ProratedListPrice__c = 100;
    quoteLine.SBQQ__ProratedPrice__c = 100;
    quoteLine.SBQQ__Quantity__c = 1;
    quoteLine.SBQQ__Quote__c = quote.Id;
    quoteLine.SBQQ__RegularPrice__c = 100;
    quoteLine.SBQQ__SpecialPrice__c = 100;
    quoteLine.SBQQ__SubscriptionBase__c = product.SBQQ__SubscriptionBase__c;
    quoteLine.SBQQ__SubscriptionPricing__c = product.SBQQ__SubscriptionPricing__c;
    quoteLine.CPQ_Material_Type__c = product.CPQ_Material_Type__c;
    if (doInsert) {
      insert quoteLine;
    }
    return quoteLine;
  }

  public static Order createOrder(Account account, Opportunity opp, SBQQ__Quote__c quote, Boolean doInsert) {
    Order order = new Order();
    order.AccountId = account.Id;
    order.BillingCity = 'St. Petersburg';
    order.BillingCountry = 'US';
    order.BillingPostalCode = '33701';
    order.BillingState = 'FL';
    order.BillingStreet = '312 3rd St S';
    order.CurrencyIsoCode = quote.CurrencyIsoCode;
    order.EffectiveDate = Date.today();
    order.EndDate = Date.today().addMonths(12);
    order.OpportunityId = opp.Id;
    order.Pricebook2Id = quote.SBQQ__PriceBook__c;
    order.SBQQ__ContractingMethod__c = 'By Subscription End Date';
    order.SBQQ__PaymentTerm__c = 'Net 30';
    order.SBQQ__PriceCalcStatus__c = 'Not Started';
    order.SBQQ__Quote__c = quote.Id;
    order.SBQQ__RenewalTerm__c = 1;
    order.ShippingCity = 'St. Petersburg';
    order.ShippingCountry = 'US';
    order.ShippingPostalCode = '33701';
    order.ShippingState = 'FL';
    order.ShippingStreet = '312 3rd St S';
    order.Status = 'Draft';
    order.Type = 'New';
    if (doInsert) {
      insert order;
    }
    return order;
  }

  public static OrderItem createOrderItems(Order order, SBQQ__QuoteLine__c quoteLine, Boolean doInsert) {
    OrderItem oi = new OrderItem();
    oi.EndDate = Date.today().addMonths(12);
    oi.OrderId = order.Id;
    oi.PricebookEntryId = quoteLine.SBQQ__PricebookEntryId__c;
    oi.Quantity = 1;
    oi.SBQQ__Activated__c = true;
    oi.SBQQ__BillingFrequency__c = quoteLine.SBQQ__BillingFrequency__c;
    oi.SBQQ__BillingType__c = quoteLine.SBQQ__BillingType__c;
    oi.SBQQ__BookingsIndicator__c = 'Include';
    oi.SBQQ__ChargeType__c = quoteLine.SBQQ__ChargeType__c;
    oi.SBQQ__ContractAction__c = 'New';
    oi.SBQQ__ContractingMethod__c = 'Inherit';
    oi.SBQQ__DefaultSubscriptionTerm__c = 1;
    oi.SBQQ__OrderedQuantity__c = quoteLine.SBQQ__Quantity__c;
    oi.SBQQ__ProrateMultiplier__c = 1;
    oi.SBQQ__QuoteLine__c = quoteLine.Id;
    oi.SBQQ__QuotedListPrice__c = quoteLine.SBQQ__ListPrice__c;
    oi.SBQQ__QuotedQuantity__c = quoteLine.SBQQ__Quantity__c;
    oi.SBQQ__Status__c = 'Activated';
    oi.SBQQ__SubscriptionPricing__c = quoteLine.SBQQ__SubscriptionPricing__c;
    oi.SBQQ__SubscriptionTerm__c = quoteLine.SBQQ__SubscriptionTerm__c;
    oi.ServiceDate = Date.today();
    oi.UnitPrice = quoteLine.SBQQ__NetPrice__c;
    if (doInsert) {
      insert oi;
    }
    return oi;
  }



  /**
   * @description Creates a SAP_Material__c record.  SAP Materials are converted into Salesforce product2 records
   * @param sapProductNumber The product number from SAP for this record
   * @param baseUoM The base unit of measure
   * @param itemCatGrp The item category group is converted to CPQ Material type which is core to the entire CPQ build
   *                'LEAS' = Operational Lease
   *                'Z006' = Device
   *                'NORM' = Consumable
   *                'Z011' = Aggregate Commitment Service Item
   *                'ZANC' = Ancillary
   *                'DIEN' = Extended Warranty
   *                'ZIEN' = Standard Warranty
   *                'ZCRE' = Credit or Cash Back
   *                'Z013' = Credit or Cash Back
   *                'ZDEB' = Debit or Contract Charge
   *                'LEIS' = Service for Extended Warranty Items
   *                'Z012' = Service Item with Billing Plan
   * @param prodHierarchy The hierarchy number that SAP uses to dertime product type texts
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return a SAP_Material__c record
   */
  public static SAP_Material__c createSAPMaterial(
    String baseUoM,
    String sapProductNum,
    String itemCatGrp,
    String matType,
    String prodHierarchy,
    Boolean doInsert
  ) {
    SAP_Material__c material = new SAP_Material__c();
    material.SAP_Base_Unit_of_Measure__c = baseUoM;
    material.SAP_Product_Number__c = sapProductNum;
    material.SAP_Item_Category_Group__c = itemCatGrp;
    material.SAP_Material_Type__c = matType;
    material.SAP_Product_Hierarchy__c = prodHierarchy;

    if (doInsert) {
      insert material;
    }
    return material;
  }

  /**
   * @description Creates a SAP_Price_Entry__c record.  SAP Price Entries are converted to CPQ pricebook entries
   * @param sapProductNumber The product number to match to the SAP Material record for this price entry.
   * @param salesOrg The sales org this price entry will be entered for.  Each sales org has its own pricebook.
   * @param unitPrice The list price that will be set on the CPQ pricebook entry
   * @param currCode the currency ISO code to use for this price entry
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return a SAP_Price_Entry__c record
   */
  public static SAP_Price_Entry__c createSAPPriceEntry(
    String sapProductNumber,
    String salesOrg,
    Decimal unitPrice,
    String currCode,
    Boolean doInsert
  ) {
    Date today = Date.today();
    return createSAPPriceEntry(sapProductNumber, salesOrg, unitPrice, today.addDays(-10), today.addDays(10), currCode, 'ST', doInsert);
  }

  /**
   * @description Creates a SAP_Price_Entry__c record.  SAP Price Entries are converted to CPQ pricebook entries
   * @param sapProductNumber The product number to match to the SAP Material record for this price entry.
   * @param salesOrg The sales org this price entry will be entered for.  Each sales org has its own pricebook.
   * @param unitPrice The list price that will be set on the CPQ pricebook entry
   * @param validFrom The date this price entry is valid from
   * @param validTo The date this price entry is valid to
   * @param currCode the currency ISO code to use for this price entry
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return a SAP_Price_Entry__c record
   */
  public static SAP_Price_Entry__c createSAPPriceEntry(
    String sapProductNumber,
    String salesOrg,
    Decimal unitPrice,
    Date validFrom,
    Date validTo,
    String currCode,
    Boolean doInsert
  ) {
    return createSAPPriceEntry(sapProductNumber, salesOrg, unitPrice, validFrom, validTo, currCode, 'ST', doInsert);
  }

  /**
   * @description Creates a SAP_Price_Entry__c record.  SAP Price Entries are converted to CPQ pricebook entries
   * @param sapProductNumber The product number to match to the SAP Material record for this price entry.
   * @param salesOrg The sales org this price entry will be entered for.  Each sales org has its own pricebook.
   * @param unitPrice The list price that will be set on the CPQ pricebook entry
   * @param validFrom The date this price entry is valid from
   * @param validTo The date this price entry is valid to
   * @param currCode the currency ISO code to use for this price entry
   * @param uom the Unit of Measure for this price entry
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return a SAP_Price_Entry__c record
   */
  public static SAP_Price_Entry__c createSAPPriceEntry(
    String sapProductNumber,
    String salesOrg,
    Decimal unitPrice,
    Date validFrom,
    Date validTo,
    String currCode,
    String uom,
    Boolean doInsert
  ) {
    SAP_Price_Entry__c sapPriceEntry = new SAP_Price_Entry__c();
    sapPriceEntry.List_Price__c = unitPrice;
    sapPriceEntry.SAP_Product_Number__c = sapProductNumber;
    sapPriceEntry.SAP_Sales_Org_Id__c = salesOrg;
    sapPriceEntry.SAP_Valid_From__c = validFrom;
    sapPriceEntry.SAP_Valid_To__c = validTo;
    sapPriceEntry.CurrencyIsoCode = currCode;
    sapPriceEntry.SAP_Unit_of_Measure__c = uom;

    if (doInsert) {
      insert sapPriceEntry;
    }

    return sapPriceEntry;
  }

  /**
   * @description Creates a Product_Description__c record.  Product descriptions are used to determine Product2 names for SAP Materials
   * @param material The parent SAP Material record for this description.
   * @param languageCode The language of the description
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return a Product_Description__c record
   */
  public static Product_Description__c createProductDescription(SAP_Material__c material, String languageCode, Boolean doInsert) {
    Product_Description__c description = new Product_Description__c();
    description.Product_Description__c = 'Product Description';
    description.Product_Name__c = 'Product Name';
    description.SAP_Material__c = material.Id;
    description.SAP_Product_Number__c = material.SAP_Product_Number__c;
    description.Language_Code__c = languageCode;
    if (doInsert) {
      insert description;
    }
    return description;
  }

  /**
   * @description Creates a SBQQ__Localization__c record for the Product Name field
   * @param product The product record.
   * @param langCode The language code of the name
   * @param translatedName The language code of the name
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return a Product_Description__c record
   */
  public static SBQQ__Localization__c createProductNameLocalization(
    Product2 product,
    String langCode,
    String translatedName,
    Boolean doInsert
  ) {
    SBQQ__Localization__c localization = new SBQQ__Localization__c(
      SBQQ__APIName__c = 'Name',
      SBQQ__Label__c = 'Name',
      SBQQ__Language__c = langCode,
      SBQQ__Product__c = product.Id,
      SBQQ__Text__c = translatedName,
      SBQQ__UserDefined__c = false
    );

    if (doInsert) {
      insert localization;
    }
    return localization;
  }

  /**
   * @description Creates a Flexible Group record.
   * @param flexGroupNumber The flexible group number from vistex.
   * @param type The group type from vistex
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return a Flexible_Group__c record
   */
  public static Flexible_Group__c createFlexibleGroup(String flexGroupNumber, String type, Boolean doInsert) {
    Flexible_Group__c flexGroup = new Flexible_Group__c(
      Flexible_Group_Number__c = flexGroupNumber,
      Flexible_Group_Type__c = type,
      Valid_From_Date__c = Date.Today().AddMonths(-1),
      Valid_To_Date__c = Date.Today().AddMonths(1)
    );

    if (doInsert) {
      insert flexGroup;
    }

    return flexGroup;
  }

  /**
   * @description Creates a Flexible Group Item record.
   * @param flexGroupNumber The flexible group number from vistex.
   * @param itemNumber The flexible group item number from vistex.
   * @param sapMaterialNumber The SAP Material that this item represents.
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return a Flexible_Group_Item__c record
   */
  public static Flexible_Group_Item__c createFlexibleGroupItem(
    String flexGroupNumber,
    String itemNumber,
    String sapMaterialNumber,
    Boolean doInsert
  ) {
    Flexible_Group_Item__c flexGroupItem = new Flexible_Group_Item__c(
      External_ID__c = flexGroupNumber + itemNumber,
      Flexible_Group_Category__c = 'MATNR',
      Flexible_Group_Number__c = flexGroupNumber,
      Item_Number__c = itemNumber,
      Quantity__c = 0,
      SAP_Material_Number__c = sapMaterialNumber,
      Set_No__c = '00000001',
      Valid_From_Date__c = Date.Today().AddMonths(-1),
      Valid_To_Date__c = Date.Today().AddMonths(1)
    );

    if (doInsert) {
      insert flexGroupItem;
    }

    return flexGroupItem;
  }

  /*** VISTEX RELATED TEST DATA ***/

  /**
   * @description Creates a Vistex Deal Header record.
   * @param dealNumber The deal number.
   * @param salesOrg Term in months.
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return a Vistex_Deal_Header__c record
   */
  public static Vistex_Deal_Header__c createVistexDealHeader(String dealNumber, String salesOrg, Boolean doInsert) {
    Vistex_Deal_Header__c vistexDealHeader = new Vistex_Deal_Header__c(
      BOART_AG__c = 'ZDLS',
      Commitment_Indicator__c = false,
      CURRENCY__c = 'USD',
      DEALK01_Ext_Id__c = '(DEALK01)' + dealNumber,
      DEALNUM__c = dealNumber,
      DEALNUM_EXT__c = 'FREEDOM2.0',
      DEALTXT__c = 'Text Deal',
      ORGID__c = salesOrg,
      QULAF__c = '008',
      Transaction_Type_CPQ__c = '01',
      VALID_FROM__c = Date.Today().AddMonths(-1),
      VALID_TO__c = Date.Today().AddMonths(11)
    );

    if (doInsert) {
      insert vistexDealHeader;
    }

    return vistexDealHeader;
  }

  /**
   * @description Creates a Vistex Deal Line with 'ZTER' condition type to store Term information in months.
   * @param dealHeader The deal header record. Mandatory fields are: Id, Sales Org and Deal Number.
   * @param term Term in months.
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return Vistex_Deal_Line_E1KOMG__c record
   */
  public static Vistex_Deal_Line_E1KOMG__c createVistexDealLine_Term(Vistex_Deal_Header__c dealHeader, String term, Boolean doInsert) {
    return createVistexDealLine(dealHeader, 'ZTER', null, null, null, term, null, doInsert);
  }

  /**
   * @description Creates a Vistex Deal Line with 'ZEL4' condition type to store Elegibility information.
   * @param dealHeader The deal header record. Mandatory fields are: Id, Sales Org and Deal Number.
   * @param eligibilityFilter Elibility filter.
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return Vistex_Deal_Line_E1KOMG__c record
   */
  public static Vistex_Deal_Line_E1KOMG__c createVistexDealLine_Elegibility(
    Vistex_Deal_Header__c dealHeader,
    String eligibilityFilter,
    Boolean doInsert
  ) {
    return createVistexDealLine(dealHeader, 'ZEL4', null, null, eligibilityFilter, null, null, doInsert);
  }

  /**
   * @description Creates a Vistex Deal Line with a Flexible Group related to it.
   * @param dealHeader The deal header record. Mandatory fields are: Id, Sales Org and Deal Number.
   * @param condType Condition Type. Can be ZDEV or ZCON.
   * @param flexibleGroupNumber Flexible Group Number.
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return Vistex_Deal_Line_E1KOMG__c record
   */
  public static Vistex_Deal_Line_E1KOMG__c createVistexDealLine_FlexibleGroup(
    Vistex_Deal_Header__c dealHeader,
    String condType,
    String flexibleGroupNumber,
    Boolean doInsert
  ) {
    return createVistexDealLine_FlexibleGroup(dealHeader, condType, flexibleGroupNumber, null, doInsert);
  }

  /**
   * @description Creates a Vistex Deal Line with a Flexible Group related to it.
   * @param dealHeader The deal header record. Mandatory fields are: Id, Sales Org and Deal Number.
   * @param condType Condition Type. Can be ZDEV or ZCON.
   * @param flexibleGroupNumber Flexible Group Number.
   * @param flexibleGroupNumber Suffix (grouping).
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return Vistex_Deal_Line_E1KOMG__c record
   */
  public static Vistex_Deal_Line_E1KOMG__c createVistexDealLine_FlexibleGroup(
    Vistex_Deal_Header__c dealHeader,
    String condType,
    String flexibleGroupNumber,
    String suffix,
    Boolean doInsert
  ) {
    List<String> validMaterialLineConditionTypes = new List<String>{ 'ZDEV', 'ZCON' };

    if (!validMaterialLineConditionTypes.contains(condType)) {
      System.assert(
        false,
        'Invalid Condition Type for Flexible Group Line: ' +
        condType +
        '. Use: ZDEV for Device FG, ZCON for Consumable FG'
      );
    }

    return createVistexDealLine(dealHeader, condType, null, flexibleGroupNumber, null, null, suffix, doInsert);
  }

  /**
   * @description Creates a Vistex Deal Line with a Flexible Group related to it.
   * @param dealHeader The deal header record. Mandatory fields are: Id, Sales Org and Deal Number.
   * @param condType Condition Type. Can be ZDEV, ZCON or ZANC.
   * @param materialNumber SAP Material Number.
   * @param preffix Vistex line preffix, for grouping.
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return Vistex_Deal_Line_E1KOMG__c record
   */
  public static Vistex_Deal_Line_E1KOMG__c createVistexDealLine_Material(
    Vistex_Deal_Header__c dealHeader,
    String condType,
    String materialNumber,
    String preffix,
    Boolean doInsert
  ) {
    List<String> validMaterialLineConditionTypes = new List<String>{ 'ZDEV', 'ZCON', 'ZANC' };

    if (!validMaterialLineConditionTypes.contains(condType)) {
      System.assert(
        false,
        'Invalid Condition Type for Material: ' +
        condType +
        '. Use: ZDEV for Devices, ZCON for Consumables, ZANC for Ancillary.'
      );
    }

    return createVistexDealLine(dealHeader, condType, materialNumber, null, null, null, preffix, doInsert);
  }

  /**
   * @description Creates a generic Vistex Deal Line. Please, consider using the specific methods instead of this one.
   * @param dealHeader The deal header record. Mandatory fields are: Id, Sales Org and Deal Number.
   * @param condType Condition Type. Can be ZEL4, ZTER, ZDEV, ZCON or ZANC.
   * @param materialNumber SAP Material Number.
   * @param flexibleGroupNumber Flexible Group Number.
   * @param eligibilityFilter Elibility filter.
   * @param term Term in months.
   * @param preffix Vistex line preffix, for grouping.
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return Vistex_Deal_Line_E1KOMG__c record
   */
  public static Vistex_Deal_Line_E1KOMG__c createVistexDealLine(
    Vistex_Deal_Header__c dealHeader,
    String condType,
    String materialNumber,
    String flexGroupNumber,
    String eligibilityFilter,
    String term,
    String preffix,
    Boolean doInsert
  ) {
    List<Vistex_Deal_Line_E1KOMG__c> vistexDealLineE1KOMGs = new List<Vistex_Deal_Line_E1KOMG__c>();

    Vistex_Deal_Line_E1KOMG__c dealLine = new Vistex_Deal_Line_E1KOMG__c(
      DEALK01_Ext_Id__c = dealHeader.Id,
      LOEVM_KO__c = null,
      E1KOMG_Ext_Id__c = '(E1KOMG)' + Integer.valueof(Math.random() * 100000), // Just a random number
      EBONU__c = preffix,
      EKKOA__c = term,
      KOTBNR__c = 771,
      KSCHL__c = condType, // ZTER = Term, ZEL4 = Elegibility (vakey), ZCON/ZDEV/ZANC = Material (preffix) / Flexible Group
      LIFNR__c = flexGroupNumber,
      MATNR__c = materialNumber,
      VAKEY__c = dealHeader.DEALNUM__c + dealHeader.ORGID__c + '10' + eligibilityFilter // 4000006219143610LSEREAGENTA -> DEAL NUMBER
    );

    if (doInsert) {
      insert dealLine;
    }

    return dealLine;
  }

  /**
   * @description Creates a Vistex Banner Header. Please, consider using the specific methods instead of this one.
   * @param dealHeader The deal header record. Mandatory fields are: Id and Deal Number.
   * @param textId Condition Type. Can be ZEL4, ZTER, ZDEV, ZCON or ZANC.
   * @param language Language. Default: E = English.
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return Vistex_Banner_E1EDKT1__c record
   */
  public static Vistex_Banner_E1EDKT1__c createVistexBanner(
    Vistex_Deal_Header__c dealHeader,
    String textId,
    String language,
    Boolean doInsert
  ) {
    Vistex_Banner_E1EDKT1__c vistexBanner = new Vistex_Banner_E1EDKT1__c(
      DEALK01_Ext_Id__c = dealHeader.Id,
      E1EDKT1_Ext_Id__c = '(E1EDKT1)' + dealHeader.DEALNUM__c + '~ZCPQ',
      TDID__c = 'ZCPQ', // ZCPQ = , ZPRM = Promo text, ZTER = Terms & Cond
      TDOBJECT__c = 'KONA', //
      TDOBNAME__c = dealHeader.DEALNUM__c,
      TSSPRAS__c = String.isBlank(language) ? 'EN' : language // E = English
    );

    if (doInsert) {
      insert vistexBanner;
    }

    return vistexBanner;
  }

  /**
   * @description Creates a Vistex Banner Header. Please, consider using the specific methods instead of this one.
   * @param banner Vistex Deal Banner header.
   * @param textId Condition Type. Can be ZEL4, ZTER, ZDEV, ZCON or ZANC.
   * @param language Language. Default: E = English.
   * @param doInsert Indicates whether the record should be inserted or not.
   * @return a Vistex_Child_Banner_E1EDKT2__c record
   */
  public static Vistex_Child_Banner_E1EDKT2__c createVistexChildBanner(
    Vistex_Banner_E1EDKT1__c banner,
    String text,
    Boolean newLine,
    Integer lineNumber,
    Boolean doInsert
  ) {
    Vistex_Child_Banner_E1EDKT2__c vistexChildBanner = new Vistex_Child_Banner_E1EDKT2__c(
      E1EDKT1_Ext_Id__c = banner.Id,
      E1EDKT2_Ext_Id__c = banner.E1EDKT1_Ext_Id__c + '~' + lineNumber,
      TDFORMAT__c = newLine ? '*' : null,
      TDLINE__c = text
    );

    if (doInsert) {
      insert vistexChildBanner;
    }

    return vistexChildBanner;
  }

  /**
   * @description Creates a Vistex Banner Header. Please, consider using the specific methods instead of this one.
   * @param dealLine Vistex Deal Banner header.
   * @return a Vistex_Child_Banner_E1EDKT2__c record
   */
  public static Condition_Header_E1KONH__c createVistexDealLineItemCondition(Vistex_Deal_Line_E1KOMG__c dealLine, Boolean doInsert) {
    // Random number to simulate SAP Id
    String conditionNumber = String.valueOf(Integer.valueof((Math.random() * 10000))).leftPad(10, '0');

    Condition_Header_E1KONH__c dealLineItemCondition = new Condition_Header_E1KONH__c(
      DATAB__c = Date.Today().AddMonths(-1),
      DATBI__c = Date.Today().AddMonths(11),
      E1KOMG_Ext_Id__c = dealLine.Id,
      E1KONH_Ext_Id__c = '(E1KONH)' + conditionNumber,
      KNUMA_AG__c = '4000006305',
      KNUMH__c = conditionNumber
    );

    if (doInsert) {
      insert dealLineItemCondition;
    }

    return dealLineItemCondition;
  }

  public static Vistex_ZO2C_E1KONP_CPQ__c createVistexDealLineItemConditionChildObject(
    Condition_Header_E1KONH__c condHeader,
    Integer commitmentQty,
    Decimal commitmentValue,
    Integer commitmentTerm,
    String commitmentUoM,
    String shipBy,
    Boolean doInsert
  ) {
    Vistex_ZO2C_E1KONP_CPQ__c dealLineItemConditionChild = new Vistex_ZO2C_E1KONP_CPQ__c(
      Commitment_Unit_Of_Measure__c = null,
      Consumable_Total_Commitment_Qty__c = 0,
      Consumable_Total_Commitment_Value__c = 0,
      Device_Total_Target_Qty__c = 0,
      Device_Total_Target_Value__c = 0,
      E1KONH_Ext_Id__c = condHeader.Id,
      Target_Qty__c = '0.000',
      Target_Value__c = 0,
      Ship_By__c = shipBy,
      ZCOMMIT_QTY__c = commitmentQty != null ? String.valueOf(commitmentQty) : null,
      ZCOMMIT_TERM__c = commitmentTerm != null ? String.valueOf(commitmentTerm) : null,
      ZCOMMIT_VALUE__c = commitmentValue != null ? String.valueOf(commitmentValue) : null,
      ZCOMMITQTY_UOM__c = commitmentUoM != null ? String.valueOf(commitmentUoM) : null,
      ZO2C_E1KONP_CPQ_Ext_Id__c = '(Z02C_E1KONP_CPQ)' + condHeader.KNUMH__c
    );

    if (doInsert) {
      insert dealLineItemConditionChild;
    }

    return dealLineItemConditionChild;
  }

  /** UTILITY METHODS **/

  public static id getRecordType(string developer_name) {
    if (recordTypeMap.size() == 0) {
      Map<id, RecordType> rtmap = new Map<id, RecordType>([SELECT Id, DeveloperName, sobjectType, isActive FROM RecordType]);
      for (Id idKey : rtmap.keyset()) {
        RecordType rt = rtmap.get(idKey);
        recordTypeMap.put(rt.DeveloperName, rt);
      }
      System.debug('All Record Types :' + recordTypeMap);
    }

    return recordTypeMap.get(developer_name).id;
  }

  public static Integer queryCount = 0;
  public static void printQueries(String message) {
    System.debug(
      Logginglevel.ERROR,
      message +
      ' used ' +
      (Limits.getQueries() - queryCount) +
      ' queries. The total queries used is ' +
      Limits.getQueries() +
      ' CPU TIME: ' +
      Limits.getCpuTime() +
      ' ' +
      Limits.getLimitCpuTime()
    );
    queryCount = Limits.getQueries();
  }

  /** Query sobject without subquery */
  public static List<sObject> queryRecordsFromIdsAndName(Set<Id> recordIds, String objectName, String whereClause) {
    Set<Id> idSet = recordIds;
    String soql = 'SELECT ' + getAllFieldsForSObjAsStr(objectName) + ' FROM ' + objectName + ' ' + whereClause;
    System.debug(soql);
    return Database.query(soql);
  }

  /** Query sobject with subquery */
  public static List<sObject> queryRecordsAndChildrenFromIdsAndNames(
    Set<Id> recordIds,
    String parentObjName,
    String childObjName,
    String childObjRelationshipName,
    String whereClause
  ) {
    Set<Id> idSet = recordIds;
    String soql =
      'SELECT ' +
      getAllFieldsForSObjAsStr(parentObjName) +
      ', (SELECT ' +
      getAllFieldsForSObjAsStr(childObjName) +
      ' FROM ' +
      childObjRelationshipName +
      ') FROM ' +
      parentObjName +
      ' ' +
      whereClause;
    System.debug(soql);
    return Database.query(soql);
  }

  /** Get all fields for an sobject as a list - helpful for dynamic SOQL */
  public static List<String> getAllFieldsForSobj(String sobjectName) {
    List<String> allFields = new List<String>(Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap().keySet());
    return allFields;
  }

  /** Get comma delimited string list of all sobject fields */
  public static String getAllFieldsForSObjAsStr(String sobjectName) {
    return String.join(getAllFieldsForSobj(sobjectName), ', ');
  }

  public static User createUser(
    String firstName,
    String lastName,
    String email,
    String userName,
    String nickName,
    String alias,
    Id profileId,
    Id userRoleId,
    Boolean doInsert
  ) {
    User user = new User();
    user.FirstName = firstName;
    user.LastName = lastName;
    user.Email = email;
    user.Username = username;
    user.CommunityNickname = nickName;
    user.Alias = alias;
    user.UserRoleId = userRoleId;
    user.ProfileId = profileId;
    user.TimeZoneSidKey = 'America/Los_Angeles';
    user.LocaleSidKey = 'en_US';
    user.EmailEncodingKey = 'ISO-8859-1';
    user.LanguageLocaleKey = 'en_US';

    if (doInsert) {
      insert user;
    }
    return user;
  }

  public static UserRole createRole(String roleDeveloperName, Boolean doInsert) {
    UserRole r = new UserRole(DeveloperName = roleDeveloperName, Name = roleDeveloperName);

    if (doInsert) {
      insert r;
    }
    return r;
  }

  public static ZTS_EU_Position__c createZoetisPosition(User user, ZTS_EU_Territory__c territory, Boolean doInsert) {
    ZTS_EU_Position__c position = new ZTS_EU_Position__c();

    position.ZTS_EU_Employee__c = user.Id;
    position.ZTS_EU_Territory__c = territory.Id;
    if (doInsert) {
      insert position;
    }
    return position;
  }

  public static ZTS_EU_Territory__c createTerritory(
    String market,
    Id parentTerritoryId,
    String fieldForceName,
    String territoryType,
    Boolean doInsert
  ) {
    ZTS_EU_Territory__c zTSEUTerritory = new ZTS_EU_Territory__c();
    zTSEUTerritory.ZTS_EU_Market__c = market;
    zTSEUTerritory.ZTS_EU_Parent_Territory__c = parentTerritoryId;
    zTSEUTerritory.ZTS_Field_Force_Name__c = fieldForceName;
    zTSEUTerritory.ZTS_EU_Type__c = territoryType;
    zTSEUTerritory.ZTS_Type__c = territoryType;

    if (doInsert) {
      insert zTSEUTerritory;
    }

    return zTSEUTerritory;
  }

  public static ZTS_AccountTerritory__c createAccountTerritory(
    Account acct,
    ZTS_EU_Territory__c territory,
    Boolean sibFlag,
    Boolean doInsert
  ) {
    ZTS_AccountTerritory__c acctTerritory = new ZTS_AccountTerritory__c();
    acctTerritory.ZTS_EU_Account__c = acct.Id;
    acctTerritory.ZTS_SIB_Flag__c = sibFlag;
    acctTerritory.ZTS_EU_Territory__c = territory.Id;
    if (doInsert) {
      insert acctTerritory;
    }
    return acctTerritory;
  }

  public static ZTS_EU_Account_Position__c createAccountPosition(
    Account acct,
    ZTS_EU_Position__c position,
    ZTS_AccountTerritory__c accountTerritory,
    Boolean doInsert
  ) {
    ZTS_EU_Account_Position__c accountPosition = new ZTS_EU_Account_Position__c();
    accountPosition.ZTS_EU_Account__c = acct.Id;
    accountPosition.ZTS_EU_Position__c = position.Id;
    accountPosition.ZTS_AccountTerritory__c = accountTerritory.Id;
    if (doInsert) {
      insert accountPosition;
    }
    return accountPosition;
  }

  public static Ship_to_Configuration__c createShipToConfiguration(
    SBQQ__Quote__c quote,
    Address__c shipToAddress,
    Double quantity,
    Boolean isDefaultShipTo,
    Boolean doInsert
  ) {
    Ship_to_Configuration__c shipToConfig = new Ship_to_Configuration__c(
      Default_Ship_To_Location__c = isDefaultShipTo,
      Quantity__c = quantity,
      Quote__c = quote.Id,
      Ship_to_Address__c = shipToAddress.Id
    );

    if (doInsert) {
      insert shipToConfig;
    }

    return shipToConfig;
  }

  public static Ship_To_Quantity_Override__c createShipToQuantityOverride(
    SBQQ__QuoteLine__c quoteLine,
    Ship_to_Configuration__c shipToConfig,
    Double quantity,
    Boolean doInsert
  ) {
    Ship_To_Quantity_Override__c qtyOverride = new Ship_To_Quantity_Override__c(
      Quantity__c = quantity,
      Quote_Line__c = quoteLine.Id,
      Ship_to_Configuration__c = shipToConfig.Id
    );

    if (doInsert) {
      insert qtyOverride;
    }

    return qtyOverride;
  }
    
    public static User createUser(Boolean doInsert,Id profileId,boolean isActive) {
        User u = new User(
            ProfileId = profileId,
            LastName = 'last',
            Email = 'ravikanth.donthula@zoetis.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            IsActive=isActive,
            PIT_BU__c = '',
            PIT_BUs__c = 'US_Poultry',
            PIT_Filter_BU__c = 'CAD Full Line',
            country = 'United States'
        );
        if (doInsert) {
          insert u;
        }
        return u;
  }
}