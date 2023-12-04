trigger VistexDealLineTrigger on Vistex_Deal_Line_E1KOMG__c (after insert, after update) {
    
    VistexDealLineTriggerHandler handler = new VistexDealLineTriggerHandler(trigger.New, Trigger.OldMap);
    
    if (Trigger.IsInsert && Trigger.IsAfter) {
        handler.afterInsert();
    }

    if (Trigger.IsUpdate && Trigger.IsAfter) {
        handler.afterUpdate();
    }

}