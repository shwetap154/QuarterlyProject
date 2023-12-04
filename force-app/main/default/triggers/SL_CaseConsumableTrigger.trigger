trigger SL_CaseConsumableTrigger on Case_Consumable__c (after insert, before update, before delete) {

   
    if(Trigger.isAfter && Trigger.isInsert) {
        new SL_CaseConsumableTriggerHandler().onAfterInsert(Trigger.newMap);
    }

    if(Trigger.isBefore) 
    {
        if(Trigger.isUpdate)
            new SL_CaseConsumableTriggerHandler().onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        if(Trigger.isDelete)
            new SL_CaseConsumableTriggerHandler().onBeforeDelete(Trigger.old);
    }
}