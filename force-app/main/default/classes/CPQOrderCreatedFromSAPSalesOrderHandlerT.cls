/*
* File Name     :  CPQOrderCreatedFromSAPSalesOrderHandlerT
* Description   :  Test Class created for CPQOrdersCreatedFromSAPSalesOrderHandler   
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     10/04/2023        Sourav Mitra @ CTS                  Created the Class
* 2.0     10/04/2023        Nicholas Craig Grasseschi @ CTS     Added the methods
*/

@isTest
private class CPQOrderCreatedFromSAPSalesOrderHandlerT {
 
    @TestSetup
    static void testDataSetup() {

        //Create "Generic" Product
        Product2 prod = CPQ_TestDataFactory.createProduct(false);
        prod.Name = 'Generic Test Product';
        prod.ProductCode = '0000100001';
        insert prod;

        // create Standard Pricebook2
        Pricebook2 stdPB = new Pricebook2(Id = Test.getStandardPricebookId());
        // createPricebook2 for US
        Pricebook2 usPB = CPQ_TestDataFactory.createPricebook('1436 United States', '1436', true);

        // create Standard PricebookEntry for Generic Product -> UnitPrice will be 10
        PricebookEntry stdPBE = CPQ_TestDataFactory.createPriceBookEntry(prod, stdPB, 'USD', null, true); // CPQ_TestDataFactory.createPriceBookEntry(Product2, Pricebook2, CurrencyIsoCode, SAP_Price_Entry__c, doInert);
        // create a custom PricebookEntry for Generic Product -> USD -> UnitPrice will be 10
        PricebookEntry usdPBE = CPQ_TestDataFactory.createPricebookEntry(prod, usPB, 'USD', null, true);

        //Creating US Account
        Account accnt = CPQ_TestDataFactory.createAccount(false);
        System.debug('Account Details US *** '+accnt);
        insert accnt;

        // get SAP Staging record type Id
        String sapStagingRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('SAP_Staging').getRecordTypeId();
        //Creating "SAP Staging" type Order -> will NOT have an associated Quote or QuoteLines
        Order order1 = new Order(
            AccountId = accnt.Id,
            RecordTypeId = sapStagingRecTypeId,
            Pricebook2Id = usPB.Id,
            Status = 'Approved',
            Sales_Org__c = '1436',
            EffectiveDate = System.now().date().addDays(-5),
            CurrencyIsoCode = 'USD',
            SAP_Status__c = 'Approved'
        );
        insert order1;

        //Creating Order Products(OrderItem)
        OrderItem odi = new OrderItem(
            UnitPrice = 10,
            IsPortalCreated__c = TRUE,
            OrderId = order1.Id,
            Vistex_Net_Value__c = 40,
            Quantity = 1,
            Product2Id = prod.Id,
            PricebookEntryId = usdPBE.Id,
            SAP_Product_Number__c = '0000100002',
            SBQQ__Status__c = 'Activated'
        );
        insert odi;
    }

    @isTest
    private static void testOrderItemUpdate() {
        // new Product for insert -> would represent "missing" ProductCode -> OI.SAP_Product_Number__c
        Product2 prod1 = CPQ_TestDataFactory.createProduct(false);
        prod1.ProductCode = '0000100002';
        prod1.Name = 'Clone Product 1';
        insert prod1;
        // STD Pricebook2 entry for "missing" product (this would be available before our code is called)
        PricebookEntry pbe = CPQ_TestDataFactory.createPricebookEntry(prod1, true);

        // Set of Product2 Ids to send to our Handler method
        Set<Id> prodIdSet = new Set<Id>();
        prodIdSet.add(prod1.Id);

        // check OI still has "Generic" product name prior to calling our method (this OrderItem will be deleted after the new one is inserted)
        OrderItem oiPreClone = [SELECT Id, Product2.Name FROM OrderItem LIMIT 1];
        Assert.areEqual('Generic Test Product', oiPreClone.Product2.Name, 'Assertion failed as configured Product2 is not "Generic" ---> OI.Product2.Name = ' + oiPreClone.Product2.Name);
		
        Test.startTest();
        // send prodIdSet to handler for processing
        CPQOrdersCreatedFromSAPSalesOrderHandler.handleNewProducts(prodIdSet);
        Test.stopTest();

        // check that new OI has updated Product2 info
        OrderItem oiPostClone = [SELECT Id, Product2.Name FROM OrderItem LIMIT 1];
        Assert.areEqual('Clone Product 1', oiPostClone.Product2.Name, 'Assertion failed as configured Product2 is not "Clone" ---> OI.Product2.Name = ' + oiPreClone.Product2.Name);
    }
}