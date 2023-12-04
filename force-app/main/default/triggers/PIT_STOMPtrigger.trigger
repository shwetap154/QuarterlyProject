trigger PIT_STOMPtrigger on PIT_STOMP__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new PIT_STOMPtriggerHandler(), Bypass_Triggers__mdt.Account_Bypass__c);
}