/**
* File Name     :  VistexPricingRequest
* @description  :  Data definition for the vistex pricing request callout from CPQ
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     4/26/2019 	Cesar Sandrigo @ ATG     Created the Class.
* 2.0     2/6/2020		Cory Bartholomew @ ATG    Added descriptions.

**/

public class VistexPricingRequest {
  public class ITEM {
    public String DEALS_DOC_TYPE;
    public String CPQ_PROG_TYPE;
    public String ITEM;
    public String MATERIAL;
    public String MATERIAL_ENTD;
    public String PRICE_REF_MATERIAL;
    public String DOC_CURRENCY;
    public String CURRENCY_KEY;
    public String ORD_QUANTITY;
    public String ORD_UNIT;
    public String UNUSED_RES_LEN;
    public String REASON;
    public String PRICING_DATE;
    public String MATERIAL_DESC;
    public String DIVISION;
    public String PLANT;
    public String ADDON;
    public String SALES_DEAL;
    public String DLSFX;
  }

  public IS_HEADER IS_HEADER;
  public IT_ITEMS IT_ITEMS;
  public String I_RESOLUTION;

  public class IT_ITEMS {
    public List<ITEM> ITEM;

    public IT_ITEMS() {
      this.ITEM = new List<ITEM>();
    }
  }

  public class IS_HEADER {
    public String DELAS_DOC_TYPE;
    public String CPQ_PROG_TYPE;
    public String SOLD_TO_CUST;
    public String DOC_TYPE;
    public String APPLICATION;
    public String PRICING_PROC;
    public String PRICING_DATE;
    public String SALES_ORG;
    public String DISTR_CHANNEL;
    public String DIVISION;
    public String PURCH_ORG;
    public String PLANT;
    public String PAYER_CUST;
    public String BILL_TO_CUST;
    public String SHIP_TO_CUST;
    public String DOC_CONDITION;
    public String DOC_CURRENCY;
    public String CURRENCY_KEY;
    public String REQUEST_DEL_DATE;
    public String PROP_DATE_TYPE;
    public String TERMS_PAYT_KEY;
    public String SALES_DOC_TYPE;
    public String PAYT_METHOD;
  }
}