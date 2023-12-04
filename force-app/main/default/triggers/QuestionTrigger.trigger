trigger QuestionTrigger on Question (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    DispatchTriggerHandler.dispatchHandlerToFire(new QuestionTriggerHandler(), Bypass_Triggers__mdt.Question_Bypass__c);
}