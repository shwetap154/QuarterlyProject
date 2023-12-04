/**
* File Name     :  VistexPricingRequestTest
* @description  :  Test coverage for the data definition for the vistex pricing request callout from CPQ
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/6/2019 	    Cesar Sandrigo @ ATG     Created the Class.
* 2.0     2/6/2020		Cory Bartholomew @ ATG   Added descriptions.

**/

@isTest
private class VistexPricingRequestTest {

	private static String expectedJson = '{'+
		'		\"IS_HEADER\": {'+
		'			\"DELAS_DOC_TYPE\": \"\",'+
		'			\"CPQ_PROG_TYPE\": \"\",'+
		'			\"SOLD_TO_CUST\": \"1000120838\",'+
		'			\"DOC_TYPE\": \"ZOR7\",'+
		'			\"APPLICATION\": \"V\",'+
		'			\"PRICING_PROC\": \"YSTD09\",'+
		'			\"PRICING_DATE\": \"20190405\",'+
		'			\"SALES_ORG\": \"7903\",'+
		'			\"DISTR_CHANNEL\": \"10\",'+
		'			\"DIVISION\": \"00\",'+
		'			\"PURCH_ORG\": \"\",'+
		'			\"PLANT\": \"\",'+
		'			\"PAYER_CUST\": \"\",'+
		'			\"BILL_TO_CUST\": \"\",'+
		'			\"SHIP_TO_CUST\": \"\",'+
		'			\"DOC_CONDITION\": \"\",'+
		'			\"DOC_CURRENCY\": \"\",'+
		'			\"CURRENCY_KEY\": \"AUD\",'+
		'			\"REQUEST_DEL_DATE\": \"\",'+
		'			\"PROP_DATE_TYPE\": \"\",'+
		'			\"TERMS_PAYT_KEY\": \"\",'+
		'			\"SALES_DOC_TYPE\": \"\",'+
		'			\"PAYT_METHOD\": \"\"'+
		'		},'+
		'		\"IT_ITEMS\": {'+
		'			\"ITEM\": ['+
		'				{'+
		'					\"DEALS_DOC_TYPE\": \"\",'+
		'					\"CPQ_PROG_TYPE\": \"\",'+
		'					\"ITEM\": \"000001\",'+
		'					\"MATERIAL\": \"000000000010016589\",'+
		'					\"MATERIAL_ENTD\": \"\",'+
		'					\"PRICE_REF_MATERIAL\": \"\",'+
		'					\"DOC_CURRENCY\": \"\",'+
		'					\"CURRENCY_KEY\": \"\",'+
		'					\"ORD_QUANTITY\": \"10.000\",'+
		'					\"ORD_UNIT\": \"BLS\",'+
		'					\"UNUSED_RES_LEN\": \"\",'+
		'					\"REASON\": \"\",'+
		'					\"PRICING_DATE\": \"20190405\",'+
		'					\"MATERIAL_DESC\": \"\",'+
		'					\"DIVISION\": \"\",'+
		'					\"PLANT\": \"\",'+
		'					\"ADDON\": \"\",'+
		'					\"SALES_DEAL\": \"\"'+
		'				},'+
		'				{'+
		'					\"DEALS_DOC_TYPE\": \"\",'+
		'					\"CPQ_PROG_TYPE\": \"\",'+
		'					\"ITEM\": \"000002\",'+
		'					\"MATERIAL\": \"000000000010001130\",'+
		'					\"MATERIAL_ENTD\": \"\",'+
		'					\"PRICE_REF_MATERIAL\": \"\",'+
		'					\"DOC_CURRENCY\": \"\",'+
		'					\"CURRENCY_KEY\": \"\",'+
		'					\"ORD_QUANTITY\": \"1.000\",'+
		'					\"ORD_UNIT\": \"VL\",'+
		'					\"UNUSED_RES_LEN\": \"\",'+
		'					\"REASON\": \"\",'+
		'					\"PRICING_DATE\": \"20190405\",'+
		'					\"MATERIAL_DESC\": \"\",'+
		'					\"DIVISION\": \"\",'+
		'					\"PLANT\": \"\",'+
		'					\"ADDON\": \"\",'+
		'					\"SALES_DEAL\": \"\"'+
		'				}'+
		'			]'+
		'		},'+
		'		\"I_RESOLUTION\": \"4\"'+
		'}';
	
	@isTest
	public static void jsonSerialize() {
		// Implement test code
	}
	
}