trigger VaccinationRegisterTrigger on VaccinationRegister__c (after insert, after update) {
    
    DispatchTriggerHandler.dispatchHandlerToFire(new VaccinationRegisterTriggerHandler(), Bypass_Triggers__mdt.Vaccination_Register_Bypass__c);
}