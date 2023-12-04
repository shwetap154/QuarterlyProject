/*******************************************************************************************************************************************
* File Name     :  ZTS_US_CustomEvents_UtilsTest
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Vidya             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_US_CustomEvents_UtilsTest 
{   
    static List<ZTS_Events__c> listEvents;
    //static List<RecordType> listRecType;
    static ZTS_US_CustomEvents_Utils custoEventUtil = new ZTS_US_CustomEvents_Utils();
    
    public static void createTestData(){
        listEvents = createEvents(3);
        insert listEvents;
        //listRecType = createRecordType(1);
        //insert listRecType;
    }
    static testMethod void validate_ZTS_US_Internal_Attendee_Trigger_Helper (){
    test.startTest();
    createTestData();
    List<Event> listEvent = createEvent(listEvents);
    insert listEvent;
    List<ZTS_US_Internal_Attendee__c> lstattend=createInternalAttendees(listEvents);
    insert lstattend;
    ZTS_US_Internal_Attendee_Trigger_Helper.processDeleteRequest(lstattend);
    delete lstattend;
    test.stopTest();
    
    }
    static testMethod void createInternalAttendeeOnEventInsertTest(){
        test.startTest();
        createTestData();
        ZTS_US_CustomEvents_Utils.createInternalAttendeeOnEventInsert(listEvents);
        test.stopTest();
    }
    
    static testMethod void processUpdatedRecordsTest(){
        test.startTest();
        createTestData();
        List<Event> listEvent = createEvent(listEvents);
        insert listEvent;
        ZTS_US_CustomEvents_Utils.processUpdatedRecords(listEvents);
        test.stopTest();
    }
    
    static testMethod void createEntitySubscriptionTest(){
        test.startTest();
        createTestData();
        ZTS_US_CustomEvents_Utils.createEntitySubscription(listEvents);
        test.stopTest();
    }
    
    static testMethod void updateEntitySubscriptionTest(){
        test.startTest();
        createTestData();
        Map<ID, ZTS_Events__c> eventMap = new Map<ID, ZTS_Events__c>();
        String profileId = [select Id from Profile where Name='System Administrator' limit 1].Id;
        List<User> listUser = [select Id from User where Id <>: UserInfo.getUserId() and ProfileId =: profileId and IsActive=true AND ZTS_EU_Market__c = 'United States' limit 1];
        Integer counter = 0;
        for(ZTS_Events__c events: listEvents){
            events.OwnerId = UserInfo.getUserId();
            eventMap.put(events.Id, events);
        }
        if(listUser != null && listUser.size() > 0 ){
            listEvents[0].OwnerId = listUser[0].Id;
            update listEvents[0];
        }
        ZTS_US_CustomEvents_Utils.updateEntitySubscription(listEvents,eventMap);
        test.stopTest();
    }
    
    static testMethod void createEntitySubscriptionForExpenseTest(){
        test.startTest();
        createTestData();
        List<ZTS_US_Expenses__c> listExpenses = createExpenses(listEvents);
        ZTS_US_CustomEvents_Utils.createEntitySubscriptionForExpense(listExpenses);
        test.stopTest();
    }
    
    static testMethod void updateEntitySubscriptionForExpenseTest(){
        test.startTest();
        createTestData();
        List<ZTS_US_Expenses__c> listExpenses = createExpenses(listEvents);
        Map<ID, ZTS_US_Expenses__c> expenseMap = new Map<ID, ZTS_US_Expenses__c>();
        for(ZTS_US_Expenses__c expense: listExpenses){
            expenseMap.put(expense.Id, expense);
        }
        ZTS_US_CustomEvents_Utils.updateEntitySubscriptionForExpense(listExpenses,expenseMap);
        test.stopTest();
    }
    
    /*-------------insert ZTS_Events__c object records---------------*/
    public static List<ZTS_Events__c> createEvents(Integer counter){ // 6/14
        List<ZTS_Events__c> listEvents1 = new List<ZTS_Events__c>();
        for(Integer i=0; i< counter; i++){
            ZTS_Events__c event = new ZTS_Events__c();
            event.ZTS_US_Will_Firearms_be_Present__c = true;
            event.ZTS_US_Type__c = 'Cattle General';
            event.Total_Number_of_Invitees__c = i;
            event.ZTS_US_Status__c = 'New';
            event.ZTS_US_Start_Date__c = system.now();
            if( Math.mod(2,(i+1)) ==0){
                event.ZTS_US_Is_Event_Private__c = true;
            }else{
                event.ZTS_US_Is_Event_Private__c = false;
            }
            event.ZTS_US_Name__c = 'Test Event'+i;
        //    event.ZTS_US_End_Date__c = system.today().addDays(i);
            event.ZTS_US_End_Date__c = system.now().addDays(i);
            event.ZTS_US_Compliance_Status__c = 'Acceptable';
            event.ZTS_US_Event_Category__c = 'Educational Meeting';
            event.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
            event.ZTS_US_Number_of_Attendees__c = i+2;
            //event.ZTS_US_Purpose_Agenda__c = 'Test purpose';
            event.Purpose_Agenda__c = 'Test purpose';
            listEvents1.add(event);
        }
        return listEvents1;
    }
    
    /*-------------insert Events object records---------------*/
    public static List<Event> createEvent(List<ZTS_Events__c> listEvents1){ // 6/14
        List<Event> listEvent = new List<Event>();
        for(ZTS_Events__c events: listEvents1){
            //if(!events.ZTS_US_Is_Event_Private__c){
                Event eve = new Event(ZTS_US_EventCreatedByTrigger__c=true, WhatId=events.Id,DurationInMinutes=10,ActivityDateTime=system.now());
                listEvent.add(eve);
            //}
        }
        return listEvent;
    }   
    
    /*----------------insert ZTS_US_Expenses__c object records-------*/
    public static List<ZTS_US_Expenses__c> createExpenses(List<ZTS_Events__c> listEvents1){
        List<ZTS_US_Expenses__c> listExpenses = new List<ZTS_US_Expenses__c>();
        for(ZTS_Events__c events: listEvents1){
            ZTS_US_Expenses__c expense = new ZTS_US_Expenses__c(ZTS_US_Events__c=events.Id);
            listExpenses.add(expense);
        }
        return listExpenses;
    }
    /*-------insert ZTS_US_Internal_Attendee__c object records------*/
                public static List<ZTS_US_Internal_Attendee__c> createInternalAttendees(List<ZTS_Events__c> listEvnts){
                                List<ZTS_US_Internal_Attendee__c> listEventAttendees = new List<ZTS_US_Internal_Attendee__c>();
                                List<Contact> conList = ZTS_EU_DataUtilityTest.createContactRecord(1);
                                insert conList;
                                for(ZTS_Events__c event: listEvnts){
                                                ZTS_US_Internal_Attendee__c evntAtten = new ZTS_US_Internal_Attendee__c(ZTS_US_User__c=Userinfo.getUserId(), ZTS_US_Events__c=event.Id);
                                                listEventAttendees.add(evntAtten);
                                }
                                return listEventAttendees;
                }

}