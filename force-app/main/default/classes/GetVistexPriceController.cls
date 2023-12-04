/**
* File Name     :  GetVistexPriceController
* @description  :  Controller class for 'GetVistexPrice' lightning component.
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/19/2019     Cesar Sandrigo @ ATG    Created the Class.
* 1.1     8/06/2019     Cesar Sandrigo @ ATG    Added support for Manual addons. Moved helper methods to a GetVistexPriceControllerHelper class.
* 1.2     7/15/2020     Cesar Sandrigo @ ATG    Added support for Discounted addons and Rx/Dx Consumables.
*/
global without sharing class GetVistexPriceController {
  private static final Double DEAL_DISCOUNT_LIMIT = 999.99;

  private static final String STATUS_OK = 'OK';
  private static final String STATUS_WARN = 'Warn';
  private static final String STATUS_ERR = 'Error';

  // Vistex Error Type codes
  private static final Map<String, String> VistexErrorTypeDescriptionMap = new Map<String, String>{
    'S' => 'Success',
    'E' => 'Error',
    'W' => 'Warning',
    'I' => 'Information',
    'A' => 'Abort'
  };

  public static final String ADDON_TYPE_AUTOMATIC = 'A';
  public static final String ADDON_TYPE_MANUAL = 'M';
  public static final String ADDON_TYPE_DISCOUNTED = 'D';
  public static final String ADDON_TYPE_RXDX = 'R';

  /**
   * Internal Exception class.
   */
  public class VistexPricingCallException extends Exception {
  }

  global class PricingCallResponse {
    @AuraEnabled
    public String Status { get; set; }

    @AuraEnabled
    public String Message { get; set; }

    @AuraEnabled
    public String AdditionalErrorInfo { get; set; }

    @AuraEnabled
    public String CurrencyCode { get; set; }

    @AuraEnabled
    public List<AddonInfo> AutomaticAddons { get; set; }

    @AuraEnabled
    public List<AddonInfo> ManualAddons { get; set; }

    @AuraEnabled
    public List<AddonGroup> DiscountedAddonGroups { get; set; }

    @AuraEnabled
    public List<AddonGroup> RxDxConsumables { get; set; }

    public PricingCallResponse() {
      Status = STATUS_OK;
      Message = System.Label.Price_retrieved_successfully;
        system.debug('Pricing Call Response ===>'+ Message);
      AutomaticAddons = new List<AddonInfo>();
      ManualAddons = new List<AddonInfo>();
      DiscountedAddonGroups = new List<AddonGroup>();
      RxDxConsumables = new List<AddonGroup>();
    }

    public Boolean HasManualAddons() {
      return (ManualAddons != null && !ManualAddons.isEmpty()) ||
        (DiscountedAddonGroups != null && !DiscountedAddonGroups.isEmpty()) ||
        (RxDxConsumables != null && !RxDxConsumables.isEmpty());
    }
  }

  global class AddonGroup {
    @AuraEnabled
    public Double MaxQuantity { get; set; }

    @AuraEnabled
    public Double MaxValue { get; set; }

    @AuraEnabled
    public String UnitOfMeasure { get; set; }

    @AuraEnabled
    public String GroupId { get; set; }

    @AuraEnabled
    public String Deal { get; set; }

    @AuraEnabled
    public String Suffix { get; set; }

    @AuraEnabled
    public List<AddonInfo> RelatedAddons { get; set; }
  }

  global class AddonInfo {
    @AuraEnabled
    public Integer Id { get; set; }

    @AuraEnabled
    public String MaterialNumber { get; set; }

    @AuraEnabled
    public String MaterialName { get; set; }

    @AuraEnabled
    public Decimal UnitPrice { get; set; }

    @AuraEnabled
    public Decimal NetPrice { get; set; }

    @AuraEnabled
    public Double Quantity { get; set; }

    @AuraEnabled
    public String DealSuffix { get; set; }

    @AuraEnabled
    public String DealNumber { get; set; }

    @AuraEnabled
    public String GroupId { get; set; }

    @AuraEnabled
    public String AddonType { get; set; }

    //CPQATG-1291: Add flag ManualAddonMandatory
    @AuraEnabled
    public Boolean ManualAddonMandatory { get; set; }

    @AuraEnabled
    public String Key {
      get {
        if (AddonType == ADDON_TYPE_AUTOMATIC) {
          return 'AA-' + this.MaterialNumber;
        }

        return this.MaterialNumber + this.DealNumber + this.DealSuffix;
      }
    }
  }

  global class ShipToQuantity {
    @AuraEnabled
    public String ShipToId { get; set; }

    @AuraEnabled
    public Double Quantity { get; set; }

    @AuraEnabled
    public String AddonKey { get; set; }
  }

  global class ApprovalInfo {
    @AuraEnabled
    public Boolean ApprovalRequired { get; set; }

    @AuraEnabled
    public Double MaxValue { get; set; }

    @AuraEnabled
    public Double CurrValue { get; set; }

    @AuraEnabled
    public String Suffix { get; set; }
  }

  /**
   * @description Gets the Vistex pricing information and update the prices for the quote passed as parameter.
   * @param quoteId Id of the Quote.
   * @return An error message, if there was any error, or Empty string if everything went OK.
   */
  @AuraEnabled
  public static PricingCallResponse getVistexPriceFromLightning(Id quoteId, Boolean includeAddons) {
    System.debug('GetVistexPriceController > getVistexPriceFromLightning - quoteId: ' + quoteId + ' - includeAddons: ' + includeAddons);

    PricingCallResponse result = new PricingCallResponse();
    Boolean error = false;

    // Used for logging
    String quoteName = '';

    try {
      // Retrieve the quote and the quote lines
      SBQQ__Quote__c quote = getQuote(quoteId);

      quoteName = quote.Name;

      if (quote.SBQQ__LineItems__r.size() < 1) {
        result.Status = STATUS_WARN;
        result.Message = System.Label.Please_add_lines_to_the_quote;
        //return 'Please, add lines to the quote before trying to get the price from Vistex';
        return result;
      }

      // Initialize the Map to hold the relantionship: QuoteId -> Vistex Item number
      Map<Id, Integer> quoteIdVistexItemCache = new Map<Id, Integer>();

      // Build the request object. Don't include the addons in this first call.
      VistexPricingRequest requestObj = buildRequestObject(quote, quoteIdVistexItemCache, includeAddons);

      // If no lines to sent to Vistex, update quote Vistex_Price_In_Sync__c checkbox
      if (requestObj == null) {
        quote.Vistex_Price_In_Sync__c = true;
        update quote;

        result.Status = STATUS_OK;
        result.Message = '';
        return result;
      }

      // Do the Vistex callout and get the JSON object response
      String jsonResponse = VistexPricingServiceCallout.doRequest(requestObj);

      if (!String.isBlank(jsonResponse)) {
        System.debug('GetVistexPriceController - JSON Response: ' + jsonResponse);

        // Parse JSON response object
        VistexPricingResponse response = VistexPricingResponse.parse(jsonResponse);

        // Check in the Vistex Response if there is any handled error
        if (checkForVistexHandledErrors(response, result, quoteName)) {
          // There was an error. Return the result object populated with the error details.
          return result;
        } else {
          // Update quote line prices
          updateQuoteLines(quote, response, quoteIdVistexItemCache);

          /* If addons are included in the call, that means they should
           * not be processed after we get the response back*/
          if (!includeAddons) {
            // Populate the currency code in the response
            result.CurrencyCode = quote.CurrencyIsoCode;

            // Process the automatic addons
            
            result.AutomaticAddons = processAutomaticAddons(quote, response);

            // Process the Manual Addons
            Map<String, List<AddonGroup>> manualAddonsGroups = GetVistexPriceControllerHelper.getManualAddons(quote, response);

            // Build the manual add-ons list
            List<AddonInfo> manualAddonsList = new List<AddonInfo>();
            for (AddonGroup addonGrp : manualAddonsGroups.get(ADDON_TYPE_MANUAL)) {
              manualAddonsList.addAll(addonGrp.RelatedAddons);
            }

            // Set the different manual add-on types
            result.ManualAddons = manualAddonsList;
            result.DiscountedAddonGroups = manualAddonsGroups.get(ADDON_TYPE_DISCOUNTED);
            result.RxDxConsumables = manualAddonsGroups.get(ADDON_TYPE_RXDX);
          }

          // Update quote
          updateQuote(quote, response, !result.HasManualAddons());
        }
      } else {
        error = true;
      }
    } catch (Exception ex) {
      System.debug(LoggingLevel.ERROR, 'EXCEPTION: ' + ex.getMessage() + ' - Trace: ' + ex.getStackTraceString());
      ErrorLogUtil.log('GetVistexPriceController > There was an error trying to get price from Vistex for Quote: ' + quoteName + '. ', ex);
      result.AdditionalErrorInfo = ex.getMessage();
      error = true;
    }

    if (error) {
      result.Status = STATUS_ERR;
      result.Message = System.Label.There_was_an_error_on_the_Vistex_call;
    }

    // Commit error logs
    ErrorLogUtil.commitLogs();

    return result;
  }

  /**
   * @description Gets the Vistex pricing information and update the prices for the quote passed as parameter.
   * @param quoteId Id of the Quote.
   * @param addons List of manual addons to be added.
   * @return An error message, if there was any error, or Empty string if everything went OK.
   */
  @AuraEnabled
  public static String addManualAddonsToQuote(
    Id quoteId,
    List<GetVistexPriceController.AddonInfo> addons,
    List<GetVistexPriceController.ShipToQuantity> shipToQuantities,
    List<GetVistexPriceController.ApprovalInfo> approvalConfig
  ) {
    System.debug('GetVistexPriceController > addManualAddonsToQuote - quoteId: ' + quoteId);
    System.debug('GetVistexPriceController > addManualAddonsToQuote - addons: ' + addons);
    System.debug('GetVistexPriceController > addManualAddonsToQuote - shipToQuantities: ' + shipToQuantities);
    System.debug('GetVistexPriceController > addManualAddonsToQuote - approvalConfig: ' + approvalConfig);

    try {
      // Get the quote
      SBQQ__Quote__c quote = getQuote(quoteId);

      // Create/Update/Remove the quote lines associated to manual addons
      Map<String, SBQQ__QuoteLine__c> addonKeyQuoteLineIdMap = processSelectedManualAddons(quote, addons);

      // Create/Update/Remove the Ship To Quantity Override record associated to the Addon lines.
      processAddonShipToQuantityConfiguration(quote.Id, shipToQuantities, addonKeyQuoteLineIdMap);

      // Proccess approvals
      processApprovals(quote, approvalConfig);
    } catch (Exception ex) {
      System.debug(LoggingLevel.ERROR, 'EXCEPTION: ' + ex.getMessage() + ' - Trace: ' + ex.getStackTraceString());
      ErrorLogUtil.log('GetVistexPriceController > There was an error on applying add-on configuration.', ex);
      ErrorLogUtil.commitLogs();
      throw new AuraHandledException(System.Label.There_was_an_error_trying_to_add_selected_manual_add_ons_to_the_Quote);
    }

    ErrorLogUtil.commitLogs();
    return '';
  }

  /**
   * @description Gets the Vistex pricing information and update the prices for the quote passed as parameter.
   * @param quoteId Id of the Quote.
   * @return An error message, if there was any error, or Empty string if everything went OK.
   */
  @AuraEnabled
  public static List<Ship_to_Configuration__c> getShipToConfiguration(Id quoteId) {
    List<Ship_to_Configuration__c> shipToConfigurations = [
      SELECT
        Id,
        Quantity__c,
        Quote__c,
        Ship_to_Address__c,
        Default_Ship_To_Location__c,
        Ship_to_Address__r.Name,
        (SELECT Id, Quantity__c, Quote_Line__c FROM Quantity_Overrides__r)
      FROM Ship_to_Configuration__c
      WHERE Quote__c = :quoteId
      ORDER BY Name
    ];

    return shipToConfigurations;
  }

  /**
   * @description Gets the Quote and Quote Lines with all the relevant field to build the Vistex request.
   * @param quoteId Id of the quote.
   * @return Quote record and Quote Lines related to it.
   */
  private static SBQQ__Quote__c getQuote(Id quoteId) {
    SBQQ__Quote__c quote = [
      SELECT
        Id,
        Name,
        CurrencyIsoCode,
        Address__r.ZTS_US_Source_Account_Number__c, // Sold-to SAP Account
        Bill_To_Address__r.ZTS_US_Source_Account_Number__c, // Bill-to SAP Account
        Ship_To_Address__r.ZTS_US_Source_Account_Number__c, // Ship-to SAP Account
        Payer_Address__r.ZTS_US_Source_Account_Number__c, // Payer
        Sales_Org__c, // Sales Org
        SBQQ__Opportunity2__r.Market__r.Distribution_Channel__c, // Distribution channel
        SBQQ__Opportunity2__r.Market__r.Division__c, // Division
        SBQQ__Opportunity2__r.Market__r.Vistex_Pricing_Procedure__c, // Pricing procedure
        SBQQ__Opportunity2__r.Market__r.Vistex_Order_Type__c, // Document Type
        SBQQ__Opportunity2__r.Market__r.Item_Value_after_Vistex_Discount__c, // Vistex item field where to fetch the value from
        SBQQ__Opportunity2__r.Market__r.Is_Line_Total__c, // Vistex Is the provided value the line total?
        SBQQ__StartDate__c, // Quote start date
        Rx_Dx_Approval_Text__c,
        (
          SELECT
            Id,
            SBQQ__Number__c,
            SBQQ__Quantity__c,
            SBQQ__ListPrice__c, // List price to calculate Deal discount
            SBQQ__RequiredBy__c, // To identify parents
            SBQQ__Bundle__c, // Bundle, to identify quote lines that don't correspond to material
            SBQQ__Product__r.Name, // Product Name
            SBQQ__Product__r.SAP_Material__c, // SAP Material ID
            SBQQ__Product__r.SAP_Material__r.SAP_Product_Number__c, // SAP Material Number
            SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type_Grouping__c, // CPQ Material Type Grouping
            SBQQ__Product__r.SAP_Material__r.CPQ_Material_Type__c, // CPQ Material Type
            SBQQ__Product__r.Program_Eligibility_Filter__c, // Program name at parent bundle level
            SBQQ__ProductOption__c, // Product Option Id
            Vistex_Automatic_Add_on__c, // Is Automatic Vistex Addon?
            Vistex_Manual_Add_on__c, // Is Manual Vistex Addon?
            Vistex_Condition_Item_Number__c, // Vistex Condition Item number
            Exclude_from_Vistex_Pricing_Call__c, // Exclude from Vistex Pricing call flag
            SAP_Unit_Of_Measure__c, // Unit of Measure from the Price Entry
            Vistex_Sales_Deal__c, // Vistex Deal Information for Manual Addons
            Deal_Line_Group__c, // Deal Line suffix
            SBQQ__PricebookEntryId__c, // The id of the pricebook entry
            Vistex_Add_on_key__c, // Key to uniquely identify add-on lines, useful to upsert ;)
            CPQ_Material_Type__c
          FROM SBQQ__LineItems__r
        )
      FROM SBQQ__Quote__c
      WHERE Id = :quoteId
    ];

    return quote;
  }

  /**
   * @description Builds the Vistex Request object based on the Quote record passed as parameter.
   * @param quote Quote and Quote Lines to be included in the request.
   * @param quoteIdVistexItemCache Quote and Quote Lines to be included in the request.
   * @param includeAddons Quote and Quote Lines to be included in the request.
   */
  private static VistexPricingRequest buildRequestObject(
    SBQQ__Quote__c quote,
    Map<Id, Integer> quoteIdVistexItemCache,
    Boolean includeAddons
  ) {
    // Check for most common data issues and raise an exception if needed
    if (quote.Address__r == null) {
      throw new VistexPricingCallException('Sold-To Address was not set in the Quote.');
    } else if (quote.Address__r.ZTS_US_Source_Account_Number__c == null) {
      throw new VistexPricingCallException('SAP Account Number is not set in the Sold-To Account Primary Address.');
    }

    // Holds the parent bundle line to get Vistex Program information
    SBQQ__QuoteLine__c parentBundleLine;

    // Get formatted date from Quote Start Date or current date, if it's null
    String formatedDate = GetVistexPriceControllerHelper.getFormatedDate(quote.SBQQ__StartDate__c); // Date for testing Manual Addons: '20210621'

    // Build the list of items
    VistexPricingRequest.IT_ITEMS itemList = new VistexPricingRequest.IT_ITEMS();

    // Build an item object for Quote Line
    for (Integer i = 1; i <= quote.SBQQ__LineItems__r.size(); i++) {
      // Get the quote line
      SBQQ__QuoteLine__c quoteLine = quote.SBQQ__LineItems__r[i - 1];

      /* If it's the parent bundle line, exclude it from the call,
       * since it represents the 'Program' in Vistex. */
      if (quoteLine.SBQQ__RequiredBy__c == null && quoteLine.SBQQ__Bundle__c) {
        parentBundleLine = quoteLine;
        continue;
      }

      /* -- EXCLUDED LINES --
       * Lines are excluded from Vistex pricing call are: parent bundle lines,
       * non-SAP product lines, Program Charges, Aggregate Commitment lines, Rebate Consumables
       */
      if (quoteLine.Exclude_from_Vistex_Pricing_Call__c) {
        System.debug(LoggingLevel.WARN, 'GetVistexPriceController >> WARN: Ignoring Quote Line: ' + quoteLine.SBQQ__Product__r.Name);
        System.debug(LoggingLevel.WARN, 'GetVistexPriceController >> WARN: Ignored Quote Line: ' + quoteLine);
        continue;
      }

      /* -- ADDON LINES --
       * Always exclude automatic addons.
       * Only include manual add-on lines depending of the value of the parameter
       */
      if (quoteLine.Vistex_Automatic_Add_on__c || (!includeAddons && quoteLine.Vistex_Manual_Add_on__c)) {
        System.debug(LoggingLevel.WARN, 'GetVistexPriceController >> WARN: Ignoring Add-on Quote Line: ' + quoteLine.SBQQ__Product__r.Name);
        continue;
      }

      if (String.isBlank(quoteLine.SAP_Unit_Of_Measure__c)) {
        System.debuG('GetVistexPriceController >> SAP Unit of Measure is not set - PBE Id: ' + quoteLine.SBQQ__PricebookEntryId__c);
        throw new VistexPricingCallException('SAP Unit of Measure is not set for Product: ' + quoteLine.SBQQ__Product__r.Name);
      }

      // Populate the quoteline-item number map
      quoteIdVistexItemCache.put(quoteLine.Id, i);

      VistexPricingRequest.ITEM item = new VistexPricingRequest.ITEM();
      item.DEALS_DOC_TYPE = '';
      item.CPQ_PROG_TYPE = '';
      item.ITEM = String.valueOf(i).leftPad(6, '0'); // Vistex Item number. Match this in request.
      item.MATERIAL = quoteLine.SBQQ__Product__r.SAP_Material__r.SAP_Product_Number__c.leftPad(18, '0');
      item.MATERIAL_ENTD = '';
      item.PRICE_REF_MATERIAL = '';
      item.DOC_CURRENCY = '';
      item.CURRENCY_KEY = '';
      item.ORD_QUANTITY = String.valueOf(quoteLine.SBQQ__Quantity__c);
      item.ORD_UNIT = quoteLine.SAP_Unit_Of_Measure__c;
      item.REASON = '';
      item.PRICING_DATE = formatedDate;
      item.MATERIAL_DESC = '';
      item.DIVISION = '';
      item.PLANT = '';
      item.ADDON = quoteLine.Vistex_Automatic_Add_on__c || quoteLine.Vistex_Manual_Add_on__c ? 'X' : '';
      item.SALES_DEAL = quoteLine.Vistex_Manual_Add_on__c ? quoteLine.Vistex_Sales_Deal__c : '';
      item.DLSFX = quoteLine.Vistex_Manual_Add_on__c && quoteLine.Deal_Line_Group__c != null ? quoteLine.Deal_Line_Group__c : ''; // Deal Suffix

      itemList.ITEM.add(item);
    }

    if (itemList.ITEM.isEmpty()) {
      System.debug(LoggingLevel.WARN, 'GetVistexPriceController >> No lines to sent to Vistex.');
      return null;
    }

    // Build header
    VistexPricingRequest.IS_HEADER headerObj = new VistexPricingRequest.IS_HEADER();

    // Determine Bill-to account
    String billToSAPAccountId = quote.Bill_To_Address__r.ZTS_US_Source_Account_Number__c == null
      ? ''
      : quote.Bill_To_Address__r.ZTS_US_Source_Account_Number__c;

    // Determine ship-to account
    String shipToSAPAccountId = quote.Ship_To_Address__r.ZTS_US_Source_Account_Number__c == null
      ? ''
      : quote.Ship_To_Address__r.ZTS_US_Source_Account_Number__c;

    // Determine payer account
    String payerSAPAccountId = quote.Payer_Address__r.ZTS_US_Source_Account_Number__c == null
      ? ''
      : quote.Payer_Address__r.ZTS_US_Source_Account_Number__c;

    // Get the program name from the parent bundle product Elegibility filter
    String programType = parentBundleLine != null &&
      parentBundleLine.SBQQ__Product__r.Program_Eligibility_Filter__c != null
      ? parentBundleLine.SBQQ__Product__r.Program_Eligibility_Filter__c.toUpperCase()
      : '';

    // Populate header object fields
    headerObj.SOLD_TO_CUST = quote.Address__r.ZTS_US_Source_Account_Number__c;
    headerObj.BILL_TO_CUST = billToSAPAccountId;
    headerObj.SHIP_TO_CUST = shipToSAPAccountId;
    headerObj.PAYER_CUST = payerSAPAccountId;
    headerObj.DOC_TYPE = '';
    headerObj.PRICING_PROC = quote.SBQQ__Opportunity2__r.Market__r.Vistex_Pricing_Procedure__c;
    headerObj.PRICING_DATE = formatedDate;
    headerObj.SALES_ORG = quote.Sales_Org__c;
    headerObj.DISTR_CHANNEL = quote.SBQQ__Opportunity2__r.Market__r.Distribution_Channel__c;
    headerObj.DIVISION = quote.SBQQ__Opportunity2__r.Market__r.Division__c;
    headerObj.CURRENCY_KEY = quote.CurrencyIsoCode;
    headerObj.CPQ_PROG_TYPE = programType;
    headerObj.DOC_CURRENCY = '';
    headerObj.DELAS_DOC_TYPE = '';
    headerObj.PURCH_ORG = '';
    headerObj.PLANT = '';
    headerObj.DOC_CONDITION = '';
    headerObj.REQUEST_DEL_DATE = '';
    headerObj.PROP_DATE_TYPE = '';
    headerObj.TERMS_PAYT_KEY = '';
    headerObj.SALES_DOC_TYPE = quote.SBQQ__Opportunity2__r.Market__r.Vistex_Order_Type__c;
    headerObj.PAYT_METHOD = '';
    headerObj.APPLICATION = 'V'; // Fixed value

    // Build request object
    VistexPricingRequest requestObj = new VistexPricingRequest();
    requestObj.IS_HEADER = headerObj;
    requestObj.IT_ITEMS = itemList;
    requestObj.I_RESOLUTION = '4'; // Fixed value

    System.debug('GetVistexPriceController - JSON Request: ' + JSON.serialize(requestObj));

    return requestObj;
  }

  /**
   * @description Checks if there were any handled error in Vistex side.
   * @param vistexResponse The Vistex response object.
   * @param result *BY REF* Result object, passed by reference to be populated in case of error.
   * @param quoteName Quote Name, just for logging purposes in case of error.
   * @return True if there was any error.
   */
  private static Boolean checkForVistexHandledErrors(
    VistexPricingResponse vistexResponse,
    /* ref */ PricingCallResponse result,
    String quoteName
  ) {
    // If there is no return items, I'm assuming there were no errors
    if (vistexResponse.ET_RETURN == null || vistexResponse.ET_RETURN.items == null || vistexResponse.ET_RETURN.items.isEmpty()) {
      return false;
    }

    // Iterate thru the return items..
    for (VistexPricingResponse.ReturnItem returnInfo : vistexResponse.ET_RETURN.items) {
      /* We consider there was an error when:
       *    -The Return Type is ERROR or ABORT, or
       *    -The Return Type is is not SUCCESS and the items are emtpy.*/
      if (
        returnInfo.TYPE.equalsIgnoreCase('E') ||
        returnInfo.TYPE.equalsIgnoreCase('A') ||
        (!returnInfo.TYPE.equalsIgnoreCase('S') && vistexResponse.ES_RESULT.ITEM.ITEM.isEmpty())
      ) {
        System.debug(
          LoggingLevel.ERROR,
          'GetVistexPriceController > Vistex Handled ERROR detected. TYPE: ' +
          returnInfo.TYPE +
          ' - MESSAGE: ' +
          returnInfo.MESSAGE
        );

        // Populate the result object
        result.Status = STATUS_ERR;
        result.Message = System.Label.There_was_an_error_on_the_Vistex_call;

        // Build the additional error message.
        result.AdditionalErrorInfo = String.format(
          'Error Type: {1}. {0}' +
          'Error Code: {2}. {0}' +
          'Message: {3}. {0}',
          new List<String>{
            '\n',
            VistexErrorTypeDescriptionMap.containsKey(returnInfo.TYPE) ? VistexErrorTypeDescriptionMap.get(returnInfo.TYPE) : 'Unknown',
            returnInfo.CODE,
            returnInfo.MESSAGE
          }
        );

        // Create a log error record in the database
        ErrorLogUtil.log(
          'GetVistexPriceController > There was a handled error on Vistex.',
          new List<String>{ 'Quote: ' + quoteName, 'Vistex error detail: ' + System.JSON.serialize(returnInfo) }
        );
        ErrorLogUtil.commitLogs();

        return true;
      }
    }

    return false;
  }

  /**
   * @description Updates the quote fields related to Vistex price.
   * @param quote Quote (and quote lines) to be updated with pricing information.
   * @param vistexResponse Response object built from Vistex JSON response.
   * @param vistexPriceInSync Indicates the value of 'Vistex Price in Sync' flag
   */
  private static void updateQuote(SBQQ__Quote__c quote, VistexPricingResponse vistexResponse, Boolean vistexPriceInSync) {
    // Field mapping on Jira ticket CPQATG-136
    quote.Vistex_Discounted_Total__c = vistexResponse.ES_RESULT.ORD_DISCOUNT_TOT;
    quote.Vistex_Net_Price__c = vistexResponse.ES_RESULT.NET_PRICE;
    quote.Vistex_Pricing_Procedure__c = vistexResponse.ES_RESULT.PRICING_PROC;
    quote.Vistex_Total_Price__c = vistexResponse.ES_RESULT.ORD_TOT_PRICE;
    quote.Vistex_Total_Taxes__c = vistexResponse.ES_RESULT.ORD_TAXES;
    quote.Vistex_Net_Value__c = vistexResponse.ES_RESULT.NET_VALUE;
    quote.Vistex_Sales_Document_Number__c = vistexResponse.ES_RESULT.SD_DOC_NO;
    quote.Vistex_Sub_Total_1__c = vistexResponse.ES_RESULT.SUB_TOT1;
    quote.Vistex_Sub_Total_2__c = vistexResponse.ES_RESULT.SUB_TOT2;
    quote.Vistex_Sub_Total_3__c = vistexResponse.ES_RESULT.SUB_TOT3;

    // Set VISTEX PRICE IN SYNC flag!
    quote.Vistex_Price_In_Sync__c = vistexPriceInSync;

    // If flag is set to false, we disable the triggers to not fire calculation.
    if (!vistexPriceInSync) {
      SBQQ.TriggerControl.disable();
    }

    // Disable 'Vistex Price in Sync' flag calculation, since we're already populating it with the right value.
    QuoteTriggerHandler.disablePriceInSyncCalculation();
    try {
      update quote;
    } catch (Exception ex) {
      ErrorLogUtil.log('Error on updating Quote: ' + quote.Name, ex);
      throw ex;
    } finally {
      if (!SBQQ.TriggerControl.isEnabled()) {
        SBQQ.TriggerControl.enable();
      }

      QuoteTriggerHandler.enablePriceInSyncCalculation();
    }
  }

  /**
   * @description Updates the quote line fields related to Vistex price. Calculates the Deal Discount.
   * @param quote Quote (and quote lines) to be updated with pricing information.
   * @param vistexResponse Response object built from Vistex JSON response.
   */
  private static void updateQuoteLines(
    SBQQ__Quote__c quote,
    VistexPricingResponse vistexResponse,
    Map<Id, Integer> quoteIdVistexItemCache
  ) {
    System.debug('GetVistexPriceController > updateQuoteLines - quoteIdVistexItemCache: ' + quoteIdVistexItemCache);

    List<SBQQ__QuoteLine__c> quotesLinesToBeUpdated = new List<SBQQ__QuoteLine__c>();

    // Get non-addon items from response object
    Map<Integer, VistexPricingResponse.ResultItem> responseItems = GetVistexPriceControllerHelper.buildResponseItemMap(vistexResponse);

    for (SBQQ__QuoteLine__c quoteLine : quote.SBQQ__LineItems__r) {
      if (!quoteIdVistexItemCache.containsKey(quoteLine.Id))
        continue;

      if (!responseItems.containsKey(quoteIdVistexItemCache.get(quoteLine.Id))) {
        System.debug(
          LoggingLevel.WARN,
          'GetVistexPriceController > updateQuoteLines - No response item related to Quote Line Id: ' + quoteLine.Id
        );
        continue;
      }

      VistexPricingResponse.ResultItem item = responseItems.get(quoteIdVistexItemCache.get(quoteLine.Id));

      quoteLine.Vistex_Condition_Item_Number__c = Integer.valueOf(item.COND_ITEM_NO);
      quoteLine.Vistex_Condition_Subtotal__c = item.COND_SUBTOT;
      quoteLine.Vistex_Gross_Unit_Price__c = item.ITEM_CREDIT_PRICE;
      quoteLine.Vistex_Gross_Value__c = item.GROSS_VALUE_IN_DOC_CUR;
      quoteLine.Vistex_Item_Contract_Price__c = item.ITEM_CONTRACT_PRICE;
      quoteLine.Vistex_Item_Discounted_Total_Price__c = item.ITEM_DISC_TOT_PRICE;
      quoteLine.Vistex_Net_Price__c = item.NET_PRICE;
      quoteLine.Vistex_Net_Value__c = item.NET_VALUE_DOC_CUR;
      quoteLine.Vistex_Preference_Value__c = item.PREFERENCE_VALUE;
      quoteLine.Vistex_Rebate_Basis__c = item.RABATE_BASIS;
      quoteLine.Vistex_Sales_Document_Item_Category__c = item.SD_ITEM_CATG;
      quoteLine.Vistex_Subtotal_Condition_4__c = item.COND_SUBTOT4;
      quoteLine.Vistex_Subtotal_Condition_5__c = item.COND_SUBTOT5;
      quoteLine.Vistex_Subtotal_Condition_6__c = item.COND_SUBTOT6;
      quoteLine.Vistex_Tax_Amount__c = item.TAX_AMT_IN_DOC_CUR;

      // Get the item value based on market-specific configuration
      Double vistexItemNetPrice = GetVistexPriceControllerHelper.getVistexItemValueBasedOnMarketConfig(
        item,
        quote.SBQQ__Opportunity2__r.Market__r.Item_Value_after_Vistex_Discount__c,
        quote.SBQQ__Opportunity2__r.Market__r.Is_Line_Total__c
      );

      Double dealDiscount;

      // Calculate the Deal Discount
      if (quoteLine.SBQQ__ListPrice__c > 0.0) {
        // To avoid deviding by Zero
        dealDiscount = ((quoteLine.SBQQ__ListPrice__c - vistexItemNetPrice) / quoteLine.SBQQ__ListPrice__c) * 100;
      } else {
        dealDiscount = 100.00;
      }

      System.debug('GetVistexPriceController > List Price: ' + quoteLine.SBQQ__ListPrice__c);
      System.debug('GetVistexPriceController > Discounted Price: ' + vistexItemNetPrice);
      System.debug('GetVistexPriceController > Deal Discount: ' + dealDiscount);

      if (dealDiscount > DEAL_DISCOUNT_LIMIT || dealDiscount < ((-1) * DEAL_DISCOUNT_LIMIT)) {
        System.debug(
          LoggingLevel.ERROR,
          'GetVistexPriceController > Deal Discount Higher than LIMIT - Product: ' +
          quoteLine.SBQQ__Product__r.Name +
          ' - Line #' +
          quoteLine.SBQQ__Number__c
        );

        ErrorLogUtil.log(
          'GetVistexPriceController > Deal Discount Higher than LIMIT',
          new List<String>{
            'Quote: ' + quote.Name,
            'Product: ' + quoteLine.SBQQ__Product__r.Name,
            'Line Number: ' + quoteLine.SBQQ__Number__c,
            'List Price: ' + quoteLine.SBQQ__ListPrice__c,
            'Vistex Price: ' + vistexItemNetPrice,
            'Vistex Discount (calculated): ' + dealDiscount,
            'Discount Limit: (+/-)' + DEAL_DISCOUNT_LIMIT
          }
        );
      }

      quoteLine.Contract_Price__c = vistexItemNetPrice;

      // Using partner discout in order to avoid changing calculation process.
      quoteLine.SBQQ__PartnerDiscount__c = dealDiscount;
      quoteLine.Deal_Discount__c = dealDiscount;

      quotesLinesToBeUpdated.add(quoteLine);
    }

    SBQQ.TriggerControl.disable();
    QuoteTriggerHandler.disablePriceInSyncCalculation();
    try {
      update quotesLinesToBeUpdated;
    } catch (Exception ex) {
      ErrorLogUtil.log('Error on updating existing Quote Lines for quote: ' + quote.Name, ex);
      throw ex;
    } finally {
      SBQQ.TriggerControl.enable();
      QuoteTriggerHandler.enablePriceInSyncCalculation();
    }
  }

  /**
   * @description Updates the Quote Lines related to the addons with the Addons.
   * @param currentQuoteLines List of all the quote lines in the quote.
   * @param vistexResponse Response object from Vistex.
   *
   * HACKME: For now it's removing old addons and adding new ones. Maybe it can be done in an smarter way.
   */
  private static List<GetVistexPriceController.AddonInfo> processAutomaticAddons(
    SBQQ__Quote__c quote,
    VistexPricingResponse vistexResponse
  ) {
    // Quote lines to be removed
    List<SBQQ__QuoteLine__c> quoteLinesToBeRemoved = new List<SBQQ__QuoteLine__c>();

    // Quote lines to be added
    List<SBQQ__QuoteLine__c> quoteLinesToBeAdded = new List<SBQQ__QuoteLine__c>();

    Id parentQuoteLineId;

    for (SBQQ__QuoteLine__c existingQuoteLine : quote.SBQQ__LineItems__r) {
      if (!existingQuoteLine.SBQQ__Bundle__c && existingQuoteLine.SBQQ__RequiredBy__c == null && parentQuoteLineId == null) {
        parentQuoteLineId = existingQuoteLine.Id;
        System.debug('GetVistexPriceController - ADDONS > Parent Quote Id: ' + parentQuoteLineId);
      }

      if (existingQuoteLine.Vistex_Automatic_Add_on__c) {
        quoteLinesToBeRemoved.add(existingQuoteLine);
      }
    }

    // Get automatic addons from request
    List<VistexPricingResponse.ResultItem> automaticAddonsItems = GetVistexPriceControllerHelper.getAutomaticAddonsResponseItems(
      vistexResponse
    );

    // Get additional information from Addon Lines
    Map<String, VistexPricingResponse.AddonItem> additionalAddonInfoMap = GetVistexPriceControllerHelper.getAutomaticAddonsAddintionalInfo(
      vistexResponse
    );

    Set<String> materialNumberSet = new Set<String>();

    // Build a set with all the material numbers with and without leading zeros
    for (VistexPricingResponse.ResultItem item : vistexResponse.ES_RESULT.ITEM.ITEM) {
      // With leading zeros (from Vistex response)
      materialNumberSet.add(item.MATERIAL);

      // Without leading zeros
      materialNumberSet.add(String.valueOf(Integer.valueOf(item.MATERIAL)));
    }

    // Build a Map: Product Number -> Product2 record
    Map<String, Product2> productMap = GetVistexPriceControllerHelper.buildMaterialNumberProductMap(
      materialNumberSet,
      quote.Sales_Org__c,
      quote.CurrencyIsoCode
    );

    // List to store the result list with the automatic addon information, to show them to the user
    List<GetVistexPriceController.AddonInfo> addonInfoList = new List<GetVistexPriceController.AddonInfo>();

    Integer lineNumber = quote.SBQQ__LineItems__r.size() + 1;

    for (VistexPricingResponse.ResultItem addon : automaticAddonsItems) {
      // Material Number without leading zeros
      String materialNumberWithoutLeadingZeros = String.valueOf(Integer.valueOf(addon.MATERIAL));

      Product2 product;

      // Try to get the product with the material number with leading zeros
      if (productMap.containsKey(addon.MATERIAL)) {
        product = productMap.get(addon.MATERIAL);
      } else if (productMap.containsKey(materialNumberWithoutLeadingZeros)) {
        // Try to get the product with the material number without leading zeros
        product = productMap.get(materialNumberWithoutLeadingZeros);
      } else {
        // If I cannot find the Material, log the error and continue
        System.debug(LoggingLevel.ERROR, 'GetVistexPriceController - AUTO ADDONS > SAP Material not found: ' + addon.MATERIAL);
        ErrorLogUtil.log(
          'GetVistexPriceController - AUTO ADDONS > SAP Material not found',
          new List<String>{ 'Material: ' + addon.MATERIAL, 'Quote: ' + quote.Name }
        );
        continue;
      }

      if (product.PricebookEntries.isEmpty()) {
        System.debug(LoggingLevel.ERROR, 'GetVistexPriceController - AUTO ADDONS > No PBE found for Material: ' + addon.MATERIAL);
        ErrorLogUtil.log(
          'GetVistexPriceController - AUTO ADDONS > Pricebook Entry not found.',
          new List<String>{
            'Material: ' + addon.MATERIAL,
            'Quote: ' + quote.Name,
            'Sales Org: ' + quote.Sales_Org__c,
            'Currency: ' + quote.CurrencyIsoCode
          }
        );
        continue;
      }

      // Get the Price Book Entry associated to the product in this market
      PricebookEntry pbe = product.PricebookEntries[0];

      // Get add-on additional info
      VistexPricingResponse.AddonItem additionalAddonInfo = additionalAddonInfoMap.get(addon.COND_ITEM_NO);

      // Create the quote line
      SBQQ__QuoteLine__c newAddonLine = GetVistexPriceControllerHelper.createQuoteLine(
        quote.Id,
        product,
        pbe,
        lineNumber,
        quote.CurrencyIsoCode
      );

      // Set quantity and price
      newAddonLine.SBQQ__Quantity__c = addon.QUANTITY;
      newAddonLine.SBQQ__PartnerDiscount__c = 100;
      newAddonLine.Deal_Discount__c = 100;
      newAddonLine.Contract_Price__c = 0;

      // Vistex specific fields
      newAddonLine.Vistex_Automatic_Add_on__c = addon.ADDON == 'X'; // true;
      newAddonLine.Vistex_Condition_Item_Number__c = Integer.valueOf(addon.COND_ITEM_NO);
      newAddonLine.Vistex_Condition_Subtotal__c = addon.COND_SUBTOT;
      newAddonLine.Vistex_Gross_Unit_Price__c = addon.ITEM_CREDIT_PRICE;
      newAddonLine.Vistex_Gross_Value__c = addon.GROSS_VALUE_IN_DOC_CUR;
      newAddonLine.Vistex_Item_Contract_Price__c = addon.ITEM_CONTRACT_PRICE;
      newAddonLine.Vistex_Item_Discounted_Total_Price__c = addon.ITEM_DISC_TOT_PRICE;
      newAddonLine.Vistex_Net_Price__c = addon.NET_PRICE;
      newAddonLine.Vistex_Net_Value__c = addon.NET_VALUE_DOC_CUR;
      newAddonLine.Vistex_Preference_Value__c = addon.PREFERENCE_VALUE;
      newAddonLine.Vistex_Rebate_Basis__c = addon.RABATE_BASIS;
      newAddonLine.Vistex_Sales_Document_Item_Category__c = addon.SD_ITEM_CATG;
      newAddonLine.Vistex_Subtotal_Condition_4__c = addon.COND_SUBTOT4;
      newAddonLine.Vistex_Subtotal_Condition_5__c = addon.COND_SUBTOT5;
      newAddonLine.Vistex_Subtotal_Condition_6__c = addon.COND_SUBTOT6;
      newAddonLine.Vistex_Tax_Amount__c = addon.TAX_AMT_IN_DOC_CUR;
      newAddonLine.Deal_Line_Group__c = additionalAddonInfo != null ? additionalAddonInfo.DEAL_SUFFIX : '';

      quoteLinesToBeAdded.add(newAddonLine);

      // Create the info addon object and added to the list
      GetVistexPriceController.AddonInfo addonInfo = new GetVistexPriceController.AddonInfo();
      addonInfo.Id = Integer.valueOf(addon.COND_ITEM_NO);
      addonInfo.MaterialNumber = addon.MATERIAL;
      addonInfo.MaterialName = product.Name;
      addonInfo.NetPrice = addon.NET_PRICE;
      addonInfo.UnitPrice = addon.NET_PRICE;
      addonInfo.Quantity = addon.QUANTITY;
      addonInfo.AddonType = ADDON_TYPE_AUTOMATIC;
      addonInfo.ManualAddonMandatory = false; //CPQATG-1291

      addonInfoList.add(addonInfo);
    }

    SBQQ.TriggerControl.disable();
    QuoteTriggerHandler.disablePriceInSyncCalculation();
    try {
      delete quoteLinesToBeRemoved;
      insert quoteLinesToBeAdded;
    } catch (Exception ex) {
      ErrorLogUtil.log('Error on upserting Quote Lines related to Automatic Add-ons. Quote: ' + quote.Name, ex);
      AuraHandledException e = new AuraHandledException('Error on upserting Quote Lines related to manual add-ons: ' + ex.getMessage());
      e.setMessage('Error on upserting Quote Lines related to manual add-ons: ' + ex.getMessage());
      throw e;
    } finally {
      SBQQ.TriggerControl.enable();
      QuoteTriggerHandler.enablePriceInSyncCalculation();
    }

    return addonInfoList;
  }

  /***
   * @description Updates the Quote with the selected manual add-ons.
   * @param quoteId The quote Id.
   * @param addons List with the selected manual add-ons.
   */
  private static Map<String, SBQQ__QuoteLine__c> processSelectedManualAddons(
    SBQQ__Quote__c quote,
    List<GetVistexPriceController.AddonInfo> addons
  ) {
    // Get the next quote line number. The addons will be added always at the end
    Integer lineNumber = quote.SBQQ__LineItems__r.size() + 1;

    // Map to store Addon Key -> Existing Quote Line
    Map<String, SBQQ__QuoteLine__c> addonKeyQuoteLineMap = new Map<String, SBQQ__QuoteLine__c>();

    // Map to store Automatic Add-on Key -> Existing Automatic Add-on Quote Lines. This is only for returning all the add-on lines at the end.
    Map<String, SBQQ__QuoteLine__c> automaticAddonKeyQuoteLineMap = new Map<String, SBQQ__QuoteLine__c>();

    // Build a map with Adodon Key -> Existing Quote Line
    for (SBQQ__QuoteLine__c quoteLine : quote.SBQQ__LineItems__r) {
      if (quoteLine.Vistex_Manual_Add_on__c) {
        addonKeyQuoteLineMap.put(quoteLine.Vistex_Add_on_key__c, quoteLine);
      } else if (quoteLine.Vistex_Automatic_Add_on__c) {
        automaticAddonKeyQuoteLineMap.put(quoteLine.Vistex_Add_on_key__c, quoteLine);
      }
    }

    // Map to store Addon Key -> Addon Info object coming from the UI
    Map<String, GetVistexPriceController.AddonInfo> addonKeyMap = new Map<String, GetVistexPriceController.AddonInfo>();

    // Set of Material Numbers used by this new addon configuraiton.
    Set<String> materialNumberSet = new Set<String>();

    // NOTE: Only consider the Addons that have Quantity > 0. We're ignoring the rest.
    for (GetVistexPriceController.AddonInfo addon : addons) {
      if (addon.Quantity > 0) {
        addonKeyMap.put(addon.Key, addon);
        materialNumberSet.add(addon.MaterialNumber);
      }
    }

    // Quote lines to be added
    Map<String, SBQQ__QuoteLine__c> quoteLinesToUpsert = new Map<String, SBQQ__QuoteLine__c>();

    // Quote lines to be removed
    List<SBQQ__QuoteLine__c> quoteLinesToRemove = new List<SBQQ__QuoteLine__c>();

    // If some of the previous quote lines related to the addons are not part of the new configuration, remove them
    for (String addonKey : addonKeyQuoteLineMap.keySet()) {
      if (!addonKeyMap.containsKey(addonKey)) {
        quoteLinesToRemove.add(addonKeyQuoteLineMap.get(addonKey));
      }
    }

    // Build a Map: Product Number -> Product2 record
    // This is going to also get the Price Book Entries related to the Products in the Sales Org for sanity check
    Map<String, Product2> productMap = GetVistexPriceControllerHelper.buildMaterialNumberProductMap(
      materialNumberSet,
      quote.Sales_Org__c,
      quote.CurrencyIsoCode
    );

    for (String addonKey : addonKeyMap.keySet()) {
      // Get the addon
      AddonInfo addon = addonKeyMap.get(addonKey);

      // If the quote line doesn't exist yet...
      if (!addonKeyQuoteLineMap.containsKey(addonKey)) {
        // Get the material number related to the addon
        String materialNumber = addon.MaterialNumber;

        /*** BEGIN: PRODUCT SANITY CHECK ***/

        // Check if the product was found in the database
        if (!productMap.containsKey(materialNumber)) {
          String exMessage = 'No active Products were found for Material: ' + materialNumber;
          ErrorLogUtil.log(
            exMessage,
            new List<String>{ 'Quote: ' + quote.Name, 'Material: ' + materialNumber, 'Sales Org: ' + quote.Sales_Org__c }
          );

          AuraHandledException ex = new AuraHandledException(exMessage);
          ex.setMessage(exMessage);
          throw ex;
        }

        // Get the product record from the map
        Product2 product = productMap.get(materialNumber);

        // Check if the product has a Price Book Entry in the Pricebook related to the Sales Org
        if (product.PricebookEntries.isEmpty()) {
          String exMessage = 'The Product [' + product.Name + '] does not have a Price for Sales Org: ' + quote.Sales_Org__c;

          ErrorLogUtil.log(
            exMessage,
            new List<String>{ 'Quote: ' + quote.Name, 'Product: ' + product.Name, 'Sales Org: ' + quote.Sales_Org__c }
          );

          AuraHandledException ex = new AuraHandledException(exMessage);
          ex.setMessage(exMessage);
          throw ex;
        }

        // Get the Price Book Entry associated to the product in this market
        PricebookEntry pbe = product.PricebookEntries[0];

        // Check Unit of Measure associated to the Price Book Entry
        if (String.isBlank(pbe.SAP_Unit_Of_Measure__c)) {
          String exMessage =
            'The price defined for Product [' +
            product.Name +
            '] does not have a valid SAP Unit of Measure for Sales Org: ' +
            quote.Sales_Org__c;

          ErrorLogUtil.log(
            exMessage,
            new List<String>{ 'Quote: ' + quote.Name, 'Product: ' + product.Name, 'Sales Org: ' + quote.Sales_Org__c }
          );

          AuraHandledException ex = new AuraHandledException(exMessage);
          ex.setMessage(exMessage);
          throw ex;
        }
        /*** END: PRODUCT SANITY CHECK ***/

        // Create the manual addon quote line based on the information received from the configuration page
        quoteLinesToUpsert.put(
          addonKey,
          GetVistexPriceControllerHelper.createManualAddonQuoteLine(quote.Id, addon, product, pbe, lineNumber, quote.CurrencyIsoCode)
        );
        lineNumber++;
      } else {
        // If line already exists...
        // Get the existing quote line and update the quantity
        SBQQ__QuoteLine__c ql = addonKeyQuoteLineMap.get(addonKey);
        ql.SBQQ__Quantity__c = addon.Quantity;

        // Add it to the upsert list
        quoteLinesToUpsert.put(addonKey, ql);
      }
    }

    System.debug('GetVistexPriceController - MANUAL ADDONS > Removing: ' + quoteLinesToRemove);
    System.debug('GetVistexPriceController - MANUAL ADDONS > Upserting: ' + quoteLinesToUpsert.values());

    SBQQ.TriggerControl.disable();
    QuoteTriggerHandler.disablePriceInSyncCalculation();
    try {
      delete quoteLinesToRemove;
      upsert quoteLinesToUpsert.values();
    } catch (Exception ex) {
      ErrorLogUtil.log('Error on upserting Quote Lines related to manual add-ons', ex);
      AuraHandledException e = new AuraHandledException('Error on upserting Quote Lines related to manual add-ons: ' + ex.getMessage());
      e.setMessage('Error on upserting Quote Lines related to manual add-ons: ' + ex.getMessage());
      throw e;
    } finally {
      SBQQ.TriggerControl.enable();
      QuoteTriggerHandler.enablePriceInSyncCalculation();
    }

    // Add the automatic add-on lines to the result map
    quoteLinesToUpsert.putAll(automaticAddonKeyQuoteLineMap);

    // Return all the add-on lines:  Add-on KEY -> Quote Line
    return quoteLinesToUpsert;
  }

  /***
   * @description Updates the Quote with the selected manual add-ons.
   * @param quoteId The quote Id.
   * @param addons List with the selected manual add-ons.
   */
  private static void processAddonShipToQuantityConfiguration(
    Id quoteId,
    List<ShipToQuantity> shipToQuantities,
    Map<String, SBQQ__QuoteLine__c> addonKeyQuoteLineMap
  ) {
    List<Ship_To_Quantity_Override__c> shipToQuantitiesToUpsert = new List<Ship_To_Quantity_Override__c>();
    List<Ship_To_Quantity_Override__c> shipToQuantitiesToDelete = new List<Ship_To_Quantity_Override__c>();

    // Create a map with AddonKey + ShipTo Id -> Ship To Quantity Config. AKA: What came from the UI.
    Map<String, ShipToQuantity> addonKeyShipToQuantityConfig = new Map<String, ShipToQuantity>();
    for (ShipToQuantity shipToConfig : shipToQuantities) {
      addonKeyShipToQuantityConfig.put(getShipToAddonKey(shipToConfig.ShipToId, shipToConfig.AddonKey), shipToConfig);
    }

    // Get the current Ship-to Quantity Override records for the addon lines.
    List<Ship_To_Quantity_Override__c> addonShipToQuantities = [
      SELECT Id, Quantity__c, Quote_Line__c, Quote_Line__r.Vistex_Add_on_key__c, Ship_to_Configuration__c, Ship_to_Configuration__r.Quote__c
      FROM Ship_To_Quantity_Override__c
      WHERE Ship_to_Configuration__r.Quote__c = :quoteId AND Quote_Line__r.Vistex_Manual_Add_on__c = TRUE
    ];

    System.debug('GetVistexPriceController - Quantity Overrides > Existing records: ' + addonShipToQuantities);

    // Create a map with AddonKey + ShipTo Id -> Ship To Quantity Override. AKA: What's in the database
    Map<String, Ship_To_Quantity_Override__c> addonKeyShipToQuantityMap = new Map<String, Ship_To_Quantity_Override__c>();

    for (Ship_To_Quantity_Override__c stq : addonShipToQuantities) {
      // Build the key: Ship To Id + addon key
      String key = getShipToAddonKey(stq.Ship_to_Configuration__c, stq.Quote_Line__r.Vistex_Add_on_key__c);

      System.debug('GetVistexPriceController - Quantity Overrides > Existing: ' + key);

      // If this key is NOT in the config coming from the UI, it needs to be removed from the database
      if (!addonKeyShipToQuantityConfig.containsKey(key)) {
        System.debug('GetVistexPriceController - Quantity Overrides > Removing: ' + key);
        shipToQuantitiesToDelete.add(stq);
        continue;
      }

      // If it's part of the configuration coming from the UI, add it to the map
      addonKeyShipToQuantityMap.put(key, stq);
      System.debug('GetVistexPriceController - Quantity Overrides > Updating: ' + key);
    }

    for (String key : addonKeyShipToQuantityConfig.keySet()) {
      // Get the configuration coming from the UI
      ShipToQuantity shipToQtyConfig = addonKeyShipToQuantityConfig.get(key);

      // If there is already a configuration stored in the data base, update it and add it to the list to be updated.
      if (addonKeyShipToQuantityMap.containsKey(key)) {
        Ship_To_Quantity_Override__c shipToQuantity = addonKeyShipToQuantityMap.get(key);
        shipToQuantity.Quantity__c = shipToQtyConfig.Quantity;
        shipToQuantitiesToUpsert.add(shipToQuantity);
      } else {
        // There should be a quote line associated to the addon
        if (!addonKeyQuoteLineMap.containsKey(shipToQtyConfig.AddonKey)) {
          System.debug(
            LoggingLevel.ERROR,
            'GetVistexPriceController - SHIP TO ADDONS > NO QUOTE LINE ASSOCIATED: ' + shipToQtyConfig.AddonKey
          );
          continue;
        }

        // Add a new Ship to Quantity Override record to be inserted in the database
        shipToQuantitiesToUpsert.add(
          new Ship_To_Quantity_Override__c(
            Quantity__c = shipToQtyConfig.Quantity,
            Ship_to_Configuration__c = shipToQtyConfig.ShipToId,
            Quote_Line__c = addonKeyQuoteLineMap.get(shipToQtyConfig.AddonKey).Id
          )
        );
      }
    }

    System.debug('GetVistexPriceController - SHIP TO ADDONS > shipToQuantitiesToDelete: ' + shipToQuantitiesToDelete);
    System.debug('GetVistexPriceController - SHIP TO ADDONS > shipToQuantitiesToUpsert: ' + shipToQuantitiesToUpsert);

    try {
      delete shipToQuantitiesToDelete;
      upsert shipToQuantitiesToUpsert;
    } catch (Exception ex) {
      ErrorLogUtil.log('Error on upserting Quantity Override configuration', ex);
      throw ex;
    }
  }

  /***
   * @description Updates the Quote with the selected manual add-ons.
   * @param quoteId The quote Id.
   * @param addons List with the selected manual add-ons.
   */
  private static void processApprovals(SBQQ__Quote__c quote, List<ApprovalInfo> approvalConfig) {
    System.debug('GetVistexPriceController - RX/DX APPROVAL > approvalConfig: ' + approvalConfig);

    if (approvalConfig.isEmpty()) {
      System.debug('GetVistexPriceController - RX/DX APPROVAL > No approvals. Clearing any previous approval.');

      if (String.isNotBlank(quote.Rx_Dx_Approval_Text__c)) {
        quote.Rx_Dx_Approval_Text__c = '';
        update quote;
      }

      return;
    }

    String NO_SUFFIX = 'NO_SUFFIX';

    Map<String, List<SBQQ__QuoteLine__c>> devicesLines = new Map<String, List<SBQQ__QuoteLine__c>>();

    for (SBQQ__QuoteLine__c quoteLine : quote.SBQQ__LineItems__r) {
      if (quoteLine.CPQ_Material_Type__c == 'Device') {
        // Get the line suffix
        String suffix = String.isBlank(quoteLine.Deal_Line_Group__c) ? NO_SUFFIX : quoteLine.Deal_Line_Group__c;

        if (!devicesLines.containsKey(suffix)) {
          devicesLines.put(suffix, new List<SBQQ__QuoteLine__c>());
        }

        devicesLines.get(suffix).add(quoteLine);
      }
    }

    String approvalText = '';

    for (ApprovalInfo approval : approvalConfig) {
      // Get the suffix of the Rx/Dx group
      String suffix = String.isBlank(approval.Suffix) ? NO_SUFFIX : approval.Suffix;

      List<String> deviceNames = new List<String>();

      if (!devicesLines.containsKey(suffix)) {
        System.debug('GetVistexPriceController - RX/DX APPROVAL > No quote lines with Suffix: ' + suffix);
        continue;
      }

      for (SBQQ__QuoteLine__c quoteLine : devicesLines.get(suffix)) {
        deviceNames.add(quoteLine.SBQQ__Product__r.Name);
      }

      approvalText += String.format(
        '{1}: {2}{0}' +
        '{3}: {7} {4}{0}' +
        '{5}: {7} {6}{0}{0}',
        new List<String>{
          '<br>',
          System.Label.Device_s,
          String.join(deviceNames, '/'),
           System.Label.Device_Total_Value,
          String.valueOf(approval.MaxValue.format()),
          System.Label.Selected_Rx_Dx_Value,
          String.valueOf(approval.CurrValue.format()),
          quote.CurrencyIsoCode
        }
      );
    }

    quote.Rx_Dx_Approval_Text__c = approvalText;
    update quote;
  }

  private static String getShipToAddonKey(Id shipToId, String addonKey) {
    return String.format('{0}-{1}', new List<String>{ shipToId, addonKey });
  }

  private static String buildAddonKey(String materialNumber, String dealNumber, String suffix) {
    return String.format('{0}{1}{2}', new List<String>{ materialNumber, dealNumber, suffix });
  }
}