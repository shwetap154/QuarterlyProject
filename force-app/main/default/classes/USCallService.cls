/*************************************************************************************************************************
  Class Name     : USCallService
  Description    : This class contains generic service methods for the Call__c object.
  Created By     : Deloitte Consulting/Fayas Mansoor
  Created On     : 01/17/2014
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Deloitte Constulting/Fayas Mansoor    01/17/2014              Created
  Aritra (Cognizant)					01/19/2022              Added 2 methods calculateEndDate and validateCallDeletion (SC-008816)
***************************************************************************************************************************/

public with sharing class USCallService {
    
    
    // Call object fields to Event object field mapping 
    public final static map<string, string> callFieldToEventFieldMap = new map<string, string>{
                                                                        'CreatedById'           => 'OwnerId',
                                                                        'Name'                  => 'Subject',
                                                                        'ZTS_EU_Call_Objectives__c'    => 'Description',
                                                                        'ZTS_EU_Account__c'            => 'WhatId',
                                                                        'ZTS_EU_Start_Date_Time__c'    => 'ActivityDateTime',
                                                                        'ZTS_EU_End_Date_Time__c'      => 'EndDateTime',
                                                                        'Id'                    => 'CallRecordId__c',
                                                                        'ZTS_EU_Status__c'             => 'Location'
                                                                        
                                                                        };
    
    /*
     * Method to create an event per call for a list of calls
     * @param list<Call__> newCalls
     * @return list<Event> 
    */                                           
    public static list<Event> createEventsFromCalls(list<Call__c> newCalls){
        
        list<Event> newEvents = new list<Event>();
        Event tempEvent;
        
        for(Call__c callIterator : newCalls){
            tempEvent = createEventFromCall(callIterator);
            if(tempEvent!=null){
                if(callIterator.ZTS_EU_Duration__c != NULL )
                {
                    tempEvent.DurationInMinutes = Integer.valueOf(Double.valueOf(callIterator.ZTS_EU_Duration__c.split(' ')[0].trim()) * 60);
                }
            }
            newEvents.add(tempEvent);
        }

        return newEvents;
    }
    
    /*
     * Method to create an event for a call
     * @param Call__c callRec
     * @return Event 
    */
    public static Event createEventFromCall(Call__c callRec){
        
        Event eventRec      = new Event();
        mapCallToEventFields(callRec,EventRec);
        return eventRec;
    }
    
    /*
     * Method to map fields from call object to event object record 
     * @param Call__c callRec
     * @param event eventRec
     * @return none 
    */
    public static void mapCallToEventFields(Call__c callRec, Event eventRec){
        
        string eventFieldName;
        
        for(string callFieldName : callFieldToEventFieldMap.keySet()){
            
            eventFieldName = callFieldToEventFieldMap.get(callFieldName);
            eventRec.put(eventFieldName,callRec.get(callFieldName));
        }
    }
    
    /*
     * Method to generate events from call records and insert them 
     * @param list<Call__c> newCalls
     * @return none 
    */
    public static void generateAndSetupEventsFromCalls(list<Call__c> newCalls){
        
        list<Event>  eventsToInsert = new list<Event> (); 
        
        try{
            eventsToInsert = createEventsFromCalls(newCalls);
            database.insert(eventsToInsert);
        }
        
        catch(exception ex){
            system.debug('##### EXCEPTION - '+ex.getmessage());
            system.debug('##### EXCEPTION - '+ex.getstacktracestring());
            
        }
        
    }
    
    /*
     * Method to iterator over new and old maps find out which all call records require an update to event record
     * and invoke method to update them 
     * @param map<id,Call__c> newCallsMap
     * @param map<id,Call__c> oldCallsMap
     * @return none 
    */
    public static void updateAndSyncEventsFromCalls(map<id,Call__c> newCallsMap, map<id,Call__c> oldCallsMap){
        boolean isEventUpdateRequired = false;
        list<Call__c> CallsToUpdateEvents = new list<Call__c>();
        
        for(Call__c callIterator : newCallsMap.values()){
            isEventUpdateRequired = checkForValueChange(callIterator, oldCallsMap.get(callIterator.id));
            if(isEventUpdateRequired){
                CallsToUpdateEvents.add(callIterator);
            }
        }
        
        updateEventsFromCalls(CallsToUpdateEvents);
                
    }
    
    /*
     * Method to compare two call record (old and new) in case of update trigger and return true if 
     * one of fields mapped to event is changed
     * @param Call__c newCall
     * @param Call__c oldCall
     * @return boolean 
    */
    public static boolean checkForValueChange(Call__c newCall, Call__c oldCall){
        boolean isValueChanged = false;
        
        for(string callFieldName : callFieldToEventFieldMap.keySet()){

            if(newCall.get(callFieldName)!=oldCall.get(callFieldName)){
                isValueChanged = true;
                break;
            }
            
        }
        
        return isValueChanged;
    }
    
    /*
     * Method to query related events from calls and update fields  
     * @param list<Call__c> CallsToUpdateEvents
     * @return none 
    */
    public static void updateEventsFromCalls(list<Call__c> callsToUpdateEvents){
        
        map<Id, Call__c> callsToUpdateEvents_map = new map<Id, Call__c>(callsToUpdateEvents);
        map<Id, Event> CallId_Event_map          = new map<Id, Event>();
        
        try{
            for(Event eventIterator : [SELECT Id,CallRecordId__c,Ischild FROM Event WHERE CallRecordId__c in : callsToUpdateEvents_map.keyset() and Ischild = false AND ZTS_EU_Market__c = 'United States']){
                    CallId_Event_map.put(eventIterator.CallRecordId__c, eventIterator);
            }
            
            for(Id callId : CallId_Event_map.keySet()){
                mapCallToEventFields(callsToUpdateEvents_map.get(callId),CallId_Event_map.get(callId));
            }       
            
            database.update(CallId_Event_map.values());
        }
        
        catch(exception ex){
            system.debug('##### EXCEPTION - '+ex.getmessage());
            system.debug('##### EXCEPTION - '+ex.getstacktracestring());
        }
        
    }
    
    /*
     * Method to query for related events and delete them  
     * @param map<id,Call__c> deletedCallsMap
     * @return none 
    */
    public static void deleteRelatedEvents(map<id,Call__c> deletedCallsMap){
        
        list<Event> eventsToDelete;
        
        try{
            
            eventsToDelete = [SELECT Id FROM Event WHERE CallRecordId__c in :deletedCallsMap.keySet() AND ZTS_EU_Market__c = 'United States'];
        
            if(eventsToDelete!=null && !eventsToDelete.isEmpty()){
                database.delete(eventsToDelete);    
            }
        }
        
        catch(exception ex){
            system.debug('##### EXCEPTION - '+ex.getmessage());
            system.debug('##### EXCEPTION - '+ex.getstacktracestring());
        }
    }
    
    /*
     * Method to restrict a user to not be able to delete Submitted Call Records.  
     * @param List callList
     * @return none 
    */
    public static void delSubmittedCall(List<Call__c> callList){
            for(Call__c cal: callList){
                if(cal.ZTS_EU_Status__c=='Submitted'){
                    cal.addError('You cannot delete a Submitted Call');
                }
            }
        }
     public static void delSampleDrop(List<Call__c> callList){
     	List<ZTS_US_Sample_Drop__c> samdrops = new List<ZTS_US_Sample_Drop__c>();
     	List<Id> callIds = new List<Id>();
     	Id abc;
     	for(Call__c cal : callList){
     		abc = cal.Id;
     	}
     	callIds.add(abc);
     	samdrops = [select id,ZTS_US_Call__c from ZTS_US_Sample_Drop__c where ZTS_US_Call__c IN:callIds];
     	try{
     		delete samdrops;
     	}
     	catch(Exception e){
     		System.debug('Exception occurred while deleting sample drop'+e);
     	}
     }
    
    /*
     * SC-008816 - Added by Aritra Chakraborty
     * Method to prevent the user from deleteing a call if the current user is not the call owner and not assigned
     * with admin profile (Integration profile, Support Administrator, System Administrator)
     * @Param list callList
     * @return none
	*/
    public static void validateCallDeletion(List<Call__c> callList){
        for(Call__c call : callList){
            if(call.ZTS_EU_Call_Owner__c != UserInfo.getUserId()){
                call.addError('You don\'t have permission to delete this call');
            }
        }
    }

    /*
     * SC-008816 - Added by Aritra Chakraborty
     * Method to calculate end date of the call only when the call Activity date or duration is updated
     * @Param list - callList, callOldMap
     * @return none
	*/
    public static void calculateEndDate(List<Call__c> callNewList, Map<Id, Call__c> callOldMap){
        String hours;
        Integer minutes;
        for(Call__c call : callNewList){
            if(call.ZTS_EU_Start_Date_Time__c != callOldMap.get(call.Id).ZTS_EU_Start_Date_Time__c ||
                call.ZTS_EU_Duration__c != callOldMap.get(call.Id).ZTS_EU_Duration__c)
            {
                if(call.ZTS_EU_Duration__c != null){
                    hours = call.ZTS_EU_Duration__c.split(' ')[0].trim();
                    minutes = Integer.valueOf(Decimal.valueOf(hours) * 60);
                    call.ZTS_EU_End_Date_Time__c = call.ZTS_EU_Start_Date_Time__c.addMinutes(minutes);
                }
            }
        }
    }
}