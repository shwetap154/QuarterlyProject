/**
* @description       : Service Class for SAPCustomerMaterialPrice__c
* @author            : Morgan Marchese @ Zoetis Inc
* @group             : Service Layer
* @last modified on  : 03-30-2022
* @last modified by  : Ethan Hirsch @ Zoetis Inc
* Modifications Log 
* Ver   Date         Author                         Modification
* 1.0   07-20-2021   Morgan Marchese @ Zoetis Inc   Initial Version
* 1.1   03-30-2022   Ethan Hirsch @ Zoetis Inc      Add removeDuplicateRecords method
**/
public with sharing class SAPCustomerMaterialPricesService {
    
    /**
* @description Finds or Creates AccountProductPortfolio__c records related to 
* SAPCustomerMaterialPrice__c records.
* @author Namrata Patane @ Zoetis Inc | 07-20-2021 
* @param List<SAPCustomerMaterialPrice__c> listMaterialPrice 
**/
    public static void linkToAccountProductPortfolio(List<SAPCustomerMaterialPrice__c> listMaterialPrice){
        Map<String ,Set<Id>> mapCustNoToPrdIDs = new Map<String,Set<Id>>(); // map<Customer_Number__c,  setProductIds> 
        Map<Id,Set<Id>> mapAccIdToPrdID = new Map<Id,Set<Id>>();  // map<AccountId, setProductIds>
        Map<String,String> mapOfAPkeyToCustNo = new Map<String,String>();  // map<AccountId + ProductID , Customer_Number__c>
        Map<String,Id> mapCustNumberToAccID = new Map<String,Id>();   
        Set<Id> productIds = new Set <Id>(); 
        Set<Id> setAllProductIds = new Set<Id>();
        List<Address__c> lstAddress;
        List<SAPCustomerMaterialPrice__c> lstToUpdate = new List<SAPCustomerMaterialPrice__c>();
        List<SAPCustomerMaterialPrice__c> lstTempData = new List<SAPCustomerMaterialPrice__c>();
        
        // Get SAP Customer Numbers and Product Ids from Scope
        for(SAPCustomerMaterialPrice__c objSAPCMP: listMaterialPrice){
            if(!String.isBlank(objSAPCMP.Customer_Number__c) && !String.isBlank(objSAPCMP.Product__c)){
                System.debug('Customer Number: ' + objSAPCMP.Customer_Number__c);
                System.debug('Product Id: ' + objSAPCMP.Product__c);
                if(mapCustNoToPrdIDs.containsKey(objSAPCMP.Customer_Number__c)){
                    mapCustNoToPrdIDs.get(objSAPCMP.Customer_Number__c).add(objSAPCMP.Product__c);
                }else{
                    mapCustNoToPrdIDs.put(objSAPCMP.Customer_Number__c, new Set<Id> { objSAPCMP.Product__c });
                }
            }
        }
        system.debug('Log1 mapCustNoToPrdIDs-----'+mapCustNoToPrdIDs);
        // Get Account Ids by Querying for Address records that match SAP Customer Numbers   
        if(!mapCustNoToPrdIDs.isEmpty()){
            System.debug('Query Keyset: ' + mapCustNoToPrdIDs.keySet());
            lstAddress = AddressesSelector.newInstance().selectBySourceAccountNumberAndType(mapCustNoToPrdIDs.keyset(),new Set<String>{'Main'});
            System.debug('lstAddress'+lstAddress);        
            for(Address__c objAdd : lstAddress){ 
                if(objAdd.ZTS_US_Source_Account_Number__c != null){
                    // Get Values from Map for re-use
                    System.debug('Source Account Number: ' + objAdd.ZTS_US_Source_Account_Number__c);
                    mapCustNumberToAccID.put(objAdd.ZTS_US_Source_Account_Number__c, objAdd.ZTS_EU_Account__c); //map AccountId to CustomerNumber
                    productIds = mapCustNoToPrdIDs.get(objAdd.ZTS_US_Source_Account_Number__c); 
                    System.debug('Product Ids: ' + productIds);
                    if(productIds != null){
                        mapAccIdToPrdID.put(objAdd.ZTS_EU_Account__c, productIds);
                        setAllProductIds.addAll(productIds);
                        for(Id prdID : productIds){
                            String keyAccIdAndPrdId = String.valueOf(objAdd.ZTS_EU_Account__c) + String.valueOf(prdID);
                            mapOfAPkeyToCustNo.put(keyAccIdAndPrdId,objAdd.ZTS_US_Source_Account_Number__c);
                        }
                    }
                }
            }
        } 
        
        // Find pre-existing AccountProductPortfolio__c records for matching Accounts/Products
        
        Map<String,Map<String,AccountProductPortfolio__c>> mapCustNoToMapAccPortfolioObj = new Map<String,Map<String,AccountProductPortfolio__c>>();
        Set<String> seenKeys = new Set<String>();
        //Structure : MAP<CustomerNumber,MAP<'CustomerNo + AccountProductPortfolio.ProductID', AccountProductPortfolio>>
        if(!mapAccIdToPrdID.isEmpty()){       
            List<AccountProductPortfolio__c> lstAccPrdProf = [SELECT Id,Account__c,Product__c FROM AccountProductPortfolio__c WHERE Account__c IN :mapAccIdToPrdID.keyset() AND Product__c IN : setAllProductIds];
            System.debug('lstAccPrdProf--->'+lstAccPrdProf);
            if(lstAccPrdProf.size() > 0){
                String sCustNumb;
                for(AccountProductPortfolio__c objAccProdProf :lstAccPrdProf ){
                    String uniqID = String.valueOf(objAccProdProf.Account__c) + String.valueOf(objAccProdProf.Product__c);
                    sCustNumb = mapOfAPkeyToCustNo.get(uniqID);
                    String keyCustNoAndPrdID = sCustNumb + String.valueOf(objAccProdProf.Product__c);
                    if(mapCustNoToMapAccPortfolioObj.containsKey(sCustNumb)){                        
                        mapCustNoToMapAccPortfolioObj.get(sCustNumb).put(keyCustNoAndPrdID,objAccProdProf);             
                    }else{
                        mapCustNoToMapAccPortfolioObj.put(sCustNumb, new Map<String,AccountProductPortfolio__c> { keyCustNoAndPrdID =>objAccProdProf });
                    }
                }
            }
            system.debug('mapCustNoToMapAccPortfolioObj--->'+mapCustNoToMapAccPortfolioObj);
            //Map<String,List<AccountProductPortfolio__c>> mapCustNoToAccProfileObj = new Map<String,List<AccountProductPortfolio__c>>();
            List<AccountProductPortfolio__c> lsttempMAptoInsert = new List<AccountProductPortfolio__c>();
            for(SAPCustomerMaterialPrice__c objSAPCMP: listMaterialPrice){
                Id accountId = mapCustNumberToAccID.get(objSAPCMP.Customer_Number__c);
                if(accountId == null) continue;
                String keyForMap = String.valueOf(objSAPCMP.Customer_Number__c) + String.valueOf(objSAPCMP.Product__c);
                // has at least 1 portfolio record
                if(mapCustNoToMapAccPortfolioObj.containsKey(objSAPCMP.Customer_Number__c)){   
                    Map<String,AccountProductPortfolio__c> tempMapAccPrdPortflio = mapCustNoToMapAccPortfolioObj.get(objSAPCMP.Customer_Number__c);  
                    // has a portfolio record matching key of customer/product                                   
                    if(tempMapAccPrdPortflio.containsKey(keyForMap)){
                        //link SAPCustomerMaterialPrice__c record to the existing AccountProductPortfolio record
                        AccountProductPortfolio__c objAccPrdPort = tempMapAccPrdPortflio.get(keyForMap);
                        objSAPCMP.Account_Product_Portfolio__c = objAccPrdPort.id; 
                        lstToUpdate.add(objSAPCMP);
                        
                    }else{
                        //create new AccountProductPortfolio record related to that Account And Product
                        lstTempData.add(objSAPCMP);
                        if(!seenKeys.contains(keyForMap)){
                            AccountProductPortfolio__c objPrdPortflio = new AccountProductPortfolio__c();
                            objPrdPortflio.Account__c= mapCustNumberToAccID.get(objSAPCMP.Customer_Number__c);
                            objPrdPortflio.Product__c =objSAPCMP.Product__c;
                            lsttempMAptoInsert.add(objPrdPortflio);

                            seenKeys.add(keyForMap);
                            System.debug('Create a new object record');
                        }
                    }
                    
                }else{ //TODO : Remove code repetition 
                    //create new AccountProductPortfolio record related to that Account And Product
                    // Key: 123/P1
                    lstTempData.add(objSAPCMP);
                    if(!seenKeys.contains(keyForMap)){
                        system.debug('Here--->>'+objSAPCMP.Customer_Number__c);
                        AccountProductPortfolio__c objPrdPortflio = new AccountProductPortfolio__c();
                        objPrdPortflio.Account__c= mapCustNumberToAccID.get(objSAPCMP.Customer_Number__c);
                        objPrdPortflio.Product__c =objSAPCMP.Product__c;

                        lsttempMAptoInsert.add(objPrdPortflio);
                        seenKeys.add(keyForMap);
                    }
                }
            }

            System.debug('SeenKeys Size: ' + seenKeys.size());
            System.debug('SeenKeys: ' + seenKeys);
            
            Map<Id,Map<String,Id>> mapAccIDToPortfoloioObj = new Map<Id,Map<String,Id>>();
            if(lsttempMAptoInsert.size() > 0){
                //insert mapCustNoToAccProfileObj.values();
                insert lsttempMAptoInsert;
                
                String AccPrdIdKey;
                Id AccountID;
                
                for(AccountProductPortfolio__c objAPrdPortflio :lsttempMAptoInsert){
                    AccPrdIdKey = String.valueOf(objAPrdPortflio.Account__c) + String.valueOf(objAPrdPortflio.Product__c);
                    if(mapAccIDToPortfoloioObj.containsKey(objAPrdPortflio.Account__c)){
                        mapAccIDToPortfoloioObj.get(objAPrdPortflio.Account__c).put(AccPrdIdKey,objAPrdPortflio.Id);
                    }else{
                        mapAccIDToPortfoloioObj.put(objAPrdPortflio.Account__c, new Map<String,Id> { AccPrdIdKey => objAPrdPortflio.Id });
                    }
                }
                
                for(SAPCustomerMaterialPrice__c objSAPCMP: lstTempData){
                    //Get Related Account Number
                    AccountId = mapCustNumberToAccID.get(objSAPCMP.Customer_Number__c);
                    if(mapAccIDToPortfoloioObj.containsKey(AccountId)){
                        Map<String,Id> tempMap = mapAccIDToPortfoloioObj.get(AccountId);
                        String sAcPrIdMapkey = String.valueOf(AccountId) + String.valueOf(objSAPCMP.Product__c);
                        if(tempMap.containsKey(sAcPrIdMapkey)){
                            objSAPCMP.Account_Product_Portfolio__c = tempMap.get(sAcPrIdMapkey);
                            lstToUpdate.add(objSAPCMP);  
                        }
                    }
                    
                    
                }
            }
            
            
            if(lstToUpdate.size() > 0){
                update lstToUpdate;
            }
        }
    }

    /**
    * @description Removes duplicate SAP Customer Material Prices from a list based on Sales Org, Customer Number, and Material Number
    * @author Ethan Hirsch @ Zoetis Inc | 03-30-2022 
    * @param materialPrices 
    * @return List<SAPCustomerMaterialPrice__c> 
    **/
    public static List<SAPCustomerMaterialPrice__c> removeDuplicateRecords(List<SAPCustomerMaterialPrice__c> materialPrices) {
        Map<String, SAPCustomerMaterialPrice__c> uniqueCustomerMaterialPricesByKey = new Map<String, SAPCustomerMaterialPrice__c>();
        
        for (SAPCustomerMaterialPrice__c materialPrice : materialPrices) {
            string key = string.format('{0}{1}{2}', new List<Object> {
                materialPrice.Customer_Number__c, materialPrice.Material_Number__c, 
                materialPrice.Sales_Organization__c
            });

            if (uniqueCustomerMaterialPricesByKey.containsKey(key) == false) {
                uniqueCustomerMaterialPricesByKey.put(key, materialPrice);
            }
        }

        return uniqueCustomerMaterialPricesByKey.values();
    }
}