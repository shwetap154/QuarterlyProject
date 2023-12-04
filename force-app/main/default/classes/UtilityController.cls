/**
 * @description       : Common and helper methods used by controllers in the Distributor Community
 * @author            : Morgan Marchese @ Zoetis Inc (Production Deployer)
 * @group             : 
 * @last modified on  : 03-30-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                                               Modification
 * 1.0   08-28-2021   Morgan Marchese @ Zoetis Inc (Production Deployer)   Initial Version
 * 1.1   09-07-2021   Chelsea Paice @ Zoetis Inc (Production Deployer)     Unknown Updates
 * 1.2   03-30-2022   Ethan Hirsch @ Zoetis Inc                            Update methods querying for SAPCustomerMaterialPrice__c records to use the SAPCustomerMaterialSelector and have duplicates removed.
**/
public without sharing class UtilityController {
    
     @AuraEnabled(cacheable=true)
    public static List<SObject> findRecords(String searchKey, String objectName, String searchField){
        String key =  searchKey + '%';
        String QUERY = 'Select Id, '+searchField+' From '+objectName +' Where '+searchField +' LIKE :key LIMIT 10';
        //System.debug(System.LoggingLevel.DEBUG, QUERY);
        List<SObject> sObjectList = Database.query(QUERY);
        //System.debug(System.LoggingLevel.DEBUG, sObjectList);
        return sObjectList;
    }

    @AuraEnabled (cacheable = true)
    public static List<SObject> findRecordsModular(String searchKey, String objectName, String searchField, String additionalFields, String conditions){
       String key = '%' + searchKey + '%';
       String QUERY = 'SELECT Id, ' + searchField + additionalFields + ' FROM ' + objectName + ' WHERE ' + searchField + ' LIKE :key ' + conditions;
       System.debug(QUERY);
       List<SObject> sObjectList = Database.query(QUERY);
       return sObjectList;
   }
    
        public static List<sobject> returnObjList(){

    //It will return sobject-Account List.
        String uId = userinfo.getUserId();
        system.debug('uId>>>>'+uId);
        String QUERY = '';
        String distaccId = ' ';
        String userMarketstr = ' ';
        
        User uMarket = [Select ZTS_EU_Market__c,Profile.name,ContactId,Contact.AccountId from User where Id=: uId limit 1];
        system.debug('uMarket>>>>'+uMarket);
        userMarketstr = uMarket.ZTS_EU_Market__c;
        system.debug('userMarketstr>>>>'+userMarketstr);
        distaccId = uMarket.Contact.AccountId;
        
        if(uMarket.profile.name == 'Distributor Community User'){
            system.debug('enter>>>>');
            QUERY += 'Select Id,ZTS_EU_Market__c From Account Where Id =:   distaccId  ';
        }else{
            system.debug('enter>>>>');
        	QUERY += 'Select Id,ZTS_EU_Market__c From Account Where ZTS_EU_Market__c =:   userMarketstr  ';
        }
        system.debug(QUERY);
        //System.debug(System.LoggingLevel.DEBUG, QUERY);
        List<SObject> sObjectList = Database.query(QUERY);
        //System.debug(System.LoggingLevel.DEBUG, sObjectList);
        return sObjectList;
        
    }
    
    /**
    * @description For the Current User, returns a list of Products. 
         These Products are returned based on the following information:
         1. The User's Contact's Account (The User must be a Community User)
         2. The Addresses related to the Account's Account Numbers
         3. The active SAP Customer Material Prices for that Account
    * @author Unknown | Unknown 
    **/
     @AuraEnabled(cacheable=true)
    public static List<product2> returnProdList(){
        
        String uId = userinfo.getUserId();
        String QUERY = '';
        String distaccId = ' ';
        String userMarketstr = ' ';
        Map<String,Address__c> addrMap = new Map<String,Address__c>();
        List<Product2> prodList = new List<Product2>();
        set<Id> prodIdSet = new set<Id>();
        List<Id> excludeRecordIds = new List<Id>();
        
        User uMarket = [Select ZTS_EU_Market__c,Profile.name,ContactId,Contact.AccountId from User where Id=: uId limit 1];
        userMarketstr = uMarket.ZTS_EU_Market__c;
        distaccId = uMarket.Contact.AccountId;
        if(distaccId != null){
            for(Address__c eachaddr : [Select Id,ZTS_EU_Account__c , ZTS_US_Source_Account_Number__c from Address__c where ZTS_EU_Account__c =: distaccId ]){
                addrMap.put(eachaddr.ZTS_US_Source_Account_Number__c,eachaddr);
            }
            if(addrMap.size()>0){
                for(SAPCustomerMaterialPrice__c eachsapCustomer : SAPCustomerMaterialPricesSelector.newInstance().selectValidByCustomerNumbersWithProduct(
                                                                      addrMap.keyset())) {
                    prodIdSet.add(eachsapCustomer.Product__c);                                                  
                }
            }
            
            if(prodIdSet.size()>0){
                for(product2 eachproduct : [SELECT Id, Name, SAP_Product_Number__c, Description, SAP_Sales_Unit_of_Measure__c, QuantityUnitOfMeasure, Business_Unit__c, CurrencyIsoCode FROM Product2 WHERE Id IN :prodIdSet ORDER BY Name ASC])
                {
                    prodList.add(eachproduct);
                    
                }
                
                
            }
            
        }
        return prodList;
       
        
    }

    /**
    * @description For the Current User, returns a Map of Price by Product Id. 
        These Prices are returned based on the following information:
         1. The User's Contact's Account (The User must be a Community User)
         2. The Addresses related to the Account's Account Numbers
         3. The active SAP Customer Material Prices for that Account
    * @author Unknown | Unknown 
    * @return Map<String, Decimal> 
    **/
    public static Map<String, Decimal> returnPriceList() {
        String uId = userinfo.getUserId();
        String distaccId = ' ';
        String userMarketstr = ' ';
        Map<String, Address__c> addrMap = new Map<String, Address__c>();
        Map<String, Decimal> priceList = new Map<String, Decimal>();

        User uMarket = [SELECT ZTS_EU_Market__c, Profile.Name, ContactId, Contact.AccountId FROM User WHERE Id = :uId LIMIT 1];
        userMarketstr = uMarket.ZTS_EU_Market__c;
        distaccId = uMarket.Contact.AccountId;
        if (distaccId != null) {
            for (Address__c eachAddr : [SELECT Id, ZTS_EU_Account__c, ZTS_US_Source_Account_Number__c FROM Address__c WHERE ZTS_EU_Account__c = :distaccId ]){
                addrMap.put(eachAddr.ZTS_US_Source_Account_Number__c, eachAddr);
            }
            if (addrMap.size() > 0) {
                for (SAPCustomerMaterialPrice__c eachSapCustomer : SAPCustomerMaterialPricesService.removeDuplicateRecords(
                                                                       SAPCustomerMaterialPricesSelector.newInstance().selectValidByCustomerNumbersWithProduct(
                                                                           addrMap.keyset()))) {
                    priceList.put(eachSapCustomer.Product__c, eachSapCustomer.Price__c);
                }
            }
        }
        return priceList;
    }

    /**
    * @description For the Current User, returns a Map of UOM by Product Id. 
        These UOMs are returned based on the following information:
         1. The User's Contact's Account (The User must be a Community User)
         2. The Addresses related to the Account's Account Numbers
         3. The active SAP Customer Material Prices for that Account
    * @author Unknown | Unknown 
    * @return Map<String, String> 
    **/
    public static Map<String, String> returnUOMList() {
        String uId = userinfo.getUserId();
        String distaccId = ' ';
        String userMarketstr = ' ';
        Map<String, Address__c> addrMap = new Map<String, Address__c>();
        Map<String, String> uomList = new Map<String, String>();

        User uMarket = [SELECT ZTS_EU_Market__c, Profile.Name, ContactId, Contact.AccountId FROM User WHERE Id = :uId LIMIT 1];
        userMarketstr = uMarket.ZTS_EU_Market__c;
        distaccId = uMarket.Contact.AccountId;
        if (distaccId != null) {
            for (Address__c eachAddr : [SELECT Id, ZTS_EU_Account__c, ZTS_US_Source_Account_Number__c FROM Address__c WHERE ZTS_EU_Account__c = :distaccId ]){
                addrMap.put(eachAddr.ZTS_US_Source_Account_Number__c, eachAddr);
            }
            if (addrMap.size() > 0) {
                for (SAPCustomerMaterialPrice__c eachSapCustomer : SAPCustomerMaterialPricesService.removeDuplicateRecords(
                                                                       SAPCustomerMaterialPricesSelector.newInstance().selectValidByCustomerNumbersWithProduct(
                                                                           addrMap.keyset()))) {
                    uomList.put(eachSapCustomer.Product__c, eachSapCustomer.Unit_of_Measure__c);
                }
            }
        }
        return uomList;
    }

    /**
    * @description For the Current User, returns a Map of Currency ISO Codes Id by Product Id. 
        These Currency ISO Codes are returned based on the following information:
         1. The User's Contact's Account (The User must be a Community User)
         2. The Addresses related to the Account's Account Numbers
         3. The active SAP Customer Material Prices for that Account
    * @author Unknown | Unknown 
    * @return Map<String, String> 
    **/
    public static Map<String, String> returnCurrencyIsoCode() {
        String uId = userinfo.getUserId();
        String distaccId = ' ';
        String userMarketstr = ' ';
        Map<String, Address__c> addrMap = new Map<String, Address__c>();
        Map<String, String> uomList = new Map<String, String>();

        User uMarket = [SELECT ZTS_EU_Market__c, Profile.Name, ContactId, Contact.AccountId FROM User WHERE Id = :uId LIMIT 1];
        userMarketstr = uMarket.ZTS_EU_Market__c;
        distaccId = uMarket.Contact.AccountId;
        if (distaccId != null) {
            for (Address__c eachAddr : [SELECT Id, ZTS_EU_Account__c, ZTS_US_Source_Account_Number__c FROM Address__c WHERE ZTS_EU_Account__c = :distaccId ]){
                addrMap.put(eachAddr.ZTS_US_Source_Account_Number__c, eachAddr);
            }
            if (addrMap.size() > 0) {
                for (SAPCustomerMaterialPrice__c eachSapCustomer : SAPCustomerMaterialPricesService.removeDuplicateRecords(
                                                                       SAPCustomerMaterialPricesSelector.newInstance().selectValidByCustomerNumbersWithProduct(
                                                                           addrMap.keyset()))) {
                    uomList.put(eachSapCustomer.Product__c, eachSapCustomer.CurrencyIsoCode);
                }
            }
        }
        return uomList;
    }

    // TODO: Replace the relevant functionality in returnProdList(), returnPriceList(), returnUOMList(), and returnCurrencyIsoCode with this function
    public static Map<String, Address__c> getAccountNumbers() {
        String userId = userinfo.getUserId();
        String userAccount = ' ';
        Map<String, Address__c> addressMap = new Map<String, Address__c>();

        User uMarket = [SELECT ZTS_EU_Market__c, Profile.Name, ContactId, Contact.AccountId FROM User WHERE Id = :userId LIMIT 1];
        userAccount = uMarket.Contact.AccountId;
        if (userAccount != null) {
            for (Address__c eachAddr : [SELECT Id, ZTS_EU_Account__c, ZTS_US_Source_Account_Number__c FROM Address__c WHERE ZTS_EU_Account__c = :userAccount]){
                addressMap.put(eachAddr.ZTS_US_Source_Account_Number__c, eachAddr);
            }
        }
        return addressMap;
    }
    
  
}