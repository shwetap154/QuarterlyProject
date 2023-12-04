trigger CaseReviewCardTrigger on ZTS_US_Case_Review_Card__c (after insert, after update,before insert, after delete, before delete,after undelete, before update)
{
    DispatchTriggerHandler.dispatchHandlerToFire(new CaseReviewCardTriggerHandler(), Bypass_Triggers__mdt.Case_Review_Card_Bypass__c);

}