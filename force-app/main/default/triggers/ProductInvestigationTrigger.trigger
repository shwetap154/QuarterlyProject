trigger ProductInvestigationTrigger on ZTS_US_Product_Investigation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new ProductInvestigationTriggerHandler(), Bypass_Triggers__mdt.Product_Investigation_Bypass__c);
}