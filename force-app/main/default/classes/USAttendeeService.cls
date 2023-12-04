/*************************************************************************************************************************
  Class Name     : AttendeeService
  Description    : This class contains generic service methods for the Attendee__c object.
  Created By     : Deloitte Consulting/Fayas Mansoor
  Created On     : 01/17/2014
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Deloitte Constulting/Fayas Mansoor    01/17/2014              Created

***************************************************************************************************************************/

public without sharing class USAttendeeService {

    /*
     * Method to put the account from call onto the attendee record.
     * @param list<attendee__c> newAttendees
     * @return void
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
            List<Attendee__c> AttendeeRecords = [SELECT Id,ZTS_EU_Represents_Account__c,ZTS_EU_Contact__c,ZTS_EU_call__c,ZTS_EU_call__r.ZTS_EU_Account__c FROM Attendee__c WHERE ZTS_EU_call__c IN: newCallList AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States'];
            system.debug('============AttendeeRecord==========='+AttendeeRecords);
            List<Contact> callContacts=[Select Id,Name from Contact where Id in:conIdList AND ZTS_EU_Market__c = 'United States'];
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
    /*
     * Method to create an event relation per attendee from a list of attendees
     * @param list<attendee__c> newAttendees
     * @return void
    */  
    public static void createEventRelations(list<Attendee__c> newAttendees){
    
        map<id,set<id>> callIdToContactIdOrUserId_Map   = new map<id,set<id>>();
        map<id,id> callIdToEventId                      = new map<id,id>(); 
        list<EventRelation> eventAttendees              = new list<EventRelation>();
        EventRelation tempEventRelation;
        
        try{
                
            callIdToContactIdOrUserId_Map = getCallIdToContactIdOrUserId_Map(newAttendees);
            
            // changes made in query by adding ischild = false condition by laxmikanth(cloudsense) on 10/30/2014
            for( Event eventIterator : [SELECT id,CallRecordId__c,Ischild FROM Event WHERE CallRecordId__c IN : callIdToContactIdOrUserId_Map.keySet() and Ischild = false AND ZTS_EU_Market__c = 'United States']){
                callIdToEventId.put(eventIterator.CallRecordId__c,eventIterator.id);
                
                system.debug('*****Ischild flag*******'+eventIterator.Ischild);
            }
            
            for(Id callId : callIdToEventId.keySet()){
                
                for(id contactIdOrUserId : callIdToContactIdOrUserId_Map.get(callId)){
                    tempEventRelation               = new EventRelation();
                    tempEventRelation.EventId       = callIdToEventId.get(callId);
                    tempEventRelation.RelationId    = contactIdOrUserId;
                    eventAttendees.add(tempEventRelation);
                }
            }
            
            if(eventAttendees!=null && !eventAttendees.isEmpty()){
              
                List<Database.Saveresult> results=database.insert(eventAttendees,false);
                 ZTS_EU_Logger.error(results, 'AttendeeService-createEventRelations');
                
            }
        }
        catch(exception ex){
            system.debug('##### EXCEPTION - '+ex.getmessage());
            ZTS_EU_Logger.error(ex.getMessage(),null, 'AttendeeService-createEventRelations');
        }
        
        
        
    }
    
    /*
     * Method to delete event relations when attendees are removed from call
     * @param map<id,Attendee__c> deletedAttendeesMap
     * @return void
    */
    public static void deleteEventRelations(map<id,Attendee__c> deletedAttendeesMap){
        map<id,set<id>> callIdToContactIdOrUserId_Map   = new map<id,set<id>>();
        map<id,id> eventIdTocallId                      = new map<id,id>(); 
        list<EventRelation> eventAttendeesToDelete      = new list<EventRelation>();
        EventRelation tempEventRelation;
        try{
            callIdToContactIdOrUserId_Map = getCallIdToContactIdOrUserId_Map(deletedAttendeesMap.values());
            
            for( Event eventIterator : [SELECT id,CallRecordId__c FROM Event WHERE CallRecordId__c = :callIdToContactIdOrUserId_Map.keySet() AND ZTS_EU_Market__c = 'United States']){
                eventIdTocallId.put(eventIterator.id,eventIterator.CallRecordId__c);
            }
            
            for(EventRelation eventRelIterator : [SELECT EventId,RelationId FROM EventRelation WHERE EventId in :eventIdTocallId.keySet() ]){
                Id callId = eventIdTocallId.get(eventRelIterator.eventId);
                if(callIdToContactIdOrUserId_Map.get(callId).contains(eventRelIterator.RelationId))
                    eventAttendeesToDelete.add(eventRelIterator);
            }
           
            if(eventAttendeesToDelete!=null && !eventAttendeesToDelete.isEmpty()){
                List<Database.Deleteresult> delresults=database.delete(eventAttendeesToDelete,false);
                ZTS_EU_Logger.error(delresults, 'AttendeeService-deleteEventRelations');
            }
        }
        catch(exception ex){
            system.debug('##### EXCEPTION - '+ex.getmessage());
             ZTS_EU_Logger.error(ex.getMessage(),null, 'AttendeeService-deleteEventRelations');
        }
    }
    
    
    /*
     * Method to prepare a map of callid to set of contact or user id from a list of attendees
     * @param list<Attendee__c> attendees
     * @return map<id,set<id>>
    */
    public static map<id,set<id>> getCallIdToContactIdOrUserId_Map(list<Attendee__c> attendees){
        map<id,set<id>> callIdToContactIdOrUserId_Map   = new map<id,set<id>>();
        set<id> ContactIdOrUserId_Set                   = new set<id>();
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
      for( Event eventIterator : [SELECT id,CallRecordId__c,Ischild FROM Event WHERE CallRecordId__c IN :callIdToContactIdOrUserId_Map.keySet() and ischild = false AND ZTS_EU_Market__c = 'United States' ORDER BY CreatedDate ASC]){
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
   * Method to create an account share records per user from a list of colleagues
   * @param list<ZTS_EU_Colleague__c> newColleagues
   * @return void
  */  
 public static void createAccShareForColleagues(list<ZTS_EU_Colleague__c> newColleagues){ 
 List <AccountShare> accShareList = new List<AccountShare>();
  for(ZTS_EU_Colleague__c calcol : [Select ZTS_EU_User__c,ZTS_EU_Call__c,ZTS_EU_Call__r.ZTS_EU_Account__c,ZTS_EU_Call__r.ZTS_EU_Call_Owner__c from ZTS_EU_Colleague__c where id IN : newColleagues AND ZTS_EU_Market__c = 'United States'])
        {
            system.debug('*******ZTS_EU_Call__r.ZTS_EU_Account__c******'+calcol.ZTS_EU_Call__r.ZTS_EU_Account__c);
            
            if(calcol.ZTS_EU_User__c!=calcol.ZTS_EU_Call__r.ZTS_EU_Call_Owner__c){
             AccountShare  accShare = new AccountShare ();
             accShare.AccountId = calcol.ZTS_EU_Call__r.ZTS_EU_Account__c;
             accShare.UserOrGroupId = calcol.ZTS_EU_User__c;
              accShare.AccountAccessLevel = 'Read';
             accShare.OpportunityAccessLevel = 'Read';
             accShare.ContactAccessLevel = 'None';
             //accShare.RowCause = Schema.AccountShare .RowCause.ZTS_US_Share_Events_Internal_Invitees__c;
             accShareList.add(accShare);
             //callId.add(calcol.ZTS_EU_Call__c);
            }
          }
        
            try {
                    List<Database.Saveresult> results=Database.insert(accShareList,false);
                    ZTS_EU_Logger.error(results, 'AttendeeService-createAccShareForColleagues');
                }
                catch(Exception e){
                   ZTS_EU_Logger.error('Non DMLException : '+e.getMessage(), null, 'AttendeeService-createAccShareForColleagues');
                }
         }
 /*
   * Method to delete an account share record when a colleague is deleted
   * @param list<ZTS_EU_Colleague__c> newColleagues
   * @return void
  */ 
public static void deleteAccShareForColleagues(list<ZTS_EU_Colleague__c> delColleagues){
    List <AccountShare> accsharetodelete = new List<AccountShare>();
    Set<Id> colIdset=new Set<Id>();
    Set<Id> accIdSet=new Set<Id>();
    List<ZTS_EU_Colleague__c> collist= [Select Id,ZTS_EU_User__c,ZTS_EU_Call__c,ZTS_EU_Call__r.ZTS_EU_Account__c,ZTS_EU_Call__r.ZTS_EU_Call_Owner__c from ZTS_EU_Colleague__c where Id IN:delColleagues AND ZTS_EU_Market__c = 'United States'];
      for(ZTS_EU_Colleague__c col:collist){
      colIdset.add(col.ZTS_EU_User__c);
      accIdSet.add(col.ZTS_EU_Call__r.ZTS_EU_Account__c);
      }
      //changes made by laxmikanth(cloudsense) to the query on 11/3/2014
      accsharetodelete=[Select Id from AccountShare where UserOrGroupId IN:colIdset and AccountId IN:accIdSet];
      //delete accsharetodelete;
       try{
                    List<Database.Deleteresult> results=Database.delete(accsharetodelete,false);
                    ZTS_EU_Logger.error(results, 'AttendeeService-deleteAccShareForColleagues');
                }
                catch(Exception e){
                   ZTS_EU_Logger.error('Non DMLException : '+e.getMessage(), null, 'AttendeeService-deleteAccShareForColleagues');
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
      for( Event eventIterator : [SELECT id,CallRecordId__c FROM Event WHERE CallRecordId__c = :callIdToContactIdOrUserId_Map.keySet() AND ZTS_EU_Market__c = 'United States' ORDER BY CreatedDate ASC]){
        eventIdTocallId.put(eventIterator.id,eventIterator.CallRecordId__c);
      }
      
      for(EventRelation eventRelIterator : [SELECT EventId,RelationId FROM EventRelation WHERE EventId in :eventIdTocallId.keySet() ]){
        Id callId = eventIdTocallId.get(eventRelIterator.eventId);
        if(callIdToContactIdOrUserId_Map.get(callId).contains(eventRelIterator.RelationId))
          eventAttendeesToDelete.add(eventRelIterator);
      }
      
      if(eventAttendeesToDelete!=null && !eventAttendeesToDelete.isEmpty()){
        List<Database.Deleteresult> delresult=database.delete(eventAttendeesToDelete,false);
         ZTS_EU_Logger.error(delresult, 'AttendeeService-deleteEventRelationsForColleague');
      }
    }
    catch(exception ex){
      system.debug('##### EXCEPTION - '+ex.getmessage());
       ZTS_EU_Logger.error(ex.getMessage(), null,'AttendeeService-deleteEventRelationsForColleague');
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