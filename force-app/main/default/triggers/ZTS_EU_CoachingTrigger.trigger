trigger ZTS_EU_CoachingTrigger on ZTS_EU_Coaching__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EU_CoachingTriggerHandler(), Bypass_Triggers__mdt.ZTS_EU_Coaching_Bypass__c);

}