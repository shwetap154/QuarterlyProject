/*******************************************************************************************************************************************
* File Name     :  EventServiceTest
* Description   :  Test class for EventRedirectionController       
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Akanksha           Created the Class.
*         09/04        Sohil(Accenture)   Modified the class. 

********************************************************************************************************************************************/
@isTest
public class EventServiceTest{
   
    @IsTest
    public static void validate_SyncService(){
       
        /*List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
        TriggerActivation__c tr = new TriggerActivation__c(Name = 'EventTrigger', ZTS_EU_Bypass__c = true);
        triggerActiveList.add(tr);
        insert triggerActiveList;*/

        Schema.DescribeSObjectResult evntschema = Schema.SObjectType.Event; 
        Map<String,Schema.RecordTypeInfo> EventRecordTypeInfo = evntschema.getRecordTypeInfosByDeveloperName();
        Id rtId = EventRecordTypeInfo.get('Sales_Call').getRecordTypeId();
        
        List<Call__c> callList =  ZTS_EU_DataUtilityTest1.createCallRecord(1);
        
        RecordType recTId=[Select Id from RecordType where SObjectType='Event' and DeveloperName='Sales_Call' limit 1];
        Event evnold=new Event(Subject='Mail',CurrencyIsoCode='USD',CallRecordId__c=callList[0].Id,StartDateTime=System.Now(),EndDateTime=System.Now().addDays(4),RecordTypeId=rtId);
        insert evnold;

        Map<Id,Event> mapIdEvntold= new Map<Id,Event>();
        mapIdEvntold.put(evnold.Id,evnold);

        Integer dmls = 0;
        test.startTest();
            Map<Id,Event> mapIdEvntnew= new Map<Id,Event>();
            mapIdEvntnew.put(
                evnold.Id,new Event(Id=evnold.Id,Subject='Call1',CurrencyIsoCode='USD',CallRecordId__c=callList[0].Id,StartDateTime=System.Now(),EndDateTime=System.Now().addDays(4),RecordTypeId=rtId)
            );
            EventService.updateAndSyncCallsFromEvents(mapIdEvntnew,mapIdEvntold);
            dmls += Limits.getDMLStatements();
        test.stopTest();

        System.assert(dmls > 0);
    }
    
    @IsTest
    public static void validate_EventService(){

         map<id,call__c> CallOldmap = new map<id,call__c>();
         map<id,call__c> Callnewmap = new map<id,call__c>();
        
        List<Call__c> UpdatecallList =  new  List<Call__c>();
        Event evnnew=new Event(Subject='Call',CurrencyIsoCode='USD',StartDateTime=System.Now(),EndDateTime=System.Now().addDays(2));
        insert evnnew;

        Event evnold=new Event(Subject='Call1',CurrencyIsoCode='USD',StartDateTime=System.Now(),EndDateTime=System.Now().addDays(4));
        insert evnold;

        List<Event> evnList=new List<Event>();
        evnList.add(evnnew);
        List<Call__c> callList =  ZTS_EU_DataUtilityTest1.createCallRecord(1);
        list<user> userlist = ZTS_EU_DataUtilityTest1.createchocheUser(1);
        insert userlist;

        system.debug('userlist==' + userlist[0].id);
        callList[0].ZTS_EU_Call_Owner__c = userlist[0].id;
        insert callList;

        CallUtils.syncOnInsert(callList);
        CallUtils.syncOnUpdate(callList);
        CallService.generateAndSetupEventsFromCalls(callList);
        datetime dt = system.now();

        Integer dmls = 0;
        test.startTest(); 
            for(call__c c: callList)
            {
                CallOldmap.put(c.id,c);
                c.Name = 'test';
                c.ZTS_EU_Call_Objectives__c = 'test';
                c.ZTS_EU_Start_Date_Time__c = dt.addMinutes(30);
                UpdatecallList.add(c);
            }
            if(UpdatecallList!=null && UpdatecallList.size()>0)
                update UpdatecallList;
            for(call__c c1: UpdatecallList)
            {
                Callnewmap.put(c1.id,c1);
            }
            CallService.updateAndSyncEventsFromCalls(Callnewmap, CallOldmap);
            CallService.updateEventsFromCalls(UpdatecallList);
            CallService.deleteRelatedEvents(Callnewmap);
            
            EventService.checkForValueChange(evnnew,evnold);
            EventService.updateCallsFromEvents(evnList);
            dmls += Limits.getDMLStatements();
        test.stopTest();

        System.assert(dmls > 0);
    }
    
    @IsTest
    public static void validate_delete(){
    	/*List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
    	TriggerActivation__c tr = new TriggerActivation__c(Name = 'EventTrigger', ZTS_EU_Bypass__c = true);
    	triggerActiveList.add(tr);
        insert triggerActiveList; */
        
        List<Call__c> callList =  ZTS_EU_DataUtilityTest1.createCallRecord(1);

        Event evntodel=new Event(Subject='Call23',CurrencyIsoCode='USD',StartDateTime=System.Now(),EndDateTime=System.Now().addDays(9));
        Event evntodel1=new Event(Subject='Call234',CurrencyIsoCode='USD',CallRecordId__c=callList[0].Id,StartDateTime=System.Now(),EndDateTime=System.Now().addDays(10));
        insert evntodel;
        insert evntodel1;
          
    	test.startTest();
            Map<Id,Event> mapIdEvnttodel= new Map<Id,Event>();
            mapIdEvnttodel.put(evntodel.Id,evntodel);
            EventService.deleteRelatedCalls(mapIdEvnttodel);        
            //Added by the Sohil Shah(Accenture) 
            EventService.deleteParentTOT(mapIdEvnttodel);
            delete evntodel1;
        test.stoptest();

        List<Event> deletedEvents = [SELECT Id FROM Event WHERE Subject = 'Call234'];
        List<call__c> deletedCalls = [SELECT Id FROM call__c];
        System.assert( deletedEvents.isEmpty() );
        System.assert( deletedCalls.isEmpty() );
    }
}