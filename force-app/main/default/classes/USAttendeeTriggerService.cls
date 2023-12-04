/**
 * @description       : Attendee Dispatcher for US Attendee Records
 * @author            : David Stern @ Slalom
 * @group             : LegacyDispatcher
 * @last modified on  : 08-04-2022
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   02-10-2020   David Stern @ Slalom           Initial Version
 * 1.1   12-09-2021   Morgan Marchese @ Zoetis Inc   Formatting
 * 1.2   08-04-2022   Ethan Hirsch @ Zoetis Inc      Reimplement security fix for updating Recent Callers on Call
**/
public class USAttendeeTriggerService 
{   
    
    public static void beforeInsert(List<Attendee__c> triggerNew) 
    {
        USAttendeeService.populateAccOnAttendee(triggerNew);
    }
    
    public static void afterInsert(List<Attendee__c> triggerNew, Map<Id, Attendee__c> triggerNewMap) 
    {
        //Moved the Contact field update logic to service class - NamrataP[12/9/21] - SC-009237
        AttendeesService.updateRelatedContacts(triggerNew);
        USAttendeeService.createEventRelations(triggerNew);
    }
    
    public static void afterDelete(List<Attendee__c> triggerOld, Map<Id, Attendee__c> triggerOldMap) 
    {
        List<Id> conIdList = new List<Id>();
        List<Contact> contsTobeUpdated = new List<Contact>();
        
        USAttendeeService.deleteEventRelations(triggerOldMap);
    }
}