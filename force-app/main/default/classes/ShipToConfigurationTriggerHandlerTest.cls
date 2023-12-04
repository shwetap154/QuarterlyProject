/**
 * @description       : Test class for ShipToConfigurationTriggerHandler class 
 * @author            : Ramiro Alvarez @ ATG - Advanced Technology Group.
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   09-07-2020   Ramiro Alvarez @ ATG        Created the Class. Added the initial test functions.
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc   Add class header
 * 1.2   01-13-2023   Mila Imas @ Zoetis Inc   Add inst date
 **/
@istest
public class ShipToConfigurationTriggerHandlerTest {

    @TestSetup
    static void setup() {
    	// Disable Triggers to improve performance and save on limits
    	DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('AddressTriggerHandler');
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        DispatchTriggerHandler.bypass('OpportunityTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
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

        // Create an opportunity for the account in the US Market
        Opportunity oppty = CPQ_TestDataFactory.createOppty(account, usMarket, true);

        // Crete an empty quote
        SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, account, contact, false);
        quote.Address__c = soldToAddress.Id;
        quote.Ship_To_Address__c = soldToAddress.Id;
        quote.Bill_To_Address__c = soldToAddress.Id;
        quote.Payer_Address__c= soldToAddress.Id;
        quote.Requested_Installation_Date__c  = date.today().addMonths(1);
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

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{childLine1,childLine2};
        insert lines;
        test.stopTest();

    }

    @istest
    public static void testGetShipToLocations_DefaultShipTo() {

        Ship_To_Configuration__c config = [SELECT Id, Default_Ship_To_Location__c FROM Ship_To_Configuration__c];
        System.debug('Test, config: ' + config);

        System.assertEquals(true, config.Default_Ship_To_Location__c, 'Default Ship to should be TRUE since is the unique record');
        
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c][0];
        Account account = [SELECT Id FROM Account][0];

        Address__c secondAddress = CPQ_TestDataFactory.createAddress(account, false);
          secondAddress.ZTS_US_Source_Account_Number__c = '1000009538';
        insert secondAddress;        

        Ship_to_Configuration__c newConfig = new Ship_to_Configuration__c(
            Quote__c = quote.Id,
            Ship_to_Address__c = secondAddress.Id,
            Default_Ship_To_Location__c = true,
            Quantity__c = 1
          );

        Test.startTest();
        insert newConfig;
        Test.stopTest();


        Ship_To_Configuration__c afterInsertconfig = [SELECT Id, Default_Ship_To_Location__c FROM Ship_To_Configuration__c WHERE Id = :config.Id];
        System.debug('Test, config after 2nd insertion: ' + afterInsertconfig);
        System.debug('Test, new Config: ' + newConfig);

        System.assertEquals(false, afterInsertconfig.Default_Ship_To_Location__c, 'Default Ship now should be FALSE');
    }

    
}