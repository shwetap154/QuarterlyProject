/************************************************************************
 @author Alex Carstairs
 @date 24 May 2019
 @description Test class for DispatchTriggerHandler class
 ************************************************************************/
@isTest
public with sharing class DispatchTriggerHandler_Test {

    public static String testHandlerContext = '';
    private static final String HANDLER_NAME = 'TestHandler';
    private static DispatchTriggerHandler_Test.TestHandler handler = new DispatchTriggerHandler_Test.TestHandler();

    @isTest static void beforeInsert_Test() {
        Test.startTest();
        DispatchTriggerHandler.context = 'BEFORE_INSERT';
        DispatchTriggerHandler.dispatchHandlerToFire(handler);
        Test.stopTest();
        
        System.assertEquals(DispatchTriggerHandler.context,testHandlerContext, 'The context in the test handler should match the dispatcher');
    }

    @isTest static void beforeUpdate_Test() {
        Test.startTest();
        DispatchTriggerHandler.context = 'BEFORE_UPDATE';
        DispatchTriggerHandler.dispatchHandlerToFire(handler);
        Test.stopTest();

        System.assertEquals(DispatchTriggerHandler.context,testHandlerContext, 'The context in the test handler should match the dispatcher');
    }

    @isTest static void beforeDelete_Test() {
        Test.startTest();
        DispatchTriggerHandler.context = 'BEFORE_DELETE';
        DispatchTriggerHandler.dispatchHandlerToFire(handler);
        Test.stopTest();

        System.assertEquals(DispatchTriggerHandler.context,testHandlerContext, 'The context in the test handler should match the dispatcher');
    }

    @isTest static void afterInsert_Test() {
        Test.startTest();
        DispatchTriggerHandler.context = 'AFTER_INSERT';
        DispatchTriggerHandler.dispatchHandlerToFire(handler);
        Test.stopTest();

        System.assertEquals(DispatchTriggerHandler.context,testHandlerContext, 'The context in the test handler should match the dispatcher');
    }

    @isTest static void afterUpdate_Test() {
        Test.startTest();
        DispatchTriggerHandler.context = 'AFTER_UPDATE';
        DispatchTriggerHandler.dispatchHandlerToFire(handler);
        Test.stopTest();

        System.assertEquals(DispatchTriggerHandler.context,testHandlerContext, 'The context in the test handler should match the dispatcher');
    }

    @isTest static void afterDelete_Test() {
        Test.startTest();
        DispatchTriggerHandler.context = 'AFTER_DELETE';
        DispatchTriggerHandler.dispatchHandlerToFire(handler);
        Test.stopTest();

        System.assertEquals(DispatchTriggerHandler.context,testHandlerContext, 'The context in the test handler should match the dispatcher');
    }

    @isTest static void afterUndelete_Test() {
        Test.startTest();
        DispatchTriggerHandler.context = 'AFTER_UNDELETE';
        DispatchTriggerHandler.dispatchHandlerToFire(handler);
        Test.stopTest();

    }

    @isTest static void triggerDisabled_Test() {
        Test.startTest();
        handler.disableTrigger = true;
        DispatchTriggerHandler.dispatchHandlerToFire(handler);
        Test.stopTest();

        System.assertEquals(DispatchTriggerHandler.context, null, 'The context should be null since the trigger is disabled');
    }

    @isTest static void isTriggerFiring_Test() {
        Test.startTest();
        DispatchTriggerHandler.dispatchHandlerToFire(handler);
        Test.stopTest();

        System.assert(!DispatchTriggerHandler.isTriggerExecuting, 'Trigger should not be firing');
        System.assertEquals(DispatchTriggerHandler.context, null, 'Since the handler is not being called in a trigger');
    }

    @isTest static void allowRecursion_Test() {
        DispatchTriggerHandler.setRecursionContexts(handler);

        String triggerContext = 'BEFORE_INSERT';
        Test.startTest();
        DispatchTriggerHandler.context = triggerContext;
        Boolean recursionAllowed = DispatchTriggerHandler.allowRecursion(HANDLER_NAME+triggerContext);
        Test.stopTest();

        System.assert(recursionAllowed, 'Recursion should be allowed');
    }

    @isTest static void disallowRecursion_Test() {

        String triggerContext = 'BEFORE_INSERT';

        Test.startTest();
        DispatchTriggerHandler.context = triggerContext;
        Boolean recursionAllowed = DispatchTriggerHandler.allowRecursion(HANDLER_NAME+triggerContext);
        Test.stopTest();

        System.assert(!recursionAllowed, 'Recursion should not be allowed');
    }

    @isTest static void recursionCheck_Test() {
        DispatchTriggerHandler.context = 'BEFORE_INSERT';

        System.assert(handler.isFirstTime(), 'Should be set to true before handler fires');
        DispatchTriggerHandler.dispatchHandlerToFire(handler);

        Test.startTest();
        DispatchTriggerHandler.dispatchHandlerToFire(handler);
        Test.stopTest();

        System.assert(!handler.isFirstTime(), 'Should be set to false since it\'s been fired twice');
    }

    @isTest static void bypassAPI_Test() {
        DispatchTriggerHandler.bypass(HANDLER_NAME);
        DispatchTriggerHandler.dispatchHandlerToFire(handler);
        System.assertEquals(true,DispatchTriggerHandler.isBypassed(handler),'Handler should be in Bypass Set');
        System.assertEquals(DispatchTriggerHandler.context, null, 'The context should be null since the trigger is bypassed');
        DispatchTriggerHandler.clearBypass(HANDLER_NAME);
        System.assertEquals(false,DispatchTriggerHandler.isBypassed(handler),'Handler should not be in Bypass Set');
        DispatchTriggerHandler.bypass(HANDLER_NAME);
        System.assertEquals(true,DispatchTriggerHandler.isBypassed(handler),'Handler should be in Bypass Set');
        DispatchTriggerHandler.clearAllBypasses();
        System.assertEquals(false,DispatchTriggerHandler.isBypassed(handler),'Handler should not be in Bypass Set');
    }

    @isTest
    private static void testCustomSettingBypass(){
        insert new Automation_Bypass__c(SetupOwnerId=UserInfo.getProfileId(), Case_Bypass__c=true);
        system.assertEquals(true,DispatchTriggerHandler.checkCustomSettingBypass(Automation_Bypass__c.Case_Bypass__c));
        system.assertEquals(false,DispatchTriggerHandler.checkCustomSettingBypass(Automation_Bypass__c.Assessment_Bypass__c));
    }


    /***************************************
     * testing utilities
     ***************************************/

    private static void resetTest() {
        DispatchTriggerHandler_Test.testHandlerContext = null;
    }

    private with sharing class TestHandler extends TriggerHandlerExtension implements TriggerHandlerInterface {
    
        public void beforeInsert(List<SObject> triggerNew) {
            DispatchTriggerHandler_Test.testHandlerContext = 'BEFORE_INSERT';
        }
    
        public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
            DispatchTriggerHandler_Test.testHandlerContext = 'BEFORE_UPDATE';
        }
    
        public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
            DispatchTriggerHandler_Test.testHandlerContext = 'BEFORE_DELETE';
        }
    
        public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
            DispatchTriggerHandler_Test.testHandlerContext = 'AFTER_INSERT';
        }
    
        public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
            DispatchTriggerHandler_Test.testHandlerContext = 'AFTER_UPDATE';
        }
    
        public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
            DispatchTriggerHandler_Test.testHandlerContext = 'AFTER_DELETE';
        }
    
        public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
            DispatchTriggerHandler_Test.testHandlerContext = 'AFTER_UNDELETE';
        }
    
    }

}