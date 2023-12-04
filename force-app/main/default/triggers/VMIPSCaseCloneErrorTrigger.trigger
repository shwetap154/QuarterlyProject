trigger VMIPSCaseCloneErrorTrigger on VMIPS_Case_Clone_Error__e (after insert) {

    ZTS_EU_Error_Log__c[] logs = new ZTS_EU_Error_Log__c[]{};
    for(VMIPS_Case_Clone_Error__e triggerRec: trigger.new){
        ZTS_EU_Error_Log__c log = ZTS_EU_Logger.error( triggerRec.Error_Message__c, null, 'SL_CaseTriggerHandler.cloneRelatedList',false);
        if(log!=null){
            logs.add(log);
        }
    }
    if(!logs.isEmpty()){
        insert logs;
    }
}