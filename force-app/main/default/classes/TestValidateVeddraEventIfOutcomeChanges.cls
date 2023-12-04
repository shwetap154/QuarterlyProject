@isTest
public with sharing class TestValidateVeddraEventIfOutcomeChanges {
    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    @isTest
    public static void TestValidateVeddraEventIfOutcomeChanges() {

        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case for Case Approval Validation',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                ZTS_US_Information_Type__c = 'Erred',
                                ZTS_US_First_Received_Date__c = Date.today(),
                                ZTS_US_Date_First_Valid__c = Date.today());
        insert newCase;

        List<ZTS_US_Event_Narrative__c> listEventNarrative = new List<ZTS_US_Event_Narrative__c>();

        ZTS_US_Event_Narrative__c eventNarrative = new ZTS_US_Event_Narrative__c();

        eventNarrative.ZTS_US_Outcome_of_Reaction__c = 'Died';
        eventNarrative.ZTS_US_Case__c = newCase.Id;
        listEventNarrative.add(eventNarrative);

        insert listEventNarrative;

        newCase.ZTS_US_Event_Narrative__c = listEventNarrative[0].Id;
        update newCase;

        try{
            ValidateVeddraEventIfOutcomeChanges.validateVeddraCoding(newCase, listEventNarrative);

        }
        catch(Exception e){
            Boolean message = e.getMessage().contains('Atleast one veddra coding should have preferred term as dead if the event narrative outcome is died') ? true : false;
            System.AssertEquals(message, true);

        }




        

    }
}