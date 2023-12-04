/*******************************************************************************************************************************************
* File Name     :  ZTS_US_CustomEvents_Utils_Test
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/14         Sonali             Created the Class.
*****************************************************************************************************************************************/



@isTest(SeeAllData=false) 
public class ZTS_US_CustomEvents_Utils_Test 
{   
    static List<ZTS_Events__c> listEvents;
    static USZTS_US_CustomEvents_Utils custoEventUtil = new USZTS_US_CustomEvents_Utils();
    
    public static void createTestData(){
        listEvents = createEvents(3);
        insert listEvents;
    }
    static testMethod void validate_ZTS_US_Internal_Attendee_Trigger_Helper (){
    test.startTest();
    createTestData();
    List<Event> listEvent = createEvent(listEvents);
    insert listEvent;
    List<ZTS_US_Internal_Attendee__c> lstattend=createInternalAttendees(listEvents);
    insert lstattend;
    ZTS_US_Internal_Attendee_Trigger_Helper.processDeleteRequest(lstattend);
    test.stopTest();
    
    }
    
    static testMethod void createInternalAttendeeOnEventInsertTest(){
        test.startTest();
        createTestData();
        USZTS_US_CustomEvents_Utils.createInternalAttendeeOnEventInsert(listEvents);
        test.stopTest();
    }
    
    static testMethod void processUpdatedRecordsTest(){
        test.startTest();
        createTestData();
        List<Event> listEvent = createEvent(listEvents);
        insert listEvent;
        USZTS_US_CustomEvents_Utils.processUpdatedRecords(listEvents);
        test.stopTest();
    }
    
    static testMethod void createEntitySubscriptionTest(){
        test.startTest();
        createTestData();
        USZTS_US_CustomEvents_Utils.createEntitySubscription(listEvents);
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
        USZTS_US_CustomEvents_Utils.updateEntitySubscription(listEvents,eventMap);
        test.stopTest();
    }
    
     static testMethod void createEntitySubscriptionForExpenseTest(){
        test.startTest();
        createTestData();
        List<ZTS_US_Expenses__c> listExpenses = createExpenses(listEvents);
        USZTS_US_CustomEvents_Utils.createEntitySubscriptionForExpense(listExpenses);
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
        USZTS_US_CustomEvents_Utils.updateEntitySubscriptionForExpense(listExpenses,expenseMap);
        test.stopTest();
    }
    
    static testMethod void updateExpensesonattendeesupdateTest(){
        test.startTest();
		ZTS_Events__c event1 = new ZTS_Events__c();
        event1.ZTS_US_Type__c = 'Full Day Wet Lab';
        event1.ZTS_US_Status__c = 'New';
        event1.ZTS_US_Start_Date__c = system.now();
        event1.ZTS_US_Name__c = 'Test Event';
        event1.ZTS_US_End_Date__c = system.now().addDays(1);
        event1.ZTS_US_Compliance_Status__c = 'Acceptable';
        event1.ZTS_US_Event_Category__c = 'Educational Meeting';
        event1.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
        event1.ZTS_US_Number_of_Attendees__c = 20;
       // event1.ZTS_US_Purpose_Agenda__c = 'Test purpose';
        event1.Purpose_Agenda__c = 'Test purpose';
        //adding market segmenting
        event1.ZTS_EU_Market__c = 'United States';
        Insert event1;
        ZTS_US_Expenses__c expense = new ZTS_US_Expenses__c(ZTS_US_Events__c=event1.Id,ZTS_US_Expense_Date__c=System.today(),
                                                           ZTS_US_Payment_Method__c='Meeting card',ZTS_US_Unit__c=20,ZTS_US_Cost__c=100,
                                                           ZTS_US_Event_Category__c='Educational Meeting',ZTS_US_Type__c='Meals');
        Insert expense;
        event1.ZTS_US_Number_of_Attendees__c=30;
        update event1;
        test.stopTest();
    }
    
   /*static testMethod void updateOldTotalSumExpensesTest(){
        test.startTest();
        createTestData();
        Map<ID, ZTS_Events__c> eventMap = new Map<ID, ZTS_Events__c>();
        List<ZTS_US_Expenses__c> listExpenses = createExpenses(listEvents);
        for(ZTS_US_Expenses__c exp : listExpenses){
            exp.ZTS_US_Cost__c = 10;
            exp.ZTS_US_Unit__c = 1;
            exp.ZTS_US_Payment_Method__c = 'Check';
            exp.ZTS_US_Type__c = 'Other';
            //exp.ZTS_US_Event_Category__c = 'Educational Meeting';
        }
        insert listExpenses;
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
        
        
        USZTS_US_CustomEvents_Utils.updateOldTotalSumExpenses(listEvents,eventMap);
        test.stopTest();
    }*/
    
    
    /*static testMethod void updateOldTotalSumExpensesTest(){
        test.startTest();
        List<ZTS_Events__c> lstevent = createEvents(3);
        insert lstevent;
        test.stopTest();
        
        }
        */
    
