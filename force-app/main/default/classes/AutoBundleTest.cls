/**
* File Name     :  AutoBundleTest
* @description  :  Test method for the auto bundle batch process
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     10/7/2019		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/6/2020		Cory Bartholomew @ ATG     Added descriptions.

**/

@isTest
private class AutoBundleTest {
    @TestSetup
    /*Create the data stack for vistex deal processing. 
        All data will be created for the US sales org 1436

    */
    static void setup(){

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

        // ADDING SAP PRICE ENTRY FOR NEW VALIDATION
        Date today = Date.today();
        List<SAP_Price_Entry__c> sapPriceEntries = new List<SAP_Price_Entry__c> {
            CPQ_TestDataFactory.createSAPPriceEntry('000000000016001290', '1436', 10.1, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000016001293', '1436', 11.2, today.addDays(-10), today.addDays(10), 'USD', 'ST', false),
            CPQ_TestDataFactory.createSAPPriceEntry('000000000011021425', '1436', 12.3, today.addDays(-10), today.addDays(10), 'USD', 'EA', false),
            CPQ_TestDataFactory.createSAPPriceEntry('00000000716001287', '1436', 13.4, today.addDays(-10), today.addDays(10), 'USD', 'PK', false)
        };

        insert sapPriceEntries;

        //Create Product2 records to be associated to Materials
        List<Product2> products = new List<Product2>();        
        for(SAP_Material__c material : materials){
            Product2 product = CPQ_TestDataFactory.createProduct(material, false);             
            product.name = material.SAP_Item_Category_Group__c + material.SAP_Material_Type__c;
            products.add(product);
        }
        insert products;

        //Insert Flexible Group
        Flexible_Group__c flxGroup = CPQ_TestDataFactory.createFlexibleGroup('000001', 'ZFLX', true);
        //Insert Flexible Group Items
        List<Flexible_Group_Item__c> flexGroupItems = new List<Flexible_Group_Item__c>();
        flexGroupItems.add(CPQ_TestDataFactory.createFlexibleGroupItem('000001', '101', materials[0].SAP_Product_Number__c, false)); //Device
        flexGroupItems.add(CPQ_TestDataFactory.createFlexibleGroupItem('000001', '102', materials[2].SAP_Product_Number__c, false)); //Consumable
        flexGroupItems.add(CPQ_TestDataFactory.createFlexibleGroupItem('000001', '103', materials[3].SAP_Product_Number__c, false)); //Consumable    
        insert flexGroupItems;
        //Create Deal Lines. 
        List<Vistex_Deal_Line_E1KOMG__c> dealLines = new List<Vistex_Deal_Line_E1KOMG__c>(); 
        //Add device and 2 consumables to flexible group
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_FlexibleGroup(deals[0], 'ZDEV', '000001', false));
        //no flexible group
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deals[0], 'ZCON', materials[1].SAP_Product_Number__c, 'S2', false));//3        
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deals[0], 'ZCON', materials[4].SAP_Product_Number__c, 'S2', false));//4        
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deals[0], 'ZCON', materials[5].SAP_Product_Number__c,  'S2', false));//5
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Material(deals[0], 'ZDEV', materials[10].SAP_Product_Number__c,  'S3', false));//5
       
        //Create Term Deal Line
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Term(deals[0],'72', false));//6
        //Create Eligibility Deal Line
        dealLines.add(CPQ_TestDataFactory.createVistexDealLine_Elegibility(deals[0], 'TestBNDL', false));//7

        //create bad deal lines for invalid deal
        //A deal can only have 1 term line 
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

    @isTest static void testAutobundleBatchableValid(){
        List<SAP_Material__c> materials = [SELECT Id FROM SAP_Material__c];
        System.assertEquals(11,materials.size());
        List<Product2> products = [SELECT Id FROM Product2];
        System.assertEquals(11,products.size());

        Vistex_Deal_Header__c goodDeal =  [
            SELECT Id, Deal_Validity_Issues__c, Exclude_From_Batch__c,DEALNUM__c, Is_Third_Party_Lease_Default__c, 
                ( 
                    SELECT Id, Vistex_Deal_Header__c, Name, ProductCode 
                    FROM BundleWrapperProducts__r 
                )   
            FROM Vistex_Deal_Header__c WHERE DEALNUM__c = '4000006474'
        ];
        
        //Code added by Sourav Mitra @ CTS to create banners while testing
        List<Vistex_Banner_E1EDKT1__c> bannerList = new List<Vistex_Banner_E1EDKT1__c>();
        
        //Creating first banner with 'ZPRM' TDID
        Vistex_Banner_E1EDKT1__c banner = new Vistex_Banner_E1EDKT1__c();
        banner.DEALK01_Ext_Id__c = goodDeal.Id;
        banner.E1EDKT1_Ext_Id__c = '(E1EDKT1)4000006474~ZPRM';
        banner.TDID__c = 'ZPRM';
        banner.TSSPRAS__c = 'EN';
        bannerList.add(banner);
        
        //Creating second banner with 'ZCPQ' TDID
        Vistex_Banner_E1EDKT1__c banner2 = new Vistex_Banner_E1EDKT1__c();
        banner2.DEALK01_Ext_Id__c = goodDeal.Id;
        banner2.E1EDKT1_Ext_Id__c = '(E1EDKT1)4000006474~ZCPQ';
        banner2.TDID__c = 'ZCPQ';
        banner2.TSSPRAS__c = 'EN';
        bannerList.add(banner2);
        
        //Creating third banner with 'ZTER' TDID
        Vistex_Banner_E1EDKT1__c banner3 = new Vistex_Banner_E1EDKT1__c();
        banner3.DEALK01_Ext_Id__c = goodDeal.Id;
        banner3.E1EDKT1_Ext_Id__c = '(E1EDKT1)4000006474~ZTER';
        banner3.TDID__c = 'ZTER';
        banner3.TSSPRAS__c = 'EN';
        bannerList.add(banner3);
        
        //Creating fourth banner with 'ZPRQ' TDID
        Vistex_Banner_E1EDKT1__c banner4 = new Vistex_Banner_E1EDKT1__c();
        banner4.DEALK01_Ext_Id__c = goodDeal.Id;
        banner4.E1EDKT1_Ext_Id__c = '(E1EDKT1)4000006474~ZPRQ';
        banner4.TDID__c = 'ZPRQ';
        banner4.TSSPRAS__c = 'EN';
        bannerList.add(banner4);
        
        insert bannerList;
        
        //Creating Child Banners and assigning to both the parent banners
        List<Vistex_Child_Banner_E1EDKT2__c> childBannerList = new List<Vistex_Child_Banner_E1EDKT2__c>();
        
        for(Vistex_Banner_E1EDKT1__c bannerParent : [Select Id,Name,TDID__c from Vistex_Banner_E1EDKT1__c]){
            Vistex_Child_Banner_E1EDKT2__c bannerChild = new Vistex_Child_Banner_E1EDKT2__c();
            if(bannerParent.TDID__c == 'ZPRM'){
                bannerChild.E1EDKT1_Ext_Id__c = bannerParent.Id;
                bannerChild.E1EDKT2_Ext_Id__c = '(E1EDKT2)4000006474~ZPRM~1';
                bannerChild.TDLINE__c = 'Test Data 1';
                bannerChild.TDFORMAT__c = '*';
                childBannerList.add(bannerChild);
            }else if(bannerParent.TDID__c == 'ZCPQ'){
                bannerChild.E1EDKT1_Ext_Id__c = bannerParent.Id;
                bannerChild.E1EDKT2_Ext_Id__c = '(E1EDKT2)4000006474~ZCPQ~2';
                bannerChild.TDLINE__c = 'Test Data 2';
                bannerChild.TDFORMAT__c = '*';
                childBannerList.add(bannerChild);
            }else if(bannerParent.TDID__c == 'ZTER'){
                bannerChild.E1EDKT1_Ext_Id__c = bannerParent.Id;
                bannerChild.E1EDKT2_Ext_Id__c = '(E1EDKT2)4000006474~ZTER~3';
                bannerChild.TDLINE__c = 'Test Data 3';
                bannerChild.TDFORMAT__c = '*';
                childBannerList.add(bannerChild);
            }else if(bannerParent.TDID__c == 'ZPRQ'){
                bannerChild.E1EDKT1_Ext_Id__c = bannerParent.Id;
                bannerChild.E1EDKT2_Ext_Id__c = '(E1EDKT2)4000006474~ZPRQ~4';
                bannerChild.TDLINE__c = 'Test Data 4';
                bannerChild.TDFORMAT__c = '*';
                childBannerList.add(bannerChild);
            }
        }
        
        insert childBannerList;
            
        Test.StartTest();
        AutoBundleBatchable  abb = new AutoBundleBatchable(goodDeal.Id);
        Database.executeBatch(abb,1);
        Test.StopTest();
        Vistex_Deal_Header__c goodDealAfter =  [
            SELECT Id, Deal_Validity_Issues__c, Exclude_From_Batch__c,DEALNUM__c,Is_Third_Party_Lease_Default__c, 
                ( 
                    SELECT Id, Vistex_Deal_Header__c, Name, ProductCode 
                    FROM BundleWrapperProducts__r 
                )   
            FROM Vistex_Deal_Header__c WHERE DEALNUM__c = '4000006474'
        ];
        System.assertEquals(null, goodDealAfter.Deal_Validity_Issues__c);
        System.assertEquals(false, goodDealAfter.Exclude_From_Batch__c);
        //System.assertEquals(1, goodDealAfter.BundleWrapperProducts__r.size());

      
    }

    @isTest static void testAutobundleBatchableInvalid(){
        List<SAP_Material__c> materials = [SELECT Id FROM SAP_Material__c];
        System.assertEquals(11,materials.size());
        List<Product2> products = [SELECT Id FROM Product2];
        System.assertEquals(11,products.size());


        Vistex_Deal_Header__c invalidDeal =  [
                SELECT Id, Deal_Validity_Issues__c, Exclude_From_Batch__c,DEALNUM__c, Is_Third_Party_Lease_Default__c,
                    ( 
                        SELECT Id, Vistex_Deal_Header__c, Name, ProductCode 
                        FROM BundleWrapperProducts__r 
                    )   
                FROM Vistex_Deal_Header__c WHERE DEALNUM__c = '4008675309'
        ];       
        Test.StartTest();
        AutoBundleBatchable  abb = new AutoBundleBatchable(invalidDeal.Id);
        Database.executeBatch(abb,1);
        Test.StopTest();


        Vistex_Deal_Header__c invalidDealAfter =  [
                SELECT Id, Deal_Validity_Issues__c, Exclude_From_Batch__c,DEALNUM__c,Is_Third_Party_Lease_Default__c,
                    ( 
                        SELECT Id, Vistex_Deal_Header__c, Name, ProductCode 
                        FROM BundleWrapperProducts__r 
                    )   
                FROM Vistex_Deal_Header__c WHERE DEALNUM__c = '4008675309'
        ];  

        System.assertNotEquals(null, invalidDealAfter.Deal_Validity_Issues__c);
        System.assertEquals(true, invalidDealAfter.Exclude_From_Batch__c);
        System.assertEquals(0, invalidDealAfter.BundleWrapperProducts__r.size());
    }    

}