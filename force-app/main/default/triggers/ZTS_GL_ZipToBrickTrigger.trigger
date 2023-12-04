trigger ZTS_GL_ZipToBrickTrigger on ZTS_GL_ZipToBrick__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_GL_ZipToBrickHandler(), Bypass_Triggers__mdt.ZTS_GL_ZipToBrick_Bypass__c);
}