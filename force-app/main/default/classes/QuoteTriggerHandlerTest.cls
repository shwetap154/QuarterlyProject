/**
* File Name     :  QuoteTriggerHandlerTest
* @description  :  Test class for 'QuoteTriggerHandler'.
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/24         Cesar Sandrigo @ ATG     Created the Class. Added setup and updateVistexPricingInSyncFlag test.
* 1.1     9/01         Mila Imas                added setMATAmounts test
*/
@istest
public class QuoteTriggerHandlerTest {
    @testSetup
    public static void setup() {
        
        
        AutomationSettings__c settings = new AutomationSettings__c(SetupOwnerId=UserInfo.getOrganizationId(), SkipProcessBuilder_c__c= true);
        insert settings;
        // Create Markets and Market Countries
        List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
        CPQ_TestDataFactory.createMarketCountrys(markets, true);

        // Get US market
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');

        // Create an account and a contact
        Account account = CPQ_TestDataFactory.createAccount(true);
        Contact contact = CPQ_TestDataFactory.createContact(false);
        contact.AccountId = account.Id;
        contact.ZTS_US_Job_Function__c ='Account Contact'; 
   		contact.ZTS_US_Profession__c='Academia';	
     	contact.ZTS_EU_Market__c  ='Canada';
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
        quote.QT_Sales_Program__c = 'FREEFLEX';
        productParent.Program_Eligibility_Filter__c = 'FREEDOM';

        // Insert products
        insert new List<Product2>{ productParent, product };

        // Create PBEs
        insert new List<PricebookEntry>{
            CPQ_TestDataFactory.createPriceBookEntry(productParent, false),
            CPQ_TestDataFactory.createPriceBookEntry(product, false)
        };
		Test.startTest();        
        // Insert bundle parent line
        SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
        parentLine.SBQQ__Bundle__c = true;
        insert parentLine;
		
        // Insert child line
        SBQQ__QuoteLine__c childLine = CPQ_TestDataFactory.createQuoteLine(quote, product, false);
        childLine.SBQQ__RequiredBy__c = parentLine.Id;
        insert childLine;
        Test.stopTest();
    }

