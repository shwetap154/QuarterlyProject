trigger ASC_AdministrationTrigger on ASC_Administration__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new ASC_AdministrationTriggerHandler(), Bypass_Triggers__mdt.ASC_Administration_Bypass__c);
}