/*************************************************************************************************************************
  Class Name     : EventService
  Description    : This class contains generic service methods for the Event object.
  Created By     : Deloitte Consulting/Fayas Mansoor
  Created On     : 01/17/2014
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Deloitte Constulting/Fayas Mansoor    01/17/2014              Created
  Sohil Shah(CloudSense)                 09/01/2014          Added to Bug Fix DEF-000068 - Deleting TOT from calendar

***************************************************************************************************************************/

public with sharing class EventService {


    // Call object fields to Event object field mapping 
    public final static map<string, string> eventFieldToCallFieldMap = new map<string, string>{
                                                                        'Subject'               => 'Name',
                                                                        'Description'           => 'ZTS_EU_Call_Objectives__c',
                                                                        'WhatId'                => 'ZTS_EU_Account__c',
                                                                        'ActivityDateTime'      => 'ZTS_EU_Start_Date_Time__c',
                                                                        'EndDateTime'           => 'ZTS_EU_End_Date_Time__c'
                                                                        }; 
    
    public final static set<string> SalesCallEventRecordTypes       = new set<string>{'Sales Call'};
    public static boolean IsEveDelete = false;
    public static boolean iscreateattendee = false;
    
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
            
            // LIGHTNI-1581: Addded the null check for recordtypeId.
            if(String.isNotBlank(eventIterator.recordTypeId))
                isSalesCallEvent = SalesCallEventRecordTypes.contains(RTInfosbyId.get(eventIterator.recordTypeId).getName());
            
            if(isSalesCallEvent){
                isCallUpdateRequired = checkForValueChange(eventIterator, oldEventsMap.get(eventIterator.id));
                system.debug('isCallUpdateRequired'+ isCallUpdateRequired);
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
                system.debug('isValueChanged' + isValueChanged);
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
            for(Event eventIterator : deletedEventsMap.values()){
                callRecordIdsToDelete.add(eventIterator.CallRecordId__c);
            }
        
            if(callRecordIdsToDelete!=null && !callRecordIdsToDelete.isEmpty() && CallUtils.IsCallDelete == false){
                database.delete(callRecordIdsToDelete); 
            }
        }
        
        catch(exception ex){
            system.debug('##### EXCEPTION - '+ex.getmessage());
            system.debug('##### EXCEPTION - '+ex.getstacktracestring());
        }
    }
    
    /* Added by Sohil Shah
     * Method to delete the Time of Territory as soon it is delted from Calender  
     * @param map<id,Event> deletedEventsMap     
     * @return none 
    */
    public static void deleteParentTOT(map<id,Event> deletedEventsMap)
    {
        if(CallUtils.IsCallDelete == false && EventService.IsEveDelete == false)
        {
        list<id> totIds = new list<id>();
        list<Time_Out_of_Territory__c> parentTOTsToDelete = new list<Time_Out_of_Territory__c>();
       
        try{
                for(Event eventIterator : deletedEventsMap.values())
                {              
                    totIds.add(eventIterator.WhatId);
                    System.debug('totIds------'+totIds);
                }
              
                if(totIds!=null && !totIds.isEmpty())
                { 
                        database.delete(totIds);
                }
                
            }        
        catch(exception ex){
            ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'EventService-deleteRelatedCalls');
            system.debug('##### EXCEPTION - '+ex.getmessage());
            system.debug('##### EXCEPTION - '+ex.getstacktracestring());
        }
      }
    }
}