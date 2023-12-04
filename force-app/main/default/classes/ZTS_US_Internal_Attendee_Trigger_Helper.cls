/****************************************************************************************************************************************** 
 * Class Name       : ZTS_US_Internal_Attendee_Trigger_Helper
 * Description      : The class is used by the trigger to perform the following actions 
                            1. Create a record in the share object. 
                            2. Provide read/write access to Internal Attendee on the related event
                            3. Delete apex sharing for zoetis attendees who were deleted from the event
                                    
 * Created By   : Deloitte Consulting
 * Created Date : May 5th, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sameep Agrawal           05/05/2014          Created 
*****************************************************************************************************************************************/
public class ZTS_US_Internal_Attendee_Trigger_Helper 
{
    public static void processInternalAttendeeRecord(List<ZTS_US_Internal_Attendee__c> internalAttendee)
    {
        List <ZTS_Events__Share> eventSHareList = new List<ZTS_Events__Share>();
        List<Event> listEvent = new List<Event>();
        List <Id> eventId = new List<Id>(); 
        Map<Id, Id> mapEvent = new Map<Id, Id>();
        List<EventRelation> listEventRelation = new List<EventRelation>();
        
        //Build the list for adding sharing
        for(ZTS_US_Internal_Attendee__c oblIntAttnd : internalAttendee)
        {
             ZTS_Events__Share eventShare = new ZTS_Events__Share();
             eventSHare.ParentId = oblIntAttnd.ZTS_US_Events__c;
             eventSHare.UserOrGroupId = oblIntAttnd.ZTS_US_User__c;
             eventSHare.AccessLevel = 'edit';
             eventSHare.RowCause = Schema.ZTS_Events__Share.RowCause.ZTS_US_Share_Events_Internal_Invitees__c;
             eventSHareList.add(eventShare);
             eventId.add(oblIntAttnd.ZTS_US_Events__c);
        }
        
        //Logic to share the event calendar with attendees. Only the event automatically created will be shared. 
        //The flag ZTS_US_EventCreatedByTrigger__c is used to ensure manually created calendar items are not shared.
        //SOQL query edited by laxmikanth(cloudsense) on 2/29/16 by adding the condition to query with Ischild=false for SC-002114.
        for(Event objEvent : [select Id, WhatId, Ischild from Event where WhatId IN: eventId and ZTS_US_EventCreatedByTrigger__c= true and Ischild=false AND ZTS_EU_Market__c = 'United States'])
        {
            mapEvent.put(objEvent.WhatId, objEvent.Id);
        }
        
        for(ZTS_US_Internal_Attendee__c oblIntAttnd : internalAttendee)
        {
            System.debug('Checking event Id : '+oblIntAttnd.ZTS_US_Events__c);
            if(mapEvent.containsKey(oblIntAttnd.ZTS_US_Events__c))
            {
                EventRelation objEventRelation = new EventRelation();
                String standardEventId = mapEvent.get(oblIntAttnd.ZTS_US_Events__c);
                system.debug('Event Id ::::'+standardEventId);
                objEventRelation.EventId = standardEventId;
                objEventRelation.RelationId = oblIntAttnd.ZTS_US_User__c;
                System.debug('Inserting invitee');
                listEventRelation.add(objEventRelation);
            }
        }
        try
        {
            insert eventSHareList;
            if(listEventRelation.size() > 0)
            {
                insert listEventRelation;
            }
        }
        catch(Exception ex)
        {
            System.debug('Exception occurred while trying to share Event record through Apex or while creating an event for internal attendee : '+ex);
        }
    }
    
    //This method is used to delete the apex sharing for Zoetis Attendees who were deleted from the event
    public static void processDeleteRequest (List<ZTS_US_Internal_Attendee__c> delInternalAttendee)
    {
        List <Id> eventId = new List<Id>(); 
        List <EventRelation> listDelEventRelation = new List<EventRelation>();
        List<Id> Userids = new List<Id>();
        for(ZTS_US_Internal_Attendee__c objIntAttendee : delInternalAttendee)
        {
            eventId.add(objIntAttendee.ZTS_US_Events__c);
            Userids.add(objIntAttendee.ZTS_US_User__c);
        }
        List<ZTS_Events__Share> eventsToDelete = [Select Id from ZTS_Events__Share where parentId IN : eventId and RowCause =: Schema.ZTS_Events__Share.RowCause.ZTS_US_Share_Events_Internal_Invitees__c and UserOrGroupId IN:Userids];
        List<Event> listDelOOTBEvent = [Select Id, WhatId, OwnerId from Event where WhatId IN: eventId and ZTS_US_EventCreatedByTrigger__c = true AND ZTS_EU_Market__c = 'United States'];
        
        for(EventRelation objEventRelation : [Select Id from EventRelation where EventId IN : listDelOOTBEvent and RelationId IN:Userids])
        {
            listDelEventRelation.add(objEventRelation);
        }
        
        try
        {
            delete eventsToDelete; 
            if(listDelEventRelation.size()>0)
            {
                delete listDelEventRelation;
            } 
        }
        catch(Exception ex)
        {
            System.debug('Exception occurred while deleting the apex sharing or removing attendee from the multi uer calendar : '+ex);
        }
    }
}