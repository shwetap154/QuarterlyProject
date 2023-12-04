@isTest
public with sharing class CSE_EventNarrativeTriggerHandler_Test
{
    @testSetup
    public static void setupData(){
    String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId(); 

    ZTS_US_Event_Narrative__c testEventNarrative = (ZTS_US_Event_Narrative__c) SL_TestDataFactory.createSObject
    (   new ZTS_US_Event_Narrative__c
        (    ZTS_US_Reaction_Treated__c = 'No',
             ZTS_US_Event_Narrative_Summary_Field__c = 'test',
             ZTS_US_Treatment__c = 'test'
        )
    ,   true
    );
        Case testCase = new Case(Subject = 'Test Case',
        Status = 'New',
        Origin = 'phone',
        Type = 'Animal Complaint',
        RecordTypeId = animalRecordtypeId,
        Sync_Status__c=VmipsCaseSyncStatusHandler.SYNC_SUCCESS,
        ZTS_US_Event_Narrative__c = testEventNarrative.id
        );
        insert testCase;
    }

    @isTest
    private static void test_CSE_EventNarrativeTrigger_Positive(){
        final String EXCEPTION_MESSAGE = 'cannot be set to null';
        ZTS_US_Event_Narrative__c eventNarrativeTest = [SELECT ID, Name, ZTS_US_Treatment__c, ZTS_US_Reaction_Treated__c, ZTS_US_Event_Narrative_Summary_Field__c
                                                        FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Reaction_Treated__c = 'No' LIMIT 1];
        eventNarrativeTest.ZTS_US_Reaction_Treated__c = 'Yes';
        eventNarrativeTest.ZTS_US_Treatment__c ='patient was treated';
        try{
            test.startTest();
            update eventNarrativeTest;
            test.stopTest();
             ZTS_US_Event_Narrative__c eventNarrativeTestcheck = [SELECT ID, Name, ZTS_US_Treatment__c, ZTS_US_Reaction_Treated__c, ZTS_US_Event_Narrative_Summary_Field__c
                                                        FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Reaction_Treated__c = 'Yes' LIMIT 1];
            System.Assert(eventNarrativeTestcheck.ZTS_US_Reaction_Treated__c == 'Yes', 'the field should have successfully been changed to Pharmacist');
        }catch(Exception ex){
            system.debug('event narrative error'+ex.getMessage());
            System.Assert(false, 'the test should never throw an error');
        }
    }

    @isTest
    private static void test_CSE_EventNarrativeTrigger_Negative(){
        final String EXCEPTION_MESSAGE = 'cannot be set to null';
        ZTS_US_Event_Narrative__c eventNarrativeTest = [SELECT ID, Name, ZTS_US_Treatment__c, ZTS_US_Reaction_Treated__c, ZTS_US_Event_Narrative_Summary_Field__c FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Reaction_Treated__c = 'No' LIMIT 1];
        eventNarrativeTest.ZTS_US_Reaction_Treated__c = null;
        Boolean exceptionThrownMessage = False;
        try{
            test.startTest();
            update eventNarrativeTest;
            test.stopTest();
            
        } catch(Exception ex){
            System.debug('Exception from test '+ ex);
            exceptionThrownMessage =  ex.getMessage().contains(EXCEPTION_MESSAGE) ? true : false;
        }
        System.assertEquals(true, exceptionThrownMessage, 'We expect that there will be a validation error on the related Case record due to one of its fields on its approval field set becoming a null value');
    }
   
}