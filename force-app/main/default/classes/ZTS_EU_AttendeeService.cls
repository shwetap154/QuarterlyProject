/*************************************************************************************************************************
  Class Name     : AttendeeService
  Description    : This class contains generic service methods for the Attendee__c and Colleague object.
  Created By     : Deloitte Consulting/Fayas Mansoor
  Created On     : 01/17/2014
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer                      Date                    Description
  ---------                    ----                 -----------
  Deloitte Constulting/Fayas Mansoor  01/17/2014              Created
  Deloitte Constulting/Teresa  06/19/2014              Modified for event creation and deletion whenever Colleagues are added to call
  Deepshikha Tyagi(Cognizant)  09/01/2023             Modified for deleting Campaign Members whenever attendees are removed from the call 
***************************************************************************************************************************/

public with sharing class ZTS_EU_AttendeeService {

  /*
   * Method to create an event relation per attendee from a list of attendees
   * @param list<attendee__c> newAttendees
   * @return void
  */  
  public static void createEventRelations(list<Attendee__c> newAttendees){
  
    map<id,set<id>> callIdToContactIdOrUserId_Map   = new map<id,set<id>>();
    map<id,id> callIdToEventId             = new map<id,id>(); 
    list<EventRelation> eventAttendees        = new list<EventRelation>();
    EventRelation tempEventRelation;
    try{
        
      callIdToContactIdOrUserId_Map = getCallIdToContactIdOrUserId_Map(newAttendees);
      
      for( Event eventIterator : [SELECT id,CallRecordId__c FROM Event WHERE CallRecordId__c = :callIdToContactIdOrUserId_Map.keySet() AND ZTS_EU_Market__c != 'United States']){
        callIdToEventId.put(eventIterator.CallRecordId__c,eventIterator.id);
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
      	List<Database.Saveresult> results=Database.Insert(eventAttendees,false);
        ZTS_EU_Logger.error(results, 'ZTS_EU_AttendeeService-createEventRelations');
      }
    }
    catch(exception ex){
      ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'ZTS_EU_AttendeeService-createEventRelations');
      system.debug('##### EXCEPTION - '+ex.getmessage());
      system.debug('##### EXCEPTION - '+ex.getstacktracestring());
    }
    
    
    
  }
  
  /*
   * Method to delete event relations when attendees are removed from call
   * @param map<id,Attendee__c> deletedAttendeesMap
   * @return void
  */
  public static void deleteEventRelations(map<id,Attendee__c> deletedAttendeesMap){
    map<id,set<id>> callIdToContactIdOrUserId_Map   = new map<id,set<id>>();
    map<id,id> eventIdTocallId             = new map<id,id>(); 
    list<EventRelation> eventAttendeesToDelete    = new list<EventRelation>();
    EventRelation tempEventRelation;
    map<id,Attendee__c> deletedAttendeeMap = new map<id,Attendee__c>();
    try{
      callIdToContactIdOrUserId_Map = getCallIdToContactIdOrUserId_Map(deletedAttendeesMap.values());
      
      for( Event eventIterator : [SELECT id,CallRecordId__c FROM Event WHERE CallRecordId__c = :callIdToContactIdOrUserId_Map.keySet() AND ZTS_EU_Market__c != 'United States']){
        eventIdTocallId.put(eventIterator.id,eventIterator.CallRecordId__c);
      }
      
      for(EventRelation eventRelIterator : [SELECT EventId,RelationId FROM EventRelation WHERE EventId in :eventIdTocallId.keySet() ]){
        Id callId = eventIdTocallId.get(eventRelIterator.eventId);
        if(callIdToContactIdOrUserId_Map.get(callId).contains(eventRelIterator.RelationId))
          eventAttendeesToDelete.add(eventRelIterator);
      }
      
      if(eventAttendeesToDelete!=null && !eventAttendeesToDelete.isEmpty()){
      	List<Database.Deleteresult> results=Database.delete(eventAttendeesToDelete,false);
        ZTS_EU_Logger.error(results, 'ZTS_EU_AttendeeService-deleteEventRelations');
    
      }
    }
    catch(exception ex){
      ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'ZTS_EU_AttendeeService-deleteEventRelations');
      system.debug('##### EXCEPTION - '+ex.getmessage());
      system.debug('##### EXCEPTION - '+ex.getstacktracestring());
    }
  }
  
  
  /*
   * Method to prepare a map of callid to set of contact or user id from a list of attendees
   * @param list<Attendee__c> attendees
   * @return map<id,set<id>>
  */
  public static map<id,set<id>> getCallIdToContactIdOrUserId_Map(list<Attendee__c> attendees){
    map<id,set<id>> callIdToContactIdOrUserId_Map   = new map<id,set<id>>();
    set<id> ContactIdOrUserId_Set           = new set<id>();
    for(Attendee__c attendeeIterator : attendees){
        
        ContactIdOrUserId_Set = new set<id>();
        
        if (callIdToContactIdOrUserId_Map.containsKey(attendeeIterator.ZTS_EU_call__c)){
          ContactIdOrUserId_Set = callIdToContactIdOrUserId_Map.get(attendeeIterator.ZTS_EU_call__c);
        }
        
        if(attendeeIterator.ZTS_EU_Contact__c!=null)
          ContactIdOrUserId_Set.add(attendeeIterator.ZTS_EU_Contact__c);
        if(attendeeIterator.ZTS_EU_Employee__c!=null)
          ContactIdOrUserId_Set.add(attendeeIterator.ZTS_EU_Employee__c);
        
        callIdToContactIdOrUserId_Map.put(attendeeIterator.ZTS_EU_call__c,ContactIdOrUserId_Set);
      }
    return callIdToContactIdOrUserId_Map;
  }
  
  /*
   * Method to create an event relation per user from a list of users
   * @param list<ZTS_EU_Colleague__c> newAttendees
   * @return void
  */  
  public static void createEventRelationsForColleagues(list<ZTS_EU_Colleague__c> newColleagues){
  
    map<id,set<id>> callIdToContactIdOrUserId_Map   = new map<id,set<id>>();
    map<id,id> callIdToEventId             = new map<id,id>(); 
    list<EventRelation> eventAttendees        = new list<EventRelation>();
    EventRelation tempEventRelation;
    try{
        
      callIdToContactIdOrUserId_Map = getCallIdToColleagueIdOrUserId_Map(newColleagues);
      
      for( Event eventIterator : [SELECT id,CallRecordId__c FROM Event WHERE CallRecordId__c = :callIdToContactIdOrUserId_Map.keySet() AND ZTS_EU_Market__c != 'United States' ORDER BY CreatedDate ASC LIMIT 1]){
        callIdToEventId.put(eventIterator.CallRecordId__c,eventIterator.id);
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
        List<Database.Saveresult> results=Database.Insert(eventAttendees,false);
        ZTS_EU_Logger.error(results, 'ZTS_EU_AttendeeService-createEventRelationsForColleagues');
      }
    }
    catch(exception ex){
      ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'ZTS_EU_AttendeeService-createEventRelationsForColleagues');
      system.debug('##### EXCEPTION - '+ex.getmessage());
      system.debug('##### EXCEPTION - '+ex.getstacktracestring());
    }
    
    
    
  }
  
  /*
   * Method to delete event relations when users are removed from call
   * @param map<id,ZTS_EU_Colleague__c> deletedAttendeesMap
   * @return void
  */
  public static void deleteEventRelationsForColleague(map<id,ZTS_EU_Colleague__c> deletedAttendeesMap){
    map<id,set<id>> callIdToContactIdOrUserId_Map   = new map<id,set<id>>();
    map<id,id> eventIdTocallId             = new map<id,id>(); 
    list<EventRelation> eventAttendeesToDelete    = new list<EventRelation>();
    EventRelation tempEventRelation;
    try{
      callIdToContactIdOrUserId_Map = getCallIdToColleagueIdOrUserId_Map(deletedAttendeesMap.values());
      
      for( Event eventIterator : [SELECT id,CallRecordId__c FROM Event WHERE CallRecordId__c = :callIdToContactIdOrUserId_Map.keySet() AND ZTS_EU_Market__c != 'United States' ORDER BY CreatedDate ASC LIMIT 1]){
        eventIdTocallId.put(eventIterator.id,eventIterator.CallRecordId__c);
      }
      
      for(EventRelation eventRelIterator : [SELECT EventId,RelationId FROM EventRelation WHERE EventId in :eventIdTocallId.keySet() ]){
        Id callId = eventIdTocallId.get(eventRelIterator.eventId);
        if(callIdToContactIdOrUserId_Map.get(callId).contains(eventRelIterator.RelationId))
          eventAttendeesToDelete.add(eventRelIterator);
      }
      
      if(eventAttendeesToDelete!=null && !eventAttendeesToDelete.isEmpty()){
        List<Database.Deleteresult> results=Database.delete(eventAttendeesToDelete,false);
        ZTS_EU_Logger.error(results, 'ZTS_EU_AttendeeService-deleteEventRelationsForColleague');
    
      }
    }
    catch(exception ex){
      ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'ZTS_EU_AttendeeService-deleteEventRelationsForColleague');
      system.debug('##### EXCEPTION - '+ex.getmessage());
      system.debug('##### EXCEPTION - '+ex.getstacktracestring());
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
        callIdSet.add(attendeeIterator.ZTS_EU_call__c);
        
        if (callIdToContactIdOrUserId_Map.containsKey(attendeeIterator.ZTS_EU_call__c)){
          ContactIdOrUserId_Set = callIdToContactIdOrUserId_Map.get(attendeeIterator.ZTS_EU_call__c);
        }
        
        if(attendeeIterator.ZTS_EU_User__c!=null)
          ContactIdOrUserId_Set.add(attendeeIterator.ZTS_EU_User__c);
        
        
        callIdToContactIdOrUserId_Map.put(attendeeIterator.ZTS_EU_call__c,ContactIdOrUserId_Set);
      }
      callIdList.addAll(callIdSet);
      Map<Id,Call__c> callData = new Map<Id,Call__c>([SELECT Id,CreatedById FROM Call__c WHERE Id IN: callIdList AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States']);
      for(Id callId : callIdToContactIdOrUserId_Map.keySet()){
      	ContactIdOrUserId_Set           = new set<id>();
      	if(callData != null && callData.get(callId)!=null)
      		callIdToContactIdOrUserId_Map.get(callId).remove(callData.get(callId).CreatedById);
      		callIdToContactIdOrUserId_Map.put(callId,callIdToContactIdOrUserId_Map.get(callId));
      		
      }
      
    return callIdToContactIdOrUserId_Map;
  }
    /*
   * Method to delete Campaign Members when Attendee are removed from call
   * @param map<id,Attendee__c> 
   * @return void
   */
    public static void getRelatedRecordsAndDeleteCampaignMembers(map<id,Attendee__c> deletedAttendeesMap){
        List<ZTS_EU_Discussion__c> discussionList = new List<ZTS_EU_Discussion__c>();
        String Action = '';
        discussionList = [SELECT id, Name,ZTS_EU_Call_Attendee__c,ZTS_EU_Call_Attendee__r.ZTS_EU_call__c,ZTS_EU_Campaign__c,ZTS_EU_Call_Attendee__r.ZTS_EU_Contact__c,ZTS_EU_Campaign__r.ZTS_EU_Field_Targeting__c,ZTS_EU_Campaign__r.IsActive
                          FROM ZTS_EU_Discussion__c 
                          WHERE ZTS_EU_Call_Attendee__c IN :deletedAttendeesMap.keyset() 
                          AND ZTS_EU_Campaign__c != null
                          AND ZTS_EU_Campaign__r.ZTS_EU_Field_Targeting__c ='Open'];
        If(discussionList.size()>0){
             Action = 'Delete';
             DiscussionsService.createDeleteCampaignMembers(discussionList,Action);
        }
    }
     /*
     * Method to put the account from call onto the attendee record.
     * @param list<attendee__c> newAttendees
     * @return void
     * //Newly added line to populate represent acount for INTL Markets TPDEV-2016	
    */  
    public static void populateAccOnAttendee(list<Attendee__c> newAttendees){
            String errorMsg = 'You cannot add same attendee to call again';
            List<String> callname = new List<String>();
            List<String> newCallList = new List<String>();
            List<Id> attendeeId = new List<Id>();
            List<Id> conIdList =new List<Id>();
            Map<Id,Call__c> callAttenMap=new Map<Id,Call__c>();
            for(Attendee__c newattendee : newAttendees){
                newCallList.add(newattendee.ZTS_EU_call__c);
                //conIdList.add(newattendee.ZTS_EU_Contact__c);
                
            }
            callAttenMap=new Map<Id,Call__c>([Select Id,ZTS_EU_Account__c from Call__c where Id in:newCallList]);
            system.debug('david map: ' + callAttenMap);
            List<Attendee__c> AttendeeRecords = [SELECT Id,ZTS_EU_Represents_Account__c,ZTS_EU_Contact__c,ZTS_EU_call__c,ZTS_EU_call__r.ZTS_EU_Account__c FROM Attendee__c WHERE ZTS_EU_call__c IN: newCallList AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
            system.debug('============AttendeeRecord==========='+AttendeeRecords);
            List<Contact> callContacts=[Select Id,Name from Contact where Id in:conIdList AND ZTS_EU_Market__c != 'United States'];
            //Check if the same attendee already exists on the Call.If yes, display the error message.
            
            for(Attendee__c newRec : newAttendees){
              //system.debug('david record:' + newRec.Id);
                //system.debug('======ACCID======'+callAttenMap.get(newRec.ZTS_EU_call__c).ZTS_EU_Account__c);
                    if(callAttenMap.containsKey(newRec.ZTS_EU_call__c)){
                        newRec.ZTS_EU_Represents_Account__c=callAttenMap.get(newRec.ZTS_EU_call__c).ZTS_EU_Account__c;
                        system.debug('should be in here');
                        }
                    for (Attendee__c ExistingRec: AttendeeRecords)
                        {
                        system.debug('===='+ExistingRec.ZTS_EU_Contact__c+'===='+newRec.ZTS_EU_Contact__c+'===='+ExistingRec.ZTS_EU_call__c+'===='+newRec.ZTS_EU_call__c+'===='+ExistingRec.ZTS_EU_Represents_Account__c+'===='+newRec.ZTS_EU_Represents_Account__c);
                        if(ExistingRec.ZTS_EU_Contact__c == newRec.ZTS_EU_Contact__c && ExistingRec.ZTS_EU_call__c  == newRec.ZTS_EU_call__c && ExistingRec.ZTS_EU_Represents_Account__c==newRec.ZTS_EU_Represents_Account__c ){
                            newRec.addError(errorMsg);
                        }
                    }
                    system.debug('print once end of for loop');               
                }
            }
    
    
}