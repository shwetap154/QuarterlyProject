/**
 * @description       : Test class for 'GetVistexPriceController'.
 * @author            : Cesar Sandrigo @ ATG - Advanced Technology Group
 * @group             : 
 * @last modified on  : 07-25-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-18-2019   Cesar Sandrigo @ ATG        Created the Class and all the tests
 * 1.1	 01-13-2010	  Cesar Sandrigo @ ATG        Fixed test cases.
 * 1.2	 02-14-2020   Ramiro Alvarez @ ATG		    Add new test method: getVistexPrice_NullObj 	
 * 1.3	 03-22-2022   Ethan Hirsch @ Zoetis Inc   Update File Header 	
 * 1.4   07-25-2022   Ethan Hirsch @ Zoetis Inc   Bypass Triggers and run setup inside Test.startTest and Test.stopTest to save on limits
**/
@istest
public class GetVistexPriceControllerTest {
  private static string EMPTY_RESPONSE = '';
  private static string SUCCESS_RESPONSE_WITH_AUTOMATIC_ADDONS =
    '{' +
    '   \"ES_RESULT\":{' +
    '      \"SD_DOC_NO\":\"\",' +
    '      \"CUST_NO\":1000009536,' +
    '      \"PRICING_PROC\":\"YSTC01\",' +
    '      \"DOC_CURRENCY\":\"USD\",' +
    '      \"NET_VALUE\":\"2609.60\",' +
    '      \"NET_PRICE\":-237.15,' +
    '      \"SUB_TOT1\":0,' +
    '      \"SUB_TOT2\":0,' +
    '      \"SUB_TOT3\":0,' +
    '      \"ORD_DISCOUNT_TOT\":\"2609.60\",' +
    '      \"ORD_TAXES\":241.39,' +
    '      \"ORD_TOT_PRICE\":2850.99,' +
    '      \"ITEM\":{' +
    '         \"ITEM\":[' +
    '            {' +
    '               \"COND_ITEM_NO\":\"000002\",' +
    '               \"MATERIAL\":\"000000000010001498\",' +
    '               \"SALES_UNIT\":\"VL\",' +
    '               \"PRICE_OK\":\"X\",' +
    '               \"SD_ITEM_CATG\":\"\",' +
    '               \"PLANT\":\"\",' +
    '               \"COND_PRICE_UNIT\":1,' +
    '               \"COND_UNIT\":\"VL\",' +
    '               \"WEIGHT_UNIT\":\"KG\",' +
    '               \"VOLUME_UNIT\":\"M3\",' +
    '               \"QUANTITY\":\"10.000\",' +
    '               \"NET_PRICE\":230.96,' +
    '               \"NET_VALUE_DOC_CUR\":\"2309.60\",' +
    '               \"GROSS_VALUE_IN_DOC_CUR\":2523.24,' +
    '               \"TAX_AMT_IN_DOC_CUR\":213.64,' +
    '               \"COND_SUBTOT\":\"2887.00\",' +
    '               \"ITEM_CONTRACT_PRICE\":\"2887.00\",' +
    '               \"ITEM_DISC_TOT_PRICE\":\"2887.00\",' +
    '               \"COND_SUBTOT4\":\"252.324\",' +
    '               \"COND_SUBTOT5\":\"2309.60\",' +
    '               \"COND_SUBTOT6\":2523.24,' +
    '               \"RABATE_BASIS\":\"288.70\",' +
    '               \"PREFERENCE_VALUE\":0,' +
    '               \"ITEM_CREDIT_PRICE\":252.324,' +
    '               \"COST_DOC_CURRENCY\":0,' +
    '               \"ITEM_GROSS_WEIGHT\":\".043\",' +
    '               \"ITEM_NET_WEIGHT\":\".043\",' +
    '               \"ITEM_VOLUME\":0,' +
    '               \"ADDON\":\"\"' +
    '            },' +
    '            {' +
    '               \"COND_ITEM_NO\":\"000014\",' +
    '               \"MATERIAL\":\"000000000010001498\",' +
    '               \"SALES_UNIT\":\"VL\",' +
    '               \"PRICE_OK\":\"\",' +
    '               \"SD_ITEM_CATG\":\"\",' +
    '               \"PLANT\":\"\",' +
    '               \"COND_PRICE_UNIT\":0,' +
    '               \"COND_UNIT\":\"\",' +
    '               \"WEIGHT_UNIT\":\"KG\",' +
    '               \"VOLUME_UNIT\":\"M3\",' +
    '               \"QUANTITY\":\"1.000\",' +
    '               \"NET_PRICE\":0,' +
    '               \"NET_VALUE_DOC_CUR\":0,' +
    '               \"GROSS_VALUE_IN_DOC_CUR\":0,' +
    '               \"TAX_AMT_IN_DOC_CUR\":0,' +
    '               \"COND_SUBTOT\":0,' +
    '               \"ITEM_CONTRACT_PRICE\":0,' +
    '               \"ITEM_DISC_TOT_PRICE\":0,' +
    '               \"COND_SUBTOT4\":0,' +
    '               \"COND_SUBTOT5\":0,' +
    '               \"COND_SUBTOT6\":0,' +
    '               \"RABATE_BASIS\":0,' +
    '               \"PREFERENCE_VALUE\":0,' +
    '               \"ITEM_CREDIT_PRICE\":0,' +
    '               \"COST_DOC_CURRENCY\":0,' +
    '               \"ITEM_GROSS_WEIGHT\":\".043\",' +
    '               \"ITEM_NET_WEIGHT\":\".043\",' +
    '               \"ITEM_VOLUME\":0,' +
    '               \"ADDON\":\"X\"' +
    '            }' +
    '         ]' +
    '      }' +
    '   },' +
    '   \"ET_ADDONS\":{' +
    '      \"ITEM\":{' +
    '         \"DEAL\":3000000030,' +
    '         \"DEAL_SUFFIX\":\"S1\",' +
    '         \"ITEMNO_SD_DOC\":\"000014\",' +
    '         \"ADDON_STATUS\":\"A\",' +
    '         \"GROUP\":\"\",' +
    '         \"MATERIAL\":\"000000000010001498\",' +
    '         \"MATERIAL_DESC\":\"CONVENIA 80MG\\/ML 10MLVLX1 US\",' +
    '         \"CUM_ORD_QUANTITY\":0,' +
    '         \"ADDON_QUAN_SALES_UNIT\":\"1.000\",' +
    '         \"SALES_UNIT\":\"VL\",' +
    '         \"MAX_ORD_QUANTITY\":0,' +
    '         \"ADDON_ADD_PROP\":\"\",' +
    '         \"ADDON_AUTO_APPLY\":\"X\",' +
    '         \"GROUP_REF\":\"\",' +
    '         \"ADDON_GROUP\":\"\",' +
    '         \"COND_REC_NO\":\"0025960462\",' +
    '         \"CROSS_ORD_RESTRICTION\":\"\",' +
    '         \"WORKGRP_TYPE\":\"\",' +
    '         \"CHECKBOX\":\"\",' +
    '         \"FLEXIBLE_GROUP\":\"\",' +
    '         \"REVENUE_RECOG\":\"\",' +
    '         \"NET_PRICE\":0,' +
    '         \"SD_DOC_CURRENCY\":\"\"' +
    '      }' +
    '   },' +
    '   \"ET_DEAL_LOG\":\"\",' +
    '   \"ET_HEADER_BENEFITS\":\"\",' +
    '   \"ET_ITEM_DEALS\":{' +
    '      \"ITEM\":[' +
    '      ]' +
    '   }' +
    '}';

