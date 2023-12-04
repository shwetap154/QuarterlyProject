/**
 * @description       : Controller class used by alpha_stockAndForecastUpload LWC to handle downloading and uploading
 *                      CSV files for Forecast and Stock Entry creation.
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 04-01-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-28-2021   Unknown                     Initial Version
 * 1.1   04-01-2022   Ethan Hirsch @ Zoetis Inc   Fix a bug where a Distributor Price with a comma could not be parsed.
**/
public with sharing class alphaDistExcelController {
    @AuraEnabled
    public static List<Map<String, String>> getProductList(String objectType) {
        List<Map<String, String>> productList = new List<Map<String, String>>();
        Map<String, Decimal> priceList = new Map<String, Decimal>();
        Map<String, String> currencyCodeList = new Map<String, String>();
        Map<String, String> uomList = new Map<String, String>();

        // Optimization: Merge returnUOMList(), returnPriceList(), and returnCurrencyIsoCode as they share almost the same functions.
        uomList = UtilityController.returnUOMList();
        // Get prices for forecasts
        if (objectType == 'Forecast') {
            priceList = UtilityController.returnPriceList();
            currencyCodeList = UtilityController.returnCurrencyIsoCode();
        }

        for (Product2 prod : UtilityController.returnProdList()) {
            Map<String, String> newProduct = new Map<String, String>();
            newProduct.put('SAP Material Code', prod.SAP_Product_Number__c);
            newProduct.put('Product ID', prod.Id);
            newProduct.put('Product Description', prod.Name);
            newProduct.put('Quantity', '0');

            // newProduct.put('Unit of Measure', prod.SAP_Sales_Unit_of_Measure__c);
            System.debug(uomList);
            if (String.isBlank(uomList.get(prod.Id))) {
                newProduct.put('Unit of Measure', prod.SAP_Sales_Unit_of_Measure__c);
            }
            else {
                newProduct.put('Unit of Measure', uomList.get(prod.Id));
            }
            
            switch on (objectType) {
                when ('Forecast') {
                    newProduct.put('Distributor Price', priceList.get(prod.Id).format());
                    // newProduct.put('Currency', prod.CurrencyIsoCode);
                    System.debug(currencyCodeList);
                    System.debug(currencyCodeList.get(prod.Id));
                    if (String.isBlank(currencyCodeList.get(prod.Id))) {
                        newProduct.put('Currency', prod.CurrencyIsoCode);
                        System.debug('blank');
                        System.debug(newProduct.get('Currency'));
                    }
                    else {
                        newProduct.put('Currency', currencyCodeList.get(prod.Id));
                        System.debug('not blank');
                        System.debug(newProduct.get('Currency'));
                    }
                }
                when ('Stock') {
                    newProduct.put('Batch/Lot Number', '');
                    // newProduct.put('Expiry Date', System.today().format());
                    newProduct.put('Expiry Date', '');
                }
            }

            productList.add(newProduct);
        }

        return productList;
    }

    @AuraEnabled
    public static List<Map<String, String>> getProductListDemo(String objectType) {
        List<Map<String, String>> productList = new List<Map<String, String>>();
        for(Product2 prod : [SELECT Id, Name, SAP_Product_Number__c, Description, SAP_Sales_Unit_of_Measure__c, CurrencyIsoCode from Product2 LIMIT 5]) {
            Map<String, String> newProduct = new Map<String, String>();
            newProduct.put('SAP Material Code', prod.SAP_Product_Number__c);
            newProduct.put('Product ID', prod.Id);
            newProduct.put('Product Description', prod.Name);
            newProduct.put('Distributor Product Code', ''); // Distributor_Product_Code__c
            newProduct.put('Distributor Product Name', ''); // Distributor_Product_Name__c
            newProduct.put('Quantity', '0');
            newProduct.put('Unit of Measure', prod.SAP_Sales_Unit_of_Measure__c);
            
            switch on (objectType) {
                when ('Forecast') {
                    newProduct.put('Distributor Price', '1');
                    newProduct.put('Currency', prod.CurrencyIsoCode);
                }
                when ('Stock') {
                    newProduct.put('Batch/Lot Number', '');
                    newProduct.put('Expiry Date', System.today().format());
                }
            }

            productList.add(newProduct);
        }

        return productList;
    }

    // These parsing functions will need to be checked for governor limits
    @AuraEnabled
    public static List<Map<String, String>> parseForecastExcelJson(List<Map<String, String>> csvJson, Map<String, String> forecastData) {
        System.debug(csvJson);
        System.debug(forecastData);
        // List<Forecast__c> forecastList = new List<Forecast__c>();
        List<Forecast_Product__c> fpList = new List<Forecast_Product__c>();
        List<Map<String, String>> failedRecords = new List<Map<String, String>>();
        String userId = userinfo.getUserId();
        User userData = [SELECT Id, Contact.AccountId, Contact.Account.ZTS_EU_Market__c FROM User WHERE Id = :userId];
        Savepoint savePoint = Database.setSavepoint();

        // Create the forecast, assumes that all records will be for the same month
        Forecast__c forecast = new Forecast__c();
        forecast.Month__c = forecastData.get('Month');
        forecast.Year__c = forecastData.get('Year');
        forecast.Account__c = userData.Contact.AccountId;
        forecast.Market_Account__c = userData.Contact.Account.ZTS_EU_Market__c;

        List<Forecast__c> forecastSearch = [SELECT Id, Month__c, Year__c, Account__c FROM Forecast__c WHERE Month__c = :forecast.Month__c AND Year__c = :forecast.Year__c AND Account__c = :forecast.Account__c];
        if (forecastSearch.size() > 0) {
            throw new uploadException('A forecast for this month and year has already been submitted.');
        }
        else {
            insert forecast;
        }

        // Get list of products, compress it to the information we need
        List<Map<String, String>> productList = getProductList('Forecast');
        Map<String, Map<String, String>> productNameList = new Map<String, Map<String, String>>();
        for (Map<String, String> product : productList) {
            productNameList.put(product.get('Product Description'), product);
        }

        for (Map<String, String> entry : csvJson) {
            System.debug(entry);

            /*
            Forecast__c forecast = new Forecast__c();
            forecast.Month__c = entry.get('Month');
            forecast.Year__c = entry.get('Year');
            forecast.Account__c = '0011g00000u7SSdAAM';

            // Search existing forecasts to minimize DML operations, insert new one only if needed
            for (Forecast__c existingForecast : forecastList) {
                if (existingForecast.Month__c == forecast.Month__c && existingForecast.Year__c == forecast.Year__c && existingForecast.Account__c == forecast.Account__c) {
                    forecast.Id = existingForecast.Id;
                }
            }
    
            if (String.isEmpty(forecast.Id)) {
                List<Forecast__c> forecastSearch = [SELECT Id, Month__c, Year__c, Account__c FROM Forecast__c WHERE Month__c = :forecast.Month__c AND Year__c = :forecast.Year__c AND Account__c = :forecast.Account__c];
                if (forecastSearch.size() > 0) {
                    // forecast.Id = forecastSearch[0].Id;
                    entry.put('Failure Reason', 'Forecast for this month and year has already been submitted.');
                    failedRecords.add(entry);
                    continue;
                }
                else {
                    insert forecast;
                }
                forecastList.add(forecast);
            }
            System.debug(forecastList);
            */

            Boolean validEntry = true;
            Forecast_Product__c fp = new Forecast_Product__c();

            // Get fields from Excel sheet
            if (String.isBlank(entry.get('Product Description'))) {
                if (String.isBlank(entry.get('Failure Reason'))) {
                    entry.put('Failure Reason', 'Product Description must have a value');
                }
                else {
                    entry.put('Failure Reason', entry.get('Failure Reason') + ', Product Description must have a value');
                }
                validEntry = false;
            }
            else {
                String productDescription = entry.get('Product Description');
                if (productNameList.get(productDescription) == null) {
                    entry.put('Failure Reason', entry.get('Failure Reason') + ', No product by this name was found');
                }
                else {
                    fp.Product__c = productNameList.get(productDescription).get('Product ID');
                }

                // Quantity
                if (String.isBlank(entry.get('Quantity'))) {
                    if (String.isBlank(entry.get('Failure Reason'))) {
                        entry.put('Failure Reason', 'Quantity must have a value');
                    }
                    else {
                        entry.put('Failure Reason', entry.get('Failure Reason') + ', Quantity must have a value');
                    }
                    validEntry = false;
                }
                else {
                    fp.Quantity__c = Integer.valueOf(entry.get('Quantity'));
                }

                // Distributor Product Code and Name
                fp.Distributor_Product_Code__c = entry.get('Distributor Product Code');
                fp.Distributor_Product_Name__c = entry.get('Distributor Product Name');
                // Added By Suvankar :: UOM field mapping :: SC - 009087
                system.debug('>>>>>>>>>'+entry.get('Unit of Measure'));
                fp.Unit_of_Measure__c = entry.get('Unit of Measure');
                // Get rest of the fields directly from the product
                if (validEntry) {
                    try {
                        // Values over 1000 will be formatted with comma separators. Remove the comma before parsing the decimal to avoid errors
                        // Note that currently all Users have a locale of en_US. If this changes this code may need to handle the thousand
                        // separator being a "." instead of ",".
                        fp.Price__c = Decimal.valueOf(productNameList.get(productDescription).get('Distributor Price')?.replace(',', ''));
                    }
                    catch(Exception e) {
                        validEntry = false;
                        entry.put('Failure Reason', entry.get('Failure Reason') + ', This product has invalid price data. Please contact your market admin to resolve this issue.');
                    }

                    try {
                        fp.SAP_Product_Code__c = productNameList.get(productDescription).get('SAP Material Code');
                    }
                    catch(Exception e) {
                        fp.SAP_Product_Code__c = '';
                    }

                    try {
                        fp.CurrencyIsoCode = productNameList.get(productDescription).get('Currency');
                    }
                    catch(Exception e) {
                        fp.CurrencyIsoCode = '';
                    }
        
                    fp.Forecast__c = forecast.Id;
                }
            }

            if (validEntry) {
                fpList.add(fp);
            }
            else {
                failedRecords.add(entry);
            }
        }

        if (!failedRecords.isEmpty()) {
            Database.rollback(savePoint);
        }
        else {
            System.debug(fpList);
            insert fpList;
            System.debug(fpList);
        }
        
        System.debug(failedRecords);
        return failedRecords;
    }
    
    @AuraEnabled
    public static List<Map<String, String>> parseStockExcelJson(List<Map<String, String>> csvJson, Map<String, String> stockData) {
        System.debug(csvJson);
        List<Stock__c> stockList = new List<Stock__c>();
        List<Stock_Product__c> spList = new List<Stock_Product__c>();
        List<Map<String, String>> failedRecords = new List<Map<String, String>>();
        String userId = userinfo.getUserId();
        User userData = [SELECT Id, Contact.AccountId, Contact.Account.ZTS_EU_Market__c FROM User WHERE Id = :userId];
        Savepoint savePoint = Database.setSavepoint();

        // Create the forecast, assumes that all records will be for the same month
        Stock__c stock = new Stock__c();
        stock.Month__c = stockData.get('Month');
        stock.Year__c = stockData.get('Year');
        stock.Account__c = userData.Contact.AccountId;
        stock.Market_Account__c = userData.Contact.Account.ZTS_EU_Market__c;

        List<Stock__c> stockSearch = [SELECT Id, Month__c, Year__c, Account__c FROM Stock__c WHERE Month__c = :stock.Month__c AND Year__c = :stock.Year__c AND Account__c = :stock.Account__c];
            if (stockSearch.size() > 0) {
                throw new uploadException('Stock for this month and year has already been submitted.');
            }
            else {
                insert stock;
            }

        // Get list of products, compress it to the information we need
        List<Map<String, String>> productList = getProductList('Forecast');
        Map<String, Map<String, String>> productNameList = new Map<String, Map<String, String>>();
        for (Map<String, String> product : productList) {
            productNameList.put(product.get('Product Description'), product);
        }

        for (Map<String, String> entry : csvJson) {
            System.debug(entry);

            /*
            Stock__c stock = new Stock__c();
            stock.Month__c = entry.get('Month');
            stock.Year__c = entry.get('Year');
            stock.Account__c = '0011g00000u7SSdAAM';

            // Search existing stocks to minimize DML operations, insert new one only if needed
            for (Stock__c existingStock : stockList) {
                if (existingStock.Month__c == stock.Month__c && existingStock.Year__c == stock.Year__c && existingStock.Account__c == stock.Account__c) {
                    stock.Id = existingStock.Id;
                }
            }
    
            if (String.isEmpty(stock.Id)) {
                List<Stock__c> stockSearch = [SELECT Id, Month__c, Year__c, Account__c FROM Stock__c WHERE Month__c = :stock.Month__c AND Year__c = :stock.Year__c AND Account__c = :stock.Account__c];
                if (stockSearch.size() > 0) {
                    // stock.Id = stockSearch[0].Id;
                    entry.put('Failure Reason', 'Stock for this month and year has already been submitted.');
                    failedRecords.add(entry);
                    continue;
                }
                else {
                    insert stock;
                }
                stockList.add(stock);
            }
            System.debug(stockList);
            */

            Boolean validEntry = true;
            Stock_Product__c sp = new Stock_Product__c();

            // Get fields from Excel sheet
            if (String.isBlank(entry.get('Product Description'))) {
                if (String.isBlank(entry.get('Failure Reason'))) {
                    entry.put('Failure Reason', 'Product Description must have a value');
                }
                else {
                    entry.put('Failure Reason', entry.get('Failure Reason') + ', Product Description must have a value');
                }
                validEntry = false;
            }
            else {
                String productDescription = entry.get('Product Description');
                if (productNameList.get(productDescription) == null) {
                    entry.put('Failure Reason', entry.get('Failure Reason') + ', No product by this name was found');
                }
                else {
                    sp.Product__c = productNameList.get(productDescription).get('Product ID');
                }

                // Quantity
                if (String.isBlank(entry.get('Quantity'))) {
                    if (String.isBlank(entry.get('Failure Reason'))) {
                        entry.put('Failure Reason', 'Quantity must have a value');
                    }
                    else {
                        entry.put('Failure Reason', entry.get('Failure Reason') + ', Quantity must have a value');
                    }
                    validEntry = false;
                }
                else {
                    sp.Quantity__c = Integer.valueOf(entry.get('Quantity'));
                }

                // Batch / Lot Number
                if (String.isBlank(entry.get('Batch/Lot Number'))) {
                    if (String.isBlank(entry.get('Failure Reason'))) {
                        entry.put('Failure Reason', 'Batch/Lot Number must have a value');
                    }
                    else {
                        entry.put('Failure Reason', entry.get('Failure Reason') + ', Batch/Lot Number must have a value');
                    }
                    validEntry = false;
                }
                else {
                    sp.Batch_Lot_Number__c = entry.get('Batch/Lot Number');
                }
                
                if (String.isBlank(entry.get('Expiry Date'))) {
                    if (String.isBlank(entry.get('Failure Reason'))) {
                        entry.put('Failure Reason', 'Expiry Date must have a value');
                    }
                    else {
                        entry.put('Failure Reason', entry.get('Failure Reason') + ', Expiry Date must have a value');
                    }
                    validEntry = false;
                }
                else {
                    System.debug('Expiry Date processing');
                    System.debug(entry.get('Expiry Date'));
                    System.debug(Date.parse(entry.get('Expiry Date')));
                    sp.Expiration_Date__c = Date.parse(entry.get('Expiry Date'));
                }
            
                // Distributor Code and Name
                sp.Distributor_Product_Code__c = entry.get('Distributor Product Code');
                sp.Distributor_Product_Name__c = entry.get('Distributor Product Name');

                // Get rest of the fields directly from the product
                if (validEntry) {
                    try {
                        sp.SAP_Product_Code__c = productNameList.get(productDescription).get('SAP Material Code');
                    }
                    catch(Exception e) {
                        sp.SAP_Product_Code__c = '';
                    }

                    sp.Stock__c = stock.Id;
                }
            }

            if (validEntry) {
                spList.add(sp);
            }
            else {
                failedRecords.add(entry);
            }
        }

        if (!failedRecords.isEmpty()) {
            Database.rollback(savePoint);
        }
        else {
	        System.debug(spList);
	        insert spList;
	        System.debug(spList);
        }
        
        System.debug(failedRecords);
        return failedRecords;
    }

    public class uploadException extends Exception {}
}