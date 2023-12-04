/*************************************************************************************************************************
  Class Name     : TOTService_ForCreateduser
  Description    : This class contains generic service methods for the ToT object.
  Created By     : Deloitte Consulting/Chandra
  Created On     : 05/22/2014
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Deloitte Constulting/Chandra    05/22/2014                      Created
  Priya Krishnamurthy             29/04/2015                      Modified
***************************************************************************************************************************/

public with sharing class TOTService_ForCreateduser {
    public Static Boolean isEventUpdatingCall = False;
    public Static Boolean isToTUpdatingEvent = False;
    public Static Boolean isEventDeletingCall = False;
 //   Boolean isEventUpdatingCall = False;
            
    // Call object fields to Event object field mapping 
    public final static map<string, string> totFieldToEventFieldMap = new map<string, string>{
                                                                        'OwnerId'           => 'OwnerId',
                                                                        'ZTS_EU_Type__c'                  => 'Subject',
                                                                        'ZTS_EU_Reason__c'    => 'Description',
                                                                        'ZTS_EU_Start_Date_Time__c'    => 'ActivityDateTime',
                                                                        'ZTS_EU_End_Date_Time__c'      => 'EndDateTime',                                                            
                                                                        'Id'            => 'WhatId'   ,
                                                                        'ZTS_EU_DurationInMinutes__c' => 'DurationInMinutes', 
                                                                         'ZTS_EU_Status__c' => 'ZTS_EU_Status__c'
                                                                        };
    
    /*
     * Method to create an event per call for a list of calls
     * @param list<Call__> newCalls
     * @return list<Event> 
    */                                           
    public static list<Event> createEventsFromToTs(list<Time_Out_of_Territory__c> newToTs){
        
        list<Event> newEvents = new list<Event>();
        list<Event> tempEvent;
        
        for(Time_Out_of_Territory__c totIterator : newToTs){
            tempEvent = createEventFromToT(totIterator);
            if(tempEvent!=null){
                //newEvents=tempEvent;
                newEvents.addAll(tempEvent);
            }
        }	
        return newEvents;
    }
    
    /*
     * Method to create an event for a tots
     * @param Time_Out_of_Territory__c totRec
     * @return Event 
    */
    public static List<Event> createEventFromToT(Time_Out_of_Territory__c totRec){
        
       List<Event> eventRecList      = new List<Event>();
        Event eventRec=new Event();
  // Srinivas K added event record type Id to event object 
     ZTS_EU_Field_ID__c record = ZTS_EU_Field_ID__c.getInstance('Event object Regular Event');
             eventRec.RecordTypeId=record.ZTS_EU_ID__c;
    // Srinivas K added code for to set ZTS_custom_Event__c filed value part of DEF-001263
       eventRec.ZTS_custom_Event__c=true;

        eventRecList.add(eventRec);
        mapToTToEventFields(totRec,eventRecList);
        return eventRecList;
        }
    
    /*
     * Method to map fields from call object to event object record 
     * @param Time_Out_of_Territory__c callRec
     * @param event eventRec
     * @return none 
    */
    public static void mapToTToEventFields(Time_Out_of_Territory__c totRec, List<Event> eventRecList){
        string eventFieldName;
        For(Event eventRec:eventRecList)
        {
            for(string totFieldName : totFieldToEventFieldMap.keySet()){
            
            eventFieldName = totFieldToEventFieldMap.get(totFieldName);
            if(totFieldToEventFieldMap.get(totFieldName).equals('DurationInMinutes')) 
            {
            integer x= Integer.valueof(totRec.get(totFieldName));
                if(x<0) 
                {
                    eventRec.put(eventFieldName, -1*(x));
                }
                else
                {
                    eventRec.put(eventFieldName,x);
                }
            }
            
            else
            eventRec.put(eventFieldName,totRec.get(totFieldName));
        } 
       } 
    }
        
        
    
    /*
       *Method to check and skip weekends when a tot record is created
       * @param Time_Out_of_Territory__c StartDateTime
       * @return Boolean value
    */
    
    //Method included by priya to skip weekends in Tot creation.
    
    public static boolean isWeekDay(DateTime startdatetime, Map<String, String> businessHoursMap, User user)
    {
        system.debug('outside weekday boolean');
     boolean isWeekDay = false;
                    if(businessHoursMap.get(user.ZTS_EU_Market__c ) != null){
                      isWeekDay = BusinessHours.isWithin(businessHoursMap.get(user.ZTS_EU_Market__c), startdatetime);
                        system.debug('isWeekDay' + isWeekDay);
                    }
        
        return isWeekDay;
    }

    
    /*
     * Method to generate events from tot records and insert them 
     * @param list<Time_Out_of_Territory__c> newToTs
     * @return none 
    */
    public static void generateAndSetupEventsFromToTs(list<Time_Out_of_Territory__c> newToTs){
           
        list < Event > eventsToInsert = new list < Event > ();
        try {
            List<Event> resultEvent = new List<Event>();
            eventsToInsert = createEventsFromToTs(newToTs);
            //Added by Priya to insert an event for each single day.
           User user=[select ZTS_EU_Market__c from user where id=:userinfo.getUserid() AND ZTS_EU_Market__c !='United States']; 
          List<BusinessHours> businessHoursList = new List<BusinessHours>();
          Map<String, String> businessHoursMap = new Map<String, String>();
          businessHoursList = [SELECT Id, Name FROM BusinessHours WHERE Name=: user.ZTS_EU_Market__c ];
        for(BusinessHours bh: businessHoursList){
            businessHoursMap.put(bh.Name, bh.Id);
        }
			
            For(Event insertEvent: eventsToInsert){
            Event event= insertEvent;
            Event dailyEvent;
            DateTime startDate=event.ActivityDateTime;
            DateTime endDate=event.EndDateTime;
            Time endTime= Time.newInstance(endDate.hour() , endDate.minute(), endDate.second(),endDate.millisecond());
            Integer numberOfDays =  startDate.Date().daysBetween(endDate.Date());
            eventsToInsert = new list < Event > ();
            for(integer i=0;i<=numberOfDays;i++)
            {
               dailyEvent=new Event();
               dailyEvent.ActivityDateTime=startDate.AddDays(i);
               dailyEvent.RecordTypeId=event.RecordTypeId;
                system.debug('--------my record event'+dailyEvent.RecordTypeId);
               dailyEvent.Description=event.Description;
               dailyEvent.WhatId=event.WhatId;
               dailyEvent.Subject=event.Subject;
                dailyEvent.ZTS_custom_Event__c=true;
                dailyEvent.OwnerId=event.OwnerId;
               //dailyEvent.DurationInMinutes=event.DurationInMinutes;
                dailyEvent.ZTS_EU_Status__c = event.ZTS_EU_Status__c;
               dailyEvent.EndDateTime=DateTime.newInstance( dailyEvent.ActivityDateTime.Date(), endTime); 
               //Removed the Weekday check by Mayukh Deb as part of the SC-002798
               //if(isWeekDay(dailyEvent.ActivityDateTime,businessHoursMap,user))
               //{
               eventsToInsert.add(dailyEvent);
               //}
            }
            //}
            //end of event for each single day 

           //to remove duplicates from List
            Set<Event> eventset = new Set<Event>();
            eventset.addAll(eventsToInsert);
            resultEvent.addAll(eventset);
            }
            system.debug('resultEvent.size()-->'+resultEvent.size());
            //START: Code added for testing the issue
            for(Event e: resultEvent)
            {
                system.debug('#####'+e);
            }
           integer cnt =resultEvent.size()/10;
            integer counter =0;
            List <Event> lstEvnttoCreate = new List<Event>();
            for(Integer i=0; i<resultEvent.size(); i++) 
            {              
                lstEvnttoCreate.add(resultEvent[i]);
                system.debug('####'+resultEvent[i]);
                counter++;
                if(counter == 9){
                    Database.insert(lstEvnttoCreate);
                    lstEvnttoCreate.clear();
                    system.debug('Insert Success');
                    counter =0;                    
                }               
            }
            if(lstEvnttoCreate.size() >0){
            	database.insert(lstEvnttoCreate);
            	system.debug('#####Event Id: ' + lstEvnttoCreate[0].id);
            }
            //END: Code added for testing the issue
            //Below line needs to uncommented after test code is deleted/commented
            //database.insert(resultEvent);
            }
       catch (exception ex) {
            system.debug('##### EXCEPTION - ' + ex.getmessage());
            system.debug('##### EXCEPTION - ' + ex.getstacktracestring());

        }

    }
    
    /*
     * Method to iterator over new and old maps find out which all tot records require an update to event record
     * and invoke method to update them 
     * @param map<id,Time_Out_of_Territory__c> newToTsMap
     * @param map<id,Time_Out_of_Territory__c> oldToTsMap
     * @return none 
    */
    public static void updateAndSyncEventsFromToTs(map<id,Time_Out_of_Territory__c> newToTsMap, map<id,Time_Out_of_Territory__c> oldToTMap){
        boolean isEventUpdateRequired = false;
        list<Time_Out_of_Territory__c> ToTsToUpdateEvents = new list<Time_Out_of_Territory__c>();
        set<Id> totOwnerId= new set<id>();
        
        for(Time_Out_of_Territory__c totIterator : newToTsMap.values()){
            isEventUpdateRequired = checkForValueChange(totIterator, oldToTMap.get(totIterator.id));
              if(totIterator.ownerId!=null){
                totOwnerId.add(totIterator.Ownerid);
                  
            }
            if(isEventUpdateRequired){
                ToTsToUpdateEvents.add(totIterator);
                
            }
        }
        updateEventsFromToTs(ToTsToUpdateEvents,totOwnerId); 
                
    }
    
    /*
     * Method to compare two tot record (old and new) in case of update trigger and return true if 
     * one of fields mapped to event is changed
     * @param Time_Out_of_Territory__c newToT
     * @param Time_Out_of_Territory__c oldToTs
     * @return boolean 
    */
    public static boolean checkForValueChange(Time_Out_of_Territory__c newToT, Time_Out_of_Territory__c oldToT){
        boolean isValueChanged = false;
        
        for(string totFieldName : totFieldToEventFieldMap.keySet()){

            if(newToT.get(totFieldName)!=oldToT.get(totFieldName)){
                isValueChanged = true;
                break;
            }
            
        }
        
        return isValueChanged;
    }
    
    /*
     * Method to query related events from calls and update fields  
     * @param list<Time_Out_of_Territory__c> CallsToUpdateEvents
     * @return none 
    */
    public static void updateEventsFromToTs(list<Time_Out_of_Territory__c> totsToUpdateEvents,set<id> totOwnerId){
        
        map<Id, Time_Out_of_Territory__c> totsToUpdateEvents_map = new map<Id, Time_Out_of_Territory__c>(totsToUpdateEvents);
        	
        map<Id,List<Event>> ToTId_Event_map   = new map<Id,List<Event>>();
        	
        List<Event> tempEventList = new List <Event>();
        List<Event> updateEventList = new List <Event>();
        List <Event> queryEvents= new List<Event>();
          if(totOwnerId!=null){
       		queryEvents=[SELECT Id,WhatId FROM Event WHERE WhatId in : totsToUpdateEvents_map.keyset() and ownerId in :totOwnerId AND ZTS_EU_Market__c != 'United States'];//get all the events for the affected TOTs
                    }
               try{
                   list<Event> lstOfEventTemp;
            for(Event eventIterator : queryEvents){
                if(ToTId_Event_map.get(eventIterator.WhatId) != null){
                    lstOfEventTemp = ToTId_Event_map.get(eventIterator.WhatId);
                    }	
                else
                    lstOfEventTemp = new list<Event>();
    				lstOfEventTemp.add(eventIterator);
                	ToTId_Event_map.put(eventIterator.WhatId, lstOfEventTemp);
            }
       
            for(Id totId : ToTId_Event_map.keySet()){
               // mapToTToEventFields(totsToUpdateEvents_map.get(totId),ToTId_Event_map.get(totId));
                updateEventList.addAll(ToTId_Event_map.get(totId));
            }  
            
                        
            //to remove duplicates from List
            Set<Event> eventset = new Set<Event>();
            List<Event> resultEvent = new List<Event>();
            eventset.addAll(updateEventList);
            resultEvent.addAll(eventset);
            delete resultEvent;
            generateAndSetupEventsFromToTs(totsToUpdateEvents);

        }
        
        catch(exception ex){
            system.debug('##### EXCEPTION - '+ex.getmessage());
            system.debug('##### EXCEPTION - '+ex.getstacktracestring());
        }
        
    }
    
    /*
     * Method to query for related events and delete them  
     * @param map<id,Time_Out_of_Territory__c> deletedCallsMap
     * @return none 
    */
  /*  public static void deleteRelatedEvents(List<Time_Out_of_Territory__c> deletedToTslst){
        
        List<Event> eventsToDelete;
        Set<Id> totids = new Set<Id>();
        try{
            for(Time_Out_of_Territory__c tot : deletedToTslst){
            if(tot.ZTS_EU_Status__c == 'Cancelled'){
            
            totids.add(tot.id);
            
            }
            eventsToDelete = [SELECT Id FROM Event WHERE WhatId IN : totids AND ZTS_EU_Market__c != 'United States'];
         
            if(eventsToDelete!=null && !eventsToDelete.isEmpty()){
                isEventUpdatingCall = True;
                database.delete(eventsToDelete);    
            }
            }
        }
        
        catch(exception ex){
            system.debug('##### EXCEPTION - '+ex.getmessage());
            system.debug('##### EXCEPTION - '+ex.getstacktracestring());
        }
    } */
    
}