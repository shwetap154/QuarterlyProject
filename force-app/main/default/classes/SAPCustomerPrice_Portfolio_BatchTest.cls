/**
* @description       : Test class for Batch Job[SAPCustomerPrice_Portfolio_Batch] for matching AccountProductPortfolio__c Records
* to SAPCustomerMaterialPrice__c records by looping through SAPCustomerMaterialPrice__c records
* without an existing AccountProductPortfolio__c relationship, matching them to existing
* AccountProductPortfolio__c records if found, or creating new ones as needed.
* @author            : Namrata Patane @ Zoetis Inc
* @group             :
* @last modified on  : 09-16-2021
* @last modified by  : Morgan Marchese @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                         Modification
* 1.0   07-20-2021   Namrata Patane @ Zoetis Inc   Initial Version
**/

@isTest
public class SAPCustomerPrice_Portfolio_BatchTest {
    private static final Integer MAX_RECORDS = 10;

    @testSetup static void testData() {
        Map<Integer, String> mapIndexToMaterialId = new Map<Integer, String>();
        Map<Integer, String> mapIndexToCustomerId = new Map<Integer, String>();
        String customerId;
        String materialId;
        for(Integer i=0;i<MAX_RECORDS;i++){
            mapIndexToMaterialId.put(i, '0000000010000316' + i);
        }
        for(Integer i=0;i<MAX_RECORDS;i++){
            mapIndexToCustomerId.put(i, '10000567' + i);
        }
        List<Account> listAccounts = new List<Account>(); // Accounts to Insert
        List<Product2> listProducts = new List<Product2>(); // Products to Insert
        List<Address__c> listAddress = new List<Address__c>(); // Each Account gets one Address
        List<AccountProductPortfolio__c> listAccountProductPortfolio = new List<AccountProductPortfolio__c>(); // Each Account gets listSize - 2 Existing Portfolio records
        List<SAPCustomerMaterialPrice__c> listSAPCustomerMaterialPrice = new List<SAPCustomerMaterialPrice__c>();
        Integer maxCount = 0;

        State_Country__c sc = TestDataFactory.createStateCountry('United Kingdom','County Down',false);
        insert sc;

        for(Integer i = 0;i<MAX_RECORDS;i++){
            listAccounts.add(TestDataFactory.createAccount_EU('Test Account ' + i, sc.Id, false));
        }
        insert listAccounts;
        
        for(Integer i=0; i<MAX_RECORDS; i++){
            listProducts.add(new Product2(Name = 'Test Class Product ' + i, ProductCode = mapIndexToMaterialId.get(i)));
        }     
        insert listProducts;
        
        
        Integer sapCount = 0;
        for(Account objAccount : listAccounts){                        
            Integer productCount = 0;
            maxCount = listProducts.size() - 2;
            customerId = mapIndexToCustomerId.get(sapCount);
            materialId = mapIndexToMaterialId.get(sapCount);
            Address__c  objAddress = new Address__c ();
            objAddress.ZTS_EU_Account__c = objAccount.id;       
            objAddress.Name = '123 Some Street Apartment 5';
            objAddress.ZTS_EU_District__c = 'Wakiso';
            objAddress.ZTS_EU_Country__c = 'Uganda';
            objAddress.ZTS_US_Source_Account_Number__c = customerId;
            listAddress.add(objAddress);

            for(Product2 objProduct : listProducts){
                if(productCount < maxCount){

                    AccountProductPortfolio__c objAPP = new AccountProductPortfolio__c(
                        Account__c = objAccount.Id,
                        Product__c = listProducts[productCount++].Id
                        
                    );
                    listAccountProductPortfolio.add(objAPP);                    
                }

                SAPCustomerMaterialPrice__c sapPrice = new SAPCustomerMaterialPrice__c();
                sapPrice.Customer_Number__c = customerId;
                sapPrice.Material_Number__c = objProduct.ProductCode;
                sapPrice.Product__c = objProduct.Id;
                sapPrice.Valid_From__c = System.today().addDays(-120);
                sapPrice.Valid_To__c = System.today().addDays(120);
                sapPrice.Price__c = 245.00;
                sapPrice.Sales_Organization__c = '2941';
                sapPrice.External_Id__c = 'EXTID-' + math.random() + sapCount;
                listSAPCustomerMaterialPrice.add(sapPrice);
            }
           sapCount++;
        }
        insert listAddress;
        insert listAccountProductPortfolio;
        insert listSAPCustomerMaterialPrice;
    }

