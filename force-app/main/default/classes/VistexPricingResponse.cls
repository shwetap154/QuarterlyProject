/**
* File Name     :  VistexPricingResponse
* @description  :  Data definition for the vistex pricing response that is parsed and sets the price for CPQ quote lines
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/28/2019 	Cesar Sandrigo @ ATG     Created the Class.
* 2.0     2/6/2020		Cory Bartholomew @ ATG   Added descriptions.
* 3.0     4/12/2023		Mila Imas (formating changes)
* 4.0     9/18/2023		Mila Imas (formating changes)

**/
public class VistexPricingResponse {
	
	public class ET_ITEM_DEALS {
		public List<DealItem> ITEM {get;set;} 

		public ET_ITEM_DEALS(JSONParser parser) {

			/* HACK: This is to support SAP empty array which is serialized as and empty string */
			if (parser.getCurrentToken() == System.JSONToken.VALUE_STRING) {
				ITEM = new List<DealItem>();
			}
			else {
				while (parser.nextToken() != System.JSONToken.END_OBJECT) {
					if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
						String text = parser.getText();
						if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
							if (text == 'ITEM') {
								ITEM = arrayOfDealItem(parser);
							} else {
								System.debug(LoggingLevel.WARN, 'ET_ITEM_DEALS consuming unrecognized property: '+text);
								consumeObject(parser);
							}
						}
					}
				}
			}
		}
	}
	
	public class ReturnItem {
		public String TYPE {get;set;} // in json: TYPE
		public String CODE {get;set;} 
		public String MESSAGE {get;set;} 
		public String LOG_NO {get;set;} 
		public String LOG_MSG_NO {get;set;} 
		public String MESSAGE_V1 {get;set;} 
		public String MESSAGE_V2 {get;set;} 
		public String MESSAGE_V3 {get;set;} 
		public String MESSAGE_V4 {get;set;} 

		public ReturnItem(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'TYPE') {
							TYPE = parser.getText();
						} else if (text == 'CODE') {
							CODE = parser.getText();
						} else if (text == 'MESSAGE') {
							MESSAGE = parser.getText();
						} else if (text == 'LOG_NO') {
							LOG_NO = parser.getText();
						} else if (text == 'LOG_MSG_NO') {
							LOG_MSG_NO = parser.getText();
						} else if (text == 'MESSAGE_V1') {
							MESSAGE_V1 = parser.getText();
						} else if (text == 'MESSAGE_V2') {
							MESSAGE_V2 = parser.getText();
						} else if (text == 'MESSAGE_V3') {
							MESSAGE_V3 = parser.getText();
						} else if (text == 'MESSAGE_V4') {
							MESSAGE_V4 = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Item consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public Result ES_RESULT {get;set;} 
	public ET_ADDONS ET_ADDONS {get;set;} 
	public String ET_DEAL_LOG {get;set;} 
	public String ET_HEADER_BENEFITS {get;set;} 
	public ET_ITEM_DEALS ET_ITEM_DEALS {get;set;} 
	public ET_RETURN ET_RETURN {get;set;} 

	public VistexPricingResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'ES_RESULT') {
						ES_RESULT = new Result(parser);
					} else if (text == 'ET_ADDONS') {
						ET_ADDONS = new ET_ADDONS(parser);
					} else if (text == 'ET_DEAL_LOG') {
						ET_DEAL_LOG = parser.getText();
					} else if (text == 'ET_HEADER_BENEFITS') {
						ET_HEADER_BENEFITS = parser.getText();
					} else if (text == 'ET_ITEM_DEALS') {
						ET_ITEM_DEALS = new ET_ITEM_DEALS(parser);
					} else if (text == 'ET_RETURN') {
						ET_RETURN = new ET_RETURN(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'VistexPricingResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class ET_RETURN {

		public List<ReturnItem> items { get; set; } 

		public ET_RETURN(JSONParser parser) {
            
            /* HACK: This is to support SAP empty array which is serialized as and empty string */
			if (parser.getCurrentToken() == System.JSONToken.VALUE_STRING) {
				items = new List<ReturnItem>();
			}
			else {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'item') {
                                items = arrayOfReturnItems(parser);
                            } else {
                                System.debug(LoggingLevel.WARN, 'ET_RETURN consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
		}
	}

	public class DealItem {
		public String COND_REC_NO {get;set;} 
		public String ITEM {get;set;} 
		public Long DEAL {get;set;} 
		public String DEAL_SUFFIX {get;set;} 
		public String COND_TYPE {get;set;} 
		public String COND_VAL {get;set;} 
		public Integer COND_VAL_OLD {get;set;} 
		public String PRIORITY {get;set;} 
		public String COMPATABLITY_MODE {get;set;} 
		public String COND_INACTIVE {get;set;} 
		public Integer RATE {get;set;} 
		public Integer COND_VAL_NET {get;set;} 
		public String MATERIAL {get;set;} 
		public Integer CUM_ORD_QUAN {get;set;} 
		public Integer CUM_ORD_QUAN_EL {get;set;} 
		public Integer CUM_ORD_QUAN_EX {get;set;} 
		public String BASE_UOM {get;set;} 
		public String CURRENCY_KEY {get;set;} 
		public String ON_DEMAND {get;set;} 
		public String ADDON {get;set;} 
		public Integer DEAL_RESOLUTION {get;set;} 

		public DealItem(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'COND_REC_NO') {
							COND_REC_NO = parser.getText();
						} else if (text == 'ITEM') {
							ITEM = parser.getText();
						} else if (text == 'DEAL') {
							DEAL = parser.getLongValue();
						} else if (text == 'DEAL_SUFFIX') {
							DEAL_SUFFIX = parser.getText();
						} else if (text == 'COND_TYPE') {
							COND_TYPE = parser.getText();
						} else if (text == 'COND_VAL') {
							COND_VAL = parser.getText();
						} else if (text == 'COND_VAL_OLD') {
							COND_VAL_OLD = parser.getIntegerValue();
						} else if (text == 'PRIORITY') {
							PRIORITY = parser.getText();
						} else if (text == 'COMPATABLITY_MODE') {
							COMPATABLITY_MODE = parser.getText();
						} else if (text == 'COND_INACTIVE') {
							COND_INACTIVE = parser.getText();
						} else if (text == 'RATE') {
							RATE = parser.getIntegerValue();
						} else if (text == 'COND_VAL_NET') {
							COND_VAL_NET = parser.getIntegerValue();
						} else if (text == 'MATERIAL') {
							MATERIAL = parser.getText();
						} else if (text == 'CUM_ORD_QUAN') {
							CUM_ORD_QUAN = parser.getIntegerValue();
						} else if (text == 'CUM_ORD_QUAN_EL') {
							CUM_ORD_QUAN_EL = parser.getIntegerValue();
						} else if (text == 'CUM_ORD_QUAN_EX') {
							CUM_ORD_QUAN_EX = parser.getIntegerValue();
						} else if (text == 'BASE_UOM') {
							BASE_UOM = parser.getText();
						} else if (text == 'CURRENCY_KEY') {
							CURRENCY_KEY = parser.getText();
						} else if (text == 'ON_DEMAND') {
							ON_DEMAND = parser.getText();
						} else if (text == 'ADDON') {
							ADDON = parser.getText();
						} else if (text == 'DEAL_RESOLUTION') {
							DEAL_RESOLUTION = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'DealItem consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Result {
		public String SD_DOC_NO {get;set;} 
		public Integer CUST_NO {get;set;} 
		public String PRICING_PROC {get;set;} 
		public String DOC_CURRENCY {get;set;} 
		public Double NET_VALUE {get;set;} 
		public Double NET_PRICE {get;set;} 
		public Double SUB_TOT1 {get;set;} 
		public Double SUB_TOT2 {get;set;} 
		public Double SUB_TOT3 {get;set;} 
		public Double ORD_DISCOUNT_TOT {get;set;} 
		public Double ORD_TAXES {get;set;} 
		public Double ORD_TOT_PRICE {get;set;} 
		public ResultItemArray ITEM {get;set;} 

		public Result(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'SD_DOC_NO') {
							SD_DOC_NO = parser.getText();
						} else if (text == 'CUST_NO') {
							CUST_NO = parseIntegerOrEmptyString(parser);
						} else if (text == 'PRICING_PROC') {
							PRICING_PROC = parser.getText();
						} else if (text == 'DOC_CURRENCY') {
							DOC_CURRENCY = parser.getText();
						} else if (text == 'NET_VALUE') {
							/* HACK: For some reason when SAP PI serialize 
							 * this field sometimes as string or as a number */
							NET_VALUE = parseStringOrNumericField(parser);
						} else if (text == 'NET_PRICE') {
							/* HACK: For some reason when SAP PI serialize 
							 * this field sometimes as string or as a number */
							NET_PRICE = parseStringOrNumericField(parser);
						} else if (text == 'SUB_TOT1') {
							SUB_TOT1 = parseStringOrNumericField(parser);
						} else if (text == 'SUB_TOT2') {
							SUB_TOT2 = parseStringOrNumericField(parser);
						} else if (text == 'SUB_TOT3') {
							SUB_TOT3 = parseStringOrNumericField(parser);
						} else if (text == 'ORD_DISCOUNT_TOT') {
							/* HACK: For some reason when SAP PI serialize 
							 * this field sometimes as string or as a number */
							ORD_DISCOUNT_TOT = parseStringOrNumericField(parser);
						} else if (text == 'ORD_TAXES') {
							ORD_TAXES = parseStringOrNumericField(parser);
						} else if (text == 'ORD_TOT_PRICE') {
							ORD_TOT_PRICE = parseStringOrNumericField(parser);
						} else if (text == 'ITEM') {
							ITEM = new ResultItemArray(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'ES_RESULT consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ResultItem {
		public String COND_ITEM_NO {get;set;} 
		public String MATERIAL {get;set;} 
		public String SALES_UNIT {get;set;} 
		public String PRICE_OK {get;set;} 
		public String SD_ITEM_CATG {get;set;} 
		public String PLANT {get;set;} 
		public Integer COND_PRICE_UNIT {get;set;} 
		public String COND_UNIT {get;set;} 
		public String WEIGHT_UNIT {get;set;} 
		public String VOLUME_UNIT {get;set;} 
		public Double QUANTITY {get;set;} 
		public Double NET_PRICE {get;set;} 
		public Double NET_VALUE_DOC_CUR {get;set;} 
		public Double GROSS_VALUE_IN_DOC_CUR {get;set;} 
		public Double TAX_AMT_IN_DOC_CUR {get;set;} 
		public Double COND_SUBTOT {get;set;} 
		public Double ITEM_CONTRACT_PRICE {get;set;} 
		public Double ITEM_DISC_TOT_PRICE {get;set;} 
		public Double COND_SUBTOT4 {get;set;} 
		public Double COND_SUBTOT5 {get;set;} 
		public Double COND_SUBTOT6 {get;set;} 
		public Double RABATE_BASIS {get;set;} 
		public Double PREFERENCE_VALUE {get;set;} 
		public Double ITEM_CREDIT_PRICE {get;set;} 
		public Double COST_DOC_CURRENCY {get;set;} 
		public String ITEM_GROSS_WEIGHT {get;set;} 
		public String ITEM_NET_WEIGHT {get;set;} 
		public Double ITEM_VOLUME {get;set;} 
		public String ADDON {get;set;} 

		public ResultItem(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'COND_ITEM_NO') {
							COND_ITEM_NO = parser.getText();
						} else if (text == 'MATERIAL') {
							MATERIAL = parser.getText();
						} else if (text == 'SALES_UNIT') {
							SALES_UNIT = parser.getText();
						} else if (text == 'PRICE_OK') {
							PRICE_OK = parser.getText();
						} else if (text == 'SD_ITEM_CATG') {
							SD_ITEM_CATG = parser.getText();
						} else if (text == 'PLANT') {
							PLANT = parser.getText();
						} else if (text == 'COND_PRICE_UNIT') {
							COND_PRICE_UNIT = parser.getIntegerValue();
						} else if (text == 'COND_UNIT') {
							COND_UNIT = parser.getText();
						} else if (text == 'WEIGHT_UNIT') {
							WEIGHT_UNIT = parser.getText();
						} else if (text == 'VOLUME_UNIT') {
							VOLUME_UNIT = parser.getText();
						} else if (text == 'QUANTITY') {
							QUANTITY = parseStringOrNumericField(parser);
						} else if (text == 'NET_PRICE') {
							NET_PRICE = parseStringOrNumericField(parser);
						} else if (text == 'NET_VALUE_DOC_CUR') {
							NET_VALUE_DOC_CUR = parseStringOrNumericField(parser);
						} else if (text == 'GROSS_VALUE_IN_DOC_CUR') {
							GROSS_VALUE_IN_DOC_CUR = parseStringOrNumericField(parser);
						} else if (text == 'TAX_AMT_IN_DOC_CUR') {
							TAX_AMT_IN_DOC_CUR = parseStringOrNumericField(parser);
						} else if (text == 'COND_SUBTOT') {
							COND_SUBTOT = parseStringOrNumericField(parser);
						} else if (text == 'ITEM_CONTRACT_PRICE') {
							ITEM_CONTRACT_PRICE = parseStringOrNumericField(parser);
						} else if (text == 'ITEM_DISC_TOT_PRICE') {
							ITEM_DISC_TOT_PRICE =parseStringOrNumericField(parser);
						} else if (text == 'COND_SUBTOT4') {
							COND_SUBTOT4 = parseStringOrNumericField(parser);
						} else if (text == 'COND_SUBTOT5') {
							COND_SUBTOT5 = parseStringOrNumericField(parser);
						} else if (text == 'COND_SUBTOT6') {
							COND_SUBTOT6 = parseStringOrNumericField(parser);
						} else if (text == 'RABATE_BASIS') {
							RABATE_BASIS = parseStringOrNumericField(parser);
						} else if (text == 'PREFERENCE_VALUE') {
							//PREFERENCE_VALUE = parser.getIntegerValue();
							PREFERENCE_VALUE = parseStringOrNumericField(parser);
						} else if (text == 'ITEM_CREDIT_PRICE') {
                            ITEM_CREDIT_PRICE = parseStringOrNumericField(parser);
                            //ITEM_CREDIT_PRICE =  Double.valueOf( parseStringOrNumericField(parser));
							//ITEM_CREDIT_PRICE = parser.getDoubleValue();
						} else if (text == 'COST_DOC_CURRENCY') {
							//COST_DOC_CURRENCY = parser.getIntegerValue();
							COST_DOC_CURRENCY = parseStringOrNumericField(parser);
						} else if (text == 'ITEM_GROSS_WEIGHT') {
							ITEM_GROSS_WEIGHT = parser.getText();
						} else if (text == 'ITEM_NET_WEIGHT') {
							ITEM_NET_WEIGHT = parser.getText();
						} else if (text == 'ITEM_VOLUME') {
							ITEM_VOLUME = parseStringOrNumericField(parser);
						} else if (text == 'ADDON') {
							ADDON = parser.getText();
						} else if (text == 'COND') {
							// Just ignore it.
						} else {
							System.debug(LoggingLevel.WARN, 'ResultItem consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class AddonItem {
		public String DEAL {get;set;} 
		public String DEAL_SUFFIX {get;set;} 
		public String ITEMNO_SD_DOC {get;set;} 
		public String ADDON_STATUS {get;set;} 
		public String GROUP_Z {get;set;} // in json: GROUP
		public String MATERIAL {get;set;} 
		public String MATERIAL_DESC {get;set;} 
		public Integer CUM_ORD_QUANTITY {get;set;} 
		public Double ADDON_QUAN_SALES_UNIT {get;set;} 
		public String SALES_UNIT {get;set;} 
		public Integer MAX_ORD_QUANTITY {get;set;} 
		public String ADDON_ADD_PROP {get;set;} 
		public String ADDON_AUTO_APPLY {get;set;} 
		public String GROUP_REF {get;set;} 
		public String ADDON_GROUP {get;set;} 
		public String COND_REC_NO {get;set;} 
		public String CROSS_ORD_RESTRICTION {get;set;} 
		public String WORKGRP_TYPE {get;set;} 
		public String CHECKBOX {get;set;} 
		public String FLEXIBLE_GROUP {get;set;} 
		public String REVENUE_RECOG {get;set;} 
		public Double NET_PRICE {get;set;} 
		public String SD_DOC_CURRENCY {get;set;} 

		public AddonItem(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'DEAL') {
							DEAL = parser.getText();
						} else if (text == 'DEAL_SUFFIX') {
							DEAL_SUFFIX = parser.getText();
						} else if (text == 'ITEMNO_SD_DOC') {
							ITEMNO_SD_DOC = parser.getText();
						} else if (text == 'ADDON_STATUS') {
							ADDON_STATUS = parser.getText();
						} else if (text == 'GROUP') {
							GROUP_Z = parser.getText();
						} else if (text == 'MATERIAL') {
							MATERIAL = parser.getText();
						} else if (text == 'MATERIAL_DESC') {
							MATERIAL_DESC = parser.getText();
						} else if (text == 'CUM_ORD_QUANTITY') {
							CUM_ORD_QUANTITY = parseIntegerOrEmptyString(parser);
						} else if (text == 'ADDON_QUAN_SALES_UNIT') {
							ADDON_QUAN_SALES_UNIT = parseStringOrNumericField(parser);
						} else if (text == 'SALES_UNIT') {
							SALES_UNIT = parser.getText();
						} else if (text == 'MAX_ORD_QUANTITY') {
							MAX_ORD_QUANTITY = parseIntegerOrEmptyString(parser);
						} else if (text == 'ADDON_ADD_PROP') {
							ADDON_ADD_PROP = parser.getText();
						} else if (text == 'ADDON_AUTO_APPLY') {
							ADDON_AUTO_APPLY = parser.getText();
						} else if (text == 'GROUP_REF') {
							GROUP_REF = parser.getText();
						} else if (text == 'ADDON_GROUP') {
							ADDON_GROUP = parser.getText();
						} else if (text == 'COND_REC_NO') {
							COND_REC_NO = parser.getText();
						} else if (text == 'CROSS_ORD_RESTRICTION') {
							CROSS_ORD_RESTRICTION = parser.getText();
						} else if (text == 'WORKGRP_TYPE') {
							WORKGRP_TYPE = parser.getText();
						} else if (text == 'CHECKBOX') {
							CHECKBOX = parser.getText();
						} else if (text == 'FLEXIBLE_GROUP') {
							FLEXIBLE_GROUP = parser.getText();
						} else if (text == 'REVENUE_RECOG') {
							REVENUE_RECOG = parser.getText();
						} else if (text == 'NET_PRICE') {
							NET_PRICE = parseStringOrNumericField(parser);
						} else if (text == 'SD_DOC_CURRENCY') {
							SD_DOC_CURRENCY = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'AddonItem consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ET_ADDONS {
		public List<AddonItem> ITEM {get;set;} 

		public ET_ADDONS(JSONParser parser) {

			/* HACK: This is to support SAP empty array which is serialized as and empty string */
			if (parser.getCurrentToken() == System.JSONToken.VALUE_STRING) {
				ITEM = new List<AddonItem>();
			}
			else {
				while (parser.nextToken() != System.JSONToken.END_OBJECT) {
					if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
						String text = parser.getText();
						if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
							if (text == 'ITEM') {
								ITEM = arrayOfAddonItem(parser);
							} else {
								System.debug(LoggingLevel.WARN, 'ET_ADDONS consuming unrecognized property: '+text);
								consumeObject(parser);
							}
						}
					}
				}
			}
		}
	}
	
	public class ResultItemArray {
		public List<ResultItem> ITEM {get;set;} 

		public ResultItemArray(JSONParser parser) {

			String firstToken = parser.getText();

			System.debug('ResultItemArray > First token: ' + firstToken);

			// If it's an empty string, just return an empty list
			if (String.isBlank(firstToken)) {
				ITEM = new List<ResultItem>();
				return;
			}

			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'ITEM') {
							ITEM = arrayOfResultItem(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'ResultItemArray consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public static VistexPricingResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new VistexPricingResponse(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<ResultItem> arrayOfResultItem(System.JSONParser p) {

		List<ResultItem> res = new List<ResultItem>();

		System.JSONToken currentToken = p.getCurrentToken();
        if (currentToken == null) p.nextToken();

		if (currentToken == System.JSONToken.START_ARRAY) {
			while (p.nextToken() != System.JSONToken.END_ARRAY) {
				res.add(new ResultItem(p));
			}
		}
		else if (currentToken == System.JSONToken.START_OBJECT) {
			res.add(new ResultItem(p));
		}

        return res;
    }

	/**
	 *
	 */
	private static List<ReturnItem> arrayOfReturnItems(System.JSONParser p) {

		List<ReturnItem> res = new List<ReturnItem>();

		System.JSONToken currentToken = p.getCurrentToken();
        if (p.getCurrentToken() == null) p.nextToken();

		if (currentToken == System.JSONToken.START_ARRAY) {
			while (p.nextToken() != System.JSONToken.END_ARRAY) {
				res.add(new ReturnItem(p));
			}
		}
		else if (currentToken == System.JSONToken.START_OBJECT) {
			res.add(new ReturnItem(p));
		}

        return res;
    }

	/**
	 *
	 */
    private static List<DealItem> arrayOfDealItem(System.JSONParser p) {

		List<DealItem> res = new List<DealItem>();

		System.JSONToken currentToken = p.getCurrentToken();
        if (p.getCurrentToken() == null) p.nextToken();

		if (currentToken == System.JSONToken.START_ARRAY) {
			while (p.nextToken() != System.JSONToken.END_ARRAY) {
				res.add(new DealItem(p));
			}
		}
		else if (currentToken == System.JSONToken.START_OBJECT) {
			res.add(new DealItem(p));
		}

        return res;
    }

	/**
	 *
	 */
    private static List<AddonItem> arrayOfAddonItem(System.JSONParser p) {

		System.JSONToken currentToken = p.getCurrentToken();

		List<AddonItem> res = new List<AddonItem>();
        if (currentToken == null) p.nextToken();

		if (currentToken == System.JSONToken.START_ARRAY) {
			while (p.nextToken() != System.JSONToken.END_ARRAY) {
				res.add(new AddonItem(p));
			}
		}
		else if (currentToken == System.JSONToken.START_OBJECT) {
			res.add(new AddonItem(p));
		}

        return res;
	}

	/**
	 * @description Gets a Double value from the current JSON Token on the parser passed as parameter.
	 * @param parser The JSON parser object.
	 * @return Double value.
	 */
	private static Double parseStringOrNumericField(JSONParser parser) {

		Double parsedValue;

		try {
			parsedValue = parser.getDoubleValue();
			return parsedValue;
		}
		catch(System.JSONException ex) {}

		String stringValue = parser.getText();
		if (stringValue.isNumeric() || stringValue.indexOf('.') > -1) {
			try {
				parsedValue = Double.valueOf(stringValue);
			}
			catch (TypeException te) {
				System.debug(LoggingLevel.ERROR, 'VistexPricingResponse - parseStringOrNumericField. ERROR Parsing: ' + parser.getText());
			}
		}

		return parsedValue;
	}

	/**
	 * @description Gets an Integer value from the JSON Token passed as parameter. Returns 0 when string is empty.
	 * @param parser The JSON parser object.
	 * @return Integer value.
	 */
	private static Integer parseIntegerOrEmptyString(JSONParser parser) {
		return parseIntegerOrEmptyString(parser, true);
	}

	/**
	 * @description Gets an Integer value from the JSON Token passed as parameter. Returns 0 when string is empty.
	 * @param parser The JSON parser object.
	 * @param returnZeroWhenEmpty If it's true it will return 0 when value is an empty string, if false returns null.
	 * @return Integer value.
	 */
	private static Integer parseIntegerOrEmptyString(JSONParser parser, Boolean returnZeroWhenEmpty) {

		Integer parsedValue;

		try {
			parsedValue = parser.getIntegerValue();
			return parsedValue;
		}
		catch(System.JSONException ex) {}

		String stringValue = parser.getText();
		
		if (String.isBlank(stringValue)) {
			return returnZeroWhenEmpty ? 0 : null;
		}

		if (stringValue.isNumeric()) {
			try {
				parsedValue = Integer.valueOf(stringValue);
			}
			catch (TypeException te) {
				System.debug(LoggingLevel.ERROR, 'VistexPricingResponse - parseIntegerOrEmptyString. ERROR Parsing: ' + parser.getText());
			}
		}

		return parsedValue;
	}
}