    @istest
    public static void updateVistexPricingInSyncFlag_Test() {
        // Get the quote created on set-up
        SBQQ__Quote__c quote = [
            SELECT Id, SBQQ__Account__c, Vistex_Price_In_Sync__c, (SELECT Id FROM SBQQ__LineItems__r)
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        // Simulate the price was retrieved from Vistex
        quote.Vistex_Price_In_Sync__c = true;
        update quote;

        // Change a field not related with pricing
        quote.SBQQ__SubscriptionTerm__c = 24;
        update quote;

        // Refresh the quote
        quote = [SELECT Id, SBQQ__Account__c, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];

        // Assert pricing information is still in sync
        System.Assert(quote.Vistex_Price_In_Sync__c);

        // Create a bill to address
        State_Country__c stateCountry = new State_Country__c();
        stateCountry.Name = 'Madrid';
        stateCountry.ZTS_EU_Country__c = 'Spain';
        insert stateCountry;

        Address__c billToAddress = new Address__c();
        billToAddress.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName()
            .get('ZTS_EU_Account_Address')
            .getRecordTypeId();
        billToAddress.Name = 'Evergreen Av. 1234';
        billToAddress.ZTS_EU_Account__c = quote.SBQQ__Account__c;
        billToAddress.ZTS_EU_Address_Type__c = 'Invoice';
        billToAddress.ZTS_EU_Country__c = 'Spain';
        billToAddress.ZTS_EU_District__c = 'Madrid';
        billToAddress.Zip_Postal_Code__c = '1234';
        billToAddress.ZTS_EU_State_County__c = stateCountry.Id;
        billToAddress.ZTS_US_Source_Account_Number__c = '1000009537';
        insert billToAddress;

        // Change a price-related field (ie. Bill-to address)
        quote.Bill_To_Address__c = billToAddress.Id;
        update quote;

        // Refresh the quote
        quote = [SELECT Id, SBQQ__Account__c, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];

        // Assert pricing information is not in sync anymore
        //System.Assert(!quote.Vistex_Price_In_Sync__c);
    }

    @istest
    public static void testValidateAddressToAccountHierarchy_Invalid_ShipTo() {
        //Stage account hierarchy with addresses for testing
        Account parentAccount = [SELECT Id FROM Account LIMIT 1];

        Account childAccount = new Account();
        childAccount.Name = 'TestChild';
        childAccount.ZTS_EU_Market__c = 'United States';
        childAccount.Practice_Management_Software__c = 'Animana';
        childAccount.ParentId = parentAccount.Id;
        childAccount.BillingPostalCode = '00000';
        childAccount.BillingCity = 'testCity';
        childAccount.BillingState = 'testState';
        childAccount.BillingStreet = 'testStreet';
        insert childAccount;

        Account unrelatedAccount = new Account();
        unrelatedAccount.Name = 'Unrelated';
        unrelatedAccount.ZTS_EU_Market__c = 'United States';
        unrelatedAccount.Practice_Management_Software__c = 'Animana';
        unrelatedAccount.BillingPostalCode = '00000';
        unrelatedAccount.BillingCity = 'testCity';
        unrelatedAccount.BillingState = 'testState';
        unrelatedAccount.BillingStreet = 'testStreet';
        insert unrelatedAccount;

        //requery child account and validate the ultimate parent was set
        Account childAccountAfter = [SELECT Id, Account_Ultimate_Parent_Name__c FROM Account WHERE Id = :childAccount.Id];
        System.assertEquals(parentAccount.Id, childAccountAfter.Account_Ultimate_Parent_Name__c);

        //Create one address in hierarchy and one not in hierarchy
        List<Address__c> addressesToInsert = new List<Address__c>();
        Address__c inHierarchy = CPQ_TestDataFactory.createAddress(childAccountAfter, false);
        Address__c notInHierarchy = CPQ_TestDataFactory.createAddress(unrelatedAccount, false);
        addressesToInsert.add(inHierarchy);
        addressesToInsert.add(notInHierarchy);
        insert addressesToInsert;

        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Account__c FROM SBQQ__Quote__c LIMIT 1];
        quote.SBQQ__Account__c = parentAccount.Id;
        quote.Ship_To_Address__c = notInHierarchy.Id;
        quote.Bill_To_Address__c = inHierarchy.Id;
        quote.Payer_Address__c = inHierarchy.Id;

        try {
            update quote;
        } catch (Exception e) {
           /* System.debug('Apex Test Execution Caught Expected Address Validation');
            System.debug('Exception Message: ' + e.getMessage());*/
            System.assertEquals(true, e.getMessage().contains('Ship to Address'));
            System.assertEquals(false, e.getMessage().contains('Payer Address'));
            System.assertEquals(false, e.getMessage().contains('Bill to Address'));
        }
    }

    @istest
    public static void testUpdateOnShipToAddressField() {
        //Stage account hierarchy with addresses for testing
        Account parentAccount = [SELECT Id FROM Account LIMIT 1];

        Account childAccount = new Account();
        childAccount.Name = 'TestChild';
        childAccount.ZTS_EU_Market__c = 'United States';
        childAccount.Practice_Management_Software__c = 'Animana';
        childAccount.ParentId = parentAccount.Id;
        childAccount.BillingPostalCode = '00000';
        childAccount.BillingCity = 'testCity';
        childAccount.BillingState = 'testState';
        childAccount.BillingStreet = 'testStreet';
        insert childAccount;
        Test.startTest();

        //requery child account and validate the ultimate parent was set
        Account childAccountAfter = [SELECT Id, Account_Ultimate_Parent_Name__c FROM Account WHERE Id = :childAccount.Id];
        System.assertEquals(parentAccount.Id, childAccountAfter.Account_Ultimate_Parent_Name__c);

        //Create one address in hierarchy and one not in hierarchy
        List<Address__c> addressesToInsert = new List<Address__c>();
        Address__c inHierarchy = CPQ_TestDataFactory.createAddress(childAccountAfter, false);
        addressesToInsert.add(inHierarchy);
        insert addressesToInsert;

        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Account__c FROM SBQQ__Quote__c LIMIT 1];

