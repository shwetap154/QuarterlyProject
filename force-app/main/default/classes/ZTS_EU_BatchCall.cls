/* -----------------------------------------------------------------------------------------------------------------------
Name:        ZTS_EU_BatchCall.cls
Description: Batch used for Inserting/Updating missing events for calls and colleagues for all markets                    
Date         Version    Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
21-03-2016   1.0        Priya               Initial Version    
10-06-2016                 Chandana       Modified query to get all events of accounts with call ids included.
------------------------------------------------------------------------------------------------------------------------*/

global class ZTS_EU_BatchCall implements Database.Batchable<sObject> {
    // Variable declaration 
    string str = system.label.Market_Value; //for market value reusability
    string str1 = '';
    //Query for fetching all the calls respective for the market
    string query = 'SELECT id, name, ZTS_EU_Account__c, Contact_Employee_Count__c, Discussion_Item_Count__c, Contact_Employee__c,Discussion_Item__c,ZTS_EU_Next_Call_Date__c, ZTS_EU_Sub_Type__c, ZTS_EU_Next_Step__c, ZTS_EU_Local_Subtype__c, ZTS_EU_Call_Objectives__c, ZTS_EU_Account__r.ZTS_EU_Market__c, ZTS_EU_Start_Date_Time__c, ZTS_EU_Call_Owner__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Status__c ' + 
        +' FROM Call__c c'
        +' WHERE ZTS_EU_Account__r.ZTS_EU_Market__c =: str And ZTS_EU_Call_Owner__c !=: str1 ';
    
    // Start Method 
    global Database.queryLocator start(Database.BatchableContext BC){
        system.debug('query========>'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Call__c> callList){
        //static variable for avoiding recursive call i.e. to avoid deleting call on deleting event.
        CallUtils.IsCallDelete = true;
        map<id,list<ZTS_EU_Colleague__c>> mapcoll = new map<id,list<ZTS_EU_Colleague__c>>(); // map of call and its list of colleagues
        list<ZTS_EU_Colleague__c> colleaguelist = [select id,ZTS_EU_Call__c,ZTS_EU_User__c,ZTS_EU_Call__r.ZTS_EU_Call_Owner__c from ZTS_EU_Colleague__c where ZTS_EU_Call__c in : callList AND ZTS_EU_Market__c != 'United States'];
        list<ZTS_EU_Colleague__c> colllst = new list<ZTS_EU_Colleague__c>();
        set<id> setacc = new set<id>(); // to have unique set of accounts
        set<id> callIds = new set<id>(); // to have unique set of call ids
            for(ZTS_EU_Colleague__c coll: colleaguelist)
            {
                 if(coll.ZTS_EU_User__c != coll.ZTS_EU_Call__r.ZTS_EU_Call_Owner__c)
                {
                list<ZTS_EU_Colleague__c> colleague = new list<ZTS_EU_Colleague__c>();
                colleague.add(coll);
                if(mapcoll!=null && mapcoll.containsKey(coll.ZTS_EU_Call__c))
                    colleague.addall(mapcoll.get(coll.ZTS_EU_Call__c));
                    mapcoll.put(coll.ZTS_EU_Call__c,colleague);
                    colllst.addAll(colleague);
                }
            }
            for(call__c c: calllist)
            {
                setacc.add(c.ZTS_EU_Account__c);
                callIds.add(c.Id);
            }
        system.debug('callIds' + callIds);
        
        //Query to get all the related events for the accounts and callids with record type "Sales call"
        List<Event> events= [select id, whatid, Ownerid from Event where whatid in : setacc and CallRecordId__c in :callIds and Recordtypeid = '012F0000000WRKj' AND ZTS_EU_Market__c != 'United States'];
        system.debug('events========>'+events);
        database.delete(events);
        system.debug('events========>'+events);
        if(callList.size()>0 && callList!=null){
            system.debug('inside insert time off----');
            CallService.generateAndSetupEventsFromCalls(callList); // to create calendar event for call owner
        }
        
        
        system.debug('colllst' + colllst);
       
        if(colllst!=null && colllst.size()>0)
        {
            system.debug('inside if====');
             ZTS_EU_AttendeeService.createEventRelationsForColleagues(colllst); // to create calendar event for colleagues for a call
        }
    }

    global void finish(Database.BatchableContext BC){    
    }
}