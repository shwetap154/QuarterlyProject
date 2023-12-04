trigger CaseAgencySubmissionTrigger on ZTS_US_Case_Agency_Submission__c (after insert, after update,before insert, after delete, before delete,after undelete, before update) {
    DispatchTriggerHandler.dispatchHandlerToFire(new CaseAgencySubmissionTriggerHandler(), Bypass_Triggers__mdt.Case_Agency_Submission_Bypass__c);
}