/**
 * @description       : Test class for 'CreateQuoteController'.
 * @author            : Facundo Castello @ ATG - Advanced Technology Group
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-19-????   Facundo Castello @ ATG      Created the Class and all the tests
 * 1.1   03-11-2021   Ramiro Alvarez @ ATG        CPQATG-1299 Deprecate Distributor and Leasing Agent
 * 1.2   07-07-2022   Ethan Hirsch @ Zoetis Inc   Change class header
 * 1.3   03-30-2023	  Sourav Mitra @ CTS		  Added test method for checking Opportunity with SAP ID
 **/
@istest
public class CreateQuoteControllerTest {
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
        Address__c distributorAddress = CPQ_TestDataFactory.createAddress(account, true);

         // Create an account and a contact        
        Contact contact = CPQ_TestDataFactory.createContact(false);
        contact.AccountId = account.Id;
        insert contact;

        // Create an opportunity for the account in the US Market
        Opportunity oppty = CPQ_TestDataFactory.createOppty(account, usMarket, true);
        oppty.Purchasing_Contact__c = contact.Id;
        oppty.Distributor_Address__c = distributorAddress.Id;
        update oppty;
    }

    @istest
    public static void getOpportunityData_WrongOpportunity() {
        Test.startTest();
        CreateQuoteController.CreateQuoteResponse response = CreateQuoteController.getOpportunityData('WrongId');
        Test.stopTest();

        CreateQuoteController.CreateQuoteResponse expected = new CreateQuoteController.CreateQuoteResponse();
        expected.AdditionalErrorInfo = 'List has no rows for assignment to SObject';
        expected.Status = 'Error';
        expected.Message = 'There was an error creating the quote. Please contact a Zoetis Administrator.';

        System.assertEquals(null, response.opportunity);
        System.assertEquals('List has no rows for assignment to SObject', response.AdditionalErrorInfo);
        System.assertEquals('Error', response.Status);
        System.assertEquals('There was an error creating the quote. Please contact a Zoetis Administrator.', response.Message);
    }

    @istest
    public static void getOpportunityData_WithOpportunity() {
        //Code added by Sourav for setting the Active Flag to TRUE for all addresses
        List<Address__c> soldToAddress = [SELECT Id, ZTS_US_Source_Account_Number__c, Is_Active__c FROM Address__c WHERE ZTS_US_Source_Account_Number__c != null];
            for(Address__c addr : soldToAddress){
                addr.Is_Active__c = TRUE;
            }
        update soldToAddress;
        
        Opportunity oppty = [
            SELECT
                AccountId,
                Distributor_Address__c,
                Id,
                SBQQ__QuotePricebookId__c,
                Account.ZTS_EU_Primary_Address__c,
                Account.ZTS_EU_Primary_Address__r.ZTS_US_Source_Account_Number__c,
            	Customer_Language__c,Internet_Speed_Available__c
            FROM Opportunity
            LIMIT 1
        ];

        Test.startTest();
        CreateQuoteController.CreateQuoteResponse response = CreateQuoteController.getOpportunityData(oppty.Id);
        Test.stopTest();

        System.debug(response);
    }

    @istest
    public static void createQuote_WithNeededData() {
        Opportunity oppty = [
            SELECT
                AccountId,
                Distributor_Address__c,
                Id,
                SBQQ__QuotePricebookId__c,
                Account.ZTS_EU_Primary_Address__c,
                Account.ZTS_EU_Primary_Address__r.ZTS_US_Source_Account_Number__c,Customer_Language__c,Internet_Speed_Available__c
            FROM Opportunity
            LIMIT 1
        ];
        Boolean primary = true;

        // Account account = CPQ_TestDataFactory.createAccount(true);
        // Address__c leasingAddress = CPQ_TestDataFactory.createAddress(account, true);

        Test.startTest();
        CreateQuoteController.CreateQuoteResponse response = CreateQuoteController.createQuote(
            primary,
            oppty.Id,
            Date.today(),
            oppty.AccountId,
            oppty.Account.ZTS_EU_Primary_Address__c,
            oppty.Customer_Language__c,
            oppty.Internet_Speed_Available__c
            //null,
            //null
        );
        Test.stopTest();
        System.debug(response.AdditionalErrorInfo);

        SBQQ__Quote__c quoteWithName = [SELECT Name FROM SBQQ__Quote__c LIMIT 1];

        System.assertEquals(null, response.opportunity);
        System.assertEquals('OK', response.Status);
        System.assertEquals('Quote ' + quoteWithName.Name + ' has been added.', response.Message);
        System.assertEquals(null, response.AdditionalErrorInfo);
    }

    @istest
    public static void createQuote_WithoutNeededData() {
        Opportunity oppty = [
            SELECT
                AccountId,
                Distributor_Address__c,
                Id,
                SBQQ__QuotePricebookId__c,
                Account.ZTS_EU_Primary_Address__c,
                Account.ZTS_EU_Primary_Address__r.ZTS_US_Source_Account_Number__c
            FROM Opportunity
            LIMIT 1
        ];

        Test.startTest();
        CreateQuoteController.CreateQuoteResponse response = CreateQuoteController.createQuote(
            null,
            null,
            null,
            oppty.AccountId,
            oppty.Account.ZTS_EU_Primary_Address__c,
            null,
            null
            //null,
            //null
        );
        Test.stopTest();

        System.assertEquals('Error', response.Status);
    }

    /* 
    Test Method added by Sourav
    for checking getOpportunityData method
    with SAP Customer ID
    */
    @isTest
    public static void getOppotunityData_withSAPID(){
        Account accnt = [SELECT Id, ZTS_EU_SAP_Customer_ID__c FROM Account LIMIT 1];
        //Address__c soldToAddress = [SELECT Id, ZTS_US_Source_Account_Number__c, Is_Active__c FROM Address__c WHERE ZTS_US_Source_Account_Number__c != null LIMIT 1];
        //soldToAddress.Is_Active__c = TRUE;
        List<Address__c> soldToAddress = [SELECT Id, ZTS_US_Source_Account_Number__c, Is_Active__c FROM Address__c WHERE ZTS_US_Source_Account_Number__c != null];
        for(Address__c addr : soldToAddress){
            addr.Is_Active__c = TRUE;
        }
        update soldToAddress;
        accnt.ZTS_EU_SAP_Customer_ID__c = soldToAddress[0].ZTS_US_Source_Account_Number__c;
        update accnt;
        
        Opportunity oppty = [
            SELECT
                AccountId,
                Distributor_Address__c,
                Id,
                SBQQ__QuotePricebookId__c,
                Account.ZTS_EU_Primary_Address__c,
                Account.ZTS_EU_Primary_Address__r.ZTS_US_Source_Account_Number__c,
            Customer_Language__c,Country1__c,Internet_Speed_Available__c
            FROM Opportunity
            LIMIT 1
        ];
		
        Test.startTest();
        CreateQuoteController.CreateQuoteResponse response = CreateQuoteController.getOpportunityData(oppty.Id);
        Test.stopTest();

        System.debug(response);
    }
    
    /*
     * Test Method created by Sourav 
     * to test the values generated by getPickListValuesIntoList method 
     * in the CreateQuotecontroller class
    */
    @isTest
    public static void getPickListValCheck(){
         Opportunity oppty = [
            SELECT
                AccountId,
                Distributor_Address__c,
                Id,
                SBQQ__QuotePricebookId__c,
                Account.ZTS_EU_Primary_Address__c,
                Account.ZTS_EU_Primary_Address__r.ZTS_US_Source_Account_Number__c,
            	Customer_Language__c,Internet_Speed_Available__c
            FROM Opportunity
            LIMIT 1
        ];
        
        Market__c mrktVal = [Select Id,Name,Change_Customer_Language__c from Market__c Where Name = 'Canada' LIMIT 1];
        System.debug('Market Value *** ' + mrktVal);
        
        List<String> actualVal = CreateQuoteController.getPickListValuesIntoList(oppty.Id);
        
        List<String> expectedValue = new List<String>{'English','French'};
        
        System.debug('Picklist Returned Values *** ' + actualVal);
        System.debug('Picklist Expected Values *** ' + expectedValue);
        
        System.assertEquals(expectedValue, actualVal);
    } 

    //CPQATG-1299 Deprecate Distributors and LeasingAgents test

    /*
    @istest
    public static void getDistributorsAndLeasingAgents() {
        Opportunity oppty = [SELECT Id, Market__c FROM Opportunity LIMIT 1];

        Account distributorAccount = new Account(
            Name = 'Distributor Account',
            ZTS_EU_Market__c = 'United States',
            Practice_Management_Software__c = 'Animana',
            BillingPostalCode = '00000',
            BillingCity = 'testCity',
            BillingState = 'testState',
            BillingStreet = 'testStreet',
            Type = 'Distributor'
        );

        Account lessorAccount = new Account(
            Name = 'Lessor Account',
            ZTS_EU_Market__c = 'United States',
            Practice_Management_Software__c = 'Animana',
            BillingPostalCode = '00000',
            BillingCity = 'testCity',
            BillingState = 'testState',
            BillingStreet = 'testStreet',
            Type = 'Lessor'
        );

        insert new List<Account>{ distributorAccount, lessorAccount };

        Address__c distAddress = CPQ_TestDataFactory.createAddress(distributorAccount, false);
        distAddress.ZTS_US_Source_Account_Number__c = '1000009538';

        Address__c lessorAddress = CPQ_TestDataFactory.createAddress(lessorAccount, false);
        lessorAddress.ZTS_US_Source_Account_Number__c = '1000009539';

        insert new List<Address__c>{ distAddress, lessorAddress };

        // Insert the Distributor and Leasing Agent
        Distributor__c distributor = new Distributor__c(
            Name = 'Great Distributor',
            Address__c = distAddress.Id,
            Sales_Org_Market__c = oppty.Market__c
        );
        insert distributor;

        Leasing_Agent__c leasingAgent = new Leasing_Agent__c(
            Name = 'Amazing Lessor',
            Address__c = lessorAddress.Id,
            Sales_Org_Market__c = oppty.Market__c
        );
        insert leasingAgent;

        Test.startTest();
        Market__c market = CreateQuoteController.getDistributorsAndLeasingAgents(oppty.Market__c);
        Test.stopTest();

        System.assert(market != null);
        System.assert(market.Distributors__r != null);
        System.assert(market.Distributors__r.size() == 1);
        System.assertEquals('Great Distributor', market.Distributors__r[0].Name);
        System.assertEquals(distributor.Id, market.Distributors__r[0].Id);

        System.assert(market.Leasing_Agents__r != null);
        System.assert(market.Leasing_Agents__r.size() == 1);
        System.assertEquals('Amazing Lessor', market.Leasing_Agents__r[0].Name);
        System.assertEquals(leasingAgent.Id, market.Leasing_Agents__r[0].Id);
    }

    */
}