  private static string SUCCESS_RESPONSE_WITH_MANUAL_ADDONS =
    '{' +
    '   \"ES_RESULT\":{' +
    '      \"SD_DOC_NO\":\"\",' +
    '      \"CUST_NO\":1000009537,' +
    '      \"PRICING_PROC\":\"YSTC01\",' +
    '      \"DOC_CURRENCY\":\"USD\",' +
    '      \"NET_VALUE\":0,' +
    '      \"NET_PRICE\":0,' +
    '      \"SUB_TOT1\":0,' +
    '      \"SUB_TOT2\":0,' +
    '      \"SUB_TOT3\":0,' +
    '      \"ORD_DISCOUNT_TOT\":0,' +
    '      \"ORD_TAXES\":0,' +
    '      \"ORD_TOT_PRICE\":0,' +
    '      \"ITEM\":{' +
    '         \"ITEM\":[' +
    '            {' +
    '               \"COND_ITEM_NO\":\"000002\",' +
    '               \"MATERIAL\":\"000000000016001240\",' +
    '               \"SALES_UNIT\":\"ST\",' +
    '               \"PRICE_OK\":\"\",' +
    '               \"SD_ITEM_CATG\":\"\",' +
    '               \"PLANT\":\"\",' +
    '               \"COND_PRICE_UNIT\":1,' +
    '               \"COND_UNIT\":\"ST\",' +
    '               \"WEIGHT_UNIT\":\"KG\",' +
    '               \"VOLUME_UNIT\":\"\",' +
    '               \"QUANTITY\":\"1.000\",' +
    '               \"NET_PRICE\":0,' +
    '               \"NET_VALUE_DOC_CUR\":0,' +
    '               \"GROSS_VALUE_IN_DOC_CUR\":0,' +
    '               \"TAX_AMT_IN_DOC_CUR\":0,' +
    '               \"COND_SUBTOT\":0,' +
    '               \"ITEM_CONTRACT_PRICE\":0,' +
    '               \"ITEM_DISC_TOT_PRICE\":0,' +
    '               \"COND_SUBTOT4\":0,' +
    '               \"COND_SUBTOT5\":0,' +
    '               \"COND_SUBTOT6\":0,' +
    '               \"RABATE_BASIS\":0,' +
    '               \"PREFERENCE_VALUE\":0,' +
    '               \"ITEM_CREDIT_PRICE\":0,' +
    '               \"COST_DOC_CURRENCY\":0,' +
    '               \"ITEM_GROSS_WEIGHT\":\"20.000\",' +
    '               \"ITEM_NET_WEIGHT\":0,' +
    '               \"ITEM_VOLUME\":0,' +
    '               \"ADDON\":\"\"' +
    '            },' +
    '            {' +
    '               \"COND_ITEM_NO\":\"000003\",' +
    '               \"MATERIAL\":\"000000000016001260\",' +
    '               \"SALES_UNIT\":\"ST\",' +
    '               \"PRICE_OK\":\"\",' +
    '               \"SD_ITEM_CATG\":\"\",' +
    '               \"PLANT\":\"\",' +
    '               \"COND_PRICE_UNIT\":1,' +
    '               \"COND_UNIT\":\"ST\",' +
    '               \"WEIGHT_UNIT\":\"KG\",' +
    '               \"VOLUME_UNIT\":\"\",' +
    '               \"QUANTITY\":\"1.000\",' +
    '               \"NET_PRICE\":0,' +
    '               \"NET_VALUE_DOC_CUR\":0,' +
    '               \"GROSS_VALUE_IN_DOC_CUR\":0,' +
    '               \"TAX_AMT_IN_DOC_CUR\":0,' +
    '               \"COND_SUBTOT\":0,' +
    '               \"ITEM_CONTRACT_PRICE\":0,' +
    '               \"ITEM_DISC_TOT_PRICE\":0,' +
    '               \"COND_SUBTOT4\":0,' +
    '               \"COND_SUBTOT5\":0,' +
    '               \"COND_SUBTOT6\":0,' +
    '               \"RABATE_BASIS\":0,' +
    '               \"PREFERENCE_VALUE\":0,' +
    '               \"ITEM_CREDIT_PRICE\":0,' +
    '               \"COST_DOC_CURRENCY\":0,' +
    '               \"ITEM_GROSS_WEIGHT\":\"22.000\",' +
    '               \"ITEM_NET_WEIGHT\":0,' +
    '               \"ITEM_VOLUME\":0,' +
    '               \"ADDON\":\"\"' +
    '            }' +
    '         ]' +
    '      }' +
    '   },' +
    '   \"ET_ADDONS\":{' +
    '      \"ITEM\":[' +
    '         {' +
    '            \"DEAL\":3000000058,' +
    '            \"DEAL_SUFFIX\":\"S1\",' +
    '            \"ITEMNO_SD_DOC\":\"000000\",' +
    '            \"ADDON_STATUS\":\"\",' +
    '            \"GROUP\":\"\",' +
    '            \"MATERIAL\":\"000000000060000043\",' +
    '            \"MATERIAL_DESC\":\"2 Year Extended Warranty\",' +
    '            \"CUM_ORD_QUANTITY\":0,' +
    '            \"ADDON_QUAN_SALES_UNIT\":\"1.000\",' +
    '            \"SALES_UNIT\":\"EA\",' +
    '            \"MAX_ORD_QUANTITY\":0,' +
    '            \"ADDON_ADD_PROP\":\"\",' +
    '            \"ADDON_AUTO_APPLY\":\"\",' +
    '            \"GROUP_REF\":\"\",' +
    '            \"ADDON_GROUP\":\"\",' +
    '            \"COND_REC_NO\":\"0025961699\",' +
    '            \"CROSS_ORD_RESTRICTION\":\"\",' +
    '            \"WORKGRP_TYPE\":\"\",' +
    '            \"CHECKBOX\":\"\",' +
    '            \"FLEXIBLE_GROUP\":\"\",' +
    '            \"REVENUE_RECOG\":\"\",' +
    '            \"NET_PRICE\":0,' +
    '            \"SD_DOC_CURRENCY\":\"\"' +
    '         },' +
    '         {' +
    '            \"DEAL\":3000000058,' +
    '            \"DEAL_SUFFIX\":\"S2\",' +
    '            \"ITEMNO_SD_DOC\":\"000000\",' +
    '            \"ADDON_STATUS\":\"\",' +
    '            \"GROUP\":\"\",' +
    '            \"MATERIAL\":\"000000000060000041\",' +
    '            \"MATERIAL_DESC\":\"HM5 - Standard Warranty\",' +
    '            \"CUM_ORD_QUANTITY\":0,' +
    '            \"ADDON_QUAN_SALES_UNIT\":\"1.000\",' +
    '            \"SALES_UNIT\":\"SU\",' +
    '            \"MAX_ORD_QUANTITY\":0,' +
    '            \"ADDON_ADD_PROP\":\"\",' +
    '            \"ADDON_AUTO_APPLY\":\"\",' +
    '            \"GROUP_REF\":\"\",' +
    '            \"ADDON_GROUP\":\"\",' +
    '            \"COND_REC_NO\":\"0025961700\",' +
    '            \"CROSS_ORD_RESTRICTION\":\"\",' +
    '            \"WORKGRP_TYPE\":\"\",' +
    '            \"CHECKBOX\":\"\",' +
    '            \"FLEXIBLE_GROUP\":\"\",' +
    '            \"REVENUE_RECOG\":\"\",' +
    '            \"NET_PRICE\":0,' +
    '            \"SD_DOC_CURRENCY\":\"\"' +
    '         }' +
    '      ]' +
    '   },' +
    '   \"ET_DEAL_LOG\":\"\",' +
    '   \"ET_HEADER_BENEFITS\":\"\",' +
    '   \"ET_ITEM_DEALS\":\"\"' +
    '}';

  private static string ERROR_RESPONSE =
    '{ ' +
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

