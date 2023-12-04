trigger BatchDetailTrigger on Batch_Detail__c (after insert, after update,before insert, after delete, before delete,after undelete, before update) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new BatchDetailTriggerHandler(), Bypass_Triggers__mdt.Batch_Detail_Bypass__c);     
}