    static testMethod void RequireRejectionCommentTest(){
        test.startTest();
        createTestData();
        Map<ID, ZTS_Events__c> eventMap = new Map<ID, ZTS_Events__c>();
        String profileId = [select Id from Profile where Name='System Administrator' limit 1].Id;
        List<User> listUser = [select Id from User where Id <>: UserInfo.getUserId() and ProfileId =: profileId and IsActive=true AND ZTS_EU_Market__c = 'United States' limit 1];
        Integer counter = 0;
      
        
       /*ZTS_Events__c event1 = new ZTS_Events__c();
        event1.ZTS_US_Will_Firearms_be_Present__c = true;
        event1.ZTS_US_Type__c = 'Cattle General';
        event1.ZTS_US_Status__c = 'New';
        event1.ZTS_US_Start_Date__c = system.now();
        event1.ZTS_US_Name__c = 'Test Event';
        event1.ZTS_US_End_Date__c = system.today().addDays(1);
        event1.ZTS_US_Compliance_Status__c = 'Acceptable';
        event1.ZTS_US_Event_Category__c = 'Educational Meeting';
        event1.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
        event1.ZTS_US_Number_of_Attendees__c = 2;
        event1.ZTS_US_Purpose_Agenda__c = 'Test purpose';
        event1.ZTS_US_Status__c = 'New';
        */
         
        for(ZTS_Events__c events: listEvents){
            events.OwnerId = UserInfo.getUserId();
            eventMap.put(events.Id, events);
            //eventMap.put(events.Id, event1);
        }                    
         
        
        if(listUser != null && listUser.size() > 0 ){
            //listEvents[0].OwnerId = listUser[0].Id;
            listEvents[0].OwnerId = UserInfo.getUserId();
            //listEvents[0].ZTS_US_Status__c = 'Rejected';
            update listEvents[0];
        }
       /* Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(listEvents[0].id);
        Approval.ProcessResult result = Approval.process(req1);
        */
        
        USZTS_US_CustomEvents_Utils.RequireRejectionComment(listEvents,eventMap);
       // USZTS_US_CustomEvents_Utils.updateOldTotalSumExpenses(listEvents,eventMap);
        test.stopTest();
    }
    
    /*static testMethod void RequireRejectionCommentTest1(){
        test.startTest();
     
        List<ZTS_Events__c> lstevent = createEvents(3);
        insert lstevent;
        
        
         
        for(ZTS_Events__c events: lstevent){
            events.ZTS_US_Status__c = 'Rejected';
            
        }                    
         update lstevent;
        
       test.stopTest();
    }
    */
    
    /*-------------insert ZTS_Events__c object records---------------*/
    public static List<ZTS_Events__c> createEvents(Integer counter){ 
        List<ZTS_Events__c> listEvents1 = new List<ZTS_Events__c>();
        for(Integer i=0; i< counter; i++){
            ZTS_Events__c event = new ZTS_Events__c();
            event.ZTS_US_Will_Firearms_be_Present__c = true;
            event.ZTS_US_Type__c = 'Cattle General';
            //event.ZTS_US_Total_Number_of_Invitees__c = i;
            event.ZTS_US_Status__c = 'New';
            event.ZTS_US_Start_Date__c = system.today().addDays(1);
            //event.ZTS_US_Sum_of_Total__c = 100;
            if( Math.mod(2,(i+1)) ==0){
                event.ZTS_US_Is_Event_Private__c = true;
            }else{
                event.ZTS_US_Is_Event_Private__c = false;
            }
            event.ZTS_US_Name__c = 'Test Event'+i;
            event.ZTS_US_End_Date__c = system.today().addDays(i+1);
            event.ZTS_US_Compliance_Status__c = 'Acceptable';
            event.ZTS_US_Event_Category__c = 'Educational Meeting';
            event.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
            event.ZTS_US_Number_of_Attendees__c = i+2;
          //  event.ZTS_US_Purpose_Agenda__c = 'Test purpose';
            event.Purpose_Agenda__c = 'Test purpose';
            //adding market segmenting
            event.ZTS_EU_Market__c = 'United States';
            listEvents1.add(event);
        }
        return listEvents1;
    }
    
    /*-------------insert Events object records---------------*/
    public static List<Event> createEvent(List<ZTS_Events__c> listEvents1){ 
        List<Event> listEvent = new List<Event>();
        for(ZTS_Events__c events: listEvents1){
           
                Event eve = new Event(ZTS_US_EventCreatedByTrigger__c=true, WhatId=events.Id,DurationInMinutes=10,ActivityDateTime=system.now());
                listEvent.add(eve);
            
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
                                List<Contact> conList =  ZTS_DataUtilityTest.createContactRecord(1);
                                conList[0].ZTS_EU_Market__c = 'United States';
                                insert conList;
                                for(ZTS_Events__c event: listEvnts){
                                                ZTS_US_Internal_Attendee__c evntAtten = new ZTS_US_Internal_Attendee__c(ZTS_US_User__c=Userinfo.getUserId(), ZTS_US_Events__c=event.Id);
                                                listEventAttendees.add(evntAtten);
                                }
                                return listEventAttendees;
                }
    
    
    }