        quote.Ship_To_Address__c = inHierarchy.Id;
        update quote;
        Test.stopTest();
    }

    @istest
    public static void testUpdateOnShipToAddressField_noShipToRecord() {
        //Stage account hierarchy with addresses for testing
        Account parentAccount = [SELECT Id FROM Account LIMIT 1];

        Account childAccount = new Account();
        childAccount.Name = 'TestChild';
        childAccount.ZTS_EU_Market__c = 'United States';
        childAccount.Practice_Management_Software__c = 'Animana';
        childAccount.ParentId = parentAccount.Id;
        childAccount.BillingPostalCode = '00000';
        childAccount.BillingCity = 'testCity';
        childAccount.BillingState = 'testState';
        childAccount.BillingStreet = 'testStreet';
        insert childAccount;
        Test.startTest();

        //requery child account and validate the ultimate parent was set
        Account childAccountAfter = [SELECT Id, Account_Ultimate_Parent_Name__c FROM Account WHERE Id = :childAccount.Id];
        System.assertEquals(parentAccount.Id, childAccountAfter.Account_Ultimate_Parent_Name__c);

        //Create one address in hierarchy and one not in hierarchy
        List<Address__c> addressesToInsert = new List<Address__c>();
        Address__c inHierarchy = CPQ_TestDataFactory.createAddress(childAccountAfter, false);
        addressesToInsert.add(inHierarchy);
        insert addressesToInsert;

        List<Ship_to_Configuration__c> shipTo = [SELECT Id FROM Ship_to_Configuration__c];
        delete shipTo;

        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Account__c FROM SBQQ__Quote__c LIMIT 1];

        quote.Ship_To_Address__c = inHierarchy.Id;
        update quote;
        Test.stopTest();
    }
    @istest
    public static void testsetMATAmount() {
        // Get the quote created on set-up
         //add records to external object
         SBQQ__Quote__c quote = [
            SELECT Id, QT_Sales_Program__c,SBQQ__Account__c, MAT_Purchase_Dollars_Rx__c,MAT_Purchase_Dollars_Dx__c, (SELECT Id FROM SBQQ__LineItems__r)
            FROM SBQQ__Quote__c
            LIMIT 1
        ];
        
        // add External rec
        List<CPQ_Sales_MAT_Amount__c> salesRecs = new List<CPQ_Sales_MAT_Amount__c>();
        salesRecs.add(
           new CPQ_Sales_MAT_Amount__c(
           	CPQ_Sales_External_Id__c = '56566-56566-Account-Dx',
        	Account_Id__c = quote.SBQQ__Account__c,
            source_account_number__c ='56566',
            Sales_By_Date__c = Date.today(),
            Product_Grouping_Type__c ='Dx',
            Total_MAT_Current_Sales__c = 1200.00
            )
         );
        //QueryPassthrough.setMock( new Mock(mockExternalRecs) );
   		salesRecs.add(
           new CPQ_Sales_MAT_Amount__c(
            CPQ_Sales_External_Id__c = '56566-56566-Account-Rx',
        	Account_Id__c = quote.SBQQ__Account__c,
            source_account_number__c ='56566',
            Sales_By_Date__c = Date.today(),
            Product_Grouping_Type__c ='Rx',
            Total_MAT_Current_Sales__c = 1300.00
            )
        );
		insert salesRecs;
 
        system.debug('insert of sales record for accountID =' + quote.SBQQ__Account__c);       
        system.debug('insert of sales record salesRecs ====> ' + salesRecs); 
		quote.QT_Sales_Program__c = 'FREEFLEX';
        update quote;
        // Refresh the quote
        quote = [SELECT Id,QT_Sales_Program__c, SBQQ__Account__c, MAT_Purchase_Dollars_Rx__c,MAT_Purchase_Dollars_Dx__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        
         system.debug('result of updating quote =' + quote);

        // Assert mat
        salesRecs = [SELECT Id, Account_Id__c,Product_Grouping_Type__c,Sales_By_Date__c,source_account_number__c, Total_MAT_Current_Sales__c
                	FROM CPQ_Sales_MAT_Amount__c where  Account_Id__c =:quote.SBQQ__Account__c];
 
		System.AssertEquals(salesRecs.size(),2);
        System.AssertNotEquals(quote.MAT_Purchase_Dollars_Dx__c,1200.00);
        System.AssertNotEquals(quote.MAT_Purchase_Dollars_Rx__c,1300.00);
        quote.ApprovalStatus__c = 'Pending';
        update quote;
        // Refresh the quote
        quote = [SELECT Id,QT_Sales_Program__c, SBQQ__Account__c,MAT_AMT_Date__c, MAT_Purchase_Dollars_Rx__c,MAT_Purchase_Dollars_Dx__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        quote.ApprovalStatus__c = '';
        quote.QT_Sales_Program__c = '';
        update quote;
        system.debug('updated quote ==> '+ quote);
        quote = [SELECT Id,QT_Sales_Program__c, SBQQ__Account__c, MAT_Purchase_Dollars_Rx__c,MAT_Purchase_Dollars_Dx__c 
                 FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        system.AssertEquals(quote.MAT_Purchase_Dollars_Rx__c,0.00);
    }
    
    @istest
    public static void testvalidatePrimaryQuote() {
        // Get the quote created on set-up
        SBQQ__Quote__c quote = [
            SELECT Id, QT_Sales_Program__c,ApprovalStatus__c,SBQQ__Primary__c, (SELECT Id FROM SBQQ__LineItems__r)
            FROM SBQQ__Quote__c
            LIMIT 1
        ];
        quote.SBQQ__Primary__c = false;
        //quote.ApprovalStatus__c = 'Pending';
        update quote;
        // Refresh the quote
        quote = [SELECT Id,QT_Sales_Program__c, ApprovalStatus__c,SBQQ__Primary__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        boolean primary = quote.SBQQ__Primary__c;
        string status = quote.ApprovalStatus__c;
        system.debug('value is ==>'+ primary);
        System.AssertEquals(quote.SBQQ__Primary__c,primary);
        
        quote.SBQQ__Primary__c = true;
        quote.ApprovalStatus__c = 'Approved';
        update quote;
        
        quote = [SELECT Id,QT_Sales_Program__c, ApprovalStatus__c,SBQQ__Primary__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        
        system.debug('value of ApprovalStatus__c ==>'+ quote.ApprovalStatus__c);
        System.AssertEquals(quote.ApprovalStatus__c,'Approved');
    }	
    
 
    //CPQATG-1299 Deprecate test for Distributor and Leasing Agent

    /*
    @istest
    public static void setDistributorAndLeasingAgentAddress() {
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

        // Get the Opportunity, contact and Address to create the quote
        Opportunity oppty = [SELECT Id, AccountId, CloseDate, Market__c FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c WHERE ZTS_US_Source_Account_Number__c = '1000009537' LIMIT 1];

        // Insert the Distributor and Leasing Agent
        Distributor__c distributor = new Distributor__c(Address__c = distAddress.Id, Sales_Org_Market__c = oppty.Market__c);
        insert distributor;

        Leasing_Agent__c leasingAgent = new Leasing_Agent__c(Address__c = lessorAddress.Id, Sales_Org_Market__c = oppty.Market__c);
        insert leasingAgent;

        Test.startTest();

        SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, new Account(Id = oppty.AccountId), contact, address, false);
        quote.Distributor_Add__c = distributor.Id;
        quote.Leasing_Agent_Add__c = leasingAgent.Id;
        insert quote;

        Test.stopTest();

        SBQQ__Quote__c refreshedQuote = [
            SELECT Id, Distributor_Add__c, Leasing_Agent_Add__c, Leasing_Agent_Address__c, Distributor_Address__c
            FROM SBQQ__Quote__c
            WHERE Id = :quote.Id
        ];

        System.assertEquals(distributor.Id, refreshedQuote.Distributor_Add__c);
        System.assertEquals(distAddress.Id, refreshedQuote.Distributor_Address__c);
        System.assertEquals(leasingAgent.Id, refreshedQuote.Leasing_Agent_Add__c);
        System.assertEquals(lessorAddress.Id, refreshedQuote.Leasing_Agent_Address__c);
    }

    */

    /*@istest
    public static void updateDistributorAndLeasingAgentAddress() {
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

        // Get the Opportunity, contact and Address to create the quote
        Opportunity oppty = [SELECT Id, AccountId, CloseDate, Market__c FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c WHERE ZTS_US_Source_Account_Number__c = '1000009537' LIMIT 1];

        // Insert the Distributor and Leasing Agent
        Distributor__c distributor = new Distributor__c(Address__c = distAddress.Id, Sales_Org_Market__c = oppty.Market__c);
        insert distributor;

        Leasing_Agent__c leasingAgent = new Leasing_Agent__c(Address__c = lessorAddress.Id, Sales_Org_Market__c = oppty.Market__c);
        insert leasingAgent;

        // Insert quote
        SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, new Account(Id = oppty.AccountId), contact, address, true);

        Test.startTest();

        // Refresh the quote
        SBQQ__Quote__c refreshedQuote = [
            SELECT Id, Distributor_Add__c, Leasing_Agent_Add__c, Leasing_Agent_Address__c, Distributor_Address__c
            FROM SBQQ__Quote__c
            WHERE Id = :quote.Id
        ];

        System.assertEquals(null, refreshedQuote.Distributor_Add__c);
        System.assertEquals(null, refreshedQuote.Distributor_Address__c);
        System.assertEquals(null, refreshedQuote.Leasing_Agent_Add__c);
        System.assertEquals(null, refreshedQuote.Leasing_Agent_Address__c);

        QuoteTriggerHandler.run = true;
        refreshedQuote.Distributor_Add__c = distributor.Id;
        refreshedQuote.Leasing_Agent_Add__c = leasingAgent.Id;
        update refreshedQuote;

        refreshedQuote = [
            SELECT Id, Distributor_Add__c, Leasing_Agent_Add__c, Leasing_Agent_Address__c, Distributor_Address__c
            FROM SBQQ__Quote__c
            WHERE Id = :refreshedQuote.Id
        ];

        System.assertEquals(distributor.Id, refreshedQuote.Distributor_Add__c);
        System.assertEquals(distAddress.Id, refreshedQuote.Distributor_Address__c);
        System.assertEquals(leasingAgent.Id, refreshedQuote.Leasing_Agent_Add__c);
        System.assertEquals(lessorAddress.Id, refreshedQuote.Leasing_Agent_Address__c);

        QuoteTriggerHandler.run = true;
        refreshedQuote.Distributor_Add__c = null;
        refreshedQuote.Leasing_Agent_Add__c = null;
        update refreshedQuote;

        Test.stopTest();

        refreshedQuote = [
            SELECT Id, Distributor_Add__c, Leasing_Agent_Add__c, Leasing_Agent_Address__c, Distributor_Address__c
            FROM SBQQ__Quote__c
            WHERE Id = :refreshedQuote.Id
        ];

        System.assertEquals(null, refreshedQuote.Distributor_Add__c);
        System.assertEquals(null, refreshedQuote.Distributor_Address__c);
        System.assertEquals(null, refreshedQuote.Leasing_Agent_Add__c);
        System.assertEquals(null, refreshedQuote.Leasing_Agent_Address__c);
    }
    */
}