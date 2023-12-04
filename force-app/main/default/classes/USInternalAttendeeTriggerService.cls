/****************************************************************************************************************************************** 
 * Trigger Name : USInternalAttendeeTriggerService
 * Description  : This trigger is used to provide Read/Write access to an Internal Attendee on the associated event
 * Created By   : Deloitte Consulting
 * Created Date : May 5th, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sameep Agrawal         05/05/2014           Created 
 * Art Smorodin			  02/06/2020	       Moved to Service Class
*****************************************************************************************************************************************/
public without sharing class USInternalAttendeeTriggerService 
{      
	public static void afterInsert(List<ZTS_US_Internal_Attendee__c> triggerNew, Map<Id, ZTS_US_Internal_Attendee__c> triggerNewMap)
    {   
        List <ZTS_Events__Share> eventSHareList = new List<ZTS_Events__Share>();
        List<Event> listEvent = new List<Event>();
        List <Id> eventId = new List<Id>(); 
        Map<Id, Id> mapEvent = new Map<Id, Id>();
        List<EventRelation> listEventRelation = new List<EventRelation>();
        
        //Build the list for adding sharing
        for(ZTS_US_Internal_Attendee__c oblIntAttnd : triggerNew)
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
        //SOQL query edited by laxmikanth(cloudsense) on 10/29/2014 by adding the condition to query with Ischild=false.
        for(ZTS_Events__c objEvent : [SELECT Id 
                                      FROM ZTS_Events__c 
                                      WHERE ZTS_EU_Market__c = 'United States'])
        {
            mapEvent.put(objEvent.Id, objEvent.Id);
        }
        
        for(ZTS_US_Internal_Attendee__c oblIntAttnd : triggerNew)
        {
            if(mapEvent.containsKey(oblIntAttnd.ZTS_US_Events__c))
            {
                EventRelation objEventRelation = new EventRelation();
                String standardEventId = mapEvent.get(oblIntAttnd.ZTS_US_Events__c);
                objEventRelation.EventId = standardEventId;
                objEventRelation.RelationId = oblIntAttnd.ZTS_US_User__c;
                listEventRelation.add(objEventRelation);
                
            }
        }
        try
        {
            insert eventSHareList;
            system.debug('*****eventSHareList******' +eventSHareList);
            if(listEventRelation.size() > 0)
            {
                insert listEventRelation;
                system.debug('*****listEventRelation.******' +listEventRelation);
                
                
            }
        }
        catch(Exception ex)
        {
            System.debug('Exception occurred while trying to share Event record through Apex or while creating an event for internal attendee : '+ex);
        }
    }
	public static void afterDelete(List<ZTS_US_Internal_Attendee__c> triggerOld, Map<Id, ZTS_US_Internal_Attendee__c> triggerOldMap)
    {   
        List <Id> eventId = new List<Id>(); 
        List<Id> Userids = new List<Id>();
        List <EventRelation> listDelEventRelation = new List<EventRelation>();
        
        for(ZTS_US_Internal_Attendee__c objIntAttendee : triggerOld)
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