/*******************************************************************************************************************************************
* File Name     :   ZTS_US_Trigger_Create_Expense_RecordTest
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Akanksha             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_US_Trigger_Create_Expense_RecordTest 
{   
    static List<ZTS_Events__c> listEvents; 

    public static void createTestData(){
        listEvents = createEvents(1);
        insert listEvents;
        
        //listRecType = createRecordType(1);
        //insert listRecType;
    }
    static testMethod void validate_ZTS_US_Trigger_Create_Expense_Record () {
        test.startTest();
        createTestData();
        
        List<Contact> conList = ZTS_EU_DataUtilityTest.createContactRecord(1);
        conList[0].ZTS_EU_Market__c = 'United States';
        insert conList;
        
        List<ZTS_US_Expenses__c> listExpenses=createExpenses(listEvents);
        //insert listExpenses;
        /*ZTS_US_Expenses__c exp;
        exp.ZTS_US_Comments__c='New Comments';
        listExpenses.add(exp);
        update listExpenses;*/
        system.debug('--------listEvents[0]: ' + listEvents[0].ZTS_US_Start_Date__c+'---'+listEvents[0].ZTS_US_End_Date__c+'------'+conList[0].Id);
        
        ZTS_US_Speaker__c speakerrec=new ZTS_US_Speaker__c(ZTS_US_Event__c=listEvents[0].Id,ZTS_US_Speaker_Fee__c=500,ZTS_US_Speaking_Date__c=System.today().addDays(1),ZTS_US_Contact__c=conList[0].Id);
        insert speakerrec;
        
        speakerrec.ZTS_US_Speaker_Fee__c=1000;
        update speakerrec;
        
        List<ZTS_US_Speaker__c> speakerList=new List<ZTS_US_Speaker__c>();
        speakerList.add(speakerrec);
        
        USZTS_US_Class_Expense_Trigger_Helper.updateExpenseRecord(speakerList);
        
        List<Id> speakerIdList=new List<Id>();
        speakerIdList.add(speakerrec.Id);
        delete speakerrec;
        
        ZTS_US_Class_Expense_Trigger_Helper.deleteSpeakerExpense(speakerIdList);
        
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
            event.ZTS_US_End_Date__c = system.today().addDays(i+2);
            event.ZTS_US_Compliance_Status__c = 'Acceptable';
            event.ZTS_US_Event_Category__c = 'Educational Meeting';
            event.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
            event.ZTS_US_Number_of_Attendees__c = i+1;
           // event.ZTS_US_Purpose_Agenda__c = 'Test purpose';
            event.Purpose_Agenda__c = 'Test purpose';
            event.ZTS_EU_Market__c = 'United States';
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
            ZTS_US_Expenses__c expense = new ZTS_US_Expenses__c(ZTS_US_Events__c=events.Id,ZTS_US_Type__c='Educational Meeting',ZTS_US_Cost__c=100,ZTS_US_Unit__c=5,    ZTS_US_Payment_Method__c='Check',ZTS_US_Payment_Status__c='Pending');
            listExpenses.add(expense);
        }
        return listExpenses;
    }
}