trigger LeadTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new LeadTriggerHandler(), Bypass_Triggers__mdt.Lead_Bypass__c);
}