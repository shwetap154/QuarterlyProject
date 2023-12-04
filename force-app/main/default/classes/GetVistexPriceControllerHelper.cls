/**
* File Name     :  GetVistexPriceControllerHelper
* @description  :  Helper class for GetVistexPriceController. It contains multiple auxiliar methods used by GetVistexPriceController.
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/06/2019     Cesar Sandrigo @ ATG    Created the Class. Moved helper methods from GetVistexPriceController.
*/
public without sharing class GetVistexPriceControllerHelper {
  private static final String MANAUAL_ADDON_GROUP = 'manAddonGrp';

  /**
   * @description Helper method that gets a list of manual addons from Response object.
   * @param vistexResponse Response object built from Vistex JSON response.
   * @param quote Quote object. It's used to know if the manual addon is already added to the quote.
   * @return List of manual addons.
   */
  public static Map<String, List<GetVistexPriceController.AddonGroup>> getManualAddons(
    SBQQ__Quote__c quote,
    VistexPricingResponse vistexResponse
  ) {
    // Map to store Group Name -> Addon Group
    List<GetVistexPriceController.AddonGroup> manualAddonGroups = new List<GetVistexPriceController.AddonGroup>();
    Map<String, GetVistexPriceController.AddonGroup> discountedAddonGroupMap = new Map<String, GetVistexPriceController.AddonGroup>();
    Map<String, GetVistexPriceController.AddonGroup> rxDxAddonGroupMap = new Map<String, GetVistexPriceController.AddonGroup>();

    // Map to store Group Name -> List of Addons
    Map<String, List<GetVistexPriceController.AddonInfo>> addonInfoMap = new Map<String, List<GetVistexPriceController.AddonInfo>>();

    // CPQATG-1291 If the offer is Type: Choice Financed Offer,
    CPQ_Warranty_Addons__c warrantyConfig = CPQ_Warranty_Addons__c.getOrgDefaults();
    List<String> uSProgramTypeChoiceFinancedList = warrantyConfig.US_Program_Type_Choice_Financed__c != null ?
      warrantyConfig.US_Program_Type_Choice_Financed__c.split(',') : new List<String> ();

    // Query parent bundle line to get product code
    List<SBQQ__QuoteLine__c> parentLine = [SELECT Id, SBQQ__ProductCode__c, SBQQ__Quote__c, SBQQ__Product__r.Vistex_Deal_Header__c,
      Vistex_Deal_Header__c
      FROM SBQQ__QuoteLine__c
      WHERE SBQQ__Product__r.Vistex_Deal_Header__c != null
      AND SBQQ__Quote__c = :quote.Id
      LIMIT 1];    

    System.debug('getManualAddons > Processing Add-ons: ' + vistexResponse.ET_ADDONS.ITEM.size());

    for (Integer i = 0; i < vistexResponse.ET_ADDONS.ITEM.size(); i++) {
      // Get the item from the response
      VistexPricingResponse.AddonItem item = vistexResponse.ET_ADDONS.ITEM[i];

      // Only process manual addons. ADDON_AUTO_APPLY != 'X'
      if (item.ADDON_AUTO_APPLY == 'X') {
        continue;
      }

      // If GROUP is populated, it means this Item is the header of the group.
      if (String.isNotBlank(item.GROUP_Z)) {
        // Create the group, and assign it the group identifier
        GetVistexPriceController.AddonGroup addonGroup = new GetVistexPriceController.AddonGroup();
        addonGroup.GroupId = item.GROUP_Z;

        // If the next price has a value, that means it's an Rx/Dx group
        if (item.NET_PRICE != null && item.NET_PRICE > 0) {
          addonGroup.MaxValue = item.NET_PRICE;
          rxDxAddonGroupMap.put(addonGroup.GroupId, addonGroup);

          System.debug('getManualAddons > Rx/Dx group: ' + item.GROUP_Z);
        } else {
          // If not, it's a discounted add-on
          addonGroup.MaxQuantity = item.ADDON_QUAN_SALES_UNIT;
          addonGroup.UnitOfMeasure = item.SALES_UNIT;
          discountedAddonGroupMap.put(addonGroup.GroupId, addonGroup);

          System.debug('getManualAddons > Discounted Add-on group: ' + item.GROUP_Z);
        }
      } else {
        // If the Group is not populated, that means it's either a group item or an stand-alone manual add-on
        GetVistexPriceController.AddonInfo addon = new GetVistexPriceController.AddonInfo();
        addon.Id = i;
        addon.MaterialNumber = item.MATERIAL;
        addon.MaterialName = item.MATERIAL_DESC;
        addon.NetPrice = item.NET_PRICE;
        addon.UnitPrice = item.NET_PRICE;
        addon.Quantity = 0;
        addon.DealSuffix = item.DEAL_SUFFIX;
        addon.DealNumber = item.DEAL;
        addon.AddonType = GetVistexPriceController.ADDON_TYPE_MANUAL;
        addon.ManualAddonMandatory = !parentLine.isEmpty() ? (uSProgramTypeChoiceFinancedList.contains(parentLine[0].SBQQ__ProductCode__c) ? true : false) : false ; //CPQATG-1291

        System.debug('getManualAddons > Manual Addon Item Deal: ' + item.DEAL);
        System.debug('getManualAddons > Manual Addon CS: ' + uSProgramTypeChoiceFinancedList);
        System.debug('getManualAddons > Manual Addon Mandatory: ' + addon.ManualAddonMandatory);

        // If GROUP_REF if defined, that means it's an part of a group
        if (String.isNotBlank(item.GROUP_REF)) {
          System.debug('getManualAddons > Add-on Group Item: ' + item.GROUP_REF);

          // Assing it to the group
          addon.GroupId = item.GROUP_REF;

          // Add it the the Group Name -> AddonInfo map
          if (!addonInfoMap.containsKey(addon.GroupId)) {
            addonInfoMap.put(addon.GroupId, new List<GetVistexPriceController.AddonInfo>());
          }

          // Add the addon to the Map: Group Name -> List of Addons
          addonInfoMap.get(addon.GroupId).add(addon);
        } else {
          // If it's not part of a group, that means that it's an standalone Manual add-on
          System.debug('getManualAddons > Processing Manual Add-on item');

          // Create an specific group for wrapping the Manual Add-on
          GetVistexPriceController.AddonGroup addonGroup = new GetVistexPriceController.AddonGroup();
          addonGroup.GroupId = MANAUAL_ADDON_GROUP + i;
          addonGroup.MaxQuantity = item.ADDON_QUAN_SALES_UNIT;
          addonGroup.UnitOfMeasure = item.SALES_UNIT;

          // Set the addon group to the AddonInfo object, and the Quantity
          addon.GroupId = addonGroup.GroupId;
          addon.Quantity = item.ADDON_QUAN_SALES_UNIT;

          // Add the addon to the group we just created.
          addonGroup.RelatedAddons = new List<GetVistexPriceController.AddonInfo>{ addon };

          // Finaly add the manual addon group to the list
          manualAddonGroups.add(addonGroup);
        }
      }
    }

    List<GetVistexPriceController.AddonInfo> rxdxAddons = new List<GetVistexPriceController.AddonInfo>();

    // Assigning the Addons to the Groups
    for (String groupKey : addonInfoMap.keySet()) {
      // Get the addon
      List<GetVistexPriceController.AddonInfo> addons = addonInfoMap.get(groupKey);

      // Populate the related addons to the group and add it to the result list
      if (discountedAddonGroupMap.containsKey(groupKey)) {
        discountedAddonGroupMap.get(groupKey).RelatedAddons = addons;
      } else if (rxDxAddonGroupMap.containsKey(groupKey)) {
        rxDxAddonGroupMap.get(groupKey).RelatedAddons = addons;
        rxdxAddons.addAll(addons);
      } else {
        System.debug(LoggingLevel.WARN, 'getManualAddons > No Addon Group found for group: ' + groupKey);
      }
    }

    // Populate the Unit Price for Rx/Dx Add-ons
    populateRxDxAddonUnitPrice(rxdxAddons, quote.Sales_Org__c, quote.CurrencyIsoCode);

    System.debug('getManualAddons > Manual Add-ons: ' + manualAddonGroups.size());
    System.debug('getManualAddons > Discounted Add-ons Groups: ' + discountedAddonGroupMap.values().size());
    System.debug('getManualAddons > RxDx Consumable Groups: ' + rxDxAddonGroupMap.values().size());

    Map<String, List<GetVistexPriceController.AddonGroup>> result = new Map<String, List<GetVistexPriceController.AddonGroup>>();
    result.put(GetVistexPriceController.ADDON_TYPE_MANUAL, manualAddonGroups);
    result.put(GetVistexPriceController.ADDON_TYPE_DISCOUNTED, discountedAddonGroupMap.values());
    result.put(GetVistexPriceController.ADDON_TYPE_RXDX, rxDxAddonGroupMap.values());

    return result;
  }

  /**
   * @description Helper method that returns a list with all the AUTOMATIC ADDON items from the Vistex response.
   * @param vistexResponse Response object from Vistex.
   * @return List of Vistex add-on items.
   */
  public static Double getVistexItemValueBasedOnMarketConfig(
    VistexPricingResponse.ResultItem vistexItem,
    String marketSpecificField,
    Boolean isLineTotal
  ) {
    String json = System.JSON.serialize(vistexItem);
    Map<String, Object> jsonMap = (Map<String, Object>) System.JSON.deserializeUntyped(json);

    Double linePrice = Double.valueOf(jsonMap.get(marketSpecificField));
    Double quantity = Double.valueOf(jsonMap.get('QUANTITY'));

    if (!isLineTotal || quantity == 1.0 || quantity == 0.0) {
      return linePrice;
    }

    return linePrice / quantity;
  }

  /**
   * @description Helper method that returns a list with all the AUTOMATIC ADDON items from the Vistex response.
   * @param vistexResponse Response object from Vistex.
   * @return List of Vistex add-on items.
   */
  public static List<VistexPricingResponse.ResultItem> getAutomaticAddonsResponseItems(VistexPricingResponse vistexResponse) {
    List<VistexPricingResponse.ResultItem> addonItems = new List<VistexPricingResponse.ResultItem>();

    for (VistexPricingResponse.ResultItem item : vistexResponse.ES_RESULT.ITEM.ITEM) {
      if (item.ADDON == 'X') {
        addonItems.add(item);
      }
    }

    return addonItems;
  }

  /***
   * @description Helper method that returns a Map with additional information abou
   * @param vistexResponse Response object from Vistex.
   */
  public static Map<String, VistexPricingResponse.AddonItem> getAutomaticAddonsAddintionalInfo(VistexPricingResponse vistexResponse) {
    Map<String, VistexPricingResponse.AddonItem> additionalInfoMap = new Map<String, VistexPricingResponse.AddonItem>();

    for (VistexPricingResponse.AddonItem item : vistexResponse.ET_ADDONS.ITEM) {
      if (item.ADDON_AUTO_APPLY == 'X') {
        additionalInfoMap.put(item.ITEMNO_SD_DOC, item);
      }
    }

    return additionalInfoMap;
  }

  /**
   * @description Helper method that builds a Map with the Response items related to
   *				quote lines (excluding add-on line) to easy process them.
   * @param vistexResponse Response object built from Vistex JSON response.
   */
  public static Map<Integer, VistexPricingResponse.ResultItem> buildResponseItemMap(VistexPricingResponse vistexResponse) {
    Map<Integer, VistexPricingResponse.ResultItem> itemsMap = new Map<Integer, VistexPricingResponse.ResultItem>();

    for (VistexPricingResponse.ResultItem item : vistexResponse.ES_RESULT.ITEM.ITEM) {
      //if (item.ADDON != 'X') { // FIXME: IT SHOULD BE FINE TO INCLUDE ALL THE LINES
      Integer itemNumber = Integer.valueOf(item.COND_ITEM_NO);
      itemsMap.put(itemNumber, item);
      //}
    }

    return itemsMap;
  }

  /**
   * @description Helper method that builds a Map with the Material Number as a key and the Product related to it as the value.
   * @param materialNumberSet	Set of material numbers
   * @param salesOrgId		Id of the sales org to get the Price Book Entires.
   */
  public static Map<String, Product2> buildMaterialNumberProductMap(Set<String> materialNumberSet, String salesOrgId, String currIsoCode) {
    // Get the related products, and the Pricebook Entries for the product in the Sales Org
    List<Product2> products = [
      SELECT
        Id,
        Name,
        SAP_Material__r.SAP_Product_Number__c,
        CPQ_Material_Type__c,
        CPQ_Material_Type_Group__c,
        (
          SELECT Id, Pricebook2Id, SAP_Unit_Of_Measure__c, UnitPrice
          FROM PricebookEntries
          WHERE
            IsActive = TRUE
            AND Pricebook2.IsActive = TRUE
            AND Pricebook2.SAP_Sales_Org_ID__c = :salesOrgId
            AND CurrencyIsoCode = :currIsoCode
        )
      FROM Product2
      WHERE IsActive = TRUE AND SAP_Material__r.SAP_Product_Number__c IN :materialNumberSet
    ];

    // Material Number -> Product
    Map<String, Product2> materialNumberProductMap = new Map<String, Product2>();

    // Build the map
    for (Product2 product : products) {
      if (!materialNumberProductMap.containsKey(product.SAP_Material__r.SAP_Product_Number__c)) {
        materialNumberProductMap.put(product.SAP_Material__r.SAP_Product_Number__c, product);
      }
    }

    return materialNumberProductMap;
  }

  /**
   * @description
   * @param quoteId
   * @param addonInfo
   * @param product
   * @param pbe
   * @param lineNumber	The number of the line that's being created
   */
  public static SBQQ__QuoteLine__c createManualAddonQuoteLine(
    Id quoteId,
    GetVistexPriceController.AddonInfo addonInfo,
    Product2 product,
    PricebookEntry pbe,
    Integer lineNumber,
    String currIsoCode
  ) {
    // Create the basic quote line
    SBQQ__QuoteLine__c quoteLine = createQuoteLine(quoteId, product, pbe, lineNumber, currIsoCode);

    // Set the quantity
    quoteLine.SBQQ__Quantity__c = addonInfo.Quantity;

    // Vistex specific fields
    quoteLine.Vistex_Automatic_Add_on__c = false;
    quoteLine.Vistex_Manual_Add_on__c = true;
    quoteLine.Deal_Line_Group__c = addonInfo.DealSuffix;
    quoteLine.Vistex_Sales_Deal__c = addonInfo.DealNumber;

    return quoteLine;
  }

  /**
   * @description
   * @param quoteId
   * @param addonInfo
   * @param product
   * @param pbe
   * @param lineNumber	The number of the line that's being created
   */
  public static SBQQ__QuoteLine__c createQuoteLine(
    Id quoteId,
    Product2 product,
    PricebookEntry pbe,
    Integer lineNumber,
    String currIsoCode
  ) {
    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
    quoteLine.SBQQ__Quote__c = quoteId;
    quoteLine.SBQQ__Quantity__c = 1;
    quoteLine.SBQQ__Product__c = product.Id;
    quoteLine.SBQQ__Number__c = lineNumber;
    quoteLine.CurrencyIsoCode = currIsoCode;

    /* HACK: Usually, assigning the Product ID to a quote line is enough to get everything else populated (PBE and all the twin fields).
     * But since this is done by a queueable, not always is finished as soon as it's needed.
     * In the current implementation we do two call to the controller: one for creating the Manual Add-an Line and the second (right after)
     * to get the price for those manual addons. Some times when the second call is trying to update the quote line this doesn't have all
     * the fields populated yet.
     * NOTE: We don't do everything in a single call because SFDC doesn't allow to do a callout after a DML operation.
     */
    quoteLine.SBQQ__PricebookEntryId__c = pbe.Id;
    quoteLine.SBQQ__ListPrice__c = pbe.UnitPrice;
    quoteLine.SAP_Unit_Of_Measure__c = pbe.SAP_Unit_Of_Measure__c;
    quoteLine.CPQ_Material_Type__c = product.CPQ_Material_Type__c;

    /* FIXME: not adding the line inside the bundle for now, because it can cause issues if the user wants to re-configure the bundle */
    //newAddonLine.SBQQ__RequiredBy__c = parentQuoteLineId; // Add it inside of the bundle

    return quoteLine;
  }

  /**
   * @description Populates the unit price to the addonInfo objects
   * @param rxdxAddons
   * @param salesOrgId
   */
  private static void populateRxDxAddonUnitPrice(
    List<GetVistexPriceController.AddonInfo> rxdxAddons,
    String salesOrgId,
    String currIsoCode
  ) {
    if (rxdxAddons == null || rxdxAddons.isEmpty()) {
      return;
    }

    // Material Number -> List of Addon
    Map<String, List<GetVistexPriceController.AddonInfo>> materialRxDxAddonMap = new Map<String, List<GetVistexPriceController.AddonInfo>>();

    for (GetVistexPriceController.AddonInfo addon : rxdxAddons) {
      if (!materialRxDxAddonMap.containsKey(addon.MaterialNumber)) {
        materialRxDxAddonMap.put(addon.MaterialNumber, new List<GetVistexPriceController.AddonInfo>());
      }
      materialRxDxAddonMap.get(addon.MaterialNumber).add(addon);
    }

    // Get the Products related to the materials and the price for the current market
    Map<String, Product2> productMap = buildMaterialNumberProductMap(materialRxDxAddonMap.keySet(), salesOrgId, currIsoCode);

    for (String materialNumber : materialRxDxAddonMap.keySet()) {
      /*** BEGIN: PRODUCT SANITY CHECK ***/

      // Check if the product was found in the database
      if (!productMap.containsKey(materialNumber)) {
        throw new AuraException('No active Products were found for Material: ' + materialNumber);
      }

      // Get the product record from the map
      Product2 product = productMap.get(materialNumber);

      // Check if the product has a Price Book Entry in the Pricebook related to the Sales Org
      if (product.PricebookEntries.isEmpty()) {
        throw new AuraException('The Product [' + product.Name + '] does not have a Price for Sales Org: ' + salesOrgId);
      }

      // Get the Price Book Entry associated to the product in this market
      PricebookEntry pbe = product.PricebookEntries[0];

      // Check Unit of Measure associated to the Price Book Entry
      if (String.isBlank(pbe.SAP_Unit_Of_Measure__c)) {
        throw new AuraException(
          'The price defined for Product [' +
          product.Name +
          '] does not have a valid SAP Unit of Measure for Sales Org: ' +
          salesOrgId
        );
      }

      /*** END: PRODUCT SANITY CHECK ***/

      // Populate the list price on the addons associated to the material
      for (GetVistexPriceController.AddonInfo addon : materialRxDxAddonMap.get(materialNumber)) {
        addon.UnitPrice = pbe.UnitPrice;
        addon.NetPrice = 0;
      }
    }
  }

  /**
   * @description Retuns the date formated as YYYYMMDD based on the date passed as parameter or the current date, if it's null.
   * @param aDate A date.
   */
  public static String getFormatedDate(Date aDate) {
    DateTime dt = aDate == null ? DateTime.now() : DateTime.newInstance(aDate.year(), aDate.month(), aDate.day());
    return dt.format('yyyyMMdd');
  }
}