  private static string SUCCESS_RESPONSE_WITH_RXDX_ADDONS =
    '{' +
    '   \"ES_RESULT\":{' +
    '      \"SD_DOC_NO\":\"\",' +
    '      \"CUST_NO\":1000009537,' +
    '      \"PRICING_PROC\":\"YSTC01\",' +
    '      \"DOC_CURRENCY\":\"USD\",' +
    '      \"NET_VALUE\":0,' +
    '      \"NET_PRICE\":0,' +
    '      \"SUB_TOT1\":0,' +
    '      \"SUB_TOT2\":0,' +
    '      \"SUB_TOT3\":0,' +
    '      \"ORD_DISCOUNT_TOT\":0,' +
    '      \"ORD_TAXES\":0,' +
    '      \"ORD_TOT_PRICE\":0,' +
    '      \"ITEM\":{' +
    '         \"ITEM\":[' +
    '            {' +
    '               \"COND_ITEM_NO\":\"000002\",' +
    '               \"MATERIAL\":\"000000000016001240\",' +
    '               \"SALES_UNIT\":\"ST\",' +
    '               \"PRICE_OK\":\"\",' +
    '               \"SD_ITEM_CATG\":\"\",' +
    '               \"PLANT\":\"\",' +
    '               \"COND_PRICE_UNIT\":1,' +
    '               \"COND_UNIT\":\"ST\",' +
    '               \"WEIGHT_UNIT\":\"KG\",' +
    '               \"VOLUME_UNIT\":\"\",' +
    '               \"QUANTITY\":\"1.000\",' +
    '               \"NET_PRICE\":0,' +
    '               \"NET_VALUE_DOC_CUR\":0,' +
    '               \"GROSS_VALUE_IN_DOC_CUR\":0,' +
    '               \"TAX_AMT_IN_DOC_CUR\":0,' +
    '               \"COND_SUBTOT\":0,' +
    '               \"ITEM_CONTRACT_PRICE\":0,' +
    '               \"ITEM_DISC_TOT_PRICE\":0,' +
    '               \"COND_SUBTOT4\":0,' +
    '               \"COND_SUBTOT5\":0,' +
    '               \"COND_SUBTOT6\":0,' +
    '               \"RABATE_BASIS\":0,' +
    '               \"PREFERENCE_VALUE\":0,' +
    '               \"ITEM_CREDIT_PRICE\":0,' +
    '               \"COST_DOC_CURRENCY\":0,' +
    '               \"ITEM_GROSS_WEIGHT\":\"20.000\",' +
    '               \"ITEM_NET_WEIGHT\":0,' +
    '               \"ITEM_VOLUME\":0,' +
    '               \"ADDON\":\"\"' +
    '            },' +
    '            {' +
    '               \"COND_ITEM_NO\":\"000003\",' +
    '               \"MATERIAL\":\"000000000016001260\",' +
    '               \"SALES_UNIT\":\"ST\",' +
    '               \"PRICE_OK\":\"\",' +
    '               \"SD_ITEM_CATG\":\"\",' +
    '               \"PLANT\":\"\",' +
    '               \"COND_PRICE_UNIT\":1,' +
    '               \"COND_UNIT\":\"ST\",' +
    '               \"WEIGHT_UNIT\":\"KG\",' +
    '               \"VOLUME_UNIT\":\"\",' +
    '               \"QUANTITY\":\"1.000\",' +
    '               \"NET_PRICE\":0,' +
    '               \"NET_VALUE_DOC_CUR\":0,' +
    '               \"GROSS_VALUE_IN_DOC_CUR\":0,' +
    '               \"TAX_AMT_IN_DOC_CUR\":0,' +
    '               \"COND_SUBTOT\":0,' +
    '               \"ITEM_CONTRACT_PRICE\":0,' +
    '               \"ITEM_DISC_TOT_PRICE\":0,' +
    '               \"COND_SUBTOT4\":0,' +
    '               \"COND_SUBTOT5\":0,' +
    '               \"COND_SUBTOT6\":0,' +
    '               \"RABATE_BASIS\":0,' +
    '               \"PREFERENCE_VALUE\":0,' +
    '               \"ITEM_CREDIT_PRICE\":0,' +
    '               \"COST_DOC_CURRENCY\":0,' +
    '               \"ITEM_GROSS_WEIGHT\":\"22.000\",' +
    '               \"ITEM_NET_WEIGHT\":0,' +
    '               \"ITEM_VOLUME\":0,' +
    '               \"ADDON\":\"\"' +
    '            }' +
    '         ]' +
    '      }' +
    '   },' +
    '   \"ET_ADDONS\":{' +
    '      \"ITEM\":[' +
    '         {' +
    '            \"DEAL\":3000000058,' +
    '            \"DEAL_SUFFIX\":\"S1\",' +
    '            \"ITEMNO_SD_DOC\":\"000000\",' +
    '            \"ADDON_STATUS\":\"\",' +
    '            \"GROUP\":\"0000001287\",' +
    '            \"MATERIAL\":\"\",' +
    '            \"MATERIAL_DESC\":\"\",' +
    '            \"CUM_ORD_QUANTITY\":0,' +
    '            \"ADDON_QUAN_SALES_UNIT\":\"1.000\",' +
    '            \"SALES_UNIT\":\"EA\",' +
    '            \"MAX_ORD_QUANTITY\":0,' +
    '            \"ADDON_ADD_PROP\":\"\",' +
    '            \"ADDON_AUTO_APPLY\":\"\",' +
    '            \"GROUP_REF\":\"\",' +
    '            \"ADDON_GROUP\":\"\",' +
    '            \"COND_REC_NO\":\"0025961699\",' +
    '            \"CROSS_ORD_RESTRICTION\":\"\",' +
    '            \"WORKGRP_TYPE\":\"\",' +
    '            \"CHECKBOX\":\"\",' +
    '            \"FLEXIBLE_GROUP\":\"\",' +
    '            \"REVENUE_RECOG\":\"\",' +
    '            \"NET_PRICE\":100,' +
    '            \"SD_DOC_CURRENCY\":\"\"' +
    '         },' +
    '         {' +
    '            \"DEAL\":3000000058,' +
    '            \"DEAL_SUFFIX\":\"S1\",' +
    '            \"ITEMNO_SD_DOC\":\"000000\",' +
    '            \"ADDON_STATUS\":\"\",' +
    '            \"GROUP\":\"\",' +
    '            \"MATERIAL\":\"000000000010001498\",' +
    '            \"MATERIAL_DESC\":\"2 Year Extended Warranty\",' +
    '            \"CUM_ORD_QUANTITY\":0,' +
    '            \"ADDON_QUAN_SALES_UNIT\":\"1.000\",' +
    '            \"SALES_UNIT\":\"EA\",' +
    '            \"MAX_ORD_QUANTITY\":0,' +
    '            \"ADDON_ADD_PROP\":\"\",' +
    '            \"ADDON_AUTO_APPLY\":\"\",' +
    '            \"GROUP_REF\":\"0000001287\",' +
    '            \"ADDON_GROUP\":\"\",' +
    '            \"COND_REC_NO\":\"0025961699\",' +
    '            \"CROSS_ORD_RESTRICTION\":\"\",' +
    '            \"WORKGRP_TYPE\":\"\",' +
    '            \"CHECKBOX\":\"\",' +
    '            \"FLEXIBLE_GROUP\":\"\",' +
    '            \"REVENUE_RECOG\":\"\",' +
    '            \"NET_PRICE\":0,' +
    '            \"SD_DOC_CURRENCY\":\"\"' +
    '         },' +
    '         {' +
    '            \"DEAL\":3000000058,' +
    '            \"DEAL_SUFFIX\":\"S1\",' +
    '            \"ITEMNO_SD_DOC\":\"000000\",' +
    '            \"ADDON_STATUS\":\"\",' +
    '            \"GROUP\":\"\",' +
    '            \"MATERIAL\":\"000000000060000043\",' +
    '            \"MATERIAL_DESC\":\"HM5 - Standard Warranty\",' +
    '            \"CUM_ORD_QUANTITY\":0,' +
    '            \"ADDON_QUAN_SALES_UNIT\":\"1.000\",' +
    '            \"SALES_UNIT\":\"SU\",' +
    '            \"MAX_ORD_QUANTITY\":0,' +
    '            \"ADDON_ADD_PROP\":\"\",' +
    '            \"ADDON_AUTO_APPLY\":\"\",' +
    '            \"GROUP_REF\":\"0000001287\",' +
    '            \"ADDON_GROUP\":\"\",' +
    '            \"COND_REC_NO\":\"0025961700\",' +
    '            \"CROSS_ORD_RESTRICTION\":\"\",' +
    '            \"WORKGRP_TYPE\":\"\",' +
    '            \"CHECKBOX\":\"\",' +
    '            \"FLEXIBLE_GROUP\":\"\",' +
    '            \"REVENUE_RECOG\":\"\",' +
    '            \"NET_PRICE\":0,' +
    '            \"SD_DOC_CURRENCY\":\"\"' +
    '         }' +
    '      ]' +
    '   },' +
    '   \"ET_DEAL_LOG\":\"\",' +
    '   \"ET_HEADER_BENEFITS\":\"\",' +
    '   \"ET_ITEM_DEALS\":\"\"' +
    '}';

