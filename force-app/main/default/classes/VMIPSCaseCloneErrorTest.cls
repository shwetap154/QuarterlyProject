@isTest
private class VMIPSCaseCloneErrorTest {
    @isTest
    private static void testTrigger() {
        String message = 'Error in creating related records on case clone';
        test.startTest();
        VMIPS_Case_Clone_Error__e errorEvent = new VMIPS_Case_Clone_Error__e(Error_Message__c=message);
        EventBus.publish(errorEvent);
        test.stopTest();
        ZTS_EU_Error_Log__c log = [SELECT id,ZTS_EU_Message__c FROM ZTS_EU_Error_Log__c LIMIT 1];
        system.assert(log!=null && log.ZTS_EU_Message__c==message);
    }
}