    /**
    * @description Tests that we're getting the correct amount of starter data to test this batch
    * @author Morgan Marchese @ Zoetis Inc | 07-21-2021 
    * @return testMethod 
    **/
    private static testMethod void testDataSize(){
        // Check Account Data
        List<Account> listAccounts = [SELECT Id FROM Account];
        System.assertEquals(MAX_RECORDS,listAccounts.size());

        // Check Product Data
        List<Product2> listProducts = [SELECT Id FROM Product2 WHERE Name LIKE 'Test Class Product %'];
        System.assertEquals(MAX_RECORDS, listProducts.size());
        
        // Check Customer Material Price Data
        List<SAPCustomerMaterialPrice__c> listCustomerPrices = [SELECT Id,Customer_Number__c,Product__c FROM SAPCustomerMaterialPrice__c];
        System.assertEquals(MAX_RECORDS * listAccounts.size(), listCustomerPrices.size());
        Set<String> setUniqueMaterialPrices = new Set<String>();        
        for(SAPCustomerMaterialPrice__c objPrice : listCustomerPrices){
            String key = objPrice.Customer_Number__c + String.valueOf(objPrice.Product__c);
            if(setUniqueMaterialPrices.contains(key)){                
            	System.assertEquals(false,setUniqueMaterialPrices.contains(key));
            }
            setUniqueMaterialPrices.add(key);
        }

        // Check Account Product Portfolio Data
        List<AccountProductPortfolio__c> listAPP = [SELECT Id,Account__c,Product__c FROM AccountProductPortfolio__c];
        System.assertEquals((MAX_RECORDS - 2) * listAccounts.size(), listAPP.size());
        Set<String> setUniquePortfolios = new Set<String>();
        for(AccountProductPortfolio__c objPortfolio : listAPP){
            String key = String.valueOf(objPortfolio.Account__c) + String.valueOf(objPortfolio.Product__c);
            System.assertEquals(false, setUniquePortfolios.contains(key));
            setUniquePortfolios.add(key);
        }

        // Check Address Data
        List<Address__c> listAddresses = [SELECT Id, ZTS_US_Source_Account_Number__c FROM Address__c WHERE ZTS_US_Source_Account_Number__c != null];
        System.assertEquals(MAX_RECORDS, listAddresses.size());
        Set<String> setCustomerNumbers = new Set<String>();
        for(Address__c objAddress : listAddresses){
            System.assertEquals(false,setCustomerNumbers.contains(objAddress.ZTS_US_Source_Account_Number__c));
            setCustomerNumbers.add(objAddress.ZTS_US_Source_Account_Number__c);
        }
    }
    