  @testSetup
  public static void setup() {
    // Run setup in Test.startTest and Test.stopTest due to it using a good amount of SOQL limits
    Test.startTest();
      // Disable Triggers to reduce limit usage
      SBQQ.TriggerControl.disable();
      DispatchTriggerHandler.bypass('AccountTriggerHandler');
      DispatchTriggerHandler.bypass('AddressTriggerHandler');
      DispatchTriggerHandler.bypass('ContactTriggerHandler');
      DispatchTriggerHandler.bypass('OpportunityTriggerHandler');
      DispatchTriggerHandler.bypass('OpportunityTriggerHandler');

      // Insert custom settings from Vistex
      insertVistexCustomSettings();

      // Create Markets and Market Countries
      List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
      CPQ_TestDataFactory.createMarketCountrys(markets, true);

      // Create US pricebook
      Pricebook2 usPricebook = CPQ_TestDataFactory.createPricebook('US Pricebook', '1436', true);

      // Get US market
      Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
      usMarket.Price_Book__c = usPricebook.Id;
      update usMarket;

      // Create an account and a contact
      Account account = CPQ_TestDataFactory.createAccount(true);
      Address__c soldToAddress = CPQ_TestDataFactory.createAddress(account, true);
      account.ZTS_EU_Primary_Address__c = soldToAddress.Id;
      update account;

      // Create an account and a contact        
       Contact contact = CPQ_TestDataFactory.createContact(false);
       contact.AccountId = account.Id;
       insert contact;

       // Create an opportunity for the account in the US Market
       Opportunity oppty = CPQ_TestDataFactory.createOppty(account, usMarket, false);
       oppty.Purchasing_Contact__c = contact.Id;     
       insert oppty;

      // Create Address record
      Address__c address = CPQ_TestDataFactory.createAddress(account, true);

      // Crete an empty quote
      SBQQ__Quote__c quote = CPQ_TestDataFactory.createQuote(oppty, account, contact, address, false);
      quote.Address__c = soldToAddress.Id;
      insert quote;

      // Create SAP materials
      List<SAP_Material__c> materials = new List<SAP_Material__c>{
        CPQ_TestDataFactory.createSAPMaterial('VL', '000000000010001498', 'NORM', 'ZFER', '', false),
        CPQ_TestDataFactory.createSAPMaterial('EA', '000000000060000043', 'DIEN', 'DIEN', '', false)
      };
      insert materials;

      // Create product
      Product2 product = CPQ_TestDataFactory.createProduct(false);
      product.SAP_Material__c = materials[0].Id;

      Product2 productWarranty = CPQ_TestDataFactory.createProduct(false);
      productWarranty.SAP_Material__c = materials[1].Id;

      Product2 productParent = CPQ_TestDataFactory.createProduct(false);
      productParent.Name = 'Bundle parent';
      productParent.Program_Eligibility_Filter__c = 'FREEDOM';

      // Insert products
      insert new List<Product2>{ productParent, product, productWarranty };

      Date today = Date.today();
      List<SAP_Price_Entry__c> sapPriceEntries = new List<SAP_Price_Entry__c>{
        CPQ_TestDataFactory.createSAPPriceEntry('000000000010001498', '1436', 10.0, 'USD', false),
        CPQ_TestDataFactory.createSAPPriceEntry('000000000060000043', '1436', 10.0, 'USD', false)
      };
      insert sapPriceEntries;

      // Create PBEs
      insert new List<PricebookEntry>{
        // Standard pricebook
        CPQ_TestDataFactory.createPriceBookEntry(productParent, false),
        CPQ_TestDataFactory.createPriceBookEntry(productWarranty, false),
        CPQ_TestDataFactory.createPriceBookEntry(product, false),
        // US pricebook
        CPQ_TestDataFactory.createPriceBookEntry(productParent, usPricebook, 'USD', false),
        CPQ_TestDataFactory.createPriceBookEntry(productWarranty, usPricebook, 'USD', sapPriceEntries[1], false),
        CPQ_TestDataFactory.createPriceBookEntry(product, usPricebook, 'USD', sapPriceEntries[0], false)
      };

      // Insert bundle parent line
      SBQQ__QuoteLine__c parentLine = CPQ_TestDataFactory.createQuoteLine(quote, productParent, false);
      parentLine.SBQQ__Bundle__c = true;
      insert parentLine;

      // Insert child line
      SBQQ__QuoteLine__c childLine = CPQ_TestDataFactory.createQuoteLine(quote, product, false);
      childLine.SBQQ__RequiredBy__c = parentLine.Id;
      insert childLine;

      childLine.SAP_Unit_Of_Measure__c = 'ST';
      update childLine;
    
      // Reenable Triggers to be safe.
      SBQQ.TriggerControl.enable();
      DispatchTriggerHandler.clearAllBypasses();
    Test.stopTest();
  }

  private static void insertVistexCustomSettings() {
    Vistex_Configuration__c vistexConfig = new Vistex_Configuration__c();
    vistexConfig.Endpoint_Relative_Path__c = 'RESTAdapter/Deals/DealsSimulation/1234';
    vistexConfig.Response_time_out__c = 3000;
    vistexConfig.Retry_Times__c = 1;
    insert vistexConfig;
  }

  @istest
  public static void getVistexPriceFromLightning_EmptyQuote() {
    // Remove the quote line to get an empty quote
    List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];

    // Get the quote id before removing the quote line
    Id quoteId = quoteLines[0].SBQQ__Quote__c;

    Test.startTest();
    // Remove the quote line
    delete quoteLines;
    Test.stopTest();

    // Try to get the price from the empty quote
    GetVistexPriceController.PricingCallResponse result = GetVistexPriceController.getVistexPriceFromLightning(quoteId, false);

