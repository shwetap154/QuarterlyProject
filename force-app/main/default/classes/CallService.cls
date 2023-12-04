/*************************************************************************************************************************
  Class Name     : CallService
  Description    : This class contains generic service methods for the Cal__c object.
  Created By     : Deloitte Consulting/Fayas Mansoor
  Created On     : 01/17/2014
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Deloitte Constulting/Fayas Mansoor    01/17/2014              Created
  CloudSense / Sohil Shah               07/21/2015              Added Code for Call Type Transaltion 
  Elton Barbosa                         9/2/2020                Added code to translate call subtype
  Aritra (Cognizant)					08/10/2021				Updated method 'createEventsFromCalls' to pass call duration while creating events for that (SC-004726)
***************************************************************************************************************************/

public with sharing class CallService {
    
    public static boolean flag = false;
    
    // Call object fields to Event object field mapping 
    public final static map<string, string> callFieldToEventFieldMap = new map<string, string>{
                                                                        'ZTS_EU_Call_Owner__c'           => 'OwnerId',
                                                                        'Name'                  => 'Subject',
                                                                        'ZTS_EU_Call_Objectives__c'    => 'Description',
                                                                        'ZTS_EU_Account__c'            => 'WhatId',
                                                                        'ZTS_EU_Start_Date_Time__c'    => 'ActivityDateTime',
                                                                        'ZTS_EU_End_Date_Time__c'      => 'EndDateTime',
                                                                        'ZTS_EU_Status__c'      =>  'Location',
                                                                        'Id'                    => 'CallRecordId__c',
                                                                        'ZTS_EU_Local_Subtype__c'     => 'Local_sub_type__c',
                                                                         'ZTS_EU_Sub_Type__c'  =>   'Sub_Type__c',
                                                                         'Contact_Employee__c'  =>  'Contact_Employee__c',
                                                                        
                                                                        //'Discussion_Item__c' => 'Discussion_Item__c',
                                                                        'Contact_Employee_Count__c' => 'Contact_Employee_Count__c',
                                                                        'Discussion_Item_Count__c' => 'Discussion_Item_Count__c'
                                                                        };
    
     public static String eventRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sales_Call'].Id;
    
    
    /*
     * Method to create an event per call for a list of calls
     * @param list<Call__> newCalls
     * @return list<Event> 
    */                                           
    public static list<Event> createEventsFromCalls(list<Call__c> newCalls){
        
        
        list<Event> newEvents = new list<Event>();
        Event tempEvent;
        list<call__c> calleve = [select id,name, ZTS_EU_Call_Owner__r.isActive ,ZTS_EU_Call_Owner__r.profileid,ZTS_EU_ACCOUNT__C, CONTACT_EMPLOYEE_COUNT__C, CONTACT_EMPLOYEE__C, ZTS_EU_ADDITIONAL_NOTES__C, ZTS_EU_ADDRESS__C,ZTS_EU_CALL_OBJECTIVES__C,
                                 ZTS_EU_CITY__C,ZTS_EU_DURATION__C,ZTS_EU_END_DATE_TIME__C,ZTS_EU_EXPENSE_TYPE__C,ZTS_EU_EXPENSE_VALUE__C, ZTS_EU_LOCAL_SUBTYPE__C,ZTS_EU_NEXT_CALL_DATE__C,ZTS_EU_NEXT_STEP__C,ZTS_EU_START_DATE_TIME__C,ZTS_EU_STATUS__C, 
                                    ZTS_EU_SUB_TYPE__C,ZTS_EU_SUBMITTED_DATE__C, ZTS_EU_CALL_OWNER__C,ZTS_EU_HISTORICAL_OWNER_NAME__C,ZTS_EU_RECORD_OWNER__C,DISCUSSION_ITEM_COUNT__C, DISCUSSION_ITEM__C,INTEGRATION_ID__C from call__c where id in : newCalls AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        system.debug('calleve -->'+calleve );
        for(Call__c callIterator : calleve){
            tempEvent = createEventFromCall(callIterator);
            tempEvent.RecordTypeId = eventRecordTypeId;  
            system.debug('user check active====' + callIterator.ZTS_EU_Call_Owner__r.isActive );
            system.debug('user profile check====' + callIterator.ZTS_EU_Call_Owner__r.profileid );
            system.debug('user owner====' + callIterator.ZTS_EU_Call_Owner__c );
            if(callIterator.ZTS_EU_Call_Owner__r.profileid!=null && callIterator.ZTS_EU_Call_Owner__r.profileid != '00eF0000000U6IsIAK'){
            if(tempEvent!=null){
                system.debug('inside if====' );
                //Aritra added below part to set event duration (this part is present in callservice for US version) 
                //previously for INTL, the end date calculation used to be done in the VF page controller.(SC-004726)
                if(callIterator.ZTS_EU_Duration__c != NULL )
                {
                    tempEvent.DurationInMinutes = Integer.valueOf(Double.valueOf(callIterator.ZTS_EU_Duration__c.split(' ')[0].trim()) * 60);
                }
                newEvents.add(tempEvent);
            }
        }
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
        System.debug('eventRec--------'+eventRec);
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

                    if (sr.isSuccess()) {

                        // Operation was successful, so get the ID of the record that was processed

                        System.debug('Successfully inserted Event. EventID: ' + sr.getId());

                    }

                    else {

                        // Operation failed, so get all errors               

                        for(Database.Error err : sr.getErrors()) {

                            System.debug('The following error has occurred.');                   

                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
        
                            System.debug('Event fields that affected this error: ' + err.getFields());

                        }

                    }

            }


            
        }
        
        catch(exception ex){
            ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'CallService-generateAndSetupEventsFromCalls');
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
             System.debug('oldCallsMap.get(callIterator.id)--------'+oldCallsMap.get(callIterator.id));
             System.debug('oldCallowner--------'+oldCallsMap.get(callIterator.id).ZTS_EU_Call_Owner__c);
             System.debug('newcallonwer--------'+newCallsMap.get(callIterator.id).ZTS_EU_Call_Owner__c);
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
        System.debug('isValueChanged---------'+isValueChanged);
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
            for(Event eventIterator : [SELECT Id,CallRecordId__c,IsChild FROM Event WHERE CallRecordId__c in : callsToUpdateEvents_map.keyset() and IsChild = false AND ZTS_EU_Market__c != 'United States']){
                    CallId_Event_map.put(eventIterator.CallRecordId__c, eventIterator);
            }
            
            for(Id callId : CallId_Event_map.keySet()){
                mapCallToEventFields(callsToUpdateEvents_map.get(callId),CallId_Event_map.get(callId));
            }       
           
            database.update(CallId_Event_map.values());
        }
        
        catch(exception ex){
            ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'CallService-updateEventsFromCalls');
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
            
            eventsToDelete = [SELECT Id FROM Event WHERE CallRecordId__c in :deletedCallsMap.keySet() AND ZTS_EU_Market__c != 'United States'];
            if(eventsToDelete!=null && !eventsToDelete.isEmpty()){
                database.delete(eventsToDelete);    
            }
        }
        
        catch(exception ex){
            ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'CallService-deleteRelatedEvents');
            system.debug('##### EXCEPTION - '+ex.getmessage());
            system.debug('##### EXCEPTION - '+ex.getstacktracestring());
        }
    }
    public static void updateCallOwner(List<ZTS_EU_Colleague__c> newcolleagueList)
    {
        //string subtype;
        //List<Call__C> OriginalcallList = new List<Call__C>();
        List<Call__C> callList = new List<Call__C>();
        List<Call__C> callToUpdateList = new List<Call__C>();
        set<Id> callIDs = new Set<Id>();
        /*string sd;
        integer day;
        integer month;
        integer year ;
        date mydate;
        string name;
        DateTime dt;*/
        for(ZTS_EU_Colleague__c colleague : newcolleagueList)
        {
            callIDs.add(colleague.ZTS_EU_Call__c);
        }
        //OriginalcallList = [Select id, Name,Completed_Calls__c , ZTS_EU_Start_Date_Time__c,ZTS_EU_Sub_Type__c, ZTS_EU_Call_Owner__c from Call__C where Id IN:callIDs];
        //subtype = OriginalcallList[0].ZTS_EU_Sub_Type__c;
        System.debug('call-----'+callList);
        callList = [Select id, Name,Completed_Calls__c , ZTS_EU_Start_Date_Time__c,ZTS_EU_Sub_Type__c, ZTS_EU_Call_Owner__c,(Select Id,ZTS_EU_User__r.Name,ZTS_EU_User__c from Colleagues__r) from Call__C where Id IN:callIDs AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        List<ZTS_EU_Colleague__c> tempcolleagueList = new List<ZTS_EU_Colleague__c>();
        Map<ID,List<ZTS_EU_Colleague__c>> callColleagueMap = new Map<ID,List<ZTS_EU_Colleague__c>>();
        for(call__C call: callList)
        {
            tempcolleagueList.addAll(call.Colleagues__r);
            callColleagueMap.put(call.id,tempcolleagueList);
            System.debug('callColleagueMap-----'+callColleagueMap);
            for(ZTS_EU_Colleague__c colleague: callColleagueMap.get(call.id))
            {
                if(colleague.ZTS_EU_User__r.Name !='Data Admin')
                {
                    call.ZTS_EU_Call_Owner__c = colleague.ZTS_EU_User__c;
                    break;
                }
                else
                {
                    call.ZTS_EU_Call_Owner__c = null;
                }
                
            }
            /*dt = call.ZTS_EU_Start_Date_Time__c;
            sd = string.valueOf(dt.date());
            mydate = Date.valueOf(sd);
            day = myDate.day();
            month = myDate.month();
            year = myDate.year();
            name = call.ZTS_EU_Sub_Type__c + ' - ' + day + '/' + month + '/' + year;
            call.Name = name;
            call.ZTS_EU_Sub_Type__c = subtype;*/
            callToUpdateList.add(call);
        }
        
        
        //List<ZTS_EU_Colleague__c> colleagueList = new List<ZTS_EU_Colleague__c>();
        //colleagueList = [Select Id,ZTS_EU_User__c,ZTS_EU_User__r.Name,ZTS_EU_Call__r.ZTS_EU_Call_Owner__c from ZTS_EU_Colleague__c where ZTS_EU_Call__c IN:callColleagueMap.keySet() and ZTS_EU_User__r.Name !=: 'Data Admin' AND ZTS_EU_Market__c != 'United States'];
        
        update callToUpdateList;
        System.debug('updated call owner --'+callToUpdateList[0].ZTS_EU_Call_Owner__c);
 
    }

    public static void delSampleDrop(List<Call__c> callList){
        List<Sample_Drop__c> samdrops = new List<Sample_Drop__c>();
        List<Id> callIds = new List<Id>();
        Id abc;
        for(Call__c cal : callList){
            abc = cal.Id;
        }
        callIds.add(abc);
        samdrops = [select id,ZTS_EU_Call__c from Sample_Drop__c where ZTS_EU_Call__c IN:callIds];
        try{
            delete samdrops;
        }
        catch(Exception e){
            System.debug('Exception occurred while deleting sample drop'+e);
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
    
    /*
     * Method to translate the call subtype  
     * @param List callList
     * @return none 
    */
    public static void callNaming(List<Call__C> triggerNew)
    {
        if(flag == false)
        {
            List<Call__C> callList = new List<Call__C>();
            callList = [Select id, Name , ZTS_EU_Start_Date_Time__c,toLabel(ZTS_EU_Sub_Type__c) from call__C where id IN: triggerNew];
            flag = true;
            Database.update(callList,false);
        }
        
    }
}