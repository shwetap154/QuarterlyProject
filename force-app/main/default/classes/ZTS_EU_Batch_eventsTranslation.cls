global class ZTS_EU_Batch_eventsTranslation implements Database.Batchable<SObject>
{       
    global String querys;
    global String nullValue; 
    global ZTS_EU_Batch_eventsTranslation(String Querys)
    {
        nullValue = '';
        Querys = 'Select Id, Sub_Type__c,CallRecordId__c from event WHERE ZTS_EU_Market__c != \'United States\' limit 1';
    }
    global Database.queryLocator start(Database.BatchableContext bc) { 
            
        String query = 'Select Id, Sub_Type__c,CallRecordId__c from event where  CallRecordId__c !=: nullValue and IsChild = False AND ZTS_EU_Market__c != \'United States\'';
        return Database.getQueryLocator(query);   
    }
    global void execute(Database.BatchableContext bc, List<Event> scope) {
        List<Event> allEventList = new  List<Event>();
        List<Event> filteredEventList = new  List<Event>();
        List<Event> filteredListToUpdate = new List<Event>();
        allEventList = [Select Id, Sub_Type__c,CallRecordId__c from event where  CallRecordId__c !='' and IsChild = false and id IN:scope AND ZTS_EU_Market__c != 'United States'] ;
        System.debug('allEventList-----'+allEventList);
        System.debug('allEventList--size---'+allEventList.Size());
        Set<Id> callId = new Set<Id>();
        Set<Id> filterdCallId = new Set<Id>();
        for(event eve :allEventList)
        {
            callId.add(eve.CallRecordId__c);
        }
        List<Call__C> callList = new List<Call__C>();
        callList = [Select Id, Name, ZTS_EU_Sub_Type__c,ZTS_EU_Account__c,ZTS_EU_Account__r.ZTS_EU_Market__c,ZTS_EU_Local_Subtype__c from call__c where ZTS_EU_Account__r.ZTS_EU_Market__c = 'France' and id IN:callId];
        System.debug('callList-----'+callList);
        System.debug('callList--size---'+callList.Size());
        for(Call__C call: callList)
        {
            filterdCallId.add(call.id);
        }
        filteredEventList = [Select Id, Sub_Type__c,CallRecordId__c from event where CallRecordId__c IN: filterdCallId and IsChild = false AND ZTS_EU_Market__c != 'United States'];
        System.debug('filteredEventList-----'+filteredEventList);
        System.debug('filteredEventList--size---'+filteredEventList.Size());
        for(event eve :filteredEventList)
        {
            if(eve.Sub_Type__c == System.Label.Account_Call)
            {
                eve.Sub_Type__c = 'Visite client'; 
            }
            if(eve.Sub_Type__c == System.Label.Account_Call_with_Speaker)
            {
                eve.Sub_Type__c = 'Visite avec KOL'; 
            }
            if(eve.Sub_Type__c == System.Label.Advisory_Diagnostic_visit)
            {
                eve.Sub_Type__c = 'Visite Diagnostic'; 
            }
            if(eve.Sub_Type__c == System.Label.Clinical_Seedings_initial)
            {
                eve.Sub_Type__c = 'Visite élevage'; 
            }
            if(eve.Sub_Type__c == System.Label.Demonstration_PPE)
            {
                eve.Sub_Type__c = 'Démonstration'; 
            }
            if(eve.Sub_Type__c == System.Label.ICP_DMA_visit)
            {
                eve.Sub_Type__c = 'Rev Intra-Cabinet'; 
            }
            if(eve.Sub_Type__c == System.Label.Loyalty_VAS_visit)
            {
                eve.Sub_Type__c = 'Visite PBC - Offre payante'; 
            }
            if(eve.Sub_Type__c == System.Label.PBC_Call)
            {
                eve.Sub_Type__c = 'Visite PBC - Offre non payante'; 
            }
            if(eve.Sub_Type__c == System.Label.Practice_Discussion_Group)
            {
                eve.Sub_Type__c = 'Groupe de discussion'; 
            }
            
            filteredListToUpdate.add(eve);
        }   
        System.debug('filteredListToUpdate-----'+filteredListToUpdate);
        System.debug('filteredListToUpdate--size---'+filteredListToUpdate.Size());
        update filteredListToUpdate;
    }
    global void finish(Database.BatchableContext bc) {
     }  
    
}