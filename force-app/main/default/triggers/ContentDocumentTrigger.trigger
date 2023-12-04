trigger ContentDocumentTrigger on ContentDocument (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new ContentDocumentTriggerHandler(),Bypass_Triggers__mdt.Attachment_Bypass__c);
}