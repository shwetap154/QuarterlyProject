trigger HolidayTrigger on Holiday__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new HolidayTriggerHandler(), Bypass_Triggers__mdt.Holiday_Bypass__c);
}