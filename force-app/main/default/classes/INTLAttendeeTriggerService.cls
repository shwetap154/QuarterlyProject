/**
 * @description       : Logic for all INTL Attendee triggers housed here.
 * @author            : David Stern @ Slalom
 * @group             : 
 * @last modified on  : 04-06-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-10-2020   David Stern @ Slalom        Created, Logic from all triggers moved to this class.
 * 1.1   04-06-2022   Ethan Hirsch @ Zoetis Inc   Remove filter for Market != United States from User queries to prevent failures for US Users. 
 *                                                Remove unused query in afterDelete method
 *  Deepshikha Tyagi(Cognizant)  09/01/2023       Modified for deleting Campaign Members whenever attendees are removed from the call 
**/
public class INTLAttendeeTriggerService  
{   
    public static void beforeDelete(List<Attendee__c> triggerOld, Map<Id, Attendee__c> triggerOldMap) 
    {
        Id currUsrId = UserInfo.getUserId();
        
        User user = [Select ZTS_EU_Market__c from User where Id = :UserInfo.getUserId()];
        
        if(user.ZTS_EU_Market__c == 'France')
        {
            updateCall.callUpdate(triggerOld);
        } 
        ZTS_EU_AttendeeService.getRelatedRecordsAndDeleteCampaignMembers(triggerOldMap);//Added for TPDEV-360 
    }
    public static void afterInsert(List<Attendee__c> triggerNew, Map<Id, Attendee__c> triggerNewMap) 
    {
        Id currUsrId = UserInfo.getUserId();
        
        User user = [Select ZTS_EU_Market__c from User where Id = :UserInfo.getUserId()]; 
        
        ZTS_EU_AttendeeService.createEventRelations(triggerNew);
        if(user.ZTS_EU_Market__c == 'France')
        {
            updateCall.callUpdate(triggerNew);
        }   
    }
    public static void afterDelete(List<Attendee__c> triggerOld, Map<Id, Attendee__c> triggerOldMap) 
    {   
        ZTS_EU_AttendeeService.deleteEventRelations(triggerOldMap);
    }
     //Newly added line to populate represent acount for INTL Markets TPDEV-2016	
    public static void beforeInsert(List<Attendee__c> triggerNew) 
    {
       ZTS_EU_AttendeeService.populateAccOnAttendee(triggerNew);
    }
}