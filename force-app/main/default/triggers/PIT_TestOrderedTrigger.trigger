trigger PIT_TestOrderedTrigger on PIT_Test_Ordered__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    DispatchTriggerHandler.dispatchHandlerToFire(new PIT_TestOrderedTriggerHandler(), Bypass_Triggers__mdt.PIT_Test_Order_Bypass__c);
    
}