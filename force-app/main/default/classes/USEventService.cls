/*************************************************************************************************************************
  Class Name     : USEventService
  Description    : This class contains generic service methods for the Event object.
  Created By     : Deloitte Consulting/Fayas Mansoor
  Created On     : 01/17/2014
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Deloitte Constulting/Fayas Mansoor    01/17/2014              Created

***************************************************************************************************************************/

public with sharing class USEventService {

    //TOT Type Picklist Values
    public static final String TIME_ON = 'Time On';
    public static final String TIME_OFF = 'Time Off';
    
    // Call object fields to Event object field mapping 
    public final static map<string, string> eventFieldToCallFieldMap = new map<string, string>{
                                                                        'Subject'               => 'Name',
                                                                        'Description'           => 'Call_Objectives__c',
                                                                        'WhatId'                => 'Account__c',
                                                                        'ActivityDateTime'      => 'Start_Date_Time__c',
                                                                        'EndDateTime'           => 'End_Date_Time__c'
                                                                        }; 
    
    public final static set<string> SalesCallEventRecordTypes       = new set<string>{'Sales Call'};
    
    /*
     * Method to map fields from event object record to call object record 
     * @param Call__c callRec
     * @param event eventRec
     * @return none 
    */
    public static void mapEventToCallFields(Event eventRec, Call__c callRec){
        
        string callFieldName ;
        
        for(string eventFieldName : eventFieldToCallFieldMap.keySet()){
            
            callFieldName  = eventFieldToCallFieldMap.get(eventFieldName);
            callRec.put(callFieldName,eventRec.get(eventFieldName));
        }
    }
    
    /*
     * Method to iterator over new and old maps find out which all event records require an update to call record
     * and invoke method to update them 
     * @param map<id,Call__c> newEventsMap
     * @param map<id,Call__c> oldEventsMap
     * @return none 
    */
    
    public static void updateAndSyncCallsFromEvents(map<id,Event> newEventsMap, map<id,Event> oldEventsMap){
        
        boolean isCallUpdateRequired    = false;
        boolean isSalesCallEvent        = false;
        list<Event> EventsToUpdateCalls = new list<Event>();
        map<Id,Schema.RecordTypeInfo> RTInfosbyId = UtilityService.getRecordtypeInfosbyId('Event');
        
        for(Event eventIterator : newEventsMap.values()){
            
            isSalesCallEvent = SalesCallEventRecordTypes.contains(RTInfosbyId.get(eventIterator.recordTypeId).getName());
            
            if(isSalesCallEvent){
                isCallUpdateRequired = checkForValueChange(eventIterator, oldEventsMap.get(eventIterator.id));
                
                if(isCallUpdateRequired){
                    EventsToUpdateCalls.add(eventIterator);
                }
            }
        }
        
        if(EventsToUpdateCalls!=null && !EventsToUpdateCalls.isEmpty())
            updateCallsFromEvents(EventsToUpdateCalls);
                
    }
    
    /*
     * Method to compare two event record (old and new) in case of update trigger and return true if 
     * one of fields mapped to call is changed
     * @param Event newEvent
     * @param Event oldEvent
     * @return boolean 
    */
    public static boolean checkForValueChange(Event newEvent, Event oldEvent){
        boolean isValueChanged = false;
        
        for(string eventFieldName : eventFieldToCallFieldMap.keySet()){

            if(newEvent.get(eventFieldName)!=oldEvent.get(eventFieldName)){
                isValueChanged = true;
                break;
            }
            
        }
        
        return isValueChanged;
    }
    
    /*
     * Method to get call ids from events and and update fields  
     * @param list<Event> eventsToUpdateCalls
     * @return none 
    */
    public static void updateCallsFromEvents(list<Event> eventsToUpdateCalls){
        
        map<Id, Event> eventsToUpdateCalls_map  = new map<Id, Event>(eventsToUpdateCalls);
        map<Id, Call__c> eventId_Call_map       = new map<Id, Call__c>();
        
        try{
            for(Event eventIterator : eventsToUpdateCalls){
                eventId_Call_map.put(eventIterator.Id, new Call__c(id=eventIterator.CallRecordId__c));
            }           
            for(Id eventId : eventId_Call_map.keySet()){
                mapEventToCallFields(eventsToUpdateCalls_map.get(eventId),eventId_Call_map.get(eventId));
            }       
            
            database.update(eventId_Call_map.values());
        }
        
        catch(exception ex){
            system.debug('##### EXCEPTION - '+ex.getmessage());
            system.debug('##### EXCEPTION - '+ex.getstacktracestring());
        }
        
    }
    
    /*
     * Method to delete related calls 
     * @param map<id,Event> deletedEventsMap
     * @return none 
    */
    public static void deleteRelatedCalls(map<id,Event> deletedEventsMap){
        
        list<id> callRecordIdsToDelete = new list<id>();
        
        try{
            for(Event eventIterator : deletedEventsMap.values())
            {
                if(eventIterator.CallRecordId__c!=null)
                {
                    callRecordIdsToDelete.add(eventIterator.CallRecordId__c);
                }
           }
        
            if(callRecordIdsToDelete!=null && !callRecordIdsToDelete.isEmpty()){
                database.delete(callRecordIdsToDelete); 
            }
        }
        
        catch(exception ex){
            system.debug('##### EXCEPTION - '+ex.getmessage());
            system.debug('##### EXCEPTION - '+ex.getstacktracestring());
        }
    }
    
    /*
     * Method to Update the Event Id on TOT record on Event creation 
     * @param map<id,Event> createdEventsMap
     * @return none 
    */
    public static void updateEventIdOnTOT(map<id,Event> createdEventsMap){
        
        String eventRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'General_Event'].Id;
        
        Set<Id> setTOTId = new Set<Id>();
        List<Time_Out_of_Territory__c> lstTOT = new List<Time_Out_of_Territory__c>();
        List<Time_Out_of_Territory__c> lstTOTForUpdate = new List<Time_Out_of_Territory__c>();
        Map<Id,Time_Out_of_Territory__c> mapEventWhatIdAndTOT = new Map<Id,Time_Out_of_Territory__c>();
        
        for(Event objEvent : createdEventsMap.values()){
            //if(objEvent.RecordTypeId == eventRecordTypeId && (objEvent.Type == TIME_ON || objEvent.Type == TIME_OFF )){
            if(objEvent.RecordTypeId == eventRecordTypeId){
                setTOTId.add(objEvent.WhatId);
            }
        }
        lstTOT = [Select z.ZTS_US_Calendar_Event__c, z.Id From Time_Out_of_Territory__c z
                    where Id in :setTOTId AND ZTS_Market__c = 'United States'];
        for(Time_Out_of_Territory__c objTOT : lstTOT){
            mapEventWhatIdAndTOT.put(objTOT.Id,objTOT);
        } 
        for(Event objEvent : createdEventsMap.values()){
            if(mapEventWhatIdAndTOT.get(objEvent.WhatId) != null){
                mapEventWhatIdAndTOT.get(objEvent.WhatId).ZTS_US_Calendar_Event__c = objEvent.Id;
                
                lstTOTForUpdate.add(mapEventWhatIdAndTOT.get(objEvent.WhatId));
            }
        }
        try{
            if(lstTOTForUpdate != null && lstTOTForUpdate.size() > 0){
                Database.update(lstTOTForUpdate);
            }
        }
        catch(Exception e){
            system.debug('Exception while updating a TOT record'+ e);
        }           
    }
}