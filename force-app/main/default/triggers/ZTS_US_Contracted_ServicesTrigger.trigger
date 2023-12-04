trigger ZTS_US_Contracted_ServicesTrigger on ZTS_US_Contracted_Services__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_US_Contracted_ServicesTriggerHandler(), Bypass_Triggers__mdt.ZTS_US_Contracted_Services_Bypass__c);
}