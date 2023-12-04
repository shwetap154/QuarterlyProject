trigger Vaccination_Register on VaccinationRegister__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new VaccinationRegisterTriggerHandler(), Bypass_Triggers__mdt.Vaccination_Register_Bypass__c);
}