/**
 * @description       : Test classes for EditShipToLocationsController
 * @author            : Cesar Sandrigo @ ATG - Advanced Technology Group
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-27-2020   Cesar Sandrigo @ ATG        Initial Version (Based on Controller class)
 * 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc   Add file header
**/
@istest
public class EditShipToLocationsControllerTest {
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

    Ship_To_Configuration__c config = [SELECT Id FROM Ship_To_Configuration__c];

    EditShipToLocationsController.QuantityOverride qtyOverride = new EditShipToLocationsController.QuantityOverride();
    qtyOverride.QuoteLineId = childLine2.Id;
    qtyOverride.ShipToAddressId = soldToAddress.Id;
    qtyOverride.Quantity = 7;
    qtyOverride.Key = soldToAddress.Id + '' + childLine2.Id;
    qtyOverride.ShipToId = config.Id;
  }

  @istest
  public static void testGetShipToLocations_DefaultShipTo() {
    SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
    System.assertNotEquals(null, quote, 'There was no quote created in testSetup()');
    List<EditShipToLocationsController.ShipToLocation> locations = EditShipToLocationsController.getShipToLocations(quote.Id);
    System.assertEquals(1, locations.size(), 'The default Ship To Location was note created from the quote trigger during testSetup()');
  }

  @istest
  public static void testGetQuoteLines() {
    SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
    System.assertNotEquals(null, quote, 'There was no quote created in testSetup()');
    List<SBQQ__QuoteLine__c> quoteLines = EditShipToLocationsController.getQuoteLines(quote.Id);
    System.assertEquals(3, quoteLines.size(), 'The quote lines were not setup or retrieved correctly');
  }

  @istest
  public static void testSaveShipTo() {
    SBQQ__Quote__c quote = [SELECT Id, Ship_To_Address__c FROM SBQQ__Quote__c LIMIT 1];

    Account acc = [SELECT Id FROM Account LIMIT 1];

    State_Country__c stateCountry = new State_Country__c();
    stateCountry.Name = 'Michigan';
    stateCountry.ZTS_EU_Country__c = 'United States';
    insert stateCountry;

    List<EditShipToLocationsController.ShipToLocation> updatedShipToLocations = EditShipToLocationsController.getShipToLocations(quote.Id);

    Address__c address2 = new Address__c();
    address2.RecordTypeId = CPQ_TestDataFactory.getRecordType('ZTS_EU_Account_Address');
    address2.Name = 'Test Street';
    address2.ZTS_EU_Account__c = acc.Id;
    address2.ZTS_EU_Address_Type__c = 'Invoice';
    address2.ZTS_EU_Country__c = 'United States';
    address2.ZTS_EU_District__c = 'Michigan';
    address2.Zip_Postal_Code__c = '49316';
    address2.ZTS_EU_State_County__c = stateCountry.Id;
    address2.ZTS_US_Source_Account_Number__c = '1000001234';
    insert address2;

    EditShipToLocationsController.ShipToLocation location = new EditShipToLocationsController.ShipToLocation();
    location.IsDefaultShipTo = false;
    location.Index = 2;
    location.BaseQuantity = 2;
    location.ShipToAddressId = address2.Id;
    location.QuoteId = quote.Id;
    updatedShipToLocations.add(location);

    List<SBQQ__QuoteLine__c> lines = EditShipToLocationsController.getQuoteLines(quote.Id);
    for (SBQQ__QuoteLine__c line : lines) {
      System.debug(line);
    }

    EditShipToLocationsController.QuantityOverride qtyOverride = new EditShipToLocationsController.QuantityOverride();
    qtyOverride.QuoteLineId = lines[0].Id;
    qtyOverride.ShipToAddressId = address2.Id;
    qtyOverride.Quantity = 7;
    qtyOverride.Key = address2.Id + '' + lines[0].Id;

    Test.startTest();
    EditShipToLocationsController.saveShipToConfigurations(
      updatedShipToLocations,
      new List<EditShipToLocationsController.QuantityOverride>{ qtyOverride },
      quote.Id
    );
    Test.stopTest();

    List<Ship_To_Configuration__c> configs = [SELECT Id FROM Ship_To_Configuration__c];
    System.assertEquals(2, configs.size(), 'The ship to configurations are incorrect');
  }
}