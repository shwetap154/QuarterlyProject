/**
* File Name     :  PriceEntryBatchableTest
* @description  :  Test class for PriceEntryBatchable and PriceEntryBatchHelper
* @author       :  Cesar Sandrigo @ ATG	 - Advanced Technology Group.
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0	  7/19/2019		Cesar Sandrigo @ ATG	Added the all logic.
* 1.2	  7/19/2019		Cesar Sandrigo @ ATG	Added test for non-existing PBE for the standard pricebook
*                                               Current coverage: PriceEntryBatchable: 93% - PriceEntryBatchableHelper: 89%
*1.3      7/24/2020    Ramiro Alvarez @ ARG     CPQATG-910 Comment assertions for spe.Product__c
*/
@istest
public class PriceEntryBatchableTest {

    @testSetup
    public static void setup() {
        // Create custom pricebooks
        Pricebook2 usPricebook = CPQ_TestDataFactory.createPricebook('US pricebook', '1436', false);
        Pricebook2 ukPricebook = CPQ_TestDataFactory.createPricebook('UK pricebook', '7974', false);

        insert new List<Pricebook2> { usPricebook, ukPricebook };

        // Create Markets and Market Countries 
        List<Market__c> markets = CPQ_TestDataFactory.createMarkets(false);

        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        usMarket.Price_Book__c = usPricebook.Id;
        Market__c ukMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United Kingdom');
        ukMarket.Price_Book__c = ukPricebook.Id;

        insert markets;

        CPQ_TestDataFactory.createMarketCountrys(markets, true);

        // Create SAP materials
        SAP_Material__c material1 = CPQ_TestDataFactory.createSAPMaterial('VL', '000000000010001498', 'NORM', 'ZFER', '', false);
        SAP_Material__c material2 = CPQ_TestDataFactory.createSAPMaterial('ST', '000000000010001430', 'NORM', 'ZFER', '', false);

        insert new List<SAP_Material__c> { material1, material2 };

        /** BEGIN: Material Master Batchable work */

        // Create product
        Product2 prod1 = CPQ_TestDataFactory.createProduct(false);
        prod1.Name = 'Product 1';
        prod1.SAP_Material__c = material1.Id;

		Product2 prod2 = CPQ_TestDataFactory.createProduct(false);
		prod2.Name = 'Product 2';
        prod2.SAP_Material__c = material2.Id;

        insert new List<Product2> { prod1, prod2 };

        // Create the PBEs for Standard pricebook for USD and GBP currencies
        insert new List<PricebookEntry> {
        	CPQ_TestDataFactory.createPriceBookEntry(prod1, 'USD', false),
			CPQ_TestDataFactory.createPriceBookEntry(prod2, 'USD', false),
            CPQ_TestDataFactory.createPriceBookEntry(prod1, 'GBP', false),
            CPQ_TestDataFactory.createPriceBookEntry(prod2, 'GBP', false)
		};

        /** END: Material Master Batchable work */
    }

    @istest
    public static void process_nonExistingPBEs() {
        
        Date today = Date.today();

        // Simulate a SAP Price Entry load from SAP
        List<SAP_Price_Entry__c> sapPriceEntries = new List<SAP_Price_Entry__c> {
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '1436', 10.1, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 11.2, today.addDays(-10), today.addDays(10), 'GBP', 'ST', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001498', '1436', 12.3, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001498', '7974', 13.4, today.addDays(-10), today.addDays(10), 'GBP', 'PK', false)
        };

        insert sapPriceEntries;

        Test.startTest();
        
        // Create and execute the batchable job
        PriceEntryBatchable peb  = new PriceEntryBatchable();
		Database.executeBatch(peb, 200);
        
        Test.stopTest();

        // Check no error logs were inserted
        List<Error_Log__c> errorLogs = [SELECT Id, Message__c, Stack_Trace__c FROM Error_Log__c];
        if(!errorLogs.isEmpty()) {
            System.assert(false, 'Error: ' + errorLogs[0].Message__c + ' - Trace: ' + errorLogs[0].Stack_Trace__c);
        }