    private static testMethod void testDuplicateMaterialMatch(){
        // Given - 
        //  Accounts(5) 
        //    - Address (1?) (Customer Number)
        //  Assuming Multiple SAPCustomerMaterialPrice with the SAME Customer Number and Product in the SAME batch
        //  Also assuming no pre-existing/matching AccountProductPortfolio
        // Expected Result: Multiple SAPCustomerMaterialPrices that are the "same" will be related to the same newly created AccountProductPortfolio
        // Actual Result: Each SAPCustomerMaterialPrice appears to create its own AccountProductPortfolio, resulting in duplications in APP

        List<Account> accounts = [
            SELECT Id,
            (
                SELECT Id, 
                ZTS_US_Source_Account_Number__c 
                FROM Addresses__r 
                WHERE ZTS_US_Source_Account_Number__c != null
            ) 
            FROM Account
        ];
        List<Product2> listProducts = new List<Product2>();
        List<SAPCustomerMaterialPrice__c> listCustomerPrices = [SELECT Id FROM SAPCustomerMaterialPrice__c];
        List<AccountProductPortfolio__c> listPortfolios = [SELECT Id FROM AccountProductPortfolio__c];
        delete listCustomerPrices;
        delete listPortfolios;
        listCustomerPrices = new List<SAPCustomerMaterialPrice__c>();

        for(Integer i=0; i<2; i++){
            listProducts.add(new Product2(Name = 'New Test Product ' + i, ProductCode = '1234' + i));
        }     
        insert listProducts;


        for(Account a : accounts){
            for(Integer i=0;i<4;i++){
                SAPCustomerMaterialPrice__c sapPrice = new SAPCustomerMaterialPrice__c();
                sapPrice.Customer_Number__c = a.Addresses__r[0].ZTS_US_Source_Account_Number__c;
                sapPrice.Material_Number__c = listProducts[i >= 2 ? 0 : 1].ProductCode;
                sapPrice.Product__c = listProducts[i >= 2 ? 0 : 1].Id;
                sapPrice.Valid_From__c = System.today().addDays(-120 * (i + 1));
                sapPrice.Valid_To__c = System.today().addDays(120 * (i + 1));
                sapPrice.Price__c = 245.00;
                sapPrice.Sales_Organization__c = '2941';
                sapPrice.External_Id__c = 'EXTID1230'+ a.Id + i;
                listCustomerPrices.add(sapPrice);
            }
        }
        insert listCustomerPrices;
        Test.startTest();
        /*List<SAPCustomerMaterialPrice__c> listPricesWithoutLink = [
            SELECT Id, Customer_Number__c
            FROM SAPCustomerMaterialPrice__c 
            WHERE Account_Product_Portfolio__c = null 
            AND Product__c != null
        ];

        System.assertEquals(40, listPricesWithoutLink.size());

        Set<String> sapCustomerIds = new Set<String>();

        for(SAPCustomerMaterialPrice__c objCMP : listPricesWithoutLink){
            sapCustomerIds.add(objCMP.Customer_Number__c);
        */

        SAPCustomerPrice_Portfolio_Batch batch = new SAPCustomerPrice_Portfolio_Batch();
        Database.executeBatch(batch);
        Test.stopTest();

        List<SAPCustomerMaterialPrice__c> listPricesWithoutLink = [
            SELECT Id, Customer_Number__c
            FROM SAPCustomerMaterialPrice__c 
            WHERE Account_Product_Portfolio__c = null 
            AND Product__c != null
        ];

        System.assertEquals(0, listPricesWithoutLink.size());

        listPortfolios = [SELECT Id,(SELECT Id FROM SAP_Customer_Material_Prices__r) FROM AccountProductPortfolio__c];
        System.assertEquals(accounts.size() * 2,listPortfolios.size());
        for(AccountProductPortfolio__c portfolio : listPortfolios){
            System.assertEquals(2,portfolio.SAP_Customer_Material_Prices__r.size());
        }
    }

    private static testMethod void testSAPMaterialToExistingPortfolio(){
        List<AccountProductPortfolio__c> portfolios = [SELECT Id FROM AccountProductPortfolio__c];
        /*List<SAPCustomerMaterialPrice__c> listPricesWithoutLink = [
            SELECT Id, Customer_Number__c
            FROM SAPCustomerMaterialPrice__c 
            WHERE Account_Product_Portfolio__c = null 
            AND Product__c != null
        ];

        Set<String> sapCustomerIds = new Set<String>();

        System.assertEquals(80, portfolios.size());
        System.assertEquals(100, listPricesWithoutLink.size());
        for(SAPCustomerMaterialPrice__c objCMP : listPricesWithoutLink){
            sapCustomerIds.add(objCMP.Customer_Number__c);
        }*/
        Test.startTest();
        SAPCustomerPrice_Portfolio_Batch batch = new SAPCustomerPrice_Portfolio_Batch();
        Database.executeBatch(batch);
        Test.stopTest();

        List<SAPCustomerMaterialPrice__c> listPricesWithoutLink = [
            SELECT Id, Customer_Number__c,
            Account_Product_Portfolio__c
            FROM SAPCustomerMaterialPrice__c 
            WHERE Account_Product_Portfolio__c != null 
            AND Product__c != null
        ];
        System.assertEquals(100,listPricesWithoutLink.size());

        // check for duplicates in the results
        Set<Id> setAccountProductPortfolioIds = new Set<Id>();
        for(SAPCustomerMaterialPrice__c objPrice : listPricesWithoutLink){
            System.assertEquals(false, setAccountProductPortfolioIds.contains(objPrice.Account_Product_Portfolio__c));
            setAccountProductPortfolioIds.add(objPrice.Account_Product_Portfolio__c);
        }

        portfolios = [SELECT Id FROM AccountProductPortfolio__c];
        System.assertEquals(100, portfolios.size());
    }
    
    
    
}