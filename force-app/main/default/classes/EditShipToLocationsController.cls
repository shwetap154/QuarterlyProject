/**
* File Name     :  EditShipToLocationsController
* @description  :  Controller class for the Ship-To Configuration page. Called mainly from configureShipToLocationsAndQuantities LWC
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/27/2020    Cesar Sandrigo @ ATG     Created the Class. 
*/
public with sharing class EditShipToLocationsController {
  public class QuantityOverride {
    @AuraEnabled
    public String Id { get; set; }

    @AuraEnabled
    public String QuoteLineId { get; set; }

    @AuraEnabled
    public String ShipToId { get; set; }

    @AuraEnabled
    public String ShipToAddressId { get; set; }

    @AuraEnabled
    public Decimal Quantity { get; set; }

    @AuraEnabled
    public String Key { get; set; }

    public QuantityOverride() {
      this('', '', '', '', 1);
    }

    public QuantityOverride(String id, String quoteLineId, String shipToConfigId, String shipToAddrId, Decimal qty) {
      this.Id = Id;
      this.QuoteLineId = quoteLineId;
      this.ShipToId = shipToConfigId;
      this.ShipToAddressId = shipToAddrId;
      this.Quantity = qty;
      this.Key = shipToAddrId + '' + quoteLineId;
    }
  }

  public class ShipToLocation {
    @AuraEnabled
    public String RecordId { get; set; }

    @AuraEnabled
    public Boolean IsDefaultShipTo { get; set; }

    @AuraEnabled
    public Integer Index { get; set; }

    @AuraEnabled
    public Decimal BaseQuantity { get; set; }

    @AuraEnabled
    public String ShipToAddressId { get; set; }

    @AuraEnabled
    public String ShipToAddressName { get; set; }

    @AuraEnabled
    public String ShipToAddressAccountName { get; set; }

    @AuraEnabled
    public String QuoteId { get; set; }

    @AuraEnabled
    public List<QuantityOverride> QuantityOverrides { get; set; }

    public ShipToLocation() {
      BaseQuantity = 1;
      IsDefaultShipTo = true;
      Index = 1;
    }

    public ShipToLocation(Integer baseQty, Boolean isDefault, Integer i) {
      BaseQuantity = baseQty;
      IsDefaultShipTo = isDefault;
      Index = i;
    }
  }
  @AuraEnabled(cacheable=true)
  public static List<ShipToLocation> getShipToLocations(Id quoteId) {
    List<Ship_to_Configuration__c> shipToConfigurations = [
      SELECT
        Id,
        Name,
        Quantity__c,
        Quote__c,
        Ship_to_Address__c,
        Default_Ship_To_Location__c,
        Ship_To_Address__r.Name,
        Ship_To_Address__r.Account_Name__c,
        (
          SELECT Id, Quantity__c, Quote_Line__c, Key__c
          FROM Quantity_Overrides__r
          WHERE Quote_Line__r.Vistex_Automatic_Add_on__c = FALSE AND Quote_Line__r.Vistex_Manual_Add_on__c = FALSE
        )
      FROM Ship_to_Configuration__c
      WHERE Quote__c = :quoteId
    ];

    List<ShipToLocation> locations = new List<ShipToLocation>();
    Integer i = 1;
    for (Ship_to_Configuration__c config : shipToConfigurations) {
      System.debug(config);
      System.debug(config.Quantity_Overrides__r);
      ShipToLocation location = new ShipToLocation();
      location.RecordId = config.Id == null ? '' : config.Id;
      location.IsDefaultShipTo = config.Default_Ship_To_Location__c;
      location.BaseQuantity = config.Quantity__c == null ? 0 : config.Quantity__c;
      location.ShipToAddressId = config.Ship_to_Address__c == null ? '' : config.Ship_to_Address__c;

      location.ShipToAddressAccountName = config.Ship_To_Address__r.Account_Name__c == null
        ? ''
        : config.Ship_To_Address__r.Account_Name__c;
      location.ShipToAddressName = config.Ship_To_Address__r.Name == null ? '' : config.Ship_To_Address__r.Name;
      location.QuoteId = config.Quote__c == null ? '' : config.Quote__c;
      location.QuantityOverrides = new List<QuantityOverride>();
      location.Index = i;

      if (config.Quantity_Overrides__r.size() > 0) {
        for (Ship_To_Quantity_Override__c shipToOverride : config.Quantity_Overrides__r) {
          location.quantityOverrides.add(
            new QuantityOverride(
              shipToOverride.Id,
              shipToOverride.Quote_Line__c == null ? '' : shipToOverride.Quote_Line__c,
              config.Id == null ? '' : config.Id,
              config.Ship_to_Address__c == null ? '' : config.Ship_to_Address__c,
              shipToOverride.Quantity__c == null ? 0 : shipToOverride.Quantity__c
            )
          );
        }
      }
      locations.add(location);
      i++;
    }
    System.debug(locations);
    return locations;
  }

  @AuraEnabled(cacheable=true)
  public static List<SBQQ__QuoteLine__c> getQuoteLines(Id quoteId) {
    //List<SBQQ__QuoteLine__c> quoteLines =
    return [
      SELECT
        Id,
        Is_Ancillary__c,
        Is_Quantity_Overridable__c,
        SBQQ__ProductName__c,
        SBQQ__Quantity__c,
        SBQQ__Number__c,
        SBQQ__OptionLevel__c,
        Specific_Commitment__c,
        CPQ_Commitment_Quantity__c,
        CPQ_Commitment_Value__c,
        SBQQ__Quote__r.SBQQ__Account__c,
        SBQQ__Product__r.CPQ_Material_Type_Group__c,
        (SELECT Id, Key__c, Quantity__c, Quote_Line__c, Ship_to_Configuration__c FROM Quantity_Overrides__r)
      FROM SBQQ__QuoteLine__c
      WHERE
        SBQQ__Quote__c = :quoteId
        AND Vistex_Automatic_Add_on__c = FALSE
        AND Vistex_Manual_Add_on__c = FALSE
        AND SBQQ__Product__r.CPQ_Material_Type_Group__c != 'Program Charge'
        AND SBQQ__ProductName__c != 'Additional Contract Considerations'
        AND Potential_Commitment_Spread_Line__c = FALSE
        AND Rebate_Consumable__c = FALSE
        AND Additional_Consumable_or_Ancillary__c = FALSE
      ORDER BY SBQQ__Number__c ASC
    ];
  }

  @AuraEnabled
  public static String saveShipToConfigurations(
    List<ShipToLocation> updatedShipToLocations,
    List<QuantityOverride> overrides,
    String quoteId
  ) {
    List<Ship_to_Configuration__c> updatedShipToConfigs = convertLocationToConfiguration(updatedShipToLocations);
    List<Ship_To_Quantity_Override__c> overridesFromComponent = convertOverrideStructure(overrides);
    Set<Id> updatedConfigIds = ApexUtils.pluckIdSet(updatedShipToConfigs, 'Id');
    Map<Id, Ship_to_Configuration__c> configsToDelete = new Map<Id, Ship_to_Configuration__c>();
    List<Ship_To_Quantity_Override__c> qtyOverridesToUpsert = new List<Ship_To_Quantity_Override__c>();

    System.debug('overridesFromComponent: ' + overridesFromComponent);

    //Get existing quote ship-to configs for cross reference of what may have been deleted
    List<Ship_to_Configuration__c> quoteShipToConfigs = [
      SELECT
        Id,
        Quantity__c,
        Quote__c,
        Ship_to_Address__c,
        Default_Ship_To_Location__c,
        (SELECT Id, Quantity__c, Quote_Line__c, Ship_to_Configuration__c, Key__c FROM Quantity_Overrides__r)
      FROM Ship_to_Configuration__c
      WHERE Quote__c = :quoteId
    ];

    Id quoteDeafultId;
    Integer totalQty = 0;
    //were all of the existing ship to configs deleted?
    if (!updatedConfigIds.isEmpty()) {
      //check if any were deleted
      for (Ship_to_Configuration__c config : quoteShipToConfigs) {
        if (config.Default_Ship_To_Location__c) {
          quoteDeafultId = config.Ship_To_Address__c;
        }

        //Id will be null for new records we haven't saved yet
        if (config.Id != null) {
          //if there was a record on the quote that isn't in the new list, we need to delete it
          if (!updatedConfigIds.contains(config.Id)) {
            configsToDelete.put(config.Id, config);
          }
        }
      }
    }

    // Get the quote
    SBQQ__Quote__c quote = [SELECT Id, Market_is_Vistex_Ready__c FROM SBQQ__Quote__c WHERE Id = :quoteId];

    if (!updatedShipToConfigs.isEmpty()) {
      upsert updatedShipToConfigs;

      // Update the Ship-to quantity in the quote
      quote.Ship_To__c = updatedShipToConfigs.size();

      //check if the Id of the defualt was changed from the quote default. Also sum the qty of the Ship to configurations associated to the quote and update the lines
      Decimal shipToQty = 0;

      Map<Id, Decimal> shiptoAdressMap = new Map<Id, Decimal>();
      Set<String> setOverrideKey = new Set<String>();

      // Map of Quantity Override to be deleted.
      Map<Id, Ship_To_Quantity_Override__c> overridesToDelete = new Map<Id, Ship_To_Quantity_Override__c>();

      // Map of Quantity Override to Insert or Update.
      Map<String, Ship_To_Quantity_Override__c> overridesToUpsert = new Map<String, Ship_To_Quantity_Override__c>();

      for (Ship_to_Configuration__c updatedConfig : updatedShipToConfigs) {
        if ((updatedConfig.Default_Ship_To_Location__c) && (updatedConfig.Ship_To_Address__c != quoteDeafultId)) {
          quote.Ship_To_Address__c = updatedConfig.Ship_To_Address__c;
        }

        //loop through overrides that came fro mthe component and try to match on the address.  when adding a new location the ship to wasnt set until the above upsert.
        for (Ship_To_Quantity_Override__c qtyOR : overridesFromComponent) {
          if (String.isBlank(qtyOR.Ship_to_Configuration__c)) {
            // First Id in the key is the Ship To Address
            if (qtyOR.Key__c.contains(updatedConfig.Ship_To_Address__c)) {
              qtyOR.Ship_To_Configuration__c = updatedConfig.Id;
            }
          }

          // If this override corresponds to a deleted configuration, add to the remove list
          if (configsToDelete.containsKey(qtyOR.Ship_to_Configuration__c)) {
            if (qtyOR.Id != null) {
              System.debug('Deleting override 1: ' + qtyOR);
              overridesToDelete.put(qtyOR.Id, qtyOR);
            }
          } else {
            if (qtyOR.Ship_to_Configuration__c != null && qtyOR.Quote_Line__c != null && !String.IsBlank(qtyOR.Key__c)) {
              overridesToUpsert.put(qtyOR.Key__c, qtyOR);
              setOverrideKey.add(qtyOR.Ship_to_Configuration__c + '-' + qtyOR.Quote_Line__c);
            }
          }
        }

        shipToQty += updatedConfig.Quantity__c;
        shiptoAdressMap.put(updatedConfig.Id, updatedConfig.Quantity__c);
      }

      //Try to update the quote with the new values
      update quote;

      Map<String, List<Ship_To_Quantity_Override__c>> quoteLineOverrideMap = ApexUtils.groupBy(overridesToUpsert.values(), 'Quote_Line__c');

      // Query quote lines to update them
      List<SBQQ__QuoteLine__c> lines = getAllQuoteLines(quoteId);
      Set<String> componentOverrideKeys = apexUtils.pluckStringSet(overridesToUpsert.values(), 'Key__c');

      for (SBQQ__QuoteLine__c line : lines) {
        // Check if a quote line override exists that was not sent back from the component.  We need to delete it
        for (Ship_To_Quantity_Override__c existingOverride : line.Quantity_Overrides__r) {
          if (
            !componentOverrideKeys.contains(existingOverride.Key__c) ||
            configsToDelete.containsKey(existingOverride.Ship_to_Configuration__c)
          ) {
            overridesToDelete.put(existingOverride.Id, existingOverride);
            System.debug('Deleting override 2: ' + existingOverride);
          }
        }

        // Calculate new quantities
        if (!line.Is_Ancillary__c && !line.Specific_Commitment__c) {
          line.SBQQ__Quantity__c = shipToQty;
        } else {
          // Check if there are any ship to overrides that apply to this line and get the qty
          Decimal overrideQty = 0;
          if (quoteLineOverrideMap.containsKey(line.Id)) {
            for (Ship_To_Quantity_Override__c qtyOverride : quoteLineOverrideMap.get(line.Id)) {
              overrideQty += qtyOverride.Quantity__c;
            }
          }
          for (Id shipToId : shiptoAdressMap.keySet()) {
            String key = shipToId + '-' + line.Id;
            if (setOverrideKey.contains(key)) {
              continue;
            } else {
              overrideQty += shiptoAdressMap.get(shipToId);
            }
          }

          // If it's specific commitment line, Quantity = Commitment Quantity * offer Quantity
          line.SBQQ__Quantity__c = overrideQty;
        }
      }

      // Turn off CPQ triggers to avoid causing calculation
      SBQQ.TriggerControl.disable();

      // Disabling 'Vistex Price in Sync' calculation
      QuoteTriggerHandler.disablePriceInSyncCalculation();

      // Disable ship-to override update in the Quote Line
      QuoteLineTriggerHandler.disableShipToOverrideUpdate();

      try {
        if (!configsToDelete.isEmpty()) {
          System.debug('Deleting Ship-to Configurations' + configsToDelete.values());
          delete configsToDelete.values();
        }

        if (!overridesToDelete.isEmpty()) {
          System.debug('Deleting Overrides that existed but no longer apply' + overridesToDelete.values());
          Database.delete(overridesToDelete.values(), false);
        }

        System.debug('upserting Overrides from component based on key ' + overridesToUpsert.values());
        upsert overridesToUpsert.values() Key__c;
        update lines;
      } catch (Exception ex) {
        ErrorLogUtil.log('Error on updating Ship-to Location and Quantity information', ex);
        ErrorLogUtil.commitLogs();
        throw ex;
      } finally {
        SBQQ.TriggerControl.enable();
        QuoteTriggerHandler.enablePriceInSyncCalculation();
        QuoteLineTriggerHandler.enableShipToOverrideUpdate();
      }
    }

    return determineReturnURL(quote);
  }

  public static String determineReturnURL(SBQQ__Quote__c quote) {
    // If Market is Vistex ready, go to the Get Vistex Price page.
    if (quote.Market_is_Vistex_Ready__c) {
      return '/apex/c__GetVistexPricePage?id=' + quote.Id;
    }

    //default to the QLE, determine if we need to go to the next page or not
    return '/apex/sbqq__sb?id=' + quote.Id;
  }

  public static List<Ship_to_Configuration__c> convertLocationToConfiguration(List<ShipToLocation> locations) {
    List<Ship_to_Configuration__c> configsToReturn = new List<Ship_to_Configuration__c>();

    for (ShipToLocation loc : locations) {
      Ship_To_Configuration__c config = new Ship_to_Configuration__c();
      if (!String.isBlank(loc.recordId)) {
        config.Id = loc.recordId;
      }
      if (!String.isBlank(loc.ShipToAddressId)) {
        config.Ship_To_Address__c = loc.ShipToAddressId;
      }
      config.Default_Ship_To_Location__c = loc.IsDefaultShipTo;
      config.Quote__c = loc.quoteId;
      config.Quantity__c = loc.BaseQuantity;
      configsToReturn.add(config);
    }
    return configsToReturn;
  }

  public static List<Ship_To_Quantity_Override__c> convertOverrideStructure(List<QuantityOverride> overrides) {
    System.debug('convertOverrideStructure: ' + overrides);

    List<Ship_To_Quantity_Override__c> overridesToReturn = new List<Ship_To_Quantity_Override__c>();

    for (QuantityOverride qtyOverride : overrides) {
      Ship_To_Quantity_Override__c newOverride = new Ship_To_Quantity_Override__c();

      if (!String.isBlank(qtyOverride.Id)) {
        newOverride.Id = qtyOverride.Id;
      }

      if (!String.isBlank(qtyOverride.ShipToId)) {
        newOverride.Ship_to_Configuration__c = qtyOverride.ShipToId;
      }

      if (!String.isBlank(qtyOverride.QuoteLineId)) {
        newOverride.Quote_Line__c = qtyOverride.QuoteLineId;
      }

      newOverride.Quantity__c = qtyOverride.Quantity;
      newOverride.Key__c = qtyOverride.Key;
      overridesToReturn.add(newOverride);
    }
    return overridesToReturn;
  }

  /**
   * @description Get the Quote Lines, included the Spread Lines and the Rebate lines.
   */
  private static List<SBQQ__QuoteLine__c> getAllQuoteLines(Id quoteId) {
    //List<SBQQ__QuoteLine__c> quoteLines =
    return [
      SELECT
        Id,
        Is_Ancillary__c,
        Is_Quantity_Overridable__c,
        SBQQ__ProductName__c,
        SBQQ__Quantity__c,
        SBQQ__Number__c,
        SBQQ__OptionLevel__c,
        Specific_Commitment__c,
        CPQ_Commitment_Quantity__c,
        CPQ_Commitment_Value__c,
        SBQQ__Quote__r.SBQQ__Account__c,
        SBQQ__Product__r.CPQ_Material_Type_Group__c,
        (SELECT Id, Key__c, Quantity__c, Quote_Line__c, Ship_to_Configuration__c FROM Quantity_Overrides__r)
      FROM SBQQ__QuoteLine__c
      WHERE
        SBQQ__Quote__c = :quoteId
        AND Vistex_Automatic_Add_on__c = FALSE
        AND Vistex_Manual_Add_on__c = FALSE
        AND SBQQ__Product__r.CPQ_Material_Type_Group__c != 'Program Charge'
        AND SBQQ__ProductName__c != 'Additional Contract Considerations'
        AND Additional_Consumable_or_Ancillary__c = FALSE
      ORDER BY SBQQ__Number__c ASC
    ];
  }
}