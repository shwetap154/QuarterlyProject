/**
* File Name     :  CPQ_OrderTriggerHandler
* @description  :  Handler class for CPQ_OrderTrigger.  Runs validations on SAP values and creates the SAP contract text objects 
                    that SAP picks up in the SFDC order > SAP contract query
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/19/2019		Cesar Sandrigo @ ATG    Created the Class.
* 2.0     2/3/2020      Cory Bartholomew @ ATG  Updated contract text creation to add translated deal text from quote. Updated descriptions
* 2.1     7/17/2020     Cesar Sandrigo @ ATG    Added text for Ship-to and Quantity configuration
*/
public with sharing class CPQ_OrderTriggerHandler {
  private static final String LINE_BREAK = '\n\r';
  private static final String FORMULA_BR = '_BR_ENCODED_';
  private static final Integer MAX_TEXT_LENGTH = 132;

  /**
   * @description Handles the Before Insert event.
   * @param triggerNewList List of new version of the orders, provided by the trigger.   
   */
  public static void handleBeforeInsert(List<Order> triggerNewList) {
    
    //CPQATG-1288
    setPreInstallCheckListLookup(triggerNewList);
  }  
  
  /**
   * @description Handles the After Update event.
   * @param triggerNewList List of new version of the orders, provided by the trigger.
   * @param triggerOldMap Map of old version of the orders, provided by the trigger.
   */
  public static void handleAfterUpdate(List<Order> triggerNewList, Map<Id, Order> triggerOldMap) {
    Map<Id, Order> activatedOrdersMap = new Map<Id, Order>();

    // Build a map with activated orders
    for (
      Order activatedOrder : (List<Order>) ApexUtils.findChangedRecsWithMatchingVal(
        triggerNewList,
        triggerOldMap,
        Schema.Order.Status,
        'Activated'
      )
    ) {
      activatedOrdersMap.put(activatedOrder.Id, activatedOrder);
    }

    // Build SAP Contract Texts for activated orders
    buildSAPContractTexts(activatedOrdersMap);
  }

  /**
   * @description Handles the Before Update event.
   * @param triggerNewList List of new version of the orders, provided by the trigger.
   * @param triggerOldMap Map of old version of the orders, provided by the trigger.
   */
  public static void handleBeforeUpdate(List<Order> triggerNewList, Map<Id, Order> triggerOldMap) {
    // Validate all the Items have Item Categoty and Usage Type before Activate the Order
    validateItemCategoryAndUsageTypeBeforeActivate(triggerNewList, triggerOldMap);
  }

  /**
   * @description Populate lookup to the related Pre-Install checklist record.
   * @param newList List of new version of the orders, provided by the trigger.   
   */
  private static void setPreInstallCheckListLookup(List<Order> newList) {
    

    Set<Id> quoteIds = new Set<Id> ();
    Map<Id,Id> quotePreInstallMap = new Map<Id,Id> ();

    for (Order order : newList) {
      quoteIds.add(order.SBQQ__Quote__c);
    }
    

    List<PreInstallCheckList__c> preInstallCheckList = [SELECT Id, Quote__c
                                                        FROM PreInstallCheckList__c
                                                        WHERE Quote__c IN :quoteIds];

    
    System.debug('CPQ_OrderTriggerHandler, setPreInstallCheckListLookup preInstallCheckList ' + preInstallCheckList);
    for (PreInstallCheckList__c preInstall : preInstallCheckList) {
      quotePreInstallMap.put(preInstall.Quote__c,preInstall.Id);
    }

    for (Order order : newList) {
      if (quotePreInstallMap.containsKey(order.SBQQ__Quote__c)) {
        order.PreInstallCheckList__c = quotePreInstallMap.get(order.SBQQ__Quote__c);
      }
    }
  }

  /**
   * @description Validates if the Items of the Orders being activated have Item Category and Usage Type.
   * @param newList List of new version of the orders, provided by the trigger.
   * @param oldMap Map of old version of the orders, provided by the trigger.
   */
  private static void validateItemCategoryAndUsageTypeBeforeActivate(List<Order> newList, Map<Id, Order> oldMap) {
    Map<String, Order> ordersBeingActivated = new Map<String, Order>();

    // Build a map with activated orders
    for (Order activatedOrder : (List<Order>) ApexUtils.findChangedRecsWithMatchingVal(newList, oldMap, Schema.Order.Status, 'Activated')) {
      ordersBeingActivated.put(activatedOrder.Id, activatedOrder);
    }

    /* Get the order items related to the Orders that are being activated that
     * are not commitment spread line and don't have Usage Type or Item Category defined */
    List<OrderItem> orderItems = [
      SELECT Id, OrderId, OrderItemNumber
      FROM OrderItem
      WHERE
        SBQQ__QuoteLine__r.SBQQ__Bundle__c = FALSE // Ignore bundle lines
        AND Is_Spread_Commitment_Line__c = FALSE
        AND SBQQ__QuoteLine__r.Exclude_from_SAP__c = FALSE
        AND (SAP_Usage_Type__c = NULL
        OR SAP_Item_Category__c = NULL
        OR SAP_Usage_Type__c = ''
        OR SAP_Item_Category__c = '')
        AND OrderId IN :ordersBeingActivated.keySet()
    ];

    // Group invalid items per Order
    Map<String, List<OrderItem>> orderItemsGroupedByOrderId = (Map<String, List<OrderItem>>) ApexUtils.groupBy(
      orderItems,
      Schema.OrderItem.OrderId
    );

    for (String orderId : orderItemsGroupedByOrderId.keySet()) {
      // Should contains, but check it to be safe
      if (!ordersBeingActivated.containsKey(orderId)) {
        continue;
      }

      // Get the item list that are wrong
      List<String> invalidItemNumbers = new List<String>();

      for (OrderItem item : orderItemsGroupedByOrderId.get(orderId)) {
        invalidItemNumbers.add(item.OrderItemNumber);
      }

      // Add error message to the order
      ordersBeingActivated.get(orderId)
        .addError(
          'Order cannot be Activated. The following item(s) do not have a valid Item Category or Usage Type: ' +
          String.join(invalidItemNumbers, ', ')
        );
    }
  }

  /**
   * @description Creates the SAP Contract text records for the Orders passed as parameter.
   * @param ordersMap Map of Orders.
   */
  private static void buildSAPContractTexts(Map<Id, Order> ordersMap) {
    // If there's no oders to be processed, get out of here
    if (ordersMap.isEmpty()) {
      return;
    }

    // Delete previous version of the SAP Contract Text, if it exists
    // FIXME: This code should not be needed, but it's useful for testing. REMOVE AFTER TEST!
    List<SAP_Contract_Text__c> sapContractTextsToBeDeleted = [SELECT Id FROM SAP_Contract_Text__c WHERE Order__c = :ordersMap.keySet()];
    if (!sapContractTextsToBeDeleted.isEmpty()) {
      delete sapContractTextsToBeDeleted;
    }

    // Get the Order Items related to the Orders
    List<OrderItem> orderItemsList = [
      SELECT Id, OrderId, Initial_Order_Text__c, Auto_Shipment_Text__c, Contract_Charge_Text__c
      FROM OrderItem
      WHERE OrderId = :ordersMap.keySet()
      ORDER BY OrderItemNumber
    ];

    // Create and populate a Map with OrderId -> List of Items
    Map<Id, List<OrderItem>> orderIdOrderItemsMap = new Map<Id, List<OrderItem>>();

    for (OrderItem oItem : orderItemsList) {
      if (!orderIdOrderItemsMap.containsKey(oItem.OrderId)) {
        orderIdOrderItemsMap.put(oItem.OrderId, new List<OrderItem>());
      }

      orderIdOrderItemsMap.get(oItem.OrderId).add(oItem);
    }

    // List to store the SAP Contract Text records to be created
    List<SAP_Contract_Text__c> sapContractTextsToBeCreated = new List<SAP_Contract_Text__c>();

    for (Id orderId : orderIdOrderItemsMap.keySet()) {
      // Get the Order record, to retrieve Header Text information
      Order currOrder = ordersMap.get(orderId);

      //CPQATG-679 Map the translated deal text values to a SAP Contract Text
      if (!String.isBlank(currOrder.Rebate_Commitment__c)) {
        sapContractTextsToBeCreated.add(createContractText(currOrder.Id, 'ZC01', currOrder.Rebate_Commitment__c));
      }
      if (!String.isBlank(currOrder.vistex_banner_zprm_translated__c)) {
        sapContractTextsToBeCreated.add(createContractText(currOrder.Id, 'ZC01', currOrder.vistex_banner_zprm_translated__c));
      }
      if (!String.isBlank(currOrder.vistex_banner_zter_translated__c)) {
        sapContractTextsToBeCreated.add(createContractText(currOrder.Id, 'ZC01', currOrder.vistex_banner_zter_translated__c));
      }
      if (!String.isBlank(currOrder.vistex_banner_zcpq_translated__c)) {
        sapContractTextsToBeCreated.add(createContractText(currOrder.Id, 'ZC01', currOrder.vistex_banner_zcpq_translated__c));
      }
      if (!String.isBlank(currOrder.vistex_banner_zprq_translated__c)) {
        sapContractTextsToBeCreated.add(createContractText(currOrder.Id, 'ZC01', currOrder.vistex_banner_zprq_translated__c));
      }
      if (!String.isBlank(currOrder.Notes_for_SAP__c)) {
        sapContractTextsToBeCreated.add(createContractText(currOrder.Id, 'ZC01', 'CPQ Notes: ' + currOrder.Notes_for_SAP__c));
      }
      //CPQATG-1247 - Pass text "Quote for ineligible offer - update Vistex eligibility" to SAP
      if (currOrder.Ineligible_Offer__c) {
        sapContractTextsToBeCreated.add(createContractText(currOrder.Id, 'ZC01', 'Quote for ineligible offer - update Vistex eligibility'));
      }

      String initialOrderItemsText = '';
      String autoShipItemsText = '';
      String programChargesText = '';

      for (OrderItem oItem : orderIdOrderItemsMap.get(orderId)) {
        // If Initial Order Text is not empty for this item, add it
        if (!String.isBlank(oItem.Initial_Order_Text__c)) {
          initialOrderItemsText += ((String.isBlank(initialOrderItemsText) ? '' : LINE_BREAK) + oItem.Initial_Order_Text__c);
        }

        // If Auto-ship Text is not empty for this item, add it
        if (!String.isBlank(oItem.Auto_Shipment_Text__c)) {
          autoShipItemsText += ((String.isBlank(autoShipItemsText) ? '' : LINE_BREAK) + oItem.Auto_Shipment_Text__c);
        }

        // If Program Charges Text is not empty for this item, add it
        if (!String.isBlank(oItem.Contract_Charge_Text__c)) {
          programChargesText += ((String.isBlank(programChargesText) ? '' : LINE_BREAK) + oItem.Contract_Charge_Text__c);
        }
      }

      // If there is Header Text for Misc. Information, create a record
      if (!String.isBlank(currOrder.Contract_Text_Misc_Information__c) || !String.isBlank(programChargesText)) {
        sapContractTextsToBeCreated.add(
          new SAP_Contract_Text__c(
            Order__c = orderId,
            SAP_Text_ID__c = 'ZC01', // Misc. Information
            Text__c = (String.isBlank(currOrder.Contract_Text_Misc_Information__c)
                ? ''
                : currOrder.Contract_Text_Misc_Information__c.replace(FORMULA_BR, LINE_BREAK)) +
              (String.isBlank(programChargesText) ? '' : LINE_BREAK + programChargesText)
          )
        );
      }

      // If there is Header Text for Distributor Rep Information
      if (!String.isBlank(currOrder.Contract_Text_Distributor_Rep_Info__c)) {
        sapContractTextsToBeCreated.add(
          new SAP_Contract_Text__c(
            Order__c = orderId,
            SAP_Text_ID__c = 'ZC04',
            Text__c = currOrder.Contract_Text_Distributor_Rep_Info__c.replace(FORMULA_BR, LINE_BREAK)
          )
        );
      }

      // If there is Header Text for External Rep Information
      if (!String.isBlank(currOrder.Contract_Text_External_Foreign_Rep__c)) {
        sapContractTextsToBeCreated.add(
          new SAP_Contract_Text__c(
            Order__c = orderId,
            SAP_Text_ID__c = 'ZC05', // External Rep Information
            Text__c = currOrder.Contract_Text_External_Foreign_Rep__c
          )
        );
      }

      // If there is an Initial Order text, create a record to store it
      if (!String.isBlank(initialOrderItemsText)) {
        sapContractTextsToBeCreated.add(
          new SAP_Contract_Text__c(
            Order__c = orderId,
            SAP_Text_ID__c = 'ZC03', // Initial Order Quantity
            Text__c = initialOrderItemsText
          )
        );
      }

      // If there is an Initial Order text, create a record to store it
      if (!String.isBlank(autoShipItemsText)) {
        sapContractTextsToBeCreated.add(
          new SAP_Contract_Text__c(
            Order__c = orderId,
            SAP_Text_ID__c = 'ZC02', // Auto-Ship Information
            Text__c = /* HEADER TEXT + */ autoShipItemsText
          )
        );
      }

      // FIXME: Querying within a for loop
      String shipToText = buildShipToText(currOrder.SBQQ__Quote__c);
      if (!String.isBlank(shipToText)) {
        sapContractTextsToBeCreated.add(
          new SAP_Contract_Text__c(
            Order__c = orderId,
            SAP_Text_ID__c = 'ZC06', // Ship-to Information
            Text__c = shipToText
          )
        );
      }
    }

    if (!sapContractTextsToBeCreated.isEmpty()) {
      insert sapContractTextsToBeCreated;
    }
  }

  /**
     * @description Creates and returns an SAP Contract text record.
     * @param orderId The order to associate the contract text with.
     * @param sapTextId The inidcator of the SAP text values that determines which SAP field it maps to:
     *      ZC01 - Misc. Contract Information 
            ZC02 - Auto-ship Information 
            ZC03 - Initial Order Information 
            ZC04 - Distributor Rep. 
            ZC05 - External / Foreign Rep
            ZC06 - Ship-to / Quantity Text
     * @param text The text to pass to SAP
     */
  private static SAP_Contract_Text__c createContractText(Id orderId, String sapTextId, String text) {
    return new SAP_Contract_Text__c(
      Order__c = orderId,
      SAP_Text_ID__c = sapTextId, // Initial Order Quantity
      Text__c = text
    );
  }

  private static String buildShipToText(Id quoteId) {
    // Get the quote, quote lines and ship to configurations
    SBQQ__Quote__c quote = [
      SELECT
        Id,
        (
          SELECT
            Id,
            Name,
            SBQQ__Product__r.SAP_Product_Number__c,
            Is_Quantity_Overridable__c,
            Vistex_Automatic_Add_on__c,
            Vistex_Manual_Add_on__c,
            Is_Spread_Commitment_Line__c,
            Program_Charge_Type__c,
            Rebate_Consumable__c
          FROM SBQQ__LineItems__r
          WHERE Exclude_from_SAP__c = FALSE OR Vistex_Automatic_Add_on__c = TRUE
        ),
        (SELECT Quantity__c, Ship_to_Address__r.Name, Ship_to_Address__r.ZTS_US_Source_Account_Number__c FROM Ship_to_Configurations__r)
      FROM SBQQ__Quote__c
      WHERE Id = :quoteId
    ];

    // Get the ship to overrides
    List<Ship_To_Quantity_Override__c> quantityOverrides = [
      SELECT
        Id,
        Quantity__c,
        Quote_Line__c,
        Ship_to_Configuration__c,
        Ship_to_Configuration__r.Ship_to_Address__r.ZTS_US_Source_Account_Number__c
      FROM Ship_To_Quantity_Override__c
      WHERE Quote_Line__r.SBQQ__Quote__c = :quoteId
    ];

    Map<String, Ship_To_Quantity_Override__c> quantityOverrideMap = new Map<String, Ship_To_Quantity_Override__c>();

    for (Ship_To_Quantity_Override__c qo : quantityOverrides) {
      quantityOverrideMap.put(String.format('{0}{1}', new List<String>{ qo.Quote_Line__c, qo.Ship_to_Configuration__c }), qo);
    }

    String shipToText = '';

    for (SBQQ__QuoteLine__c quoteLine : quote.SBQQ__LineItems__r) {
      // Check if the line has a material number associated
      if (String.IsBlank(quoteLine.SBQQ__Product__r.SAP_Product_Number__c)) {
        System.debug('buildShipToText > [IGNORED] No SAP Material Number for line: ' + quoteLine.Name);
        continue;
      }

      // Exclude the commitment spread lines from the text
      if (quoteLine.Is_Spread_Commitment_Line__c) {
        System.debug('buildShipToText > [IGNORED] Commitment Spread line: ' + quoteLine.Name);
        continue;
      }

      // Exclude the commitment spread lines from the text
      if (quoteLine.Rebate_Consumable__c) {
        System.debug('buildShipToText > [IGNORED] Rebate Consumable line: ' + quoteLine.Name);
        continue;
      }

      // Exclude the commitment spread lines from the text
      if (String.isNotBlank(quoteLine.Program_Charge_Type__c)) {
        System.debug('buildShipToText > [IGNORED] Program Charge line: ' + quoteLine.Name);
        continue;
      }

      for (Ship_to_Configuration__c shipTo : quote.Ship_to_Configurations__r) {
        String key = String.format('{0}{1}', new List<String>{ quoteLine.Id, shipTo.Id });

        Boolean hasOverride = quantityOverrideMap.containsKey(key);

        if ((quoteLine.Vistex_Automatic_Add_on__c || quoteLine.Vistex_Manual_Add_on__c) && !hasOverride) {
          System.debug(
            'buildShipToText > No override for Add-on Line. MAT: ' +
            quoteLine.SBQQ__Product__r.SAP_Product_Number__c +
            ' - ADDR: ' +
            shipTo.Ship_to_Address__r.Name
          );
          continue;
        }

        Ship_To_Quantity_Override__c qtyOverride = quantityOverrideMap.get(key);

        shipToText += String.format(
          'Qty: {0}  Material: {1}  Address: {2} ({3}){4}',
          new List<String>{
            hasOverride
              ? String.valueOf(qtyOverride.Quantity__c)
              : String.valueOf(shipTo.Quantity__c), // Quantity
            quoteLine.SBQQ__Product__r.SAP_Product_Number__c, // Material Number
            shipTo.Ship_to_Address__r.ZTS_US_Source_Account_Number__c, // Address Number
            shipTo.Ship_to_Address__r.Name, // Address Name
            LINE_BREAK
          }
        );
      }
    }

    return shipToText;
  }
}