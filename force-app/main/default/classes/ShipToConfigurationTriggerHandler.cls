/**
* File Name     :  ShipToConfigurationTriggerHandler.cls
* @description  :  Handler class for ShipToConfiguration Trigger
* @author       :  Ramiro Alvarez @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     09/07/2020		Ramiro Alvarez @ ATG     Created the Class.
**/

public class ShipToConfigurationTriggerHandler {
    
    private List<Ship_to_Configuration__c> triggerNew;
    private Map<Id, Ship_to_Configuration__c> triggerNewMap;    
    private Map<Id, Ship_to_Configuration__c> triggerOldMap { get; set; }

    /**
    * @description Constructor.
    * @param triggerNew List of new version of the Ship_to_Configuration__c, provided by the trigger.
    * @param triggerNewMap Map of the new version of the Ship_to_Configuration__c, provided by the trigger.
    * @param triggerOldMap Map of the old version of the Ship_to_Configuration__c, provided by the trigger.
    */
    public ShipToConfigurationTriggerHandler(
        List<Ship_to_Configuration__c> triggerNew,
        Map<Id, Ship_to_Configuration__c> triggerNewMap,
        Map<Id, Ship_to_Configuration__c> triggerOldMap
    ) {
        this.triggerNew = triggerNew;
        this.triggerNewMap = triggerNewMap;
        this.triggerOldMap = triggerOldMap;
    }

    public void afterInsert() {
        updateToFalseDefaultShipToConfiguration(triggerNew);
    }

    public void afterUpdate() {
        updateToFalseDefaultShipToConfiguration(triggerNew);
    }
    
    private static void updateToFalseDefaultShipToConfiguration(List<Ship_to_Configuration__c> newShipToConfigList) {

        System.debug('Entering updateToFalseDefaultShipToConfiguration...');
        List<Ship_to_Configuration__c> shipToConfToUpd = new List<Ship_to_Configuration__c> ();
        List<SBQQ__Quote__c> quotesToUpd = new List<SBQQ__Quote__c> ();
        Map<Id,Id> shipToQuoteMap = new Map<Id,Id> ();
        Map<Id,Id> shipToAddressMap = new Map<Id,Id> ();

        for (Ship_to_Configuration__c shipTo : newShipToConfigList){
            if (shipTo.Default_Ship_To_Location__c) {
                shipToQuoteMap.put(shipTo.Id,shipTo.Quote__c);
                shipToAddressMap.put(shipTo.Id,shipTo.Ship_to_Address__c);
            }
        }

        if (shipToQuoteMap.isEmpty()) {
            System.debug('updateToFalseDefaultShipToConfiguration, no changes un default Shipto - return');
            return;
        }
        //Query for other Ship To in same Quote
        List<Ship_to_Configuration__c> relatedShipToListInQuote = [SELECT Id, Default_Ship_To_Location__c, Quote__c
            FROM Ship_to_Configuration__c
            WHERE Id NOT IN :shipToQuoteMap.keySet()
            AND Quote__c IN : shipToQuoteMap.values()];

        for (Ship_to_Configuration__c shipTo : relatedShipToListInQuote) {
            if (shipTo.Default_Ship_To_Location__c) {
                shipToConfToUpd.add(new Ship_to_Configuration__c (Id = shipTo.Id, Default_Ship_To_Location__c = false));                
            }
        }
        for (Id shipTo : shipToQuoteMap.keySet()) {
            quotesToUpd.add(new SBQQ__Quote__c(Id = shipToQuoteMap.get(shipTo), Ship_To_Address__c = shipToAddressMap.get(shipTo)));
        }
        if (!shipToConfToUpd.isEmpty()) {
            update shipToConfToUpd;
        }
        if (!quotesToUpd.isEmpty()) {
            QuoteTriggerHandler.disableUpdatesOnShipTo();
            update quotesToUpd;
            QuoteTriggerHandler.enableUpdatesOnShipTo();
        }
    }
}