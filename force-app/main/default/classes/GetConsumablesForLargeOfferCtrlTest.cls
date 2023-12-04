/**
 * @description       : Test class for 'GetConsumablesForLargeOfferController'.
 * @author            : Ramiro Alvarez @ ATG - Advanced Technology Group
 * @group             : 
 * @last modified on  : 07-26-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-03-2021   Ramiro Alvarez @ ATG        Initial Version
 * 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc   Update file header
 * 1.2   07-26-2022   Ethan Hirsch @ Zoetis Inc   Add Test.startTest and Test.stopTest around
 *                                                GetConsumablesForLargeOfferController to indicate code being tested
 *                                                and reset limits.
**/
@istest
public class GetConsumablesForLargeOfferCtrlTest {

    @testSetup
    public static void setup() {
       Test.startTest();
      // Disable Triggers to reduce limit usage
      SBQQ.TriggerControl.disable();
      DispatchTriggerHandler.bypass('AccountTriggerHandler');
      DispatchTriggerHandler.bypass('AddressTriggerHandler');
      DispatchTriggerHandler.bypass('ContactTriggerHandler');
      DispatchTriggerHandler.bypass('OpportunityTriggerHandler');
        // Create Markets and Market Countries
        List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
        CPQ_TestDataFactory.createMarketCountrys(markets, true);

        Pricebook2 pricebook = CPQ_TestDataFactory.createPricebook('US Pricebook', '1436', false);
        insert pricebook;

        // Get US market
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');               
        usMarket.Price_Book__c = pricebook.Id;
        usMarket.Add_Consumables_Ancillaries_Available__c = true;

        update usMarket;

        // Create an account and a contact
        Account account = CPQ_TestDataFactory.createAccount(true);
        Contact contact = CPQ_TestDataFactory.createContact(false);
        contact.AccountId = account.Id;
        insert contact;

        // Create an opportunity for the account in the US Market
        Opportunity oppty = CPQ_TestDataFactory.createOppty(account, usMarket, false);
        oppty.Purchasing_Contact__c = contact.Id;
        insert oppty;

        // Create Address record
        Address__c address = CPQ_TestDataFactory.createAddress(account, true);

        // Crete an empty quote
        SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, account, contact, address, true);

        // Create SAP material
        SAP_Material__c material = CPQ_TestDataFactory.createSAPMaterial('VL', '000000000010001498', 'NORM', 'ZFER', '', true);

        // Create product
        Product2 product = CPQ_TestDataFactory.createProduct(false);
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

        // Insert bundle parent line
        SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
        parentLine.SBQQ__Bundle__c = true;
        insert parentLine;

        // Insert child line
        SBQQ__QuoteLine__c childLine = CPQ_TestDataFactory.createQuoteLine(quote, product, false);
        childLine.SBQQ__RequiredBy__c = parentLine.Id;
        insert childLine;

        // Create flexible groups
        insert new List<Flexible_Group__c> {
            CPQ_TestDataFactory.createFlexibleGroup('0000004116', 'ZFLX', false)
        };
        insert new List<Flexible_Group_Item__c> {            
            CPQ_TestDataFactory.createFlexibleGroupItem('0000004116', '000001', '000000000010000284', false)            
        };

        // Create SAP material
        SAP_Material__c material2 = CPQ_TestDataFactory.createSAPMaterial('VL', '000000000010000284', 'NORM', 'ZFER', '', true);

        // Create product
        Product2 product2 = CPQ_TestDataFactory.createProduct(false);
        product2.SAP_Material__c = material2.Id;
        product2.ProductCode = '000000000010000284';
        insert product2;
        
        insert new List<PricebookEntry>{          
            CPQ_TestDataFactory.createPriceBookEntry(product2,'USD',false)
        };

        insert new List<PricebookEntry>{          
            CPQ_TestDataFactory.createPriceBookEntry(product2,pricebook,'USD',false)
        };
            
        SBQQ.TriggerControl.enable();
        DispatchTriggerHandler.clearAllBypasses();
        Test.stopTest();
        
    }


    @istest
    public static void getSelectedMaterialsByFlexibleGroupTest() {
        SBQQ.TriggerControl.disable();
        // Get the quote created on set-up
        SBQQ__Quote__c quote = [
            SELECT Id 
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        SBQQ__QuoteLine__c childLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c != NULL];
        childLine.Is_a_consumable_for_LargeOffer__c = TRUE;
        childLine.Flexible_Group__c = 'TEST';
        update childLine;
        SBQQ.TriggerControl.enable();

        Test.startTest();
            GetConsumablesForLargeOfferController.getSelectedMaterialsByFlexibleGroup(quote.Id);
        Test.stopTest();
    }

    @istest
    public static void createQuoteLinesTest() {
        SBQQ.TriggerControl.disable();
        // Get the quote created on set-up
        SBQQ__Quote__c quote = [
            SELECT Id 
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        SBQQ__QuoteLine__c childLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c != NULL];
        //childLine.Is_a_consumable_for_LargeOffer__c = TRUE;
        childLine.CPQ_Material_Type__c = 'Aggregate Commitment Service Item';
        childLine.Flexible_Group__c = '0000004116';
        childLine.Deal_Line_Group__c = '01';
        update childLine;        

        List<String> keyList = new List<String> {'0000004116-01:000000000010000284'};
        SBQQ.TriggerControl.enable();

        Test.startTest();
            GetConsumablesForLargeOfferController.createQuoteLines(quote.Id, keyList);
        Test.stopTest();
    }

    @istest
    public static void getFlexibleGroupTest() {
        // Get the quote created on set-up
        SBQQ__Quote__c quote = [
            SELECT Id 
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        String quoteId = quote.Id;

        Test.startTest();
            GetConsumablesForLargeOfferController.getFlexibleGroups(quoteId);
        Test.stopTest();
    }

    @istest
    public static void getFlexibleGroupItemsTest() {
        SBQQ.TriggerControl.disable();
        // Get the quote created on set-up
        SBQQ__Quote__c quote = [
            SELECT Id 
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        SBQQ__QuoteLine__c childLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c != NULL];
        //childLine.Is_a_consumable_for_LargeOffer__c = TRUE;
        childLine.CPQ_Material_Type__c = 'Aggregate Commitment Service Item';
        childLine.Flexible_Group__c = '0000004116';
        childLine.Deal_Line_Group__c = '01';
        update childLine;  
        SBQQ.TriggerControl.enable();

        Test.startTest();
            GetConsumablesForLargeOfferController.getFlexGroupItems(quote.Id);
        Test.stopTest();
    }




}