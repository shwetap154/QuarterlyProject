/*
* @Name: USZTS_US_CustomEvents_Utils
* @Desciption: Utils Class for the trigger on ZTS_Events__c.
*              1.Creates Internal Attendee record with the Event creator/owner whenever an Event is inserted.
* @date Created:Mar 07, 2014
* @author Ketan Prakash Singh
*  Modification Log
Name                        Modified Date           Comments
------------------------------------------------------------------------
Sohil Shah(Cloud Sense)     5th Dec'2014            Added code to fix DEF-000720    
*/
public class USZTS_US_CustomEvents_Utils{
    public static void createInternalAttendeeOnEventInsert(List<ZTS_Events__c> lstEvents)
    {
        List<ZTS_US_Internal_Attendee__c> lstIntAtten = new List<ZTS_US_Internal_Attendee__c>();
        List<Event> listEvent = new List<Event>();
        String eventRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'General_Event'].Id;
        boolean createEvent = false;
        
        for(ZTS_Events__c eventsObj: lstEvents)
        {
            ZTS_US_Internal_Attendee__c interAttenObj = new ZTS_US_Internal_Attendee__c();
            interAttenObj.ZTS_US_Events__c = eventsObj.id;
            interAttenObj.ZTS_US_User__c = eventsObj.CreatedById;
            interAttenObj.ZTS_US_Event_Percentage_Payment__c = 100;
            
            lstIntAtten.add(interAttenObj);
            System.debug('@@@lstIntAtten is: '+lstIntAtten);
            
            //Create an out of the box event whenever a custom event is created & event is not marked private 
            if(!eventsObj.ZTS_US_Is_Event_Private__c)
            {
                Event objEvent = new Event();
                objEvent.OwnerId = eventsObj.OwnerId;
                objEvent.WhatId = eventsObj.Id;
                objEvent.StartDateTime = eventsObj.ZTS_US_Start_Date__c;
                objEvent.EndDateTime = eventsObj.ZTS_US_End_Date__c;
                objEvent.Subject = eventsObj.ZTS_US_Name__c;
                objEvent.RecordTypeId = eventRecordTypeId;
                objEvent.ZTS_US_EventCreatedByTrigger__c = true;
                //// Modified by Laxmikanth(Cloudsense) to display event status on calendar 
                
                objEvent.Location = eventsObj.ZTS_US_Status__c;
                
                
               
                System.debug('Values : ' + eventsObj.OwnerId + ' ' + eventsObj.Id + ' ' + eventsObj.ZTS_US_Start_Date__c + ' ' + eventsObj.ZTS_US_End_Date__c + ' ' + eventsObj.ZTS_US_Name__c);
                listEvent.add(objEvent);
                createEvent = true; 
            }
            
        }
        try
        { 
            insert lstIntAtten;
            if(createEvent)
            {
                insert listEvent;
            }
            
        }
        catch(Exception e)
        {
            system.debug('Exception while inserting internal attendee or while creating an OOTB event'+ e);
        }
    }
    
    //This method is used to process the updated events records. It deletes/updates calendar item.
    public static void processUpdatedRecords(List<ZTS_Events__c> updEvents)
    {
        List<Id>listEventId = new List<Id>(); 
        List<Id>listUpdateEventId = new List<Id>(); 
        List<Event> objOOTBDelEvent = new List<Event>();
        List<Event> updateOOTBEvent = new List<Event>();
        Map<Id, ZTS_Events__c> calendarItemandEventMapping = new Map<Id, ZTS_Events__c>();
         
        for(ZTS_Events__c objEvents : updEvents)
        {
            if(objEvents.ZTS_US_Is_Event_Private__c)
            {
                listEventId.add(objEvents.Id);
            }
            else
            {
                listUpdateEventId.add(objEvents.Id);
                calendarItemandEventMapping.put(objEvents.Id, objEvents);
            }
        }
        
        if(listEventId.size()>0)
        {
            List<Event> listOOTBEvent = [Select Id, WhatId, OwnerId from Event where WhatId IN: listEventId and ZTS_US_EventCreatedByTrigger__c = true AND ZTS_EU_Market__c = 'United States'];
            for(Event objOOTBEvent : listOOTBEvent)
            {
                objOOTBDelEvent.add(objOOTBEvent);
            }
            
            try
            {
                delete objOOTBDelEvent;
            }
            catch (Exception ex)
            {
                System.debug('Exception occurred while delete calendar event');
            }
        }
        
        if(listUpdateEventId.size()>0)
        {
            List<Event> listOOTBEvent = [Select Id, WhatId, OwnerId from Event where WhatId IN: listUpdateEventId and ZTS_US_EventCreatedByTrigger__c = true and IsChild = false AND ZTS_EU_Market__c = 'United States'];
            for(Event objOOTBEvent : listOOTBEvent)
            {
                if(calendarItemandEventMapping.containsKey(objOOTBEvent.WhatId))
                {
                    ZTS_Events__c objTempEvent = new ZTS_Events__c();
                    objTempEvent = calendarItemandEventMapping.get(objOOTBEvent.WhatId);
                    objOOTBEvent.StartDateTime = objTempEvent.ZTS_US_Start_Date__c;
                    objOOTBEvent.EndDateTime = objTempEvent.ZTS_US_End_Date__c;
                    objOOTBEvent.Location = objTempEvent.ZTS_US_Status__c; 
                    // Added by sohil  Update Status of the standard event with respect to standard event 
                    updateOOTBEvent.add(objOOTBEvent);
                }
            }
            
            try
            {
                update updateOOTBEvent;
            }
            catch (Exception ex)
            {
                System.debug('Exception occurred while updating calendar event');
            }
        }
        /*if(listOOTBEvent.size())
        
        List<Id> listId = [SELECT Id from ZTS_Events__c where Id IN : Trigger.newMap.keySet() and ZTS_US_Is_Event_Private__c = true AND ZTS_EU_Market__c = 'United States'];
        
        List<ZTS_US_Internal_Attendee__c> listAttendee = [SELECT Id, ZTS_US_User__c from ZTS_US_Internal_Attendee__c where ZTS_US_Events__c IN: listId AND ZTS_EU_Market_from_Parent__c = 'United States'];
        
        /*for(ZTS_Events__c objEvents : updEvents)
        {
            for (Event objOEvent : [select ])
            
            if(objEvents.ZTS_US_Is_Event_Private__c)
            {
                for(ZTS_US_Internal_Attendee__c objAttendee : [Select Id, ZTS_US_User__c from ZTS_US_Internal_Attendee__c where ZTS_US_Events__c =: objEvents.Id AND ZTS_EU_Market_from_Parent__c = 'United States'])
                {
                    
                }
            }
        }*/
    }
    
    /* This method is used to create Entity Subscription record every time event record is created
    */
    public static void createEntitySubscription(List<ZTS_Events__c> listEvents){
        EntitySubscription entitySubs;
        List<EntitySubscription> listEntitySubs = new List<EntitySubscription>();
        for(ZTS_Events__c event: listEvents){
            entitySubs = new EntitySubscription(SubscriberId=event.OwnerId, ParentId=event.Id);
            listEntitySubs.add(entitySubs);
        }
        if(listEntitySubs != null && listEntitySubs.size() > 0){
            try{
                insert listEntitySubs;
            }catch(Exception e){
                system.debug('-----Exception caught while inserting--'+e);
            }
        }
    }
    
    /* This method is used to delete existing Entity Subscription records and create new ones
    *  when event owner changes
    */
    public static void updateEntitySubscription(List<ZTS_Events__c> listNewEvents, Map<ID, ZTS_Events__c> mapOldEvents){
        EntitySubscription entitySubs;
        List<EntitySubscription> listEntitySubs = new List<EntitySubscription>();
        List<ID> listEventId = new List<ID>();
        List<ID> listOwnerId = new List<ID>();
        Map<Id, EntitySubscription> mapEntitySubscription = new Map<ID, EntitySubscription>();
        for(ZTS_Events__c event: listNewEvents){
            if(event.OwnerId != mapOldEvents.get(event.Id).OwnerId){
                listEventId.add(event.Id);
                listOwnerId.add(mapOldEvents.get(event.Id).OwnerId);
                entitySubs = new EntitySubscription(SubscriberId=event.OwnerId, ParentId=event.Id);
                listEntitySubs.add(entitySubs);
            }
        }
        List<EntitySubscription> listEntitySub = [select ParentId, SubscriberId from EntitySubscription where SubscriberId IN: listOwnerId and
                                                        ParentId IN: listEventId];
        if(listEntitySub != null && listEntitySub.size() > 0){
            delete listEntitySub;
        }
        if(listEntitySubs != null && listEntitySubs.size() > 0){
            try{
                insert listEntitySubs;
            }catch(Exception e){
                system.debug('-----Exception caught while inserting--'+e);
            }
        }
    }
    
    /* This method is used to create Entity Subscription record every time expense record is created
    */
    public static void createEntitySubscriptionForExpense(List<ZTS_US_Expenses__c> listExpenses){
        EntitySubscription entitySubs;
        List<EntitySubscription> listEntitySubs = new List<EntitySubscription>();
        for(ZTS_US_Expenses__c expense: listExpenses){
            entitySubs = new EntitySubscription(SubscriberId=expense.LastModifiedById, ParentId=expense.Id);
            listEntitySubs.add(entitySubs);
        }
        if(listEntitySubs != null && listEntitySubs.size() > 0){
            try{
                insert listEntitySubs;
            }catch(Exception e){
                system.debug('-----Exception caught while inserting--'+e);
            }
        }
    }
    
    /* This method is used to delete existing Entity Subscription records and create new ones
    *  when expense owner changes
    */
    public static void updateEntitySubscriptionForExpense(List<ZTS_US_Expenses__c> listNewEvents, Map<ID, ZTS_US_Expenses__c> mapOldEvents){
        EntitySubscription entitySubs;
        List<EntitySubscription> listEntitySubs = new List<EntitySubscription>();
        List<ID> listExpenseId = new List<ID>();
        List<ID> listOwnerId = new List<ID>();
        Map<Id, EntitySubscription> mapEntitySubscription = new Map<ID, EntitySubscription>();
        for(ZTS_US_Expenses__c expense: listNewEvents){
            if(expense.LastModifiedById != mapOldEvents.get(expense.Id).LastModifiedById){
                listExpenseId.add(expense.Id);
                listOwnerId.add(mapOldEvents.get(expense.Id).LastModifiedById);
                entitySubs = new EntitySubscription(SubscriberId=expense.LastModifiedById, ParentId=expense.Id);
                listEntitySubs.add(entitySubs);
            }
        }
        List<EntitySubscription> listEntitySub = [select ParentId, SubscriberId from EntitySubscription where SubscriberId IN: listOwnerId and
                                                        ParentId IN: listExpenseId];
        if(listEntitySub != null && listEntitySub.size() > 0){
            delete listEntitySub;
        }
        if(listEntitySubs != null && listEntitySubs.size() > 0){
            try{
                insert listEntitySubs;
            }catch(Exception e){
                system.debug('-----Exception caught while inserting--'+e);
            }
        }
    }
    
    /*  This method is used to update the Old Total Sum of Expenses field on Event
    *   with the current value before the 'Roll up summary' field is calculated
    */
    public static void updateOldTotalSumExpenses(List<ZTS_Events__c> listEvents, Map<ID, ZTS_Events__c> mapIDEvent){
        for(ZTS_Events__c event: listEvents){
            if(mapIDEvent != null && mapIDEvent.containsKey(event.Id)){
                system.debug('-----------value:'+event.ZTS_US_Sum_of_Total__c +'---'+ mapIDEvent.get(event.Id).ZTS_US_Sum_of_Total__c);
                event.ZTS_US_Old_Total_Sum_of_Expenses__c = event.ZTS_US_Sum_of_Total__c - mapIDEvent.get(event.Id).ZTS_US_Sum_of_Total__c;
            }
        }
    }
    
    /* This method is used to validate if a comment has been provided or not
    *  when an event's (custom) approval request is rejected
    */
    public static void RequireRejectionComment(List<ZTS_Events__c> lstEvents,Map<ID,ZTS_Events__c> eventsOldMap){
    
      Map<Id, ZTS_Events__c> rejectedStatements 
                 = new Map<Id, ZTS_Events__c>{};
    
      for(ZTS_Events__c objEvents: lstEvents)
      {
        /* 
          Get the old object record, and check if the approval status 
          field has been updated to rejected. If so, put it in a map 
          so we only have to use 1 SOQL query to do all checks.
        */
        ZTS_Events__c oldobjEvents = eventsOldMap.get(objEvents.Id);
    
        if (oldobjEvents.ZTS_US_Status__c != 'Rejected' 
         && objEvents.ZTS_US_Status__c == 'Rejected')
        { 
          rejectedStatements.put(objEvents.Id, objEvents);  
        }
      }
       
      if (!rejectedStatements.isEmpty())  
      {
        // Get the most recent approval process instance for the object.
        // If there are some approvals to be reviewed for approval, then
        // get the most recent process instance for each object.
        List<Id> processInstanceIds = new List<Id>{};
        
        for (ZTS_Events__c objEvents : [SELECT (SELECT ID
                                                  FROM ProcessInstances
                                                  ORDER BY CreatedDate DESC
                                                  LIMIT 1)
                                          FROM ZTS_Events__c
                                          WHERE ID IN :rejectedStatements.keySet()
                                          AND ZTS_EU_Market__c = 'United States'])
        {
            processInstanceIds.add(objEvents.ProcessInstances[0].Id);
        }
          
        // Now that we have the most recent process instances, we can check
        // the most recent process steps for comments.  
        for (ProcessInstance pi : [SELECT TargetObjectId,
                                       (SELECT Id, StepStatus, Comments 
                                        FROM Steps
                                        ORDER BY CreatedDate DESC
                                        LIMIT 1 )
                                   FROM ProcessInstance
                                   WHERE Id IN :processInstanceIds
                                   ORDER BY CreatedDate DESC])   
        {                   
          if ((pi.Steps[0].Comments == null || 
               pi.Steps[0].Comments.trim().length() == 0))
          {
          system.debug('@@@@@@@ Rejection Error');
            rejectedStatements.get(pi.TargetObjectId).addError(
              'A comment is required for rejection');
          }
        }  
      }
    } 

 /***********
    * Method name  : populateUserTerritoryOnEvent
    * Description  : This will update event owner's user territory on Events.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/  
    public static void populateUserTerritoryOnEvent(List<ZTS_Events__c> lstEvents,Map<ID, ZTS_Events__c> mapOldEvent,boolean isInsert,boolean isUpdate){
    Set<Id> setEventId = new Set<Id>();
    Set<Id> setEventOwnerId = new Set<Id>();
    List<ZTS_EU_Position__c> listUserTerr= new List<ZTS_EU_Position__c>();
    List<ZTS_Events__c> eventsToUpdate = new List<ZTS_Events__c>();
    Map<Id,ZTS_EU_Position__c> mapUserUT=new Map<Id,ZTS_EU_Position__c>();
    
        for(ZTS_Events__c evn:lstEvents){
            setEventId.add(evn.Id);
            setEventOwnerId.add(evn.OwnerId);
            }
        listUserTerr=[Select Id,Name,ZTS_EU_Employee__c,OwnerId,ZTS_Territory_Name__c from ZTS_EU_Position__c where ZTS_EU_Employee__c IN:setEventOwnerId ORDER BY CreatedDate];
         
        for(ZTS_EU_Position__c userterr:listUserTerr){
             if(userterr.ZTS_EU_Employee__c!=null && !mapUserUT.containsKey(userterr.ZTS_EU_Employee__c)){
                    mapUserUT.put(userterr.ZTS_EU_Employee__c,userterr);
                    }
         }
         
        for(ZTS_Events__c evnt:lstEvents){
                if(isInsert){
                    if((mapUserUT.containsKey(evnt.OwnerId)) && (evnt.ZTS_US_EventOwner_Territory__c==null)){
                                evnt.ZTS_US_EventOwner_Territory__c = mapUserUT.get(evnt.OwnerId).ZTS_Territory_Name__c;
                                eventsToUpdate.add(evnt);
                            }
                }
                if(isUpdate){
                    if(mapOldEvent.containsKey(evnt.Id)){
                        if((mapUserUT.containsKey(evnt.OwnerId)) &&(evnt.OwnerId != mapOldEvent.get(evnt.Id).OwnerId)){
                            evnt.ZTS_US_EventOwner_Territory__c = mapUserUT.get(evnt.OwnerId).ZTS_Territory_Name__c;
                            eventsToUpdate.add(evnt);
                        }
                    }
                }
        }
    }
    /***********
    * Method name  : updateExpensesonattendeesupdate
    * Description  : This will update event expenses when no.of attendees changes.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/  
    public static void updateExpensesonattendeesupdate(Map<ID, ZTS_Events__c> newEvents, Map<ID, ZTS_Events__c> oldEvents)
    {
        List<ZTS_US_Expenses__c> toBeUpdated = new List<ZTS_US_Expenses__c>();
        List<ZTS_US_Expenses__c> expenses = new List<ZTS_US_Expenses__c>();
        
        expenses = [select id,ZTS_US_Events__c,ZTS_US_Cost__c,ZTS_US_Unit__c from ZTS_US_Expenses__c where ZTS_US_Events__c IN:newEvents.values() AND ZTS_EU_Market__c = 'United States'];
        for(ZTS_US_Expenses__c exp : expenses){
            ZTS_Events__c oldevnt = oldEvents.get(exp.ZTS_US_Events__c);
            ZTS_Events__c newevnt = newEvents.get(exp.ZTS_US_Events__c);
            if(oldevnt.ZTS_US_Number_of_Attendees__c == exp.ZTS_US_Unit__c&&exp.ZTS_US_Unit__c!=null){
                exp.ZTS_US_Unit__c=newevnt.ZTS_US_Number_of_Attendees__c;
                toBeupdated.add(exp);
            }
        }
        update toBeUpdated;
    }
}