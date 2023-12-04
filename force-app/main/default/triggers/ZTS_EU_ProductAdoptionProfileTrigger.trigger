trigger ZTS_EU_ProductAdoptionProfileTrigger on ZTS_EU_Product_Adoption_Profile__c (after insert, after update, before insert,before update) {
    
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EU_ProductAdoptionProfileHandler(), Bypass_Triggers__mdt.ZTS_EU_ProductAdoptionProfile_Bypass__c);

}