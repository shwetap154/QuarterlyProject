/**
* File Name     :  CPQOrdersCreatedFromSAPSalesOrderHandler
* @description  :  Handler class for OrderItem update/clone when a "missing" product is inserted and OrderItems have SAP_Product_Number__c matching the new Prod.ProductCode
*                   These OrderItem records are created for SAP Staging type Orders (no Quote/QuoteLines) and may or may not have the correct Product on creation (will be some "Generic" product to satisfy the integration)
* Test Class    :  CPQOrderCreatedFromSAPSalesOrderHandlerT
* @author       :  Nicholas Grasseschi @ CTS - Cognizant Technology Solutions
* Modification Log
===================================================================================================
* Ver.    Date          Author              	    Modification
---------------------------------------------------------------------------------------------------
* 1.0     10/05/2023	Nicholas Grasseschi @ CTS   Created class + added methods
*/

public with sharing class CPQOrdersCreatedFromSAPSalesOrderHandler {

    // Map of PricebookEntry whose values to insert -> the Key for this map will be the 'OI.SAP_Product_Number__c'-'Order.Pricebook2.Name'
    private static Map<String, PricebookEntry> newPBEMap;
    // map of Pricebook2
    private static Map<String, Pricebook2> pricebookMap;
    // Map of ProductCode to Product
    private static Map<String, Product2> newProdMap;


    /**
        AfterInsert method which will query for new Products using the successful ID set and send to helper method to
         check whether OrderItems configured with the "Generic" product that have a SAP_Product_Number__c which matches ProductCode
     */
    public static void handleNewProducts(Set<Id> newProductIdSet) {
        // List of new Products w/ ProductCode to find OrderItem for clone
        List<Product2> product4OrderItemClone = new List<Product2>();

        // query for "successfully" created products -> this way we don't do wonky stuff if there is an error when multiple are created
        List<Product2> newProductList = [SELECT Id, ProductCode FROM Product2 WHERE Id IN :newProductIdSet];
        
        // if ProductCode is not null or empty, check for OrderItem records that need update(clone)
        for (Product2 prod : newProductList) {
            // check ProductCode value
            if (prod.ProductCode != null && prod.ProductCode != '') {
                product4OrderItemClone.add(prod);
            }
        }

        // if we have Products for OrderItem check, send to helper method
        if (!product4OrderItemClone.isEmpty()) {
            updateOrderItemCreatedFromSAP(product4OrderItemClone);
        }
    }


    // helper method to clone then delete OrderItems that have SAP_Product_Number__c matching ProductCode but having "generic" product configured
    public static void updateOrderItemCreatedFromSAP(List<Product2> newProdList) {
        // Set of ProductCodes from Products passed to this method
        Set<String> newProdCodesSet = new Set<String>();
        // List of cloned OrderItems to insert
        List<OrderItem> cloneOI4InsertList = new List<OrderItem>();
        // Map of OrderItem Ids to delete after clones are inserted
        Map<String, OrderItem> originalOIMap = new Map<String, OrderItem>();
        // Set of successfully cloned OI.Ids
        Set<Id> successfulOIClone = new Set<Id>();
        
        // initialize newProdMap
        newProdMap = new Map<String, Product2>();

        // collect *new* ProductCodes and populate our Product Map
        for (Product2 prod : newProdList) {
            newProdCodesSet.add(prod.ProductCode);
            newProdMap.put(prod.ProductCode, prod);
        }

        // query OrderItem records with SAP_Product_Number__c in newProdCodesSet and Product.ProductCode not in newProdCodesSet
        List<OrderItem> orderItems = queryOrderItems(newProdCodesSet);

        // if OrderItems are returned, process Custom PricebookEntries
        if (!orderItems.IsEmpty()) {

            // initialize Map of OrderItem info to pass to PBE creation to check for OI.UnitPrice
            Map<String, Decimal> oiUnitPriceMap = new Map<String, Decimal>();

            // create the Map of <ProductCode-PBName, OI.UnitPrice>
            for (OrderItem oi : orderItems) {
                // Key for oiUnitPriceMap entry
                String oiUPKey = oi.SAP_Product_Number__c + '-' + oi.Order.Pricebook2.Name; // will look something like... '00001234-1436 Unites States'
                // add UnitPrice value to Map
                oiUnitPriceMap.put(oiUPKey, oi.UnitPrice); // ex: ({'00001234-1436 Unites States' => 3.15},...)
            }
            
            // collect Pricebook2 records for cust PricebookEntries
            initializePricebookMap();

            // create custom PricebookEntries for each Product
            createPricebookEntries(oiUnitPriceMap);


            // loop over OrderItems to create clones
            for (OrderItem oi : orderItems) {
                // build our OI Key to get PricebookEntryId later
                String oiKey = oi.SAP_Product_Number__c + '-' + oi.Order.Pricebook2.Name;
                // build our "original" OI Key for deletion later -> (ctrl+f 'zzz1')
                String delKey = oi.SAP_Product_Number__c+oi.OrderId+oi.Order.Pricebook2.Name;
                
                // set new OrderItem Product/PBE lookup Ids as string to check maps for existence
                Boolean cloneOIProduct2IdExists = newProdMap.get(oi.SAP_Product_Number__c) != null ? true : false; // don't expect Product Map to be empty...
                Boolean cloneOIPricebookEntryIdExists = newPBEMap.get(oiKey) != null ? true : false; // if null set to blank

                // if both ProductId and PricebookEntryId can be found for the given combo, clone the OrderItem record
                if (cloneOIProduct2IdExists && cloneOIPricebookEntryIdExists) {
                    // define clone OI
                    OrderItem cloneOI = oi.clone(false, true, false, false); // clone(PreserveId - false, IsDeepClone - true, PreserveReadFields(ex:CreatedDate) - false, PreserveAutoNumber(OI.Name) - false)

                    cloneOI.Product2Id = newProdMap.get(oi.SAP_Product_Number__c).Id;
                    cloneOI.PricebookEntryId = newPBEMap.get(oiKey).Id;
                    cloneOI.ListPrice = newPBEMap.get(oiKey).UnitPrice;

                    // add cloneOI to insert list
                    cloneOI4InsertList.add(cloneOI);

                    // add old OI to delete map
                    originalOIMap.put(delKey, oi);
                }
            }

            // insert new OI if available
            if (!cloneOI4InsertList.isEmpty()) {
                //attemp Orderitem inserts.  Loop DB results and grab successes.  Log failures.
                Database.SaveResult[] orderItemsToInsert = Database.insert(cloneOI4InsertList,false); // DB.Insert(RecordsToInsert, AllOrNone) -> AllOrNone = false allows partial insert
                for(Database.SaveResult sr : orderItemsToInsert) {
                    if(sr.isSuccess()) {
                        successfulOIClone.add(sr.getId());
                    }
                }
                ErrorLogUtil.handleSaveResults('CPQOrdersCreatedFromSAPSalesOrderHandler: Failed to Insert Clone OrderItem', orderItemsToInsert);
            }

            if (!successfulOIClone.isEmpty()) {
                deleteDuplicateOrderItems(successfulOIClone, originalOIMap);
            }
        }
    }


    /**
        create custom PricebookEntry for ALL cusotm Pricebooks

        This code is built on the assumption that the set of CurrencyCodes from Market_Country__c records is GREATER than the set of CurrencyCodes from Pricebook2
         Standard PricebookEntries are created from the CurrencyIsoCode present in Market_Country__c, whereas the below is based on Pricebook2 CurrencyIsoCode
         If a Standard Price was not created via the Market_Country__c the cusotm PBE will fail since there is not a CurrencyCode available in the STD book
         Ex: Thailand Market/MarketCountry have Thai Bhat (THB) as their configured currencies, but the Thai Pricebook2 is set in EUR because they do business in Euro
            -> if this was reversed the below code would fail
     */ 
    private static void createPricebookEntries(Map<String, Decimal> oiUnitPriceMap) {

        // initialize newPBEMap
        newPBEMap = new Map<String, PricebookEntry>();

        // Set for successful PB Entries
        Set<Id> successfulPBEIdSet = new Set<Id>();

        // create a new PricebookEntry for each ProductCode<>Pricebook2 combination
        // loop over Products for Product2Id
        for (Product2 prod : newProdMap.values()) {

            // loop over Pricebook2 for Pricebook2Id and CurrencyIsoCode
            for (Pricebook2 pb : pricebookMap.values()) {

                // key value to check if oiUnitPriceMap for usable UnitPrice value
                String pbeKey = prod.ProductCode + '-' + pb.Name;
                System.debug('zzz2: pbeKey--->'+pbeKey);

                // check for UnitPrice from oiUnitPriceMap
                Decimal oiUnitPriceValue = oiUnitPriceMap.get(pbeKey);

                // create new PricebookEntry out of Product<>PriceBook information
                // check for UnitPrice from OI, if none default zero '0'
                PricebookEntry pbe = new PricebookEntry(
                    Product2Id = prod.Id,
                    Pricebook2Id = pb.Id,
                    IsActive = true,
                    CurrencyIsoCode = pb.CurrencyIsoCode,
                    UnitPrice = oiUnitPriceValue != null ? oiUnitPriceValue : 0
                );

                // add new PBE to Map for insert later
                newPBEMap.put(pbeKey, pbe);
            }
        }
        System.debug('zzz@: custom PricebookEntry records to insert size()--->'+newPBEMap.values().size());        
            
        // insert new Custom PricebookEntry records
        if (!newPBEMap.values().isEmpty()) {
            //attemp product inserts.  Loop DB results and grab successes.  Log failures.
            Database.SaveResult[] pricebookEntriesToInsert = Database.insert(newPBEMap.values(),false); // DB.Insert(RecordsToInsert, AllOrNone) -> AllOrNone = false allows partial insert
            for(Database.SaveResult sr : pricebookEntriesToInsert) {
                if(sr.isSuccess()) {
                    System.debug('Successfully inserted custom PriceBookEntry');
                    successfulPBEIdSet.add(sr.getId());
                }
            }
            ErrorLogUtil.handleSaveResults('CPQOrdersCreatedFromSAPSalesOrderHandler: Failed to Insert PriceBookEntry', pricebookEntriesToInsert);
        }

        // collect successfully inerted records
        List<PricebookEntry> successfulPBEInserts = [SELECT Id, ProductCode, CurrencyIsoCode, UnitPrice, Pricebook2.Name
                                                       FROM PricebookEntry
                                                       WHERE Id IN :successfulPBEIdSet];
        
        // reset newPBEMap with only values that were inserted...
        newPBEMap.clear();
        System.debug('zzz@ newPBEMap.clear() size--->'+newPBEMap.size());

        // repopulate the PBE Map from successful values
        for (PricebookEntry pbe : successfulPBEInserts) {
            // construct our Key 
            String key = pbe.ProductCode + '-' + pbe.Pricebook2.Name;

            // add to map
            newPBEMap.put(key, pbe);
        }
    }


    /**
    Method to clean up original OI that were cloned
     */
    private static void deleteDuplicateOrderItems(Set<Id> oiIds, Map<String, OrderItem> originalOIMap) {
        // Set of OrderItem Ids collected from Map for deletion
        List<OrderItem> oiToDelete = new List<OrderItem>();

        // collect OI records from Successful Ids
        List<OrderItem> successfulInsertOIList = [SELECT SAP_Product_Number__c, OrderId, Order.Pricebook2.Name
                                                  FROM OrderItem
                                                  WHERE Id IN :oiIds];
        
        // loop over successfully clones OrderItems to construct the "delete" key to indentify duplicate OI.Ids to delete
        for (OrderItem oi : successfulInsertOIList) {
            // construct delete key as above (ctrl+f 'zzz1')
            String delKey = oi.SAP_Product_Number__c+oi.OrderId+oi.Order.Pricebook2.Name;

            // get Id from map of ALL old OI in case any failed to insert for whatever reason
            oiToDelete.add(originalOIMap.get(delKey));
        }

        // delete duplicate OrderItems
        if (!oiToDelete.isEmpty()) {
            delete oiToDelete;
        }
    }


    /**
    Initialize a Pricebook2 Map to create custom PBE later
     */
    private static void initializePricebookMap() {
        // Initialize the Map
		pricebookMap = new Map<String, Pricebook2>();

		// Retrieve the list of Markets
		List<Pricebook2> pbList = [SELECT Id, Name, IsActive, CurrencyIsoCode, SAP_Sales_Org_ID__c
                                       FROM Pricebook2
                                       WHERE SAP_Sales_Org_ID__c != null
                                       AND IsActive = true];

		// Interate thru the markets list and create the map entries
		for (Pricebook2 pb : pbList) {
			pricebookMap.put(pb.SAP_Sales_Org_ID__c, pb);
		}

        System.debug('zzz@: pricbookMap.values().size()--->'+pricebookMap.values().size());
        System.debug('zzz@: pricbookMap.values()--->'+pricebookMap.values());
    }


    /**
    Query for OrderItem records
    -> query separated from main process to make the process easier to read 
    */
    private static List<OrderItem> queryOrderItems(Set<String> newProdCodesSet) {
        // return OrderItems with matching SAP_Product_Number__c that are not configured with the correct Product2 (likely "Generic" product)
        return [SELECT SAP_Product_Number__c, SBQQ__Activated__c, SBQQ__Status__c, Vistex_Automatic_Add_on__c, Aggregate_Commitment_Type__c, SBQQ__Asset__c,
                        Auto_Ship_Day_of_Month__c, Auto_Ship__c, Auto_Ship_Frequency__c, AvailableQuantity, Bill_To_Address__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c,
                        SBQQ__BlockPrice__c, SBQQ__BookingsIndicator__c, SBQQ__BundleRoot__c, SBQQ__ChargeType__c, Commitment_UOM__c, SBQQ__Contract__c,
                        SBQQ__ContractAction__c, SBQQ__Contracted__c, SBQQ__ContractingMethod__c, CPQ_Commitment_Quantity__c, CPQ_Commitment_Value__c, CurrencyIsoCode, Deal_Discount__c,
                        SBQQ__DefaultSubscriptionTerm__c, Discount__c, SBQQ__DiscountSchedule__c, Distributor_Address__c, Drop_Ship__c, Drop_Ship_Requester_Distr__c, EndDate,
                        Estimated_Amount__c, Estimated_Quantity__c, SBQQ__TaxAmount__c, Exclude_from_SAP__c, Flexible_Group__c, FreeOfChargePercent__c,
                        FreeOfChargeQuantity__c, SBQQ__UnproratedNetPrice__c, Installments__c, Is_Aggregate_Commitment_Line__c, Is_Spread_Commitment_Line__c, IsPortalCreated__c, Lease__c,
                        Leasing_Agent_Address__c, Description, ListPrice, OrderId, SBQQ__OrderedQuantity__c, OriginalOrderItemId, Payer_Address__c, 
                        SBQQ__PriceDimension__c, SBQQ__PriceSchedule__c, SBQQ__PricingMethod__c, SBQQ__ProductSubscriptionType__c, Program_Charge_Type__c, SBQQ__ProrateMultiplier__c,
                        Quantity, SBQQ__QuoteLine__c, SBQQ__QuotedListPrice__c, SBQQ__QuotedQuantity__c, Rebate_Commitment__c, Requested_Delivery_Date__c,
                        SBQQ__RequiredBy__c, SBQQ__RevisedOrderProduct__c, SAP_Item_Category_Group__c, SAP_Unit_Of_Measure__c, SAP_Unit_Of_Measure_ISO__c, SAP_Usage_Type__c,
                        SAP_Item_Category__c, SBQQ__SegmentIndex__c, SBQQ__SegmentKey__c, SBQQ__DimensionType__c, Ship_to_Address__c, SBQQ__ShippingAccount__c,
                        Sold_to_Address__c, Specific_Commitment__c, ServiceDate, SBQQ__Subscription__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionType__c,
                        SystemModstamp, SBQQ__TaxCode__c, SBQQ__TermDiscountSchedule__c, SBQQ__TerminatedDate__c, Total_Commitment_Value__c, TotalPrice, UnitPrice,
                        SBQQ__UpgradedSubscription__c, Vistex_Condition_Item_Number__c, Vistex_Condition_Subtotal__c, Vistex_Gross_Unit_Price__c, Vistex_Gross_Value__c,
                        Vistex_Item_Contract_Price__c, Vistex_Item_Discounted_Total_Price__c, Vistex_Net_Price__c, Vistex_Net_Value__c, Vistex_Preference_Value__c, Vistex_Rebate_Basis__c,
                        Vistex_Sales_Document_Item_Category__c, Vistex_Subtotal_Condition_4__c, Vistex_Subtotal_Condition_5__c, Vistex_Subtotal_Condition_6__c, Vistex_Tax_Amount__c, 
                        Order.Pricebook2Id, Order.Pricebook2.Name, Order.Pricebook2.CurrencyIsoCode, Product2.ProductCode
                FROM OrderItem
                WHERE SAP_Product_Number__c IN :newProdCodesSet AND Product2.ProductCode NOT IN :newProdCodesSet ];
    }
}