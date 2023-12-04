/* -----------------------------------------------------------------------------------------------------------------------
Name:        ZTS_EU_BatchCreateMissingEventForCall.cls
Description: Batch used for Inserting missing events for calls and colleagues for all markets                    
Date         Version    Author              Summary of Changes 
09-03-2022		1.0		Anuj Sharma			SC-009137
--------------------------------------------------------------------------------------------------------------------------*/
global class ZTS_EU_BatchCreateMissingEventForCall implements Database.Batchable<sObject> {

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
    string str1 = '';
    
    //Query for fetching all the calls respective for the market
    string query = 'SELECT id, name, ZTS_EU_Account__c, Contact_Employee_Count__c, Discussion_Item_Count__c, Contact_Employee__c,Discussion_Item__c,ZTS_EU_Next_Call_Date__c, ZTS_EU_Sub_Type__c, ZTS_EU_Next_Step__c, ZTS_EU_Local_Subtype__c, ZTS_EU_Call_Objectives__c, ZTS_EU_Account__r.ZTS_EU_Market__c, ZTS_EU_Start_Date_Time__c, ZTS_EU_Call_Owner__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Status__c ' + 
        +' ,CreatedById FROM Call__c'
        +' WHERE ZTS_EU_Call_Owner__c !=: str1 and CreatedDate = Last_N_Days:1';
    
    
    
    // Start Method 
    global Database.queryLocator start(Database.BatchableContext BC){
        system.debug('query========>'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Call__c> callList){
   		list<ZTS_EU_Colleague__c> colleaguelist = new list<ZTS_EU_Colleague__c>();
        set<id> setacc = new set<id>(); // to have unique set of accounts
        set<id> callIds = new set<id>(); // to have unique set of call ids
		Set<string> callRecId = new Set<string>();
        list<Call__c> lstFinalCallRecordUS = new list<Call__c>();
        list<Call__c> lstFinalCallRecordINTL = new list<Call__c>();
        for(call__c c: calllist)
        {
            setacc.add(c.ZTS_EU_Account__c);
            callIds.add(c.Id);
        }
         system.debug('callIds::' + callIds.size());
        system.debug('callIds::' + callIds);
        
        //Query to get all the related events for the accounts and callids with record type "Sales call"
        List<Event> events= [select id, whatid, Ownerid,CallRecordId__c,ZTS_EU_Market__c from Event where whatid in : setacc 
                             and CallRecordId__c in :callIds and Recordtypeid = '012F0000000WRKj'];
        
        for(Event item : events){
            callRecId.add(item.CallRecordId__c);
        }

        system.debug('callRecId::' + callRecId.size());
        system.debug('callRecId::' + callRecId);
        
        for(Call__c item : callList){
            System.debug('item.id::'+item.id);
            System.debug('!callRecId.Contains(item.id)::'+!callRecId.Contains(item.id));
            if(!callRecId.Contains(item.id)){
                System.debug('item.ZTS_EU_Account__r.ZTS_EU_Market__c::'+item.ZTS_EU_Account__r.ZTS_EU_Market__c);
                if(item.ZTS_EU_Account__r.ZTS_EU_Market__c == 'United States'){
                    lstFinalCallRecordUS.add(item);
                } else{
                    lstFinalCallRecordINTL.add(item);
                }
            }
        }
        
        System.debug('lstFinalCallRecordUS.size()::'+lstFinalCallRecordUS);
        if(lstFinalCallRecordUS.size() > 0){
            list<ZTS_EU_Colleague__c> colllst = new list<ZTS_EU_Colleague__c>();
            colleaguelist = [select id,ZTS_EU_Call__c,ZTS_EU_User__c,ZTS_EU_Call__r.ZTS_EU_Call_Owner__c 
                             from ZTS_EU_Colleague__c where ZTS_EU_Call__c in : lstFinalCallRecordUS];
            
            for(ZTS_EU_Colleague__c coll: colleaguelist)
            {
                if(coll.ZTS_EU_User__c != coll.ZTS_EU_Call__r.ZTS_EU_Call_Owner__c)
                {
                    colllst.add(coll);
                }
            }
            
             System.debug('lstFinalCallRecordUS'+lstFinalCallRecordUS);
            generateAndSetupEventsFromCalls(lstFinalCallRecordUS);
            
            System.debug('colllst'+colllst);
            if(colllst!=null && colllst.size()>0)
            {
                system.debug('inside if====');
                createEventRelationsForColleagues(colllst); // to create calendar event for colleagues for a call
            }
        }
        
        System.debug('lstFinalCallRecordINTL.size()::'+lstFinalCallRecordINTL);
        if(lstFinalCallRecordINTL.size() > 0){
            list<ZTS_EU_Colleague__c> colllst = new list<ZTS_EU_Colleague__c>();
            colleaguelist = [select id,ZTS_EU_Call__c,ZTS_EU_User__c,ZTS_EU_Call__r.ZTS_EU_Call_Owner__c 
                             from ZTS_EU_Colleague__c where ZTS_EU_Call__c in : lstFinalCallRecordINTL];
            
            System.debug('colleaguelist::'+colleaguelist);
            for(ZTS_EU_Colleague__c coll: colleaguelist)
            {
                if(coll.ZTS_EU_User__c != coll.ZTS_EU_Call__r.ZTS_EU_Call_Owner__c)
                {
                    colllst.add(coll);
                }
            }
            
            System.debug('lstFinalCallRecordINTL'+lstFinalCallRecordINTL);
            generateAndSetupEventsFromCalls(lstFinalCallRecordINTL);
            
             System.debug('colllst'+colllst);
            if(colllst!=null && colllst.size()>0)
            {
                system.debug('inside if====');
                createEventRelationsForColleagues(colllst); // to create calendar event for colleagues for a call
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){    
    }
    
      /*
     * Method to generate events from call records and insert them 
     * @param list<Call__c> newCalls
     * @return none 
    */
    public static void generateAndSetupEventsFromCalls(list<Call__c> newCalls){
        
        list<Event>  eventsToInsert = new list<Event> (); 
        
        try{
            system.debug('**********************generate Events*******************');
            eventsToInsert = createEventsFromCalls(newCalls);
            system.debug('**********************eventsToInsert******************'+eventsToInsert);
            
            Database.SaveResult[] srList = database.insert(eventsToInsert,false);
            system.debug('**********************eventsInserted******************'+eventsToInsert);
            system.debug('**********************eventsInserted******************'+eventsToInsert.size());
            
            for (Database.SaveResult sr : srList) {
                
                System.debug('sr::'+sr);
                
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted Event. EventID: ' + sr.getId());
                    }
                    else {
                        list<ZTS_EU_Error_Log__c> lstError = new list<ZTS_EU_Error_Log__c>();
                        // Operation failed, so get all errors 
                        String errorMsg = 'ZTS_EU_BatchCreateMissingEventForCall-generateAndSetupEventsFromCalls - '
                            +Datetime.now()+'\n';    
                        System.debug('sr::'+sr);
                        for(Database.Error err : sr.getErrors()) {
                           
                            ZTS_EU_Error_Log__c objError = new ZTS_EU_Error_Log__c();
                            objError.ZTS_EU_Message__c = errorMsg+' :: ' + err.getMessage()+' :: fields - '+ err.getFields();
                            objError.ZTS_EU_Log_level__c = 'ERROR';
                            objError.ZTS_EU_Origin_Type__c = 'DML Operations';
                            objError.ZTS_EU_Status_Code__c = string.valueOf(err.getStatusCode()).substring(0,9);
                            objError.ZTS_EU_SObject__c = 'Event';
                            objError.ZTS_EU_Notify_Admin__c = true;
                            lstError.add(objError);
                            System.debug('The following error has occurred.');                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Event fields that affected this error: ' + err.getFields());
                        }
                        if(lstError.size() > 0)
                            insert lstError;
                    }
            }
        }
        catch(exception ex){
            ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'ZTS_EU_BatchCreateMissingEventForCall-generateAndSetupEventsFromCalls - ');
            system.debug('##### EXCEPTION - '+ex.getmessage());
            system.debug('##### EXCEPTION - '+ex.getstacktracestring());              
        }
    }
    
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
* Method to create an event relation per user from a list of users
* @param list<ZTS_EU_Colleague__c> newColleagues
* @return void
*/  
    public static void createEventRelationsForColleagues(list<ZTS_EU_Colleague__c> newColleagues){
        map<id,set<id>> callIdToContactIdOrUserId_Map   = new map<id,set<id>>();
        map<id,id> callIdToEventId             = new map<id,id>(); 
        list<EventRelation> eventAttendees        = new list<EventRelation>();
        EventRelation tempEventRelation;
        try{
            
            callIdToContactIdOrUserId_Map = getCallIdToColleagueIdOrUserId_Map(newColleagues);
            // changes made in query by adding ischild = false condition by laxmikanth(cloudsense) on 10/30/2014
            for( Event eventIterator : [SELECT id,CallRecordId__c,Ischild FROM Event WHERE CallRecordId__c IN :callIdToContactIdOrUserId_Map.keySet() and ischild = false ORDER BY CreatedDate ASC]){
                callIdToEventId.put(eventIterator.CallRecordId__c,eventIterator.id);
                system.debug('*****Ischild flag**********'+eventIterator.Ischild);
            }
            
            for(Id callId : callIdToEventId.keySet()){
                
                for(id contactIdOrUserId : callIdToContactIdOrUserId_Map.get(callId)){
                    tempEventRelation         = new EventRelation();
                    tempEventRelation.EventId     = callIdToEventId.get(callId);
                    tempEventRelation.RelationId   = contactIdOrUserId;
                    eventAttendees.add(tempEventRelation);
                }
            }
            
            if(eventAttendees!=null && !eventAttendees.isEmpty()){
                List<Database.SaveResult> results=database.insert(eventAttendees,false);
                ZTS_EU_Logger.error(results, 'AttendeeService-createEventRelationsForColleagues');
            }
        }
        catch(exception ex){
            system.debug('##### EXCEPTION - '+ex.getmessage());
            ZTS_EU_Logger.error(ex.getMessage(),null, 'AttendeeService-createEventRelationsForColleagues');
        }
        
        
    }
    
    
  /*
   * Method to prepare a map of callid to set of contact or user id from a list of attendees
   * @param list<ZTS_EU_Colleague__c> attendees
   * @return map<id,set<id>>
  */
  public static map<id,set<id>> getCallIdToColleagueIdOrUserId_Map(list<ZTS_EU_Colleague__c> attendees){
    map<id,set<id>> callIdToContactIdOrUserId_Map   = new map<id,set<id>>();
    set<id> ContactIdOrUserId_Set           = new set<id>();
    Set<String> callIdSet                       = new Set<String>();
    List<String> callIdList                 = new List<String>();
     for(ZTS_EU_Colleague__c attendeeIterator : attendees){
        
        ContactIdOrUserId_Set = new set<id>();
        callIdSet.add(attendeeIterator.ZTS_EU_Call__c);
        
        if (callIdToContactIdOrUserId_Map.containsKey(attendeeIterator.ZTS_EU_Call__c)){
          ContactIdOrUserId_Set = callIdToContactIdOrUserId_Map.get(attendeeIterator.ZTS_EU_Call__c);
        }
        
        if(attendeeIterator.ZTS_EU_User__c!=null)
          ContactIdOrUserId_Set.add(attendeeIterator.ZTS_EU_User__c);
        
        
        callIdToContactIdOrUserId_Map.put(attendeeIterator.ZTS_EU_Call__c,ContactIdOrUserId_Set);
      }
      callIdList.addAll(callIdSet);
      Map<Id,Call__c> callData = new Map<Id,Call__c>([SELECT Id,CreatedById FROM Call__c WHERE Id IN: callIdList]);
      for(Id callId : callIdToContactIdOrUserId_Map.keySet()){
        ContactIdOrUserId_Set           = new set<id>();
        if(callData != null && callData.get(callId)!=null)
          callIdToContactIdOrUserId_Map.get(callId).remove(callData.get(callId).CreatedById);
          callIdToContactIdOrUserId_Map.put(callId,callIdToContactIdOrUserId_Map.get(callId));
          
      }
      
    return callIdToContactIdOrUserId_Map;
  }
  

}