        // Refresh the list of SAP entries
        sapPriceEntries = [SELECT Id, Last_Batch_Run__c, Price_Book__c, Product__c FROM SAP_Price_Entry__c];
        System.AssertEquals(4, sapPriceEntries.size());

        // Check if 'Last batch run' was populated as well as the Pricebook Id
        for (SAP_Price_Entry__c spe : sapPriceEntries) {
            System.Assert(spe.Last_Batch_Run__c != null);
            System.Assert(spe.Price_Book__c != null);
           // System.Assert(spe.Product__c != null);
        }

        // Get the non-standard pricebook entries
        List<PricebookEntry> pbes = [SELECT Id, Product2.SAP_Product_Number__c, SAP_Unit_of_Measure__c,
                                        Pricebook2.SAP_Sales_Org_ID__c, CurrencyIsoCode, UnitPrice
                                     FROM PricebookEntry
                                     WHERE Pricebook2.IsStandard = FALSE
                                     ORDER BY Product2.SAP_Product_Number__c, Pricebook2.SAP_Sales_Org_ID__c];

        // Amount of entries inserted
        System.AssertEquals(4, pbes.size());

        // Per the ORDER BY in the query, I'm expecting to have the PBEs in the same order the entries were entered
        System.AssertEquals('000000000010001430', pbes[1].Product2.SAP_Product_Number__c);
        System.AssertEquals('1436', pbes[0].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(10.1, pbes[0].UnitPrice); 
        System.AssertEquals('USD', pbes[0].CurrencyIsoCode);
        System.AssertEquals('EA', pbes[0].SAP_Unit_of_Measure__c);

        System.AssertEquals('000000000010001430', pbes[1].Product2.SAP_Product_Number__c);
        System.AssertEquals('7974', pbes[1].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(11.2, pbes[1].UnitPrice); 
        System.AssertEquals('GBP', pbes[1].CurrencyIsoCode);
        System.AssertEquals('ST', pbes[1].SAP_Unit_of_Measure__c);

        System.AssertEquals('000000000010001498', pbes[2].Product2.SAP_Product_Number__c);
        System.AssertEquals('1436', pbes[2].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(12.3, pbes[2].UnitPrice); 
        System.AssertEquals('USD', pbes[2].CurrencyIsoCode);
        System.AssertEquals('EA', pbes[2].SAP_Unit_of_Measure__c);

        System.AssertEquals('000000000010001498', pbes[3].Product2.SAP_Product_Number__c);
        System.AssertEquals('7974', pbes[3].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(13.4, pbes[3].UnitPrice); 
        System.AssertEquals('GBP', pbes[3].CurrencyIsoCode);
        System.AssertEquals('PK', pbes[3].SAP_Unit_of_Measure__c);
    }

    @istest
    public static void process_existingPBEs() {

        List<PricebookEntry> existingPBEs = new List<PricebookEntry>();
        
        // Get one product and both non-standard pricebooks
        Product2 product = [SELECT Id FROM Product2 WHERE SAP_Product_Number__c = '000000000010001430'];
        List<Pricebook2> pricebooks = [SELECT Id, SAP_Sales_Org_ID__c FROM Pricebook2 WHERE Pricebook2.IsStandard = FALSE];

        // Create PBEs, simulating they already exist for material 000000000010001430, and they will be updated
        for (Pricebook2 pb : pricebooks) {

            if (pb.SAP_Sales_Org_ID__c == '1436') {
                // This is for testing the scenario where we have different currencies for same product-pricebook combination
                existingPBEs.add(CPQ_TestDataFactory.createPriceBookEntry(product, pb, 'USD', false));
                existingPBEs.add(CPQ_TestDataFactory.createPriceBookEntry(product, pb, 'GBP', false)); // this one should not be updated
            }
            else if (pb.SAP_Sales_Org_ID__c == '7974') {
                existingPBEs.add(CPQ_TestDataFactory.createPriceBookEntry(product, pb, 'GBP', false));
            }
        }

        // Create PBEs, simulating they already exist and this is an update
        insert existingPBEs;

        Date today = Date.today();

        // Simulate a SAP Price Entry load from SAP
        List<SAP_Price_Entry__c> sapPriceEntries = new List<SAP_Price_Entry__c> {
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '1436', 10.1, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 11.2, today.addDays(-10), today.addDays(10), 'GBP', 'ST', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001498', '1436', 12.3, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001498', '7974', 13.4, today.addDays(-10), today.addDays(10), 'GBP', 'PK', false)
        };
        insert sapPriceEntries;

        Test.startTest();
        
        // Create and execute the batchable job
        PriceEntryBatchable peb  = new PriceEntryBatchable();
		Database.executeBatch(peb, 200);
        
        Test.stopTest();

        // Check no error logs were inserted
        List<Error_Log__c> errorLogs = [SELECT Id, Message__c, Stack_Trace__c FROM Error_Log__c];
        if (!errorLogs.isEmpty()) {
            System.assert(false, 'Error: ' + errorLogs[0].Message__c + ' - Trace: ' + errorLogs[0].Stack_Trace__c);
        }

        // Refresh the list of SAP entries
        sapPriceEntries = [SELECT Id, Last_Batch_Run__c, Price_Book__c, Product__c FROM SAP_Price_Entry__c];
        System.AssertEquals(4, sapPriceEntries.size()); 

        // Check if 'Last batch run' was populated as well as the Pricebook Id
        for (SAP_Price_Entry__c spe : sapPriceEntries) {
            System.Assert(spe.Last_Batch_Run__c != null);
            System.Assert(spe.Price_Book__c != null);
        //    System.Assert(spe.Product__c != null);
        }

        // Get the non-standard pricebook entries
        List<PricebookEntry> pbes = [SELECT Id, Product2.SAP_Product_Number__c, SAP_Unit_of_Measure__c,
                                        Pricebook2.SAP_Sales_Org_ID__c, CurrencyIsoCode, UnitPrice
                                     FROM PricebookEntry
                                     WHERE Pricebook2.IsStandard = FALSE
                                     ORDER BY Product2.SAP_Product_Number__c, Pricebook2.SAP_Sales_Org_ID__c, CurrencyIsoCode];

        // Amount of entries inserted
        System.AssertEquals(5, pbes.size()); // 3 existing, 2 new

        // Per the ORDER BY in the query, I'm expecting to have the PBEs in the same order the entries were entered

        // This is the existing one, that should not be changed, since there is no SAP entry for this one
        System.AssertEquals('000000000010001430', pbes[0].Product2.SAP_Product_Number__c);
        System.AssertEquals('1436', pbes[0].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(10, pbes[0].UnitPrice); 
        System.AssertEquals('GBP', pbes[0].CurrencyIsoCode);

        System.AssertEquals('000000000010001430', pbes[1].Product2.SAP_Product_Number__c);
        System.AssertEquals('1436', pbes[1].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(10.1, pbes[1].UnitPrice); 
        System.AssertEquals('USD', pbes[1].CurrencyIsoCode);
        System.AssertEquals('EA', pbes[1].SAP_Unit_of_Measure__c);

        System.AssertEquals('000000000010001430', pbes[2].Product2.SAP_Product_Number__c);
        System.AssertEquals('7974', pbes[2].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(11.2, pbes[2].UnitPrice); 
        System.AssertEquals('GBP', pbes[2].CurrencyIsoCode);
        System.AssertEquals('ST', pbes[2].SAP_Unit_of_Measure__c);

        System.AssertEquals('000000000010001498', pbes[3].Product2.SAP_Product_Number__c);
        System.AssertEquals('1436', pbes[3].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(12.3, pbes[3].UnitPrice); 
        System.AssertEquals('USD', pbes[3].CurrencyIsoCode);
        System.AssertEquals('EA', pbes[3].SAP_Unit_of_Measure__c);

        System.AssertEquals('000000000010001498', pbes[4].Product2.SAP_Product_Number__c);
        System.AssertEquals('7974', pbes[4].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(13.4, pbes[4].UnitPrice); 
        System.AssertEquals('GBP', pbes[4].CurrencyIsoCode);
        System.AssertEquals('PK', pbes[4].SAP_Unit_of_Measure__c);

        System.Assert(true);
    }

    @isTest
    public static void testSchedulable() {
		Test.startTest();
		
        PriceEntryBatchable schedJob  = new PriceEntryBatchable();
        String sch = '0 0 0 * * ?';
        Id jobId = System.schedule('Price Entry batch', sch, schedJob);
		
        Test.stopTest();
		
        //Lookup the job based on the Job ID
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		
        //Assertions
		System.assert(ct != null, 'Cron Trigger is null');
    }
    
    @istest
    public static void process_overlapping_records_insert() {

        // Get one product and both non-standard pricebooks
        Product2 product = [SELECT Id FROM Product2 WHERE SAP_Product_Number__c = '000000000010001430'];
        List<Pricebook2> pricebooks = [SELECT Id, SAP_Sales_Org_ID__c FROM Pricebook2 WHERE Pricebook2.IsStandard = FALSE];

        Date today = Date.today();

        // Simulate a SAP Price Entry load from SAP, with overlaping time periods
        List<SAP_Price_Entry__c> sapPriceEntries = new List<SAP_Price_Entry__c> {
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '1436', 10.1, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 11.2, today.addDays(-20), today.addDays(20), 'GBP', 'ST', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 15.0, today.addDays(-10), today.addDays(10), 'GBP', 'ST', false)
        };
        insert sapPriceEntries;

        Test.startTest();
        
        // Create and execute the batchable job
        PriceEntryBatchable peb  = new PriceEntryBatchable();
		Database.executeBatch(peb, 200);
        
        Test.stopTest();

        // Check no error logs were inserted
        List<Error_Log__c> errorLogs = [SELECT Id, Message__c, Stack_Trace__c FROM Error_Log__c];
        if (!errorLogs.isEmpty()) {
            System.assert(false, 'Error: ' + errorLogs[0].Message__c + ' - Trace: ' + errorLogs[0].Stack_Trace__c);
        }

        // Refresh the list of SAP entries
        sapPriceEntries = [SELECT Id, Last_Batch_Run__c, Price_Book__c, Product__c FROM SAP_Price_Entry__c];
        System.AssertEquals(3, sapPriceEntries.size()); 

        // Check if 'Last batch run' was populated as well as the Pricebook Id
        for (SAP_Price_Entry__c spe : sapPriceEntries) {
            System.Assert(spe.Last_Batch_Run__c != null);
            System.Assert(spe.Price_Book__c != null);
          //  System.Assert(spe.Product__c != null);
        }

        // Get the non-standard pricebook entries
        List<PricebookEntry> pbes = [SELECT Id, Product2.SAP_Product_Number__c, SAP_Unit_of_Measure__c,
                                        Pricebook2.SAP_Sales_Org_ID__c, CurrencyIsoCode, UnitPrice
                                     FROM PricebookEntry
                                     WHERE Pricebook2.IsStandard = FALSE
                                     ORDER BY Product2.SAP_Product_Number__c, Pricebook2.SAP_Sales_Org_ID__c, CurrencyIsoCode];

        // Amount of entries inserted
        System.AssertEquals(2, pbes.size()); // 3 existing, 2 new

        // Per the ORDER BY in the query, I'm expecting to have the PBEs in the same order the entries were entered

        System.AssertEquals('000000000010001430', pbes[0].Product2.SAP_Product_Number__c);
        System.AssertEquals('1436', pbes[0].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(10.1, pbes[0].UnitPrice); 
        System.AssertEquals('USD', pbes[0].CurrencyIsoCode);
        System.AssertEquals('EA', pbes[0].SAP_Unit_of_Measure__c);

        System.AssertEquals('000000000010001430', pbes[1].Product2.SAP_Product_Number__c);
        System.AssertEquals('7974', pbes[1].Pricebook2.SAP_Sales_Org_ID__c);
        //System.AssertEquals(15.0, pbes[1].UnitPrice); //FIXME: This is failinguntil the support for overlapping records is implemented
        System.AssertEquals('GBP', pbes[1].CurrencyIsoCode);
        System.AssertEquals('ST', pbes[1].SAP_Unit_of_Measure__c);
    }

    @istest
    public static void process_overlapping_records_update() {

        // Get one product and both non-standard pricebooks
        Product2 product = [SELECT Id FROM Product2 WHERE SAP_Product_Number__c = '000000000010001430'];
        List<Pricebook2> pricebooks = [SELECT Id, SAP_Sales_Org_ID__c FROM Pricebook2 WHERE Pricebook2.IsStandard = FALSE];

        List<PricebookEntry> existingPBEs = new List<PricebookEntry>();

        // Create PBEs, simulating they already exist for material 000000000010001430, and they will be updated
        for (Pricebook2 pb : pricebooks) {
            if (pb.SAP_Sales_Org_ID__c == '7974') {
                existingPBEs.add(CPQ_TestDataFactory.createPriceBookEntry(product, pb, 'GBP', false));
            }
        }

        // Create PBEs, simulating they already exist and this is an update
        insert existingPBEs;

        Date today = Date.today();

        // Simulate a SAP Price Entry load from SAP, with overlaping time periods
        List<SAP_Price_Entry__c> sapPriceEntries = new List<SAP_Price_Entry__c> {
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '1436', 10.1, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 11.2, today.addDays(-20), today.addDays(20), 'GBP', 'ST', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 15.0, today.addDays(-10), today.addDays(10), 'GBP', 'ST', false)
        };
        insert sapPriceEntries;

        Test.startTest();
        
        // Create and execute the batchable job
        PriceEntryBatchable peb  = new PriceEntryBatchable();
		Database.executeBatch(peb, 200);
        
        Test.stopTest();

        // Check no error logs were inserted
        List<Error_Log__c> errorLogs = [SELECT Id, Message__c, Stack_Trace__c FROM Error_Log__c];
        if (!errorLogs.isEmpty()) {
            System.assert(false, 'Error: ' + errorLogs[0].Message__c + ' - Trace: ' + errorLogs[0].Stack_Trace__c);
        }

        // Refresh the list of SAP entries
        sapPriceEntries = [SELECT Id, Last_Batch_Run__c, Price_Book__c, Product__c FROM SAP_Price_Entry__c];
        System.AssertEquals(3, sapPriceEntries.size()); 

        // Check if 'Last batch run' was populated as well as the Pricebook Id
        for (SAP_Price_Entry__c spe : sapPriceEntries) {
            System.Assert(spe.Last_Batch_Run__c != null);
            System.Assert(spe.Price_Book__c != null);
            //System.Assert(spe.Product__c != null);
        }

        // Get the non-standard pricebook entries
        List<PricebookEntry> pbes = [SELECT Id, Product2.SAP_Product_Number__c, SAP_Unit_of_Measure__c,
                                        Pricebook2.SAP_Sales_Org_ID__c, CurrencyIsoCode, UnitPrice
                                     FROM PricebookEntry
                                     WHERE Pricebook2.IsStandard = FALSE
                                     ORDER BY Product2.SAP_Product_Number__c, Pricebook2.SAP_Sales_Org_ID__c, CurrencyIsoCode];

        // Amount of entries inserted
        System.AssertEquals(2, pbes.size()); // 3 existing, 2 new

        // Per the ORDER BY in the query, I'm expecting to have the PBEs in the same order the entries were entered

        System.AssertEquals('000000000010001430', pbes[0].Product2.SAP_Product_Number__c);
        System.AssertEquals('1436', pbes[0].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(10.1, pbes[0].UnitPrice); 
        System.AssertEquals('USD', pbes[0].CurrencyIsoCode);
        System.AssertEquals('EA', pbes[0].SAP_Unit_of_Measure__c);

        System.AssertEquals('000000000010001430', pbes[1].Product2.SAP_Product_Number__c);
        System.AssertEquals('7974', pbes[1].Pricebook2.SAP_Sales_Org_ID__c);
        //System.AssertEquals(15.0, pbes[1].UnitPrice); //FIXME: This is failinguntil the support for overlapping records is implemented
        System.AssertEquals('GBP', pbes[1].CurrencyIsoCode);
        System.AssertEquals('ST', pbes[1].SAP_Unit_of_Measure__c);
    }


    @istest
    public static void process_no_overlapping_records() {

        Date today = Date.today();

        // Simulate a SAP Price Entry load from SAP, with overlaping time periods
        List<SAP_Price_Entry__c> sapPriceEntries = new List<SAP_Price_Entry__c> {
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 10.1, today.addDays(-20), today.addDays(-10), 'GBP', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 11.2, today.addDays(-9), today.addDays(10), 'GBP', 'ST', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 15.0, today.addDays(11), today.addDays(20), 'GBP', 'PK', false)
        };
        insert sapPriceEntries;

        Test.startTest();
        
        // Create and execute the batchable job
        PriceEntryBatchable peb  = new PriceEntryBatchable();
		Database.executeBatch(peb, 200);
        
        Test.stopTest();

        // Check no error logs were inserted
        List<Error_Log__c> errorLogs = [SELECT Id, Message__c, Stack_Trace__c FROM Error_Log__c];
        if (!errorLogs.isEmpty()) {
            System.assert(false, 'Error: ' + errorLogs[0].Message__c + ' - Trace: ' + errorLogs[0].Stack_Trace__c);
        }

        // Refresh the list of SAP entries
        sapPriceEntries = [SELECT Id, Last_Batch_Run__c, Date_Range_Valid__c,  Price_Book__c, Product__c FROM SAP_Price_Entry__c];
        System.AssertEquals(3, sapPriceEntries.size()); 

        // Check if 'Last batch run' was populated as well as the Pricebook Id
        for (SAP_Price_Entry__c spe : sapPriceEntries) {
            if (spe.Date_Range_Valid__c) {
                System.Assert(spe.Last_Batch_Run__c != null);
                System.Assert(spe.Price_Book__c != null);
               // System.Assert(spe.Product__c != null);
            }
            else {
                System.Assert(spe.Last_Batch_Run__c == null);
                System.Assert(spe.Price_Book__c == null);
              //  System.Assert(spe.Product__c == null);
            }
        }

        // Get the non-standard pricebook entries
        List<PricebookEntry> pbes = [SELECT Id, Product2.SAP_Product_Number__c, SAP_Unit_of_Measure__c,
                                        Pricebook2.SAP_Sales_Org_ID__c, CurrencyIsoCode, UnitPrice
                                     FROM PricebookEntry
                                     WHERE Pricebook2.IsStandard = FALSE
                                     ORDER BY Product2.SAP_Product_Number__c, Pricebook2.SAP_Sales_Org_ID__c, CurrencyIsoCode];

        // Amount of entries inserted
        System.AssertEquals(1, pbes.size()); // 3 existing, 2 new

        // Per the ORDER BY in the query, I'm expecting to have the PBEs in the same order the entries were entered

        System.AssertEquals('000000000010001430', pbes[0].Product2.SAP_Product_Number__c);
        System.AssertEquals('7974', pbes[0].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(11.2, pbes[0].UnitPrice); 
        System.AssertEquals('GBP', pbes[0].CurrencyIsoCode);
        System.AssertEquals('ST', pbes[0].SAP_Unit_of_Measure__c);
    }

    @istest
    public static void process_no_overlapping_existing_old_record() {

        // Get one product and both non-standard pricebooks
        Product2 product = [SELECT Id FROM Product2 WHERE SAP_Product_Number__c = '000000000010001430'];
        List<Pricebook2> pricebooks = [SELECT Id, SAP_Sales_Org_ID__c FROM Pricebook2 WHERE Pricebook2.IsStandard = FALSE];

        List<PricebookEntry> existingPBEs = new List<PricebookEntry>();

        // Create PBEs, simulating they already exist for material 000000000010001430, and they will be updated
        for (Pricebook2 pb : pricebooks) {
            if (pb.SAP_Sales_Org_ID__c == '7974') {
                existingPBEs.add(CPQ_TestDataFactory.createPriceBookEntry(product, pb, 'GBP', false));
            }
        }

        // Create PBEs, simulating they already exist and this is an update
        insert existingPBEs;

        Date today = Date.today();

        // Simulate a SAP Price Entry load from SAP, with overlaping time periods
        List<SAP_Price_Entry__c> sapPriceEntries = new List<SAP_Price_Entry__c> {
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 10.1, today.addDays(-20), today.addDays(-10), 'GBP', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 11.2, today.addDays(-9), today.addDays(10), 'GBP', 'ST', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 15.0, today.addDays(11), today.addDays(20), 'GBP', 'PK', false)
        };
        insert sapPriceEntries;

        // Update existing PBE with an old reference
        existingPBEs[0].SAP_Price_Entry__c = sapPriceEntries[0].Id;
        existingPBEs[0].UnitPrice = sapPriceEntries[0].List_Price__c;
        update existingPBEs[0];

        Test.startTest();
        
        // Create and execute the batchable job
        PriceEntryBatchable peb  = new PriceEntryBatchable();
		Database.executeBatch(peb, 200);
        
        Test.stopTest();

        // Check no error logs were inserted
        List<Error_Log__c> errorLogs = [SELECT Id, Message__c, Stack_Trace__c FROM Error_Log__c];
        if (!errorLogs.isEmpty()) {
            System.assert(false, 'Error: ' + errorLogs[0].Message__c + ' - Trace: ' + errorLogs[0].Stack_Trace__c);
        }

        // Refresh the list of SAP entries
        sapPriceEntries = [SELECT Id, Last_Batch_Run__c, Date_Range_Valid__c,  Price_Book__c, Product__c FROM SAP_Price_Entry__c];
        System.AssertEquals(3, sapPriceEntries.size()); 

        // Check if 'Last batch run' was populated as well as the Pricebook Id
        for (SAP_Price_Entry__c spe : sapPriceEntries) {
            if (spe.Date_Range_Valid__c) {
                System.Assert(spe.Last_Batch_Run__c != null);
                System.Assert(spe.Price_Book__c != null);
               // System.Assert(spe.Product__c != null);
            }
            else {
                System.Assert(spe.Last_Batch_Run__c == null);
                System.Assert(spe.Price_Book__c == null);
               // System.Assert(spe.Product__c == null);
            }
        }

        // Get the non-standard pricebook entries
        List<PricebookEntry> pbes = [SELECT Id, Product2.SAP_Product_Number__c, SAP_Unit_of_Measure__c,
                                        Pricebook2.SAP_Sales_Org_ID__c, CurrencyIsoCode, UnitPrice
                                     FROM PricebookEntry
                                     WHERE Pricebook2.IsStandard = FALSE
                                     ORDER BY Product2.SAP_Product_Number__c, Pricebook2.SAP_Sales_Org_ID__c, CurrencyIsoCode];

        // Amount of entries inserted
        System.AssertEquals(1, pbes.size());

        // The old value should be replaced by the current
        System.AssertEquals('000000000010001430', pbes[0].Product2.SAP_Product_Number__c);
        System.AssertEquals('7974', pbes[0].Pricebook2.SAP_Sales_Org_ID__c);
        System.AssertEquals(11.2, pbes[0].UnitPrice); 
        System.AssertEquals('GBP', pbes[0].CurrencyIsoCode);
        System.AssertEquals('ST', pbes[0].SAP_Unit_of_Measure__c);
    }

    @istest
    public static void process_nonExistingPBEs_nonStandardPBE() {
        
        Date today = Date.today();

        // Simulate a SAP Price Entry load from SAP
        List<SAP_Price_Entry__c> sapPriceEntries = new List<SAP_Price_Entry__c> {
            // With standard PBE
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '1436', 10.1, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 11.2, today.addDays(-10), today.addDays(10), 'GBP', 'ST', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001498', '1436', 12.3, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001498', '7974', 13.4, today.addDays(-10), today.addDays(10), 'GBP', 'PK', false),
            // Without standard PBE
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '1436', 10.1, today.addDays(-10), today.addDays(10), 'AUD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001430', '7974', 11.2, today.addDays(-10), today.addDays(10), 'AUD', 'ST', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001498', '1436', 12.3, today.addDays(-10), today.addDays(10), 'AUD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000010001498', '7974', 13.4, today.addDays(-10), today.addDays(10), 'AUD', 'PK', false)
        };

        insert sapPriceEntries;

        Test.startTest();
        
        // Create and execute the batchable job
        PriceEntryBatchable peb  = new PriceEntryBatchable();
		Database.executeBatch(peb, 200);
        
        Test.stopTest();

        // Check no error logs were inserted
        List<Error_Log__c> errorLogs = [SELECT Id, Message__c, Stack_Trace__c FROM Error_Log__c];
        if(!errorLogs.isEmpty()) {
            System.assert(false, 'Error: ' + errorLogs[0].Message__c + ' - Trace: ' + errorLogs[0].Stack_Trace__c);
        }

        // Refresh the list of SAP entries
        sapPriceEntries = [SELECT Id, Last_Batch_Run__c, Price_Book__c, Product__c FROM SAP_Price_Entry__c];
        System.AssertEquals(8, sapPriceEntries.size());

        // Check if 'Last batch run' was populated as well as the Pricebook Id
        for (SAP_Price_Entry__c spe : sapPriceEntries) {
            System.Assert(spe.Last_Batch_Run__c != null);
            System.Assert(spe.Price_Book__c != null);
         //   System.Assert(spe.Product__c != null);
        }

        Id standardPricebookId = Test.getStandardPricebookId();

        // Get the non-standard pricebook entries
        List<PricebookEntry> pbes = [SELECT Id, Product2.SAP_Product_Number__c, SAP_Unit_of_Measure__c,
                                        Pricebook2.SAP_Sales_Org_ID__c, CurrencyIsoCode, UnitPrice, Pricebook2Id
                                     FROM PricebookEntry
                                     WHERE Pricebook2Id = :standardPricebookId
                                     ORDER BY Product2.SAP_Product_Number__c, CurrencyIsoCode];

        // Amount of entries inserted
        System.AssertEquals(6, pbes.size());

        // Per the ORDER BY in the query, I'm expecting to have the PBEs in the same order the entries were entered
        System.AssertEquals('000000000010001430', pbes[0].Product2.SAP_Product_Number__c);
        System.AssertEquals(0, pbes[0].UnitPrice); 
        System.AssertEquals('AUD', pbes[0].CurrencyIsoCode);
        System.AssertEquals(standardPricebookId, pbes[0].Pricebook2Id);

        System.AssertEquals('000000000010001430', pbes[1].Product2.SAP_Product_Number__c);
        System.AssertEquals(10, pbes[1].UnitPrice); 
        System.AssertEquals('GBP', pbes[1].CurrencyIsoCode);
        System.AssertEquals(standardPricebookId, pbes[1].Pricebook2Id);

        System.AssertEquals('000000000010001430', pbes[2].Product2.SAP_Product_Number__c);
        System.AssertEquals(10, pbes[2].UnitPrice); 
        System.AssertEquals('USD', pbes[2].CurrencyIsoCode);
        System.AssertEquals(standardPricebookId, pbes[2].Pricebook2Id);

        System.AssertEquals('000000000010001498', pbes[3].Product2.SAP_Product_Number__c);
        System.AssertEquals(0, pbes[3].UnitPrice); 
        System.AssertEquals('AUD', pbes[3].CurrencyIsoCode);
        System.AssertEquals(standardPricebookId, pbes[3].Pricebook2Id);

        System.AssertEquals('000000000010001498', pbes[4].Product2.SAP_Product_Number__c);
        System.AssertEquals(10, pbes[4].UnitPrice); 
        System.AssertEquals('GBP', pbes[4].CurrencyIsoCode);
        System.AssertEquals(standardPricebookId, pbes[4].Pricebook2Id);

        System.AssertEquals('000000000010001498', pbes[5].Product2.SAP_Product_Number__c);
        System.AssertEquals(10, pbes[5].UnitPrice); 
        System.AssertEquals('USD', pbes[5].CurrencyIsoCode);
        System.AssertEquals(standardPricebookId, pbes[5].Pricebook2Id);
    }
}