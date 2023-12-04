/**
 * @description       : Unit Tests for CustomLookupController class
 * @author            : Cory Bartholomew @ ATG - Advanced Technology Group
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                                              Modification
 * 1.0   09-25-2020   Cory Bartholomew @ ATG - Advanced Technology Group  Initial Version (Based on creation data in International Org)
 * 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc                           Add file header
 **/
@isTest
public class CustomLookupControllerTest {
    @isTest
    static void searchAccountShipToAddressesTest() {
        List<Id> fixedResults = new List<Id>(1);

        List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
        CPQ_TestDataFactory.createMarketCountrys(markets, true);

        // Get US market
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        // Create an account and a contact
        Account account = CPQ_TestDataFactory.createAccount(true);        
        Contact contact = CPQ_TestDataFactory.createContact(true);

        // Create an opportunity for the account in the US Market
        Opportunity oppty = CPQ_TestDataFactory.createOppty(account, usMarket, true);
        // Create Address record
        Address__c address = CPQ_TestDataFactory.createAddress(account, true);
        // Crete an empty quote
        SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, account, contact, address, true);        
         
        
        fixedResults.add(address.Id);
        
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();

        List<LookupSearchResult> results = CustomLookupController.searchAccountShipToAddresses('Evergre',quote.Id,selectedIds);

        System.assertEquals(1, results.size());
        
    }

}