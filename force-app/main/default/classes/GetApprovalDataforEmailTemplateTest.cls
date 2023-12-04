/**
 * @description       : Test class for 'GetApprovalDataforEmailTemplate'.
 * @author            : Ramiro Alvarez @ ATG - Advanced Technology Group
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-24-2021   Ramiro Alvarez @ ATG        Initial Version
 * 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc   Update file header
**/
@istest
public class GetApprovalDataforEmailTemplateTest {
    @testSetup
    public static void setup() {
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
    }

    @istest
    public static void getEmailDataTest() {
        // Get the quote created on set-up
        SBQQ__Quote__c quote = [
            SELECT Id, SBQQ__Account__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];
        
        Id quoteId = quote.Id;

        GetApprovalDataforEmailTemplate g1 = new GetApprovalDataforEmailTemplate ();
        g1.quoteId = quoteId;
        
        List<GetApprovalDataforEmailTemplate.EmailData> test = g1.getEmailData();

        
    }
}