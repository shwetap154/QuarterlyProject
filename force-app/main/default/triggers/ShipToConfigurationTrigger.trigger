trigger ShipToConfigurationTrigger on Ship_to_Configuration__c (before insert, after insert, before update, after update) {
    
    ShipToConfigurationTriggerHandler handler = new ShipToConfigurationTriggerHandler(Trigger.New, Trigger.NewMap, Trigger.oldMap);
    
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            handler.afterInsert();
        }
        if(Trigger.isUpdate) {
            handler.afterUpdate();
        }
    }
}