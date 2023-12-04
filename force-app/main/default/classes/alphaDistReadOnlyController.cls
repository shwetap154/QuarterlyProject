/**
 * @description       : Controller for alphaDistReadOnlyForecast, alphaNewForecastEntryForm, and alphaNewStockEntryForm
 * @author            : Morgan Marchese @ Zoetis Inc (Production Deployer)
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   08-28-2021   Morgan Marchese @ Zoetis Inc   Initial Version (Deployed to Production)
 * 1.1   01-19-2022   Unknown                        Unknown updates
 * 1.2   03-29-2022   Ethan Hirsch @ Zoetis Inc      Update SAPCustomerMaterialPrice__c queries in getProductStock and getProductForecast
 *                                                   to use SAPCustomerMaterialPricesSelector to retrieve data that is
 *                                                   currently valid.
**/
public without sharing class alphaDistReadOnlyController {
    public alphaDistReadOnlyController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<SObject> getColumns(String type){
        try {
                List<SObject> colList = [SELECT label,label__c,fieldName__c,Type__c from StockForecastColumns__mdt where ObjectName__c = 'SF'AND (Type__c = null OR Type__c = :type) order by label];
            system.debug('colList' +colList);  
            return colList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static ProductStock getProductStock(string productId){
        try {
                Product2 prod = [SELECT Id, Name, SAP_Product_Number__c, Description,
                                 SAP_Sales_Unit_of_Measure__c FROM Product2 WHERE Id =: productId];
                Stock_Product__c sp = new  Stock_Product__c();
                ProductStock ps = new ProductStock();

                Set<String> accountNumbers = UtilityController.getAccountNumbers().keyset();

                ISAPCustomerMaterialPricesSelector sapSelector = SAPCustomerMaterialPricesSelector.newInstance();
                List<SAPCustomerMaterialPrice__c> productPriceList = sapSelector.selectValidByCustomerNumbersAndProductIds(
                    accountNumbers, new Set<ID> {productId}); 

                SAPCustomerMaterialPrice__c productPrice = new SAPCustomerMaterialPrice__c();
               // System.debug(productId);
               // System.debug(accountNumbers);
               // System.debug(productPriceList); 
                if (productPriceList.size() > 0) {
                    productPrice = productPriceList[0];
                }

                sp.SAP_Product_Code__c = prod.SAP_Product_Number__c;
                sp.Product__c = prod.Id;
                sp.Distributor_Product_Code__c = '';
                sp.Distributor_Product_Name__c = '';
                sp.Batch_Lot_Number__c = '';
                if (String.isBlank(productPrice.Unit_of_Measure__c)) {
                    sp.Unit_of_Measure__c = prod.SAP_Sales_Unit_of_Measure__c;
                }
                else {
                    sp.Unit_of_Measure__c = productPrice.Unit_of_Measure__c;
                }
                sp.Quantity__c = 0;
                sp.Expiration_Date__c = system.today();
                ps.stock = sp;
                ps.prod = prod;

                return ps;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ProductForecast getProductForecast(string productId){
        try {
                Product2 prod = [SELECT Id, Name, SAP_Product_Number__c, Description, SAP_Sales_Unit_of_Measure__c FROM Product2 WHERE Id = :productId];

                Set<String> accountNumbers = UtilityController.getAccountNumbers().keyset();
                
                ISAPCustomerMaterialPricesSelector sapSelector = SAPCustomerMaterialPricesSelector.newInstance();
                List<SAPCustomerMaterialPrice__c> productPriceList = sapSelector.selectValidByCustomerNumbersAndProductIds(
                    accountNumbers, new Set<Id>{productId}); 

                SAPCustomerMaterialPrice__c productPrice = new SAPCustomerMaterialPrice__c();
             //   System.debug(productId);
               // System.debug(accountNumbers);
               // System.debug(productPriceList); 
                if (productPriceList.size() > 0) {
                    productPrice = productPriceList[0];
                }

                Forecast_Product__c fp = new Forecast_Product__c();
                ProductForecast pf = new ProductForecast();
                fp.Product__c = prod.Id;
                fp.SAP_Product_Code__c = prod.SAP_Product_Number__c;
                fp.Quantity__c = 0;
                if (String.isBlank(productPrice.Unit_of_Measure__c)) {
                    fp.Unit_of_Measure__c = prod.SAP_Sales_Unit_of_Measure__c;
                }
                else {
                    fp.Unit_of_Measure__c = productPrice.Unit_of_Measure__c;
                }
                fp.Price__c = productPrice.Price__c;
                fp.CurrencyIsoCode = productPrice.CurrencyIsoCode;
                fp.Distributor_Product_Code__c = '';
                fp.Distributor_Product_Name__c = '';
                pf.forecast = fp;
                pf.prod = prod;
 // System.debug(pf);
           //  System.debug(fp);
            
                return pf;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductStock> getIntialList(){
                
        try {
                List<ProductStock> psList = new List<ProductStock>();
                for(Product2 prod : UtilityController.returnProdList())
                    {
                        Stock_Product__c sp = new  Stock_Product__c();
                        ProductStock ps = new ProductStock();
                        sp.SAP_Product_Code__c = prod.SAP_Product_Number__c;
                        sp.Product__c = prod.Id;
                        sp.Distributor_Product_Code__c = '';
                        sp.Distributor_Product_Name__c = '';
                        sp.Batch_Lot_Number__c = '';
                        sp.Quantity__c = 0;
                        sp.Expiration_Date__c = system.today();
                        ps.stock = sp;
                        ps.prod = prod;
                        
                        psList.Add(ps);

                    }
            // System.debug('Prod List===>'+ psList);
            return psList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductForecast> getInitialListForecast(){
        try {
            List<ProductForecast> pfList = new List<ProductForecast>();
            // for(Product2 prod : [SELECT Id, Name, SAP_Product_Number__c, Description, QuantityUnitOfMeasure, CurrencyIsoCode FROM Product2 LIMIT 5]) {
            for (Product2 prod : UtilityController.returnProdList()) {
                Forecast_Product__c fp = new Forecast_Product__c();
                ProductForecast pf = new ProductForecast();
                fp.SAP_Product_Code__c = prod.SAP_Product_Number__c;
                fp.Product__c = prod.Id;
                // fp.Unit_of_Measure__c = prod.QuantityUnitOfMeasure;
                fp.Distributor_Product_Code__c = '';
                fp.Distributor_Product_Name__c = '';
                fp.Quantity__c = 0;
                fp.Price__c = 1;
                fp.CurrencyIsoCode = prod.CurrencyIsoCode;
                pf.forecast = fp;
                pf.prod = prod;
                
                pfList.add(pf);
            }
            return pfList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ProductForecast> getMonthlyForecast(String month, String year){
      //  system.debug('>>>>>>>');
        try {
            // String accountId = '0011g00000u7SSdAAM';
            String userId = userinfo.getUserId();
            String accountId = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userId].Contact.AccountId;

            List<Forecast_Product__c> existingForecasts = [SELECT Id, SAP_Product_Code__c, Unit_of_Measure__c, Distributor_Product_Code__c, Distributor_Product_Name__c, Product__c, Product__r.Name, Quantity__c, Price__c, CurrencyIsoCode, Forecast__r.Month__c, Forecast__r.Year__c, Forecast__r.Account__c FROM Forecast_Product__c WHERE Forecast__r.Account__c = :accountId AND Forecast__r.Month__c = :month AND Forecast__r.Year__c = :year ORDER BY Product__r.Name ASC];
                                     
            if (existingForecasts.isEmpty()) {
                // return getInitialListForecast();
               // system.debug('existingForecasts'+existingForecasts);
                return new List<ProductForecast>();
            }
            else {
                List<ProductForecast> pfList = new List<ProductForecast>();
                for (Forecast_Product__c forecastProduct : existingForecasts) {
                    ProductForecast pf = new ProductForecast();
                    pf.forecast = forecastProduct;
                    pf.prod = new Product2(Id = forecastProduct.Product__c, Name = forecastProduct.Product__r.Name);
                   // system.debug('pf'+pf);
                    pfList.add(pf);
                   // system.debug('pfList'+pfList);
                }
                return pfList;
                
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    

    @AuraEnabled
    public static List<ProductStock> getMonthlyStock(String month, String year){
       // system.debug('>>>>>>>');
        try {
            String userId = userinfo.getUserId();
            String accountId = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userId].Contact.AccountId;

            List<Stock_Product__c> existingStock = [SELECT Id, SAP_Product_Code__c, Unit_of_Measure__c, Distributor_Product_Code__c, Distributor_Product_Name__c, Product__c, Product__r.Name, Quantity__c,Batch_Lot_Number__c, Expiration_Date__c, Stock__r.Month__c, Stock__r.Year__c, Stock__r.Account__c FROM Stock_Product__c WHERE Stock__r.Account__c = :accountId AND Stock__r.Month__c = :month AND Stock__r.Year__c = :year];
            if (existingStock.isEmpty()) {
                // return getInitialListForecast();
                return new List<ProductStock>();
            }
            else {
                List<ProductStock> psList = new List<ProductStock>();
                for (Stock_Product__c stockProduct : existingStock) {
                    ProductStock ps = new ProductStock();
                    ps.stock = stockProduct;
                    ps.prod = new Product2(Id = stockProduct.Product__c, Name = stockProduct.Product__r.Name);
                    
                    psList.add(ps);
                }
                return psList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string saveStockRecord(string payload,string year,string month){
		system.debug('payload>>>'+payload);
        List<sobject> accountList = UtilityController.returnObjList();  
        //system.debug('accountList>>>>'+accountList);
        Account acc = (Account)accountList[0];
        // string accountId = '0011g00000u7SSdAAM';
        string QueryText = 'SELECT Id from Stock__c  where Month__c = :month  and Year__c = : year';

        if(accountList.size()>0)
        {
                QueryText +=  ' and Account__c IN: accountList ';           
        }
        else {
            throw new AuraHandledException('User do not have any associated market');
        }
        
        // SC-009042 to display latest on top
 		QueryText +=  ' order by Createddate desc';
        
        List<Stock__c> stockCount = Database.query(QueryText);
        if(stockCount.size() > 0)
        {
            
            // system.debug('Stock count==>' + stockCount.size());
            throw new AuraHandledException('You have submitted record for the month, you cannot enter again for the same month');
        }

        List<Stock_Product__c> spList = new List<Stock_Product__c>();
        try{
                PSList recList = (PSList)JSON.deserialize(payload,PSList.class);
                // system.debug('recList'+recList);

                Stock__c stock = new Stock__c();
                stock.Month__c = month;
                stock.Year__c = year;
                stock.Account__c = acc.Id;
                stock.Market_Account__c = acc.ZTS_EU_Market__c;
                insert stock;

                for(ProductStock ps : recList.psOfList){
                               // System.debug('SP:==>>>'+ ps.stock);
                                Stock_Product__c sp = new  Stock_Product__c();
                                sp.SAP_Product_Code__c = ps.stock.SAP_Product_Code__c;
                                sp.Product__c = ps.prod.Id;
                                sp.Distributor_Product_Code__c = ps.stock.Distributor_Product_Code__c;
                                sp.Distributor_Product_Name__c = ps.stock.Distributor_Product_Name__c;
                                sp.Batch_Lot_Number__c = ps.stock.Batch_Lot_Number__c;
                                sp.Quantity__c = ps.stock.Quantity__c;
                                sp.Expiration_Date__c = ps.stock.Expiration_Date__c;
                                sp.Stock__c = stock.Id;
                                sp.Unit_of_Measure__c = ps.stock.Unit_of_Measure__c;
                                spList.Add(sp);

                }
                insert spList;

                return 'Success';
            }
            catch(Exception ex){
                 throw new AuraHandledException(ex.getMessage());
            }
    }

    @AuraEnabled
    public static void saveForecastRecord(string payload,string year,string month){
        System.debug('payload: ' + payload);
        System.debug('Year:==>>>'+ year);
        System.debug('month:==>>>'+ month);

        List<Forecast_Product__c> fpList = new List<Forecast_Product__c>();
        String userId = userinfo.getUserId();
        User userData = [SELECT Id, Contact.AccountId, Contact.Account.ZTS_EU_Market__c FROM User WHERE Id = :userId];
        try{
            PFList recList = (PFList)JSON.deserialize(payload,PFList.class);

            Forecast__c forecast = new Forecast__c();
            forecast.Month__c = month;
            forecast.Year__c = year;
            forecast.Account__c = userData.Contact.AccountId;
            forecast.Market_Account__c = userData.Contact.Account.ZTS_EU_Market__c;
            
            List<Forecast__c> forecastSearch = [SELECT Id, Month__c, Year__c, Account__c FROM Forecast__c WHERE Month__c = :forecast.Month__c AND Year__c = :forecast.Year__c AND Account__c = :forecast.Account__c];
            List<Forecast_Product__c> existingFPList = new List<Forecast_Product__c>();
            if (forecastSearch.size() > 0) {
                existingFPList = [SELECT Id, SAP_Product_Code__c, Product__c, Forecast__c FROM Forecast_Product__c WHERE Forecast__c = :forecastSearch[0].Id];
               // System.debug('existingFPList: ' + existingFPList);
            }
            else {
               // System.debug('No existingFPList');
                insert forecast;
            }

           // System.debug(recList);
            for(ProductForecast pf : recList.pfOfList){
              //  System.debug('SP:==>>>'+ pf.forecast);
                Forecast_Product__c fp = new Forecast_Product__c();
                fp.SAP_Product_Code__c = pf.forecast.SAP_Product_Code__c;
                fp.Product__c = pf.prod.Id;
                fp.Distributor_Product_Code__c = pf.forecast.Distributor_Product_Code__c;
                fp.Distributor_Product_Name__c = pf.forecast.Distributor_Product_Name__c;
                fp.Quantity__c = pf.forecast.Quantity__c;
                fp.Price__c = pf.forecast.Price__c;
                fp.CurrencyIsoCode = pf.forecast.CurrencyIsoCode;
                fp.Unit_of_Measure__c = pf.forecast.Unit_of_Measure__c;

                if (forecastSearch.size() > 0) {
                    //System.debug('debug start');
                    //System.debug(existingFPList);
                   // System.debug(fp.Forecast__c);
                    Boolean foundExisting = false;
                    for (Forecast_Product__c existingFP : existingFPList) {
                        if (fp.SAP_Product_Code__c == existingFP.SAP_Product_Code__c && fp.SAP_Product_Code__c == existingFP.SAP_Product_Code__c) {
                            fp.Id = existingFP.Id;
                            foundExisting = true;
                            break;
                        }
                    }
                    if (!foundExisting) {
                        fp.Forecast__c = forecastSearch[0].Id;
                    }
                }
                else {
                    fp.Forecast__c = forecast.Id;
                }

                fpList.add(fp);
            }
            if(!Test.isRunningTest())
            upsert fpList;
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
            system.debug(ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ResultSet> loadForecastView(string month, string year,string accountId){
        
        Map<string,sobject> accmap = new Map<string,sobject>();
        List<sobject> accountList = UtilityController.returnObjList();
        
         accmap.putAll(accountList);
        // system.debug('+++++++++++++++'+accountList);
        // system.debug('>>>>'+month+'+++++++++++'+year);
        try {
            
            System.debug('Account ID' + accountId);
            //This is for testing & demo only...
             if(String.isEmpty(accountId))
             {
                 //accountId = '0011g00000u7SSdAAM';
             }
           
            List<ResultSet> resultSet = new List<ResultSet>();
            string quanField = 'Quantity__c';

                        string QueryText = 'SELECT Id,Name,Product__r.Name,Forecast__r.Month__c,Forecast__r.Name,CurrencyIsoCode,Price__c,SAP_Product_Code__c,Unit_of_Measure__c,Forecast__r.Year__c,Forecast__r.Account__r.Name,Quantity__c,createddate,Distributor_Product_Code__c,Distributor_Product_Name__c,(SELECT ParentId,OldValue, NewValue,createddate FROM Histories where field = :quanField) from Forecast_Product__c  where Forecast__r.Month__c = :month  and Forecast__r.Year__c = : year' ;

		//	system.debug('Qurey==>' + QueryText);
            
            if(!String.isEmpty(accountId) )
            {
                if(accmap.size()>0 && (!accmap.containskey(accountId))){
                    throw new AuraHandledException('Market Mismatch');
                }else{
                    QueryText = QueryText + ' and Forecast__r.Account__c = :accountId';
                }
                //system.debug('Qurey==>' + QueryText);
            }
            else {
               // system.debug('Enter>>>>>>>>>');
                QueryText +=  ' and Forecast__r.Account__c IN: accountList ';
            }
            
            // SC-009042,TPDev-758
            QueryText += ' ORDER BY Forecast__r.CreatedDate DESC,Product__r.Name ASC';


           // system.debug('Qurey==>' + QueryText);
            List<Forecast_Product__c> lstFP = Database.query(QueryText);
           // system.debug('FP Size==>' + lstFP.size());
            for(Forecast_Product__c fp :lstFP )
            {

                    if(fp.Histories.size()> 0)
                    {
                        for(Forecast_Product__History fh : fp.Histories)
                            {
                                ResultSet rs = new ResultSet();
                                    rs.Id = fp.Id;
                                    rs.forecastNumber = fp.Forecast__r.Name;
                                    rs.sapProductCode = fp.SAP_Product_Code__c;
                                    rs.uom = fp.Unit_of_Measure__c;
                                    rs.price = string.valueOf(fp.Price__c);
                                    rs.currencyCode = fp.CurrencyIsoCode;
                                    rs.distProdCode = fp.Distributor_Product_Code__c;
                                    rs.distProdName = fp.Distributor_Product_Name__c;
                                    rs.accountName = fp.Forecast__r.Account__r.Name;
                                    rs.productName = fp.Product__r.Name;
                                    rs.forecastMonth = fp.Forecast__r.Month__c;
                                    rs.forecastYear = fp.Forecast__r.Year__c;
                                    rs.updateDate = fh.createddate.format('yyyy/MM/dd');
                                if(String.isBlank(String.valueof(fh.OldValue)))
                                    {
                                            rs.oldValue = '0';
                                            rs.newValue = String.valueof(fp.Quantity__c).substringBefore('.');
                                    }
                                    else{
                                            rs.oldValue = String.valueof(fh.OldValue);
                                            rs.newValue = String.valueof(fh.NewValue);
                                    }
                                    resultSet.Add(rs);
                               // System.debug('FP:==>>>'+ rs);
                                }    
                                  
                    }
                    else {
                            ResultSet rs = new ResultSet();
                                    rs.Id = fp.Id;
                                    rs.forecastNumber = fp.Forecast__r.Name;
                                    rs.sapProductCode = fp.SAP_Product_Code__c;
                                    rs.uom = fp.Unit_of_Measure__c;
                                    rs.price = string.valueOf(fp.Price__c);
                                    rs.currencyCode = fp.CurrencyIsoCode;
                                    rs.distProdCode = fp.Distributor_Product_Code__c;
                                    rs.distProdName = fp.Distributor_Product_Name__c;
                                    rs.accountName = fp.Forecast__r.Account__r.Name;
                                    rs.productName = fp.Product__r.Name;
                                    rs.forecastMonth = fp.Forecast__r.Month__c;
                                    rs.forecastYear = fp.Forecast__r.Year__c;
                                    rs.updateDate = fp.createddate.format('yyyy/MM/dd');
                                    rs.oldValue = '0';
                                    rs.newValue = String.valueof(fp.Quantity__c).substringBefore('.');
                                    resultSet.Add(rs);
                        
                    }                            
            }
               // System.debug('RS:==>>>'+ resultSet);
                return resultSet;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ResultSet> loadStockView(string month, string year, string accountId){
        
        Map<string,sobject> accmap = new Map<string,sobject>();
        List<sobject> accountList = UtilityController.returnObjList();
       // system.debug(accountList);
        //for(account eachacc: sobject){
            accmap.putAll(accountList);
        //}
        
        try {
            
            //System.debug('Account ID' + accountId);
            //This is for testing & demo only...
             if(String.isEmpty(accountId))
             {
                 //accountId = '0011g00000u7SSdAAM';
             }

            List<ResultSet> resultSet = new List<ResultSet>();
            string quanField = 'Quantity__c';

           // System.debug('Month:==>>>'+ month);
           // System.debug('Year:==>>>'+ year);
            string QueryText = 'SELECT Id,Stock__r.Name,Expiration_Date__c,Name,Product__r.Name,Stock__r.Month__c, Stock__r.Year__c,Stock__r.Account__r.Name,Quantity__c,Batch_Lot_Number__c,Distributor_Product_Code__c,Distributor_Product_Name__c,SAP_Product_Code__c,Unit_of_Measure__c,createddate  from Stock_Product__c  where Stock__r.Month__c = :month  and Stock__r.Year__c = : year';
                     // system.debug('QueryText'+QueryText);
           if(!String.isEmpty(accountId))
            {
                if( !accmap.containskey(accountId)){
                    throw new AuraHandledException('Market Mismatch');
                }else{
                    QueryText = QueryText + ' and Stock__r.Account__c = :accountId';
                }                          
            }
            else {
                QueryText +=  ' and Stock__r.Account__c IN: accountList ';
            }
             // SC-009042, TPDev-758
             QueryText += ' ORDER BY Stock__r.CreatedDate DESC,Product__r.Name ASC';
             // QueryText +='ORDER BY Product__r.Name ASC';
            //System.debug('Query Text ===>>>' + QueryText);
            List<Stock_Product__c> lstFP = Database.query(QueryText);

            for(Stock_Product__c fp :lstFP )
            {
            
                ResultSet rs = new ResultSet();
                    rs.Id = fp.Id;
                    rs.stockNumber = fp.Stock__r.Name;
                    rs.sapProductCode = fp.SAP_Product_Code__c;
                    rs.uom = fp.Unit_of_Measure__c ;
                    // rs.price = string.valueOf(fp.Price__c);
                    // rs.currencyCode = fp.CurrencyIsoCode;
                    rs.distProdCode = fp.Distributor_Product_Code__c;
                    rs.distProdName = fp.Distributor_Product_Name__c;
                    rs.expiryDate = string.valueOf(fp.Expiration_Date__c);
                    rs.accountName = fp.Stock__r.Account__r.Name;
                    rs.productName = fp.Product__r.Name;
                    rs.forecastMonth = fp.Stock__r.Month__c;
                    rs.forecastYear = fp.Stock__r.Year__c;
                    rs.updateDate = fp.createddate.format('yyyy/MM/dd');
                    rs.quantity = String.valueof(fp.Quantity__c).substringBefore('.');
                    rs.batchNo = fp.Batch_Lot_Number__c;          
                    // rs.oldValue = String.valueof(fh.OldValue);
                    // rs.newValue = String.valueof(fh.NewValue);
    
                

                resultSet.Add(rs);
            
        }
        // System.debug('Final LIST:==>>>'+ resultSet);
        return resultSet;
        } catch (Exception e) {
            system.debug(e.getMessage());
            system.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    //This is class which will hold each display record..
    Public class ResultSet {
        @AuraEnabled
            public string Id{get;set;}
            @AuraEnabled
            public string accountName{get;set;}
            @AuraEnabled
            public string productName{get;set;}
            @AuraEnabled
            public string forecastMonth{get;set;}
            @AuraEnabled
            public string forecastYear{get;set;}
            @AuraEnabled
            public string updateDate{get;set;}
            @AuraEnabled
            public string oldValue{get;set;}
            @AuraEnabled
            public string newValue{get;set;}
            @AuraEnabled
            public string quantity{get;set;}
            @AuraEnabled
            public string batchNo{get;set;}
            @AuraEnabled
            public string forecastNumber{get;set;}
             @AuraEnabled
            public string stockNumber{get;set;}
            @AuraEnabled
            public string sapProductCode{get;set;}
             @AuraEnabled
            public string uom{get;set;}
              @AuraEnabled
            public string price{get;set;}
             @AuraEnabled
            public string currencyCode{get;set;}
              @AuraEnabled
            public string expiryDate{get;set;}
             @AuraEnabled
            public string distProdCode{get;set;}
              @AuraEnabled
            public string distProdName{get;set;}
    }

    public class ProductStock {
        @AuraEnabled
        public Product2 prod{get;set;}
        @AuraEnabled
        public Stock_Product__c stock{get;set;}
    }

    public class ProductForecast {
        @AuraEnabled
        public Product2 prod{get;set;}
        @AuraEnabled
        public Forecast_Product__c forecast{get;set;}
    }

    public class PSList{
         public List<ProductStock> psOfList{get;set;}
    }

    public class PFList{
        public List<ProductForecast> pfOfList{get;set;}
    }
    
    
    
    
    


    
}