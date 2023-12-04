/* -----------------------------------------------------------------------------------------------------------------------
Name:        ZTS_EU_BatchCusEvents.cls
Description: Batch used for Inserting missing events for Custom Events for all markets                    
Date         Version    Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
15-04-2016   1.0        Priya               Initial Version    
------------------------------------------------------------------------------------------------------------------------*/

global class ZTS_EU_BatchCusEvents implements Database.Batchable<sObject> {
    // Variable declaration 
    string str = system.label.Market_Value; //for market value reusability
    
    //Query for fetching all the custom events respective for the market
    string query = 'SELECT id, name, Ownerid, ZTS_US_Accomplishment__c,CreatedById, ZTS_US_Approved_Date__c, ZTS_EU_BA_City__c,ZTS_US_End_Date__c,ZTS_EU_Historical_Owner_Name__c, ZTS_US_Type__c, ZTS_US_Location__c, ZTS_EU_Market__c, ZTS_US_Name__c, ZTS_US_Number_of_Attendees__c, ZTS_US_Purpose_Agenda__c, ZTS_US_Is_Event_Private__c, ZTS_US_Start_Date__c, ZTS_US_Status__c, ZTS_US_Event_Category__c ' + 
        +' FROM ZTS_Events__c'
        +' WHERE ZTS_EU_Market__c =: str '
        +' AND ZTS_EU_Market__c != \'United States\'';
    
    // Start Method 
    global Database.queryLocator start(Database.BatchableContext BC){
        system.debug('query========>'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ZTS_Events__c> eveList){
        //static variable for avoiding recursive call i.e. to avoid deleting custom event on deleting event.
        EventService.IsEveDelete = true;
        EventService.iscreateattendee = true;
        map<id,list<ZTS_US_Internal_Attendee__c>> mapattd = new map<id,list<ZTS_US_Internal_Attendee__c>>(); // map of custom events and its list of attendees
        list<ZTS_US_Internal_Attendee__c> attendeelist = [select id,ZTS_US_Events__c,ZTS_US_Events__r.ownerid,ZTS_US_Event_Percentage_Payment__c,ZTS_US_User__c from ZTS_US_Internal_Attendee__c where ZTS_US_Events__c in : eveList AND ZTS_EU_Market_from_Parent__c != 'United States'];
        list<ZTS_US_Internal_Attendee__c> attendlst = new list<ZTS_US_Internal_Attendee__c>();
        set<id> setacc = new set<id>(); // to have unique set of accounts
            for(ZTS_US_Internal_Attendee__c att: attendeelist)
            {
                 if(att.ZTS_US_User__c != att.ZTS_US_Events__r.ownerid)
                {
                list<ZTS_US_Internal_Attendee__c> attd = new list<ZTS_US_Internal_Attendee__c>();
                attd.add(att);
                if(mapattd!=null && mapattd.containsKey(att.ZTS_US_Events__c))
                    attd.addall(mapattd.get(att.ZTS_US_Events__c));
 	                mapattd.put(att.ZTS_US_Events__c,attd);
                	attendlst.addAll(attd);
                }
            }
        set<id> seteve = new set<id>();
       
            for(ZTS_Events__c e: eveList)
            {
                seteve.add(e.id);
            }
        
        //Query to get all the related events for the custom events
        List<Event> events= [select id, whatid, Ownerid from Event where whatid in : seteve AND ZTS_EU_Market__c != 'United States'];
        system.debug('events========>'+events);
        database.delete(events);
        system.debug('events========>'+events);
        if(eveList.size()>0 && eveList!=null){
            system.debug('inside insert eveList ----');
            ZTS_US_CustomEvents_Utils.createInternalAttendeeOnEventInsert(eveList); // to create calendar event for custom event owner
        }
        if(attendlst!=null && attendlst.size()>0)
        {
            system.debug('inside if====');
             ZTS_US_Internal_Attendee_Trigger_Helper.processInternalAttendeeRecord(attendlst); // to create calendar event for attendees for a custom event
        }
    }

    global void finish(Database.BatchableContext BC){    
    }
}