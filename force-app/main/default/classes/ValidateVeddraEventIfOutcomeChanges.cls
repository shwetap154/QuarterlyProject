public with sharing class ValidateVeddraEventIfOutcomeChanges {

    static final  String Death = 'Death';

    public static void validateVeddraCoding(Case aCase, List<ZTS_US_Event_Narrative__c> listCaseNarrative) {

        List<Id> eventNarrativeIds = new List<Id>();

        Boolean veddraCheckFlag = false;

        for(ZTS_US_Event_Narrative__c eachEventNarratives: listCaseNarrative){
            if(eachEventNarratives.ZTS_US_Outcome_of_Reaction__c == 'Died'){

                eventNarrativeIds.add(eachEventNarratives.Id);

            }

        }
        System.debug('Event Narratives Id = '+eventNarrativeIds);
        List<ZTS_US_VedDRA_Event__c> queriedVeddraEvent = [SELECT Id, ZTS_US_VedDRA_Coding__c FROM ZTS_US_VedDRA_Event__c WHERE ZTS_US_Event_Narrative__c IN: eventNarrativeIds];

        List<Id> veddraCodingId = new List<Id>();

        if(eventNarrativeIds.size() != 0){
            for(ZTS_US_VedDRA_Event__c eachVeddraEvent:queriedVeddraEvent ){
                veddraCodingId.add(eachVeddraEvent.ZTS_US_VedDRA_Coding__c);
            }
        }
        

        List<ZTS_US_VedDRA_Coding__c> queriedVeddraCoding = [SELECT Id, ZTS_US_Preferred_Term__c 
                                                            FROM ZTS_US_VedDRA_Coding__c WHERE Id IN: veddraCodingId 
                                                            AND ZTS_US_Preferred_Term__c =: Death];

        System.debug('queriedVeddraCoding = '+queriedVeddraCoding);
        Integer count;
        if(veddraCodingId.size() != 0){
            if(queriedVeddraCoding.size() == 0){
                aCase.addError('Atleast one veddra coding should have preferred term as dead if the event narrative outcome is died');           
            }

        }
        
    }
}