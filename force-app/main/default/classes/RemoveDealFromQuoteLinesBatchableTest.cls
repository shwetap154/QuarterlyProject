/**
 * @description       : Test class for RemoveDealFromQuoteLinesBatchable class 
 * @author            : Ramiro Alvarez @ ATG - Advanced Technology Group.
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-23-2020   Ramiro Alvarez @ ATG        Created the Class. Added the initial test functions.
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc   Change class header
 * 1.2   01-13-2023   Mila Imas @ Zoetis Inc   Add inst date
 **/
@isTest
public with sharing class RemoveDealFromQuoteLinesBatchableTest {
    
    @testSetup
    public static void setup() {        

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
        oppty.Purchasing_Contact__c = contact.Id;
        insert oppty;

        // Crete an empty quote
        SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, account, contact, false);
        quote.Address__c = soldToAddress.Id;
        quote.Requested_Installation_Date__c  = date.today().addMonths(1);
        quote.Ship_To_Address__c = soldToAddress.Id;
        quote.Bill_To_Address__c = soldToAddress.Id;
        quote.Payer_Address__c = soldToAddress.Id;
		insert quote;

        // Create SAP materials
		List<SAP_Material__c> materials = new List<SAP_Material__c> {
        	CPQ_TestDataFactory.createSAPMaterial('VL', '000000000010001498', 'NORM', 'ZFER', '', false),
			CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000043', 'DIEN', 'DIEN', '', false)
		};
		insert materials;

        // Create product
        Product2 product = CPQ_TestDataFactory.createProduct(false);
        product.SAP_Material__c = materials[0].Id;

		Product2 productWarranty = CPQ_TestDataFactory.createProduct(false);
        productWarranty.SAP_Material__c = materials[1].Id;

		Product2 productParent = CPQ_TestDataFactory.createProduct(false);
		productParent.Name = 'Bundle parent';
		productParent.Program_Eligibility_Filter__c = 'FREEDOM';

		// Insert products
        insert new List<Product2> { productParent, product, productWarranty };

        // Create PBEs
		insert new List<PricebookEntry> {
        	CPQ_TestDataFactory.createPriceBookEntry(productParent, false),
			CPQ_TestDataFactory.createPriceBookEntry(productWarranty, false),
			CPQ_TestDataFactory.createPriceBookEntry(product, false)
        };
        
        Vistex_Deal_Header__c deal = new Vistex_Deal_Header__c ();
        //Create Vistex Deal header
        deal = CPQ_TestDataFactory.createVistexDealHeader('4000006474', '1436', false);        
        insert deal;

		// Insert bundle parent line
        SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
        parentLine.SBQQ__Bundle__c = true;
        parentLine.Vistex_Deal_Header__c = deal.Id;
        insert parentLine;		
    }

    @istest
    public static void executeBatch() {    
        Vistex_Deal_Header__c deal = [SELECT Id FROM Vistex_Deal_Header__c][0];

        Test.startTest();        
        RemoveDealFromQuoteLinesBatchable batch = new RemoveDealFromQuoteLinesBatchable(deal.Id);
        Database.executeBatch(batch);
        Test.stopTest();
    }     
    
}