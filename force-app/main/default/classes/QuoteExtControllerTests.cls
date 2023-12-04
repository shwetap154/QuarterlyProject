/**
 * @description       : Test class for QuoteExtController
 * @author            : Kristin Owens @ ATG
 * @group             : 
 * @last modified on  : 06-08-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-07-2019   Kristin Owens @ ATG         Initial Version
 * 1.1   06-08-2022   Ethan Hirsch @ Zoetis Inc   Fix Unit Test failures due to validation errors
**/
@isTest
private class QuoteExtControllerTests {
     
     @testSetup static void setup() {
                
            Account account = new Account();
            account.Name = 'Test';
            account.ZTS_EU_Market__c = 'United States';
            account.Practice_Management_Software__c = 'Animana';
            account.ZTS_EU_Zip_Postal_Code__c = '12345';
            account.BillingPostalCode = '12345';
            account.BillingCity = 'Boca Raton';
            account.BillingState = 'Florida';
            account.BillingStreet = 'Elm Lane';
            insert account;

            Address__c soldToAddress = CPQ_TestDataFactory.createAddress(account, true);
		    account.ZTS_EU_Primary_Address__c = soldToAddress.Id;
            update account;
         
            List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
            CPQ_TestDataFactory.createMarketCountrys(markets, true);

            // Get US market
            Market__c market = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
         
            Opportunity opportunity = new Opportunity();
            opportunity.Name = 'AA Test';
            opportunity.AccountId = account.Id;
            opportunity.CloseDate = Date.Today();
            opportunity.Country1__c = 'United States';
            opportunity.Customer_Language__c = 'English';
            opportunity.Market__c = market.Id;
            opportunity.CurrencyIsoCode = 'USD';           
            opportunity.Pricebook2Id = Test.getStandardPricebookId();
            opportunity.Probability = 10;
            opportunity.TotalOpportunityQuantity = 0;
            opportunity.Sales_Org1__c = '1436 United States';
            opportunity.StageName = 'Qualified';
            opportunity.ZTS_EU_Market__c = 'United States';
            insert opportunity;
     }      
    
    
    testMethod static void testSubmit() {
       
        Opportunity opp = [SELECT Id,
            AccountId, 
            SAP_Account_ID__c,
            Market__c,  
            Sales_Org1__c, 
            Country1__c,
            CloseDate,
            CurrencyIsoCode,
            Pricebook2Id FROM Opportunity 
            WHERE ZTS_EU_Market__c = 'United States' LIMIT 1];

        System.debug('Opportunity: ' + opp);
        
        SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(opp, new Account(), new Contact(), retrieveTestAddress(), false);
        quote.Vistex_Price_In_Sync__c = true;
        insert quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', quote.ApprovalStatus__c);
    }
    
    testMethod static void testRecall() {
        
        Opportunity opp = [SELECT Id, CloseDate, CurrencyIsoCode, Pricebook2Id FROM Opportunity WHERE ZTS_EU_Market__c = 'United States' LIMIT 1];
        
        SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(opp, new Account(), new Contact(), retrieveTestAddress(), false);
        quote.Vistex_Price_In_Sync__c = true;
        insert quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecall();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Recalled', quote.ApprovalStatus__c);
    }

    testMethod static void testCancel() {
        
        Opportunity opp = [SELECT Id, CloseDate, CurrencyIsoCode, Pricebook2Id FROM Opportunity WHERE ZTS_EU_Market__c = 'United States' LIMIT 1];
        
        SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(opp, new Account(), new Contact(), retrieveTestAddress(), false);
        quote.Vistex_Price_In_Sync__c = true;
        insert quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onCancel();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        // Check status didn't changed
        System.assertEquals(null, quote.ApprovalStatus__c);
    }

    private static Address__c retrieveTestAddress() {
        return [
            SELECT Id
            FROM Address__c
            WHERE ZTS_US_Source_Account_Number__c != null
            LIMIT 1];
    }
}