/**
* File Name     :  CreateBundleFromVistexDealTest
* @description  :  Test coverage for the createBundleFromVistexDeal controller
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     1/31/2020		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/5/2020		Cory Bartholomew @ ATG     Added descriptions.

**/


@IsTest
public class CreateBundleFromVistexDealTest {
   @TestSetup
   static void makeData(){


    List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
    List<Market_Country__c> marketCountries = CPQ_TestDataFactory.createMarketCountrys(markets, true);

    
    List<Vistex_Deal_Header__c> deals = new List<Vistex_Deal_Header__c>();
    //Create Good Vistex Deal header
    deals.add(CPQ_TestDataFactory.createVistexDealHeader('4000006474', '1436', false));
    //Create an invalid deal
    deals.add(CPQ_TestDataFactory.createVistexDealHeader('4008675309', '1436', false));        
    insert deals;


    //Create SAP Materials
    List<SAP_Material__c> materials = new List<SAP_Material__c>();
    //Device Item Cat Grp = Z006       
    materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001280', 'Z006', 'ZFER', '015000715175010', false)); //0
    materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001290', 'Z006', 'ZFER', '015000715175010', false)); //1              
    //Consumables
    materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001282', 'NORM', 'ZFER', '015000715177010', false)); //2
    materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001291', 'NORM', 'ZFER', '015000715178010', false)); //3
    materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001293', 'NORM', 'ZFER', '015000715178010', false)); //4
    materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000011021425', 'NORM', 'ZFER', '021000312431010', false)); //5
    //Ancillary
    materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001285', 'ZANC', 'ZFER', '015000715175010', false)); //6
    //Agregate Service Line Item
    materials.add(CPQ_TestDataFactory.createSAPMaterial( 'AU', '000000000020001951', 'Z011', 'DIEN', '033000315186010', false)); //7
    //Program Charge
    materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000016001287', 'ZCRE', 'DIEN', '015000715170010', false)); //8
    //Warratny
    materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '000000000030002331', 'LEAS', 'UNBW', null, false)); //9
    //Service Item with Billing Plan
     materials.add(CPQ_TestDataFactory.createSAPMaterial( 'PCE', '00000000716001287', 'Z012', 'DIEN', '015000715170010', false)); //10
    insert materials;

    //Create Product2 records to be associated to Materials
    List<Product2> products = new List<Product2>();        
    for(SAP_Material__c material : materials){
        Product2 product = CPQ_TestDataFactory.createProduct(material, false);             
        product.name = material.SAP_Item_Category_Group__c + material.SAP_Material_Type__c;
        products.add(product);
    }
    insert products;
   
    //Create Deal Lines. 
    List<Vistex_Deal_Line_E1KOMG__c> dealLines = new List<Vistex_Deal_Line_E1KOMG__c>(); 
    dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deals[0], 'ZCON', materials[1].SAP_Product_Number__c, null, false));//3        
    dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deals[0], 'ZCON', materials[4].SAP_Product_Number__c, null, false));//4        
    dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deals[0], 'ZCON', materials[5].SAP_Product_Number__c,  null, false));//5
    dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deals[0], 'ZDEV', materials[10].SAP_Product_Number__c,  null, false));//5
   
    //Create Term Deal Line
    dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Term(deals[0],'72', false));//6
    //Create Eligibility Deal Line
    dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Elegibility(deals[0], 'TestBNDL', false));//7

    //create bad deal lines for invalid deal
    //A deal can only have 1 term line 
    //A deal must have a Consumable or Device to be processes
    dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Term(deals[1],'72', false));
    dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Term(deals[1],'72', false));
    insert dealLines;

    List<Condition_Header_E1KONH__c> conditions = new List<Condition_Header_E1KONH__c>();
    for(Vistex_Deal_Line_E1KOMG__c line : dealLines){
        conditions.add(CPQ_TestDataFactory.createVistexDealLineItemCondition(line, false));
    }
    insert conditions;

    List<Vistex_ZO2C_E1KONP_CPQ__c> conditionChildren = new List<Vistex_ZO2C_E1KONP_CPQ__c>();
    
    for(Condition_Header_E1KONH__c condition : conditions){
        conditionChildren.add(CPQ_TestDataFactory.createVistexDealLineItemConditionChildObject(condition, 0, null, 0, 'EA', '01', false));
    }
    insert conditionChildren;        
   }

   @isTest
   static void testBadDeal(){
       Vistex_Deal_Header__c deal = [SELECT Id,Is_Third_Party_Lease_Default__c FROM Vistex_Deal_Header__c WHERE DEALNUM__c = '4008675309' LIMIT 1];
       System.assertNotEquals(null, deal);      

       CreateBundleFromVistexDealController.CreateBundleResponse response = CreateBundleFromVistexDealController.processDeal(deal.Id);
    }

    @isTest
    static void testDealAlreadyExists(){
        Vistex_Deal_Header__c deal = [SELECT Id,Is_Third_Party_Lease_Default__c FROM Vistex_Deal_Header__c WHERE DEALNUM__c = '4000006474' LIMIT 1];       
        System.assertNotEquals(null, deal);

        
        CPQBundleUpdates__c setting = new CPQBundleUpdates__c();
        setting.isEnableBundleUpdate__c = true;
        insert setting;

        // Simulate a SAP Price Entry load from SAP
        Date today = Date.today();
        List<SAP_Price_Entry__c> sapPriceEntries = new List<SAP_Price_Entry__c> {
            CPQ_TestDataFactory.createSAPPriceEntry('000000000016001290', '1436', 10.1, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000016001293', '1436', 11.2, today.addDays(-10), today.addDays(10), 'USD', 'ST', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000011021425', '1436', 12.3, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('00000000716001287', '1436', 13.4, today.addDays(-10), today.addDays(10), 'USD', 'PK', false)
        };

        insert sapPriceEntries;

        Product2 product = CPQ_TestDataFactory.createProduct(false);
        product.Vistex_Deal_Header__c = deal.Id;
        insert product;

        deal.Exclude_From_Batch__c = false;
        update deal;

        CreateBundleFromVistexDealController.CreateBundleResponse response = CreateBundleFromVistexDealController.processDeal(deal.Id);
    }
   
}