    System.AssertEquals('Warn', result.Status);
    System.AssertNotEquals('', result.Message);
  }

  @istest
  public static void getVistexPrice_NullObj() {
    List<SBQQ__QuoteLine__c> quotelines = [SELECT Id, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Bundle__c = FALSE];

    // Get the quote id before removing the quote line
    Id quoteId = quoteLines[0].SBQQ__Quote__c;

    Test.startTest();

    delete quotelines;

    Test.stopTest();

    // Try to get the price from the empty quote
    GetVistexPriceController.PricingCallResponse result = GetVistexPriceController.getVistexPriceFromLightning(quoteId, false);

    SBQQ__Quote__c quote = [SELECT Id, Vistex_Price_In_Sync__c FROM SBQQ__Quote__c WHERE Id = :quoteId];

    //Check Vistex_Price_In_Sync__c on quote
    System.AssertEquals(true, quote.Vistex_Price_In_Sync__c);
  }

  @istest
  public static void getVistexPriceFromLightning_WithAutomaticAddOns() {
    // Configure mock service to get an empty response
    VistexPricingServiceMock vistexServiceMock = new VistexPricingServiceMock(
      200,
      'Success',
      SUCCESS_RESPONSE_WITH_AUTOMATIC_ADDONS,
      new Map<String, String>()
    );
    Test.setMock(HttpCalloutMock.class, vistexServiceMock);

    // Get the quote created on set-up
    SBQQ__Quote__c quoteBefore = [SELECT Id, (SELECT Id FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c LIMIT 1];

    Test.startTest();

    // Try to get Vistex Price
    GetVistexPriceController.PricingCallResponse result = GetVistexPriceController.getVistexPriceFromLightning(quoteBefore.Id, false);

    Test.stopTest();

    // Empty result means everything was OK
    System.AssertEquals('OK', result.Status);
    System.AssertEquals(1, result.AutomaticAddons.size());
    System.AssertEquals(0, result.ManualAddons.size());

    // Get the quote updated
    SBQQ__Quote__c quoteAfter = [
      SELECT
        Id,
        Vistex_Price_In_Sync__c,
        (SELECT Id, Vistex_Automatic_Add_on__c, Deal_Discount__c, Contract_Price__c, Deal_Line_Group__c FROM SBQQ__LineItems__r)
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    // Check if the 'Price in Sync' was updated
    System.Assert(quoteAfter.Vistex_Price_In_Sync__c);

    // Check there is a new quote line (add-on)
    System.AssertEquals(quoteBefore.SBQQ__LineItems__r.size() + 1, quoteAfter.SBQQ__LineItems__r.size());

    SBQQ__QuoteLine__c addon;
    SBQQ__QuoteLine__c originalLine;

    for (SBQQ__QuoteLine__c quoteLine : quoteAfter.SBQQ__LineItems__r) {
      if (quoteLine.Vistex_Automatic_Add_on__c) {
        addon = quoteLine;
      } else {
        originalLine = quoteLine;
      }
    }

    // Check original line
    System.Assert(originalLine != null);
    System.AssertEquals(false, originalLine.Vistex_Automatic_Add_on__c);
    System.AssertEquals(252.324, originalLine.Contract_Price__c);

    // Check addon line
    System.Assert(addon != null);
    System.AssertEquals(true, addon.Vistex_Automatic_Add_on__c);
    System.AssertEquals(100, addon.Deal_Discount__c);
    System.AssertEquals(0, addon.Contract_Price__c);
    System.AssertEquals('S1', addon.Deal_Line_Group__c);
  }

  @istest
  public static void getVistexPriceFromLightning_EmptyResponse() {
    // Configure mock service to get an empty response
    VistexPricingServiceMock vistexServiceMock = new VistexPricingServiceMock(200, 'Success', EMPTY_RESPONSE, new Map<String, String>());
    Test.setMock(HttpCalloutMock.class, vistexServiceMock);

    // Get the quote created on set-up
    SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

    Boolean exceptionCaptured = false;
    GetVistexPriceController.PricingCallResponse result;

    Test.startTest();

    try {
      // Try to get Vistex price
      result = GetVistexPriceController.getVistexPriceFromLightning(quote.Id, false);
    } catch (Exception ex) {
      exceptionCaptured = true;
    }

    Test.stopTest();

    // Check was not thrown and captured in the code
    System.Assert(!exceptionCaptured);

    System.AssertEquals('Error', result.Status);
    System.AssertNotEquals('', result.Message);
  }

  @istest
  public static void getVistexPriceFromLightning_ServerError() {
    // Configure mock service to get an empty response
    VistexPricingServiceMock vistexServiceMock = new VistexPricingServiceMock(
      500,
      'Internal Server Error',
      EMPTY_RESPONSE,
      new Map<String, String>()
    );
    Test.setMock(HttpCalloutMock.class, vistexServiceMock);

    Boolean exceptionCaptured = false;

    // Get the quote created on set-up
    SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

    GetVistexPriceController.PricingCallResponse result;

    Test.startTest();

    try {
      // Try to get Vistex price
      result = GetVistexPriceController.getVistexPriceFromLightning(quote.Id, false);
    } catch (Exception ex) {
      exceptionCaptured = true;
    }

    Test.stopTest();

    // Check was not thrown and captured in the code
    System.Assert(!exceptionCaptured);

    System.AssertEquals('Error', result.Status);
    System.AssertNotEquals('', result.Message);
  }

  @istest
  public static void getVistexPriceFromLightning_WithManualAddOns() {
    // Configure mock service to get an empty response
    VistexPricingServiceMock vistexServiceMock = new VistexPricingServiceMock(
      200,
      'Success',
      SUCCESS_RESPONSE_WITH_MANUAL_ADDONS,
      new Map<String, String>()
    );
    Test.setMock(HttpCalloutMock.class, vistexServiceMock);

    // Get the quote created on set-up
    SBQQ__Quote__c quoteBefore = [SELECT Id, (SELECT Id FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c LIMIT 1];

    Test.startTest();

    // Try to get Vistex Price
    GetVistexPriceController.PricingCallResponse result = GetVistexPriceController.getVistexPriceFromLightning(quoteBefore.Id, false);

    Test.stopTest();

    // Check the result object
    System.AssertEquals('OK', result.Status);
    System.AssertEquals(0, result.AutomaticAddons.size());
    System.AssertEquals(2, result.ManualAddons.size());

    // Check the Manual Addons in the response are correct
    GetVistexPriceController.AddonInfo manualAddon1 = result.ManualAddons[0];
    System.assertEquals('000000000060000043', manualAddon1.MaterialNumber);
    System.assertEquals('2 Year Extended Warranty', manualAddon1.MaterialName);
    System.assertEquals(0.0, manualAddon1.NetPrice);
    System.assertEquals(1.0, manualAddon1.Quantity);
    System.assertEquals('S1', manualAddon1.DealSuffix);

    GetVistexPriceController.AddonInfo manualAddon2 = result.ManualAddons[1];
    System.assertEquals('000000000060000041', manualAddon2.MaterialNumber);
    System.assertEquals('HM5 - Standard Warranty', manualAddon2.MaterialName);
    System.assertEquals(0.0, manualAddon2.NetPrice);
    System.assertEquals(1.0, manualAddon2.Quantity);
    System.assertEquals('S2', manualAddon2.DealSuffix);

    // Get the quote updated
    SBQQ__Quote__c quoteAfter = [
      SELECT
        Id,
        Vistex_Price_In_Sync__c,
        (SELECT Id, Vistex_Automatic_Add_on__c, Deal_Discount__c, Contract_Price__c FROM SBQQ__LineItems__r)
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    // Check no new quote lines were added since no automatic addons were received
    System.AssertEquals(quoteBefore.SBQQ__LineItems__r.size(), quoteAfter.SBQQ__LineItems__r.size());
  }

  @istest
  public static void addManualAddonsToQuote_NoneAddonsSelected() {
    // Configure mock service to get an empty response
    VistexPricingServiceMock vistexServiceMock = new VistexPricingServiceMock(
      200,
      'Success',
      SUCCESS_RESPONSE_WITH_MANUAL_ADDONS,
      new Map<String, String>()
    );
    Test.setMock(HttpCalloutMock.class, vistexServiceMock);

    // Get the quote created on set-up
    SBQQ__Quote__c quoteBefore = [SELECT Id, (SELECT Id FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c LIMIT 1];

    Test.startTest();

    // Try to get Vistex Price
    GetVistexPriceController.PricingCallResponse result = GetVistexPriceController.getVistexPriceFromLightning(quoteBefore.Id, false);

    Test.stopTest();

    // Check the result object
    System.AssertEquals('OK', result.Status);
    System.AssertEquals(0, result.AutomaticAddons.size());
    System.AssertEquals(2, result.ManualAddons.size());

    // Check the Manual Addons in the response are correct
    GetVistexPriceController.AddonInfo manualAddon1 = result.ManualAddons[0];
    System.assertEquals('000000000060000043', manualAddon1.MaterialNumber);
    System.assertEquals('2 Year Extended Warranty', manualAddon1.MaterialName);
    System.assertEquals(0.0, manualAddon1.NetPrice);
    System.assertEquals(1.0, manualAddon1.Quantity);
    System.assertEquals('S1', manualAddon1.DealSuffix);

    GetVistexPriceController.AddonInfo manualAddon2 = result.ManualAddons[1];
    System.assertEquals('000000000060000041', manualAddon2.MaterialNumber);
    System.assertEquals('HM5 - Standard Warranty', manualAddon2.MaterialName);
    System.assertEquals(0.0, manualAddon2.NetPrice);
    System.assertEquals(1.0, manualAddon2.Quantity);
    System.assertEquals('S2', manualAddon2.DealSuffix);

    // Nothing selected
    String manualAddonCallResult = GetVistexPriceController.addManualAddonsToQuote(
      quoteBefore.Id,
      new List<GetVistexPriceController.AddonInfo>(),
      new List<GetVistexPriceController.ShipToQuantity>(),
      new List<GetVistexPriceController.ApprovalInfo>()
    );
    System.assertEquals('', manualAddonCallResult);

    // Get the quote updated
    SBQQ__Quote__c quoteAfter = [
      SELECT
        Id,
        Vistex_Price_In_Sync__c,
        (SELECT Id, Vistex_Automatic_Add_on__c, Deal_Discount__c, Contract_Price__c FROM SBQQ__LineItems__r)
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    // Check if the 'Price in Sync'
    // System.Assert(quoteAfter.Vistex_Price_In_Sync__c);

    // Check no new quote lines were added
    System.AssertEquals(quoteBefore.SBQQ__LineItems__r.size(), quoteAfter.SBQQ__LineItems__r.size());
  }

  @istest
  public static void addManualAddonsToQuote_OneSelected() {
    // Configure mock service to get an empty response
    VistexPricingServiceMock vistexServiceMock = new VistexPricingServiceMock(
      200,
      'Success',
      SUCCESS_RESPONSE_WITH_MANUAL_ADDONS,
      new Map<String, String>()
    );
    Test.setMock(HttpCalloutMock.class, vistexServiceMock);

    // Get the quote created on set-up
    SBQQ__Quote__c quoteBefore = [SELECT Id, (SELECT Id FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c LIMIT 1];

    Test.startTest();

    // Try to get Vistex Price
    GetVistexPriceController.PricingCallResponse result = GetVistexPriceController.getVistexPriceFromLightning(quoteBefore.Id, false);

    Test.stopTest();

    // Check the result object
    System.AssertEquals('OK', result.Status);
    System.AssertEquals(0, result.AutomaticAddons.size());
    System.AssertEquals(2, result.ManualAddons.size());

    // Check the Manual Addons in the response are correct
    GetVistexPriceController.AddonInfo manualAddon1 = result.ManualAddons[0];
    System.assertEquals('000000000060000043', manualAddon1.MaterialNumber);
    System.assertEquals('2 Year Extended Warranty', manualAddon1.MaterialName);
    System.assertEquals(0.0, manualAddon1.NetPrice);
    System.assertEquals(1.0, manualAddon1.Quantity);
    System.assertEquals('S1', manualAddon1.DealSuffix);

    GetVistexPriceController.AddonInfo manualAddon2 = result.ManualAddons[1];
    System.assertEquals('000000000060000041', manualAddon2.MaterialNumber);
    System.assertEquals('HM5 - Standard Warranty', manualAddon2.MaterialName);
    System.assertEquals(0.0, manualAddon2.NetPrice);
    System.assertEquals(1.0, manualAddon2.Quantity);
    System.assertEquals('S2', manualAddon2.DealSuffix);

    // Create a list with selected addons, and select the first one.
    List<GetVistexPriceController.AddonInfo> selectedAddons = new List<GetVistexPriceController.AddonInfo>();
    selectedAddons.add(result.ManualAddons[0]);

    // Nothing selected
    String manualAddonCallResult = GetVistexPriceController.addManualAddonsToQuote(
      quoteBefore.Id,
      selectedAddons,
      new List<GetVistexPriceController.ShipToQuantity>(),
      new List<GetVistexPriceController.ApprovalInfo>()
    );
    System.assertEquals('', manualAddonCallResult);

    // Get the quote updated
    SBQQ__Quote__c quoteAfter = [
      SELECT
        Id,
        Vistex_Price_In_Sync__c,
        (
          SELECT
            Id,
            Vistex_Manual_Add_on__c,
            Deal_Discount__c,
            Contract_Price__c,
            SBQQ__PartnerDiscount__c,
            SBQQ__Product__r.SAP_Material__r.SAP_Product_Number__c,
            SBQQ__Quantity__c,
            Deal_Line_Group__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    // Check no new quote lines were added
    System.AssertEquals(quoteBefore.SBQQ__LineItems__r.size() + 1, quoteAfter.SBQQ__LineItems__r.size());

    Boolean manualAddonFound = false;

    for (SBQQ__QuoteLine__c ql : quoteAfter.SBQQ__LineItems__r) {
      if (ql.Vistex_Manual_Add_on__c) {
        manualAddonFound = true;
        System.AssertEquals('000000000060000043', ql.SBQQ__Product__r.SAP_Material__r.SAP_Product_Number__c);
        //System.AssertEquals(0.0, ql.Contract_Price__c);
        //System.AssertEquals(100, ql.Deal_Discount__c);
        //System.AssertEquals(100, ql.SBQQ__PartnerDiscount__c);
        System.AssertEquals(1, ql.SBQQ__Quantity__c);
        System.AssertEquals('S1', ql.Deal_Line_Group__c);
        break;
      }
    }

    // Make sure the manual addon was found in the quote lines
    System.assert(manualAddonFound);
  }

  @istest
  public static void addManualAddonsToQuote_UnselectAlreadyAddedManualAddon() {
    // Get the quote created on set-up
    SBQQ__Quote__c quoteBefore = [SELECT Id, (SELECT Id FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c LIMIT 1];

    // Simulate manual addons result
    GetVistexPriceController.PricingCallResponse result = new GetVistexPriceController.PricingCallResponse();

    GetVistexPriceController.AddonInfo addonInfo1 = new GetVistexPriceController.AddonInfo();
    addonInfo1.Id = 1;
    addonInfo1.MaterialNumber = '000000000060000043';
    addonInfo1.MaterialName = '2 Year Extended Warranty';
    addonInfo1.NetPrice = 0.0;
    addonInfo1.Quantity = 1.0;
    addonInfo1.DealSuffix = 'S1';
    result.ManualAddons.add(addonInfo1);

    GetVistexPriceController.AddonInfo addonInfo2 = new GetVistexPriceController.AddonInfo();
    addonInfo2.Id = 2;
    addonInfo2.MaterialNumber = '000000000060000041';
    addonInfo2.MaterialName = 'HM5 - Standard Warranty';
    addonInfo2.NetPrice = 0.0;
    addonInfo2.Quantity = 1.0;
    addonInfo2.DealSuffix = 'S2';
    result.ManualAddons.add(addonInfo2);

    // Create a list with selected addons, and select the first one.
    List<GetVistexPriceController.AddonInfo> selectedAddons = new List<GetVistexPriceController.AddonInfo>();
    selectedAddons.add(result.ManualAddons[0]);

    // Nothing selected
    String manualAddonCallResult = GetVistexPriceController.addManualAddonsToQuote(
      quoteBefore.Id,
      selectedAddons,
      new List<GetVistexPriceController.ShipToQuantity>(),
      new List<GetVistexPriceController.ApprovalInfo>()
    );
    System.assertEquals('', manualAddonCallResult);

    // Get the quote updated
    SBQQ__Quote__c quoteAfter = [
      SELECT
        Id,
        Vistex_Price_In_Sync__c,
        (
          SELECT
            Id,
            Vistex_Manual_Add_on__c,
            Deal_Discount__c,
            Contract_Price__c,
            SBQQ__PartnerDiscount__c,
            SBQQ__Product__r.SAP_Material__r.SAP_Product_Number__c,
            SBQQ__Quantity__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    // Check if the 'Price in Sync'
    //System.Assert(quoteAfter.Vistex_Price_In_Sync__c);

    // Check a new quote lines was added
    System.AssertEquals(quoteBefore.SBQQ__LineItems__r.size() + 1, quoteAfter.SBQQ__LineItems__r.size());

    Boolean manualAddonFound = false;

    for (SBQQ__QuoteLine__c ql : quoteAfter.SBQQ__LineItems__r) {
      if (ql.Vistex_Manual_Add_on__c) {
        manualAddonFound = true;
        System.AssertEquals('000000000060000043', ql.SBQQ__Product__r.SAP_Material__r.SAP_Product_Number__c);
        //System.AssertEquals(100, ql.Deal_Discount__c);
        //System.AssertEquals(100, ql.SBQQ__PartnerDiscount__c);
        System.AssertEquals(1, ql.SBQQ__Quantity__c);
        break;
      }
    }

    // Make sure the manual addon was found in the quote lines
    System.assert(manualAddonFound);

    Test.startTest();
    /*** UNSELECT PREVIOUSLY ADDED MANUAL ADDON ***/
    String manualAddonCallResult2 = GetVistexPriceController.addManualAddonsToQuote(
      quoteBefore.Id,
      new List<GetVistexPriceController.AddonInfo>(),
      new List<GetVistexPriceController.ShipToQuantity>(),
      new List<GetVistexPriceController.ApprovalInfo>()
    );
    System.assertEquals('', manualAddonCallResult2);
    Test.stopTest();

    // Get the quote updated
    SBQQ__Quote__c quoteAfterUnselect = [
      SELECT
        Id,
        Vistex_Price_In_Sync__c,
        (
          SELECT
            Id,
            Vistex_Manual_Add_on__c,
            Deal_Discount__c,
            Contract_Price__c,
            SBQQ__PartnerDiscount__c,
            SBQQ__Product__r.SAP_Material__r.SAP_Product_Number__c,
            SBQQ__Quantity__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    // Check if the 'Price in Sync'
    //System.Assert(quoteAfter.Vistex_Price_In_Sync__c);

    // Check a quote line was removed
    System.AssertEquals(quoteAfter.SBQQ__LineItems__r.size() - 1, quoteAfterUnselect.SBQQ__LineItems__r.size());

    manualAddonFound = false;

    for (SBQQ__QuoteLine__c ql : quoteAfterUnselect.SBQQ__LineItems__r) {
      if (ql.Vistex_Manual_Add_on__c) {
        manualAddonFound = true;
      }
    }

    // Make sure the manual addon was NOT found in the quote lines
    System.assert(!manualAddonFound);
  }

  @istest
  public static void getVistexPriceFromLightning_VistexHandledError() {
    // Configure mock service to get an empty response
    VistexPricingServiceMock vistexServiceMock = new VistexPricingServiceMock(200, 'Success', ERROR_RESPONSE, new Map<String, String>());
    Test.setMock(HttpCalloutMock.class, vistexServiceMock);

    // Get the quote created on set-up
    SBQQ__Quote__c quoteBefore = [SELECT Id, (SELECT Id FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c LIMIT 1];

    Test.startTest();

    // Try to get Vistex Price
    GetVistexPriceController.PricingCallResponse result = GetVistexPriceController.getVistexPriceFromLightning(quoteBefore.Id, false);

    Test.stopTest();

    // Check the result object
    System.AssertEquals('Error', result.Status);
    System.AssertEquals(false, String.isBlank(result.Message));
    System.AssertEquals(false, String.isBlank(result.AdditionalErrorInfo));
    System.AssertEquals(0, result.AutomaticAddons.size());
    System.AssertEquals(0, result.ManualAddons.size());

    // Check an Error Log record was created
    List<Error_Log__c> errorList = [SELECT Id FROM Error_Log__c];
    System.assertEquals(1, errorList.size());
  }

  @istest
  public static void getShipToConfiguration_test() {
    // Get the quote created on set-up
    SBQQ__Quote__c quote = [SELECT Id, Ship_To_Address__c FROM SBQQ__Quote__c LIMIT 1];

    // Get the ship-to configurations
    List<Ship_to_Configuration__c> shipToConfigurationList = GetVistexPriceController.getShipToConfiguration(quote.Id);

    // We should get the default ship-to configuration created when the quote is created
    System.assertEquals(1, shipToConfigurationList.size());
  }

  @istest
  public static void addManualAddonsToQuote_WithShipToInformation() {
    // Configure mock service to get an empty response
    VistexPricingServiceMock vistexServiceMock = new VistexPricingServiceMock(
      200,
      'Success',
      SUCCESS_RESPONSE_WITH_MANUAL_ADDONS,
      new Map<String, String>()
    );
    Test.setMock(HttpCalloutMock.class, vistexServiceMock);

    // Get the quote created on set-up
    SBQQ__Quote__c quoteBefore = [
      SELECT Id, (SELECT Id, Ship_to_Address__c FROM Ship_to_Configurations__r), (SELECT Id FROM SBQQ__LineItems__r)
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    // Get the default ship-to configuration
    Ship_to_Configuration__c shipToConfig = quoteBefore.Ship_to_Configurations__r[0];

    Test.startTest();

    // Try to get Vistex Price
    GetVistexPriceController.PricingCallResponse result = GetVistexPriceController.getVistexPriceFromLightning(quoteBefore.Id, false);

    Test.stopTest();

    // Check the result object
    System.AssertEquals('OK', result.Status);
    System.AssertEquals(0, result.AutomaticAddons.size());
    System.AssertEquals(2, result.ManualAddons.size());

    // Check the Manual Addons in the response are correct
    GetVistexPriceController.AddonInfo manualAddon1 = result.ManualAddons[0];
    System.assertEquals('000000000060000043', manualAddon1.MaterialNumber);
    System.assertEquals('2 Year Extended Warranty', manualAddon1.MaterialName);
    System.assertEquals(0.0, manualAddon1.NetPrice);
    System.assertEquals(1.0, manualAddon1.Quantity);
    System.assertEquals('S1', manualAddon1.DealSuffix);

    GetVistexPriceController.AddonInfo manualAddon2 = result.ManualAddons[1];
    System.assertEquals('000000000060000041', manualAddon2.MaterialNumber);
    System.assertEquals('HM5 - Standard Warranty', manualAddon2.MaterialName);
    System.assertEquals(0.0, manualAddon2.NetPrice);
    System.assertEquals(1.0, manualAddon2.Quantity);
    System.assertEquals('S2', manualAddon2.DealSuffix);

    GetVistexPriceController.ShipToQuantity shipToQuantity = new GetVistexPriceController.ShipToQuantity();
    shipToQuantity.ShipToId = shipToConfig.Id;
    shipToQuantity.Quantity = 1;
    shipToQuantity.AddonKey = manualAddon1.Key;

    // Create a list with selected addons, and select the first one.
    List<GetVistexPriceController.AddonInfo> selectedAddons = new List<GetVistexPriceController.AddonInfo>();
    selectedAddons.add(result.ManualAddons[0]);

    // Nothing selected
    String manualAddonCallResult = GetVistexPriceController.addManualAddonsToQuote(
      quoteBefore.Id,
      selectedAddons,
      new List<GetVistexPriceController.ShipToQuantity>{ shipToQuantity },
      new List<GetVistexPriceController.ApprovalInfo>()
    );
    System.assertEquals('', manualAddonCallResult);

    // Get the quote updated
    SBQQ__Quote__c quoteAfter = [
      SELECT
        Id,
        Vistex_Price_In_Sync__c,
        (
          SELECT
            Id,
            Vistex_Manual_Add_on__c,
            Deal_Discount__c,
            Contract_Price__c,
            SBQQ__PartnerDiscount__c,
            SBQQ__Product__r.SAP_Material__r.SAP_Product_Number__c,
            SBQQ__Quantity__c,
            Deal_Line_Group__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    // Check no new quote lines were added
    System.AssertEquals(quoteBefore.SBQQ__LineItems__r.size() + 1, quoteAfter.SBQQ__LineItems__r.size());

    Boolean manualAddonFound = false;

    for (SBQQ__QuoteLine__c ql : quoteAfter.SBQQ__LineItems__r) {
      if (ql.Vistex_Manual_Add_on__c) {
        manualAddonFound = true;
        System.AssertEquals('000000000060000043', ql.SBQQ__Product__r.SAP_Material__r.SAP_Product_Number__c);
        System.AssertEquals(1, ql.SBQQ__Quantity__c);
        System.AssertEquals('S1', ql.Deal_Line_Group__c);
        break;
      }
    }

    // Make sure the manual addon was found in the quote lines
    System.assert(manualAddonFound);
  }

  @istest
  public static void RxDxAddonsResponse() {
    // Configure mock service to get an empty response
    VistexPricingServiceMock vistexServiceMock = new VistexPricingServiceMock(
      200,
      'Success',
      SUCCESS_RESPONSE_WITH_RXDX_ADDONS,
      new Map<String, String>()
    );
    Test.setMock(HttpCalloutMock.class, vistexServiceMock);

    // Get the quote created on set-up
    SBQQ__Quote__c quoteBefore = [SELECT Id, (SELECT Id FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c LIMIT 1];

    Test.startTest();

    // Try to get Vistex Price
    GetVistexPriceController.PricingCallResponse result = GetVistexPriceController.getVistexPriceFromLightning(quoteBefore.Id, false);

    Test.stopTest();

    // Check the result object
    System.AssertEquals('OK', result.Status);
    System.AssertEquals(0, result.AutomaticAddons.size());
    System.AssertEquals(0, result.ManualAddons.size());
    System.AssertEquals(0, result.DiscountedAddonGroups.size());
    System.AssertEquals(1, result.RxDxConsumables.size());

    GetVistexPriceController.AddonGroup rxdxAddonGroup = result.RxDxConsumables[0];
    System.AssertEquals(100, rxdxAddonGroup.MaxValue);
    System.AssertEquals('0000001287', rxdxAddonGroup.GroupId);
    System.AssertEquals(2, rxdxAddonGroup.RelatedAddons.size());

    // Check the Manual Addons in the response are correct
    GetVistexPriceController.AddonInfo manualAddon1 = rxdxAddonGroup.RelatedAddons[0];
    System.assertEquals('000000000010001498', manualAddon1.MaterialNumber);
    System.assertEquals('S1', manualAddon1.DealSuffix);
    System.AssertEquals('3000000058', manualAddon1.DealNumber);
    System.AssertEquals('0000001287', manualAddon1.GroupId);

    GetVistexPriceController.AddonInfo manualAddon2 = rxdxAddonGroup.RelatedAddons[1];
    System.assertEquals('000000000060000043', manualAddon2.MaterialNumber);
    System.assertEquals('S1', manualAddon2.DealSuffix);
    System.AssertEquals('3000000058', manualAddon2.DealNumber);
    System.AssertEquals('0000001287', manualAddon2.GroupId);
  }

  @istest
  public static void RxDxAddonsResponse_WithApprovals() {

    SBQQ.TriggerControl.disable();
    QuoteLineTriggerHandler.disableShipToOverrideUpdate();
    QuoteTriggerHandler.disablePriceInSyncCalculation();
    QuoteTriggerHandler.disableUpdatesOnShipTo();    

    // Configure mock service to get an empty response
    VistexPricingServiceMock vistexServiceMock = new VistexPricingServiceMock(
      200,
      'Success',
      SUCCESS_RESPONSE_WITH_RXDX_ADDONS,
      new Map<String, String>()
    );
    Test.setMock(HttpCalloutMock.class, vistexServiceMock);

    // Get the quote created on set-up
    SBQQ__Quote__c quoteBefore = [
      SELECT Id, (SELECT Id, Ship_to_Address__c FROM Ship_to_Configurations__r), (SELECT Id FROM SBQQ__LineItems__r)
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    // Get the default ship-to configuration
    Ship_to_Configuration__c shipToConfig = quoteBefore.Ship_to_Configurations__r[0];

    Test.startTest();    

    // Try to get Vistex Price
    GetVistexPriceController.PricingCallResponse result = GetVistexPriceController.getVistexPriceFromLightning(quoteBefore.Id, false);    

    Test.stopTest();

    // Check the result object
    System.AssertEquals('OK', result.Status);
    System.AssertEquals(0, result.AutomaticAddons.size());
    System.AssertEquals(0, result.ManualAddons.size());
    System.AssertEquals(0, result.DiscountedAddonGroups.size());
    System.AssertEquals(1, result.RxDxConsumables.size());

    GetVistexPriceController.AddonGroup rxdxAddonGroup = result.RxDxConsumables[0];
    System.AssertEquals(100, rxdxAddonGroup.MaxValue);
    System.AssertEquals('0000001287', rxdxAddonGroup.GroupId);
    System.AssertEquals(2, rxdxAddonGroup.RelatedAddons.size());

    // Check the Manual Addons in the response are correct
    GetVistexPriceController.AddonInfo manualAddon1 = rxdxAddonGroup.RelatedAddons[0];
    System.assertEquals('000000000010001498', manualAddon1.MaterialNumber);
    System.assertEquals('S1', manualAddon1.DealSuffix);
    System.AssertEquals('3000000058', manualAddon1.DealNumber);
    System.AssertEquals('0000001287', manualAddon1.GroupId);

    GetVistexPriceController.AddonInfo manualAddon2 = rxdxAddonGroup.RelatedAddons[1];
    System.assertEquals('000000000060000043', manualAddon2.MaterialNumber);
    System.assertEquals('S1', manualAddon2.DealSuffix);
    System.AssertEquals('3000000058', manualAddon2.DealNumber);
    System.AssertEquals('0000001287', manualAddon2.GroupId);

    // Create a list with selected addons, and select the first one.
    List<GetVistexPriceController.AddonInfo> selectedAddons = new List<GetVistexPriceController.AddonInfo>();
    manualAddon1.Quantity = 12;
    selectedAddons.add(manualAddon1);

    GetVistexPriceController.ApprovalInfo approvalInfo = new GetVistexPriceController.ApprovalInfo();
    approvalInfo.ApprovalRequired = true;
    approvalInfo.MaxValue = 100;
    approvalInfo.CurrValue = 120;
    approvalInfo.Suffix = 'S1';

    GetVistexPriceController.ShipToQuantity shipToQuantity = new GetVistexPriceController.ShipToQuantity();
    shipToQuantity.ShipToId = shipToConfig.Id;
    shipToQuantity.Quantity = 12;
    shipToQuantity.AddonKey = manualAddon1.Key;

    // Nothing selected
    String manualAddonCallResult = GetVistexPriceController.addManualAddonsToQuote(
      quoteBefore.Id,
      selectedAddons,
      new List<GetVistexPriceController.ShipToQuantity>{ shipToQuantity },
      new List<GetVistexPriceController.ApprovalInfo>{ approvalInfo }
    );
    System.assertEquals('', manualAddonCallResult);

    // Get the quote updated
    SBQQ__Quote__c quoteAfter = [
      SELECT
        Id,
        Vistex_Price_In_Sync__c,
        Rx_Dx_Approval_Text__c,
        (
          SELECT
            Id,
            Vistex_Manual_Add_on__c,
            Deal_Discount__c,
            Contract_Price__c,
            SBQQ__PartnerDiscount__c,
            SBQQ__Product__r.SAP_Material__r.SAP_Product_Number__c,
            SBQQ__Quantity__c,
            Deal_Line_Group__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      LIMIT 1
    ];

    SBQQ.TriggerControl.enable();
    QuoteLineTriggerHandler.enableShipToOverrideUpdate();
    QuoteTriggerHandler.enablePriceInSyncCalculation();
    QuoteTriggerHandler.enableUpdatesOnShipTo();

    // The Approval text is populated
    /*System.Assert(String.isNotBlank(quoteAfter.Rx_Dx_Approval_Text__c));

    // Check no new quote lines were added
    System.AssertEquals(quoteBefore.SBQQ__LineItems__r.size() + 1, quoteAfter.SBQQ__LineItems__r.size());

    Boolean manualAddonFound = false;

    for (SBQQ__QuoteLine__c ql : quoteAfter.SBQQ__LineItems__r) {
      if (ql.Vistex_Manual_Add_on__c) {
        manualAddonFound = true;
        System.AssertEquals('000000000060000043', ql.SBQQ__Product__r.SAP_Material__r.SAP_Product_Number__c);
        System.AssertEquals(12, ql.SBQQ__Quantity__c);
        System.AssertEquals('S1', ql.Deal_Line_Group__c);
        break;
      }
    }

    // Make sure the manual addon was found in the quote lines
    System.assert(manualAddonFound);*/
  }
}