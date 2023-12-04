/**
* File Name     :  VistexPricingResponse
* @description  :  Test coverage for the data definition for the vistex pricing response that is parsed and sets the price for CPQ quote lines
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/28/2019     Cesar Sandrigo @ ATG     Created the Class.
* 2.0     2/6/2020      Cory Bartholomew @ ATG   Added descriptions.

**/

@IsTest
public class VistexPricingResponseTest {
    
    // This test method should give 100% coverage
    @IsTest
    public static void testParse() {
        
        String json = '{'+
        '    \"ES_RESULT\": {'+
        '        \"SD_DOC_NO\": \"\",'+
        '        \"CUST_NO\": 1000120838,'+
        '        \"PRICING_PROC\": \"YSTD09\",'+
        '        \"DOC_CURRENCY\": \"AUD\",'+
        '        \"NET_VALUE\": \"765.10\",'+
        '        \"NET_PRICE\": \"765.10\",'+
        '        \"SUB_TOT1\": 0,'+
        '        \"SUB_TOT2\": 0,'+
        '        \"SUB_TOT3\": 0,'+
        '        \"ORD_DISCOUNT_TOT\": \"765.10\",'+
        '        \"ORD_TAXES\": 76.51,'+
        '        \"ORD_TOT_PRICE\": 841.61,'+
        '        \"ITEM\": {'+
        '            \"ITEM\": ['+
        '                {'+
        '                    \"COND_ITEM_NO\": \"000001\",'+
        '                    \"MATERIAL\": \"000000000010016589\",'+
        '                    \"SALES_UNIT\": \"BLS\",'+
        '                    \"PRICE_OK\": \"X\",'+
        '                    \"SD_ITEM_CATG\": \"\",'+
        '                    \"PLANT\": \"\",'+
        '                    \"COND_PRICE_UNIT\": 1,'+
        '                    \"COND_UNIT\": \"KAR\",'+
        '                    \"WEIGHT_UNIT\": \"KG\",'+
        '                    \"VOLUME_UNIT\": \"M3\",'+
        '                    \"QUANTITY\": \"10.000\",'+
        '                    \"NET_PRICE\": 70.18,'+
        '                    \"NET_VALUE_DOC_CUR\": \"701.80\",'+
        '                    \"GROSS_VALUE_IN_DOC_CUR\": 771.98,'+
        '                    \"TAX_AMT_IN_DOC_CUR\": 70.18,'+
        '                    \"COND_SUBTOT\": \"701.80\",'+
        '                    \"ITEM_CONTRACT_PRICE\": \"701.80\",'+
        '                    \"ITEM_DISC_TOT_PRICE\": \"701.80\",'+
        '                    \"COND_SUBTOT4\": \"701.80\",'+
        '                    \"COND_SUBTOT5\": \"701.80\",'+
        '                    \"COND_SUBTOT6\": 771.98,'+
        '                    \"RABATE_BASIS\": 70.18,'+
        '                    \"PREFERENCE_VALUE\": 0,'+
        '                    \"ITEM_CREDIT_PRICE\": 77.198,'+
        '                    \"COST_DOC_CURRENCY\": 0,'+
        '                    \"ITEM_GROSS_WEIGHT\": \".047\",'+
        '                    \"ITEM_NET_WEIGHT\": \".018\",'+
        '                    \"ITEM_VOLUME\": 0,'+
        '                    \"ADDON\": \"\"' +
        '                },'+
        '                {'+
        '                    \"COND_ITEM_NO\": \"000002\",'+
        '                    \"MATERIAL\": \"000000000010001130\",'+
        '                    \"SALES_UNIT\": \"VL\",'+
        '                    \"PRICE_OK\": \"X\",'+
        '                    \"SD_ITEM_CATG\": \"\",'+
        '                    \"PLANT\": \"\",'+
        '                    \"COND_PRICE_UNIT\": 1,'+
        '                    \"COND_UNIT\": \"VL\",'+
        '                    \"WEIGHT_UNIT\": \"KG\",'+
        '                    \"VOLUME_UNIT\": \"\",'+
        '                    \"QUANTITY\": \"1.000\",'+
        '                    \"NET_PRICE\": \"63.30\",'+
        '                    \"NET_VALUE_DOC_CUR\": \"63.30\",'+
        '                    \"GROSS_VALUE_IN_DOC_CUR\": 69.63,'+
        '                    \"TAX_AMT_IN_DOC_CUR\": 6.33,'+
        '                    \"COND_SUBTOT\": \"63.30\",'+
        '                    \"ITEM_CONTRACT_PRICE\": \"63.30\",'+
        '                    \"ITEM_DISC_TOT_PRICE\": \"63.30\",'+
        '                    \"COND_SUBTOT4\": \"63.30\",'+
        '                    \"COND_SUBTOT5\": \"63.30\",'+
        '                    \"COND_SUBTOT6\": 69.63,'+
        '                    \"RABATE_BASIS\": \"63.30\",'+
        '                    \"PREFERENCE_VALUE\": 0,'+
        '                    \"ITEM_CREDIT_PRICE\": 69.63,'+
        '                    \"COST_DOC_CURRENCY\": 0,'+
        '                    \"ITEM_GROSS_WEIGHT\": \".110\",'+
        '                    \"ITEM_NET_WEIGHT\": \".110\",'+
        '                    \"ITEM_VOLUME\": 0,'+
        '                    \"ADDON\": \"\"'+
        '                },'+
        '                {'+
        '                    \"COND_ITEM_NO\": \"000012\",'+
        '                    \"MATERIAL\": \"000000000010003255\",'+
        '                    \"SALES_UNIT\": \"TUB\",'+
        '                    \"PRICE_OK\": \"\",'+
        '                    \"SD_ITEM_CATG\": \"\",'+
        '                    \"PLANT\": \"AU06\",'+
        '                    \"COND_PRICE_UNIT\": 0,'+
        '                    \"COND_UNIT\": \"\",'+
        '                    \"WEIGHT_UNIT\": \"KG\",'+
        '                    \"VOLUME_UNIT\": \"\",'+
        '                    \"QUANTITY\": \"1.000\",'+
        '                    \"NET_PRICE\": 0,'+ 
        '                    \"NET_VALUE_DOC_CUR\": 0,'+
        '                    \"GROSS_VALUE_IN_DOC_CUR\": 0,'+
        '                    \"TAX_AMT_IN_DOC_CUR\": 0,'+
        '                    \"COND_SUBTOT\": 0,'+
        '                    \"ITEM_CONTRACT_PRICE\": 0,'+
        '                    \"ITEM_DISC_TOT_PRICE\": 0,'+
        '                    \"COND_SUBTOT4\": 0,'+
        '                    \"COND_SUBTOT5\": 0,'+
        '                    \"COND_SUBTOT6\": 0,'+
        '                    \"RABATE_BASIS\": 0,'+
        '                    \"PREFERENCE_VALUE\": 0,'+
        '                    \"ITEM_CREDIT_PRICE\": 0,'+
        '                    \"COST_DOC_CURRENCY\": 0,'+
        '                    \"ITEM_GROSS_WEIGHT\": 0,'+
        '                    \"ITEM_NET_WEIGHT\": 0,'+
        '                    \"ITEM_VOLUME\": 0,'+
        '                    \"ADDON\": \"X\"'+
        '                },'+
        '                {'+
        '                    \"COND_ITEM_NO\": \"000022\",'+
        '                    \"MATERIAL\": \"000000000010001130\",'+
        '                    \"SALES_UNIT\": \"VL\",'+
        '                    \"PRICE_OK\": \"\",'+
        '                    \"SD_ITEM_CATG\": \"\",'+
        '                    \"PLANT\": \"AU06\",'+
        '                    \"COND_PRICE_UNIT\": 0,'+
        '                    \"COND_UNIT\": \"\",'+
        '                    \"WEIGHT_UNIT\": \"KG\",'+
        '                    \"VOLUME_UNIT\": \"\",'+
        '                    \"QUANTITY\": \"1.000\",'+
        '                    \"NET_PRICE\": 0,'+
        '                    \"NET_VALUE_DOC_CUR\": 0,'+
        '                    \"GROSS_VALUE_IN_DOC_CUR\": 0,'+
        '                    \"TAX_AMT_IN_DOC_CUR\": 0,'+
        '                    \"COND_SUBTOT\": 0,'+
        '                    \"ITEM_CONTRACT_PRICE\": 0,'+
        '                    \"ITEM_DISC_TOT_PRICE\": 0,'+
        '                    \"COND_SUBTOT4\": 0,'+
        '                    \"COND_SUBTOT5\": 0,'+
        '                    \"COND_SUBTOT6\": 0,'+
        '                    \"RABATE_BASIS\": 0,'+
        '                    \"PREFERENCE_VALUE\": 0,'+
        '                    \"ITEM_CREDIT_PRICE\": 0,'+
        '                    \"COST_DOC_CURRENCY\": 0,'+
        '                    \"ITEM_GROSS_WEIGHT\": \".110\",'+
        '                    \"ITEM_NET_WEIGHT\": \".110\",'+
        '                    \"ITEM_VOLUME\": 0,'+
        '                    \"ADDON\": \"X\"'+
        '                }'+
        '            ]'+
        '        }'+
        '    },'+
        '    \"ET_ADDONS\": {'+
        '        \"ITEM\": ['+
        '            {'+
        '                \"DEAL\": 4000002988,'+
        '                \"DEAL_SUFFIX\": \"\",'+
        '                \"ITEMNO_SD_DOC\": \"000012\",'+
        '                \"ADDON_STATUS\": \"A\",'+
        '                \"GROUP\": \"\",'+
        '                \"MATERIAL\": \"000000000010003255\",'+
        '                \"MATERIAL_DESC\": \"RSPSRE DRAW OFF TUBESX1\",'+
        '                \"CUM_ORD_QUANTITY\": 0,'+
        '                \"ADDON_QUAN_SALES_UNIT\": \"1.000\",'+
        '                \"SALES_UNIT\": \"TUB\",'+
        '                \"MAX_ORD_QUANTITY\": 0,'+
        '                \"ADDON_ADD_PROP\": \"X\",'+
        '                \"ADDON_AUTO_APPLY\": \"X\",'+
        '                \"GROUP_REF\": \"\",'+
        '                \"ADDON_GROUP\": \"\",'+
        '                \"COND_REC_NO\": \"0020267071\",'+
        '                \"CROSS_ORD_RESTRICTION\": \"\",'+
        '                \"WORKGRP_TYPE\": \"\",'+
        '                \"CHECKBOX\": \"\",'+
        '                \"FLEXIBLE_GROUP\": \"\",'+
        '                \"REVENUE_RECOG\": \"\",'+
        '                \"NET_PRICE\": 0,'+
        '                \"SD_DOC_CURRENCY\": \"\"'+
        '            },'+
        '            {'+
        '                \"DEAL\": 4000006028,'+
        '                \"DEAL_SUFFIX\": \"\",'+
        '                \"ITEMNO_SD_DOC\": \"000022\",'+
        '                \"ADDON_STATUS\": \"A\",'+
        '                \"GROUP\": \"\",'+
        '                \"MATERIAL\": \"000000000010001130\",'+
        '                \"MATERIAL_DESC\": \"CLAVULOX SOL 5.6GM/MLX40ML VLX1 AUS\",'+
        '                \"CUM_ORD_QUANTITY\": 0,'+
        '                \"ADDON_QUAN_SALES_UNIT\": \"1.000\",'+
        '                \"SALES_UNIT\": \"KAR\",'+
        '                \"MAX_ORD_QUANTITY\": 0,'+
        '                \"ADDON_ADD_PROP\": \"X\",'+
        '                \"ADDON_AUTO_APPLY\": \"X\",'+
        '                \"GROUP_REF\": \"\",'+
        '                \"ADDON_GROUP\": \"\",'+
        '                \"COND_REC_NO\": \"0025958886\",'+
        '                \"CROSS_ORD_RESTRICTION\": \"\",'+
        '                \"WORKGRP_TYPE\": \"\",'+
        '                \"CHECKBOX\": \"\",'+
        '                \"FLEXIBLE_GROUP\": \"\",'+
        '                \"REVENUE_RECOG\": \"\",'+
        '                \"NET_PRICE\": 0,'+
        '                \"SD_DOC_CURRENCY\": \"\"'+
        '            }'+
        '        ]'+
        '    },'+
        '    \"ET_DEAL_LOG\": \"\",'+
        '    \"ET_HEADER_BENEFITS\": \"\",'+
        '    \"ET_ITEM_DEALS\": {'+
        '        \"ITEM\": ['+
        '            {'+
        '                \"COND_REC_NO\": \"0025958920\",'+
        '                \"ITEM\": \"000001\",'+
        '                \"DEAL\": 4000006029,'+
        '                \"DEAL_SUFFIX\": \"\",'+
        '                \"COND_TYPE\": \"ZB08\",'+
        '                \"COND_VAL\": \"701.80\",'+
        '                \"COND_VAL_OLD\": 0,'+
        '                \"PRIORITY\": \"000\",'+
        '                \"COMPATABLITY_MODE\": \"\",'+
        '                \"COND_INACTIVE\": \"\",'+
        '                \"RATE\": 0,'+
        '                \"COND_VAL_NET\": 0,'+
        '                \"MATERIAL\": \"\",'+
        '                \"CUM_ORD_QUAN\": 0,'+
        '                \"CUM_ORD_QUAN_EL\": 0,'+
        '                \"CUM_ORD_QUAN_EX\": 0,'+
        '                \"BASE_UOM\": \"\",'+
        '                \"CURRENCY_KEY\": \"AUD\",'+
        '                \"ON_DEMAND\": \"\",'+
        '                \"ADDON\": \"\",'+
        '                \"DEAL_RESOLUTION\": 4'+
        '            },'+
        '            {'+
        '                \"COND_REC_NO\": \"0025958920\",'+
        '                \"ITEM\": \"000002\",'+
        '                \"DEAL\": 4000006029,'+
        '                \"DEAL_SUFFIX\": \"\",'+
        '                \"COND_TYPE\": \"ZB08\",'+
        '                \"COND_VAL\": \"63.30\",'+
        '                \"COND_VAL_OLD\": 0,'+
        '                \"PRIORITY\": \"000\",'+
        '                \"COMPATABLITY_MODE\": \"\",'+
        '                \"COND_INACTIVE\": \"\",'+
        '                \"RATE\": 0,'+
        '                \"COND_VAL_NET\": 0,'+
        '                \"MATERIAL\": \"\",'+
        '                \"CUM_ORD_QUAN\": 0,'+
        '                \"CUM_ORD_QUAN_EL\": 0,'+
        '                \"CUM_ORD_QUAN_EX\": 0,'+
        '                \"BASE_UOM\": \"\",'+
        '                \"CURRENCY_KEY\": \"AUD\",'+
        '                \"ON_DEMAND\": \"\",'+
        '                \"ADDON\": \"\",'+
        '                \"DEAL_RESOLUTION\": 4'+
        '            }'+
        '        ]'+
        '    }'+
        '}';
        VistexPricingResponse r = VistexPricingResponse.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VistexPricingResponse.ET_ITEM_DEALS objET_ITEM_DEALS = new VistexPricingResponse.ET_ITEM_DEALS(System.JSON.createParser(json));
        System.assert(objET_ITEM_DEALS != null);
        System.assert(objET_ITEM_DEALS.ITEM == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VistexPricingResponse objVistexPricingResponse = new VistexPricingResponse(System.JSON.createParser(json));
        System.assert(objVistexPricingResponse != null);
        System.assert(objVistexPricingResponse.ES_RESULT == null);
        System.assert(objVistexPricingResponse.ET_ADDONS == null);
        System.assert(objVistexPricingResponse.ET_DEAL_LOG == null);
        System.assert(objVistexPricingResponse.ET_HEADER_BENEFITS == null);
        System.assert(objVistexPricingResponse.ET_ITEM_DEALS == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VistexPricingResponse.DealItem objDealItem = new VistexPricingResponse.DealItem(System.JSON.createParser(json));
        System.assert(objDealItem != null);
        System.assert(objDealItem.COND_REC_NO == null);
        System.assert(objDealItem.ITEM == null);
        System.assert(objDealItem.DEAL == null);
        System.assert(objDealItem.DEAL_SUFFIX == null);
        System.assert(objDealItem.COND_TYPE == null);
        System.assert(objDealItem.COND_VAL == null);
        System.assert(objDealItem.COND_VAL_OLD == null);
        System.assert(objDealItem.PRIORITY == null);
        System.assert(objDealItem.COMPATABLITY_MODE == null);
        System.assert(objDealItem.COND_INACTIVE == null);
        System.assert(objDealItem.RATE == null);
        System.assert(objDealItem.COND_VAL_NET == null);
        System.assert(objDealItem.MATERIAL == null);
        System.assert(objDealItem.CUM_ORD_QUAN == null);
        System.assert(objDealItem.CUM_ORD_QUAN_EL == null);
        System.assert(objDealItem.CUM_ORD_QUAN_EX == null);
        System.assert(objDealItem.BASE_UOM == null);
        System.assert(objDealItem.CURRENCY_KEY == null);
        System.assert(objDealItem.ON_DEMAND == null);
        System.assert(objDealItem.ADDON == null);
        System.assert(objDealItem.DEAL_RESOLUTION == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VistexPricingResponse.Result objES_RESULT = new VistexPricingResponse.Result(System.JSON.createParser(json));
        System.assert(objES_RESULT != null);
        System.assert(objES_RESULT.SD_DOC_NO == null);
        System.assert(objES_RESULT.CUST_NO == null);
        System.assert(objES_RESULT.PRICING_PROC == null);
        System.assert(objES_RESULT.DOC_CURRENCY == null);
        System.assert(objES_RESULT.NET_VALUE == null);
        System.assert(objES_RESULT.NET_PRICE == null);
        System.assert(objES_RESULT.SUB_TOT1 == null);
        System.assert(objES_RESULT.SUB_TOT2 == null);
        System.assert(objES_RESULT.SUB_TOT3 == null);
        System.assert(objES_RESULT.ORD_DISCOUNT_TOT == null);
        System.assert(objES_RESULT.ORD_TAXES == null);
        System.assert(objES_RESULT.ORD_TOT_PRICE == null);
        System.assert(objES_RESULT.ITEM == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VistexPricingResponse.ResultItem objResultItem = new VistexPricingResponse.ResultItem(System.JSON.createParser(json));
        System.assert(objResultItem != null);
        System.assert(objResultItem.COND_ITEM_NO == null);
        System.assert(objResultItem.MATERIAL == null);
        System.assert(objResultItem.SALES_UNIT == null);
        System.assert(objResultItem.PRICE_OK == null);
        System.assert(objResultItem.SD_ITEM_CATG == null);
        System.assert(objResultItem.PLANT == null);
        System.assert(objResultItem.COND_PRICE_UNIT == null);
        System.assert(objResultItem.COND_UNIT == null);
        System.assert(objResultItem.WEIGHT_UNIT == null);
        System.assert(objResultItem.VOLUME_UNIT == null);
        System.assert(objResultItem.QUANTITY == null);
        System.assert(objResultItem.NET_PRICE == null);
        System.assert(objResultItem.NET_VALUE_DOC_CUR == null);
        System.assert(objResultItem.GROSS_VALUE_IN_DOC_CUR == null);
        System.assert(objResultItem.TAX_AMT_IN_DOC_CUR == null);
        System.assert(objResultItem.COND_SUBTOT == null);
        System.assert(objResultItem.ITEM_CONTRACT_PRICE == null);
        System.assert(objResultItem.ITEM_DISC_TOT_PRICE == null);
        System.assert(objResultItem.COND_SUBTOT4 == null);
        System.assert(objResultItem.COND_SUBTOT5 == null);
        System.assert(objResultItem.COND_SUBTOT6 == null);
        System.assert(objResultItem.RABATE_BASIS == null);
        System.assert(objResultItem.PREFERENCE_VALUE == null);
        System.assert(objResultItem.ITEM_CREDIT_PRICE == null);
        System.assert(objResultItem.COST_DOC_CURRENCY == null);
        System.assert(objResultItem.ITEM_GROSS_WEIGHT == null);
        System.assert(objResultItem.ITEM_NET_WEIGHT == null);
        System.assert(objResultItem.ITEM_VOLUME == null);
        System.assert(objResultItem.ADDON == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VistexPricingResponse.AddonItem objAddonItem = new VistexPricingResponse.AddonItem(System.JSON.createParser(json));
        System.assert(objAddonItem != null);
        System.assert(objAddonItem.DEAL == null);
        System.assert(objAddonItem.DEAL_SUFFIX == null);
        System.assert(objAddonItem.ITEMNO_SD_DOC == null);
        System.assert(objAddonItem.ADDON_STATUS == null);
        System.assert(objAddonItem.GROUP_Z == null);
        System.assert(objAddonItem.MATERIAL == null);
        System.assert(objAddonItem.MATERIAL_DESC == null);
        System.assert(objAddonItem.CUM_ORD_QUANTITY == null);
        System.assert(objAddonItem.ADDON_QUAN_SALES_UNIT == null);
        System.assert(objAddonItem.SALES_UNIT == null);
        System.assert(objAddonItem.MAX_ORD_QUANTITY == null);
        System.assert(objAddonItem.ADDON_ADD_PROP == null);
        System.assert(objAddonItem.ADDON_AUTO_APPLY == null);
        System.assert(objAddonItem.GROUP_REF == null);
        System.assert(objAddonItem.ADDON_GROUP == null);
        System.assert(objAddonItem.COND_REC_NO == null);
        System.assert(objAddonItem.CROSS_ORD_RESTRICTION == null);
        System.assert(objAddonItem.WORKGRP_TYPE == null);
        System.assert(objAddonItem.CHECKBOX == null);
        System.assert(objAddonItem.FLEXIBLE_GROUP == null);
        System.assert(objAddonItem.REVENUE_RECOG == null);
        System.assert(objAddonItem.NET_PRICE == null);
        System.assert(objAddonItem.SD_DOC_CURRENCY == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VistexPricingResponse.ET_ADDONS objET_ADDONS = new VistexPricingResponse.ET_ADDONS(System.JSON.createParser(json));
        System.assert(objET_ADDONS != null);
        System.assert(objET_ADDONS.ITEM == null);
    }

    @IsTest
    public static void testParse2() {
        String json = '{'+
        '   \"ES_RESULT\":{'+
        '      \"SD_DOC_NO\":\"\",'+
        '      \"CUST_NO\":1000009536,'+
        '      \"PRICING_PROC\":\"YSTC01\",'+
        '      \"DOC_CURRENCY\":\"USD\",'+
        '      \"NET_VALUE\":\"2609.60\",'+
        '      \"NET_PRICE\":-237.15,'+
        '      \"SUB_TOT1\":0,'+
        '      \"SUB_TOT2\":0,'+
        '      \"SUB_TOT3\":0,'+
        '      \"ORD_DISCOUNT_TOT\":\"2609.60\",'+
        '      \"ORD_TAXES\":241.39,'+
        '      \"ORD_TOT_PRICE\":2850.99,'+
        '      \"ITEM\":{'+
        '         \"ITEM\":['+
        '            {'+
        '               \"COND_ITEM_NO\":\"000003\",'+
        '               \"MATERIAL\":\"000000000010001498\",'+
        '               \"SALES_UNIT\":\"VL\",'+
        '               \"PRICE_OK\":\"X\",'+
        '               \"SD_ITEM_CATG\":\"\",'+
        '               \"PLANT\":\"\",'+
        '               \"COND_PRICE_UNIT\":1,'+
        '               \"COND_UNIT\":\"VL\",'+
        '               \"WEIGHT_UNIT\":\"KG\",'+
        '               \"VOLUME_UNIT\":\"M3\",'+
        '               \"QUANTITY\":\"10.000\",'+
        '               \"NET_PRICE\":230.96,'+
        '               \"NET_VALUE_DOC_CUR\":\"2309.60\",'+
        '               \"GROSS_VALUE_IN_DOC_CUR\":2523.24,'+
        '               \"TAX_AMT_IN_DOC_CUR\":213.64,'+
        '               \"COND_SUBTOT\":\"2887.00\",'+
        '               \"ITEM_CONTRACT_PRICE\":\"2887.00\",'+
        '               \"ITEM_DISC_TOT_PRICE\":\"2887.00\",'+
        '               \"COND_SUBTOT4\":\"2309.60\",'+
        '               \"COND_SUBTOT5\":\"2309.60\",'+
        '               \"COND_SUBTOT6\":2523.24,'+
        '               \"RABATE_BASIS\":\"288.70\",'+
        '               \"PREFERENCE_VALUE\":0,'+
        '               \"ITEM_CREDIT_PRICE\":252.324,'+
        '               \"COST_DOC_CURRENCY\":0,'+
        '               \"ITEM_GROSS_WEIGHT\":\".043\",'+
        '               \"ITEM_NET_WEIGHT\":\".043\",'+
        '               \"ITEM_VOLUME\":0,'+
        '               \"ADDON\":\"\"'+
        '            },'+
        '            {'+
        '               \"COND_ITEM_NO\":\"000004\",'+
        '               \"MATERIAL\":\"000000000010004677\",'+
        '               \"SALES_UNIT\":\"VL\",'+
        '               \"PRICE_OK\":\"X\",'+
        '               \"SD_ITEM_CATG\":\"\",'+
        '               \"PLANT\":\"\",'+
        '               \"COND_PRICE_UNIT\":1,'+
        '               \"COND_UNIT\":\"VL\",'+
        '               \"WEIGHT_UNIT\":\"KG\",'+
        '               \"VOLUME_UNIT\":\"\",'+
        '               \"QUANTITY\":\"1.000\",'+
        '               \"NET_PRICE\":\"300.00\",'+
        '               \"NET_VALUE_DOC_CUR\":\"300.00\",'+
        '               \"GROSS_VALUE_IN_DOC_CUR\":327.75,'+
        '               \"TAX_AMT_IN_DOC_CUR\":27.75,'+
        '               \"COND_SUBTOT\":402.49,'+
        '               \"ITEM_CONTRACT_PRICE\":\"300.00\",'+
        '               \"ITEM_DISC_TOT_PRICE\":\"300.00\",'+
        '               \"COND_SUBTOT4\":\"300.00\",'+
        '               \"COND_SUBTOT5\":\"300.00\",'+
        '               \"COND_SUBTOT6\":327.75,'+
        '               \"RABATE_BASIS\":\"300.00\",'+
        '               \"PREFERENCE_VALUE\":0,'+
        '               \"ITEM_CREDIT_PRICE\":327.75,'+
        '               \"COST_DOC_CURRENCY\":0,'+
        '               \"ITEM_GROSS_WEIGHT\":\".520\",'+
        '               \"ITEM_NET_WEIGHT\":\".520\",'+
        '               \"ITEM_VOLUME\":0,'+
        '               \"ADDON\":\"\"'+
        '            },'+
        '            {'+
        '               \"COND_ITEM_NO\":\"000014\",'+
        '               \"MATERIAL\":\"000000000010001498\",'+
        '               \"SALES_UNIT\":\"VL\",'+
        '               \"PRICE_OK\":\"\",'+
        '               \"SD_ITEM_CATG\":\"\",'+
        '               \"PLANT\":\"\",'+
        '               \"COND_PRICE_UNIT\":0,'+
        '               \"COND_UNIT\":\"\",'+
        '               \"WEIGHT_UNIT\":\"KG\",'+
        '               \"VOLUME_UNIT\":\"M3\",'+
        '               \"QUANTITY\":\"1.000\",'+
        '               \"NET_PRICE\":0,'+
        '               \"NET_VALUE_DOC_CUR\":0,'+
        '               \"GROSS_VALUE_IN_DOC_CUR\":0,'+
        '               \"TAX_AMT_IN_DOC_CUR\":0,'+
        '               \"COND_SUBTOT\":0,'+
        '               \"ITEM_CONTRACT_PRICE\":0,'+
        '               \"ITEM_DISC_TOT_PRICE\":0,'+
        '               \"COND_SUBTOT4\":0,'+
        '               \"COND_SUBTOT5\":0,'+
        '               \"COND_SUBTOT6\":0,'+
        '               \"RABATE_BASIS\":0,'+
        '               \"PREFERENCE_VALUE\":0,'+
        '               \"ITEM_CREDIT_PRICE\":0,'+
        '               \"COST_DOC_CURRENCY\":0,'+
        '               \"ITEM_GROSS_WEIGHT\":\".043\",'+
        '               \"ITEM_NET_WEIGHT\":\".043\",'+
        '               \"ITEM_VOLUME\":0,'+
        '               \"ADDON\":\"X\"'+
        '            }'+
        '         ]'+
        '      }'+
        '   },'+
        '   \"ET_ADDONS\":{'+
        '      \"ITEM\":{'+
        '         \"DEAL\":3000000030,'+
        '         \"DEAL_SUFFIX\":\"\",'+
        '         \"ITEMNO_SD_DOC\":\"000014\",'+
        '         \"ADDON_STATUS\":\"A\",'+
        '         \"GROUP\":\"\",'+
        '         \"MATERIAL\":\"000000000010001498\",'+
        '         \"MATERIAL_DESC\":\"CONVENIA 80MG\\/ML 10MLVLX1 US\",'+
        '         \"CUM_ORD_QUANTITY\":0,'+
        '         \"ADDON_QUAN_SALES_UNIT\":\"1.000\",'+
        '         \"SALES_UNIT\":\"VL\",'+
        '         \"MAX_ORD_QUANTITY\":0,'+
        '         \"ADDON_ADD_PROP\":\"\",'+
        '         \"ADDON_AUTO_APPLY\":\"X\",'+
        '         \"GROUP_REF\":\"\",'+
        '         \"ADDON_GROUP\":\"\",'+
        '         \"COND_REC_NO\":\"0025960462\",'+
        '         \"CROSS_ORD_RESTRICTION\":\"\",'+
        '         \"WORKGRP_TYPE\":\"\",'+
        '         \"CHECKBOX\":\"\",'+
        '         \"FLEXIBLE_GROUP\":\"\",'+
        '         \"REVENUE_RECOG\":\"\",'+
        '         \"NET_PRICE\":0,'+
        '         \"SD_DOC_CURRENCY\":\"\"'+
        '      }'+
        '   },'+
        '   \"ET_DEAL_LOG\":\"\",'+
        '   \"ET_HEADER_BENEFITS\":\"\",'+
        '   \"ET_ITEM_DEALS\":{'+
        '      \"ITEM\":['+
        '         {'+
        '            \"COND_REC_NO\":\"0025960455\",'+
        '            \"ITEM\":\"000003\",'+
        '            \"DEAL\":3000000028,'+
        '            \"DEAL_SUFFIX\":\"\",'+
        '            \"COND_TYPE\":\"ZB02\",'+
        '            \"COND_VAL\":\"-577.40\",'+
        '            \"COND_VAL_OLD\":0,'+
        '            \"PRIORITY\":\"000\",'+
        '            \"COMPATABLITY_MODE\":\"\",'+
        '            \"COND_INACTIVE\":\"\",'+
        '            \"RATE\":0,'+
        '            \"COND_VAL_NET\":0,'+
        '            \"MATERIAL\":\"\",'+
        '            \"CUM_ORD_QUAN\":0,'+
        '            \"CUM_ORD_QUAN_EL\":0,'+
        '            \"CUM_ORD_QUAN_EX\":0,'+
        '            \"BASE_UOM\":\"\",'+
        '            \"CURRENCY_KEY\":\"USD\",'+
        '            \"ON_DEMAND\":\"\",'+
        '            \"ADDON\":\"\",'+
        '            \"DEAL_RESOLUTION\":4'+
        '         },'+
        '         {'+
        '            \"COND_REC_NO\":\"0025960472\",'+
        '            \"ITEM\":\"000004\",'+
        '            \"DEAL\":4000006099,'+
        '            \"DEAL_SUFFIX\":\"\",'+
        '            \"COND_TYPE\":\"ZLP2\",'+
        '            \"COND_VAL\":40.25,'+
        '            \"COND_VAL_OLD\":0,'+
        '            \"PRIORITY\":\"000\",'+
        '            \"COMPATABLITY_MODE\":\"\",'+
        '            \"COND_INACTIVE\":\"\",'+
        '            \"RATE\":0,'+
        '            \"COND_VAL_NET\":0,'+
        '            \"MATERIAL\":\"\",'+
        '            \"CUM_ORD_QUAN\":0,'+
        '            \"CUM_ORD_QUAN_EL\":0,'+
        '            \"CUM_ORD_QUAN_EX\":0,'+
        '            \"BASE_UOM\":\"\",'+
        '            \"CURRENCY_KEY\":\"USD\",'+
        '            \"ON_DEMAND\":\"\",'+
        '            \"ADDON\":\"\",'+
        '            \"DEAL_RESOLUTION\":4'+
        '         },'+
        '         {'+
        '            \"COND_REC_NO\":\"0025960475\",'+
        '            \"ITEM\":\"000004\",'+
        '            \"DEAL\":4000006100,'+
        '            \"DEAL_SUFFIX\":\"\",'+
        '            \"COND_TYPE\":\"ZLP3\",'+
        '            \"COND_VAL\":\"300.00\",'+
        '            \"COND_VAL_OLD\":0,'+
        '            \"PRIORITY\":\"000\",'+
        '            \"COMPATABLITY_MODE\":\"\",'+
        '            \"COND_INACTIVE\":\"\",'+
        '            \"RATE\":0,'+
        '            \"COND_VAL_NET\":0,'+
        '            \"MATERIAL\":\"\",'+
        '            \"CUM_ORD_QUAN\":0,'+
        '            \"CUM_ORD_QUAN_EL\":0,'+
        '            \"CUM_ORD_QUAN_EX\":0,'+
        '            \"BASE_UOM\":\"\",'+
        '            \"CURRENCY_KEY\":\"USD\",'+
        '            \"ON_DEMAND\":\"\",'+
        '            \"ADDON\":\"\",'+
        '            \"DEAL_RESOLUTION\":4'+
        '         }'+
        '      ]'+
        '   }'+
        '}';

        VistexPricingResponse r = VistexPricingResponse.parse(json);
        System.assert(r != null);
    }

    @IsTest
    public static void testParse3() {
        String json = '{'+
        '   \"ES_RESULT\":{'+
        '      \"SD_DOC_NO\":\"\",'+
        '      \"CUST_NO\":1000009536,'+
        '      \"PRICING_PROC\":\"YSTC01\",'+
        '      \"DOC_CURRENCY\":\"USD\",'+
        '      \"NET_VALUE\":328.83,'+
        '      \"NET_PRICE\":-10.17,'+
        '      \"SUB_TOT1\":0,'+
        '      \"SUB_TOT2\":0,'+
        '      \"SUB_TOT3\":0,'+
        '      \"ORD_DISCOUNT_TOT\":328.83,'+
        '      \"ORD_TAXES\":0,'+
        '      \"ORD_TOT_PRICE\":328.83,'+
        '      \"ITEM\":{'+
        '         \"ITEM\":['+
        '            {'+
        '               \"COND_ITEM_NO\":\"000003\",'+
        '               \"MATERIAL\":\"000000000030002331\",'+
        '               \"SALES_UNIT\":\"ST\",'+
        '               \"PRICE_OK\":\"X\",'+
        '               \"SD_ITEM_CATG\":\"\",'+
        '               \"PLANT\":\"\",'+
        '               \"COND_PRICE_UNIT\":1,'+
        '               \"COND_UNIT\":\"ST\",'+
        '               \"WEIGHT_UNIT\":\"KG\",'+
        '               \"VOLUME_UNIT\":\"\",'+
        '               \"QUANTITY\":\"1.000\",'+
        '               \"NET_PRICE\":86.33,'+
        '               \"NET_VALUE_DOC_CUR\":86.33,'+
        '               \"GROSS_VALUE_IN_DOC_CUR\":86.33,'+
        '               \"TAX_AMT_IN_DOC_CUR\":0,'+
        '               \"COND_SUBTOT\":\"89.00\",'+
        '               \"ITEM_CONTRACT_PRICE\":\"89.00\",'+
        '               \"ITEM_DISC_TOT_PRICE\":\"89.00\",'+
        '               \"COND_SUBTOT4\":86.33,'+
        '               \"COND_SUBTOT5\":86.33,'+
        '               \"COND_SUBTOT6\":86.33,'+
        '               \"RABATE_BASIS\":\"89.00\",'+
        '               \"PREFERENCE_VALUE\":0,'+
        '               \"ITEM_CREDIT_PRICE\":86.33,'+
        '               \"COST_DOC_CURRENCY\":0,'+
        '               \"ITEM_GROSS_WEIGHT\":\"20.000\",'+
        '               \"ITEM_NET_WEIGHT\":\"20.000\",'+
        '               \"ITEM_VOLUME\":0,'+
        '               \"ADDON\":\"\"'+
        '            },'+
        '            {'+
        '               \"COND_ITEM_NO\":\"000004\",'+
        '               \"MATERIAL\":\"000000000030002330\",'+
        '               \"SALES_UNIT\":\"ST\",'+
        '               \"PRICE_OK\":\"X\",'+
        '               \"SD_ITEM_CATG\":\"\",'+
        '               \"PLANT\":\"\",'+
        '               \"COND_PRICE_UNIT\":1,'+
        '               \"COND_UNIT\":\"ST\",'+
        '               \"WEIGHT_UNIT\":\"KG\",'+
        '               \"VOLUME_UNIT\":\"\",'+
        '               \"QUANTITY\":\"1.000\",'+
        '               \"NET_PRICE\":\"242.50\",'+
        '               \"NET_VALUE_DOC_CUR\":\"242.50\",'+
        '               \"GROSS_VALUE_IN_DOC_CUR\":\"242.50\",'+
        '               \"TAX_AMT_IN_DOC_CUR\":0,'+
        '               \"COND_SUBTOT\":\"250.00\",'+
        '               \"ITEM_CONTRACT_PRICE\":\"250.00\",'+
        '               \"ITEM_DISC_TOT_PRICE\":\"250.00\",'+
        '               \"COND_SUBTOT4\":\"242.50\",'+
        '               \"COND_SUBTOT5\":\"242.50\",'+
        '               \"COND_SUBTOT6\":\"242.50\",'+
        '               \"RABATE_BASIS\":\"250.00\",'+
        '               \"PREFERENCE_VALUE\":0,'+
        '               \"ITEM_CREDIT_PRICE\":242.5,'+
        '               \"COST_DOC_CURRENCY\":0,'+
        '               \"ITEM_GROSS_WEIGHT\":\"5.000\",'+
        '               \"ITEM_NET_WEIGHT\":0,'+
        '               \"ITEM_VOLUME\":0,'+
        '               \"ADDON\":\"\"'+
        '            }'+
        '         ]'+
        '      }'+
        '   },'+
        '   \"ET_ADDONS\":\"\",'+
        '   \"ET_DEAL_LOG\":\"\",'+
        '   \"ET_HEADER_BENEFITS\":\"\",'+
        '   \"ET_ITEM_DEALS\":{'+
        '      \"ITEM\":['+
        '         {'+
        '            \"COND_REC_NO\":\"0025961073\",'+
        '            \"ITEM\":\"000003\",'+
        '            \"DEAL\":3000000043,'+
        '            \"DEAL_SUFFIX\":\"\",'+
        '            \"COND_TYPE\":\"ZB02\",'+
        '            \"COND_VAL\":-2.67,'+
        '            \"COND_VAL_OLD\":0,'+
        '            \"PRIORITY\":\"000\",'+
        '            \"COMPATABLITY_MODE\":\"\",'+
        '            \"COND_INACTIVE\":\"\",'+
        '            \"RATE\":0,'+
        '            \"COND_VAL_NET\":0,'+
        '            \"MATERIAL\":\"\",'+
        '            \"CUM_ORD_QUAN\":0,'+
        '            \"CUM_ORD_QUAN_EL\":0,'+
        '            \"CUM_ORD_QUAN_EX\":0,'+
        '            \"BASE_UOM\":\"\",'+
        '            \"CURRENCY_KEY\":\"USD\",'+
        '            \"ON_DEMAND\":\"\",'+
        '            \"ADDON\":\"\",'+
        '            \"DEAL_RESOLUTION\":4'+
        '         },'+
        '         {'+
        '            \"COND_REC_NO\":\"0025961073\",'+
        '            \"ITEM\":\"000004\",'+
        '            \"DEAL\":3000000043,'+
        '            \"DEAL_SUFFIX\":\"\",'+
        '            \"COND_TYPE\":\"ZB02\",'+
        '            \"COND_VAL\":\"-7.50\",'+
        '            \"COND_VAL_OLD\":0,'+
        '            \"PRIORITY\":\"000\",'+
        '            \"COMPATABLITY_MODE\":\"\",'+
        '            \"COND_INACTIVE\":\"\",'+
        '            \"RATE\":0,'+
        '            \"COND_VAL_NET\":0,'+
        '            \"MATERIAL\":\"\",'+
        '            \"CUM_ORD_QUAN\":0,'+
        '            \"CUM_ORD_QUAN_EL\":0,'+
        '            \"CUM_ORD_QUAN_EX\":0,'+
        '            \"BASE_UOM\":\"\",'+
        '            \"CURRENCY_KEY\":\"USD\",'+
        '            \"ON_DEMAND\":\"\",'+
        '            \"ADDON\":\"\",'+
        '            \"DEAL_RESOLUTION\":4'+
        '         }'+
        '      ]'+
        '   }'+
        '}';
        
        VistexPricingResponse r = VistexPricingResponse.parse(json);
        System.assert(r != null);
    }


    static testMethod void testParse4() {
        String json = '{'+
        '   \"ES_RESULT\":{'+
        '      \"SD_DOC_NO\":\"\",'+
        '      \"CUST_NO\":1000009536,'+
        '      \"PRICING_PROC\":\"YSTC01\",'+
        '      \"DOC_CURRENCY\":\"USD\",'+
        '      \"NET_VALUE\":345.83,'+
        '      \"NET_PRICE\":-16.17,'+
        '      \"SUB_TOT1\":0,'+
        '      \"SUB_TOT2\":0,'+
        '      \"SUB_TOT3\":0,'+
        '      \"ORD_DISCOUNT_TOT\":345.83,'+
        '      \"ORD_TAXES\":1.57,'+
        '      \"ORD_TOT_PRICE\":\"347.40\",'+
        '      \"ITEM\":{'+
        '         \"ITEM\":['+
        '            {'+
        '               \"COND_ITEM_NO\":\"000002\",'+
        '               \"MATERIAL\":\"000000000016001283\",'+
        '               \"SALES_UNIT\":\"ST\",'+
        '               \"PRICE_OK\":\"X\",'+
        '               \"SD_ITEM_CATG\":\"\",'+
        '               \"PLANT\":\"\",'+
        '               \"COND_PRICE_UNIT\":1,'+
        '               \"COND_UNIT\":\"ST\",'+
        '               \"WEIGHT_UNIT\":\"KG\",'+
        '               \"VOLUME_UNIT\":\"\",'+
        '               \"QUANTITY\":\"1.000\",'+
        '               \"NET_PRICE\":\"13.00\",'+
        '               \"NET_VALUE_DOC_CUR\":\"13.00\",'+
        '               \"GROSS_VALUE_IN_DOC_CUR\":\"14.20\",'+
        '               \"TAX_AMT_IN_DOC_CUR\":\"1.20\",'+
        '               \"COND_SUBTOT\":\"13.00\",'+
        '               \"ITEM_CONTRACT_PRICE\":\"13.00\",'+
        '               \"ITEM_DISC_TOT_PRICE\":\"13.00\",'+
        '               \"COND_SUBTOT4\":\"13.00\",'+
        '               \"COND_SUBTOT5\":\"13.00\",'+
        '               \"COND_SUBTOT6\":\"14.20\",'+
        '               \"RABATE_BASIS\":\"13.00\",'+
        '               \"PREFERENCE_VALUE\":0,'+
        '               \"ITEM_CREDIT_PRICE\":14.2,'+
        '               \"COST_DOC_CURRENCY\":0,'+
        '               \"ITEM_GROSS_WEIGHT\":\"2.000\",'+
        '               \"ITEM_NET_WEIGHT\":0,'+
        '               \"ITEM_VOLUME\":0,'+
        '               \"ADDON\":\"\"'+
        '            },'+
        '            {'+
        '               \"COND_ITEM_NO\":\"000003\",'+
        '               \"MATERIAL\":\"000000000016001301\",'+
        '               \"SALES_UNIT\":\"ST\",'+
        '               \"PRICE_OK\":\"X\",'+
        '               \"SD_ITEM_CATG\":\"\",'+
        '               \"PLANT\":\"\",'+
        '               \"COND_PRICE_UNIT\":1,'+
        '               \"COND_UNIT\":\"ST\",'+
        '               \"WEIGHT_UNIT\":\"KG\",'+
        '               \"VOLUME_UNIT\":\"\",'+
        '               \"QUANTITY\":\"1.000\",'+
        '               \"NET_PRICE\":\"4.00\",'+
        '               \"NET_VALUE_DOC_CUR\":\"4.00\",'+
        '               \"GROSS_VALUE_IN_DOC_CUR\":4.37,'+
        '               \"TAX_AMT_IN_DOC_CUR\":\".37\",'+
        '               \"COND_SUBTOT\":\"10.00\",'+
        '               \"ITEM_CONTRACT_PRICE\":\"4.00\",'+
        '               \"ITEM_DISC_TOT_PRICE\":\"4.00\",'+
        '               \"COND_SUBTOT4\":\"4.00\",'+
        '               \"COND_SUBTOT5\":\"4.00\",'+
        '               \"COND_SUBTOT6\":4.37,'+
        '               \"RABATE_BASIS\":\"4.00\",'+
        '               \"PREFERENCE_VALUE\":0,'+
        '               \"ITEM_CREDIT_PRICE\":4.37,'+
        '               \"COST_DOC_CURRENCY\":0,'+
        '               \"ITEM_GROSS_WEIGHT\":\"2.000\",'+
        '               \"ITEM_NET_WEIGHT\":0,'+
        '               \"ITEM_VOLUME\":0,'+
        '               \"ADDON\":\"\"'+
        '            },'+
        '            {'+
        '               \"COND_ITEM_NO\":\"000005\",'+
        '               \"MATERIAL\":\"000000000030002330\",'+
        '               \"SALES_UNIT\":\"ST\",'+
        '               \"PRICE_OK\":\"X\",'+
        '               \"SD_ITEM_CATG\":\"\",'+
        '               \"PLANT\":\"\",'+
        '               \"COND_PRICE_UNIT\":1,'+
        '               \"COND_UNIT\":\"ST\",'+
        '               \"WEIGHT_UNIT\":\"KG\",'+
        '               \"VOLUME_UNIT\":\"\",'+
        '               \"QUANTITY\":\"1.000\",'+
        '               \"NET_PRICE\":\"242.50\",'+
        '               \"NET_VALUE_DOC_CUR\":\"242.50\",'+
        '               \"GROSS_VALUE_IN_DOC_CUR\":\"242.50\",'+
        '               \"TAX_AMT_IN_DOC_CUR\":0,'+
        '               \"COND_SUBTOT\":\"250.00\",'+
        '               \"ITEM_CONTRACT_PRICE\":\"250.00\",'+
        '               \"ITEM_DISC_TOT_PRICE\":\"250.00\",'+
        '               \"COND_SUBTOT4\":\"242.50\",'+
        '               \"COND_SUBTOT5\":\"242.50\",'+
        '               \"COND_SUBTOT6\":\"242.50\",'+
        '               \"RABATE_BASIS\":\"250.00\",'+
        '               \"PREFERENCE_VALUE\":0,'+
        '               \"ITEM_CREDIT_PRICE\":242.5,'+
        '               \"COST_DOC_CURRENCY\":0,'+
        '               \"ITEM_GROSS_WEIGHT\":\"5.000\",'+
        '               \"ITEM_NET_WEIGHT\":0,'+
        '               \"ITEM_VOLUME\":0,'+
        '               \"ADDON\":\"\"'+
        '            },'+
        '            {'+
        '               \"COND_ITEM_NO\":\"000006\",'+
        '               \"MATERIAL\":\"000000000030002331\",'+
        '               \"SALES_UNIT\":\"ST\",'+
        '               \"PRICE_OK\":\"X\",'+
        '               \"SD_ITEM_CATG\":\"\",'+
        '               \"PLANT\":\"\",'+
        '               \"COND_PRICE_UNIT\":1,'+
        '               \"COND_UNIT\":\"ST\",'+
        '               \"WEIGHT_UNIT\":\"KG\",'+
        '               \"VOLUME_UNIT\":\"\",'+
        '               \"QUANTITY\":\"1.000\",'+
        '               \"NET_PRICE\":86.33,'+
        '               \"NET_VALUE_DOC_CUR\":86.33,'+
        '               \"GROSS_VALUE_IN_DOC_CUR\":86.33,'+
        '               \"TAX_AMT_IN_DOC_CUR\":0,'+
        '               \"COND_SUBTOT\":\"89.00\",'+
        '               \"ITEM_CONTRACT_PRICE\":\"89.00\",'+
        '               \"ITEM_DISC_TOT_PRICE\":\"89.00\",'+
        '               \"COND_SUBTOT4\":86.33,'+
        '               \"COND_SUBTOT5\":86.33,'+
        '               \"COND_SUBTOT6\":86.33,'+
        '               \"RABATE_BASIS\":\"89.00\",'+
        '               \"PREFERENCE_VALUE\":0,'+
        '               \"ITEM_CREDIT_PRICE\":86.33,'+
        '               \"COST_DOC_CURRENCY\":0,'+
        '               \"ITEM_GROSS_WEIGHT\":\"20.000\",'+
        '               \"ITEM_NET_WEIGHT\":\"20.000\",'+
        '               \"ITEM_VOLUME\":0,'+
        '               \"ADDON\":\"\"'+
        '            }'+
        '         ]'+
        '      }'+
        '   },'+
        '   \"ET_ADDONS\":\"\",'+
        '   \"ET_DEAL_LOG\":\"\",'+
        '   \"ET_HEADER_BENEFITS\":\"\",'+
        '   \"ET_ITEM_DEALS\":{'+
        '      \"ITEM\":['+
        '         {'+
        '            \"COND_REC_NO\":\"0025958124\",'+
        '            \"ITEM\":\"000003\",'+
        '            \"DEAL\":4000006012,'+
        '            \"DEAL_SUFFIX\":\"\",'+
        '            \"COND_TYPE\":\"ZLP1\",'+
        '            \"COND_VAL\":\"-6.00\",'+
        '            \"COND_VAL_OLD\":0,'+
        '            \"PRIORITY\":\"000\",'+
        '            \"COMPATABLITY_MODE\":\"\",'+
        '            \"COND_INACTIVE\":\"\",'+
        '            \"RATE\":0,'+
        '            \"COND_VAL_NET\":0,'+
        '            \"MATERIAL\":\"\",'+
        '            \"CUM_ORD_QUAN\":0,'+
        '            \"CUM_ORD_QUAN_EL\":0,'+
        '            \"CUM_ORD_QUAN_EX\":0,'+
        '            \"BASE_UOM\":\"\",'+
        '            \"CURRENCY_KEY\":\"USD\",'+
        '            \"ON_DEMAND\":\"\",'+
        '            \"ADDON\":\"\",'+
        '            \"DEAL_RESOLUTION\":4'+
        '         },'+
        '         {'+
        '            \"COND_REC_NO\":\"0025961073\",'+
        '            \"ITEM\":\"000005\",'+
        '            \"DEAL\":3000000043,'+
        '            \"DEAL_SUFFIX\":\"\",'+
        '            \"COND_TYPE\":\"ZB02\",'+
        '            \"COND_VAL\":\"-7.50\",'+
        '            \"COND_VAL_OLD\":0,'+
        '            \"PRIORITY\":\"000\",'+
        '            \"COMPATABLITY_MODE\":\"\",'+
        '            \"COND_INACTIVE\":\"\",'+
        '            \"RATE\":0,'+
        '            \"COND_VAL_NET\":0,'+
        '            \"MATERIAL\":\"\",'+
        '            \"CUM_ORD_QUAN\":0,'+
        '            \"CUM_ORD_QUAN_EL\":0,'+
        '            \"CUM_ORD_QUAN_EX\":0,'+
        '            \"BASE_UOM\":\"\",'+
        '            \"CURRENCY_KEY\":\"USD\",'+
        '            \"ON_DEMAND\":\"\",'+
        '            \"ADDON\":\"\",'+
        '            \"DEAL_RESOLUTION\":4'+
        '         },'+
        '         {'+
        '            \"COND_REC_NO\":\"0025961073\",'+
        '            \"ITEM\":\"000006\",'+
        '            \"DEAL\":3000000043,'+
        '            \"DEAL_SUFFIX\":\"\",'+
        '            \"COND_TYPE\":\"ZB02\",'+
        '            \"COND_VAL\":-2.67,'+
        '            \"COND_VAL_OLD\":0,'+
        '            \"PRIORITY\":\"000\",'+
        '            \"COMPATABLITY_MODE\":\"\",'+
        '            \"COND_INACTIVE\":\"\",'+
        '            \"RATE\":0,'+
        '            \"COND_VAL_NET\":0,'+
        '            \"MATERIAL\":\"\",'+
        '            \"CUM_ORD_QUAN\":0,'+
        '            \"CUM_ORD_QUAN_EL\":0,'+
        '            \"CUM_ORD_QUAN_EX\":0,'+
        '            \"BASE_UOM\":\"\",'+
        '            \"CURRENCY_KEY\":\"USD\",'+
        '            \"ON_DEMAND\":\"\",'+
        '            \"ADDON\":\"\",'+
        '            \"DEAL_RESOLUTION\":4'+
        '         }'+
        '      ]'+
        '   }'+
        '}';

        VistexPricingResponse obj = VistexPricingResponse.parse(json);
        System.assert(obj != null);
    }

    static testMethod void testParse5() {
        String json = '{'+
        '   \"ES_RESULT\":{'+
        '      \"SD_DOC_NO\":\"\",'+
        '      \"CUST_NO\":1000009537,'+
        '      \"PRICING_PROC\":\"YSTC01\",'+
        '      \"DOC_CURRENCY\":\"USD\",'+
        '      \"NET_VALUE\":\"4.00\",'+
        '      \"NET_PRICE\":\"-6.00\",'+
        '      \"SUB_TOT1\":0,'+
        '      \"SUB_TOT2\":0,'+
        '      \"SUB_TOT3\":0,'+
        '      \"ORD_DISCOUNT_TOT\":\"4.00\",'+
        '      \"ORD_TAXES\":\".25\",'+
        '      \"ORD_TOT_PRICE\":4.25,'+
        '      \"ITEM\":{'+
        '         \"ITEM\":{'+
        '            \"COND_ITEM_NO\":\"000002\",'+
        '            \"MATERIAL\":\"000000000016001301\",'+
        '            \"SALES_UNIT\":\"ST\",'+
        '            \"PRICE_OK\":\"X\",'+
        '            \"SD_ITEM_CATG\":\"\",'+
        '            \"PLANT\":\"\",'+
        '            \"COND_PRICE_UNIT\":1,'+
        '            \"COND_UNIT\":\"ST\",'+
        '            \"WEIGHT_UNIT\":\"KG\",'+
        '            \"VOLUME_UNIT\":\"\",'+
        '            \"QUANTITY\":\"1.000\",'+
        '            \"NET_PRICE\":\"4.00\",'+
        '            \"NET_VALUE_DOC_CUR\":\"4.00\",'+
        '            \"GROSS_VALUE_IN_DOC_CUR\":4.25,'+
        '            \"TAX_AMT_IN_DOC_CUR\":\".25\",'+
        '            \"COND_SUBTOT\":\"10.00\",'+
        '            \"ITEM_CONTRACT_PRICE\":\"4.00\",'+
        '            \"ITEM_DISC_TOT_PRICE\":\"4.00\",'+
        '            \"COND_SUBTOT4\":\"4.00\",'+
        '            \"COND_SUBTOT5\":\"4.00\",'+
        '            \"COND_SUBTOT6\":4.25,'+
        '            \"RABATE_BASIS\":\"4.00\",'+
        '            \"PREFERENCE_VALUE\":0,'+
        '            \"ITEM_CREDIT_PRICE\":4.25,'+
        '            \"COST_DOC_CURRENCY\":0,'+
        '            \"ITEM_GROSS_WEIGHT\":\"2.000\",'+
        '            \"ITEM_NET_WEIGHT\":0,'+
        '            \"ITEM_VOLUME\":0,'+
        '            \"ADDON\":\"\"'+
        '         }'+
        '      }'+
        '   },'+
        '   \"ET_ADDONS\":\"\",'+
        '   \"ET_DEAL_LOG\":\"\",'+
        '   \"ET_HEADER_BENEFITS\":\"\",'+
        '   \"ET_ITEM_DEALS\":{'+
        '      \"ITEM\":{'+
        '         \"COND_REC_NO\":\"0025958124\",'+
        '         \"ITEM\":\"000002\",'+
        '         \"DEAL\":4000006012,'+
        '         \"DEAL_SUFFIX\":\"\",'+
        '         \"COND_TYPE\":\"ZLP1\",'+
        '         \"COND_VAL\":\"-6.00\",'+
        '         \"COND_VAL_OLD\":0,'+
        '         \"PRIORITY\":\"000\",'+
        '         \"COMPATABLITY_MODE\":\"\",'+
        '         \"COND_INACTIVE\":\"\",'+
        '         \"RATE\":0,'+
        '         \"COND_VAL_NET\":0,'+
        '         \"MATERIAL\":\"\",'+
        '         \"CUM_ORD_QUAN\":0,'+
        '         \"CUM_ORD_QUAN_EL\":0,'+
        '         \"CUM_ORD_QUAN_EX\":0,'+
        '         \"BASE_UOM\":\"\",'+
        '         \"CURRENCY_KEY\":\"USD\",'+
        '         \"ON_DEMAND\":\"\",'+
        '         \"ADDON\":\"\",'+
        '         \"DEAL_RESOLUTION\":4'+
        '      }'+
        '   }'+
        '}';

        VistexPricingResponse obj = VistexPricingResponse.parse(json);
        System.assert(obj != null);
        System.assert(obj.ES_RESULT != null);
        System.assert(obj.ES_RESULT.ITEM != null);
        System.assert(obj.ES_RESULT.ITEM.ITEM != null);
        System.assert(obj.ES_RESULT.ITEM.ITEM.size() == 1);

        VistexPricingResponse.ResultItem item = obj.ES_RESULT.ITEM.ITEM[0];
        System.assertEquals('000002', item.COND_ITEM_NO);

    }

    static testMethod void testParseManualAddons() {
        String json = '{'+
        '   \"ES_RESULT\":{'+
        '      \"SD_DOC_NO\":\"\",'+
        '      \"CUST_NO\":1000009537,'+
        '      \"PRICING_PROC\":\"YSTC01\",'+
        '      \"DOC_CURRENCY\":\"USD\",'+
        '      \"NET_VALUE\":0,'+
        '      \"NET_PRICE\":0,'+
        '      \"SUB_TOT1\":0,'+
        '      \"SUB_TOT2\":0,'+
        '      \"SUB_TOT3\":0,'+
        '      \"ORD_DISCOUNT_TOT\":0,'+
        '      \"ORD_TAXES\":0,'+
        '      \"ORD_TOT_PRICE\":0,'+
        '      \"ITEM\":{'+
        '         \"ITEM\":['+
        '            {'+
        '               \"COND_ITEM_NO\":\"000002\",'+
        '               \"MATERIAL\":\"000000000016001240\",'+
        '               \"SALES_UNIT\":\"ST\",'+
        '               \"PRICE_OK\":\"\",'+
        '               \"SD_ITEM_CATG\":\"\",'+
        '               \"PLANT\":\"\",'+
        '               \"COND_PRICE_UNIT\":1,'+
        '               \"COND_UNIT\":\"ST\",'+
        '               \"WEIGHT_UNIT\":\"KG\",'+
        '               \"VOLUME_UNIT\":\"\",'+
        '               \"QUANTITY\":\"1.000\",'+
        '               \"NET_PRICE\":0,'+
        '               \"NET_VALUE_DOC_CUR\":0,'+
        '               \"GROSS_VALUE_IN_DOC_CUR\":0,'+
        '               \"TAX_AMT_IN_DOC_CUR\":0,'+
        '               \"COND_SUBTOT\":0,'+
        '               \"ITEM_CONTRACT_PRICE\":0,'+
        '               \"ITEM_DISC_TOT_PRICE\":0,'+
        '               \"COND_SUBTOT4\":0,'+
        '               \"COND_SUBTOT5\":0,'+
        '               \"COND_SUBTOT6\":0,'+
        '               \"RABATE_BASIS\":0,'+
        '               \"PREFERENCE_VALUE\":0,'+
        '               \"ITEM_CREDIT_PRICE\":0,'+
        '               \"COST_DOC_CURRENCY\":0,'+
        '               \"ITEM_GROSS_WEIGHT\":\"20.000\",'+
        '               \"ITEM_NET_WEIGHT\":0,'+
        '               \"ITEM_VOLUME\":0,'+
        '               \"ADDON\":\"\"'+
        '            },'+
        '            {'+
        '               \"COND_ITEM_NO\":\"000003\",'+
        '               \"MATERIAL\":\"000000000016001260\",'+
        '               \"SALES_UNIT\":\"ST\",'+
        '               \"PRICE_OK\":\"\",'+
        '               \"SD_ITEM_CATG\":\"\",'+
        '               \"PLANT\":\"\",'+
        '               \"COND_PRICE_UNIT\":1,'+
        '               \"COND_UNIT\":\"ST\",'+
        '               \"WEIGHT_UNIT\":\"KG\",'+
        '               \"VOLUME_UNIT\":\"\",'+
        '               \"QUANTITY\":\"1.000\",'+
        '               \"NET_PRICE\":0,'+
        '               \"NET_VALUE_DOC_CUR\":0,'+
        '               \"GROSS_VALUE_IN_DOC_CUR\":0,'+
        '               \"TAX_AMT_IN_DOC_CUR\":0,'+
        '               \"COND_SUBTOT\":0,'+
        '               \"ITEM_CONTRACT_PRICE\":0,'+
        '               \"ITEM_DISC_TOT_PRICE\":0,'+
        '               \"COND_SUBTOT4\":0,'+
        '               \"COND_SUBTOT5\":0,'+
        '               \"COND_SUBTOT6\":0,'+
        '               \"RABATE_BASIS\":0,'+
        '               \"PREFERENCE_VALUE\":0,'+
        '               \"ITEM_CREDIT_PRICE\":0,'+
        '               \"COST_DOC_CURRENCY\":0,'+
        '               \"ITEM_GROSS_WEIGHT\":\"22.000\",'+
        '               \"ITEM_NET_WEIGHT\":0,'+
        '               \"ITEM_VOLUME\":0,'+
        '               \"ADDON\":\"\"'+
        '            }'+
        '         ]'+
        '      }'+
        '   },'+
        '   \"ET_ADDONS\":{'+
        '      \"ITEM\":['+
        '         {'+
        '            \"DEAL\":3000000058,'+
        '            \"DEAL_SUFFIX\":\"S1\",'+
        '            \"ITEMNO_SD_DOC\":\"000000\",'+
        '            \"ADDON_STATUS\":\"\",'+
        '            \"GROUP\":\"\",'+
        '            \"MATERIAL\":\"000000000060000043\",'+
        '            \"MATERIAL_DESC\":\"2 Year Extended Warranty\",'+
        '            \"CUM_ORD_QUANTITY\":0,'+
        '            \"ADDON_QUAN_SALES_UNIT\":\"1.000\",'+
        '            \"SALES_UNIT\":\"EA\",'+
        '            \"MAX_ORD_QUANTITY\":0,'+
        '            \"ADDON_ADD_PROP\":\"\",'+
        '            \"ADDON_AUTO_APPLY\":\"\",'+
        '            \"GROUP_REF\":\"\",'+
        '            \"ADDON_GROUP\":\"\",'+
        '            \"COND_REC_NO\":\"0025961699\",'+
        '            \"CROSS_ORD_RESTRICTION\":\"\",'+
        '            \"WORKGRP_TYPE\":\"\",'+
        '            \"CHECKBOX\":\"\",'+
        '            \"FLEXIBLE_GROUP\":\"\",'+
        '            \"REVENUE_RECOG\":\"\",'+
        '            \"NET_PRICE\":0,'+
        '            \"SD_DOC_CURRENCY\":\"\"'+
        '         },'+
        '         {'+
        '            \"DEAL\":3000000058,'+
        '            \"DEAL_SUFFIX\":\"S2\",'+
        '            \"ITEMNO_SD_DOC\":\"000000\",'+
        '            \"ADDON_STATUS\":\"\",'+
        '            \"GROUP\":\"\",'+
        '            \"MATERIAL\":\"000000000060000041\",'+
        '            \"MATERIAL_DESC\":\"HM5 - Standard Warranty\",'+
        '            \"CUM_ORD_QUANTITY\":0,'+
        '            \"ADDON_QUAN_SALES_UNIT\":\"1.000\",'+
        '            \"SALES_UNIT\":\"SU\",'+
        '            \"MAX_ORD_QUANTITY\":0,'+
        '            \"ADDON_ADD_PROP\":\"\",'+
        '            \"ADDON_AUTO_APPLY\":\"\",'+
        '            \"GROUP_REF\":\"\",'+
        '            \"ADDON_GROUP\":\"\",'+
        '            \"COND_REC_NO\":\"0025961700\",'+
        '            \"CROSS_ORD_RESTRICTION\":\"\",'+
        '            \"WORKGRP_TYPE\":\"\",'+
        '            \"CHECKBOX\":\"\",'+
        '            \"FLEXIBLE_GROUP\":\"\",'+
        '            \"REVENUE_RECOG\":\"\",'+
        '            \"NET_PRICE\":0,'+
        '            \"SD_DOC_CURRENCY\":\"\"'+
        '         }'+
        '      ]'+
        '   },'+
        '   \"ET_DEAL_LOG\":\"\",'+
        '   \"ET_HEADER_BENEFITS\":\"\",'+
        '   \"ET_ITEM_DEALS\":\"\"'+
        '}';

        VistexPricingResponse obj = VistexPricingResponse.parse(json);
        System.assert(obj != null);
        System.assert(obj.ES_RESULT != null);
        System.assert(obj.ES_RESULT.ITEM != null);
        System.assert(obj.ES_RESULT.ITEM.ITEM != null);
        System.assertEquals(2, obj.ES_RESULT.ITEM.ITEM.size());
        System.assertEquals(2, obj.ET_ADDONS.ITEM.size());

        VistexPricingResponse.AddonItem item = obj.ET_ADDONS.ITEM[0];
        System.assertEquals('', item.ADDON_AUTO_APPLY);
        System.assertEquals('000000000060000043', item.MATERIAL);
        System.assertEquals('2 Year Extended Warranty', item.MATERIAL_DESC);
    }

    @istest
    public static void testParseJsonWithReturn() {
        String json = '{'+
        '    \"ES_RESULT\": {'+
        '        \"SD_DOC_NO\": \"\",'+
        '        \"CUST_NO\": 1000120838,'+
        '        \"PRICING_PROC\": \"YSTD09\",'+
        '        \"DOC_CURRENCY\": \"AUD\",'+
        '        \"NET_VALUE\": \"765.10\",'+
        '        \"NET_PRICE\": \"765.10\",'+
        '        \"SUB_TOT1\": 0,'+
        '        \"SUB_TOT2\": 0,'+
        '        \"SUB_TOT3\": 0,'+
        '        \"ORD_DISCOUNT_TOT\": \"765.10\",'+
        '        \"ORD_TAXES\": 76.51,'+
        '        \"ORD_TOT_PRICE\": 841.61,'+
        '        \"ITEM\": {'+
        '            \"ITEM\": ['+
        '                {'+
        '                    \"COND_ITEM_NO\": \"000001\",'+
        '                    \"MATERIAL\": \"000000000010016589\",'+
        '                    \"SALES_UNIT\": \"BLS\",'+
        '                    \"PRICE_OK\": \"X\",'+
        '                    \"SD_ITEM_CATG\": \"\",'+
        '                    \"PLANT\": \"\",'+
        '                    \"COND_PRICE_UNIT\": 1,'+
        '                    \"COND_UNIT\": \"KAR\",'+
        '                    \"WEIGHT_UNIT\": \"KG\",'+
        '                    \"VOLUME_UNIT\": \"M3\",'+
        '                    \"QUANTITY\": \"10.000\",'+
        '                    \"NET_PRICE\": 70.18,'+
        '                    \"NET_VALUE_DOC_CUR\": \"701.80\",'+
        '                    \"GROSS_VALUE_IN_DOC_CUR\": 771.98,'+
        '                    \"TAX_AMT_IN_DOC_CUR\": 70.18,'+
        '                    \"COND_SUBTOT\": \"701.80\",'+
        '                    \"ITEM_CONTRACT_PRICE\": \"701.80\",'+
        '                    \"ITEM_DISC_TOT_PRICE\": \"701.80\",'+
        '                    \"COND_SUBTOT4\": \"701.80\",'+
        '                    \"COND_SUBTOT5\": \"701.80\",'+
        '                    \"COND_SUBTOT6\": 771.98,'+
        '                    \"RABATE_BASIS\": 70.18,'+
        '                    \"PREFERENCE_VALUE\": 0,'+
        '                    \"ITEM_CREDIT_PRICE\": 77.198,'+
        '                    \"COST_DOC_CURRENCY\": 0,'+
        '                    \"ITEM_GROSS_WEIGHT\": \".047\",'+
        '                    \"ITEM_NET_WEIGHT\": \".018\",'+
        '                    \"ITEM_VOLUME\": 0,'+
        '                    \"ADDON\": \"\"'+
        '                },'+
        '                {'+
        '                    \"COND_ITEM_NO\": \"000002\",'+
        '                    \"MATERIAL\": \"000000000010001130\",'+
        '                    \"SALES_UNIT\": \"VL\",'+
        '                    \"PRICE_OK\": \"X\",'+
        '                    \"SD_ITEM_CATG\": \"\",'+
        '                    \"PLANT\": \"\",'+
        '                    \"COND_PRICE_UNIT\": 1,'+
        '                    \"COND_UNIT\": \"VL\",'+
        '                    \"WEIGHT_UNIT\": \"KG\",'+
        '                    \"VOLUME_UNIT\": \"\",'+
        '                    \"QUANTITY\": \"1.000\",'+
        '                    \"NET_PRICE\": \"63.30\",'+
        '                    \"NET_VALUE_DOC_CUR\": \"63.30\",'+
        '                    \"GROSS_VALUE_IN_DOC_CUR\": 69.63,'+
        '                    \"TAX_AMT_IN_DOC_CUR\": 6.33,'+
        '                    \"COND_SUBTOT\": \"63.30\",'+
        '                    \"ITEM_CONTRACT_PRICE\": \"63.30\",'+
        '                    \"ITEM_DISC_TOT_PRICE\": \"63.30\",'+
        '                    \"COND_SUBTOT4\": \"63.30\",'+
        '                    \"COND_SUBTOT5\": \"63.30\",'+
        '                    \"COND_SUBTOT6\": 69.63,'+
        '                    \"RABATE_BASIS\": \"63.30\",'+
        '                    \"PREFERENCE_VALUE\": 0,'+
        '                    \"ITEM_CREDIT_PRICE\": 69.63,'+
        '                    \"COST_DOC_CURRENCY\": 0,'+
        '                    \"ITEM_GROSS_WEIGHT\": \".110\",'+
        '                    \"ITEM_NET_WEIGHT\": \".110\",'+
        '                    \"ITEM_VOLUME\": 0,'+
        '                    \"ADDON\": \"\"'+
        '                },'+
        '                {'+
        '                    \"COND_ITEM_NO\": \"000012\",'+
        '                    \"MATERIAL\": \"000000000010003255\",'+
        '                    \"SALES_UNIT\": \"TUB\",'+
        '                    \"PRICE_OK\": \"\",'+
        '                    \"SD_ITEM_CATG\": \"\",'+
        '                    \"PLANT\": \"AU06\",'+
        '                    \"COND_PRICE_UNIT\": 0,'+
        '                    \"COND_UNIT\": \"\",'+
        '                    \"WEIGHT_UNIT\": \"KG\",'+
        '                    \"VOLUME_UNIT\": \"\",'+
        '                    \"QUANTITY\": \"1.000\",'+
        '                    \"NET_PRICE\": 0,'+
        '                    \"NET_VALUE_DOC_CUR\": 0,'+
        '                    \"GROSS_VALUE_IN_DOC_CUR\": 0,'+
        '                    \"TAX_AMT_IN_DOC_CUR\": 0,'+
        '                    \"COND_SUBTOT\": 0,'+
        '                    \"ITEM_CONTRACT_PRICE\": 0,'+
        '                    \"ITEM_DISC_TOT_PRICE\": 0,'+
        '                    \"COND_SUBTOT4\": 0,'+
        '                    \"COND_SUBTOT5\": 0,'+
        '                    \"COND_SUBTOT6\": 0,'+
        '                    \"RABATE_BASIS\": 0,'+
        '                    \"PREFERENCE_VALUE\": 0,'+
        '                    \"ITEM_CREDIT_PRICE\": 0,'+
        '                    \"COST_DOC_CURRENCY\": 0,'+
        '                    \"ITEM_GROSS_WEIGHT\": 0,'+
        '                    \"ITEM_NET_WEIGHT\": 0,'+
        '                    \"ITEM_VOLUME\": 0,'+
        '                    \"ADDON\": \"X\"'+
        '                },'+
        '                {'+
        '                    \"COND_ITEM_NO\": \"000022\",'+
        '                    \"MATERIAL\": \"000000000010001130\",'+
        '                    \"SALES_UNIT\": \"VL\",'+
        '                    \"PRICE_OK\": \"\",'+
        '                    \"SD_ITEM_CATG\": \"\",'+
        '                    \"PLANT\": \"AU06\",'+
        '                    \"COND_PRICE_UNIT\": 0,'+
        '                    \"COND_UNIT\": \"\",'+
        '                    \"WEIGHT_UNIT\": \"KG\",'+
        '                    \"VOLUME_UNIT\": \"\",'+
        '                    \"QUANTITY\": \"1.000\",'+
        '                    \"NET_PRICE\": 0,'+
        '                    \"NET_VALUE_DOC_CUR\": 0,'+
        '                    \"GROSS_VALUE_IN_DOC_CUR\": 0,'+
        '                    \"TAX_AMT_IN_DOC_CUR\": 0,'+
        '                    \"COND_SUBTOT\": 0,'+
        '                    \"ITEM_CONTRACT_PRICE\": 0,'+
        '                    \"ITEM_DISC_TOT_PRICE\": 0,'+
        '                    \"COND_SUBTOT4\": 0,'+
        '                    \"COND_SUBTOT5\": 0,'+
        '                    \"COND_SUBTOT6\": 0,'+
        '                    \"RABATE_BASIS\": 0,'+
        '                    \"PREFERENCE_VALUE\": 0,'+
        '                    \"ITEM_CREDIT_PRICE\": 0,'+
        '                    \"COST_DOC_CURRENCY\": 0,'+
        '                    \"ITEM_GROSS_WEIGHT\": \".110\",'+
        '                    \"ITEM_NET_WEIGHT\": \".110\",'+
        '                    \"ITEM_VOLUME\": 0,'+
        '                    \"ADDON\": \"X\"'+
        '                }'+
        '            ]'+
        '        }'+
        '    },'+
        '    \"ET_ADDONS\": {'+
        '        \"ITEM\": ['+
        '            {'+
        '                \"DEAL\": 4000002988,'+
        '                \"DEAL_SUFFIX\": \"\",'+
        '                \"ITEMNO_SD_DOC\": \"000012\",'+
        '                \"ADDON_STATUS\": \"A\",'+
        '                \"GROUP\": \"\",'+
        '                \"MATERIAL\": \"000000000010003255\",'+
        '                \"MATERIAL_DESC\": \"RSPSRE DRAW OFF TUBESX1\",'+
        '                \"CUM_ORD_QUANTITY\": 0,'+
        '                \"ADDON_QUAN_SALES_UNIT\": \"1.000\",'+
        '                \"SALES_UNIT\": \"TUB\",'+
        '                \"MAX_ORD_QUANTITY\": 0,'+
        '                \"ADDON_ADD_PROP\": \"X\",'+
        '                \"ADDON_AUTO_APPLY\": \"X\",'+
        '                \"GROUP_REF\": \"\",'+
        '                \"ADDON_GROUP\": \"\",'+
        '                \"COND_REC_NO\": \"0020267071\",'+
        '                \"CROSS_ORD_RESTRICTION\": \"\",'+
        '                \"WORKGRP_TYPE\": \"\",'+
        '                \"CHECKBOX\": \"\",'+
        '                \"FLEXIBLE_GROUP\": \"\",'+
        '                \"REVENUE_RECOG\": \"\",'+
        '                \"NET_PRICE\": 0,'+
        '                \"SD_DOC_CURRENCY\": \"\"'+
        '            },'+
        '            {'+
        '                \"DEAL\": 4000006028,'+
        '                \"DEAL_SUFFIX\": \"\",'+
        '                \"ITEMNO_SD_DOC\": \"000022\",'+
        '                \"ADDON_STATUS\": \"A\",'+
        '                \"GROUP\": \"\",'+
        '                \"MATERIAL\": \"000000000010001130\",'+
        '                \"MATERIAL_DESC\": \"CLAVULOX SOL 5.6GM/MLX40ML VLX1 AUS\",'+
        '                \"CUM_ORD_QUANTITY\": 0,'+
        '                \"ADDON_QUAN_SALES_UNIT\": \"1.000\",'+
        '                \"SALES_UNIT\": \"KAR\",'+
        '                \"MAX_ORD_QUANTITY\": 0,'+
        '                \"ADDON_ADD_PROP\": \"X\",'+
        '                \"ADDON_AUTO_APPLY\": \"X\",'+
        '                \"GROUP_REF\": \"\",'+
        '                \"ADDON_GROUP\": \"\",'+
        '                \"COND_REC_NO\": \"0025958886\",'+
        '                \"CROSS_ORD_RESTRICTION\": \"\",'+
        '                \"WORKGRP_TYPE\": \"\",'+
        '                \"CHECKBOX\": \"\",'+
        '                \"FLEXIBLE_GROUP\": \"\",'+
        '                \"REVENUE_RECOG\": \"\",'+
        '                \"NET_PRICE\": 0,'+
        '                \"SD_DOC_CURRENCY\": \"\"'+
        '            }'+
        '        ]'+
        '    },'+
        '    \"ET_DEAL_LOG\": \"\",'+
        '    \"ET_HEADER_BENEFITS\": \"\",'+
        '    \"ET_ITEM_DEALS\": {'+
        '        \"ITEM\": ['+
        '            {'+
        '                \"COND_REC_NO\": \"0025958920\",'+
        '                \"ITEM\": \"000001\",'+
        '                \"DEAL\": 4000006029,'+
        '                \"DEAL_SUFFIX\": \"\",'+
        '                \"COND_TYPE\": \"ZB08\",'+
        '                \"COND_VAL\": \"701.80\",'+
        '                \"COND_VAL_OLD\": 0,'+
        '                \"PRIORITY\": \"000\",'+
        '                \"COMPATABLITY_MODE\": \"\",'+
        '                \"COND_INACTIVE\": \"\",'+
        '                \"RATE\": 0,'+
        '                \"COND_VAL_NET\": 0,'+
        '                \"MATERIAL\": \"\",'+
        '                \"CUM_ORD_QUAN\": 0,'+
        '                \"CUM_ORD_QUAN_EL\": 0,'+
        '                \"CUM_ORD_QUAN_EX\": 0,'+
        '                \"BASE_UOM\": \"\",'+
        '                \"CURRENCY_KEY\": \"AUD\",'+
        '                \"ON_DEMAND\": \"\",'+
        '                \"ADDON\": \"\",'+
        '                \"DEAL_RESOLUTION\": 4'+
        '            },'+
        '            {'+
        '                \"COND_REC_NO\": \"0025958920\",'+
        '                \"ITEM\": \"000002\",'+
        '                \"DEAL\": 4000006029,'+
        '                \"DEAL_SUFFIX\": \"\",'+
        '                \"COND_TYPE\": \"ZB08\",'+
        '                \"COND_VAL\": \"63.30\",'+
        '                \"COND_VAL_OLD\": 0,'+
        '                \"PRIORITY\": \"000\",'+
        '                \"COMPATABLITY_MODE\": \"\",'+
        '                \"COND_INACTIVE\": \"\",'+
        '                \"RATE\": 0,'+
        '                \"COND_VAL_NET\": 0,'+
        '                \"MATERIAL\": \"\",'+
        '                \"CUM_ORD_QUAN\": 0,'+
        '                \"CUM_ORD_QUAN_EL\": 0,'+
        '                \"CUM_ORD_QUAN_EX\": 0,'+
        '                \"BASE_UOM\": \"\",'+
        '                \"CURRENCY_KEY\": \"AUD\",'+
        '                \"ON_DEMAND\": \"\",'+
        '                \"ADDON\": \"\",'+
        '                \"DEAL_RESOLUTION\": 4'+
        '            }'+
        '        ]'+
        '    },'+
        '    \"ET_RETURN\": {'+
        '        \"item\": {'+
        '            \"TYPE\": \"S\",'+
        '            \"CODE\": 801,'+
        '            \"MESSAGE\": \"\",'+
        '            \"LOG_NO\": \"\",'+
        '            \"LOG_MSG_NO\": \"000000\",'+
        '            \"MESSAGE_V1\": \"MWST\",'+
        '            \"MESSAGE_V2\": \"\",'+
        '            \"MESSAGE_V3\": \"\",'+
        '            \"MESSAGE_V4\": \"\"'+
        '        }'+
        '    }'+
        '}';

        VistexPricingResponse obj = VistexPricingResponse.parse(json);
        System.assert(obj != null);
        System.assert(obj.ET_RETURN != null);
        System.assert(obj.ET_RETURN.items != null);
        System.assertEquals(1, obj.ET_RETURN.items.size());

        VistexPricingResponse.ReturnItem item = obj.ET_RETURN.items[0];
        System.assertEquals('S', item.TYPE);
        System.assertEquals('801', item.CODE);
        System.assertEquals('', item.MESSAGE);
        System.assertEquals('', item.LOG_NO);
        System.assertEquals('000000', item.LOG_MSG_NO);
    }

    @istest
    public static void testParseJsonWithReturnError() {
        String json =
        '{ '+
        '   \"ES_RESULT\": {' +
        '     \"SD_DOC_NO\":\"\",' +
        '     \"CUST_NO\":\"\",' +
        '     \"PRICING_PROC\":\"\",' +
        '     \"DOC_CURRENCY\":\"\",' +
        '     \"NET_VALUE\":0,' +
        '     \"NET_PRICE\":0,' +
        '     \"SUB_TOT1\":0,' +
        '     \"SUB_TOT2\":0,' +
        '     \"SUB_TOT3\":0,' +
        '     \"ORD_DISCOUNT_TOT\":0,' +
        '     \"ORD_TAXES\":0,' +
        '     \"ORD_TOT_PRICE\":0,' +
        '     \"ITEM\":\"\"' +
        '  },' +
        '  \"ET_ADDONS\":\"\",' +
        '  \"ET_DEAL_LOG\":\"\",' +
        '  \"ET_HEADER_BENEFITS\":\"\",' +
        '  \"ET_ITEM_DEALS\":\"\",' +
        '  \"ET_RETURN\":{' +
        '     \"item\":{' +
        '        \"TYPE\":\"E\",' +
        '        \"CODE\":165,' +
        '        \"MESSAGE\":\"Sales unit ****** is invalid for material 10016589\",' +
        '        \"LOG_NO\":\"\",' +
        '        \"LOG_MSG_NO\":\"000000\",' +
        '        \"MESSAGE_V1\":\"******\",' +
        '        \"MESSAGE_V2\":10016589,' +
        '        \"MESSAGE_V3\":\"\",' +
        '        \"MESSAGE_V4\":\"\"' +
        '     }' +
        '  }' +
        '}';

        VistexPricingResponse obj = VistexPricingResponse.parse(json);
        
        // 
        System.assert(obj != null);
        System.assert(obj.ES_RESULT != null);
        System.assert(obj.ES_RESULT.ITEM != null);
        System.assert(obj.ES_RESULT.ITEM.ITEM != null);
        System.assertEquals(0, obj.ES_RESULT.ITEM.ITEM.size());
        System.assertEquals(0, obj.ET_ADDONS.ITEM.size());
        
        // Check the ET_RETURN object
        System.assert(obj != null);
        System.assert(obj.ET_RETURN != null);
        System.assert(obj.ET_RETURN.items != null);
        System.assertEquals(1, obj.ET_RETURN.items.size());

        VistexPricingResponse.ReturnItem item = obj.ET_RETURN.items[0];
        System.assertEquals('E', item.TYPE);
        System.assertEquals('165', item.CODE);
        System.assertEquals('Sales unit ****** is invalid for material 10016589', item.MESSAGE);
        System.assertEquals('', item.LOG_NO);
    }
}